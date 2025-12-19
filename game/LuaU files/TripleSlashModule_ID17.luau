-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:03
-- Luau version 6, Types version 3
-- Time taken: 0.010538 seconds

local module_upvr = {
	Cooldown = 22;
	GlobalCD = 1.2;
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
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local HumanoidRootPart_2_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Basic_Sword_upvr = ReplicatedStorage_upvr.Skills["Basic Sword"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Basic_Sword_upvr["Triple Slash"].Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(0.85)
	var2_upvw.applyStatus(arg1, "Freeze", 1.4)
	var2_upvw.resetm1s()
	local clone_upvr = Basic_Sword_upvr["Triple Slash"].SlashVfx.vfx:Clone()
	clone_upvr.Parent = HumanoidRootPart_2_upvr
	game.Debris:AddItem(clone_upvr, 8)
	local clone_upvr_2 = Basic_Sword_upvr["Triple Slash"].Hitbox:Clone()
	clone_upvr_2.Parent = Folder
	clone_upvr_2.weld.Part0 = HumanoidRootPart_2_upvr
	game.Debris:AddItem(clone_upvr_2, 8)
	local tbl_2_upvr = {}
	local var12_upvw = false
	local function cleanup() -- Line 52
		--[[ Upvalues[4]:
			[1]: var12_upvw (read and write)
			[2]: tbl_2_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: arg1 (readonly)
		]]
		if var12_upvw then
		else
			var12_upvw = true
			for _, v_2 in ipairs(tbl_2_upvr) do
				if typeof(v_2) == "RBXScriptConnection" then
					v_2:Disconnect()
				end
			end
			table.clear(tbl_2_upvr)
			if var2_upvw.removeStatus then
				pcall(function() -- Line 66
					--[[ Upvalues[2]:
						[1]: var2_upvw (copied, read and write)
						[2]: arg1 (copied, readonly)
					]]
					var2_upvw.removeStatus(arg1, "Freeze")
				end)
			end
		end
	end
	task.delay(3.5, cleanup)
	table.insert(tbl_2_upvr, any_LoadAnimation_result1.Stopped:Connect(cleanup))
	local var20_upvw = 0
	table.insert(tbl_2_upvr, var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function() -- Line 77
		--[[ Upvalues[6]:
			[1]: var20_upvw (read and write)
			[2]: var2_upvw (copied, read and write)
			[3]: clone_upvr_2 (readonly)
			[4]: HumanoidRootPart_2_upvr (readonly)
			[5]: TweenService_upvr (copied, readonly)
			[6]: Basic_Sword_upvr (readonly)
		]]
		var20_upvw += 1
		var2_upvw.findEnemiesPart(clone_upvr_2)
		for _, v in var2_upvw.FoundEnemies do
			if not var2_upvw.CheckBlock(v) then
				var2_upvw.applyStatus(v, "Stunned", 0.7)
				var2_upvw.applyDamage(v, 5)
				var2_upvw.blood(v, 2)
				local HumanoidRootPart = v:FindFirstChild("HumanoidRootPart")
				if HumanoidRootPart then
					local Position_2 = HumanoidRootPart.Position
					HumanoidRootPart.CFrame = CFrame.lookAt(Vector3.new(Position_2.X, HumanoidRootPart_2_upvr.Position.Y, Position_2.Z), HumanoidRootPart_2_upvr.Position)
					TweenService_upvr:Create(HumanoidRootPart, TweenInfo.new(0.5), {
						CFrame = HumanoidRootPart.CFrame + HumanoidRootPart_2_upvr.CFrame.LookVector * 11;
					}):Play()
				end
				local clone_2 = Basic_Sword_upvr["Triple Slash"].SlashVfx.hitVFX:Clone()
				local Torso = v:FindFirstChild("Torso")
				if not Torso then
					Torso = v:FindFirstChild("UpperTorso")
					if not Torso then
						Torso = v
					end
				end
				clone_2.Parent = Torso
				var2_upvw.EmitAllDescendants(clone_2)
				if clone_2:FindFirstChild("hitSFX") then
					local hitSFX = clone_2.hitSFX
					hitSFX.PlaybackSpeed += var20_upvw * 0.1
					clone_2.hitSFX:Play()
				end
				game.Debris:AddItem(clone_2, 3)
			end
		end
	end), module_upvr.Cooldown))
	local var42_upvw = 0
	table.insert(tbl_2_upvr, var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("swing"):Connect(function() -- Line 108
		--[[ Upvalues[5]:
			[1]: var42_upvw (read and write)
			[2]: clone_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: arg1 (readonly)
			[5]: HumanoidRootPart_2_upvr (readonly)
		]]
		var42_upvw += 1
		local Swing = clone_upvr:FindFirstChild("Swing")
		if Swing then
			local clone = Swing:Clone()
			clone.PlaybackSpeed += var42_upvw * 0.1
			clone.Parent = clone_upvr
			clone:Play()
			game.Debris:AddItem(clone, 2)
		end
		pcall(function() -- Line 120
			--[[ Upvalues[3]:
				[1]: var2_upvw (copied, read and write)
				[2]: arg1 (copied, readonly)
				[3]: HumanoidRootPart_2_upvr (copied, readonly)
			]]
			var2_upvw.Knockback(arg1, HumanoidRootPart_2_upvr.Position - HumanoidRootPart_2_upvr.CFrame.LookVector * 3.5, 40)
		end)
		var2_upvw.EmitAllDescendants(clone_upvr)
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.Blur(arg1, 10, 0.25)
		var2_upvw.changeFov(arg1, 70, 0.01, 0.15)
	end), module_upvr.Cooldown))
end
return module_upvr