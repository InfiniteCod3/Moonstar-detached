-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:17
-- Luau version 6, Types version 3
-- Time taken: 0.004386 seconds

local module_upvr = {}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local RunService_upvr = game:GetService("RunService")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[5]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: RunService_upvr (readonly)
		[5]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	for _, v in arg1:GetDescendants() do
		if v:IsA("BodyVelocity") then
			v:Destroy()
		end
	end
	local BodyVelocity_upvr = Instance.new("BodyVelocity", arg1.Head)
	BodyVelocity_upvr.MaxForce = Vector3.new(100000, 0, 100000)
	BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 160
	game.Debris:AddItem(BodyVelocity_upvr, 0.35)
	local var15_upvw
	local var16_upvw = false
	var15_upvw = var2_upvw.conTimer(RunService_upvr.RenderStepped:Connect(function() -- Line 42
		--[[ Upvalues[8]:
			[1]: BodyVelocity_upvr (readonly)
			[2]: var15_upvw (read and write)
			[3]: var16_upvw (read and write)
			[4]: TweenService_upvr (copied, readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: ReplicatedStorage_upvr (copied, readonly)
			[7]: var2_upvw (copied, read and write)
			[8]: arg1 (readonly)
		]]
		if not BodyVelocity_upvr.Parent then
			var15_upvw:Disconnect()
			if not var16_upvw then
				TweenService_upvr:Create(HumanoidRootPart_upvr, TweenInfo.new(0.3), {
					Velocity = Vector3.new(0, 0, 0);
				}):Play()
				ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Final Strike v2")
			end
		else
			BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 160
			if 0 < #var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 12, 8.5) then
				var16_upvw = true
				BodyVelocity_upvr:Destroy()
				TweenService_upvr:Create(HumanoidRootPart_upvr, TweenInfo.new(0.1), {
					Velocity = Vector3.new(0, 0, 0);
				}):Play()
				ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Final Strike", HumanoidRootPart_upvr.CFrame)
				var2_upvw.applyStatus(arg1, "AutoRotate", 0.8)
			end
		end
	end), 60)
end
return module_upvr