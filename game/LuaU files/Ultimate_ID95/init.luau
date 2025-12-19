-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:01
-- Luau version 6, Types version 3
-- Time taken: 0.006348 seconds

local module_upvr = {}
local var2_upvw
if script.Parent.Parent:IsA("ModuleScript") then
	var2_upvw = require(script.Parent.Parent)
end
module_upvr.ModeLength = 92
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 16
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
	local Humanoid = arg1:FindFirstChild("Humanoid")
	local Ultimate_upvr = ReplicatedStorage_upvr.Skills["Cyber Katana"].Ultimate
	local CyberKatana_upvr = arg1:FindFirstChild("CyberKatana")
	local clone_5_upvr = Ultimate_upvr.CyberKatanaTheme:Clone()
	clone_5_upvr.Parent = arg1.Head
	clone_5_upvr.Volume = 0.5
	clone_5_upvr:Play()
	task.delay(module_upvr.ModeLength, function() -- Line 37
		--[[ Upvalues[1]:
			[1]: clone_5_upvr (readonly)
		]]
		if clone_5_upvr and clone_5_upvr.Parent then
			clone_5_upvr:Destroy()
		end
	end)
	for _, v in arg1:GetDescendants() do
		if v:IsA("BodyVelocity") or v:IsA("BodyPosition") then
			v:Destroy()
		end
	end
	Humanoid.Health = Humanoid.MaxHealth
	var2_upvw.applyStatus(arg1, "Stunned", 4.2)
	var2_upvw.applyStatus(arg1, "IFrames", 4.2)
	var2_upvw.applyStatus(arg1, "AutoRotate", 4.2)
	var2_upvw.applyStatus(arg1, "Ultimate", 4.2)
	var2_upvw.applyStatus(arg1, "Cutscene", 4.2)
	local BodyVelocity = Instance.new("BodyVelocity", arg1:FindFirstChild("HumanoidRootPart"))
	BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	BodyVelocity.Velocity = Vector3.new(0, 0, 0)
	var2_upvw.applyDebris(BodyVelocity, 4.2)
	local function ClearHitVFX_upvr() -- Line 64, Named "ClearHitVFX"
		--[[ Upvalues[1]:
			[1]: CyberKatana_upvr (readonly)
		]]
		for _, v_2 in CyberKatana_upvr:GetChildren() do
			if v_2.Name == "hitVFX" then
				v_2:Destroy()
			end
		end
	end
	local function ClearWeaponTrail_upvr() -- Line 72, Named "ClearWeaponTrail"
		--[[ Upvalues[1]:
			[1]: CyberKatana_upvr (readonly)
		]]
		for _, v_3 in CyberKatana_upvr.TrailAtt:GetChildren() do
			if v_3:IsA("Trail") then
				v_3:Destroy()
			end
		end
	end
	ClearWeaponTrail_upvr()
	ClearHitVFX_upvr()
	local clone_3 = Ultimate_upvr.RedTrail:Clone()
	clone_3.Parent = CyberKatana_upvr.TrailAtt
	clone_3.Attachment0 = CyberKatana_upvr.TrailAtt
	clone_3.Attachment1 = CyberKatana_upvr.TrailAtt2
	local clone_4 = Ultimate_upvr.HitVFX.RedHitVFX:Clone()
	clone_4.Name = "hitVFX"
	clone_4.Parent = CyberKatana_upvr
	local neon_upvr = CyberKatana_upvr.WeaponParts:FindFirstChild("neon")
	task.delay(1, function() -- Line 93
		--[[ Upvalues[2]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: neon_upvr (readonly)
		]]
		TweenService_upvr:Create(neon_upvr, TweenInfo.new(1), {
			Color = Color3.fromRGB(209, 72, 72);
		}):Play()
	end)
	task.delay(module_upvr.ModeLength, function() -- Line 96
		--[[ Upvalues[6]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: neon_upvr (readonly)
			[3]: ClearWeaponTrail_upvr (readonly)
			[4]: ClearHitVFX_upvr (readonly)
			[5]: Ultimate_upvr (readonly)
			[6]: CyberKatana_upvr (readonly)
		]]
		TweenService_upvr:Create(neon_upvr, TweenInfo.new(1), {
			Color = Color3.fromRGB(98, 37, 209);
		}):Play()
		ClearWeaponTrail_upvr()
		ClearHitVFX_upvr()
		local clone_2 = Ultimate_upvr.PurpleTrail:Clone()
		clone_2.Parent = CyberKatana_upvr.TrailAtt
		clone_2.Attachment0 = CyberKatana_upvr.TrailAtt
		clone_2.Attachment1 = CyberKatana_upvr.TrailAtt2
		local clone = Ultimate_upvr.HitVFX.PurpleHitVFX:Clone()
		clone.Name = "hitVFX"
		clone.Parent = CyberKatana_upvr
	end)
end
return module_upvr