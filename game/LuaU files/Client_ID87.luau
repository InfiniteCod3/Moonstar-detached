-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:14
-- Luau version 6, Types version 3
-- Time taken: 0.003922 seconds

local module = {}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local any_conTimer_result1_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnClientEvent:Connect(function(arg1_2, arg2_2) -- Line 24
		--[[ Upvalues[1]:
			[1]: TweenService_upvr (copied, readonly)
		]]
		if arg1_2 ~= "Brute" then
		else
			local Highlight_upvr = Instance.new("Highlight", arg2_2)
			Highlight_upvr.FillColor = Color3.new(0, 0, 0)
			Highlight_upvr.OutlineColor = Color3.new(0, 0, 0)
			Highlight_upvr.FillTransparency = 0.3
			Highlight_upvr.OutlineTransparency = 0
			game.Debris:AddItem(Highlight_upvr, 5)
			task.delay(1, function() -- Line 33
				--[[ Upvalues[2]:
					[1]: TweenService_upvr (copied, readonly)
					[2]: Highlight_upvr (readonly)
				]]
				TweenService_upvr:Create(Highlight_upvr, TweenInfo.new(1), {
					FillTransparency = 1;
					OutlineTransparency = 1;
				}):Play()
			end)
		end
	end), 6)
	task.delay(6, function() -- Line 42
		--[[ Upvalues[1]:
			[1]: any_conTimer_result1_upvw (read and write)
		]]
		if not any_conTimer_result1_upvw then
		else
			any_conTimer_result1_upvw:Disconnect()
		end
	end)
end
return module