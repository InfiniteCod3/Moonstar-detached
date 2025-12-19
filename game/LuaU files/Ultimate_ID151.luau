-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:19:05
-- Luau version 6, Types version 3
-- Time taken: 0.005920 seconds

local module = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module.ModeLength = 105
local var3_upvw
function module.Script(arg1, arg2) -- Line 14
	--[[ Upvalues[2]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, 20)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid = arg1:FindFirstChild("Humanoid")
	local Ultimate_upvr = ReplicatedStorage_upvr.Skills.Chef.Ultimate
	var3_upvw.applyStatus(arg1, "Stunned", 3)
	var3_upvw.applyStatus(arg1, "Ultimate", 3)
	var3_upvw.applyStatus(arg1, "AutoRotate", 3)
	var3_upvw.applyStatus(arg1, "IFrames", 3)
	var3_upvw.applyStatus(arg1, "LockUltimateMeter", 25)
	var3_upvw.changeFov(arg1, 50, 1.65, 0.5)
	Humanoid.Health = Humanoid.MaxHealth
	local any_LoadAnimation_result1 = Humanoid:LoadAnimation(Ultimate_upvr.Animation)
	any_LoadAnimation_result1:Play(0)
	var3_upvw.changeFov(arg1, 60, 1, 3)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Spin"):Once(function() -- Line 47
		--[[ Upvalues[5]:
			[1]: arg1 (readonly)
			[2]: var3_upvw (copied, read and write)
			[3]: Ultimate_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: Folder_upvr (readonly)
		]]
		local var10_upvw
		if arg1:FindFirstChild("HotPan") then
			var10_upvw = "Burnt Turkey"
		end
		local const_number_upvw = 0
		task.spawn(function() -- Line 56
			--[[ Upvalues[4]:
				[1]: var3_upvw (copied, read and write)
				[2]: Ultimate_upvr (copied, readonly)
				[3]: HumanoidRootPart_upvr (copied, readonly)
				[4]: const_number_upvw (read and write)
			]]
			repeat
				wait(0.2)
				local any_applySound_result1 = var3_upvw.applySound(Ultimate_upvr.SpinSFX, HumanoidRootPart_upvr, 4)
				any_applySound_result1.PlaybackSpeed += math.random(-1, 1) * 0.1
				local any_applySound_result1_2 = var3_upvw.applySound(Ultimate_upvr.ThrowSFX, HumanoidRootPart_upvr, 4)
				any_applySound_result1_2.PlaybackSpeed += math.random(-1, 1) * 0.1
			until 35 <= const_number_upvw
		end)
		repeat
			wait(0.03)
			var3_upvw.camShake(arg1, "SmallBump")
			var3_upvw.changeFov(arg1, 100, 0, 0.5)
			local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position + Vector3.new(0, 5, 0), Vector3.new(math.random(-320, 320), -100, math.random(-320, 320)), var3_upvw.raycastParams)
			local var16
			if workspace_Raycast_result1 then
				var16 += 1
				local clone_upvr = Ultimate_upvr.Hitbox:Clone()
				clone_upvr.Parent = Folder_upvr
				clone_upvr.CFrame = CFrame.new(workspace_Raycast_result1.Position) * clone_upvr.CFrame - clone_upvr.CFrame.Position
				var3_upvw.applyDebris(clone_upvr, 20)
				local tbl = {
					Replication = var10_upvw;
				}
				tbl.Character = arg1
				tbl.Hitbox = clone_upvr
				var3_upvw.Replication("All", "Chef", tbl)
				task.spawn(function() -- Line 80
					--[[ Upvalues[4]:
						[1]: clone_upvr (readonly)
						[2]: var3_upvw (copied, read and write)
						[3]: var10_upvw (read and write)
						[4]: Ultimate_upvr (copied, readonly)
					]]
					-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
					wait(0.35)
					-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
					-- KONSTANTERROR: [67] 50. Error Block 8 start (CF ANALYSIS FAILED)
					wait(0.2)
					-- KONSTANTERROR: [67] 50. Error Block 8 end (CF ANALYSIS FAILED)
					-- KONSTANTERROR: [4] 4. Error Block 2 start (CF ANALYSIS FAILED)
					-- KONSTANTERROR: [4] 4. Error Block 2 end (CF ANALYSIS FAILED)
				end)
			end
			clone_upvr = 35
		until clone_upvr <= var16
	end), 3)
end
return module