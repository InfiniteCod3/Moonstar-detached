-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:59
-- Luau version 6, Types version 3
-- Time taken: 0.014734 seconds

local module_upvr = {
	Cooldown = 15;
	GlobalCD = 0.8;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 11
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
	local Flowing_Strike_upvr = ReplicatedStorage_upvr.Skills["Wind Spear"]["Flowing Strike"]
	local Wind_Spear_upvr = arg1:FindFirstChild("Wind Spear")
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Flowing_Strike_upvr.Animation)
	task.wait()
	any_LoadAnimation_result1:Play()
	var2_upvw.applyStatus(arg1, "Slowed", 0.8)
	Wind_Spear_upvr.Sounds.flowStart:Play()
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("strike"):Connect(function() -- Line 32
		--[[ Upvalues[7]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Wind_Spear_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: TweenService_upvr (copied, readonly)
			[6]: Flowing_Strike_upvr (readonly)
			[7]: Folder_upvr (readonly)
		]]
		-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
		var2_upvw.applyStatus(arg1, "AutoRotate", 0.5)
		var2_upvw.applyStatus(arg1, "IFrames", 0.4)
		Wind_Spear_upvr.Sounds.Dash:play()
		Wind_Spear_upvr.Sounds.Dash2:Play()
		local BodyVelocity_upvr = Instance.new("BodyVelocity", arg1.Torso)
		BodyVelocity_upvr.MaxForce = Vector3.new(1000000, 1000000, 1000000)
		BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 150
		TweenService_upvr:Create(BodyVelocity_upvr, TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 20;
		}):Play()
		for _, v_upvr in arg1:GetDescendants() do
			if v_upvr:IsA("BasePart") and v_upvr.Transparency ~= 1 then
				v_upvr.Transparency = 1
				local Transparency_upvr = v_upvr.Transparency
				delay(0.12, function() -- Line 51
					--[[ Upvalues[2]:
						[1]: v_upvr (readonly)
						[2]: Transparency_upvr (readonly)
					]]
					v_upvr.Transparency = Transparency_upvr
				end)
			end
		end
		game.Debris:AddItem(BodyVelocity_upvr, 0.5)
		var2_upvw.CreateDebris(HumanoidRootPart_upvr.Position, 4)
		var2_upvw.changeFov(arg1, 90, 0.02, 0.4)
		var2_upvw.Blur(arg1, 8, 0.4)
		local clone_2_upvr = Flowing_Strike_upvr.trail:Clone()
		clone_2_upvr.Parent = Folder_upvr
		clone_2_upvr.weld.Part0 = HumanoidRootPart_upvr
		var2_upvw.EmitAllDescendants(clone_2_upvr)
		delay(0.3, function() -- Line 67
			--[[ Upvalues[1]:
				[1]: clone_2_upvr (readonly)
			]]
			clone_2_upvr.Trail.Enabled = false
		end)
		game.Debris:AddItem(clone_2_upvr, 1)
		local clone_3 = Flowing_Strike_upvr.HitboxCarrier:Clone()
		clone_3.Parent = Folder_upvr
		clone_3.CFrame = HumanoidRootPart_upvr.CFrame
		Transparency_upvr = 1
		game.Debris:AddItem(clone_3, Transparency_upvr)
		task.wait(0.2)
		Transparency_upvr = 2
		var2_upvw.applyStatus(arg1, "CombatStun", Transparency_upvr)
		Transparency_upvr = 0.4
		var2_upvw.applyStatus(arg1, "Freeze", Transparency_upvr)
		Transparency_upvr = 0.4
		var2_upvw.applyStatus(arg1, "GlobalCD", Transparency_upvr)
		Transparency_upvr = nil
		for _, v_2_upvr in var2_upvw.findEnemiesPart(clone_3.Hitbox), nil, Transparency_upvr do
			task.spawn(function() -- Line 84
				--[[ Upvalues[6]:
					[1]: var2_upvw (copied, read and write)
					[2]: v_2_upvr (readonly)
					[3]: HumanoidRootPart_upvr (copied, readonly)
					[4]: BodyVelocity_upvr (readonly)
					[5]: arg1 (copied, readonly)
					[6]: Flowing_Strike_upvr (copied, readonly)
				]]
				var2_upvw.Knockback(v_2_upvr, HumanoidRootPart_upvr.Position + BodyVelocity_upvr.Velocity, 15, 2)
				var2_upvw.applyDamage(v_2_upvr, 1)
				var2_upvw.applyStatus(v_2_upvr, "Stunned", 0.25)
				var2_upvw.changeFov(arg1, 75, 0, 0.5)
				var2_upvw.changeFov(v_2_upvr, 75, 0, 0.5)
				var2_upvw.Blur(arg1, 10, 0.3)
				var2_upvw.Blur(v_2_upvr, 10, 0.3)
				task.wait(0.2)
				for i_3_upvr = 1, 11 do
					task.wait(0.1)
					local _, _ = pcall(function() -- Line 96
						--[[ Upvalues[4]:
							[1]: Flowing_Strike_upvr (copied, readonly)
							[2]: i_3_upvr (readonly)
							[3]: v_2_upvr (copied, readonly)
							[4]: var2_upvw (copied, read and write)
						]]
						local clone_5 = Flowing_Strike_upvr.HitboxCarrier:FindFirstChild("slash"..i_3_upvr):Clone()
						clone_5.Parent = v_2_upvr.HumanoidRootPart
						var2_upvw.applyDebris(clone_5, 2)
						var2_upvw.EmitAllDescendants(clone_5)
						var2_upvw.applyDamage(v_2_upvr, 1)
						var2_upvw.applyStatus(v_2_upvr, "Stunned", 0.45)
						local clone_4 = Flowing_Strike_upvr.HitboxCarrier.sfx1:Clone()
						local clone = Flowing_Strike_upvr.HitboxCarrier.sfx2:Clone()
						clone_4.PlaybackSpeed += math.random(-1, 1) * 0.1
						clone.PlaybackSpeed += math.random(-1, 1) * 0.1
						clone_4.Parent = v_2_upvr.HumanoidRootPart
						clone.Parent = v_2_upvr.HumanoidRootPart
						var2_upvw.applyDebris(clone_4, 5)
						var2_upvw.applyDebris(clone, 5)
						clone_4:Play()
						clone:Play()
					end)
				end
			end)
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 117
		--[[ Upvalues[1]:
			[1]: Wind_Spear_upvr (readonly)
		]]
		if Wind_Spear_upvr.Sounds:FindFirstChild(arg1_2) then
			Wind_Spear_upvr.Sounds[arg1_2]:Play()
		end
	end), module_upvr.Cooldown)
end
return module_upvr