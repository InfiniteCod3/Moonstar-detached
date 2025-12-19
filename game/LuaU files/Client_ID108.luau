-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:14
-- Luau version 6, Types version 3
-- Time taken: 0.002392 seconds

local module_upvr = {}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module_upvr.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local var5_upvw
	task.delay(1, function() -- Line 28
		--[[ Upvalues[1]:
			[1]: var5_upvw (read and write)
		]]
		if not var5_upvw then
		else
			var5_upvw:Disconnect()
		end
	end)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var5_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnClientEvent:Connect(function(arg1_2) -- Line 33
		--[[ Upvalues[3]:
			[1]: var5_upvw (read and write)
			[2]: ReplicatedStorage_upvr (copied, readonly)
			[3]: HumanoidRootPart_upvr (readonly)
		]]
		if arg1_2 ~= "Siphon" then
		else
			var5_upvw:Disconnect()
			ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Siphon", HumanoidRootPart_upvr.CFrame)
		end
	end), 2)
end
return module_upvr