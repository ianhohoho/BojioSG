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

export interface DateCell {
  key: string;
  dayLabel: string;
  date: number;
  month: string;
  isToday: boolean;
}

const DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

export function generateDates(count: number): DateCell[] {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return Array.from({ length: count }, (_, i) => {
    const d = new Date(today);
    d.setDate(d.getDate() + i);
    const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
    return {
      key,
      dayLabel: i === 0 ? "Today" : i === 1 ? "Tmr" : DAYS[d.getDay()],
      date: d.getDate(),
      month: MONTHS[d.getMonth()],
      isToday: i === 0,
    };
  });
}

export function getCapacityColor(spotsLeft: number): string {
  if (spotsLeft <= 0) return "bg-red-500 dark:bg-red-400";
  if (spotsLeft === 1) return "bg-orange-500 dark:bg-orange-400";
  if (spotsLeft === 2) return "bg-yellow-500 dark:bg-yellow-400";
  return "bg-green-500 dark:bg-green-400";
}

export function getCapacityTextColor(spotsLeft: number): string {
  if (spotsLeft <= 0) return "text-red-600 dark:text-red-400";
  if (spotsLeft === 1) return "text-orange-600 dark:text-orange-400";
  if (spotsLeft === 2) return "text-yellow-600 dark:text-yellow-400";
  return "text-muted-foreground";
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
