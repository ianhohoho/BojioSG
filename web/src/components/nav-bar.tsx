"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Bell, Plus, LogOut } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useAuth } from "@/lib/auth-context";

interface NavBarProps {
  unreadCount: number;
}

export function NavBar({ unreadCount }: NavBarProps) {
  const { displayName, logout } = useAuth();
  const pathname = usePathname();

  const isActive = (path: string) => pathname === path;

  return (
    <header className="sticky top-0 z-50 w-full border-b border-border/50 bg-background/90 backdrop-blur-md">
      <div className="mx-auto flex h-14 max-w-5xl items-center justify-between px-4 sm:px-6">
        <Link href="/events" className="flex items-center gap-2 group">
          <span className="text-xl group-hover:scale-110 transition-transform duration-200">🎾</span>
          <span className="font-heading text-lg font-bold tracking-wide hidden sm:block">BOJIO SG</span>
        </Link>

        <nav className="flex items-center gap-1">
          <Button
            variant="ghost"
            size="sm"
            render={<Link href="/events/create" />}
            className={`relative gap-1.5 rounded-lg ${isActive("/events/create") ? "text-primary" : "text-muted-foreground hover:text-foreground"}`}
          >
            <Plus className="h-4 w-4" />
            <span className="hidden sm:inline">Create</span>
            {isActive("/events/create") && (
              <span className="absolute -bottom-2.5 left-1/2 -translate-x-1/2 h-0.5 w-4 bg-primary rounded-full" />
            )}
          </Button>

          <div className="relative">
            <Button
              variant="ghost"
              size="icon-sm"
              render={<Link href="/inbox" />}
              className={`relative rounded-lg ${isActive("/inbox") ? "text-primary" : "text-muted-foreground hover:text-foreground"}`}
            >
              <Bell className="h-4 w-4" />
              {isActive("/inbox") && (
                <span className="absolute -bottom-2.5 left-1/2 -translate-x-1/2 h-0.5 w-4 bg-primary rounded-full" />
              )}
            </Button>
            {unreadCount > 0 && (
              <span className="absolute -top-1 -right-1 flex h-4.5 min-w-4.5 items-center justify-center rounded-full bg-destructive px-1 text-[10px] font-bold text-white pointer-events-none ring-2 ring-background">
                {unreadCount}
              </span>
            )}
          </div>

          <Button
            variant="ghost"
            size="sm"
            render={<Link href="/profile" />}
            className={`relative gap-1.5 rounded-lg ${isActive("/profile") ? "text-primary" : "text-muted-foreground hover:text-foreground"}`}
          >
            <span className="flex h-6 w-6 items-center justify-center rounded-md bg-primary text-[10px] font-bold text-primary-foreground">
              {(displayName || "?")[0].toUpperCase()}
            </span>
            <span className="hidden sm:inline">{displayName}</span>
            {isActive("/profile") && (
              <span className="absolute -bottom-2.5 left-1/2 -translate-x-1/2 h-0.5 w-4 bg-primary rounded-full" />
            )}
          </Button>

          <div className="mx-1.5 h-4 w-px bg-border" />

          <Button
            variant="ghost"
            size="icon-sm"
            onClick={logout}
            title="Logout"
            className="rounded-lg text-muted-foreground hover:text-foreground"
          >
            <LogOut className="h-4 w-4" />
          </Button>
        </nav>
      </div>
    </header>
  );
}
