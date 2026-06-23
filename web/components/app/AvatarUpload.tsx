"use client";

import { useRef, useState } from "react";
import { createClient } from "@/lib/supabase";
import { useLang } from "./LangProvider";

export default function AvatarUpload({
  currentUrl,
  fallbackEmoji = "👤",
  pathPrefix,
  onUploaded,
  onRemoved,
}: {
  currentUrl: string;
  fallbackEmoji?: string;
  pathPrefix: "parents" | "children";
  onUploaded: (url: string) => void;
  onRemoved?: () => void;
}) {
  const { t } = useLang();
  const inputRef = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState("");

  async function handleFile(file: File) {
    setError("");
    setUploading(true);
    try {
      const ext = file.name.split(".").pop() ?? "jpg";
      const path = `${pathPrefix}/${Date.now()}-${Math.random().toString(36).slice(2)}.${ext}`;
      const supabase = createClient();
      const { error: uploadErr } = await supabase.storage
        .from("avatars")
        .upload(path, file, { upsert: true });
      if (uploadErr) {
        setError(t("avatarUploadError"));
        return;
      }
      const { data } = supabase.storage.from("avatars").getPublicUrl(path);
      onUploaded(data.publicUrl);
    } catch {
      setError(t("avatarUploadError"));
    } finally {
      setUploading(false);
    }
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: "10px" }}>
      <div
        style={{
          width: "80px", height: "80px", borderRadius: "50%", overflow: "hidden",
          background: "var(--primary-fixed)", display: "flex", alignItems: "center",
          justifyContent: "center", fontSize: "40px", flexShrink: 0,
        }}
      >
        {currentUrl ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={currentUrl} alt="avatar" style={{ width: "100%", height: "100%", objectFit: "cover" }} />
        ) : (
          fallbackEmoji
        )}
      </div>

      <div style={{ display: "flex", gap: "8px" }}>
        <button
          type="button"
          onClick={() => inputRef.current?.click()}
          disabled={uploading}
          className="gw-btn gw-btn--ghost gw-btn--sm"
        >
          <span className="material-symbols-outlined" style={{ fontSize: "16px" }}>upload</span>
          {uploading ? "…" : t("uploadPhoto")}
        </button>
        {currentUrl && onRemoved && (
          <button
            type="button"
            onClick={onRemoved}
            className="gw-btn gw-btn--ghost gw-btn--sm"
            style={{ color: "var(--color-error)" }}
          >
            {t("removePhoto")}
          </button>
        )}
      </div>

      {error && <p className="text-sm text-error">{error}</p>}

      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        style={{ display: "none" }}
        onChange={(e) => {
          const file = e.target.files?.[0];
          if (file) handleFile(file);
          e.target.value = "";
        }}
      />
    </div>
  );
}
