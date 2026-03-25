"use client";

import { useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Loader2, Phone } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useAuth } from "@/lib/auth-context";
import { useProfile } from "@/hooks/use-profile";
import { ApiError } from "@/lib/api-client";

export default function ProfilePage() {
  const { token, session, updateNickname } = useAuth();
  const { profile, loading, fetchProfile, updateProfile } = useProfile(token);
  const router = useRouter();
  const searchParams = useSearchParams();
  const isSetup = searchParams.get("setup") === "1";
  const [nickname, setNickname] = useState("");
  const [phoneNumber, setPhoneNumber] = useState("");
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState("");

  useEffect(() => {
    fetchProfile();
  }, [fetchProfile]);

  useEffect(() => {
    if (profile) {
      setNickname(profile.nickname || "");
      setPhoneNumber(profile.phone_number || "");
    }
  }, [profile]);

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setMessage("");
    try {
      const updated = await updateProfile({
        nickname: nickname || null,
        phone_number: phoneNumber || null,
      });
      if (updated?.nickname) {
        updateNickname(updated.nickname);
      }
      setMessage("Profile updated!");
      if (isSetup) {
        router.replace("/events");
        return;
      }
    } catch (err) {
      setMessage(err instanceof ApiError ? err.message : "Failed to save");
    } finally {
      setSaving(false);
    }
  }

  const email = session?.user?.email;
  const initials = (nickname || email || "?").slice(0, 2).toUpperCase();

  if (loading) {
    return (
      <div className="max-w-md mx-auto">
        <div className="rounded-xl border bg-card p-8 animate-pulse">
          <div className="flex flex-col items-center gap-3 mb-6">
            <div className="h-20 w-20 rounded-xl bg-muted" />
            <div className="h-5 w-32 rounded bg-muted" />
            <div className="h-4 w-20 rounded bg-muted" />
          </div>
          <div className="space-y-4">
            <div className="h-12 rounded-lg bg-muted" />
            <div className="h-12 rounded-lg bg-muted" />
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-md mx-auto animate-fade-in">
      <div className="rounded-xl border bg-card p-8">
        <div className="flex flex-col items-center mb-8">
          <span className="flex h-20 w-20 items-center justify-center rounded-xl bg-primary text-2xl font-heading font-bold text-primary-foreground mb-4">
            {initials}
          </span>
          <h2 className="font-heading text-xl font-bold">{nickname || email?.split("@")[0]}</h2>
          {email && <p className="text-sm text-muted-foreground mt-0.5">{email}</p>}
        </div>

        {isSetup && (
          <div className="flex items-start gap-3 rounded-lg bg-primary/10 px-4 py-3 mb-6">
            <Phone className="h-5 w-5 text-primary mt-0.5 shrink-0" />
            <p className="text-sm text-primary">
              Add your phone number so participants can send you PayNow payments when you organise events.
            </p>
          </div>
        )}

        <form onSubmit={handleSave} className="space-y-5">
          <div className="space-y-2">
            <Label htmlFor="nickname" className="text-xs uppercase tracking-wider text-muted-foreground font-medium">Display Name</Label>
            <Input
              id="nickname"
              value={nickname}
              onChange={(e) => setNickname(e.target.value)}
              placeholder="Your display name"
              className="h-12 rounded-lg"
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="phone" className="text-xs uppercase tracking-wider text-muted-foreground font-medium">Phone Number</Label>
            <Input
              id="phone"
              value={phoneNumber}
              onChange={(e) => setPhoneNumber(e.target.value)}
              placeholder="e.g. 91234567"
              className="h-12 rounded-lg"
            />
            <p className="text-xs text-muted-foreground">
              Used for PayNow payments when you organise events
            </p>
          </div>
          {message && (
            <div className={`rounded-lg px-4 py-3 text-sm ${
              message.includes("updated")
                ? "bg-emerald-50 dark:bg-emerald-400/5 text-emerald-700 dark:text-emerald-400"
                : "bg-destructive/10 text-destructive"
            }`}>
              {message}
            </div>
          )}
          <Button type="submit" className="w-full h-12 rounded-lg font-heading font-semibold" disabled={saving}>
            {saving ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                Saving...
              </>
            ) : (
              isSetup ? "Continue" : "Save Changes"
            )}
          </Button>
        </form>
      </div>
    </div>
  );
}
