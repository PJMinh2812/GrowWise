import { NextRequest, NextResponse } from 'next/server'

export const runtime = 'nodejs'

const ENDPOINT = 'https://texttospeech.googleapis.com/v1/text:synthesize'
// Vietnamese voice. Override via env if you want a different one (e.g. Wavenet/Neural2).
const VOICE = process.env.GOOGLE_TTS_VOICE ?? 'vi-VN-Standard-A'

/**
 * Server-side Vietnamese text-to-speech via Google Cloud TTS.
 * Returns MP3 audio bytes so the browser plays a real Vietnamese voice instead
 * of relying on whatever voices happen to be installed on the device.
 * If GOOGLE_TTS_API_KEY isn't set, returns 501 so the client falls back to the
 * browser Web Speech API.
 */
export async function POST(req: NextRequest) {
  const apiKey = process.env.GOOGLE_TTS_API_KEY
  if (!apiKey) {
    return NextResponse.json({ error: 'tts_not_configured' }, { status: 501 })
  }

  const { text } = (await req.json()) as { text?: string }
  if (!text || !text.trim()) {
    return NextResponse.json({ error: 'Thiếu nội dung' }, { status: 400 })
  }

  try {
    const res = await fetch(`${ENDPOINT}?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        input: { text: text.slice(0, 5000) },
        voice: { languageCode: 'vi-VN', name: VOICE },
        audioConfig: { audioEncoding: 'MP3', speakingRate: 1.0 },
      }),
    })
    if (!res.ok) {
      const err = await res.json().catch(() => ({}))
      return NextResponse.json(
        { error: err?.error?.message ?? 'Google TTS error' },
        { status: res.status },
      )
    }
    const data = (await res.json()) as { audioContent?: string }
    if (!data.audioContent) {
      return NextResponse.json({ error: 'Không tạo được audio' }, { status: 502 })
    }
    const audio = Buffer.from(data.audioContent, 'base64')
    return new NextResponse(audio, {
      headers: {
        'Content-Type': 'audio/mpeg',
        'Cache-Control': 'no-store',
      },
    })
  } catch (e) {
    return NextResponse.json({ error: String(e) }, { status: 500 })
  }
}
