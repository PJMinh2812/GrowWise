import type { Metadata, Viewport } from "next";
import { Nunito, Nunito_Sans } from "next/font/google";
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

export const metadata: Metadata = {
  title: "GrowWise - Dạy con yêu tiền, đúng cách, đúng lúc",
  description: "GrowWise giúp trẻ học quản lý tiền qua nhiệm vụ hằng ngày, hệ thống 3 hũ và trợ lý AI thông minh. Ứng dụng giáo dục tài chính #1 cho trẻ em Việt Nam.",
  keywords: ["giáo dục tài chính", "trẻ em", "quản lý tiền", "tiết kiệm", "Việt Nam", "GrowWise"],
  authors: [{ name: "GrowWise" }],
  openGraph: {
    title: "GrowWise - Dạy con yêu tiền, đúng cách, đúng lúc",
    description: "GrowWise giúp trẻ học quản lý tiền qua nhiệm vụ hằng ngày, hệ thống 3 hũ và trợ lý AI thông minh.",
    type: "website",
    locale: "vi_VN",
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
  return (
    <html
      lang="vi"
      className={`${nunito.variable} ${nunitoSans.variable} bg-background antialiased`}
    >
      <head>
        <link
          rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block"
        />
      </head>
      <body className="min-h-full flex flex-col font-sans" suppressHydrationWarning>
        {children}
      </body>
    </html>
  );
}
