-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:19:01
-- Luau version 6, Types version 3
-- Time taken: 0.005732 seconds

local module = {}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local RunService_upvr = game:GetService("RunService")
function module.Script(arg1, arg2) -- Line 10
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: RunService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	for _, v in arg1:GetDescendants() do
		if v:IsA("BodyVelocity") then
			v:Destroy()
		end
	end
	local BodyVelocity = Instance.new("BodyVelocity", arg1.Torso)
	BodyVelocity.MaxForce = Vector3.new(0, 1000000, 0)
	BodyVelocity.Velocity = Vector3.new(0, 50, 0)
	game.Debris:AddItem(BodyVelocity, 0.35)
	local BodyVelocity_2_upvr = Instance.new("BodyVelocity", HumanoidRootPart_upvr)
	BodyVelocity_2_upvr.MaxForce = Vector3.new(1000000, 0, 1000000)
	BodyVelocity_2_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 50
	game.Debris:AddItem(BodyVelocity_2_upvr, 1.2)
	local var14_upvw
	var14_upvw = var2_upvw.conTimer(RunService_upvr.RenderStepped:Connect(function() -- Line 38
		--[[ Upvalues[3]:
			[1]: BodyVelocity_2_upvr (readonly)
			[2]: var14_upvw (read and write)
			[3]: HumanoidRootPart_upvr (readonly)
		]]
		if not BodyVelocity_2_upvr.Parent then
			var14_upvw:Disconnect()
		else
			BodyVelocity_2_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 50
		end
	end), 3)
	local var16_upvw
	task.delay(2, function() -- Line 44
		--[[ Upvalues[1]:
			[1]: var16_upvw (read and write)
		]]
		if not var16_upvw then
		else
			var16_upvw:Disconnect()
		end
	end)
	var16_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnClientEvent:Connect(function(arg1_2, arg2_2) -- Line 49
		--[[ Upvalues[2]:
			[1]: ReplicatedStorage_upvr (copied, readonly)
			[2]: HumanoidRootPart_upvr (readonly)
		]]
		if arg1_2 ~= "Aerial Smite" then
		else
			ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Aerial Smite", {
				ClientCF = HumanoidRootPart_upvr.CFrame;
			})
		end
	end), 8)
end
return module