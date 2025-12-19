-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:47
-- Luau version 6, Types version 3
-- Time taken: 0.012501 seconds

local module_upvr = {
	Cooldown = 20;
	GlobalCD = 1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[5]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: module_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: RunService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, 20)
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Earthly_Impact_upvr = ReplicatedStorage_upvr.Skills["Earth Hammer"]["Earthly Impact"]
	local any_LoadAnimation_result1_upvr = Humanoid_upvr.Animator:LoadAnimation(Earthly_Impact_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play(0.4)
	local clone_upvr = Earthly_Impact_upvr.Part.sounds:Clone()
	clone_upvr.Parent = arg1.Torso
	var2_upvw.applyDebris(clone_upvr, 12)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 38
		--[[ Upvalues[1]:
			[1]: clone_upvr (readonly)
		]]
		if clone_upvr:FindFirstChild(arg1_2) then
			for _, v in clone_upvr:GetChildren() do
				if v.Name == arg1_2 then
					v:Play()
				end
			end
			return
		end
	end), module_upvr.Cooldown)
	var2_upvw.applyStatus(arg1, "Freeze", 1)
	var2_upvw.applyStatus(arg1, "AutoRotate", 1)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Earth_Hammer_upvr = arg1:FindFirstChild("Earth Hammer")
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("stomp"):Connect(function() -- Line 53
		--[[ Upvalues[13]:
			[1]: clone_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: arg1 (readonly)
			[5]: TweenService_upvr (copied, readonly)
			[6]: module_upvr (copied, readonly)
			[7]: Earthly_Impact_upvr (readonly)
			[8]: Folder_upvr (readonly)
			[9]: any_LoadAnimation_result1_upvr (readonly)
			[10]: Humanoid_upvr (readonly)
			[11]: Earth_Hammer_upvr (readonly)
			[12]: ReplicatedStorage_upvr (copied, readonly)
			[13]: RunService_upvr (copied, readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 20 start (CF ANALYSIS FAILED)
		clone_upvr.rocksfx:Play()
		var2_upvw.crater(1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 6, 2.5, 0.1)
		var2_upvw.CreateDebris(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 6, 5, 1, 0.7, 0.2)
		var2_upvw.camShake(arg1, "SmallBump")
		var2_upvw.changeFov(arg1, 52, 0.01, 0.5)
		var2_upvw.Blur(arg1, 20, 0.5)
		local function destroyWall_upvr(arg1_3) -- Line 62, Named "destroyWall"
			--[[ Upvalues[3]:
				[1]: TweenService_upvr (copied, readonly)
				[2]: var2_upvw (copied, read and write)
				[3]: module_upvr (copied, readonly)
			]]
			if arg1_3:FindFirstChild("welds") then
				arg1_3.welds:Destroy()
				arg1_3.CanCollide = false
				for _, v_2_upvr in arg1_3:GetChildren() do
					if v_2_upvr:IsA("BasePart") then
						v_2_upvr.CollisionGroup = "noCollision"
						v_2_upvr.CanCollide = true
						v_2_upvr.RotVelocity = Vector3.new(math.random(-25, 25), math.random(-25, 25), math.random(-25, 25))
						task.delay(5, function() -- Line 72
							--[[ Upvalues[4]:
								[1]: TweenService_upvr (copied, readonly)
								[2]: v_2_upvr (readonly)
								[3]: var2_upvw (copied, read and write)
								[4]: module_upvr (copied, readonly)
							]]
							local any_Create_result1 = TweenService_upvr:Create(v_2_upvr, TweenInfo.new(math.random(1, 3)), {
								Size = Vector3.new(0, 0, 0);
							})
							any_Create_result1:Play()
							var2_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 76
								--[[ Upvalues[1]:
									[1]: v_2_upvr (copied, readonly)
								]]
								v_2_upvr:Destroy()
							end), module_upvr.Cooldown + 5)
						end)
					end
				end
			end
		end
		local var36 = HumanoidRootPart_upvr
		local any_findEnemiesMagnitude_result1 = var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + var36.CFrame.LookVector * 6, 6, true)
		if 0 < #any_findEnemiesMagnitude_result1 then
			var36 = HumanoidRootPart_upvr
			local var31 = HumanoidRootPart_upvr.Position + var36.CFrame.LookVector * 42
			var36 = HumanoidRootPart_upvr.CFrame.LookVector
			var36 = var2_upvw.raycastParams
			local workspace_Raycast_result1_2 = workspace:Raycast(HumanoidRootPart_upvr.Position, var36 * 42, var36)
			if workspace_Raycast_result1_2 then
				var31 = workspace_Raycast_result1_2.Position
			end
			var36 = Vector3.new(0, -10, 0)
			local workspace_Raycast_result1 = workspace:Raycast(var31, var36, var2_upvw.raycastParams)
			if workspace_Raycast_result1 then
				local clone_upvw = Earthly_Impact_upvr.EarthWall:Clone()
				clone_upvw.Parent = Folder_upvr
				var36 = CFrame.new(workspace_Raycast_result1.Position + Vector3.new(0, -(clone_upvw.Size.Y / 2), 0))
				var36 = HumanoidRootPart_upvr.CFrame.p
				clone_upvw.CFrame = var36 * HumanoidRootPart_upvr.CFrame - var36
				clone_upvw.RockLift:Play()
				var36 = 6
				var2_upvw.CreateDebris(workspace_Raycast_result1.Position, var36, 1, 1.5, 0.1)
				var36 = clone_upvw
				TweenService_upvr:Create(var36, TweenInfo.new(0.25), {
					CFrame = CFrame.new(workspace_Raycast_result1.Position + Vector3.new(0, clone_upvw.Size.Y / 2.4)) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p;
				}):Play()
				function var36() -- Line 104
					--[[ Upvalues[2]:
						[1]: destroyWall_upvr (readonly)
						[2]: clone_upvw (read and write)
					]]
					destroyWall_upvr(clone_upvw)
				end
				task.delay(5, var36)
			end
		end
		local _ = {}
		-- KONSTANTERROR: [0] 1. Error Block 20 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [514] 383. Error Block 10 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [514] 383. Error Block 10 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [238] 177. Error Block 17 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: Expression was reused, decompilation is incorrect
		if TweenInfo.new(0.25) then
		end
		-- KONSTANTERROR: [238] 177. Error Block 17 end (CF ANALYSIS FAILED)
	end), module_upvr.Cooldown)
end
return module_upvr