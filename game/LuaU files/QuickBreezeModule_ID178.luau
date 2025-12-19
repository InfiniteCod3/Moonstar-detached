-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:13
-- Luau version 6, Types version 3
-- Time taken: 0.015091 seconds

local module_upvr = {
	Cooldown = 30;
	GlobalCD = 0.1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown + 10)
	local Aggressive_Breeze_upvr = ReplicatedStorage_upvr.Skills["Firework Rapier"].Ultimate["Aggressive Breeze"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Aggressive_Breeze_upvr.Animation)
	any_LoadAnimation_result1:AdjustSpeed(1)
	any_LoadAnimation_result1:Play()
	local Firework_Rapier_upvr = arg1:FindFirstChild("Firework Rapier")
	local function _(arg1_2) -- Line 35, Named "ToggleTrails"
		--[[ Upvalues[1]:
			[1]: Firework_Rapier_upvr (readonly)
		]]
		for _, v in Firework_Rapier_upvr:GetDescendants() do
			if v:IsA("Trail") and v.Name == "Trail" then
				v.Enabled = arg1_2
			end
		end
	end
	var2_upvw.changeFov(arg1, 40, 0.8, 3)
	var2_upvw.applyStatus(arg1, "Slowed", 1)
	var2_upvw.applyStatus(arg1, "GlobalCD", 1)
	any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function() -- Line 54
		--[[ Upvalues[4]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: ReplicatedStorage_upvr (copied, readonly)
			[4]: arg2 (readonly)
		]]
		var2_upvw.applyStatus(arg1, "AutoRotate", 1)
		var2_upvw.applyStatus(arg1, "Freeze", 1)
		var2_upvw.applyStatus(arg1, "GlobalCD", 1)
		ReplicatedStorage_upvr.Remotes.ClientInfo:FireClient(arg2, "Quick Breeze")
	end)
	local clone_2_upvr = Aggressive_Breeze_upvr.SoundPart.SoundAtt:Clone()
	clone_2_upvr.Parent = arg1:FindFirstChild("HumanoidRootPart")
	var2_upvw.applyDebris(clone_2_upvr, 12)
	clone_2_upvr.WindReverse:Play()
	local var16_upvw
	var16_upvw = ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_3, arg2_2, arg3) -- Line 69
		--[[ Upvalues[7]:
			[1]: arg2 (readonly)
			[2]: var16_upvw (read and write)
			[3]: Aggressive_Breeze_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: var2_upvw (copied, read and write)
			[6]: arg1 (readonly)
			[7]: clone_2_upvr (readonly)
		]]
		if arg2_2 ~= "Quick Breeze" or arg1_3 ~= arg2 then
		else
			var16_upvw:Disconnect()
			local clone_3 = Aggressive_Breeze_upvr.Hitbox:Clone()
			clone_3.Parent = Folder_upvr
			clone_3.CFrame = arg3.CF
			clone_3.Size = Vector3.new(6, 6, arg3.SizeZ)
			var2_upvw.applyDebris(clone_3, 3)
			var2_upvw.camShake(arg1, "Bump")
			var2_upvw.changeFov(arg1, 20, 0.02, 2)
			var2_upvw.flashScreen(arg1, Color3.new(1, 0.647059, 0.560784), 0.5)
			var2_upvw.impactFrame2(arg1)
			var2_upvw.Blur(arg1, 30, 0.4)
			task.delay(0.1, function() -- Line 84
				--[[ Upvalues[2]:
					[1]: var2_upvw (copied, read and write)
					[2]: arg1 (copied, readonly)
				]]
				var2_upvw.flashScreen(arg1, Color3.new(1, 0.490196, 0.490196), 0.3)
				var2_upvw.impactFrame(arg1)
			end)
			clone_2_upvr.Strike:Play()
			clone_2_upvr.chime:Play()
			for i_2, v_2_upvr in var2_upvw.findEnemiesPart(clone_3), nil do
				if not var2_upvw.CheckBlock(v_2_upvr) then
					for _, v_3 in v_2_upvr.Humanoid:GetPlayingAnimationTracks() do
						v_3:AdjustSpeed(0)
					end
					local BodyVelocity = Instance.new("BodyVelocity", v_2_upvr.Torso)
					BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					BodyVelocity.Velocity = Vector3.new(0, 0, 0)
					game.Debris:AddItem(BodyVelocity, 1)
					var2_upvw.applyStatus(v_2_upvr, "Stunned", 1)
					var2_upvw.applyStatus(v_2_upvr, "AutoRotate", 1)
					task.delay(0.8, function() -- Line 110
						--[[ Upvalues[4]:
							[1]: Aggressive_Breeze_upvr (copied, readonly)
							[2]: v_2_upvr (readonly)
							[3]: var2_upvw (copied, read and write)
							[4]: arg1 (copied, readonly)
						]]
						local clone = Aggressive_Breeze_upvr.VFX.ExplosionVFX:Clone()
						clone.Parent = v_2_upvr.HumanoidRootPart
						var2_upvw.EmitAllDescendants(clone)
						for _, v_4 in clone:GetChildren() do
							if v_4:IsA("Sound") then
								v_4.PlaybackSpeed += math.random(-1, 1) * 0.1
								v_4:Play()
							end
						end
						var2_upvw.applyDamage(v_2_upvr, 12)
						var2_upvw.applyStatus(v_2_upvr, "Stunned", 0.8)
						var2_upvw.applyStatus(v_2_upvr, "AutoRotate", 0.8)
						var2_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 0.5)
						var2_upvw.camShake(arg1, "Bump")
						var2_upvw.Blur(arg1, 20, 0.3)
						var2_upvw.flashScreen(v_2_upvr, Color3.new(1, 1, 1), 0.5)
						var2_upvw.camShake(v_2_upvr, "Bump")
						var2_upvw.Blur(v_2_upvr, 20, 0.3)
					end)
				end
			end
			if 0 + 1 <= 0 then
				i_2 = 1.5
				var2_upvw.applyStatus(arg1, "AutoRotate", i_2)
				i_2 = 1.5
				var2_upvw.applyStatus(arg1, "Stunned", i_2)
			end
		end
	end)
	task.delay(2, function() -- Line 145
		--[[ Upvalues[1]:
			[1]: var16_upvw (read and write)
		]]
		if not var16_upvw then
		else
			var16_upvw:Disconnect()
		end
	end)
end
return module_upvr