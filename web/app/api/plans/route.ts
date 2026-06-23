import { NextResponse } from 'next/server';
import { getPlanPrices } from '@/lib/app/plan-prices';

export const dynamic = 'force-dynamic';

// Public plan prices (monthly + auto-computed yearly) so the mobile app shows
// the same prices it will actually be charged. Plans are public-read.
export async function GET() {
  const prices = await getPlanPrices();
  return NextResponse.json(prices);
}
