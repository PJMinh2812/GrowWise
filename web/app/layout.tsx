import type { Metadata, Viewport } from "next";
import { Nunito, Nunito_Sans } from "next/font/google";
import { GoogleAnalytics } from "@next/third-parties/google";
import "./globals.css";

const nunito = Nunito({
  variable: "--font-nunito",
  subsets: ["latin", "vietnamese"],
  weight: ["400", "500", "600", "700", "800"],
});

const nunitoSans = Nunito_Sans({
  variable: "--font-nunito-sans",
  subsets: ["latin", "vietnamese"],
  weight: ["400", "500", "600", "700"],
});

const SITE_URL = "https://www.growwise.io.vn";
const TITLE = "GrowWise - Dạy con yêu tiền, đúng cách, đúng lúc";
const DESCRIPTION =
  "GrowWise giúp trẻ học quản lý tiền qua nhiệm vụ hằng ngày, hệ thống 3 hũ và trợ lý AI thông minh. Ứng dụng giáo dục tài chính #1 cho trẻ em Việt Nam.";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: TITLE,
  description: DESCRIPTION,
  keywords: ["giáo dục tài chính", "trẻ em", "quản lý tiền", "tiết kiệm", "Việt Nam", "GrowWise"],
  authors: [{ name: "GrowWise", url: SITE_URL }],
  alternates: { canonical: "/" },
  robots: { index: true, follow: true },
  openGraph: {
    title: TITLE,
    description: DESCRIPTION,
    type: "website",
    locale: "vi_VN",
    url: SITE_URL,
    siteName: "GrowWise",
    images: [
      {
        url: "/opengraph-image",
        width: 1200,
        height: 630,
        alt: "GrowWise - Dạy con yêu tiền, đúng cách, đúng lúc",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: TITLE,
    description: DESCRIPTION,
    images: ["/opengraph-image"],
  },
};

export const viewport: Viewport = {
  themeColor: "#22c55e",
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const gaId = process.env.NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID;
  return (
    <html
      lang="vi"
      className={`${nunito.variable} ${nunitoSans.variable} bg-background antialiased`}
    >
      <body className="min-h-full flex flex-col font-sans" suppressHydrationWarning>
        {children}
      </body>
      {gaId && <GoogleAnalytics gaId={gaId} />}
    </html>
  );
}
