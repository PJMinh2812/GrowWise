import type { CSSProperties } from "react";
import type { Icon as PhIcon, IconWeight } from "@phosphor-icons/react";
import {
  House,
  SquaresFour,
  ClipboardText,
  Wallet,
  GraduationCap,
  UsersThree,
  Path,
  PiggyBank,
  Hourglass,
  Robot,
  GearSix,
  Medal,
  Coins,
  PencilSimple,
  X,
  Star,
  Lock,
  LockKey,
  ArrowsLeftRight,
  CaretRight,
  ArrowLeft,
  ArrowRight,
  SpeakerHigh,
  SpeakerSlash,
  UploadSimple,
  PaperPlaneRight,
  ArrowCounterClockwise,
  Images,
  Camera,
  Image as ImageIcon,
  UserPlus,
  Envelope,
  SignOut,
  DownloadSimple,
  Trash,
  ChatCircleDots,
  Megaphone,
  Backspace,
  Plus,
  Question,
  CheckCircle,
  Smiley,
  RocketLaunch,
  Eye,
  EyeSlash,
  LockOpen,
  WarningCircle,
  Clock,
} from "@phosphor-icons/react/dist/ssr";

/**
 * Maps the legacy Material Symbols names used across the app to Phosphor icons,
 * so call sites keep their familiar names while we render a single, consistent
 * (duotone) icon set. Add a new entry here when introducing a new icon name.
 */
const MAP: Record<string, PhIcon> = {
  home: House,
  dashboard: SquaresFour,
  assignment: ClipboardText,
  account_balance_wallet: Wallet,
  school: GraduationCap,
  group: UsersThree,
  route: Path,
  savings: PiggyBank,
  hourglass_top: Hourglass,
  smart_toy: Robot,
  settings: GearSix,
  workspace_premium: Medal,
  toll: Coins,
  edit: PencilSimple,
  close: X,
  star: Star,
  lock: Lock,
  lock_reset: LockKey,
  swap_horiz: ArrowsLeftRight,
  chevron_right: CaretRight,
  arrow_back: ArrowLeft,
  arrow_forward: ArrowRight,
  volume_up: SpeakerHigh,
  volume_off: SpeakerSlash,
  upload: UploadSimple,
  send: PaperPlaneRight,
  replay: ArrowCounterClockwise,
  photo_library: Images,
  photo_camera: Camera,
  image: ImageIcon,
  person_add: UserPlus,
  mail: Envelope,
  logout: SignOut,
  download: DownloadSimple,
  delete: Trash,
  chat: ChatCircleDots,
  campaign: Megaphone,
  backspace: Backspace,
  add: Plus,
  quiz: Question,
  check_circle: CheckCircle,
  mood: Smiley,
  upgrade: RocketLaunch,
  visibility: Eye,
  visibility_off: EyeSlash,
  lock_open: LockOpen,
  error: WarningCircle,
  schedule: Clock,
};

export default function Icon({
  name,
  className,
  weight = "duotone",
  size,
  style,
  fill,
}: {
  name: string;
  className?: string;
  weight?: IconWeight;
  /** Pixel/string size. Defaults to `1em` so it scales with surrounding font-size. */
  size?: number | string;
  style?: CSSProperties;
  /** Convenience: render the solid (fill) variant. */
  fill?: boolean;
}) {
  const Cmp = MAP[name];
  if (!Cmp) {
    if (process.env.NODE_ENV !== "production") {
      // eslint-disable-next-line no-console
      console.warn(`[Icon] unknown name "${name}" — add it to components/Icon.tsx`);
    }
    return null;
  }
  return <Cmp className={className} weight={fill ? "fill" : weight} size={size} style={style} />;
}
