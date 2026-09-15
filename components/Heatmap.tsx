function bucket(minutes: number) {
  if (minutes === 0) return "bg-line/40";
  if (minutes < 15) return "bg-teal-soft";
  if (minutes < 45) return "bg-teal/60";
  return "bg-teal";
}

export default function Heatmap({
  days,
  data,
}: {
  days: number;
  data: Record<string, number>; // date string -> active minutes
}) {
  const cells: { date: string; minutes: number }[] = [];
  for (let i = days - 1; i >= 0; i--) {
    const d = new Date();
    d.setDate(d.getDate() - i);
    const key = d.toISOString().slice(0, 10);
    cells.push({ date: key, minutes: data[key] ?? 0 });
  }

  return (
    <div className="flex flex-wrap gap-1">
      {cells.map((c) => (
        <div
          key={c.date}
          title={`${c.date}: ${c.minutes} min`}
          className={`w-3 h-3 rounded-sm ${bucket(c.minutes)}`}
        />
      ))}
    </div>
  );
}
