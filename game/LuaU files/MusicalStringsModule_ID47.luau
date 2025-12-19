-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:55
-- Luau version 6, Types version 3
-- Time taken: 0.009797 seconds

local module_upvr = {
	Cooldown = 20;
	GlobalCD = 0.1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 12
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local Harp_upvr = ReplicatedStorage_upvr.Skills.Harp
	local Musical_Strings_upvr = Harp_upvr["Musical Strings"]
	local clone = Musical_Strings_upvr.Harp:Clone()
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid"):LoadAnimation(Musical_Strings_upvr.Animation1)
	any_LoadAnimation_result1:AdjustSpeed(3.25)
	any_LoadAnimation_result1:Play()
	var2_upvw.applyStatus(arg1, "Slowed", 1)
	clone.Parent = HumanoidRootPart
	clone:Play()
	var2_upvw.applyDebris(clone, 6)
	clone.Volume = 0
	TweenService_upvr:Create(clone, TweenInfo.new(1), {
		Volume = clone.Volume;
	}):Play()
	local clone_5 = Musical_Strings_upvr.HarpPlay:Clone()
	clone_5.Parent = HumanoidRootPart
	clone_5:Play()
	var2_upvw.applyDebris(clone_5, 6)
	local clone_3 = Musical_Strings_upvr.Harp3:Clone()
	clone_3.Parent = HumanoidRootPart
	clone_3:Play()
	var2_upvw.applyDebris(clone_3, 6)
	var2_upvw.camShake(arg1, "Bump")
	var2_upvw.changeFov(arg1, 60, 0.4, 1)
	local clone_4 = Harp_upvr["Musical Strings"].Shockwave:Clone()
	clone_4.Parent = Folder_upvr
	clone_4.Weld.Part0 = HumanoidRootPart
	clone_4.Weld.Part1 = clone_4
	var2_upvw.EmitAllDescendants(clone_4)
	for _, v_upvr in var2_upvw.findEnemiesMagnitude(HumanoidRootPart.Position, 20, true), nil do
		local clone_6_upvr = Musical_Strings_upvr.String:Clone()
		clone_6_upvr.summon:Play()
		local summon = clone_6_upvr.summon
		summon.PlaybackSpeed += math.random(-3, 3) * 0.05
		clone_6_upvr.Parent = Folder_upvr
		clone_6_upvr.Anchored = true
		clone_6_upvr.CFrame = HumanoidRootPart.CFrame * CFrame.new(math.random(-10, 10), 5, 5)
		clone_6_upvr.CFrame *= CFrame.Angles(0, (math.pi/2), 0)
		game.Debris:AddItem(clone_6_upvr, 10)
		for _, v_2 in clone_6_upvr:GetChildren() do
			if v_2:IsA("Attachment") then
				for _, v_3 in v_2:GetChildren() do
					if v_3:IsA("ParticleEmitter") then
						v_3.Enabled = true
					end
				end
			end
		end
		for _, v_4 in clone_6_upvr:GetChildren() do
			if v_4:IsA("ParticleEmitter") then
				v_4.Enabled = true
			end
		end
		coroutine.wrap(function() -- Line 88
			--[[ Upvalues[3]:
				[1]: TweenService_upvr (copied, readonly)
				[2]: clone_6_upvr (readonly)
				[3]: v_upvr (readonly)
			]]
			for _ = 1, 8.333333333333334 do
				TweenService_upvr:Create(clone_6_upvr, TweenInfo.new(0.05), {
					CFrame = CFrame.new(clone_6_upvr.Position, v_upvr.HumanoidRootPart.Position - Vector3.new(0, 3, 0)) * CFrame.Angles(0, (math.pi/2), 0);
				}):Play()
				task.wait()
			end
		end)()
		local tbl_upvr = {}
		task.delay(0.25, function() -- Line 98
			--[[ Upvalues[9]:
				[1]: clone_6_upvr (readonly)
				[2]: var2_upvw (copied, read and write)
				[3]: TweenService_upvr (copied, readonly)
				[4]: Harp_upvr (readonly)
				[5]: Folder_upvr (readonly)
				[6]: Musical_Strings_upvr (readonly)
				[7]: v_upvr (readonly)
				[8]: arg1 (readonly)
				[9]: tbl_upvr (readonly)
			]]
			local workspace_Raycast_result1_upvr = workspace:Raycast(clone_6_upvr.Position, clone_6_upvr.CFrame.RightVector * 500, var2_upvw.raycastParams)
			if workspace_Raycast_result1_upvr then
				local Position = workspace_Raycast_result1_upvr.Position
				local any_Create_result1 = TweenService_upvr:Create(clone_6_upvr, TweenInfo.new((clone_6_upvr.Position - Position).Magnitude * 0.005, Enum.EasingStyle.Linear), {
					Position = Position;
				})
				any_Create_result1:Play()
				clone_6_upvr.Swoosh:Play()
				any_Create_result1.Completed:Connect(function() -- Line 106
					--[[ Upvalues[10]:
						[1]: TweenService_upvr (copied, readonly)
						[2]: clone_6_upvr (copied, readonly)
						[3]: Harp_upvr (copied, readonly)
						[4]: Folder_upvr (copied, readonly)
						[5]: Musical_Strings_upvr (copied, readonly)
						[6]: workspace_Raycast_result1_upvr (readonly)
						[7]: var2_upvw (copied, read and write)
						[8]: v_upvr (copied, readonly)
						[9]: arg1 (copied, readonly)
						[10]: tbl_upvr (copied, readonly)
					]]
					TweenService_upvr:Create(clone_6_upvr.Swoosh, TweenInfo.new(0.5), {
						Volume = 0;
					}):Play()
					clone_6_upvr.groundhit:Play()
					local clone_7_upvr = Harp_upvr["Musical Strings"].TimeBomb:Clone()
					clone_7_upvr.Parent = Folder_upvr
					clone_7_upvr.CFrame = clone_6_upvr.CFrame
					task.delay(1, function() -- Line 114
						--[[ Upvalues[9]:
							[1]: clone_6_upvr (copied, readonly)
							[2]: clone_7_upvr (readonly)
							[3]: Musical_Strings_upvr (copied, readonly)
							[4]: Folder_upvr (copied, readonly)
							[5]: workspace_Raycast_result1_upvr (copied, readonly)
							[6]: var2_upvw (copied, read and write)
							[7]: v_upvr (copied, readonly)
							[8]: arg1 (copied, readonly)
							[9]: tbl_upvr (copied, readonly)
						]]
						clone_6_upvr:Destroy()
						clone_7_upvr:Destroy()
						local clone_2 = Musical_Strings_upvr.vfx:Clone()
						clone_2.Parent = Folder_upvr
						clone_2.Position = workspace_Raycast_result1_upvr.Position
						var2_upvw.applyDebris(clone_2, 6)
						var2_upvw.EmitAllDescendants(clone_2.explo)
						clone_2.explo.Explosion:Play()
						var2_upvw.camShake(v_upvr, "Bump")
						var2_upvw.camShake(arg1, "Bump")
						for _, v_5 in var2_upvw.findEnemiesMagnitude(clone_6_upvr.Position, 20, true), nil do
							if not table.find(tbl_upvr, v_5) then
								table.insert(tbl_upvr, v_5)
								var2_upvw.applyDamage(v_5, 12)
								var2_upvw.applyStatus(v_5, "Stunned", 0.65)
								var2_upvw.Knockback(v_5, workspace_Raycast_result1_upvr.Position, 50, 12)
								var2_upvw.applyStatus(v_5, "Ragdoll", 1.6)
								var2_upvw.CreateDebris(workspace_Raycast_result1_upvr.Position, 6, 0.95, 0.9, 0.1)
								var2_upvw.crater(1, workspace_Raycast_result1_upvr.Position, 2.5, 0.9)
							end
						end
						for _, v_6 in clone_6_upvr:GetDescendants() do
							if v_6:IsA("ParticleEmitter") then
								v_6.Enabled = false
							end
						end
					end)
				end)
			else
				clone_6_upvr:Destroy()
			end
		end)
	end
end
return module_upvr