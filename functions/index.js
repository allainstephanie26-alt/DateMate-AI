const { onRequest } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');

admin.initializeApp();

const GEMINI_API_KEY = defineSecret('GEMINI_API_KEY');
const GEMINI_MODEL = 'gemini-2.5-flash';

function json(res, status, payload) {
  return res.status(status).set('Content-Type', 'application/json').send(payload);
}

function setCors(res) {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
}

async function requireUser(req) {
  const header = String(req.headers.authorization || '');
  if (!header.startsWith('Bearer ')) {
    throw new Error('UNAUTHENTICATED');
  }

  const token = header.substring('Bearer '.length).trim();
  if (!token) throw new Error('UNAUTHENTICATED');

  return admin.auth().verifyIdToken(token);
}

function safePlaceList(places) {
  return Array.isArray(places)
    ? places
        .filter((place) => place && typeof place === 'object')
        .slice(0, 12)
    : [];
}

function buildPrompt({ preferences, mood, places }) {
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
    `Verified curated place shortlist: ${JSON.stringify(places)}`,
  ].join('\n');
}

function buildContents(history, message) {
  const contents = [];
  for (const item of Array.isArray(history) ? history.slice(-12) : []) {
    const role = item?.role === 'assistant' ? 'model' : 'user';
    const text = String(item?.text || '').trim();
    if (text) contents.push({ role, parts: [{ text }] });
  }

  contents.push({
    role: 'user',
    parts: [{ text: message }],
  });

  return contents;
}

exports.aiChat = onRequest(
  {
    region: 'asia-southeast1',
    secrets: [GEMINI_API_KEY],
    timeoutSeconds: 35,
    memory: '256MiB',
  },
  async (req, res) => {
    setCors(res);

    if (req.method === 'OPTIONS') {
      return res.status(204).send('');
    }

    if (req.method !== 'POST') {
      return json(res, 405, { error: 'POST required.' });
    }

    try {
      await requireUser(req);

      const message = String(req.body?.message || '').trim();
      const preferences = req.body?.preferences || {};
      const mood = String(req.body?.mood || '');
      const places = safePlaceList(req.body?.places);

      if (!message) {
        return json(res, 400, { error: 'message is required.' });
      }

      if (!places.length) {
        return json(res, 400, {
          error: 'No curated place candidates are available.',
        });
      }

      const prompt = buildPrompt({ preferences, mood, places });

      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': GEMINI_API_KEY.value(),
          },
          body: JSON.stringify({
            systemInstruction: {
              parts: [{ text: prompt }],
            },
            contents: buildContents(req.body?.history, message),
            generationConfig: {
              temperature: 0.55,
              maxOutputTokens: 450,
              responseMimeType: 'application/json',
            },
          }),
        },
      );

      const body = await response.json();

      if (!response.ok) {
        console.error('Gemini error:', body);
        return json(res, 502, {
          error: 'The DateMate AI model could not respond right now.',
        });
      }

      const raw = body.candidates?.[0]?.content?.parts
        ?.map((part) => part.text || '')
        .join('')
        .trim();

      if (!raw) {
        return json(res, 502, {
          error: 'The DateMate AI model returned an empty response.',
        });
      }

      let parsed;
      try {
        parsed = JSON.parse(raw);
      } catch (_) {
        return json(res, 502, {
          error: 'The DateMate AI response was not valid JSON.',
        });
      }

      const reply = String(parsed.reply || '').trim();
      const requestedId = parsed.selectedPlaceId == null
        ? null
        : String(parsed.selectedPlaceId).trim();

      const validIds = new Set(places.map((place) => String(place.id)));
      const selectedPlaceId = requestedId && validIds.has(requestedId)
        ? requestedId
        : null;

      if (!reply) {
        return json(res, 502, {
          error: 'The DateMate AI response did not contain a reply.',
        });
      }

      return json(res, 200, {
        reply,
        selectedPlaceId,
      });
    } catch (error) {
      if (error?.message === 'UNAUTHENTICATED') {
        return json(res, 401, {
          error: 'Authentication required.',
        });
      }

      console.error(error);
      return json(res, 500, {
        error: 'DateMate AI service failed.',
      });
    }
  },
);
