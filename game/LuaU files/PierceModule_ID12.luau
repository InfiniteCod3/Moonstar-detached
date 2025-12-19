-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:12:58
-- Luau version 6, Types version 3
-- Time taken: 0.029276 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 24
module_upvr.GlobalCD = 1
local var3_upvw
local RunService_upvr = game:GetService("RunService")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 18
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: RunService_upvr (readonly)
		[5]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Pierce_upvr = ReplicatedStorage_upvr.Skills["Basic Sword"].Ultimate.Pierce
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid"):LoadAnimation(Pierce_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play(0)
	any_LoadAnimation_result1_upvr:AdjustSpeed(0.9)
	local tbl = {}
	table.insert(tbl, var3_upvw.applyStatus(arg1, "Stunned", 3))
	table.insert(tbl, var3_upvw.applyStatus(arg1, "AutoRotate", 3))
	var3_upvw.camShake(arg1, "SmallBump")
	var3_upvw.changeFov(arg1, 100, 0.5, 0.8)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 43
		--[[ Upvalues[3]:
			[1]: Pierce_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var3_upvw (copied, read and write)
		]]
		for _, v in Pierce_upvr:GetChildren() do
			if v:IsA("Sound") and v.Name == arg1_2 then
				local clone = v:Clone()
				clone.Parent = HumanoidRootPart_upvr
				clone:Play()
				var3_upvw.applyDebris(clone, clone.TimeLength * clone.PlaybackSpeed)
			end
		end
	end), module_upvr.Cooldown)
	var3_upvw.camShake(arg1, "SmallBump")
	var3_upvw.changeFov(arg1, 69, 0, 2)
	var3_upvw.EmitAllDescendants(var3_upvw.applyVFX(Pierce_upvr.VFX.pulseVFX, HumanoidRootPart_upvr, 3))
	local var18_upvw
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("charge"):Connect(function() -- Line 60
		--[[ Upvalues[5]:
			[1]: var18_upvw (read and write)
			[2]: var3_upvw (copied, read and write)
			[3]: Pierce_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: arg1 (readonly)
		]]
		var18_upvw = var3_upvw.applyVFX(Pierce_upvr.VFX.chargeVFX, HumanoidRootPart_upvr, 3)
		for _ = 1, 30.333333333333336 do
			var3_upvw.changeFov(arg1, 69, 0, 5)
			var3_upvw.camShake(arg1, "SmallBump")
			task.wait()
		end
	end), module_upvr.Cooldown)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("fire"):Connect(function() -- Line 69
		--[[ Upvalues[9]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: var18_upvw (read and write)
			[4]: Pierce_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: RunService_upvr (copied, readonly)
			[8]: module_upvr (copied, readonly)
			[9]: TweenService_upvr (copied, readonly)
		]]
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.changeFov(arg1, 100, 0, 3)
		var3_upvw.applyDebris(var18_upvw, 0)
		var3_upvw.EmitAllDescendants(var3_upvw.applyVFX(Pierce_upvr.VFX.fireVFX, HumanoidRootPart_upvr, 3))
		var3_upvw.Knockback(arg1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 20, 20)
		local clone_upvr_2 = Pierce_upvr.PierceBall:Clone()
		clone_upvr_2.Parent = Folder_upvr
		clone_upvr_2.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 20
		clone_upvr_2.pulling:Play()
		local var27_upvr = HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 100
		local BodyPosition_2_upvr = Instance.new("BodyPosition", clone_upvr_2)
		BodyPosition_2_upvr.MaxForce = Vector3.new(1000000, 1000000, 1000000)
		BodyPosition_2_upvr.Position = var27_upvr
		task.delay(0.25, function() -- Line 88
			--[[ Upvalues[2]:
				[1]: BodyPosition_2_upvr (readonly)
				[2]: var27_upvr (readonly)
			]]
			BodyPosition_2_upvr.Position = var27_upvr + Vector3.new(0, 12, 0)
		end)
		local tbl_2_upvr = {}
		local var32_upvw
		var32_upvw = var3_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 95
			--[[ Upvalues[5]:
				[1]: arg1 (copied, readonly)
				[2]: clone_upvr_2 (readonly)
				[3]: var32_upvw (read and write)
				[4]: var3_upvw (copied, read and write)
				[5]: tbl_2_upvr (readonly)
			]]
			if not arg1.Parent or not clone_upvr_2.Parent then
				var32_upvw:Disconnect()
			else
				for _, var34 in var3_upvw.findEnemiesMagnitude(clone_upvr_2.Position, 50, true), nil do
					if not (var34.Torso:FindFirstChild("PierceBP") or false) and not var3_upvw.CheckBlock(var34, true) then
						var3_upvw.applyDamage(var34, 5, false, true)
						var3_upvw.applyStatus(var34, "Stunned", 2.5)
						local BodyPosition = Instance.new("BodyPosition", var34.Torso)
						BodyPosition.Name = "PierceBP"
						BodyPosition.MaxForce = Vector3.new(1000000, 1000000, 1000000)
						BodyPosition.Position = clone_upvr_2.Position
						var3_upvw.applyDebris(BodyPosition, 5)
						table.insert(tbl_2_upvr, BodyPosition)
					end
				end
			end
		end), module_upvr.Cooldown)
		var3_upvw.conTimer(var32_upvw, 1.5)
		local var37_upvw
		var37_upvw = var3_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 120
			--[[ Upvalues[4]:
				[1]: arg1 (copied, readonly)
				[2]: clone_upvr_2 (readonly)
				[3]: var37_upvw (read and write)
				[4]: tbl_2_upvr (readonly)
			]]
			if not arg1.Parent or not clone_upvr_2.Parent then
				var37_upvw:Disconnect()
			else
				for _, var39 in tbl_2_upvr do
					var39.Position = clone_upvr_2.Position
				end
			end
		end), module_upvr.Cooldown)
		var3_upvw.conTimer(var37_upvw, 5)
		task.wait(1.5)
		TweenService_upvr:Create(clone_upvr_2.pulling, TweenInfo.new(1), {
			Volume = 0;
		}):Play()
		for _, v_2 in clone_upvr_2.PullVFX:GetChildren() do
			v_2.Enabled = false
		end
		task.wait(1)
		clone_upvr_2.Anchored = true
		local clone_upvr = Pierce_upvr["Giant Sword"]:Clone()
		clone_upvr.Parent = Folder_upvr
		clone_upvr.CFrame = clone_upvr_2.CFrame + Vector3.new(0, 45, 0)
		var3_upvw.EmitAllDescendants(clone_upvr.Neon)
		for _, v_3 in clone_upvr.SpawnSounds:GetChildren() do
			v_3:Play()
		end
		var3_upvw.camShake(arg1, "SmallBump")
		clone_upvr.Move:Play()
		local any_Create_result1 = TweenService_upvr:Create(clone_upvr, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			CFrame = CFrame.new(clone_upvr_2.Position + Vector3.new(0, -10, 0)) * clone_upvr.CFrame - clone_upvr.CFrame.p;
		})
		any_Create_result1:Play()
		var3_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 151
			--[[ Upvalues[5]:
				[1]: tbl_2_upvr (readonly)
				[2]: var3_upvw (copied, read and write)
				[3]: clone_upvr (readonly)
				[4]: clone_upvr_2 (readonly)
				[5]: arg1 (copied, readonly)
			]]
			for _, v_4 in tbl_2_upvr do
				var3_upvw.applyDebris(v_4, 0)
			end
			table.clear(tbl_2_upvr)
			for _, v_5 in clone_upvr.ImpactSounds:GetChildren() do
				v_5:Play()
			end
			for _, v_6 in clone_upvr.ShatterSounds:GetChildren() do
				v_6:Play()
			end
			var3_upvw.EmitAllDescendants(clone_upvr.Shatter)
			clone_upvr.Neon.Transparency = 1
			for _, v_7 in clone_upvr_2:GetDescendants() do
				if v_7:IsA("ParticleEmitter") then
					v_7.Enabled = false
				end
			end
			var3_upvw.camShake(arg1, "Bump")
			var3_upvw.changeFov(arg1, 100, 0, 2)
			var3_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 0.02)
			for _, v_8 in var3_upvw.findEnemiesMagnitude(clone_upvr_2.Position, 50, true), nil do
				if not var3_upvw.CheckBlock(v_8, true) then
					var3_upvw.applyDamage(v_8, 25, false, true)
					var3_upvw.applyStatus(v_8, "Ragdoll", 2.25)
					var3_upvw.Knockback(v_8, clone_upvr_2.Position, 10, -20)
					var3_upvw.camShake(v_8, "Bump")
					var3_upvw.changeFov(v_8, 100, 0, 2)
					var3_upvw.flashScreen(v_8, Color3.new(1, 1, 1), 0.02)
				end
			end
		end), module_upvr.Cooldown)
	end), module_upvr.Cooldown)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("end"):Connect(function() -- Line 195
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:Stop(0.1)
	end), module_upvr.Cooldown)
end
return module_upvr