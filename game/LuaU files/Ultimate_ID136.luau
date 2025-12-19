-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:39
-- Luau version 6, Types version 3
-- Time taken: 0.033576 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.GlobalCD = 0
module_upvr.ModeLength = 60
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 18
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: TweenService_upvr (readonly)
		[4]: PlayerStatus_upvr (readonly)
		[5]: module_upvr (readonly)
	]]
	-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, 20)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid = arg1:FindFirstChild("Humanoid")
	local Ultimate_upvr = ReplicatedStorage_upvr.Skills["Earth Hammer"].Ultimate
	local clone_8_upvr = Ultimate_upvr.TheResponse:Clone()
	clone_8_upvr.Parent = HumanoidRootPart_upvr
	var3_upvw.applyDebris(clone_8_upvr, clone_8_upvr.TimeLength)
	clone_8_upvr:Play()
	local var30
	for i, v in workspace.WorldInfo.Live:GetDescendants() do
		if v:IsA("Sound") and v.Name == "TheCalling" then
			var30 = v
		elseif v:IsA("Sound") and v.Name == "TheResponse" then
			local var31 = v
		end
	end
	local function Totality(arg1_2) -- Line 47
		--[[ Upvalues[5]:
			[1]: ReplicatedStorage_upvr (copied, readonly)
			[2]: var3_upvw (copied, read and write)
			[3]: TweenService_upvr (copied, readonly)
			[4]: PlayerStatus_upvr (copied, readonly)
			[5]: arg1 (readonly)
		]]
		local var36
		if arg1_2:IsA("Sound") and arg1_2.Name == "TheCalling" then
			var36 = ReplicatedStorage_upvr.Skills["Bone Scythe"].Ultimate
		elseif arg1_2:IsA("Sound") and arg1_2.Name == "TheResponse" then
			var36 = ReplicatedStorage_upvr.Skills["Earth Hammer"].Ultimate
		end
		if var36 then
			local Totality_2 = var36.Totality
			local clone_5 = var36.TotalityVFX:Clone()
			clone_5.Parent = arg1_2
			clone_5.CFrame = arg1_2.Parent.Parent.HumanoidRootPart.CFrame
			var3_upvw.EmitAllDescendants(clone_5)
			var3_upvw.applyDebris(clone_5, 6)
			for _, v_2 in clone_5:GetDescendants() do
				if v_2:IsA("Sound") then
					v_2:Play()
				end
			end
			arg1_2.Name = "Totality"
			TweenService_upvr:Create(arg1_2, TweenInfo.new(0), {
				Volume = Totality_2.Volume;
			}):Play()
			arg1_2.SoundId = Totality_2.SoundId
			arg1_2.TimePosition = 0
			task.delay(0.1, function() -- Line 74
				--[[ Upvalues[3]:
					[1]: PlayerStatus_upvr (copied, readonly)
					[2]: arg1 (copied, readonly)
					[3]: var3_upvw (copied, read and write)
				]]
				for _, v_3 in PlayerStatus_upvr.FindTable(arg1) do
					var3_upvw.applyDebris(v_3, 0)
				end
			end)
		end
	end
	if var30 and var31 then
		i = workspace
		local children, NONE_6, NONE_2_upvw = i.WorldInfo.Live:GetChildren()
		for _, v_4 in children, NONE_6, NONE_2_upvw do
			var3_upvw.camShake(v_4, "Bump")
			var3_upvw.changeFov(v_4, 300, 0, 3)
			var3_upvw.flashScreen(v_4, Color3.new(0, 0, 0), 0.1)
		end
		NONE_2_upvw = "Stunned"
		var3_upvw.applyStatus(arg1, NONE_2_upvw, 1)
		NONE_2_upvw = "IFrames"
		var3_upvw.applyStatus(arg1, NONE_2_upvw, 1)
		NONE_2_upvw = "GlobalCD"
		var3_upvw.applyStatus(arg1, NONE_2_upvw, 1)
		NONE_2_upvw = "AutoRotate"
		var3_upvw.applyStatus(arg1, NONE_2_upvw, 1)
		NONE_2_upvw = "Totality"
		var3_upvw.Dialogue("All", NONE_2_upvw, 0.05, 2.5, true)
		Totality(var30)
		Totality(var31)
	end
	NONE_2_upvw = module_upvr.ModeLength + 1
	var3_upvw.applyDebris(clone_8_upvr, NONE_2_upvw)
	Humanoid.Health = Humanoid.MaxHealth
	local clone_9_upvr = Ultimate_upvr.Part.sounds:Clone()
	clone_9_upvr.Parent = HumanoidRootPart_upvr
	NONE_2_upvw = var3_upvw
	NONE_2_upvw = clone_9_upvr
	NONE_2_upvw.applyDebris(NONE_2_upvw, module_upvr.ModeLength + 1)
	NONE_2_upvw = module_upvr.ModeLength
	task.delay(NONE_2_upvw, function() -- Line 108
		--[[ Upvalues[3]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: clone_9_upvr (readonly)
			[3]: clone_8_upvr (readonly)
		]]
		TweenService_upvr:Create(clone_9_upvr.Music2, TweenInfo.new(1), {
			Volume = 0;
		}):Play()
		TweenService_upvr:Create(clone_8_upvr, TweenInfo.new(1), {
			Volume = 0;
		}):Play()
	end)
	if var30 and var31 then
	else
		local any_LoadAnimation_result1_upvr = Humanoid.Animator:LoadAnimation(Ultimate_upvr.Animation)
		NONE_2_upvw = any_LoadAnimation_result1_upvr:Play
		NONE_2_upvw()
		NONE_2_upvw = var3_upvw.applyStatus
		NONE_2_upvw(arg1, "Freeze", 4.5)
		NONE_2_upvw = var3_upvw.applyStatus
		NONE_2_upvw(arg1, "AutoRotate", 4.5)
		NONE_2_upvw = var3_upvw.applyStatus
		NONE_2_upvw(arg1, "IFrames", 4.5)
		NONE_2_upvw = var3_upvw.applyStatus
		NONE_2_upvw(arg1, "GlobalCD", 4.5)
		NONE_2_upvw = clone_9_upvr.whoosh:Play
		NONE_2_upvw()
		NONE_2_upvw = clone_9_upvr.charge:Play
		NONE_2_upvw()
		NONE_2_upvw = clone_9_upvr.Mode:Play
		NONE_2_upvw()
		NONE_2_upvw = 0
		any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("smash"):Connect(function() -- Line 129
			--[[ Upvalues[10]:
				[1]: NONE_2_upvw (read and write)
				[2]: clone_9_upvr (readonly)
				[3]: TweenService_upvr (copied, readonly)
				[4]: arg1 (readonly)
				[5]: Ultimate_upvr (readonly)
				[6]: var3_upvw (copied, read and write)
				[7]: module_upvr (copied, readonly)
				[8]: any_LoadAnimation_result1_upvr (readonly)
				[9]: HumanoidRootPart_upvr (readonly)
				[10]: Folder_upvr (readonly)
			]]
			NONE_2_upvw += 1
			local Music = clone_9_upvr.Music
			Music.Volume += 1
			Music = NONE_2_upvw
			local var101
			if var101 == 1 then
				var101 = clone_9_upvr.Music
				var101.PlaybackSpeed = 0.8
			else
				var101 = NONE_2_upvw
				if var101 == 3 then
					var101 = TweenService_upvr
					local _ = {
						PlaybackSpeed = 1;
					}
					var101 = var101:Create(clone_9_upvr.Music, TweenInfo.new(2), _):Play
					var101()
					var101 = clone_9_upvr.Flow:Play
					var101()
					var101 = clone_9_upvr.Music
					var101.PlaybackSpeed = 1
					var101 = clone_9_upvr.Music2:Play
					var101()
					var101 = arg1:GetChildren()
					local children_5, NONE_4, NONE_7 = arg1:GetChildren()
					for _, v_5 in children_5, NONE_4, NONE_7 do
						if v_5.Name == "Left Arm" or v_5.Name == "Right Arm" or v_5.Name == "Head" or v_5.Name == "Torso" or v_5.Name == "Left Leg" or v_5.Name == "Right Leg" then
							for _, v_6 in Ultimate_upvr.Aura:GetChildren() do
								local clone_7_upvr = v_6:Clone()
								clone_7_upvr.Parent = v_5
								clone_7_upvr.Enabled = true
								var3_upvw.applyDebris(clone_7_upvr, module_upvr.ModeLength + 5)
								task.delay(module_upvr.ModeLength, function() -- Line 150
									--[[ Upvalues[1]:
										[1]: clone_7_upvr (readonly)
									]]
									clone_7_upvr.Enabled = false
								end)
							end
						end
					end
					children_5 = task.wait
					children_5()
					children_5 = any_LoadAnimation_result1_upvr:Stop
					children_5(1.5)
					children_5 = TweenService_upvr
					local _ = {
						Volume = 0;
					}
					children_5 = children_5:Create(clone_9_upvr.Music, TweenInfo.new(5), _):Play
					children_5()
				end
			end
			children_5 = clone_9_upvr.smash:Play
			children_5()
			children_5 = clone_9_upvr.smash
			children_5.PlaybackSpeed -= 0.2
			children_5 = clone_9_upvr.smash
			children_5.Volume += 1
			children_5 = clone_9_upvr.smash2:Play
			children_5()
			children_5 = clone_9_upvr.smash2
			children_5.PlaybackSpeed -= 0.2
			children_5 = clone_9_upvr.smash2
			children_5.Volume += 1
			children_5 = var3_upvw.changeFov
			children_5(arg1, 40, 0.01, 1)
			children_5 = var3_upvw.Blur
			children_5(arg1, 30, 0.4)
			children_5 = var3_upvw.flashScreen
			children_5(arg1, Color3.new(0.0705882, 0.0705882, 0.0705882), 0.35)
			children_5 = var3_upvw.impactFrame2
			children_5(arg1, 0.1)
			children_5 = var3_upvw.crater
			children_5(NONE_2_upvw * 1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5, 1.5, 0.1)
			children_5 = var3_upvw.CreateDebris
			children_5(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5, NONE_2_upvw * 6, NONE_2_upvw * 0.8, NONE_2_upvw * 0.8, 0.01)
			children_5 = var3_upvw.crater
			children_5(NONE_2_upvw * 1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5, NONE_2_upvw * 3, NONE_2_upvw * 1.8)
			children_5 = var3_upvw.camShake
			children_5(arg1, "Explosion")
			children_5 = nil
			local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5, Vector3.new(0, -3.0999, 0), var3_upvw.raycastParams)
			if workspace_Raycast_result1 then
				children_5 = workspace_Raycast_result1.Position
				local clone_3 = Ultimate_upvr.Cracks:FindFirstChild("MainCrack"..NONE_2_upvw):Clone()
				clone_3.Parent = Folder_upvr
				clone_3.Position = workspace_Raycast_result1.Position
				var3_upvw.EmitAllDescendants(clone_3.Vfx)
			end
			if children_5 then
				local clone_10 = Ultimate_upvr.Hitboxes:FindFirstChild("Hitbox"..NONE_2_upvw):Clone()
				if clone_10 then
					clone_10.Parent = Folder_upvr
					clone_10.Position = children_5
					var3_upvw.applyDebris(clone_10, 0.1)
					for _, v_7 in var3_upvw.findEnemiesPart(clone_10, true), nil do
						clone_7_upvr = Ultimate_upvr
						local clone = clone_7_upvr.hitVfx:Clone()
						clone_7_upvr = Folder_upvr
						clone.Parent = clone_7_upvr
						clone_7_upvr = v_7.Torso.Position
						clone.Position = clone_7_upvr
						clone_7_upvr = var3_upvw.EmitAllDescendants
						clone_7_upvr(clone)
						clone_7_upvr = clone.sfx:Play
						clone_7_upvr()
						clone_7_upvr = var3_upvw.applyDebris
						clone_7_upvr(clone, 5)
						clone_7_upvr = var3_upvw.CheckBlock
						clone_7_upvr(v_7, true)
						clone_7_upvr = NONE_2_upvw
						if clone_7_upvr < 3 then
							clone_7_upvr = var3_upvw.applyDamage
							clone_7_upvr(v_7, 3)
							clone_7_upvr = var3_upvw.applyStatus
							clone_7_upvr(v_7, "Ragdoll", 2)
							clone_7_upvr = var3_upvw.Knockback
							clone_7_upvr(v_7, HumanoidRootPart_upvr.Position, 0, 15)
						else
							clone_7_upvr = var3_upvw.applyDamage
							clone_7_upvr(v_7, 6)
							clone_7_upvr = var3_upvw.applyStatus
							clone_7_upvr(v_7, "Ragdoll", 3)
							clone_7_upvr = var3_upvw.Knockback
							clone_7_upvr(v_7, HumanoidRootPart_upvr.Position, 0, 70)
						end
					end
				end
			end
			task.wait(0.1)
			if NONE_2_upvw ~= 3 then
				clone_9_upvr.whoosh:Play()
				clone_9_upvr.charge:Play()
				local whoosh_2 = clone_9_upvr.whoosh
				whoosh_2.PlaybackSpeed -= 0.1
				local charge = clone_9_upvr.charge
				charge.PlaybackSpeed -= 0.1
			end
		end)
	end
end
return module_upvr