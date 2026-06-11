"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";
import type { Lesson } from "@/lib/types";
import QuizEditor from "./QuizEditor";

interface Props {
  initial?: Lesson;
  lessonId?: string;
}

const EMPTY_LESSON: Lesson = {
  title: "",
  description: "",
  youtube_id: "",
  audience: "child",
  category: "Tiết kiệm",
  thumbnail_emoji: "📚",
  duration_seconds: 0,
  order_index: 0,
  is_published: false,
};

const EMOJI_PICKS = ["💰","💳","🏦","🎯","📈","🛒","💡","🌱","🎁","🏆","🐷","📚","🏫","🏧"];
const CATEGORIES = ["Tiết kiệm", "Đầu tư", "Chi tiêu", "Kiếm tiền"];
const AUDIENCES = [
  { value: "child",  label: "Trẻ em" },
  { value: "parent", label: "Phụ huynh" },
];

export default function LessonForm({ initial, lessonId }: Props) {
  const router = useRouter();
  const [form, setForm] = useState<Lesson>(initial ?? EMPTY_LESSON);
  const [saving, setSaving] = useState(false);
  const [publishing, setPublishing] = useState(false);
  const [error, setError] = useState("");

  const isEdit = !!lessonId;

  function set<K extends keyof Lesson>(key: K, value: Lesson[K]) {
    setForm((prev) => ({ ...prev, [key]: value }));
  }

  async function save(publish: boolean) {
    const isSavingDraft = !publish;
    if (publish) setPublishing(true);
    else setSaving(true);
    setError("");

    const supabase = createClient();
    const payload = {
      ...form,
      is_published: publish ? true : form.is_published,
      updated_at: new Date().toISOString(),
    };

    if (isEdit) {
      const { error } = await supabase.from("lessons").update(payload).eq("id", lessonId);
      if (error) {
        setError(error.message);
        isSavingDraft ? setSaving(false) : setPublishing(false);
        return;
      }
      router.push("/admin/lessons");
      router.refresh();
    } else {
      const { data: newLesson, error } = await supabase.from("lessons").insert(payload).select().single();
      if (error) {
        setError(error.message);
        isSavingDraft ? setSaving(false) : setPublishing(false);
        return;
      }
      router.push(`/admin/lessons/${newLesson.id}`);
    }
  }

  const youtubeEmbedUrl = form.youtube_id
    ? `https://www.youtube.com/embed/${form.youtube_id}`
    : null;

  return (
    <div className="min-h-screen flex flex-col">
      {/* Top App Bar */}
      <header className="h-16 px-6 bg-surface border-b border-outline-variant flex justify-between items-center sticky top-0 z-40">
        <div className="flex items-center gap-4">
          <button
            type="button"
            onClick={() => router.push("/admin/lessons")}
            className="p-2 hover:bg-surface-container-high rounded-full transition-colors text-on-surface text-lg leading-none"
          >
            ←
          </button>
          <div className="flex flex-col">
            <span className="text-xs text-on-surface-variant uppercase tracking-wider">Danh sách bài học</span>
            <h2 className="text-lg font-semibold text-on-surface leading-tight">
              {isEdit ? "Chỉnh sửa bài học" : "Tạo bài học mới"}
            </h2>
          </div>
        </div>
        <div className="flex items-center gap-3">
          {error && <p className="text-sm text-error">{error}</p>}
          <button
            type="button"
            onClick={() => save(false)}
            disabled={saving || publishing}
            className="px-4 py-2 text-sm font-medium border border-outline text-on-surface rounded-lg hover:bg-surface-container transition-colors disabled:opacity-50"
          >
            {saving ? "Đang lưu..." : "Lưu nháp"}
          </button>
          <button
            type="button"
            onClick={() => save(true)}
            disabled={saving || publishing}
            className="px-4 py-2 text-sm font-semibold bg-primary text-on-primary rounded-lg hover:opacity-90 transition-all shadow-sm active:scale-95 disabled:opacity-50"
          >
            {publishing ? "Đang xuất bản..." : "Xuất bản"}
          </button>
        </div>
      </header>

      {/* 2-column layout */}
      <div className="p-6 max-w-[1440px] mx-auto w-full grid grid-cols-1 md:grid-cols-12 gap-6 flex-1">
        {/* ── LEFT column (7/12) ── */}
        <div className="md:col-span-7 space-y-6">

          {/* Thông tin cơ bản */}
          <section className="bg-surface-container-lowest border border-outline-variant rounded-xl p-6">
            <div className="flex items-center gap-2 mb-5">
              <span className="text-primary text-lg">ℹ️</span>
              <h3 className="text-lg font-semibold text-on-surface">Thông tin cơ bản</h3>
            </div>
            <div className="space-y-4">
              {/* Emoji + Title */}
              <div className="flex gap-4">
                <div className="flex flex-col gap-1">
                  <label className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Biểu tượng</label>
                  <div className="w-14 h-14 bg-surface border border-outline-variant rounded-xl flex items-center justify-center text-3xl">
                    {form.thumbnail_emoji || "📚"}
                  </div>
                  <div className="flex gap-1 flex-wrap mt-1 max-w-[200px]">
                    {EMOJI_PICKS.map(e => (
                      <button
                        key={e}
                        type="button"
                        onClick={() => set("thumbnail_emoji", e)}
                        className={`text-lg hover:scale-110 transition-transform rounded p-0.5 ${form.thumbnail_emoji === e ? 'bg-primary/10 ring-1 ring-primary' : ''}`}
                      >
                        {e}
                      </button>
                    ))}
                  </div>
                </div>
                <div className="flex-1 flex flex-col gap-1">
                  <label className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Tiêu đề bài học *</label>
                  <input
                    value={form.title}
                    onChange={e => set("title", e.target.value)}
                    required
                    placeholder="VD: Hiểu về lãi suất kép"
                    className="w-full bg-surface border border-outline-variant rounded-lg px-4 py-2.5 text-sm text-on-surface outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
                  />
                </div>
              </div>

              {/* Description */}
              <div className="flex flex-col gap-1">
                <label className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Mô tả ngắn</label>
                <textarea
                  value={form.description}
                  onChange={e => set("description", e.target.value)}
                  rows={3}
                  placeholder="Nhập mô tả tóm tắt nội dung bài học..."
                  className="w-full bg-surface border border-outline-variant rounded-lg px-4 py-2.5 text-sm text-on-surface outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all resize-none"
                />
              </div>

              {/* Category / Audience / Duration */}
              <div className="grid grid-cols-3 gap-3">
                <div className="flex flex-col gap-1">
                  <label className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Danh mục</label>
                  <select
                    value={form.category}
                    onChange={e => set("category", e.target.value)}
                    className="bg-surface border border-outline-variant rounded-lg px-3 py-2.5 text-sm text-on-surface outline-none focus:border-primary"
                  >
                    {CATEGORIES.map(c => <option key={c}>{c}</option>)}
                  </select>
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Đối tượng</label>
                  <select
                    value={form.audience}
                    onChange={e => set("audience", e.target.value as "child" | "parent")}
                    className="bg-surface border border-outline-variant rounded-lg px-3 py-2.5 text-sm text-on-surface outline-none focus:border-primary"
                  >
                    {AUDIENCES.map(a => <option key={a.value} value={a.value}>{a.label}</option>)}
                  </select>
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Thứ tự</label>
                  <input
                    type="number"
                    value={form.order_index}
                    onChange={e => set("order_index", parseInt(e.target.value) || 0)}
                    className="bg-surface border border-outline-variant rounded-lg px-3 py-2.5 text-sm text-on-surface outline-none focus:border-primary"
                  />
                </div>
              </div>
            </div>
          </section>

          {/* Video */}
          <section className="bg-surface-container-lowest border border-outline-variant rounded-xl p-6">
            <div className="flex items-center gap-2 mb-5">
              <span className="text-lg">▶️</span>
              <h3 className="text-lg font-semibold text-on-surface">Video bài giảng</h3>
            </div>
            <div className="space-y-4">
              <div className="flex flex-col gap-1">
                <label className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider">YouTube Video ID *</label>
                <input
                  value={form.youtube_id}
                  onChange={e => set("youtube_id", e.target.value.trim())}
                  placeholder="VD: WRcgRimBac8 (từ youtube.com/watch?v=...)"
                  className="w-full bg-surface border border-outline-variant rounded-lg px-4 py-2.5 text-sm text-on-surface outline-none focus:border-primary"
                />
              </div>
              <div className="flex flex-col gap-1">
                <label className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Thời lượng (giây) *</label>
                <input
                  type="number"
                  value={form.duration_seconds}
                  onChange={e => set("duration_seconds", parseInt(e.target.value) || 0)}
                  placeholder="180"
                  className="bg-surface border border-outline-variant rounded-lg px-4 py-2.5 text-sm text-on-surface outline-none focus:border-primary"
                />
                {form.duration_seconds > 0 && (
                  <p className="text-xs text-on-surface-variant">{Math.round(form.duration_seconds / 60)} phút</p>
                )}
              </div>

              {/* Video preview */}
              <div className="aspect-video bg-inverse-surface rounded-xl flex items-center justify-center overflow-hidden relative">
                {youtubeEmbedUrl ? (
                  <iframe src={youtubeEmbedUrl} className="w-full h-full" allowFullScreen title="YouTube preview" />
                ) : (
                  <>
                    <span className="text-[64px] opacity-40">▶️</span>
                    <span className="absolute bottom-4 text-sm text-surface/60">Nhập Video ID để xem trước</span>
                  </>
                )}
              </div>
            </div>
          </section>

          {/* Quiz */}
          {isEdit && (
            <section className="bg-surface-container-lowest border border-outline-variant rounded-xl p-6">
              <div className="flex items-center gap-2 mb-5">
                <span className="text-lg">📝</span>
                <h3 className="text-lg font-semibold text-on-surface">Câu hỏi trắc nghiệm</h3>
              </div>
              <QuizEditor
                lessonId={lessonId}
                lessonTitle={form.title}
                lessonDescription={form.description}
                audience={form.audience}
                lessonDuration={form.duration_seconds}
              />
            </section>
          )}
        </div>

        {/* ── RIGHT column (5/12) ── */}
        <div className="md:col-span-5 space-y-6">

          {/* Card preview */}
          <section className="bg-surface-container-lowest border border-outline-variant rounded-xl p-6">
            <div className="flex items-center gap-2 mb-5">
              <span className="text-lg">👁️</span>
              <h3 className="text-lg font-semibold text-on-surface">Xem trước thẻ</h3>
            </div>
            <div className="max-w-[260px] mx-auto bg-surface rounded-xl shadow-lg border border-outline-variant overflow-hidden hover:scale-[1.02] transition-transform cursor-pointer">
              <div className="h-32 bg-primary/10 flex items-center justify-center relative">
                <span className="text-5xl">{form.thumbnail_emoji || "📚"}</span>
                {form.category && (
                  <div className="absolute top-2 left-2 bg-white/90 backdrop-blur px-2 py-0.5 rounded-full text-xs font-bold text-primary">
                    {form.category}
                  </div>
                )}
              </div>
              <div className="p-4 space-y-2">
                <h4 className="text-sm font-semibold text-on-surface line-clamp-2">
                  {form.title || "Tiêu đề bài học"}
                </h4>
                {form.description && (
                  <p className="text-xs text-on-surface-variant line-clamp-2">{form.description}</p>
                )}
                <div className="flex items-center justify-between pt-2 border-t border-outline-variant">
                  <div className="flex items-center gap-1 text-primary">
                    <span className="text-xs">⏱</span>
                    <span className="text-xs">{form.duration_seconds > 0 ? Math.round(form.duration_seconds / 60) + ' phút' : '—'}</span>
                  </div>
                  <span className="text-primary text-sm">→</span>
                </div>
              </div>
            </div>
          </section>

          {/* Settings */}
          <section className="bg-surface-container-lowest border border-outline-variant rounded-xl p-6">
            <div className="space-y-5">
              {/* Published toggle */}
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-on-surface">Trạng thái bài học</p>
                  <p className="text-xs text-on-surface-variant mt-0.5">
                    {form.is_published ? "Cho phép người dùng xem" : "Bài học đang ẩn"}
                  </p>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={form.is_published}
                    onChange={e => set("is_published", e.target.checked)}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-outline-variant rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary relative" />
                </label>
              </div>

              <div className="h-px bg-outline-variant" />

              {/* Timestamps */}
              {isEdit && (
                <div className="space-y-2 text-sm">
                  <div className="flex justify-between">
                    <span className="text-on-surface-variant">Người tạo:</span>
                    <span className="font-medium text-on-surface">Admin</span>
                  </div>
                </div>
              )}
            </div>
          </section>

          {/* Danger zone */}
          {isEdit && (
            <section className="bg-error-container/10 border border-error/20 rounded-xl p-6">
              <h3 className="text-sm font-medium text-error mb-2 flex items-center gap-2">
                ⚠️ Vùng nguy hiểm
              </h3>
              <p className="text-xs text-on-surface-variant mb-4">
                Xóa bài học sẽ không thể hoàn tác và ảnh hưởng đến tiến trình của học sinh.
              </p>
              <button
                type="button"
                onClick={async () => {
                  if (!confirm('Xóa bài học này?')) return
                  const supabase = createClient()
                  await supabase.from('lessons').delete().eq('id', lessonId!)
                  router.push('/admin/lessons')
                }}
                className="w-full py-2 border border-error text-error text-sm font-medium rounded-lg hover:bg-error hover:text-white transition-all active:scale-95"
              >
                Xóa bài học này
              </button>
            </section>
          )}
        </div>
      </div>
    </div>
  );
}
