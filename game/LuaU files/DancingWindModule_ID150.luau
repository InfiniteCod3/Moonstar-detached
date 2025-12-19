-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:19:02
-- Luau version 6, Types version 3
-- Time taken: 0.007163 seconds

local module_upvr = {
	Cooldown = 30;
	GlobalCD = 1.35;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 12
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
	local Dancing_Wind_upvr = ReplicatedStorage_upvr.Skills["Wind Spear"]["Dancing Wind"]
	local Wind_Spear_upvr = arg1:FindFirstChild("Wind Spear")
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Dancing_Wind_upvr.Animation)
	any_LoadAnimation_result1:AdjustSpeed(0.95)
	task.wait()
	any_LoadAnimation_result1:Play()
	var2_upvw.applyStatus(arg1, "Freeze", 1.5)
	var2_upvw.resetm1s()
	Wind_Spear_upvr.Sounds.startSFX:Play()
	local var10_upvw = 0
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function() -- Line 36
		--[[ Upvalues[6]:
			[1]: var10_upvw (read and write)
			[2]: arg1 (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: Dancing_Wind_upvr (readonly)
			[5]: var2_upvw (copied, read and write)
			[6]: TweenService_upvr (copied, readonly)
		]]
		var10_upvw += 1
		local var16 = 32
		if var10_upvw == 2 then
			var16 = 5
		end
		local BodyVelocity = Instance.new("BodyVelocity", arg1.Torso)
		BodyVelocity.MaxForce = Vector3.new(1000000, 0, 1000000)
		BodyVelocity.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * var16
		game.Debris:AddItem(BodyVelocity, 0.4)
		task.wait()
		BodyVelocity.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * var16
		local clone_2 = Dancing_Wind_upvr["Dancing Wind"].WindSlash:Clone()
		clone_2.Parent = HumanoidRootPart_upvr
		game.Debris:AddItem(clone_2, 5)
		var2_upvw.EmitAllDescendants(clone_2)
		local windslashSFX = clone_2.windslashSFX
		windslashSFX.PlaybackSpeed += math.random(-1, 1) * 0.1
		clone_2.windslashSFX:Play()
		TweenService_upvr:Create(clone_2.windslashSFX, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Volume = 0;
		}):Play()
		local swingSFX = clone_2.swingSFX
		swingSFX.PlaybackSpeed += math.random(-1, 1) * 0.1
		clone_2.swingSFX:Play()
		var2_upvw.changeFov(arg1, var10_upvw * 5 + 80, 0.1, 1)
		for _, v in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position, 18), nil do
			var2_upvw.applyDamage(v, 6)
			var2_upvw.applyStatus(v, "Stunned", 1.25)
			var2_upvw.Knockback(v, HumanoidRootPart_upvr.Position, 3, 0)
			local clone = Dancing_Wind_upvr["Dancing Wind"].hitVFX:Clone()
			clone.Parent = v.HumanoidRootPart
			var2_upvw.EmitAllDescendants(clone)
			local hitSFX = clone.hitSFX
			hitSFX.PlaybackSpeed += math.random(-1, 1) * 0.1
			clone.hitSFX:Play()
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 85
		--[[ Upvalues[1]:
			[1]: Wind_Spear_upvr (readonly)
		]]
		if Wind_Spear_upvr.Sounds:FindFirstChild(arg1_2) then
			Wind_Spear_upvr.Sounds[arg1_2]:Play()
		end
	end), module_upvr.Cooldown)
end
return module_upvr