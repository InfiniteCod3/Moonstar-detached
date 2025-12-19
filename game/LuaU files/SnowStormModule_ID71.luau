-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:46
-- Luau version 6, Types version 3
-- Time taken: 0.014727 seconds

local module_upvr = {
	Cooldown = 15;
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
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Snow_Storm_upvr = ReplicatedStorage_upvr.Skills["Snow Blasters"].Ultimate["Snow Storm"]
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Snow_Storm_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	local tbl_upvr_2 = {}
	for i, v in arg1:FindFirstChild("Snow Blasters"):GetDescendants() do
		if v:IsA("BasePart") then
			tbl_upvr_2[i] = {}
			tbl_upvr_2[i].BasePart = v
			tbl_upvr_2[i].Transparency = v.Transparency
			TweenService_upvr:Create(v, TweenInfo.new(0), {
				Transparency = 1;
			}):Play()
		elseif v:IsA("Trail") then
			v.Enabled = false
		end
	end
	local tbl_upvr = {}
	table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "Slowed", 4))
	table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "GlobalCD", 4))
	local Snow_Cannon_upvr = arg1:FindFirstChild("Snow Cannon")
	if not Snow_Cannon_upvr then
		Snow_Cannon_upvr = arg1:WaitForChild("Snow Cannon")
	end
	Snow_Cannon_upvr.weld.Part0 = arg1["Right Arm"]
	Snow_Cannon_upvr.weld.C1 = Snow_Cannon_upvr.weld.C0
	local var20_upvw = true
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 56
		--[[ Upvalues[7]:
			[1]: var20_upvw (read and write)
			[2]: tbl_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: tbl_upvr_2 (readonly)
			[5]: TweenService_upvr (copied, readonly)
			[6]: Snow_Cannon_upvr (readonly)
			[7]: arg1 (readonly)
		]]
		var20_upvw = false
		for _, v_2 in tbl_upvr do
			var2_upvw.applyDebris(v_2, 0)
		end
		for _, v_3 in tbl_upvr_2 do
			TweenService_upvr:Create(v_3.BasePart, TweenInfo.new(0.1), {
				Transparency = v_3.Transparency;
			}):Play()
		end
		local PointLight = Snow_Cannon_upvr:FindFirstChild("PointLight")
		if PointLight then
			TweenService_upvr:Create(PointLight, TweenInfo.new(0), {
				Brightness = 0;
			}):Play()
		end
		if Snow_Cannon_upvr:FindFirstChild("Glow") then
			TweenService_upvr:Create(Snow_Cannon_upvr.Glow, TweenInfo.new(0), {
				Color = Color3.new(0, 0, 0);
			}):Play()
		end
		Snow_Cannon_upvr.weld.Part0 = arg1.Torso
		Snow_Cannon_upvr.weld.C1 = Snow_Cannon_upvr.weld:GetAttribute("BackCF")
	end), module_upvr.Cooldown)
	local var30_upvw
	task.spawn(function() -- Line 84
		--[[ Upvalues[5]:
			[1]: var20_upvw (read and write)
			[2]: any_LoadAnimation_result1_upvr (readonly)
			[3]: var30_upvw (read and write)
			[4]: var2_upvw (copied, read and write)
			[5]: HumanoidRootPart_upvr (readonly)
		]]
		while task.wait(0.1) and var20_upvw ~= false do
			if any_LoadAnimation_result1_upvr.Speed <= 0.1 then
				var20_upvw = false
				any_LoadAnimation_result1_upvr:Stop()
			end
			if var30_upvw then
				for _, v_4 in var2_upvw.findEnemiesPart(var30_upvw, true), nil do
					if not var2_upvw.CheckBlock(v_4, false) then
						var2_upvw.applyDamage(v_4, 1)
						var2_upvw.applyStatus(v_4, "Stunned", 0.4)
						var2_upvw.Knockback(v_4, HumanoidRootPart_upvr.Position, 15, 0)
					end
				end
			end
		end
	end)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("spray"):Connect(function() -- Line 106
		--[[ Upvalues[10]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: Snow_Cannon_upvr (readonly)
			[3]: Snow_Storm_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: var2_upvw (copied, read and write)
			[7]: var30_upvw (read and write)
			[8]: any_LoadAnimation_result1_upvr (readonly)
			[9]: var20_upvw (read and write)
			[10]: module_upvr (copied, readonly)
		]]
		TweenService_upvr:Create(Snow_Cannon_upvr.Glow, TweenInfo.new(1), {
			Color = Color3.new(0.6, 1, 1);
		}):Play()
		TweenService_upvr:Create(Snow_Cannon_upvr.PointLight, TweenInfo.new(1), {
			Brightness = 2;
		}):Play()
		local clone_2_upvr = Snow_Storm_upvr.SmallSpray:Clone()
		clone_2_upvr.Parent = Folder_upvr
		clone_2_upvr.Weld.Part0 = HumanoidRootPart_upvr
		clone_2_upvr.Weld.Part1 = clone_2_upvr
		var2_upvw.applyDebris(clone_2_upvr, 10)
		var30_upvw = clone_2_upvr.Hitbox
		for _, v_5 in clone_2_upvr:GetDescendants() do
			if v_5:IsA("ParticleEmitter") then
				v_5.Enabled = true
			elseif v_5:IsA("Sound") then
				v_5:Play()
			end
		end
		var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("spray2"):Connect(function() -- Line 124
			--[[ Upvalues[8]:
				[1]: var20_upvw (copied, read and write)
				[2]: Snow_Storm_upvr (copied, readonly)
				[3]: Folder_upvr (copied, readonly)
				[4]: HumanoidRootPart_upvr (copied, readonly)
				[5]: var2_upvw (copied, read and write)
				[6]: var30_upvw (copied, read and write)
				[7]: clone_2_upvr (readonly)
				[8]: TweenService_upvr (copied, readonly)
			]]
			if var20_upvw == false then
			else
				var20_upvw = "Hard"
				local clone = Snow_Storm_upvr.BigSpray:Clone()
				clone.Parent = Folder_upvr
				clone.Weld.Part0 = HumanoidRootPart_upvr
				clone.Weld.Part1 = clone
				var2_upvw.applyDebris(clone, 10)
				var30_upvw = clone.Hitbox
				for _, v_7 in clone:GetDescendants() do
					if v_7:IsA("ParticleEmitter") then
						v_7.Enabled = true
					elseif v_7:IsA("Sound") then
						v_7:Play()
					end
				end
				for _, v_8 in clone_2_upvr:GetDescendants() do
					if v_8:IsA("Sound") then
						v_8:Stop()
					end
				end
				repeat
					task.wait()
				until var20_upvw == false
				for _, v_9 in clone:GetDescendants() do
					if v_9:IsA("ParticleEmitter") then
						v_9.Enabled = false
					elseif v_9:IsA("Sound") then
						TweenService_upvr:Create(v_9, TweenInfo.new(0.5), {
							Volume = 0;
						}):Play()
					end
				end
			end
		end), module_upvr.Cooldown)
		repeat
			task.wait()
		until var20_upvw == false
		for _, v_6 in clone_2_upvr:GetDescendants() do
			if v_6:IsA("ParticleEmitter") then
				v_6.Enabled = false
			elseif v_6:IsA("Sound") then
				TweenService_upvr:Create(v_6, TweenInfo.new(0.5), {
					Volume = 0;
				}):Play()
			end
		end
	end), module_upvr.Cooldown)
	repeat
		task.wait(0.1)
		if var20_upvw == true then
			var2_upvw.camShake(arg1, "SmallBump")
		elseif var20_upvw == "Hard" then
			var2_upvw.camShake(arg1, "Bump")
		end
	until var20_upvw == false
end
return module_upvr