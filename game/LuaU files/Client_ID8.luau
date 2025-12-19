-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:12:54
-- Luau version 6, Types version 3
-- Time taken: 0.003885 seconds

local module = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
local Remotes_upvr = game:GetService("ReplicatedStorage").Remotes
local RunService_upvr = game:GetService("RunService")
function module.Script(arg1, arg2) -- Line 14
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: Remotes_upvr (readonly)
		[4]: RunService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 10)
	for _, v in arg1:GetDescendants() do
		if v:IsA("BodyVelocity") then
			v:Destroy()
		end
	end
	local var13_upvw = false
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var3_upvw.conTimer(var3_upvw.conTimer(Remotes_upvr.ClientInfo.OnClientEvent:Connect(function(arg1_2, arg2_2) -- Line 36
		--[[ Upvalues[6]:
			[1]: var13_upvw (read and write)
			[2]: Remotes_upvr (copied, readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: arg1 (readonly)
			[5]: var3_upvw (copied, read and write)
			[6]: RunService_upvr (copied, readonly)
		]]
		if arg1_2 ~= "Skewer" then
		else
			if var13_upvw then
				Remotes_upvr.ClientInfo:FireServer("Skewer", {
					ClientCF = HumanoidRootPart_upvr.CFrame;
				})
				var13_upvw:Destroy()
				return
			end
			local BodyVelocity_upvr = Instance.new("BodyVelocity", arg1.Torso)
			BodyVelocity_upvr.MaxForce = Vector3.new(1000000, 1000000, 1000000)
			BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 100
			game.Debris:AddItem(BodyVelocity_upvr, 5)
			var13_upvw = BodyVelocity_upvr
			local var18_upvw
			var18_upvw = var3_upvw.conTimer(RunService_upvr.RenderStepped:Connect(function() -- Line 52
				--[[ Upvalues[4]:
					[1]: arg1 (copied, readonly)
					[2]: BodyVelocity_upvr (readonly)
					[3]: var18_upvw (read and write)
					[4]: HumanoidRootPart_upvr (copied, readonly)
				]]
				if not arg1.Parent or not BodyVelocity_upvr.Parent then
					var18_upvw:Disconnect()
				else
					BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 100
				end
			end), 10)
		end
	end), 5), 5)
end
return module