-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:12:59
-- Luau version 6, Types version 3
-- Time taken: 0.014977 seconds

local module_upvr = {
	Cooldown = 18;
	GlobalCD = 0.5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 12
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Cleave_upvr = ReplicatedStorage_upvr.Skills["Basic Sword"].Cleave
	local Basic_Sword_upvr = arg1:FindFirstChild("Basic Sword")
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Cleave_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(1.1)
	local function _(arg1_2) -- Line 30, Named "toggleTrail"
		--[[ Upvalues[1]:
			[1]: Basic_Sword_upvr (readonly)
		]]
		for _, v in Basic_Sword_upvr.TrailAtt:GetChildren() do
			v.Enabled = arg1_2
		end
	end
	for _, v_2 in Basic_Sword_upvr.TrailAtt:GetChildren() do
		v_2.Enabled = true
	end
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 37
		--[[ Upvalues[1]:
			[1]: Basic_Sword_upvr (readonly)
		]]
		for _, v_3 in Basic_Sword_upvr.TrailAtt:GetChildren() do
			v_3.Enabled = false
		end
	end), module_upvr.Cooldown)
	local tbl_upvr = {}
	table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "GlobalCD", 2))
	table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "Slowed", 2))
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_3) -- Line 46
		--[[ Upvalues[3]:
			[1]: Cleave_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
		]]
		local clone = Cleave_upvr[arg1_3]:Clone()
		clone.Parent = HumanoidRootPart_upvr
		clone:Play()
		var2_upvw.applyDebris(clone, 4)
	end), module_upvr.Cooldown)
	local var29_upvw = false
	local var31_upvw = 0
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slash"):Connect(function() -- Line 55
		--[[ Upvalues[9]:
			[1]: var31_upvw (read and write)
			[2]: var2_upvw (copied, read and write)
			[3]: Cleave_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: var29_upvw (read and write)
			[6]: TweenService_upvr (copied, readonly)
			[7]: any_LoadAnimation_result1_upvr (readonly)
			[8]: arg1 (readonly)
			[9]: tbl_upvr (readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 41 start (CF ANALYSIS FAILED)
		var31_upvw += 1
		var2_upvw.applyVFX(Cleave_upvr.VFX["slashVFX"..var31_upvw], HumanoidRootPart_upvr)
		local any_findEnemiesMagnitude_result1 = var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5, 6.4)
		for _, v_4 in any_findEnemiesMagnitude_result1 do
			if not var2_upvw.CheckBlock(v_4, true) then
				if var31_upvw == 1 then
					var29_upvw = true
					var2_upvw.applyDamage(v_4, 5)
					var2_upvw.applyStatus(v_4, "Stunned", 2)
					var2_upvw.applyStatus(v_4, "AutoRotate", 2)
					local BodyVelocity = Instance.new("BodyVelocity", v_4.Torso)
					BodyVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
					BodyVelocity.Velocity = Vector3.new(0, 0, 0)
					var2_upvw.applyDebris(BodyVelocity, 2)
					v_4.HumanoidRootPart.CFrame = CFrame.lookAt(v_4.HumanoidRootPart.Position, Vector3.new(HumanoidRootPart_upvr.Position.X, v_4.HumanoidRootPart.Position.Y, HumanoidRootPart_upvr.Position.Z))
					TweenService_upvr:Create(v_4.HumanoidRootPart, TweenInfo.new(0.5), {
						CFrame = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 5 + Vector3.new(0, 1.5, 0)) * CFrame.Angles(0, (-math.pi), 0);
					}):Play()
					local any_LoadAnimation_result1 = v_4.Humanoid.Animator:LoadAnimation(Cleave_upvr.TargetAnimation)
					any_LoadAnimation_result1:Play()
					any_LoadAnimation_result1:AdjustSpeed(0.7)
					var2_upvw.applySound(Cleave_upvr.hitSFX, v_4.Torso)
				elseif var31_upvw == 2 then
					for _, v_6 in v_4:GetDescendants() do
						if v_6:IsA("BodyVelocity") then
							v_6:Destroy()
						end
					end
					var2_upvw.applySound(Cleave_upvr.hitSFX2, v_4.Torso)
					var2_upvw.applyDamage(v_4, 10)
					var2_upvw.applyStatus(v_4, "Ragdoll", 2)
					var2_upvw.Knockback(v_4, HumanoidRootPart_upvr.Position, 40, 0)
					any_LoadAnimation_result1_upvr:AdjustSpeed(0.65)
				end
			end
		end
		-- KONSTANTERROR: [0] 1. Error Block 41 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [252] 189. Error Block 15 start (CF ANALYSIS FAILED)
		table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "GlobalCD", 2))
		table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "Freeze", 2))
		var2_upvw.changeFov(arg1, 125, 0.6, 5)
		do
			return
		end
		-- KONSTANTERROR: [252] 189. Error Block 15 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [285] 217. Error Block 35 start (CF ANALYSIS FAILED)
		if var31_upvw == 2 then
			var2_upvw.changeFov(arg1, 66, 0.05, 1)
			var2_upvw.camShake(arg1, "Bump")
			if #any_findEnemiesMagnitude_result1 <= 0 then
				var2_upvw.applyStatus(arg1, "Stunned", 1)
				var2_upvw.applyStatus(arg1, "AutoRotate", 1)
			end
			if var29_upvw then
				for _, v_5 in tbl_upvr do
					var2_upvw.applyDebris(v_5, 0.25)
				end
			end
		end
		-- KONSTANTERROR: [285] 217. Error Block 35 end (CF ANALYSIS FAILED)
	end), module_upvr.Cooldown)
	local var46_upvw = 0
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("end"):Connect(function() -- Line 128
		--[[ Upvalues[3]:
			[1]: var46_upvw (read and write)
			[2]: var29_upvw (read and write)
			[3]: any_LoadAnimation_result1_upvr (readonly)
		]]
		var46_upvw += 1
		if var46_upvw == 1 then
			if var29_upvw then
			else
				any_LoadAnimation_result1_upvr:Stop(0.4)
			end
		end
		any_LoadAnimation_result1_upvr:Stop(0.6)
	end), module_upvr.Cooldown)
end
return module_upvr