// Cloudflare Worker entry point for Lunarity authentication + script delivery
// Deploy with Wrangler and bind:
//   - R2 bucket named "SCRIPTS_BUCKET" for script storage (loader.lua, lunarity.lua, etc.)
// Provide an optional kill switch via KILL_SWITCH env var.
// Security: Uses HMAC-signed tokens (no KV required)

const CONFIG = {
    loaderR2Key: "loader.lua",
    sessionTtl: 600, // seconds tokens stay valid
    requiredUserAgent: "LunarityLoader/1.0",
    encryptionKey: "LunarityXOR2025!SecretKey", // XOR encryption key for payload obfuscation
    signingSecret: "LunarityHMAC2025!SigningKey", // HMAC signing key for tokens
    discordWebhook: "https://discord.com/api/webhooks/1424094994129485915/tj3RnyDn8DqMprbe-3Is4yuz-shQsHe--r4baFAQ9vGRdRaYqrENVeY92NR2DGUs7u94",
    scripts: {
        lunarityUI: {
            r2Key: "LunarityUI.lua",
            label: "Lunarity UI Module",
            description: "Shared ImGUI-style UI framework for all Lunarity scripts",
            version: "1.0.0",
            enabled: true,
        },
        lunarity: {
            r2Key: "lunarity.lua",
            label: "Lunarity · IFrames",
            description: "Advanced combat enhancer with IFrames + Anti-Debuff",
            version: "1.0.0",
            enabled: true,
        },
        doorEsp: {
            r2Key: "DoorESP.lua",
            label: "Door ESP · Halloween",
            description: "ESP and Auto-Candy support for Halloween doors",
            version: "1.0.0",
            enabled: true,
        },
        teleport: {
            r2Key: "Teleport.lua",
            label: "Teleport · Advanced",
            description: "Player and map teleportation with spoofing support",
            version: "1.0.0",
            enabled: true,
        },
        remoteLogger: {
            r2Key: "RemoteLogger.lua",
            label: "Remote Logger · Dev",
            description: "Developer tool that logs incoming/outgoing remotes",
            version: "1.0.0",
            enabled: true,
        },
        aetherShitter: {
            r2Key: "AetherShitterRecode.lua",
            label: "Aether Shitter · Recode",
            description: "Massive server destruction tool (Use with caution)",
            version: "1.0.0",
            enabled: true,
        },
        gamepassUnlocker: {
            r2Key: "GamepassUnlocker.lua",
            label: "Gamepass Unlocker",
            description: "Gamepass bypass proof of concept with namecall hooking and weapon injection",
            version: "1.0.0",
            enabled: true,
        },
        autofarm: {
            r2Key: "Autofarm.lua",
            label: "Autofarm · Void",
            description: "Automated farming with void teleportation and target tracking",
            version: "1.0.0",
            enabled: true,
        },
    },
};

// API Keys Configuration - Edit this object directly to add/remove keys
// No secrets or KV required - just modify this code and redeploy
const API_KEYS = {
    "demo-d3v-key": {
        label: "Developer",
        allowedScripts: ["lunarityUI", "lunarity", "doorEsp", "teleport", "remoteLogger", "aetherShitter", "gamepassUnlocker", "autofarm"],
    },
    "test-key-123": {
        label: "Tester",
        allowedScripts: ["lunarityUI", "lunarity", "doorEsp", "teleport", "gamepassUnlocker", "autofarm"],
    },
    "autofarm-only-key": {
        label: "Autofarm User",
        allowedScripts: ["lunarityUI", "autofarm"],
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

// HMAC-based token signing (no KV required)
async function hmacSign(data) {
    const encoder = new TextEncoder();
    const key = await crypto.subtle.importKey(
        "raw",
        encoder.encode(CONFIG.signingSecret),
        { name: "HMAC", hash: "SHA-256" },
        false,
        ["sign"]
    );
    const signature = await crypto.subtle.sign("HMAC", key, encoder.encode(data));
    return [...new Uint8Array(signature)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

async function hmacVerify(data, signature) {
    const expectedSignature = await hmacSign(data);
    return expectedSignature === signature;
}

// Create a signed token containing all session data (no server storage needed)
async function createSignedToken(metadata) {
    const payload = {
        scriptId: metadata.scriptId,
        userId: metadata.userId,
        username: metadata.username,
        issuedAt: Date.now(),
        expiresAt: Date.now() + (CONFIG.sessionTtl * 1000),
    };
    const payloadStr = JSON.stringify(payload);
    const payloadB64 = btoa(payloadStr);
    const signature = await hmacSign(payloadB64);
    // Token format: base64(payload).signature
    return { token: `${payloadB64}.${signature}`, expiresIn: CONFIG.sessionTtl };
}

// Verify and decode a signed token
async function verifySignedToken(token) {
    if (!token || typeof token !== "string") return null;

    const parts = token.split(".");
    if (parts.length !== 2) return null;

    const [payloadB64, signature] = parts;

    // Verify signature
    const isValid = await hmacVerify(payloadB64, signature);
    if (!isValid) return null;

    // Decode payload
    try {
        const payloadStr = atob(payloadB64);
        const payload = JSON.parse(payloadStr);

        // Check expiration
        if (payload.expiresAt && Date.now() > payload.expiresAt) {
            return null; // Token expired
        }

        return payload;
    } catch (e) {
        return null;
    }
}

async function handleLoader(env) {
    const object = await env.SCRIPTS_BUCKET.get(CONFIG.loaderR2Key);
    if (!object) {
        return new Response("-- Loader not uploaded to R2 (key: " + CONFIG.loaderR2Key + ")", {
            status: 503,
            headers: {
                "content-type": "text/plain; charset=utf-8",
                "cache-control": "no-store",
            },
        });
    }
    const source = await object.text();
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

    const scriptObject = await env.SCRIPTS_BUCKET.get(scriptMeta.r2Key);
    if (!scriptObject) {
        return jsonResponse({ ok: false, reason: `Script body missing in R2 (${scriptMeta.r2Key}).` }, { status: 500 });
    }
    const scriptBody = await scriptObject.text();

    const tokenInfo = await createSignedToken({
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

    // Verify the signed token (no KV lookup needed)
    const record = await verifySignedToken(token);
    if (!record) {
        await logToDiscord("validate_fail", {
            reason: "Token expired or invalid signature",
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

    // Issue a fresh signed token with extended expiry
    const newTokenInfo = await createSignedToken({
        scriptId: record.scriptId,
        userId: record.userId,
        username: record.username,
    });

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
            const object = await env.SCRIPTS_BUCKET.get("LunarityUI.lua");
            if (!object) {
                return new Response("-- LunarityUI not uploaded to R2", {
                    status: 503,
                    headers: {
                        "content-type": "text/plain; charset=utf-8",
                        "cache-control": "no-store",
                    },
                });
            }
            const source = await object.text();
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
