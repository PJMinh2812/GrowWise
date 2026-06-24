import { NextRequest, NextResponse } from 'next/server'
import { createServerSupabase } from '@/lib/supabase-server'
import {
  getUserPlan,
  isPremiumPlan,
  getDailyAiUsage,
  incrementAiUsage,
  FREE_LIMITS,
} from '@/lib/app/subscription'
import { bandFor, type RoadmapTask } from '@/lib/app/roadmap-bands'

const GROQ_ENDPOINT = 'https://api.groq.com/openai/v1/chat/completions'
const GROQ_MODEL = 'llama-3.3-70b-versatile'

export const runtime = 'nodejs'

interface Answers {
  childId: string
  age: number
  goals: string[]
  tasksPerDay: number
  coinLevel: 'low' | 'medium' | 'high'
  knowsSaving: boolean
  penalty: boolean
  note?: string
}

function buildPrompt(a: Answers): string {
  const coinHint = a.coinLevel === 'low' ? '10–30' : a.coinLevel === 'high' ? '50–100' : '20–60'
  return `Bạn là chuyên gia giáo dục tài chính cho trẻ em (app GrowWise, hệ thống 3 hũ: Tiêu/Tiết kiệm/Chia sẻ).
Hãy tạo lộ trình ${a.tasksPerDay} nhiệm vụ HẰNG NGÀY cho một bé ${a.age} tuổi.
Mục tiêu ưu tiên của phụ huynh: ${a.goals.join(', ') || 'thói quen tốt'}.
Bé ${a.knowsSaving ? 'đã' : 'chưa'} quen tiết kiệm.
Phạt khi bỏ lỡ: ${a.penalty ? 'có' : 'không'}.
Ghi chú thêm của phụ huynh: ${a.note?.trim() || 'không'}.

CHỈ TRẢ VỀ JSON hợp lệ, không giải thích, không markdown. Định dạng:
{"tasks":[{"title":"...","description":"...","category":"Việc nhà|Học tập|Sức khỏe|Sáng tạo","icon":"<1 emoji>","coin_reward":<số ${coinHint}>,"auto_approve":true,"has_penalty":${a.penalty},"penalty_percent":10}]}
Yêu cầu: tiêu đề ngắn gọn tiếng Việt, phù hợp ${a.age} tuổi, cân bằng giữa việc nhà/học tập/sức khỏe và thói quen tiền (tiết kiệm/chia sẻ). Đúng ${a.tasksPerDay} nhiệm vụ.`
}

function parseTasks(raw: string): RoadmapTask[] | null {
  try {
    const jsonStr = raw.replace(/```json|```/g, '').trim()
    const start = jsonStr.indexOf('{')
    const end = jsonStr.lastIndexOf('}')
    if (start < 0 || end < 0) return null
    const obj = JSON.parse(jsonStr.slice(start, end + 1))
    const arr = Array.isArray(obj?.tasks) ? obj.tasks : Array.isArray(obj) ? obj : null
    if (!arr) return null
    const tasks: RoadmapTask[] = arr
      .filter((t: unknown) => t && typeof (t as { title?: unknown }).title === 'string')
      .map((t: Record<string, unknown>) => ({
        title: String(t.title).slice(0, 80),
        description: String(t.description ?? '').slice(0, 160),
        category: String(t.category ?? 'Học tập'),
        icon: String(t.icon ?? '⭐').slice(0, 4),
        coin_reward: Math.max(0, Math.round(Number(t.coin_reward) || 20)),
        auto_approve: t.auto_approve !== false,
        has_penalty: t.has_penalty !== false,
        penalty_percent: Math.min(100, Math.max(0, Math.round(Number(t.penalty_percent) || 10))),
      }))
    return tasks.length ? tasks : null
  } catch {
    return null
  }
}

export async function POST(req: NextRequest) {
  const supabase = await createServerSupabase()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return NextResponse.json({ error: 'unauthorized' }, { status: 401 })

  const a = (await req.json()) as Answers
  const age = Number(a.age) || 8

  // Reuse the free daily AI quota.
  const plan = await getUserPlan()
  if (!isPremiumPlan(plan)) {
    const used = await getDailyAiUsage(user.id)
    if (used >= FREE_LIMITS.dailyAiMessages) {
      return NextResponse.json(
        { error: 'limit', message: 'Hết lượt AI hôm nay. Nâng cấp để dùng không giới hạn!' },
        { status: 429 },
      )
    }
  }

  const apiKey = process.env.GROQ_API_KEY
  const fallback = bandFor(age).map((t) => ({
    ...t,
    auto_approve: true,
    has_penalty: a.penalty ?? true,
    penalty_percent: 10,
  }))

  if (!apiKey) return NextResponse.json({ tasks: fallback, source: 'fallback' })

  try {
    const res = await fetch(GROQ_ENDPOINT, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${apiKey}` },
      body: JSON.stringify({
        model: GROQ_MODEL,
        messages: [{ role: 'user', content: buildPrompt({ ...a, age }) }],
        temperature: 0.6,
        max_tokens: 900,
        response_format: { type: 'json_object' },
      }),
    })
    if (!res.ok) return NextResponse.json({ tasks: fallback, source: 'fallback' })
    const data = await res.json()
    const tasks = parseTasks(data?.choices?.[0]?.message?.content ?? '')
    if (!isPremiumPlan(plan)) await incrementAiUsage(user.id)
    return NextResponse.json({ tasks: tasks ?? fallback, source: tasks ? 'ai' : 'fallback' })
  } catch {
    return NextResponse.json({ tasks: fallback, source: 'fallback' })
  }
}
