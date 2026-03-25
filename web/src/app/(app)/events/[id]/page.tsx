"use client";

import { useEffect, useState, useCallback, use } from "react";
import { useRouter } from "next/navigation";
import { ArrowLeft, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useAuth } from "@/lib/auth-context";
import { useEvents } from "@/hooks/use-events";
import { EventDetailInfo } from "@/components/event-detail-info";
import { ParticipantSection } from "@/components/participant-section";
import { JoinActionArea } from "@/components/join-action-area";
import type { EventResponse } from "@/lib/types";

export default function EventDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const { token } = useAuth();
  const router = useRouter();
  const {
    fetchEvent,
    joinEvent,
    approveParticipant,
    notifyPayment,
    confirmPayment,
    removeParticipant,
    leaveEvent,
  } = useEvents(token);

  const [event, setEvent] = useState<EventResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const loadEvent = useCallback(async () => {
    try {
      const data = await fetchEvent(Number(id));
      setEvent(data);
      setError("");
    } catch {
      setError("Failed to load event");
    } finally {
      setLoading(false);
    }
  }, [id, fetchEvent]);

  useEffect(() => {
    loadEvent();
  }, [loadEvent]);

  if (loading) {
    return (
      <div className="flex items-center justify-center py-24">
        <Loader2 className="h-6 w-6 animate-spin text-primary" />
      </div>
    );
  }

  if (error || !event) {
    return (
      <div className="text-center py-20">
        <div className="inline-flex h-16 w-16 items-center justify-center rounded-xl bg-destructive/10 mb-4">
          <span className="text-2xl">😕</span>
        </div>
        <p className="font-heading font-semibold mb-1">{error || "Event not found"}</p>
        <p className="text-muted-foreground text-sm mb-4">
          This event may have been removed
        </p>
        <Button variant="outline" className="rounded-lg" onClick={() => router.back()}>
          Go Back
        </Button>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <Button
        variant="ghost"
        size="sm"
        onClick={() => router.push("/events")}
        className="gap-1.5 rounded-lg text-muted-foreground hover:text-foreground -ml-2"
      >
        <ArrowLeft className="h-4 w-4" />
        Home
      </Button>

      <EventDetailInfo event={event} />

      {event.is_organizer && event.participants && (
        <ParticipantSection
          participants={event.participants}
          onApprove={async (userId) => {
            await approveParticipant(event.id, userId);
            await loadEvent();
          }}
          onConfirmPayment={async (userId) => {
            await confirmPayment(event.id, userId);
            await loadEvent();
          }}
          onRemove={async (userId, reason) => {
            await removeParticipant(event.id, userId, reason);
            await loadEvent();
          }}
        />
      )}

      {!event.is_organizer && (
        <JoinActionArea
          event={event}
          onJoin={async () => {
            await joinEvent(event.id);
            await loadEvent();
          }}
          onNotifyPayment={async () => {
            await notifyPayment(event.id);
            await loadEvent();
          }}
          onLeave={async () => {
            await leaveEvent(event.id);
            await loadEvent();
          }}
        />
      )}
    </div>
  );
}
