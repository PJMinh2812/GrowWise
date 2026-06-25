"use client";

import { useState } from "react";
import type { LessonQuiz } from "@/lib/types";
import { useLang } from "./LangProvider";
import { track } from "@/lib/analytics";

/** Modal câu hỏi trắc nghiệm. Dùng chung cho bài video (LessonPlayer) và truyện (StoryReader). */
export default function QuizOverlay({
  quiz,
  onDone,
}: {
  quiz: LessonQuiz;
  onDone: () => void;
}) {
  const { t } = useLang();
  const [picked, setPicked] = useState<number | null>(null);
  const options = (quiz.quiz_options ?? []).slice().sort((a, b) => a.order_index - b.order_index);
  const correct = picked === quiz.correct_index;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="gw-card" style={{ width: "100%", maxWidth: "520px", padding: "24px" }}>
        <p className="text-sm font-semibold text-primary mb-1">{t("quizQuestion")}</p>
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
                onClick={() => { setPicked(i); track("lesson_quiz_answered", { correct: i === quiz.correct_index }); }}
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
              {correct ? t("correctAnswer") : t("incorrectAnswer")} {quiz.explanation}
            </p>
            <button
              onClick={onDone}
              className="gw-btn gw-btn--primary"
              style={{ marginTop: "12px", width: "100%" }}
            >
              {t("continueBtn")}
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
