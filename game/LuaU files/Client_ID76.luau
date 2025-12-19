-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:51
-- Luau version 6, Types version 3
-- Time taken: 0.054358 seconds

local module = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: TweenService_upvr (readonly)
		[4]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 10)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local clone_upvr = ReplicatedStorage_upvr.Skills["Snow Blasters"]["Snow Cloak"].TeleportIndicator:Clone()
	clone_upvr.Parent = Folder
	clone_upvr.CFrame = CFrame.new(HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * 32) * clone_upvr.CFrame - clone_upvr.CFrame.p
	game.Debris:AddItem(clone_upvr, 4)
	clone_upvr.Size = Vector3.new(1, 1, 1)
	TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.3), {
		Size = clone_upvr.Size;
	}):Play()
	local descendants, NONE, _ = clone_upvr:GetDescendants()
	local var17
	for _, v in descendants, NONE, var17 do
		if v:IsA("ParticleEmitter") then
			v.Enabled = true
		end
	end
	clone_upvr.Blizzard:Play()
	var17 = 0
	clone_upvr.Blizzard.Volume = var17
	TweenService_upvr:Create(clone_upvr.Blizzard, TweenInfo.new(0.75), {
		Volume = clone_upvr.Blizzard.Volume;
	}):Play()
	local var19_upvw = false
	var17 = task.delay
	var17(0.75, function() -- Line 51
		--[[ Upvalues[3]:
			[1]: var19_upvw (read and write)
			[2]: clone_upvr (readonly)
			[3]: TweenService_upvr (copied, readonly)
		]]
		var19_upvw = true
		clone_upvr.Transparency = 1
		for _, v_2 in clone_upvr:GetDescendants() do
			if v_2:IsA("ParticleEmitter") then
				v_2:Destroy()
			elseif v_2:IsA("Sound") then
				TweenService_upvr:Create(v_2, TweenInfo.new(0.8), {
					Volume = 0;
				}):Play()
			end
		end
	end)
	var17 = false
	while task.wait() and clone_upvr.Parent and not var19_upvw do
		if PlayerStatus_upvr.FindStatus(arg1, "Stunned") or PlayerStatus_upvr.FindStatus(arg1, "Ragdoll") then
			var17 = true
			var19_upvw = true
			return
		end
		local var27 = HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * 32
		local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart.Position, HumanoidRootPart.CFrame.LookVector * 32, var3_upvw.raycastParams)
		if workspace_Raycast_result1 then
			var27 = workspace_Raycast_result1.Position
		end
		TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.3), {
			CFrame = CFrame.new(var27) * clone_upvr.CFrame - clone_upvr.CFrame.p;
		}):Play()
	end
	if var17 then
	else
		ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("SnowCloak", {
			TeleportPosition = clone_upvr.Position;
		})
	end
end
return module