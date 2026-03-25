"use client";

import { useState, useCallback } from "react";
import { apiRequest } from "@/lib/api-client";
import type { ProfileResponse, ProfileUpdate } from "@/lib/types";

export function useProfile(token: string | null) {
  const [profile, setProfile] = useState<ProfileResponse | null>(null);
  const [loading, setLoading] = useState(false);

  const fetchProfile = useCallback(async () => {
    if (!token) return;
    setLoading(true);
    try {
      const data = await apiRequest<ProfileResponse>("/auth/me", { token });
      setProfile(data);
    } catch {
      // ignore
    } finally {
      setLoading(false);
    }
  }, [token]);

  const updateProfile = useCallback(
    async (update: ProfileUpdate) => {
      if (!token) return;
      const data = await apiRequest<ProfileResponse>("/auth/me", {
        method: "PUT",
        body: update,
        token,
      });
      setProfile(data);
      return data;
    },
    [token]
  );

  return { profile, loading, fetchProfile, updateProfile };
}
