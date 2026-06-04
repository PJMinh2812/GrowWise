import { Smartphone, PiggyBank, Sparkles, Gift, Star, Coins } from "lucide-react";

export function Hero() {
  return (
    <section className="relative overflow-hidden py-16 sm:py-24 lg:py-32 bg-gradient-to-br from-white via-[#f0fdf4] to-[#dcfce7]">
      {/* Background decorations */}
      <div className="absolute inset-0 -z-10">
        <div className="absolute top-20 left-10 w-40 h-40 bg-secondary/30 rounded-full blur-3xl" />
        <div className="absolute top-40 right-20 w-64 h-64 bg-primary/20 rounded-full blur-3xl" />
        <div className="absolute bottom-20 left-1/4 w-48 h-48 bg-accent/80 rounded-full blur-3xl" />
        <div className="absolute -top-10 right-1/3 w-32 h-32 bg-primary/10 rounded-full blur-2xl" />
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          {/* Content */}
          <div className="text-center lg:text-left">
            {/* Badge */}
            <div className="inline-flex items-center gap-2 bg-muted px-4 py-2 rounded-full mb-6">
              <Sparkles className="w-4 h-4 text-secondary" />
              <span className="text-sm font-medium text-muted-foreground">
                Ứng dụng #1 cho trẻ em Việt Nam
              </span>
            </div>

            {/* Headline */}
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold text-foreground leading-tight text-balance">
              Dạy con yêu tiền —{" "}
              <span className="text-primary">Đúng cách</span>,{" "}
              <span className="text-secondary">Đúng lúc</span>
            </h1>

            {/* Subtext */}
            <p className="mt-6 text-lg sm:text-xl text-muted-foreground max-w-xl mx-auto lg:mx-0 leading-relaxed">
              GrowWise giúp trẻ học quản lý tiền qua nhiệm vụ hằng ngày, hệ thống 3 hũ và trợ lý AI thông minh.
            </p>

            {/* CTAs */}
            <div className="mt-8 flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
              <a
                href="#download"
                className="inline-flex items-center justify-center gap-2 bg-primary text-primary-foreground px-8 py-4 rounded-full font-semibold text-lg hover:bg-primary/90 transition-all hover:scale-105 shadow-lg shadow-primary/25"
              >
                <Smartphone className="w-5 h-5" />
                Tải ứng dụng
              </a>
              <a
                href="#how-it-works"
                className="inline-flex items-center justify-center gap-2 bg-card text-foreground px-8 py-4 rounded-full font-semibold text-lg border-2 border-border hover:border-primary hover:text-primary transition-colors"
              >
                Xem demo
              </a>
            </div>

            {/* Stats */}
            <div className="mt-12 grid grid-cols-3 gap-4 sm:gap-8 max-w-md mx-auto lg:mx-0">
              <div className="text-center lg:text-left">
                <div className="text-2xl sm:text-3xl font-bold text-foreground">10K+</div>
                <div className="text-sm text-muted-foreground">Gia đình</div>
              </div>
              <div className="text-center lg:text-left">
                <div className="text-2xl sm:text-3xl font-bold text-foreground">4.9</div>
                <div className="text-sm text-muted-foreground flex items-center justify-center lg:justify-start gap-1">
                  <Star className="w-3 h-3 fill-secondary text-secondary" />
                  Đánh giá
                </div>
              </div>
              <div className="text-center lg:text-left">
                <div className="text-2xl sm:text-3xl font-bold text-foreground">50K+</div>
                <div className="text-sm text-muted-foreground">Nhiệm vụ</div>
              </div>
            </div>
          </div>

          {/* Phone Mockup */}
          <div className="relative flex justify-center lg:justify-end">
            <div className="relative">
              {/* Floating elements */}
              <div className="absolute -top-4 -left-4 bg-card p-3 rounded-2xl shadow-xl animate-bounce">
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 bg-primary/20 rounded-full flex items-center justify-center">
                    <Coins className="w-4 h-4 text-primary" />
                  </div>
                  <div>
                    <div className="text-xs font-medium text-foreground">+50 xu</div>
                    <div className="text-[10px] text-muted-foreground">Hoàn thành!</div>
                  </div>
                </div>
              </div>

              <div className="absolute -bottom-4 -right-4 bg-card p-3 rounded-2xl shadow-xl animate-pulse">
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 bg-secondary/20 rounded-full flex items-center justify-center">
                    <Gift className="w-4 h-4 text-secondary" />
                  </div>
                  <div>
                    <div className="text-xs font-medium text-foreground">Streak 7 ngày!</div>
                    <div className="text-[10px] text-muted-foreground">Huy hiệu mới</div>
                  </div>
                </div>
              </div>

              {/* Phone frame */}
              <div className="relative bg-foreground rounded-[3rem] p-3 shadow-2xl">
                <div className="bg-card rounded-[2.5rem] overflow-hidden w-[280px] sm:w-[320px] aspect-[9/19]">
                  {/* App mockup content */}
                  <div className="p-4 h-full flex flex-col">
                    {/* Status bar */}
                    <div className="flex justify-between items-center mb-4">
                      <span className="text-xs text-muted-foreground">9:41</span>
                      <div className="flex gap-1">
                        <div className="w-4 h-2 bg-foreground/20 rounded-sm" />
                        <div className="w-4 h-2 bg-foreground/20 rounded-sm" />
                        <div className="w-6 h-3 bg-primary rounded-sm" />
                      </div>
                    </div>

                    {/* App header */}
                    <div className="flex items-center justify-between mb-6">
                      <div>
                        <div className="text-sm text-muted-foreground">Xin chào,</div>
                        <div className="text-lg font-bold text-foreground">Minh 👋</div>
                      </div>
                      <div className="w-10 h-10 bg-primary/20 rounded-full flex items-center justify-center">
                        <span className="text-lg">🧒</span>
                      </div>
                    </div>

                    {/* 3 Jars */}
                    <div className="bg-muted rounded-2xl p-4 mb-4">
                      <div className="text-sm font-medium text-foreground mb-3">3 Hũ Xu của bạn</div>
                      <div className="grid grid-cols-3 gap-2">
                        <div className="text-center">
                          <div className="w-10 h-12 mx-auto bg-primary/20 rounded-lg flex items-center justify-center mb-1">
                            <PiggyBank className="w-5 h-5 text-primary" />
                          </div>
                          <div className="text-xs font-medium text-foreground">150</div>
                          <div className="text-[10px] text-muted-foreground">Tiết kiệm</div>
                        </div>
                        <div className="text-center">
                          <div className="w-10 h-12 mx-auto bg-secondary/20 rounded-lg flex items-center justify-center mb-1">
                            <Coins className="w-5 h-5 text-secondary" />
                          </div>
                          <div className="text-xs font-medium text-foreground">80</div>
                          <div className="text-[10px] text-muted-foreground">Tiêu dùng</div>
                        </div>
                        <div className="text-center">
                          <div className="w-10 h-12 mx-auto bg-accent rounded-lg flex items-center justify-center mb-1">
                            <Gift className="w-5 h-5 text-accent-foreground" />
                          </div>
                          <div className="text-xs font-medium text-foreground">30</div>
                          <div className="text-[10px] text-muted-foreground">Sẻ chia</div>
                        </div>
                      </div>
                    </div>

                    {/* Tasks */}
                    <div className="bg-card border border-border rounded-2xl p-3 flex-1">
                      <div className="text-sm font-medium text-foreground mb-2">Nhiệm vụ hôm nay</div>
                      <div className="flex flex-col gap-2">
                        <div className="flex items-center gap-3 bg-muted rounded-xl p-3">
                          <div className="w-10 h-10 bg-primary rounded-full flex items-center justify-center text-lg">📚</div>
                          <div className="flex-1">
                            <div className="text-sm font-medium text-foreground">Đọc sách 30 phút</div>
                            <div className="text-xs text-muted-foreground">+30 xu</div>
                          </div>
                          <div className="w-6 h-6 bg-primary rounded-full flex items-center justify-center">
                            <svg className="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={3}><path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" /></svg>
                          </div>
                        </div>
                        <div className="flex items-center gap-3 bg-white rounded-xl p-3 border border-border">
                          <div className="w-10 h-10 bg-secondary/20 rounded-full flex items-center justify-center text-lg">🧹</div>
                          <div className="flex-1">
                            <div className="text-sm font-medium text-foreground">Dọn phòng</div>
                            <div className="text-xs text-muted-foreground">+20 xu</div>
                          </div>
                          <div className="w-6 h-6 border-2 border-border rounded-full" />
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
