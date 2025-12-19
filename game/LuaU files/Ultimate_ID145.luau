-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:57
-- Luau version 6, Types version 3
-- Time taken: 0.007812 seconds

local module = {
	GlobalCD = 1.6;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module.Script(arg1, arg2) -- Line 10
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, 16.6)
	local Ultimate_upvr = ReplicatedStorage_upvr.Skills["Wind Spear"].Ultimate
	local Wind_Spear_upvr = arg1:FindFirstChild("Wind Spear")
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Ultimate_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(0.5)
	var2_upvw.applyStatus(arg1, "Freeze", 2.4000000000000004)
	var2_upvw.applyStatus(arg1, "IFrames", 2.4000000000000004)
	var2_upvw.applyStatus(arg1, "LockUltimateMeter", 10)
	var2_upvw.changeFov(arg1, 105, 1.2, 5)
	Wind_Spear_upvr.Sounds.spearLift:Play()
	task.delay(0.86, function() -- Line 34
		--[[ Upvalues[2]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
			[2]: Wind_Spear_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:AdjustSpeed(1)
		Wind_Spear_upvr.Sounds.spearSlam:Play()
	end)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slam"):Connect(function() -- Line 39
		--[[ Upvalues[7]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Wind_Spear_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: Ultimate_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
		]]
		var2_upvw.applyStatus(arg1, "AutoRotate", 1.6)
		Wind_Spear_upvr.Sounds.groundSmash:Play()
		Wind_Spear_upvr.Sounds.tornado:Play()
		delay(0.9, function() -- Line 44
			--[[ Upvalues[1]:
				[1]: Wind_Spear_upvr (copied, readonly)
			]]
			Wind_Spear_upvr.Sounds.tornado:Stop()
			for _, v in Wind_Spear_upvr.tornado:GetChildren() do
				v.Enabled = false
			end
		end)
		for _, v_2 in Wind_Spear_upvr.tornado:GetChildren() do
			v_2.Enabled = true
		end
		var2_upvw.crater(1, HumanoidRootPart_upvr.Position, 5, 1.1)
		var2_upvw.CreateDebris(HumanoidRootPart_upvr.Position, 8, 2, 0.5, 0.1)
		var2_upvw.changeFov(arg1, 70, 0.01, 0.8)
		var2_upvw.camShake(arg1, "Explosion")
		var2_upvw.impactFrame2(arg1)
		local clone_upvr = Ultimate_upvr.Tornado:Clone()
		clone_upvr.Parent = Folder_upvr
		clone_upvr.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 16 - Vector3.new(0, 3, 0)
		clone_upvr.sfx.Volume = 0
		clone_upvr.sfx:Play()
		TweenService_upvr:Create(clone_upvr.sfx, TweenInfo.new(1), {
			Volume = clone_upvr.sfx.Volume;
		}):Play()
		clone_upvr.bang:Play()
		game.Debris:AddItem(clone_upvr, 10)
		for _, v_3 in clone_upvr:GetDescendants() do
			if v_3:IsA("ParticleEmitter") then
				v_3.Enabled = true
			end
		end
		local any_Create_result1 = TweenService_upvr:Create(clone_upvr, TweenInfo.new(6, Enum.EasingStyle.Linear), {
			CFrame = clone_upvr.CFrame + clone_upvr.CFrame.LookVector * 300;
		})
		any_Create_result1:Play()
		local var34_upvw = true
		var2_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 84
			--[[ Upvalues[3]:
				[1]: var34_upvw (read and write)
				[2]: clone_upvr (readonly)
				[3]: TweenService_upvr (copied, readonly)
			]]
			var34_upvw = false
			clone_upvr.bang:Stop()
			TweenService_upvr:Create(clone_upvr.sfx, TweenInfo.new(1), {
				Volume = 0;
			}):Play()
			for _, v_4 in clone_upvr:GetDescendants() do
				if v_4:IsA("ParticleEmitter") then
					v_4.Enabled = false
				end
			end
		end), 30)
		local tbl = {}
		while task.wait(0.2) and var34_upvw do
			local var43 = 6 - 0.2
			var2_upvw.CreateDebris(clone_upvr.Position, 4, 3, 2, 0.2)
			var2_upvw.CreateDebris(clone_upvr.Position, 1, 4, 6, 0.1)
			for _, v_5 in var2_upvw.findEnemiesPart(clone_upvr.Hitbox, true), nil do
				if not table.find(tbl, v_5) then
					table.insert(tbl, v_5)
					var2_upvw.applyStatus(v_5, "Ragdoll", var43 + 2)
					var2_upvw.applyStatus(v_5, "DashDB", var43 + 0.5)
				end
				var2_upvw.Knockback(v_5, clone_upvr.Hitbox.Position, -100, 25 + math.random(-40, 25))
				var2_upvw.applyDamage(v_5, 4)
			end
		end
	end), 10)
end
return module