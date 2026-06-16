"use client";

import { useEffect, useState, useTransition } from "react";
import type { ActiveSurvey } from "@/lib/app/surveys";
import { dismissSurvey } from "@/lib/app/survey-actions";

export default function SurveyBanner({
  survey,
  childId,
}: {
  survey: ActiveSurvey;
  childId?: string | null;
}) {
  const [hidden, setHidden] = useState(false);
  const [, start] = useTransition();
  const laterKey = `survey_later_${survey.id}`;

  // "Để sau" only hides for this browser until a refresh in a new session.
  useEffect(() => {
    if (sessionStorage.getItem(laterKey)) setHidden(true);
  }, [laterKey]);

  if (hidden) return null;

  function doSurvey() {
    window.open(survey.url, "_blank", "noopener,noreferrer");
    setHidden(true);
    start(async () => {
      await dismissSurvey(survey.id, childId);
    });
  }

  function later() {
    sessionStorage.setItem(laterKey, "1");
    setHidden(true);
  }

  return (
    <div className="app-card mb-6 p-4 flex items-start gap-3 border-l-4 border-primary bg-primary/5">
      <span className="text-2xl">📋</span>
      <div className="flex-1 min-w-0">
        <p className="font-bold text-on-surface">{survey.title}</p>
        {survey.description && (
          <p className="text-sm text-on-surface-variant mt-0.5">{survey.description}</p>
        )}
        <div className="flex flex-wrap gap-2 mt-3">
          <button
            onClick={doSurvey}
            className="px-4 py-2 rounded-[14px] bg-primary text-on-primary font-bold text-sm"
          >
            Làm khảo sát
          </button>
          <button
            onClick={later}
            className="px-4 py-2 rounded-[14px] bg-surface-container text-on-surface-variant font-semibold text-sm"
          >
            Để sau
          </button>
        </div>
      </div>
      <button onClick={later} aria-label="Đóng" className="text-on-surface-variant hover:text-on-surface">
        <span className="material-symbols-outlined">close</span>
      </button>
    </div>
  );
}
