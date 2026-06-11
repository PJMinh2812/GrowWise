import { PiggyBank, Gamepad2, Sparkles, Heart } from "lucide-react";

const features = [
  {
    icon: PiggyBank,
    title: "3 Hũ Xu",
    subtitle: "Tiêu dùng · Tiết kiệm · Sẻ chia",
    description: "Hệ thống 3 hũ giúp con học cách phân bổ tiền thông minh ngay từ nhỏ",
    color: "bg-secondary",
    bgColor: "bg-secondary/10",
  },
  {
    icon: Gamepad2,
    title: "Gamification",
    subtitle: "XP, cấp độ, huy hiệu, streak",
    description: "Biến việc học quản lý tiền thành trò chơi thú vị với phần thưởng hấp dẫn",
    color: "bg-secondary",
    bgColor: "bg-secondary/10",
  },
  {
    icon: Sparkles,
    title: "AI Dream Coach",
    subtitle: "Gợi ý nhiệm vụ & mục tiêu cá nhân",
    description: "Trợ lý AI thông minh giúp con đặt mục tiêu và theo dõi tiến độ tài chính",
    color: "bg-gray-900",
    bgColor: "bg-gray-900/10",
  },
  {
    icon: Heart,
    title: "Bonding",
    subtitle: "Kết nối phụ huynh & con cái",
    description: "Tăng cường gắn kết gia đình qua các hoạt động và nhiệm vụ cùng nhau",
    color: "bg-primary",
    bgColor: "bg-amber-100",
  },
];

export function Features() {
  return (
    <section id="features" className="py-16 sm:py-24 bg-[#f0fdf4]">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-12 sm:mb-16">
          <span className="inline-block bg-secondary/10 text-secondary px-4 py-1.5 rounded-full text-sm font-medium mb-4">
            Tính năng nổi bật
          </span>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-gray-900 text-balance">
            Tất cả những gì con bạn cần
          </h2>
          <p className="mt-4 text-lg text-gray-500 max-w-2xl mx-auto">
            GrowWise kết hợp công nghệ và tâm lý học để tạo ra trải nghiệm học tập tài chính hoàn hảo
          </p>
        </div>

        {/* Features grid */}
        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {features.map((feature, index) => (
            <div
              key={index}
              className="group bg-white rounded-3xl p-6 border border-gray-200 hover:border-secondary/50 hover:shadow-xl transition-all duration-300"
            >
              {/* Icon */}
              <div className={`w-14 h-14 ${feature.bgColor} rounded-2xl flex items-center justify-center mb-5 group-hover:scale-110 transition-transform`}>
                <feature.icon className={`w-7 h-7 ${feature.color === "bg-secondary" ? "text-secondary" : feature.color === "bg-gray-900" ? "text-gray-900" : "text-amber-700"}`} />
              </div>

              {/* Content */}
              <h3 className="text-xl font-bold text-gray-900 mb-1">
                {feature.title}
              </h3>
              <p className="text-sm font-medium text-secondary mb-3">
                {feature.subtitle}
              </p>
              <p className="text-gray-500 text-sm leading-relaxed">
                {feature.description}
              </p>
            </div>
          ))}
        </div>

        {/* Bottom CTA */}
        <div className="mt-12 text-center">
          <a
            href="#download"
            className="inline-flex items-center gap-2 text-secondary font-medium hover:underline"
          >
            Khám phá thêm tính năng
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
            </svg>
          </a>
        </div>
      </div>
    </section>
  );
}
