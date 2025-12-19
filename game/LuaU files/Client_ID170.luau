-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:05
-- Luau version 6, Types version 3
-- Time taken: 0.010372 seconds

local module_upvr = {}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local RunService_upvr = game:GetService("RunService")
function module_upvr.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: RunService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local var9_upvw
	for _, v in arg1:GetDescendants() do
		if v:IsA("BodyVelocity") then
			v:Destroy()
		end
	end
	local BodyVelocity_upvr = Instance.new("BodyVelocity", arg1.Head)
	BodyVelocity_upvr.MaxForce = Vector3.new(100000, 0, 100000)
	BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 100
	game.Debris:AddItem(BodyVelocity_upvr, 3)
	local var15_upvw
	local var16_upvw = 150
	var15_upvw = var2_upvw.conTimer(RunService_upvr.RenderStepped:Connect(function() -- Line 41
		--[[ Upvalues[5]:
			[1]: BodyVelocity_upvr (readonly)
			[2]: var15_upvw (read and write)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var16_upvw (read and write)
			[5]: var9_upvw (read and write)
		]]
		if not BodyVelocity_upvr.Parent then
			var15_upvw:Disconnect()
		else
			BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * var16_upvw
			if var9_upvw then
				var9_upvw.Attachment.Position = Vector3.new(0, 0, var16_upvw * 0.28)
				var9_upvw.BotATT.Position = Vector3.new(0, -20, var16_upvw * 0.28)
				var9_upvw.TopATT.Position = Vector3.new(0, 20, var16_upvw * 0.28)
			end
			if 17 < var16_upvw then
				var16_upvw -= 2
			end
		end
	end), 60)
	local any_conTimer_result1_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnClientEvent:Connect(function(arg1_2, arg2_2) -- Line 58
		--[[ Upvalues[2]:
			[1]: var9_upvw (read and write)
			[2]: Folder_upvr (readonly)
		]]
		if arg1_2 == "Lightspeed Slashes VFX" then
			var9_upvw = arg2_2:Clone()
			var9_upvw.Parent = Folder_upvr
			for _, v_2 in var9_upvw:GetChildren() do
				if v_2:IsA("Sound") then
					v_2:Stop()
				end
			end
			for _, v_3 in arg2_2:GetDescendants() do
				if v_3:IsA("ParticleEmitter") or v_3:IsA("Trail") then
					v_3:Destroy()
				end
			end
		end
	end), 60)
	task.delay(3, function() -- Line 78
		--[[ Upvalues[1]:
			[1]: any_conTimer_result1_upvw (read and write)
		]]
		if not any_conTimer_result1_upvw then
		else
			any_conTimer_result1_upvw:Disconnect()
		end
	end)
	local any_conTimer_result1_upvw_2 = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnClientEvent:Connect(function(arg1_3, arg2_3) -- Line 84
		--[[ Upvalues[3]:
			[1]: var2_upvw (copied, read and write)
			[2]: BodyVelocity_upvr (readonly)
			[3]: var9_upvw (read and write)
		]]
		if arg1_3 == "Lightspeed Slashes" then
			var2_upvw.applyDebris(BodyVelocity_upvr, 0)
			for _, v_4 in var9_upvw:GetDescendants() do
				if v_4:IsA("ParticleEmitter") or v_4:IsA("Trail") then
					v_4.Enabled = false
				end
			end
		end
	end), 60)
	task.delay(6, function() -- Line 97
		--[[ Upvalues[1]:
			[1]: any_conTimer_result1_upvw_2 (read and write)
		]]
		if not any_conTimer_result1_upvw_2 then
		else
			any_conTimer_result1_upvw_2:Disconnect()
		end
	end)
end
return module_upvr