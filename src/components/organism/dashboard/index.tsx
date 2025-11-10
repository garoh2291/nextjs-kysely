"use client";

import { useSession, signOut } from "next-auth/react";
import { useEffect } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  Building2,
  Users,
  ShoppingCart,
  BarChart3,
  LogOut,
} from "lucide-react";
import { useGetTenantInfo, useTrackLogin } from "@/services/auth.service";
export const Dashboard = () => {
  const { data: session, status } = useSession();

  // React Query hooks
  const {
    data: tenantInfo,
    isLoading: isTenantInfoLoading,
    error: tenantInfoError,
  } = useGetTenantInfo({
    enabled: status === "authenticated" && !!session?.user?.id,
  });

  const trackLoginMutation = useTrackLogin({
    onSuccess: () => {
      console.log("Login tracked successfully");
    },
    onError: (error) => {
      console.error("Error tracking login:", error);
    },
  });

  // Track login when user is authenticated
  useEffect(() => {
    if (
      status === "authenticated" &&
      session?.user?.id &&
      !trackLoginMutation.isSuccess
    ) {
      trackLoginMutation.mutate();
    }
  }, [status, session?.user?.id, trackLoginMutation.isSuccess]);

  const handleSignOut = async () => {
    await signOut({ callbackUrl: "/signin" });
  };

  // Loading states
  const isLoading = status === "loading" || isTenantInfoLoading;

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
      </div>
    );
  }

  if (!session) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Card>
          <CardContent className="pt-6">
            <p>Please sign in to access the dashboard.</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  // Handle tenant info error
  if (tenantInfoError) {
    console.error("Tenant info error:", tenantInfoError);
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center space-x-4">
              <h1 className="text-2xl font-bold text-gray-900">
                Zulal Dashboard
              </h1>
              {session.user.isAdmin && (
                <div className="bg-red-100 text-red-800 text-xs px-2 py-1 rounded-full font-medium">
                  Admin
                </div>
              )}
            </div>

            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-3">
                <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center text-white font-medium">
                  {session.user.name?.charAt(0) ||
                    session.user.email?.charAt(0) ||
                    "U"}
                </div>
                <div className="hidden sm:block">
                  <p className="text-sm font-medium text-gray-900">
                    {session.user.name || session.user.email}
                  </p>
                  <p className="text-xs text-gray-500">{session.user.email}</p>
                </div>
              </div>

              <Button variant="outline" size="sm" onClick={handleSignOut}>
                <LogOut className="h-4 w-4 mr-2" />
                Sign Out
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-gray-900">
            Welcome back,{" "}
            {session.user.name || session.user.email?.split("@")[0]}!
          </h2>
          <p className="text-gray-600 mt-2">
            You&apos;re successfully signed in to the Zulal multi-tenant retail
            marketplace.
            {session.user.isAdmin && " You have administrative privileges."}
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <Card className="text-center">
            <CardHeader>
              <Building2 className="h-12 w-12 text-blue-600 mx-auto mb-4" />
              <CardTitle className="text-lg">Your Organization</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-gray-600 mb-2">Name:</p>
              <p className="text-sm font-medium">
                {tenantInfo?.tenant.name || session.user.tenantSlug}
              </p>
              <p className="text-sm text-gray-600 mt-2 mb-1">Slug:</p>
              <p className="text-xs font-mono text-gray-800">
                {session.user.tenantSlug}
              </p>
            </CardContent>
          </Card>

          <Card className="text-center">
            <CardHeader>
              <Users className="h-12 w-12 text-green-600 mx-auto mb-4" />
              <CardTitle className="text-lg">Your Role</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800 capitalize">
                {session.user.role}
              </div>
              <p className="text-xs text-gray-600 mt-2">
                Role-based access control active
              </p>
            </CardContent>
          </Card>

          <Card className="text-center">
            <CardHeader>
              <ShoppingCart className="h-12 w-12 text-purple-600 mx-auto mb-4" />
              <CardTitle className="text-lg">Campaign Management</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-gray-600">
                Ready to manage your marketing campaigns across multiple
                platforms
              </p>
            </CardContent>
          </Card>

          <Card className="text-center">
            <CardHeader>
              <BarChart3 className="h-12 w-12 text-orange-600 mx-auto mb-4" />
              <CardTitle className="text-lg">Financial Tracking</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-gray-600">
                Budget allocation, invoicing, and payment processing
              </p>
            </CardContent>
          </Card>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>System Information</CardTitle>
            <CardDescription>
              Your account and tenant information in the Zulal platform
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <h4 className="font-medium text-blue-900 mb-2">
                Multi-Tenant Setup Complete
              </h4>
              <ul className="text-sm text-blue-800 space-y-1">
                <li>
                  ✅ Your account has been automatically created with{" "}
                  <strong>{session.user.role}</strong> privileges
                </li>
                <li>
                  ✅ You&apos;re assigned to tenant:{" "}
                  <strong>{session.user.tenantSlug}</strong>
                </li>
                <li>
                  ✅ All data is isolated per tenant using Row-Level Security
                </li>
                <li>
                  ✅ Session context is properly configured for database access
                </li>
                {session.user.isAdmin && (
                  <li>
                    ✅ <strong>Admin privileges active</strong> - You have
                    access to platform-wide features
                  </li>
                )}
              </ul>
            </div>
          </CardContent>
        </Card>
      </main>
    </div>
  );
};
