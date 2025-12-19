-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:12
-- Luau version 6, Types version 3
-- Time taken: 0.011307 seconds

local module_upvr = {
	Cooldown = 18;
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
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Tri_Slash_upvr = ReplicatedStorage_upvr.Skills["Firework Rapier"]["Tri-Slash"]
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Tri_Slash_upvr.Animation)
	any_LoadAnimation_result1_upvr:AdjustSpeed(1.1)
	any_LoadAnimation_result1_upvr:Play()
	local Firework_Rapier_upvr = arg1:FindFirstChild("Firework Rapier")
	local function ToggleTrails_upvr(arg1_2) -- Line 35, Named "ToggleTrails"
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
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 44
		--[[ Upvalues[1]:
			[1]: ToggleTrails_upvr (readonly)
		]]
		ToggleTrails_upvr(false)
	end), module_upvr.Cooldown)
	local clone_3 = Tri_Slash_upvr.Charge:Clone()
	clone_3.Parent = HumanoidRootPart_upvr
	clone_3:Play()
	var2_upvw.applyDebris(clone_3, 5)
	local tbl_upvr = {}
	table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "Slowed", 3.2))
	table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "GlobalCD", 3.2))
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("uppercut"):Connect(function() -- Line 60
		--[[ Upvalues[7]:
			[1]: tbl_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: arg1 (readonly)
			[4]: Tri_Slash_upvr (readonly)
			[5]: Folder_upvr (readonly)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: any_LoadAnimation_result1_upvr (readonly)
		]]
		table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "Freeze", 2.8))
		local clone_4 = Tri_Slash_upvr.UppercutVFX:Clone()
		clone_4.Parent = Folder_upvr
		clone_4.CFrame = HumanoidRootPart_upvr.CFrame
		var2_upvw.EmitAllDescendants(clone_4)
		local descendants_2, _, NONE_5 = clone_4:GetDescendants()
		local var34
		for _, v_2 in descendants_2, var34, NONE_5 do
			if v_2:IsA("Sound") then
				v_2:Play()
			end
		end
		var34 = var2_upvw
		var34 = arg1
		var34.camShake(var34, "Bump")
		var34 = var2_upvw
		var34 = arg1
		var34.changeFov(var34, 40, 0.15, 0.8)
		var34 = var2_upvw
		var34 = arg1
		var34.flashScreen(var34, Color3.new(1, 0.670588, 0.4), 1)
		var34 = var2_upvw
		var34 = arg1
		var34.Blur(var34, 50, 0.3)
		var34 = var2_upvw
		var34 = HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 8
		var34 = false
		for i_3, v_3_upvr in var34.findEnemiesMagnitude(var34, 8, true), nil do
			if not var2_upvw.CheckBlock(v_3_upvr, true) then
				var34 = true
				var2_upvw.applyStatus(v_3_upvr, "Ragdoll", 2)
				var2_upvw.applyStatus(v_3_upvr, "DashDB", 2)
				var2_upvw.applyDamage(v_3_upvr, 3)
				var2_upvw.Knockback(v_3_upvr, HumanoidRootPart_upvr.Position, -1, 25)
				task.delay(0.5, function() -- Line 87
					--[[ Upvalues[3]:
						[1]: v_3_upvr (readonly)
						[2]: HumanoidRootPart_upvr (copied, readonly)
						[3]: var2_upvw (copied, read and write)
					]]
					local BodyPosition = Instance.new("BodyPosition", v_3_upvr.HumanoidRootPart)
					BodyPosition.MaxForce = Vector3.new(1000000, 1000000, 1000000)
					BodyPosition.Position = Vector3.new(v_3_upvr.HumanoidRootPart.Position.X, HumanoidRootPart_upvr.Position.Y, v_3_upvr.HumanoidRootPart.Position.Z)
					var2_upvw.applyDebris(BodyPosition, 1.5)
				end)
			end
		end
		if not var34 then
			task.wait(0.1)
			i_3 = 0.5
			var2_upvw.applyStatus(arg1, "Freeze", i_3)
			i_3 = 0.75
			var2_upvw.applyStatus(arg1, "GlobalCD", i_3)
			for _, v_4 in tbl_upvr do
				var2_upvw.applyDebris(v_4, 0)
			end
			any_LoadAnimation_result1_upvr:Stop(0.75)
		end
	end), module_upvr.Cooldown)
	local var38_upvw = 0
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slash"):Connect(function() -- Line 109
		--[[ Upvalues[6]:
			[1]: var38_upvw (read and write)
			[2]: Tri_Slash_upvr (readonly)
			[3]: Folder_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: var2_upvw (copied, read and write)
			[6]: arg1 (readonly)
		]]
		var38_upvw += 1
		local clone = Tri_Slash_upvr["SlashVFX"..var38_upvw]:Clone()
		clone.Parent = Folder_upvr
		clone.CFrame = HumanoidRootPart_upvr.CFrame
		var2_upvw.EmitAllDescendants(clone)
		for _, v_5 in clone:GetDescendants() do
			if v_5:IsA("Sound") then
				v_5:Play()
			end
		end
		if var38_upvw ~= 1 then
		end
		var2_upvw.changeFov(arg1, 60 - var38_upvw * 5, 0.02, 1)
		var2_upvw.flashScreen(arg1, Color3.new(1, 0.8, 0.47451), 1.1)
		var2_upvw.Blur(arg1, 20, 0.6)
		for _, v_6 in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 8, 8, true), nil do
			if not var2_upvw.CheckBlock(v_6, true) then
				var2_upvw.applyStatus(v_6, "Ragdoll", 1)
				var2_upvw.applyDamage(v_6, 4)
				local clone_2 = Tri_Slash_upvr.ExplosionVFX:Clone()
				clone_2.Parent = Folder_upvr
				clone_2.CFrame = v_6.HumanoidRootPart.CFrame
				var2_upvw.applyDebris(clone_2, 6)
				var2_upvw.EmitAllDescendants(clone_2)
				for i_7, v_7 in clone_2:GetDescendants() do
					if v_7:IsA("Sound") then
						v_7.PlaybackSpeed += math.random(-1, 1) * 0.1
						v_7:Play()
					end
				end
				if var38_upvw == 3 then
					i_7 = HumanoidRootPart_upvr
					i_7 = 40
					var2_upvw.Knockback(v_6, i_7.Position, i_7)
				else
					i_7 = HumanoidRootPart_upvr
					i_7 = 1
					v_7 = 11
					var2_upvw.Knockback(v_6, i_7.Position, i_7, v_7)
				end
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr