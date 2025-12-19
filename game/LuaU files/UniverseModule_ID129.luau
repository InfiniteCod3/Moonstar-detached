-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:10
-- Luau version 6, Types version 3
-- Time taken: 0.033887 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 120
module_upvr.GlobalCD = 0.5
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 15
	--[[ Upvalues[6]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: RunService_upvr (readonly)
		[6]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Universe_upvr = ReplicatedStorage_upvr.Skills.Nebula.Ultimate.Universe
	local tbl_upvr_2 = {}
	local any_LoadAnimation_result1 = Humanoid_upvr:LoadAnimation(Universe_upvr.Animation)
	any_LoadAnimation_result1:Play()
	local tbl_upvr = {}
	local BodyVelocity_upvr = Instance.new("BodyVelocity", arg1.Head)
	BodyVelocity_upvr.MaxForce = Vector3.new(0, 99999, 0)
	BodyVelocity_upvr.Velocity = Vector3.new(0, 60, 0)
	var3_upvw.applyDebris(BodyVelocity_upvr, 25)
	table.insert(tbl_upvr, BodyVelocity_upvr)
	TweenService_upvr:Create(BodyVelocity_upvr, TweenInfo.new(1), {
		Velocity = Vector3.new(0, 0, 0);
	}):Play()
	table.insert(tbl_upvr_2, var3_upvw.applySound(Universe_upvr.Jump, HumanoidRootPart_upvr))
	var3_upvw.camShake(arg1, "SmallBump")
	var3_upvw.changeFov(arg1, 45, 0.75, 5)
	var3_upvw.Blur(arg1, 10, 1)
	var3_upvw.applyStatus(arg1, "Slowed", 2)
	var3_upvw.applyStatus(arg1, "GlobalCD", 2)
	var3_upvw.applyStatus(arg1, "IFrames", 2)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Wormhole"):Connect(function() -- Line 54
		--[[ Upvalues[13]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: BodyVelocity_upvr (readonly)
			[4]: TweenService_upvr (copied, readonly)
			[5]: Universe_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: HumanoidRootPart_upvr (readonly)
			[8]: RunService_upvr (copied, readonly)
			[9]: module_upvr (copied, readonly)
			[10]: tbl_upvr_2 (readonly)
			[11]: tbl_upvr (readonly)
			[12]: Humanoid_upvr (readonly)
			[13]: PlayerStatus_upvr (copied, readonly)
		]]
		BodyVelocity_upvr.Velocity = Vector3.new(0, 50, 0)
		TweenService_upvr:Create(BodyVelocity_upvr, TweenInfo.new(0.5), {
			Velocity = Vector3.new(0, 0, 0);
		}):Play()
		var3_upvw.camShake(arg1, "BigBump")
		var3_upvw.flashScreen(arg1, Color3.new(0, 0, 0), 1)
		var3_upvw.Blur(arg1, 40, 1)
		var3_upvw.changeFov(arg1, 300, 0, 1)
		local clone_upvr = Universe_upvr.Wormhole:Clone()
		clone_upvr.Parent = Folder_upvr
		clone_upvr.CFrame = HumanoidRootPart_upvr.CFrame + Vector3.new(0, -5, 0)
		local var68_upvw = HumanoidRootPart_upvr.CFrame + Vector3.new(0, -8, 0)
		local function _() -- Line 73
			--[[ Upvalues[3]:
				[1]: clone_upvr (readonly)
				[2]: TweenService_upvr (copied, readonly)
				[3]: var68_upvw (read and write)
			]]
			if not clone_upvr.Parent then
			else
				TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.25), {
					CFrame = var68_upvw;
				}):Play()
			end
		end
		clone_upvr.Wireframe.Size = Vector3.new(50, 0, 50)
		TweenService_upvr:Create(clone_upvr.Wireframe, TweenInfo.new(0.5), {
			Size = Vector3.new(50, 10, 50);
		}):Play()
		clone_upvr.Glass.Size = Vector3.new(55, 0, 55)
		TweenService_upvr:Create(clone_upvr.Glass, TweenInfo.new(0.75), {
			Size = Vector3.new(55, 10, 55);
		}):Play()
		table.insert(tbl_upvr_2, var3_upvw.applySound(Universe_upvr.Spawn, clone_upvr))
		table.insert(tbl_upvr_2, var3_upvw.applySound(Universe_upvr.Spawn2, clone_upvr))
		table.insert(tbl_upvr_2, var3_upvw.applySound(Universe_upvr.Spawn3, clone_upvr))
		local any_applySound_result1 = var3_upvw.applySound(Universe_upvr.Pull, clone_upvr)
		any_applySound_result1.Volume = 0
		TweenService_upvr:Create(any_applySound_result1, TweenInfo.new(0.4), {
			Volume = 2;
		}):Play()
		task.wait(0.2)
		local descendants_3, NONE_10, _ = clone_upvr.Glass:GetDescendants()
		local var77
		for _, v in descendants_3, NONE_10, var77 do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			end
		end
		local function ScreenEffects_upvr(arg1_2) -- Line 96, Named "ScreenEffects"
			--[[ Upvalues[2]:
				[1]: var3_upvw (copied, read and write)
				[2]: arg1 (copied, readonly)
			]]
			var3_upvw.changeFov(arg1_2, 120, 0, 0.5)
			var3_upvw.impactFrame(arg1)
			var3_upvw.flashScreen(arg1_2, Color3.new(1, 1, 1), 0.5)
			task.delay(0.1, function() -- Line 100
				--[[ Upvalues[2]:
					[1]: var3_upvw (copied, read and write)
					[2]: arg1_2 (readonly)
				]]
				var3_upvw.flashScreen(arg1_2, Color3.new(0, 0, 0), 0.5)
			end)
		end
		var77 = false
		local any_findEnemiesPart_result1 = var3_upvw.findEnemiesPart(clone_upvr.Hitbox, true)
		for var91, var95_upvr in any_findEnemiesPart_result1 do
			if not var3_upvw.CheckBlock(var95_upvr, false) and not var95_upvr:GetAttribute("Dead") then
				var77 = true
				local var81_upvw = false
				task.spawn(function() -- Line 113
					--[[ Upvalues[8]:
						[1]: var95_upvr (readonly)
						[2]: var3_upvw (copied, read and write)
						[3]: clone_upvr (readonly)
						[4]: tbl_upvr (copied, readonly)
						[5]: RunService_upvr (copied, readonly)
						[6]: module_upvr (copied, readonly)
						[7]: var81_upvw (read and write)
						[8]: ScreenEffects_upvr (readonly)
					]]
					for _, v_3 in var95_upvr:GetDescendants() do
						if v_3:IsA("BodyVelocity") then
							v_3:Destroy()
						end
					end
					var3_upvw.applyDamage(var95_upvr, 10, true, true)
					var3_upvw.applyStatus(var95_upvr, "Ragdoll", 20)
					var3_upvw.applyStatus(var95_upvr, "DashDB", 20)
					var3_upvw.applyStatus(var95_upvr, "Stunned", 20)
					var3_upvw.applyStatus(var95_upvr, "AutoRotate", 20)
					var3_upvw.applyStatus(var95_upvr, "IFrames", 20)
					var3_upvw.applyStatus(var95_upvr, "Ultimate", 20)
					local BodyPosition_upvr = Instance.new("BodyPosition", var95_upvr.Torso)
					BodyPosition_upvr.MaxForce = Vector3.new(99999, 99999, 99999)
					BodyPosition_upvr.Position = clone_upvr.Wireframe.Position
					var3_upvw.applyDebris(BodyPosition_upvr, 20)
					table.insert(tbl_upvr, BodyPosition_upvr)
					local function _() -- Line 137
						--[[ Upvalues[2]:
							[1]: BodyPosition_upvr (readonly)
							[2]: clone_upvr (copied, readonly)
						]]
						if not BodyPosition_upvr.Parent then
						else
							BodyPosition_upvr.Position = clone_upvr.Wireframe.Position
						end
					end
					var3_upvw.changeFov(var95_upvr, 1000, 0.5, 10)
					var3_upvw.Blur(var95_upvr, 20, 1)
					task.wait(0.5)
					var81_upvw = true
					ScreenEffects_upvr(var95_upvr)
					var3_upvw.camShake(var95_upvr, "Bump")
					var3_upvw.Blur(var95_upvr, 20, 0.5)
					task.wait()
					var3_upvw.Cutscene(var95_upvr, "Galaxy", true)
				end)
			end
		end
		if var77 then
			var3_upvw.applySound(Universe_upvr.Charge, clone_upvr)
			var91 = 0.5
			var95_upvr = 10
			var3_upvw.changeFov(arg1, 1000, var91, var95_upvr)
			var91 = 1
			var3_upvw.Blur(arg1, 20, var91)
			var91 = "NebulaTheme"
			var95_upvr = true
			local var89_upvr = arg1:FindFirstChild(var91, var95_upvr) or false
			if var89_upvr then
				var91 = var89_upvr
				var95_upvr = TweenInfo.new(0.5)
				TweenService_upvr:Create(var91, var95_upvr, {
					Volume = 0;
				}):Play()
				function var91() -- Line 166
					--[[ Upvalues[2]:
						[1]: var89_upvr (readonly)
						[2]: TweenService_upvr (copied, readonly)
					]]
					if var89_upvr and var89_upvr:IsDescendantOf(game) then
						TweenService_upvr:Create(var89_upvr, TweenInfo.new(1.5), {
							Volume = 0.5;
						}):Play()
					end
				end
				task.delay(18, var91)
			end
			var95_upvr = "NebulaHighlight"
			local var93_upvr = arg1:FindFirstChild(var95_upvr) or false
			if var93_upvr then
				var95_upvr = var93_upvr
				TweenService_upvr:Create(var95_upvr, TweenInfo.new(0.25), {
					OutlineTransparency = 1;
					FillTransparency = 1;
				}):Play()
				var91 = 20
				function var95_upvr() -- Line 177
					--[[ Upvalues[2]:
						[1]: var93_upvr (readonly)
						[2]: TweenService_upvr (copied, readonly)
					]]
					if not var93_upvr then
					else
						TweenService_upvr:Create(var93_upvr, TweenInfo.new(2), {
							OutlineTransparency = 0;
							FillTransparency = 0;
						}):Play()
					end
				end
				task.delay(var91, var95_upvr)
			end
			var91 = var3_upvw
			var91 = arg1
			var95_upvr = "Stunned"
			var91.applyStatus(var91, var95_upvr, 20)
			var91 = var3_upvw
			var91 = arg1
			var95_upvr = "AutoRotate"
			var91.applyStatus(var91, var95_upvr, 20)
			var91 = var3_upvw
			var91 = arg1
			var95_upvr = "IFrames"
			var91.applyStatus(var91, var95_upvr, 20)
			var91 = var3_upvw
			var91 = arg1
			var95_upvr = "Ultimate"
			var91.applyStatus(var91, var95_upvr, 20)
			repeat
				task.wait()
				if var81_upvw then break end
				var91 = arg1
			until not var91.Parent
			local descendants_5, NONE_5, NONE_4 = clone_upvr.Glass:GetDescendants()
			for _, v_4 in descendants_5, NONE_5, NONE_4 do
				if v_4:IsA("ParticleEmitter") then
					v_4.Enabled = false
				end
			end
			NONE_5 = arg1
			ScreenEffects_upvr(NONE_5)
			NONE_5 = var3_upvw
			NONE_5 = arg1
			NONE_4 = "Bump"
			NONE_5.camShake(NONE_5, NONE_4)
			NONE_5 = var3_upvw
			NONE_5 = arg1
			NONE_4 = 20
			NONE_5.Blur(NONE_5, NONE_4, 0.5)
			NONE_4 = clone_upvr.Wireframe
			TweenService_upvr:Create(NONE_4, TweenInfo.new(0.1), {
				Size = Vector3.new(0, 0, 0);
			}):Play()
			NONE_4 = clone_upvr.Glass
			TweenService_upvr:Create(NONE_4, TweenInfo.new(0.1), {
				Size = Vector3.new(0, 0, 0);
			}):Play()
			NONE_5 = var3_upvw
			NONE_5 = arg1
			NONE_4 = "Galaxy"
			NONE_5.Cutscene(NONE_5, NONE_4, true)
			NONE_5 = nil
			NONE_4 = nil
			for _, v_5 in tbl_upvr_2, NONE_5, NONE_4 do
				TweenService_upvr:Create(v_5, TweenInfo.new(2), {
					Volume = 0;
				}):Play()
			end
			NONE_4 = 0.6
			clone_upvr.SpaceModel:ScaleTo(NONE_4)
			function NONE_5() -- Line 207
				--[[ Upvalues[1]:
					[1]: clone_upvr (readonly)
				]]
				while task.wait() and clone_upvr.Parent do
					local SpinWeld = clone_upvr.SpaceModel.SpinWeld
					SpinWeld.C0 *= CFrame.Angles(0, 0.02, 0)
				end
			end
			task.spawn(NONE_5)
			NONE_4 = any_applySound_result1
			TweenService_upvr:Create(NONE_4, TweenInfo.new(1), {
				Volume = 0;
			}):Play()
			var68_upvw = HumanoidRootPart_upvr.CFrame
			NONE_5 = var3_upvw
			NONE_5 = arg1
			NONE_4 = "Stunned"
			NONE_5.applyStatus(NONE_5, NONE_4, 4)
			NONE_5 = var3_upvw
			NONE_5 = arg1
			NONE_4 = "AutoRotate"
			NONE_5.applyStatus(NONE_5, NONE_4, 4)
			NONE_5 = var3_upvw
			NONE_4 = Universe_upvr.VFX
			NONE_5 = NONE_4.GalaxyVFX
			NONE_4 = arg1.Torso
			NONE_5 = task.wait
			NONE_4 = 11
			NONE_5(NONE_4)
			NONE_5 = print
			NONE_4 = "CUTSCENE OVER"
			NONE_5(NONE_4)
			NONE_4 = var3_upvw
			NONE_5 = NONE_4.applySound
			NONE_4 = Universe_upvr.Flow
			NONE_5(NONE_4, clone_upvr)
			NONE_4 = var3_upvw
			NONE_5 = NONE_4.CameraDistance
			NONE_4 = arg1
			NONE_5(NONE_4, 40, 40, 4)
			NONE_4 = var3_upvw
			NONE_5 = NONE_4.changeFov
			NONE_4 = arg1
			NONE_5(NONE_4, 50, 3, 3)
			NONE_5 = any_findEnemiesPart_result1
			NONE_4 = nil
			for _, v_6 in NONE_5, NONE_4 do
				var3_upvw.CameraDistance(v_6, 40, 40, 4)
				var3_upvw.changeFov(v_6, 60, 1, 3)
			end
			NONE_5 = task.wait
			NONE_4 = 2
			NONE_5(NONE_4)
			NONE_4 = var3_upvw
			NONE_5 = NONE_4.CameraDistance
			NONE_4 = arg1
			NONE_5(NONE_4, 120, 120, 3)
			NONE_4 = var3_upvw
			NONE_5 = NONE_4.camShake
			NONE_4 = arg1
			NONE_5(NONE_4, "SmallBump")
			NONE_4 = var3_upvw
			NONE_5 = NONE_4.flashScreen
			NONE_4 = arg1
			NONE_5(NONE_4, Color3.new(1, 1, 1), 0.4)
			NONE_5 = any_findEnemiesPart_result1
			NONE_4 = nil
			for _, v_7 in NONE_5, NONE_4 do
				var3_upvw.CameraDistance(v_7, 120, 120, 3)
				var3_upvw.flashScreen(v_7, Color3.new(1, 1, 1), 0.4)
				var3_upvw.camShake(v_7, "SmallBump")
			end
			NONE_4 = var3_upvw
			NONE_5 = NONE_4.EmitAllDescendants
			NONE_4 = clone_upvr.SpaceModel.Space.VFX.Charge
			NONE_5(NONE_4)
			NONE_4 = var3_upvw
			NONE_5 = NONE_4.applySound
			NONE_4 = Universe_upvr.StarCharge
			NONE_5(NONE_4, clone_upvr)
			NONE_5 = task.wait
			NONE_4 = 0.5
			NONE_5(NONE_4)
			NONE_5 = clone_upvr.SpaceModel:GetDescendants()
			local descendants, NONE, NONE_2 = clone_upvr.SpaceModel:GetDescendants()
			for _, v_8 in descendants, NONE, NONE_2 do
				if v_8:IsA("BasePart") then
					TweenService_upvr:Create(v_8, TweenInfo.new(0.5), {
						Color = Color3.new(1, 1, 1);
					}):Play()
					TweenService_upvr:Create(v_8, TweenInfo.new(0.5), {
						Size = v_8.Size * Vector3.new(0.5, 0.5, 0.5);
					}):Play()
				elseif v_8:IsA("ParticleEmitter") then
					v_8.Enabled = false
				end
			end
			descendants = task.wait
			NONE = 0.5
			descendants(NONE)
			NONE = var3_upvw
			descendants = NONE.applySound
			NONE = Universe_upvr.StarExplode
			descendants(NONE, clone_upvr)
			NONE = var3_upvw
			descendants = NONE.applySound
			NONE = Universe_upvr.StarExplode2
			descendants(NONE, clone_upvr)
			NONE = var3_upvw
			descendants = NONE.EmitAllDescendants
			NONE = clone_upvr.SpaceModel.Space.VFX.Explosion
			descendants(NONE)
			NONE = var3_upvw
			descendants = NONE.camShake
			NONE = arg1
			descendants(NONE, "BigBump")
			NONE = var3_upvw
			descendants = NONE.flashScreen
			NONE = arg1
			descendants(NONE, Color3.new(1, 1, 1), 0.4)
			descendants = any_findEnemiesPart_result1
			NONE = nil
			for _, v_9 in descendants, NONE do
				var3_upvw.flashScreen(v_9, Color3.new(1, 1, 1), 0.4)
				var3_upvw.camShake(v_9, "BigBump")
			end
			descendants = clone_upvr.SpaceModel:GetDescendants()
			local descendants_6, NONE_9, NONE_6 = clone_upvr.SpaceModel:GetDescendants()
			for _, v_10 in descendants_6, NONE_9, NONE_6 do
				if v_10:IsA("BasePart") then
					TweenService_upvr:Create(v_10, TweenInfo.new(0.5), {
						Size = v_10.Size * Vector3.new(4, 4, 4);
						Transparency = 1;
					}):Play()
				end
			end
			descendants_6 = tbl_upvr
			NONE_9 = nil
			for _, v_11 in descendants_6, NONE_9 do
				var3_upvw.applyDebris(v_11, 0)
			end
			descendants_6 = task.wait
			descendants_6()
			NONE_9 = var3_upvw
			descendants_6 = NONE_9.applyStatus
			NONE_9 = arg1
			descendants_6(NONE_9, "Ultimate", 2.5)
			NONE_9 = var3_upvw
			descendants_6 = NONE_9.applyStatus
			NONE_9 = arg1
			descendants_6(NONE_9, "Stunned", 2.5)
			descendants_6 = Instance.new
			NONE_9 = "BodyVelocity"
			descendants_6 = descendants_6(NONE_9, arg1.Head)
			NONE_9 = Vector3.new(0, 99999, 0)
			descendants_6.MaxForce = NONE_9
			NONE_9 = Vector3.new(0, 65, 0)
			descendants_6.Velocity = NONE_9
			NONE_9 = var3_upvw.applyDebris
			NONE_9(descendants_6, 2)
			NONE_9 = Humanoid_upvr:LoadAnimation(Universe_upvr.Animation2)
			NONE_9:Play()
			TweenService_upvr:Create(descendants_6, TweenInfo.new(2), {
				Velocity = Vector3.new(0, 0, 0);
			}):Play()
			var3_upvw.CameraDistance(arg1, 60, 60, 2)
			for _, v_12 in any_findEnemiesPart_result1 do
				if not var3_upvw.CheckBlock(v_12, false) then
					var3_upvw.CameraDistance(v_12, 100, 100, 2)
					PlayerStatus_upvr.ClearStatus(v_12)
					var3_upvw.applyDamage(v_12, 90, true)
					var3_upvw.applyStatus(v_12, "Ragdoll", 3)
					var3_upvw.Knockback(v_12, clone_upvr.SpaceModel.Space.Position, 25, 60)
				end
			end
		else
			var89_upvr = clone_upvr.Glass:GetDescendants()
			local descendants_2, NONE_8, NONE_3 = clone_upvr.Glass:GetDescendants()
			for _, v_13 in descendants_2, NONE_8, NONE_3 do
				if v_13:IsA("ParticleEmitter") then
					v_13.Enabled = false
				end
			end
			descendants_2 = clone_upvr.SpaceModel:Destroy
			descendants_2()
			NONE_8 = var3_upvw
			descendants_2 = NONE_8.applyDebris
			NONE_8 = var3_upvw.applyStatus(arg1, "Stunned", 5)
			descendants_2(NONE_8, 0.5)
			NONE_8 = var3_upvw
			descendants_2 = NONE_8.applyDebris
			NONE_8 = BodyVelocity_upvr
			descendants_2(NONE_8, 0.5)
			descendants_2 = TweenService_upvr
			;({}).Size = Vector3.new(0, 0, 0)
			descendants_2 = descendants_2:Create
			-- KONSTANTERROR: Expression was reused, decompilation is incorrect
			descendants_2 = descendants_2(clone_upvr.Wireframe, TweenInfo.new(1), {}):Play
			descendants_2()
			descendants_2 = TweenService_upvr
			;({}).Size = Vector3.new(0, 0, 0)
			descendants_2 = descendants_2:Create
			-- KONSTANTERROR: Expression was reused, decompilation is incorrect
			descendants_2 = descendants_2(clone_upvr.Glass, TweenInfo.new(1), {}):Play
			descendants_2()
		end
	end), module_upvr.Cooldown)
end
return module_upvr