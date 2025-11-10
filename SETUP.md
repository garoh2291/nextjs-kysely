# Zulal Authentication Setup Guide

## Overview

Your Zulal application now has a complete authentication system with Google OAuth integration, proper multi-tenant database logic, and automatic user registration.

## Environment Variables Required

Create a `.env.local` file in your project root with the following variables:

```env
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/zulal"

# NextAuth.js
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="your-nextauth-secret-here"

# Google OAuth
GOOGLE_CLIENT_ID="your-google-client-id"
GOOGLE_CLIENT_SECRET="your-google-client-secret"
```

## Google OAuth Setup

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google+ API
4. Go to "Credentials" and create a new "OAuth 2.0 Client ID"
5. Configure the OAuth consent screen
6. Add authorized redirect URIs:
   - `http://localhost:3000/api/auth/callback/google` (for development)
   - `https://yourdomain.com/api/auth/callback/google` (for production)
7. Copy the Client ID and Client Secret to your `.env.local` file

## Database Setup

Make sure your PostgreSQL database is running and has the Zulal schema applied. The authentication system will:

1. Automatically create users when they sign in with Google
2. Create a tenant organization for each new user
3. Assign roles based on email (garoh2291@gmail.com gets admin role)
4. Set up proper tenant relationships

## How the Authentication Works

### User Flow:

1. User visits `/` → redirected to `/auth/signin` if not authenticated
2. User clicks "Continue with Google" → Google OAuth flow
3. After successful authentication:
   - Check if user exists in database
   - If not, create new user with email and basic info
   - Create tenant organization for the user
   - Assign role (`admin` for garoh2291@gmail.com, `retailer` for others)
   - Set up user-tenant relationship
4. User is redirected to `/dashboard` with full tenant context

### Special Admin Logic:

- The email `garoh2291@gmail.com` is automatically assigned the `admin` role
- Admin users get a special tenant called "Zulal Admin"
- Admin users have access to platform-wide features
- All other users get `retailer` role by default

### Multi-Tenant Security:

- Session context is set with tenant ID and user ID for RLS
- All database queries respect tenant isolation
- Users can only access their own tenant's data
- Proper audit logging tracks all user actions

## File Structure Created:

```
src/
├── lib/
│   ├── auth.ts              # NextAuth configuration & user management
│   └── db.ts                # Database connection with RLS helpers
├── types/
│   └── next-auth.d.ts       # TypeScript extensions for NextAuth
├── components/
│   └── providers/
│       └── session-provider.tsx  # Session provider wrapper
├── app/
│   ├── api/
│   │   ├── auth/
│   │   │   └── [...nextauth]/route.ts  # NextAuth API route
│   │   └── user/
│   │       └── tenant-info/route.ts    # Tenant info API
│   ├── auth/
│   │   └── signin/page.tsx  # Google login page
│   ├── dashboard/page.tsx   # Protected dashboard
│   ├── layout.tsx           # Updated with session provider
│   └── page.tsx             # Home page with auth redirects
├── middleware.ts            # Route protection middleware
└── SETUP.md                # This setup guide
```

## Running the Application

1. Install dependencies: `npm install`
2. Set up your environment variables in `.env.local`
3. Make sure your database is running and has the Zulal schema
4. Run the development server: `npm run dev`
5. Visit `http://localhost:3000`

## Testing the Authentication

1. Visit the homepage - you should be redirected to the sign-in page
2. Click "Continue with Google" and complete the OAuth flow
3. You should be redirected to the dashboard showing your user and tenant information
4. Try signing out and signing back in - it should remember your account
5. Test with the admin email (garoh2291@gmail.com) to see admin privileges

## Key Features Implemented:

✅ Google OAuth integration with NextAuth.js  
✅ Automatic user registration and tenant creation  
✅ Multi-tenant database architecture with RLS  
✅ Role-based access control (admin vs retailer)  
✅ Protected routes with middleware  
✅ Session management with tenant context  
✅ Comprehensive error handling  
✅ TypeScript support throughout  
✅ Modern UI with shadcn/ui components

The system is now ready for development and can handle user authentication, registration, and multi-tenant data access according to your database schema!
