# V13 - Client-Controlled Health Restoration

## Severity: CRITICAL

## Summary
The server trusts client-provided values for health restoration (siphon/lifesteal mechanics), allowing attackers to send arbitrary health values and instantly heal to full or beyond maximum health.

## Vulnerability Details

### Root Cause
The `Siphon` function in skill modules directly adds health based on a client-provided `arg3` parameter without any validation or clamping.

### Affected Code Pattern
```lua
-- BladeStormModule_ID98.luau:94
local var32 = Humanoid_upvr
var32.Health += arg3  -- arg3 comes directly from client!

-- PinpointShurikenModule_ID99.luau:95
var20.Health += arg3

-- RapidBlinksModule_ID97.luau:94
var38.Health += arg3
```

### Attack Vector
1. Player activates a skill with siphon/lifesteal mechanic
2. Client sends `FireServer` with manipulated `arg3` value
3. Server blindly adds this value to player's health
4. Player can heal for any amount (e.g., 999999)

## Impact
- Instant full health restoration
- Potential for health values exceeding max (if not clamped elsewhere)
- Complete negation of damage-based gameplay
- PvP becomes impossible against exploiters

## Affected Files
| File | Line | Function |
|------|------|----------|
| BladeStormModule_ID98.luau | 94 | Siphon |
| PinpointShurikenModule_ID99.luau | 95 | Health restoration |
| RapidBlinksModule_ID97.luau | 94 | Health restoration |

## Proof of Concept
See `poc.luau` in this folder.

## Remediation
```lua
-- Server-side fix: Calculate health restoration server-side
local SIPHON_AMOUNT = 5  -- Fixed server-controlled value
local maxHealth = Humanoid_upvr.MaxHealth
local currentHealth = Humanoid_upvr.Health
local newHealth = math.min(currentHealth + SIPHON_AMOUNT, maxHealth)
Humanoid_upvr.Health = newHealth
```

## References
- CWE-20: Improper Input Validation
- OWASP: Injection Flaws
