from datetime import datetime, timezone

from sqlalchemy import Column, DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    nickname = Column(String, nullable=True)
    phone_number = Column(String, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    organized_events = relationship("Event", back_populates="organizer")
    participations = relationship("EventParticipant", back_populates="user")


class Event(Base):
    __tablename__ = "events"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=False)
    sport_type = Column(String, nullable=False)
    location = Column(String, nullable=False)
    date_time = Column(DateTime, nullable=False)
    price = Column(Float, nullable=False)
    max_participants = Column(Integer, nullable=False)
    organizer_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    organizer = relationship("User", back_populates="organized_events")
    participants = relationship("EventParticipant", back_populates="event")


class EventParticipant(Base):
    __tablename__ = "event_participants"

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(Integer, ForeignKey("events.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    status = Column(String, nullable=False, default="pending")
    joined_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    event = relationship("Event", back_populates="participants")
    user = relationship("User", back_populates="participations")
