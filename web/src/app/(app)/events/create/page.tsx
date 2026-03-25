"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { useEvents } from "@/hooks/use-events";
import { CreateEventForm } from "@/components/create-event-form";
import { ApiError } from "@/lib/api-client";
import type { EventCreate } from "@/lib/types";

export default function CreateEventPage() {
  const { token } = useAuth();
  const { createEvent } = useEvents(token);
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  async function handleSubmit(event: EventCreate) {
    setLoading(true);
    setError("");
    try {
      const created = await createEvent(event);
      router.push(`/events/${created.id}`);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to create event");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="py-4">
      <CreateEventForm onSubmit={handleSubmit} loading={loading} error={error} />
    </div>
  );
}
