-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:02
-- Luau version 6, Types version 3
-- Time taken: 0.004526 seconds

local module = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[3]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 10)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local Entry = ReplicatedStorage_upvr.Skills["Basic Sword"].Entry
	for _, v in arg1:GetDescendants() do
		if v:IsA("BodyVelocity") then
			v:Destroy()
		end
	end
	local clone = Entry.VFX.VFXpart:Clone()
	clone.Parent = Folder
	clone.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(0.6108652381980153, 0, 0)
	game.Debris:AddItem(clone, 4)
	var3_upvw.applyVFX(Entry.VFX.JumpVFX, clone)
	local BodyVelocity = Instance.new("BodyVelocity", arg1.Torso)
	BodyVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
	BodyVelocity.Velocity = Vector3.new(0, 0, 0)
	game.Debris:AddItem(BodyVelocity, 2)
	TweenService_upvr:Create(HumanoidRootPart, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		CFrame = HumanoidRootPart.CFrame + HumanoidRootPart.CFrame.LookVector * -12 + Vector3.new(0, 5, 0);
	}):Play()
	task.wait(0.35)
	game.Debris:AddItem(BodyVelocity, 0.4)
	ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Entry", {
		ClientCF = HumanoidRootPart.CFrame;
	})
	TweenService_upvr:Create(HumanoidRootPart, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		CFrame = HumanoidRootPart.CFrame + HumanoidRootPart.CFrame.LookVector * 12 + Vector3.new(0, -5, 0);
	}):Play()
end
return module