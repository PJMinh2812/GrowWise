"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";
import type { Lesson, StoryPage } from "@/lib/types";
import QuizEditor from "./QuizEditor";

interface Props {
  initial?: Lesson;
  lessonId?: string;
}

const EMPTY_LESSON: Lesson = {
  title: "",
  description: "",
  youtube_id: "",
  lesson_type: "video",
  story_pages: [],
  audience: "child",
  category: "Tiết kiệm",
  thumbnail_emoji: "📚",
  thumbnail_url: "",
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
  const [uploading, setUploading] = useState(false);
  const [uploadingThumb, setUploadingThumb] = useState(false);

  const isEdit = !!lessonId;
  const pages: StoryPage[] = form.story_pages ?? [];

  function set<K extends keyof Lesson>(key: K, value: Lesson[K]) {
    setForm((prev) => ({ ...prev, [key]: value }));
  }

  function setPages(next: StoryPage[]) {
    set("story_pages", next);
  }

  // Upload nhiều ảnh truyện lên Supabase Storage (bucket lesson-images),
  // mỗi ảnh thành 1 trang { image_url, caption: "" }.
  async function onPickStoryImages(e: React.ChangeEvent<HTMLInputElement>) {
    const files = Array.from(e.target.files ?? []);
    e.target.value = ""; // cho phép chọn lại cùng file
    if (files.length === 0) return;
    setError("");
    setUploading(true);
    try {
      const supabase = createClient();
      const uploaded: StoryPage[] = [];
      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        const ext = file.name.split(".").pop()?.toLowerCase() || "jpg";
        const path = `lessons/${Date.now()}-${i}.${ext}`;
        const { error: upErr } = await supabase.storage
          .from("lesson-images")
          .upload(path, file, { contentType: file.type || "image/jpeg", upsert: true });
        if (upErr) throw upErr;
        const url = supabase.storage.from("lesson-images").getPublicUrl(path).data.publicUrl;
        uploaded.push({ image_url: url, caption: "" });
      }
      setPages([...pages, ...uploaded]);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Tải ảnh thất bại");
    } finally {
      setUploading(false);
    }
  }

  function updateCaption(idx: number, caption: string) {
    setPages(pages.map((p, i) => (i === idx ? { ...p, caption } : p)));
  }

  function movePage(idx: number, dir: -1 | 1) {
    const target = idx + dir;
    if (target < 0 || target >= pages.length) return;
    const next = [...pages];
    [next[idx], next[target]] = [next[target], next[idx]];
    setPages(next);
  }

  function removePage(idx: number) {
    setPages(pages.filter((_, i) => i !== idx));
  }

  // Upload ảnh thumbnail cho bài học (1 ảnh, lưu vào bucket lesson-images).
  async function onPickThumbnail(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    e.target.value = "";
    if (!file) return;
    setError("");
    setUploadingThumb(true);
    try {
      const supabase = createClient();
      const ext = file.name.split(".").pop()?.toLowerCase() || "jpg";
      const path = `thumbnails/${Date.now()}.${ext}`;
      const { error: upErr } = await supabase.storage
        .from("lesson-images")
        .upload(path, file, { contentType: file.type || "image/jpeg", upsert: true });
      if (upErr) throw upErr;
      const url = supabase.storage.from("lesson-images").getPublicUrl(path).data.publicUrl;
      set("thumbnail_url", url);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Tải ảnh thất bại");
    } finally {
      setUploadingThumb(false);
    }
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
                  <label className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Biểu tượng / Ảnh bìa</label>
                  <div className="w-14 h-14 bg-surface border border-outline-variant rounded-xl flex items-center justify-center text-3xl overflow-hidden">
                    {form.thumbnail_url ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img src={form.thumbnail_url} alt="Ảnh bìa" className="w-full h-full object-cover" />
                    ) : (
                      form.thumbnail_emoji || "📚"
                    )}
                  </div>
                  {/* Upload ảnh bìa */}
                  <label className="mt-1 text-xs text-center px-2 py-1 border border-outline-variant rounded-lg cursor-pointer hover:bg-surface-container text-on-surface max-w-[200px]">
                    {uploadingThumb ? "Đang tải..." : form.thumbnail_url ? "Đổi ảnh bìa" : "📷 Tải ảnh bìa"}
                    <input
                      type="file"
                      accept="image/*"
                      onChange={onPickThumbnail}
                      disabled={uploadingThumb}
                      className="hidden"
                    />
                  </label>
                  {form.thumbnail_url && (
                    <button
                      type="button"
                      onClick={() => set("thumbnail_url", "")}
                      className="text-xs text-error hover:underline max-w-[200px]"
                    >
                      Xóa ảnh, dùng emoji
                    </button>
                  )}
                  {!form.thumbnail_url && (
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
                  )}
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

              {/* Loại bài học */}
              <div className="flex flex-col gap-1">
                <label className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Loại bài học</label>
                <div className="flex gap-2">
                  {[
                    { value: "video", label: "▶️ Video" },
                    { value: "story", label: "📖 Truyện tranh" },
                  ].map((opt) => (
                    <button
                      key={opt.value}
                      type="button"
                      onClick={() => set("lesson_type", opt.value as "video" | "story")}
                      className={`flex-1 px-4 py-2.5 rounded-lg border text-sm font-semibold transition-all ${
                        (form.lesson_type ?? "video") === opt.value
                          ? "border-primary bg-primary/10 text-primary"
                          : "border-outline-variant text-on-surface hover:bg-surface-container"
                      }`}
                    >
                      {opt.label}
                    </button>
                  ))}
                </div>
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
          {(form.lesson_type ?? "video") === "video" && (
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
          )}

          {/* Trang truyện (story) */}
          {form.lesson_type === "story" && (
            <section className="bg-surface-container-lowest border border-outline-variant rounded-xl p-6">
              <div className="flex items-center justify-between mb-5">
                <div className="flex items-center gap-2">
                  <span className="text-lg">📖</span>
                  <h3 className="text-lg font-semibold text-on-surface">Trang truyện</h3>
                </div>
                <label className="px-4 py-2 text-sm font-semibold bg-primary text-on-primary rounded-lg cursor-pointer hover:opacity-90 transition active:scale-95">
                  {uploading ? "Đang tải..." : "+ Thêm ảnh"}
                  <input
                    type="file"
                    accept="image/*"
                    multiple
                    onChange={onPickStoryImages}
                    disabled={uploading}
                    className="hidden"
                  />
                </label>
              </div>

              {pages.length === 0 ? (
                <p className="text-sm text-on-surface-variant text-center py-8">
                  Chưa có trang nào. Bấm “+ Thêm ảnh” để tải ảnh truyện lên (chọn được nhiều ảnh một lúc).
                </p>
              ) : (
                <div className="space-y-3">
                  {pages.map((p, idx) => (
                    <div
                      key={idx}
                      className="flex gap-3 p-3 bg-surface border border-outline-variant rounded-xl"
                    >
                      <div className="shrink-0 w-24">
                        {/* eslint-disable-next-line @next/next/no-img-element */}
                        <img
                          src={p.image_url}
                          alt={`Trang ${idx + 1}`}
                          className="w-24 h-24 object-cover rounded-lg bg-surface-container"
                        />
                        <p className="text-xs text-center text-on-surface-variant mt-1">Trang {idx + 1}</p>
                      </div>
                      <div className="flex-1 flex flex-col gap-2">
                        <textarea
                          value={p.caption}
                          onChange={(e) => updateCaption(idx, e.target.value)}
                          rows={3}
                          placeholder="Lời kể cho trang này (sẽ hiện dưới ảnh và dùng để đọc to)..."
                          className="w-full bg-surface border border-outline-variant rounded-lg px-3 py-2 text-sm text-on-surface outline-none focus:border-primary resize-none"
                        />
                        <div className="flex items-center gap-2">
                          <button
                            type="button"
                            onClick={() => movePage(idx, -1)}
                            disabled={idx === 0}
                            className="px-2 py-1 text-sm border border-outline-variant rounded-lg text-on-surface disabled:opacity-40 hover:bg-surface-container"
                          >
                            ↑
                          </button>
                          <button
                            type="button"
                            onClick={() => movePage(idx, 1)}
                            disabled={idx === pages.length - 1}
                            className="px-2 py-1 text-sm border border-outline-variant rounded-lg text-on-surface disabled:opacity-40 hover:bg-surface-container"
                          >
                            ↓
                          </button>
                          <button
                            type="button"
                            onClick={() => removePage(idx)}
                            className="ml-auto px-3 py-1 text-sm border border-error text-error rounded-lg hover:bg-error hover:text-white transition"
                          >
                            Xóa
                          </button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </section>
          )}

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
              <div className="h-32 bg-primary/10 flex items-center justify-center relative overflow-hidden">
                {form.thumbnail_url ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={form.thumbnail_url} alt="Ảnh bìa" className="absolute inset-0 w-full h-full object-cover" />
                ) : (
                  <span className="text-5xl">{form.thumbnail_emoji || "📚"}</span>
                )}
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
