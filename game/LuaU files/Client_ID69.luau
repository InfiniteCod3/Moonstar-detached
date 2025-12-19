-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:44
-- Luau version 6, Types version 3
-- Time taken: 0.006776 seconds

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
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 10)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local BodyVelocity_upvr = Instance.new("BodyVelocity", arg1.Head)
	BodyVelocity_upvr.MaxForce = Vector3.new(1000000, 1000000, 1000000)
	BodyVelocity_upvr.Velocity = HumanoidRootPart.CFrame.LookVector * 100 + Vector3.new(0, 100, 0)
	var2_upvw.applyDebris(BodyVelocity_upvr, 3.2)
	TweenService_upvr:Create(BodyVelocity_upvr, TweenInfo.new(3), {
		Velocity = HumanoidRootPart.CFrame.LookVector * 10 + Vector3.new(0, 150, 0);
	}):Play()
	task.delay(0.6, function() -- Line 34
		--[[ Upvalues[1]:
			[1]: BodyVelocity_upvr (readonly)
		]]
		BodyVelocity_upvr.MaxForce = Vector3.new(1000000, 0, 1000000)
	end)
	local tbl_upvr = {}
	table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "AutoRotate", 3))
	table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "Freeze", 3))
	local var13_upvw
	var13_upvw = var2_upvw.conTimer(RunService_upvr.RenderStepped:Connect(function() -- Line 43
		--[[ Upvalues[5]:
			[1]: BodyVelocity_upvr (readonly)
			[2]: var13_upvw (read and write)
			[3]: tbl_upvr (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: arg1 (readonly)
		]]
		if not BodyVelocity_upvr.Parent then
			var13_upvw:Disconnect()
			for _, v in tbl_upvr do
				var2_upvw.applyDebris(v, 0)
			end
		elseif arg1:FindFirstChild("FiredCannon") then
			BodyVelocity_upvr:Destroy()
		end
	end), 60)
end
return module