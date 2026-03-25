interface EmptyStateProps {
  icon: React.ReactNode;
  title: string;
  description: string;
}

export function EmptyState({ icon, title, description }: EmptyStateProps) {
  return (
    <div className="text-center py-20">
      <div className="inline-flex h-16 w-16 items-center justify-center rounded-xl bg-muted mb-4">
        {icon}
      </div>
      <p className="font-heading font-semibold">{title}</p>
      <p className="text-muted-foreground text-sm mt-1">{description}</p>
    </div>
  );
}
