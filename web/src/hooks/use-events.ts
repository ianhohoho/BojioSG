"use client";

import { useState, useCallback } from "react";
import { apiRequest } from "@/lib/api-client";
import type {
  EventResponse,
  EventCreate,
  JoinResponse,
  ParticipantActionResponse,
  RemoveParticipantRequest,
} from "@/lib/types";

export function useEvents(token: string | null) {
  const [events, setEvents] = useState<EventResponse[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const fetchEvents = useCallback(
    async (sportType?: string) => {
      setLoading(true);
      setError("");
      try {
        const query = sportType ? `?sport_type=${sportType}` : "";
        const data = await apiRequest<EventResponse[]>(`/events${query}`, {
          token,
        });
        setEvents(data);
      } catch {
        setError("Failed to load events");
      } finally {
        setLoading(false);
      }
    },
    [token]
  );

  const fetchEvent = useCallback(
    async (id: number) => {
      const data = await apiRequest<EventResponse>(`/events/${id}`, { token });
      return data;
    },
    [token]
  );

  const createEvent = useCallback(
    async (event: EventCreate) => {
      return apiRequest<EventResponse>("/events", {
        method: "POST",
        body: event,
        token,
      });
    },
    [token]
  );

  const joinEvent = useCallback(
    async (id: number) => {
      return apiRequest<JoinResponse>(`/events/${id}/join`, {
        method: "POST",
        token,
      });
    },
    [token]
  );

  const approveParticipant = useCallback(
    async (eventId: number, userId: number) => {
      return apiRequest<ParticipantActionResponse>(
        `/events/${eventId}/participants/${userId}/approve`,
        { method: "PUT", token }
      );
    },
    [token]
  );

  const notifyPayment = useCallback(
    async (eventId: number) => {
      return apiRequest<ParticipantActionResponse>(
        `/events/${eventId}/notify-payment`,
        { method: "PUT", token }
      );
    },
    [token]
  );

  const confirmPayment = useCallback(
    async (eventId: number, userId: number) => {
      return apiRequest<ParticipantActionResponse>(
        `/events/${eventId}/participants/${userId}/confirm-payment`,
        { method: "PUT", token }
      );
    },
    [token]
  );

  const removeParticipant = useCallback(
    async (eventId: number, userId: number, reason?: string) => {
      const body: RemoveParticipantRequest = reason ? { reason } : {};
      return apiRequest<ParticipantActionResponse>(
        `/events/${eventId}/participants/${userId}`,
        { method: "DELETE", body, token }
      );
    },
    [token]
  );

  const leaveEvent = useCallback(
    async (eventId: number) => {
      return apiRequest<ParticipantActionResponse>(`/events/${eventId}/leave`, {
        method: "DELETE",
        token,
      });
    },
    [token]
  );

  return {
    events,
    loading,
    error,
    fetchEvents,
    fetchEvent,
    createEvent,
    joinEvent,
    approveParticipant,
    notifyPayment,
    confirmPayment,
    removeParticipant,
    leaveEvent,
  };
}
