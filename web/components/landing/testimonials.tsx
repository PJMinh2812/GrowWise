"use client";

import { Star, Quote } from "lucide-react";
import { useLang } from "@/components/app/LangProvider";
import type { TKey } from "@/lib/i18n";

const testimonials: { name: string; roleKey: TKey; avatar: string; rating: number; contentKey: TKey }[] = [
  { name: "Lan Anh", roleKey: "lpTest1Role", avatar: "👩", rating: 5, contentKey: "lpTest1Content" },
  { name: "Hoàng", roleKey: "lpTest2Role", avatar: "👨", rating: 5, contentKey: "lpTest2Content" },
  { name: "Thảo", roleKey: "lpTest3Role", avatar: "👩‍🦱", rating: 5, contentKey: "lpTest3Content" },
];

export function Testimonials() {
  const { t } = useLang();
  return (
    <section id="testimonials" className="py-16 sm:py-24 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-12 sm:mb-16">
          <span className="inline-block bg-amber-100 text-amber-700 px-4 py-1.5 rounded-full text-sm font-medium mb-4">
            {t("lpTestEyebrow")}
          </span>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-gray-900 text-balance">
            {t("lpTestTitle")}
          </h2>
          <p className="mt-4 text-lg text-gray-500 max-w-2xl mx-auto">
            {t("lpTestSub")}
          </p>
        </div>

        {/* Testimonials grid */}
        <div className="grid md:grid-cols-3 gap-6 lg:gap-8">
          {testimonials.map((testimonial, index) => (
            <div
              key={index}
              className="bg-white rounded-3xl p-6 sm:p-8 border border-gray-200 hover:border-secondary/50 transition-colors relative"
            >
              {/* Quote icon */}
              <Quote className="absolute top-6 right-6 w-8 h-8 text-secondary/20" />

              {/* Rating */}
              <div className="flex gap-1 mb-4">
                {Array.from({ length: testimonial.rating }).map((_, i) => (
                  <Star key={i} className="w-5 h-5 fill-secondary text-secondary" />
                ))}
              </div>

              {/* Content */}
              <p className="text-gray-900 leading-relaxed mb-6">
                {`"${t(testimonial.contentKey)}"`}
              </p>

              {/* Author */}
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center text-2xl">
                  {testimonial.avatar}
                </div>
                <div>
                  <div className="font-semibold text-gray-900">{testimonial.name}</div>
                  <div className="text-sm text-gray-500">{t(testimonial.roleKey)}</div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
