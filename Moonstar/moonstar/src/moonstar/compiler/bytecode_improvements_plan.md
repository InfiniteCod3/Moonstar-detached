# Moonstar Bytecode Improvements Plan v2.0

> **Created:** 2025-12-09 | **Target:** `moonstar/src/moonstar/compiler/`  
> **Status:** 14/20 Features Completed (70%)

---

## Summary

This document tracks the bytecode security and performance improvements for the Moonstar compiler. The implementation is organized into 6 sprints, with Sprints 1-3 and Sprint 5 complete.

### Completed Features ✅

| ID | Feature | Type | Files |
|----|---------|------|-------|
| S1 | Opcode Shuffling | Security | `init.lua`, `vm.lua` |
| S2 | Dynamic Register Remapping | Security | `registers.lua` |
| S4 | Multi-Layer String Encryption | Security | `vmConstantEncryptor.lua` |
| S6 | Instruction Polymorphism | Security | `expressions.lua`, `statements.lua` |
| P9 | Inline Caching | Performance | `expressions.lua` (integrated with P3 constant hoisting) |
| P10 | Loop Invariant Code Motion | Performance | `licm.lua` |
| P11 | Peephole Optimization | Performance | `peephole.lua` |
| P12 | Small Function Inlining | Performance | `inlining.lua` |
| P14 | Common Subexpression Elimination | Performance | `cse.lua` |
| P15 | Strength Reduction | Performance | `expressions.lua` |
| P17 | Table Pre-sizing | Performance | `expressions.lua`, `table_presizing.lua` |
| P18 | Vararg Optimization | Performance | `statements.lua`, `vararg_optimization.lua` |

### Pending Features

| ID | Feature | Type | Difficulty | Files |
|----|---------|------|------------|-------|
| S3 | Fake Control Flow Paths | Security | High | new `opaque_predicates.lua` |
| S5 | Anti-Tampering Checksums | Security | High | new `integrity.lua` |
| S7 | Metamethod Traps | Security | Medium | `vm.lua` |
| S8 | Environment Sandboxing | Security | Low | `init.lua` |
| S9 | Control Flow Obfuscation | Security | High | `statements.lua` |
| S10 | Anti-Debug Detection | Security | Medium | new `antidebug.lua` |
| P13 | Graph Coloring Registers | Performance | Very High | new `graph_coloring.lua` |
| P16 | Branch Prediction Hints | Performance | Medium | `statements.lua` |

---

## Configuration Reference

All implemented features can be configured via compiler options:

```lua
{
    -- Security (Implemented)
    enableOpcodeShuffling = true,         -- S1
    enableRegisterRemapping = true,       -- S2
    ghostRegisterDensity = 15,            -- S2
    enableMultiLayerEncryption = true,    -- S4
    encryptionLayers = 3,                 -- S4
    enableInstructionPolymorphism = true, -- S6
    polymorphismRate = 50,                -- S6
    
    -- Performance (Implemented)
    enableInlineCaching = false,          -- P9
    inlineCacheThreshold = 5,             -- P9
    enableLICM = false,                   -- P10
    licmMinIterations = 2,                -- P10
    enablePeepholeOptimization = true,    -- P11
    maxPeepholeIterations = 5,            -- P11
    enableFunctionInlining = false,       -- P12
    maxInlineFunctionSize = 10,           -- P12
    enableCSE = false,                    -- P14
    enableStrengthReduction = true,       -- P15
    enableTablePresizing = false,         -- P17
    enableVarargOptimization = false,     -- P18
    
    -- Security (Not Yet Implemented)
    enableFakeControlFlow = false,        -- S3
    fakePathDensity = 20,                 -- S3
    enableIntegrityChecks = false,        -- S5
    integrityResponseMode = "silent",     -- S5
    enableMetamethodTraps = false,        -- S7
    enableEnvironmentSandbox = false,     -- S8
    enableControlFlowFlattening = false,  -- S9
    enableAntiDebug = false,              -- S10
    
    -- Performance (Not Yet Implemented)
    useGraphColoring = false,             -- P13
    enableBranchHints = false,            -- P16
}
```

---

## Implementation Files

### Created Files
- `licm.lua` - Loop Invariant Code Motion (P10)
- `peephole.lua` - Peephole Optimization (P11)
- `inlining.lua` - Small Function Inlining (P12)
- `cse.lua` - Common Subexpression Elimination (P14)
- `inline_cache.lua` - Inline Caching for Globals (P9)
- `table_presizing.lua` - Table Pre-sizing (P17)
- `vararg_optimization.lua` - Vararg Optimization (P18)

### Files to Create (Pending)
- `opaque_predicates.lua` (S3)
- `integrity.lua` (S5)
- `antidebug.lua` (S10)
- `liveness.lua` (P13)
- `graph_coloring.lua` (P13)

---

## Remaining Implementation Details

### S3: Fake Control Flow Paths

**Goal:** Inject opaque predicates and honeypot blocks.

#### New File: `opaque_predicates.lua`
```lua
local OpaquePredicates = {}

OpaquePredicates.alwaysFalse = {
    function(env) -- type(nil) == "function"
        return Ast.EqualsExpression(
            Ast.FunctionCallExpression(Ast.IndexExpression(env, Ast.StringExpression("type")), {Ast.NilExpression()}),
            Ast.StringExpression("function"))
    end,
    function(env) -- math.pi < 3
        return Ast.LessThanExpression(
            Ast.IndexExpression(Ast.IndexExpression(env, Ast.StringExpression("math")), Ast.StringExpression("pi")),
            Ast.NumberExpression(3))
    end,
    -- Add 8+ more predicates
}

function OpaquePredicates.getRandomFalse(env)
    return OpaquePredicates.alwaysFalse[math.random(1, #OpaquePredicates.alwaysFalse)](env)
end

return OpaquePredicates
```

#### Tasks
- [ ] **S3.1** Create `opaque_predicates.lua` with 10+ predicates
- [ ] **S3.2** Create `VmGen.createHoneypotBlock()` with dead-end code
- [ ] **S3.3** Inject fake branches in `IfStatement` (20% density)
- [ ] **S3.4** Mark honeypots to skip dead code elimination
- [ ] **S3.5** Add config: `enableFakeControlFlow`, `fakePathDensity`

---

### S5: Anti-Tampering Checksums

**Goal:** Hash critical blocks, verify at runtime.

#### New File: `integrity.lua`
```lua
local Integrity = {}

function Integrity.hashString(str)
    local hash = 5381
    for i = 1, #str do hash = ((hash * 33) + string.byte(str, i)) % (2^32) end
    return hash
end

function Integrity.hashBlock(block)
    local parts = {}
    for _, stmt in ipairs(block.statements) do
        table.insert(parts, tostring(stmt.statement.kind or "x"))
    end
    return Integrity.hashString(table.concat(parts, ","))
end

return Integrity
```

#### Tasks
- [ ] **S5.1** Create `integrity.lua` with DJB2 hash
- [ ] **S5.2** Compute checksums after block finalization
- [ ] **S5.3** Inject verification at random points (not startup)
- [ ] **S5.4** Implement response modes: `silent`, `delay`, `decoy`, `exit`
- [ ] **S5.5** Add config: `enableIntegrityChecks`, `integrityResponseMode`

---

### S7: Metamethod Traps

**Goal:** Use metatables to hide actual values/operations.

#### Tasks
- [ ] **S7.1** Create trap table generator with `__index`, `__call`, `__add` etc.
- [ ] **S7.2** Wrap critical values in proxy tables
- [ ] **S7.3** Implement lazy evaluation via `__index`
- [ ] **S7.4** Add decoy metamethods that trigger on tampering
- [ ] **S7.5** Add config: `enableMetamethodTraps`, `trapDensity`

---

### S8: Environment Sandboxing

**Goal:** Create isolated `_ENV` with restricted access patterns.

#### Tasks
- [ ] **S8.1** Generate custom `_ENV` wrapper at VM start
- [ ] **S8.2** Whitelist allowed globals
- [ ] **S8.3** Intercept `rawget`/`rawset` attempts
- [ ] **S8.4** Add shadow environment for decoy values
- [ ] **S8.5** Add config: `enableEnvironmentSandbox`, `allowedGlobals`

---

### S9: Control Flow Obfuscation (Flattening Lite)

**Goal:** Convert structured control flow to switch-based dispatch.

#### Tasks
- [ ] **S9.1** Identify "flattenable" function bodies (no complex upvalues)
- [ ] **S9.2** Number each basic block
- [ ] **S9.3** Create state variable for current block
- [ ] **S9.4** Generate `while true do` loop with block dispatch
- [ ] **S9.5** Randomize block order in dispatch table
- [ ] **S9.6** Add config: `enableControlFlowFlattening`, `flattenThreshold`

---

### S10: Anti-Debug Detection

**Goal:** Detect debugging attempts and alter behavior.

#### New File: `antidebug.lua`
```lua
local AntiDebug = {}

AntiDebug.checks = {
    function(env) -- Check if debug library exists and is modified
        return Ast.NotEqualsExpression(
            Ast.FunctionCallExpression(Ast.IndexExpression(env, Ast.StringExpression("type")),
                {Ast.IndexExpression(env, Ast.StringExpression("debug"))}),
            Ast.StringExpression("table"))
    end,
    function(env) -- Timing check placeholder
        -- If execution too slow, someone is stepping through
    end,
}

return AntiDebug
```

#### Tasks
- [ ] **S10.1** Create `antidebug.lua` with detection methods
- [ ] **S10.2** Check for `debug` library tampering
- [ ] **S10.3** Add timing-based checks (optional, may have false positives)
- [ ] **S10.4** Implement response actions (same as S5)
- [ ] **S10.5** Add config: `enableAntiDebug`, `antiDebugResponseMode`

---

### P13: Graph Coloring Register Allocation

**Goal:** Optimal register allocation via liveness analysis.

#### New Files: `liveness.lua`, `graph_coloring.lua`

#### Tasks
- [ ] **P13.1** Implement live-in/live-out computation (fixed-point iteration)
- [ ] **P13.2** Build interference graph from overlapping live ranges
- [ ] **P13.3** Implement graph coloring with simplify/select phases
- [ ] **P13.4** Handle spills: store/load to overflow table
- [ ] **P13.5** Two-phase compilation: virtual regs → coloring → physical regs
- [ ] **P13.6** Add config: `useGraphColoring`

---

### P15: Strength Reduction (Remaining)

One pattern still deferred:
- [ ] **P15.4** Add modulo optimization for power of 2 divisors (requires bit32/bit ops)

---

### P16: Branch Prediction Hints

**Goal:** Reorder branches to favor likely paths.

#### Tasks
- [ ] **P16.1** Mark loop conditions as "likely true" (for while/for)
- [ ] **P16.2** Mark nil checks as "likely false" (common Lua pattern)
- [ ] **P16.3** Place likely branch as fall-through (fewer jumps)
- [ ] **P16.4** Order `if-elseif-else` by annotated probability
- [ ] **P16.5** Add config: `enableBranchHints`

---

## Sprint Progress

| Sprint | Focus | Status |
|--------|-------|--------|
| Sprint 1 | Foundations (P11, S1, P15) | ✅ COMPLETED |
| Sprint 2 | Core Security (S4, S2, S6) | ✅ COMPLETED |
| Sprint 3 | Core Performance (P10, P14, P9) | ✅ COMPLETED |
| Sprint 4 | Advanced Security (S3, S5, S9) | ⏳ PENDING |
| Sprint 5 | Advanced Performance (P12, P17, P18) | ✅ COMPLETED |
| Sprint 6 | Expert Level (S7, S8, S10, P16, P13) | ⏳ PENDING |

---

## Success Metrics

| Category | Metric | Status |
|----------|--------|--------|
| Security | Unique outputs per compile | ✅ Achieved |
| Security | Pattern detection resistance | ✅ Via S1, S2, S4, S6 |
| Performance | Peephole optimization | ✅ P11 |
| Performance | Loop optimization | ✅ P10 (LICM) |
| Performance | Expression optimization | ✅ P14 (CSE), P15 |
| Performance | Function optimization | ✅ P12 (inlining) |
| Quality | Test pass rate | ✅ 100% |

---

**End of Plan**
