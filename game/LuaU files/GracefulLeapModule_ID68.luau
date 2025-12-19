-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:43
-- Luau version 6, Types version 3
-- Time taken: 0.016572 seconds

local module_upvr = {
	Cooldown = 17;
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
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Graceful_Leap_upvr = ReplicatedStorage_upvr.Skills["Snow Blasters"].Ultimate["Graceful Leap"]
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Graceful_Leap_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	local tbl_upvr = {}
	for i, v in arg1:FindFirstChild("Snow Blasters"):GetDescendants() do
		if v:IsA("BasePart") then
			tbl_upvr[i] = {}
			tbl_upvr[i].BasePart = v
			tbl_upvr[i].Transparency = v.Transparency
			TweenService_upvr:Create(v, TweenInfo.new(0), {
				Transparency = 1;
			}):Play()
		elseif v:IsA("Trail") then
			v.Enabled = false
		end
	end
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 47
		--[[ Upvalues[3]:
			[1]: Graceful_Leap_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
		]]
		for _, v_2 in Graceful_Leap_upvr.Sounds:GetChildren() do
			if v_2.Name == arg1_2 then
				local clone_2 = v_2:Clone()
				clone_2.Parent = HumanoidRootPart_upvr
				clone_2:Play()
				var2_upvw.applyDebris(clone_2, 8)
			end
		end
	end), module_upvr.Cooldown)
	local clone_4_upvr = Graceful_Leap_upvr.TrailVFX:Clone()
	clone_4_upvr.Weld.Part0 = arg1.Torso
	clone_4_upvr.Weld.Part1 = clone_4_upvr
	clone_4_upvr.Parent = Folder_upvr
	local Snow_Cannon_upvr = arg1:FindFirstChild("Snow Cannon")
	if not Snow_Cannon_upvr then
		Snow_Cannon_upvr = arg1:WaitForChild("Snow Cannon")
	end
	Snow_Cannon_upvr.weld.Part0 = arg1["Right Arm"]
	Snow_Cannon_upvr.weld.C1 = Snow_Cannon_upvr.weld.C0
	local var31_upvw = true
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 69
		--[[ Upvalues[6]:
			[1]: var31_upvw (read and write)
			[2]: tbl_upvr (readonly)
			[3]: TweenService_upvr (copied, readonly)
			[4]: clone_4_upvr (readonly)
			[5]: Snow_Cannon_upvr (readonly)
			[6]: arg1 (readonly)
		]]
		var31_upvw = false
		for _, v_3 in tbl_upvr do
			TweenService_upvr:Create(v_3.BasePart, TweenInfo.new(0.1), {
				Transparency = v_3.Transparency;
			}):Play()
		end
		for _, v_4 in clone_4_upvr:GetDescendants() do
			if v_4:IsA("Trail") then
				v_4.Enabled = false
			end
		end
		local PointLight = Snow_Cannon_upvr:FindFirstChild("PointLight")
		if PointLight then
			TweenService_upvr:Create(PointLight, TweenInfo.new(0), {
				Brightness = 0;
			}):Play()
		end
		if Snow_Cannon_upvr:FindFirstChild("Glow") then
			TweenService_upvr:Create(Snow_Cannon_upvr.Glow, TweenInfo.new(0), {
				Color = Color3.new(0, 0, 0);
			}):Play()
		end
		Snow_Cannon_upvr.weld.C1 = Snow_Cannon_upvr.weld:GetAttribute("BackCF")
		Snow_Cannon_upvr.weld.Part0 = arg1.Torso
	end), module_upvr.Cooldown)
	var2_upvw.applyStatus(arg1, "Freeze", 2)
	var2_upvw.applyStatus(arg1, "GlobalCD", 2)
	var2_upvw.applyStatus(arg1, "IFrames", 2)
	local clone_3 = Graceful_Leap_upvr.JumpVFX:Clone()
	clone_3.Parent = Folder_upvr
	clone_3.CFrame = HumanoidRootPart_upvr.CFrame
	var2_upvw.EmitAllDescendants(clone_3)
	clone_3.SFX:Play()
	var2_upvw.camShake(arg1, "Explosion")
	for _, v_5 in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position, 70, true), nil do
		if not var2_upvw.CheckBlock(v_5) then
			var2_upvw.unragdoll(v_5)
			var2_upvw.Knockback(v_5, HumanoidRootPart_upvr.Position, 80)
			var2_upvw.camShake(v_5, "Explosion")
			var2_upvw.flashScreen(v_5, Color3.new(0.219608, 0.988235, 1), 4)
			var2_upvw.Blur(v_5, 40, 2)
			var2_upvw.changeFov(arg1, 50, 0.1, 2)
			var2_upvw.applyStatus(v_5, "Ragdoll", 1)
			var2_upvw.applyDamage(v_5, 10)
		end
	end
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("charge"):Connect(function() -- Line 126
		--[[ Upvalues[11]:
			[1]: Snow_Cannon_upvr (readonly)
			[2]: TweenService_upvr (copied, readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: any_LoadAnimation_result1_upvr (readonly)
			[5]: arg1 (readonly)
			[6]: clone_4_upvr (readonly)
			[7]: var31_upvw (read and write)
			[8]: Graceful_Leap_upvr (readonly)
			[9]: Folder_upvr (readonly)
			[10]: HumanoidRootPart_upvr (readonly)
			[11]: module_upvr (copied, readonly)
		]]
		Snow_Cannon_upvr.Charge:Play()
		TweenService_upvr:Create(Snow_Cannon_upvr.Glow, TweenInfo.new(1), {
			Color = Color3.new(0.6, 1, 1);
		}):Play()
		TweenService_upvr:Create(Snow_Cannon_upvr.PointLight, TweenInfo.new(1), {
			Brightness = 2;
		}):Play()
		var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Fire"):Connect(function() -- Line 131
			--[[ Upvalues[9]:
				[1]: arg1 (copied, readonly)
				[2]: var2_upvw (copied, read and write)
				[3]: clone_4_upvr (copied, readonly)
				[4]: var31_upvw (copied, read and write)
				[5]: TweenService_upvr (copied, readonly)
				[6]: Snow_Cannon_upvr (copied, readonly)
				[7]: Graceful_Leap_upvr (copied, readonly)
				[8]: Folder_upvr (copied, readonly)
				[9]: HumanoidRootPart_upvr (copied, readonly)
			]]
			local Folder = Instance.new("Folder", arg1)
			Folder.Name = "FiredCannon"
			var2_upvw.applyDebris(Folder, 1)
			for _, v_6 in clone_4_upvr:GetDescendants() do
				if v_6:IsA("Trail") then
					v_6.Enabled = false
				end
			end
			var31_upvw = false
			TweenService_upvr:Create(Snow_Cannon_upvr.Glow, TweenInfo.new(0.25), {
				Color = Color3.new(0, 0, 0);
			}):Play()
			TweenService_upvr:Create(Snow_Cannon_upvr.PointLight, TweenInfo.new(0.25), {
				Brightness = 0;
			}):Play()
			var2_upvw.changeFov(arg1, 55, 0, 1)
			var2_upvw.flashScreen(arg1, Color3.new(0.411765, 1, 0.980392), 2)
			var2_upvw.Blur(arg1, 30, 0.2)
			var2_upvw.impactFrame(arg1)
			task.delay(0.05, function() -- Line 150
				--[[ Upvalues[2]:
					[1]: arg1 (copied, readonly)
					[2]: var2_upvw (copied, read and write)
				]]
				local BodyVelocity_2 = Instance.new("BodyVelocity", arg1.Torso)
				BodyVelocity_2.MaxForce = Vector3.new(1000000, 1000000, 1000000)
				BodyVelocity_2.Velocity = Vector3.new(0, 50, 0)
				var2_upvw.applyDebris(BodyVelocity_2, 0.6)
				var2_upvw.camShake(arg1, "Explosion")
				var2_upvw.impactFrame2(arg1)
				task.wait(0.05)
				var2_upvw.impactFrame(arg1)
			end)
			Snow_Cannon_upvr.CannonFire1:Play()
			Snow_Cannon_upvr.CannonFire2:Play()
			Snow_Cannon_upvr.BassDrop:Play()
			var2_upvw.changeFov(arg1, 0.5, 100, 2)
			var2_upvw.flashScreen(arg1, Color3.new(0.654902, 1, 0.988235), 1)
			local clone_5 = Graceful_Leap_upvr.VFX:Clone()
			clone_5.Parent = Folder_upvr
			clone_5.CFrame = HumanoidRootPart_upvr.CFrame * CFrame.Angles((-math.pi/2), 0, 0)
			clone_5.SFX:Play()
			var2_upvw.EmitAllDescendants(clone_5)
			var2_upvw.applyDebris(clone_5, 10)
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(1000000, 100, 1000000)
			BodyVelocity.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * -50
			var2_upvw.applyDebris(BodyVelocity, 1)
			var2_upvw.applyVelocity(arg1.Head, BodyVelocity, 0.4, false, false, true)
			local clone = Graceful_Leap_upvr.HitboxHolder:Clone()
			clone.Parent = Folder_upvr
			clone.CFrame = clone_5.CFrame
			var2_upvw.applyDebris(clone, 1)
			for _, v_7_upvr in var2_upvw.findEnemiesPart(clone.Hitbox, true), nil do
				if not var2_upvw.CheckBlock(v_7_upvr, true) then
					var2_upvw.unragdoll(v_7_upvr)
					var2_upvw.camShake(v_7_upvr, "Explosion")
					var2_upvw.flashScreen(v_7_upvr, Color3.new(0.219608, 0.988235, 1), 4)
					var2_upvw.Blur(v_7_upvr, 40, 4)
					var2_upvw.changeFov(arg1, 30, 0.1, 4)
					var2_upvw.applyStatus(v_7_upvr, "Ragdoll", 2.5)
					var2_upvw.applyStatus(v_7_upvr, "DashDB", 2.5)
					var2_upvw.applyDamage(v_7_upvr, 20)
					var2_upvw.impactFrame(v_7_upvr)
					task.delay(0.05, function() -- Line 205
						--[[ Upvalues[2]:
							[1]: var2_upvw (copied, read and write)
							[2]: v_7_upvr (readonly)
						]]
						var2_upvw.impactFrame2(v_7_upvr)
						task.wait(0.05)
						var2_upvw.impactFrame(v_7_upvr)
					end)
				end
			end
		end), module_upvr.Cooldown)
	end), module_upvr.Cooldown)
end
return module_upvr