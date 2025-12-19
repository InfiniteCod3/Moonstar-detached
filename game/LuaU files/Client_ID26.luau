-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:37
-- Luau version 6, Types version 3
-- Time taken: 0.005588 seconds

local module_upvr = {
	Cooldown = 16;
	GlobalCD = 0.5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module_upvr.Script(arg1, arg2) -- Line 15
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
	local _
	for _, v in arg1:GetDescendants() do
		if v:IsA("BodyVelocity") then
			v:Destroy()
		end
	end
	HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
	task.wait(0.1)
	local BodyVelocity = Instance.new("BodyVelocity", HumanoidRootPart)
	BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	BodyVelocity.Velocity = HumanoidRootPart.CFrame.LookVector * 80 + Vector3.new(0, 25, 0)
	game.Debris:AddItem(BodyVelocity, 0.25)
	task.wait(0.25)
	repeat
		task.wait(0.05)
		var2_upvw.applyStatus(arg1, "AutoRotate", 0.5)
		var2_upvw.applyStatus(arg1, "Freeze", 0.5)
		var2_upvw.applyStatus(arg1, "IFrames", 0.15)
		var2_upvw.applyStatus(arg1, "GlobalCD", 0.5)
		local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -3 + HumanoidRootPart.Velocity.Y * 0.24, 0), var2_upvw.raycastParams)
		local var20
		if workspace_Raycast_result1 and workspace_Raycast_result1.Position.Y < HumanoidRootPart.Position.Y then
			var20 = false
			local var21
		end
		if var20 == true then
			if (HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 1 then
				var21 += 1
			end
			if var21 == 10 then
				for _, v_2 in arg1:FindFirstChild("Greatsword").FireVfx:GetChildren() do
					v_2.Enabled = false
				end
				break
			end
		end
	until var20 == false
	ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Fiery Leap", {
		ExplosionPosition = workspace_Raycast_result1.Position;
	})
end
return module_upvr