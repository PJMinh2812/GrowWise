import { Hero } from "@/components/landing/hero";
import { HowItWorks } from "@/components/landing/how-it-works";
import { Features } from "@/components/landing/features";
import { Testimonials } from "@/components/landing/testimonials";
import { Pricing } from "@/components/landing/pricing";
import { DownloadCTA } from "@/components/landing/download-cta";
import { Header } from "@/components/landing/header";
import { Footer } from "@/components/landing/footer";
import { getPlanPrices } from "@/lib/app/plan-prices";
import { getLang } from "@/lib/i18n-server";
import { LangProvider } from "@/components/app/LangProvider";

export const dynamic = "force-dynamic";

export default async function LandingPage() {
  const [prices, lang] = await Promise.all([getPlanPrices(), getLang()]);
  return (
    <LangProvider initialLang={lang}>
      <div className="landing-theme min-h-screen bg-white">
        <Header />
        <main>
          <Hero />
          <HowItWorks />
          <Features />
          <Testimonials />
          <Pricing prices={prices} />
          <DownloadCTA />
        </main>
        <Footer />
      </div>
    </LangProvider>
  );
}
