export function parseAPIDate(dateStr: string): Date | null {
  if (!dateStr) return null;
  // Handle both ISO format and Python's naive datetime format
  const d = new Date(dateStr);
  return isNaN(d.getTime()) ? null : d;
}

export function formatEventDate(dateStr: string): string {
  const d = parseAPIDate(dateStr);
  if (!d) return dateStr;

  const day = d.getDate();
  const month = d.toLocaleDateString("en-US", { month: "short" });
  const year = d.getFullYear();
  const hour = d.getHours();
  const ampm = hour >= 12 ? "pm" : "am";
  const h12 = hour % 12 || 12;
  const minutes = d.getMinutes();
  const timeStr = minutes > 0 ? `${h12}:${String(minutes).padStart(2, "0")}${ampm}` : `${h12}${ampm}`;

  return `${day} ${month} ${year}, ${timeStr}`;
}

export function formatPrice(price: number): string {
  return `$${price.toFixed(2)}/pax`;
}

export function formatRelativeDate(dateStr: string): string {
  const d = parseAPIDate(dateStr);
  if (!d) return dateStr;

  const now = new Date();
  const diffMs = now.getTime() - d.getTime();
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMs / 3600000);
  const diffDays = Math.floor(diffMs / 86400000);

  if (diffMins < 1) return "Just now";
  if (diffMins < 60) return `${diffMins}m ago`;
  if (diffHours < 24) return `${diffHours}h ago`;
  if (diffDays < 7) return `${diffDays}d ago`;
  return formatEventDate(dateStr);
}
