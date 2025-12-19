-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:19:08
-- Luau version 6, Types version 3
-- Time taken: 0.022177 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 27
module_upvr.GlobalCD = 1
local TweenService_upvr = game:GetService("TweenService")
local Bezier_upvr = require(ReplicatedStorage_upvr.Modules.Bezier)
function module_upvr.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[4]:
		[1]: module_upvr (readonly)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: TweenService_upvr (readonly)
		[4]: Bezier_upvr (readonly)
	]]
	local Skills_upvr = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Pan_Fry_upvr = ReplicatedStorage_upvr.Skills.Chef["Pan Fry"]
	local Chef = arg1:FindFirstChild("Chef")
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Pan_Fry_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(1)
	Skills_upvr.applyStatus(arg1, "Freeze", 1.6)
	Skills_upvr.applyStatus(arg1, "GlobalCD", 1.6)
	Skills_upvr.camShake(arg1, "SmallBump")
	Skills_upvr.changeFov(arg1, 65, 0.5, 2)
	local var11_upvw
	if arg1:FindFirstChild("HotPan") then
		var11_upvw = Pan_Fry_upvr.CriticalCookingVFX:Clone()
	else
		var11_upvw = Pan_Fry_upvr.CookingVFX:Clone()
	end
	var11_upvw.Parent = Chef
	var11_upvw.weld.Part0 = Chef.Pan
	var11_upvw.weld.Part1 = var11_upvw
	Skills_upvr.conTimer(any_LoadAnimation_result1_upvr.Stopped:Once(function() -- Line 47
		--[[ Upvalues[3]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: var11_upvw (read and write)
			[3]: arg1 (readonly)
		]]
		TweenService_upvr:Create(var11_upvw, TweenInfo.new(0.5), {
			Transparency = 1;
		}):Play()
		for _, v in var11_upvw:GetChildren() do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
		if arg1:FindFirstChild("HotPan") then
			arg1.HotPan.Name = "UsedHotPan"
		end
	end), 4)
	local any_applySound_result1_upvr_2 = Skills_upvr.applySound(Pan_Fry_upvr.CookingSFX, HumanoidRootPart_upvr, 4)
	delay(0.5, function() -- Line 63
		--[[ Upvalues[2]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: any_applySound_result1_upvr_2 (readonly)
		]]
		TweenService_upvr:Create(any_applySound_result1_upvr_2, TweenInfo.new(0.4), {
			Volume = 0;
		}):Play()
	end)
	local any_applySound_result1_upvr = Skills_upvr.applySound(Pan_Fry_upvr.swingSFX2, HumanoidRootPart_upvr, 4)
	Skills_upvr.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Toss"):Once(function() -- Line 67
		--[[ Upvalues[9]:
			[1]: Skills_upvr (readonly)
			[2]: arg1 (readonly)
			[3]: Pan_Fry_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: Bezier_upvr (copied, readonly)
			[7]: any_LoadAnimation_result1_upvr (readonly)
			[8]: TweenService_upvr (copied, readonly)
			[9]: any_applySound_result1_upvr (readonly)
		]]
		Skills_upvr.camShake(arg1, "SmallBump")
		Skills_upvr.changeFov(arg1, 100, 0.05, 0.5)
		local any_cloneInstance_result1_2 = Skills_upvr.cloneInstance(Pan_Fry_upvr.HitboxHolder, Folder_upvr, 1)
		any_cloneInstance_result1_2.CFrame = HumanoidRootPart_upvr.CFrame
		Skills_upvr.crater(1, any_cloneInstance_result1_2.Hitbox.Position, 2, 0.25)
		Skills_upvr.CreateDebris(any_cloneInstance_result1_2.Hitbox.Position, 6, 1.5, 1, 0.1)
		local tbl = {}
		tbl.Character = arg1
		tbl.Replication = "Toss"
		tbl.AbilityCF = any_cloneInstance_result1_2.CFrame
		Skills_upvr.Replication("All", "Chef", tbl)
		local var30
		for i_2, v_2 in Skills_upvr.findEnemiesPart(any_cloneInstance_result1_2.Hitbox, true), nil do
			if not Skills_upvr.CheckBlock(v_2, false) then
				local HumanoidRootPart = v_2.HumanoidRootPart
				Skills_upvr.unragdoll(v_2)
				Skills_upvr.applyDamage(v_2, 10)
				v_2.Humanoid:LoadAnimation(Pan_Fry_upvr.FlipAnimation):Play(0)
				HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, Vector3.new(HumanoidRootPart_upvr.Position.X, HumanoidRootPart.Position.Y, HumanoidRootPart_upvr.Position.Z))
				Skills_upvr.applyStatus(v_2, "Stunned", 0.9)
				Skills_upvr.applyStatus(v_2, "AutoRotate", 0.9)
				local BodyVelocity = Instance.new("BodyVelocity", v_2.Torso)
				BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				BodyVelocity.Velocity = Vector3.new(0, 0, 0)
				Skills_upvr.applyDebris(BodyVelocity, 0.9)
				Bezier_upvr.new(HumanoidRootPart.Position, HumanoidRootPart.CFrame:Lerp(HumanoidRootPart_upvr.CFrame, 0.5).Position + Vector3.new(0, 22, 0), HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 8):CreateCFrameTween(HumanoidRootPart, {"CFrame"}, TweenInfo.new(0.7, Enum.EasingStyle.Linear)):Play()
			end
		end
		if not nil then
			wait(0.2)
			any_LoadAnimation_result1_upvr:Stop(0.5)
			i_2 = 0.6
			Skills_upvr.applyStatus(arg1, "Freeze", i_2)
			i_2 = 0.6
			Skills_upvr.applyStatus(arg1, "GlobalCD", i_2)
			i_2 = TweenInfo.new
			v_2 = 0.3
			i_2 = i_2(v_2)
			v_2 = {}
			v_2.Volume = 0
			TweenService_upvr:Create(any_applySound_result1_upvr, i_2, v_2):Play()
			return
		end
	end), 3)
	Skills_upvr.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Action"):Once(function() -- Line 120
		--[[ Upvalues[5]:
			[1]: Skills_upvr (readonly)
			[2]: arg1 (readonly)
			[3]: Pan_Fry_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
		]]
		Skills_upvr.camShake(arg1, "Bump")
		Skills_upvr.changeFov(arg1, 70, 0, 0.4)
		local any_cloneInstance_result1 = Skills_upvr.cloneInstance(Pan_Fry_upvr.HitboxHolder2, Folder_upvr, 1)
		any_cloneInstance_result1.CFrame = HumanoidRootPart_upvr.CFrame
		local var40
		if var40 then
			var40 = Skills_upvr.Replication
			local tbl_3 = {}
			tbl_3.Character = arg1
			tbl_3.Replication = "Critical Pan Fry"
			tbl_3.AbilityCF = any_cloneInstance_result1.CFrame
			var40("All", "Chef", tbl_3)
		else
			var40 = Skills_upvr.Replication
			local tbl_2 = {}
			tbl_2.Character = arg1
			tbl_2.Replication = "Pan Fry"
			tbl_2.AbilityCF = any_cloneInstance_result1.CFrame
			var40("All", "Chef", tbl_2)
		end
		var40 = false
		for _, v_3 in Skills_upvr.findEnemiesPart(any_cloneInstance_result1.Hitbox, true), nil do
			if not Skills_upvr.CheckBlock(v_3, true) then
				var40 = true
				Skills_upvr.unragdoll(v_3)
				if arg1:FindFirstChild("HotPan") then
					Skills_upvr.applyDamage(v_3, 20)
				else
					Skills_upvr.applyDamage(v_3, 10)
				end
				Skills_upvr.applyStatus(v_3, "Ragdoll", 2)
				Skills_upvr.Knockback(v_3, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 30, 60)
				v_3.Humanoid:LoadAnimation(Pan_Fry_upvr.FlipAnimation):Play(0)
			end
		end
		if var40 then
		end
		if arg1:FindFirstChild("HotPan") then
			arg1.HotPan.Name = "UsedHotPan"
		end
	end), 3)
end
return module_upvr