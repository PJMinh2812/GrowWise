import { NextRequest, NextResponse } from 'next/server'

export const runtime = 'nodejs'

const ENDPOINT = 'https://api-us.faceplusplus.com/facepp/v3/detect'

const EMOTION_MAP: Record<string, { emoji: string; label: string; advice: string }> = {
  happy: { emoji: '😊', label: 'Vui vẻ', advice: 'Thời điểm tuyệt vời để khen ngợi và cùng con đặt mục tiêu mới!' },
  angry: { emoji: '😠', label: 'Bực bội', advice: 'Hãy chờ bình tĩnh lại trước khi nói chuyện với con — phản ứng lúc này dễ gây tổn thương.' },
  sad: { emoji: '😢', label: 'Buồn bã', advice: 'Chia sẻ cảm xúc với con là điều tốt — dạy con rằng buồn cũng là cảm xúc bình thường.' },
  stressed: { emoji: '😰', label: 'Căng thẳng', advice: 'Hãy thở sâu trước khi tương tác với con — con rất nhạy cảm với tâm trạng của ba/mẹ.' },
  surprised: { emoji: '😮', label: 'Ngạc nhiên', advice: 'Giữ tinh thần cởi mở — đây là lúc tốt để lắng nghe những điều bất ngờ từ con.' },
  neutral: { emoji: '😐', label: 'Bình thường', advice: 'Bạn đang ở trạng thái ổn định — lý tưởng để lắng nghe và hỗ trợ con.' },
}

export async function POST(req: NextRequest) {
  const apiKey = process.env.FACE_PLUS_PLUS_API_KEY
  const apiSecret = process.env.FACE_PLUS_PLUS_API_SECRET
  if (!apiKey || !apiSecret) {
    return NextResponse.json({ error: 'Face++ chưa được cấu hình' }, { status: 500 })
  }

  const { imageBase64 } = (await req.json()) as { imageBase64: string }
  if (!imageBase64) return NextResponse.json({ error: 'Thiếu ảnh' }, { status: 400 })

  const form = new FormData()
  form.append('api_key', apiKey)
  form.append('api_secret', apiSecret)
  form.append('image_base64', imageBase64.replace(/^data:image\/\w+;base64,/, ''))
  form.append('return_attributes', 'emotion')

  try {
    const res = await fetch(ENDPOINT, { method: 'POST', body: form })
    const data = await res.json()
    const faces = data?.faces as Array<{ attributes?: { emotion?: Record<string, number> } }>
    if (!faces || faces.length === 0) {
      return NextResponse.json({ error: 'Không nhận diện được khuôn mặt' }, { status: 422 })
    }
    const e = faces[0].attributes?.emotion ?? {}
    const mapped: Record<string, number> = {
      happy: e.happiness ?? 0,
      angry: (e.anger ?? 0) + (e.disgust ?? 0),
      sad: e.sadness ?? 0,
      stressed: e.fear ?? 0,
      surprised: e.surprise ?? 0,
      neutral: e.neutral ?? 0,
    }
    const dominant = Object.entries(mapped).reduce((a, b) => (b[1] >= a[1] ? b : a))[0]
    const info = EMOTION_MAP[dominant] ?? EMOTION_MAP.neutral
    return NextResponse.json({ emotion: dominant, ...info })
  } catch (err) {
    return NextResponse.json({ error: String(err) }, { status: 500 })
  }
}
