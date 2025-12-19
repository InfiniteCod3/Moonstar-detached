-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:10
-- Luau version 6, Types version 3
-- Time taken: 0.005759 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 18
module_upvr.GlobalCD = 1.4
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Charge_upvr = ReplicatedStorage_upvr.Skills["Titans Edge"].Ultimate.Charge
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Charge_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play(0.2)
	var3_upvw.applyStatus(arg1, "Freeze", 3)
	var3_upvw.applyStatus(arg1, "AutoRotate", 3)
	var3_upvw.applyStatus(arg1, "GlobalCD", 3)
	var3_upvw.changeFov(arg1, 60, 1, 1)
	local any_applySound_result1_upvr = var3_upvw.applySound(Charge_upvr.ChargingShockwave, HumanoidRootPart_upvr)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 42
		--[[ Upvalues[1]:
			[1]: any_applySound_result1_upvr (readonly)
		]]
		any_applySound_result1_upvr:Stop()
	end), module_upvr.Cooldown)
	local ThemeSong_upvr = HumanoidRootPart_upvr:FindFirstChild("ThemeSong")
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("dash"):Connect(function() -- Line 46
		--[[ Upvalues[13]:
			[1]: any_applySound_result1_upvr (readonly)
			[2]: TweenService_upvr (copied, readonly)
			[3]: ThemeSong_upvr (readonly)
			[4]: Charge_upvr (readonly)
			[5]: Folder_upvr (readonly)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: var3_upvw (copied, read and write)
			[8]: arg1 (readonly)
			[9]: any_LoadAnimation_result1_upvr (readonly)
			[10]: ReplicatedStorage_upvr (copied, readonly)
			[11]: arg2 (readonly)
			[12]: PlayerStatus_upvr (copied, readonly)
			[13]: module_upvr (copied, readonly)
		]]
		any_applySound_result1_upvr:Stop()
		TweenService_upvr:Create(ThemeSong_upvr, TweenInfo.new(0.25), {
			Volume = 0;
		}):Play()
		task.delay(2.5, function() -- Line 49
			--[[ Upvalues[2]:
				[1]: TweenService_upvr (copied, readonly)
				[2]: ThemeSong_upvr (copied, readonly)
			]]
			TweenService_upvr:Create(ThemeSong_upvr, TweenInfo.new(1), {
				Volume = ThemeSong_upvr:GetAttribute("ogVolume");
			}):Play()
		end)
		local clone_upvr = Charge_upvr.ChargeVFX:Clone()
		clone_upvr.Parent = Folder_upvr
		clone_upvr.CFrame = HumanoidRootPart_upvr.CFrame
		var3_upvw.EmitAllDescendants(clone_upvr)
		var3_upvw.applySound(Charge_upvr.DashSFX, HumanoidRootPart_upvr)
		var3_upvw.applySound(Charge_upvr.DashSFX2, HumanoidRootPart_upvr)
		TweenService_upvr:Create(HumanoidRootPart_upvr, TweenInfo.new(0.2), {
			CFrame = clone_upvr.Main.TeleportPart.CFrame;
		}):Play()
		var3_upvw.camShake(arg1, "BigBump")
		var3_upvw.changeFov(arg1, 100, 0.01, 0.25)
		var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("stab"):Connect(function() -- Line 66
			--[[ Upvalues[10]:
				[1]: var3_upvw (copied, read and write)
				[2]: clone_upvr (readonly)
				[3]: ReplicatedStorage_upvr (copied, readonly)
				[4]: arg2 (copied, readonly)
				[5]: arg1 (copied, readonly)
				[6]: Charge_upvr (copied, readonly)
				[7]: any_LoadAnimation_result1_upvr (copied, readonly)
				[8]: HumanoidRootPart_upvr (copied, readonly)
				[9]: PlayerStatus_upvr (copied, readonly)
				[10]: module_upvr (copied, readonly)
			]]
			-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
			-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
			-- KONSTANTERROR: [157] 128. Error Block 4 start (CF ANALYSIS FAILED)
			-- KONSTANTERROR: [157] 128. Error Block 4 end (CF ANALYSIS FAILED)
			-- KONSTANTERROR: [15] 13. Error Block 8 start (CF ANALYSIS FAILED)
			-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [157.8]
			if not nil then
				-- KONSTANTWARNING: GOTO [159] #129
			end
			-- KONSTANTERROR: [15] 13. Error Block 8 end (CF ANALYSIS FAILED)
		end), module_upvr.Cooldown)
	end), module_upvr.Cooldown)
end
return module_upvr