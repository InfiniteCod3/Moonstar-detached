// Cloudflare Worker entry point for Lunarity authentication + script delivery
// Deploy with Wrangler and bind a KV namespace named "SCRIPTS" that stores:
//   - loader.lua (GUI loader served at / or /loader)
//   - lunarity.lua (combat script)
//   - DoorESP.lua (ESP script)
// Provide an API key map via the API_KEYS secret (JSON) and optional kill switch via KILL_SWITCH env var.

const CONFIG = {
    loaderKvKey: "loader.lua",
    tokenKvPrefix: "whitelist:",
    loaderWhitelistTtl: 120, // seconds loader tokens stay valid before validation
    sessionTtl: 600, // seconds granted after scripts validate successfully
    requiredUserAgent: "LunarityLoader/1.0",
    encryptionKey: "LunarityXOR2025!SecretKey", // XOR encryption key for payload obfuscation
    discordWebhook: "https://discord.com/api/webhooks/1424094994129485915/tj3RnyDn8DqMprbe-3Is4yuz-shQsHe--r4baFAQ9vGRdRaYqrENVeY92NR2DGUs7u94",
    scripts: {
        lunarityUI: {
            kvKey: "LunarityUI.lua",
            label: "Lunarity UI Module",
            description: "Shared ImGUI-style UI framework for all Lunarity scripts",
            version: "1.0.0",
            enabled: true,
        },
        lunarity: {
            kvKey: "lunarity.lua",
            label: "Lunarity · IFrames",
            description: "Advanced combat enhancer with IFrames + Anti-Debuff",
            version: "1.0.0",
            enabled: true,
        },
        doorEsp: {
            kvKey: "DoorESP.lua",
            label: "Door ESP · Halloween",
            description: "ESP and Auto-Candy support for Halloween doors",
            version: "1.0.0",
            enabled: true,
        },
        teleport: {
            kvKey: "Teleport.lua",
            label: "Teleport · Advanced",
            description: "Player and map teleportation with spoofing support",
            version: "1.0.0",
            enabled: true,
        },
        remoteLogger: {
            kvKey: "RemoteLogger.lua",
            label: "Remote Logger · Dev",
            description: "Developer tool that logs incoming/outgoing remotes",
            version: "1.0.0",
            enabled: true,
        },
        aetherShitter: {
            kvKey: "AetherShitterRecode.lua",
            label: "Aether Shitter · Recode",
            description: "Massive server destruction tool (Use with caution)",
            version: "1.0.0",
            enabled: true,
        },
        playerTracker: {
            kvKey: "PlayerTracker.lua",
            label: "Player Tracker · Aim",
            description: "Hold RMB to track closest player with auto-prediction algorithms",
            version: "1.0.0",
            enabled: true,
        },
        gamepassUnlocker: {
            kvKey: "GamepassUnlocker.lua",
            label: "Gamepass Unlocker",
            description: "Gamepass bypass proof of concept with namecall hooking and weapon injection",
            version: "1.0.0",
            enabled: true,
        },
    },
};

// API Keys Configuration - Edit this object directly to add/remove keys
// No secrets or KV required - just modify this code and redeploy
const API_KEYS = {
    "demo-dev-key": {
        label: "Developer",
        allowedScripts: ["lunarityUI", "lunarity", "doorEsp", "teleport", "remoteLogger", "aetherShitter", "playerTracker", "gamepassUnlocker"],
    },
    "test-key-123": {
        label: "Tester",
        allowedScripts: ["lunarityUI", "lunarity", "doorEsp", "teleport", "playerTracker", "gamepassUnlocker"],
    },
    // Add more keys here:
    // "your-custom-key": {
    //     label: "Your Name",
    //     allowedScripts: ["lunarityUI", "lunarity", "doorEsp", "teleport"],
    // },
};

const JSON_HEADERS = {
    "content-type": "application/json; charset=utf-8",
    "cache-control": "no-store",
};

function jsonResponse(body, init = {}) {
    return new Response(JSON.stringify(body, null, 2), {
        ...init,
        headers: {
            ...JSON_HEADERS,
            ...(init.headers || {}),
        },
    });
}

function parseKeyring(env) {
    // Always use the hardcoded API_KEYS object
    return API_KEYS;
}

// XOR encryption/decryption for payload obfuscation
function xorCrypt(input, key) {
    const keyBytes = new TextEncoder().encode(key);
    const inputBytes = typeof input === "string" ? new TextEncoder().encode(input) : input;
    const output = new Uint8Array(inputBytes.length);
    for (let i = 0; i < inputBytes.length; i++) {
        output[i] = inputBytes[i] ^ keyBytes[i % keyBytes.length];
    }
    return output;
}

function encryptPayload(plainText) {
    const encrypted = xorCrypt(plainText, CONFIG.encryptionKey);
    // Use chunked approach to avoid stack overflow on large payloads
    let binaryStr = "";
    const chunkSize = 8192;
    for (let i = 0; i < encrypted.length; i += chunkSize) {
        const chunk = encrypted.subarray(i, Math.min(i + chunkSize, encrypted.length));
        binaryStr += String.fromCharCode.apply(null, chunk);
    }
    return btoa(binaryStr);
}

function decryptPayload(base64Cipher) {
    try {
        const binaryStr = atob(base64Cipher);
        const encrypted = new Uint8Array(binaryStr.length);
        for (let i = 0; i < binaryStr.length; i++) {
            encrypted[i] = binaryStr.charCodeAt(i);
        }
        const decrypted = xorCrypt(encrypted, CONFIG.encryptionKey);
        return new TextDecoder().decode(decrypted);
    } catch (e) {
        return null;
    }
}

function validateUserAgent(request) {
    const ua = request.headers.get("User-Agent") || "";
    return ua === CONFIG.requiredUserAgent;
}

// Discord webhook logging
async function logToDiscord(type, data, request) {
    if (!CONFIG.discordWebhook) return;

    const ip = request?.headers?.get("cf-connecting-ip") || "Unknown";
    const country = request?.headers?.get("cf-ipcountry") || "Unknown";
    const timestamp = new Date().toISOString();

    let color = 0x9966ff; // Purple default
    let title = "Unknown Event";
    let fields = [];

    switch (type) {
        case "auth_success":
            color = 0x00ff00; // Green
            title = "Authorization Success";
            fields = [
                { name: "User", value: `${data.username || "Unknown"} (${data.userId || "N/A"})`, inline: true },
                { name: "API Key", value: `\`${data.apiKey?.substring(0, 8)}...\``, inline: true },
                { name: "Script", value: data.scriptId || "Menu Only", inline: true },
                { name: "Place ID", value: String(data.placeId || "N/A"), inline: true },
                { name: "IP", value: `\`${ip}\``, inline: true },
                { name: "Country", value: country, inline: true },
            ];
            break;
        case "auth_fail":
            color = 0xff0000; // Red
            title = "Authorization Failed";
            fields = [
                { name: "Reason", value: data.reason || "Unknown", inline: false },
                { name: "Attempted Key", value: `\`${data.apiKey?.substring(0, 12) || "None"}...\``, inline: true },
                { name: "User", value: `${data.username || "Unknown"} (${data.userId || "N/A"})`, inline: true },
                { name: "IP", value: `\`${ip}\``, inline: true },
                { name: "Country", value: country, inline: true },
            ];
            break;
        case "validate_success":
            color = 0x00aaff; // Blue
            title = "Token Validated";
            fields = [
                { name: "Script", value: data.scriptId || "Unknown", inline: true },
                { name: "User", value: `${data.username || "Unknown"} (${data.userId || "N/A"})`, inline: true },
                { name: "IP", value: `\`${ip}\``, inline: true },
            ];
            break;
        case "validate_fail":
            color = 0xff6600; // Orange
            title = "Validation Failed";
            fields = [
                { name: "Reason", value: data.reason || "Unknown", inline: false },
                { name: "Script", value: data.scriptId || "Unknown", inline: true },
                { name: "IP", value: `\`${ip}\``, inline: true },
                { name: "Country", value: country, inline: true },
            ];
            break;
        case "invalid_client":
            color = 0x8800ff; // Purple
            title = "Invalid Client Blocked";
            fields = [
                { name: "User-Agent", value: `\`${data.userAgent || "None"}\``, inline: false },
                { name: "Endpoint", value: data.endpoint || "Unknown", inline: true },
                { name: "IP", value: `\`${ip}\``, inline: true },
                { name: "Country", value: country, inline: true },
            ];
            break;
    }

    const embed = {
        title,
        color,
        fields,
        footer: { text: `Lunarity Auth System • ${timestamp}` },
        timestamp,
    };

    try {
        await fetch(CONFIG.discordWebhook, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ embeds: [embed] }),
        });
    } catch (e) {
        console.error("Discord webhook error:", e);
    }
}

function normalizeKey(raw) {
    return (raw || "").trim();
}

function buildScriptList(allowedIds) {
    return allowedIds
        .map((id) => {
            const meta = CONFIG.scripts[id];
            if (!meta || !meta.enabled) {
                return null;
            }
            return {
                id,
                label: meta.label,
                description: meta.description,
                version: meta.version,
            };
        })
        .filter(Boolean);
}

function randomToken(bytes = 16) {
    const buf = new Uint8Array(bytes);
    crypto.getRandomValues(buf);
    return [...buf].map((b) => b.toString(16).padStart(2, "0")).join("");
}

function buildTokenKey(token) {
    return CONFIG.tokenKvPrefix + token;
}

async function issueWhitelistToken(env, metadata) {
    const token = randomToken();
    const key = buildTokenKey(token);
    await env.SCRIPTS.put(key, JSON.stringify({
        scriptId: metadata.scriptId,
        userId: metadata.userId,
        username: metadata.username,
        issuedAt: Date.now(),
    }), { expirationTtl: CONFIG.loaderWhitelistTtl });
    return { token, expiresIn: CONFIG.loaderWhitelistTtl };
}

async function refreshWhitelistToken(env, token, record, ttl) {
    const key = buildTokenKey(token);
    await env.SCRIPTS.put(key, JSON.stringify(record), { expirationTtl: ttl });
}

async function handleLoader(env) {
    const source = await env.SCRIPTS.get(CONFIG.loaderKvKey, "text");
    if (!source) {
        return new Response("-- Loader not uploaded to KV (key: " + CONFIG.loaderKvKey + ")", {
            status: 503,
            headers: {
                "content-type": "text/plain; charset=utf-8",
                "cache-control": "no-store",
            },
        });
    }
    return new Response(source, {
        headers: {
            "content-type": "text/plain; charset=utf-8",
            "cache-control": "no-store",
        },
    });
}

async function handleAuthorize(request, env) {
    const killSwitch = (env?.KILL_SWITCH || "false").toLowerCase() === "true";
    if (killSwitch) {
        return jsonResponse({ ok: false, reason: "Global kill switch active." }, { status: 503 });
    }

    let bodyText;
    try {
        bodyText = await request.text();
    } catch (err) {
        return jsonResponse({ ok: false, reason: "Failed to read request body." }, { status: 400 });
    }

    // Try to decrypt if payload appears to be base64 encoded (encrypted)
    let decryptedBody = null;
    if (bodyText && !bodyText.startsWith("{")) {
        decryptedBody = decryptPayload(bodyText);
        if (decryptedBody) {
            bodyText = decryptedBody;
        }
    }

    let body;
    try {
        body = JSON.parse(bodyText);
    } catch (err) {
        console.error("JSON parse error:", err.message);
        console.error("Request body:", bodyText.substring(0, 500));
        return jsonResponse({
            ok: false,
            reason: "Invalid JSON payload.",
            debug: bodyText.substring(0, 200)
        }, { status: 400 });
    }

    const keyring = parseKeyring(env);
    const apiKey = normalizeKey(body.apiKey);
    const keyEntry = keyring[apiKey];
    if (!keyEntry) {
        await logToDiscord("auth_fail", {
            reason: "Invalid API key",
            apiKey: apiKey,
            username: body.username,
            userId: body.userId,
            placeId: body.placeId,
        }, request);
        return jsonResponse({ ok: false, reason: "Unauthorized: invalid API key." }, { status: 401 });
    }

    const allowedScripts = Array.isArray(keyEntry.allowedScripts) && keyEntry.allowedScripts.length > 0
        ? keyEntry.allowedScripts
        : Object.keys(CONFIG.scripts);

    const responseBase = {
        ok: true,
        message: "Authorization OK",
        scripts: buildScriptList(allowedScripts),
        actor: {
            label: keyEntry.label || "User",
            userId: body.userId,
            username: body.username,
            placeId: body.placeId,
        },
    };

    const scriptId = body.scriptId || body.script;
    if (!scriptId) {
        return jsonResponse(responseBase);
    }

    if (!allowedScripts.includes(scriptId)) {
        await logToDiscord("auth_fail", {
            reason: "Script not permitted for this key",
            apiKey: apiKey,
            scriptId: scriptId,
            username: body.username,
            userId: body.userId,
        }, request);
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
        username: body.username,
    });

    // Log successful authorization
    await logToDiscord("auth_success", {
        username: body.username,
        userId: body.userId,
        apiKey: apiKey,
        scriptId: scriptId,
        placeId: body.placeId,
    }, request);

    return jsonResponse({
        ...responseBase,
        script: scriptBody,
        scriptEncrypted: false,
        scriptMeta: {
            id: scriptId,
            label: scriptMeta.label,
            description: scriptMeta.description,
            version: scriptMeta.version,
        },
        accessToken: tokenInfo.token,
        expiresIn: tokenInfo.expiresIn,
        validatePath: "/validate",
    });
}

function handleHealth() {
    return jsonResponse({ ok: true });
}

async function handleValidate(request, env) {
    const killSwitch = (env?.KILL_SWITCH || "false").toLowerCase() === "true";
    if (killSwitch) {
        return jsonResponse({ ok: false, reason: "Kill switch active", killSwitch: true }, { status: 403 });
    }

    let bodyText;
    try {
        bodyText = await request.text();
    } catch (_err) {
        return jsonResponse({ ok: false, reason: "Failed to read request body." }, { status: 400 });
    }

    // Try to decrypt if payload appears to be base64 encoded (encrypted)
    if (bodyText && !bodyText.startsWith("{")) {
        const decrypted = decryptPayload(bodyText);
        if (decrypted) {
            bodyText = decrypted;
        }
    }

    let body;
    try {
        body = JSON.parse(bodyText);
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
        await logToDiscord("validate_fail", {
            reason: "Token expired or invalid (possible replay attack)",
            scriptId: body.scriptId,
        }, request);
        return jsonResponse({ ok: false, reason: "Token expired or invalid." }, { status: 401 });
    }

    if (body.scriptId && record.scriptId && body.scriptId !== record.scriptId) {
        await logToDiscord("validate_fail", {
            reason: "Token/script mismatch (tampering attempt)",
            scriptId: body.scriptId,
            expectedScriptId: record.scriptId,
        }, request);
        return jsonResponse({ ok: false, reason: "Token/script mismatch." }, { status: 403 });
    }

    // Dynamic Token Rotation: Delete old token and issue a new one
    // This prevents replay attacks - each token can only be used once
    await env.SCRIPTS.delete(tokenKey);

    const newTokenInfo = await issueWhitelistToken(env, {
        scriptId: record.scriptId,
        userId: record.userId,
        username: record.username,
    });

    // Extend TTL for the new token to sessionTtl
    await refreshWhitelistToken(env, newTokenInfo.token, {
        scriptId: record.scriptId,
        userId: record.userId,
        username: record.username,
        issuedAt: Date.now(),
    }, CONFIG.sessionTtl);

    // Log successful validation (rate-limited to avoid spam - only log occasionally)
    // Uncomment below if you want to log every heartbeat:
    // logToDiscord("validate_success", {
    //     scriptId: record.scriptId,
    //     username: record.username,
    //     userId: record.userId,
    // }, request);

    return jsonResponse({
        ok: true,
        scriptId: record.scriptId,
        expiresIn: CONFIG.sessionTtl,
        newToken: newTokenInfo.token, // Client must use this for next validation
    });
}

function handleNotFound() {
    return jsonResponse({ ok: false, reason: "Not found" }, { status: 404 });
}

export default {
    async fetch(request, env) {
        const url = new URL(request.url);

        if (request.method === "OPTIONS") {
            return new Response(null, { status: 204 });
        }

        if (url.pathname === "/" || url.pathname === "/loader") {
            return handleLoader(env);
        }

        // Serve LunarityUI module directly for scripts to load
        if (url.pathname === "/ui" || url.pathname === "/LunarityUI") {
            const source = await env.SCRIPTS.get("LunarityUI.lua", "text");
            if (!source) {
                return new Response("-- LunarityUI not uploaded to KV", {
                    status: 503,
                    headers: {
                        "content-type": "text/plain; charset=utf-8",
                        "cache-control": "no-store",
                    },
                });
            }
            return new Response(source, {
                headers: {
                    "content-type": "text/plain; charset=utf-8",
                    "cache-control": "no-store",
                },
            });
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
    },
};
