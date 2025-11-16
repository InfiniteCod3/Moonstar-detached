var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// cloudflare-worker.js
var CONFIG = {
  loaderKvKey: "loader.lua",
  tokenKvPrefix: "whitelist:",
  loaderWhitelistTtl: 120,
  // seconds loader tokens stay valid before validation
  sessionTtl: 600,
  // seconds granted after scripts validate successfully
  scripts: {
    lunarity: {
      kvKey: "lunarity.lua",
      label: "Lunarity \xB7 IFrames",
      description: "Advanced combat enhancer with IFrames + Anti-Debuff",
      version: "1.0.0",
      enabled: true
    },
    doorEsp: {
      kvKey: "DoorESP.lua",
      label: "Door ESP \xB7 Halloween",
      description: "ESP and Auto-Candy support for Halloween doors",
      version: "1.0.0",
      enabled: true
    }
  }
};
var API_KEYS = {
  "demo-dev-key": {
    label: "Developer",
    allowedScripts: ["lunarity", "doorEsp"]
  },
  "test-key-123": {
    label: "Tester",
    allowedScripts: ["lunarity", "doorEsp"]
  }
  // Add more keys here:
  // "your-custom-key": {
  //     label: "Your Name",
  //     allowedScripts: ["lunarity", "doorEsp"],
  // },
};
var JSON_HEADERS = {
  "content-type": "application/json; charset=utf-8",
  "cache-control": "no-store"
};
function jsonResponse(body, init = {}) {
  return new Response(JSON.stringify(body, null, 2), {
    ...init,
    headers: {
      ...JSON_HEADERS,
      ...init.headers || {}
    }
  });
}
__name(jsonResponse, "jsonResponse");
function parseKeyring(env) {
  return API_KEYS;
}
__name(parseKeyring, "parseKeyring");
function normalizeKey(raw) {
  return (raw || "").trim();
}
__name(normalizeKey, "normalizeKey");
function buildScriptList(allowedIds) {
  return allowedIds.map((id) => {
    const meta = CONFIG.scripts[id];
    if (!meta || !meta.enabled) {
      return null;
    }
    return {
      id,
      label: meta.label,
      description: meta.description,
      version: meta.version
    };
  }).filter(Boolean);
}
__name(buildScriptList, "buildScriptList");
function randomToken(bytes = 16) {
  const buf = new Uint8Array(bytes);
  crypto.getRandomValues(buf);
  return [...buf].map((b) => b.toString(16).padStart(2, "0")).join("");
}
__name(randomToken, "randomToken");
function buildTokenKey(token) {
  return CONFIG.tokenKvPrefix + token;
}
__name(buildTokenKey, "buildTokenKey");
async function issueWhitelistToken(env, metadata) {
  const token = randomToken();
  const key = buildTokenKey(token);
  await env.SCRIPTS.put(key, JSON.stringify({
    scriptId: metadata.scriptId,
    userId: metadata.userId,
    username: metadata.username,
    issuedAt: Date.now()
  }), { expirationTtl: CONFIG.loaderWhitelistTtl });
  return { token, expiresIn: CONFIG.loaderWhitelistTtl };
}
__name(issueWhitelistToken, "issueWhitelistToken");
async function refreshWhitelistToken(env, token, record, ttl) {
  const key = buildTokenKey(token);
  await env.SCRIPTS.put(key, JSON.stringify(record), { expirationTtl: ttl });
}
__name(refreshWhitelistToken, "refreshWhitelistToken");
async function handleLoader(env) {
  const source = await env.SCRIPTS.get(CONFIG.loaderKvKey, "text");
  if (!source) {
    return new Response("-- Loader not uploaded to KV (key: " + CONFIG.loaderKvKey + ")", {
      status: 503,
      headers: {
        "content-type": "text/plain; charset=utf-8",
        "cache-control": "no-store"
      }
    });
  }
  return new Response(source, {
    headers: {
      "content-type": "text/plain; charset=utf-8",
      "cache-control": "no-store"
    }
  });
}
__name(handleLoader, "handleLoader");
async function handleAuthorize(request, env) {
  const killSwitch = (env?.KILL_SWITCH || "false").toLowerCase() === "true";
  if (killSwitch) {
    return jsonResponse({ ok: false, reason: "Global kill switch active." }, { status: 503 });
  }
  let body;
  try {
    body = await request.json();
  } catch (err) {
    return jsonResponse({ ok: false, reason: "Invalid JSON payload." }, { status: 400 });
  }
  const keyring = parseKeyring(env);
  const apiKey = normalizeKey(body.apiKey);
  const keyEntry = keyring[apiKey];
  if (!keyEntry) {
    return jsonResponse({ ok: false, reason: "Unauthorized: invalid API key." }, { status: 401 });
  }
  const allowedScripts = Array.isArray(keyEntry.allowedScripts) && keyEntry.allowedScripts.length > 0 ? keyEntry.allowedScripts : Object.keys(CONFIG.scripts);
  const responseBase = {
    ok: true,
    message: "Authorization OK",
    scripts: buildScriptList(allowedScripts),
    actor: {
      label: keyEntry.label || "User",
      userId: body.userId,
      username: body.username,
      placeId: body.placeId
    }
  };
  const scriptId = body.scriptId || body.script;
  if (!scriptId) {
    return jsonResponse(responseBase);
  }
  if (!allowedScripts.includes(scriptId)) {
    return jsonResponse({ ok: false, reason: "API key not permitted for this script." }, { status: 403 });
  }
  const scriptMeta = CONFIG.scripts[scriptId];
  if (!scriptMeta || !scriptMeta.enabled) {
    return jsonResponse({ ok: false, reason: "Requested script is disabled." }, { status: 503 });
  }
  const scriptBody = await env.SCRIPTS.get(scriptMeta.kvKey, "text");
  if (!scriptBody) {
    return jsonResponse({ ok: false, reason: `Script body missing in KV (${scriptMeta.kvKey}).` }, { status: 500 });
  }
  const tokenInfo = await issueWhitelistToken(env, {
    scriptId,
    userId: body.userId,
    username: body.username
  });
  return jsonResponse({
    ...responseBase,
    script: scriptBody,
    scriptMeta: {
      id: scriptId,
      label: scriptMeta.label,
      description: scriptMeta.description,
      version: scriptMeta.version
    },
    accessToken: tokenInfo.token,
    expiresIn: tokenInfo.expiresIn,
    validatePath: "/validate"
  });
}
__name(handleAuthorize, "handleAuthorize");
function handleHealth() {
  return jsonResponse({ ok: true });
}
__name(handleHealth, "handleHealth");
async function handleValidate(request, env) {
  const killSwitch = (env?.KILL_SWITCH || "false").toLowerCase() === "true";
  if (killSwitch) {
    return jsonResponse({ ok: false, reason: "Kill switch active", killSwitch: true }, { status: 403 });
  }
  let body;
  try {
    body = await request.json();
  } catch (_err) {
    return jsonResponse({ ok: false, reason: "Invalid JSON payload." }, { status: 400 });
  }
  const token = normalizeKey(body.token);
  if (!token) {
    return jsonResponse({ ok: false, reason: "Token missing." }, { status: 400 });
  }
  const tokenKey = buildTokenKey(token);
  const record = await env.SCRIPTS.get(tokenKey, { type: "json" });
  if (!record) {
    return jsonResponse({ ok: false, reason: "Token expired or invalid." }, { status: 401 });
  }
  if (body.scriptId && record.scriptId && body.scriptId !== record.scriptId) {
    return jsonResponse({ ok: false, reason: "Token/script mismatch." }, { status: 403 });
  }
  const refresh = body.refresh !== false;
  if (refresh) {
    await refreshWhitelistToken(env, token, record, CONFIG.sessionTtl);
  }
  return jsonResponse({
    ok: true,
    scriptId: record.scriptId,
    expiresIn: refresh ? CONFIG.sessionTtl : CONFIG.loaderWhitelistTtl
  });
}
__name(handleValidate, "handleValidate");
function handleNotFound() {
  return jsonResponse({ ok: false, reason: "Not found" }, { status: 404 });
}
__name(handleNotFound, "handleNotFound");
var cloudflare_worker_default = {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204 });
    }
    if (url.pathname === "/" || url.pathname === "/loader") {
      return handleLoader(env);
    }
    if (url.pathname === "/authorize" && request.method === "POST") {
      return handleAuthorize(request, env);
    }
    if (url.pathname === "/validate" && request.method === "POST") {
      return handleValidate(request, env);
    }
    if (url.pathname === "/health") {
      return handleHealth();
    }
    return handleNotFound();
  }
};
export {
  cloudflare_worker_default as default
};
//# sourceMappingURL=cloudflare-worker.js.map
