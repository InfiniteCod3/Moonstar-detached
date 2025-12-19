# V24 - Remote-Triggered Instance Spam

## Severity: HIGH

## Summary
Several skills fire remotes within RenderStepped/Stepped loops without proper rate limiting. Attackers can exploit this to overwhelm server replication or cause lag for other players.

## Vulnerability Details

### Root Cause
Remotes are fired inside high-frequency game loops without throttling.

### Affected Code Pattern
```lua
-- Client_ID165.luau:45-73
RunService.RenderStepped:Connect(function()
    -- Fires remote every frame
    ClientInfo:FireServer("RapidJab")
    ClientInfo:FireServer("RapidJab", HumanoidRootPart.CFrame)
end)
```

### Attack Vector
1. Trigger skills with RenderStepped remotes
2. Modify client to never terminate the loop
3. Flood server with remote calls
4. Cause lag/desync for other players

## Impact
- Server resource exhaustion
- Client lag for other players
- Potential server crashes
- DoS attack vector

## Affected Files
| File | Pattern |
|------|---------|
| Client_ID165.luau | RenderStepped remote spam |
| RapidJab skills | High-frequency remotes |

## Remediation
```lua
-- Server-side rate limiting
local lastCall = {}
local RATE_LIMIT = 0.1 -- 10 calls per second max

ClientInfo.OnServerEvent:Connect(function(player, skillName, ...)
    local key = player.UserId .. skillName
    if tick() - (lastCall[key] or 0) < RATE_LIMIT then
        return -- Rate limited
    end
    lastCall[key] = tick()
    -- Process normally
end)
```
