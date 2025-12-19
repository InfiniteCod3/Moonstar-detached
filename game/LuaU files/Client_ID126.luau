-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:07
-- Luau version 6, Types version 3
-- Time taken: 0.001722 seconds

local module = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
function module.Script(arg1, arg2) -- Line 14
	--[[ Upvalues[2]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	var3_upvw.conTimer(arg1:FindFirstChild("HumanoidRootPart").ChildAdded:Connect(function(arg1_2) -- Line 26
		--[[ Upvalues[1]:
			[1]: arg1 (readonly)
		]]
		task.wait()
		if arg1_2.Name == "NebulaTheme" then
			arg1_2.Parent = arg1
		end
	end), 3)
end
return module