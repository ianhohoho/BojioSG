"use client";

import { useRef, useEffect, useMemo } from "react";
import { ArrowUpDown, X, ChevronDown } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { SPORTS, SPORT_TYPES } from "@/lib/sport-constants";

export type EventFilter = "all" | "organised" | "joined";
export type SortOrder = "earliest" | "latest";

interface EventFiltersProps {
  filter: EventFilter;
  onFilterChange: (f: EventFilter) => void;
  sportFilter: string | null;
  onSportFilterChange: (s: string | null) => void;
  dateFilter: string | null;
  onDateFilterChange: (d: string | null) => void;
  sortOrder: SortOrder;
  onSortOrderChange: (s: SortOrder) => void;
}

function generateDates(count: number): { key: string; day: string; date: number; month: string; isToday: boolean }[] {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

  return Array.from({ length: count }, (_, i) => {
    const d = new Date(today);
    d.setDate(d.getDate() + i);
    const yyyy = d.getFullYear();
    const mm = String(d.getMonth() + 1).padStart(2, "0");
    const dd = String(d.getDate()).padStart(2, "0");
    return {
      key: `${yyyy}-${mm}-${dd}`,
      day: i === 0 ? "Today" : i === 1 ? "Tmr" : days[d.getDay()],
      date: d.getDate(),
      month: months[d.getMonth()],
      isToday: i === 0,
    };
  });
}

export function EventFilters({
  filter,
  onFilterChange,
  sportFilter,
  onSportFilterChange,
  dateFilter,
  onDateFilterChange,
  sortOrder,
  onSortOrderChange,
}: EventFiltersProps) {
  const hasActiveFilters = sportFilter !== null;
  const scrollRef = useRef<HTMLDivElement>(null);
  const dates = useMemo(() => generateDates(21), []);

  useEffect(() => {
    if (scrollRef.current && dateFilter) {
      const el = scrollRef.current.querySelector(`[data-date="${dateFilter}"]`);
      if (el) {
        el.scrollIntoView({ inline: "center", block: "nearest", behavior: "smooth" });
      }
    }
  }, [dateFilter]);

  const filterButtons: { value: EventFilter; label: string }[] = [
    { value: "all", label: "All Events" },
    { value: "organised", label: "Organised" },
    { value: "joined", label: "Joined" },
  ];

  return (
    <div className="space-y-3 mb-8">
      {/* Date scroller */}
      <div className="relative -mx-4 sm:-mx-6">
        <div
          ref={scrollRef}
          className="flex gap-1.5 overflow-x-auto px-4 sm:px-6 pb-1 scrollbar-hide"
          style={{ scrollbarWidth: "none", msOverflowStyle: "none" }}
        >
          <button
            onClick={() => onDateFilterChange(null)}
            className={`shrink-0 flex flex-col items-center rounded-lg px-3 py-2 text-xs font-medium transition-all duration-200 ${
              dateFilter === null
                ? "bg-primary text-primary-foreground"
                : "bg-card border border-border text-muted-foreground hover:text-foreground hover:border-primary/30"
            }`}
          >
            <span className="text-[11px]">All</span>
            <span className="text-sm font-semibold mt-0.5">-</span>
          </button>
          {dates.map((d) => (
            <button
              key={d.key}
              data-date={d.key}
              onClick={() => onDateFilterChange(dateFilter === d.key ? null : d.key)}
              className={`shrink-0 flex flex-col items-center rounded-lg px-3 py-2 min-w-[3.25rem] text-xs font-medium transition-all duration-200 ${
                dateFilter === d.key
                  ? "bg-primary text-primary-foreground"
                  : d.isToday
                  ? "bg-primary/10 text-primary border border-primary/20"
                  : "bg-card border border-border text-muted-foreground hover:text-foreground hover:border-primary/30"
              }`}
            >
              <span className="text-[11px]">{d.day}</span>
              <span className="text-sm font-semibold mt-0.5">{d.date}</span>
              <span className="text-[10px] opacity-60">{d.month}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Segmented control */}
      <div className="inline-flex gap-0.5 rounded-lg bg-card border border-border p-1">
        {filterButtons.map((fb) => (
          <button
            key={fb.value}
            onClick={() => onFilterChange(fb.value)}
            className={`rounded-md px-4 py-1.5 text-sm font-medium transition-all duration-200 ${
              filter === fb.value
                ? "bg-primary text-primary-foreground"
                : "text-muted-foreground hover:text-foreground"
            }`}
          >
            {fb.label}
          </button>
        ))}
      </div>

      {/* Sport filter + Sort */}
      <div className="flex items-center gap-2 flex-wrap">
        <DropdownMenu>
          <DropdownMenuTrigger
            render={
              <Button
                variant="outline"
                size="sm"
                className={`rounded-lg gap-1.5 ${
                  sportFilter ? "border-primary/50 text-primary" : ""
                }`}
              />
            }
          >
            {sportFilter
              ? `${SPORTS[sportFilter]?.emoji} ${SPORTS[sportFilter]?.label}`
              : "Sport"}
            <ChevronDown className="h-3 w-3 opacity-50" />
          </DropdownMenuTrigger>
          <DropdownMenuContent>
            {SPORT_TYPES.map((s) => (
              <DropdownMenuItem
                key={s}
                onClick={() => onSportFilterChange(sportFilter === s ? null : s)}
              >
                {SPORTS[s].emoji} {SPORTS[s].label}
                {sportFilter === s && " \u2713"}
              </DropdownMenuItem>
            ))}
          </DropdownMenuContent>
        </DropdownMenu>

        {hasActiveFilters && (
          <Button
            variant="ghost"
            size="sm"
            className="rounded-lg gap-1 text-muted-foreground"
            onClick={() => onSportFilterChange(null)}
          >
            <X className="h-3.5 w-3.5" />
            Reset
          </Button>
        )}

        <div className="ml-auto">
          <Button
            variant="ghost"
            size="sm"
            className="rounded-lg gap-1.5 text-muted-foreground"
            onClick={() =>
              onSortOrderChange(sortOrder === "earliest" ? "latest" : "earliest")
            }
          >
            <ArrowUpDown className="h-3.5 w-3.5" />
            {sortOrder === "earliest" ? "Earliest" : "Latest"}
          </Button>
        </div>
      </div>
    </div>
  );
}
