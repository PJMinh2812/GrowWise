// Đọc to văn bản tiếng Việt cho trẻ.
// Ưu tiên giọng Google qua /api/tts (giọng vi thật); nếu route chưa cấu hình
// (thiếu GOOGLE_TTS_API_KEY → trả 501) thì fallback sang Web Speech API.
// Trích từ logic speak() trong components/app/WisyChat.tsx để dùng chung.

let currentAudio: HTMLAudioElement | null = null;

/** Dừng mọi audio / giọng đọc đang phát. */
export function stopSpeak() {
  try {
    if (currentAudio) {
      currentAudio.pause();
      currentAudio.src = "";
      currentAudio = null;
    }
    if (typeof window !== "undefined") window.speechSynthesis?.cancel();
  } catch {
    /* noop */
  }
}

/** Đọc to một đoạn văn bản. Tự dừng đoạn đang đọc trước đó. */
export async function speak(text: string) {
  const clean = text.replace(/[^\p{L}\p{N}\s.,!?]/gu, "").trim();
  if (!clean) return;
  try {
    const res = await fetch("/api/tts", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text: clean }),
    });
    if (res.ok && res.headers.get("content-type")?.includes("audio")) {
      const url = URL.createObjectURL(await res.blob());
      stopSpeak();
      const audio = new Audio(url);
      currentAudio = audio;
      audio.onended = () => URL.revokeObjectURL(url);
      await audio.play();
      return;
    }
  } catch {
    /* fall through to browser speech */
  }
  speakBrowser(clean);
}

function speakBrowser(clean: string) {
  try {
    // Phát hiện ngôn ngữ: có dấu tiếng Việt → vi, ngược lại → en.
    const hasVietnamese =
      /[ăâđêôơưàáạảãằắặẳẵầấậẩẫèéẹẻẽềếệểễìíịỉĩòóọỏõồốộổỗờớợởỡùúụủũừứựửữỳýỵỷỹ]/i.test(
        clean,
      );
    const langPrefix = hasVietnamese ? "vi" : "en";
    const u = new SpeechSynthesisUtterance(clean);
    u.lang = hasVietnamese ? "vi-VN" : "en-US";

    const voices = window.speechSynthesis.getVoices();
    const match = voices.find((v) => v.lang?.toLowerCase().startsWith(langPrefix));
    if (match) u.voice = match;

    window.speechSynthesis.cancel();
    window.speechSynthesis.speak(u);
  } catch {
    /* TTS not supported */
  }
}
