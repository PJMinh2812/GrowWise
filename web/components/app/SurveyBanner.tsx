"use client";

import { useEffect, useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import type { ActiveSurvey } from "@/lib/app/surveys";
import { dismissSurvey } from "@/lib/app/survey-actions";
import { useLang } from "./LangProvider";

export default function SurveyBanner({
  survey,
  childId,
}: {
  survey: ActiveSurvey;
  childId?: string | null;
}) {
  const router = useRouter();
  const { t } = useLang();
  const [hidden, setHidden] = useState(false);
  const [opened, setOpened] = useState(false);
  const [, start] = useTransition();
  const laterKey = `survey_later_${survey.id}`;

  // "Để sau" only hides for this browser session.
  useEffect(() => {
    if (sessionStorage.getItem(laterKey)) setHidden(true);
  }, [laterKey]);

  if (hidden) return null;

  function openForm() {
    window.open(survey.url, "_blank", "noopener,noreferrer");
    if (survey.verified) {
      // Don't hide — banner disappears only after a real submit (webhook records it).
      setOpened(true);
    } else {
      setHidden(true);
      start(async () => {
        await dismissSurvey(survey.id, childId);
      });
    }
  }

  function later() {
    sessionStorage.setItem(laterKey, "1");
    setHidden(true);
  }

  return (
    <div className="gw-survey">
      <span className="blob" />
      <span className="ico">
        <span className="material-symbols-outlined">campaign</span>
      </span>
      <div className="flex-1 min-w-0" style={{ zIndex: 1 }}>
        <h3>{survey.title}</h3>
        {survey.description && <p>{survey.description}</p>}
        {survey.verified && opened && (
          <p className="mt-1">
            {t("surveyAutoHide")}{" "}
            <button onClick={() => router.refresh()} className="underline font-extrabold">
              {t("surveyReload")}
            </button>
          </p>
        )}
        <div className="flex flex-wrap gap-2 mt-3">
          <button
            onClick={openForm}
            className="gw-btn gw-btn--tertiary gw-btn--sm"
          >
            {opened ? t("surveyReopen") : t("surveyDo")}
          </button>
          <button onClick={later} className="gw-btn gw-btn--ghost gw-btn--sm">
            {t("surveyLater")}
          </button>
        </div>
      </div>
      <button
        onClick={later}
        aria-label={t("close")}
        className="shrink-0"
        style={{ zIndex: 1, color: "#5B3FC0" }}
      >
        <span className="material-symbols-outlined">close</span>
      </button>
    </div>
  );
}
