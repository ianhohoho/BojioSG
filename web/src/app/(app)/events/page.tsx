"use client";

import { useEffect, useState, useMemo } from "react";
import { useAuth } from "@/lib/auth-context";
import { useEvents } from "@/hooks/use-events";
import { EventCard } from "@/components/event-card";
import {
  EventFilters,
  type EventFilter,
  type SortOrder,
} from "@/components/event-filters";
import { parseAPIDate } from "@/lib/date-utils";
import type { EventResponse } from "@/lib/types";
import { CalendarOff } from "lucide-react";
import { EmptyState } from "@/components/empty-state";

function applyFilters(
  events: EventResponse[],
  filter: EventFilter,
  sportFilter: string | null,
  dateFilter: string | null,
  sortOrder: SortOrder
): EventResponse[] {
  let filtered = [...events];

  if (filter === "organised") {
    filtered = filtered.filter((e) => e.is_organizer);
  } else if (filter === "joined") {
    filtered = filtered.filter((e) => e.join_status !== null && !e.is_organizer);
  }

  if (sportFilter) {
    filtered = filtered.filter(
      (e) => e.sport_type.toLowerCase() === sportFilter.toLowerCase()
    );
  }

  if (dateFilter) {
    filtered = filtered.filter((e) => {
      const d = parseAPIDate(e.date_time);
      if (!d) return false;
      const yyyy = d.getFullYear();
      const mm = String(d.getMonth() + 1).padStart(2, "0");
      const dd = String(d.getDate()).padStart(2, "0");
      return `${yyyy}-${mm}-${dd}` === dateFilter;
    });
  }

  filtered.sort((a, b) => {
    const da = parseAPIDate(a.date_time)?.getTime() ?? 0;
    const db = parseAPIDate(b.date_time)?.getTime() ?? 0;
    return sortOrder === "earliest" ? da - db : db - da;
  });

  return filtered;
}

function LoadingSkeleton() {
  return (
    <div className="grid gap-4 grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
      {Array.from({ length: 6 }).map((_, i) => (
        <div key={i} className="rounded-xl border bg-card p-5 animate-pulse">
          <div className="flex justify-between mb-3">
            <div className="h-6 w-24 rounded-full bg-muted" />
            <div className="h-6 w-16 rounded-full bg-muted" />
          </div>
          <div className="h-5 w-3/4 rounded-lg bg-muted mb-3" />
          <div className="space-y-2">
            <div className="h-4 w-2/3 rounded bg-muted" />
            <div className="h-4 w-1/2 rounded bg-muted" />
          </div>
          <div className="mt-4 pt-3 border-t border-border/50">
            <div className="flex justify-between mb-2">
              <div className="h-4 w-16 rounded bg-muted" />
              <div className="h-4 w-20 rounded bg-muted" />
            </div>
            <div className="h-1 rounded-full bg-muted" />
          </div>
        </div>
      ))}
    </div>
  );
}

export default function EventsPage() {
  const { token } = useAuth();
  const { events, loading, error, fetchEvents } = useEvents(token);
  const [filter, setFilter] = useState<EventFilter>("all");
  const [sportFilter, setSportFilter] = useState<string | null>(null);
  const [dateFilter, setDateFilter] = useState<string | null>(null);
  const [sortOrder, setSortOrder] = useState<SortOrder>("earliest");

  useEffect(() => {
    fetchEvents();
  }, [fetchEvents]);

  const filteredEvents = useMemo(
    () => applyFilters(events, filter, sportFilter, dateFilter, sortOrder),
    [events, filter, sportFilter, dateFilter, sortOrder]
  );

  return (
    <div>
      <div className="mb-8">
        <h1 className="font-heading text-3xl font-bold tracking-tight">Events</h1>
        <p className="text-muted-foreground mt-1">
          Find and join sports events near you
        </p>
      </div>

      <EventFilters
        filter={filter}
        onFilterChange={setFilter}
        sportFilter={sportFilter}
        onSportFilterChange={setSportFilter}
        dateFilter={dateFilter}
        onDateFilterChange={setDateFilter}
        sortOrder={sortOrder}
        onSortOrderChange={setSortOrder}
      />

      {loading && <LoadingSkeleton />}

      {error && (
        <div className="text-center py-20">
          <p className="text-destructive">{error}</p>
        </div>
      )}

      {!loading && !error && filteredEvents.length === 0 && (
        <EmptyState
          icon={<CalendarOff className="h-7 w-7 text-muted-foreground" />}
          title="No events found"
          description={dateFilter ? "No events on this date" : "Try adjusting your filters or create a new event"}
        />
      )}

      <div className="grid gap-4 grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
        {filteredEvents.map((event, i) => (
          <div
            key={event.id}
            className="animate-fade-up"
            style={{ "--stagger": Math.min(i, 8) } as React.CSSProperties}
          >
            <EventCard event={event} />
          </div>
        ))}
      </div>
    </div>
  );
}
