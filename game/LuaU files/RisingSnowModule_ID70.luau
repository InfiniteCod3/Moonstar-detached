-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:45
-- Luau version 6, Types version 3
-- Time taken: 0.010041 seconds

local module_upvr = {
	Cooldown = 11;
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
	local Rising_Snow_upvr = ReplicatedStorage_upvr.Skills["Snow Blasters"].Ultimate["Rising Snow"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Rising_Snow_upvr.Animation)
	any_LoadAnimation_result1:Play()
	local tbl_upvr = {}
	for i, v in arg1:FindFirstChild("Snow Blasters"):GetDescendants() do
		if v:IsA("BasePart") then
			tbl_upvr[i] = {}
			tbl_upvr[i].BasePart = v
			tbl_upvr[i].Transparency = v.Transparency
			TweenService_upvr:Create(v, TweenInfo.new(0), {
				Transparency = 1;
			}):Play()
		elseif v:IsA("Trail") then
			v.Enabled = false
		end
	end
	local Snow_Cannon_upvr = arg1:FindFirstChild("Snow Cannon")
	if not Snow_Cannon_upvr then
		Snow_Cannon_upvr = arg1:WaitForChild("Snow Cannon")
	end
	Snow_Cannon_upvr.weld.Part0 = arg1["Right Arm"]
	Snow_Cannon_upvr.weld.C1 = Snow_Cannon_upvr.weld.C0
	local var18_upvw = true
	var2_upvw.conTimer(any_LoadAnimation_result1.Stopped:Connect(function() -- Line 54
		--[[ Upvalues[5]:
			[1]: var18_upvw (read and write)
			[2]: tbl_upvr (readonly)
			[3]: TweenService_upvr (copied, readonly)
			[4]: Snow_Cannon_upvr (readonly)
			[5]: arg1 (readonly)
		]]
		var18_upvw = false
		for _, v_2 in tbl_upvr do
			TweenService_upvr:Create(v_2.BasePart, TweenInfo.new(0.1), {
				Transparency = v_2.Transparency;
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
	var2_upvw.applyStatus(arg1, "Slowed", 2)
	var2_upvw.applyStatus(arg1, "GlobalCD", 2)
	Snow_Cannon_upvr.Charge:Play()
	TweenService_upvr:Create(Snow_Cannon_upvr.Glow, TweenInfo.new(1), {
		Color = Color3.new(0.6, 1, 1);
	}):Play()
	TweenService_upvr:Create(Snow_Cannon_upvr.PointLight, TweenInfo.new(1), {
		Brightness = 2;
	}):Play()
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Fire"):Connect(function() -- Line 82
		--[[ Upvalues[8]:
			[1]: var18_upvw (read and write)
			[2]: TweenService_upvr (copied, readonly)
			[3]: Snow_Cannon_upvr (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: arg1 (readonly)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: Rising_Snow_upvr (readonly)
			[8]: Folder_upvr (readonly)
		]]
		var18_upvw = false
		TweenService_upvr:Create(Snow_Cannon_upvr.Glow, TweenInfo.new(0.25), {
			Color = Color3.new(0, 0, 0);
		}):Play()
		TweenService_upvr:Create(Snow_Cannon_upvr.PointLight, TweenInfo.new(0.25), {
			Brightness = 0;
		}):Play()
		var2_upvw.camShake(arg1, "Explosion")
		var2_upvw.changeFov(arg1, 55, 0, 1)
		var2_upvw.flashScreen(arg1, Color3.new(0.611765, 1, 0.988235), 0.7)
		var2_upvw.Blur(arg1, 30, 0.2)
		Snow_Cannon_upvr.Charge:Stop()
		Snow_Cannon_upvr.Detach:Play()
		Snow_Cannon_upvr.CannonFire3:Play()
		local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 50, Vector3.new(0, -1000, 0), var2_upvw.raycastParams)
		if workspace_Raycast_result1 then
			local clone = Rising_Snow_upvr.Indicator:Clone()
			clone.Parent = Folder_upvr
			clone.CFrame = CFrame.new(workspace_Raycast_result1.Position) * clone.CFrame - clone.CFrame.p
			for _, v_3 in clone:GetChildren() do
				if v_3:IsA("Sound") then
					v_3:Play()
				end
			end
			for _, v_4 in var2_upvw.findEnemiesPart(clone.Hitbox, true), nil do
				if not var2_upvw.CheckBlock(v_4, true) then
					var2_upvw.applyDamage(v_4, 10)
					var2_upvw.Knockback(v_4, HumanoidRootPart_upvr.Position, 0, 100)
					var2_upvw.applyStatus(v_4, "Ragdoll", 5)
					var2_upvw.camShake(v_4, "Explosion")
					var2_upvw.flashScreen(v_4, Color3.new(0.219608, 0.988235, 1), 4)
					var2_upvw.Blur(v_4, 40, 4)
					var2_upvw.changeFov(v_4, 30, 0.1, 4)
				end
			end
			var2_upvw.EmitAllDescendants(clone)
			task.wait(1.2)
			TweenService_upvr:Create(clone, TweenInfo.new(1), {
				CFrame = CFrame.new(workspace_Raycast_result1.Position + Vector3.new(0, -5, 0)) * clone.CFrame - clone.CFrame.p;
			}):Play()
		end
	end), module_upvr.Cooldown)
end
return module_upvr