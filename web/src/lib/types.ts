// Auth
export interface UserCreate {
  username: string;
  password: string;
}

export interface Token {
  access_token: string;
  token_type: string;
  user_id: number;
  username: string;
  nickname: string | null;
}

export interface ProfileResponse {
  id: number;
  username: string;
  nickname: string | null;
  phone_number: string | null;
  created_at: string;
}

export interface ProfileUpdate {
  nickname?: string | null;
  phone_number?: string | null;
}

// Events
export interface EventCreate {
  title: string;
  description: string;
  sport_type: string;
  location: string;
  date_time: string;
  price: number;
  max_participants: number;
}

export interface ParticipantResponse {
  id: number;
  username: string;
  phone_number: string | null;
  status: string;
  joined_at: string;
}

export interface EventResponse {
  id: number;
  title: string;
  description: string;
  sport_type: string;
  location: string;
  date_time: string;
  price: number;
  max_participants: number;
  current_participants: number;
  organizer_id: number;
  organizer_username: string;
  organizer_phone_number: string | null;
  is_organizer: boolean | null;
  join_status: string | null;
  participants: ParticipantResponse[] | null;
  created_at: string;
}

export interface JoinResponse {
  message: string;
  status: string;
}

export interface ParticipantActionResponse {
  message: string;
}

export interface RemoveParticipantRequest {
  reason?: string | null;
}

// Notifications
export interface NotificationResponse {
  id: number;
  event_id: number;
  event_title: string;
  type: string;
  message: string;
  reason: string | null;
  is_read: boolean;
  created_at: string;
}
