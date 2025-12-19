-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:21
-- Luau version 6, Types version 3
-- Time taken: 0.004004 seconds

local module = {}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[2]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 10)
	local CameraBP_upvr = arg1:FindFirstChild("CameraBP", true)
	CameraBP_upvr:SetAttribute("Offset", Vector3.new(0, 10, 0))
	arg2.CameraMaxZoomDistance = 120
	arg2.CameraMinZoomDistance = 120
	local var7_upvw
	var7_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnClientEvent:Connect(function(arg1_2) -- Line 37
		--[[ Upvalues[3]:
			[1]: var7_upvw (read and write)
			[2]: CameraBP_upvr (readonly)
			[3]: arg2 (readonly)
		]]
		if arg1_2 ~= "Dancing Flame" then
		else
			var7_upvw:Disconnect()
			CameraBP_upvr:SetAttribute("Offset", Vector3.new(0, 0, 0))
			arg2.CameraMinZoomDistance = 20
			arg2.CameraMaxZoomDistance = 20
			task.wait(1)
			arg2.CameraMaxZoomDistance = 40
			arg2.CameraMinZoomDistance = 10
		end
	end), 10)
	task.delay(10, function() -- Line 51
		--[[ Upvalues[1]:
			[1]: var7_upvw (read and write)
		]]
		if not var7_upvw then
		else
			var7_upvw:Disconnect()
		end
	end)
end
return module