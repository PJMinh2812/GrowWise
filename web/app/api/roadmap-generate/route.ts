import { NextRequest, NextResponse } from 'next/server'
import { createServerSupabase } from '@/lib/supabase-server'
import {
  getUserPlan,
  isPremiumPlan,
  getDailyAiUsage,
  incrementAiUsage,
  FREE_LIMITS,
} from '@/lib/app/subscription'
import {
  bandFor,
  withSchedule,
  FALLBACK_STAGES,
  type RoadmapTask,
  type RoadmapStageSeed,
} from '@/lib/app/roadmap-bands'

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
  schoolSession?: string
  timeBudget?: string
  note?: string
}

function buildPrompt(a: Answers): string {
  const coinHint = a.coinLevel === 'low' ? '10–30' : a.coinLevel === 'high' ? '50–100' : '20–60'
  return `Bạn là CHUYÊN GIA giáo dục tài chính cho trẻ em, thiết kế một LỘ TRÌNH 1 NĂM để bé hiểu cơ bản về
chi tiêu – tiết kiệm – quản lý tiền (app GrowWise, hệ thống 3 hũ: Tiêu/Tiết kiệm/Chia sẻ).

Thông tin bé: ${a.age} tuổi; đi học buổi: ${a.schoolSession || 'không rõ'}; quỹ thời gian mỗi ngày: ${a.timeBudget || 'vừa phải'}.
Mục tiêu phụ huynh: ${a.goals.join(', ') || 'thói quen tốt'}. Bé ${a.knowsSaving ? 'đã' : 'chưa'} quen tiết kiệm.
Phạt khi trễ: ${a.penalty ? 'có' : 'không'}. Ghi chú: ${a.note?.trim() || 'không'}.

CHỈ TRẢ VỀ JSON hợp lệ (không markdown, không giải thích) dạng:
{
 "stages":[{"month":1,"theme":"...","goal":"...","lesson_category":"Cơ bản|Tiết kiệm|Chi tiêu|Chia sẻ|Quản lý","milestone":"..."}, ... đúng 12 phần tử, tiến triển từ kiếm xu → 3 hũ → mục tiêu tiết kiệm → chi tiêu thông minh → chia sẻ → ngân sách → tự quản ],
 "tasks":[{"title":"...","description":"...","category":"Việc nhà|Học tập|Sức khỏe|Sáng tạo","icon":"<1 emoji>","coin_reward":<${coinHint}>,"scheduled_time":"HH:MM","duration_minutes":<5-30>,"frequency":"daily","auto_approve":true,"has_penalty":${a.penalty},"penalty_percent":10}]
}
Yêu cầu cho "tasks" (đúng ${a.tasksPerDay} nhiệm vụ HẰNG NGÀY cho CHẶNG 1):
- Xếp "scheduled_time" hợp lý trong ngày, TRÁNH giờ đi học (${a.schoolSession || 'sáng'}), tổng thời lượng vừa quỹ thời gian.
- Cân bằng việc nhà/học tập/sức khỏe + ít nhất 1 nhiệm vụ liên quan tiền (bỏ heo/tiết kiệm).
- Tiêu đề ngắn gọn tiếng Việt, phù hợp ${a.age} tuổi.`
}

interface GenResult { tasks: RoadmapTask[]; stages: RoadmapStageSeed[] }

function parseResult(raw: string): GenResult | null {
  try {
    const jsonStr = raw.replace(/```json|```/g, '').trim()
    const start = jsonStr.indexOf('{')
    const end = jsonStr.lastIndexOf('}')
    if (start < 0 || end < 0) return null
    const obj = JSON.parse(jsonStr.slice(start, end + 1))
    const arr = Array.isArray(obj?.tasks) ? obj.tasks : null
    if (!arr) return null
    const tasks: RoadmapTask[] = arr
      .filter((t: unknown) => t && typeof (t as { title?: unknown }).title === 'string')
      .map((t: Record<string, unknown>) => ({
        title: String(t.title).slice(0, 80),
        description: String(t.description ?? '').slice(0, 160),
        category: String(t.category ?? 'Học tập'),
        icon: String(t.icon ?? '⭐').slice(0, 4),
        coin_reward: Math.max(0, Math.round(Number(t.coin_reward) || 20)),
        scheduled_time: typeof t.scheduled_time === 'string' ? t.scheduled_time.slice(0, 5) : null,
        duration_minutes: Math.min(120, Math.max(5, Math.round(Number(t.duration_minutes) || 15))),
        frequency: 'daily',
        auto_approve: t.auto_approve !== false,
        has_penalty: t.has_penalty !== false,
        penalty_percent: Math.min(100, Math.max(0, Math.round(Number(t.penalty_percent) || 10))),
        stage: 1,
      }))
    if (!tasks.length) return null
    const stagesArr = Array.isArray(obj?.stages) ? obj.stages : []
    const stages: RoadmapStageSeed[] = stagesArr
      .filter((s: unknown) => s && typeof (s as { theme?: unknown }).theme === 'string')
      .map((s: Record<string, unknown>, i: number) => ({
        month: Number(s.month) || i + 1,
        theme: String(s.theme).slice(0, 80),
        goal: String(s.goal ?? '').slice(0, 120),
        lesson_category: String(s.lesson_category ?? 'Cơ bản').slice(0, 40),
        milestone: String(s.milestone ?? '').slice(0, 120),
      }))
    return { tasks, stages: stages.length ? stages : FALLBACK_STAGES }
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

  const fallback: GenResult = {
    tasks: withSchedule(bandFor(age)).map((t) => ({ ...t, has_penalty: a.penalty ?? true })),
    stages: FALLBACK_STAGES,
  }

  const apiKey = process.env.GROQ_API_KEY
  if (!apiKey) return NextResponse.json({ ...fallback, source: 'fallback' })

  try {
    const res = await fetch(GROQ_ENDPOINT, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${apiKey}` },
      body: JSON.stringify({
        model: GROQ_MODEL,
        messages: [{ role: 'user', content: buildPrompt({ ...a, age }) }],
        temperature: 0.6,
        max_tokens: 1600,
        response_format: { type: 'json_object' },
      }),
    })
    if (!res.ok) return NextResponse.json({ ...fallback, source: 'fallback' })
    const data = await res.json()
    const parsed = parseResult(data?.choices?.[0]?.message?.content ?? '')
    if (!isPremiumPlan(plan)) await incrementAiUsage(user.id)
    return NextResponse.json(parsed ? { ...parsed, source: 'ai' } : { ...fallback, source: 'fallback' })
  } catch {
    return NextResponse.json({ ...fallback, source: 'fallback' })
  }
}
