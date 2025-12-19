-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:19
-- Luau version 6, Types version 3
-- Time taken: 0.031746 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 18
module_upvr.GlobalCD = 0.9
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 18
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local Dagger_Trifecta_upvr = ReplicatedStorage_upvr.Skills.Dagger["Dagger Trifecta"]
	for _, v in Dagger_Trifecta_upvr.daggers:GetChildren() do
		local clone_3 = v:Clone()
		clone_3.Parent = arg1
		table.insert({}, clone_3)
		clone_3.weld.Part0 = arg1["Left Arm"]
		clone_3.weld.Part1 = clone_3
		game.Debris:AddItem(clone_3, 3)
		for _, v_2 in clone_3.DaggerParts:GetChildren() do
			if v_2:IsA("BasePart") then
				TweenService_upvr:Create(v_2, TweenInfo.new(0), {
					Size = Vector3.new(0, 0, 0);
				}):Play()
				TweenService_upvr:Create(v_2, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Size = v_2.Size;
				}):Play()
			end
		end
	end
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Dagger_Trifecta_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(1.2)
	var3_upvw.applyStatus(arg1, "Slowed", 1)
	local clone_5_upvr = Dagger_Trifecta_upvr.Part.sounds:Clone()
	clone_5_upvr.Parent = arg1.Torso
	game.Debris:AddItem(clone_5_upvr, 10)
	clone_5_upvr.ArmWhoosh:Play()
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 61
		--[[ Upvalues[2]:
			[1]: clone_5_upvr (readonly)
			[2]: arg1 (readonly)
		]]
		local clone_4 = clone_5_upvr:FindFirstChild(arg1_2):Clone()
		clone_4.Parent = arg1.Torso
		clone_4:Play()
		game.Debris:AddItem(clone_4, 5)
	end), module_upvr.Cooldown)
	local var29_upvw = false
	if 1 < require(arg1.ServerScript.Combat).punchNum then
		var29_upvw = true
	end
	local var31_upvw = 0
	local tbl_3_upvr = {}
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local tbl_upvr = {}
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("throw"):Connect(function() -- Line 75
		--[[ Upvalues[12]:
			[1]: var31_upvw (read and write)
			[2]: tbl_3_upvr (readonly)
			[3]: TweenService_upvr (copied, readonly)
			[4]: Dagger_Trifecta_upvr (readonly)
			[5]: Folder_upvr (readonly)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: var3_upvw (copied, read and write)
			[8]: arg1 (readonly)
			[9]: var29_upvw (read and write)
			[10]: tbl_upvr (readonly)
			[11]: PlayerStatus_upvr (copied, readonly)
			[12]: clone_5_upvr (readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 36 start (CF ANALYSIS FAILED)
		var31_upvw += 1
		local var71_upvr
		for _, v_3 in tbl_3_upvr do
			local children, NONE_6_upvr, NONE_4 = v_3.DaggerParts:GetChildren()
			for i_4, v_4_upvr in children, NONE_6_upvr, NONE_4 do
				if v_4_upvr:IsA("BasePart") then
					var71_upvr = v_4_upvr
					TweenService_upvr:Create(var71_upvr, TweenInfo.new(0), {
						Size = Vector3.new(0, 0, 0);
					}):Play()
					if var31_upvw == 1 then
						local Size_upvr_2 = v_4_upvr.Size
						function var71_upvr() -- Line 84
							--[[ Upvalues[3]:
								[1]: TweenService_upvr (copied, readonly)
								[2]: v_4_upvr (readonly)
								[3]: Size_upvr_2 (readonly)
							]]
							TweenService_upvr:Create(v_4_upvr, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
								Size = Size_upvr_2;
							}):Play()
						end
						task.delay(0.15, var71_upvr)
					end
				end
			end
		end
		local clone_6 = Dagger_Trifecta_upvr:FindFirstChild("DaggerSpawn"..var31_upvw):Clone()
		clone_6.Parent = Folder_upvr
		clone_6.CFrame = HumanoidRootPart_upvr.CFrame
		local var75_upvr = 0.45
		var3_upvw.changeFov(arg1, 97, 0.01, var75_upvr)
		local const_number = 0.5
		var3_upvw.Blur(arg1, 15, const_number)
		local var77_upvr = 1
		-- KONSTANTERROR: [0] 1. Error Block 36 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [260] 192. Error Block 28 start (CF ANALYSIS FAILED)
		task.delay((var71_upvr.HumanoidRootPart.Position - const_number.Position).Magnitude * 0.007, function() -- Line 147
			--[[ Upvalues[12]:
				[1]: var3_upvw (copied, read and write)
				[2]: var71_upvr (readonly)
				[3]: tbl_upvr (copied, readonly)
				[4]: PlayerStatus_upvr (copied, readonly)
				[5]: var75_upvr (readonly)
				[6]: HumanoidRootPart_upvr (copied, readonly)
				[7]: clone_5_upvr (copied, readonly)
				[8]: var31_upvw (copied, read and write)
				[9]: Dagger_Trifecta_upvr (copied, readonly)
				[10]: arg1 (copied, readonly)
				[11]: NONE_6_upvr (readonly)
				[12]: var77_upvr (readonly)
			]]
			if var3_upvw.CheckBlock(var71_upvr) then
			else
				var3_upvw.applyStatus(var71_upvr, "Stunned", 0.9)
				if not table.find(tbl_upvr, var71_upvr) and not PlayerStatus_upvr.FindStatus(var71_upvr, "HyperArmor") then
					table.insert(tbl_upvr, var71_upvr)
					var75_upvr.Heartbeat:Play()
					var3_upvw.applyStatus(var71_upvr, "Slowed", 1)
					var3_upvw.flashScreen(var71_upvr, Color3.new(0.384314, 0, 0), 3)
					var3_upvw.Blur(var71_upvr, 30, 3)
				end
				var3_upvw.blood(var71_upvr, 2)
				var3_upvw.applyDamage(var71_upvr, 2)
				var71_upvr.HumanoidRootPart.CFrame = CFrame.lookAt(var71_upvr.HumanoidRootPart.Position, Vector3.new(HumanoidRootPart_upvr.Position.X, var71_upvr.HumanoidRootPart.Position.Y, HumanoidRootPart_upvr.Position.Z))
				local clone_2 = clone_5_upvr.hit:Clone()
				clone_2.Parent = var71_upvr.Torso
				clone_2.PlaybackSpeed += math.random(-1, 1) * 0.05
				clone_2:Play()
				game.Debris:AddItem(clone_2, 4)
				local var80
				if not var71_upvr.Torso:FindFirstChild("EnemyDaggers"..var31_upvw) then
					var80 = Dagger_Trifecta_upvr:FindFirstChild("EnemyDaggers"..var31_upvw):Clone()
					var80.Parent = var71_upvr.Torso
					var80.Motor6D.Part1 = var80
					var80.Motor6D.Part0 = var71_upvr.Torso
					game.Debris:AddItem(var80, 8)
				else
					var80 = var71_upvr.Torso:FindFirstChild("EnemyDaggers"..var31_upvw)
				end
				var3_upvw.changeFov(arg1, 72, 0.01, 0.15)
				NONE_6_upvr:Cancel()
				var75_upvr.TrailAtt.Trail.Enabled = false
				var75_upvr.Anchored = false
				var75_upvr.weld.Part0 = var80[var77_upvr]
				var75_upvr.weld.Part1 = var75_upvr
				var3_upvw.EmitAllDescendants(var75_upvr.HitVfx)
			end
		end)
		-- KONSTANTERROR: [260] 192. Error Block 28 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [88] 70. Error Block 41 start (CF ANALYSIS FAILED)
		if i_4 then
			-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [289.65666]
			if v_4_upvr <= Size_upvr_2 then
			end
		end
		-- KONSTANTERROR: Expression was reused, decompilation is incorrect
		if v_4_upvr <= Size_upvr_2 and not i_4 then
		elseif v_4_upvr then
		else
		end
		-- KONSTANTERROR: [88] 70. Error Block 41 end (CF ANALYSIS FAILED)
	end), module_upvr.Cooldown)
end
return module_upvr