import { Header } from "@/components/landing/header";
import { Footer } from "@/components/landing/footer";
import { Pricing } from "@/components/landing/pricing";

export const metadata = {
  title: "Bảng giá – GrowWise",
  description: "Chọn gói phù hợp cho gia đình bạn. Miễn phí, Nâng Cao 79.000₫/tháng, hoặc Gia Đình 149.000₫/tháng.",
};

export default function PricingPage() {
  return (
    <div className="min-h-screen bg-white">
      <Header />
      <main className="pt-8">
        <Pricing />
      </main>
      <Footer />
    </div>
  );
}
