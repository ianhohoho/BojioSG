from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from auth import get_current_user
from database import get_db
from models import Event, EventParticipant, User
from schemas import EventCreate, EventResponse, JoinResponse

router = APIRouter(prefix="/events", tags=["events"])


def _event_to_response(event: Event) -> EventResponse:
    return EventResponse(
        id=event.id,
        title=event.title,
        description=event.description,
        sport_type=event.sport_type,
        location=event.location,
        date_time=event.date_time,
        price=event.price,
        max_participants=event.max_participants,
        current_participants=len(event.participants),
        organizer_id=event.organizer_id,
        created_at=event.created_at,
    )


@router.get("", response_model=list[EventResponse])
def list_events(db: Session = Depends(get_db)):
    events = db.query(Event).order_by(Event.date_time).all()
    return [_event_to_response(e) for e in events]


@router.get("/{event_id}", response_model=EventResponse)
def get_event(event_id: int, db: Session = Depends(get_db)):
    event = db.query(Event).filter(Event.id == event_id).first()
    if not event:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found",
        )
    return _event_to_response(event)


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
    db.commit()
    db.refresh(event)
    return _event_to_response(event)


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

    # Check if already joined
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
            detail="You have already joined this event",
        )

    # Check capacity
    participant_count = (
        db.query(EventParticipant)
        .filter(EventParticipant.event_id == event_id)
        .count()
    )
    if participant_count >= event.max_participants:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This event is full",
        )

    participant = EventParticipant(
        event_id=event_id,
        user_id=current_user.id,
    )
    db.add(participant)
    db.commit()

    return JoinResponse(message="Successfully joined the event!")
