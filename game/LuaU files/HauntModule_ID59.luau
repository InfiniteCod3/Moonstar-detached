-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:50
-- Luau version 6, Types version 3
-- Time taken: 0.014259 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 27
module_upvr.GlobalCD = 1
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[2]:
		[1]: module_upvr (readonly)
		[2]: ReplicatedStorage_upvr (readonly)
	]]
	local Skills_upvr = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Haunt_upvr = ReplicatedStorage_upvr.Skills.Hallow.Haunt
	local function SpawnPumpkins_upvr(arg1_2) -- Line 31, Named "SpawnPumpkins"
		--[[ Upvalues[5]:
			[1]: Haunt_upvr (readonly)
			[2]: Folder_upvr (readonly)
			[3]: Skills_upvr (readonly)
			[4]: arg1 (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
		]]
		for i_upvr = 1, arg1_2 do
			local clone_upvr = Haunt_upvr.TurretPart:Clone()
			clone_upvr.Parent = Folder_upvr
			Skills_upvr.applyDebris(clone_upvr, 15)
			local clone = Haunt_upvr.PumpkinHumanoid:Clone()
			clone.Parent = workspace.WorldInfo.Live
			clone.HumanoidRootPart.weld.Part0 = clone_upvr
			clone.HumanoidRootPart.weld.Part1 = clone.HumanoidRootPart
			Skills_upvr.applyDebris(clone, 13)
			Instance.new("Folder", clone).Name = arg1.Name
			local function _() -- Line 47, Named "rdmNumber"
				local var11_upvw
				local function findNumber() -- Line 49
					--[[ Upvalues[2]:
						[1]: findNumber (readonly)
						[2]: var11_upvw (read and write)
					]]
					local randint_5 = math.random(-4, 4)
					if randint_5 == 0 then
						findNumber()
					else
						var11_upvw = randint_5
					end
				end
				local randint_3 = math.random(-4, 4)
				if randint_3 == 0 then
					findNumber()
				else
					var11_upvw = randint_3
				end
				return var11_upvw * 4
			end
			local var14_upvw
			local function findNumber() -- Line 49
				--[[ Upvalues[2]:
					[1]: findNumber (readonly)
					[2]: var14_upvw (read and write)
				]]
				local randint_2 = math.random(-4, 4)
				if randint_2 == 0 then
					findNumber()
				else
					var14_upvw = randint_2
				end
			end
			local var16_upvw
			if var16_upvw == 0 then
				findNumber()
			else
				var14_upvw = var16_upvw
			end
			var16_upvw = nil
			local function findNumber_upvr() -- Line 49, Named "findNumber"
				--[[ Upvalues[2]:
					[1]: findNumber_upvr (readonly)
					[2]: var16_upvw (read and write)
				]]
				local randint = math.random(-4, 4)
				if randint == 0 then
					findNumber_upvr()
				else
					var16_upvw = randint
				end
			end
			local randint_4 = math.random(-4, 4)
			if randint_4 == 0 then
				findNumber_upvr()
			else
				var16_upvw = randint_4
			end
			clone_upvr.CFrame = HumanoidRootPart_upvr.CFrame + Vector3.new(var14_upvw * 4, 0, var16_upvw * 4)
			clone_upvr.CFrame *= CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)
			Skills_upvr.conTimer(clone.Humanoid.HealthChanged:Connect(function(arg1_3) -- Line 66
				--[[ Upvalues[1]:
					[1]: clone_upvr (readonly)
				]]
				if arg1_3 <= 1 then
					clone_upvr:SetAttribute("Despawning", true)
				end
			end), 30)
			delay(13, function() -- Line 72
				--[[ Upvalues[1]:
					[1]: clone_upvr (readonly)
				]]
				clone_upvr:SetAttribute("Despawning", true)
			end)
			local workspace_Raycast_result1 = workspace:Raycast(clone_upvr.Position, Vector3.new(0, -100, 0), Skills_upvr.raycastParams)
			if workspace_Raycast_result1 then
				clone_upvr.CFrame = CFrame.new(workspace_Raycast_result1.Position + Vector3.new(0, 1.70000, 0)) * clone_upvr.CFrame - clone_upvr.CFrame.Position
			end
			local tbl_2 = {}
			tbl_2.Character = arg1
			tbl_2.Replication = "SpawnPumpkin"
			tbl_2.TurretPart = clone_upvr
			Skills_upvr.Replication("All", "Hallow", tbl_2)
			task.spawn(function() -- Line 83
				--[[ Upvalues[6]:
					[1]: clone_upvr (readonly)
					[2]: arg1 (copied, readonly)
					[3]: i_upvr (readonly)
					[4]: Skills_upvr (copied, readonly)
					[5]: Haunt_upvr (copied, readonly)
					[6]: Folder_upvr (copied, readonly)
				]]
				pcall(function() -- Line 84
					--[[ Upvalues[6]:
						[1]: clone_upvr (copied, readonly)
						[2]: arg1 (copied, readonly)
						[3]: i_upvr (copied, readonly)
						[4]: Skills_upvr (copied, readonly)
						[5]: Haunt_upvr (copied, readonly)
						[6]: Folder_upvr (copied, readonly)
					]]
					local function _() -- Line 85, Named "GetClosestCharacter"
						--[[ Upvalues[2]:
							[1]: clone_upvr (copied, readonly)
							[2]: arg1 (copied, readonly)
						]]
						local var27_upvw
						local _, _ = pcall(function() -- Line 87
							--[[ Upvalues[3]:
								[1]: clone_upvr (copied, readonly)
								[2]: arg1 (copied, readonly)
								[3]: var27_upvw (read and write)
							]]
							for _, v in workspace.WorldInfo.Live:GetChildren() do
								local Magnitude_2 = (v.Torso.Position - clone_upvr.Position).Magnitude
								if v ~= arg1 and not v:FindFirstChild(arg1.Name) and Magnitude_2 <= 75 and Magnitude_2 <= 75 then
									var27_upvw = v
								end
							end
						end)
						return var27_upvw
					end
					wait(i_upvr * 0.01)
					while true do
						wait(3)
						if not clone_upvr.Parent then break end
						if clone_upvr:GetAttribute("Despawning") then break end
						local var37_upvw
						local _, _ = pcall(function() -- Line 87
							--[[ Upvalues[3]:
								[1]: clone_upvr (copied, readonly)
								[2]: arg1 (copied, readonly)
								[3]: var37_upvw (read and write)
							]]
							for _, v_2 in workspace.WorldInfo.Live:GetChildren() do
								local Magnitude = (v_2.Torso.Position - clone_upvr.Position).Magnitude
								if v_2 ~= arg1 and not v_2:FindFirstChild(arg1.Name) and Magnitude <= 75 and Magnitude <= 75 then
									var37_upvw = v_2
								end
							end
						end)
						local var47 = var37_upvw
						print(var47)
						if var47 then
							Skills_upvr.camShake(arg1, "SmallBump")
							Skills_upvr.changeFov(arg1, 75, 0, 0.4)
							local tbl_3 = {}
							tbl_3.Character = arg1
							tbl_3.Replication = "FirePumpkin"
							tbl_3.TurretPart = clone_upvr
							Skills_upvr.Replication("All", "Hallow", tbl_3)
							clone_upvr.CFrame = CFrame.lookAt(clone_upvr.Position, var47.HumanoidRootPart.Position)
							local any_cloneInstance_result1 = Skills_upvr.cloneInstance(Haunt_upvr.BeamHitbox, Folder_upvr, 1)
							any_cloneInstance_result1.weld.Part0 = clone_upvr
							any_cloneInstance_result1.weld.Part1 = any_cloneInstance_result1
							for _, v_3 in Skills_upvr.findEnemiesPart(any_cloneInstance_result1, true), nil do
								if not Skills_upvr.CheckBlock(v_3) then
									Skills_upvr.applyDamage(v_3, 4)
								end
							end
						end
					end
				end)
			end)
		end
	end
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Haunt_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(1)
	Skills_upvr.applyStatus(arg1, "Slowed", 1.1)
	Skills_upvr.applyStatus(arg1, "GlobalCD", 1.1)
	Skills_upvr.camShake(arg1, "SmallBump")
	Skills_upvr.changeFov(arg1, 65, 0.5, 2)
	local tbl = {}
	tbl.Character = arg1
	tbl.Replication = "Start"
	Skills_upvr.Replication("All", "Hallow", tbl)
	Skills_upvr.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Lift"):Once(function() -- Line 150
		--[[ Upvalues[4]:
			[1]: Skills_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: arg1 (readonly)
			[4]: SpawnPumpkins_upvr (readonly)
		]]
		for _, v_4 in Skills_upvr.findEnemiesMagnitude(HumanoidRootPart_upvr.Position, 21, true), nil do
			if not Skills_upvr.CheckBlock(v_4) then
				Skills_upvr.applyDamage(v_4, 6)
				Skills_upvr.Knockback(v_4, HumanoidRootPart_upvr.Position, 5, 32)
				Skills_upvr.applyStatus(v_4, "Ragdoll", 0.6)
			end
		end
		local tbl_4 = {}
		tbl_4.Character = arg1
		tbl_4.Replication = "Rise"
		Skills_upvr.Replication("All", "Hallow", tbl_4)
		Skills_upvr.camShake(arg1, "SmallBump")
		Skills_upvr.changeFov(arg1, 100, 0.1, 2)
		SpawnPumpkins_upvr(3)
	end), 3)
end
return module_upvr