import { getMyChildren } from "@/lib/app/children";
import RolePicker from "@/components/app/RolePicker";

export const dynamic = "force-dynamic";

export default async function RolePage() {
  const children = await getMyChildren();
  return <RolePicker children={children} />;
}
