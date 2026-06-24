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

function systemPrompt(childrenSummary: string, now: string): string {
  return `Bạn là trợ lý AI của GrowWise — ứng dụng giáo dục tài chính cho trẻ em — đang tư vấn cho PHỤ HUYNH.
Thời gian hiện tại (giờ Việt Nam): ${now}

${childrenSummary}

Vai trò của bạn:
- Gợi ý nhiệm vụ/lộ trình phù hợp độ tuổi để dạy con quản lý tiền (3 hũ: Tiêu/Tiết kiệm/Chia sẻ).
- Tư vấn cách đặt mục tiêu tiết kiệm, xử lý chi tiêu phát sinh, tạo thói quen tốt.
- Đưa lời khuyên nuôi dạy tài chính ngắn gọn, thực tế, tích cực.

Quy tắc:
- Trả lời bằng tiếng Việt, rõ ràng, thực tế (tối đa 5 câu hoặc gạch đầu dòng ngắn).
- Khi gợi ý nhiệm vụ, nêu kèm số xu hợp lý và độ tuổi phù hợp.
- Không bịa số liệu của con; chỉ dùng thông tin được cung cấp.`
}

export async function POST(req: NextRequest) {
  const apiKey = process.env.GROQ_API_KEY
  if (!apiKey) return NextResponse.json({ error: 'GROQ_API_KEY not configured' }, { status: 500 })

  const { messages } = (await req.json()) as { messages: ChatMessage[] }

  const supabase = await createServerSupabase()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return NextResponse.json({ error: 'unauthorized' }, { status: 401 })

  const plan = await getUserPlan()
  if (!isPremiumPlan(plan)) {
    const used = await getDailyAiUsage(user.id)
    if (used >= FREE_LIMITS.dailyAiMessages) {
      return NextResponse.json(
        { error: 'limit', message: 'Hết lượt hỏi AI hôm nay. Nâng cấp để dùng không giới hạn!' },
        { status: 429 },
      )
    }
  }

  // Light context: children names/ages.
  const { data: family } = await supabase.from('families').select('id').eq('parent_id', user.id).maybeSingle()
  let childrenSummary = 'Phụ huynh chưa có hồ sơ con.'
  if (family) {
    const { data: kids } = await supabase
      .from('children')
      .select('name, age, level, total_coins')
      .eq('family_id', family.id)
    if (kids && kids.length) {
      childrenSummary = 'Các con: ' + kids
        .map((k) => `${k.name} (${k.age} tuổi, Level ${k.level}, ${k.total_coins} xu)`)
        .join('; ')
    }
  }

  const system = systemPrompt(
    childrenSummary,
    new Date().toLocaleString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh', dateStyle: 'full', timeStyle: 'short' }),
  )

  try {
    const res = await fetch(GROQ_ENDPOINT, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${apiKey}` },
      body: JSON.stringify({
        model: GROQ_MODEL,
        messages: [{ role: 'system', content: system }, ...messages.slice(-10)],
        temperature: 0.7,
        max_tokens: 500,
      }),
    })
    if (!res.ok) {
      const err = await res.json().catch(() => ({}))
      return NextResponse.json({ error: err?.error?.message ?? 'Groq error' }, { status: res.status })
    }
    const data = await res.json()
    const reply: string = data?.choices?.[0]?.message?.content ?? 'Xin lỗi, chưa trả lời được 😅'
    if (!isPremiumPlan(plan)) await incrementAiUsage(user.id)
    return NextResponse.json({ reply })
  } catch (e) {
    return NextResponse.json({ error: String(e) }, { status: 500 })
  }
}
