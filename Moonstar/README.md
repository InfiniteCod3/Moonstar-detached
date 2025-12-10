# Moonstar - Advanced Lua/Luau Obfuscator

Moonstar is an advanced Lua/Luau obfuscator designed to provide high-level protection for your Lua scripts. It supports both Lua 5.1 and Roblox LuaU, offering multiple layers of security including VM-based obfuscation, anti-tamper protection, and instruction randomization.

## Features

### Core Obfuscation
- **VM-based Bytecode** — Custom bytecode format with embedded virtual machine
- **Control Flow Flattening** — Converts nested structures into opaque state machines
- **Global Virtualization** — Hides globals and mocks environment to prevent hooking
- **Anti-Tamper Protection** — Detects and prevents runtime code modifications
- **Compression** — LZSS, Huffman, Arithmetic, PPM, or BWT compression

### String & Constant Protection
- **Multi-Mode String Encryption** — Light, Standard, or Polymorphic encryption modes
- **Multi-Layer Encryption** — Chains XOR → Caesar → Substitution with unique keys
- **JIT String Decryption** — Runtime-generated decryption logic
- **String Splitting** — Breaks strings into chunks to defeat pattern matching
- **Constant Array** — Hides constants in shuffled arrays with obfuscated indices
- **Numbers to Expressions** — Converts literals into complex arithmetic expressions

### Bytecode Security
- **Opcode Shuffling** — Unique randomized block IDs per compilation
- **Dynamic Register Remapping** — Fisher-Yates shuffled registers with ghost writes
- **Instruction Polymorphism** — Semantically equivalent but syntactically different code
- **Encrypted Block IDs** — XOR-encrypted dispatch with per-compilation seed
- **Randomized BST Order** — Shuffled binary search tree comparisons

### Bytecode Performance
- **Loop Invariant Code Motion** — Hoists invariant computations out of loops
- **Peephole Optimization** — Eliminates redundant copies, dead stores, identity ops
- **Function Inlining** — Inlines small functions (≤10 statements) at call sites
- **Common Subexpression Elimination** — Reuses previously computed expressions
- **Strength Reduction** — Converts expensive ops (x*2 → x+x, x^2 → x*x)
- **Copy Propagation** — Eliminates redundant register copies
- **Allocation Sinking** — Defers/eliminates unnecessary memory allocations
- **Inline Caching** — Caches frequently accessed global lookups
- **Table Pre-sizing** — Emits size hints for table constructors
- **Vararg Optimization** — Optimizes `select('#', ...)` and `{...}[n]` patterns
- **Tail Call Optimization** — Proper tail call emission for eligible returns
- **Loop Unrolling** — Unrolls small constant-bound loops (≤8 iterations)
- **Dead Code Elimination** — Removes unreachable blocks and dead stores
- **Aggressive Block Inlining** — Inlines single-predecessor and hot-path blocks
- **Constant Hoisting** — Promotes frequently-used globals to locals

### Additional
- **Multiple Presets** — `Minify`, `Weak`, `Medium`, `Strong`
- **Lua 5.1 & LuaU Support** — Full compatibility with standard Lua and Roblox
- **Vararg Injection** — Confuses function signatures with unused `...`
- **Local Proxification** — Wraps local variables in proxies
- **VM Profile Randomizer** — Permutes opcodes and handler names

## Installation

Moonstar requires **Lua 5.1** to run.

To install dependencies on Debian/Ubuntu:

```bash
sudo apt-get update && sudo apt-get install -y lua5.1
```

## Usage

Run Moonstar using the `lua` (or `lua5.1`) command:

```bash
lua moonstar.lua <input_file> [options]
```

### Arguments

- `input_file`: Path to the Lua/Luau file you want to obfuscate.
- `--out <file>`: Path where the obfuscated script will be saved (default: `<input_file>.obfuscated.lua`).

### Options

- `--preset=X`: Select a configuration preset (default: `Minify`).
  - **Available Presets:** `Minify`, `Weak`, `Medium`, `Strong`
- `--config=<file>`: Load configuration from a specific file.
- `--LuaU`: Target LuaU (Roblox).
- `--Lua51`: Target Lua 5.1 (default).
- `--pretty`: Enable pretty printing for readable output (useful for debugging).
- `--nocolors`: Disable colored output.
- `--saveerrors`: Save error messages to a file.
- `--seed=N`: Set a specific random seed for reproducible output.

### Presets

**Minify** — No obfuscation, just minification.
- **Features:** None (structure preservation only)

**Weak** — Basic protection against casual snooping.
- **Features:** `WrapInFunction`, `EncryptStrings` (Light), `SplitStrings`, `ConstantArray`, `NumbersToExpressions`

**Medium** — Balanced protection for general use.
- **Features:** All Weak features plus `EncryptStrings` (Standard), `IndexObfuscation`, `AddVararg`

**Strong** — Maximum protection for sensitive logic.
- **Features:** All Medium features plus `ControlFlowFlattening`, `GlobalVirtualization`, `AntiTamper`, `Vmify`, `VmProfileRandomizer`, `Compression`

### Examples

**Basic usage (Medium preset):**
```bash
lua moonstar.lua myscript.lua --preset=Medium
```

**Maximum protection:**
```bash
lua moonstar.lua myscript.lua --preset=Strong --out output.lua
```

**For Roblox (LuaU):**
```bash
lua moonstar.lua script.lua --preset=Medium --LuaU
```

**Minify only:**
```bash
lua moonstar.lua script.lua --preset=Minify
```

## Testing

To run the test suite:

```bash
lua5.1 runtests.lua
```

### Testing Luau and Roblox Scripts

Moonstar includes a comprehensive mock Roblox environment emulator called **Aurora** to allow for testing Luau code that uses Roblox-specific APIs.

#### Aurora Emulator

- **Location:** `tests/setup/aurora/` (modular) or `tests/setup/aurora.lua` (compatibility wrapper)
- **Architecture:** Modular design split across multiple files for maintainability

#### Modules

| Module | Description |
|--------|-------------|
| `signal.lua` | RBXScriptSignal implementation with Connect, Once, Wait, Fire, Disconnect |
| `typeof.lua` | Roblox-style `typeof()` function with custom type registration |
| `datatypes.lua` | Vector2, Vector3, CFrame, Color3, UDim, UDim2, Ray, BrickColor, TweenInfo, and more |
| `instance.lua` | Full Instance class with Parent/Children, FindFirstChild, IsA, Clone, Attributes |
| `services.lua` | HttpService, RunService, TweenService, Players, Debris, and other services |
| `executor.lua` | Executor environment: getgenv, hookfunction, file operations, rconsole |
| `task.lua` | Task library: task.spawn, task.defer, task.delay, task.wait, task.cancel |
| `enum.lua` | Complete Enum system (KeyCode, UserInputType, EasingStyle, Material, etc.) |
| `init.lua` | Main loader that combines all modules and sets up the environment |

#### Supported Features

**Data Types:**
- Vector2, Vector3, CFrame (with full rotation/transformation methods)
- Color3 (fromRGB, fromHSV, Lerp)
- UDim, UDim2, Rect, NumberRange
- ColorSequence, NumberSequence
- Ray, RaycastParams, BrickColor
- TweenInfo, Axes, Faces

**Instance System:**
- Full parent-child hierarchy with proper synchronization
- Class inheritance via `IsA()`
- FindFirstChild, FindFirstChildOfClass, FindFirstChildWhichIsA
- GetChildren, GetDescendants, GetFullName
- WaitForChild (with timeout support)
- Attributes (SetAttribute, GetAttribute, GetAttributes)
- Clone with deep copy of children
- Destroy with proper cleanup

**Services:**
- `HttpService`: JSONEncode, JSONDecode, GenerateGUID, UrlEncode
- `RunService`: Heartbeat, RenderStepped, Stepped signals
- `TweenService`: Create tweens with full easing support
- `Players`: LocalPlayer mock with Character
- `UserInputService`: Input type detection, GetMouseLocation
- `Debris`: AddItem for delayed destruction

**Executor Globals:**
- Environment: getgenv, getrenv, getreg, getgc
- Hooking: hookfunction, hookmetamethod
- Metatables: getrawmetatable, setrawmetatable, setreadonly
- Upvalues: getupvalues, setupvalue, getconstants
- File System: isfile, isfolder, readfile, writefile, appendfile, delfile, makefolder
- Console: rconsoleprint, rconsolewarn, rconsoleerr, rconsoleclear, rconsoleinfo
- Clipboard: setclipboard, getclipboard
- HTTP: request, http_request, syn.request

**Task Library:**
- task.spawn, task.defer, task.delay
- task.wait, task.cancel

When `runtests.lua` is executed, it automatically discovers and runs `.luau` files found in the `tests/` directory. The Aurora emulator is prepended to each `.luau` test file at runtime, allowing you to write tests using Roblox APIs.

To add a new Roblox-specific test:
1. Create a new file with a `.luau` extension inside the `tests/luau/` directory.
2. Write your test code using standard Roblox APIs.

The test runner will handle the rest.

## Copyright

© 2025 Moonstar. All rights reserved.
