export default function ComingSoon({ title, icon = "construction" }: { title: string; icon?: string }) {
  return (
    <div>
      <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-6">{title}</h1>
      <div className="app-card p-10 flex flex-col items-center text-center text-on-surface-variant">
        <span className="material-symbols-outlined text-5xl text-primary mb-3">{icon}</span>
        <p>Tính năng đang được hoàn thiện.</p>
      </div>
    </div>
  );
}
