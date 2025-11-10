import NextAuth from "next-auth";
import { JWT } from "next-auth/jwt";

declare module "next-auth" {
  interface Session {
    user: {
      id: string;
      name?: string | null;
      email?: string | null;
      image?: string | null;
      tenantId: string;
      role: string;
      tenantSlug: string;
      isAdmin: boolean;
    };
  }

  interface User {
    id: string;
    email: string;
    name?: string;
    tenantId?: string;
    role?: string;
    tenantSlug?: string;
    isAdmin?: boolean;
  }
}

declare module "next-auth/jwt" {
  interface JWT {
    userId?: string;
    tenantId?: string;
    role?: string;
    tenantSlug?: string;
    isAdmin?: boolean;
  }
}
