-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:15
-- Luau version 6, Types version 3
-- Time taken: 0.060315 seconds

local module_upvr = {
	Cooldown = 38;
	GlobalCD = 0.5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
function module_upvr.Script(arg1, arg2) -- Line 14
	--[[ Upvalues[5]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: RunService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Event_Horizon_upvr = ReplicatedStorage_upvr.Skills.Nebula["Event Horizon"]
	local any_LoadAnimation_result1_2_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Event_Horizon_upvr.Animation)
	any_LoadAnimation_result1_2_upvr:Play()
	any_LoadAnimation_result1_2_upvr:AdjustSpeed(1.1)
	local tbl_upvr_3 = {}
	table.insert(tbl_upvr_3, var2_upvw.applyStatus(arg1, "GlobalCD", 3))
	table.insert(tbl_upvr_3, var2_upvw.applyStatus(arg1, "Slowed", 3))
	table.insert(tbl_upvr_3, var2_upvw.applyStatus(arg1, "HyperArmor", 0.7))
	var2_upvw.conTimer(any_LoadAnimation_result1_2_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 38
		--[[ Upvalues[3]:
			[1]: Event_Horizon_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: HumanoidRootPart_upvr (readonly)
		]]
		for _, v in Event_Horizon_upvr:GetChildren() do
			if v:IsA("Sound") and v.Name == arg1_2 then
				var2_upvw.applySound(v, HumanoidRootPart_upvr)
			end
		end
	end), module_upvr.Cooldown)
	var2_upvw.camShake(arg1, "SmallBump")
	for _, v_2 in arg1.Head:GetChildren() do
		if v_2:IsA("BodyVelocity") then
			v_2:Destroy()
		end
	end
	local BodyVelocity_upvr = Instance.new("BodyVelocity", arg1.Head)
	BodyVelocity_upvr.MaxForce = Vector3.new(0, 9999900, 0)
	BodyVelocity_upvr.Velocity = Vector3.new(0, 15, 0)
	TweenService_upvr:Create(BodyVelocity_upvr, TweenInfo.new(2), {
		Velocity = Vector3.new(0, 0, 0);
	}):Play()
	var2_upvw.applyDebris(BodyVelocity_upvr, 5)
	table.insert(tbl_upvr_3, BodyVelocity_upvr)
	local tbl_upvr_4 = {}
	local tbl_upvr = {}
	local var27_upvw
	var27_upvw = var2_upvw.conTimer(arg2.CharacterRemoving:Connect(function() -- Line 63
		--[[ Upvalues[4]:
			[1]: var27_upvw (read and write)
			[2]: tbl_upvr_4 (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: tbl_upvr (readonly)
		]]
		var27_upvw:Disconnect()
		for _, v_3 in tbl_upvr_4 do
			var2_upvw.applyDebris(v_3, 0)
		end
		for _, v_4 in tbl_upvr do
			v_4:Stop()
		end
	end), module_upvr.Cooldown)
	local var32_upvw = false
	local var33_upvw = false
	local var34_upvw
	var2_upvw.conTimer(any_LoadAnimation_result1_2_upvr.Stopped:Connect(function() -- Line 77
		--[[ Upvalues[5]:
			[1]: var32_upvw (read and write)
			[2]: tbl_upvr_3 (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: tbl_upvr_4 (readonly)
			[5]: var34_upvw (read and write)
		]]
		if var32_upvw then
		else
			for _, v_12 in tbl_upvr_3 do
				var2_upvw.applyDebris(v_12, 0)
			end
			table.clear(tbl_upvr_3)
			for _, v_13 in tbl_upvr_4 do
				var2_upvw.applyDebris(v_13, 0)
			end
			table.clear(tbl_upvr_4)
			var2_upvw.applyDebris(var34_upvw, 0)
		end
	end), module_upvr.Cooldown)
	var2_upvw.applySound(Event_Horizon_upvr.StartUp, HumanoidRootPart_upvr)
	local tbl_upvr_5 = {}
	local tbl_upvr_2 = {}
	local any_applySound_result1_upvr = var2_upvw.applySound(Event_Horizon_upvr.HoleCreation, HumanoidRootPart_upvr)
	var2_upvw.conTimer(any_LoadAnimation_result1_2_upvr:GetMarkerReachedSignal("Lift"):Connect(function() -- Line 97
		--[[ Upvalues[17]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Event_Horizon_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: TweenService_upvr (copied, readonly)
			[6]: Folder_upvr (readonly)
			[7]: var34_upvw (read and write)
			[8]: var33_upvw (read and write)
			[9]: tbl_upvr_5 (readonly)
			[10]: tbl_upvr_2 (readonly)
			[11]: tbl_upvr (readonly)
			[12]: tbl_upvr_4 (readonly)
			[13]: RunService_upvr (copied, readonly)
			[14]: module_upvr (copied, readonly)
			[15]: any_LoadAnimation_result1_2_upvr (readonly)
			[16]: tbl_upvr_3 (readonly)
			[17]: any_applySound_result1_upvr (readonly)
		]]
		var2_upvw.camShake(arg1, "SmallBump")
		var2_upvw.Blur(arg1, 15, 1)
		local clone_2 = Event_Horizon_upvr.LiftRing:Clone()
		clone_2.Parent = arg1
		clone_2.weld.Part0 = HumanoidRootPart_upvr
		clone_2.weld.Part1 = clone_2
		TweenService_upvr:Create(clone_2.weld, TweenInfo.new(0.25), {
			C0 = clone_2.TargetWeld.C0;
		}):Play()
		TweenService_upvr:Create(clone_2, TweenInfo.new(0.25), {
			Transparency = 1;
		}):Play()
		var2_upvw.applyDebris(clone_2, 2)
		local var59 = HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 20 + Vector3.new(0, -3, 0)
		local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 20, Vector3.new(0, -50, 0), var2_upvw.raycastParams)
		local var61
		if workspace_Raycast_result1 then
			var59 = workspace_Raycast_result1.Position
		end
		var61 = Event_Horizon_upvr
		local clone = var61.LiftRing2:Clone()
		var61 = Folder_upvr
		clone.Parent = var61
		var61 = CFrame.new(var59) * clone.CFrame - clone.CFrame.p
		clone.CFrame = var61
		var61 = TweenService_upvr
		local _ = {
			Size = Vector3.new(40, 1, 40);
			Transparency = 1;
		}
		var61 = var61:Create(clone, TweenInfo.new(0.5), _):Play
		var61()
		var61 = var2_upvw.applyDebris
		var61(clone, 2)
		var61 = Event_Horizon_upvr["Black Hole"]:Clone()
		var34_upvw = var61
		var61 = var34_upvw
		var61.Parent = Folder_upvr
		var61 = var34_upvw
		var61.CFrame = HumanoidRootPart_upvr.CFrame
		var61 = var34_upvw
		var61.CFrame = CFrame.new(var59) * var34_upvw.CFrame - var34_upvw.CFrame.p
		var61 = TweenService_upvr
		local _ = {
			CFrame = var34_upvw.CFrame + Vector3.new(0, 16, 0);
		}
		var61 = var61:Create(var34_upvw, TweenInfo.new(1), _):Play
		var61()
		var61 = var2_upvw.applyDebris
		var61(var34_upvw, 12)
		var61 = false
		for _, v_5_upvr in var2_upvw.findEnemiesMagnitude(var59, 20, true), nil do
			if not var2_upvw.CheckBlock(v_5_upvr) then
				var61 = true
				var33_upvw = true
				table.insert(tbl_upvr_5, v_5_upvr)
				var2_upvw.unragdoll(v_5_upvr)
				var2_upvw.applyDamage(v_5_upvr, 2, false, true)
				var2_upvw.applyStatus(v_5_upvr, "Stunned", 5)
				var2_upvw.applyStatus(v_5_upvr, "AutoRotate", 5)
				tbl_upvr_2[v_5_upvr.Name] = var2_upvw.applyStatus(v_5_upvr, "IFrames", 7)
				local any_LoadAnimation_result1 = v_5_upvr.Humanoid.Animator:LoadAnimation(Event_Horizon_upvr.FloatAnimation)
				any_LoadAnimation_result1:Play()
				table.insert(tbl_upvr, any_LoadAnimation_result1)
				local BodyVelocity = Instance.new("BodyVelocity", v_5_upvr.Head)
				BodyVelocity.MaxForce = Vector3.new(99999, 99999, 99999)
				BodyVelocity.Velocity = Vector3.new(0, 0, 0)
				var2_upvw.applyDebris(BodyVelocity, 7)
				table.insert(tbl_upvr_4, BodyVelocity)
				local var68_upvw
				var68_upvw = var2_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 159
					--[[ Upvalues[5]:
						[1]: v_5_upvr (readonly)
						[2]: var33_upvw (copied, read and write)
						[3]: var68_upvw (read and write)
						[4]: TweenService_upvr (copied, readonly)
						[5]: var34_upvw (copied, read and write)
					]]
					if not v_5_upvr.Parent or not var33_upvw then
						var68_upvw:Disconnect()
					else
						TweenService_upvr:Create(v_5_upvr.HumanoidRootPart, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
							CFrame = var34_upvw.CFrame;
						}):Play()
					end
				end), module_upvr.Cooldown)
			end
		end
		task.wait()
		if not var61 then
			any_LoadAnimation_result1_2_upvr:Stop(0.4)
			for _, v_6 in var34_upvw["Event Horizon"]:GetDescendants() do
				if v_6:IsA("ParticleEmitter") then
					v_6.Enabled = false
				end
			end
			for _, v_7 in tbl_upvr_3 do
				var2_upvw.applyDebris(v_7, 0)
			end
			var2_upvw.applyStatus(arg1, "Stunned", 1)
			var2_upvw.applyStatus(arg1, "AutoRotate", 1)
			;({}).Volume = 0
			-- KONSTANTERROR: Expression was reused, decompilation is incorrect
			TweenService_upvr:Create(any_applySound_result1_upvr, TweenInfo.new(3), {}):Play()
		else
			table.insert(tbl_upvr_3, var2_upvw.applyStatus(arg1, "IFrames", 3))
			var2_upvw.applySound(Event_Horizon_upvr.AirWhoosh2, HumanoidRootPart_upvr)
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1_2_upvr:GetMarkerReachedSignal("Expand"):Connect(function() -- Line 194
		--[[ Upvalues[13]:
			[1]: var2_upvw (copied, read and write)
			[2]: Event_Horizon_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var34_upvw (read and write)
			[5]: arg1 (readonly)
			[6]: BodyVelocity_upvr (readonly)
			[7]: tbl_upvr_3 (readonly)
			[8]: tbl_upvr_5 (readonly)
			[9]: var33_upvw (read and write)
			[10]: TweenService_upvr (copied, readonly)
			[11]: tbl_upvr_4 (readonly)
			[12]: tbl_upvr_2 (readonly)
			[13]: var27_upvw (read and write)
		]]
		-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
		var2_upvw.applySound(Event_Horizon_upvr.AirWhoosh1, HumanoidRootPart_upvr)
		var2_upvw.applySound(Event_Horizon_upvr.Expand, var34_upvw)
		var2_upvw.applySound(Event_Horizon_upvr.Expand2, var34_upvw)
		var2_upvw.changeFov(arg1, 100, 0.8, 3)
		var2_upvw.camShake(arg1, "SmallBump")
		var2_upvw.Blur(arg1, 15, 1)
		BodyVelocity_upvr.Velocity = Vector3.new(0, -4, 0)
		table.insert(tbl_upvr_3, var2_upvw.applyStatus(arg1, "GlobalCD", 3))
		table.insert(tbl_upvr_3, var2_upvw.applyStatus(arg1, "Slowed", 3))
		for _, v_8 in var34_upvw["Event Horizon"].Blackhole:GetChildren() do
			v_8.Enabled = false
		end
		var2_upvw.EmitAllDescendants(var34_upvw["Event Horizon"].Expand)
		for _, v_9 in var34_upvw["Event Horizon"].Galaxy:GetChildren() do
			if v_9:IsA("ParticleEmitter") then
				v_9.Enabled = true
			end
		end
		for _, v_10 in var34_upvw["Event Horizon"].Galaxy:GetDescendants() do
			if v_10:IsA("ParticleEmitter") then
				v_10.Enabled = true
			end
		end
		task.wait(1)
		if not var34_upvw then
		else
			for _, v_14_upvr in var34_upvw["Event Horizon"].Galaxy.StarsAtt:GetChildren() do
				if v_14_upvr.Name == "Star" and v_14_upvr:IsA("Attachment") then
					if not var34_upvw then return end
					var2_upvw.EmitAllDescendants(v_14_upvr.Charge)
					var2_upvw.applySound(Event_Horizon_upvr.SunCharge, var34_upvw)
					task.delay(0.5, function() -- Line 231
						--[[ Upvalues[6]:
							[1]: var34_upvw (copied, read and write)
							[2]: var2_upvw (copied, read and write)
							[3]: arg1 (copied, readonly)
							[4]: Event_Horizon_upvr (copied, readonly)
							[5]: v_14_upvr (readonly)
							[6]: tbl_upvr_5 (copied, readonly)
						]]
						-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
						if not var34_upvw then
						else
							var2_upvw.changeFov(arg1, 65, 0, 0.5)
							var2_upvw.camShake(arg1, "Bump")
							var2_upvw.Blur(arg1, 15, 0.5)
							var2_upvw.applySound(Event_Horizon_upvr.StarBlast, var34_upvw)
							var2_upvw.EmitAllDescendants(v_14_upvr.Explosion)
							for _, v_23 in v_14_upvr:GetChildren() do
								if v_23:IsA("ParticleEmitter") then
									v_23:Destroy()
								end
							end
							local function HitTarget(arg1_3) -- Line 246
								--[[ Upvalues[1]:
									[1]: var2_upvw (copied, read and write)
								]]
								if not var2_upvw.CheckBlock(arg1_3, true) then
									var2_upvw.applyDamage(arg1_3, 3, true, true)
									var2_upvw.applyStatus(arg1_3, "Stunned", 0.5)
									var2_upvw.applyStatus(arg1_3, "AutoRotate", 0.5)
								end
							end
							for _, v_24 in tbl_upvr_5 do
								HitTarget(v_24)
								local var210
							end
							for _, v_25 in var2_upvw.findEnemiesMagnitude(var34_upvw.Position, 20, true), nil do
								var210(v_25)
								local _
							end
						end
					end)
					task.wait(0.1)
				end
			end
			task.wait(0.65)
			if not var34_upvw then return end
			var2_upvw.applySound(Event_Horizon_upvr.SingularityCharge, var34_upvw)
			var2_upvw.applySound(Event_Horizon_upvr.SingularityCharge2, var34_upvw)
			var2_upvw.EmitAllDescendants(var34_upvw["Event Horizon"].Suck)
			for _, v_15 in var34_upvw["Event Horizon"]:GetDescendants() do
				if v_15:IsA("ParticleEmitter") then
					v_15.Enabled = false
				end
			end
			for _, v_16 in var34_upvw["Event Horizon"].Blackhole2:GetChildren() do
				v_16.Enabled = true
			end
			task.wait(1)
			var33_upvw = false
			task.wait()
			if not var34_upvw then return end
			for _, v_17 in tbl_upvr_5 do
				(function(arg1_4) -- Line 290, Named "HitTarget"
					--[[ Upvalues[1]:
						[1]: TweenService_upvr (copied, readonly)
					]]
					TweenService_upvr:Create(arg1_4.HumanoidRootPart, TweenInfo.new(0), {
						CFrame = arg1_4.HumanoidRootPart.CFrame;
					}):Play()
				end)(v_17)
				local var219
			end
			for _, v_18 in var2_upvw.findEnemiesMagnitude(var34_upvw.Position, 20, true), nil do
				var219(v_18)
				local _
			end
			for _, v_19 in tbl_upvr_4 do
				v_19:Destroy()
			end
			for i_20, v_20 in tbl_upvr_2 do
				local var221 = workspace.WorldInfo.Live:FindFirstChild(i_20) or false
				if var221 then
					var2_upvw.applyDebris(v_20, 0, var221)
				end
			end
			task.wait()
			var27_upvw:Disconnect()
			var2_upvw.changeFov(arg1, 60, 0, 1)
			var2_upvw.camShake(arg1, "BigBump")
			var2_upvw.Blur(arg1, 15, 1)
			var2_upvw.applySound(Event_Horizon_upvr.SingularityBlast, var34_upvw)
			var2_upvw.EmitAllDescendants(var34_upvw["Event Horizon"].Explosion)
			var34_upvw["Event Horizon"].Blackhole2:Destroy()
			for _, v_21 in tbl_upvr_5 do
				(function(arg1_5) -- Line 326, Named "HitTarget2"
					--[[ Upvalues[2]:
						[1]: var2_upvw (copied, read and write)
						[2]: var34_upvw (copied, read and write)
					]]
					if not var2_upvw.CheckBlock(arg1_5, true) then
						var2_upvw.applyDamage(arg1_5, 5)
						var2_upvw.applyStatus(arg1_5, "Ragdoll", 3)
						var2_upvw.Knockback(arg1_5, var34_upvw.Position, 10, 30)
					end
				end)(v_21)
				local var222
			end
			for _, v_22 in var2_upvw.findEnemiesMagnitude(var34_upvw.Position, 20, true), nil do
				var222(v_22)
				local _
			end
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1_2_upvr:GetMarkerReachedSignal("end"):Connect(function() -- Line 346
		--[[ Upvalues[3]:
			[1]: var32_upvw (read and write)
			[2]: tbl_upvr_3 (readonly)
			[3]: var2_upvw (copied, read and write)
		]]
		var32_upvw = true
		for _, v_11 in tbl_upvr_3 do
			var2_upvw.applyDebris(v_11, 0.25)
		end
		table.clear(tbl_upvr_3)
	end), module_upvr.Cooldown)
end
return module_upvr