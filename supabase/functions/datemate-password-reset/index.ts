import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const attempts = new Map<string, { count: number; resetAt: number }>();
const WINDOW_MS = 15 * 60 * 1000;
const MAX_ATTEMPTS = 5;

function normalize(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function rateLimited(key: string): boolean {
  const now = Date.now();
  const current = attempts.get(key);

  if (!current || current.resetAt <= now) {
    attempts.set(key, { count: 1, resetAt: now + WINDOW_MS });
    return false;
  }

  current.count += 1;
  return current.count > MAX_ATTEMPTS;
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed." }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const clientIp =
    request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? "unknown";

  if (rateLimited(clientIp)) {
    return new Response(
      JSON.stringify({ error: "Too many recovery attempts. Please wait and try again." }),
      { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  try {
    const body = await request.json();
    const email = normalize(body?.email).toLowerCase();
    const name = normalize(body?.name);
    const coupleCode = normalize(body?.coupleCode).toUpperCase();
    const newPassword = normalize(body?.newPassword);

    if (
      !email ||
      !email.includes("@") ||
      name.length < 2 ||
      coupleCode.length < 4 ||
      newPassword.length < 6
    ) {
      return new Response(
        JSON.stringify({ error: "Enter valid recovery details and a new password of at least 6 characters." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !serviceRoleKey) {
      return new Response(
        JSON.stringify({ error: "Password recovery is not configured on the server." }),
        { status: 503, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // This client exists only inside the trusted Edge Function runtime.
    // The service-role key is never returned to or embedded in Flutter.
    const admin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const { data: profile, error: profileError } = await admin
      .from("profiles")
      .select("id, name, email, couple_id")
      .eq("email", email)
      .maybeSingle();

    if (profileError || !profile) {
      return new Response(
        JSON.stringify({ error: "The recovery details do not match this account." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const profileName = String(profile.name ?? "").trim().toLowerCase();
    if (profileName !== name.toLowerCase() || !profile.couple_id) {
      return new Response(
        JSON.stringify({ error: "The recovery details do not match this account." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { data: couple, error: coupleError } = await admin
      .from("couples")
      .select("id, code")
      .eq("id", profile.couple_id)
      .eq("code", coupleCode)
      .maybeSingle();

    if (coupleError || !couple) {
      return new Response(
        JSON.stringify({ error: "The recovery details do not match this account." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { error: updateError } = await admin.auth.admin.updateUserById(
      String(profile.id),
      { password: newPassword },
    );

    if (updateError) {
      return new Response(
        JSON.stringify({ error: "The password could not be updated. Please try again." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({ ok: true }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (_) {
    return new Response(
      JSON.stringify({ error: "The password could not be updated. Please try again." }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
