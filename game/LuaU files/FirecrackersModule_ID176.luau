-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:11
-- Luau version 6, Types version 3
-- Time taken: 0.009416 seconds

local module_upvr = {
	Cooldown = 25;
	GlobalCD = 0.1;
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
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown + 10)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Firecrackers_upvr = ReplicatedStorage_upvr.Skills["Firework Rapier"].Firecrackers
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Firecrackers_upvr.Animation)
	any_LoadAnimation_result1:Play()
	local Firework_Rapier_upvr = arg1:FindFirstChild("Firework Rapier")
	local function ToggleTrails_upvr(arg1_2) -- Line 34, Named "ToggleTrails"
		--[[ Upvalues[1]:
			[1]: Firework_Rapier_upvr (readonly)
		]]
		for _, v in Firework_Rapier_upvr:GetDescendants() do
			if v:IsA("Trail") and v.Name == "Trail" then
				v.Enabled = arg1_2
			end
		end
	end
	ToggleTrails_upvr(true)
	any_LoadAnimation_result1.Stopped:Connect(function() -- Line 43
		--[[ Upvalues[1]:
			[1]: ToggleTrails_upvr (readonly)
		]]
		ToggleTrails_upvr(false)
	end)
	local clone_3 = Firecrackers_upvr.SwingCharge:Clone()
	clone_3.Parent = HumanoidRootPart_upvr
	clone_3:Play()
	var2_upvw.applyDebris(clone_3, 5)
	any_LoadAnimation_result1:GetMarkerReachedSignal("swing"):Connect(function() -- Line 53
		--[[ Upvalues[3]:
			[1]: Firecrackers_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
		]]
		local clone = Firecrackers_upvr.Swing:Clone()
		clone.Parent = HumanoidRootPart_upvr
		clone:Play()
		var2_upvw.applyDebris(clone, 5)
	end)
	var2_upvw.applyStatus(arg1, "Slowed", 1.4)
	var2_upvw.applyStatus(arg1, "GlobalCD", 1.4)
	var2_upvw.changeFov(arg1, 90, 0.5, 3)
	any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function() -- Line 66
		--[[ Upvalues[6]:
			[1]: Firecrackers_upvr (readonly)
			[2]: Folder_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: arg1 (readonly)
			[6]: TweenService_upvr (copied, readonly)
		]]
		local clone_2_upvr = Firecrackers_upvr.SlashVFX:Clone()
		clone_2_upvr.Parent = Folder_upvr
		clone_2_upvr.CFrame = HumanoidRootPart_upvr.CFrame
		var2_upvw.EmitAllDescendants(clone_2_upvr.Attachment)
		var2_upvw.applyDebris(clone_2_upvr, 5)
		for _, v_2 in clone_2_upvr.Attachment:GetChildren() do
			if v_2:IsA("Sound") then
				v_2:Play()
			end
		end
		var2_upvw.applyStatus(arg1, "GlobalCD", 0.5)
		var2_upvw.applyStatus(arg1, "Freeze", 0.5)
		var2_upvw.applyStatus(arg1, "AutoRotate", 0.5)
		var2_upvw.camShake(arg1, "SmallBump")
		var2_upvw.changeFov(arg1, 60, 0.1, 2)
		var2_upvw.flashScreen(arg1, Color3.new(1, 0.737255, 0.411765), 1)
		var2_upvw.Blur(arg1, 20, 0.4)
		task.spawn(function() -- Line 87
			--[[ Upvalues[6]:
				[1]: clone_2_upvr (readonly)
				[2]: Firecrackers_upvr (copied, readonly)
				[3]: Folder_upvr (copied, readonly)
				[4]: var2_upvw (copied, read and write)
				[5]: TweenService_upvr (copied, readonly)
				[6]: arg1 (copied, readonly)
			]]
			for _ = 1, 20 do
				local CFrame_upvr = clone_2_upvr.CFrame
				local clone_upvr = Firecrackers_upvr.FireworkBall:Clone()
				clone_upvr.Parent = Folder_upvr
				local shoot = clone_upvr.shoot
				shoot.PlaybackSpeed += math.random(-2, 2) * 0.1
				clone_upvr.shoot:Play()
				clone_upvr["sizzle sfx"]:Play()
				var2_upvw.applyDebris(clone_upvr, 7)
				clone_upvr.CFrame = CFrame_upvr * CFrame.Angles(math.rad(math.random(-25, 25)), math.rad(math.random(-25, 25)), math.rad(math.random(-25, 25)))
				local any_Create_result1 = TweenService_upvr:Create(clone_upvr, TweenInfo.new(math.random(4, 5) * 0.1, Enum.EasingStyle.Linear), {
					Position = clone_upvr.Position + clone_upvr.CFrame.LookVector * math.random(20, 45);
				})
				any_Create_result1:Play()
				any_Create_result1.Completed:Connect(function() -- Line 106
					--[[ Upvalues[4]:
						[1]: clone_upvr (readonly)
						[2]: var2_upvw (copied, read and write)
						[3]: arg1 (copied, readonly)
						[4]: CFrame_upvr (readonly)
					]]
					clone_upvr["sizzle sfx"]:Stop()
					var2_upvw.EmitAllDescendants(clone_upvr.FireworkBall.ExplosionVFX)
					for _, v_3 in clone_upvr.FireworkBall:GetDescendants() do
						if v_3:IsA("ParticleEmitter") or v_3:IsA("Trail") then
							v_3.Enabled = false
						end
					end
					local ExplodeSFX = clone_upvr.FireworkBall.ExplosionVFX.ExplodeSFX
					ExplodeSFX.PlaybackSpeed += math.random(-2, 2) * 0.1
					ExplodeSFX:Play()
					var2_upvw.camShake(arg1, "SmallBump")
					var2_upvw.flashScreen(arg1, Color3.new(1, 0.882353, 0.796078), 0.2)
					for _, v_4 in var2_upvw.findEnemiesMagnitude(clone_upvr.Position, 21, true), nil do
						if not var2_upvw.CheckBlock(v_4, false) then
							var2_upvw.applyDamage(v_4, 1)
							var2_upvw.applyStatus(v_4, "Stunned", 0.8)
							var2_upvw.Knockback(v_4, CFrame_upvr.p, 5, 2)
							var2_upvw.camShake(v_4, "SmallBump")
							var2_upvw.flashScreen(v_4, Color3.new(1, 0.882353, 0.796078), 0.2)
						end
					end
				end)
				task.wait(0.03)
			end
		end)
	end)
end
return module_upvr