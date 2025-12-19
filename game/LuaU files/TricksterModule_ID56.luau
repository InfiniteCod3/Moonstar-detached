-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:47
-- Luau version 6, Types version 3
-- Time taken: 0.010245 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 22
module_upvr.GlobalCD = 1
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 18
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Trickster_upvr = ReplicatedStorage_upvr.Skills.Hallow.Trickster
	local Hallow_upvr = arg1:FindFirstChild("Hallow")
	local clone_upvr = Trickster_upvr.HallowGround:Clone()
	clone_upvr.Parent = arg1
	clone_upvr.weld.Part0 = HumanoidRootPart_upvr
	clone_upvr.weld.Part1 = clone_upvr
	var3_upvw.applyDebris(clone_upvr, 3)
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Trickster_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(1.1)
	var3_upvw.applyStatus(arg1, "Stunned", 2.1)
	var3_upvw.changeFov(arg1, 90, 0.3, 3)
	var3_upvw.applySound(Trickster_upvr.Charge, HumanoidRootPart_upvr, 5)
	local function Visibility_upvr(arg1_2, arg2_2) -- Line 48, Named "Visibility"
		if arg1_2 == true then
			arg2_2.Handle.Transparency = 0
			for _, v in arg2_2.BaseTrails:GetChildren() do
				v.Enabled = true
			end
			for _, v_2 in arg2_2.BodyVFX:GetChildren() do
				if v_2:IsA("ParticleEmitter") or v_2:IsA("PointLight") then
					v_2.Enabled = true
				end
			end
		elseif arg1_2 == false then
			arg2_2.Handle.Transparency = 1
			for _, v_5 in arg2_2.BaseTrails:GetChildren() do
				v_5.Enabled = false
			end
			for _, v_6 in arg2_2.BodyVFX:GetChildren() do
				if v_6:IsA("ParticleEmitter") or v_6:IsA("PointLight") then
					v_6.Enabled = false
				end
			end
		end
	end
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Once(function() -- Line 76
		--[[ Upvalues[3]:
			[1]: Visibility_upvr (readonly)
			[2]: Hallow_upvr (readonly)
			[3]: clone_upvr (readonly)
		]]
		Visibility_upvr(true, Hallow_upvr)
		Visibility_upvr(false, clone_upvr)
		for _, v_3 in Hallow_upvr.BaseTrails:GetChildren() do
			v_3.Enabled = false
		end
	end), 5)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Invisible"):Connect(function() -- Line 85
		--[[ Upvalues[3]:
			[1]: Visibility_upvr (readonly)
			[2]: Hallow_upvr (readonly)
			[3]: clone_upvr (readonly)
		]]
		Visibility_upvr(false, Hallow_upvr)
		Visibility_upvr(true, clone_upvr)
	end), 3)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Visible"):Connect(function() -- Line 90
		--[[ Upvalues[6]:
			[1]: Visibility_upvr (readonly)
			[2]: Hallow_upvr (readonly)
			[3]: clone_upvr (readonly)
			[4]: var3_upvw (copied, read and write)
			[5]: Trickster_upvr (readonly)
			[6]: HumanoidRootPart_upvr (readonly)
		]]
		Visibility_upvr(true, Hallow_upvr)
		Visibility_upvr(false, clone_upvr)
		var3_upvw.applySound(Trickster_upvr.swingSFX, HumanoidRootPart_upvr, 5)
	end), 3)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Smash"):Connect(function() -- Line 97
		--[[ Upvalues[7]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
			[2]: var3_upvw (copied, read and write)
			[3]: arg1 (readonly)
			[4]: Trickster_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 42 start (CF ANALYSIS FAILED)
		any_LoadAnimation_result1_upvr:AdjustSpeed(0.75)
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.changeFov(arg1, 70, 0, 0.5)
		var3_upvw.applySound(Trickster_upvr.Metal, HumanoidRootPart_upvr, 5)
		var3_upvw.applySound(Trickster_upvr.HitSound, HumanoidRootPart_upvr, 5)
		var3_upvw.applySound(Trickster_upvr.Charge, HumanoidRootPart_upvr, 5)
		var3_upvw.applySound(Trickster_upvr.SmashSFX, HumanoidRootPart_upvr, 5)
		local any_applyVFX_result1 = var3_upvw.applyVFX(Trickster_upvr.TricksterVFX, Folder_upvr, 10)
		any_applyVFX_result1.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 10 + Vector3.new(0, -2.9000, 0)
		var3_upvw.applySound(Trickster_upvr.FlameBurst, any_applyVFX_result1, 5)
		var3_upvw.applySound(Trickster_upvr.Burst, any_applyVFX_result1, 5)
		local workspace_Raycast_result1 = workspace:Raycast(any_applyVFX_result1.Position, Vector3.new(0, -10, 0), var3_upvw.raycastParams)
		if workspace_Raycast_result1 then
			any_applyVFX_result1.CFrame = CFrame.new(workspace_Raycast_result1.Position + Vector3.new(0, 0.10000, 0)) * any_applyVFX_result1.CFrame - any_applyVFX_result1.CFrame.p
		end
		for _, v_4 in any_applyVFX_result1:GetChildren() do
			if v_4:IsA("ParticleEmitter") or v_4:IsA("Trail") then
				v_4.Enabled = true
			end
		end
		TweenService_upvr:Create(any_applyVFX_result1, TweenInfo.new(0.7, Enum.EasingStyle.Linear), {
			CFrame = any_applyVFX_result1.CFrame + any_applyVFX_result1.CFrame.LookVector * 110;
		}):Play()
		-- KONSTANTERROR: [0] 1. Error Block 42 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [185] 140. Error Block 47 start (CF ANALYSIS FAILED)
		wait(0.05)
		-- KONSTANTERROR: [185] 140. Error Block 47 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [174] 131. Error Block 10 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [174] 131. Error Block 10 end (CF ANALYSIS FAILED)
	end), 3)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("FloorHit"):Connect(function() -- Line 178
		--[[ Upvalues[4]:
			[1]: var3_upvw (copied, read and write)
			[2]: Trickster_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: arg1 (readonly)
		]]
		var3_upvw.applySound(Trickster_upvr.Metal, HumanoidRootPart_upvr, 5)
		var3_upvw.applySound(Trickster_upvr.Charge, HumanoidRootPart_upvr, 5)
		var3_upvw.applySound(Trickster_upvr.HitSound2, HumanoidRootPart_upvr, 5)
		var3_upvw.applyVFX(Trickster_upvr.FloorHitVFX, HumanoidRootPart_upvr, 5)
		var3_upvw.applyStatus(arg1, "IFrames", 1.3)
		var3_upvw.camShake(arg1, "SmallBump")
		var3_upvw.changeFov(arg1, 75, 0, 0.7)
	end), 3)
end
return module_upvr