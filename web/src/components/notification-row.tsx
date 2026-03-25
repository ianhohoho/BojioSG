"use client";

import type { NotificationResponse } from "@/lib/types";
import { formatRelativeDate } from "@/lib/date-utils";
import { Bell, CheckCircle2, CreditCard, UserPlus, UserMinus, LogOut, XCircle } from "lucide-react";

const TYPE_ICONS: Record<string, React.ComponentType<{ className?: string }>> = {
  join_request: UserPlus,
  payment_required: CreditCard,
  payment_submitted: CreditCard,
  approved: CheckCircle2,
  removed: UserMinus,
  rejected: XCircle,
  withdrawn: LogOut,
};

interface NotificationRowProps {
  notification: NotificationResponse;
  onClick: () => void;
}

export function NotificationRow({ notification, onClick }: NotificationRowProps) {
  const Icon = TYPE_ICONS[notification.type] || Bell;

  return (
    <button
      className={`w-full text-left rounded-xl border bg-card p-4 transition-all duration-200 hover:border-primary/30 hover:shadow-[0_0_24px_-6px] hover:shadow-primary/10 hover:-translate-y-0.5 ${
        !notification.is_read ? "border-primary/30" : ""
      }`}
      onClick={onClick}
    >
      <div className="flex items-start gap-3.5">
        <div className={`flex h-9 w-9 items-center justify-center rounded-lg shrink-0 ${
          !notification.is_read
            ? "bg-primary/10 text-primary"
            : "bg-muted text-muted-foreground"
        }`}>
          <Icon className="h-4 w-4" />
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <p className="text-sm font-heading font-semibold line-clamp-1 flex-1">
              {notification.event_title}
            </p>
            {!notification.is_read && (
              <span className="h-2 w-2 shrink-0 rounded-full bg-primary" />
            )}
          </div>
          <p className="text-sm text-muted-foreground mt-0.5 line-clamp-2">
            {notification.message}
          </p>
          {notification.reason && (
            <p className="mt-1.5 text-xs text-muted-foreground italic border-l-2 border-border pl-2">
              &ldquo;{notification.reason}&rdquo;
            </p>
          )}
          <p className="text-xs text-muted-foreground mt-1.5">
            {formatRelativeDate(notification.created_at)}
          </p>
        </div>
      </div>
    </button>
  );
}
