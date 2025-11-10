import { NextRequest, NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions, getUserPrimaryTenant } from "@/lib/auth";

export async function GET(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);

    if (!session?.user?.id) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const tenantInfo = await getUserPrimaryTenant(session.user.id);

    if (!tenantInfo) {
      return NextResponse.json(
        { error: "No tenant found for user" },
        { status: 404 }
      );
    }

    return NextResponse.json(tenantInfo);
  } catch (error) {
    console.error("Error fetching tenant info:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
