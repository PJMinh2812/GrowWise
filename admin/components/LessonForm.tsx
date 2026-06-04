"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";
import type { Lesson, LessonQuiz } from "@/lib/types";
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
  category: "",
  thumbnail_emoji: "📚",
  duration_seconds: 0,
  order_index: 0,
  is_published: false,
};

export default function LessonForm({ initial, lessonId }: Props) {
  const router = useRouter();
  const [form, setForm] = useState<Lesson>(initial ?? EMPTY_LESSON);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  const isEdit = !!lessonId;

  function set<K extends keyof Lesson>(key: K, value: Lesson[K]) {
    setForm((prev) => ({ ...prev, [key]: value }));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError("");

    const supabase = createClient();
    const payload = { ...form, updated_at: new Date().toISOString() };

    if (isEdit) {
      const { error } = await supabase
        .from("lessons")
        .update(payload)
        .eq("id", lessonId);
      if (error) {
        setError(error.message);
        setSaving(false);
        return;
      }
      router.push("/lessons");
      router.refresh();
    } else {
      const { data: newLesson, error } = await supabase
        .from("lessons")
        .insert(payload)
        .select()
        .single();
      if (error) {
        setError(error.message);
        setSaving(false);
        return;
      }
      // Redirect to edit page so QuizEditor is available immediately
      router.push(`/lessons/${newLesson.id}`);
    }
  }

  const youtubePreviewUrl = form.youtube_id
    ? `https://www.youtube.com/embed/${form.youtube_id}`
    : null;

  return (
    <div className="max-w-3xl mx-auto px-6 py-8">
      <div className="flex items-center gap-3 mb-6">
        <button
          onClick={() => router.back()}
          className="text-gray-400 hover:text-gray-600 text-xl"
        >
          ←
        </button>
        <h1 className="text-xl font-bold text-white">
          {isEdit ? "Chỉnh sửa bài học" : "Thêm bài học mới"}
        </h1>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Audience picker */}
        <div className="bg-white border border-gray-200 rounded-xl p-6">
          <h2 className="font-semibold text-black mb-3">Đối tượng bài học *</h2>
          <div className="flex gap-3">
            {(["child", "parent"] as const).map((a) => (
              <button
                key={a}
                type="button"
                onClick={() => set("audience", a)}
                className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-xl border-2 text-sm font-semibold transition ${
                  form.audience === a
                    ? "border-violet-500 bg-violet-50 text-violet-700"
                    : "border-gray-400 bg-white text-gray-900 hover:border-gray-600"
                }`}
              >
                <span className="text-xl">{a === "child" ? "👦" : "👨‍👩‍👧"}</span>
                {a === "child" ? "Trẻ em" : "Phụ huynh"}
              </button>
            ))}
          </div>
        </div>

        {/* Basic info */}
        <div className="bg-white border border-gray-200 rounded-xl p-6 space-y-4">
          <h2 className="font-semibold text-gray-900">Thông tin cơ bản</h2>

          <div className="grid grid-cols-2 gap-4">
            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tiêu đề *
              </label>
              <input
                value={form.title}
                onChange={(e) => set("title", e.target.value)}
                required
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-black placeholder-black"
                placeholder="Vd: Tiền từ đâu mà có?"
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Mô tả
              </label>
              <textarea
                value={form.description}
                onChange={(e) => set("description", e.target.value)}
                rows={3}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 resize-none text-black placeholder-black"
                placeholder="Mô tả ngắn về bài học..."
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Danh mục *
              </label>
              <input
                value={form.category}
                onChange={(e) => set("category", e.target.value)}
                required
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-black placeholder-black"
                placeholder="Vd: Tiết kiệm, Chi tiêu..."
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Emoji thumbnail
                <span className="ml-1 text-xs text-gray-400 font-normal">
                  (icon đại diện bài học trong app)
                </span>
              </label>
              <div className="flex gap-2 items-center">
                <span className="text-3xl w-10 text-center">
                  {form.thumbnail_emoji || "📚"}
                </span>
                <input
                  value={form.thumbnail_emoji}
                  onChange={(e) => set("thumbnail_emoji", e.target.value)}
                  className="flex-1 border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-black placeholder-black"
                  placeholder="📚"
                  maxLength={8}
                />
              </div>
              <div className="flex gap-1.5 mt-1.5 flex-wrap">
                {[
                  "💰",
                  "💳",
                  "🏦",
                  "🎯",
                  "📈",
                  "🛒",
                  "💡",
                  "🌱",
                  "🎁",
                  "🏆",
                ].map((e) => (
                  <button
                    key={e}
                    type="button"
                    onClick={() => set("thumbnail_emoji", e)}
                    className="text-xl hover:scale-110 transition-transform"
                  >
                    {e}
                  </button>
                ))}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Thứ tự hiển thị
              </label>
              <input
                type="number"
                value={form.order_index}
                onChange={(e) =>
                  set("order_index", parseInt(e.target.value) || 0)
                }
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-black placeholder-black"
              />
            </div>
          </div>
        </div>

        {/* YouTube */}
        <div className="bg-white border border-gray-200 rounded-xl p-6 space-y-4">
          <h2 className="font-semibold text-gray-900">Video YouTube</h2>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              YouTube Video ID *
            </label>
            <input
              value={form.youtube_id}
              onChange={(e) => set("youtube_id", e.target.value.trim())}
              required
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm font-mono focus:outline-none focus:ring-2 focus:ring-violet-500 text-black placeholder-black"
              placeholder="Vd: WRcgRimBac8 (lấy từ URL youtube.com/watch?v=...)"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Thời lượng (giây) *
            </label>
            <input
              type="number"
              value={form.duration_seconds}
              onChange={(e) =>
                set("duration_seconds", parseInt(e.target.value) || 0)
              }
              required
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-black placeholder-black"
              placeholder="180"
            />
            {form.duration_seconds > 0 && (
              <p className="text-xs text-gray-400 mt-1">
                {Math.round(form.duration_seconds / 60)} phút
              </p>
            )}
          </div>
          {youtubePreviewUrl && (
            <div className="rounded-xl overflow-hidden aspect-video bg-gray-100">
              <iframe
                src={youtubePreviewUrl}
                className="w-full h-full"
                allowFullScreen
                title="YouTube preview"
              />
            </div>
          )}
        </div>

        {error && <p className="text-sm text-red-600">{error}</p>}

        <div className="flex gap-3">
          <button
            type="submit"
            disabled={saving}
            className="flex-1 bg-violet-600 text-white py-2.5 rounded-lg text-sm font-semibold hover:bg-violet-700 disabled:opacity-50 transition"
          >
            {saving ? "Đang lưu..." : isEdit ? "Lưu thay đổi" : "Tạo & thêm câu hỏi →"}
          </button>
          <button
            type="button"
            onClick={() => router.back()}
            className="px-6 py-2.5 rounded-lg border border-gray-300 text-sm font-medium text-gray-600 hover:bg-gray-50 transition"
          >
            Hủy
          </button>
        </div>
      </form>

      {/* Quiz editor — shown when editing any lesson */}
      {isEdit && (
        <div className="mt-8">
          <QuizEditor
            lessonId={lessonId}
            lessonTitle={form.title}
            lessonDescription={form.description}
            audience={form.audience}
            lessonDuration={form.duration_seconds}
          />
        </div>
      )}
    </div>
  );
}
