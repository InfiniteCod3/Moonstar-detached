-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:46
-- Luau version 6, Types version 3
-- Time taken: 0.003670 seconds

local module = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
local RunService_upvr = game:GetService("RunService")
local TweenService_upvr = game:GetService("TweenService")
function module.Script(arg1, arg2) -- Line 11
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: RunService_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	arg1:FindFirstChild("HumanoidRootPart"):WaitForChild("WaterBrawlerTheme"):Stop()
	local clone_upvr = ReplicatedStorage_upvr.Skills["Water Brawler"].Ultimate.WaterBrawlerTheme:Clone()
	clone_upvr.Parent = arg1
	clone_upvr:Play()
	clone_upvr.Volume = 1
	var3_upvw.applyDebris(clone_upvr, 70)
	local var8_upvw
	var8_upvw = var3_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 32
		--[[ Upvalues[4]:
			[1]: arg1 (readonly)
			[2]: var8_upvw (read and write)
			[3]: TweenService_upvr (copied, readonly)
			[4]: clone_upvr (readonly)
		]]
		if not arg1.Parent then
			var8_upvw:Disconnect()
		elseif arg1.Info.UltimateMeter.Value <= 0 then
			var8_upvw:Disconnect()
			TweenService_upvr:Create(clone_upvr, TweenInfo.new(1), {
				Volume = 0;
			}):Play()
		end
	end), 200)
	local CameraBP_upvr = arg1:FindFirstChild("CameraBP", true)
	CameraBP_upvr:SetAttribute("Offset", Vector3.new(0, 0, 0))
	arg2.CameraMaxZoomDistance = 80
	arg2.CameraMinZoomDistance = 80
	local var12_upvw
	var12_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnClientEvent:Connect(function(arg1_2) -- Line 47
		--[[ Upvalues[3]:
			[1]: var12_upvw (read and write)
			[2]: CameraBP_upvr (readonly)
			[3]: arg2 (readonly)
		]]
		if arg1_2 ~= "WaterBrawlerUltimate" then
		else
			var12_upvw:Disconnect()
			CameraBP_upvr:SetAttribute("Offset", Vector3.new(0, 20, 0))
			arg2.CameraMaxZoomDistance = 180
			arg2.CameraMinZoomDistance = 180
			task.wait(1.5)
			CameraBP_upvr:SetAttribute("Offset", Vector3.new(0, 0, 0))
			arg2.CameraMinZoomDistance = 20
			arg2.CameraMaxZoomDistance = 20
			task.wait(1)
			arg2.CameraMaxZoomDistance = 40
			arg2.CameraMinZoomDistance = 10
		end
	end), 200)
	task.delay(10, function() -- Line 64
		--[[ Upvalues[1]:
			[1]: var12_upvw (read and write)
		]]
		if not var12_upvw then
		else
			var12_upvw:Disconnect()
		end
	end)
end
return module