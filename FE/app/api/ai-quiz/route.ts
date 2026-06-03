import { NextRequest, NextResponse } from 'next/server'

const GEMINI_ENDPOINT =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent'

export async function POST(req: NextRequest) {
  const apiKey = process.env.GEMINI_API_KEY
  if (!apiKey) {
    return NextResponse.json({ error: 'GEMINI_API_KEY not configured' }, { status: 500 })
  }

  const { title, description, audience, count = 3 } = await req.json()

  const prompt =
    `Tạo ${count} câu hỏi trắc nghiệm cho bài học "${title}" về chủ đề tài chính cho trẻ em. ` +
    `${description ? `Mô tả: ${description}. ` : ''}` +
    `Đối tượng: ${audience === 'child' ? 'trẻ em 5-12 tuổi' : 'phụ huynh'}. ` +
    'Trả về JSON array KHÔNG có markdown:\n' +
    '[{"question":"...","options":[{"emoji":"emoji","text":"..."},...],"correct_index":số,"explanation":"..."}]\n' +
    'Mỗi câu có 4 lựa chọn, 1 đáp án đúng, giải thích ngắn gọn. Tiếng Việt, đơn giản, thú vị.'

  try {
    const res = await fetch(`${GEMINI_ENDPOINT}?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ role: 'user', parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.8,
          maxOutputTokens: 1024,
          thinkingConfig: { thinkingBudget: 0 },
        },
      }),
    })

    if (!res.ok) {
      const err = await res.json()
      return NextResponse.json({ error: err?.error?.message ?? 'Gemini error' }, { status: res.status })
    }

    const data = await res.json()
    // Filter out thinking parts
    const parts: { thought?: boolean; text?: string }[] =
      data?.candidates?.[0]?.content?.parts ?? []
    const textPart = parts.find((p) => !p.thought)
    const text = textPart?.text ?? ''

    const match = text.match(/\[[\s\S]*\]/)
    if (!match) {
      return NextResponse.json({ error: 'Could not parse AI response' }, { status: 500 })
    }

    const quizzes = JSON.parse(match[0])
    return NextResponse.json({ quizzes })
  } catch (e) {
    return NextResponse.json({ error: String(e) }, { status: 500 })
  }
}
