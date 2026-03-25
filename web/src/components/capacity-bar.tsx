import { getCapacityColor } from "@/lib/date-utils";

interface CapacityBarProps {
  current: number;
  max: number;
  height?: string;
}

export function CapacityBar({ current, max, height = "h-1" }: CapacityBarProps) {
  const spotsLeft = max - current;
  const fillPercent = Math.min((current / max) * 100, 100);

  return (
    <div className={`${height} w-full rounded-full bg-muted overflow-hidden`}>
      <div
        className={`h-full rounded-full transition-all duration-700 ease-out ${getCapacityColor(spotsLeft)}`}
        style={{ width: `${fillPercent}%` }}
      />
    </div>
  );
}
