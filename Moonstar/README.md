# Moonstar - Advanced Lua/Luau Obfuscator

Moonstar is an advanced Lua/Luau obfuscator designed to provide high-level protection for your Lua scripts. It supports both Lua 5.1 and Roblox LuaU, offering multiple layers of security including VM-based obfuscation, anti-tamper protection, and instruction randomization.

## Features

- **Advanced Obfuscation Engine:** Utilizes a sophisticated pipeline to transform code.
- **Modular Presets:** Presets are stored as individual `.lua` files in `presets/` for easy customization.
- **VM-based Bytecode Compilation:** Compiles Lua code into a custom bytecode format executed by a virtual machine (`Vmify`).
- **Control Flow Flattening:** Flattens nested control structures into a complex state machine (`ControlFlowFlattening`).
- **Global Virtualization:** Hides global variables and mocks the environment to prevent hooking (`GlobalVirtualization`).

- **Anti-Tamper Protection:** Prevents unauthorized modification of the obfuscated script (`AntiTamper`).
- **Instruction Randomization:** Randomizes VM instructions to make reverse engineering more difficult (`VmProfileRandomizer`).
- **Compression:** Compresses the script using advanced algorithms (LZSS, Huffman, Arithmetic, PPM, BWT) to reduce file size and add another layer of obfuscation (`Compression`).
- **String Encryption:** Encrypts strings to hide sensitive information with multiple modes (Light, Standard, Polymorphic).
- **String Splitting:** Breaks long strings into smaller chunks to disrupt pattern matching (`SplitStrings`).
- **Constant Array:** Hides constants in a shuffled array to obscure their original location (`ConstantArray`).
- **Constant Folding:** Pre-calculates constant expressions to simplify code before obfuscation (`ConstantFolding`).
- **Number to Expression:** Converts plain numbers into complex arithmetic expressions (`NumbersToExpressions`).
- **Vararg Injection:** Injects unused vararg (`...`) parameters to confuse function signatures (`AddVararg`).

- **Lua 5.1 & LuaU Support:** Fully compatible with standard Lua 5.1 and Roblox's LuaU.

## Installation

Moonstar requires **Lua 5.1** to run.

To install dependencies on Debian/Ubuntu:

```bash
sudo apt-get update && sudo apt-get install -y lua5.1
```

## Project Structure

```
Moonstar/
├── moonstar.lua          # Main entry point (consolidated CLI + library)
├── presets/              # Preset configuration files
│   ├── minify.lua        # No obfuscation, just minification
│   ├── weak.lua          # Basic protection
│   ├── medium.lua        # Balanced protection (recommended)
│   └── strong.lua        # Maximum protection
├── moonstar/src/         # Core obfuscator modules
│   ├── config.lua
│   ├── logger.lua
│   ├── colors.lua
│   ├── highlightlua.lua
│   └── moonstar/         # Pipeline, steps, compiler, etc.
├── tests/                # Test suite
├── examples/             # Example scripts
└── banner.txt            # Optional banner for obfuscated output
```

## Usage

Run Moonstar using the `lua` (or `lua5.1`) command:

```bash
lua moonstar.lua <input_file> <output_file> [options]
```

### Arguments

- `input_file`: Path to the Lua/Luau file you want to obfuscate.
- `output_file`: Path where the obfuscated script will be saved.

### Options

- `--preset=X`: Select a configuration preset (default: `Medium`).
  - **Built-in Presets:** `Minify`, `Weak`, `Medium`, `Strong`
  - **Custom Presets:** Place a `.lua` file in `presets/` and use its name
- `--LuaU`: Target LuaU (Roblox).
- `--Lua51`: Target Lua 5.1 (default).
- `--pretty`: Enable pretty printing for readable output (useful for debugging).
- `--no-antitamper`: Disable anti-tamper protection.
- `--seed=N`: Set a specific random seed for reproducible output.
- `--detailed`: Show detailed build report with step timings.
- `--compress`: Enable compression of output.
- `--parallel=N`: Number of parallel compression tests (default: 4).
- `--debug`: Enable debug mode (verbose logging, fixed seed, pretty printing).

### Presets

Presets are stored in the `presets/` folder as individual Lua files that return configuration tables.

**Minify** (`presets/minify.lua`) — No obfuscation, just minification.
- **Features:** None (structure preservation only)

**Weak** (`presets/weak.lua`) — Basic protection against casual snooping.
- **Features:** `WrapInFunction`, `EncryptStrings` (Light), `SplitStrings`, `ConstantArray`, `NumbersToExpressions`

**Medium** (`presets/medium.lua`) — Balanced protection for general use.
- **Features:** All Weak features plus `EncryptStrings` (Standard), `IndexObfuscation`, `AddVararg`

**Strong** (`presets/strong.lua`) — Maximum protection for sensitive logic.
- **Features:** All Medium features plus `ControlFlowFlattening`, `GlobalVirtualization`, `AntiTamper`, `Vmify`, `VmProfileRandomizer`, `Compression`

### Custom Presets

To create a custom preset, add a new `.lua` file to the `presets/` folder that returns a configuration table:

```lua
-- presets/mycustom.lua
return {
    LuaVersion    = "Lua51";
    VarNamePrefix = "";
    NameGenerator = "MangledShuffled";
    PrettyPrint   = false;
    Seed          = 0;

    WrapInFunction = { Enabled = true };
    EncryptStrings = { Enabled = true; Mode = "standard" };
    -- Add more configuration as needed
}
```

Then use it with `--preset=mycustom`.

### Examples

**Basic usage (Medium preset):**
```bash
lua moonstar.lua myscript.lua output.lua --preset=Medium
```

**Maximum protection:**
```bash
lua moonstar.lua myscript.lua output.lua --preset=Strong
```

**For Roblox (LuaU):**
```bash
lua moonstar.lua script.lua output.lua --preset=Medium --LuaU
```

**Minify only:**
```bash
lua moonstar.lua script.lua output.lua --preset=Minify
```

**Debug mode with detailed report:**
```bash
lua moonstar.lua script.lua output.lua --preset=Strong --debug --detailed
```

## Using as a Library

Moonstar can also be used as a Lua library in your own scripts:

```lua
-- Add Moonstar to your package path
package.path = "./Moonstar/moonstar/src/?.lua;" ..
               "./Moonstar/moonstar/src/moonstar/?.lua;" ..
               package.path

-- Require Moonstar
local Moonstar = require("Moonstar.moonstar")

-- Access components
local Pipeline = Moonstar.Pipeline
local Presets = Moonstar.Presets
local Logger = Moonstar.Logger

-- Get a preset configuration
local config = Moonstar.getPreset("Strong")

-- Create and use a pipeline
local pipeline = Pipeline:fromConfig(config)
local obfuscated = pipeline:apply(sourceCode, "input.lua")
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
