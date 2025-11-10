import { Kysely, PostgresDialect, sql } from "kysely";
import { DB } from "kysely-codegen";
import { Pool } from "pg";

const db = new Kysely<DB>({
  dialect: new PostgresDialect({
    pool: new Pool({
      connectionString: process.env.DATABASE_URL,
    }),
  }),
});

// Helper function to set session context for multi-tenant RLS
export async function setSessionContext(tenantId: string, userId: string) {
  await sql`SELECT set_session_context(${tenantId}, ${userId})`.execute(db);
}

// Helper functions to get current context
export async function getCurrentTenantId(): Promise<string | null> {
  try {
    const result = await sql<{
      current_tenant_id: string | null;
    }>`SELECT current_tenant_id()`.execute(db);
    return result.rows[0]?.current_tenant_id || null;
  } catch {
    return null;
  }
}

export async function getCurrentUserId(): Promise<string | null> {
  try {
    const result = await sql<{
      current_user_id: string | null;
    }>`SELECT current_user_id()`.execute(db);
    return result.rows[0]?.current_user_id || null;
  } catch {
    return null;
  }
}

export { db };
