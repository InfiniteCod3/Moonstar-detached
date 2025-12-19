-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:14
-- Luau version 6, Types version 3
-- Time taken: 0.021969 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 17
module_upvr.GlobalCD = 1
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Boil_upvr = ReplicatedStorage_upvr.Skills["Blood Sword"].Ultimate.Boil
	var3_upvw.applyStatus(arg1, "Slowed", 1)
	var3_upvw.applyStatus(arg1, "GlobalCD", 1)
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid"):LoadAnimation(Boil_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(0.8)
	var3_upvw.applySound(Boil_upvr["Blood Arrow"], HumanoidRootPart_upvr)
	local clone_upvr = Boil_upvr.bloodEmit.ChargeVFX:Clone()
	clone_upvr.Parent = arg1.Torso
	var3_upvw.applyDebris(clone_upvr, 1)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("launch"):Connect(function() -- Line 43
		--[[ Upvalues[7]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: clone_upvr (readonly)
			[4]: Boil_upvr (readonly)
			[5]: Folder_upvr (readonly)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
		]]
		-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.changeFov(arg1, 90, 0.05, 0.4)
		for _, v in clone_upvr:GetChildren() do
			v.Enabled = false
		end
		local clone_2 = Boil_upvr.bloodEmit.CastVFX:Clone()
		clone_2.Parent = arg1.Torso
		var3_upvw.applyDebris(clone_2, 3)
		var3_upvw.EmitAllDescendants(clone_2)
		local clone_3_upvr = Boil_upvr.BoilVFX:Clone()
		clone_3_upvr.Parent = Folder_upvr
		clone_3_upvr.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 10
		var3_upvw.applySound(Boil_upvr.Implode, clone_3_upvr)
		local var40 = clone_3_upvr.Position + clone_3_upvr.CFrame.LookVector * 125
		local workspace_Raycast_result1 = workspace:Raycast(clone_3_upvr.Position, clone_3_upvr.CFrame.LookVector * 125, var3_upvw.raycastParams)
		if workspace_Raycast_result1 then
			var40 = workspace_Raycast_result1.Position
		end
		TweenService_upvr:Create(clone_3_upvr, TweenInfo.new(1), {
			CFrame = CFrame.new(var40) * clone_3_upvr.CFrame - clone_3_upvr.CFrame.p;
		}):Play()
		local tbl_upvr_2 = {}
		local tbl_upvr = {}
		local var45_upvw = true
		task.delay(1.5, function() -- Line 75
			--[[ Upvalues[7]:
				[1]: var45_upvw (read and write)
				[2]: tbl_upvr (readonly)
				[3]: clone_3_upvr (readonly)
				[4]: Boil_upvr (copied, readonly)
				[5]: var3_upvw (copied, read and write)
				[6]: arg1 (copied, readonly)
				[7]: tbl_upvr_2 (readonly)
			]]
			var45_upvw = false
			for _, v_2 in tbl_upvr do
				v_2:Destroy()
			end
			for _, v_3 in clone_3_upvr:GetChildren() do
				if v_3:IsA("ParticleEmitter") then
					v_3.Enabled = false
				end
			end
			task.wait(0.1)
			local clone = Boil_upvr.bloodEmit.HitVFX:Clone()
			clone.Parent = clone_3_upvr
			var3_upvw.EmitAllDescendants(clone)
			var3_upvw.applyDebris(clone, 5)
			var3_upvw.applySound(Boil_upvr.Explode, clone)
			var3_upvw.applySound(Boil_upvr.Explode2, clone)
			var3_upvw.camShake(arg1, "Bump")
			var3_upvw.changeFov(arg1, 90, 0.1, 1.5)
			for _, v_4 in tbl_upvr_2 do
				var3_upvw.applyDamage(v_4, 20)
				var3_upvw.Knockback(v_4, clone_3_upvr.Position, 5, math.random(60, 100))
				var3_upvw.applyStatus(v_4, "Ragdoll", 2)
				var3_upvw.camShake(v_4, "Bump")
				var3_upvw.changeFov(v_4, 90, 0.1, 1.5)
			end
		end)
		while task.wait() and clone_3_upvr.Parent and var45_upvw do
			for _, v_5 in var3_upvw.findEnemiesPart(clone_3_upvr.Hitbox), nil do
				if not table.find(tbl_upvr_2, v_5) then
					table.insert(tbl_upvr_2, v_5)
					local BodyPosition = Instance.new("BodyPosition", v_5.Head)
					BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					BodyPosition.Position = clone_3_upvr.Position
					table.insert(tbl_upvr, BodyPosition)
					var3_upvw.camShake(arg1, "SmallBump")
					var3_upvw.changeFov(arg1, 68, 0, 1)
					var3_upvw.camShake(v_5, "SmallBump")
					var3_upvw.changeFov(v_5, 68, 0, 1)
					var3_upvw.applySound(Boil_upvr.Grab, v_5.Torso)
					var3_upvw.applyDamage(v_5, 10)
					var3_upvw.applyStatus(v_5, "Ragdoll", 1.5)
					var3_upvw.applyStatus(v_5, "DashDB", 1.5)
				end
			end
			for _, v_6 in tbl_upvr do
				v_6.Position = clone_3_upvr.Position
				local _
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr