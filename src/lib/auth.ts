import { getServerSession, NextAuthOptions } from "next-auth";
import GoogleProvider from "next-auth/providers/google";
import { db } from "./db";
import { DB } from "kysely-codegen";

// Define user type based on your database schema
export interface ZulalUser {
  id: string;
  email: string;
  locale: string;
  preferred_locales: string[];
  metadata: keyof DB["user"]["metadata"];
  is_active: boolean;
  cio_id?: string;
  created_at: Date;
}

export interface ZulalUserTenant {
  id: string;
  user_id: string;
  tenant_id: string;
  role: "retailer" | "brand" | "admin" | "platform";
  is_primary: boolean;
  joined_at: Date;
}

export interface ZulalTenant {
  id: string;
  name: string;
  slug: string;
  settings: keyof DB["tenant"]["settings"];
  features: keyof DB["tenant"]["features"];
  is_active: boolean;
}

// Admin email constant
const ADMIN_EMAIL = "garoh2291@gmail.com";

// Function to get or create user
export async function getOrCreateUser(
  email: string,
  name?: string
): Promise<ZulalUser> {
  try {
    // First, try to find existing user
    const user = (await db
      .selectFrom("user")
      .selectAll()
      .where("email", "=", email)
      .where("is_active", "=", true)
      .executeTakeFirst()) as ZulalUser;

    if (user) {
      return user;
    }

    // Create new user
    const userId = crypto.randomUUID();
    const now = new Date();

    const newUser = (await db
      .insertInto("user")
      .values({
        id: userId,
        email: email,
        locale: "en",
        preferred_locales: ["en"],
        metadata: {},
        is_active: true,
        created_at: now,
        created_timestamp: Math.floor(now.getTime() / 1000),
      })
      .returningAll()
      .executeTakeFirstOrThrow()) as ZulalUser;

    return newUser;
  } catch (error) {
    console.error("Error in getOrCreateUser:", error);
    throw error;
  }
}

// Function to get or create tenant for user
export async function getOrCreateUserTenant(
  user: ZulalUser
): Promise<{ tenant: ZulalTenant; userTenant: ZulalUserTenant }> {
  try {
    // Check if user already has a tenant relationship
    const existingUserTenant = (await db
      .selectFrom("user_tenant")
      .selectAll()
      .where("user_id", "=", user.id)
      .where("is_primary", "=", true)
      .executeTakeFirst()) as ZulalUserTenant;

    if (existingUserTenant) {
      // Get the tenant details
      const tenant = (await db
        .selectFrom("tenant")
        .selectAll()
        .where("id", "=", existingUserTenant.tenant_id)
        .where("is_active", "=", true)
        .executeTakeFirstOrThrow()) as ZulalTenant;

      return { tenant, userTenant: existingUserTenant };
    }

    // Create new tenant for the user
    const tenantId = crypto.randomUUID();
    const userTenantId = crypto.randomUUID();
    const now = new Date();

    // Determine tenant name and user role
    const isAdmin = user.email === ADMIN_EMAIL;
    const tenantName = isAdmin
      ? "Zulal Admin"
      : `${user.email.split("@")[0]}'s Organization`;
    const tenantSlug = isAdmin
      ? "zulal-admin"
      : `${user.email.split("@")[0].replace(/[^a-zA-Z0-9]/g, "-")}-org`;
    const userRole = isAdmin ? "admin" : "retailer";

    // Create tenant
    const tenant = await db
      .insertInto("tenant")
      .values({
        id: tenantId,
        name: tenantName,
        slug: tenantSlug,
        settings: {},
        features: {},
        is_active: true,
        created_at: now,
        created_by: user.id,
        updated_at: now,
        updated_by: user.id,
      })
      .returningAll()
      .executeTakeFirstOrThrow();

    // Create user-tenant relationship
    const userTenant = await db
      .insertInto("user_tenant")
      .values({
        id: userTenantId,
        user_id: user.id,
        tenant_id: tenantId,
        role: userRole,
        is_primary: true,
        joined_at: now,
        created_by: user.id,
        updated_at: now,
        updated_by: user.id,
      })
      .returningAll()
      .executeTakeFirstOrThrow();

    return { tenant, userTenant } as {
      tenant: ZulalTenant;
      userTenant: ZulalUserTenant;
    };
  } catch (error) {
    console.error("Error in getOrCreateUserTenant:", error);
    throw error;
  }
}

// Function to get user's primary tenant
export async function getUserPrimaryTenant(
  userId: string
): Promise<{ tenant: ZulalTenant; userTenant: ZulalUserTenant } | null> {
  try {
    const result = await db
      .selectFrom("user_tenant")
      .innerJoin("tenant", "tenant.id", "user_tenant.tenant_id")
      .select([
        "user_tenant.id as ut_id",
        "user_tenant.user_id",
        "user_tenant.tenant_id",
        "user_tenant.role",
        "user_tenant.is_primary",
        "user_tenant.joined_at",
        "tenant.id as tenant_id",
        "tenant.name as tenant_name",
        "tenant.slug as tenant_slug",
        "tenant.settings as tenant_settings",
        "tenant.features as tenant_features",
        "tenant.is_active as tenant_is_active",
      ])
      .where("user_tenant.user_id", "=", userId)
      .where("user_tenant.is_primary", "=", true)
      .where("tenant.is_active", "=", true)
      .executeTakeFirst();

    if (!result) return null;

    const tenant: ZulalTenant = {
      id: result.tenant_id,
      name: result.tenant_name,
      slug: result.tenant_slug,
      settings: result.tenant_settings as keyof DB["tenant"]["settings"],
      features: result.tenant_features as keyof DB["tenant"]["features"],
      is_active: result.tenant_is_active as boolean,
    };

    const userTenant: ZulalUserTenant = {
      id: result.ut_id,
      user_id: result.user_id,
      tenant_id: result.tenant_id,
      role: result.role as "retailer" | "brand" | "admin" | "platform",
      is_primary: result.is_primary as boolean,
      joined_at: result.joined_at as Date,
    };

    return { tenant, userTenant };
  } catch (error) {
    console.error("Error in getUserPrimaryTenant:", error);
    return null;
  }
}

// Function to log user login
export async function logUserLogin(
  userId: string,
  tenantId?: string,
  request?: Request
): Promise<void> {
  try {
    const now = new Date();
    const loginId = crypto.randomUUID();

    // Extract request information if available
    let loginIp: string | null = null;
    let userAgent: string | null = null;
    let deviceInfo: [string, string][] = [];

    if (request) {
      // Try to get IP from various headers
      loginIp =
        request.headers.get("x-forwarded-for")?.split(",")[0] ||
        request.headers.get("x-real-ip") ||
        request.headers.get("cf-connecting-ip") ||
        request.headers.get("x-forwarded-for")?.split(",")[0] ||
        null;

      userAgent = request.headers.get("user-agent") || null;

      // Basic device info parsing
      if (userAgent) {
        deviceInfo = {
          //@ts-expect-error - userAgent is a string
          userAgent,
          isMobile: /Mobile|Android|iPhone|iPad/.test(userAgent),
          browser: userAgent.includes("Chrome")
            ? "Chrome"
            : userAgent.includes("Firefox")
            ? "Firefox"
            : userAgent.includes("Safari")
            ? "Safari"
            : "Unknown",
        };
      }
    }

    await db
      .insertInto("user_login")
      .values({
        id: loginId,
        user_id: userId,
        tenant_id: tenantId || null,
        login_at: now,
        login_ip: loginIp,
        user_agent: userAgent,
        device_info: deviceInfo,
        location: {}, // Could be enhanced with IP geolocation
        success: true,
        session_id: loginId, // Using login ID as session ID for now
      })
      .execute();

    console.log(`Login logged for user ${userId}`);
  } catch (error) {
    console.error("Error logging user login:", error);
    // Don't throw error - login tracking shouldn't break authentication
  }
}

export const authOptions: NextAuthOptions = {
  providers: [
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    }),
  ],
  callbacks: {
    async signIn({ user, account, profile }) {
      try {
        if (account?.provider === "google" && user.email) {
          // Get or create user in database
          const dbUser = await getOrCreateUser(
            user.email,
            user.name || undefined
          );

          // Get or create tenant relationship
          await getOrCreateUserTenant(dbUser);

          return true;
        }
        return false;
      } catch (error) {
        console.error("Error in signIn callback:", error);
        return false;
      }
    },
    async jwt({ token, user, account, trigger }) {
      if (account && user.email) {
        try {
          // Get user from database
          const dbUser = await getOrCreateUser(user.email);

          // Get primary tenant
          const tenantInfo = await getUserPrimaryTenant(dbUser.id);

          if (tenantInfo) {
            token.userId = dbUser.id;
            token.tenantId = tenantInfo.tenant.id;
            token.role = tenantInfo.userTenant.role;
            token.tenantSlug = tenantInfo.tenant.slug;
            token.isAdmin = dbUser.email === ADMIN_EMAIL;

            // Log the login event (only on initial sign in, not on token refresh)
            if (trigger !== "update") {
              await logUserLogin(dbUser.id, tenantInfo.tenant.id);
            }
          }
        } catch (error) {
          console.error("Error in jwt callback:", error);
        }
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user && token) {
        session.user.id = token.userId as string;
        session.user.tenantId = token.tenantId as string;
        session.user.role = token.role as string;
        session.user.tenantSlug = token.tenantSlug as string;
        session.user.isAdmin = token.isAdmin as boolean;
      }
      return session;
    },
  },
  pages: {
    signIn: "/signin",
  },
  session: {
    strategy: "jwt",
  },
};

export const checkServerSession = async () => {
  try {
    const session = await getServerSession(authOptions);
    return session;
  } catch (error) {
    console.error("Error in checkServerSession:", error);
    return null;
  }
};

export type GetCurrentUser = Awaited<ReturnType<typeof checkServerSession>>;
