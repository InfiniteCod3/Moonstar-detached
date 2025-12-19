-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:16
-- Luau version 6, Types version 3
-- Time taken: 0.011903 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 25
module_upvr.GlobalCD = 0.1
local var3_upvw
local RunService_upvr = game:GetService("RunService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: RunService_upvr (readonly)
		[5]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Frenzy_upvr = ReplicatedStorage_upvr.Skills["Blood Sword"].Frenzy
	var3_upvw.applyStatus(arg1, "Freeze", 1)
	var3_upvw.applyStatus(arg1, "GlobalCD", 1)
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Frenzy_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	local clone_2 = Frenzy_upvr["sword move"]:Clone()
	clone_2.Parent = HumanoidRootPart_upvr
	clone_2:Play()
	game.Debris:AddItem(clone_2, 5)
	var3_upvw.applyStatus(arg1, "IFrames", 1)
	task.wait(0.28)
	for _, v in arg1:GetDescendants() do
		if v:IsA("BodyVelocity") then
			v:Destroy()
		end
	end
	var3_upvw.CreateDebris(HumanoidRootPart_upvr.Position, 7, 0.6, 0.25, 0.09)
	local clone_3 = Frenzy_upvr.DashImpact:Clone()
	clone_3.Parent = HumanoidRootPart_upvr
	clone_3:Play()
	game.Debris:AddItem(clone_3, 5)
	local clone = Frenzy_upvr.Dash:Clone()
	clone.Parent = HumanoidRootPart_upvr
	clone:Play()
	game.Debris:AddItem(clone, 5)
	local var18_upvw = true
	local any_conTimer_result1_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2) -- Line 71
		--[[ Upvalues[2]:
			[1]: arg2 (readonly)
			[2]: var18_upvw (read and write)
		]]
		if arg1_2 ~= arg2 then
		elseif arg2_2 == "StopLoop" then
			var18_upvw = false
		end
	end), module_upvr.Cooldown)
	task.delay(5, function() -- Line 78
		--[[ Upvalues[1]:
			[1]: any_conTimer_result1_upvw (read and write)
		]]
		any_conTimer_result1_upvw:Disconnect()
	end)
	local var22_upvw
	local var23_upvw
	local function comboScene_upvr(arg1_3) -- Line 84, Named "comboScene"
		--[[ Upvalues[7]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
			[2]: Frenzy_upvr (readonly)
			[3]: var3_upvw (copied, read and write)
			[4]: arg1 (readonly)
			[5]: ReplicatedStorage_upvr (copied, readonly)
			[6]: arg2 (readonly)
			[7]: var23_upvw (read and write)
		]]
		if arg1_3 then
			any_LoadAnimation_result1_upvr:AdjustSpeed(1)
			local any_LoadAnimation_result1 = arg1_3.Humanoid.Animator:LoadAnimation(Frenzy_upvr.EnemyAnimation)
			any_LoadAnimation_result1:Play()
			any_LoadAnimation_result1.TimePosition = any_LoadAnimation_result1_upvr.TimePosition
			var3_upvw.SetRootPriority(arg1, 100, 1.3)
			var3_upvw.applyStatus(arg1, "GlobalCD", 1.3)
			var3_upvw.applyStatus(arg1, "Freeze", 1.3)
			var3_upvw.applyStatus(arg1_3, "Stunned", 1.3)
			var3_upvw.applyStatus(arg1, "IFrames", 1.3)
			var3_upvw.applyStatus(arg1_3, "IFrames", 1.3)
			task.delay(1.3, function() -- Line 102
				--[[ Upvalues[2]:
					[1]: ReplicatedStorage_upvr (copied, readonly)
					[2]: arg2 (copied, readonly)
				]]
				ReplicatedStorage_upvr.Remotes.ClientInfo:FireClient(arg2, "Frenzy", {
					Action = "Destroy";
				})
			end)
			var23_upvw = var3_upvw.applyWeld(arg1_3, Vector3.new(0, 0, 3.5), Vector3.new(0, 180, 0), 2)
		else
			any_LoadAnimation_result1_upvr:Stop()
		end
	end
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slash"):Connect(function(arg1_4) -- Line 113
		--[[ Upvalues[8]:
			[1]: Frenzy_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var22_upvw (read and write)
			[4]: var3_upvw (copied, read and write)
			[5]: arg1 (readonly)
			[6]: var23_upvw (read and write)
			[7]: ReplicatedStorage_upvr (copied, readonly)
			[8]: arg2 (readonly)
		]]
		for i_2, v_2 in {"BodySlash", "swing"} do
			if Frenzy_upvr:FindFirstChild(v_2) then
				local clone_5 = Frenzy_upvr[v_2]:Clone()
				clone_5.Parent = HumanoidRootPart_upvr
				clone_5.PlaybackSpeed += math.random(-1, 1) * 0.1
				clone_5:Play()
				game.Debris:AddItem(clone_5, 6)
			end
		end
		if var22_upvw then
			local clone_6 = Frenzy_upvr.vfx.Att:Clone()
			clone_6.Parent = var22_upvw.Torso
			var3_upvw.EmitAllDescendants(clone_6)
			i_2 = clone_6
			v_2 = 3
			game.Debris:AddItem(i_2, v_2)
			v_2 = arg1_4 * 3
			i_2 = 80 - v_2
			v_2 = 0.01
			var3_upvw.changeFov(arg1, i_2, v_2, 2)
			i_2 = Color3.new
			v_2 = 1
			i_2 = i_2(v_2, 0.560784, 0.560784)
			v_2 = 0.6
			var3_upvw.flashScreen(arg1, i_2, v_2)
			v_2 = arg1_4 * 3
			i_2 = 80 - v_2
			v_2 = 0.01
			var3_upvw.changeFov(var22_upvw, i_2, v_2, 2)
			i_2 = 3
			var3_upvw.blood(var22_upvw, i_2)
			if arg1_4 ~= '4' then
				i_2 = 3
				v_2 = true
				var3_upvw.applyDamage(var22_upvw, i_2, v_2, true)
				i_2 = "SmallBump"
				var3_upvw.camShake(arg1, i_2)
				i_2 = 65
				v_2 = 0
				var3_upvw.changeFov(arg1, i_2, v_2, 2)
			else
				i_2 = "Bump"
				var3_upvw.camShake(arg1, i_2)
				i_2 = 60
				v_2 = 0
				var3_upvw.changeFov(arg1, i_2, v_2, 3)
				i_2 = 0
				var3_upvw.applyDebris(var23_upvw, i_2)
				i_2 = ReplicatedStorage_upvr
				i_2 = arg2
				v_2 = "Frenzy"
				i_2.Remotes.ClientInfo:FireClient(i_2, v_2, {
					Action = "Destroy";
				})
				i_2 = 6
				v_2 = true
				var3_upvw.applyDamage(var22_upvw, i_2, v_2)
				v_2 = HumanoidRootPart_upvr
				i_2 = v_2.Position
				v_2 = 5
				var3_upvw.Knockback(var22_upvw, i_2, v_2, 40)
				i_2 = "Ragdoll"
				v_2 = 2
				var3_upvw.applyStatus(var22_upvw, i_2, v_2)
				HumanoidRootPart_upvr.RootPriority = 0
			end
		end
		var3_upvw.applyStatus(arg1, "GlobalCD", 1.25)
		var3_upvw.applyStatus(arg1, "Freeze", 1.25)
		var3_upvw.applyStatus(var22_upvw, "Stunned", 1.25)
	end), module_upvr.Cooldown)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function() -- Line 162
		--[[ Upvalues[2]:
			[1]: Frenzy_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
		]]
		for _, v_3 in {"Whoosh", "Whoosh2", "Splat"} do
			if Frenzy_upvr:FindFirstChild(v_3) then
				local clone_4 = Frenzy_upvr[v_3]:Clone()
				clone_4.Parent = HumanoidRootPart_upvr
				clone_4.PlaybackSpeed += math.random(-1, 1) * 0.1
				clone_4:Play()
				game.Debris:AddItem(clone_4, 6)
			end
		end
	end), module_upvr.Cooldown)
	any_LoadAnimation_result1_upvr:AdjustSpeed(0.6)
	local var40_upvw
	local tbl_upvr = {}
	var40_upvw = var3_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 179
		--[[ Upvalues[11]:
			[1]: var18_upvw (read and write)
			[2]: var40_upvw (read and write)
			[3]: var22_upvw (read and write)
			[4]: any_LoadAnimation_result1_upvr (readonly)
			[5]: var3_upvw (copied, read and write)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: tbl_upvr (readonly)
			[8]: PlayerStatus_upvr (copied, readonly)
			[9]: ReplicatedStorage_upvr (copied, readonly)
			[10]: arg2 (readonly)
			[11]: comboScene_upvr (readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [2] 3. Error Block 18 start (CF ANALYSIS FAILED)
		var40_upvw:Disconnect()
		if not var22_upvw then
			any_LoadAnimation_result1_upvr:Stop(0.4)
		end
		do
			return
		end
		-- KONSTANTERROR: [2] 3. Error Block 18 end (CF ANALYSIS FAILED)
	end), module_upvr.Cooldown)
end
return module_upvr