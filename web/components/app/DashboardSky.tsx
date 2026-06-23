// Decorative dashboard backdrop: sky gradient + clouds + rolling hills + coins,
// fading into the page background at the bottom. Pure presentational.
// The sky stretches far enough to sit behind the top cards (incl. Achievements).
export default function DashboardSky() {
  return (
    <svg
      viewBox="0 0 430 480"
      width="100%"
      height="100%"
      preserveAspectRatio="xMidYMin slice"
      style={{ display: "block" }}
      aria-hidden
    >
      <defs>
        <linearGradient id="gwDashSky" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#CDE8FF" />
          <stop offset="55%" stopColor="#E8F3FF" />
          <stop offset="100%" stopColor="#FFF6EA" />
        </linearGradient>
        <linearGradient id="gwDashFade" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="var(--color-background)" stopOpacity="0" />
          <stop offset="100%" stopColor="var(--color-background)" stopOpacity="1" />
        </linearGradient>
      </defs>

      {/* sky */}
      <rect x="0" y="0" width="430" height="480" fill="url(#gwDashSky)" />

      {/* sun */}
      <circle cx="360" cy="74" r="34" fill="#FFE08A" opacity="0.85" />

      {/* clouds */}
      <g opacity="0.95" style={{ animation: "gw-cloud-drift 7s ease-in-out infinite" }}>
        <ellipse cx="80" cy="90" rx="30" ry="18" fill="#fff" />
        <ellipse cx="56" cy="98" rx="18" ry="13" fill="#fff" />
        <ellipse cx="104" cy="98" rx="20" ry="14" fill="#fff" />
      </g>
      <g opacity="0.9" style={{ animation: "gw-cloud-drift 9s ease-in-out 1s infinite" }}>
        <ellipse cx="300" cy="150" rx="26" ry="15" fill="#fff" />
        <ellipse cx="282" cy="156" rx="15" ry="11" fill="#fff" />
        <ellipse cx="318" cy="156" rx="17" ry="12" fill="#fff" />
      </g>

      {/* floating coins */}
      <g style={{ animation: "float 5s ease-in-out infinite" }}>
        <circle cx="150" cy="150" r="14" fill="#F2C94C" stroke="#D9A300" strokeWidth="2.5" />
        <text x="150" y="156" textAnchor="middle" fontSize="14" fontWeight="900" fill="#A77B00">₫</text>
      </g>
      <g style={{ animation: "float 6s ease-in-out 0.8s infinite" }}>
        <circle cx="250" cy="96" r="11" fill="#F2C94C" stroke="#D9A300" strokeWidth="2" />
        <text x="250" y="101" textAnchor="middle" fontSize="11" fontWeight="900" fill="#A77B00">₫</text>
      </g>

      {/* rolling hills near the bottom (behind the Achievements card area) */}
      <path d="M0,432 Q110,386 230,424 T430,412 V480 H0 Z" fill="#BFE3A6" opacity="0.85" />
      <path d="M0,452 Q140,418 280,446 T430,440 V480 H0 Z" fill="#9FD487" opacity="0.9" />

      {/* fade into page background (starts below the cards) */}
      <rect x="0" y="360" width="430" height="120" fill="url(#gwDashFade)" />
    </svg>
  );
}
