-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:16:46
-- Luau version 6, Types version 3
-- Time taken: 0.008986 seconds

local module_upvr = {
	Cooldown = 20;
	GlobalCD = 1.5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module_upvr.Script(arg1, arg2) -- Line 12
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Dead_Calm_upvr = ReplicatedStorage_upvr.Skills["Basic Katana"]["Dead Calm"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Dead_Calm_upvr.Animation)
	any_LoadAnimation_result1:Play()
	var2_upvw.applyStatus(arg1, "Freeze", 1.5)
	wait(0.5)
	var2_upvw.Knockback(arg1, HumanoidRootPart_upvr.Position - HumanoidRootPart_upvr.CFrame.LookVector * 3.5, 40, 0, 0.4)
	var2_upvw.applyStatus(arg1, "HyperArmor", 1.5)
	local clone_2 = Dead_Calm_upvr.DeadCalmStart:Clone()
	game.Debris:AddItem(clone_2, 1)
	for _, v in pairs(clone_2:GetDescendants()) do
		if v:IsA("Attachment") then
			v:Clone()
			v.Parent = HumanoidRootPart_upvr
			var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Slash"):Connect(function() -- Line 42
				--[[ Upvalues[1]:
					[1]: HumanoidRootPart_upvr (readonly)
				]]
				HumanoidRootPart_upvr['2'].Effect:Emit(8)
			end), module_upvr.Cooldown)
			var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Shiny"):Connect(function() -- Line 46
				--[[ Upvalues[1]:
					[1]: HumanoidRootPart_upvr (readonly)
				]]
				HumanoidRootPart_upvr['1'].Shiny:Emit(3)
			end), module_upvr.Cooldown)
			game.Debris:AddItem(v, 5)
		end
		if v:IsA("Sound") then
			v:Play()
		end
	end
	local tbl = {}
	for _ = 1, 30 do
		for _, v_2_upvr in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position, 8.5), nil do
			if not table.find(tbl, v_2_upvr) then
				table.insert(tbl, v_2_upvr)
				var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Shiny"):Connect(function() -- Line 68
					--[[ Upvalues[3]:
						[1]: Dead_Calm_upvr (readonly)
						[2]: v_2_upvr (readonly)
						[3]: var2_upvw (copied, read and write)
					]]
					local clone_3_upvr = Dead_Calm_upvr.Slashes.Slash1:Clone()
					clone_3_upvr.Parent = v_2_upvr.HumanoidRootPart
					game.Debris:AddItem(clone_3_upvr, 5)
					task.delay(1.4, function() -- Line 73
						--[[ Upvalues[1]:
							[1]: clone_3_upvr (readonly)
						]]
						clone_3_upvr.Ring1.Enabled = false
						clone_3_upvr.Ring2.Enabled = false
						task.delay(0.4, function() -- Line 76
							--[[ Upvalues[1]:
								[1]: clone_3_upvr (copied, readonly)
							]]
							clone_3_upvr:Destroy()
						end)
					end)
					coroutine.wrap(function() -- Line 82
						--[[ Upvalues[3]:
							[1]: Dead_Calm_upvr (copied, readonly)
							[2]: v_2_upvr (copied, readonly)
							[3]: var2_upvw (copied, read and write)
						]]
						for _ = 1, 20 do
							wait(0.05)
							local clone = Dead_Calm_upvr.DeadCalmStart.slash:Clone()
							clone.PlaybackSpeed += math.random(-1, 1) * 0.1
							clone.Parent = v_2_upvr.HumanoidRootPart
							clone:Play()
							local clone_4 = Dead_Calm_upvr.Slashes.hitVFX:Clone()
							clone_4.Parent = v_2_upvr.HumanoidRootPart
							game.Debris:AddItem(clone_4, 3)
							var2_upvw.EmitAllDescendants(clone_4)
							game.Debris:AddItem(clone, 3)
							var2_upvw.applyDamage(v_2_upvr, 1)
							var2_upvw.applyStatus(v_2_upvr, "Stunned", 0.6)
						end
					end)()
				end), module_upvr.Cooldown)
			end
		end
		task.wait()
	end
end
return module_upvr