-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:41
-- Luau version 6, Types version 3
-- Time taken: 0.018765 seconds

local module_upvr = {
	Cooldown = 12;
	GlobalCD = 1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 16
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
	local Pillars_of_Fate_upvr = ReplicatedStorage_upvr.Skills["Earth Hammer"].Ultimate["Pillars of Fate"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Pillars_of_Fate_upvr.Animation)
	any_LoadAnimation_result1:Play()
	local Earth_Hammer_upvr = arg1:FindFirstChild("Earth Hammer")
	var2_upvw.conTimer(any_LoadAnimation_result1.Stopped:Connect(function() -- Line 32
		--[[ Upvalues[1]:
			[1]: Earth_Hammer_upvr (readonly)
		]]
		Earth_Hammer_upvr.TrailAtt.Trail.Enabled = false
	end), module_upvr.Cooldown)
	any_LoadAnimation_result1:AdjustSpeed(1)
	local clone_upvr = Pillars_of_Fate_upvr.Part.sounds:Clone()
	clone_upvr.Parent = arg1.Torso
	var2_upvw.applyDebris(clone_upvr, 10)
	var2_upvw.applyStatus(arg1, "Freeze", 1)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 45
		--[[ Upvalues[1]:
			[1]: clone_upvr (readonly)
		]]
		if clone_upvr:FindFirstChild(arg1_2) then
			for _, v in clone_upvr:GetChildren() do
				if v.Name == arg1_2 then
					v:Play()
				end
			end
			return
		end
	end), module_upvr.Cooldown)
	var2_upvw.changeFov(arg1, 90, 0.6, 3)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("stomp"):Connect(function() -- Line 59
		--[[ Upvalues[8]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: clone_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: Pillars_of_Fate_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: module_upvr (copied, readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
		var2_upvw.applyStatus(arg1, "AutoRotate", 0.3)
		clone_upvr.smash:Play()
		local var19 = arg1["Right Leg"].Position + HumanoidRootPart_upvr.CFrame.LookVector * 2
		local clone_3 = Pillars_of_Fate_upvr.SmashVfx:Clone()
		clone_3.Parent = Folder_upvr
		clone_3.Position = var19
		var2_upvw.EmitAllDescendants(clone_3)
		var2_upvw.applyDebris(clone_3, 5)
		;(function(arg1_3) -- Line 71, Named "screenEffects"
			--[[ Upvalues[1]:
				[1]: var2_upvw (copied, read and write)
			]]
			var2_upvw.changeFov(arg1_3, 65, 0.01, 0.9)
			var2_upvw.camShake(arg1_3, "Bump")
			var2_upvw.flashScreen(arg1_3, Color3.new(0.478431, 0.478431, 0.478431), 0.25)
		end)(arg1)
		var2_upvw.crater(1, var19, 2.5, 0.5)
		var2_upvw.crater(1, var19, 2, 0.12)
		var2_upvw.CreateDebris(var19, 8, 0.75, 0.9, 0.1)
		local tbl_upvr = {}
		local function _(arg1_4) -- Line 83, Named "createPillar"
			--[[ Upvalues[8]:
				[1]: var2_upvw (copied, read and write)
				[2]: arg1 (copied, readonly)
				[3]: Pillars_of_Fate_upvr (copied, readonly)
				[4]: Folder_upvr (copied, readonly)
				[5]: TweenService_upvr (copied, readonly)
				[6]: module_upvr (copied, readonly)
				[7]: tbl_upvr (readonly)
				[8]: HumanoidRootPart_upvr (copied, readonly)
			]]
			var2_upvw.camShake(arg1, "Bump")
			var2_upvw.changeFov(arg1, 55, 0.01, 0.5)
			local clone_2_upvr = Pillars_of_Fate_upvr.Pillar:Clone()
			clone_2_upvr.Parent = Folder_upvr
			clone_2_upvr.Position = arg1_4
			TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(0.8), {
				Size = Vector3.new(13, 300, 13);
			}):Play()
			var2_upvw.applyDebris(clone_2_upvr, 10)
			var2_upvw.EmitAllDescendants(clone_2_upvr.Attachment)
			var2_upvw.applyDebris(clone_2_upvr.Attachment, 1)
			var2_upvw.CreateDebris(arg1_4 + Vector3.new(0, 1, 0), 5, 1.5, 1.5, 0.1)
			clone_2_upvr.Color = Color3.new(1, 1, 1)
			clone_2_upvr.Material = Enum.Material.Neon
			local any_Create_result1_2 = TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(0.45, Enum.EasingStyle.Linear), {
				Color = clone_2_upvr.Color;
			})
			any_Create_result1_2:Play()
			var2_upvw.conTimer(any_Create_result1_2.Completed:Connect(function() -- Line 101
				--[[ Upvalues[5]:
					[1]: clone_2_upvr (readonly)
					[2]: TweenService_upvr (copied, readonly)
					[3]: var2_upvw (copied, read and write)
					[4]: arg1 (copied, readonly)
					[5]: module_upvr (copied, readonly)
				]]
				clone_2_upvr.Material = Enum.Material.Slate
				task.wait(5)
				local any_Create_result1 = TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(2, Enum.EasingStyle.Linear), {
					Size = Vector3.new(13, 0, 13);
				})
				any_Create_result1:Play()
				clone_2_upvr.RockMove:Play()
				var2_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 108
					--[[ Upvalues[3]:
						[1]: clone_2_upvr (copied, readonly)
						[2]: var2_upvw (copied, read and write)
						[3]: arg1 (copied, readonly)
					]]
					clone_2_upvr.Transparency = 1
					var2_upvw.EmitAllDescendants(clone_2_upvr.Attachment2)
					var2_upvw.applyDebris(clone_2_upvr.Attachment2, 1)
					var2_upvw.camShake(arg1, "Bump")
				end), module_upvr.Cooldown)
			end), module_upvr.Cooldown)
			task.spawn(function() -- Line 116
				--[[ Upvalues[1]:
					[1]: clone_2_upvr (readonly)
				]]
				local Position = clone_2_upvr.Position
				local Rotation = clone_2_upvr.Rotation
				for _ = 1, 25 do
					clone_2_upvr.Position = Position + Vector3.new(math.random(-4, 0.4), 0, math.random(-4, 4) * 0.1)
					clone_2_upvr.Rotation = Rotation + Vector3.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
					task.wait()
				end
				clone_2_upvr.Position = Position
				clone_2_upvr.Rotation = Rotation
			end)
			clone_2_upvr.Rocks:Play()
			local Rocks = clone_2_upvr.Rocks
			Rocks.PlaybackSpeed += math.random(-1, 1) * 0.1
			clone_2_upvr.HolySfx:Play()
			local HolySfx = clone_2_upvr.HolySfx
			HolySfx.PlaybackSpeed += math.random(-1, 1) * 0.1
			clone_2_upvr["Light Spell"]:Play()
			local Light_Spell = clone_2_upvr["Light Spell"]
			Light_Spell.PlaybackSpeed += math.random(-1, 1) * 0.1
			TweenService_upvr:Create(clone_2_upvr["Light Spell"], TweenInfo.new(2), {
				Volume = 0;
			}):Play()
			task.delay(0.03, function() -- Line 138
				--[[ Upvalues[6]:
					[1]: Pillars_of_Fate_upvr (copied, readonly)
					[2]: Folder_upvr (copied, readonly)
					[3]: clone_2_upvr (readonly)
					[4]: var2_upvw (copied, read and write)
					[5]: tbl_upvr (copied, readonly)
					[6]: HumanoidRootPart_upvr (copied, readonly)
				]]
				local clone = Pillars_of_Fate_upvr.Hitbox:Clone()
				clone.Parent = Folder_upvr
				clone.Position = clone_2_upvr.Position
				var2_upvw.applyDebris(clone, 0.1)
				for _, v_2 in var2_upvw.findEnemiesPart(clone, true), nil do
					if not table.find(tbl_upvr, v_2) then
						table.insert(tbl_upvr, v_2)
						var2_upvw.applyStatus(v_2, "Ragdoll", 3.2)
						var2_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position, -20, 120)
						var2_upvw.applyDamage(v_2, 25)
					end
				end
			end)
		end
		-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [92] 76. Error Block 2 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [92] 76. Error Block 2 end (CF ANALYSIS FAILED)
	end), module_upvr.Cooldown)
end
return module_upvr