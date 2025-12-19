-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:10
-- Luau version 6, Types version 3
-- Time taken: 0.002420 seconds

local module = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
function module.Script(arg1, arg2) -- Line 14
	--[[ Upvalues[2]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	arg1:FindFirstChild("CameraBP", true):SetAttribute("Offset", Vector3.new(0, 0, 0))
	arg2.CameraMaxZoomDistance = 50
	arg2.CameraMinZoomDistance = 50
	task.wait(9)
	arg2.CameraMaxZoomDistance = 40
	arg2.CameraMinZoomDistance = 10
end
return module