"use client";

import { useState } from "react";
import { Loader2 } from "lucide-react";
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

export function CreateEventForm({ onSubmit, loading, error }: CreateEventFormProps) {
  const [sportType, setSportType] = useState("");
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [location, setLocation] = useState("");
  const [dateTime, setDateTime] = useState("");
  const [price, setPrice] = useState("");
  const [maxParticipants, setMaxParticipants] = useState("");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!sportType) return;
    await onSubmit({
      title,
      description,
      sport_type: sportType,
      location,
      date_time: new Date(dateTime).toISOString(),
      price: parseFloat(price),
      max_participants: parseInt(maxParticipants),
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

          <div className="space-y-2">
            <Label htmlFor="datetime" className="text-xs uppercase tracking-wider text-muted-foreground font-medium">Date & Time</Label>
            <Input
              id="datetime"
              type="datetime-local"
              value={dateTime}
              onChange={(e) => setDateTime(e.target.value)}
              required
              className="h-12 rounded-lg"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="price" className="text-xs uppercase tracking-wider text-muted-foreground font-medium">Price ($)</Label>
              <Input
                id="price"
                type="number"
                step="0.50"
                min="0"
                value={price}
                onChange={(e) => setPrice(e.target.value)}
                placeholder="10.00"
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

          {error && (
            <div className="rounded-lg bg-destructive/10 px-4 py-3 text-sm text-destructive">
              {error}
            </div>
          )}

          <Button
            type="submit"
            className="w-full h-12 rounded-lg font-heading font-semibold"
            disabled={loading || !sportType}
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
