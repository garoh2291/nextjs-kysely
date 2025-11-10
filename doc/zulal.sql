-- -------------------------------------------------------------
-- TablePlus 6.0.0(550)
--
-- https://tableplus.com/
--
-- Database: zulal
-- Generation Time: 2025-11-10 15:42:08.1510
-- -------------------------------------------------------------


-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."address_type";
CREATE TYPE "public"."address_type" AS ENUM ('billing', 'shipping', 'other');
DROP TYPE IF EXISTS "public"."address_category";
CREATE TYPE "public"."address_category" AS ENUM ('home', 'office', 'other');

-- Table Definition
CREATE TABLE "public"."address" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "customer_id" uuid,
    "type" "public"."address_type" DEFAULT 'other'::address_type,
    "category" "public"."address_category" DEFAULT 'other'::address_category,
    "line1" text NOT NULL,
    "line2" text,
    "city" text NOT NULL,
    "state" text,
    "postal_code" text,
    "country" text NOT NULL,
    "country_code" bpchar(2),
    "phone" text,
    "lat" float8,
    "long" float8,
    "normalized_postal_code" text,
    "address_hash" text,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "is_primary" bool DEFAULT false,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    "deleted_at" timestamptz,
    "deleted_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."api_credential" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "platform_connection_id" uuid NOT NULL,
    "encrypted_access_token" text NOT NULL,
    "encrypted_refresh_token" text,
    "token_expires_at" timestamptz,
    "scopes" _text,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."actor_type";
CREATE TYPE "public"."actor_type" AS ENUM ('user', 'system', 'api', 'webhook', 'scheduled');

-- Table Definition
CREATE TABLE "public"."audit_log" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "correlation_id" uuid,
    "event_type" text NOT NULL,
    "actor_id" uuid,
    "actor_type" "public"."actor_type" DEFAULT 'user'::actor_type,
    "job_id" uuid,
    "api_endpoint" text,
    "api_method" text,
    "api_request" jsonb,
    "api_response" jsonb,
    "api_status_code" int4,
    "db_table" text,
    "db_operation" text,
    "db_record_id" uuid,
    "db_before" jsonb,
    "db_after" jsonb,
    "message" text,
    "source_ip" inet,
    "user_agent" text,
    "duration_ms" int4,
    "created_at" timestamptz DEFAULT now(),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."brand" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "customer_id" uuid NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "logo_url" text,
    "website_url" text,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "settings" jsonb DEFAULT '{}'::jsonb,
    "is_active" bool DEFAULT true,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    "deleted_at" timestamptz,
    "deleted_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."budget_status";
CREATE TYPE "public"."budget_status" AS ENUM ('draft', 'pending_collection', 'active', 'completed', 'cancelled');

-- Table Definition
CREATE TABLE "public"."budget" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "amount" numeric CHECK (amount > (0)::numeric),
    "amount_cents" int4,
    "currency" text NOT NULL,
    "status" "public"."budget_status" DEFAULT 'draft'::budget_status,
    "start_date" date NOT NULL,
    "end_date" date NOT NULL,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    "deleted_at" timestamptz,
    "deleted_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."budget_status";
CREATE TYPE "public"."budget_status" AS ENUM ('draft', 'pending_collection', 'active', 'completed', 'cancelled');

-- Table Definition
CREATE TABLE "public"."budget_item" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "budget_id" uuid NOT NULL,
    "customer_id" uuid,
    "invoice_item_id" uuid,
    "platform_campaign_id" uuid,
    "amount" numeric NOT NULL CHECK (amount >= (0)::numeric),
    "amount_cents" int4,
    "currency" text NOT NULL,
    "fee" numeric DEFAULT 0 CHECK (fee >= (0)::numeric),
    "fee_cents" int4 DEFAULT 0,
    "status" "public"."budget_status" DEFAULT 'pending_collection'::budget_status,
    "hidden_from_retailer" bool DEFAULT false,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."budget_participant" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "budget_id" uuid NOT NULL,
    "customer_id" uuid,
    "brand_id" uuid,
    "store_id" uuid,
    "percentage" numeric NOT NULL,
    "fixed_amount" numeric CHECK (fixed_amount >= (0)::numeric),
    "fixed_amount_cents" int4,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."service_type";
CREATE TYPE "public"."service_type" AS ENUM ('facebook_ads', 'google_ads', 'instagram_ads', 'tiktok_ads', 'website_design', 'website_maintenance', 'email_marketing', 'social_media_management', 'seo', 'content_creation', 'custom');

-- Table Definition
CREATE TABLE "public"."campaign_order" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "order_id" uuid NOT NULL,
    "service_type" "public"."service_type" NOT NULL,
    "platform_id" uuid,
    "start_date" date,
    "end_date" date,
    "total_budget" numeric,
    "total_budget_cents" int4,
    "daily_budget" numeric,
    "daily_budget_cents" int4,
    "spent_budget" numeric DEFAULT 0,
    "spent_budget_cents" int4 DEFAULT 0,
    "impressions" int8 DEFAULT 0,
    "clicks" int8 DEFAULT 0,
    "conversions" int8 DEFAULT 0,
    "settings" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."currency_conversion" (
    "id" uuid NOT NULL,
    "from_currency" text NOT NULL,
    "to_currency" text NOT NULL,
    "rate" numeric NOT NULL,
    "valid_from" timestamptz DEFAULT now(),
    "valid_until" timestamptz,
    "source" text DEFAULT 'manual'::text,
    "created_at" timestamptz DEFAULT now(),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."account_type";
CREATE TYPE "public"."account_type" AS ENUM ('retailer', 'brand', 'admin', 'platform');

-- Table Definition
CREATE TABLE "public"."customer" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "type" "public"."account_type" DEFAULT 'retailer'::account_type,
    "name" text NOT NULL,
    "description" text,
    "invoice_prefix" text,
    "default_address_id" uuid,
    "owner_id" uuid,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "settings" jsonb DEFAULT '{}'::jsonb,
    "is_active" bool DEFAULT true,
    "stripe_customer_id" text,
    "stripe_test_mode" bool DEFAULT false,
    "external_id" text,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    "deleted_at" timestamptz,
    "deleted_by" uuid,
    PRIMARY KEY ("id")
);

-- Column Comment
COMMENT ON COLUMN "public"."customer"."stripe_customer_id" IS 'Stripe customer ID for billing integration';

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."customer_event" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "user_id" uuid,
    "anonymous_id" text,
    "event_name" text NOT NULL,
    "event_data" jsonb DEFAULT '{}'::jsonb,
    "timestamp" timestamptz DEFAULT now(),
    "cio_delivery_id" text,
    "page_url" text,
    "referrer_url" text,
    "user_agent" text,
    "ip_address" inet,
    "created_at" timestamptz DEFAULT now(),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."domain_status";
CREATE TYPE "public"."domain_status" AS ENUM ('active', 'inactive', 'expired', 'transferred', 'pending');

-- Table Definition
CREATE TABLE "public"."domain" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "domain_name" text NOT NULL,
    "registrar" text,
    "status" "public"."domain_status" DEFAULT 'active'::domain_status,
    "expires_at" timestamptz,
    "ssl_expires_at" timestamptz,
    "dns_provider" text,
    "nameservers" _text,
    "is_verified" bool DEFAULT false,
    "verified_at" timestamptz,
    "health_check_enabled" bool DEFAULT true,
    "last_health_check_at" timestamptz,
    "health_status" jsonb,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."email_activity" (
    "id" uuid NOT NULL,
    "notification_id" uuid,
    "activity_type" text NOT NULL CHECK (activity_type = ANY (ARRAY['opened'::text, 'clicked'::text, 'bounced'::text, 'unsubscribed'::text, 'dropped'::text, 'deferred'::text, 'delivered'::text])),
    "timestamp" timestamptz DEFAULT now(),
    "link_url" text,
    "user_agent" text,
    "ip_address" inet,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."email_preference" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "marketing_emails" bool DEFAULT true,
    "transactional_emails" bool DEFAULT true,
    "weekly_digest" bool DEFAULT true,
    "monthly_reports" bool DEFAULT true,
    "product_updates" bool DEFAULT true,
    "segment_ids" _text,
    "attributes" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."account_type";
CREATE TYPE "public"."account_type" AS ENUM ('retailer', 'brand', 'admin', 'platform');
DROP TYPE IF EXISTS "public"."invite_status";
CREATE TYPE "public"."invite_status" AS ENUM ('pending', 'accepted', 'declined', 'expired', 'cancelled');
DROP TYPE IF EXISTS "public"."locale";
CREATE TYPE "public"."locale" AS ENUM ('en', 'es', 'fr', 'de', 'it', 'pt', 'ja', 'zh', 'ar', 'hi');

-- Table Definition
CREATE TABLE "public"."invite" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "email" text NOT NULL,
    "invited_by" uuid NOT NULL,
    "customer_id" uuid,
    "brand_id" uuid,
    "role" "public"."account_type" DEFAULT 'retailer'::account_type,
    "status" "public"."invite_status" DEFAULT 'pending'::invite_status,
    "locale" "public"."locale" DEFAULT 'en'::locale,
    "description" text,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "expires_at" timestamptz DEFAULT (now() + '7 days'::interval),
    "accepted_at" timestamptz,
    "created_at" timestamptz DEFAULT now(),
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."invoice" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "customer_id" uuid NOT NULL,
    "order_id" uuid,
    "invoice_number" text NOT NULL CHECK (invoice_number ~ '^[A-Z0-9-]+$'::text),
    "description" text,
    "status" text DEFAULT 'draft'::text CHECK (status = ANY (ARRAY['draft'::text, 'open'::text, 'paid'::text, 'uncollectible'::text, 'void'::text, 'sent'::text, 'overdue'::text, 'cancelled'::text, 'refunded'::text])),
    "due_date" date,
    "paid_date" date,
    "amount" numeric NOT NULL CHECK (amount >= (0)::numeric),
    "amount_cents" int4,
    "currency" text NOT NULL,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "stripe_invoice_id" text,
    "stripe_payment_intent_id" text,
    "stripe_status" text,
    "amount_paid" numeric DEFAULT 0,
    "amount_paid_cents" int4 DEFAULT 0,
    "amount_due" numeric,
    "amount_due_cents" int4,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    "deleted_at" timestamptz,
    "deleted_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."invoice_item" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "invoice_id" uuid NOT NULL,
    "order_item_id" uuid,
    "description" text NOT NULL,
    "quantity" numeric CHECK (quantity > (0)::numeric),
    "unit_price" numeric NOT NULL CHECK (unit_price >= (0)::numeric),
    "unit_amount_cents" int4,
    "total_amount" numeric NOT NULL CHECK (total_amount >= (0)::numeric),
    "total_amount_cents" int4,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."job" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "type" text NOT NULL,
    "name" text,
    "description" text,
    "payload" jsonb DEFAULT '{}'::jsonb,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "scheduled_at" timestamptz,
    "started_at" timestamptz,
    "completed_at" timestamptz,
    "failed_at" timestamptz,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."job_status";
CREATE TYPE "public"."job_status" AS ENUM ('pending', 'running', 'completed', 'failed', 'cancelled');

-- Table Definition
CREATE TABLE "public"."job_status_event" (
    "id" uuid NOT NULL,
    "job_id" uuid NOT NULL,
    "status" "public"."job_status" NOT NULL,
    "message" text,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."lead_status";
CREATE TYPE "public"."lead_status" AS ENUM ('new', 'contacted', 'qualified', 'proposal', 'negotiation', 'won', 'lost', 'nurture');

-- Table Definition
CREATE TABLE "public"."lead" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "lead_source_id" uuid,
    "first_name" text,
    "last_name" text,
    "email" text,
    "phone" text,
    "status" "public"."lead_status" DEFAULT 'new'::lead_status,
    "score" int4 DEFAULT 0,
    "assigned_to" uuid,
    "converted_at" timestamptz,
    "converted_by" uuid,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "tags" _text,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."lead_source_type";
CREATE TYPE "public"."lead_source_type" AS ENUM ('website', 'social_media', 'referral', 'email', 'phone', 'event', 'advertisement', 'direct', 'other');

-- Table Definition
CREATE TABLE "public"."lead_source" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "name" text NOT NULL,
    "type" "public"."lead_source_type" NOT NULL,
    "domain_id" uuid,
    "product_id" uuid,
    "service_catalog_id" uuid,
    "campaign_order_id" uuid,
    "url" text,
    "utm_source" text,
    "utm_medium" text,
    "utm_campaign" text,
    "utm_term" text,
    "utm_content" text,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "is_active" bool DEFAULT true,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."note" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "parent_note_id" uuid,
    "version" int4 DEFAULT 1,
    "resource_type" text NOT NULL,
    "resource_id" uuid NOT NULL,
    "title" text,
    "content" text NOT NULL,
    "is_internal" bool DEFAULT false,
    "is_current" bool DEFAULT true,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid NOT NULL,
    PRIMARY KEY ("id")
);

-- Column Comment
COMMENT ON COLUMN "public"."note"."resource_type" IS 'Table name of the entity this note is attached to';
COMMENT ON COLUMN "public"."note"."resource_id" IS 'UUID of the entity this note is attached to';

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."delivery_method";
CREATE TYPE "public"."delivery_method" AS ENUM ('email', 'sms', 'push', 'in_app', 'webhook');
DROP TYPE IF EXISTS "public"."priority_level";
CREATE TYPE "public"."priority_level" AS ENUM ('low', 'medium', 'high', 'urgent', 'critical');
DROP TYPE IF EXISTS "public"."notification_category";
CREATE TYPE "public"."notification_category" AS ENUM ('system', 'billing', 'campaign', 'order', 'general', 'alert');

-- Table Definition
CREATE TABLE "public"."notification" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "user_id" uuid,
    "resource_type" text NOT NULL,
    "resource_id" uuid NOT NULL,
    "delivery_method" "public"."delivery_method" NOT NULL,
    "priority" "public"."priority_level" DEFAULT 'medium'::priority_level,
    "category" "public"."notification_category" NOT NULL,
    "subject" text,
    "message" jsonb NOT NULL,
    "scheduled_at" timestamptz,
    "sent_at" timestamptz,
    "read_at" timestamptz,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "cio_campaign_id" text,
    "cio_broadcast_id" text,
    "cio_delivery_id" text,
    "cio_action_id" text,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- Column Comment
COMMENT ON COLUMN "public"."notification"."resource_type" IS 'Table name of the related resource';
COMMENT ON COLUMN "public"."notification"."resource_id" IS 'UUID of the related resource';

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."notification_state";
CREATE TYPE "public"."notification_state" AS ENUM ('scheduled', 'sent', 'delivered', 'read', 'failed');

-- Table Definition
CREATE TABLE "public"."notification_event" (
    "id" uuid NOT NULL,
    "notification_id" uuid NOT NULL,
    "state" "public"."notification_state" NOT NULL,
    "message" text,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."order_type";
CREATE TYPE "public"."order_type" AS ENUM ('campaign', 'subscription', 'service', 'product', 'custom');

-- Table Definition
CREATE TABLE "public"."order" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "customer_id" uuid NOT NULL,
    "brand_id" uuid,
    "store_id" uuid,
    "order_type" "public"."order_type" NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "total_amount" numeric,
    "total_amount_cents" int4,
    "currency" text,
    "is_draft" bool DEFAULT false,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    "deleted_at" timestamptz,
    "deleted_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."order_item" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "order_id" uuid NOT NULL,
    "product_id" uuid,
    "service_catalog_id" uuid,
    "quantity" numeric DEFAULT 1,
    "unit_price" numeric,
    "unit_price_cents" int4,
    "total_amount" numeric,
    "total_amount_cents" int4,
    "discount_amount" numeric DEFAULT 0,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."order_participant" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "order_id" uuid NOT NULL,
    "customer_id" uuid,
    "brand_id" uuid,
    "store_id" uuid,
    "role" text,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."payment_method" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "customer_id" uuid NOT NULL,
    "stripe_payment_method_id" text,
    "type" text NOT NULL CHECK (type = ANY (ARRAY['card'::text, 'bank_account'::text, 'paypal'::text, 'other'::text])),
    "last4" text,
    "brand" text,
    "exp_month" int4,
    "exp_year" int4,
    "bank_name" text,
    "is_default" bool DEFAULT false,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    "deleted_at" timestamptz,
    "deleted_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."platform" (
    "id" uuid NOT NULL,
    "name" text NOT NULL,
    "display_name" text NOT NULL,
    "base_url" text,
    "api_version" text,
    "is_active" bool DEFAULT true,
    "capabilities" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    "updated_at" timestamptz DEFAULT now(),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."artifact_type";
CREATE TYPE "public"."artifact_type" AS ENUM ('campaign', 'ad_set', 'ad', 'creative', 'audience', 'pixel');

-- Table Definition
CREATE TABLE "public"."platform_artifact" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "platform_connection_id" uuid NOT NULL,
    "platform_artifact_id" text NOT NULL,
    "type" "public"."artifact_type" NOT NULL,
    "name" text NOT NULL,
    "status" text,
    "parent_artifact_id" uuid,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."platform_campaign" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "campaign_order_id" uuid NOT NULL,
    "platform_artifact_id" uuid NOT NULL,
    "platform_id" uuid NOT NULL,
    "platform_campaign_id" text NOT NULL,
    "name" text NOT NULL,
    "status" text,
    "type" text,
    "budget" numeric CHECK (budget >= (0)::numeric),
    "budget_cents" int4,
    "currency" text,
    "start_date" date,
    "end_date" date,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."connection_status";
CREATE TYPE "public"."connection_status" AS ENUM ('pending', 'connected', 'disconnected', 'error', 'expired');

-- Table Definition
CREATE TABLE "public"."platform_connection" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "platform_id" uuid NOT NULL,
    "customer_id" uuid,
    "brand_id" uuid,
    "store_id" uuid,
    "status" "public"."connection_status" DEFAULT 'pending'::connection_status,
    "platform_account_id" text,
    "platform_account_name" text,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "connected_at" timestamptz,
    "disconnected_at" timestamptz,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    "deleted_at" timestamptz,
    "deleted_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."price_type";
CREATE TYPE "public"."price_type" AS ENUM ('one_time', 'recurring', 'usage_based', 'tiered');
DROP TYPE IF EXISTS "public"."price_interval";
CREATE TYPE "public"."price_interval" AS ENUM ('day', 'week', 'month', 'quarter', 'year');

-- Table Definition
CREATE TABLE "public"."price" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "product_id" uuid NOT NULL,
    "currency" text NOT NULL,
    "unit_amount" numeric CHECK (unit_amount > (0)::numeric),
    "unit_amount_cents" int4,
    "unit_amount_decimal" text,
    "type" "public"."price_type" NOT NULL DEFAULT 'one_time'::price_type,
    "interval" "public"."price_interval",
    "interval_count" int4 DEFAULT 1 CHECK (interval_count > 0),
    "nickname" text,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "is_active" bool DEFAULT true,
    "stripe_price_id" text,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    "deleted_at" timestamptz,
    "deleted_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."product" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "name" text NOT NULL,
    "slug" text NOT NULL,
    "description" text,
    "sku" text,
    "barcode" text,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "attributes" jsonb DEFAULT '{}'::jsonb,
    "is_active" bool DEFAULT true,
    "stripe_product_id" text,
    "default_price_id" uuid,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    "deleted_at" timestamptz,
    "deleted_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."rate_limit" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "user_id" uuid,
    "endpoint" text NOT NULL,
    "requests" int4 DEFAULT 0,
    "window_start" timestamptz DEFAULT now(),
    "created_at" timestamptz DEFAULT now(),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."service_type";
CREATE TYPE "public"."service_type" AS ENUM ('facebook_ads', 'google_ads', 'instagram_ads', 'tiktok_ads', 'website_design', 'website_maintenance', 'email_marketing', 'social_media_management', 'seo', 'content_creation', 'custom');
DROP TYPE IF EXISTS "public"."price_interval";
CREATE TYPE "public"."price_interval" AS ENUM ('day', 'week', 'month', 'quarter', 'year');

-- Table Definition
CREATE TABLE "public"."service_catalog" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "service_type" "public"."service_type" NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "base_price" numeric,
    "currency" text,
    "billing_interval" "public"."price_interval",
    "features" jsonb DEFAULT '{}'::jsonb,
    "prerequisites" _text,
    "is_active" bool DEFAULT true,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."actor_type";
CREATE TYPE "public"."actor_type" AS ENUM ('user', 'system', 'api', 'webhook', 'scheduled');

-- Table Definition
CREATE TABLE "public"."status_event" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "resource_type" text NOT NULL,
    "resource_id" uuid NOT NULL,
    "status" text NOT NULL,
    "previous_status" text,
    "reason" text,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "actor_id" uuid,
    "actor_type" "public"."actor_type" DEFAULT 'user'::actor_type,
    "created_at" timestamptz DEFAULT now(),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."store_type";
CREATE TYPE "public"."store_type" AS ENUM ('showroom', 'retail', 'warehouse', 'popup', 'online');

-- Table Definition
CREATE TABLE "public"."store" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "customer_id" uuid NOT NULL,
    "name" text NOT NULL,
    "type" "public"."store_type" DEFAULT 'showroom'::store_type,
    "address_id" uuid,
    "website_url" text,
    "phone" text,
    "email" text,
    "operating_hours" jsonb,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "settings" jsonb DEFAULT '{}'::jsonb,
    "is_active" bool DEFAULT true,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    "deleted_at" timestamptz,
    "deleted_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."price_interval";
CREATE TYPE "public"."price_interval" AS ENUM ('day', 'week', 'month', 'quarter', 'year');

-- Table Definition
CREATE TABLE "public"."subscription_order" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "order_id" uuid NOT NULL,
    "service_catalog_id" uuid NOT NULL,
    "start_date" date NOT NULL,
    "end_date" date,
    "next_billing_date" date,
    "billing_interval" "public"."price_interval" NOT NULL,
    "amount" numeric,
    "amount_cents" int4,
    "stripe_subscription_id" text,
    "auto_renew" bool DEFAULT true,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."tenant" (
    "id" uuid NOT NULL,
    "name" text NOT NULL,
    "slug" text NOT NULL,
    "settings" jsonb DEFAULT '{}'::jsonb,
    "features" jsonb DEFAULT '{}'::jsonb,
    "is_active" bool DEFAULT true,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    "deleted_at" timestamptz,
    "deleted_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."url_type";
CREATE TYPE "public"."url_type" AS ENUM ('landing_page', 'tracking', 'redirect', 'webhook', 'api');

-- Table Definition
CREATE TABLE "public"."url" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "domain_id" uuid,
    "customer_id" uuid,
    "brand_id" uuid,
    "store_id" uuid,
    "order_id" uuid,
    "path" text,
    "full_url" text NOT NULL,
    "type" "public"."url_type" DEFAULT 'landing_page'::url_type,
    "is_primary" bool DEFAULT false,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    "deleted_at" timestamptz,
    "deleted_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."locale";
CREATE TYPE "public"."locale" AS ENUM ('en', 'es', 'fr', 'de', 'it', 'pt', 'ja', 'zh', 'ar', 'hi');

-- Table Definition
CREATE TABLE "public"."user" (
    "id" uuid NOT NULL,
    "email" text NOT NULL,
    "locale" "public"."locale" DEFAULT 'en'::locale,
    "preferred_locales" _locale DEFAULT ARRAY['en'::locale],
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "is_active" bool DEFAULT true,
    "cio_id" text,
    "cio_unsubscribed" bool DEFAULT false,
    "cio_email_bounced" bool DEFAULT false,
    "created_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    "deleted_at" timestamptz,
    "deleted_by" uuid,
    "created_timestamp" int8,
    PRIMARY KEY ("id")
);

-- Column Comment
COMMENT ON COLUMN "public"."user"."cio_id" IS 'Customer.io customer ID for email marketing';

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."user_login" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "tenant_id" uuid,
    "login_at" timestamptz DEFAULT now(),
    "login_ip" inet,
    "user_agent" text,
    "device_info" jsonb,
    "location" jsonb,
    "success" bool DEFAULT true,
    "failure_reason" text,
    "session_id" text,
    "logout_at" timestamptz,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."account_type";
CREATE TYPE "public"."account_type" AS ENUM ('retailer', 'brand', 'admin', 'platform');

-- Table Definition
CREATE TABLE "public"."user_tenant" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "role" "public"."account_type" NOT NULL DEFAULT 'retailer'::account_type,
    "is_primary" bool DEFAULT false,
    "joined_at" timestamptz DEFAULT now(),
    "created_by" uuid,
    "updated_at" timestamptz DEFAULT now(),
    "updated_by" uuid,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."webhook_event" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "service" text NOT NULL CHECK (service = ANY (ARRAY['stripe'::text, 'customerio'::text, 'facebook'::text, 'google'::text, 'other'::text])),
    "event_id" text,
    "event_type" text NOT NULL,
    "payload" jsonb NOT NULL,
    "headers" jsonb DEFAULT '{}'::jsonb,
    "processed_at" timestamptz,
    "error_message" text,
    "retry_count" int4 DEFAULT 0,
    "created_at" timestamptz DEFAULT now(),
    PRIMARY KEY ("id")
);

ALTER TABLE "public"."address" ADD FOREIGN KEY ("deleted_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."address" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."address" ADD FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id");
ALTER TABLE "public"."address" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."address" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."api_credential" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."api_credential" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."api_credential" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."api_credential" ADD FOREIGN KEY ("platform_connection_id") REFERENCES "public"."platform_connection"("id");
ALTER TABLE "public"."audit_log" ADD FOREIGN KEY ("actor_id") REFERENCES "public"."user"("id");
ALTER TABLE "public"."audit_log" ADD FOREIGN KEY ("job_id") REFERENCES "public"."job"("id");
ALTER TABLE "public"."audit_log" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");


-- Comments
COMMENT ON TABLE "public"."audit_log" IS 'Comprehensive audit trail with actor tracking';
ALTER TABLE "public"."brand" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."brand" ADD FOREIGN KEY ("deleted_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."brand" ADD FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id");
ALTER TABLE "public"."brand" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."brand" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");


-- Indices
CREATE UNIQUE INDEX brand_tenant_id_name_key ON public.brand USING btree (tenant_id, name);
ALTER TABLE "public"."budget" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."budget" ADD FOREIGN KEY ("deleted_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."budget" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."budget" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."budget_item" ADD FOREIGN KEY ("budget_id") REFERENCES "public"."budget"("id");
ALTER TABLE "public"."budget_item" ADD FOREIGN KEY ("platform_campaign_id") REFERENCES "public"."platform_campaign"("id");
ALTER TABLE "public"."budget_item" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."budget_item" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."budget_item" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."budget_item" ADD FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id");
ALTER TABLE "public"."budget_item" ADD FOREIGN KEY ("invoice_item_id") REFERENCES "public"."invoice_item"("id");
ALTER TABLE "public"."budget_participant" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."budget_participant" ADD FOREIGN KEY ("budget_id") REFERENCES "public"."budget"("id");
ALTER TABLE "public"."budget_participant" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."budget_participant" ADD FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id");
ALTER TABLE "public"."budget_participant" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."budget_participant" ADD FOREIGN KEY ("brand_id") REFERENCES "public"."brand"("id");
ALTER TABLE "public"."budget_participant" ADD FOREIGN KEY ("store_id") REFERENCES "public"."store"("id");
ALTER TABLE "public"."campaign_order" ADD FOREIGN KEY ("platform_id") REFERENCES "public"."platform"("id");
ALTER TABLE "public"."campaign_order" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."campaign_order" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."campaign_order" ADD FOREIGN KEY ("order_id") REFERENCES "public"."order"("id");
ALTER TABLE "public"."campaign_order" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");


-- Comments
COMMENT ON TABLE "public"."campaign_order" IS 'Marketing campaign specific orders';


-- Indices
CREATE UNIQUE INDEX currency_conversion_from_currency_to_currency_valid_from_key ON public.currency_conversion USING btree (from_currency, to_currency, valid_from);
ALTER TABLE "public"."customer" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."customer" ADD FOREIGN KEY ("default_address_id") REFERENCES "public"."address"("id");
ALTER TABLE "public"."customer" ADD FOREIGN KEY ("deleted_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."customer" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."customer" ADD FOREIGN KEY ("owner_id") REFERENCES "public"."user"("id");
ALTER TABLE "public"."customer" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");


-- Comments
COMMENT ON TABLE "public"."customer" IS 'Customers with Stripe integration support';


-- Indices
CREATE UNIQUE INDEX customer_stripe_customer_id_key ON public.customer USING btree (stripe_customer_id);
CREATE UNIQUE INDEX customer_external_id_unique ON public.customer USING btree (external_id);
ALTER TABLE "public"."customer_event" ADD FOREIGN KEY ("user_id") REFERENCES "public"."user"("id");
ALTER TABLE "public"."customer_event" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."domain" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."domain" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."domain" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");


-- Comments
COMMENT ON TABLE "public"."domain" IS 'Managed domains with health monitoring';


-- Indices
CREATE UNIQUE INDEX domain_domain_name_key ON public.domain USING btree (domain_name);
ALTER TABLE "public"."email_activity" ADD FOREIGN KEY ("notification_id") REFERENCES "public"."notification"("id");
ALTER TABLE "public"."email_preference" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."email_preference" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."email_preference" ADD FOREIGN KEY ("user_id") REFERENCES "public"."user"("id");
ALTER TABLE "public"."email_preference" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");


-- Indices
CREATE UNIQUE INDEX email_preference_user_id_tenant_id_key ON public.email_preference USING btree (user_id, tenant_id);
ALTER TABLE "public"."invite" ADD FOREIGN KEY ("invited_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."invite" ADD FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id");
ALTER TABLE "public"."invite" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."invite" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."invite" ADD FOREIGN KEY ("brand_id") REFERENCES "public"."brand"("id");
ALTER TABLE "public"."invoice" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."invoice" ADD FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id");
ALTER TABLE "public"."invoice" ADD FOREIGN KEY ("order_id") REFERENCES "public"."order"("id");
ALTER TABLE "public"."invoice" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."invoice" ADD FOREIGN KEY ("deleted_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."invoice" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");


-- Indices
CREATE UNIQUE INDEX invoice_stripe_invoice_id_key ON public.invoice USING btree (stripe_invoice_id);
CREATE UNIQUE INDEX invoice_tenant_id_invoice_number_key ON public.invoice USING btree (tenant_id, invoice_number);
ALTER TABLE "public"."invoice_item" ADD FOREIGN KEY ("invoice_id") REFERENCES "public"."invoice"("id");
ALTER TABLE "public"."invoice_item" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."invoice_item" ADD FOREIGN KEY ("order_item_id") REFERENCES "public"."order_item"("id");
ALTER TABLE "public"."invoice_item" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."invoice_item" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."job" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."job" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."job_status_event" ADD FOREIGN KEY ("job_id") REFERENCES "public"."job"("id");
ALTER TABLE "public"."lead" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."lead" ADD FOREIGN KEY ("lead_source_id") REFERENCES "public"."lead_source"("id");
ALTER TABLE "public"."lead" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."lead" ADD FOREIGN KEY ("converted_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."lead" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."lead" ADD FOREIGN KEY ("assigned_to") REFERENCES "public"."user"("id");


-- Comments
COMMENT ON TABLE "public"."lead" IS 'CRM lead tracking with source attribution';
ALTER TABLE "public"."lead_source" ADD FOREIGN KEY ("campaign_order_id") REFERENCES "public"."campaign_order"("id");
ALTER TABLE "public"."lead_source" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."lead_source" ADD FOREIGN KEY ("domain_id") REFERENCES "public"."domain"("id");
ALTER TABLE "public"."lead_source" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."lead_source" ADD FOREIGN KEY ("service_catalog_id") REFERENCES "public"."service_catalog"("id");
ALTER TABLE "public"."lead_source" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."lead_source" ADD FOREIGN KEY ("product_id") REFERENCES "public"."product"("id");


-- Comments
COMMENT ON TABLE "public"."lead_source" IS 'Sources where leads originate from';
ALTER TABLE "public"."note" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."note" ADD FOREIGN KEY ("parent_note_id") REFERENCES "public"."note"("id");
ALTER TABLE "public"."note" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");


-- Comments
COMMENT ON TABLE "public"."note" IS 'Versioned notes that can be attached to any entity';
ALTER TABLE "public"."notification" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."notification" ADD FOREIGN KEY ("user_id") REFERENCES "public"."user"("id");
ALTER TABLE "public"."notification" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."notification" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");


-- Comments
COMMENT ON TABLE "public"."notification" IS 'Generic notifications using resource_type/resource_id pattern';
ALTER TABLE "public"."notification_event" ADD FOREIGN KEY ("notification_id") REFERENCES "public"."notification"("id");
ALTER TABLE "public"."order" ADD FOREIGN KEY ("deleted_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."order" ADD FOREIGN KEY ("brand_id") REFERENCES "public"."brand"("id");
ALTER TABLE "public"."order" ADD FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id");
ALTER TABLE "public"."order" ADD FOREIGN KEY ("store_id") REFERENCES "public"."store"("id");
ALTER TABLE "public"."order" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."order" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."order" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");


-- Comments
COMMENT ON TABLE "public"."order" IS 'Generic orders that can be campaigns, subscriptions, or services';
ALTER TABLE "public"."order_item" ADD FOREIGN KEY ("order_id") REFERENCES "public"."order"("id");
ALTER TABLE "public"."order_item" ADD FOREIGN KEY ("service_catalog_id") REFERENCES "public"."service_catalog"("id");
ALTER TABLE "public"."order_item" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."order_item" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."order_item" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."order_item" ADD FOREIGN KEY ("product_id") REFERENCES "public"."product"("id");
ALTER TABLE "public"."order_participant" ADD FOREIGN KEY ("brand_id") REFERENCES "public"."brand"("id");
ALTER TABLE "public"."order_participant" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."order_participant" ADD FOREIGN KEY ("order_id") REFERENCES "public"."order"("id");
ALTER TABLE "public"."order_participant" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."order_participant" ADD FOREIGN KEY ("store_id") REFERENCES "public"."store"("id");
ALTER TABLE "public"."order_participant" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."order_participant" ADD FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id");


-- Indices
CREATE UNIQUE INDEX order_participant_order_id_customer_id_brand_id_store_id_key ON public.order_participant USING btree (order_id, customer_id, brand_id, store_id);
ALTER TABLE "public"."payment_method" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."payment_method" ADD FOREIGN KEY ("deleted_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."payment_method" ADD FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id");
ALTER TABLE "public"."payment_method" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."payment_method" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");


-- Indices
CREATE UNIQUE INDEX payment_method_stripe_payment_method_id_key ON public.payment_method USING btree (stripe_payment_method_id);


-- Indices
CREATE UNIQUE INDEX platform_name_key ON public.platform USING btree (name);
ALTER TABLE "public"."platform_artifact" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."platform_artifact" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."platform_artifact" ADD FOREIGN KEY ("parent_artifact_id") REFERENCES "public"."platform_artifact"("id");
ALTER TABLE "public"."platform_artifact" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."platform_artifact" ADD FOREIGN KEY ("platform_connection_id") REFERENCES "public"."platform_connection"("id");


-- Indices
CREATE UNIQUE INDEX platform_artifact_platform_connection_id_platform_artifact__key ON public.platform_artifact USING btree (platform_connection_id, platform_artifact_id);
ALTER TABLE "public"."platform_campaign" ADD FOREIGN KEY ("platform_id") REFERENCES "public"."platform"("id");
ALTER TABLE "public"."platform_campaign" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."platform_campaign" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."platform_campaign" ADD FOREIGN KEY ("platform_artifact_id") REFERENCES "public"."platform_artifact"("id");
ALTER TABLE "public"."platform_campaign" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."platform_campaign" ADD FOREIGN KEY ("campaign_order_id") REFERENCES "public"."campaign_order"("id");


-- Indices
CREATE UNIQUE INDEX platform_campaign_platform_artifact_id_platform_campaign_id_key ON public.platform_campaign USING btree (platform_artifact_id, platform_campaign_id);
ALTER TABLE "public"."platform_connection" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."platform_connection" ADD FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id");
ALTER TABLE "public"."platform_connection" ADD FOREIGN KEY ("deleted_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."platform_connection" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."platform_connection" ADD FOREIGN KEY ("brand_id") REFERENCES "public"."brand"("id");
ALTER TABLE "public"."platform_connection" ADD FOREIGN KEY ("platform_id") REFERENCES "public"."platform"("id");
ALTER TABLE "public"."platform_connection" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."platform_connection" ADD FOREIGN KEY ("store_id") REFERENCES "public"."store"("id");
ALTER TABLE "public"."price" ADD FOREIGN KEY ("product_id") REFERENCES "public"."product"("id");
ALTER TABLE "public"."price" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."price" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."price" ADD FOREIGN KEY ("deleted_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."price" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");


-- Indices
CREATE UNIQUE INDEX price_stripe_price_id_key ON public.price USING btree (stripe_price_id);
ALTER TABLE "public"."product" ADD FOREIGN KEY ("deleted_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."product" ADD FOREIGN KEY ("default_price_id") REFERENCES "public"."price"("id");
ALTER TABLE "public"."product" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."product" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."product" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");


-- Indices
CREATE UNIQUE INDEX product_stripe_product_id_key ON public.product USING btree (stripe_product_id);
CREATE UNIQUE INDEX product_tenant_id_slug_key ON public.product USING btree (tenant_id, slug);
CREATE UNIQUE INDEX product_tenant_id_sku_key ON public.product USING btree (tenant_id, sku);
ALTER TABLE "public"."rate_limit" ADD FOREIGN KEY ("user_id") REFERENCES "public"."user"("id");
ALTER TABLE "public"."rate_limit" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");


-- Indices
CREATE UNIQUE INDEX rate_limit_tenant_id_user_id_endpoint_window_start_key ON public.rate_limit USING btree (tenant_id, user_id, endpoint, window_start);
ALTER TABLE "public"."service_catalog" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."service_catalog" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."service_catalog" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."status_event" ADD FOREIGN KEY ("actor_id") REFERENCES "public"."user"("id");
ALTER TABLE "public"."status_event" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");


-- Comments
COMMENT ON TABLE "public"."status_event" IS 'Generic status tracking for any entity';
ALTER TABLE "public"."store" ADD FOREIGN KEY ("address_id") REFERENCES "public"."address"("id");
ALTER TABLE "public"."store" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."store" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."store" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."store" ADD FOREIGN KEY ("deleted_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."store" ADD FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id");


-- Comments
COMMENT ON TABLE "public"."store" IS 'Physical or virtual stores (formerly retailers)';


-- Indices
CREATE UNIQUE INDEX store_tenant_id_name_key ON public.store USING btree (tenant_id, name);
ALTER TABLE "public"."subscription_order" ADD FOREIGN KEY ("order_id") REFERENCES "public"."order"("id");
ALTER TABLE "public"."subscription_order" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."subscription_order" ADD FOREIGN KEY ("service_catalog_id") REFERENCES "public"."service_catalog"("id");
ALTER TABLE "public"."subscription_order" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."subscription_order" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");


-- Comments
COMMENT ON TABLE "public"."subscription_order" IS 'Recurring service subscriptions';


-- Indices
CREATE UNIQUE INDEX subscription_order_stripe_subscription_id_key ON public.subscription_order USING btree (stripe_subscription_id);
ALTER TABLE "public"."tenant" ADD FOREIGN KEY ("deleted_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."tenant" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."tenant" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");


-- Comments
COMMENT ON TABLE "public"."tenant" IS 'Multi-tenant organizations using the platform';


-- Indices
CREATE UNIQUE INDEX tenant_slug_key ON public.tenant USING btree (slug);
ALTER TABLE "public"."url" ADD FOREIGN KEY ("deleted_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."url" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."url" ADD FOREIGN KEY ("domain_id") REFERENCES "public"."domain"("id");
ALTER TABLE "public"."url" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."url" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."url" ADD FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id");
ALTER TABLE "public"."url" ADD FOREIGN KEY ("brand_id") REFERENCES "public"."brand"("id");
ALTER TABLE "public"."url" ADD FOREIGN KEY ("order_id") REFERENCES "public"."order"("id");
ALTER TABLE "public"."url" ADD FOREIGN KEY ("store_id") REFERENCES "public"."store"("id");
ALTER TABLE "public"."user" ADD FOREIGN KEY ("deleted_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."user" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."user" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");


-- Comments
COMMENT ON TABLE "public"."user" IS 'Users with Customer.io integration support';


-- Indices
CREATE UNIQUE INDEX user_email_key ON public."user" USING btree (email);
CREATE UNIQUE INDEX user_cio_id_key ON public."user" USING btree (cio_id);
ALTER TABLE "public"."user_login" ADD FOREIGN KEY ("user_id") REFERENCES "public"."user"("id");
ALTER TABLE "public"."user_login" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");


-- Comments
COMMENT ON TABLE "public"."user_login" IS 'Track user login history for security and analytics';
ALTER TABLE "public"."user_tenant" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."user_tenant" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");
ALTER TABLE "public"."user_tenant" ADD FOREIGN KEY ("created_by") REFERENCES "public"."user"("id");
ALTER TABLE "public"."user_tenant" ADD FOREIGN KEY ("user_id") REFERENCES "public"."user"("id");


-- Indices
CREATE UNIQUE INDEX user_tenant_user_id_tenant_id_key ON public.user_tenant USING btree (user_id, tenant_id);
ALTER TABLE "public"."webhook_event" ADD FOREIGN KEY ("tenant_id") REFERENCES "public"."tenant"("id");


-- Indices
CREATE UNIQUE INDEX webhook_event_event_id_key ON public.webhook_event USING btree (event_id);
