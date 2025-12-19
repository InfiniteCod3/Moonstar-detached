-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:58
-- Luau version 6, Types version 3
-- Time taken: 0.008467 seconds

local module = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
if script.Parent:IsA("ModuleScript") then
	var3_upvw = require(script.Parent.Parent.Parent.Parent)
end
local RunService_upvr = game:GetService("RunService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
local TweenService_upvr = game:GetService("TweenService")
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: RunService_upvr (readonly)
		[4]: PlayerStatus_upvr (readonly)
		[5]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local var8_upvw = 50
	local BodyVelocity_2_upvr = Instance.new("BodyVelocity", arg1.Head)
	BodyVelocity_2_upvr.MaxForce = Vector3.new(100000, 100000, 100000)
	BodyVelocity_2_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * var8_upvw + Vector3.new(0, 20, 0)
	game.Debris:AddItem(BodyVelocity_2_upvr, 10)
	task.delay(0.2, function() -- Line 31
		--[[ Upvalues[1]:
			[1]: BodyVelocity_2_upvr (readonly)
		]]
		BodyVelocity_2_upvr.MaxForce = Vector3.new(100000, 0, 100000)
	end)
	local var11_upvw = 50
	local var12_upvw = false
	local const_number_upvr = 180
	task.delay(0.63, function() -- Line 38
		--[[ Upvalues[3]:
			[1]: var12_upvw (read and write)
			[2]: var11_upvw (read and write)
			[3]: const_number_upvr (readonly)
		]]
		var12_upvw = true
		var11_upvw = const_number_upvr
	end)
	var3_upvw.CreateDebris(HumanoidRootPart_upvr.Position, 5, 0.5, 0.85, 0.2)
	local var16_upvw
	local tick_result1_upvr = tick()
	local var18_upvw
	local var19_upvw
	var16_upvw = var3_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 50
		--[[ Upvalues[12]:
			[1]: BodyVelocity_2_upvr (readonly)
			[2]: var16_upvw (read and write)
			[3]: tick_result1_upvr (readonly)
			[4]: var11_upvw (read and write)
			[5]: var12_upvw (read and write)
			[6]: var3_upvw (copied, read and write)
			[7]: HumanoidRootPart_upvr (readonly)
			[8]: var8_upvw (read and write)
			[9]: var18_upvw (read and write)
			[10]: var19_upvw (read and write)
			[11]: PlayerStatus_upvr (copied, readonly)
			[12]: ReplicatedStorage_upvr (copied, readonly)
		]]
		if not BodyVelocity_2_upvr.Parent then
			var16_upvw:Disconnect()
		else
			if var12_upvw then
				var3_upvw.CreateDebris(HumanoidRootPart_upvr.Position, 1, 0.5, 0.65, 0.2)
			end
			BodyVelocity_2_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * var8_upvw + Vector3.new(0, 20, 0)
			var8_upvw = var11_upvw - math.abs(tick_result1_upvr - tick()) * var11_upvw * 0.06
			if not var18_upvw and var12_upvw and not var19_upvw then
				for _, v in var3_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position, 12, true), nil do
					if not PlayerStatus_upvr.FindStatus(v, "IFrames") then
						var18_upvw = true
						ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Anguish", v)
						return
					end
					var19_upvw = true
					task.delay(0.1, function() -- Line 71
						--[[ Upvalues[1]:
							[1]: var19_upvw (copied, read and write)
						]]
						var19_upvw = false
					end)
				end
			end
		end
	end), 60)
	local var24_upvw
	var24_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnClientEvent:Connect(function(arg1_2) -- Line 80
		--[[ Upvalues[4]:
			[1]: var24_upvw (read and write)
			[2]: BodyVelocity_2_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: TweenService_upvr (copied, readonly)
		]]
		if arg1_2 == "Anguish" then
			var24_upvw:Disconnect()
			BodyVelocity_2_upvr:Destroy()
			task.wait()
			local BodyVelocity = Instance.new("BodyVelocity", HumanoidRootPart_upvr)
			BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
			BodyVelocity.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 120 + Vector3.new(0, 45, 0)
			TweenService_upvr:Create(BodyVelocity, TweenInfo.new(1.3), {
				Velocity = Vector3.new(0, 0, 0);
			}):Play()
			game.Debris:AddItem(BodyVelocity, 1.5)
		elseif arg1_2 == "AnguishStop" then
			var24_upvw:Disconnect()
			BodyVelocity_2_upvr:Destroy()
		end
	end), 10)
end
return module