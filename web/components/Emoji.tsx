import type { CSSProperties } from "react";

/**
 * Consistent 3D emoji rendered from vendored Fluent Emoji assets
 * (public/emoji/*.png), so decorative emoji look the same on every device
 * instead of relying on each OS's native emoji font.
 *
 * Only decorative/UI emoji belong here — user-chosen emoji (avatars, dream
 * items, lesson content) stay as native text.
 */
export type EmojiName =
  | "coin"
  | "trophy"
  | "fire"
  | "party"
  | "seedling"
  | "moneybag"
  | "gift"
  | "rocket"
  | "sparkles"
  | "star"
  | "shopping"
  | "piggy"
  | "bank"
  | "cart"
  | "bulb"
  | "target"
  | "clipboard"
  | "check"
  | "heart"
  | "warning"
  | "inbox"
  | "outbox"
  | "family"
  | "box"
  | "people"
  | "new"
  | "locked";

export default function Emoji({
  name,
  size = 22,
  className,
  style,
  alt = "",
}: {
  name: EmojiName;
  size?: number;
  className?: string;
  style?: CSSProperties;
  alt?: string;
}) {
  return (
    // eslint-disable-next-line @next/next/no-img-element
    <img
      src={`/emoji/${name}.png`}
      alt={alt}
      width={size}
      height={size}
      aria-hidden={alt === "" ? true : undefined}
      className={className}
      style={{ display: "inline-block", verticalAlign: "middle", objectFit: "contain", ...style }}
      draggable={false}
    />
  );
}
