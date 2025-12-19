-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:36
-- Luau version 6, Types version 3
-- Time taken: 0.017152 seconds

local module_upvr = {
	Cooldown = 15;
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
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid = arg1:FindFirstChild("Humanoid")
	local Fiery_Leap = ReplicatedStorage_upvr.Skills.Greatsword["Fiery Leap"]
	local Greatsword_upvr = arg1:FindFirstChild("Greatsword")
	local any_LoadAnimation_result1 = Humanoid.Animator:LoadAnimation(Fiery_Leap.Animation)
	any_LoadAnimation_result1:Play()
	local clone_4 = Fiery_Leap.Part.Sounds:Clone()
	clone_4.Parent = arg1.Torso
	game.Debris:AddItem(clone_4, 20)
	clone_4.BodyPrepare:Play()
	clone_4.Whoosh:Play()
	clone_4.slash:Play()
	clone_4.wind:Play()
	clone_4.wind.Volume = 0
	clone_4.shockwave:Play()
	TweenService_upvr:Create(clone_4.wind, TweenInfo.new(0.4), {
		Volume = 7;
	}):Play()
	local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -3.2000, 0), var2_upvw.raycastParams)
	local var37
	if workspace_Raycast_result1 then
		clone_4.Rocks:Play()
		var2_upvw.CreateDebris(workspace_Raycast_result1.Position, 5, 1, 0.8, 0.1)
		var2_upvw.crater(1, workspace_Raycast_result1.Position, 3, 0.4)
	end
	var2_upvw.applyStatus(arg1, "AutoRotate", 1)
	var2_upvw.applyStatus(arg1, "Slowed", 1)
	var2_upvw.applyStatus(arg1, "IFrames", 1)
	task.wait(0.35)
	if workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -2, 0), var2_upvw.raycastParams) then
		any_LoadAnimation_result1:Stop()
		clone_4.wind:Stop()
	else
		for _, v in Greatsword_upvr.FireVfx:GetChildren() do
			v.Enabled = true
		end
		var2_upvw.changeFov(arg1, 100, 2, 15)
		local var34_upvw
		local var35_upvw = true
		var37 = ReplicatedStorage_upvr.Remotes
		function var37(arg1_2, arg2_2, arg3) -- Line 81
			--[[ Upvalues[3]:
				[1]: arg2 (readonly)
				[2]: var35_upvw (read and write)
				[3]: var34_upvw (read and write)
			]]
			if arg2 ~= arg1_2 or arg2_2 ~= "Fiery Leap" then
			else
				var35_upvw = false
				var34_upvw = arg3.ExplosionPosition
			end
		end
		var37 = module_upvr
		var2_upvw.conTimer(var37.ClientInfo.OnServerEvent:Connect(var37), var37.Cooldown)
		repeat
			task.wait(0.05)
			var37 = 0.5
			var2_upvw.applyStatus(arg1, "AutoRotate", var37)
			var37 = 0.5
			var2_upvw.applyStatus(arg1, "Freeze", var37)
			var37 = 0.15
			var2_upvw.applyStatus(arg1, "IFrames", var37)
			var37 = 0.5
			var2_upvw.applyStatus(arg1, "GlobalCD", var37)
		until var35_upvw == false
		any_LoadAnimation_result1:Stop()
		clone_4.wind:Stop()
		if var35_upvw ~= false then return end
		Humanoid.Animator:LoadAnimation(Fiery_Leap.Animation2):Play()
		var37 = Color3.new(1, 0.717647, 0.556863)
		var2_upvw.flashScreen(arg1, var37, 1.6)
		function var37() -- Line 107
			--[[ Upvalues[1]:
				[1]: Greatsword_upvr (readonly)
			]]
			for _, v_2 in Greatsword_upvr.FireVfx:GetChildren() do
				v_2.Enabled = false
			end
		end
		task.delay(1, var37)
		var37 = "GlobalCD"
		var2_upvw.applyStatus(arg1, var37, 1.1)
		var37 = "Freeze"
		var2_upvw.applyStatus(arg1, var37, 1.2)
		var37 = "AutoRotate"
		var2_upvw.applyStatus(arg1, var37, 1.1)
		var37 = "IFrames"
		var2_upvw.applyStatus(arg1, var37, 0.15)
		var37 = var34_upvw
		var2_upvw.crater(1, var37, 4, 1)
		var37 = 10
		var2_upvw.CreateDebris(var34_upvw, var37, 1, 1, 0.1)
		var37 = "Explosion"
		var2_upvw.camShake(arg1, var37)
		local clone_2 = Fiery_Leap.Hitbox:Clone()
		clone_2.Parent = Folder
		var37 = Vector3.new(0, clone_2.Size.Y / 2 - 2, 0)
		clone_2.Position = var34_upvw + var37
		var37 = game
		var37.Debris:AddItem(clone_2, 10)
		local clone_3_upvr = Fiery_Leap["Fire Explosion"]:Clone()
		clone_3_upvr.Parent = Folder
		clone_3_upvr.Position = var34_upvw
		var37 = var2_upvw.EmitAllDescendants
		var37(clone_3_upvr)
		var37 = game.Debris:AddItem
		var37(clone_3_upvr, 10)
		var37 = clone_3_upvr:GetChildren()
		local children, NONE_4, NONE = clone_3_upvr:GetChildren()
		for _, v_3 in children, NONE_4, NONE do
			if v_3:IsA("Sound") then
				v_3:Play()
			end
		end
		children = TweenService_upvr
		local _ = {
			Volume = 0;
		}
		children = children:Create(clone_3_upvr.FireExplosion2, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), _):Play
		children()
		children = TweenService_upvr
		local _ = {
			Color3 = Color3.new(0.0156863, 0.00784314, 0.00392157);
		}
		children = children:Create(clone_3_upvr.Texture, TweenInfo.new(2.5), _):Play
		children()
		children = TweenService_upvr
		local _ = {
			Brightness = 0;
		}
		children = children:Create(clone_3_upvr.Attachment.PointLight, TweenInfo.new(2.5), _):Play
		children()
		children = task.delay
		children(5, function() -- Line 143
			--[[ Upvalues[2]:
				[1]: TweenService_upvr (copied, readonly)
				[2]: clone_3_upvr (readonly)
			]]
			TweenService_upvr:Create(clone_3_upvr.Texture, TweenInfo.new(2.5), {
				Transparency = 1;
			}):Play()
		end)
		children = var2_upvw.impactFrame2
		children(arg1)
		children = var2_upvw.changeFov
		children(arg1, 70, 0.01, 3)
		children = false
		for i_4, v_4 in var2_upvw.findEnemiesPart(clone_2, true), nil do
			var2_upvw.applyStatus(v_4, "Ragdoll", 2.4)
			var2_upvw.Knockback(v_4, HumanoidRootPart.Position, 15, 70)
			var2_upvw.applyDamage(v_4, 15)
			if v_4.Humanoid.Health <= 1 then
				for _, v_5 in v_4:GetDescendants() do
					if v_5:IsA("Shirt") or v_5:IsA("Pants") then
						v_5:Destroy()
					elseif v_5:IsA("BasePart") then
						v_5.Material = "Neon"
						v_5.Color = Color3.new(1, 0.768627, 0.364706)
						TweenService_upvr:Create(v_5, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
							Color = Color3.new(0, 0, 0);
						}):Play()
						if not v_5:FindFirstChild("burnVfx") and v_5.Name == "Torso" or v_5.Name == "Left Arm" or v_5.Name == "Right Arm" or v_5.Name == "Head" or v_5.Name == "Left Leg" or v_5.Name == "Right Leg" then
							local clone_5 = Fiery_Leap.burnVfx:Clone()
							clone_5.Parent = v_5
							clone_5.Enabled = true
							local clone = Fiery_Leap.burnSfx:Clone()
							clone.Parent = v_5
							clone:Play()
						end
					end
				end
			end
			children = true
		end
		if children then
			i_4 = 2
			var2_upvw.applyStatus(arg1, "CombatStun", i_4)
		end
	end
end
return module_upvr