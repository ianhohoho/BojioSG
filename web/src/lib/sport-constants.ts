export interface SportInfo {
  label: string;
  emoji: string;
  color: string;
  textColor: string;
  badgeBg: string;
}

export const SPORTS: Record<string, SportInfo> = {
  pickleball: {
    label: "Pickleball",
    emoji: "\u{1F3D3}",
    color: "bg-lime-500",
    textColor: "text-lime-700 dark:text-lime-400",
    badgeBg: "bg-lime-100 dark:bg-lime-400/10",
  },
  badminton: {
    label: "Badminton",
    emoji: "\u{1F3F8}",
    color: "bg-rose-500",
    textColor: "text-rose-700 dark:text-rose-400",
    badgeBg: "bg-rose-100 dark:bg-rose-400/10",
  },
  tennis: {
    label: "Tennis",
    emoji: "\u{1F3BE}",
    color: "bg-yellow-500",
    textColor: "text-yellow-700 dark:text-yellow-400",
    badgeBg: "bg-yellow-100 dark:bg-yellow-400/10",
  },
  basketball: {
    label: "Basketball",
    emoji: "\u{1F3C0}",
    color: "bg-orange-500",
    textColor: "text-orange-700 dark:text-orange-400",
    badgeBg: "bg-orange-100 dark:bg-orange-400/10",
  },
};

export const SPORT_TYPES = Object.keys(SPORTS);

export function getSportInfo(sportType: string): SportInfo {
  return (
    SPORTS[sportType.toLowerCase()] || {
      label: sportType,
      emoji: "\u{1F3C5}",
      color: "bg-stone-500",
      textColor: "text-stone-700 dark:text-stone-400",
      badgeBg: "bg-stone-100 dark:bg-stone-400/10",
    }
  );
}
