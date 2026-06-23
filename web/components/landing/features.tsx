"use client";

import { PiggyBank, Gamepad2, Sparkles, Heart } from "lucide-react";
import { useLang } from "@/components/app/LangProvider";
import type { TKey } from "@/lib/i18n";

const features: {
  icon: typeof PiggyBank;
  titleKey: TKey;
  subtitleKey: TKey;
  descKey: TKey;
  color: string;
  bgColor: string;
}[] = [
  { icon: PiggyBank, titleKey: "lpFeat1Title", subtitleKey: "lpFeat1Sub", descKey: "lpFeat1Desc", color: "bg-secondary", bgColor: "bg-secondary/10" },
  { icon: Gamepad2, titleKey: "lpFeat2Title", subtitleKey: "lpFeat2Sub", descKey: "lpFeat2Desc", color: "bg-secondary", bgColor: "bg-secondary/10" },
  { icon: Sparkles, titleKey: "lpFeat3Title", subtitleKey: "lpFeat3Sub", descKey: "lpFeat3Desc", color: "bg-gray-900", bgColor: "bg-gray-900/10" },
  { icon: Heart, titleKey: "lpFeat4Title", subtitleKey: "lpFeat4Sub", descKey: "lpFeat4Desc", color: "bg-primary", bgColor: "bg-amber-100" },
];

export function Features() {
  const { t } = useLang();
  return (
    <section id="features" className="py-16 sm:py-24 bg-[#f0fdf4]">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-12 sm:mb-16">
          <span className="inline-block bg-secondary/10 text-secondary px-4 py-1.5 rounded-full text-sm font-medium mb-4">
            {t("lpFeatEyebrow")}
          </span>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-gray-900 text-balance">
            {t("lpFeatTitle")}
          </h2>
          <p className="mt-4 text-lg text-gray-500 max-w-2xl mx-auto">
            {t("lpFeatSub")}
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
                {t(feature.titleKey)}
              </h3>
              <p className="text-sm font-medium text-secondary mb-3">
                {t(feature.subtitleKey)}
              </p>
              <p className="text-gray-500 text-sm leading-relaxed">
                {t(feature.descKey)}
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
            {t("lpFeatMore")}
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
            </svg>
          </a>
        </div>
      </div>
    </section>
  );
}
