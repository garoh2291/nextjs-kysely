# Zulal Database: Multi-Tenant Retail Marketplace Platform

## Table of Contents

1. [Introduction](#1-introduction)
2. [Multi-Tenancy Architecture](#2-multi-tenancy-architecture)
3. [Core Data Model](#3-core-data-model)
4. [Security Model](#4-security-model)
5. [User Management & Authentication](#5-user-management--authentication)
6. [Customer Relationship Management](#6-customer-relationship-management)
7. [Product & Service Catalog](#7-product--service-catalog)
8. [Order Management](#8-order-management)
9. [Marketing Campaign Management](#9-marketing-campaign-management)
10. [Financial Management](#10-financial-management)
11. [External Integrations](#11-external-integrations)
12. [System Administration](#12-system-administration)
13. [Data Patterns & Best Practices](#13-data-patterns--best-practices)
14. [Performance Considerations](#14-performance-considerations)
15. [Example Queries](#15-example-queries)
16. [Appendix: Table Reference](#16-appendix-table-reference)

## 1. Introduction

The Zulal database is a comprehensive, multi-tenant retail marketplace platform designed to support complex business relationships between brands, retailers, and service providers. It enables:

- Multi-tenant data isolation using PostgreSQL Row-Level Security (RLS)
- Marketing campaign management across multiple platforms
- Financial tracking with budgets, invoices, and payments
- Customer relationship management
- Product and service catalog management
- External integrations with platforms like Stripe and Customer.io

The database is designed for scalability, security, and flexibility to accommodate various retail business models within a single platform.

### Key Features

- **Secure Multi-Tenancy**: Complete data isolation between tenants
- **Comprehensive Audit System**: Track all changes with detailed audit logs
- **Flexible Permissions**: Granular, role-based access control
- **Integration Support**: Built-in connections to payment, marketing, and notification platforms
- **Extensible Data Model**: JSON fields for metadata allowing customization without schema changes

### Technical Highlights

- Native PostgreSQL with Row-Level Security (RLS)
- UUID primary keys for distributed systems
- Polymorphic relationships for flexible data modeling
- JSONB fields for extensible metadata
- Time-based versioning and soft deletion
- Optimized indexes for common query patterns

## 2. Multi-Tenancy Architecture

The database implements a robust multi-tenant architecture where each tenant's data is logically separated using PostgreSQL's Row-Level Security (RLS). This approach provides several advantages:

- Single database instance serving multiple tenants
- Strong data isolation without separate schemas or databases
- Simplified maintenance and upgrades
- Efficient resource utilization

### Tenant Isolation

The foundation of multi-tenancy is the `tenant` table, which defines each organization using the platform:

```sql
CREATE TABLE public.tenant (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  settings jsonb DEFAULT '{}'::jsonb,
  features jsonb DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  updated_at timestamp with time zone DEFAULT now(),
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid
);
```

Most tables in the database include a `tenant_id` column that links records to a specific tenant. Row-Level Security policies are applied to these tables to ensure that users can only access data belonging to their tenant:

```sql
ALTER TABLE public.customer ENABLE ROW LEVEL SECURITY;

CREATE POLICY customer_tenant_isolation ON public.customer
  FOR ALL USING (tenant_id = current_setting('app.current_tenant_id', true)::uuid);
```

### Session Context Management

To implement tenant isolation, the database uses session context variables to identify the current user and tenant:

```sql
-- Set the context at the beginning of each session
SELECT public.set_session_context('tenant-uuid', 'user-uuid');

-- Helper functions to retrieve the current context
CREATE FUNCTION public.current_tenant_id() RETURNS uuid AS $$
BEGIN
    RETURN current_setting('app.current_tenant_id', true)::uuid;
EXCEPTION
    WHEN OTHERS THEN RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE FUNCTION public.current_user_id() RETURNS uuid AS $$
BEGIN
    RETURN current_setting('app.current_user_id', true)::uuid;
EXCEPTION
    WHEN OTHERS THEN RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;
```

### Cross-Tenant Access

While most data is tenant-specific, certain entities like `user` operate across tenants. The relationship between users and tenants is managed through the `user_tenant` table, which allows a single user to belong to multiple tenants with different roles.

## 3. Core Data Model

The data model is structured around several core entities that form the foundation of the platform:

### Key Entity Relationships

![Entity Relationship Diagram]

#### Primary Entities:

- **Tenant**: The top-level organization entity
- **User**: Individual accounts that can access the platform
- **Customer**: Organizations that use the platform, scoped to a tenant
- **Brand**: Product brands managed by customers
- **Store**: Physical or virtual retail locations
- **Product**: Items that can be sold or used in services
- **Order**: Generic order entity with specializations for different business types
- **Campaign**: Marketing activities across various platforms
- **Budget**: Financial allocations for campaigns and other activities

### Tenant and User Structure

The platform separates the concept of users (accounts that can log in) from customers (business entities that use the platform). A single user can belong to multiple tenants with different roles, allowing for flexible cross-tenant operations.

Key relationships:
- A user can belong to multiple tenants (via user_tenant)
- A tenant contains multiple customers
- A customer is owned by a single tenant
- A customer can have multiple brands and stores

### Data Storage Patterns

The database employs several storage patterns for flexibility:

1. **JSONB for Metadata**: Most tables include a `metadata` field that stores additional attributes without requiring schema changes:

```sql
CREATE TABLE public.customer (
  -- other fields...
  metadata jsonb DEFAULT '{}'::jsonb,
  -- more fields...
);
```

2. **Soft Deletion**: Instead of physically removing records, most tables include `deleted_at` and `deleted_by` fields to mark records as deleted while preserving their data.

3. **Audit Fields**: Every table includes standard audit fields (`created_at`, `created_by`, `updated_at`, `updated_by`) to track changes.

4. **Polymorphic Relationships**: Used for generic relationships like notes, status events, and notifications:

```sql
CREATE TABLE public.note (
  -- other fields...
  resource_type text NOT NULL,  -- Table name
  resource_id uuid NOT NULL,    -- Primary key
  -- more fields...
);
```

## 4. Security Model

The security model is designed around Row-Level Security (RLS) combined with a flexible permission system.

### Row-Level Security (RLS)

RLS policies are applied to all tenant-scoped tables to ensure data isolation:

```sql
-- Enable RLS
ALTER TABLE public.customer ENABLE ROW LEVEL SECURITY;

-- Create isolation policy
CREATE POLICY customer_tenant_isolation ON public.customer
  FOR ALL USING (tenant_id = current_setting('app.current_tenant_id', true)::uuid);
```

These policies are automatically enforced by PostgreSQL for all queries, preventing access to data from other tenants.

### Permission System

The permission system uses three main tables:

1. **Permission Groups**: Collections of related permissions
2. **Permissions**: Individual access rules for specific resources
3. **Authorization**: Links users to permissions or permission groups

```sql
CREATE TABLE public.permission (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  permission_group_id uuid REFERENCES public.permission_group(id),
  scope permission_scope NOT NULL DEFAULT 'read',
  resource_type text NOT NULL,
  resource_id uuid NOT NULL,
  conditions jsonb DEFAULT '{}'::jsonb,
  -- audit fields...
);
```

This allows for granular access control within a tenant, defining which users can access specific resources and what actions they can perform.

### Audit Logging

All significant actions are recorded in the audit log:

```sql
CREATE TABLE public.audit_log (
  id uuid PRIMARY KEY,
  tenant_id uuid REFERENCES public.tenant(id),
  correlation_id uuid,
  event_type text NOT NULL,
  actor_id uuid REFERENCES public.user(id),
  actor_type actor_type DEFAULT 'user',
  -- additional fields for tracking DB operations, API calls, etc.
  -- ...
  created_at timestamp with time zone DEFAULT now()
);
```

The audit log captures database operations, API calls, user actions, and system events, providing a comprehensive trail for compliance and troubleshooting.

## 5. User Management & Authentication

The user management system handles authentication, profile management, and tenant relationships.

### User Entity

The `user` table is tenant-independent, allowing accounts to exist across multiple tenants:

```sql
CREATE TABLE public.user (
  id uuid PRIMARY KEY,
  email email_domain UNIQUE,
  locale locale DEFAULT 'en',
  preferred_locales locale[] DEFAULT ARRAY['en']::locale[],
  metadata jsonb DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  -- Customer.io integration
  cio_id text UNIQUE,
  cio_unsubscribed boolean DEFAULT false,
  cio_email_bounced boolean DEFAULT false,
  -- Timestamps
  created_timestamp bigint,
  created_at timestamp with time zone DEFAULT now(),
  -- other audit fields...
);
```

### User-Tenant Relationship

Users are associated with tenants through the `user_tenant` table, which defines their role within each tenant:

```sql
CREATE TABLE public.user_tenant (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES public.user(id),
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  role account_type NOT NULL DEFAULT 'retailer',
  is_primary boolean DEFAULT false,
  joined_at timestamp with time zone DEFAULT now(),
  -- audit fields...
  UNIQUE(user_id, tenant_id)
);
```

This design allows:
- A user to belong to multiple tenants
- Different roles in different tenants
- Designating a primary tenant for the user

### Login Tracking

User authentication events are tracked for security and analytics:

```sql
CREATE TABLE public.user_login (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES public.user(id),
  tenant_id uuid REFERENCES public.tenant(id),
  login_at timestamp with time zone DEFAULT now(),
  login_ip inet,
  user_agent text,
  device_info jsonb,
  location jsonb,
  success boolean DEFAULT true,
  failure_reason text,
  session_id text,
  logout_at timestamp with time zone
);
```

### Email Preferences

User communication preferences are managed through the `email_preference` table, which integrates with Customer.io for marketing and transactional emails:

```sql
CREATE TABLE public.email_preference (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES public.user(id),
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  marketing_emails boolean DEFAULT true,
  transactional_emails boolean DEFAULT true,
  weekly_digest boolean DEFAULT true,
  monthly_reports boolean DEFAULT true,
  product_updates boolean DEFAULT true,
  segment_ids text[],
  attributes jsonb DEFAULT '{}'::jsonb,
  -- audit fields...
  UNIQUE(user_id, tenant_id)
);
```

## 6. Customer Relationship Management

The CRM components handle customer data, addressing, and lead management.

### Customer Entity

Each tenant has multiple customers, which represent the businesses using the platform:

```sql
CREATE TABLE public.customer (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  type account_type DEFAULT 'retailer',
  name text NOT NULL,
  description text,
  invoice_prefix text,
  default_address_id uuid,
  owner_id uuid REFERENCES public.user(id),
  metadata jsonb DEFAULT '{}'::jsonb,
  settings jsonb DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  -- Stripe integration
  stripe_customer_id text UNIQUE,
  stripe_test_mode boolean DEFAULT false,
  external_id text,
  -- audit fields...
);
```

Customers can be retailers, brands, or other business types defined by the `account_type` enum.

### Address Management

Addresses are linked to customers and can be of different types:

```sql
CREATE TABLE public.address (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  customer_id uuid REFERENCES public.customer(id),
  type address_type DEFAULT 'other',
  category address_category DEFAULT 'other',
  line1 text NOT NULL,
  line2 text,
  city text NOT NULL,
  state text,
  postal_code text,
  country text NOT NULL,
  country_code char(2),
  phone text,
  lat double precision,
  long double precision,
  normalized_postal_code text,
  address_hash text,
  metadata jsonb DEFAULT '{}'::jsonb,
  is_primary boolean DEFAULT false,
  -- audit fields...
);
```

The `address_hash` field helps identify duplicate addresses, while the `type` and `category` fields distinguish between different address purposes (billing, shipping, etc.) and locations (home, office, etc.).

### Lead Management

The platform includes a lead tracking system for marketing and sales:

```sql
CREATE TABLE public.lead (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  lead_source_id uuid REFERENCES public.lead_source(id),
  first_name text,
  last_name text,
  email text,
  phone text,
  status lead_status DEFAULT 'new',
  score integer DEFAULT 0,
  assigned_to uuid REFERENCES public.user(id),
  converted_at timestamp with time zone,
  converted_by uuid REFERENCES public.user(id),
  metadata jsonb DEFAULT '{}'::jsonb,
  tags text[],
  -- audit fields...
);

CREATE TABLE public.lead_source (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  name text NOT NULL,
  type lead_source_type NOT NULL,
  -- various reference fields for tracking origin...
  url text,
  utm_source text,
  utm_medium text,
  utm_campaign text,
  utm_term text,
  utm_content text,
  metadata jsonb DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  -- audit fields...
);
```

This system tracks lead sources (campaigns, websites, etc.), status progression, and conversion metrics.

### Notes System

A versioned notes system allows attaching comments to any entity:

```sql
CREATE TABLE public.note (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  parent_note_id uuid REFERENCES public.note(id),
  version integer DEFAULT 1,
  resource_type text NOT NULL,
  resource_id uuid NOT NULL,
  title text,
  content text NOT NULL,
  is_internal boolean DEFAULT false,
  is_current boolean DEFAULT true,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid NOT NULL REFERENCES public.user(id)
);
```

The polymorphic design (`resource_type` and `resource_id`) allows notes to be attached to any entity in the system, while versioning tracks edits over time.

## 7. Product & Service Catalog

The platform manages both products (physical goods) and services (marketing, design, etc.).

### Product Management

Products are defined in the `product` table:

```sql
CREATE TABLE public.product (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  name text NOT NULL,
  slug text NOT NULL,
  description text,
  sku text,
  barcode text,
  metadata jsonb DEFAULT '{}'::jsonb,
  attributes jsonb DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  -- Stripe integration
  stripe_product_id text UNIQUE,
  default_price_id uuid,
  -- audit fields...
  UNIQUE(tenant_id, slug),
  UNIQUE(tenant_id, sku)
);
```

Products can have multiple prices with different currencies and pricing models:

```sql
CREATE TABLE public.price (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  product_id uuid NOT NULL REFERENCES public.product(id),
  currency text NOT NULL,
  unit_amount numeric CHECK (unit_amount > 0),
  unit_amount_cents integer,
  unit_amount_decimal text,
  type price_type NOT NULL DEFAULT 'one_time',
  interval price_interval,
  interval_count integer DEFAULT 1 CHECK (interval_count > 0),
  nickname text,
  metadata jsonb DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  -- Stripe integration
  stripe_price_id text UNIQUE,
  -- audit fields...
  CONSTRAINT price_interval_check CHECK (
    (type = 'recurring' AND interval IS NOT NULL) OR
    (type != 'recurring' AND interval IS NULL)
  )
);
```

The pricing system supports:
- One-time purchases
- Recurring subscriptions with different intervals
- Usage-based pricing
- Tiered pricing models

### Service Catalog

Services (like marketing campaigns or design work) are defined separately:

```sql
CREATE TABLE public.service_catalog (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  service_type service_type NOT NULL,
  name text NOT NULL,
  description text,
  base_price numeric,
  currency text,
  billing_interval price_interval,
  features jsonb DEFAULT '{}'::jsonb,
  prerequisites text[],
  is_active boolean DEFAULT true,
  -- audit fields...
);
```

Service types include marketing platforms (Facebook, Google, TikTok, etc.) and professional services (design, content creation, etc.).

### Brands and Stores

Products and services can be associated with specific brands and stores:

```sql
CREATE TABLE public.brand (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  customer_id uuid NOT NULL REFERENCES public.customer(id),
  name text NOT NULL,
  description text,
  logo_url text,
  website_url text,
  metadata jsonb DEFAULT '{}'::jsonb,
  settings jsonb DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  -- audit fields...
  UNIQUE(tenant_id, name)
);

CREATE TABLE public.store (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  customer_id uuid NOT NULL REFERENCES public.customer(id),
  name text NOT NULL,
  type store_type DEFAULT 'showroom',
  address_id uuid REFERENCES public.address(id),
  website_url text,
  phone text,
  email text,
  operating_hours jsonb,
  metadata jsonb DEFAULT '{}'::jsonb,
  settings jsonb DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  -- audit fields...
  UNIQUE(tenant_id, name)
);
```

## 8. Order Management

The order management system is designed to handle different types of orders through a common framework.

### Generic Order System

All orders start with a base `order` table:

```sql
CREATE TABLE public.order (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  customer_id uuid NOT NULL REFERENCES public.customer(id),
  brand_id uuid REFERENCES public.brand(id),
  store_id uuid REFERENCES public.store(id),
  order_type order_type NOT NULL,
  name text NOT NULL,
  description text,
  metadata jsonb DEFAULT '{}'::jsonb,
  total_amount numeric,
  total_amount_cents integer,
  currency text,
  is_draft boolean DEFAULT false,
  -- audit fields...
);
```

The `order_type` field determines the kind of order (campaign, subscription, product, etc.), which links to specialized tables.

### Order Items

Order items represent the products or services being purchased:

```sql
CREATE TABLE public.order_item (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  order_id uuid NOT NULL REFERENCES public.order(id),
  product_id uuid REFERENCES public.product(id),
  service_catalog_id uuid REFERENCES public.service_catalog(id),
  quantity numeric DEFAULT 1,
  unit_price numeric,
  unit_price_cents integer,
  total_amount numeric,
  total_amount_cents integer,
  discount_amount numeric DEFAULT 0,
  metadata jsonb DEFAULT '{}'::jsonb,
  -- audit fields...
  CONSTRAINT order_item_type_check CHECK (
    (product_id IS NOT NULL AND service_catalog_id IS NULL) OR
    (product_id IS NULL AND service_catalog_id IS NOT NULL)
  )
);
```

Items can reference either products or services, but not both (enforced by the `order_item_type_check` constraint).

### Campaign Orders

Marketing campaigns are handled through specialized orders:

```sql
CREATE TABLE public.campaign_order (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  order_id uuid NOT NULL REFERENCES public.order(id),
  service_type service_type NOT NULL,
  platform_id uuid REFERENCES public.platform(id),
  start_date date,
  end_date date,
  total_budget numeric,
  total_budget_cents integer,
  daily_budget numeric,
  daily_budget_cents integer,
  spent_budget numeric DEFAULT 0,
  spent_budget_cents integer DEFAULT 0,
  impressions bigint DEFAULT 0,
  clicks bigint DEFAULT 0,
  conversions bigint DEFAULT 0,
  settings jsonb DEFAULT '{}'::jsonb,
  -- audit fields...
  CONSTRAINT campaign_order_date_check CHECK (end_date IS NULL OR end_date >= start_date)
);
```

Campaign orders track marketing metrics (impressions, clicks, conversions) and budget usage.

### Subscription Orders

Recurring services use subscription orders:

```sql
CREATE TABLE public.subscription_order (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  order_id uuid NOT NULL REFERENCES public.order(id),
  service_catalog_id uuid NOT NULL REFERENCES public.service_catalog(id),
  start_date date NOT NULL,
  end_date date,
  next_billing_date date,
  billing_interval price_interval NOT NULL,
  amount numeric,
  amount_cents integer,
  -- Stripe subscription
  stripe_subscription_id text UNIQUE,
  auto_renew boolean DEFAULT true,
  -- audit fields...
);
```

Subscription orders handle recurring billing and service delivery over time.

### Order Participants

The system tracks multiple participants in each order:

```sql
CREATE TABLE public.order_participant (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  order_id uuid NOT NULL REFERENCES public.order(id),
  customer_id uuid REFERENCES public.customer(id),
  brand_id uuid REFERENCES public.brand(id),
  store_id uuid REFERENCES public.store(id),
  role text,
  metadata jsonb DEFAULT '{}'::jsonb,
  -- audit fields...
  UNIQUE(order_id, customer_id, brand_id, store_id)
);
```

This allows complex relationships where multiple entities collaborate on an order.

## 9. Marketing Campaign Management

The platform provides comprehensive marketing campaign management across various platforms.

### Platform Connections

External marketing platforms are defined and connected:

```sql
CREATE TABLE public.platform (
  id uuid PRIMARY KEY,
  name text NOT NULL UNIQUE,
  display_name text NOT NULL,
  base_url text,
  api_version text,
  is_active boolean DEFAULT true,
  capabilities jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.platform_connection (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  platform_id uuid NOT NULL REFERENCES public.platform(id),
  customer_id uuid REFERENCES public.customer(id),
  brand_id uuid REFERENCES public.brand(id),
  store_id uuid REFERENCES public.store(id),
  status connection_status DEFAULT 'pending',
  platform_account_id text,
  platform_account_name text,
  metadata jsonb DEFAULT '{}'::jsonb,
  connected_at timestamp with time zone,
  disconnected_at timestamp with time zone,
  -- audit fields...
);
```

### Campaign Structure

Campaigns are structured hierarchically:

1. **Platform Connection**: The authenticated connection to a marketing platform
2. **Platform Artifact**: Container for platform-specific objects (campaigns, ad sets, etc.)
3. **Platform Campaign**: The actual campaign running on the platform

```sql
CREATE TABLE public.platform_artifact (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  platform_connection_id uuid NOT NULL REFERENCES public.platform_connection(id),
  platform_artifact_id text NOT NULL,
  type artifact_type NOT NULL,
  name text NOT NULL,
  status text,
  parent_artifact_id uuid REFERENCES public.platform_artifact(id),
  metadata jsonb DEFAULT '{}'::jsonb,
  -- audit fields...
  UNIQUE(platform_connection_id, platform_artifact_id)
);

CREATE TABLE public.platform_campaign (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  campaign_order_id uuid NOT NULL REFERENCES public.campaign_order(id),
  platform_artifact_id uuid NOT NULL REFERENCES public.platform_artifact(id),
  platform_id uuid NOT NULL REFERENCES public.platform(id),
  platform_campaign_id text NOT NULL,
  name text NOT NULL,
  status text,
  type text,
  budget numeric CHECK (budget >= 0),
  budget_cents integer,
  currency text,
  start_date date,
  end_date date,
  metadata jsonb DEFAULT '{}'::jsonb,
  -- audit fields...
  UNIQUE(platform_artifact_id, platform_campaign_id)
);
```

This structure allows the platform to:
1. Connect to marketing platforms (Facebook, Google, etc.)
2. Create and manage campaigns across those platforms
3. Track performance metrics in a consistent way

### API Credentials

Secure storage for API credentials:

```sql
CREATE TABLE public.api_credential (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  platform_connection_id uuid NOT NULL REFERENCES public.platform_connection(id),
  encrypted_access_token text NOT NULL,
  encrypted_refresh_token text,
  token_expires_at timestamp with time zone,
  scopes text[],
  -- audit fields...
);
```

Tokens are encrypted to protect sensitive authentication data.

### Domain and URL Management

The platform manages domains and URLs for marketing campaigns:

```sql
CREATE TABLE public.domain (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  domain_name text NOT NULL UNIQUE,
  registrar text,
  status domain_status DEFAULT 'active',
  expires_at timestamp with time zone,
  ssl_expires_at timestamp with time zone,
  dns_provider text,
  nameservers text[],
  is_verified boolean DEFAULT false,
  verified_at timestamp with time zone,
  health_check_enabled boolean DEFAULT true,
  last_health_check_at timestamp with time zone,
  health_status jsonb,
  metadata jsonb DEFAULT '{}'::jsonb,
  -- audit fields...
);

CREATE TABLE public.url (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  domain_id uuid REFERENCES public.domain(id),
  customer_id uuid REFERENCES public.customer(id),
  brand_id uuid REFERENCES public.brand(id),
  store_id uuid REFERENCES public.store(id),
  order_id uuid REFERENCES public.order(id),
  path text,
  full_url text NOT NULL,
  type url_type DEFAULT 'landing_page',
  is_primary boolean DEFAULT false,
  metadata jsonb DEFAULT '{}'::jsonb,
  -- audit fields...
);
```

This allows tracking of landing pages, tracking URLs, and redirects used in marketing campaigns.

## 10. Financial Management

The financial management system handles budgeting, invoicing, and payments.

### Budget Management

Budgets allocate funds for marketing activities:

```sql
CREATE TABLE public.budget (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  name text NOT NULL,
  description text,
  amount numeric CHECK (amount > 0),
  amount_cents integer,
  currency text NOT NULL,
  status budget_status DEFAULT 'draft',
  start_date date NOT NULL,
  end_date date NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb,
  -- audit fields...
  CONSTRAINT budget_date_check CHECK (end_date >= start_date)
);

CREATE TABLE public.budget_participant (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  budget_id uuid NOT NULL REFERENCES public.budget(id),
  customer_id uuid REFERENCES public.customer(id),
  brand_id uuid REFERENCES public.brand(id),
  store_id uuid REFERENCES public.store(id),
  percentage percentage_domain,
  fixed_amount numeric CHECK (fixed_amount >= 0),
  fixed_amount_cents integer,
  metadata jsonb DEFAULT '{}'::jsonb,
  -- audit fields...
  CONSTRAINT budget_participant_amount_check CHECK (
    (percentage IS NOT NULL AND fixed_amount IS NULL) OR
    (percentage IS NULL AND fixed_amount IS NOT NULL)
  )
);

CREATE TABLE public.budget_item (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  budget_id uuid NOT NULL REFERENCES public.budget(id),
  customer_id uuid REFERENCES public.customer(id),
  invoice_item_id uuid REFERENCES public.invoice_item(id),
  platform_campaign_id uuid REFERENCES public.platform_campaign(id),
  amount numeric NOT NULL CHECK (amount >= 0),
  amount_cents integer,
  currency text NOT NULL,
  fee numeric DEFAULT 0 CHECK (fee >= 0),
  fee_cents integer DEFAULT 0,
  status budget_status DEFAULT 'pending_collection',
  hidden_from_retailer boolean DEFAULT false,
  metadata jsonb DEFAULT '{}'::jsonb,
  -- audit fields...
);
```

This system allows:
- Creating budgets with multiple participants (brands, retailers)
- Tracking budget allocation across campaigns
- Managing budget status through its lifecycle

### Invoicing

The invoice system handles billing and payments:

```sql
CREATE TABLE public.invoice (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  customer_id uuid NOT NULL REFERENCES public.customer(id),
  order_id uuid REFERENCES public.order(id),
  invoice_number text NOT NULL,
  description text,
  status text DEFAULT 'draft' CHECK (status IN ('draft', 'open', 'paid', 'uncollectible', 'void', 'sent', 'overdue', 'cancelled', 'refunded')),
  due_date date,
  paid_date date,
  amount numeric NOT NULL CHECK (amount >= 0),
  amount_cents integer,
  currency text NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb,
  -- Stripe integration
  stripe_invoice_id text UNIQUE,
  stripe_payment_intent_id text,
  stripe_status text,
  amount_paid numeric DEFAULT 0,
  amount_paid_cents integer DEFAULT 0,
  amount_due numeric,
  amount_due_cents integer,
  -- audit fields...
  UNIQUE(tenant_id, invoice_number),
  CONSTRAINT invoice_number_format CHECK (invoice_number ~ '^[A-Z0-9-]+$')
);

CREATE TABLE public.invoice_item (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  invoice_id uuid NOT NULL REFERENCES public.invoice(id),
  order_item_id uuid REFERENCES public.order_item(id),
  description text NOT NULL,
  quantity numeric CHECK (quantity > 0),
  unit_price numeric NOT NULL CHECK (unit_price >= 0),
  unit_amount_cents integer,
  total_amount numeric NOT NULL CHECK (total_amount >= 0),
  total_amount_cents integer,
  metadata jsonb DEFAULT '{}'::jsonb,
  -- audit fields...
);
```

The invoice system integrates with Stripe for payment processing, tracking both the invoice status in the platform and its payment status in Stripe.

### Payment Methods

Payment methods are stored for recurring billing:

```sql
CREATE TABLE public.payment_method (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  customer_id uuid NOT NULL REFERENCES public.customer(id),
  stripe_payment_method_id text UNIQUE,
  type text NOT NULL CHECK (type IN ('card', 'bank_account', 'paypal', 'other')),
  last4 text,
  brand text,
  exp_month integer,
  exp_year integer,
  bank_name text,
  is_default boolean DEFAULT false,
  metadata jsonb DEFAULT '{}'::jsonb,
  -- audit fields...
);
```

### Currency Conversion

Support for multi-currency operations:

```sql
CREATE TABLE public.currency_conversion (
  id uuid PRIMARY KEY,
  from_currency text NOT NULL,
  to_currency text NOT NULL,
  rate numeric NOT NULL,
  valid_from timestamp with time zone DEFAULT now(),
  valid_until timestamp with time zone,
  source text DEFAULT 'manual',
  created_at timestamp with time zone DEFAULT now(),
  UNIQUE(from_currency, to_currency, valid_from)
);
```

This allows handling budgets, invoices, and payments in different currencies with accurate conversion.

## 11. External Integrations

The platform integrates with several external services.

### Stripe Integration

Stripe is used for payment processing:

- **Customers**: Mapped to Stripe customers (`stripe_customer_id`)
- **Products**: Synchronized with Stripe products (`stripe_product_id`)
- **Prices**: Linked to Stripe prices (`stripe_price_id`)
- **Invoices**: Created and tracked in Stripe (`stripe_invoice_id`, `stripe_payment_intent_id`)
- **Subscriptions**: Managed through Stripe (`stripe_subscription_id`)

### Customer.io Integration

Customer.io handles email marketing and notifications:

- **Users**: Linked to Customer.io contacts (`cio_id`)
- **Email Preferences**: Manage subscription status and preferences
- **Events**: Track user activity for triggering automated campaigns
- **Notifications**: Send and track emails through Customer.io

```sql
CREATE TABLE public.customer_event (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  user_id uuid REFERENCES public.user(id),
  anonymous_id text,
  event_name text NOT NULL,
  event_data jsonb DEFAULT '{}'::jsonb,
  timestamp timestamp with time zone DEFAULT now(),
  cio_delivery_id text,
  page_url text,
  referrer_url text,
  user_agent text,
  ip_address inet,
  created_at timestamp with time zone DEFAULT now()
);
```

### Marketing Platforms

The platform connects to various marketing services:

- Facebook Ads
- Google Ads
- Instagram Ads
- TikTok Ads

This is handled through the platform connection and API credential system described in the Marketing Campaign Management section.

### Webhook System

External service events are processed through webhooks:

```sql
CREATE TABLE public.webhook_event (
  id uuid PRIMARY KEY,
  tenant_id uuid REFERENCES public.tenant(id),
  service text NOT NULL CHECK (service IN ('stripe', 'customerio', 'facebook', 'google', 'other')),
  event_id text UNIQUE,
  event_type text NOT NULL,
  payload jsonb NOT NULL,
  headers jsonb DEFAULT '{}'::jsonb,
  processed_at timestamp with time zone,
  error_message text,
  retry_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now()
);
```

This allows the platform to receive and process events from external services such as payment confirmations, email tracking, and ad platform updates.

## 12. System Administration

The system includes several administrative features for monitoring and management.

### Notification System

A flexible notification system for user communication:

```sql
CREATE TABLE public.notification (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  user_id uuid REFERENCES public.user(id),
  resource_type text NOT NULL,
  resource_id uuid NOT NULL,
  delivery_method delivery_method NOT NULL,
  priority priority_level DEFAULT 'medium',
  category notification_category NOT NULL,
  subject text,
  message jsonb NOT NULL,
  scheduled_at timestamp with time zone,
  sent_at timestamp with time zone,
  read_at timestamp with time zone,
  metadata jsonb DEFAULT '{}'::jsonb,
  -- Customer.io tracking
  cio_campaign_id text,
  cio_broadcast_id text,
  cio_delivery_id text,
  cio_action_id text,
  -- audit fields...
);
```

Notifications can be delivered through various channels (email, SMS, push, in-app) and are categorized by priority and type.

### Job System

Background processing is handled through a job system:

```sql
CREATE TABLE public.job (
  id uuid PRIMARY KEY,
  tenant_id uuid,
  type text NOT NULL,
  name text,
  description text,
  payload jsonb DEFAULT '{}'::jsonb,
  metadata jsonb DEFAULT '{}'::jsonb,
  scheduled_at timestamp with time zone,
  started_at timestamp with time zone,
  completed_at timestamp with time zone,
  failed_at timestamp with time zone,
  -- audit fields...
);

CREATE TABLE public.job_status_event (
  id uuid PRIMARY KEY,
  job_id uuid NOT NULL REFERENCES public.job(id),
  status job_status NOT NULL,
  message text,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now()
);
```

This system manages asynchronous tasks like data synchronization, report generation, and scheduled operations.

### Invite System

New users can be invited to the platform:

```sql
CREATE TABLE public.invite (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  email email_domain,
  invited_by uuid NOT NULL REFERENCES public.user(id),
  customer_id uuid REFERENCES public.customer(id),
  brand_id uuid REFERENCES public.brand(id),
  role account_type DEFAULT 'retailer',
  status invite_status DEFAULT 'pending',
  locale locale DEFAULT 'en',
  description text,
  metadata jsonb DEFAULT '{}'::jsonb,
  expires_at timestamp with time zone DEFAULT (now() + interval '7 days'),
  accepted_at timestamp with time zone,
  -- audit fields...
);
```

The invite system tracks invitation status and automatically creates user accounts upon acceptance.

### Status Tracking

Generic status tracking for any entity:

```sql
CREATE TABLE public.status_event (
  id uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenant(id),
  resource_type text NOT NULL,
  resource_id uuid NOT NULL,
  status text NOT NULL,
  previous_status text,
  reason text,
  metadata jsonb DEFAULT '{}'::jsonb,
  actor_id uuid REFERENCES public.user(id),
  actor_type actor_type DEFAULT 'user',
  created_at timestamp with time zone DEFAULT now()
);
```

This provides a consistent way to track status changes across different entity types.

### Rate Limiting

API rate limiting is managed through the database:

```sql
CREATE TABLE public.rate_limit (
  id uuid PRIMARY KEY,
  tenant_id uuid REFERENCES public.tenant(id),
  user_id uuid REFERENCES public.user(id),
  endpoint text NOT NULL,
  requests integer DEFAULT 0,
  window_start timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  UNIQUE(tenant_id, user_id, endpoint, window_start)
);
```

This allows controlling API usage by tenant and user.

## 13. Data Patterns & Best Practices

The database implements several design patterns and best practices:

### Audit Trails

All tables include standard audit fields:
- `created_at`: Timestamp of creation
- `created_by`: User who created the record
- `updated_at`: Timestamp of last update
- `updated_by`: User who last updated the record

Many tables also include:
- `deleted_at`: Soft deletion timestamp
- `deleted_by`: User who performed the soft deletion

### Soft Deletion

Instead of physically deleting records, many tables use a `deleted_at` timestamp to mark records as deleted. This preserves the data for audit purposes while removing it from normal queries.

### UUID Primary Keys

All tables use UUID primary keys, which provide several advantages:
- Globally unique across distributed systems
- No sequential information leakage
- No central sequence generator bottleneck
- Consistent ID format across all tables

### JSONB for Extensibility

Most tables include `metadata` and/or `settings` JSONB fields, which allow storing additional attributes without requiring schema changes. This makes the system more adaptable to evolving requirements.

### Polymorphic Relationships

Generic relationships are implemented using a polymorphic pattern with `resource_type` and `resource_id` fields. This is used in several tables:
- `note`: Attach notes to any entity
- `notification`: Send notifications about any entity
- `status_event`: Track status changes for any entity
- `permission`: Define access rules for any entity

### Dual Currency Representation

Money amounts are stored in both decimal and integer (cents) format:
```sql
amount numeric,
amount_cents integer,
```

This provides both precise decimal calculations and efficient integer operations.

### Type Safety

The database uses custom domains and constraints to enforce data integrity:
- Email validation with `email_domain`
- URL validation with `url_domain`
- Positive number validation with `positive_numeric`
- Percentage validation with `percentage_domain`

### Row-Level Security

All tenant-scoped tables use Row-Level Security (RLS) to enforce data isolation:
```sql
ALTER TABLE public.customer ENABLE ROW LEVEL SECURITY;

CREATE POLICY customer_tenant_isolation ON public.customer
  FOR ALL USING (tenant_id = current_setting('app.current_tenant_id', true)::uuid);
```

## 14. Performance Considerations

The schema includes several features to optimize performance:

### Indexing Strategy

While not explicitly shown in the schema, the following indexes should be created:

1. **Foreign Keys**: All foreign key columns should be indexed
2. **Tenant ID**: All `tenant_id` columns should be indexed for fast RLS filtering
3. **Common Query Patterns**: Additional indexes for frequently used query patterns
4. **Composite Indexes**: For columns often queried together

### Partitioning

Large tables can be partitioned by tenant:

```sql
-- Example of partitioning the audit_log table by tenant
CREATE TABLE public.audit_log_partition OF public.audit_log
PARTITION BY LIST (tenant_id);

-- Create partitions for each tenant
CREATE TABLE public.audit_log_tenant_1 
PARTITION OF public.audit_log_partition 
FOR VALUES IN ('tenant-1-uuid');
```

### Materialized Views

For complex reporting queries, materialized views can be created and refreshed periodically:

```sql
-- Example of a materialized view for campaign performance metrics
CREATE MATERIALIZED VIEW public.campaign_performance AS
SELECT
  tenant_id,
  date_trunc('day', created_at) as day,
  sum(impressions) as total_impressions,
  sum(clicks) as total_clicks,
  sum(conversions) as total_conversions,
  sum(spent_budget) as total_spent
FROM
  public.campaign_order
GROUP BY
  tenant_id, date_trunc('day', created_at);

-- Create index on the materialized view
CREATE INDEX idx_campaign_performance_tenant_day
ON public.campaign_performance (tenant_id, day);

-- Refresh the materialized view
REFRESH MATERIALIZED VIEW public.campaign_performance;
```

### JSONB Indexing

For JSON fields that need to be queried, GIN indexes can be added:

```sql
-- Create GIN index on metadata field
CREATE INDEX idx_customer_metadata ON public.customer USING GIN (metadata);

-- Create GIN index on specific JSON paths
CREATE INDEX idx_customer_metadata_tags ON public.customer USING GIN ((metadata->'tags'));
```

### Monitoring Queries

Database functions to identify slow queries and performance issues:

```sql
-- Function to find slow queries
CREATE OR REPLACE FUNCTION public.find_slow_queries(
  threshold_ms integer DEFAULT 1000
)
RETURNS TABLE (
  tenant_id uuid,
  query_text text,
  execution_time_ms integer,
  call_count integer
)
AS $$
BEGIN
  RETURN QUERY
  SELECT
    current_setting('app.current_tenant_id', true)::uuid,
    query,
    (total_time / calls) AS avg_time_ms,
    calls
  FROM
    pg_stat_statements
  WHERE
    (total_time / calls) > threshold_ms
  ORDER BY
    avg_time_ms DESC
  LIMIT 20;
END;
$$ LANGUAGE plpgsql;
```

## 15. Example Queries

Here are examples of common queries for various use cases:

### User Authentication

```sql
-- Set session context for the authenticated user
SELECT public.set_session_context('tenant-uuid', 'user-uuid');

-- Get user details with tenant information
SELECT
  u.*,
  t.name AS tenant_name,
  ut.role
FROM
  public.user u
JOIN
  public.user_tenant ut ON u.id = ut.user_id
JOIN
  public.tenant t ON ut.tenant_id = t.id
WHERE
  u.email = 'user@example.com'
  AND u.is_active = true
  AND t.is_active = true;
```

### Customer Management

```sql
-- List all customers for the current tenant
SELECT
  c.id,
  c.name,
  c.type,
  COUNT(b.id) AS brand_count,
  COUNT(s.id) AS store_count
FROM
  public.customer c
LEFT JOIN
  public.brand b ON c.id = b.customer_id AND b.tenant_id = current_tenant_id()
LEFT JOIN
  public.store s ON c.id = s.customer_id AND s.tenant_id = current_tenant_id()
WHERE
  c.tenant_id = current_tenant_id()
  AND c.is_active = true
  AND c.deleted_at IS NULL
GROUP BY
  c.id, c.name, c.type
ORDER BY
  c.name;
```

### Campaign Performance

```sql
-- Get performance metrics for all active campaigns
SELECT
  co.id AS order_id,
  co.name AS campaign_name,
  p.name AS platform_name,
  co.total_budget,
  co.spent_budget,
  co.impressions,
  co.clicks,
  co.conversions,
  CASE
    WHEN co.clicks > 0 THEN (co.spent_budget / co.clicks)::numeric(10,2)
    ELSE NULL
  END AS cost_per_click,
  CASE
    WHEN co.conversions > 0 THEN (co.spent_budget / co.conversions)::numeric(10,2)
    ELSE NULL
  END AS cost_per_conversion
FROM
  public.campaign_order co
JOIN
  public.order o ON co.order_id = o.id AND o.tenant_id = current_tenant_id()
JOIN
  public.platform p ON co.platform_id = p.id
WHERE
  co.tenant_id = current_tenant_id()
  AND (co.end_date IS NULL OR co.end_date >= CURRENT_DATE)
ORDER BY
  co.spent_budget DESC;
```

### Invoicing

```sql
-- Get unpaid invoices with customer details
SELECT
  i.id,
  i.invoice_number,
  c.name AS customer_name,
  i.amount,
  i.currency,
  i.due_date,
  i.status
FROM
  public.invoice i
JOIN
  public.customer c ON i.customer_id = c.id AND c.tenant_id = current_tenant_id()
WHERE
  i.tenant_id = current_tenant_id()
  AND i.status IN ('draft', 'open', 'sent', 'overdue')
  AND i.deleted_at IS NULL
ORDER BY
  CASE
    WHEN i.status = 'overdue' THEN 1
    WHEN i.status = 'sent' THEN 2
    WHEN i.status = 'open' THEN 3
    ELSE 4
  END,
  i.due_date;
```

### Budget Allocation

```sql
-- Get budget allocation by brand and campaign
SELECT
  b.name AS budget_name,
  br.name AS brand_name,
  bi.amount,
  bi.currency,
  pc.name AS campaign_name,
  p.name AS platform_name,
  bi.status
FROM
  public.budget_item bi
JOIN
  public.budget b ON bi.budget_id = b.id AND b.tenant_id = current_tenant_id()
JOIN
  public.brand br ON bi.customer_id = br.customer_id AND br.tenant_id = current_tenant_id()
LEFT JOIN
  public.platform_campaign pc ON bi.platform_campaign_id = pc.id AND pc.tenant_id = current_tenant_id()
LEFT JOIN
  public.platform p ON pc.platform_id = p.id
WHERE
  bi.tenant_id = current_tenant_id()
ORDER BY
  b.name, br.name, pc.name;
```

### Audit Logs

```sql
-- Get recent audit logs for a specific customer
SELECT
  al.created_at,
  u.email AS actor_email,
  al.event_type,
  al.db_table,
  al.message
FROM
  public.audit_log al
LEFT JOIN
  public.user u ON al.actor_id = u.id
WHERE
  al.tenant_id = current_tenant_id()
  AND al.db_table = 'customer'
  AND al.db_record_id = 'customer-uuid'
ORDER BY
  al.created_at DESC
LIMIT 50;
```

## 16. Appendix: Table Reference

The database contains the following main tables:

| Table Name | Description |
|------------|-------------|
| tenant | Multi-tenant organizations using the platform |
| user | Users with Customer.io integration support |
| user_tenant | User-tenant relationship with role |
| user_login | Track user login history |
| email_preference | Email subscription preferences |
| permission_group | Groups of related permissions |
| permission | Individual access rules |
| authorization | Links users to permissions |
| customer | Organizations using the platform |
| address | Addresses linked to customers |
| payment_method | Payment methods for Stripe |
| brand | Product brands |
| store | Physical or virtual retail locations |
| domain | Domain names managed by the platform |
| product | Products that can be sold |
| price | Pricing for products |
| service_catalog | Available services |
| order | Generic order entity |
| order_item | Items in an order |
| campaign_order | Marketing campaign orders |
| subscription_order | Recurring service orders |
| status_event | Generic status tracking |
| order_participant | Participants in an order |
| lead_source | Sources for leads |
| lead | Potential customer leads |
| note | Versioned notes |
| budget | Financial allocations |
| budget_participant | Participants in a budget |
| budget_item | Line items in a budget |
| invoice | Invoices for billing |
| invoice_item | Items in an invoice |
| platform_connection | Connections to marketing platforms |
| api_credential | Encrypted API credentials |
| platform_artifact | Objects on marketing platforms |
| platform_campaign | Campaigns on marketing platforms |
| url | URLs for marketing campaigns |
| invite | User invitations |
| job | Background processing tasks |
| job_status_event | Status updates for jobs |
| customer_event | Customer.io event tracking |
| notification | User notifications |
| notification_event | Notification status updates |
| email_activity | Email engagement tracking |
| webhook_event | Incoming webhook events |
| audit_log | Comprehensive audit trail |
| rate_limit | API rate limiting |
| currency_conversion | Currency exchange rates |

---

This document provides a comprehensive overview of the Zulal database schema, its functionality, and usage patterns. For implementation details, refer to the SQL schema files and application code that interacts with this database.
