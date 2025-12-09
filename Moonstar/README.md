# Moonstar - Advanced Lua/Luau Obfuscator

Moonstar is an advanced Lua/Luau obfuscator designed to provide high-level protection for your Lua scripts. It supports both Lua 5.1 and Roblox LuaU, offering multiple layers of security including VM-based obfuscation, anti-tamper protection, and instruction randomization.

## Features

- **Advanced Obfuscation Engine:** Utilizes a sophisticated pipeline to transform code.
- **Multiple Presets:** Built-in configurations ranging from simple minification to extreme protection.
- **VM-based Bytecode Compilation:** Compiles Lua code into a custom bytecode format executed by a virtual machine (`Vmify`).
- **Control Flow Flattening:** Flattens nested control structures into a complex state machine (`ControlFlowFlattening`).
- **Global Virtualization:** Hides global variables and mocks the environment to prevent hooking (`GlobalVirtualization`).
- **JIT String Encryption:** Replaces static strings with runtime-generated logic (`JitStringDecryptor`).
- **Anti-Tamper Protection:** Prevents unauthorized modification of the obfuscated script (`AntiTamper`).
- **Instruction Randomization:** Randomizes VM instructions to make reverse engineering more difficult (`VmProfileRandomizer`).
- **Compression:** Compresses the script using advanced algorithms (LZSS, Huffman, Arithmetic, PPM, BWT) to reduce file size and add another layer of obfuscation (`Compression`).
- **String Encryption:** Encrypts strings to hide sensitive information with multiple modes (Light, Standard, Polymorphic).
- **String Splitting:** Breaks long strings into smaller chunks to disrupt pattern matching (`SplitStrings`).
- **Constant Array:** Hides constants in a shuffled array to obscure their original location (`ConstantArray`).
- **Constant Folding:** Pre-calculates constant expressions to simplify code before obfuscation (`ConstantFolding`).
- **Number to Expression:** Converts plain numbers into complex arithmetic expressions (`NumbersToExpressions`).
- **Vararg Injection:** Injects unused vararg (`...`) parameters to confuse function signatures (`AddVararg`).
- **Local Proxification:** Wraps local variables in proxies to hide their values (`ProxifyLocals`).
- **Lua 5.1 & LuaU Support:** Fully compatible with standard Lua 5.1 and Roblox's LuaU.

## Bytecode Security & Performance

Moonstar includes advanced bytecode-level optimizations for both security and performance:

### Security Features

- **Opcode Shuffling (S1):** Randomizes block IDs per compilation, producing unique output each time
- **Dynamic Register Remapping (S2):** Permutes register indices with Fisher-Yates shuffle and injects ghost registers
- **Multi-Layer String Encryption (S4):** Chains XOR → Caesar → Substitution encryption with unique keys per string
- **Instruction Polymorphism (S6):** Generates semantically equivalent but syntactically different code patterns

### Performance Optimizations

- **Loop Invariant Code Motion (P10):** Hoists invariant computations out of loops
- **Peephole Optimization (P11):** Removes redundant copies, dead stores, and identity operations
- **Small Function Inlining (P12):** Inlines small functions (≤10 statements) at call sites
- **Common Subexpression Elimination (P14):** Reuses previously computed expression results
- **Strength Reduction (P15):** Replaces expensive operations (x*2 → x+x, x^2 → x*x)
- **Inline Caching (P9):** Caches resolved global lookups for frequently accessed globals
- **Table Pre-sizing (P17):** Emits table constructors with size hints when known
- **Vararg Optimization (P18):** Optimizes `...` handling for common patterns

### Configuration

Enable/disable features in your config:

```lua
{
    -- Security
    enableOpcodeShuffling = true,
    enableRegisterRemapping = true,
    ghostRegisterDensity = 15,
    enableMultiLayerEncryption = true,
    encryptionLayers = 3,
    enableInstructionPolymorphism = true,
    polymorphismRate = 50,
    
    -- Performance
    enableLICM = true,
    enablePeepholeOptimization = true,
    enableFunctionInlining = true,
    enableCSE = true,
    enableStrengthReduction = true,
    enableTablePresizing = true,
    enableVarargOptimization = true,
}
```

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
