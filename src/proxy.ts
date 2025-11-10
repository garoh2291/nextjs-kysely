import { withAuth } from "next-auth/middleware";
import { NextResponse } from "next/server";

export default withAuth(
  function middleware(req) {
    const { pathname } = req.nextUrl;
    const token = req.nextauth.token;

    // If user is authenticated and trying to access signin, redirect to home
    if (token && pathname.startsWith("/signin")) {
      return NextResponse.redirect(new URL("/", req.url));
    }

    // If user is not authenticated and trying to access protected routes, redirect to signin
    if (!token && pathname !== "/signin") {
      return NextResponse.redirect(new URL("/signin", req.url));
    }

    return NextResponse.next();
  },
  {
    callbacks: {
      authorized: ({ token, req }) => {
        const { pathname } = req.nextUrl;

        // Allow access to signin page without authentication
        if (pathname.startsWith("/signin")) {
          return true;
        }

        // Allow access to API routes
        if (pathname.startsWith("/api")) {
          return true;
        }

        // For all other routes, require authentication
        return !!token;
      },
    },
  }
);

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     */
    "/((?!_next/static|_next/image|favicon.ico|.*\\.png$|.*\\.jpg$|.*\\.jpeg$|.*\\.gif$|.*\\.svg$).*)",
  ],
};
