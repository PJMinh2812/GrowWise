import type { MetadataRoute } from "next";

const BASE = "https://www.growwise.io.vn";

export default function sitemap(): MetadataRoute.Sitemap {
  return [
    { url: BASE, changeFrequency: "weekly", priority: 1 },
    { url: `${BASE}/pricing`, changeFrequency: "monthly", priority: 0.8 },
    { url: `${BASE}/login`, changeFrequency: "yearly", priority: 0.3 },
    { url: `${BASE}/register`, changeFrequency: "yearly", priority: 0.3 },
  ];
}
