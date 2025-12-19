-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:52
-- Luau version 6, Types version 3
-- Time taken: 0.019340 seconds

local module = {
	GlobalCD = 5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, 20)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Force_Of_Music_upvr = ReplicatedStorage_upvr.Skills.Harp["Force Of Music"]
	local clone_upvr = Force_Of_Music_upvr.Theme:Clone()
	clone_upvr.Parent = HumanoidRootPart_upvr
	var2_upvw.applyDebris(clone_upvr, 20)
	clone_upvr:Play()
	delay(4, function() -- Line 31
		--[[ Upvalues[2]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: clone_upvr (readonly)
		]]
		TweenService_upvr:Create(clone_upvr, TweenInfo.new(2), {
			Volume = 0;
		}):Play()
	end)
	var2_upvw.applyStatus(arg1, "Freeze", 5)
	var2_upvw.applyStatus(arg1, "IFrames", 5)
	var2_upvw.applyStatus(arg1, "Ultimate", 7)
	task.wait(0.2)
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Force_Of_Music_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(1.5)
	local BodyVelocity_upvr = Instance.new("BodyVelocity", HumanoidRootPart_upvr)
	BodyVelocity_upvr.Velocity = Vector3.new(0, 30, 0)
	BodyVelocity_upvr.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	game.Debris:AddItem(BodyVelocity_upvr, 0.9)
	local clone_2_upvr = Force_Of_Music_upvr.Shockwave:Clone()
	clone_2_upvr.Parent = Folder_upvr
	clone_2_upvr.CFrame = HumanoidRootPart_upvr.CFrame
	var2_upvw.EmitAllDescendants(clone_2_upvr)
	var2_upvw.applyDebris(clone_2_upvr, 5)
	for _, v in clone_2_upvr:GetChildren() do
		if v:IsA("Sound") then
			v:Play()
		end
	end
	for _, v_2_upvr in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position, 100, true), nil do
		var2_upvw.unragdoll(v_2_upvr)
		task.delay(0.1, function() -- Line 65
			--[[ Upvalues[3]:
				[1]: var2_upvw (copied, read and write)
				[2]: v_2_upvr (readonly)
				[3]: clone_2_upvr (readonly)
			]]
			local BodyPosition = Instance.new("BodyPosition", v_2_upvr.Head)
			BodyPosition.MaxForce = Vector3.new(1000000, 1000000, 1000000)
			BodyPosition.Position = clone_2_upvr.Position
			var2_upvw.applyDebris(BodyPosition, 2.7)
		end)
	end
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("musicrain"):Connect(function() -- Line 78
		--[[ Upvalues[10]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
			[2]: BodyVelocity_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: Force_Of_Music_upvr (readonly)
			[5]: Folder_upvr (readonly)
			[6]: TweenService_upvr (copied, readonly)
			[7]: clone_2_upvr (readonly)
			[8]: var2_upvw (copied, read and write)
			[9]: arg1 (readonly)
			[10]: clone_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:AdjustSpeed(0.4)
		BodyVelocity_upvr:Destroy()
		local BodyPosition_2 = Instance.new("BodyPosition", HumanoidRootPart_upvr)
		BodyPosition_2.Position = HumanoidRootPart_upvr.Position + Vector3.new(0, 30, 0)
		BodyPosition_2.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		game.Debris:AddItem(BodyPosition_2, 4)
		coroutine.wrap(function() -- Line 86
			--[[ Upvalues[9]:
				[1]: Force_Of_Music_upvr (copied, readonly)
				[2]: Folder_upvr (copied, readonly)
				[3]: HumanoidRootPart_upvr (copied, readonly)
				[4]: TweenService_upvr (copied, readonly)
				[5]: clone_2_upvr (copied, readonly)
				[6]: var2_upvw (copied, read and write)
				[7]: arg1 (copied, readonly)
				[8]: any_LoadAnimation_result1_upvr (copied, readonly)
				[9]: clone_upvr (copied, readonly)
			]]
			for _ = 1, 23.999999999999996 do
				local clone_3_upvr = Force_Of_Music_upvr["Music Block"]:Clone()
				clone_3_upvr.Parent = Folder_upvr
				clone_3_upvr.CFrame = HumanoidRootPart_upvr.CFrame * CFrame.new(math.random(-10, 10), 5, 5)
				clone_3_upvr.Color = Color3.fromRGB(math.random(0, 200), math.random(0, 200), math.random(0, 200))
				local sfx = clone_3_upvr.sfx
				sfx.PlaybackSpeed += math.random(-2, 2) * 0.1
				clone_3_upvr.sfx:Play()
				TweenService_upvr:Create(clone_3_upvr, TweenInfo.new(4), {
					Color = Color3.fromRGB(math.random(0, 200), math.random(0, 200), math.random(0, 200));
				}):Play()
				game.Debris:AddItem(clone_3_upvr, 5)
				local any_Create_result1 = TweenService_upvr:Create(clone_3_upvr, TweenInfo.new((clone_3_upvr.Position - clone_2_upvr.Position).Magnitude * 0.005, Enum.EasingStyle.Linear), {
					CFrame = CFrame.new(clone_2_upvr.Position + Vector3.new(math.random(-10, 10) * 2, -3, math.random(-10, 10) * 2)) * CFrame.Angles(math.rad(math.random(-160, 160)), math.rad(math.random(-160, 160)), math.rad(math.random(-160, 160)));
				})
				any_Create_result1:Play()
				var2_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 104
					--[[ Upvalues[5]:
						[1]: var2_upvw (copied, read and write)
						[2]: arg1 (copied, readonly)
						[3]: clone_3_upvr (readonly)
						[4]: Force_Of_Music_upvr (copied, readonly)
						[5]: Folder_upvr (copied, readonly)
					]]
					var2_upvw.camShake(arg1, "Bump")
					clone_3_upvr.CollisionGroup = "noCollision"
					local groundhit = clone_3_upvr.groundhit
					groundhit.PlaybackSpeed += math.random(-2, 2) * 0.1
					clone_3_upvr.groundhit:Play()
					for _, v_3 in clone_3_upvr:GetChildren() do
						if v_3:IsA("ParticleEmitter") or v_3:IsA("Trail") then
							v_3.Enabled = true
						end
					end
					local clone_upvr_2 = Force_Of_Music_upvr.TimeBomb:Clone()
					clone_upvr_2.Parent = Folder_upvr
					clone_upvr_2.CFrame = clone_3_upvr.CFrame
					var2_upvw.applyDebris(clone_3_upvr, 1.1)
					var2_upvw.applyDebris(clone_upvr_2, 1.1)
					task.delay(1, function() -- Line 126
						--[[ Upvalues[4]:
							[1]: Force_Of_Music_upvr (copied, readonly)
							[2]: Folder_upvr (copied, readonly)
							[3]: clone_upvr_2 (readonly)
							[4]: var2_upvw (copied, read and write)
						]]
						local clone = Force_Of_Music_upvr.Explosion:Clone()
						clone.Parent = Folder_upvr
						clone.CFrame = clone_upvr_2.CFrame
						var2_upvw.EmitAllDescendants(clone)
						for _, v_4 in clone:GetDescendants() do
							if v_4:IsA("Sound") then
								v_4.PlaybackSpeed += math.random(-1, 1) * 0.1
								v_4:Play()
							end
						end
						var2_upvw.findEnemiesMagnitude(clone.Position, 24, true)
						for _, v_5 in var2_upvw.FoundEnemies do
							var2_upvw.CheckBlock(v_5, true)
							var2_upvw.camShake(v_5, "Bump")
							var2_upvw.applyDamage(v_5, 5)
						end
					end)
				end), 20)
				task.wait(0.14)
			end
			any_LoadAnimation_result1_upvr:Stop(0.65)
			clone_3_upvr = TweenInfo.new(8)
			TweenService_upvr:Create(clone_upvr, clone_3_upvr, {
				Volume = 0;
			}):Play()
		end)()
	end), 20)
end
return module