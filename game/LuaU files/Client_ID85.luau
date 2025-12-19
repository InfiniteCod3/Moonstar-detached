-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:12
-- Luau version 6, Types version 3
-- Time taken: 0.006589 seconds

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
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local BodyVelocity_upvr = Instance.new("BodyVelocity", arg1.Head)
	BodyVelocity_upvr.MaxForce = Vector3.new(1000000, 0, 1000000)
	BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 250
	game.Debris:AddItem(BodyVelocity_upvr, 0.5)
	local var7_upvw = 0.5
	task.spawn(function() -- Line 30
		--[[ Upvalues[1]:
			[1]: var7_upvw (read and write)
		]]
		for _ = 1, 100 do
			task.wait(0.05)
			var7_upvw -= 0.05
		end
	end)
	local var11_upvw
	local var12_upvw = false
	var11_upvw = var2_upvw.conTimer(RunService_upvr.RenderStepped:Connect(function() -- Line 40
		--[[ Upvalues[7]:
			[1]: BodyVelocity_upvr (readonly)
			[2]: var11_upvw (read and write)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var12_upvw (read and write)
			[5]: var2_upvw (copied, read and write)
			[6]: ReplicatedStorage_upvr (copied, readonly)
			[7]: var7_upvw (read and write)
		]]
		if not BodyVelocity_upvr.Parent then
			var11_upvw:Disconnect()
		else
			BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 250
			if not var12_upvw then
				for _, v in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position, 12), nil do
					var12_upvw = true
					ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Rise", v, var7_upvw)
					return
				end
			end
		end
	end), 60)
end
return module