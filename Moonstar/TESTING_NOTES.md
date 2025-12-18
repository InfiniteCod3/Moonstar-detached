# Moonstar Testing Notes

## Bugs Fixed (December 2024)

### 1. ConstantArray NaN Table Key Crash

**File:** `moonstar/src/moonstar/steps/ConstantArray.lua`

**Issue:** The obfuscator crashed with "table index is NaN" when processing code containing NaN values (e.g., `0/0`, `math.sqrt(-1)`).

**Root Cause:** NaN cannot be used as a table key in Lua because `NaN ~= NaN`. The `addConstant` and `getConstant` functions were trying to use NaN as a key in the `self.lookup` table.

**Fix:** Added NaN checks to skip NaN values in constant array processing:
```lua
-- Skip NaN values - they cannot be used as table keys (NaN ~= NaN)
if type(value) == "number" and value ~= value then
    return nil
end
```

**Affected functions:**
- `ConstantArray:getConstant()` (line ~196)
- `ConstantArray:addConstant()` (line ~211)
- Shuffle loop rebuild (line ~513)

---

### 2. Unparser NaN Literal Output

**File:** `moonstar/src/moonstar/unparser.lua`

**Issue:** When outputting NaN values, the unparser would output `nan` or `-nan` as literal text, which is invalid Lua syntax.

**Root Cause:** The unparser handled `inf` and `-inf` specially (converting to `2e1024`), but had no handling for NaN values. Lua's `tostring()` on NaN returns "nan" or "-nan" depending on platform.

**Fix:** Added NaN pattern matching to convert to `(0/0)`:
```lua
-- Handle NaN (can appear as "nan", "-nan", "NaN", "-NaN", etc.)
if(str:match("^%-?[nN][aA][nN]$")) then
    return "(0/0)"
end
```

---

### 3. Unparser Negative Number Power Precedence

**File:** `moonstar/src/moonstar/unparser.lua`

**Issue:** Expressions like `(-1)^inf` were being output as `-1^inf`, which has different semantics due to operator precedence.

**Root Cause:** In Lua, `-1^2` is parsed as `-(1^2) = -1`, but `(-1)^2 = 1`. When constant folding produced a NumberExpression with value `-1`, the unparser didn't add parentheses before the `^` operator.

**Fix:** Added check for negative NumberExpression on left side of PowExpression:
```lua
-- Handle negative numbers on the left side of ^ operator
-- -1^2 is parsed as -(1^2) = -1, but (-1)^2 = 1
if(expression.lhs.kind == AstKind.NumberExpression and expression.lhs.value < 0) then
    lhs = "(" .. lhs .. ")";
end
```

---

## Known Test Failures (Strong Preset)

The following tests fail only on the **Strong** preset due to VM (Vmify) limitations. They pass on Minify, Weak, and Medium presets.

### 1. tests/global_metatable.lua - Strong Preset

**Error:** `C stack overflow`

**Cause:** The test sets custom metatables on `_G` with `__index` and `__newindex` metamethods. When the VM-based obfuscator (Vmify) tries to access globals through its virtualized environment, it triggers the metatable repeatedly, causing infinite recursion.

**Details:**
- The VM intercepts global access for security purposes
- Custom metatables on `_G` create a feedback loop with VM's global interception
- This is an inherent limitation of combining VM virtualization with metatable-driven globals

**Workaround:** Avoid using custom metatables on `_G` in scripts that will be obfuscated with the Strong preset.

---

### 2. tests/tail_calls.lua - Strong Preset

**Error:** `C stack overflow` or runtime error

**Cause:** The test includes deep mutual tail call chains (e.g., `state_a -> state_b -> state_c -> state_a`). The VM's instruction dispatch mechanism doesn't properly implement tail call optimization, causing stack buildup.

**Details:**
- Lua's tail call optimization normally prevents stack growth for `return func()` patterns
- The VM transforms code into bytecode interpreted in a dispatch loop
- This dispatch loop doesn't preserve Lua's tail call semantics
- Deep tail call chains exhaust the C stack

**Workaround:** For code with heavy tail recursion, consider using Weak or Medium presets instead of Strong.

---

## Test Coverage Added (December 2024)

| Test File | Purpose | Notes |
|-----------|---------|-------|
| `tests/deep_recursion.lua` | Tests deep recursive algorithms (quicksort, mergesort, ackermann, fibonacci, tree traversal) | Passes all presets |
| `tests/tail_calls.lua` | Tests tail call optimization, mutual recursion, state machines | Fails Strong (VM limitation) |
| `tests/extreme_numbers.lua` | Tests NaN, Inf, -0, floating point edge cases | Found 3 bugs, now passes |
| `tests/global_metatable.lua` | Tests metatables on `_G`, lazy initialization, access tracking | Fails Strong (VM limitation) |
| `tests/luau/environment_fenv.luau` | Tests getfenv/setfenv interactions | Requires Aurora emulator |

---

## Test Results Summary

```
Total Tests:   128 (32 files × 4 presets)
Passed:        122
Failed:        2 (Strong preset VM limitations)
Skipped:       4 (Aurora environment requirements)
Success Rate:  95.3%
```
