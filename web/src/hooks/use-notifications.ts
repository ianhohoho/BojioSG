"use client";

import { useState, useCallback } from "react";
import { apiRequest } from "@/lib/api-client";
import type { NotificationResponse } from "@/lib/types";

export function useNotifications(token: string | null) {
  const [notifications, setNotifications] = useState<NotificationResponse[]>([]);
  const [loading, setLoading] = useState(false);

  const fetchNotifications = useCallback(async () => {
    if (!token) return;
    setLoading(true);
    try {
      const data = await apiRequest<NotificationResponse[]>("/notifications", {
        token,
      });
      setNotifications(data);
    } catch {
      // ignore
    } finally {
      setLoading(false);
    }
  }, [token]);

  const markAsRead = useCallback(
    async (id: number) => {
      if (!token) return;
      try {
        await apiRequest(`/notifications/${id}/read`, {
          method: "PUT",
          token,
        });
        setNotifications((prev) =>
          prev.map((n) => (n.id === id ? { ...n, is_read: true } : n))
        );
      } catch {
        // ignore
      }
    },
    [token]
  );

  const unreadCount = notifications.filter((n) => !n.is_read).length;

  return { notifications, loading, fetchNotifications, markAsRead, unreadCount };
}
