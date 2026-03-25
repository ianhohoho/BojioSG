"use client";

import { useState, useRef, useEffect, useMemo } from "react";
import { Loader2, ChevronLeft, ChevronRight, Users, DollarSign } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { SPORTS, SPORT_TYPES } from "@/lib/sport-constants";
import type { EventCreate } from "@/lib/types";

interface CreateEventFormProps {
  onSubmit: (event: EventCreate) => Promise<void>;
  loading: boolean;
  error: string;
}

const DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

function generateDates(count: number) {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return Array.from({ length: count }, (_, i) => {
    const d = new Date(today);
    d.setDate(d.getDate() + i);
    const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
    return {
      key,
      dayLabel: i === 0 ? "Today" : i === 1 ? "Tmr" : DAYS[d.getDay()],
      date: d.getDate(),
      month: MONTHS[d.getMonth()],
    };
  });
}

function generateHours() {
  return Array.from({ length: 12 }, (_, i) => i + 1);
}

const MINUTES = ["00", "15", "30", "45"];

export function CreateEventForm({ onSubmit, loading, error }: CreateEventFormProps) {
  const [sportType, setSportType] = useState("");
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [location, setLocation] = useState("");
  const [selectedDateKey, setSelectedDateKey] = useState("");
  const [hour, setHour] = useState("7");
  const [minute, setMinute] = useState("00");
  const [ampm, setAmpm] = useState("PM");
  const [totalPrice, setTotalPrice] = useState("");
  const [maxParticipants, setMaxParticipants] = useState("");

  const scrollRef = useRef<HTMLDivElement>(null);
  const dates = useMemo(() => generateDates(30), []);

  // Scroll to show "Today" on mount
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollLeft = 0;
    }
  }, []);

  const pricePerPax = useMemo(() => {
    const total = parseFloat(totalPrice);
    const pax = parseInt(maxParticipants);
    if (!isNaN(total) && !isNaN(pax) && pax > 0 && total >= 0) {
      return total / pax;
    }
    return null;
  }, [totalPrice, maxParticipants]);

  function scrollDates(direction: "left" | "right") {
    if (!scrollRef.current) return;
    const amount = direction === "left" ? -200 : 200;
    scrollRef.current.scrollBy({ left: amount, behavior: "smooth" });
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!sportType || !selectedDateKey) return;

    // Build datetime from parts
    let h = parseInt(hour);
    if (ampm === "PM" && h !== 12) h += 12;
    if (ampm === "AM" && h === 12) h = 0;
    const dateTimeStr = `${selectedDateKey}T${String(h).padStart(2, "0")}:${minute}:00`;

    const total = parseFloat(totalPrice);
    const pax = parseInt(maxParticipants);
    const perPax = pax > 0 ? total / pax : total;

    await onSubmit({
      title,
      description,
      sport_type: sportType,
      location,
      date_time: new Date(dateTimeStr).toISOString(),
      price: Math.round(perPax * 100) / 100,
      max_participants: pax,
    });
  }

  return (
    <div className="max-w-2xl mx-auto animate-fade-in">
      <div className="mb-8">
        <h1 className="font-heading text-2xl font-bold tracking-tight">Create Event</h1>
        <p className="text-muted-foreground mt-1">
          Set up a new sports event for others to join
        </p>
      </div>

      <div className="rounded-xl border bg-card p-6">
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Sport picker */}
          <div className="space-y-3">
            <Label className="text-xs uppercase tracking-wider text-muted-foreground font-medium">Sport</Label>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
              {SPORT_TYPES.map((s) => {
                const sport = SPORTS[s];
                const selected = sportType === s;
                return (
                  <button
                    key={s}
                    type="button"
                    onClick={() => setSportType(s)}
                    className={`flex items-center justify-center gap-2 rounded-lg px-3 py-3 text-sm font-medium transition-all duration-200 border ${
                      selected
                        ? "border-primary bg-primary/10 text-primary"
                        : "border-border bg-card text-muted-foreground hover:text-foreground hover:border-primary/30"
                    }`}
                  >
                    <span className="text-lg">{sport.emoji}</span>
                    {sport.label}
                  </button>
                );
              })}
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="title" className="text-xs uppercase tracking-wider text-muted-foreground font-medium">Title</Label>
            <Input
              id="title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="e.g. Sunday Pickleball @ East Coast"
              required
              className="h-12 rounded-lg"
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="description" className="text-xs uppercase tracking-wider text-muted-foreground font-medium">Description</Label>
            <Textarea
              id="description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Tell people about your event..."
              rows={3}
              className="rounded-lg"
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="location" className="text-xs uppercase tracking-wider text-muted-foreground font-medium">Location</Label>
            <Input
              id="location"
              value={location}
              onChange={(e) => setLocation(e.target.value)}
              placeholder="e.g. East Coast Park Court 3"
              required
              className="h-12 rounded-lg"
            />
          </div>

          {/* Date picker */}
          <div className="space-y-3">
            <Label className="text-xs uppercase tracking-wider text-muted-foreground font-medium">Date</Label>
            <div className="relative">
              <button
                type="button"
                onClick={() => scrollDates("left")}
                className="absolute left-0 top-1/2 -translate-y-1/2 z-10 h-8 w-8 flex items-center justify-center rounded-full bg-card/90 border shadow-sm text-muted-foreground hover:text-foreground transition-colors"
              >
                <ChevronLeft className="h-4 w-4" />
              </button>
              <div
                ref={scrollRef}
                className="flex gap-2 overflow-x-auto scrollbar-hide px-9 py-1"
              >
                {dates.map((d) => {
                  const selected = selectedDateKey === d.key;
                  return (
                    <button
                      key={d.key}
                      type="button"
                      onClick={() => setSelectedDateKey(d.key)}
                      className={`flex flex-col items-center shrink-0 w-[56px] rounded-xl px-2 py-2.5 text-center transition-all duration-200 border ${
                        selected
                          ? "border-primary bg-primary text-primary-foreground"
                          : "border-border bg-card text-muted-foreground hover:border-primary/30 hover:text-foreground"
                      }`}
                    >
                      <span className="text-[11px] font-medium">{d.dayLabel}</span>
                      <span className="text-lg font-bold leading-tight">{d.date}</span>
                      <span className={`text-[10px] ${selected ? "text-primary-foreground/70" : "opacity-60"}`}>{d.month}</span>
                    </button>
                  );
                })}
              </div>
              <button
                type="button"
                onClick={() => scrollDates("right")}
                className="absolute right-0 top-1/2 -translate-y-1/2 z-10 h-8 w-8 flex items-center justify-center rounded-full bg-card/90 border shadow-sm text-muted-foreground hover:text-foreground transition-colors"
              >
                <ChevronRight className="h-4 w-4" />
              </button>
            </div>
          </div>

          {/* Time picker */}
          <div className="space-y-3">
            <Label className="text-xs uppercase tracking-wider text-muted-foreground font-medium">Time</Label>
            <div className="flex items-center gap-2">
              <select
                value={hour}
                onChange={(e) => setHour(e.target.value)}
                className="h-12 rounded-lg border border-border bg-card px-3 text-sm font-medium appearance-none cursor-pointer focus:outline-none focus:ring-2 focus:ring-ring flex-1 text-center"
              >
                {generateHours().map((h) => (
                  <option key={h} value={h}>{h}</option>
                ))}
              </select>
              <span className="text-xl font-bold text-muted-foreground">:</span>
              <select
                value={minute}
                onChange={(e) => setMinute(e.target.value)}
                className="h-12 rounded-lg border border-border bg-card px-3 text-sm font-medium appearance-none cursor-pointer focus:outline-none focus:ring-2 focus:ring-ring flex-1 text-center"
              >
                {MINUTES.map((m) => (
                  <option key={m} value={m}>{m}</option>
                ))}
              </select>
              <div className="flex rounded-lg border border-border overflow-hidden">
                {(["AM", "PM"] as const).map((val) => (
                  <button
                    key={val}
                    type="button"
                    onClick={() => setAmpm(val)}
                    className={`h-12 px-4 text-sm font-semibold transition-colors ${
                      ampm === val
                        ? "bg-primary text-primary-foreground"
                        : "bg-card text-muted-foreground hover:text-foreground"
                    }`}
                  >
                    {val}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* Price + participants */}
          <div className="space-y-3">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="price" className="text-xs uppercase tracking-wider text-muted-foreground font-medium">Total Price ($)</Label>
                <Input
                  id="price"
                  type="number"
                  step="0.50"
                  min="0"
                  value={totalPrice}
                  onChange={(e) => setTotalPrice(e.target.value)}
                  placeholder="80.00"
                  required
                  className="h-12 rounded-lg"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="max" className="text-xs uppercase tracking-wider text-muted-foreground font-medium">Max Participants</Label>
                <Input
                  id="max"
                  type="number"
                  min="2"
                  value={maxParticipants}
                  onChange={(e) => setMaxParticipants(e.target.value)}
                  placeholder="8"
                  required
                  className="h-12 rounded-lg"
                />
              </div>
            </div>

            {/* Price per pax preview */}
            {pricePerPax !== null && (
              <div className="flex items-center gap-3 rounded-lg border border-primary/20 bg-primary/5 px-4 py-3">
                <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10 shrink-0">
                  <DollarSign className="h-4 w-4 text-primary" />
                </div>
                <div className="flex items-baseline gap-1.5">
                  <span className="text-lg font-heading font-bold text-primary">
                    ${pricePerPax.toFixed(2)}
                  </span>
                  <span className="text-sm text-muted-foreground">per pax</span>
                </div>
                <div className="ml-auto flex items-center gap-1 text-sm text-muted-foreground">
                  <Users className="h-3.5 w-3.5" />
                  <span>{maxParticipants}</span>
                </div>
              </div>
            )}
          </div>

          {error && (
            <div className="rounded-lg bg-destructive/10 px-4 py-3 text-sm text-destructive">
              {error}
            </div>
          )}

          <Button
            type="submit"
            className="w-full h-12 rounded-lg font-heading font-semibold"
            disabled={loading || !sportType || !selectedDateKey}
          >
            {loading ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                Creating...
              </>
            ) : (
              "Create Event"
            )}
          </Button>
        </form>
      </div>
    </div>
  );
}
