// DateMate AI — Gemini-powered chat, as a Supabase Edge Function.
//
// This replaces the original Firebase Cloud Function (`functions/index.js`)
// one-for-one: same request body, same "source of truth" prompt rules, same
// {reply, selectedPlaceId} response shape. The Flutter app calls it through
// `AiChatService._tryCloudReply`, using `supabase.functions.invoke(...)`,
// and always has a fully local fallback if this function is slow, not
// deployed, or errors out — so the app never depends on Gemini being up.
//
// Deploy:
//   supabase functions deploy datemate-chat
//   supabase secrets set GEMINI_API_KEY=your-key-here
//
// Auth: Supabase verifies the caller's JWT before this code runs (unless
// deployed with --no-verify-jwt). This function double-checks the token
// itself as well, so a request with no valid Supabase session is always
// rejected even if that platform check is ever disabled.

import { createClient } from 'jsr:@supabase/supabase-js@2';

const GEMINI_MODEL = 'gemini-2.5-flash';
// GEMINI_API_KEY is the only secret that has to be set by hand, via
// `supabase secrets set GEMINI_API_KEY=...`. SUPABASE_URL and
// SUPABASE_ANON_KEY below are injected automatically into every deployed
// Edge Function's runtime by Supabase itself — note that's "ANON_KEY" here
// specifically because that's the fixed name Supabase's Functions runtime
// uses, independent of the SUPABASE_PUBLISHABLE_KEY name the Flutter app
// uses for the same key via --dart-define.
const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY') ?? '';
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') ?? '';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function json(status: number, payload: unknown): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  });
}

interface PlaceCandidate {
  id: string;
  [key: string]: unknown;
}

function safePlaceList(places: unknown): PlaceCandidate[] {
  if (!Array.isArray(places)) return [];
  return places
    .filter((p): p is PlaceCandidate => !!p && typeof p === 'object' && typeof (p as PlaceCandidate).id === 'string')
    .slice(0, 12);
}

function buildPrompt(preferences: unknown, mood: string, places: PlaceCandidate[]): string {
  return [
    'You are DateMate AI, a friendly conversational date-planning assistant.',
    'You are not a generic chatbot. Your job is to help a couple choose a date.',
    '',
    'SOURCE OF TRUTH RULES:',
    '1. You may recommend ONLY a place whose exact id appears in the supplied shortlist.',
    '2. Never invent or guess a place, address, price, opening hour, menu item, website, or map link.',
    '3. Treat the supplied place fields as the only factual source for place details.',
    '4. If the user asks for information that is not supplied, say that it is not available and direct them to the supplied official website/menu/Google Maps link when appropriate.',
    '5. Respect the saved location, budget, currency, food preferences, activities, and mood.',
    '6. If the user asks for a cheaper option, prioritize candidates whose listed maximum cost is lower.',
    '7. If the user asks for food, prioritize candidates whose category/subtitle fits food or the saved food preferences.',
    '8. If the user asks for another place, choose a different valid candidate when possible.',
    '9. If no candidate satisfies the new criteria, say so honestly and suggest which criterion can be relaxed.',
    '10. A place whose "verified" field is false is a DateMate-generated idea, not a confirmed real business — say so if asked, and suggest checking Google Maps before going.',
    '',
    'CONVERSATION RULES:',
    '- Sound like a natural helpful AI companion, not a form.',
    '- Answer the user directly, then ask a short follow-up only when useful.',
    '- When you pick a place, explain why it matches the couple.',
    '- Keep most replies to 2–5 short sentences.',
    '- You can use a small amount of friendly emoji.',
    '',
    'OUTPUT RULE:',
    'Return ONLY valid JSON with this exact shape:',
    '{"reply":"string","selectedPlaceId":"string or null"}',
    'selectedPlaceId must be one of the supplied place ids or null.',
    '',
    `Saved mood: ${JSON.stringify(mood)}`,
    `Saved couple preferences: ${JSON.stringify(preferences)}`,
    `Verified + generated place shortlist: ${JSON.stringify(places)}`,
  ].join('\n');
}

interface HistoryItem {
  role?: string;
  text?: string;
}

function buildContents(history: unknown, message: string) {
  const contents: { role: string; parts: { text: string }[] }[] = [];
  const items: HistoryItem[] = Array.isArray(history) ? (history as HistoryItem[]).slice(-12) : [];
  for (const item of items) {
    const role = item?.role === 'assistant' ? 'model' : 'user';
    const text = String(item?.text || '').trim();
    if (text) contents.push({ role, parts: [{ text }] });
  }
  contents.push({ role: 'user', parts: [{ text: message }] });
  return contents;
}

interface ChatRequestBody {
  message?: string;
  mood?: string;
  preferences?: unknown;
  places?: unknown;
  history?: unknown;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS });
  }
  if (req.method !== 'POST') {
    return json(405, { error: 'POST required.' });
  }
  if (!GEMINI_API_KEY) {
    return json(500, { error: 'GEMINI_API_KEY is not configured for this project.' });
  }

  try {
    // Verify the caller is a real, signed-in Supabase user.
    const authHeader = req.headers.get('Authorization') ?? '';
    if (!authHeader.startsWith('Bearer ')) {
      return json(401, { error: 'Authentication required.' });
    }
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: userData, error: userError } = await supabase.auth.getUser();
    if (userError || !userData?.user) {
      return json(401, { error: 'Authentication required.' });
    }

    const body = (await req.json().catch(() => ({}))) as ChatRequestBody;
    const message = String(body.message || '').trim();
    const preferences = body.preferences ?? {};
    const mood = String(body.mood || '');
    const places = safePlaceList(body.places);

    if (!message) return json(400, { error: 'message is required.' });
    if (!places.length) {
      return json(400, { error: 'No place candidates were supplied.' });
    }

    const prompt = buildPrompt(preferences, mood, places);

    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': GEMINI_API_KEY,
        },
        body: JSON.stringify({
          systemInstruction: { parts: [{ text: prompt }] },
          contents: buildContents(body.history, message),
          generationConfig: {
            temperature: 0.55,
            maxOutputTokens: 450,
            responseMimeType: 'application/json',
          },
        }),
      },
    );

    const geminiBody = await geminiResponse.json();
    if (!geminiResponse.ok) {
      console.error('Gemini error:', geminiBody);
      return json(502, { error: 'The DateMate AI model could not respond right now.' });
    }

    const raw = geminiBody?.candidates?.[0]?.content?.parts
      ?.map((part: { text?: string }) => part.text || '')
      .join('')
      .trim();

    if (!raw) {
      return json(502, { error: 'The DateMate AI model returned an empty response.' });
    }

    let parsed: { reply?: string; selectedPlaceId?: string | null };
    try {
      parsed = JSON.parse(raw);
    } catch (_err) {
      return json(502, { error: 'The DateMate AI response was not valid JSON.' });
    }

    const reply = String(parsed.reply || '').trim();
    const requestedId = parsed.selectedPlaceId == null ? null : String(parsed.selectedPlaceId).trim();
    const validIds = new Set(places.map((p) => p.id));
    const selectedPlaceId = requestedId && validIds.has(requestedId) ? requestedId : null;

    if (!reply) {
      return json(502, { error: 'The DateMate AI response did not contain a reply.' });
    }

    return json(200, { reply, selectedPlaceId });
  } catch (error) {
    console.error(error);
    return json(500, { error: 'DateMate AI service failed.' });
  }
});