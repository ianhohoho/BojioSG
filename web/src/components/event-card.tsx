"use client";

import Link from "next/link";
import { MapPin, Calendar, Users } from "lucide-react";
import type { EventResponse } from "@/lib/types";
import { getSportInfo } from "@/lib/sport-constants";
import { formatEventDate, formatPrice } from "@/lib/date-utils";

interface EventCardProps {
  event: EventResponse;
}

function StatusBadge({ event }: { event: EventResponse }) {
  if (event.is_organizer) {
    const pendingCount = event.participants?.filter((p) => p.status === "pending").length ?? 0;
    const paymentSubmittedCount = event.participants?.filter((p) => p.status === "payment_submitted").length ?? 0;
    const actionCount = pendingCount + paymentSubmittedCount;
    return (
      <span className="inline-flex items-center rounded-full bg-muted px-2 py-0.5 text-[11px] font-medium text-muted-foreground">
        Organiser{actionCount > 0 ? ` \u00b7 ${actionCount}` : ""}
      </span>
    );
  }
  const statusMap: Record<string, { label: string; classes: string }> = {
    pending: { label: "Pending", classes: "bg-amber-100 dark:bg-amber-400/10 text-amber-700 dark:text-amber-400" },
    pending_payment: { label: "Pay Now", classes: "bg-sky-100 dark:bg-sky-400/10 text-sky-700 dark:text-sky-400" },
    payment_submitted: { label: "Paid", classes: "bg-teal-100 dark:bg-teal-400/10 text-teal-700 dark:text-teal-400" },
    approved: { label: "Joined", classes: "bg-lime-100 dark:bg-lime-400/10 text-lime-700 dark:text-lime-400" },
  };
  const status = event.join_status ? statusMap[event.join_status] : null;
  if (!status) return null;
  return (
    <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-[11px] font-medium ${status.classes}`}>
      {status.label}
    </span>
  );
}

export function EventCard({ event }: EventCardProps) {
  const sport = getSportInfo(event.sport_type);
  const spotsLeft = event.max_participants - event.current_participants;
  const fillPercent = Math.min((event.current_participants / event.max_participants) * 100, 100);

  return (
    <Link href={`/events/${event.id}`} className="group block">
      <div className="rounded-xl border bg-card p-5 transition-all duration-200 hover:border-primary/30 hover:shadow-[0_0_24px_-6px] hover:shadow-primary/10 hover:-translate-y-0.5">
        {/* Header */}
        <div className="flex items-center justify-between gap-2 mb-3">
          <span className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium ${sport.badgeBg} ${sport.textColor}`}>
            {sport.emoji} {sport.label}
          </span>
          <StatusBadge event={event} />
        </div>

        {/* Title */}
        <h3 className="font-heading font-semibold text-[15px] leading-snug line-clamp-1 mb-3 group-hover:text-primary transition-colors">
          {event.title}
        </h3>

        {/* Meta */}
        <div className="space-y-1.5 text-sm">
          <div className="flex items-center gap-2.5 text-foreground">
            <Calendar className="h-3.5 w-3.5 shrink-0 text-primary" />
            <span className="font-medium">{formatEventDate(event.date_time)}</span>
          </div>
          <div className="flex items-center gap-2.5 text-muted-foreground">
            <MapPin className="h-3.5 w-3.5 shrink-0 opacity-60" />
            <span className="line-clamp-1">{event.location}</span>
          </div>
        </div>

        {/* Footer */}
        <div className="mt-4 pt-3 border-t border-border/50">
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-1.5 text-sm">
              <Users className="h-3.5 w-3.5 text-muted-foreground opacity-60" />
              <span className="tabular-nums">
                <span className={`font-medium ${spotsLeft <= 0 ? "text-red-600 dark:text-red-400" : ""}`}>{event.current_participants}</span>
                <span className="text-muted-foreground">/{event.max_participants}</span>
              </span>
              {spotsLeft === 2 && (
                <span className="text-yellow-600 dark:text-yellow-400 text-xs font-medium ml-1">
                  2 left
                </span>
              )}
              {spotsLeft === 1 && (
                <span className="text-orange-600 dark:text-orange-400 text-xs font-medium ml-1">
                  1 left
                </span>
              )}
              {spotsLeft <= 0 && (
                <span className="text-red-600 dark:text-red-400 text-xs font-medium ml-1">Full</span>
              )}
            </div>
            <span className="text-sm font-semibold tabular-nums">
              {formatPrice(event.price)}
            </span>
          </div>
          <div className="h-1 w-full rounded-full bg-muted overflow-hidden">
            <div
              className={`h-full rounded-full transition-all duration-700 ease-out ${
                spotsLeft <= 0
                  ? "bg-red-500 dark:bg-red-400"
                  : spotsLeft === 1
                  ? "bg-orange-500 dark:bg-orange-400"
                  : spotsLeft === 2
                  ? "bg-yellow-500 dark:bg-yellow-400"
                  : "bg-green-500 dark:bg-green-400"
              }`}
              style={{ width: `${fillPercent}%` }}
            />
          </div>
        </div>
      </div>
    </Link>
  );
}
