"use client";

import { useState } from "react";
import type { LessonQuiz } from "@/lib/types";

/** Modal câu hỏi trắc nghiệm. Dùng chung cho bài video (LessonPlayer) và truyện (StoryReader). */
export default function QuizOverlay({
  quiz,
  onDone,
}: {
  quiz: LessonQuiz;
  onDone: () => void;
}) {
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
