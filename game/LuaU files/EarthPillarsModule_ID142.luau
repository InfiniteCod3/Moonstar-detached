-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:45
-- Luau version 6, Types version 3
-- Time taken: 0.049074 seconds

local module_upvr = {
	Cooldown = 20;
	GlobalCD = 1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 17
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
	local Earth_Pillars_upvr = ReplicatedStorage_upvr.Skills["Earth Hammer"]["Earth Pillars"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Earth_Pillars_upvr.Animation)
	any_LoadAnimation_result1:Play()
	local Earth_Hammer_upvr = arg1:FindFirstChild("Earth Hammer")
	any_LoadAnimation_result1.Stopped:Connect(function() -- Line 33
		--[[ Upvalues[1]:
			[1]: Earth_Hammer_upvr (readonly)
		]]
		Earth_Hammer_upvr.TrailAtt.Trail.Enabled = false
	end)
	any_LoadAnimation_result1:AdjustSpeed(1)
	local clone_3_upvr = Earth_Pillars_upvr.Part.sounds:Clone()
	clone_3_upvr.Parent = arg1.Torso
	var2_upvw.applyDebris(clone_3_upvr, 10)
	var2_upvw.applyStatus(arg1, "Freeze", 1)
	var2_upvw.applyStatus(arg1, "CombatStun", 2)
	any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 47
		--[[ Upvalues[1]:
			[1]: clone_3_upvr (readonly)
		]]
		if clone_3_upvr:FindFirstChild(arg1_2) then
			for _, v in clone_3_upvr:GetChildren() do
				if v.Name == arg1_2 then
					v:Play()
				end
			end
		else
			print(arg1_2)
		end
	end)
	var2_upvw.changeFov(arg1, 90, 0.6, 3)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	any_LoadAnimation_result1:GetMarkerReachedSignal("stomp"):Connect(function() -- Line 61
		--[[ Upvalues[7]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: clone_3_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: Earth_Pillars_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
		]]
		-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
		var2_upvw.applyStatus(arg1, "AutoRotate", 0.3)
		clone_3_upvr.smash:Play()
		local var71 = arg1["Right Leg"].Position + HumanoidRootPart_upvr.CFrame.LookVector * 2
		local clone_4 = Earth_Pillars_upvr.SmashVfx:Clone()
		clone_4.Parent = Folder_upvr
		clone_4.Position = var71
		var2_upvw.EmitAllDescendants(clone_4)
		var2_upvw.applyDebris(clone_4, 5)
		local function screenEffects(arg1_3) -- Line 73
			--[[ Upvalues[1]:
				[1]: var2_upvw (copied, read and write)
			]]
			var2_upvw.changeFov(arg1_3, 55, 0.01, 0.9)
			var2_upvw.camShake(arg1_3, "SmallBump")
			var2_upvw.flashScreen(arg1_3, Color3.new(0.478431, 0.478431, 0.478431), 0.25)
		end
		screenEffects(arg1)
		var2_upvw.crater(1, var71, 2.5, 0.5)
		var2_upvw.crater(1, var71, 2, 0.12)
		var2_upvw.CreateDebris(var71, 8, 0.75, 0.9, 0.1)
		local clone_6 = Earth_Pillars_upvr.Hitbox:Clone()
		clone_6.Parent = Folder_upvr
		clone_6.Position = var71
		var2_upvw.applyDebris(clone_6, 1)
		for _, v_2 in var2_upvw.findEnemiesPart(clone_6, true), nil do
			screenEffects(v_2)
			var2_upvw.Knockback(v_2, var71, 4, 15)
			var2_upvw.applyStatus(v_2, "Ragdoll", 1.2)
			var2_upvw.applyDamage(v_2, 8)
		end
		local clone_9_upvr = Earth_Pillars_upvr.PillarParts:Clone()
		clone_9_upvr.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * -6
		clone_9_upvr.Parent = Folder_upvr
		for _, v_3 in clone_9_upvr:GetDescendants() do
			if v_3:IsA("BasePart") and v_3.Parent ~= clone_9_upvr then
				v_3.Transparency = 1
			end
		end
		task.wait()
		for i_4 = 1, 8 do
			if clone_9_upvr:FindFirstChild(i_4) then
				local SOME_upvr = clone_9_upvr:FindFirstChild(i_4)
				SOME_upvr.Anchored = true
				local workspace_Raycast_result1 = workspace:Raycast(SOME_upvr.Position, SOME_upvr.CFrame.UpVector * -15, var2_upvw.raycastParams)
				if workspace_Raycast_result1 then
					for _, v_4 in SOME_upvr:GetChildren() do
						if v_4:IsA("BasePart") then
							v_4.Transparency = 0
						end
					end
					var2_upvw.CreateDebris(workspace_Raycast_result1.Position, 5, 1.2, 0.7, 0.2)
					SOME_upvr.CFrame = CFrame.new(workspace_Raycast_result1.Position + SOME_upvr.CFrame.UpVector * -8) * SOME_upvr.CFrame - SOME_upvr.CFrame.p
					local any_Create_result1_2 = TweenService_upvr:Create(SOME_upvr, TweenInfo.new(0.2), {
						CFrame = CFrame.new(workspace_Raycast_result1.Position + SOME_upvr.CFrame.UpVector * 8) * SOME_upvr.CFrame - SOME_upvr.CFrame.p;
					})
					any_Create_result1_2:Play()
					local tbl_upvr = {}
					local tbl_upvr_2 = {}
					any_Create_result1_2.Completed:Connect(function() -- Line 132
						--[[ Upvalues[9]:
							[1]: var2_upvw (copied, read and write)
							[2]: SOME_upvr (readonly)
							[3]: tbl_upvr (readonly)
							[4]: TweenService_upvr (copied, readonly)
							[5]: Earth_Pillars_upvr (copied, readonly)
							[6]: Folder_upvr (copied, readonly)
							[7]: arg1 (copied, readonly)
							[8]: tbl_upvr_2 (readonly)
							[9]: clone_9_upvr (readonly)
						]]
						for _, v_5 in var2_upvw.findEnemiesPart(SOME_upvr, true), nil do
							if not table.find(tbl_upvr, v_5) then
								table.insert(tbl_upvr, v_5)
								var2_upvw.applyDamage(v_5, 10)
								var2_upvw.applyStatus(v_5, "Ragdoll", 1)
								var2_upvw.Knockback(v_5, SOME_upvr.Position + SOME_upvr.CFrame.UpVector * -8, 0, 50)
							end
						end
						task.wait(0.5)
						for _, v_6_upvr in SOME_upvr:GetChildren() do
							if v_6_upvr:IsA("BasePart") then
								v_6_upvr.Material = "Neon"
								local any_Create_result1 = TweenService_upvr:Create(v_6_upvr, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
									Color = Color3.new(1, 1, 1);
								})
								any_Create_result1:Play()
								any_Create_result1.Completed:Connect(function() -- Line 149
									--[[ Upvalues[1]:
										[1]: v_6_upvr (readonly)
									]]
									v_6_upvr:Destroy()
								end)
							end
						end
						local clone = Earth_Pillars_upvr.PillarSfx2.Charge:Clone()
						clone.Parent = SOME_upvr
						clone.PlaybackSpeed += math.random(-1, 1) * 0.05
						clone:Play()
						task.wait(0.75)
						local clone_7_upvr = Earth_Pillars_upvr.PillarSfx2.Explosion:Clone()
						clone_7_upvr.Parent = SOME_upvr
						clone_7_upvr.PlaybackSpeed += math.random(-2, 2) * 0.1
						clone_7_upvr:Play()
						task.delay(2, function() -- Line 168
							--[[ Upvalues[2]:
								[1]: TweenService_upvr (copied, readonly)
								[2]: clone_7_upvr (readonly)
							]]
							TweenService_upvr:Create(clone_7_upvr, TweenInfo.new(0.45), {
								Volume = 0;
							}):Play()
						end)
						local clone_5 = Earth_Pillars_upvr.vfx:Clone()
						clone_5.Parent = Folder_upvr
						clone_5.CFrame = SOME_upvr.CFrame
						var2_upvw.EmitAllDescendants(clone_5)
						local clone_2 = Earth_Pillars_upvr.ExplosionHitbox:Clone()
						clone_2.Parent = Folder_upvr
						clone_2.CFrame = clone_5.CFrame
						var2_upvw.camShake(arg1, "SmallBump")
						var2_upvw.Blur(arg1, 20, 0.45)
						var2_upvw.changeFov(arg1, 55, 0.01, 1)
						for _, v_7 in var2_upvw.findEnemiesPart(clone_2, true), nil do
							if not table.find(tbl_upvr_2, v_7) then
								table.insert(tbl_upvr_2, v_7)
								var2_upvw.camShake(v_7, "SmallBump")
								var2_upvw.Blur(v_7, 20, 0.45)
								var2_upvw.changeFov(v_7, 55, 0.01, 1)
								var2_upvw.Knockback(v_7, clone_9_upvr.Position, 25, 20)
								var2_upvw.applyStatus(v_7, "Ragdoll", 1)
								var2_upvw.applyDamage(v_7, 5)
							end
						end
					end)
					var2_upvw.camShake(arg1, "SmallBump")
					for _, v_8 in Earth_Pillars_upvr.PillarSfx:GetChildren() do
						local clone_8 = v_8:Clone()
						clone_8.Parent = SOME_upvr
						clone_8.PlaybackSpeed += math.random(-1, 1) * 0.1
						clone_8:Play()
						local var110
					end
					for _, v_9 in var110:GetChildren() do
						if v_9.Name == "TopMaterial" then
							v_9.Material = workspace_Raycast_result1.Instance.Material
							for _, v_10 in workspace_Raycast_result1.Instance:GetChildren() do
								if v_10:IsA("Texture") then
									v_10:Clone().Parent = v_9
								end
							end
							v_9.Color = workspace_Raycast_result1.Instance.Color
							v_9.MaterialVariant = workspace_Raycast_result1.Instance.MaterialVariant
						end
					end
				else
					var110:Destroy()
				end
				task.wait(0.04)
			end
		end
	end)
end
return module_upvr