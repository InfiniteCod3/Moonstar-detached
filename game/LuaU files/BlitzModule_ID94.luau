-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:21
-- Luau version 6, Types version 3
-- Time taken: 0.005765 seconds

local module_upvr = {
	Cooldown = 28;
	GlobalCD = 0.1;
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
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Blitz_upvr = ReplicatedStorage_upvr.Skills["Titans Edge"].Blitz
	local tbl = {}
	table.insert(tbl, var2_upvw.applyStatus(arg1, "Slowed", 1.2))
	table.insert(tbl, var2_upvw.applyStatus(arg1, "GlobalCD", 1.2))
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid"):LoadAnimation(Blitz_upvr.Animation)
	any_LoadAnimation_result1:Play()
	var2_upvw.applySound(Blitz_upvr.BlitzCharge, HumanoidRootPart_upvr)
	var2_upvw.applySound(Blitz_upvr.Charge, HumanoidRootPart_upvr)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("punch"):Connect(function() -- Line 43
		--[[ Upvalues[6]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Blitz_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: TweenService_upvr (copied, readonly)
		]]
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 74, 0, 0.5)
		local clone = Blitz_upvr.VFX:Clone()
		clone.Parent = Folder_upvr
		clone.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 4.5 + HumanoidRootPart_upvr.CFrame.RightVector * math.random(-2, 2) * 0.25 + HumanoidRootPart_upvr.CFrame.UpVector * (1.25 + math.random(-2, 2) * 0.2)
		clone.CFrame = CFrame.lookAt(clone.Position, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 20)
		TweenService_upvr:Create(clone, TweenInfo.new(0.5), {
			CFrame = clone.CFrame + clone.CFrame.LookVector * 5;
		}):Play()
		var2_upvw.EmitAllDescendants(clone)
		var2_upvw.applyDebris(clone, 3)
		var2_upvw.Knockback(arg1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -20, 8, 0)
		local clone_2 = Blitz_upvr.PunchVFX.PunchVFX:Clone()
		clone_2.Parent = HumanoidRootPart_upvr
		var2_upvw.EmitAllDescendants(clone_2)
		var2_upvw.applyDebris(clone_2, 3)
		local BlitzJab = clone_2.BlitzJab
		BlitzJab.PlaybackSpeed += math.random(-1, 1) * 0.1
		local BlitzImpact = clone_2.BlitzImpact
		BlitzImpact.PlaybackSpeed += math.random(-1, 1) * 0.1
		local Jab = clone_2.Jab
		Jab.PlaybackSpeed += math.random(-1, 1) * 0.1
		clone_2.BlitzJab:Play()
		clone_2.BlitzImpact:Play()
		clone_2.Jab:Play()
		for _, v in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5, 9), nil do
			if not var2_upvw.CheckBlock(v) then
				var2_upvw.applyDamage(v, 3)
				var2_upvw.applyStatus(v, "Stunned", 0.85)
				local BlitzPunch = clone_2.BlitzPunch
				BlitzPunch.PlaybackSpeed += math.random(-1, 1) * 0.1
				clone_2.BlitzPunch:Play()
				local Punch = clone_2.Punch
				Punch.PlaybackSpeed += math.random(-1, 1) * 0.1
				clone_2.Punch:Play()
				local clone_3 = Blitz_upvr.HitVFX.HitVFX:Clone()
				clone_3.Parent = v.Torso
				var2_upvw.applyDebris(clone_3, 2)
				var2_upvw.EmitAllDescendants(clone_3)
				var2_upvw.Knockback(v, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -20, 10, 0)
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr