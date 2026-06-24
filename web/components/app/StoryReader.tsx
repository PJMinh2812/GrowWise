"use client";

import { useEffect, useState } from "react";
import type { Lesson, LessonQuiz } from "@/lib/types";
import { speak, stopSpeak } from "@/lib/app/tts";
import QuizOverlay from "./QuizOverlay";
import { completeLesson } from "@/lib/app/child-actions";
import Icon from "@/components/Icon";
import Emoji from "@/components/Emoji";

const IMG_FALLBACK =
  "data:image/svg+xml;utf8," +
  encodeURIComponent(
    "<svg xmlns='http://www.w3.org/2000/svg' width='400' height='300'><rect width='100%' height='100%' fill='#F9ECDA'/><text x='50%' y='50%' font-size='72' text-anchor='middle' dominant-baseline='middle'>📖</text></svg>",
  );

export default function StoryReader({ lesson, childId }: { lesson: Lesson; childId?: string | null }) {
  const pages = lesson.story_pages ?? [];
  const quizzes = (lesson.lesson_quizzes ?? [])
    .slice()
    .sort((a, b) => a.order_index - b.order_index);

  const [page, setPage] = useState(0);
  const [quizIdx, setQuizIdx] = useState<number | null>(null);
  const [finished, setFinished] = useState(false);

  useEffect(() => {
    return () => stopSpeak();
  }, []);

  // Mark the lesson complete once the child reaches the finish screen.
  useEffect(() => {
    if (finished && childId && lesson.id) {
      completeLesson(childId, lesson.id);
    }
  }, [finished, childId, lesson.id]);

  if (pages.length === 0) {
    return (
      <div className="gw-card" style={{ padding: "24px", color: "var(--ink-soft)", textAlign: "center" }}>
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

  // Quiz sau truyện
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

  // Màn hình hoàn thành
  if (finished) {
    return (
      <div>
        <StoryHeader lesson={lesson} />
        <div className="gw-card gw-card--glow" style={{ padding: "40px 24px", marginTop: "16px", textAlign: "center" }}>
          <div style={{ marginBottom: "12px", animation: "bouncein .5s cubic-bezier(.2,1.4,.4,1)" }}><Emoji name="party" size={64} /></div>
          <h2 style={{ fontSize: "22px", fontWeight: 900, color: "var(--ink)" }}>Hoàn thành truyện!</h2>
          <p style={{ color: "var(--ink-soft)", marginTop: "8px", fontWeight: 600 }}>Bé giỏi lắm! Cùng đọc truyện khác nhé.</p>
          <div style={{ marginTop: "24px" }}>
            <button
              type="button"
              className="gw-btn gw-btn--primary"
              onClick={() => { setFinished(false); setPage(0); }}
            >
              <Icon name="replay" />
              Đọc lại
            </button>
          </div>
        </div>
      </div>
    );
  }

  const current = pages[page];
  const isLast = page === pages.length - 1;
  const progress = ((page + 1) / pages.length) * 100;

  return (
    <div>
      <StoryHeader lesson={lesson} />

      {/* Story card: image + caption */}
      <div className="gw-card" style={{ padding: 0, overflow: "hidden", marginTop: "16px" }}>
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src={current.image_url || IMG_FALLBACK}
          alt={`Trang ${page + 1}`}
          style={{ width: "100%", maxHeight: "60vh", objectFit: "contain", background: "var(--surface-low)", display: "block" }}
          onError={(e) => {
            const el = e.currentTarget;
            el.onerror = null;
            el.src = IMG_FALLBACK;
          }}
        />

        {current.caption && (
          <div style={{ padding: "16px", display: "flex", alignItems: "flex-start", gap: "12px" }}>
            <button
              type="button"
              className="gw-btn gw-btn--ghost gw-btn--sm"
              style={{ width: "42px", padding: 0, flexShrink: 0, borderRadius: "50%" }}
              onClick={() => speak(current.caption)}
              aria-label="Đọc to"
            >
              <Icon name="volume_up" style={{ fontSize: "20px" }} />
            </button>
            <p style={{ fontSize: "15px", lineHeight: 1.6, color: "var(--ink)", fontWeight: 600, flex: 1 }}>
              {current.caption}
            </p>
          </div>
        )}
      </div>

      {/* Progress bar */}
      <div style={{ margin: "16px 0 4px", display: "flex", alignItems: "center", gap: "10px" }}>
        <div className="gw-progress" style={{ flex: 1 }}>
          <i style={{ width: `${progress}%` }} />
        </div>
        <span style={{ fontSize: "13px", fontWeight: 800, color: "var(--ink-soft)", whiteSpace: "nowrap" }}>
          {page + 1} / {pages.length}
        </span>
      </div>

      {/* Navigation */}
      <div style={{ display: "flex", gap: "12px", marginTop: "12px" }}>
        <button
          type="button"
          disabled={page === 0}
          onClick={() => goTo(page - 1)}
          className="gw-btn gw-btn--ghost gw-btn--sm"
          style={{ flex: 1 }}
        >
          <Icon name="arrow_back" />
          Trước
        </button>
        {isLast ? (
          <button
            type="button"
            onClick={startQuizOrFinish}
            className="gw-btn gw-btn--primary gw-btn--sm"
            style={{ flex: 1 }}
          >
            {quizzes.length > 0 ? "Làm bài" : "Xong"}
            <Icon name={quizzes.length > 0 ? "quiz" : "check_circle"} />
          </button>
        ) : (
          <button
            type="button"
            onClick={() => goTo(page + 1)}
            className="gw-btn gw-btn--primary gw-btn--sm"
            style={{ flex: 1 }}
          >
            Trang sau
            <Icon name="arrow_forward" />
          </button>
        )}
      </div>
    </div>
  );
}

function StoryHeader({ lesson }: { lesson: Lesson }) {
  return (
    <div style={{ marginBottom: "4px" }}>
      <h1 style={{ fontSize: "20px", fontWeight: 900, color: "var(--ink)" }}>{lesson.title}</h1>
      {lesson.description && (
        <p style={{ color: "var(--ink-soft)", marginTop: "4px", fontWeight: 600 }}>{lesson.description}</p>
      )}
    </div>
  );
}
