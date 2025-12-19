-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:50
-- Luau version 6, Types version 3
-- Time taken: 0.007613 seconds

local module_upvr = {
	Cooldown = 18;
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
	local Torrent_upvr = ReplicatedStorage_upvr.Skills["Water Brawler"].Ultimate.Torrent
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Torrent_upvr.Animation)
	any_LoadAnimation_result1:Play()
	var2_upvw.applyStatus(arg1, "Freeze", 1.2)
	var2_upvw.applyStatus(arg1, "GlobalCD", 1.2)
	local clone_2 = Torrent_upvr.Whoosh:Clone()
	clone_2.Parent = HumanoidRootPart_upvr
	clone_2:Play()
	var2_upvw.applyDebris(clone_2, 10)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("stomp"):Connect(function() -- Line 43
		--[[ Upvalues[6]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Torrent_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: TweenService_upvr (copied, readonly)
		]]
		var2_upvw.camShake(arg1, "BigBump")
		var2_upvw.changeFov(arg1, 150, 0.01, 3)
		var2_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 2)
		var2_upvw.applyStatus(arg1, "Freeze", 1)
		var2_upvw.applyStatus(arg1, "GlobalCD", 1)
		var2_upvw.applyStatus(arg1, "AutoRotate", 1)
		for i = 1, 3 do
			local clone_3_upvr = Torrent_upvr.Slice:Clone()
			clone_3_upvr.Parent = Folder_upvr
			clone_3_upvr.CFrame = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 25 + Vector3.new(0, -3, 0)) * CFrame.Angles(0, math.rad(-50 + i * 25), 0)
			TweenService_upvr:Create(clone_3_upvr, TweenInfo.new(5, Enum.EasingStyle.Linear), {
				CFrame = clone_3_upvr.CFrame + clone_3_upvr.CFrame.LookVector * 275;
			}):Play()
			for _, v in clone_3_upvr:GetChildren() do
				if v:IsA("Sound") then
					v:Play()
				end
			end
			task.spawn(function() -- Line 63
				--[[ Upvalues[5]:
					[1]: var2_upvw (copied, read and write)
					[2]: clone_3_upvr (readonly)
					[3]: Torrent_upvr (copied, readonly)
					[4]: HumanoidRootPart_upvr (copied, readonly)
					[5]: TweenService_upvr (copied, readonly)
				]]
				local tbl = {}
				for _ = 1, 166.66666666666669 do
					for _, v_2 in var2_upvw.findEnemiesPart(clone_3_upvr.Hitbox, true), nil do
						if not table.find(tbl, v_2) then
							table.insert(tbl, v_2)
							local clone_4 = Torrent_upvr.HitSfx:Clone()
							clone_4.Parent = v_2.Torso
							clone_4:Play()
							var2_upvw.applyDebris(clone_4, 5)
							if not var2_upvw.CheckBlock(v_2) then
								var2_upvw.applyDamage(v_2, 14)
								var2_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position, -5, 70)
								var2_upvw.applyStatus(v_2, "Ragdoll", 1.7)
							end
						end
					end
					task.wait()
				end
				for _, v_3 in clone_3_upvr:GetDescendants() do
					if v_3:IsA("ParticleEmitter") then
						v_3.Enabled = false
					elseif v_3:IsA("Sound") then
						TweenService_upvr:Create(v_3, TweenInfo.new(1.5), {
							Volume = 0;
						}):Play()
					end
				end
			end)
		end
	end), module_upvr.Cooldown)
end
return module_upvr