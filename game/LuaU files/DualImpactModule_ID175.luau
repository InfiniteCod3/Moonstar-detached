-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:10
-- Luau version 6, Types version 3
-- Time taken: 0.008843 seconds

local module_upvr = {
	Cooldown = 25;
	GlobalCD = 0.1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Dual_Impact_upvr = ReplicatedStorage_upvr.Skills["Firework Rapier"]["Dual Impact"]
	local Firework_Rapier_upvr = arg1:FindFirstChild("Firework Rapier")
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Dual_Impact_upvr.Animation)
	any_LoadAnimation_result1:Play()
	local function ToggleTrails_upvr(arg1_2) -- Line 33, Named "ToggleTrails"
		--[[ Upvalues[1]:
			[1]: Firework_Rapier_upvr (readonly)
		]]
		for _, v in Firework_Rapier_upvr:GetDescendants() do
			if v:IsA("Trail") and v.Name == "Trail" then
				v.Enabled = arg1_2
			end
		end
	end
	ToggleTrails_upvr(true)
	any_LoadAnimation_result1.Stopped:Connect(function() -- Line 42
		--[[ Upvalues[1]:
			[1]: ToggleTrails_upvr (readonly)
		]]
		ToggleTrails_upvr(false)
	end)
	local clone_2 = Dual_Impact_upvr.swipe:Clone()
	clone_2.Parent = HumanoidRootPart_upvr
	clone_2:Play()
	var2_upvw.applyDebris(clone_2, 3)
	local clone_4 = Dual_Impact_upvr.swipe2:Clone()
	clone_4.Parent = HumanoidRootPart_upvr
	clone_4:Play()
	var2_upvw.applyDebris(clone_4, 3)
	var2_upvw.applyStatus(arg1, "Slowed", 1)
	var2_upvw.applyStatus(arg1, "GlobalCD", 1)
	any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function() -- Line 62
		--[[ Upvalues[5]:
			[1]: Dual_Impact_upvr (readonly)
			[2]: Folder_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: arg1 (readonly)
		]]
		local clone_3 = Dual_Impact_upvr.JabVFX:Clone()
		clone_3.Parent = Folder_upvr
		clone_3.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 1
		var2_upvw.EmitAllDescendants(clone_3)
		for _, v_2 in clone_3:GetChildren() do
			if v_2:IsA("Sound") then
				v_2:Play()
			end
		end
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.flashScreen(arg1, Color3.new(1, 0.52549, 0.113725), 0.6)
		var2_upvw.changeFov(arg1, 60, 0.01, 1)
		for _, v_3_upvr in var2_upvw.findEnemiesPart(clone_3.Hitbox), nil do
			if not var2_upvw.CheckBlock(v_3_upvr, true) then
				var2_upvw.applyDamage(v_3_upvr, 4)
				var2_upvw.Knockback(v_3_upvr, HumanoidRootPart_upvr.Position, 40)
				var2_upvw.applyStatus(v_3_upvr, "Stunned", 2)
				task.spawn(function() -- Line 85
					--[[ Upvalues[5]:
						[1]: Dual_Impact_upvr (copied, readonly)
						[2]: v_3_upvr (readonly)
						[3]: var2_upvw (copied, read and write)
						[4]: HumanoidRootPart_upvr (copied, readonly)
						[5]: arg1 (copied, readonly)
					]]
					for i_4 = 1, 2 do
						task.wait()
						local clone_5 = Dual_Impact_upvr.VFX.FireworkBall:Clone()
						clone_5.Parent = v_3_upvr.HumanoidRootPart
						clone_5.Charge:Play()
						task.wait(0.5 + 0.3 + math.random(-5, 5) * 0.025)
						for _, v_4 in clone_5.ExplosionVFX:GetChildren() do
							if v_4:IsA("Sound") then
								v_4:Play()
							end
						end
						for _, v_5 in clone_5:GetChildren() do
							if v_5:IsA("ParticleEmitter") then
								v_5:Destroy()
							end
						end
						var2_upvw.EmitAllDescendants(clone_5.ExplosionVFX)
						var2_upvw.applyDamage(v_3_upvr, 8)
						var2_upvw.Knockback(v_3_upvr, HumanoidRootPart_upvr.Position, 12, 30)
						var2_upvw.applyStatus(v_3_upvr, "Ragdoll", 1.6)
						if i_4 == 1 then
							var2_upvw.applyStatus(v_3_upvr, "DashDB", 0 + 0.35 + math.random(-5, 5) * 0.025)
						end
						var2_upvw.flashScreen(v_3_upvr, Color3.new(1, 0.52549, 0.113725), 0.4)
						var2_upvw.changeFov(v_3_upvr, 60, 0.01, 1)
						var2_upvw.Blur(v_3_upvr, 12, 0.4)
						var2_upvw.camShake(v_3_upvr, "SmallBump")
						var2_upvw.flashScreen(arg1, Color3.new(1, 0.52549, 0.113725), 0.4)
						var2_upvw.changeFov(arg1, 60, 0.01, 1)
						var2_upvw.Blur(arg1, 12, 0.4)
						var2_upvw.camShake(arg1, "SmallBump")
					end
				end)
			end
		end
	end)
	any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_3) -- Line 133
		--[[ Upvalues[1]:
			[1]: Firework_Rapier_upvr (readonly)
		]]
		for _, v_6 in Firework_Rapier_upvr:GetChildren() do
			if v_6.Name == arg1_3 then
				local clone = v_6:Clone()
				clone.Name = "SfxClone"
				clone.Parent = Firework_Rapier_upvr
				clone.PlaybackSpeed += math.random(-1, 1) * 0.1
				clone:Play()
				game.Debris:AddItem(clone, 2)
			end
		end
	end)
end
return module_upvr