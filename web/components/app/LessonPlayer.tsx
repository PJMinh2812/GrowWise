"use client";

import { useEffect, useRef, useState } from "react";
import type { Lesson, LessonQuiz } from "@/lib/types";
import QuizOverlay from "./QuizOverlay";
import StoryReader from "./StoryReader";
import { completeLesson } from "@/lib/app/child-actions";

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

export default function LessonPlayer({ lesson, childId }: { lesson: Lesson; childId?: string | null }) {
  if (lesson.lesson_type === "story") {
    return <StoryReader lesson={lesson} childId={childId} />;
  }
  return <VideoLessonPlayer lesson={lesson} childId={childId} />;
}

function VideoLessonPlayer({ lesson, childId }: { lesson: Lesson; childId?: string | null }) {
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
        videoId: lesson.youtube_id ?? "",
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
          onStateChange: (e: any) => {
            // YT.PlayerState.ENDED === 0 → mark the lesson complete.
            if (e?.data === 0 && childId && lesson.id) {
              completeLesson(childId, lesson.id);
            }
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
      <div className="gw-card" style={{ padding: 0, overflow: "hidden" }}>
        <div style={{ aspectRatio: "16/9", background: "#000" }}>
          <div ref={hostRef} style={{ width: "100%", height: "100%" }} />
        </div>
      </div>
      <h1 style={{ fontSize: "20px", fontWeight: 900, color: "var(--ink)", marginTop: "16px" }}>{lesson.title}</h1>
      <p style={{ color: "var(--ink-soft)", marginTop: "4px", fontWeight: 600 }}>{lesson.description}</p>

      {activeQuiz && <QuizOverlay quiz={activeQuiz} onDone={resumeAfterQuiz} />}
    </div>
  );
}
