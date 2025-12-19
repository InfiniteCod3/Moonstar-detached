-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:12:48
-- Luau version 6, Types version 3
-- Time taken: 0.047128 seconds

local module = {
	GlobalCD = 8.25;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: TweenService_upvr (readonly)
		[4]: RunService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, 13.25)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Ultimate_upvr = ReplicatedStorage_upvr.Skills["Basic Staff"].Ultimate
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Ultimate_upvr.Animation)
	any_LoadAnimation_result1:Play()
	var2_upvw.applyStatus(arg1, "Freeze", 8.75)
	var2_upvw.applyStatus(arg1, "AutoRotate", 8.75)
	var2_upvw.applyStatus(arg1, "IFrames", 8.75)
	local clone_upvr_5 = Ultimate_upvr.Theme:Clone()
	clone_upvr_5.Parent = HumanoidRootPart_upvr
	clone_upvr_5:Play()
	clone_upvr_5.Volume = 0
	TweenService_upvr:Create(clone_upvr_5, TweenInfo.new(0.75), {
		Volume = 3.4;
	}):Play()
	game.Debris:AddItem(clone_upvr_5, 8.25)
	task.wait(0.2)
	arg1:FindFirstChild("Basic Staff").Spin:Play()
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("strike"):Connect(function() -- Line 43
		--[[ Upvalues[9]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Ultimate_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: TweenService_upvr (copied, readonly)
			[7]: ReplicatedStorage_upvr (copied, readonly)
			[8]: RunService_upvr (copied, readonly)
			[9]: clone_upvr_5 (readonly)
		]]
		-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
		var2_upvw.impactFrame(arg1)
		local clone_upvr = Ultimate_upvr.Shockwave:Clone()
		clone_upvr.Parent = Folder_upvr
		clone_upvr.CFrame = HumanoidRootPart_upvr.CFrame - Vector3.new(0, 3, 0)
		var2_upvw.EmitAllDescendants(clone_upvr.vfx)
		for _, v in clone_upvr:GetChildren() do
			if v:IsA("Sound") then
				v:Play()
			end
		end
		TweenService_upvr:Create(clone_upvr, TweenInfo.new(2), {
			Size = clone_upvr.Size + Vector3.new(300, -clone_upvr.Size.Y + 1, 300);
		}):Play()
		local clone_3_upvr = ReplicatedStorage_upvr.CutsceneCamera:Clone()
		clone_3_upvr.Parent = arg1
		clone_3_upvr.Anchored = true
		game.Debris:AddItem(clone_3_upvr, 8.25)
		clone_3_upvr.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * -4 + Vector3.new(0, 4, 0)
		clone_3_upvr.CFrame = CFrame.lookAt(clone_3_upvr.Position, clone_upvr.Position)
		local var106_upvw = 1
		task.delay(2, function() -- Line 63
			--[[ Upvalues[3]:
				[1]: TweenService_upvr (copied, readonly)
				[2]: clone_upvr (readonly)
				[3]: var106_upvw (read and write)
			]]
			TweenService_upvr:Create(clone_upvr, TweenInfo.new(1), {
				Transparency = 1;
			}):Play()
			var106_upvw = 2
		end)
		local var110_upvw
		var110_upvw = var2_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 69
			--[[ Upvalues[5]:
				[1]: clone_3_upvr (readonly)
				[2]: var110_upvw (read and write)
				[3]: var106_upvw (read and write)
				[4]: HumanoidRootPart_upvr (copied, readonly)
				[5]: clone_upvr (readonly)
			]]
			if not clone_3_upvr.Parent then
				var110_upvw:Disconnect()
			end
			if var106_upvw == 1 then
				clone_3_upvr.CFrame = clone_3_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * -1.2 + Vector3.new(0, 0.30000, 0)
				clone_3_upvr.CFrame = CFrame.lookAt(clone_3_upvr.Position, clone_upvr.Position)
			elseif var106_upvw == 2 then
				clone_3_upvr.CFrame = clone_3_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * -0.25 + Vector3.new(0, 0.10000, 0)
				clone_3_upvr.CFrame = CFrame.lookAt(clone_3_upvr.Position, clone_upvr.Position)
			end
		end), 30)
		game.Debris:AddItem(clone_upvr, 4)
		task.wait(2)
		local clone_4 = Ultimate_upvr.SpawnParts:Clone()
		clone_4.Parent = Folder_upvr
		clone_4.CFrame = HumanoidRootPart_upvr.CFrame
		var2_upvw.impactFrame(arg1)
		var2_upvw.changeFov(arg1, 110, 0.01, 0.2)
		for i_2 = 1, #clone_4:GetChildren() do
			if clone_4:FindFirstChild(i_2) then
				local workspace_Raycast_result1_2 = workspace:Raycast(clone_4[tostring(i_2)].Position, Vector3.new(0, -300, 0), var2_upvw.raycastParams)
				if workspace_Raycast_result1_2 then
					local Position_upvr_2 = workspace_Raycast_result1_2.Position
					local clone_upvr_4 = Ultimate_upvr.UltBall:Clone()
					clone_upvr_4.Parent = Folder_upvr
					clone_upvr_4.CFrame = CFrame.new(Position_upvr_2 - Vector3.new(0, 40, 0)) * clone_upvr_4.CFrame - clone_upvr_4.CFrame.p
					clone_upvr_4.GroundPart.Position = Position_upvr_2
					clone_upvr_4.Spawn:Play()
					clone_upvr_4.Explode:Play()
					local Spawn = clone_upvr_4.Spawn
					Spawn.PlaybackSpeed += math.random(-1, 1) * 0.1
					local Explode = clone_upvr_4.Explode
					Explode.PlaybackSpeed += math.random(-1, 1) * 0.1
					var2_upvw.CreateDebris(Position_upvr_2, 8, 2.5, 4, 0.05)
					var2_upvw.crater(1, Position_upvr_2, 9, 3)
					var2_upvw.changeFov(arg1, 90, 0.01, 0.03)
					TweenService_upvr:Create(clone_upvr_4.GroundPart, TweenInfo.new(0.8), {
						Size = Vector3.new(150, 0, 150);
						Transparency = 1;
					}):Play()
					TweenService_upvr:Create(clone_upvr_4, TweenInfo.new(1.25), {
						CFrame = clone_upvr_4.CFrame * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180))) + Vector3.new(0, 270 + i_2 * 5, 0);
					}):Play()
					delay(1, function() -- Line 114
						--[[ Upvalues[6]:
							[1]: TweenService_upvr (copied, readonly)
							[2]: clone_upvr_4 (readonly)
							[3]: Position_upvr_2 (readonly)
							[4]: var2_upvw (copied, read and write)
							[5]: arg1 (copied, readonly)
							[6]: clone_upvr_5 (copied, readonly)
						]]
						TweenService_upvr:Create(clone_upvr_4.Beam, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
							TextureSpeed = -1.25;
						}):Play()
						task.wait(0.5)
						TweenService_upvr:Create(clone_upvr_4, TweenInfo.new(1.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
							CFrame = CFrame.new(Position_upvr_2 - Vector3.new(0, 30, 0)) * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)));
						}):Play()
						clone_upvr_4.Whoosh:Play()
						task.wait(1)
						clone_upvr_4.Explode2:Play()
						local Explode2_2 = clone_upvr_4.Explode2
						Explode2_2.PlaybackSpeed += math.random(-2, 2) * 0.1
						var2_upvw.changeFov(arg1, 95, 0.01, 0.03)
						var2_upvw.CreateDebris(Position_upvr_2, 15, 3.5, 8, 0.04)
						var2_upvw.crater(1, Position_upvr_2, 14, 3.65)
						var2_upvw.findEnemiesMagnitude(Position_upvr_2, 200)
						for _, v_2 in var2_upvw.FoundEnemies do
							var2_upvw.camShake(v_2, "Explosion")
						end
						for _, v_3 in var2_upvw.findEnemiesMagnitude(Position_upvr_2, 85, true), nil do
							var2_upvw.applyDamage(v_3, 50)
							var2_upvw.Knockback(v_3, Position_upvr_2, 50, 180)
							var2_upvw.applyStatus(v_3, "Stunned", 1)
							var2_upvw.applyStatus(v_3, "Ragdoll", 3.1)
						end
						task.wait(0.1)
						clone_upvr_4.Beam.Enabled = false
						TweenService_upvr:Create(clone_upvr_4, TweenInfo.new(3, Enum.EasingStyle.Linear), {
							CFrame = clone_upvr_4.CFrame - Vector3.new(0, 15, 0);
						}):Play()
						task.wait(1)
						TweenService_upvr:Create(clone_upvr_5, TweenInfo.new(5), {
							Volume = 0;
						}):Play()
					end)
					clone_upvr_5.Volume = 10
					TweenService_upvr:Create(clone_upvr_5, TweenInfo.new(2), {
						Volume = 3.4;
					}):Play()
					var2_upvw.findEnemiesMagnitude(Position_upvr_2, 185)
					for _, v_4 in var2_upvw.FoundEnemies do
						var2_upvw.camShake(v_4, "Explosion")
					end
					for _, v_5 in var2_upvw.findEnemiesMagnitude(Position_upvr_2, 55, true), nil do
						var2_upvw.applyDamage(v_5, 40)
						var2_upvw.Knockback(v_5, Position_upvr_2, 25, 125)
						var2_upvw.applyStatus(v_5, "Stunned", 4)
						var2_upvw.applyStatus(v_5, "Ragdoll", 5)
						local _
					end
					wait()
				end
			end
		end
	end), 40)
end
return module