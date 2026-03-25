"use client";

import { createContext, useContext, useState, useCallback, useEffect } from "react";
import { apiRequest } from "@/lib/api-client";
import { useAuth } from "@/lib/auth-context";
import type { NotificationResponse } from "@/lib/types";

interface NotificationsContextValue {
  notifications: NotificationResponse[];
  unreadCount: number;
  loading: boolean;
  fetchNotifications: () => Promise<void>;
  markAsRead: (id: number) => Promise<void>;
}

const NotificationsContext = createContext<NotificationsContextValue | null>(null);

export function NotificationsProvider({ children }: { children: React.ReactNode }) {
  const { token, isAuthenticated } = useAuth();
  const [notifications, setNotifications] = useState<NotificationResponse[]>([]);
  const [loading, setLoading] = useState(false);

  const fetchNotifications = useCallback(async () => {
    if (!token) return;
    setLoading(true);
    try {
      const data = await apiRequest<NotificationResponse[]>("/notifications", { token });
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
        await apiRequest(`/notifications/${id}/read`, { method: "PUT", token });
        setNotifications((prev) =>
          prev.map((n) => (n.id === id ? { ...n, is_read: true } : n))
        );
      } catch {
        // ignore
      }
    },
    [token]
  );

  useEffect(() => {
    if (isAuthenticated) {
      fetchNotifications();
    }
  }, [isAuthenticated, fetchNotifications]);

  const unreadCount = notifications.filter((n) => !n.is_read).length;

  return (
    <NotificationsContext.Provider value={{ notifications, unreadCount, loading, fetchNotifications, markAsRead }}>
      {children}
    </NotificationsContext.Provider>
  );
}

export function useNotificationsContext() {
  const ctx = useContext(NotificationsContext);
  if (!ctx) throw new Error("useNotificationsContext must be used within NotificationsProvider");
  return ctx;
}
