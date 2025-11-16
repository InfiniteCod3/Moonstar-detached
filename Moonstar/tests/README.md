# Moonstar Test Files

This directory contains functional Lua programs used to test the obfuscator.
Each test is a real, working Lua program that produces clear output, allowing
us to verify that obfuscation preserves functionality.

## Test Files

### Basic Tests
- **test_simple.lua** - Basic arithmetic, functions, conditionals, and loops
- **test_comprehensive.lua** - Fibonacci, tables, and string operations
- **test_metamethod.lua** - Metamethods and table features

### Advanced Tests
- **test_advanced.lua** - Closures, metatables, and complex logic
- **test_strings.lua** - String manipulation and pattern matching
- **test_control_flow.lua** - Loops, conditionals, and control structures
- **test_functions.lua** - Function features, recursion, and higher-order functions
- **test_tables.lua** - Table operations, sorting, and manipulation

### Luau/Roblox Tests (Not included in automated test suite)
- **test_luau.lua** - Luau-specific syntax features
- **test_luau_comprehensive.lua** - Comprehensive Luau feature testing

**Note:** Luau tests contain Luau-specific syntax (type annotations, continue statements, etc.) 
that are not compatible with standard Lua 5.1. These files are intended to be:
1. Obfuscated with the `--LuaU` flag
2. Run in a Luau environment (e.g., Roblox)

The obfuscator strips Luau syntax when processing these files, but the output is designed 
for Luau environments and may not run correctly in standard Lua 5.1.

## Running Tests

Use the `run_tests.lua` script to test obfuscation:

```bash
# Run a single test with Minify preset (default)
lua run_tests.lua test_simple

# Run a test with a specific preset
lua run_tests.lua test_advanced Medium

# Run all tests with Strong preset
lua run_tests.lua all Strong
```

### Comprehensive Test Suite

Use the `run_all_tests.lua` script to run all tests with all presets:

```bash
# Run all tests with all presets (Minify, Weak, Medium, Strong, Panic)
lua run_all_tests.lua
```

This script runs all 8 tests with all 5 presets (40 test combinations total) and provides a comprehensive summary of results.

## Test Philosophy

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

## Adding New Tests

To add a new test:
1. Create a `.lua` file in this directory
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
