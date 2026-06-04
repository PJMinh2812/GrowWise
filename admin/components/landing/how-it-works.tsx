import { ClipboardList, CheckCircle2, Coins, ArrowRight } from "lucide-react";

const steps = [
  {
    icon: ClipboardList,
    title: "Phụ huynh giao nhiệm vụ",
    description: "Tạo nhiệm vụ phù hợp với độ tuổi và khả năng của con",
    color: "bg-primary/20",
    iconColor: "text-primary",
  },
  {
    icon: CheckCircle2,
    title: "Trẻ hoàn thành",
    description: "Con thực hiện và đánh dấu hoàn thành nhiệm vụ",
    color: "bg-secondary/20",
    iconColor: "text-secondary",
  },
  {
    icon: Coins,
    title: "Nhận xu thưởng",
    description: "Con được thưởng xu để phân bổ vào 3 hũ tài chính",
    color: "bg-accent",
    iconColor: "text-accent-foreground",
  },
];

export function HowItWorks() {
  return (
    <section id="how-it-works" className="py-16 sm:py-24 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-12 sm:mb-16">
          <span className="inline-block bg-primary/10 text-primary px-4 py-1.5 rounded-full text-sm font-medium mb-4">
            Đơn giản & Hiệu quả
          </span>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-foreground text-balance">
            Cách GrowWise hoạt động
          </h2>
          <p className="mt-4 text-lg text-muted-foreground max-w-2xl mx-auto">
            Chỉ 3 bước đơn giản để con bạn bắt đầu hành trình tài chính thông minh
          </p>
        </div>

        {/* Steps */}
        <div className="grid md:grid-cols-3 gap-6 lg:gap-8">
          {steps.map((step, index) => (
            <div key={index} className="relative">
              <div className="bg-background rounded-3xl p-8 h-full border border-border hover:border-primary/50 transition-colors group">
                {/* Step number */}
                <div className="absolute -top-4 left-8 bg-foreground text-background w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm">
                  {index + 1}
                </div>

                {/* Icon */}
                <div className={`w-16 h-16 ${step.color} rounded-2xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform`}>
                  <step.icon className={`w-8 h-8 ${step.iconColor}`} />
                </div>

                {/* Content */}
                <h3 className="text-xl font-bold text-foreground mb-3">
                  {step.title}
                </h3>
                <p className="text-muted-foreground leading-relaxed">
                  {step.description}
                </p>
              </div>

              {/* Arrow connector (hidden on last item and mobile) */}
              {index < steps.length - 1 && (
                <div className="hidden md:flex absolute top-1/2 -right-4 lg:-right-6 transform -translate-y-1/2 z-10">
                  <div className="w-8 h-8 lg:w-12 lg:h-12 bg-muted rounded-full flex items-center justify-center">
                    <ArrowRight className="w-4 h-4 lg:w-5 lg:h-5 text-muted-foreground" />
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
