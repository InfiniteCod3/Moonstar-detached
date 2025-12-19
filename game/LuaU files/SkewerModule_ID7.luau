-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:12:53
-- Luau version 6, Types version 3
-- Time taken: 0.008164 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 18
module_upvr.GlobalCD = 1.4
local var3_upvw
local Remotes_upvr = game:GetService("ReplicatedStorage").Remotes
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: Remotes_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_2_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Skewer_upvr = ReplicatedStorage_upvr.Skills["Basic Sword"].Ultimate.Skewer
	local any_LoadAnimation_result1 = Humanoid_upvr.Animator:LoadAnimation(Skewer_upvr.Animation)
	any_LoadAnimation_result1:Play()
	var3_upvw.applyStatus(arg1, "Slowed", 1.5)
	var3_upvw.applyStatus(arg1, "GlobalCD", 1.5)
	local function _(arg1_2) -- Line 39, Named "SetupSFX"
		--[[ Upvalues[4]:
			[1]: var3_upvw (copied, read and write)
			[2]: Skewer_upvr (readonly)
			[3]: HumanoidRootPart_2_upvr (readonly)
			[4]: module_upvr (copied, readonly)
		]]
		var3_upvw.conTimer(arg1_2:GetMarkerReachedSignal("sfx"):Connect(function(arg1_3) -- Line 40
			--[[ Upvalues[3]:
				[1]: Skewer_upvr (copied, readonly)
				[2]: HumanoidRootPart_2_upvr (copied, readonly)
				[3]: var3_upvw (copied, read and write)
			]]
			for _, v in Skewer_upvr:GetChildren() do
				if v.Name == arg1_3 then
					local clone = v:Clone()
					clone.Parent = HumanoidRootPart_2_upvr
					clone:Play()
					var3_upvw.applyDebris(clone, clone.TimeLength * clone.PlaybackSpeed + 1)
				end
			end
		end), module_upvr.Cooldown)
	end
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_4) -- Line 40
		--[[ Upvalues[3]:
			[1]: Skewer_upvr (readonly)
			[2]: HumanoidRootPart_2_upvr (readonly)
			[3]: var3_upvw (copied, read and write)
		]]
		for _, v_2 in Skewer_upvr:GetChildren() do
			if v_2.Name == arg1_4 then
				local clone_2 = v_2:Clone()
				clone_2.Parent = HumanoidRootPart_2_upvr
				clone_2:Play()
				var3_upvw.applyDebris(clone_2, clone_2.TimeLength * clone_2.PlaybackSpeed + 1)
			end
		end
	end), module_upvr.Cooldown)
	local any_applySound_result1_upvr = var3_upvw.applySound(Skewer_upvr.Charge, HumanoidRootPart_2_upvr)
	var3_upvw.conTimer(any_LoadAnimation_result1.Stopped:Connect(function() -- Line 56
		--[[ Upvalues[1]:
			[1]: any_applySound_result1_upvr (readonly)
		]]
		any_applySound_result1_upvr:Stop()
	end), module_upvr.Cooldown)
	task.delay(1, function() -- Line 60
		--[[ Upvalues[2]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
		]]
		var3_upvw.applyStatus(arg1, "Stunned", 0.5)
	end)
	local var27_upvw
	local var28_upvw
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("skewer"):Connect(function() -- Line 66
		--[[ Upvalues[12]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: any_applySound_result1_upvr (readonly)
			[4]: Skewer_upvr (readonly)
			[5]: HumanoidRootPart_2_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: var28_upvw (read and write)
			[8]: Remotes_upvr (copied, readonly)
			[9]: arg2 (readonly)
			[10]: var27_upvw (read and write)
			[11]: Humanoid_upvr (readonly)
			[12]: module_upvr (copied, readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.changeFov(arg1, 60, 0, 0.5)
		any_applySound_result1_upvr:Stop()
		var3_upvw.applySound(Skewer_upvr.Jab, HumanoidRootPart_2_upvr)
		var3_upvw.applyStatus(arg1, "Stunned", 0.5)
		var3_upvw.applyStatus(arg1, "AutoRotate", 0.4)
		-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [294] 233. Error Block 8 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [294] 233. Error Block 8 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [62] 51. Error Block 21 start (CF ANALYSIS FAILED)
		-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [294.8]
		if not nil then
			-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [294.9]
			-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [294.10]
			-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [294.11]
			for _, _ in nil do
				-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [294.14]
				if nil then
				end
			end
			-- KONSTANTWARNING: GOTO [296] #234
		end
		-- KONSTANTERROR: [62] 51. Error Block 21 end (CF ANALYSIS FAILED)
	end), module_upvr.Cooldown)
	var3_upvw.conTimer(var3_upvw.conTimer(Remotes_upvr.ClientInfo.OnServerEvent:Connect(function(arg1_5, arg2_2, arg3) -- Line 177
		--[[ Upvalues[5]:
			[1]: arg2 (readonly)
			[2]: var28_upvw (read and write)
			[3]: var27_upvw (read and write)
			[4]: HumanoidRootPart_2_upvr (readonly)
			[5]: var3_upvw (copied, read and write)
		]]
		if arg1_5 ~= arg2 or arg2_2 ~= "Skewer" then
		else
			if not var28_upvw then return end
			local HumanoidRootPart = var28_upvw:FindFirstChild("HumanoidRootPart")
			if var27_upvw then
				var27_upvw:Destroy()
			end
			HumanoidRootPart_2_upvr.CFrame = arg3.ClientCF
			HumanoidRootPart.CFrame = (arg3.ClientCF + HumanoidRootPart_2_upvr.CFrame.LookVector * 3) * CFrame.Angles(0, math.pi, 0)
			HumanoidRootPart_2_upvr.Velocity = Vector3.new(0, 0, 0)
			HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
			var3_upvw.Knockback(var28_upvw, HumanoidRootPart_2_upvr.Position, 5)
		end
	end), module_upvr.Cooldown), 5)
end
return module_upvr