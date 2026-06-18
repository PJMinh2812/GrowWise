"use client";

import { useEffect, useState } from "react";
import type { Lesson, LessonQuiz } from "@/lib/types";
import { speak, stopSpeak } from "@/lib/app/tts";
import QuizOverlay from "./QuizOverlay";

const IMG_FALLBACK =
  "data:image/svg+xml;utf8," +
  encodeURIComponent(
    "<svg xmlns='http://www.w3.org/2000/svg' width='400' height='300'><rect width='100%' height='100%' fill='#eee'/><text x='50%' y='50%' font-size='48' text-anchor='middle' dominant-baseline='middle'>📖</text></svg>",
  );

export default function StoryReader({ lesson }: { lesson: Lesson }) {
  const pages = lesson.story_pages ?? [];
  const quizzes = (lesson.lesson_quizzes ?? [])
    .slice()
    .sort((a, b) => a.order_index - b.order_index);

  // page = chỉ số trang đang đọc; -1 = đã đọc xong (chuyển sang quiz / chúc mừng).
  const [page, setPage] = useState(0);
  const [quizIdx, setQuizIdx] = useState<number | null>(null);
  const [finished, setFinished] = useState(false);

  // Dừng đọc to khi đổi trang hoặc rời màn hình.
  useEffect(() => {
    return () => stopSpeak();
  }, []);

  if (pages.length === 0) {
    return (
      <div className="app-card p-6 text-on-surface-variant">
        Truyện này chưa có trang nào.
      </div>
    );
  }

  function startQuizOrFinish() {
    stopSpeak();
    if (quizzes.length > 0) setQuizIdx(0);
    else setFinished(true);
  }

  function goTo(next: number) {
    stopSpeak();
    setPage(next);
  }

  // Câu hỏi cuối truyện
  if (quizIdx !== null && quizIdx < quizzes.length) {
    const current = quizzes[quizIdx] as LessonQuiz;
    return (
      <div>
        <StoryHeader lesson={lesson} />
        <QuizOverlay
          quiz={current}
          onDone={() => {
            if (quizIdx + 1 < quizzes.length) setQuizIdx(quizIdx + 1);
            else {
              setQuizIdx(null);
              setFinished(true);
            }
          }}
        />
      </div>
    );
  }

  // Màn hình chúc mừng
  if (finished) {
    return (
      <div>
        <StoryHeader lesson={lesson} />
        <div className="app-card p-8 mt-4 text-center">
          <div className="text-6xl mb-3">🎉</div>
          <h2 className="text-xl font-extrabold text-on-surface">Hoàn thành truyện!</h2>
          <p className="text-on-surface-variant mt-1">Bé giỏi lắm! Cùng đọc truyện khác nhé.</p>
        </div>
      </div>
    );
  }

  const current = pages[page];
  const isLast = page === pages.length - 1;

  return (
    <div>
      <StoryHeader lesson={lesson} />

      <div className="app-card overflow-hidden mt-4">
        <div className="bg-black/5 flex items-center justify-center">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src={current.image_url || IMG_FALLBACK}
            alt={`Trang ${page + 1}`}
            className="w-full max-h-[60vh] object-contain bg-white"
            onError={(e) => {
              const el = e.currentTarget;
              el.onerror = null;
              el.src = IMG_FALLBACK;
            }}
          />
        </div>

        {current.caption && (
          <div className="p-4 flex items-start gap-3">
            <button
              type="button"
              onClick={() => speak(current.caption)}
              aria-label="Đọc to"
              title="Đọc to"
              className="shrink-0 w-10 h-10 rounded-full bg-primary/10 text-primary flex items-center justify-center hover:bg-primary/20 active:scale-95 transition"
            >
              <span className="material-symbols-outlined">volume_up</span>
            </button>
            <p className="text-base leading-relaxed text-on-surface flex-1">{current.caption}</p>
          </div>
        )}
      </div>

      {/* Điều hướng */}
      <div className="flex items-center justify-between gap-3 mt-4">
        <button
          type="button"
          disabled={page === 0}
          onClick={() => goTo(page - 1)}
          className="px-4 py-2.5 rounded-[14px] border border-outline text-on-surface font-semibold disabled:opacity-40"
        >
          ← Trang trước
        </button>
        <span className="text-sm text-on-surface-variant font-medium">
          Trang {page + 1}/{pages.length}
        </span>
        {isLast ? (
          <button
            type="button"
            onClick={startQuizOrFinish}
            className="px-4 py-2.5 rounded-[14px] bg-primary text-on-primary font-bold active:scale-95 transition"
          >
            {quizzes.length > 0 ? "Làm câu hỏi →" : "Hoàn thành ✓"}
          </button>
        ) : (
          <button
            type="button"
            onClick={() => goTo(page + 1)}
            className="px-4 py-2.5 rounded-[14px] bg-primary text-on-primary font-bold active:scale-95 transition"
          >
            Trang sau →
          </button>
        )}
      </div>
    </div>
  );
}

function StoryHeader({ lesson }: { lesson: Lesson }) {
  return (
    <div>
      <h1 className="text-xl font-extrabold text-on-surface">{lesson.title}</h1>
      {lesson.description && (
        <p className="text-on-surface-variant mt-1">{lesson.description}</p>
      )}
    </div>
  );
}
