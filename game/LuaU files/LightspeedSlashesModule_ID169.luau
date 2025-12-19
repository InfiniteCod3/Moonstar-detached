-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:04
-- Luau version 6, Types version 3
-- Time taken: 0.051785 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 14
module_upvr.GlobalCD = 0.1
local var3_upvw
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: PlayerStatus_upvr (readonly)
		[5]: TweenService_upvr (readonly)
	]]
	-- KONSTANTERROR: [0] 1. Error Block 80 start (CF ANALYSIS FAILED)
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown + 10)
	local HumanoidRootPart_2 = arg1:FindFirstChild("HumanoidRootPart")
	local Lightspeed_Slashes_upvr = ReplicatedStorage_upvr.Skills["Firework Rapier"].Ultimate["Lightspeed Slashes"]
	local clone_2_upvr = Lightspeed_Slashes_upvr.MultiSlash:Clone()
	clone_2_upvr.Parent = Folder
	clone_2_upvr.weld.Part0 = HumanoidRootPart_2
	clone_2_upvr.weld.Part1 = clone_2_upvr
	clone_2_upvr.SkillSound:Play()
	local tbl_4 = {}
	for i, v in arg1:GetDescendants() do
		if v:IsA("BasePart") then
			tbl_4[i] = {}
			tbl_4[i].OldTransparency = v.Transparency
			tbl_4[i].Part = v
			v.Transparency = 1
		end
	end
	local tbl_3 = {}
	table.insert(tbl_3, PlayerStatus_upvr.ApplyStatus(arg1, "GlobalCD"))
	table.insert(tbl_3, PlayerStatus_upvr.ApplyStatus(arg1, "IFrames"))
	table.insert(tbl_3, PlayerStatus_upvr.ApplyStatus(arg1, "Freeze"))
	local var83_upvw = 0
	task.spawn(function() -- Line 56
		--[[ Upvalues[3]:
			[1]: var83_upvw (read and write)
			[2]: Lightspeed_Slashes_upvr (readonly)
			[3]: clone_2_upvr (readonly)
		]]
		while task.wait(0.25) and 25 >= var83_upvw do
			local clone_5 = Lightspeed_Slashes_upvr.slashes:Clone()
			clone_5.Parent = clone_2_upvr
			clone_5.PlaybackSpeed += math.random(-2, 2) * 0.1
			clone_5:Play()
		end
	end)
	ReplicatedStorage_upvr.Remotes.ClientInfo:FireClient(arg2, "Lightspeed Slashes VFX", clone_2_upvr)
	-- KONSTANTERROR: [0] 1. Error Block 80 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [240] 169. Error Block 93 start (CF ANALYSIS FAILED)
	var3_upvw.camShake(arg1, "SmallBump")
	var3_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 0.2)
	var3_upvw.changeFov(arg1, 200, 0.5, 1)
	var3_upvw.Blur(arg1, 4, 0.25)
	if var83_upvw == 25 then
		for _, v_2 in {} do
			v_2:Destroy()
		end
	else
		for _, var65 in {} do
			var65.Position = HumanoidRootPart_2.Position + HumanoidRootPart_2.CFrame.LookVector * 10 + Vector3.new(math.random(-5, 5) * 3, math.random(0, 5) * 3, math.random(-5, 5) * 3)
			-- KONSTANTERROR: Expression was reused, decompilation is incorrect
		end
	end
	for _, v_3 in var3_upvw.findEnemiesMagnitude(HumanoidRootPart_2.Position, 25, true), nil do
		if v_3 and not var3_upvw.CheckBlock(v_3) then
			var3_upvw.applyStatus(v_3, "DashDB", 0.2)
			var3_upvw.applyStatus(v_3, "Ragdoll", 1)
			var3_upvw.applyDamage(v_3, 1)
			if var83_upvw == 25 then
				var3_upvw.Knockback(v_3, HumanoidRootPart_2.Position + HumanoidRootPart_2.CFrame.LookVector * -20, 70, 5)
			end
			local clone = Lightspeed_Slashes_upvr.VFX.ExplosionVFX:Clone()
			clone.Parent = v_3.HumanoidRootPart
			var3_upvw.EmitAllDescendants(clone)
			for _, v_4 in clone:GetChildren() do
				if v_4:IsA("Sound") then
					v_4.PlaybackSpeed += math.random(-2, 2) * 0.1
					v_4:Play()
				end
			end
			var3_upvw.applyDebris(clone, 3)
			if not v_3.Head:FindFirstChild("LightspeedSlashBodyPosition") and var83_upvw ~= 25 then
				for _, v_5 in v_3:GetDescendants() do
					if v_5:IsA("BodyVelocity") or v_5:IsA("BodyPosition") then
						v_5:Destroy()
					end
				end
				local BodyPosition_2 = Instance.new("BodyPosition", v_3.Head)
				BodyPosition_2.MaxForce = Vector3.new(1000000, 0, 1000000)
				BodyPosition_2.Name = "LightspeedSlashBodyPosition"
				BodyPosition_2.Position = HumanoidRootPart_2.Position + HumanoidRootPart_2.CFrame.LookVector * 10 + Vector3.new(math.random(-5, 5) * 3, math.random(0, 5) * 3, math.random(-5, 5) * 3)
				BodyPosition_2.D *= 0.7
				var3_upvw.applyDebris(BodyPosition_2, 5)
				-- KONSTANTERROR: Expression was reused, decompilation is incorrect
				table.insert({}, BodyPosition_2)
			end
		end
	end
	var83_upvw += 1
	-- KONSTANTERROR: [240] 169. Error Block 93 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [165] 113. Error Block 6 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: Expression was reused, decompilation is incorrect
	-- KONSTANTERROR: [165] 113. Error Block 6 end (CF ANALYSIS FAILED)
end
return module_upvr