-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:14
-- Luau version 6, Types version 3
-- Time taken: 0.013694 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 10
module_upvr.GlobalCD = 1.4
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Brute_upvr = ReplicatedStorage_upvr.Skills["Titans Edge"].Ultimate.Brute
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Brute_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(0.8)
	var3_upvw.applyStatus(arg1, "Freeze", 0.9)
	var3_upvw.applyStatus(arg1, "GlobalCD", 0.9)
	var3_upvw.changeFov(arg1, 80, 0.5, 5)
	var3_upvw.applySound(Brute_upvr.ChargeSFX, HumanoidRootPart_upvr)
	var3_upvw.applySound(Brute_upvr.Swing, HumanoidRootPart_upvr)
	local tbl_upvr = {}
	local var10_upvw
	local ThemeSong_upvr = HumanoidRootPart_upvr:FindFirstChild("ThemeSong")
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("stomp"):Connect(function() -- Line 47
		--[[ Upvalues[12]:
			[1]: HumanoidRootPart_upvr (readonly)
			[2]: var3_upvw (copied, read and write)
			[3]: any_LoadAnimation_result1_upvr (readonly)
			[4]: Brute_upvr (readonly)
			[5]: arg1 (readonly)
			[6]: var10_upvw (read and write)
			[7]: Folder_upvr (readonly)
			[8]: TweenService_upvr (copied, readonly)
			[9]: ThemeSong_upvr (readonly)
			[10]: tbl_upvr (readonly)
			[11]: ReplicatedStorage_upvr (copied, readonly)
			[12]: arg2 (readonly)
		]]
		if not workspace:Raycast(HumanoidRootPart_upvr.Position, Vector3.new(0, -6, 0), var3_upvw.raycastParams) then
			any_LoadAnimation_result1_upvr:Stop()
		else
			local clone = Brute_upvr.VFX.StompVFX:Clone()
			clone.Parent = HumanoidRootPart_upvr
			var3_upvw.EmitAllDescendants(clone)
			var3_upvw.applyDebris(clone, 5)
			var3_upvw.applyStatus(arg1, "Freeze", 2.5)
			var3_upvw.applyStatus(arg1, "GlobalCD", 2.5)
			var3_upvw.applyStatus(arg1, "AutoRotate", 2.5)
			var3_upvw.applyStatus(arg1, "IFrames", 2.5)
			var3_upvw.camShake(arg1, "Bump")
			var3_upvw.changeFov(arg1, 50, 0, 1)
			var10_upvw = Brute_upvr.Rock:Clone()
			var10_upvw.Parent = Folder_upvr
			var10_upvw.CFrame = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 35 - Vector3.new(0, 50, 0)) * CFrame.Angles(math.pi, 0, 0)
			TweenService_upvr:Create(var10_upvw, TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
				CFrame = var10_upvw.CFrame + Vector3.new(0, 50, 0);
			}):Play()
			HumanoidRootPart_upvr.CFrame = CFrame.lookAt(HumanoidRootPart_upvr.Position, var10_upvw.Position)
			var3_upvw.applyDebris(var10_upvw, 12)
			var3_upvw.applySound(Brute_upvr.RockKick, HumanoidRootPart_upvr)
			var3_upvw.applySound(Brute_upvr.ChargeSFX2, HumanoidRootPart_upvr)
			var3_upvw.applySound(Brute_upvr.WindSFX, HumanoidRootPart_upvr)
			var3_upvw.applySound(Brute_upvr.Swing2, HumanoidRootPart_upvr)
			TweenService_upvr:Create(ThemeSong_upvr, TweenInfo.new(0.5), {
				Volume = 0;
			}):Play()
			task.delay(2.5, function() -- Line 78
				--[[ Upvalues[2]:
					[1]: TweenService_upvr (copied, readonly)
					[2]: ThemeSong_upvr (copied, readonly)
				]]
				TweenService_upvr:Create(ThemeSong_upvr, TweenInfo.new(1), {
					Volume = ThemeSong_upvr:GetAttribute("ogVolume");
				}):Play()
			end)
			for _ = 1, 10 do
				HumanoidRootPart_upvr.CFrame = CFrame.lookAt(HumanoidRootPart_upvr.Position, var10_upvw.Position)
				for _, v_4 in var3_upvw.findEnemiesPart(var10_upvw, true), nil do
					if not table.find(tbl_upvr, v_4) and not var3_upvw.CheckBlock(v_4, true) then
						table.insert(tbl_upvr, v_4)
						var3_upvw.unragdoll(v_4)
						var3_upvw.applyDamage(v_4, 10)
						var3_upvw.applyStatus(v_4, "Stunned", 3)
						ReplicatedStorage_upvr.Remotes.ClientInfo:FireClient(arg2, "Brute", v_4)
						local Motor6D = Instance.new("Motor6D", var10_upvw)
						Motor6D.Part0 = v_4.HumanoidRootPart
						Motor6D.Part1 = var10_upvw
						Motor6D.C0 = CFrame.new(Vector3.new(math.random(-10, 10), math.random(-15, -8), math.random(-10, 10))) * v_4.HumanoidRootPart.CFrame - v_4.HumanoidRootPart.CFrame.p
						var3_upvw.applyDebris(Motor6D, 3.5)
					end
				end
				task.wait()
			end
		end
	end), module_upvr.Cooldown)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slash"):Connect(function() -- Line 110
		--[[ Upvalues[7]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
			[2]: var3_upvw (copied, read and write)
			[3]: arg1 (readonly)
			[4]: Brute_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: var10_upvw (read and write)
			[7]: tbl_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:AdjustSpeed(0.1)
		task.delay(1, function() -- Line 112
			--[[ Upvalues[1]:
				[1]: any_LoadAnimation_result1_upvr (copied, readonly)
			]]
			any_LoadAnimation_result1_upvr:AdjustSpeed(0.8)
		end)
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.changeFov(arg1, 60, 0, 3)
		local clone_2 = Brute_upvr.VFX.SlashVFX:Clone()
		clone_2.Parent = HumanoidRootPart_upvr
		var3_upvw.EmitAllDescendants(clone_2)
		var3_upvw.applyDebris(clone_2, 5)
		var3_upvw.applySound(Brute_upvr.SlashSFX, HumanoidRootPart_upvr)
		var3_upvw.applySound(Brute_upvr.Explosion2, var10_upvw)
		task.wait(1)
		var3_upvw.impactFrame(arg1, 0.05, Color3.new(1, 1, 1))
		var3_upvw.impactFrame2(arg1, 0.1)
		var3_upvw.camShake(arg1, "BigBump")
		var3_upvw.changeFov(arg1, 100, 0, 0.5)
		var3_upvw.applySound(Brute_upvr.RockExplode, var10_upvw)
		var3_upvw.applySound(Brute_upvr.Explosion, var10_upvw)
		var10_upvw.Transparency = 1
		var3_upvw.EmitAllDescendants(var10_upvw)
		for _, v in var10_upvw:GetChildren() do
			if v:IsA("Motor6D") then
				v:Destroy()
			end
		end
		local function _(arg1_2) -- Line 143, Named "onHit"
			--[[ Upvalues[2]:
				[1]: var3_upvw (copied, read and write)
				[2]: HumanoidRootPart_upvr (copied, readonly)
			]]
			var3_upvw.applyDamage(arg1_2, 15)
			var3_upvw.applyStatus(arg1_2, "Ragdoll", 2)
			var3_upvw.Knockback(arg1_2, HumanoidRootPart_upvr.Position, 60, math.random(10, 20))
		end
		for _, v_2 in tbl_upvr do
			var3_upvw.applyDamage(v_2, 15)
			var3_upvw.applyStatus(v_2, "Ragdoll", 2)
			var3_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position, 60, math.random(10, 20))
		end
		for _, v_3 in var3_upvw.findEnemiesPart(var10_upvw, true), nil do
			if not table.find(tbl_upvr, v_3) then
				var3_upvw.applyDamage(v_3, 15)
				var3_upvw.applyStatus(v_3, "Ragdoll", 2)
				var3_upvw.Knockback(v_3, HumanoidRootPart_upvr.Position, 60, math.random(10, 20))
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr