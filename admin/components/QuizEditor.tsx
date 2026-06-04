"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/lib/supabase";
import type { LessonQuiz, QuizOption } from "@/lib/types";

const OPTION_EMOJIS = ["✅", "❌", "🤔", "💡"];

function makeOptions(count: number, existing?: QuizOption[]): QuizOption[] {
  return Array.from({ length: count }, (_, i) => ({
    ...(existing?.[i] ?? {}),
    text: existing?.[i]?.text ?? "",
    emoji: existing?.[i]?.emoji ?? OPTION_EMOJIS[i] ?? "🔘",
    order_index: i,
  }));
}

const EMPTY_QUIZ: Omit<LessonQuiz, "id" | "lesson_id"> = {
  trigger_at: 0,
  question: "",
  question_type: "single",
  correct_index: 0,
  correct_indices: [],
  explanation: "",
  order_index: 0,
  quiz_options: makeOptions(4),
};

interface QuizEditorProps {
  lessonId: string;
  lessonTitle?: string;
  lessonDescription?: string;
  audience?: string;
  lessonDuration?: number;
}

export default function QuizEditor({
  lessonId,
  lessonTitle = "",
  lessonDescription = "",
  audience = "child",
  lessonDuration = 0,
}: QuizEditorProps) {
  const [quizzes, setQuizzes] = useState<LessonQuiz[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState<string | null>(null);
  const [generatingAi, setGeneratingAi] = useState(false);
  const [aiCount, setAiCount] = useState(3);

  useEffect(() => {
    fetchQuizzes();
  }, [lessonId]);

  async function fetchQuizzes() {
    const supabase = createClient();
    const { data } = await supabase
      .from("lesson_quizzes")
      .select("*, quiz_options(*)")
      .eq("lesson_id", lessonId)
      .order("order_index");
    setQuizzes(
      (data ?? []).map((q) => ({
        ...q,
        question_type: q.question_type ?? "single",
        correct_indices: q.correct_indices ?? [],
        quiz_options: [...(q.quiz_options ?? [])].sort(
          (a: QuizOption, b: QuizOption) => a.order_index - b.order_index,
        ),
      })),
    );
    setLoading(false);
  }

  function addQuiz() {
    setQuizzes((prev) => [
      ...prev,
      {
        ...EMPTY_QUIZ,
        order_index: prev.length,
        quiz_options: makeOptions(4),
      } as LessonQuiz,
    ]);
  }

  function updateQuiz(index: number, key: keyof LessonQuiz, value: unknown) {
    setQuizzes((prev) =>
      prev.map((q, i) => (i === index ? { ...q, [key]: value } : q)),
    );
  }

  function updateOption(
    quizIndex: number,
    optIndex: number,
    key: keyof QuizOption,
    value: string,
  ) {
    setQuizzes((prev) =>
      prev.map((q, i) => {
        if (i !== quizIndex) return q;
        const opts = (q.quiz_options ?? []).map((o, j) =>
          j === optIndex ? { ...o, [key]: value } : o,
        );
        return { ...q, quiz_options: opts };
      }),
    );
  }

  function changeOptionCount(quizIndex: number, count: number) {
    setQuizzes((prev) =>
      prev.map((q, i) => {
        if (i !== quizIndex) return q;
        const newOpts = makeOptions(count, q.quiz_options);
        // Clamp correct_index if out of range
        const ci = Math.min(q.correct_index, count - 1);
        const cis = (q.correct_indices ?? []).filter((idx) => idx < count);
        return { ...q, quiz_options: newOpts, correct_index: ci, correct_indices: cis };
      }),
    );
  }

  function toggleMultiCorrect(quizIndex: number, optIndex: number, checked: boolean) {
    setQuizzes((prev) =>
      prev.map((q, i) => {
        if (i !== quizIndex) return q;
        const prev_indices = q.correct_indices ?? [];
        const next = checked
          ? [...prev_indices, optIndex].sort((a, b) => a - b)
          : prev_indices.filter((x) => x !== optIndex);
        return { ...q, correct_indices: next };
      }),
    );
  }

  async function saveQuiz(index: number) {
    const quiz = quizzes[index];
    setSaving(`${index}`);
    const supabase = createClient();

    const quizPayload = {
      trigger_at: quiz.trigger_at,
      question: quiz.question,
      question_type: quiz.question_type ?? "single",
      correct_index: quiz.correct_index,
      correct_indices: quiz.correct_indices ?? [],
      explanation: quiz.explanation,
      order_index: quiz.order_index,
    };

    if (quiz.id) {
      await supabase
        .from("lesson_quizzes")
        .update(quizPayload)
        .eq("id", quiz.id);

      // Delete all existing options then re-insert to avoid stale duplicates
      await supabase.from("quiz_options").delete().eq("quiz_id", quiz.id);
      const options = (quiz.quiz_options ?? []).map((o, j) => ({
        quiz_id: quiz.id,
        text: o.text,
        emoji: o.emoji,
        order_index: j,
      }));
      await supabase.from("quiz_options").insert(options);
    } else {
      const { data: newQuiz } = await supabase
        .from("lesson_quizzes")
        .insert({ lesson_id: lessonId, ...quizPayload })
        .select()
        .single();

      if (newQuiz) {
        const options = (quiz.quiz_options ?? []).map((o, j) => ({
          quiz_id: newQuiz.id,
          text: o.text,
          emoji: o.emoji,
          order_index: j,
        }));
        await supabase.from("quiz_options").insert(options);
      }
    }

    setSaving(null);
    // Refresh to get DB-assigned IDs — prevents duplicate inserts on re-save
    await fetchQuizzes();
  }

  async function deleteQuiz(index: number) {
    const quiz = quizzes[index];
    if (!confirm("Xóa câu hỏi này?")) return;
    if (quiz.id) {
      const supabase = createClient();
      await supabase.from("lesson_quizzes").delete().eq("id", quiz.id);
    }
    setQuizzes((prev) => prev.filter((_, i) => i !== index));
  }

  async function generateAiQuizzes() {
    if (generatingAi) return;
    setGeneratingAi(true);
    try {
      const res = await fetch("/api/ai-quiz", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          title: lessonTitle,
          description: lessonDescription,
          audience,
          count: aiCount,
        }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error ?? "Lỗi AI");

      const total = data.quizzes.length;
      const supabase = createClient();

      for (let idx = 0; idx < total; idx++) {
        const q = (data.quizzes as {
          question: string;
          options: { emoji: string; text: string }[];
          correct_index: number;
          explanation: string;
        }[])[idx];

        const quizPayload = {
          lesson_id: lessonId,
          trigger_at: lessonDuration > 0
            ? Math.round((lessonDuration / (total + 1)) * (idx + 1))
            : 0,
          question: q.question,
          question_type: "single",
          correct_index: q.correct_index ?? 0,
          correct_indices: [],
          explanation: q.explanation ?? "",
          order_index: quizzes.length + idx,
        };

        const { data: newQuiz } = await supabase
          .from("lesson_quizzes")
          .insert(quizPayload)
          .select()
          .single();

        if (newQuiz) {
          const options = (q.options ?? []).map((o, i) => ({
            quiz_id: newQuiz.id,
            text: o.text ?? "",
            emoji: o.emoji ?? OPTION_EMOJIS[i] ?? "🔘",
            order_index: i,
          }));
          await supabase.from("quiz_options").insert(options);
        }
      }

      // Reload from DB to get correct IDs
      await fetchQuizzes();
    } catch (e) {
      alert(`Không thể tạo câu hỏi: ${e}`);
    }
    setGeneratingAi(false);
  }

  if (loading)
    return <div className="text-sm text-gray-400">Đang tải câu hỏi...</div>;

  return (
    <div className="bg-white border border-gray-200 rounded-xl p-6">
      <div className="flex flex-wrap items-center justify-between gap-3 mb-4">
        <h2 className="font-semibold text-gray-900">
          Câu hỏi tương tác ({quizzes.length})
        </h2>
        <div className="flex items-center gap-2">
          {/* AI generate */}
          <div className="flex items-center gap-1.5 bg-violet-50 border border-violet-200 rounded-lg px-2 py-1">
            <span className="text-xs text-violet-600 font-medium">Số lượng:</span>
            <input
              type="number" min={1} max={10} value={aiCount}
              onChange={(e) => setAiCount(Math.min(10, Math.max(1, parseInt(e.target.value) || 1)))}
              className="w-10 text-xs text-center border-0 bg-transparent text-violet-700 font-bold focus:outline-none"
            />
          </div>
          <button
            onClick={generateAiQuizzes}
            disabled={generatingAi || !lessonTitle}
            className="text-xs bg-violet-600 text-white px-3 py-1.5 rounded-lg font-medium hover:bg-violet-700 disabled:opacity-50 transition flex items-center gap-1"
          >
            {generatingAi ? "✨ Đang tạo..." : "✨ AI tạo câu hỏi"}
          </button>
          <button
            onClick={addQuiz}
            className="text-xs bg-gray-50 text-gray-700 border border-gray-200 px-3 py-1.5 rounded-lg font-medium hover:bg-gray-100 transition"
          >
            + Thêm thủ công
          </button>
        </div>
      </div>

      {quizzes.length === 0 && (
        <p className="text-sm text-gray-400 text-center py-6">
          Chưa có câu hỏi nào. Thêm câu hỏi để học sinh tương tác trong lúc xem video.
        </p>
      )}

      <div className="space-y-6">
        {quizzes.map((quiz, qi) => {
          const optCount = quiz.quiz_options?.length ?? 4;
          const isMulti = (quiz.question_type ?? "single") === "multi";

          return (
            <div
              key={quiz.id ?? `new-${qi}`}
              className="border border-gray-100 rounded-xl p-4 space-y-4"
            >
              {/* Header */}
              <div className="flex items-center justify-between">
                <span className="text-sm font-semibold text-gray-700">
                  Câu hỏi {qi + 1}
                </span>
                <div className="flex gap-2">
                  <button
                    onClick={() => saveQuiz(qi)}
                    disabled={saving === `${qi}`}
                    className="text-xs bg-green-50 text-green-700 px-3 py-1 rounded-lg font-medium hover:bg-green-100 disabled:opacity-50 transition"
                  >
                    {saving === `${qi}` ? "Đang lưu..." : "Lưu"}
                  </button>
                  <button
                    onClick={() => deleteQuiz(qi)}
                    className="text-xs bg-red-50 text-red-600 px-3 py-1 rounded-lg font-medium hover:bg-red-100 transition"
                  >
                    Xóa
                  </button>
                </div>
              </div>

              {/* Question type + option count */}
              <div className="flex flex-wrap gap-4">
                <div>
                  <p className="text-xs text-gray-500 mb-1.5">Loại câu hỏi</p>
                  <div className="flex gap-1.5">
                    {(["single", "multi"] as const).map((t) => (
                      <button
                        key={t}
                        type="button"
                        onClick={() => updateQuiz(qi, "question_type", t)}
                        className={`text-xs px-3 py-1.5 rounded-lg font-medium transition ${
                          (quiz.question_type ?? "single") === t
                            ? "bg-violet-600 text-white"
                            : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                        }`}
                      >
                        {t === "single" ? "Chọn 1 đáp án" : "Chọn nhiều đáp án"}
                      </button>
                    ))}
                  </div>
                </div>

                <div>
                  <p className="text-xs text-gray-500 mb-1.5">Số lượng đáp án (2–10)</p>
                  <input
                    type="number"
                    min={2}
                    max={10}
                    value={optCount}
                    onChange={(e) => {
                      const n = Math.min(10, Math.max(2, parseInt(e.target.value) || 2));
                      changeOptionCount(qi, n);
                    }}
                    className="w-20 border border-gray-200 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-black"
                  />
                </div>
              </div>

              {/* Trigger + Question + Explanation */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-xs text-gray-500 mb-1 block">
                    Hiện lúc (giây)
                  </label>
                  <input
                    type="number"
                    value={quiz.trigger_at}
                    onChange={(e) =>
                      updateQuiz(qi, "trigger_at", parseInt(e.target.value) || 0)
                    }
                    className="w-full border border-gray-200 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-black"
                  />
                </div>

                <div className="col-span-2 sm:col-span-1">
                  <label className="text-xs text-gray-500 mb-1 block">Câu hỏi</label>
                  <input
                    value={quiz.question}
                    onChange={(e) => updateQuiz(qi, "question", e.target.value)}
                    className="w-full border border-gray-200 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-black"
                    placeholder="Nhập câu hỏi..."
                  />
                </div>

                <div className="col-span-2">
                  <label className="text-xs text-gray-500 mb-1 block">
                    Giải thích sau khi trả lời
                  </label>
                  <input
                    value={quiz.explanation}
                    onChange={(e) => updateQuiz(qi, "explanation", e.target.value)}
                    className="w-full border border-gray-200 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-black"
                    placeholder="Giải thích đáp án đúng..."
                  />
                </div>
              </div>

              {/* Options */}
              <div>
                <label className="text-xs text-gray-500 mb-2 block">
                  Đáp án —{" "}
                  <span className="text-violet-600 font-medium">
                    {isMulti
                      ? "tích vào các ô vuông để chọn nhiều đáp án đúng"
                      : "chọn nút tròn để đánh dấu đáp án đúng"}
                  </span>
                </label>
                <div className="space-y-2">
                  {(quiz.quiz_options ?? []).map((opt, oi) => {
                    const isSingleCorrect = !isMulti && oi === quiz.correct_index;
                    const isMultiCorrect =
                      isMulti && (quiz.correct_indices ?? []).includes(oi);
                    const isCorrect = isSingleCorrect || isMultiCorrect;

                    return (
                      <div
                        key={oi}
                        className={`flex gap-2 items-center p-2 rounded-lg border transition ${
                          isCorrect
                            ? "bg-green-50 border-green-300"
                            : "bg-gray-50 border-transparent"
                        }`}
                      >
                        {/* Correct marker */}
                        {isMulti ? (
                          <input
                            type="checkbox"
                            checked={isMultiCorrect}
                            onChange={(e) =>
                              toggleMultiCorrect(qi, oi, e.target.checked)
                            }
                            className="accent-violet-600 w-4 h-4 flex-shrink-0"
                          />
                        ) : (
                          <input
                            type="radio"
                            name={`correct-${quiz.id ?? qi}`}
                            checked={isSingleCorrect}
                            onChange={() => updateQuiz(qi, "correct_index", oi)}
                            className="accent-violet-600 w-4 h-4 flex-shrink-0"
                          />
                        )}

                        <span className="text-xs text-gray-400 w-4 flex-shrink-0">
                          {oi + 1}.
                        </span>

                        <input
                          value={opt.emoji}
                          onChange={(e) => updateOption(qi, oi, "emoji", e.target.value)}
                          className="w-12 border border-gray-200 rounded px-2 py-1 text-sm text-center focus:outline-none focus:ring-2 focus:ring-violet-500 text-black"
                          placeholder="🔢"
                        />

                        <input
                          value={opt.text}
                          onChange={(e) => updateOption(qi, oi, "text", e.target.value)}
                          className="flex-1 border border-gray-200 rounded-lg px-3 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-black"
                          placeholder={`Lựa chọn ${oi + 1}...`}
                        />

                        {isCorrect && (
                          <span className="text-xs text-green-600 font-semibold flex-shrink-0">
                            ✓ Đúng
                          </span>
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
