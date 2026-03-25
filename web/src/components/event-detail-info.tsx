"use client";

import { Calendar, MapPin, Users, DollarSign, User } from "lucide-react";
import type { EventResponse } from "@/lib/types";
import { getSportInfo } from "@/lib/sport-constants";
import { formatEventDate, formatPrice, getCapacityTextColor } from "@/lib/date-utils";
import { CapacityBar } from "@/components/capacity-bar";

interface EventDetailInfoProps {
  event: EventResponse;
}

export function EventDetailInfo({ event }: EventDetailInfoProps) {
  const sport = getSportInfo(event.sport_type);
  const spotsLeft = event.max_participants - event.current_participants;

  return (
    <div className="space-y-5 animate-fade-in">
      {/* Sport badge + status */}
      <div className="flex items-center gap-2 flex-wrap">
        <span className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-sm font-medium ${sport.badgeBg} ${sport.textColor}`}>
          {sport.emoji} {sport.label}
        </span>
        {spotsLeft <= 0 && (
          <span className="rounded-full bg-red-100 dark:bg-red-400/10 px-2.5 py-1 text-xs font-medium text-red-700 dark:text-red-400">
            Full
          </span>
        )}
        {spotsLeft === 1 && (
          <span className="rounded-full bg-orange-100 dark:bg-orange-400/10 px-2.5 py-1 text-xs font-medium text-orange-700 dark:text-orange-400">
            1 spot left
          </span>
        )}
        {spotsLeft === 2 && (
          <span className="rounded-full bg-yellow-100 dark:bg-yellow-400/10 px-2.5 py-1 text-xs font-medium text-yellow-700 dark:text-yellow-400">
            2 spots left
          </span>
        )}
      </div>

      {/* Title */}
      <h1 className="font-heading text-2xl font-bold tracking-tight">{event.title}</h1>

      {/* Description */}
      {event.description && (
        <p className="text-muted-foreground leading-relaxed whitespace-pre-wrap">
          {event.description}
        </p>
      )}

      {/* Info card */}
      <div className="rounded-xl border bg-card divide-y overflow-hidden">
        {[
          { icon: Calendar, label: "Date & Time", value: formatEventDate(event.date_time) },
          { icon: MapPin, label: "Location", value: event.location },
          { icon: DollarSign, label: "Price", value: formatPrice(event.price) },
          { icon: User, label: "Organiser", value: event.organizer_username },
        ].map(({ icon: Icon, label, value }) => (
          <div key={label} className="flex items-center gap-4 px-5 py-4">
            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10 shrink-0">
              <Icon className="h-4 w-4 text-primary" />
            </div>
            <div className="min-w-0">
              <p className="text-xs text-muted-foreground uppercase tracking-wider">{label}</p>
              <p className="font-medium text-sm truncate">{value}</p>
            </div>
          </div>
        ))}

        {/* Capacity */}
        <div className="px-5 py-4">
          <div className="flex items-center justify-between mb-2.5">
            <div className="flex items-center gap-4">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10 shrink-0">
                <Users className="h-4 w-4 text-primary" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground uppercase tracking-wider">Capacity</p>
                <p className="font-medium text-sm tabular-nums">
                  {event.current_participants} / {event.max_participants}
                </p>
              </div>
            </div>
            <span className={`text-sm font-medium ${getCapacityTextColor(spotsLeft)}`}>
              {spotsLeft > 0 ? `${spotsLeft} left` : "Full"}
            </span>
          </div>
          <CapacityBar current={event.current_participants} max={event.max_participants} height="h-1.5" />
        </div>
      </div>
    </div>
  );
}
