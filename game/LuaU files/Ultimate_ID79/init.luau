-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:07
-- Luau version 6, Types version 3
-- Time taken: 0.006976 seconds

local module_upvr = {
	GlobalCD = 3.5;
	ModeLength = 70;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: module_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 20)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid = arg1:FindFirstChild("Humanoid")
	local Ultimate = ReplicatedStorage_upvr.Skills["Titans Edge"].Ultimate
	Humanoid.Animator:LoadAnimation(Ultimate.Animation):Play()
	var2_upvw.applyStatus(arg1, "Freeze", 4.5)
	var2_upvw.applyStatus(arg1, "GlobalCD", 4.5)
	var2_upvw.applyStatus(arg1, "AutoRotate", 4.5)
	var2_upvw.applyStatus(arg1, "IFrames", 4.5)
	var2_upvw.applyStatus(arg1, "Ultimate", 4.5)
	var2_upvw.applyStatus(arg1, "LockUltimateMeter", module_upvr.ModeLength)
	Humanoid.Health = Humanoid.MaxHealth
	local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
	BodyVelocity.MaxForce = Vector3.new(1000000, 0, 1000000)
	BodyVelocity.Velocity = HumanoidRootPart.CFrame.LookVector * 5
	var2_upvw.applyDebris(BodyVelocity, 4)
	local clone_upvr = Ultimate.ThemeSong:Clone()
	clone_upvr.Parent = HumanoidRootPart
	clone_upvr:Play()
	clone_upvr.Volume += 1
	clone_upvr:SetAttribute("ogVolume", clone_upvr.Volume - 1)
	task.delay(module_upvr.ModeLength, function() -- Line 61
		--[[ Upvalues[2]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: clone_upvr (readonly)
		]]
		TweenService_upvr:Create(clone_upvr, TweenInfo.new(1), {
			Volume = 0;
		}):Play()
	end)
	local var13_upvw = false
	task.delay(4.5, function() -- Line 67
		--[[ Upvalues[3]:
			[1]: var13_upvw (read and write)
			[2]: TweenService_upvr (copied, readonly)
			[3]: clone_upvr (readonly)
		]]
		var13_upvw = true
		TweenService_upvr:Create(clone_upvr, TweenInfo.new(2), {
			Volume = clone_upvr.Volume - 1;
		}):Play()
	end)
	local function pulse() -- Line 74
		--[[ Upvalues[2]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
		]]
		var2_upvw.camShake(arg1, "SmallBump")
		var2_upvw.changeFov(arg1, 60, 0.01, 0.25)
		var2_upvw.flashScreen(arg1, Color3.new(0, 0, 0), 0.2)
	end
	pulse()
	while task.wait(0.7) and not var13_upvw do
		pulse()
	end
end
return module_upvr