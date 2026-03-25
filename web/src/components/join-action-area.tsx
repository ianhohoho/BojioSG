"use client";

import { useState } from "react";
import { CreditCard, LogOut, CheckCircle2, Clock, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import type { EventResponse } from "@/lib/types";
import { formatPrice } from "@/lib/date-utils";

interface JoinActionAreaProps {
  event: EventResponse;
  onJoin: () => Promise<void>;
  onNotifyPayment: () => Promise<void>;
  onLeave: () => Promise<void>;
}

function PayNowCard({ event }: { event: EventResponse }) {
  return (
    <div className="rounded-xl border border-sky-200 dark:border-sky-800 bg-sky-50 dark:bg-sky-400/5 p-5">
      <div className="flex items-center gap-2 font-heading font-semibold text-sm text-sky-700 dark:text-sky-400 mb-2">
        <CreditCard className="h-4 w-4" />
        PayNow
      </div>
      <p className="text-sm text-sky-900 dark:text-sky-200">
        Send <span className="font-bold">{formatPrice(event.price)}</span>{" "}
        to {event.organizer_username}
        {event.organizer_phone_number && (
          <code className="ml-1.5 bg-sky-100 dark:bg-sky-900/50 px-1.5 py-0.5 rounded-md text-xs font-mono">
            {event.organizer_phone_number}
          </code>
        )}
      </p>
    </div>
  );
}

function StatusBanner({
  variant,
  icon: Icon,
  children,
}: {
  variant: "success" | "warning" | "info";
  icon: React.ComponentType<{ className?: string }>;
  children: React.ReactNode;
}) {
  const styles = {
    success: "border-emerald-200 dark:border-emerald-800 bg-emerald-50 dark:bg-emerald-400/5 text-emerald-700 dark:text-emerald-400",
    warning: "border-amber-200 dark:border-amber-800 bg-amber-50 dark:bg-amber-400/5 text-amber-700 dark:text-amber-400",
    info: "border-teal-200 dark:border-teal-800 bg-teal-50 dark:bg-teal-400/5 text-teal-700 dark:text-teal-400",
  };
  return (
    <div className={`flex items-center gap-3 rounded-xl border p-4 text-sm font-medium ${styles[variant]}`}>
      <Icon className="h-5 w-5 shrink-0" />
      {children}
    </div>
  );
}

export function JoinActionArea({
  event,
  onJoin,
  onNotifyPayment,
  onLeave,
}: JoinActionAreaProps) {
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");

  async function handleAction(action: () => Promise<void>) {
    setLoading(true);
    setMessage("");
    try {
      await action();
    } catch (err) {
      setMessage(err instanceof Error ? err.message : "Something went wrong");
    } finally {
      setLoading(false);
    }
  }

  if (event.is_organizer) return null;

  const leaveButton = (label: string) => (
    <Button
      variant="outline"
      className="w-full rounded-lg text-destructive hover:bg-destructive/10 hover:text-destructive"
      disabled={loading}
      onClick={() => handleAction(onLeave)}
    >
      <LogOut className="h-4 w-4 mr-2" />
      {label}
    </Button>
  );

  const errorMsg = message && (
    <div className="rounded-lg bg-destructive/10 px-4 py-3 text-sm text-destructive">
      {message}
    </div>
  );

  if (event.join_status === "approved") {
    return (
      <div className="space-y-3">
        <StatusBanner variant="success" icon={CheckCircle2}>
          You&apos;re in! See you there.
        </StatusBanner>
        {leaveButton("Leave Event")}
        {errorMsg}
      </div>
    );
  }

  if (event.join_status === "payment_submitted") {
    return (
      <div className="space-y-3">
        <PayNowCard event={event} />
        <StatusBanner variant="info" icon={Clock}>
          Organiser has been notified. Waiting for confirmation.
        </StatusBanner>
        {leaveButton("Withdraw")}
        {errorMsg}
      </div>
    );
  }

  if (event.join_status === "pending_payment") {
    return (
      <div className="space-y-3">
        <PayNowCard event={event} />
        <Button
          className="w-full h-12 rounded-lg font-heading font-semibold"
          disabled={loading}
          onClick={() => handleAction(onNotifyPayment)}
        >
          {loading ? (
            <Loader2 className="h-4 w-4 mr-2 animate-spin" />
          ) : (
            <CreditCard className="h-4 w-4 mr-2" />
          )}
          {loading ? "Notifying..." : "Let Organiser Know Payment Made"}
        </Button>
        {leaveButton("Withdraw")}
        {errorMsg}
      </div>
    );
  }

  if (event.join_status === "pending") {
    return (
      <div className="space-y-3">
        <StatusBanner variant="warning" icon={Clock}>
          Your request is pending organiser approval.
        </StatusBanner>
        {leaveButton("Withdraw")}
        {errorMsg}
      </div>
    );
  }

  const isFull = event.current_participants >= event.max_participants;
  return (
    <div className="space-y-3">
      <Button
        className="w-full h-12 rounded-lg font-heading font-semibold"
        disabled={loading || isFull}
        onClick={() => handleAction(onJoin)}
      >
        {loading && <Loader2 className="h-4 w-4 mr-2 animate-spin" />}
        {loading ? "Requesting..." : isFull ? "Event Full" : "Request to Join"}
      </Button>
      {errorMsg}
    </div>
  );
}
