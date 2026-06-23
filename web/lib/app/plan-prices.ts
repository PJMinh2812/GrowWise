import { createServerSupabase } from '@/lib/supabase-server'
import { effectiveYearly } from '@/lib/app/pricing-utils'

export type PlanKey = 'free' | 'premium' | 'family'

export interface PlanPrice {
  monthly: number
  yearly: number
}

/**
 * Plan monthly prices from the `plans` table so every pricing surface (in-app
 * upgrade + landing) reflects what admin sets. `yearly` is always auto-computed
 * (20% off). Falls back to sane defaults if the DB read fails.
 */
export async function getPlanPrices(): Promise<Record<PlanKey, PlanPrice>> {
  const monthly: Record<PlanKey, number> = {
    free: 0,
    premium: 79000,
    family: 149000,
  }
  try {
    const supabase = await createServerSupabase()
    const { data } = await supabase.from('plans').select('name, price_monthly')
    for (const row of data ?? []) {
      const key = row.name as PlanKey
      if (key in monthly) monthly[key] = row.price_monthly ?? 0
    }
  } catch {
    // keep defaults
  }

  const prices = {} as Record<PlanKey, PlanPrice>
  for (const key of Object.keys(monthly) as PlanKey[]) {
    prices[key] = { monthly: monthly[key], yearly: effectiveYearly(monthly[key]) }
  }
  return prices
}
