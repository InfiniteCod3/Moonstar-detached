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

Moonstar includes a mock Roblox environment emulator called **Aurora** to allow for testing Luau code that uses Roblox-specific APIs.

- **Location:** `tests/setup/aurora.lua`
- **Functionality:** Mocks common Roblox globals like `game`, `workspace`, `Instance`, `Players`, and various data types.

When `runtests.lua` is executed, it automatically discovers and runs `.luau` files found in the `tests/` directory. The Aurora emulator is prepended to each `.luau` test file at runtime, allowing you to write tests using Roblox APIs.

To add a new Roblox-specific test:
1. Create a new file with a `.luau` extension inside the `tests/luau/` directory.
2. Write your test code using standard Roblox APIs.

The test runner will handle the rest.

## Copyright

© 2025 Moonstar. All rights reserved.
