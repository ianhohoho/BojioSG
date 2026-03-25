"use client";

import { useState } from "react";
import { Check, X, CreditCard, Trash2, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import type { ParticipantResponse } from "@/lib/types";

interface ParticipantSectionProps {
  participants: ParticipantResponse[];
  onApprove: (userId: number) => Promise<void>;
  onConfirmPayment: (userId: number) => Promise<void>;
  onRemove: (userId: number, reason?: string) => Promise<void>;
}

function ParticipantAvatar({ name }: { name: string }) {
  return (
    <span className="flex h-8 w-8 items-center justify-center rounded-md bg-primary/10 text-xs font-semibold text-primary shrink-0">
      {name[0]?.toUpperCase() || "?"}
    </span>
  );
}

function SectionHeader({ title, count }: { title: string; count: number }) {
  return (
    <div className="flex items-center gap-2 mb-3">
      <h3 className="font-heading text-sm font-semibold">{title}</h3>
      <span className="inline-flex h-5 min-w-5 items-center justify-center rounded-full bg-muted px-1.5 text-xs font-medium text-muted-foreground tabular-nums">
        {count}
      </span>
    </div>
  );
}

export function ParticipantSection({
  participants,
  onApprove,
  onConfirmPayment,
  onRemove,
}: ParticipantSectionProps) {
  const [removeDialog, setRemoveDialog] = useState<{
    userId: number;
    username: string;
  } | null>(null);
  const [removeReason, setRemoveReason] = useState("");
  const [actionLoading, setActionLoading] = useState<number | null>(null);

  const pending = participants.filter((p) => p.status === "pending");
  const awaitingPayment = participants.filter(
    (p) => p.status === "pending_payment" || p.status === "payment_submitted"
  );
  const confirmed = participants.filter((p) => p.status === "approved");

  async function handleAction(userId: number, action: () => Promise<void>) {
    setActionLoading(userId);
    try {
      await action();
    } finally {
      setActionLoading(null);
    }
  }

  async function handleRemoveConfirm() {
    if (!removeDialog) return;
    setActionLoading(removeDialog.userId);
    try {
      await onRemove(removeDialog.userId, removeReason || undefined);
      setRemoveDialog(null);
      setRemoveReason("");
    } finally {
      setActionLoading(null);
    }
  }

  return (
    <div className="space-y-6">
      {pending.length > 0 && (
        <div>
          <SectionHeader title="Pending Requests" count={pending.length} />
          <div className="space-y-2">
            {pending.map((p) => (
              <div key={p.id} className="flex items-center justify-between rounded-xl border bg-card p-4">
                <div className="flex items-center gap-3">
                  <ParticipantAvatar name={p.username} />
                  <span className="font-medium text-sm">{p.username}</span>
                </div>
                <div className="flex gap-1.5">
                  <Button
                    size="sm"
                    className="rounded-lg gap-1"
                    disabled={actionLoading === p.id}
                    onClick={() => handleAction(p.id, () => onApprove(p.id))}
                  >
                    {actionLoading === p.id ? (
                      <Loader2 className="h-3.5 w-3.5 animate-spin" />
                    ) : (
                      <Check className="h-3.5 w-3.5" />
                    )}
                    Approve
                  </Button>
                  <Button
                    size="icon-sm"
                    variant="ghost"
                    className="rounded-lg text-muted-foreground hover:text-destructive"
                    disabled={actionLoading === p.id}
                    onClick={() => setRemoveDialog({ userId: p.id, username: p.username })}
                  >
                    <X className="h-3.5 w-3.5" />
                  </Button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {awaitingPayment.length > 0 && (
        <div>
          <SectionHeader title="Awaiting Payment" count={awaitingPayment.length} />
          <div className="space-y-2">
            {awaitingPayment.map((p) => (
              <div key={p.id} className="flex items-center justify-between rounded-xl border bg-card p-4">
                <div className="flex items-center gap-3">
                  <ParticipantAvatar name={p.username} />
                  <span className="font-medium text-sm">{p.username}</span>
                  {p.status === "payment_submitted" && (
                    <span className="rounded-full bg-teal-100 dark:bg-teal-400/10 px-2 py-0.5 text-[11px] font-medium text-teal-700 dark:text-teal-400">
                      Paid
                    </span>
                  )}
                </div>
                <div className="flex gap-1.5">
                  <Button
                    size="sm"
                    className="rounded-lg gap-1"
                    disabled={actionLoading === p.id}
                    onClick={() => handleAction(p.id, () => onConfirmPayment(p.id))}
                  >
                    {actionLoading === p.id ? (
                      <Loader2 className="h-3.5 w-3.5 animate-spin" />
                    ) : (
                      <CreditCard className="h-3.5 w-3.5" />
                    )}
                    Confirm
                  </Button>
                  <Button
                    size="icon-sm"
                    variant="ghost"
                    className="rounded-lg text-muted-foreground hover:text-destructive"
                    disabled={actionLoading === p.id}
                    onClick={() => setRemoveDialog({ userId: p.id, username: p.username })}
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                  </Button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {confirmed.length > 0 && (
        <div>
          <SectionHeader title="Confirmed" count={confirmed.length} />
          <div className="space-y-2">
            {confirmed.map((p) => (
              <div key={p.id} className="flex items-center justify-between rounded-xl border bg-card p-4">
                <div className="flex items-center gap-3">
                  <ParticipantAvatar name={p.username} />
                  <span className="font-medium text-sm">{p.username}</span>
                </div>
                <Button
                  size="icon-sm"
                  variant="ghost"
                  className="rounded-lg text-muted-foreground hover:text-destructive"
                  disabled={actionLoading === p.id}
                  onClick={() => setRemoveDialog({ userId: p.id, username: p.username })}
                >
                  <Trash2 className="h-3.5 w-3.5" />
                </Button>
              </div>
            ))}
          </div>
        </div>
      )}

      <Dialog
        open={!!removeDialog}
        onOpenChange={(open) => {
          if (!open) {
            setRemoveDialog(null);
            setRemoveReason("");
          }
        }}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Remove {removeDialog?.username}?</DialogTitle>
          </DialogHeader>
          <div className="space-y-2">
            <Label htmlFor="reason">Reason (optional)</Label>
            <Input
              id="reason"
              value={removeReason}
              onChange={(e) => setRemoveReason(e.target.value)}
              placeholder="e.g. Event is full"
              className="rounded-lg"
            />
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              className="rounded-lg"
              onClick={() => {
                setRemoveDialog(null);
                setRemoveReason("");
              }}
            >
              Cancel
            </Button>
            <Button variant="destructive" className="rounded-lg" onClick={handleRemoveConfirm}>
              Remove
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
