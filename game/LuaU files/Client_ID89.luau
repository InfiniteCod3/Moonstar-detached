-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:16
-- Luau version 6, Types version 3
-- Time taken: 0.005053 seconds

local module = {}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: TweenService_upvr (readonly)
		[4]: RunService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	task.wait(0.05)
	local CFrame = HumanoidRootPart_upvr.CFrame
	local var8_upvw = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 30
	local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position, HumanoidRootPart_upvr.CFrame.LookVector * 30, var2_upvw.raycastParams)
	if workspace_Raycast_result1 then
		var8_upvw = CFrame.new(workspace_Raycast_result1.Position - CFrame.LookVector * -3) * CFrame - CFrame.p
	end
	TweenService_upvr:Create(HumanoidRootPart_upvr, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = var8_upvw;
	}):Play()
	local var12_upvw
	local var13_upvw
	local tbl_upvr = {}
	var13_upvw = RunService_upvr.RenderStepped:Connect(function() -- Line 41
		--[[ Upvalues[8]:
			[1]: arg1 (readonly)
			[2]: var12_upvw (read and write)
			[3]: var13_upvw (read and write)
			[4]: var2_upvw (copied, read and write)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: tbl_upvr (readonly)
			[7]: ReplicatedStorage_upvr (copied, readonly)
			[8]: var8_upvw (read and write)
		]]
		if not arg1.Parent or var12_upvw then
			var13_upvw:Disconnect()
		else
			for _, var16 in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 3, 6), nil do
				if not table.find(tbl_upvr, var16) then
					if not var2_upvw.CheckBlock(var16) then
						var12_upvw = var16
						ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Inferior", var16, var8_upvw)
						return
					end
					table.insert(tbl_upvr, var16)
				end
				return
			end
		end
	end)
	var2_upvw.conTimer(var13_upvw, 0.35)
end
return module