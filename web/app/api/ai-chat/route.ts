import { NextRequest, NextResponse } from 'next/server'
import { createServerSupabase } from '@/lib/supabase-server'
import {
  getUserPlan,
  isPremiumPlan,
  getDailyAiUsage,
  incrementAiUsage,
  FREE_LIMITS,
} from '@/lib/app/subscription'

const GROQ_ENDPOINT = 'https://api.groq.com/openai/v1/chat/completions'
const GROQ_MODEL = 'llama-3.3-70b-versatile'

export const runtime = 'nodejs'

interface ChatMessage {
  role: 'user' | 'assistant'
  content: string
}

function buildSystemPrompt(ctx: {
  name: string
  age: number
  total: number
  spend: number
  save: number
  share: number
  level: number
  xp: number
  xpNext: number
  dreams: string[]
  badges: string[]
  now: string
}): string {
  return `Bạn là Wisy 🌱, trợ lý AI thân thiện của GrowWise — ứng dụng giáo dục tài chính cho trẻ em.
Bạn đang trò chuyện với ${ctx.name}, ${ctx.age} tuổi.

Thời gian hiện tại (giờ Việt Nam): ${ctx.now}

Thông tin của ${ctx.name}:
• Xu: ${ctx.total} xu (Chi tiêu: ${ctx.spend} | Tiết kiệm: ${ctx.save} | Chia sẻ: ${ctx.share})
• Level ${ctx.level} — ${ctx.xp}/${ctx.xpNext} XP
• Ước mơ: ${ctx.dreams.length ? ctx.dreams.join(', ') : 'Chưa có ước mơ'}
• Huy hiệu: ${ctx.badges.length ? ctx.badges.join(', ') : 'Chưa có huy hiệu'}

Quy tắc:
- Luôn dùng tiếng Việt, ngắn gọn (tối đa 3 câu), thân thiện, vui vẻ.
- Dùng 1–2 emoji mỗi câu trả lời.
- Ngôn ngữ đơn giản phù hợp ${ctx.age} tuổi.
- Dùng đúng dữ liệu của ${ctx.name} khi liên quan, không bịa số.
- Nếu được hỏi hôm nay là ngày/thứ/giờ mấy, trả lời theo "Thời gian hiện tại" ở trên.
- Luôn khuyến khích và tích cực.`
}

export async function POST(req: NextRequest) {
  const apiKey = process.env.GROQ_API_KEY
  if (!apiKey) {
    return NextResponse.json({ error: 'GROQ_API_KEY not configured' }, { status: 500 })
  }

  const { childId, messages } = (await req.json()) as {
    childId: string
    messages: ChatMessage[]
  }

  const supabase = await createServerSupabase()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return NextResponse.json({ error: 'unauthorized' }, { status: 401 })

  // Free tier: 5 messages/day
  const plan = await getUserPlan()
  if (!isPremiumPlan(plan)) {
    const used = await getDailyAiUsage(user.id)
    if (used >= FREE_LIMITS.dailyAiMessages) {
      return NextResponse.json(
        { error: 'limit', message: 'Hết lượt chat hôm nay. Nâng cấp để chat không giới hạn!' },
        { status: 429 },
      )
    }
  }

  const { data: child } = await supabase
    .from('children')
    .select('*')
    .eq('id', childId)
    .maybeSingle()
  if (!child) return NextResponse.json({ error: 'Không tìm thấy hồ sơ con' }, { status: 404 })

  const [{ data: dreams }, { data: badges }] = await Promise.all([
    supabase.from('dream_items').select('name').eq('child_id', childId).eq('is_purchased', false),
    supabase.from('badges').select('title').eq('child_id', childId),
  ])

  const system = buildSystemPrompt({
    name: child.name,
    age: child.age,
    total: child.total_coins,
    spend: child.spend_jar,
    save: child.save_jar,
    share: child.share_jar,
    level: child.level,
    xp: child.xp,
    xpNext: child.xp_to_next_level,
    dreams: (dreams ?? []).map((d: { name: string }) => d.name),
    badges: (badges ?? []).map((b: { title: string }) => b.title),
    now: new Date().toLocaleString('vi-VN', {
      timeZone: 'Asia/Ho_Chi_Minh',
      dateStyle: 'full',
      timeStyle: 'short',
    }),
  })

  try {
    const res = await fetch(GROQ_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: GROQ_MODEL,
        messages: [{ role: 'system', content: system }, ...messages.slice(-10)],
        temperature: 0.8,
        max_tokens: 300,
      }),
    })
    if (!res.ok) {
      const err = await res.json().catch(() => ({}))
      return NextResponse.json(
        { error: err?.error?.message ?? 'Groq error' },
        { status: res.status },
      )
    }
    const data = await res.json()
    const reply: string = data?.choices?.[0]?.message?.content ?? 'Xin lỗi, Wisy chưa nghĩ ra 😅'
    if (!isPremiumPlan(plan)) await incrementAiUsage(user.id)
    return NextResponse.json({ reply })
  } catch (e) {
    return NextResponse.json({ error: String(e) }, { status: 500 })
  }
}
