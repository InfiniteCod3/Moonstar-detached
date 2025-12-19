-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:33
-- Luau version 6, Types version 3
-- Time taken: 0.021684 seconds

local module_upvr = {
	Cooldown = 16;
	GlobalCD = 1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Ground_Demolition_upvr = ReplicatedStorage_upvr.Skills.Greatsword.Ultimate["Ground Demolition"]
	local any_LoadAnimation_result1 = Humanoid_upvr.Animator:LoadAnimation(Ground_Demolition_upvr.Animation)
	any_LoadAnimation_result1:Play(0.00001)
	local clone_2 = Ground_Demolition_upvr.Part.Sounds:Clone()
	clone_2.Parent = arg1.Torso
	game.Debris:AddItem(clone_2, 20)
	clone_2.BodyPrepare:Play()
	clone_2.Whoosh:Play()
	clone_2.slash:Play()
	clone_2.wind:Play()
	clone_2.wind.Volume = 0
	clone_2.shockwave:Play()
	TweenService_upvr:Create(clone_2.wind, TweenInfo.new(0.4), {
		Volume = 7;
	}):Play()
	local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position, Vector3.new(0, -3.2000, 0), var2_upvw.raycastParams)
	local var17
	if workspace_Raycast_result1 then
		clone_2.Rocks:Play()
		var17 = 1
		var2_upvw.CreateDebris(workspace_Raycast_result1.Position, 5, var17, 0.8, 0.1)
		var17 = 3
		var2_upvw.crater(1, workspace_Raycast_result1.Position, var17, 0.4)
	end
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
	var17 = HumanoidRootPart_upvr.CFrame.LookVector * 1
	BodyVelocity.Velocity = Vector3.new(0, 30, 0) + var17
	var17 = "AutoRotate"
	var2_upvw.applyStatus(arg1, var17, 0.5)
	var17 = "Freeze"
	var2_upvw.applyStatus(arg1, var17, 0.5)
	var17 = "IFrames"
	var2_upvw.applyStatus(arg1, var17, 0.5)
	var17 = "GlobalCD"
	var2_upvw.applyStatus(arg1, var17, 0.5)
	var17 = BodyVelocity
	var2_upvw.applyVelocity(HumanoidRootPart_upvr, var17, 0.2)
	task.wait(0.4)
	var17 = 100
	var2_upvw.changeFov(arg1, var17, 2, 15)
	var17 = true
	repeat
		task.wait(0.05)
		var2_upvw.applyStatus(arg1, "AutoRotate", 0.5)
		var2_upvw.applyStatus(arg1, "Freeze", 0.5)
		var2_upvw.applyStatus(arg1, "IFrames", 0.15)
		var2_upvw.applyStatus(arg1, "GlobalCD", 0.5)
		local workspace_Raycast_result1_2 = workspace:Raycast(HumanoidRootPart_upvr.Position, Vector3.new(0, -3 + HumanoidRootPart_upvr.Velocity.Y * 0.24, 0), var2_upvw.raycastParams)
		if workspace_Raycast_result1_2 and workspace_Raycast_result1_2.Position.Y < HumanoidRootPart_upvr.Position.Y then
			var17 = false
			local var20
		end
		if var17 == true then
			if HumanoidRootPart_upvr.Velocity.Y == 0 then
				var20 += 1
			end
			if var20 == 3 then break end
		end
	until var17 == false
	any_LoadAnimation_result1:Stop()
	clone_2.wind:Stop()
	if var17 ~= false then
	else
		local Position_upvw = workspace_Raycast_result1_2.Position
		for i_4 = 1, 3 do
			(function(arg1_2) -- Line 104, Named "explosion"
				--[[ Upvalues[8]:
					[1]: Humanoid_upvr (readonly)
					[2]: Ground_Demolition_upvr (readonly)
					[3]: var2_upvw (copied, read and write)
					[4]: arg1 (readonly)
					[5]: Position_upvw (read and write)
					[6]: Folder_upvr (readonly)
					[7]: TweenService_upvr (copied, readonly)
					[8]: HumanoidRootPart_upvr (readonly)
				]]
				Humanoid_upvr.Animator:LoadAnimation(Ground_Demolition_upvr.Animation2):Play(0.001)
				var2_upvw.flashScreen(arg1, Color3.new(0.521569, 1, 0.984314), 1.6)
				var2_upvw.applyStatus(arg1, "GlobalCD", 1.1)
				var2_upvw.applyStatus(arg1, "Freeze", 1.2)
				var2_upvw.applyStatus(arg1, "AutoRotate", 1.1)
				var2_upvw.applyStatus(arg1, "IFrames", 0.55)
				var2_upvw.crater(1, Position_upvw, 4 * arg1_2, 1 * arg1_2)
				var2_upvw.CreateDebris(Position_upvw, 12, 0.8 * arg1_2, 0.6 * arg1_2, 0.1)
				var2_upvw.camShake(arg1, "Explosion")
				local clone_4 = Ground_Demolition_upvr:FindFirstChild("Hitbox"..arg1_2):Clone()
				clone_4.Parent = Folder_upvr
				clone_4.Position = Position_upvw + Vector3.new(0, clone_4.Size.Y / 2 - 2, 0)
				game.Debris:AddItem(clone_4, 10)
				local clone_upvr = Ground_Demolition_upvr:FindFirstChild("Fire Explosion"..arg1_2):Clone()
				clone_upvr.Parent = Folder_upvr
				clone_upvr.Position = Position_upvw
				var2_upvw.EmitAllDescendants(clone_upvr)
				game.Debris:AddItem(clone_upvr, 10)
				for _, v in clone_upvr:GetChildren() do
					if v:IsA("Sound") then
						v:Play()
					end
				end
				TweenService_upvr:Create(clone_upvr.FireExplosion2, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Volume = 0;
				}):Play()
				TweenService_upvr:Create(clone_upvr.Texture, TweenInfo.new(2.5), {
					Color3 = Color3.new(0.0156863, 0.00784314, 0.00392157);
				}):Play()
				TweenService_upvr:Create(clone_upvr.Attachment.PointLight, TweenInfo.new(2.5), {
					Brightness = 0;
				}):Play()
				task.delay(5, function() -- Line 141
					--[[ Upvalues[2]:
						[1]: TweenService_upvr (copied, readonly)
						[2]: clone_upvr (readonly)
					]]
					TweenService_upvr:Create(clone_upvr.Texture, TweenInfo.new(2.5), {
						Transparency = 1;
					}):Play()
				end)
				var2_upvw.impactFrame2(arg1)
				var2_upvw.changeFov(arg1, 70, 0.01, 3)
				for _, v_2 in var2_upvw.findEnemiesPart(clone_4, true), nil do
					var2_upvw.applyStatus(v_2, "Ragdoll", 2.2)
					var2_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position, 15, 70)
					var2_upvw.applyDamage(v_2, 15)
					if v_2.Humanoid.Health <= 1 then
						for _, v_3 in v_2:GetDescendants() do
							if v_3:IsA("Shirt") or v_3:IsA("Pants") then
								v_3:Destroy()
							elseif v_3:IsA("BasePart") then
								v_3.Material = "Neon"
								v_3.Color = Color3.new(1, 0.768627, 0.364706)
								TweenService_upvr:Create(v_3, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
									Color = Color3.new(0, 0, 0);
								}):Play()
								if not v_3:FindFirstChild("burnVfx") and v_3.Name == "Torso" or v_3.Name == "Left Arm" or v_3.Name == "Right Arm" or v_3.Name == "Head" or v_3.Name == "Left Leg" or v_3.Name == "Right Leg" then
									local clone = Ground_Demolition_upvr.burnVfx:Clone()
									clone.Parent = v_3
									clone.Enabled = true
									local clone_3 = Ground_Demolition_upvr.burnSfx:Clone()
									clone_3.Parent = v_3
									clone_3:Play()
								end
							end
						end
					end
				end
			end)(i_4)
			task.wait(0.5)
			local _
		end
	end
end
return module_upvr