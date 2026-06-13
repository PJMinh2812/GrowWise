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
          <div className="app-card p-8 text-center text-on-surface-variant">
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
            Đã tự động duyệt (24h)
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
    <div className="app-card p-5">
      <div className="flex flex-col sm:flex-row gap-4">
        {sub.proof_image_url && (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={sub.proof_image_url}
            alt="Ảnh bằng chứng"
            className="rounded-2xl object-cover w-full sm:w-28 h-40 sm:h-28"
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

          {/* Quality stars */}
          <div className="flex items-center gap-1 mt-3">
            <span className="text-sm text-on-surface-variant mr-1">Chất lượng:</span>
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
              {rating === 1 ? "Cần cố gắng" : rating === 3 ? "Xuất sắc" : "Tốt"}
            </span>
          </div>

          {rejecting ? (
            <div className="mt-3">
              <textarea
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                placeholder="Lý do từ chối (con sẽ thấy)…"
                className="w-full border border-outline-variant rounded-[14px] px-3 py-2 text-sm text-on-surface"
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
                  className="px-4 py-2 rounded-[14px] bg-error text-on-error text-sm font-bold disabled:opacity-50"
                >
                  Xác nhận từ chối
                </button>
                <button
                  onClick={() => setRejecting(false)}
                  className="px-4 py-2 rounded-[14px] bg-surface-container text-on-surface-variant text-sm font-semibold"
                >
                  Huỷ
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
                className="px-5 py-2 rounded-[14px] bg-tertiary text-on-tertiary text-sm font-bold disabled:opacity-50"
              >
                {pending ? "…" : t("approve")}
              </button>
              <button
                onClick={() => setRejecting(true)}
                className="px-5 py-2 rounded-[14px] bg-error/10 text-error text-sm font-bold"
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
  const [pending, start] = useTransition();
  return (
    <div className="app-card p-5 border border-amber-300/60">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div className="flex items-center gap-2">
          <span className="text-2xl">{sub.child?.avatar_emoji ?? "🧒"}</span>
          <div>
            <p className="font-bold text-on-surface">
              {sub.task?.icon} {sub.task?.title}
            </p>
            <p className="text-xs text-amber-600">
              Đã tự động duyệt · +{sub.coin_earned ?? 0} xu
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
          className="px-4 py-2 rounded-[14px] bg-error/10 text-error text-sm font-bold disabled:opacity-50"
        >
          {pending ? "Đang huỷ…" : "Huỷ duyệt tự động"}
        </button>
      </div>
    </div>
  );
}
