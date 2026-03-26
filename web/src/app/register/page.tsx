"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Loader2, Check, Eye, EyeOff, Users, CalendarCheck, Bell } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useAuth } from "@/lib/auth-context";

const perks = [
  { icon: CalendarCheck, text: "Browse and join sports events near you" },
  { icon: Users, text: "Connect with players in your community" },
  { icon: Bell, text: "Get notified when spots open up" },
];

export default function RegisterPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [loading, setLoading] = useState(false);
  const { signUp, isAuthenticated } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (isAuthenticated) {
      router.replace("/profile?setup=1");
    }
  }, [isAuthenticated, router]);

  const passwordsMatch = confirmPassword.length > 0 && password === confirmPassword;
  const passwordMismatch = confirmPassword.length > 0 && password !== confirmPassword;

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setSuccess("");
    if (password.length < 6) {
      setError("Password must be at least 6 characters");
      return;
    }
    if (password !== confirmPassword) {
      setError("Passwords do not match");
      return;
    }
    setLoading(true);
    try {
      const { error, needsConfirmation } = await signUp(email, password);
      if (error) {
        setError(error);
      } else if (needsConfirmation) {
        setSuccess("Check your email for a confirmation link to complete your registration.");
      }
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex flex-1 items-center justify-center px-4 py-8">
      <div className="w-full max-w-[860px] animate-fade-in">
        <div className="grid md:grid-cols-5 gap-0 rounded-2xl border bg-card shadow-sm overflow-hidden">
          {/* Left panel — branding & perks */}
          <div className="md:col-span-2 bg-primary/5 dark:bg-primary/10 p-8 flex flex-col justify-center border-b md:border-b-0 md:border-r border-border">
            <div className="flex items-center gap-2.5 mb-2">
              <span className="text-2xl">🎾</span>
              <span className="font-heading text-2xl font-extrabold tracking-tight">BOJIO SG</span>
            </div>
            <p className="text-muted-foreground text-sm mb-8">
              Don&apos;t get left out — join the game.
            </p>

            <div className="space-y-4">
              {perks.map((perk, i) => (
                <div key={i} className="flex items-start gap-3">
                  <div className="mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-primary/10 dark:bg-primary/15">
                    <perk.icon className="h-4 w-4 text-primary" />
                  </div>
                  <p className="text-sm text-foreground/80 leading-snug pt-1">{perk.text}</p>
                </div>
              ))}
            </div>

            <p className="mt-8 text-xs text-muted-foreground hidden md:block">
              Already have an account?{" "}
              <Link href="/login" className="font-medium text-primary hover:underline underline-offset-4">
                Sign in
              </Link>
            </p>
          </div>

          {/* Right panel — form */}
          <div className="md:col-span-3 p-8">
            <h1 className="font-heading text-xl font-bold tracking-tight mb-1">
              Create your account
            </h1>
            <p className="text-muted-foreground text-sm mb-6">
              It only takes a minute to get started
            </p>

            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-1.5">
                <Label htmlFor="email" className="text-xs uppercase tracking-wider text-muted-foreground font-medium">
                  Email
                </Label>
                <Input
                  id="email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  autoFocus
                  placeholder="you@example.com"
                  className="h-11 rounded-lg bg-background border-border"
                />
              </div>

              <div className="space-y-1.5">
                <Label htmlFor="password" className="text-xs uppercase tracking-wider text-muted-foreground font-medium">
                  Password
                </Label>
                <div className="relative">
                  <Input
                    id="password"
                    type={showPassword ? "text" : "password"}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    minLength={6}
                    placeholder="Min. 6 characters"
                    className="h-11 rounded-lg bg-background border-border pr-10"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                    tabIndex={-1}
                  >
                    {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
              </div>

              <div className="space-y-1.5">
                <Label htmlFor="confirmPassword" className="text-xs uppercase tracking-wider text-muted-foreground font-medium">
                  Confirm Password
                </Label>
                <div className="relative">
                  <Input
                    id="confirmPassword"
                    type={showConfirm ? "text" : "password"}
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    required
                    minLength={6}
                    placeholder="Re-enter your password"
                    className={`h-11 rounded-lg bg-background pr-10 ${
                      passwordMismatch
                        ? "border-destructive focus-visible:ring-destructive"
                        : passwordsMatch
                          ? "border-emerald-500 focus-visible:ring-emerald-500"
                          : "border-border"
                    }`}
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirm(!showConfirm)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                    tabIndex={-1}
                  >
                    {showConfirm ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
                {passwordsMatch && (
                  <p className="text-xs text-emerald-600 dark:text-emerald-400 flex items-center gap-1">
                    <Check className="h-3 w-3" /> Passwords match
                  </p>
                )}
                {passwordMismatch && (
                  <p className="text-xs text-destructive flex items-center gap-1">
                    Passwords do not match
                  </p>
                )}
              </div>

              {error && (
                <div className="rounded-lg bg-destructive/10 px-4 py-3 text-sm text-destructive">
                  {error}
                </div>
              )}
              {success && (
                <div className="rounded-lg bg-emerald-50 dark:bg-emerald-400/5 px-4 py-3 text-sm text-emerald-700 dark:text-emerald-400">
                  {success}
                </div>
              )}

              <Button
                type="submit"
                className="w-full h-11 rounded-lg font-heading font-semibold text-base tracking-wide"
                disabled={loading || !!success}
              >
                {loading ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  "Create account"
                )}
              </Button>
            </form>

            <p className="mt-6 text-sm text-muted-foreground text-center md:hidden">
              Already have an account?{" "}
              <Link href="/login" className="font-medium text-primary hover:underline underline-offset-4">
                Sign in
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
