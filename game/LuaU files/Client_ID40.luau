-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:17
-- Luau version 6, Types version 3
-- Time taken: 0.005956 seconds

local module = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
local RunService_upvr = game:GetService("RunService")
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[3]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: RunService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 10)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	task.wait(0.28)
	for _, v in arg1:GetDescendants() do
		if v:IsA("BodyVelocity") then
			v:Destroy()
		end
	end
	local var12_upvw = false
	local BodyVelocity_upvr = Instance.new("BodyVelocity", arg1.Torso)
	BodyVelocity_upvr.MaxForce = Vector3.new(math.huge, 0, math.huge)
	BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 70
	task.delay(0.6, function() -- Line 40
		--[[ Upvalues[3]:
			[1]: var12_upvw (read and write)
			[2]: BodyVelocity_upvr (readonly)
			[3]: ReplicatedStorage_upvr (copied, readonly)
		]]
		if not var12_upvw then
			BodyVelocity_upvr:Destroy()
			ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("StopLoop")
		end
	end)
	local any_conTimer_result1_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnClientEvent:Connect(function(arg1_2, arg2_2) -- Line 48
		--[[ Upvalues[3]:
			[1]: BodyVelocity_upvr (readonly)
			[2]: ReplicatedStorage_upvr (copied, readonly)
			[3]: var12_upvw (read and write)
		]]
		if arg1_2 ~= "Frenzy" then
		else
			if arg2_2.Action == "Destroy" and BodyVelocity_upvr then
				BodyVelocity_upvr:Destroy()
				ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("StopLoop")
				return
			end
			if arg2_2.Action == "Target" then
				var12_upvw = arg2_2.Target
			end
		end
	end), 5)
	task.delay(5, function() -- Line 58
		--[[ Upvalues[1]:
			[1]: any_conTimer_result1_upvw (read and write)
		]]
		any_conTimer_result1_upvw:Disconnect()
	end)
	local var19_upvw
	var19_upvw = var3_upvw.conTimer(RunService_upvr.Heartbeat:Connect(function() -- Line 63
		--[[ Upvalues[6]:
			[1]: BodyVelocity_upvr (readonly)
			[2]: var19_upvw (read and write)
			[3]: var12_upvw (read and write)
			[4]: ReplicatedStorage_upvr (copied, readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: var3_upvw (copied, read and write)
		]]
		if not BodyVelocity_upvr.Parent then
			var19_upvw:Disconnect()
		else
			if var12_upvw and not var12_upvw.Parent then
				ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("StopLoop")
				BodyVelocity_upvr:Destroy()
				return
			end
			if workspace:Raycast(HumanoidRootPart_upvr.Position, HumanoidRootPart_upvr.CFrame.LookVector * 10, var3_upvw.raycastParams) then
				BodyVelocity_upvr.MaxForce = Vector3.new(0, 0, 0)
			else
				BodyVelocity_upvr.MaxForce = Vector3.new(math.huge, 0, math.huge)
			end
			if var12_upvw then
				BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 25
				var3_upvw.CreateDebris(HumanoidRootPart_upvr.Position, 2, 0.4, 0.2, 0.09)
				return
			end
			var3_upvw.CreateDebris(HumanoidRootPart_upvr.Position, 2, 0.4, 0.2, 0.09)
			BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 70
		end
	end), 60)
end
return module