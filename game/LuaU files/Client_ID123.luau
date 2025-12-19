-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:05
-- Luau version 6, Types version 3
-- Time taken: 0.003983 seconds

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
	for _, v in HumanoidRootPart_upvr:GetChildren() do
		if v:IsA("BodyVelocity") then
			v:Destroy()
		end
	end
	local var11_upvw = 125
	local BodyVelocity_upvr = Instance.new("BodyVelocity", HumanoidRootPart_upvr)
	BodyVelocity_upvr.MaxForce = Vector3.new(100000, 0, 100000)
	BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * var11_upvw
	game.Debris:AddItem(BodyVelocity_upvr, 3)
	local var14_upvw
	local tick_result1_upvr = tick()
	var14_upvw = var2_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 40
		--[[ Upvalues[7]:
			[1]: BodyVelocity_upvr (readonly)
			[2]: var11_upvw (read and write)
			[3]: var14_upvw (read and write)
			[4]: ReplicatedStorage_upvr (copied, readonly)
			[5]: tick_result1_upvr (readonly)
			[6]: var2_upvw (copied, read and write)
			[7]: HumanoidRootPart_upvr (readonly)
		]]
		if not BodyVelocity_upvr.Parent or var11_upvw <= 1 then
			var11_upvw = 0
			BodyVelocity_upvr.Velocity = Vector3.new(0, 0, 0)
			var14_upvw:Disconnect()
			ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("GraveDigger")
		else
			var2_upvw.CreateDebris(HumanoidRootPart_upvr.Position, 2, 0.5, 0.5, 0.2)
			BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * var11_upvw
			var11_upvw = 125 - math.abs(tick_result1_upvr - tick()) * 125
		end
	end), 60)
	local var17_upvw
	var17_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnClientEvent:Connect(function(arg1_2, arg2_2) -- Line 57
		--[[ Upvalues[3]:
			[1]: arg2 (readonly)
			[2]: var17_upvw (read and write)
			[3]: BodyVelocity_upvr (readonly)
		]]
		if arg1_2 ~= arg2 or arg2_2 ~= "GraveDigger" then
		else
			var17_upvw:Disconnect()
			BodyVelocity_upvr:Destroy()
		end
	end), 60)
	task.delay(3, function() -- Line 63
		--[[ Upvalues[1]:
			[1]: var17_upvw (read and write)
		]]
		if not var17_upvw then
		else
			var17_upvw:Disconnect()
		end
	end)
end
return module