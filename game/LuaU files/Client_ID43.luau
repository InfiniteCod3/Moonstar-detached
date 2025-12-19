-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:20
-- Luau version 6, Types version 3
-- Time taken: 0.002985 seconds

local module = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[3]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 10)
	task.wait(0.2)
	if PlayerStatus_upvr.FindStatus(arg1, "Stunned") then
	else
		ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Bind", arg1:FindFirstChild("HumanoidRootPart").CFrame)
	end
end
return module