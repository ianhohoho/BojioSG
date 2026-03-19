from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload

from auth import get_current_user, get_optional_user
from database import get_db
from models import Event, EventParticipant, Notification, User
from schemas import (
    EventCreate,
    EventResponse,
    JoinResponse,
    ParticipantActionResponse,
    ParticipantResponse,
    RemoveParticipantRequest,
)

router = APIRouter(prefix="/events", tags=["events"])


def _event_to_response(event: Event, current_user: User | None = None) -> EventResponse:
    is_organizer = None
    join_status = None
    participants = None

    approved_count = sum(1 for p in event.participants if p.status == "approved")

    if current_user is not None:
        is_organizer = event.organizer_id == current_user.id
        user_participation = next(
            (p for p in event.participants if p.user_id == current_user.id), None
        )
        join_status = user_participation.status if user_participation else None
        if is_organizer:
            participants = [
                ParticipantResponse(
                    id=p.user.id,
                    username=p.user.nickname or p.user.username,
                    phone_number=p.user.phone_number,
                    status=p.status,
                    joined_at=p.joined_at,
                )
                for p in event.participants
            ]

    return EventResponse(
        id=event.id,
        title=event.title,
        description=event.description,
        sport_type=event.sport_type,
        location=event.location,
        date_time=event.date_time,
        price=event.price,
        max_participants=event.max_participants,
        current_participants=approved_count,
        organizer_id=event.organizer_id,
        organizer_username=event.organizer.nickname or event.organizer.username,
        organizer_phone_number=event.organizer.phone_number,
        is_organizer=is_organizer,
        join_status=join_status,
        participants=participants,
        created_at=event.created_at,
    )


def _get_event_or_404(db: Session, event_id: int) -> Event:
    event = (
        db.query(Event)
        .options(
            joinedload(Event.organizer),
            joinedload(Event.participants).joinedload(EventParticipant.user),
        )
        .filter(Event.id == event_id)
        .first()
    )
    if not event:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found",
        )
    return event


@router.get("", response_model=list[EventResponse])
def list_events(
    sport_type: str | None = None,
    db: Session = Depends(get_db),
    current_user: User | None = Depends(get_optional_user),
):
    query = db.query(Event).options(
        joinedload(Event.organizer),
        joinedload(Event.participants).joinedload(EventParticipant.user),
    )
    if sport_type:
        query = query.filter(Event.sport_type == sport_type)
    events = query.order_by(Event.date_time).all(
    )
    return [_event_to_response(e, current_user) for e in events]


@router.get("/{event_id}", response_model=EventResponse)
def get_event(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User | None = Depends(get_optional_user),
):
    event = _get_event_or_404(db, event_id)
    return _event_to_response(event, current_user)


@router.post("", response_model=EventResponse, status_code=status.HTTP_201_CREATED)
def create_event(
    event_data: EventCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    event = Event(
        title=event_data.title,
        description=event_data.description,
        sport_type=event_data.sport_type,
        location=event_data.location,
        date_time=event_data.date_time,
        price=event_data.price,
        max_participants=event_data.max_participants,
        organizer_id=current_user.id,
    )
    db.add(event)
    db.flush()

    organizer_participant = EventParticipant(
        event_id=event.id,
        user_id=current_user.id,
        status="approved",
    )
    db.add(organizer_participant)
    db.commit()
    db.refresh(event)
    return _event_to_response(event, current_user)


@router.post("/{event_id}/join", response_model=JoinResponse)
def join_event(
    event_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    event = db.query(Event).filter(Event.id == event_id).first()
    if not event:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found",
        )

    # Organizer cannot join their own event
    if event.organizer_id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Organizers cannot join their own event",
        )

    # Check if already joined or pending
    existing = (
        db.query(EventParticipant)
        .filter(
            EventParticipant.event_id == event_id,
            EventParticipant.user_id == current_user.id,
        )
        .first()
    )
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You have already requested to join this event",
        )

    # Check capacity (only approved count toward capacity)
    approved_count = (
        db.query(EventParticipant)
        .filter(
            EventParticipant.event_id == event_id,
            EventParticipant.status == "approved",
        )
        .count()
    )
    if approved_count >= event.max_participants:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This event is full",
        )

    participant = EventParticipant(
        event_id=event_id,
        user_id=current_user.id,
        status="pending",
    )
    db.add(participant)

    requester_name = current_user.nickname or current_user.username
    notification = Notification(
        user_id=event.organizer_id,
        event_id=event_id,
        type="join_request",
        message=f"{requester_name} requested to join '{event.title}'",
    )
    db.add(notification)
    db.commit()

    return JoinResponse(
        message="Your request to join has been submitted. Waiting for organizer approval.",
        status="pending",
    )


@router.put(
    "/{event_id}/participants/{user_id}/approve",
    response_model=ParticipantActionResponse,
)
def approve_participant(
    event_id: int,
    user_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    event = db.query(Event).filter(Event.id == event_id).first()
    if not event:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found",
        )
    if event.organizer_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the organizer can approve participants",
        )

    participation = (
        db.query(EventParticipant)
        .filter(
            EventParticipant.event_id == event_id,
            EventParticipant.user_id == user_id,
        )
        .first()
    )
    if not participation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Participant not found",
        )
    if participation.status in ("pending_payment", "payment_submitted", "approved"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Participant is already approved",
        )

    participation.status = "pending_payment"
    organizer = db.query(User).filter(User.id == event.organizer_id).first()
    organizer_name = organizer.nickname or organizer.username
    organizer_phone = organizer.phone_number or "N/A"
    notification = Notification(
        user_id=user_id,
        event_id=event_id,
        type="payment_required",
        message=f"You've been approved for '{event.title}' — please pay ${event.price:.2f} via PayNow to {organizer_phone} ({organizer_name})",
    )
    db.add(notification)
    db.commit()

    return ParticipantActionResponse(message="Participant approved — awaiting payment")


@router.put("/{event_id}/notify-payment", response_model=ParticipantActionResponse)
def notify_payment(
    event_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    event = db.query(Event).filter(Event.id == event_id).first()
    if not event:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found",
        )

    participation = (
        db.query(EventParticipant)
        .filter(
            EventParticipant.event_id == event_id,
            EventParticipant.user_id == current_user.id,
        )
        .first()
    )
    if not participation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Participant not found",
        )
    if participation.status != "pending_payment":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You are not awaiting payment for this event",
        )

    participation.status = "payment_submitted"
    payer_name = current_user.nickname or current_user.username
    notification = Notification(
        user_id=event.organizer_id,
        event_id=event_id,
        type="payment_submitted",
        message=f"{payer_name} has made payment for '{event.title}'",
    )
    db.add(notification)
    db.commit()

    return ParticipantActionResponse(
        message="Organiser has been notified of your payment"
    )


@router.put(
    "/{event_id}/participants/{user_id}/confirm-payment",
    response_model=ParticipantActionResponse,
)
def confirm_payment(
    event_id: int,
    user_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    event = db.query(Event).filter(Event.id == event_id).first()
    if not event:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found",
        )
    if event.organizer_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the organizer can confirm payment",
        )

    participation = (
        db.query(EventParticipant)
        .filter(
            EventParticipant.event_id == event_id,
            EventParticipant.user_id == user_id,
        )
        .first()
    )
    if not participation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Participant not found",
        )
    if participation.status not in ("pending_payment", "payment_submitted"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Participant is not awaiting payment",
        )

    # Check capacity before confirming
    approved_count = (
        db.query(EventParticipant)
        .filter(
            EventParticipant.event_id == event_id,
            EventParticipant.status == "approved",
        )
        .count()
    )
    if approved_count >= event.max_participants:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This event is full",
        )

    participation.status = "approved"
    notification = Notification(
        user_id=user_id,
        event_id=event_id,
        type="approved",
        message=f"Your payment for '{event.title}' has been confirmed — you're in!",
    )
    db.add(notification)
    db.commit()

    return ParticipantActionResponse(message="Payment confirmed — participant approved")


@router.delete(
    "/{event_id}/participants/{user_id}",
    response_model=ParticipantActionResponse,
)
def remove_participant(
    event_id: int,
    user_id: int,
    body: RemoveParticipantRequest | None = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    event = db.query(Event).filter(Event.id == event_id).first()
    if not event:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found",
        )
    if event.organizer_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the organizer can remove participants",
        )

    participation = (
        db.query(EventParticipant)
        .filter(
            EventParticipant.event_id == event_id,
            EventParticipant.user_id == user_id,
        )
        .first()
    )
    if not participation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Participant not found",
        )

    reason = body.reason if body else None
    if participation.status == "pending":
        notif_type = "rejected"
        notif_message = f"Your request to join '{event.title}' was declined"
    elif participation.status in ("pending_payment", "payment_submitted"):
        notif_type = "removed"
        notif_message = f"You were removed from '{event.title}'"
    else:
        notif_type = "removed"
        notif_message = f"You were removed from '{event.title}'"
    notification = Notification(
        user_id=user_id,
        event_id=event_id,
        type=notif_type,
        message=notif_message,
        reason=reason,
    )
    db.add(notification)
    db.delete(participation)
    db.commit()

    return ParticipantActionResponse(message="Participant removed")


@router.delete("/{event_id}/leave", response_model=ParticipantActionResponse)
def leave_event(
    event_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    event = db.query(Event).filter(Event.id == event_id).first()
    if not event:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found",
        )

    participation = (
        db.query(EventParticipant)
        .filter(
            EventParticipant.event_id == event_id,
            EventParticipant.user_id == current_user.id,
        )
        .first()
    )
    if not participation:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You are not a participant of this event",
        )

    leaver_name = current_user.nickname or current_user.username
    notification = Notification(
        user_id=event.organizer_id,
        event_id=event_id,
        type="withdrawn",
        message=f"{leaver_name} withdrew from '{event.title}'",
    )
    db.add(notification)
    db.delete(participation)
    db.commit()

    return ParticipantActionResponse(message="You have left the event")
