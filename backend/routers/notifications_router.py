from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload

from auth import get_current_user
from database import get_db
from models import Notification, User
from schemas import NotificationResponse

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("", response_model=list[NotificationResponse])
def list_notifications(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    notifications = (
        db.query(Notification)
        .options(joinedload(Notification.event))
        .filter(Notification.user_id == current_user.id)
        .order_by(Notification.created_at.desc())
        .all()
    )
    return [
        NotificationResponse(
            id=n.id,
            event_id=n.event_id,
            event_title=n.event.title,
            type=n.type,
            message=n.message,
            reason=n.reason,
            is_read=n.is_read,
            created_at=n.created_at,
        )
        for n in notifications
    ]


@router.put("/{notification_id}/read", response_model=NotificationResponse)
def mark_as_read(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    notification = (
        db.query(Notification)
        .options(joinedload(Notification.event))
        .filter(Notification.id == notification_id)
        .first()
    )
    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found",
        )
    if notification.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only mark your own notifications as read",
        )

    notification.is_read = True
    db.commit()
    db.refresh(notification)

    return NotificationResponse(
        id=notification.id,
        event_id=notification.event_id,
        event_title=notification.event.title,
        type=notification.type,
        message=notification.message,
        reason=notification.reason,
        is_read=notification.is_read,
        created_at=notification.created_at,
    )
