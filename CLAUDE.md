# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Lunarity is a Cloudflare Worker-based authentication and script delivery system for Roblox Lua scripts. It consists of two main components:

1. **Moonstar** (`Moonstar/`) - An advanced Lua/Luau obfuscator with VM-based protection
2. **Script Delivery System** - Cloudflare Worker + KV storage for authenticated script distribution

## Common Commands

### Moonstar Obfuscator

```bash
# Run obfuscation (from Moonstar directory)
cd Moonstar
lua moonstar.lua <input.lua> <output.lua> --preset=Medium

# Available presets: Minify, Weak, Medium, Strong
# Additional flags: --LuaU (for Roblox), --Lua51, --pretty, --debug, --detailed
```

### Luau Preprocessing

Scripts with Luau-specific syntax (`+=`, `-=`, `*=`, `/=`, `..=`) must be preprocessed first:

```bash
lua preprocess.lua <input.lua> <output.preprocessed.lua>
```

### Running Tests

```bash
cd Moonstar
lua5.1 runtests.lua                    # Run all tests with all presets
lua5.1 runtests.lua --preset=Medium    # Run with specific preset
lua5.1 runtests.lua test_simple        # Run specific test file
lua5.1 runtests.lua --compress         # Enable compression testing
```

### Cloudflare Worker Deployment

```bash
wrangler deploy --config wrangler.toml
wrangler kv key put "script.lua" --binding=SCRIPTS --path="script.obfuscated.lua" --config wrangler.toml --remote
wrangler tail --config wrangler.toml   # View live logs
```

## Architecture

### Moonstar Obfuscator Pipeline

The obfuscator uses a modular pipeline architecture:

```
moonstar.lua                 # CLI entry point
├── moonstar/src/moonstar/
│   ├── pipeline.lua         # Core pipeline orchestrator
│   ├── parser.lua           # Lua source -> AST
│   ├── unparser.lua         # AST -> Lua source
│   ├── tokenizer.lua        # Lexical analysis
│   ├── ast.lua              # AST node definitions
│   ├── scope.lua            # Variable scope tracking
│   ├── visitast.lua         # AST visitor pattern
│   └── steps/               # Obfuscation transformation steps
│       ├── WrapInFunction.lua
│       ├── EncryptStrings.lua
│       ├── ConstantArray.lua
│       ├── ConstantFolding.lua
│       ├── ControlFlowFlattening.lua
│       ├── Vmify.lua              # VM bytecode compilation
│       ├── VmProfileRandomizer.lua
│       ├── GlobalVirtualization.lua
│       ├── Compression.lua
│       └── AntiTamper.lua
└── presets/                 # Configuration presets (minify, weak, medium, strong)
```

**Pipeline Flow**: Source → Tokenizer → Parser → AST → Steps (transformations) → Unparser → Obfuscated Source

### Script Delivery System

```
cloudflare-worker.js     # Worker entry point (contains API_KEYS config)
├── /loader endpoint     # Serves obfuscated loader.lua
├── /authorize endpoint  # Validates API key, returns allowed scripts
├── /validate endpoint   # Token validation
└── /health endpoint     # Status check

loader.lua               # Client-side loader GUI
lunarity.lua             # Main combat script
DoorESP.lua              # ESP script
Teleport.lua             # Teleportation script
```

### Aurora Roblox Emulator

Located in `Moonstar/tests/setup/aurora/`, this is a mock Roblox environment for testing Luau scripts:

- `datatypes.lua` - Vector3, CFrame, Color3, UDim2, etc.
- `instance.lua` - Instance class with parent-child hierarchy
- `services.lua` - HttpService, Players, RunService, etc.
- `executor.lua` - getgenv, hookfunction, file operations
- `task.lua` - task.spawn, task.defer, task.delay
- `signal.lua` - RBXScriptSignal implementation
- `enum.lua` - Roblox Enum system

## Key Concepts

### Presets

Presets are Lua files in `Moonstar/presets/` that return configuration tables controlling which obfuscation steps to apply and their settings. Create custom presets by adding new `.lua` files to this directory.

### Name Generators

Located in `Moonstar/moonstar/src/moonstar/namegenerators/`:
- `Il.lua` - Uses only `I` and `l` characters
- `mangled.lua` - Random character sequences
- `mangled_shuffled.lua` - Shuffled mangled names
- `number.lua` - Numeric-only names
- `confuse.lua` - Visually confusing names

### Test Philosophy

Tests in `Moonstar/tests/` are real Lua programs that produce deterministic output. The test runner compares original vs obfuscated output to verify functionality preservation.
