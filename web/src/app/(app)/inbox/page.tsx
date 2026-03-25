"use client";

import { useRouter } from "next/navigation";
import { Inbox as InboxIcon } from "lucide-react";
import { EmptyState } from "@/components/empty-state";
import { useNotificationsContext } from "@/lib/notifications-context";
import { NotificationRow } from "@/components/notification-row";

export default function InboxPage() {
  const { notifications, loading, markAsRead } = useNotificationsContext();
  const router = useRouter();

  async function handleClick(notification: { id: number; event_id: number; is_read: boolean }) {
    if (!notification.is_read) {
      await markAsRead(notification.id);
    }
    router.push(`/events/${notification.event_id}`);
  }

  return (
    <div className="max-w-2xl mx-auto animate-fade-in">
      <div className="mb-8">
        <h1 className="font-heading text-2xl font-bold tracking-tight">Inbox</h1>
        <p className="text-muted-foreground mt-1">
          Your notifications and updates
        </p>
      </div>

      {loading && (
        <div className="space-y-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="rounded-xl border bg-card p-4 animate-pulse">
              <div className="flex items-start gap-3.5">
                <div className="h-9 w-9 rounded-lg bg-muted shrink-0" />
                <div className="flex-1 space-y-2">
                  <div className="h-4 w-1/3 rounded bg-muted" />
                  <div className="h-3 w-2/3 rounded bg-muted" />
                  <div className="h-3 w-16 rounded bg-muted" />
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {!loading && notifications.length === 0 && (
        <EmptyState
          icon={<InboxIcon className="h-7 w-7 text-muted-foreground" />}
          title="All caught up!"
          description="No notifications yet"
        />
      )}

      <div className="space-y-3">
        {notifications.map((n, i) => (
          <div
            key={n.id}
            className="animate-fade-up"
            style={{ "--stagger": Math.min(i, 6) } as React.CSSProperties}
          >
            <NotificationRow
              notification={n}
              onClick={() => handleClick(n)}
            />
          </div>
        ))}
      </div>
    </div>
  );
}
