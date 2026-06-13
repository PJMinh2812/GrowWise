"use client";

import Link from "next/link";
import { Menu, X } from "lucide-react";
import { useEffect, useState } from "react";
import { createClient } from "@/lib/supabase";

export function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [loggedIn, setLoggedIn] = useState<boolean | null>(null);

  useEffect(() => {
    createClient()
      .auth.getUser()
      .then(({ data }) => setLoggedIn(Boolean(data.user)))
      .catch(() => setLoggedIn(false));
  }, []);

  const appHref = loggedIn ? "/role" : "/login";
  const appLabel = loggedIn ? "Vào ứng dụng" : "Đăng nhập";

  return (
    <header className="sticky top-0 z-50 bg-white/80 backdrop-blur-md border-b border-gray-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2">
            <div className="w-10 h-10 bg-secondary rounded-xl flex items-center justify-center">
              <span className="text-white font-bold text-lg">G</span>
            </div>
            <span className="font-bold text-xl text-gray-900">GrowWise</span>
          </Link>

          {/* Desktop Navigation */}
          <nav className="hidden md:flex items-center gap-8">
            <Link href="#how-it-works" className="text-gray-500 hover:text-gray-900 transition-colors">
              Cách hoạt động
            </Link>
            <Link href="#features" className="text-gray-500 hover:text-gray-900 transition-colors">
              Tính năng
            </Link>
            <Link href="#testimonials" className="text-gray-500 hover:text-gray-900 transition-colors">
              Đánh giá
            </Link>
            <Link href="#pricing" className="text-gray-500 hover:text-gray-900 transition-colors font-medium">
              Bảng giá
            </Link>
          </nav>

          {/* CTA Buttons */}
          <div className="hidden md:flex items-center gap-3">
            <Link
              href={appHref}
              className="text-gray-700 font-medium hover:text-gray-900 transition-colors"
            >
              {appLabel}
            </Link>
            <Link
              href="#download"
              className="bg-secondary text-white px-5 py-2.5 rounded-full font-medium hover:bg-secondary/90 transition-colors"
            >
              Tải ứng dụng
            </Link>
          </div>

          {/* Mobile Menu Button */}
          <button
            className="md:hidden p-2 text-gray-900"
            onClick={() => setIsMenuOpen(!isMenuOpen)}
            aria-label="Toggle menu"
          >
            {isMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>

        {/* Mobile Navigation */}
        {isMenuOpen && (
          <nav className="md:hidden py-4 border-t border-gray-200">
            <div className="flex flex-col gap-4">
              <Link
                href="#how-it-works"
                className="text-gray-500 hover:text-gray-900 transition-colors"
                onClick={() => setIsMenuOpen(false)}
              >
                Cách hoạt động
              </Link>
              <Link
                href="#features"
                className="text-gray-500 hover:text-gray-900 transition-colors"
                onClick={() => setIsMenuOpen(false)}
              >
                Tính năng
              </Link>
              <Link
                href="#testimonials"
                className="text-gray-500 hover:text-gray-900 transition-colors"
                onClick={() => setIsMenuOpen(false)}
              >
                Đánh giá
              </Link>
              <Link
                href="#pricing"
                className="text-gray-500 hover:text-gray-900 transition-colors font-medium"
                onClick={() => setIsMenuOpen(false)}
              >
                Bảng giá
              </Link>
              <Link
                href={appHref}
                className="text-gray-700 font-medium hover:text-gray-900 transition-colors"
                onClick={() => setIsMenuOpen(false)}
              >
                {appLabel}
              </Link>
              <Link
                href="#download"
                className="bg-secondary text-white px-5 py-2.5 rounded-full font-medium hover:bg-secondary/90 transition-colors text-center"
                onClick={() => setIsMenuOpen(false)}
              >
                Tải ứng dụng
              </Link>
            </div>
          </nav>
        )}
      </div>
    </header>
  );
}
