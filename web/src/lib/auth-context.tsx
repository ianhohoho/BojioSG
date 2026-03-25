"use client";

import { createContext, useContext, useState, useEffect, useCallback, type ReactNode } from "react";
import type { Token } from "./types";

interface AuthState {
  token: string | null;
  userId: number | null;
  username: string | null;
  nickname: string | null;
}

interface AuthContextValue extends AuthState {
  isAuthenticated: boolean;
  displayName: string;
  login: (data: Token) => void;
  logout: () => void;
  updateNickname: (nickname: string) => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

function loadAuth(): AuthState {
  if (typeof window === "undefined") {
    return { token: null, userId: null, username: null, nickname: null };
  }
  return {
    token: localStorage.getItem("token"),
    userId: Number(localStorage.getItem("userId")) || null,
    username: localStorage.getItem("username"),
    nickname: localStorage.getItem("nickname"),
  };
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [auth, setAuth] = useState<AuthState>({
    token: null,
    userId: null,
    username: null,
    nickname: null,
  });
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setAuth(loadAuth());
    setMounted(true);
  }, []);

  const login = useCallback((data: Token) => {
    localStorage.setItem("token", data.access_token);
    localStorage.setItem("userId", String(data.user_id));
    localStorage.setItem("username", data.username);
    if (data.nickname) localStorage.setItem("nickname", data.nickname);
    setAuth({
      token: data.access_token,
      userId: data.user_id,
      username: data.username,
      nickname: data.nickname,
    });
  }, []);

  const logout = useCallback(() => {
    localStorage.removeItem("token");
    localStorage.removeItem("userId");
    localStorage.removeItem("username");
    localStorage.removeItem("nickname");
    setAuth({ token: null, userId: null, username: null, nickname: null });
  }, []);

  const updateNickname = useCallback((nickname: string) => {
    localStorage.setItem("nickname", nickname);
    setAuth((prev) => ({ ...prev, nickname }));
  }, []);

  if (!mounted) return null;

  const value: AuthContextValue = {
    ...auth,
    isAuthenticated: !!auth.token,
    displayName: auth.nickname || auth.username || "",
    login,
    logout,
    updateNickname,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}
