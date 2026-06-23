"use client";

import { useState, useTransition } from "react";
import {
  approveSubmission,
  rejectSubmission,
  retroactiveReject,
} from "@/lib/app/parent-actions";
import type { SubmissionWithRelations } from "@/lib/app/submissions";
import { useLang } from "./LangProvider";

function timeAgo(iso: string | null): string {
  if (!iso) return "";
  const diff = Date.now() - new Date(iso).getTime();
  const m = Math.round(diff / 60000);
  if (m < 1) return "vừa xong";
  if (m < 60) return `${m} phút trước`;
  const h = Math.round(m / 60);
  if (h < 24) return `${h} giờ trước`;
  return `${Math.round(h / 24)} ngày trước`;
}

export default function ApprovalQueue({
  pending,
  autoApproved,
}: {
  pending: SubmissionWithRelations[];
  autoApproved: SubmissionWithRelations[];
}) {
  const { t } = useLang();
  return (
    <div className="space-y-8">
      <section>
        <h2 className="text-lg font-bold text-on-surface mb-3">
          {t("pendingReview")} ({pending.length})
        </h2>
        {pending.length === 0 ? (
          <div className="gw-card" style={{ padding: "32px", textAlign: "center", color: "var(--ink-soft)" }}>
            {t("approveQueueEmpty")}
          </div>
        ) : (
          <div className="space-y-4">
            {pending.map((s) => (
              <PendingCard key={s.id} sub={s} />
            ))}
          </div>
        )}
      </section>

      {autoApproved.length > 0 && (
        <section>
          <h2 className="text-lg font-bold text-on-surface mb-3">
            {t("autoApprovedSection")}
          </h2>
          <div className="space-y-4">
            {autoApproved.map((s) => (
              <AutoApprovedCard key={s.id} sub={s} />
            ))}
          </div>
        </section>
      )}
    </div>
  );
}

function PendingCard({ sub }: { sub: SubmissionWithRelations }) {
  const { t } = useLang();
  const [rating, setRating] = useState(2);
  const [rejecting, setRejecting] = useState(false);
  const [reason, setReason] = useState("");
  const [pending, start] = useTransition();

  return (
    <div className="gw-card" style={{ padding: "20px" }}>
      <div className="flex flex-col sm:flex-row gap-4">
        {sub.proof_image_url && (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={sub.proof_image_url}
            alt="Ảnh bằng chứng"
            className="rounded-2xl object-cover w-full sm:w-28 h-40 sm:h-28 bg-surface-container"
            onError={(e) => {
              const el = e.currentTarget;
              el.onerror = null;
              el.src =
                "data:image/svg+xml;utf8," +
                encodeURIComponent(
                  '<svg xmlns="http://www.w3.org/2000/svg" width="112" height="112"><rect width="100%" height="100%" fill="#eee"/><text x="50%" y="50%" font-size="11" text-anchor="middle" dominant-baseline="middle" fill="#999">Không tải được ảnh</text></svg>',
                );
            }}
          />
        )}
        <div className="flex-1">
          <div className="flex items-center gap-2">
            <span className="text-2xl">{sub.child?.avatar_emoji ?? "🧒"}</span>
            <div>
              <p className="font-bold text-on-surface">
                {sub.task?.icon} {sub.task?.title}
              </p>
              <p className="text-xs text-on-surface-variant">
                {sub.child?.name} · {timeAgo(sub.submitted_at)}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-1 mt-3">
            <span className="text-sm text-on-surface-variant mr-1">{t("quality")}</span>
            {[1, 2, 3].map((n) => (
              <button
                key={n}
                onClick={() => setRating(n)}
                className="text-2xl leading-none"
                aria-label={`${n} sao`}
              >
                <span className={n <= rating ? "text-amber-400" : "text-gray-300"}>★</span>
              </button>
            ))}
            <span className="text-xs text-on-surface-variant ml-1">
              {rating === 1 ? t("needsWork") : rating === 3 ? t("excellent") : t("good")}
            </span>
          </div>

          {rejecting ? (
            <div className="mt-3">
              <textarea
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                placeholder="Lý do từ chối (con sẽ thấy)…"
                className="gw-input"
                rows={2}
              />
              <div className="flex gap-2 mt-2">
                <button
                  disabled={pending}
                  onClick={() =>
                    start(async () => {
                      await rejectSubmission(sub.id, reason.trim() || undefined);
                    })
                  }
                  className="gw-btn gw-btn--sm"
                  style={{ background: "var(--color-error)", color: "var(--color-on-error)" }}
                >
                  {t("confirmReject")}
                </button>
                <button
                  onClick={() => setRejecting(false)}
                  className="gw-btn gw-btn--ghost gw-btn--sm"
                >
                  {t("cancel")}
                </button>
              </div>
            </div>
          ) : (
            <div className="flex gap-2 mt-4">
              <button
                disabled={pending}
                onClick={() =>
                  start(async () => {
                    await approveSubmission(sub.id, rating);
                  })
                }
                className="gw-btn gw-btn--tertiary gw-btn--sm"
              >
                {pending ? "…" : t("approve")}
              </button>
              <button
                onClick={() => setRejecting(true)}
                className="gw-btn gw-btn--ghost gw-btn--sm"
                style={{ color: "var(--color-error)" }}
              >
                {t("reject")}
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function AutoApprovedCard({ sub }: { sub: SubmissionWithRelations }) {
  const { t } = useLang();
  const [pending, start] = useTransition();
  return (
    <div className="gw-card" style={{ padding: "20px", borderLeft: "3px solid #f59e0b" }}>
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div className="flex items-center gap-2">
          <span className="text-2xl">{sub.child?.avatar_emoji ?? "🧒"}</span>
          <div>
            <p className="font-bold text-on-surface">
              {sub.task?.icon} {sub.task?.title}
            </p>
            <p className="text-xs text-amber-600">
              {t("autoApprovedSection")} · +{sub.coin_earned ?? 0} xu
            </p>
          </div>
        </div>
        <button
          disabled={pending}
          onClick={() =>
            start(async () => {
              await retroactiveReject(sub.id);
            })
          }
          className="gw-btn gw-btn--ghost gw-btn--sm"
          style={{ color: "var(--color-error)" }}
        >
          {pending ? t("cancelling") : t("cancelAutoApprove")}
        </button>
      </div>
    </div>
  );
}
