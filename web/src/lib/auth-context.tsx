"use client";

import { createContext, useContext, useState, useEffect, useCallback, useRef, type ReactNode } from "react";
import type { Session } from "@supabase/supabase-js";
import { createClient } from "./supabase";
import { setOnUnauthorized } from "./api-client";

interface AuthContextValue {
  session: Session | null;
  token: string | null;
  isAuthenticated: boolean;
  displayName: string;
  nickname: string | null;
  signUp: (email: string, password: string) => Promise<{ error: string | null; needsConfirmation: boolean | null }>;
  signInWithEmail: (email: string, password: string) => Promise<{ error: string | null }>;
  signOut: () => Promise<void>;
  updateNickname: (nickname: string) => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [nickname, setNickname] = useState<string | null>(null);
  const [mounted, setMounted] = useState(false);
  const supabase = createClient();

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setMounted(true);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });

    return () => subscription.unsubscribe();
  }, [supabase.auth]);

  // Wire up auto-logout on 401 from backend
  const signOutRef = useRef<() => Promise<void>>(undefined);
  useEffect(() => {
    setOnUnauthorized(() => {
      signOutRef.current?.();
    });
  }, []);

  const signUp = useCallback(async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signUp({ email, password });
    if (error) return { error: error.message, needsConfirmation: false };
    // Supabase returns a user with empty identities when email is already registered
    if (data.user && (!data.user.identities || data.user.identities.length === 0)) {
      return { error: "An account with this email already exists. Please sign in instead.", needsConfirmation: false };
    }
    const needsConfirmation = data.user && !data.session;
    return { error: null, needsConfirmation };
  }, [supabase.auth]);

  const signInWithEmail = useCallback(async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    return { error: error?.message ?? null };
  }, [supabase.auth]);

  const signOut = useCallback(async () => {
    await supabase.auth.signOut();
    setNickname(null);
  }, [supabase.auth]);
  signOutRef.current = signOut;

  const updateNickname = useCallback((name: string) => {
    setNickname(name);
  }, []);

  if (!mounted) return null;

  const user = session?.user;
  const displayName = nickname
    || user?.user_metadata?.full_name
    || user?.email?.split("@")[0]
    || "";

  const value: AuthContextValue = {
    session,
    token: session?.access_token ?? null,
    isAuthenticated: !!session,
    displayName,
    nickname,
    signUp,
    signInWithEmail,
    signOut,
    updateNickname,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}
