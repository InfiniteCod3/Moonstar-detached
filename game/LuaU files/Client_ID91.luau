-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:18
-- Luau version 6, Types version 3
-- Time taken: 0.004364 seconds

local module = {}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local RunService_upvr = game:GetService("RunService")
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: RunService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local var6_upvw
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var6_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnClientEvent:Connect(function(arg1_2) -- Line 24
		--[[ Upvalues[5]:
			[1]: var6_upvw (read and write)
			[2]: arg1 (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: RunService_upvr (copied, readonly)
			[5]: HumanoidRootPart_upvr (readonly)
		]]
		if arg1_2 ~= "Dominance" then
		else
			var6_upvw:Disconnect()
			local BodyVelocity_upvr = Instance.new("BodyVelocity", arg1.Torso)
			BodyVelocity_upvr.MaxForce = Vector3.new(1000000, 1000000, 1000000)
			local var10_upvw
			var10_upvw = var2_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 32
				--[[ Upvalues[4]:
					[1]: arg1 (copied, readonly)
					[2]: BodyVelocity_upvr (readonly)
					[3]: var10_upvw (read and write)
					[4]: HumanoidRootPart_upvr (copied, readonly)
				]]
				if not arg1.Parent or not BodyVelocity_upvr.Parent then
					var10_upvw:Disconnect()
				else
					BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 120 + Vector3.new(0, 30, 0)
				end
			end), 60)
			task.wait(0.1)
			BodyVelocity_upvr.MaxForce = Vector3.new(1000000, 0, 1000000)
			task.wait(0.5)
			BodyVelocity_upvr:Destroy()
		end
	end), 3)
	task.delay(3, function() -- Line 44
		--[[ Upvalues[1]:
			[1]: var6_upvw (read and write)
		]]
		if not var6_upvw then
		else
			var6_upvw:Disconnect()
		end
	end)
end
return module