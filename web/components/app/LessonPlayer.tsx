"use client";

import { useEffect, useRef, useState } from "react";
import type { Lesson, LessonQuiz } from "@/lib/types";

/* eslint-disable @typescript-eslint/no-explicit-any */
declare global {
  interface Window {
    YT?: any;
    onYouTubeIframeAPIReady?: () => void;
  }
}

let apiPromise: Promise<void> | null = null;
function loadYouTubeApi(): Promise<void> {
  if (typeof window === "undefined") return Promise.resolve();
  if (window.YT && window.YT.Player) return Promise.resolve();
  if (apiPromise) return apiPromise;
  apiPromise = new Promise((resolve) => {
    const tag = document.createElement("script");
    tag.src = "https://www.youtube.com/iframe_api";
    window.onYouTubeIframeAPIReady = () => resolve();
    document.head.appendChild(tag);
  });
  return apiPromise;
}

export default function LessonPlayer({ lesson }: { lesson: Lesson }) {
  const hostRef = useRef<HTMLDivElement>(null);
  const playerRef = useRef<any>(null);
  const quizzes = (lesson.lesson_quizzes ?? [])
    .slice()
    .sort((a, b) => a.trigger_at - b.trigger_at);
  const nextIdx = useRef(0);
  const [activeQuiz, setActiveQuiz] = useState<LessonQuiz | null>(null);

  useEffect(() => {
    let interval: ReturnType<typeof setInterval> | null = null;
    let cancelled = false;

    loadYouTubeApi().then(() => {
      if (cancelled || !hostRef.current) return;
      playerRef.current = new window.YT.Player(hostRef.current, {
        videoId: lesson.youtube_id,
        playerVars: { rel: 0, modestbranding: 1 },
        events: {
          onReady: () => {
            interval = setInterval(() => {
              const p = playerRef.current;
              if (!p || !p.getCurrentTime) return;
              const t = p.getCurrentTime();
              const q = quizzes[nextIdx.current];
              if (q && t >= q.trigger_at) {
                p.pauseVideo();
                setActiveQuiz(q);
              }
            }, 600);
          },
        },
      });
    });

    return () => {
      cancelled = true;
      if (interval) clearInterval(interval);
      try {
        playerRef.current?.destroy?.();
      } catch {
        /* ignore */
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [lesson.youtube_id]);

  function resumeAfterQuiz() {
    nextIdx.current += 1;
    setActiveQuiz(null);
    playerRef.current?.playVideo?.();
  }

  return (
    <div>
      <div className="aspect-video rounded-2xl overflow-hidden bg-black">
        <div ref={hostRef} className="w-full h-full" />
      </div>
      <h1 className="text-xl font-extrabold text-on-surface mt-4">{lesson.title}</h1>
      <p className="text-on-surface-variant mt-1">{lesson.description}</p>

      {activeQuiz && <QuizOverlay quiz={activeQuiz} onDone={resumeAfterQuiz} />}
    </div>
  );
}

function QuizOverlay({ quiz, onDone }: { quiz: LessonQuiz; onDone: () => void }) {
  const [picked, setPicked] = useState<number | null>(null);
  const options = (quiz.quiz_options ?? []).slice().sort((a, b) => a.order_index - b.order_index);
  const correct = picked === quiz.correct_index;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="app-card w-full max-w-lg p-6">
        <p className="text-sm font-semibold text-primary mb-1">❓ Câu hỏi!</p>
        <h3 className="text-lg font-bold text-on-surface mb-4">{quiz.question}</h3>
        <div className="space-y-2">
          {options.map((o, i) => {
            const isPicked = picked === i;
            const showState = picked !== null && (i === quiz.correct_index || isPicked);
            const cls =
              picked === null
                ? "border-outline-variant hover:bg-surface-container"
                : i === quiz.correct_index
                  ? "border-green-500 bg-green-50"
                  : isPicked
                    ? "border-error bg-error/10"
                    : "border-outline-variant opacity-60";
            return (
              <button
                key={i}
                disabled={picked !== null}
                onClick={() => setPicked(i)}
                className={`w-full text-left px-4 py-3 rounded-[14px] border-2 font-semibold text-on-surface flex items-center gap-2 ${cls}`}
              >
                <span className="text-xl">{o.emoji}</span>
                <span className="flex-1">{o.text}</span>
                {showState && (
                  <span>{i === quiz.correct_index ? "✓" : isPicked ? "✗" : ""}</span>
                )}
              </button>
            );
          })}
        </div>

        {picked !== null && (
          <div className="mt-4">
            <p className={`text-sm ${correct ? "text-green-600" : "text-error"}`}>
              {correct ? "Chính xác! " : "Chưa đúng. "} {quiz.explanation}
            </p>
            <button
              onClick={onDone}
              className="mt-3 w-full py-2.5 rounded-[14px] bg-primary text-on-primary font-bold"
            >
              Tiếp tục
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
