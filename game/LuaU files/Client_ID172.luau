-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:07
-- Luau version 6, Types version 3
-- Time taken: 0.002713 seconds

local module = {}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[2]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local var4_upvw
	task.delay(2, function() -- Line 25
		--[[ Upvalues[1]:
			[1]: var4_upvw (read and write)
		]]
		if not var4_upvw then
		else
			var4_upvw:Disconnect()
		end
	end)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var4_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnClientEvent:Connect(function(arg1_2, arg2_2) -- Line 30
		--[[ Upvalues[3]:
			[1]: var4_upvw (read and write)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: ReplicatedStorage_upvr (copied, readonly)
		]]
		if arg1_2 ~= "Agressive Breeze" then
		else
			var4_upvw:Disconnect()
			local CFrame = HumanoidRootPart_upvr.CFrame
			HumanoidRootPart_upvr.CFrame += HumanoidRootPart_upvr.CFrame.LookVector * 55
			ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Agressive Breeze", {
				SizeZ = (HumanoidRootPart_upvr.Position - CFrame.p).Magnitude;
				CF = HumanoidRootPart_upvr.CFrame:Lerp(CFrame, 0.5);
			})
		end
	end), 20)
end
return module