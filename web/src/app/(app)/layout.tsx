"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { NotificationsProvider, useNotificationsContext } from "@/lib/notifications-context";
import { NavBar } from "@/components/nav-bar";

function AppShell({ children }: { children: React.ReactNode }) {
  const { unreadCount } = useNotificationsContext();

  return (
    <>
      <NavBar unreadCount={unreadCount} />
      <main className="mx-auto w-full max-w-5xl flex-1 px-4 sm:px-6 py-8">
        {children}
      </main>
    </>
  );
}

export default function AppLayout({ children }: { children: React.ReactNode }) {
  const { isAuthenticated } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isAuthenticated) {
      router.replace("/login");
    }
  }, [isAuthenticated, router]);

  if (!isAuthenticated) return null;

  return (
    <NotificationsProvider>
      <AppShell>{children}</AppShell>
    </NotificationsProvider>
  );
}
