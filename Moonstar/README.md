# Moonstar - Advanced Lua/Luau Obfuscator

Moonstar is an advanced Lua/Luau obfuscator designed to provide high-level protection for your Lua scripts. It supports both Lua 5.1 and Roblox LuaU, offering multiple layers of security including VM-based obfuscation, anti-tamper protection, and instruction randomization.

## Features

- **Advanced Obfuscation Engine:** Utilizes a sophisticated pipeline to transform code.
- **Multiple Presets:** Built-in configurations ranging from simple minification to extreme protection.
- **VM-based Bytecode Compilation:** Compiles Lua code into a custom bytecode format executed by a virtual machine.
- **Anti-Tamper Protection:** Prevents unauthorized modification of the obfuscated script.
- **Instruction Randomization:** Randomizes VM instructions to make reverse engineering more difficult.
- **Control Flow Obfuscation:** Transforms control structures to confuse decompilers.
- **String Encryption:** Encrypts strings to hide sensitive information.
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
lua moonstar.lua <input_file> <output_file> [options]
```

### Arguments

- `input_file`: Path to the Lua/Luau file you want to obfuscate.
- `output_file`: Path where the obfuscated script will be saved.

### Options

- `--preset=X`: Select a configuration preset (default: `Medium`).
  - **Available Presets:** `Minify`, `Weak`, `Medium`, `Strong`
- `--LuaU`: Target LuaU (Roblox).
- `--Lua51`: Target Lua 5.1 (default).
- `--pretty`: Enable pretty printing for readable output (useful for debugging).
- `--no-antitamper`: Disable anti-tamper protection (for `Medium` and `Strong` presets).
- `--seed=N`: Set a specific random seed for reproducible output.

### Presets

| Preset | Description | Recommended For |
| :--- | :--- | :--- |
| **Minify** | No obfuscation, just minification. | reducing file size |
| **Weak** | Basic VM protection (Vmify + constant array). | light protection |
| **Medium** | Balanced protection (Encryption + VM + all features). | general use (Recommended) |
| **Strong** | Maximum protection (Double VM + all features). | sensitive logic |

### Examples

**Basic usage (Medium preset):**
```bash
lua moonstar.lua myscript.lua output.lua
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
