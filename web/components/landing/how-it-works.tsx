"use client";

import { ClipboardList, CheckCircle2, Coins, ArrowRight } from "lucide-react";
import { useLang } from "@/components/app/LangProvider";
import type { TKey } from "@/lib/i18n";

const steps: { icon: typeof ClipboardList; titleKey: TKey; descKey: TKey; color: string; iconColor: string }[] = [
  { icon: ClipboardList, titleKey: "lpStep1Title", descKey: "lpStep1Desc", color: "bg-secondary/20", iconColor: "text-secondary" },
  { icon: CheckCircle2, titleKey: "lpStep2Title", descKey: "lpStep2Desc", color: "bg-secondary/20", iconColor: "text-secondary" },
  { icon: Coins, titleKey: "lpStep3Title", descKey: "lpStep3Desc", color: "bg-amber-100", iconColor: "text-amber-700" },
];

export function HowItWorks() {
  const { t } = useLang();
  return (
    <section id="how-it-works" className="py-16 sm:py-24 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-12 sm:mb-16">
          <span className="inline-block bg-secondary/10 text-secondary px-4 py-1.5 rounded-full text-sm font-medium mb-4">
            {t("lpHowEyebrow")}
          </span>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-gray-900 text-balance">
            {t("lpHowTitle")}
          </h2>
          <p className="mt-4 text-lg text-gray-500 max-w-2xl mx-auto">
            {t("lpHowSub")}
          </p>
        </div>

        {/* Steps */}
        <div className="grid md:grid-cols-3 gap-6 lg:gap-8">
          {steps.map((step, index) => (
            <div key={index} className="relative">
              <div className="bg-white rounded-3xl p-8 h-full border border-gray-200 hover:border-secondary/50 transition-colors group">
                {/* Step number */}
                <div className="absolute -top-4 left-8 bg-[#1d1a24] text-white w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm">
                  {index + 1}
                </div>

                {/* Icon */}
                <div className={`w-16 h-16 ${step.color} rounded-2xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform`}>
                  <step.icon className={`w-8 h-8 ${step.iconColor}`} />
                </div>

                {/* Content */}
                <h3 className="text-xl font-bold text-gray-900 mb-3">
                  {t(step.titleKey)}
                </h3>
                <p className="text-gray-500 leading-relaxed">
                  {t(step.descKey)}
                </p>
              </div>

              {/* Arrow connector (hidden on last item and mobile) */}
              {index < steps.length - 1 && (
                <div className="hidden md:flex absolute top-1/2 -right-4 lg:-right-6 transform -translate-y-1/2 z-10">
                  <div className="w-8 h-8 lg:w-12 lg:h-12 bg-gray-100 rounded-full flex items-center justify-center">
                    <ArrowRight className="w-4 h-4 lg:w-5 lg:h-5 text-gray-500" />
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
