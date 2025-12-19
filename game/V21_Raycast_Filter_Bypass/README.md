# V21 - Raycast Filter Bypass

## Severity: MEDIUM

## Summary
Skills use `raycastParams` that are configured client-side or use shared parameters. Attackers can manipulate what the raycast filters out, allowing hits through walls, terrain, or other objects that should block attacks.

## Vulnerability Details

### Root Cause
Client-side raycasts use `var2_upvw.raycastParams` or `var3_upvw.raycastParams` which may be manipulatable, or the FilterDescendantsInstances can be modified.

### Affected Code Pattern
```lua
-- Common pattern across client modules:
local workspace_Raycast_result1 = workspace:Raycast(
    HumanoidRootPart.Position,
    HumanoidRootPart.CFrame.LookVector * 75,
    var3_upvw.raycastParams  -- Shared/client raycast params
)

-- The raycastParams are typically set up like:
local params = RaycastParams.new()
params.FilterDescendantsInstances = {character}  -- Can be modified
params.FilterType = Enum.RaycastFilterType.Blacklist
```

### Attack Vector
1. Access the shared `raycastParams` object
2. Modify `FilterDescendantsInstances` to include walls/terrain
3. Raycast now passes through all filtered objects
4. Skills can hit targets behind cover

## Impact
- Hit enemies through walls
- Attack through terrain
- Bypass map geometry
- Negates cover-based gameplay

## Affected Files
| File | Line | Raycast Usage |
|------|------|---------------|
| AerialSmiteModule_ID148.luau | 84 | var3_upvw.raycastParams |
| BlinkStrikeModule_ID106.luau | 118 | var3_upvw.raycastParams |
| Client_ID10.luau | 84 | var3_upvw.raycastParams |
| Client_ID100.luau | 62 | var2_upvw.raycastParams |
| CannonballModule_ID182.luau | 76 | var53 / var2_upvw.raycastParams |
| All modules using workspace:Raycast | Various | Shared raycastParams |

## Proof of Concept
See `poc.luau` in this folder.

## Remediation
```lua
-- Create immutable raycast params per-call
local function createSecureRaycastParams(character)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    -- Make the table read-only if possible
    return params
end

-- Don't reuse raycast params across calls
local function secureRaycast(origin, direction, character)
    local params = createSecureRaycastParams(character)
    return workspace:Raycast(origin, direction, params)
end

-- Server-side: Verify raycast results
local function validateRaycastResult(player, claimedPosition)
    local serverParams = RaycastParams.new()
    serverParams.FilterDescendantsInstances = {player.Character}

    local serverRay = workspace:Raycast(
        player.Character.HumanoidRootPart.Position,
        claimedPosition - player.Character.HumanoidRootPart.Position,
        serverParams
    )

    -- If server raycast hits something before claimed position, reject
    if serverRay and (serverRay.Position - player.Character.HumanoidRootPart.Position).Magnitude <
       (claimedPosition - player.Character.HumanoidRootPart.Position).Magnitude then
        return false -- Blocked by wall
    end

    return true
end
```

## References
- CWE-807: Reliance on Untrusted Inputs in a Security Decision
- Game Security: Wallhack/Aimbot Prevention
