import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

export async function updateSession(request: NextRequest) {
  let response = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
          response = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  const {
    data: { user },
  } = await supabase.auth.getUser();

  const path = request.nextUrl.pathname;
  const isAuthRoute = path.startsWith("/login");
  const isPublicAsset = path.startsWith("/_next") || path.startsWith("/favicon");

  // Redirects must carry over any cookies that getUser() just refreshed
  // onto `response`, or the refreshed session is dropped on every redirect
  // (which includes every visit to "/", since that path always redirects).
  const redirectTo = (pathname: string) => {
    const url = request.nextUrl.clone();
    url.pathname = pathname;
    const redirect = NextResponse.redirect(url);
    response.cookies.getAll().forEach((c) => redirect.cookies.set(c));
    return redirect;
  };

  if (!user && !isAuthRoute && !isPublicAsset) {
    return redirectTo("/login");
  }

  // Role-based routing: keep learners out of /tracker and vice versa.
  // The role is already present on the user object from getUser() above
  // (set at signup and stored in Supabase auth's user metadata), so this
  // no longer needs a second network round-trip to a profiles table —
  // that extra query was adding real, avoidable latency to every single
  // navigation in the app.
  if (user && !isAuthRoute && !isPublicAsset) {
    const role = (user.user_metadata?.role as string | undefined) ?? "learner";

    if (path.startsWith("/tracker") && role !== "tracker") {
      return redirectTo("/dashboard");
    }
    if (path.startsWith("/dashboard") && role !== "learner") {
      return redirectTo("/tracker");
    }
    if (path === "/") {
      return redirectTo(role === "tracker" ? "/tracker" : "/dashboard");
    }
  }

  if (user && isAuthRoute) {
    return redirectTo("/dashboard");
  }

  return response;
}
