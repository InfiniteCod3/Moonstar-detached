-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:42
-- Luau version 6, Types version 3
-- Time taken: 0.011896 seconds

local module_upvr = {
	Cooldown = 13;
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
	local Absolute_Eruption_upvr = ReplicatedStorage_upvr.Skills["Snow Blasters"].Ultimate["Absolute Eruption"]
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Absolute_Eruption_upvr.Animation)
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
	local Snow_Cannon_upvr = arg1:FindFirstChild("Snow Cannon")
	if not Snow_Cannon_upvr then
		Snow_Cannon_upvr = arg1:WaitForChild("Snow Cannon")
	end
	Snow_Cannon_upvr.weld.Part0 = arg1["Right Arm"]
	Snow_Cannon_upvr.weld.C1 = Snow_Cannon_upvr.weld.C0
	local var18_upvw = true
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 54
		--[[ Upvalues[5]:
			[1]: var18_upvw (read and write)
			[2]: tbl_upvr (readonly)
			[3]: TweenService_upvr (copied, readonly)
			[4]: Snow_Cannon_upvr (readonly)
			[5]: arg1 (readonly)
		]]
		var18_upvw = false
		for _, v_2 in tbl_upvr do
			TweenService_upvr:Create(v_2.BasePart, TweenInfo.new(0.1), {
				Transparency = v_2.Transparency;
			}):Play()
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
		Snow_Cannon_upvr.weld.Part0 = arg1.Torso
		Snow_Cannon_upvr.weld.C1 = Snow_Cannon_upvr.weld:GetAttribute("BackCF")
	end), module_upvr.Cooldown)
	var2_upvw.applyStatus(arg1, "Slowed", 2)
	var2_upvw.applyStatus(arg1, "GlobalCD", 2)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("charge"):Connect(function() -- Line 78
		--[[ Upvalues[10]:
			[1]: Snow_Cannon_upvr (readonly)
			[2]: TweenService_upvr (copied, readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: any_LoadAnimation_result1_upvr (readonly)
			[5]: var18_upvw (read and write)
			[6]: arg1 (readonly)
			[7]: Absolute_Eruption_upvr (readonly)
			[8]: Folder_upvr (readonly)
			[9]: HumanoidRootPart_upvr (readonly)
			[10]: module_upvr (copied, readonly)
		]]
		Snow_Cannon_upvr.Charge:Play()
		TweenService_upvr:Create(Snow_Cannon_upvr.Glow, TweenInfo.new(1), {
			Color = Color3.new(0.6, 1, 1);
		}):Play()
		TweenService_upvr:Create(Snow_Cannon_upvr.PointLight, TweenInfo.new(1), {
			Brightness = 2;
		}):Play()
		var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Fire"):Connect(function() -- Line 83
			--[[ Upvalues[8]:
				[1]: var18_upvw (copied, read and write)
				[2]: TweenService_upvr (copied, readonly)
				[3]: Snow_Cannon_upvr (copied, readonly)
				[4]: var2_upvw (copied, read and write)
				[5]: arg1 (copied, readonly)
				[6]: Absolute_Eruption_upvr (copied, readonly)
				[7]: Folder_upvr (copied, readonly)
				[8]: HumanoidRootPart_upvr (copied, readonly)
			]]
			var18_upvw = false
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
			task.delay(0.05, function() -- Line 92
				--[[ Upvalues[2]:
					[1]: var2_upvw (copied, read and write)
					[2]: arg1 (copied, readonly)
				]]
				var2_upvw.camShake(arg1, "Explosion")
				var2_upvw.impactFrame2(arg1)
				task.wait(0.05)
				var2_upvw.impactFrame(arg1)
			end)
			Snow_Cannon_upvr.CannonFire1:Play()
			Snow_Cannon_upvr.BassDrop:Play()
			local clone = Absolute_Eruption_upvr.VFX:Clone()
			clone.Parent = Folder_upvr
			clone.CFrame = HumanoidRootPart_upvr.CFrame
			clone.SFX:Play()
			var2_upvw.EmitAllDescendants(clone)
			var2_upvw.applyDebris(clone, 10)
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(1000000, 100, 1000000)
			BodyVelocity.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * -50
			var2_upvw.applyDebris(BodyVelocity, 1)
			var2_upvw.applyVelocity(arg1.Head, BodyVelocity, 0.4, false, false, true)
			local clone_2 = Absolute_Eruption_upvr.HitboxHolder:Clone()
			clone_2.Parent = Folder_upvr
			clone_2.CFrame = HumanoidRootPart_upvr.CFrame
			var2_upvw.applyDebris(clone_2, 1)
			for _, v_3_upvr in var2_upvw.findEnemiesPart(clone_2.Hitbox, true), nil do
				if not var2_upvw.CheckBlock(v_3_upvr, true) then
					var2_upvw.unragdoll(v_3_upvr)
					var2_upvw.camShake(v_3_upvr, "Explosion")
					var2_upvw.flashScreen(v_3_upvr, Color3.new(0.219608, 0.988235, 1), 4)
					var2_upvw.Blur(v_3_upvr, 40, 4)
					var2_upvw.changeFov(arg1, 30, 0.1, 4)
					var2_upvw.applyStatus(v_3_upvr, "Ragdoll", 2.5)
					var2_upvw.applyStatus(v_3_upvr, "DashDB", 2.5)
					var2_upvw.applyDamage(v_3_upvr, 20)
					var2_upvw.impactFrame(v_3_upvr)
					task.delay(0.05, function() -- Line 138
						--[[ Upvalues[2]:
							[1]: var2_upvw (copied, read and write)
							[2]: v_3_upvr (readonly)
						]]
						var2_upvw.impactFrame2(v_3_upvr)
						task.wait(0.05)
						var2_upvw.impactFrame(v_3_upvr)
					end)
				end
			end
		end), module_upvr.Cooldown)
		repeat
			task.wait(0.1)
			if var18_upvw == true then
				var2_upvw.camShake(arg1, "SmallBump")
			end
		until var18_upvw == false
	end), module_upvr.Cooldown)
end
return module_upvr