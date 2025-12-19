-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:47
-- Luau version 6, Types version 3
-- Time taken: 0.030407 seconds

local module_upvr = {
	Cooldown = 25;
	GlobalCD = 0.1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown + 10)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local Cannonball = ReplicatedStorage_upvr.Skills["Water Brawler"].Ultimate.Cannonball
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Cannonball.Animation)
	any_LoadAnimation_result1:Play(0.1)
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	BodyVelocity.Velocity = HumanoidRootPart.CFrame.LookVector * 120 + Vector3.new(0, 50, 0)
	local var53
	for _, v in arg1:GetDescendants() do
		var53 = "BodyVelocity"
		if v:IsA(var53) then
			v:Destroy()
		end
	end
	HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
	var2_upvw.applyStatus(arg1, "AutoRotate", 1)
	var2_upvw.applyStatus(arg1, "Slowed", 1)
	var2_upvw.applyStatus(arg1, "IFrames", 1)
	local clone = Cannonball.wind:Clone()
	clone.Parent = HumanoidRootPart
	clone:Play()
	local clone_4 = Cannonball.Bubble:Clone()
	clone_4.Parent = arg1
	clone_4.weld.Part0 = HumanoidRootPart
	clone_4.weld.Part1 = clone_4
	for _, v_2 in clone_4:GetChildren() do
		var53 = v_2:IsA("Sound")
		if var53 then
			var53 = v_2:Play
			var53()
		end
	end
	local clone_2 = script.Bubble:Clone()
	clone_2.Parent = arg2.PlayerGui.MainUI
	clone_2.BackgroundTransparency = 1
	clone_2.ImageTransparency = 1
	var53 = 1
	var53 = {}
	var53.ImageTransparency = 0.5
	var53.BackgroundTransparency = 0.8
	TweenService_upvr:Create(clone_2, TweenInfo.new(var53), var53):Play()
	var2_upvw.Blur(arg1, 10, 2)
	var53 = 15
	var2_upvw.changeFov(arg1, 300, 2, var53)
	task.wait(0.1)
	var2_upvw.applyVelocity(HumanoidRootPart, BodyVelocity, 0.25)
	task.wait(0.25)
	var53 = var2_upvw.raycastParams
	if workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -2, 0), var53) then
		any_LoadAnimation_result1:Stop()
		var2_upvw.applyDebris(clone, 0)
		var2_upvw.applyDebris(clone_4, 0)
		var2_upvw.applyDebris(clone_2, 0)
	else
		var53 = true
		repeat
			task.wait(0.05)
			var2_upvw.applyStatus(arg1, "AutoRotate", 0.5)
			var2_upvw.applyStatus(arg1, "Freeze", 0.5)
			var2_upvw.applyStatus(arg1, "IFrames", 0.15)
			var2_upvw.applyStatus(arg1, "GlobalCD", 0.5)
			local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -3 + HumanoidRootPart.Velocity.Y * 0.24, 0), var2_upvw.raycastParams)
			if workspace_Raycast_result1 and workspace_Raycast_result1.Position.Y < HumanoidRootPart.Position.Y then
				var53 = false
				local Position = workspace_Raycast_result1.Position
				local var62
			end
			if var53 == true then
				if (HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 1 then
					var62 += 1
				end
				if var62 == 10 then
					for _, v_3 in arg1:FindFirstChild("Water Brawler").FireVfx:GetChildren() do
						v_3.Enabled = false
					end
					break
				end
			end
		until var53 == false
		any_LoadAnimation_result1:Stop()
		var2_upvw.applyDebris(clone, 0)
		var2_upvw.applyDebris(clone_4, 0)
		var2_upvw.applyDebris(clone_2, 0)
		if var53 ~= false then return end
		var2_upvw.flashScreen(arg1, Color3.new(0.490196, 0.780392, 1), 3)
		var2_upvw.applyStatus(arg1, "GlobalCD", 1.1)
		var2_upvw.applyStatus(arg1, "Freeze", 1.2)
		var2_upvw.applyStatus(arg1, "AutoRotate", 1.1)
		var2_upvw.applyStatus(arg1, "IFrames", 0.15)
		var2_upvw.camShake(arg1, "Explosion")
		var2_upvw.Blur(arg1, 20, 2)
		local clone_3 = Cannonball.SplashVFX:Clone()
		clone_3.Parent = Folder
		clone_3.CFrame = CFrame.new(Position + Vector3.new(0, 0.5, 0)) * HumanoidRootPart.CFrame - HumanoidRootPart.CFrame.p
		var2_upvw.EmitAllDescendants(clone_3)
		game.Debris:AddItem(clone_3, 15)
		for _, v_4 in clone_3:GetDescendants() do
			if v_4:IsA("Sound") then
				v_4:Play()
			end
		end
		var2_upvw.impactFrame2(arg1)
		var2_upvw.changeFov(arg1, 40, 0.01, 0.6)
		ReplicatedStorage_upvr.Remotes.ClientInfo:FireClient(arg2, "Cannonball")
		for _, v_5 in var2_upvw.findEnemiesMagnitude(Position, 110, true), nil do
			if not var2_upvw.CheckBlock(v_5, true) then
				var2_upvw.applyDamage(v_5, 20)
				var2_upvw.Knockback(v_5, HumanoidRootPart.Position, 25, 80)
				var2_upvw.applyStatus(v_5, "Ragdoll", 2.5)
				var2_upvw.flashScreen(v_5, Color3.new(0.490196, 0.780392, 1), 2)
				var2_upvw.camShake(v_5, "Explosion")
			end
		end
	end
end
return module_upvr