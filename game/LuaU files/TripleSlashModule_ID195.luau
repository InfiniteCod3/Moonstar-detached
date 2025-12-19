-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:16:47
-- Luau version 6, Types version 3
-- Time taken: 0.002864 seconds

local module_upvr = {
	Cooldown = 1;
	GlobalCD = 1.2;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module_upvr.Script(arg1, arg2) -- Line 12
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	var2_upvw.applyStatus(arg1, "Ragdoll", 2)
	var2_upvw.applyStatus(arg1, "DashDB", 2)
	var2_upvw.Knockback(arg1, HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * -5, 5, 50)
end
return module_upvr