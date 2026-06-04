import { Star, Quote } from "lucide-react";

const testimonials = [
  {
    name: "Chị Lan Anh",
    role: "Mẹ của bé Minh (8 tuổi)",
    avatar: "👩",
    rating: 5,
    content: "Con trai tôi giờ đã biết tiết kiệm tiền để mua món đồ chơi yêu thích. GrowWise thực sự thay đổi cách con nhìn nhận về tiền bạc!",
  },
  {
    name: "Anh Hoàng",
    role: "Bố của bé Linh (10 tuổi)",
    avatar: "👨",
    rating: 5,
    content: "Việc giao nhiệm vụ cho con qua app rất tiện lợi. Con gái tôi rất hào hứng hoàn thành nhiệm vụ để nhận xu thưởng mỗi ngày.",
  },
  {
    name: "Chị Thảo",
    role: "Mẹ của bé An (6 tuổi)",
    avatar: "👩‍🦱",
    rating: 5,
    content: "Tính năng 3 hũ xu giúp con học được bài học quan trọng về chia sẻ. Cháu giờ đã biết để dành tiền để tặng quà cho ông bà!",
  },
];

export function Testimonials() {
  return (
    <section id="testimonials" className="py-16 sm:py-24 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-12 sm:mb-16">
          <span className="inline-block bg-accent text-accent-foreground px-4 py-1.5 rounded-full text-sm font-medium mb-4">
            Phụ huynh nói gì
          </span>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-foreground text-balance">
            Được tin tưởng bởi hàng ngàn gia đình
          </h2>
          <p className="mt-4 text-lg text-muted-foreground max-w-2xl mx-auto">
            Xem những câu chuyện thành công từ các gia đình đang sử dụng GrowWise
          </p>
        </div>

        {/* Testimonials grid */}
        <div className="grid md:grid-cols-3 gap-6 lg:gap-8">
          {testimonials.map((testimonial, index) => (
            <div
              key={index}
              className="bg-background rounded-3xl p-6 sm:p-8 border border-border hover:border-primary/50 transition-colors relative"
            >
              {/* Quote icon */}
              <Quote className="absolute top-6 right-6 w-8 h-8 text-primary/20" />

              {/* Rating */}
              <div className="flex gap-1 mb-4">
                {Array.from({ length: testimonial.rating }).map((_, i) => (
                  <Star key={i} className="w-5 h-5 fill-secondary text-secondary" />
                ))}
              </div>

              {/* Content */}
              <p className="text-foreground leading-relaxed mb-6">
                {`"${testimonial.content}"`}
              </p>

              {/* Author */}
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-muted rounded-full flex items-center justify-center text-2xl">
                  {testimonial.avatar}
                </div>
                <div>
                  <div className="font-semibold text-foreground">{testimonial.name}</div>
                  <div className="text-sm text-muted-foreground">{testimonial.role}</div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
