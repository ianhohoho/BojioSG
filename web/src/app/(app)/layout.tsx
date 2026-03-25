"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { useNotifications } from "@/hooks/use-notifications";
import { NavBar } from "@/components/nav-bar";

export default function AppLayout({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, token } = useAuth();
  const router = useRouter();
  const { unreadCount, fetchNotifications } = useNotifications(token);

  useEffect(() => {
    if (!isAuthenticated) {
      router.replace("/login");
    }
  }, [isAuthenticated, router]);

  useEffect(() => {
    if (isAuthenticated) {
      fetchNotifications();
    }
  }, [isAuthenticated, fetchNotifications]);

  if (!isAuthenticated) return null;

  return (
    <>
      <NavBar unreadCount={unreadCount} />
      <main className="mx-auto w-full max-w-5xl flex-1 px-4 sm:px-6 py-8">
        {children}
      </main>
    </>
  );
}
