-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:01
-- Luau version 6, Types version 3
-- Time taken: 0.033942 seconds

local module_upvr = {
	Cooldown = 16;
	GlobalCD = 1.5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local RunService_upvr = game:GetService("RunService")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 14
	--[[ Upvalues[5]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: RunService_upvr (readonly)
		[5]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local Decaying_Soul_upvr = ReplicatedStorage_upvr.Skills["Soul Lantern"]["Decaying Soul"]
	local Soul_Lantern = arg1:FindFirstChild("Soul Lantern")
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Decaying_Soul_upvr.Animation)
	any_LoadAnimation_result1_upvr:AdjustSpeed(1.85)
	task.wait()
	any_LoadAnimation_result1_upvr:Play()
	var2_upvw.applyStatus(arg1, "Freeze", 1.5)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("freeze"):Connect(function() -- Line 35
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:AdjustSpeed(0)
	end), module_upvr.Cooldown)
	task.wait(0.1)
	local tbl_4_upvr = {}
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 42
		--[[ Upvalues[1]:
			[1]: tbl_4_upvr (readonly)
		]]
		delay(1, function() -- Line 43
			--[[ Upvalues[1]:
				[1]: tbl_4_upvr (copied, readonly)
			]]
			for _, v in tbl_4_upvr do
				game.Debris:AddItem(v, 3)
			end
		end)
	end), module_upvr.Cooldown)
	for _ = 1, 3 do
		local clone_7_upvr = Decaying_Soul_upvr.Soul:Clone()
		table.insert(tbl_4_upvr, clone_7_upvr)
		clone_7_upvr.Parent = Folder_upvr
		clone_7_upvr.Position = Soul_Lantern.Vfx.Position + Vector3.new(math.random(-1, 1) * 0.2, math.random(-1, 1) * 0.2, math.random(-1, 1) * 0.2)
		clone_7_upvr.Presence:Play()
		clone_7_upvr.Anchored = false
		clone_7_upvr:SetNetworkOwner(arg2)
		local BodyPosition_upvr = Instance.new("BodyPosition", clone_7_upvr)
		BodyPosition_upvr.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		BodyPosition_upvr.Position = arg1["Right Arm"].Position + arg1["Right Arm"].CFrame.LookVector * 1 + arg1["Right Arm"].CFrame.UpVector * -1.5
		BodyPosition_upvr.P += 20000
		local var21_upvw
		var21_upvw = var2_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 66
			--[[ Upvalues[3]:
				[1]: arg1 (readonly)
				[2]: BodyPosition_upvr (readonly)
				[3]: var21_upvw (read and write)
			]]
			if not arg1.Parent or not arg1:FindFirstChild("Right Arm") or not BodyPosition_upvr.Parent then
				var21_upvw:Disconnect()
			else
				BodyPosition_upvr.Position = arg1["Right Arm"].Position + arg1["Right Arm"].CFrame.LookVector * 1 + arg1["Right Arm"].CFrame.UpVector * -1.5 + Vector3.new(math.random(-1, 1) * 1, math.random(-1, 1) * 1, math.random(-1, 1) * 1)
			end
		end), module_upvr.Cooldown)
		task.delay(0.4, function() -- Line 72
			--[[ Upvalues[3]:
				[1]: clone_7_upvr (readonly)
				[2]: BodyPosition_upvr (readonly)
				[3]: Decaying_Soul_upvr (readonly)
			]]
			for _, v_2 in clone_7_upvr:GetChildren() do
				if v_2:IsA("Trail") then
					v_2.Enabled = false
				end
				if v_2 ~= BodyPosition_upvr then
					if v_2:GetAttribute("debris") then
						game.Debris:AddItem(v_2, v_2:GetAttribute("debris"))
					else
						v_2:Destroy()
					end
				end
			end
			for _, v_3 in Decaying_Soul_upvr.DecayedSoul:GetChildren() do
				local clone_5_upvr = v_3:Clone()
				clone_5_upvr.Parent = clone_7_upvr
				if clone_5_upvr.Name == "Explode" then
					clone_5_upvr:Emit(10)
				elseif clone_5_upvr.Name == "Presence" or clone_5_upvr.Name == "Ping" then
					clone_5_upvr:Play()
				elseif clone_5_upvr:IsA("Trail") then
					task.delay(0.1, function() -- Line 93
						--[[ Upvalues[2]:
							[1]: clone_5_upvr (readonly)
							[2]: clone_7_upvr (copied, readonly)
						]]
						clone_5_upvr.Attachment0 = clone_7_upvr.att0
						clone_5_upvr.Attachment1 = clone_7_upvr.att1
					end)
				end
			end
			clone_7_upvr.Color = Decaying_Soul_upvr.DecayedSoul.Color
		end)
		task.wait(0.05)
	end
	task.wait(0.25)
	clone_7_upvr = 1.2
	var2_upvw.applyStatus(arg1, "Freeze", clone_7_upvr)
	clone_7_upvr = 1.2
	var2_upvw.applyStatus(arg1, "GlobalCD", clone_7_upvr)
	task.wait(0.1)
	any_LoadAnimation_result1_upvr:AdjustSpeed(1)
	clone_7_upvr = 1.1
	var2_upvw.applyStatus(arg1, "AutoRotate", clone_7_upvr)
	local clone = Decaying_Soul_upvr.ArmWhoosh:Clone()
	clone.Parent = arg1["Right Arm"]
	clone:Play()
	clone_7_upvr = clone
	BodyPosition_upvr = 2
	game.Debris:AddItem(clone_7_upvr, BodyPosition_upvr)
	function clone_7_upvr() -- Line 119
		--[[ Upvalues[2]:
			[1]: Decaying_Soul_upvr (readonly)
			[2]: arg1 (readonly)
		]]
		local clone_6 = Decaying_Soul_upvr.ArmWhoosh:Clone()
		clone_6.PlaybackSpeed = 1
		clone_6.Parent = arg1["Right Arm"]
		clone_6:Play()
		game.Debris:AddItem(clone_6, 2)
	end
	task.delay(0.3, clone_7_upvr)
	BodyPosition_upvr = "snap"
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	function BodyPosition_upvr() -- Line 127
		--[[ Upvalues[8]:
			[1]: tbl_4_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: arg1 (readonly)
			[4]: Decaying_Soul_upvr (readonly)
			[5]: Folder_upvr (readonly)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: module_upvr (copied, readonly)
		]]
		for _, v_4 in tbl_4_upvr do
			for _, v_5 in v_4:GetChildren() do
				if v_5:IsA("Trail") then
					v_5.Enabled = false
				elseif v_5.Name == "Presence" then
					v_5:Destroy()
				end
			end
			v_4.SoulBreak:Play()
			v_4.Explode:Emit(20)
			v_4.Transparency = 1
			v_4.p1.Enabled = false
			v_4.p2.Enabled = false
		end
		var2_upvw.camShake(arg1, "BigBump")
		var2_upvw.changeFov(arg1, 70, 0.05, 0.5)
		var2_upvw.flashScreen(arg1, Color3.new(1, 0.0627451, 0.0627451), 0.5)
		local clone_8_upvr = Decaying_Soul_upvr.RedSlash:Clone()
		clone_8_upvr.Parent = Folder_upvr
		clone_8_upvr.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 5 - Vector3.new(0, 3, 0)
		clone_8_upvr.Cast:Play()
		clone_8_upvr.Rocks:Play()
		clone_8_upvr.Beam:Play()
		var2_upvw.applySound(Decaying_Soul_upvr.Beam, HumanoidRootPart_upvr, 5)
		local workspace_Raycast_result1 = workspace:Raycast(clone_8_upvr.Position, Vector3.new(0, -20, 0), var2_upvw.raycastParams)
		if workspace_Raycast_result1 then
			clone_8_upvr.CFrame = CFrame.new(workspace_Raycast_result1.Position) * clone_8_upvr.CFrame - clone_8_upvr.CFrame.p
		end
		for _, v_6 in clone_8_upvr:GetChildren() do
			if v_6:IsA("ParticleEmitter") then
				v_6.Enabled = true
			end
		end
		local any_Create_result1_2 = TweenService_upvr:Create(clone_8_upvr, TweenInfo.new(1.4, Enum.EasingStyle.Linear), {
			CFrame = clone_8_upvr.CFrame + clone_8_upvr.CFrame.LookVector * 150;
		})
		any_Create_result1_2:Play()
		var2_upvw.conTimer(any_Create_result1_2.Completed:Connect(function() -- Line 172
			--[[ Upvalues[1]:
				[1]: clone_8_upvr (readonly)
			]]
			for _, v_7 in clone_8_upvr:GetChildren() do
				if v_7:IsA("ParticleEmitter") then
					v_7.Enabled = false
				end
			end
		end), module_upvr.Cooldown)
		local tbl_3 = {}
		for _ = 1, 63.333333333333336 do
			var2_upvw.CreateDebris(clone_8_upvr.Position + Vector3.new(0, 1, 0), 2, 1.2, 1.5, 0.08)
			for _, v_8 in var2_upvw.findEnemiesMagnitude(clone_8_upvr.Position, 15, true), nil do
				if not table.find(tbl_3, v_8) then
					table.insert(tbl_3, v_8)
					if not var2_upvw.CheckBlock(v_8) then
						var2_upvw.applyDamage(v_8, 20)
						var2_upvw.Knockback(v_8, clone_8_upvr.Position, 10, 75)
						var2_upvw.applyStatus(v_8, "Ragdoll", 2.5)
						if v_8.Humanoid.Health <= 1 and not v_8:FindFirstChild("burnVfx") and not v_8:GetAttribute("DeathEffect") then
							v_8:SetAttribute("DeathEffect", true)
							v_8.Humanoid.HealthDisplayType = "AlwaysOff"
							for _, v_9 in v_8:GetDescendants() do
								if v_9:IsA("Shirt") or v_9:IsA("Pants") then
									v_9:Destroy()
								else
									local function INLINED_2() -- Internal function, doesn't exist in bytecode
										TweenService_upvr:Create(v_9, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), tbl_5):Play()
										tbl_5.Transparency = 1
										local tbl_5 = {}
										v_9.Color = Color3.new(1, 0.207843, 0.207843)
										v_9.Material = "Neon"
										return v_9.Name == "Torso"
									end
									if v_9:IsA("BasePart") and (INLINED_2() or v_9.Name == "Left Arm" or v_9.Name == "Right Arm" or v_9.Name == "Head" or v_9.Name == "Left Leg" or v_9.Name == "Right Leg") then
										local clone_4_upvr = Decaying_Soul_upvr.burnVfx:Clone()
										clone_4_upvr.Parent = v_9
										clone_4_upvr.Enabled = true
										task.delay(2, function() -- Line 211
											--[[ Upvalues[1]:
												[1]: clone_4_upvr (readonly)
											]]
											clone_4_upvr.Enabled = false
										end)
									end
								end
							end
						end
					end
				end
			end
			wait()
		end
	end
	BodyPosition_upvr = module_upvr
	clone_7_upvr = BodyPosition_upvr.Cooldown
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal(BodyPosition_upvr):Connect(BodyPosition_upvr), clone_7_upvr)
end
return module_upvr