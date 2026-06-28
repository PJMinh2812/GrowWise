const SITE_URL = "https://www.growwise.io.vn";

const websiteSchema = {
  "@context": "https://schema.org",
  "@type": "WebSite",
  name: "GrowWise",
  url: SITE_URL,
  description:
    "GrowWise giúp trẻ học quản lý tiền qua nhiệm vụ hằng ngày, hệ thống 3 hũ và trợ lý AI thông minh.",
  inLanguage: "vi",
};

const appSchema = {
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  name: "GrowWise",
  applicationCategory: "EducationApplication",
  operatingSystem: "iOS, Android, Web",
  url: SITE_URL,
  description:
    "Ứng dụng giáo dục tài chính #1 cho trẻ em Việt Nam. Dạy con quản lý tiền qua nhiệm vụ hằng ngày, hệ thống 3 hũ và trợ lý AI.",
  inLanguage: "vi",
  aggregateRating: {
    "@type": "AggregateRating",
    ratingValue: "4.9",
    ratingCount: "10000",
    bestRating: "5",
    worstRating: "1",
  },
  offers: [
    {
      "@type": "Offer",
      name: "Free",
      price: "0",
      priceCurrency: "VND",
      availability: "https://schema.org/InStock",
    },
    {
      "@type": "Offer",
      name: "Premium",
      price: "79000",
      priceCurrency: "VND",
      availability: "https://schema.org/InStock",
    },
    {
      "@type": "Offer",
      name: "Family",
      price: "149000",
      priceCurrency: "VND",
      availability: "https://schema.org/InStock",
    },
  ],
};

const faqSchema = {
  "@context": "https://schema.org",
  "@type": "FAQPage",
  mainEntity: [
    {
      "@type": "Question",
      name: "Tôi có thể hủy không?",
      acceptedAnswer: {
        "@type": "Answer",
        text: "Có, bạn có thể hủy bất kỳ lúc nào mà không mất thêm phí. Gói dùng thử 7 ngày hoàn toàn miễn phí.",
      },
    },
    {
      "@type": "Question",
      name: "Dùng thử có cần nhập thẻ không?",
      acceptedAnswer: {
        "@type": "Answer",
        text: "Không cần! 7 ngày dùng thử hoàn toàn miễn phí, không cần thông tin thanh toán.",
      },
    },
    {
      "@type": "Question",
      name: "Gói Gia Đình dùng được mấy thiết bị?",
      acceptedAnswer: {
        "@type": "Answer",
        text: "Mỗi hồ sơ trẻ được dùng trên 1 thiết bị. Gói Gia Đình cho phép tối đa 3 hồ sơ trẻ.",
      },
    },
  ],
};

export function LandingJsonLd() {
  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(websiteSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(appSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(faqSchema) }}
      />
    </>
  );
}
