import { checkServerSession } from "@/lib/auth";
import { redirect } from "next/navigation";
import { setSessionContext } from "@/lib/db";

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const session = await checkServerSession();

  if (!session) {
    redirect("/signin");
  }

  // Set session context for RLS if user is authenticated
  if (session?.user?.tenantId && session?.user?.id) {
    try {
      await setSessionContext(session.user.tenantId, session.user.id);
    } catch (error) {
      console.error("Error setting session context:", error);
    }
  }

  return <div>{children}</div>;
}
