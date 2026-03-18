from datetime import datetime

from pydantic import BaseModel


# Auth schemas
class UserCreate(BaseModel):
    username: str
    password: str


class UserLogin(BaseModel):
    username: str
    password: str


class UserResponse(BaseModel):
    id: int
    username: str
    created_at: datetime

    model_config = {"from_attributes": True}


class Token(BaseModel):
    access_token: str
    token_type: str


# Event schemas
class EventCreate(BaseModel):
    title: str
    description: str
    sport_type: str
    location: str
    date_time: datetime
    price: float
    max_participants: int


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
    created_at: datetime

    model_config = {"from_attributes": True}


class JoinResponse(BaseModel):
    message: str
