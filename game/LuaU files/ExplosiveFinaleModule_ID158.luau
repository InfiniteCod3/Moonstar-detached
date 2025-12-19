-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:54
-- Luau version 6, Types version 3
-- Time taken: 0.018713 seconds

local module_upvr = {
	Cooldown = 10;
	GlobalCD = 3;
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
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Explosive_Finale_upvr = ReplicatedStorage_upvr.Skills["Fire Fists"].Ultimate["Explosive Finale"]
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Explosive_Finale_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(1)
	var2_upvw.applyStatus(arg1, "Freeze", 3)
	local clone_upvr_3 = Explosive_Finale_upvr.FireBarrageSFX:Clone()
	clone_upvr_3.Parent = HumanoidRootPart_upvr
	clone_upvr_3:Play()
	var2_upvw.applyDebris(clone_upvr_3, 15)
	local var10_upvw = false
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 43
		--[[ Upvalues[3]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
			[2]: var10_upvw (read and write)
			[3]: clone_upvr_3 (readonly)
		]]
		if any_LoadAnimation_result1_upvr.TimePosition < any_LoadAnimation_result1_upvr.Length then
			var10_upvw = true
			clone_upvr_3:Stop()
		end
	end), module_upvr.Cooldown)
	local clone = Explosive_Finale_upvr.Whoosh:Clone()
	clone.Parent = HumanoidRootPart_upvr
	clone:Play()
	var2_upvw.applyDebris(clone, 5)
	var2_upvw.changeFov(arg1, 100, 0.3, 5)
	local function _(arg1_2, arg2_2, arg3, arg4) -- Line 57, Named "CreateAirtime"
		--[[ Upvalues[3]:
			[1]: arg1 (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
		]]
		local var29
		for _, v in arg1_2.Head:GetChildren() do
			if v.Name == "AirTime" then
				v:Destroy()
			end
		end
		if arg1_2 ~= arg1 then
			var29 += 4
		end
		local BodyPosition_2 = Instance.new("BodyPosition", arg1_2.Head)
		BodyPosition_2.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		BodyPosition_2.Position = HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * var29
		var2_upvw.applyDebris(BodyPosition_2, arg2_2)
		BodyPosition_2.Name = "AirTime"
		if arg4 then
			if workspace:Raycast(HumanoidRootPart_upvr.Position, Vector3.new(0, -5, 0), var2_upvw.raycastParams) then
				BodyPosition_2.Name = "UptiltAirTime"
				BodyPosition_2.Position = HumanoidRootPart_upvr.Position + Vector3.new(0, 15, 0) + HumanoidRootPart_upvr.CFrame.LookVector * var29
			end
		end
		return BodyPosition_2
	end
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("punch"):Connect(function() -- Line 85
		--[[ Upvalues[8]:
			[1]: Explosive_Finale_upvr (readonly)
			[2]: Folder_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: var10_upvw (read and write)
			[6]: arg1 (readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: clone_upvr_3 (readonly)
		]]
		local clone_upvr = Explosive_Finale_upvr.Hitbox:Clone()
		clone_upvr.Parent = Folder_upvr
		clone_upvr.weld.Part1 = clone_upvr
		clone_upvr.weld.Part0 = HumanoidRootPart_upvr
		var2_upvw.applyDebris(clone_upvr, 3)
		clone_upvr.Transparency = 1
		task.spawn(function() -- Line 94
			--[[ Upvalues[6]:
				[1]: var10_upvw (copied, read and write)
				[2]: var2_upvw (copied, read and write)
				[3]: clone_upvr (readonly)
				[4]: Explosive_Finale_upvr (copied, readonly)
				[5]: HumanoidRootPart_upvr (copied, readonly)
				[6]: arg1 (copied, readonly)
			]]
			for _ = 1, 32 do
				task.wait(0.075)
				if var10_upvw == true then return end
				local any_findEnemiesPart_result1 = var2_upvw.findEnemiesPart(clone_upvr, true)
				if 0 >= #any_findEnemiesPart_result1 then
				end
				local clone_4 = Explosive_Finale_upvr.PunchSound:Clone()
				clone_4.Parent = HumanoidRootPart_upvr
				clone_4:Play()
				clone_4.PlaybackSpeed += math.random(-2, 2) * 0.1
				var2_upvw.applyDebris(clone_4, 2)
				for _, v_2 in any_findEnemiesPart_result1 do
					if not var2_upvw.CheckBlock(v_2) then
						var2_upvw.applyDamage(v_2, 1)
						var2_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 7.5)
						var2_upvw.applyStatus(v_2, "Stunned", 0.25)
						local clone_3 = Explosive_Finale_upvr.FlameM1:Clone()
						clone_3.Parent = v_2.HumanoidRootPart
						clone_3:Play()
						var2_upvw.applyDebris(clone_3, 1.5)
						local clone_2 = Explosive_Finale_upvr.VFX.hitVFX:Clone()
						clone_2.Parent = v_2.HumanoidRootPart
						var2_upvw.EmitAllDescendants(clone_2)
						var2_upvw.applyDebris(clone_3, 2)
					end
				end
				var2_upvw.camShake(arg1, "Bump")
				var2_upvw.flashScreen(arg1, Color3.new(1, 0.784314, 0.631373), 0.5)
				var2_upvw.changeFov(arg1, 60, 0.01, 0.5)
			end
		end)
		for _ = 1, 160 do
			if var10_upvw == true then return end
			task.wait()
			local clone_upvr_2 = Explosive_Finale_upvr.FireFist:Clone()
			clone_upvr_2.Parent = Folder_upvr
			clone_upvr_2.Size = Vector3.new(11.25, 11.25, 15)
			clone_upvr_2.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.RightVector * math.random(-36, 36) + HumanoidRootPart_upvr.CFrame.UpVector * math.random(-36, 36)
			var2_upvw.applyDebris(clone_upvr_2, 0.36)
			TweenService_upvr:Create(clone_upvr_2, TweenInfo.new(0.35), {
				CFrame = clone_upvr_2.CFrame + clone_upvr_2.CFrame.LookVector * 50 * 1.5;
				Size = Vector3.new(11.6999, 11.6999, 72);
			}):Play()
			TweenService_upvr:Create(clone_upvr_2, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Transparency = 1;
			}):Play()
			task.delay(0.35, function() -- Line 152
				--[[ Upvalues[1]:
					[1]: clone_upvr_2 (readonly)
				]]
				for _, v_3 in clone_upvr_2:GetDescendants() do
					if v_3:IsA("ParticleEmitter") then
						v_3.Enabled = false
					end
				end
			end)
		end
		clone_upvr_2 = TweenInfo.new(1)
		TweenService_upvr:Create(clone_upvr_3, clone_upvr_2, {
			Volume = 0;
		}):Play()
	end), module_upvr.Cooldown)
end
return module_upvr