-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:12:56
-- Luau version 6, Types version 3
-- Time taken: 0.012865 seconds

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
	local Concept = ReplicatedStorage_upvr.Skills["Basic Sword"].Ultimate.Concept
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Concept.Animation)
	any_LoadAnimation_result1:Play()
	local clone_upvr = Concept.Indicator:Clone()
	clone_upvr.Parent = Folder
	clone_upvr.CFrame = CFrame.new(HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * 25) * clone_upvr.CFrame - clone_upvr.CFrame.p
	game.Debris:AddItem(clone_upvr, 4)
	local descendants, NONE, _ = clone_upvr:GetDescendants()
	local var18
	for _, v in descendants, NONE, var18 do
		if v:IsA("ParticleEmitter") then
			v.Enabled = true
		end
	end
	local var19_upvw = false
	local function Despawn_upvr() -- Line 44, Named "Despawn"
		--[[ Upvalues[3]:
			[1]: var19_upvw (read and write)
			[2]: clone_upvr (readonly)
			[3]: TweenService_upvr (copied, readonly)
		]]
		if var19_upvw then
		else
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
		end
	end
	var18 = var3_upvw.conTimer
	var18(any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function() -- Line 58
		--[[ Upvalues[1]:
			[1]: Despawn_upvr (readonly)
		]]
		Despawn_upvr()
	end), 10)
	var18 = var3_upvw.conTimer
	var18(any_LoadAnimation_result1.Stopped:Connect(function() -- Line 62
		--[[ Upvalues[1]:
			[1]: Despawn_upvr (readonly)
		]]
		Despawn_upvr()
	end), 10)
	var18 = false
	while task.wait() and clone_upvr.Parent and not var19_upvw do
		if PlayerStatus_upvr.FindStatus(arg1, "Stunned") or PlayerStatus_upvr.FindStatus(arg1, "Ragdoll") then
			Despawn_upvr()
			var18 = true
			return
		end
		local var28 = HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * 25
		local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart.Position, HumanoidRootPart.CFrame.LookVector * 25, var3_upvw.raycastParams)
		if workspace_Raycast_result1 then
			var28 = workspace_Raycast_result1.Position
		end
		TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.3), {
			CFrame = CFrame.new(var28) * clone_upvr.CFrame - clone_upvr.CFrame.p;
		}):Play()
	end
	if var18 then
	else
		ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Concept", {
			TeleportPosition = clone_upvr.Position;
		})
	end
end
return module