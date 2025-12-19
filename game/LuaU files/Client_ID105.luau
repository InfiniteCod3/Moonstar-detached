-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:11
-- Luau version 6, Types version 3
-- Time taken: 0.003687 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
local RunService_upvr = game:GetService("RunService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: RunService_upvr (readonly)
		[5]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local var7_upvw
	task.delay(1, function() -- Line 28
		--[[ Upvalues[1]:
			[1]: var7_upvw (read and write)
		]]
		if var7_upvw then
			var7_upvw:Disconnect()
		end
	end)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var7_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnClientEvent:Connect(function(arg1_2) -- Line 32
		--[[ Upvalues[6]:
			[1]: var7_upvw (read and write)
			[2]: arg1 (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var3_upvw (copied, read and write)
			[5]: RunService_upvr (copied, readonly)
			[6]: PlayerStatus_upvr (copied, readonly)
		]]
		if arg1_2 ~= "QuickStep" then
		else
			if var7_upvw then
				var7_upvw:Disconnect()
			end
			for _, v in arg1:GetDescendants() do
				if v:IsA("BodyVelocity") then
					v:Destroy()
				end
			end
			local BodyVelocity_upvr = Instance.new("BodyVelocity", arg1.Head)
			BodyVelocity_upvr.MaxForce = Vector3.new(100000, 0, 100000)
			BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 100
			game.Debris:AddItem(BodyVelocity_upvr, 1)
			local var18_upvw
			var18_upvw = var3_upvw.conTimer(RunService_upvr.RenderStepped:Connect(function() -- Line 51
				--[[ Upvalues[5]:
					[1]: BodyVelocity_upvr (readonly)
					[2]: PlayerStatus_upvr (copied, readonly)
					[3]: arg1 (copied, readonly)
					[4]: var18_upvw (read and write)
					[5]: HumanoidRootPart_upvr (copied, readonly)
				]]
				if not BodyVelocity_upvr.Parent or PlayerStatus_upvr.FindStatus(arg1, "FoundEnemy") then
					var18_upvw:Disconnect()
					BodyVelocity_upvr.Velocity = Vector3.new(0, 0, 0)
					game.Debris:AddItem(BodyVelocity_upvr, 0.1)
				else
					BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 100
				end
			end), 10)
		end
	end), 2)
end
return module_upvr