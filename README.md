# Lunarity - Obfuscated Script Delivery System

A Cloudflare Worker-based authentication and script delivery system with Moonstar obfuscation for protecting your Roblox Lua scripts.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Worker Setup & Deployment](#worker-setup--deployment)
- [Script Obfuscation](#script-obfuscation)
- [Authentication Management](#authentication-management)
- [Quick Reference](#quick-reference)
- [Testing](#testing)
- [Moonstar Test Files](#moonstar-test-files)
- [Troubleshooting](#troubleshooting)
- [File Structure](#file-structure)

## 🎯 Overview

This system allows you to:
1. **Obfuscate** your Lua scripts using Moonstar
2. **Store** obfuscated scripts in Cloudflare KV
3. **Distribute** scripts via API with authentication
4. **Control** access with customizable API keys

Users load the loader script, authenticate with an API key, and receive obfuscated scripts that are nearly impossible to read or reverse engineer.

## ✨ Features

- **Moonstar Obfuscation**: Medium preset with string encryption, control flow obfuscation, and anti-tamper
- **API Key Authentication**: Simple key-based access control (no complex secrets)
- **Token Whitelisting**: Temporary tokens prevent unauthorized sharing
- **Multiple Scripts**: Support for multiple scripts (Lunarity, DoorESP, Teleport)
- **Kill Switch**: Optional global disable mechanism
- **Zero KV Secrets**: Authentication keys are directly in the worker code for easy editing

## 📜 Available Scripts

### Lunarity · IFrames
Advanced combat enhancer with IFrames and Anti-Debuff capabilities. Features a modern GUI with keybinds and persistent settings.

**Features:**
- IFrames toggle with customizable duration
- Anti-Debuff system
- Persistent keybind configuration
- Sleek purple-themed UI

### Door ESP · Halloween
ESP and Auto-Candy support for Halloween event doors with real-time tracking and filtering.

**Features:**
- Door type detection (Evil, Candy, Souls, Nothing)
- Billboard and tracer ESP
- Auto-candy collection
- In-game console logging
- Configurable distance and refresh rate

### Teleport · Advanced
Player and map teleportation tool with advanced spoofing capabilities and a modern interface.

**Features:**
- Teleport individual players or everyone at once
- Spoof as another player for teleportation
- Teleport map parts and objects
- Modern purple-themed GUI matching other scripts
- Real-time player list with visual indicators
- E key shortcut for quick teleportation

## 📦 Prerequisites

### Required Software

1. **Node.js** (v16 or later) - [Download](https://nodejs.org/)
2. **Wrangler CLI** - Cloudflare's deployment tool
   ```powershell
   npm install -g wrangler
   ```
3. **Lua 5.1** - For running the obfuscator
   - Download from [luabinaries.sourceforge.net](http://luabinaries.sourceforge.net/)
   - Or install via [Chocolatey](https://chocolatey.org/): `choco install lua`

### Cloudflare Account Setup

1. Create a [Cloudflare account](https://dash.cloudflare.com/sign-up)
2. Get your Account ID from the Workers dashboard
3. Authenticate Wrangler:
   ```powershell
   wrangler login
   ```

## 🚀 Initial Setup

### 1. Clone/Download This Repository

```powershell
cd C:\Users\YourName\Downloads
git clone https://github.com/YourRepo/Lunarity.git
cd Lunarity
```

### 2. Install Dependencies

```powershell
npm install
```

### 3. Create KV Namespace

```powershell
wrangler kv:namespace create SCRIPTS --config wrangler.toml
```

This will output a namespace ID. Update `wrangler.toml`:

```toml
[[kv_namespaces]]
binding = "SCRIPTS"
id = "your_namespace_id_here"  # Replace with the ID from the command above
```

### 4. Configure Custom Domain (Optional)

In `wrangler.toml`, update the domain:

```toml
[[routes]]
pattern = "api.yourdomain.com"  # Change to your domain
custom_domain = true
```

Or remove the routes section to use the default `*.workers.dev` domain.

---

## 🔧 Worker Setup & Deployment

This section explains how to deploy the Cloudflare Worker so it can act as an authentication layer, kill switch, and script host for `lunarity.lua`, `DoorESP.lua`, and the `loader.lua` GUI.

### 1. Upload Script Assets to KV

Each script is read by the worker from KV. Upload the three Lua files:

```bash
wrangler kv:key put --namespace-id <namespace-id> loader.lua "$(cat loader.lua)"
wrangler kv:key put --namespace-id <namespace-id> lunarity.lua "$(cat lunarity.lua)"
wrangler kv:key put --namespace-id <namespace-id> DoorESP.lua "$(cat DoorESP.lua)"
wrangler kv:key put --namespace-id <namespace-id> Teleport.lua "$(cat Teleport.lua)"
```

> ⚠️ KV has a 25 MB per-entry limit—these files are far below that.

### 2. Configure API Keys

Define the API keys + script permissions via a Worker secret named `API_KEYS`. The value is JSON:

```bash
wrangler secret put API_KEYS
# paste JSON like the following when prompted
{"lunarity-master":{"label":"Owner","allowedScripts":["lunarity","doorEsp","teleport"]},"esp-only":{"label":"Friend","allowedScripts":["doorEsp"]}}
```

You can revoke access by deleting a key or removing a script from `allowedScripts`.

### 3. Optional Kill Switch

Set the `KILL_SWITCH` environment variable to `true` whenever you want to disable every script instantly:

```bash
wrangler secret put KILL_SWITCH
# enter either true or false (defaults to false when unset)
```

Set it back to `false` (or delete the secret) to re-enable access.

### 4. Deploy the Worker

Use the provided `cloudflare-worker.js` as your Worker entry point:

```bash
wrangler deploy cloudflare-worker.js --name aetherfalls-lunarity
```

Verify the health endpoint:

```bash
curl https://aetherfalls-lunarity.workers.dev/health
```

### 5. Update loader.lua

- Edit `WORKER_BASE_URL` near the top of `loader.lua` to match your deployed worker URL (e.g., `https://aetherfalls-lunarity.workers.dev`).
- Re-upload `loader.lua` to KV after making changes so the served version stays in sync.

### 6. Client Usage

End users can run the loader directly via loadstring:

```lua
loadstring(game:HttpGet("https://api.relayed.network/loader"))()
```

Loader workflow:

1. User enters their API key.
2. Loader calls `/authorize` with user details; worker returns permitted scripts.
3. User clicks either **Lunarity · IFrames**, **Door ESP · Halloween**, or **Teleport · Advanced**.
4. Loader requests the chosen script; worker re-validates and returns the raw Lua source.
5. Loader executes the script with `loadstring`, inheriting the existing UIs.

### 7. Managing Script Availability

- Disable a single module by setting `enabled = false` in `CONFIG.scripts` within `cloudflare-worker.js` and redeploying.
- Remove or edit KV entries to push updated script logic.
- Flip the global kill switch when you need to stop all access without touching the scripts themselves.

With this pipeline in place, both Lua scripts are now protected by the worker-level authentication, and you can instantly revoke keys or bring the entire toolset offline when needed.

---

## 🔒 Script Obfuscation

### Obfuscating Your Scripts

The obfuscation process converts Luau syntax to Lua 5.1, then applies Moonstar obfuscation.

#### 1. Place Your Scripts

Put your `.lua` files in the root directory:
- `loader.lua` - The initial loader script
- `lunarity.lua` - Main combat script
- `DoorESP.lua` - ESP script
- `Teleport.lua` - Teleportation script
- (Add more as needed)

#### 2. Preprocess Luau Syntax

If your scripts use Luau-specific syntax (like `+=`, `-=`), preprocess them first:

```powershell
lua preprocess.lua your-script.lua your-script.preprocessed.lua
```

#### 3. Run Moonstar Obfuscator

Navigate to the Moonstar directory and obfuscate:

```powershell
cd Moonstar
lua moonstar.lua ../loader.lua ../loader.obfuscated.lua --preset=Medium
lua moonstar.lua ../lunarity.preprocessed.lua ../lunarity.obfuscated.lua --preset=Medium
lua moonstar.lua ../DoorESP.preprocessed.lua ../DoorESP.obfuscated.lua --preset=Medium
lua moonstar.lua ../Teleport.lua ../Teleport.obfuscated.lua --preset=Medium
cd ..
```

**Preset Options:**
- `Minify` - No obfuscation (just minification)
- `Weak` - Basic VM protection
- `Medium` - Balanced protection (⭐ **Recommended**)
- `Strong` - Maximum protection (larger file size)

#### 4. Upload to KV

Upload the obfuscated scripts to Cloudflare KV:

```powershell
wrangler kv key put "loader.lua" --binding=SCRIPTS --path="loader.obfuscated.lua" --config wrangler.toml --remote

wrangler kv key put "lunarity.lua" --binding=SCRIPTS --path="lunarity.obfuscated.lua" --config wrangler.toml --remote

wrangler kv key put "DoorESP.lua" --binding=SCRIPTS --path="DoorESP.obfuscated.lua" --config wrangler.toml --remote

wrangler kv key put "Teleport.lua" --binding=SCRIPTS --path="Teleport.obfuscated.lua" --config wrangler.toml --remote
```

#### Complete Obfuscation Script

For convenience, you can run all steps at once:

```powershell
# Preprocess
lua preprocess.lua lunarity.lua lunarity.preprocessed.lua
lua preprocess.lua DoorESP.lua DoorESP.preprocessed.lua

# Obfuscate
cd Moonstar
lua moonstar.lua ../loader.lua ../loader.obfuscated.lua --preset=Medium
lua moonstar.lua ../lunarity.preprocessed.lua ../lunarity.obfuscated.lua --preset=Medium
lua moonstar.lua ../DoorESP.preprocessed.lua ../DoorESP.obfuscated.lua --preset=Medium
lua moonstar.lua ../Teleport.lua ../Teleport.obfuscated.lua --preset=Medium
cd ..

# Upload to KV
wrangler kv key put "loader.lua" --binding=SCRIPTS --path="loader.obfuscated.lua" --config wrangler.toml --remote
wrangler kv key put "lunarity.lua" --binding=SCRIPTS --path="lunarity.obfuscated.lua" --config wrangler.toml --remote
wrangler kv key put "DoorESP.lua" --binding=SCRIPTS --path="DoorESP.obfuscated.lua" --config wrangler.toml --remote
wrangler kv key put "Teleport.lua" --binding=SCRIPTS --path="Teleport.obfuscated.lua" --config wrangler.toml --remote
```

### Obfuscation Statistics

Typical obfuscation results with Medium preset:

| Script | Original Size | Obfuscated Size | Ratio |
|--------|---------------|-----------------|-------|
| loader.lua | 16 KB | 72 KB | 454% |
| lunarity.lua | 71 KB | 260 KB | 357% |
| DoorESP.lua | 40 KB | 139 KB | 345% |
| Teleport.lua | 24 KB | 85 KB | 354% |

---

## 🔑 Authentication Management

### Adding/Removing API Keys

API keys are now **directly in the worker code** for easy modification. No secrets required!

#### Edit the API Keys

Open `cloudflare-worker.js` and find the `API_KEYS` object at the top:

```javascript
const API_KEYS = {
    "demo-dev-key": {
        label: "Developer",
        allowedScripts: ["lunarity", "doorEsp", "teleport"],
    },
    "test-key-123": {
        label: "Tester",
        allowedScripts: ["lunarity", "doorEsp", "teleport"],
    },
    // Add your keys here:
    "my-custom-key-abc123": {
        label: "Premium User",
        allowedScripts: ["lunarity", "doorEsp", "teleport"],
    },
};
```

#### Key Configuration

Each key has:
- **Key string** - The actual API key users will use
- **label** - A friendly name for tracking
- **allowedScripts** - Array of script IDs they can access
  - `"lunarity"` - Main combat script
  - `"doorEsp"` - ESP script
  - `"teleport"` - Teleportation script
  - Use `["lunarity", "doorEsp", "teleport"]` for all scripts

#### Deploy Changes

After editing API keys, redeploy the worker:

```powershell
wrangler deploy --config wrangler.toml
```

Changes take effect immediately (within seconds).

### Managing Scripts

Edit the `CONFIG.scripts` object in `cloudflare-worker.js`:

```javascript
const CONFIG = {
    // ... other config ...
    scripts: {
        lunarity: {
            kvKey: "lunarity.lua",
            label: "Lunarity · IFrames",
            description: "Advanced combat enhancer",
            version: "1.0.0",
            enabled: true,
        },
        doorEsp: {
            kvKey: "DoorESP.lua",
            label: "Door ESP · Halloween",
            description: "ESP and Auto-Candy support",
            version: "1.0.0",
            enabled: true,
        },
        // Add new scripts:
        myNewScript: {
            kvKey: "mynewscript.lua",  // Key in KV
            label: "My New Script",
            description: "Does cool stuff",
            version: "1.0.0",
            enabled: true,
        },
    },
};
```

Don't forget to upload the script to KV and redeploy!

---

## ⚡ Quick Reference

### Common Operations

#### Add a New API Key

1. Open `cloudflare-worker.js`
2. Find the `API_KEYS` object (around line 30)
3. Add your new key:
   ```javascript
   "your-new-key-here": {
       label: "User Name",
       allowedScripts: ["lunarity", "doorEsp", "teleport"],
   },
   ```
4. Save and deploy:
   ```powershell
   wrangler deploy --config wrangler.toml
   ```

#### Remove an API Key

1. Open `cloudflare-worker.js`
2. Delete or comment out the key in `API_KEYS`
3. Deploy:
   ```powershell
   wrangler deploy --config wrangler.toml
   ```

#### Update a Script

Complete workflow for updating any script:

```powershell
# 1. Edit your script (e.g., lunarity.lua)
# 2. Preprocess if it has Luau syntax
lua preprocess.lua lunarity.lua lunarity.preprocessed.lua

# 3. Obfuscate
cd Moonstar
lua moonstar.lua ../lunarity.preprocessed.lua ../lunarity.obfuscated.lua --preset=Strong
cd ..

# 4. Upload to KV
wrangler kv key put "lunarity.lua" --binding=SCRIPTS --path="lunarity.obfuscated.lua" --config wrangler.toml --remote
```

#### Update the Loader

The loader is special because it needs the correct worker URL:

```powershell
# 1. Edit loader.lua - update WORKER_BASE_URL if needed
# 2. Obfuscate (loader doesn't need preprocessing)
cd Moonstar
lua moonstar.lua ../loader.lua ../loader.obfuscated.lua --preset=Strong
cd ..

# 3. Upload to KV
wrangler kv key put "loader.lua" --binding=SCRIPTS --path="loader.obfuscated.lua" --config wrangler.toml --remote
```

#### Add a New Script

1. **Add to worker config** - Edit `cloudflare-worker.js`:
   ```javascript
   const CONFIG = {
       // ... existing config ...
       scripts: {
           // ... existing scripts ...
           myNewScript: {
               kvKey: "mynewscript.lua",
               label: "My New Script",
               description: "Description here",
               version: "1.0.0",
               enabled: true,
           },
       },
   };
   ```

2. **Preprocess and obfuscate**:
   ```powershell
   lua preprocess.lua mynewscript.lua mynewscript.preprocessed.lua
   cd Moonstar
   lua moonstar.lua ../mynewscript.preprocessed.lua ../mynewscript.obfuscated.lua --preset=Strong
   cd ..
   ```

3. **Upload to KV**:
   ```powershell
   wrangler kv key put "mynewscript.lua" --binding=SCRIPTS --path="mynewscript.obfuscated.lua" --config wrangler.toml --remote
   ```

4. **Deploy worker**:
   ```powershell
   wrangler deploy --config wrangler.toml
   ```

5. **Update API keys** to allow access to the new script:
   ```javascript
   const API_KEYS = {
       "some-key": {
           label: "User",
           allowedScripts: ["lunarity", "doorEsp", "teleport", "myNewScript"],  // Add here
       },
   };
   ```

6. **Redeploy**:
   ```powershell
   wrangler deploy --config wrangler.toml
   ```

#### View KV Contents

```powershell
# List all keys
wrangler kv key list --binding=SCRIPTS --config wrangler.toml --remote

# View a specific key (first 10 lines)
wrangler kv key get "loader.lua" --binding=SCRIPTS --config wrangler.toml --remote | Select-Object -First 10
```

#### Delete from KV

```powershell
wrangler kv key delete "script-name.lua" --binding=SCRIPTS --config wrangler.toml --remote
```

#### Test Authentication

```powershell
# Test with curl (PowerShell)
$body = @{
    apiKey = "demo-dev-key"
    userId = 123456
    username = "TestUser"
    placeId = 123456789
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.relayed.network/authorize" -Method POST -Body $body -ContentType "application/json"
```

#### Enable Kill Switch

1. Set environment variable in Cloudflare dashboard:
   - Go to Workers & Pages
   - Select your worker
   - Settings → Variables
   - Add: `KILL_SWITCH` = `true`

2. Or in `wrangler.toml`:
   ```toml
   [env.production]
   vars = { KILL_SWITCH = "true" }
   ```

3. Redeploy:
   ```powershell
   wrangler deploy --config wrangler.toml
   ```

#### View Worker Logs

```powershell
wrangler tail --config wrangler.toml
```

This shows real-time logs from your worker.

### Troubleshooting Commands

#### Check Worker Status

```powershell
wrangler whoami
wrangler deployments list --config wrangler.toml
```

#### Validate Worker Code

```powershell
# Check JavaScript syntax
node -c cloudflare-worker.js

# Dry-run deployment
wrangler deploy --config wrangler.toml --dry-run
```

#### Re-authenticate Wrangler

```powershell
wrangler logout
wrangler login
```

#### Check KV Namespace

```powershell
wrangler kv namespace list
```

### One-Line Commands

#### Full Update All Scripts
```powershell
lua preprocess.lua lunarity.lua lunarity.preprocessed.lua; lua preprocess.lua DoorESP.lua DoorESP.preprocessed.lua; cd Moonstar; lua moonstar.lua ../loader.lua ../loader.obfuscated.lua --preset=Strong; lua moonstar.lua ../lunarity.preprocessed.lua ../lunarity.obfuscated.lua --preset=Strong; lua moonstar.lua ../DoorESP.preprocessed.lua ../DoorESP.obfuscated.lua --preset=Strong; lua moonstar.lua ../Teleport.lua ../Teleport.obfuscated.lua --preset=Strong; cd ..; wrangler kv key put "loader.lua" --binding=SCRIPTS --path="loader.obfuscated.lua" --config wrangler.toml --remote; wrangler kv key put "lunarity.lua" --binding=SCRIPTS --path="lunarity.obfuscated.lua" --config wrangler.toml --remote; wrangler kv key put "DoorESP.lua" --binding=SCRIPTS --path="DoorESP.obfuscated.lua" --config wrangler.toml --remote; wrangler kv key put "Teleport.lua" --binding=SCRIPTS --path="Teleport.obfuscated.lua" --config wrangler.toml --remote
```

#### Quick Script Update (Lunarity)
```powershell
lua preprocess.lua lunarity.lua lunarity.preprocessed.lua; cd Moonstar; lua moonstar.lua ../lunarity.preprocessed.lua ../lunarity.obfuscated.lua --preset=Strong; cd ..; wrangler kv key put "lunarity.lua" --binding=SCRIPTS --path="lunarity.obfuscated.lua" --config wrangler.toml --remote
```

#### Quick Loader Update
```powershell
cd Moonstar; lua moonstar.lua ../loader.lua ../loader.obfuscated.lua --preset=Strong; cd ..; wrangler kv key put "loader.lua" --binding=SCRIPTS --path="loader.obfuscated.lua" --config wrangler.toml --remote
```

### URLs

- **Loader**: `https://api.relayed.network/loader`
- **Authorize**: `https://api.relayed.network/authorize` (POST)
- **Validate**: `https://api.relayed.network/validate` (POST)
- **Health**: `https://api.relayed.network/health`

### Typical Workflow

1. **Make changes** to original scripts
2. **Preprocess** if needed
3. **Obfuscate** with Moonstar
4. **Upload** to KV
5. **Test** in-game
6. **Repeat** as needed

No need to redeploy the worker unless you changed `cloudflare-worker.js` (API keys or script config).

---

## 🧪 Testing

### Test the Loader Endpoint

```powershell
curl https://api.yourdomain.com/loader
```

Should return obfuscated Lua code.

### Test Authentication

```powershell
curl -X POST https://api.yourdomain.com/authorize `
  -H "Content-Type: application/json" `
  -d '{
    "apiKey": "demo-dev-key",
    "userId": 123456,
    "username": "TestUser",
    "placeId": 123456789
  }'
```

Should return:
```json
{
  "ok": true,
  "message": "Authorization OK",
  "scripts": [
    {
      "id": "lunarity",
      "label": "Lunarity · IFrames",
      ...
    }
  ]
}
```

### Test Script Delivery

```powershell
curl -X POST https://api.yourdomain.com/authorize `
  -H "Content-Type: application/json" `
  -d '{
    "apiKey": "demo-dev-key",
    "scriptId": "lunarity",
    "userId": 123456,
    "username": "TestUser",
    "placeId": 123456789
  }'
```

Should return obfuscated script code in the response.

### In-Game Testing

1. Load the obfuscated loader in your Roblox executor:
   ```lua
   loadstring(game:HttpGet("https://api.yourdomain.com/loader"))()
   ```

2. Enter one of your API keys (e.g., `demo-dev-key`)

3. Select a script to load

4. Verify the script works correctly

---

## 🧪 Moonstar Test Files

The `Moonstar/tests` directory contains functional Lua programs used to test the obfuscator. Each test is a real, working Lua program that produces clear output, allowing us to verify that obfuscation preserves functionality.

### Test Files

#### Basic Tests
- **test_simple.lua** - Basic arithmetic, functions, conditionals, and loops
- **test_comprehensive.lua** - Fibonacci, tables, and string operations
- **test_metamethod.lua** - Metamethods and table features

#### Advanced Tests
- **test_advanced.lua** - Closures, metatables, and complex logic
- **test_strings.lua** - String manipulation and pattern matching
- **test_control_flow.lua** - Loops, conditionals, and control structures
- **test_functions.lua** - Function features, recursion, and higher-order functions
- **test_tables.lua** - Table operations, sorting, and manipulation

#### Luau/Roblox Tests (Not included in automated test suite)
- **test_luau.lua** - Luau-specific syntax features
- **test_luau_comprehensive.lua** - Comprehensive Luau feature testing

**Note:** Luau tests contain Luau-specific syntax (type annotations, continue statements, etc.) that are not compatible with standard Lua 5.1. These files are intended to be:
1. Obfuscated with the `--LuaU` flag
2. Run in a Luau environment (e.g., Roblox)

The obfuscator strips Luau syntax when processing these files, but the output is designed for Luau environments and may not run correctly in standard Lua 5.1.

### Running Tests

Use the `run_tests.lua` script to test obfuscation:

```bash
# Run a single test with Minify preset (default)
lua run_tests.lua test_simple

# Run a test with a specific preset
lua run_tests.lua test_advanced Medium

# Run all tests with Strong preset
lua run_tests.lua all Strong
```

#### Comprehensive Test Suite

Use the `run_all_tests.lua` script to run all tests with all presets:

```bash
# Run all tests with all presets (Minify, Weak, Medium, Strong, Panic)
lua run_all_tests.lua
```

This script runs all 8 tests with all 5 presets (40 test combinations total) and provides a comprehensive summary of results.

### Test Philosophy

These tests follow a simple principle: **real programs with real output**.

Instead of testing specific obfuscation techniques or internal features, we:
1. Run the original Lua program and capture its output
2. Obfuscate the program with Moonstar
3. Run the obfuscated version and capture its output
4. Compare the outputs - they should be identical

This approach ensures that:
- Obfuscation preserves program functionality
- All Lua features work correctly after obfuscation
- The tests are easy to understand and maintain
- We catch real-world issues, not just implementation details

### Adding New Tests

To add a new test:
1. Create a `.lua` file in the `tests` directory
2. Write a functional Lua program that prints clear output
3. Add the test name to the `tests` array in `run_tests.lua`
4. Run the test to verify it works

Good tests:
- ✓ Print clear, deterministic output
- ✓ Test real Lua features
- ✓ Are self-contained and easy to understand
- ✓ Demonstrate practical use cases

Bad tests:
- ✗ Test internal implementation details
- ✗ Require external dependencies
- ✗ Have non-deterministic output (random numbers, time-based)
- ✗ Test obfuscator-specific features rather than program functionality

---

## 🐛 Troubleshooting

### Obfuscation Errors

**Problem**: `Parsing Error at Position X:Y`

**Solution**: Your script has Luau-specific syntax. Run the preprocessor:
```powershell
lua preprocess.lua your-script.lua your-script.preprocessed.lua
```
Then obfuscate the `.preprocessed.lua` file.

---

**Problem**: Obfuscated script is too large

**Solution**: Use `--preset=Weak` instead of `Medium`:
```powershell
lua moonstar.lua input.lua output.lua --preset=Weak
```

### Deployment Errors

**Problem**: `namespace-id not found`

**Solution**: Create the KV namespace first:
```powershell
wrangler kv:namespace create SCRIPTS --config wrangler.toml
```
Update the `id` in `wrangler.toml` with the output.

---

**Problem**: `Error: Cannot read wrangler.toml`

**Solution**: Always specify `--config wrangler.toml`:
```powershell
wrangler deploy --config wrangler.toml
```

---

**Problem**: Changes not reflecting

**Solution**: 
1. Clear KV cache: `wrangler kv key delete "script-name.lua" --binding=SCRIPTS --config wrangler.toml --remote`
2. Re-upload: `wrangler kv key put ...`
3. Redeploy: `wrangler deploy --config wrangler.toml`

### Runtime Errors

**Problem**: `Loader validation failed`

**Solution**: Ensure the loader's `WORKER_BASE_URL` matches your deployed worker URL.

---

**Problem**: `Authorization denied`

**Solution**: Check that:
1. API key exists in `API_KEYS` object
2. Script ID is in the key's `allowedScripts` array
3. Worker has been redeployed after changes

---

**Problem**: Script loads but doesn't work

**Solution**: 
1. Check obfuscation didn't break functionality
2. Test the original (non-obfuscated) script first
3. Try a weaker obfuscation preset (`Weak` or `Minify`)

---

## 📁 File Structure

```
Lunarity/
├── README.md                      # This comprehensive guide
├── wrangler.toml                  # Worker configuration
├── cloudflare-worker.js           # Worker code (contains API_KEYS)
├── package.json                   # Node dependencies
├── preprocess.lua                 # Luau → Lua 5.1 converter
├── loader.lua                     # Original loader script
├── lunarity.lua                   # Original main script
├── DoorESP.lua                    # Original ESP script
├── Teleport.lua                   # Original teleport script
├── loader.obfuscated.lua          # Obfuscated loader
├── lunarity.obfuscated.lua        # Obfuscated main script
├── DoorESP.obfuscated.lua         # Obfuscated ESP script
├── Teleport.obfuscated.lua        # Obfuscated teleport script
└── Moonstar/                      # Obfuscator
    ├── moonstar.lua               # Obfuscator CLI
    ├── banner.txt                 # ASCII banner
    ├── run_tests.lua              # Test runner
    ├── run_all_tests.lua          # Comprehensive test runner
    ├── moonstar/                  # Obfuscator modules
    │   └── src/
    │       ├── moonstar.lua       # Core obfuscator
    │       └── ...
    ├── tests/                     # Test files
    │   ├── README.md              # Test documentation
    │   ├── test_simple.lua        # Basic tests
    │   ├── test_comprehensive.lua # Advanced tests
    │   └── ...
    └── output/                    # Test output directory
        └── ...
```

---

## 🔄 Update Workflow

When updating scripts:

1. **Edit** your original `.lua` files
2. **Preprocess** if needed (for Luau syntax)
3. **Obfuscate** with Moonstar
4. **Upload** to KV
5. **Deploy** worker (if you changed `cloudflare-worker.js`)

```powershell
# Quick update script
lua preprocess.lua lunarity.lua lunarity.preprocessed.lua
cd Moonstar
lua moonstar.lua ../lunarity.preprocessed.lua ../lunarity.obfuscated.lua --preset=Medium
cd ..
wrangler kv key put "lunarity.lua" --binding=SCRIPTS --path="lunarity.obfuscated.lua" --config wrangler.toml --remote
```

---

## 🔐 Security Notes

- **API Keys**: Store keys securely. Don't commit them to public repos.
- **Obfuscation**: Not encryption. Determined attackers can still reverse engineer.
- **Token System**: Tokens expire to prevent sharing of access.
- **Kill Switch**: Set `KILL_SWITCH=true` in environment variables to disable all access.

---

## 📝 License

Customize this section for your license.

---

## 🤝 Contributing

Contributions welcome! Please open an issue or PR.

---

## 📞 Support

For issues or questions:
- Open a GitHub issue
- Contact: your-contact-info

---

**Built with:**
- [Moonstar](https://github.com/InfiniteCod3/Moonstar) - Lua obfuscator
- [Cloudflare Workers](https://workers.cloudflare.com/) - Edge computing platform
- [Wrangler](https://developers.cloudflare.com/workers/wrangler/) - CLI tool
