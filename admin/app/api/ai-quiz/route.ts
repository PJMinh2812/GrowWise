import { NextRequest, NextResponse } from 'next/server'

const GROQ_ENDPOINT = 'https://api.groq.com/openai/v1/chat/completions'
const GROQ_MODEL = 'llama-3.3-70b-versatile'

export async function POST(req: NextRequest) {
  const apiKey = process.env.GROQ_API_KEY
  if (!apiKey) {
    return NextResponse.json({ error: 'GROQ_API_KEY not configured' }, { status: 500 })
  }

  const body = await req.json()
  const { title, description, audience } = body
  const count = Math.max(1, Math.min(10, parseInt(body.count ?? 3) || 3))

  const prompt =
    `Tạo ${count} câu hỏi trắc nghiệm cho bài học "${title}" về chủ đề tài chính cho trẻ em. ` +
    `${description ? `Mô tả: ${description}. ` : ''}` +
    `Đối tượng: ${audience === 'child' ? 'trẻ em 5-12 tuổi' : 'phụ huynh'}. ` +
    'Trả về JSON array KHÔNG có markdown:\n' +
    '[{"question":"...","options":[{"emoji":"emoji","text":"..."},...],"correct_index":số,"explanation":"..."}]\n' +
    'Mỗi câu có 4 lựa chọn, 1 đáp án đúng, giải thích ngắn gọn. Tiếng Việt, đơn giản, thú vị.'

  try {
    const res = await fetch(GROQ_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: GROQ_MODEL,
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.8,
        max_tokens: 1024,
      }),
    })

    if (!res.ok) {
      const err = await res.json()
      return NextResponse.json({ error: err?.error?.message ?? 'Groq error' }, { status: res.status })
    }

    const data = await res.json()
    const text: string = data?.choices?.[0]?.message?.content ?? ''

    const match = text.match(/\[[\s\S]*\]/)
    if (!match) {
      return NextResponse.json({ error: 'AI không trả về JSON array hợp lệ' }, { status: 500 })
    }

    let quizzes: unknown[]
    try {
      quizzes = JSON.parse(match[0])
    } catch {
      return NextResponse.json({ error: 'Không thể parse JSON từ AI response' }, { status: 500 })
    }

    return NextResponse.json({ quizzes })
  } catch (e) {
    return NextResponse.json({ error: String(e) }, { status: 500 })
  }
}
