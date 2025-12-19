-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:34
-- Luau version 6, Types version 3
-- Time taken: 0.009038 seconds

local module_upvr = {
	Cooldown = 25;
	GlobalCD = 1.4;
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
	local Earth_Catastrophe_upvr = ReplicatedStorage_upvr.Skills.Greatsword.Ultimate["Earth Catastrophe"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Earth_Catastrophe_upvr.Animation)
	any_LoadAnimation_result1:Play()
	local clone_3 = Earth_Catastrophe_upvr.Part.Sounds:Clone()
	clone_3.Parent = arg1.Torso
	game.Debris:AddItem(clone_3, 10)
	clone_3.BodyPrepare:Play()
	clone_3.Whoosh:Play()
	clone_3.slash:Play()
	var2_upvw.applyStatus(arg1, "Freeze", 1.4)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("autorotate"):Connect(function() -- Line 45
		--[[ Upvalues[2]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
		]]
		var2_upvw.applyStatus(arg1, "AutoRotate", 0.6)
	end), module_upvr.Cooldown)
	var2_upvw.changeFov(arg1, 100, 1, 10)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("slam"):Connect(function() -- Line 50
		--[[ Upvalues[6]:
			[1]: Earth_Catastrophe_upvr (readonly)
			[2]: Folder_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: arg1 (readonly)
			[6]: TweenService_upvr (copied, readonly)
		]]
		local clone_2 = Earth_Catastrophe_upvr.HitboxHolder:Clone()
		clone_2.Parent = Folder_upvr
		clone_2.CFrame = HumanoidRootPart_upvr.CFrame
		local tbl_2 = {}
		tbl_2.Character = arg1
		tbl_2.Replication = "EarthCatastrophe"
		tbl_2.ShatterCF = clone_2.CFrame
		var2_upvw.Replication("All", "Greatsword", tbl_2)
		task.wait()
		clone_2.Welds:Destroy()
		for _, v in clone_2:GetDescendants() do
			if v:IsA("BasePart") then
				v.Transparency = 1
				v.Anchored = true
			end
		end
		var2_upvw.changeFov(arg1, 70, 0.05, 10)
		local tbl = {}
		for i_2, _ in clone_2.Hitboxes:GetChildren() do
			if clone_2.Hitboxes:FindFirstChild(i_2) then
				var2_upvw.camShake(arg1, "Bump")
				for _, v_3 in var2_upvw.findEnemiesPart(clone_2.Hitboxes:FindFirstChild(i_2), true), nil do
					if not table.find(tbl, v_3) then
						table.insert(tbl, v_3)
						v_3.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
						var2_upvw.Knockback(v_3, HumanoidRootPart_upvr.Position, 0, 80)
						var2_upvw.applyStatus(v_3, "Ragdoll", 2.5)
						var2_upvw.applyDamage(v_3, 25)
						var2_upvw.camShake(v_3, "Bump")
					end
				end
				task.wait()
			end
		end
		task.wait(0.65)
		local tbl_3 = {}
		tbl_3.Character = arg1
		tbl_3.Replication = "EarthCatastrophe2"
		tbl_3.ShatterCF = clone_2.CFrame
		var2_upvw.Replication("All", "Greatsword", tbl_3)
		var2_upvw.changeFov(arg1, 95, 0.01, 3)
		var2_upvw.flashScreen(arg1, Color3.new(0.513725, 1, 0.984314), 1.5)
		var2_upvw.camShake(arg1, "Explosion")
		var2_upvw.impactFrame(arg1, 0.06)
		task.delay(0.03, function() -- Line 104
			--[[ Upvalues[2]:
				[1]: var2_upvw (copied, read and write)
				[2]: arg1 (copied, readonly)
			]]
			var2_upvw.impactFrame2(arg1, 0.03)
		end)
		for _, v_4 in var2_upvw.findEnemiesPart(clone_2.Hitbox2, true), nil do
			var2_upvw.Knockback(v_4, HumanoidRootPart_upvr.Position, 0, 110)
			var2_upvw.applyStatus(v_4, "Ragdoll", 3)
			var2_upvw.applyDamage(v_4, 25)
			var2_upvw.camShake(v_4, "Explosion")
			var2_upvw.impactFrame2(v_4)
			if v_4.Humanoid.Health <= 1 then
				for _, v_5 in v_4:GetDescendants() do
					if v_5:IsA("Shirt") or v_5:IsA("Pants") then
						v_5:Destroy()
					elseif v_5:IsA("BasePart") then
						v_5.Material = "Neon"
						v_5.Color = Color3.new(0.352941, 1, 1)
						TweenService_upvr:Create(v_5, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
							Color = Color3.new(0, 0, 0);
						}):Play()
						if not v_5:FindFirstChild("burnVfx") and v_5.Name == "Torso" or v_5.Name == "Left Arm" or v_5.Name == "Right Arm" or v_5.Name == "Head" or v_5.Name == "Left Leg" or v_5.Name == "Right Leg" then
							local clone = Earth_Catastrophe_upvr.burnVfx:Clone()
							clone.Parent = v_5
							clone.Enabled = true
							local clone_4 = Earth_Catastrophe_upvr.burnSfx:Clone()
							clone_4.Parent = v_5
							clone_4:Play()
						end
					end
				end
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr