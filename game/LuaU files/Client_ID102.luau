-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:08
-- Luau version 6, Types version 3
-- Time taken: 0.004155 seconds

local module = {}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local RunService_upvr = game:GetService("RunService")
local TweenService_upvr = game:GetService("TweenService")
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: RunService_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 5)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	for _, v in arg1:GetDescendants() do
		if v:IsA("BodyVelocity") then
			v:Destroy()
		end
	end
	local BodyVelocity_upvr = Instance.new("BodyVelocity", arg1.Head)
	BodyVelocity_upvr.MaxForce = Vector3.new(100000, 0, 100000)
	BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 130
	game.Debris:AddItem(BodyVelocity_upvr, 0.9)
	local var14_upvw = true
	task.delay(0.05, function() -- Line 39
		--[[ Upvalues[1]:
			[1]: var14_upvw (read and write)
		]]
		var14_upvw = false
	end)
	local clone_upvr = ReplicatedStorage_upvr.Skills["Cyber Katana"].Ultimate["Super Siphon"].ClientHitbox:Clone()
	clone_upvr.Parent = Folder
	clone_upvr.weld.Part0 = HumanoidRootPart_upvr
	clone_upvr.weld.Part1 = clone_upvr
	game.Debris:AddItem(clone_upvr, 2)
	local var18_upvw
	local var19_upvw = false
	var18_upvw = RunService_upvr.RenderStepped:Connect(function() -- Line 52
		--[[ Upvalues[10]:
			[1]: BodyVelocity_upvr (readonly)
			[2]: var18_upvw (read and write)
			[3]: var19_upvw (read and write)
			[4]: ReplicatedStorage_upvr (copied, readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: var2_upvw (copied, read and write)
			[7]: arg1 (readonly)
			[8]: clone_upvr (readonly)
			[9]: var14_upvw (read and write)
			[10]: TweenService_upvr (copied, readonly)
		]]
		if not BodyVelocity_upvr.Parent then
			var18_upvw:Disconnect()
			if not var19_upvw then
				ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Super Siphon", HumanoidRootPart_upvr.CFrame)
				var2_upvw.applyStatus(arg1, "AutoRotate", 0.8)
			end
		else
			BodyVelocity_upvr.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 130
			if 0 < #var2_upvw.findEnemiesPart(clone_upvr) and var14_upvw == false then
				BodyVelocity_upvr:Destroy()
				TweenService_upvr:Create(HumanoidRootPart_upvr, TweenInfo.new(0.2), {
					Velocity = Vector3.new(0, 0, 0);
				}):Play()
				ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Super Siphon", HumanoidRootPart_upvr.CFrame)
				var2_upvw.applyStatus(arg1, "AutoRotate", 0.8)
				var19_upvw = true
			end
		end
	end)
end
return module