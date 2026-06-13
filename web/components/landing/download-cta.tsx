import { Smartphone, Sparkles } from "lucide-react";

export function DownloadCTA() {
  return (
    <section id="download" className="py-16 sm:py-24 bg-[#f0fdf4]">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="relative bg-secondary rounded-[2.5rem] overflow-hidden">
          {/* Background decoration */}
          <div className="absolute inset-0">
            <div className="absolute top-0 right-0 w-96 h-96 bg-white/10 rounded-full blur-3xl transform translate-x-1/2 -translate-y-1/2" />
            <div className="absolute bottom-0 left-0 w-64 h-64 bg-white/10 rounded-full blur-3xl transform -translate-x-1/2 translate-y-1/2" />
          </div>

          <div className="relative px-6 py-12 sm:px-12 sm:py-16 lg:px-16 lg:py-20">
            <div className="grid lg:grid-cols-2 gap-10 items-center">
              {/* Content */}
              <div className="text-center lg:text-left">
                <div className="inline-flex items-center gap-2 bg-white/20 px-4 py-2 rounded-full mb-6">
                  <Sparkles className="w-4 h-4 text-white" />
                  <span className="text-sm font-medium text-white">
                    Miễn phí tải về
                  </span>
                </div>

                <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-white leading-tight text-balance">
                  Bắt đầu hành trình tài chính thông minh cho con ngay hôm nay!
                </h2>

                <p className="mt-6 text-lg text-white/80 max-w-lg mx-auto lg:mx-0">
                  Tải GrowWise miễn phí và khám phá cách giúp con bạn trở thành nhà quản lý tài chính nhí thông minh.
                </p>

                {/* App Store buttons */}
                <div className="mt-8 flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
                  <a
                    href="#"
                    className="inline-flex items-center justify-center gap-3 bg-[#1d1a24] text-white px-6 py-3.5 rounded-xl hover:bg-[#1d1a24]/90 transition-colors"
                  >
                    <svg className="w-8 h-8" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                    </svg>
                    <div className="text-left">
                      <div className="text-[10px] opacity-80">Tải về trên</div>
                      <div className="text-sm font-semibold">App Store</div>
                    </div>
                  </a>

                  <a
                    href="#"
                    className="inline-flex items-center justify-center gap-3 bg-[#1d1a24] text-white px-6 py-3.5 rounded-xl hover:bg-[#1d1a24]/90 transition-colors"
                  >
                    <svg className="w-7 h-7" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M3 20.5v-17c0-.83.67-1.5 1.5-1.5h11c.28 0 .5.22.5.5s-.22.5-.5.5H4.5c-.28 0-.5.22-.5.5v17c0 .28.22.5.5.5h15c.28 0 .5-.22.5-.5v-10c0-.28.22-.5.5-.5s.5.22.5.5v10c0 .83-.67 1.5-1.5 1.5h-15c-.83 0-1.5-.67-1.5-1.5z"/>
                      <path d="M21.89 3.77l-1.66-1.66c-.18-.18-.44-.18-.62 0l-8.55 8.55c-.18.18-.18.44 0 .62l1.66 1.66c.18.18.44.18.62 0l8.55-8.55c.18-.18.18-.44 0-.62zM12 13.5l-2.12-2.12L14.5 6.76l2.12 2.12L12 13.5z"/>
                    </svg>
                    <div className="text-left">
                      <div className="text-[10px] opacity-80">Tải về trên</div>
                      <div className="text-sm font-semibold">Google Play</div>
                    </div>
                  </a>
                </div>
              </div>

              {/* Phone illustration */}
              <div className="flex justify-center lg:justify-end">
                <div className="relative">
                  <div className="absolute -top-6 -left-6 w-24 h-24 bg-white/20 rounded-full blur-xl" />
                  <div className="absolute -bottom-6 -right-6 w-32 h-32 bg-white/20 rounded-full blur-xl" />

                  <div className="relative bg-white/20 backdrop-blur-sm rounded-[2rem] p-4 border border-white/30">
                    <div className="bg-white rounded-[1.5rem] p-6 w-[200px] sm:w-[240px]">
                      <div className="flex items-center justify-center mb-4">
                        <div className="w-16 h-16 bg-secondary rounded-2xl flex items-center justify-center">
                          <span className="text-3xl font-bold text-white">G</span>
                        </div>
                      </div>
                      <div className="text-center">
                        <h3 className="font-bold text-gray-900 text-lg">GrowWise</h3>
                        <p className="text-sm text-gray-500 mt-1">Tài chính thông minh cho trẻ</p>
                      </div>
                      <div className="mt-6 flex items-center justify-center gap-2">
                        <Smartphone className="w-5 h-5 text-secondary" />
                        <span className="text-sm font-medium text-secondary">Tải ngay!</span>
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
