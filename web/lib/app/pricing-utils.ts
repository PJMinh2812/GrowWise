// Pure pricing helpers — safe to import from both client and server (no
// server-only deps). Single source of truth for the yearly price formula.

/** Yearly billing discount vs paying monthly for 12 months. */
export const YEARLY_DISCOUNT = 0.2

/**
 * Yearly price, always auto-computed as `monthly × 12 × (1 - 20%)` rounded to
 * the nearest 1.000₫. Admin only sets the monthly price — the yearly price and
 * its discount are derived, so every surface stays consistent.
 */
export function effectiveYearly(monthly: number): number {
  if (monthly <= 0) return 0
  return Math.round((monthly * 12 * (1 - YEARLY_DISCOUNT)) / 1000) * 1000
}
