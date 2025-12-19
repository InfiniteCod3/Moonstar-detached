-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:58
-- Luau version 6, Types version 3
-- Time taken: 0.009765 seconds

local module_upvr = {
	Cooldown = 20;
	GlobalCD = 1.2;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 10
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
	local Wind_Lance_upvr = ReplicatedStorage_upvr.Skills["Wind Spear"]["Wind Lance"]
	local Wind_Spear_upvr = arg1:FindFirstChild("Wind Spear")
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Wind_Lance_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(0.9)
	var2_upvw.applyStatus(arg1, "Freeze", 1.2)
	Wind_Spear_upvr.Sounds.Breathe:Play()
	Wind_Spear_upvr.Sounds.Breathe.Volume = 0
	TweenService_upvr:Create(Wind_Spear_upvr.Sounds.Breathe, TweenInfo.new(1), {
		Volume = 10;
	}):Play()
	local HumanoidRootPart_upvr_2 = arg1:FindFirstChild("HumanoidRootPart")
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("throw"):Connect(function() -- Line 33
		--[[ Upvalues[7]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: Wind_Spear_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: arg1 (readonly)
			[5]: Wind_Lance_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: HumanoidRootPart_upvr_2 (readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
		TweenService_upvr:Create(Wind_Spear_upvr.Sounds.Breathe, TweenInfo.new(1), {
			Volume = 0;
		}):Play()
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.Blur(arg1, 10, 0.35)
		var2_upvw.changeFov(arg1, 65, 0.01, 0.3)
		Wind_Spear_upvr.Transparency = 1
		Wind_Spear_upvr.Glow.Transparency = 1
		delay(0.5, function() -- Line 41
			--[[ Upvalues[2]:
				[1]: TweenService_upvr (copied, readonly)
				[2]: Wind_Spear_upvr (copied, readonly)
			]]
			TweenService_upvr:Create(Wind_Spear_upvr, TweenInfo.new(1), {
				Transparency = 0;
			}):Play()
			task.wait(1)
			TweenService_upvr:Create(Wind_Spear_upvr.Glow, TweenInfo.new(1), {
				Transparency = 0;
			}):Play()
		end)
		Wind_Spear_upvr.Sounds.throwSfx:Play()
		Wind_Spear_upvr.Sounds.Whoosh:Play()
		local clone_upvr = Wind_Lance_upvr.SpearThrow:Clone()
		clone_upvr.Parent = Folder_upvr
		clone_upvr.CFrame = (HumanoidRootPart_upvr_2.CFrame + HumanoidRootPart_upvr_2.CFrame.LookVector * 5) * CFrame.Angles((-math.pi/2), 0, 0)
		local clone = Wind_Lance_upvr.windVfx:Clone()
		clone.Parent = Folder_upvr
		clone.CFrame = HumanoidRootPart_upvr_2.CFrame
		var2_upvw.EmitAllDescendants(clone)
		local tbl = {}
		local CFrame_upvr = clone_upvr.CFrame
		tbl.CFrame = clone_upvr.CFrame + CFrame_upvr.UpVector * 60
		TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.5), tbl):Play()
		-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [170] 125. Error Block 23 start (CF ANALYSIS FAILED)
		local HumanoidRootPart_upvr = CFrame_upvr:FindFirstChild("HumanoidRootPart")
		clone_upvr.Anchored = false
		clone_upvr.weld.Part0 = CFrame_upvr.Torso
		clone_upvr.bleedSfx:Play()
		clone_upvr.Stab:Play()
		table.insert({}, CFrame_upvr)
		if 0 < CFrame_upvr.Humanoid.Health - 10 then
			for _, v in clone_upvr.bleed:GetChildren() do
				v.Enabled = true
			end
			var2_upvw.applyStatus(arg1, "CombatStun", 2.15)
			local Position = HumanoidRootPart_upvr.Position
			HumanoidRootPart_upvr.CFrame = CFrame.lookAt(Vector3.new(Position.X, HumanoidRootPart_upvr_2.Position.Y, Position.Z), HumanoidRootPart_upvr_2.Position)
			task.delay(0.05, function() -- Line 92
				--[[ Upvalues[2]:
					[1]: CFrame_upvr (readonly)
					[2]: Wind_Lance_upvr (copied, readonly)
				]]
				CFrame_upvr.Humanoid.Animator:LoadAnimation(Wind_Lance_upvr.EnemyAnimation):Play()
			end)
			local var30_upvr = HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -1000
			task.delay(0.25, function() -- Line 97
				--[[ Upvalues[5]:
					[1]: clone_upvr (readonly)
					[2]: var2_upvw (copied, read and write)
					[3]: arg1 (copied, readonly)
					[4]: HumanoidRootPart_upvr (readonly)
					[5]: var30_upvr (readonly)
				]]
				for _, v_2_upvr in clone_upvr.WindCharge:GetChildren() do
					if v_2_upvr:IsA("ParticleEmitter") then
						v_2_upvr.Enabled = true
						task.delay(0.5, function() -- Line 101
							--[[ Upvalues[1]:
								[1]: v_2_upvr (readonly)
							]]
							v_2_upvr.Enabled = false
						end)
					end
				end
				clone_upvr.WindCharge.chargeSFX:Play()
				clone_upvr.WindExplode.explosionSFX.PlayOnRemove = true
				task.wait(0.75)
				game.Debris:AddItem(clone_upvr.WindExplode.explosionSFX, 0)
				clone_upvr.Transparency = 1
				clone_upvr.Glow.Transparency = 1
				clone_upvr.bleed:Destroy()
				clone_upvr.bleedSfx:Destroy()
				var2_upvw.EmitAllDescendants(clone_upvr.WindExplode)
				var2_upvw.camShake(arg1, "Bump")
				var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position, 18, true)
				for _, v_3 in var2_upvw.FoundEnemies do
					var2_upvw.camShake(v_3, "Bump")
					var2_upvw.applyStatus(v_3, "Stunned", 0.75)
					var2_upvw.Knockback(v_3, var30_upvr, 65, 15)
					var2_upvw.applyStatus(v_3, "Ragdoll", 1.1)
					var2_upvw.applyDamage(v_3, 10)
				end
			end)
		end
		var30_upvr = var2_upvw
		var30_upvr = CFrame_upvr
		var30_upvr.Knockback(var30_upvr, HumanoidRootPart_upvr_2.Position, 100, 2)
		var30_upvr = var2_upvw
		var30_upvr = CFrame_upvr
		var30_upvr.applyStatus(var30_upvr, "Stunned", 1.5)
		var30_upvr = var2_upvw
		var30_upvr = CFrame_upvr
		var30_upvr.applyStatus(var30_upvr, "AutoRotate", 1.5)
		var30_upvr = var2_upvw
		var30_upvr = CFrame_upvr
		var30_upvr.applyDamage(var30_upvr, 10)
		var30_upvr = var2_upvw
		var30_upvr = CFrame_upvr
		var30_upvr.blood(var30_upvr, 3)
		-- KONSTANTERROR: [170] 125. Error Block 23 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [150] 110. Error Block 2 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: Expression was reused, decompilation is incorrect
		-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [319.197660]
		-- KONSTANTERROR: [150] 110. Error Block 2 end (CF ANALYSIS FAILED)
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 148
		--[[ Upvalues[1]:
			[1]: Wind_Spear_upvr (readonly)
		]]
		if Wind_Spear_upvr.Sounds:FindFirstChild(arg1_2) then
			Wind_Spear_upvr.Sounds[arg1_2]:Play()
		end
	end), module_upvr.Cooldown)
end
return module_upvr