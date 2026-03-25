from datetime import datetime

from pydantic import BaseModel


# Auth schemas
class ProfileResponse(BaseModel):
    id: int
    username: str | None = None
    email: str | None = None
    nickname: str | None = None
    phone_number: str | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class ProfileUpdate(BaseModel):
    nickname: str | None = None
    phone_number: str | None = None


# Event schemas
class EventCreate(BaseModel):
    title: str
    description: str
    sport_type: str
    location: str
    date_time: datetime
    price: float
    max_participants: int


class ParticipantResponse(BaseModel):
    id: int
    username: str
    phone_number: str | None = None
    status: str
    joined_at: datetime

    model_config = {"from_attributes": True}


class EventResponse(BaseModel):
    id: int
    title: str
    description: str
    sport_type: str
    location: str
    date_time: datetime
    price: float
    max_participants: int
    current_participants: int
    organizer_id: int
    organizer_username: str
    organizer_phone_number: str | None = None
    is_organizer: bool | None = None
    join_status: str | None = None
    participants: list[ParticipantResponse] | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class JoinResponse(BaseModel):
    message: str
    status: str


class ParticipantActionResponse(BaseModel):
    message: str


class RemoveParticipantRequest(BaseModel):
    reason: str | None = None


class NotificationResponse(BaseModel):
    id: int
    event_id: int
    event_title: str
    type: str
    message: str
    reason: str | None = None
    is_read: bool
    created_at: datetime

    model_config = {"from_attributes": True}
