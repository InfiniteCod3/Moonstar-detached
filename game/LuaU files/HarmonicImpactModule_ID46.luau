-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:54
-- Luau version 6, Types version 3
-- Time taken: 0.013383 seconds

local module_upvr = {
	Cooldown = 19;
	GlobalCD = 1.5;
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
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Harmonic_Impact_upvr = ReplicatedStorage_upvr.Skills.Harp["Harmonic Impact"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid"):LoadAnimation(Harmonic_Impact_upvr.Animation1)
	local clone_2 = Harmonic_Impact_upvr.hitbox:Clone()
	any_LoadAnimation_result1:AdjustSpeed(2)
	var2_upvw.applyStatus(arg1, "Freeze", 1.2)
	wait(0.3)
	any_LoadAnimation_result1:Play()
	local clone_5 = Harmonic_Impact_upvr.Harp:Clone()
	clone_5.Parent = HumanoidRootPart_upvr
	clone_5:Play()
	var2_upvw.applyDebris(clone_5, 6)
	local clone = Harmonic_Impact_upvr.Harp2:Clone()
	clone.Parent = HumanoidRootPart_upvr
	clone:Play()
	var2_upvw.applyDebris(clone, 6)
	local clone_4 = Harmonic_Impact_upvr.vfx:Clone()
	clone_4.Parent = Folder_upvr
	clone_4.Anchored = true
	clone_4.CFrame = HumanoidRootPart_upvr.CFrame
	game.Debris:AddItem(clone_4, 3)
	var2_upvw.EmitAllDescendants(clone_4)
	clone_2.Parent = Folder_upvr
	clone_2.Weld.Part0 = HumanoidRootPart_upvr
	clone_2.Weld.Part1 = clone_2
	game.Debris:AddItem(clone_2, 1.1)
	var2_upvw.camShake(arg1, "Bump")
	local any_findEnemiesPart_result1 = var2_upvw.findEnemiesPart(clone_2, true)
	if 0 < #any_findEnemiesPart_result1 then
		var2_upvw.applyStatus(arg1, "GlobalCD", 1.65)
	end
	for _, v_upvr in any_findEnemiesPart_result1 do
		if not require(ReplicatedStorage_upvr.Modules.PlayerStatus).FindTable("HyperArmor") then
			var2_upvw.camShake(v_upvr, "Bump")
			var2_upvw.applyDamage(v_upvr, 5)
			var2_upvw.applyStatus(v_upvr, "Stunned", 2.2)
			var2_upvw.applyStatus(v_upvr, "Ragdoll", 2.5)
			var2_upvw.applyStatus(v_upvr, "DashDB", 1.5)
			var2_upvw.Knockback(v_upvr, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -50, 100, 12)
			local any_LoadAnimation_result1_2_upvr = v_upvr.Humanoid:LoadAnimation(Harmonic_Impact_upvr.stun)
			any_LoadAnimation_result1_2_upvr:Play()
			any_LoadAnimation_result1_2_upvr:AdjustSpeed(0.1)
			task.delay(2, function() -- Line 79
				--[[ Upvalues[1]:
					[1]: any_LoadAnimation_result1_2_upvr (readonly)
				]]
				any_LoadAnimation_result1_2_upvr:Stop()
			end)
			task.delay(0.25, function() -- Line 83
				--[[ Upvalues[7]:
					[1]: v_upvr (readonly)
					[2]: Harmonic_Impact_upvr (readonly)
					[3]: Folder_upvr (readonly)
					[4]: HumanoidRootPart_upvr (readonly)
					[5]: TweenService_upvr (copied, readonly)
					[6]: var2_upvw (copied, read and write)
					[7]: arg1 (readonly)
				]]
				local BodyVelocity_upvr = Instance.new("BodyVelocity", v_upvr.Torso)
				BodyVelocity_upvr.Velocity = Vector3.new(0, 0, 0)
				BodyVelocity_upvr.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				game.Debris:AddItem(BodyVelocity_upvr, 6)
				task.delay(0.6, function() -- Line 89
					--[[ Upvalues[8]:
						[1]: Harmonic_Impact_upvr (copied, readonly)
						[2]: Folder_upvr (copied, readonly)
						[3]: HumanoidRootPart_upvr (copied, readonly)
						[4]: v_upvr (copied, readonly)
						[5]: TweenService_upvr (copied, readonly)
						[6]: var2_upvw (copied, read and write)
						[7]: arg1 (copied, readonly)
						[8]: BodyVelocity_upvr (readonly)
					]]
					-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
					local clone_upvr = Harmonic_Impact_upvr.Parent["Harmonic Impact"].String:Clone()
					clone_upvr.summon:Play()
					clone_upvr.Parent = Folder_upvr
					clone_upvr.Anchored = true
					clone_upvr.CFrame = HumanoidRootPart_upvr.CFrame * CFrame.new(math.random(-10, 10), 5, 5)
					clone_upvr.CFrame *= CFrame.Angles(0, (math.pi/2), 0)
					game.Debris:AddItem(clone_upvr, 10)
					for _, v_2 in clone_upvr:GetChildren() do
						if v_2:IsA("Attachment") then
							for _, v_3 in v_2:GetChildren() do
								if v_3:IsA("ParticleEmitter") then
									v_3.Enabled = true
								end
							end
						end
					end
					for i_4, v_4 in clone_upvr:GetChildren() do
						if v_4:IsA("ParticleEmitter") then
							v_4.Enabled = true
						end
					end
					for _ = 1, 20 do
						i_4 = task.wait
						i_4()
						v_4 = CFrame.lookAt(clone_upvr.Position, v_upvr.HumanoidRootPart.Position)
						i_4 = v_4 * CFrame.Angles(0, (math.pi/2), 0)
						clone_upvr.CFrame = i_4
					end
					local any_Create_result1 = TweenService_upvr:Create(clone_upvr, TweenInfo.new((clone_upvr.Position - v_upvr.HumanoidRootPart.Position).Magnitude * 0.005, Enum.EasingStyle.Linear), {
						CFrame = CFrame.new(v_upvr.HumanoidRootPart.Position) * clone_upvr.CFrame - clone_upvr.CFrame.p;
					})
					any_Create_result1:Play()
					clone_upvr.Swoosh:Play()
					any_Create_result1.Completed:Connect(function() -- Line 124
						--[[ Upvalues[7]:
							[1]: Harmonic_Impact_upvr (copied, readonly)
							[2]: v_upvr (copied, readonly)
							[3]: var2_upvw (copied, read and write)
							[4]: arg1 (copied, readonly)
							[5]: BodyVelocity_upvr (copied, readonly)
							[6]: HumanoidRootPart_upvr (copied, readonly)
							[7]: clone_upvr (readonly)
						]]
						local clone_3 = Harmonic_Impact_upvr.explo.explo:Clone()
						clone_3.Parent = v_upvr.HumanoidRootPart
						var2_upvw.EmitAllDescendants(clone_3)
						var2_upvw.applyDebris(clone_3, 6)
						var2_upvw.camShake(arg1, "Bump")
						var2_upvw.camShake(v_upvr, "Bump")
						var2_upvw.applyDamage(v_upvr, 15)
						var2_upvw.applyStatus(v_upvr, "Stunned", 1)
						BodyVelocity_upvr:Destroy()
						var2_upvw.Knockback(v_upvr, HumanoidRootPart_upvr.Position, -6, 15)
						var2_upvw.applyStatus(v_upvr, "Ragdoll", 1)
						for _, v_5 in clone_3:GetChildren() do
							if v_5:IsA("Sound") then
								v_5.PlaybackSpeed += math.random(-1, 1) * 0.1
								v_5:Play()
							end
						end
						for _, v_6 in clone_upvr:GetChildren() do
							if v_6:IsA("ParticleEmitter") or v_6:IsA("Trail") then
								v_6.Enabled = false
							end
						end
						var2_upvw.applyDebris(clone_upvr, 2)
					end)
				end)
			end)
		else
			any_LoadAnimation_result1_2_upvr = var2_upvw.applyDamage
			any_LoadAnimation_result1_2_upvr(v_upvr, 5)
		end
	end
end
return module_upvr