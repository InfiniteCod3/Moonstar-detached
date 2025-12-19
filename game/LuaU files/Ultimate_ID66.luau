-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:41
-- Luau version 6, Types version 3
-- Time taken: 0.012116 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
if script.Parent.Parent:IsA("ModuleScript") then
	var3_upvw = require(script.Parent.Parent)
end
module_upvr.ModeLength = 70
local TweenService_upvr = game:GetService("TweenService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: module_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 20)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid = arg1:FindFirstChild("Humanoid")
	local Ultimate_upvr = ReplicatedStorage_upvr.Skills["Snow Blasters"].Ultimate
	for _, v in Humanoid:GetPlayingAnimationTracks() do
		v:Stop(0)
	end
	local tbl_upvr = {}
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "IFrames", 2))
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "Freeze", 2))
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "GlobalCD", 2))
	task.wait()
	local any_LoadAnimation_result1_upvr = Humanoid.Animator:LoadAnimation(Ultimate_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 44
		--[[ Upvalues[4]:
			[1]: Ultimate_upvr (readonly)
			[2]: var3_upvw (copied, read and write)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: arg1 (readonly)
		]]
		local clone_3 = Ultimate_upvr:FindFirstChild(arg1_2):Clone()
		var3_upvw.applyDebris(clone_3, 5)
		clone_3.Parent = HumanoidRootPart_upvr
		clone_3:Play()
		if arg1_2 == "footstep" then
			var3_upvw.camShake(arg1, "SmallBump")
			clone_3.PlaybackSpeed += math.random(-2, 2) * 0.12
		end
	end), 60)
	Humanoid.Health = Humanoid.MaxHealth
	local clone_5 = Ultimate_upvr.Charge:Clone()
	clone_5.Parent = HumanoidRootPart_upvr
	clone_5:Play()
	var3_upvw.applyDebris(clone_5, 5)
	local var20_upvw = 40
	local BodyVelocity_upvr = Instance.new("BodyVelocity", arg1.Head)
	BodyVelocity_upvr.MaxForce = Vector3.new(1000000, 0, 1000000)
	BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * var20_upvw
	var3_upvw.applyDebris(BodyVelocity_upvr, 1.32)
	task.spawn(function() -- Line 69
		--[[ Upvalues[3]:
			[1]: BodyVelocity_upvr (readonly)
			[2]: var20_upvw (read and write)
			[3]: HumanoidRootPart_upvr (readonly)
		]]
		while task.wait() and BodyVelocity_upvr.Parent do
			if var20_upvw <= 0 then
				BodyVelocity_upvr:Destroy()
			end
			BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * var20_upvw
			var20_upvw -= 0.05
		end
	end)
	local clone_4_upvr = Ultimate_upvr.ThemeSong:Clone()
	clone_4_upvr.Parent = HumanoidRootPart_upvr
	clone_4_upvr:Play()
	var3_upvw.applyDebris(clone_4_upvr, module_upvr.ModeLength + 5)
	clone_4_upvr.Volume += 1
	task.delay(3, function() -- Line 83
		--[[ Upvalues[2]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: clone_4_upvr (readonly)
		]]
		TweenService_upvr:Create(clone_4_upvr, TweenInfo.new(5), {
			Volume = clone_4_upvr.Volume - 1;
		}):Play()
	end)
	local var26_upvw
	task.delay(module_upvr.ModeLength, function() -- Line 88
		--[[ Upvalues[6]:
			[1]: PlayerStatus_upvr (copied, readonly)
			[2]: arg1 (readonly)
			[3]: var26_upvw (read and write)
			[4]: var3_upvw (copied, read and write)
			[5]: TweenService_upvr (copied, readonly)
			[6]: clone_4_upvr (readonly)
		]]
		repeat
			task.wait()
		until not PlayerStatus_upvr.FindStatus(arg1, "GlobalCD")
		if not var26_upvw.Parent then
		else
			var26_upvw.Detach:Play()
			var3_upvw.ChangeEnviorment(arg1, "Normal")
			TweenService_upvr:Create(clone_4_upvr, TweenInfo.new(2), {
				Volume = 0;
			}):Play()
			task.spawn(function() -- Line 97
				--[[ Upvalues[2]:
					[1]: var26_upvw (copied, read and write)
					[2]: var3_upvw (copied, read and write)
				]]
				while task.wait() and var26_upvw.Parent do
					if workspace:Raycast(var26_upvw.Position, Vector3.new(0, -3.2 + var26_upvw.Velocity.Y * 0.15, 0), var3_upvw.raycastParams) then
						var26_upvw.Fall:Play()
						return
					end
				end
			end)
			var26_upvw.Parent = workspace.WorldInfo.Thrown
			var26_upvw.CollisionGroup = "noCollision"
			var26_upvw.weld.Part0 = nil
			var26_upvw.CanCollide = true
			task.wait(5)
			TweenService_upvr:Create(var26_upvw, TweenInfo.new(4), {
				Size = Vector3.new(0, 0, 0);
			}):Play()
			TweenService_upvr:Create(var26_upvw.Glow, TweenInfo.new(4), {
				Size = Vector3.new(0, 0, 0);
			}):Play()
		end
	end)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("shoot"):Connect(function() -- Line 117
		--[[ Upvalues[9]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: var26_upvw (read and write)
			[4]: Ultimate_upvr (readonly)
			[5]: module_upvr (copied, readonly)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: var20_upvw (read and write)
			[8]: any_LoadAnimation_result1_upvr (readonly)
			[9]: tbl_upvr (readonly)
		]]
		var3_upvw.flashScreen(arg1, Color3.new(0, 0, 0), 2)
		task.delay(0.1, function() -- Line 120
			--[[ Upvalues[2]:
				[1]: var3_upvw (copied, read and write)
				[2]: arg1 (copied, readonly)
			]]
			var3_upvw.ChangeEnviorment(arg1, "SnowBlasters")
		end)
		var26_upvw = Ultimate_upvr["Snow Cannon"]:Clone()
		var26_upvw.Parent = arg1
		var26_upvw.weld.Part0 = arg1.Torso
		var26_upvw.weld.Part1 = var26_upvw
		var3_upvw.applyDebris(var26_upvw, module_upvr.ModeLength + 15)
		local clone_2 = Ultimate_upvr.Explosion:Clone()
		clone_2.Parent = HumanoidRootPart_upvr
		clone_2:Play()
		local clone = Ultimate_upvr.Explosion2:Clone()
		clone.Parent = HumanoidRootPart_upvr
		clone:Play()
		local clone_6 = Ultimate_upvr.VFX.vfx:Clone()
		clone_6.Parent = HumanoidRootPart_upvr
		var3_upvw.EmitAllDescendants(clone_6)
		var3_upvw.applyDebris(clone_6, 10)
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.changeFov(arg1, 60, 0, 1.5)
		var3_upvw.flashScreen(arg1, Color3.new(0.654902, 1, 0.976471), 1)
		var20_upvw = 20
		any_LoadAnimation_result1_upvr:AdjustSpeed(0.75)
		any_LoadAnimation_result1_upvr:Stop()
		for _, v_2 in tbl_upvr do
			var3_upvw.applyDebris(v_2, 0)
		end
	end), 60)
end
return module_upvr