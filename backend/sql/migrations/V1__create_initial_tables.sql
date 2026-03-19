-- Baseline migration: initial schema for BojioSG
-- This file documents the schema that was already applied via Supabase apply_migration.
-- Flyway will NOT execute this (baseline marks it as already applied).

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR NOT NULL UNIQUE,
    password_hash VARCHAR NOT NULL,
    nickname VARCHAR,
    phone_number VARCHAR,
    created_at TIMESTAMP DEFAULT (NOW() AT TIME ZONE 'utc')
);

CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    title VARCHAR NOT NULL,
    description VARCHAR NOT NULL,
    sport_type VARCHAR NOT NULL,
    location VARCHAR NOT NULL,
    date_time TIMESTAMP NOT NULL,
    price FLOAT NOT NULL,
    max_participants INTEGER NOT NULL,
    organizer_id INTEGER NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT (NOW() AT TIME ZONE 'utc')
);

CREATE TABLE event_participants (
    id SERIAL PRIMARY KEY,
    event_id INTEGER NOT NULL REFERENCES events(id),
    user_id INTEGER NOT NULL REFERENCES users(id),
    status VARCHAR NOT NULL DEFAULT 'pending',
    joined_at TIMESTAMP DEFAULT (NOW() AT TIME ZONE 'utc')
);

CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    event_id INTEGER NOT NULL REFERENCES events(id),
    type VARCHAR NOT NULL,
    message VARCHAR NOT NULL,
    reason VARCHAR,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT (NOW() AT TIME ZONE 'utc')
);

CREATE INDEX idx_event_participants_event_id ON event_participants(event_id);
CREATE INDEX idx_event_participants_user_id ON event_participants(user_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_events_organizer_id ON events(organizer_id);
