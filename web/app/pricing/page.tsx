import { Header } from "@/components/landing/header";
import { Footer } from "@/components/landing/footer";
import { Pricing } from "@/components/landing/pricing";
import { getPlanPrices } from "@/lib/app/plan-prices";
import { getLang } from "@/lib/i18n-server";
import { LangProvider } from "@/components/app/LangProvider";

export const metadata = {
  title: "Bảng giá – GrowWise",
  description: "Chọn gói phù hợp cho gia đình bạn. Miễn phí, Nâng Cao 79.000₫/tháng, hoặc Gia Đình 149.000₫/tháng.",
};

export const dynamic = "force-dynamic";

export default async function PricingPage() {
  const [prices, lang] = await Promise.all([getPlanPrices(), getLang()]);
  return (
    <LangProvider initialLang={lang}>
      <div className="min-h-screen bg-white">
        <Header />
        <main className="pt-8">
          <Pricing prices={prices} />
        </main>
        <Footer />
      </div>
    </LangProvider>
  );
}
