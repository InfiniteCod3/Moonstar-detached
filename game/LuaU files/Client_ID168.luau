-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:03
-- Luau version 6, Types version 3
-- Time taken: 0.006950 seconds

local module = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local CameraShaker_upvr = require(ReplicatedStorage_upvr.Modules.CameraShaker)
function module.Script(arg1, arg2) -- Line 14
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: TweenService_upvr (readonly)
		[4]: CameraShaker_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Ultimate_upvr = ReplicatedStorage_upvr.Skills["Firework Rapier"].Ultimate
	local clone_3 = Ultimate_upvr.Darken:Clone()
	clone_3.Parent = workspace
	game.Debris:AddItem(clone_3, 5)
	clone_3:Play()
	TweenService_upvr:Create(clone_3, TweenInfo.new(1), {
		Volume = 0;
	}):Play()
	local function screenFlash_upvr(arg1_2, arg2_2) -- Line 32, Named "screenFlash"
		--[[ Upvalues[1]:
			[1]: TweenService_upvr (copied, readonly)
		]]
		local clone_2 = game:GetService("MaterialService").flashScreen:Clone()
		clone_2.Parent = game.Lighting
		clone_2.TintColor = arg1_2
		clone_2.Brightness = 0.35
		TweenService_upvr:Create(clone_2, TweenInfo.new(arg2_2), {
			TintColor = Color3.new(1, 1, 1);
			Brightness = 0;
		}):Play()
		game.Debris:AddItem(clone_2, arg2_2 + 0.5)
	end
	local var11_upvw
	local function camShake_upvr(arg1_3) -- Line 42, Named "camShake"
		--[[ Upvalues[3]:
			[1]: arg2 (readonly)
			[2]: var11_upvw (read and write)
			[3]: CameraShaker_upvr (copied, readonly)
		]]
		if arg2:FindFirstChild("Toggle CamShake") then
		else
			if var11_upvw then
				var11_upvw:Stop()
			end
			local CurrentCamera_upvr_2 = workspace.CurrentCamera
			local any_new_result1 = CameraShaker_upvr.new(Enum.RenderPriority.Camera.Value, function(arg1_4) -- Line 49
				--[[ Upvalues[1]:
					[1]: CurrentCamera_upvr_2 (readonly)
				]]
				CurrentCamera_upvr_2.CFrame *= arg1_4
			end)
			any_new_result1:Start()
			var11_upvw = any_new_result1
			any_new_result1:Shake(CameraShaker_upvr.Presets[arg1_3])
		end
	end
	local ColorCorrectionEffect_upvr = Instance.new("ColorCorrectionEffect", game.Lighting)
	TweenService_upvr:Create(ColorCorrectionEffect_upvr, TweenInfo.new(1), {
		Brightness = -1.4;
	}):Play()
	local CurrentCamera_upvr = workspace.CurrentCamera
	local var19_upvw = 0.8
	task.delay(1, function() -- Line 61
		--[[ Upvalues[8]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: CurrentCamera_upvr (readonly)
			[3]: Ultimate_upvr (readonly)
			[4]: camShake_upvr (readonly)
			[5]: ColorCorrectionEffect_upvr (readonly)
			[6]: screenFlash_upvr (readonly)
			[7]: var3_upvw (copied, read and write)
			[8]: var19_upvw (read and write)
		]]
		TweenService_upvr:Create(CurrentCamera_upvr, TweenInfo.new(0), {
			FieldOfView = 15;
		}):Play()
		for i = 1, 20 do
			if i == 5 then
				local clone = Ultimate_upvr.Song:Clone()
				clone.Parent = workspace
				game.Debris:AddItem(clone, 5)
				clone:Play()
			end
			camShake_upvr("SmallBump")
			TweenService_upvr:Create(CurrentCamera_upvr, TweenInfo.new(0.25), {
				FieldOfView = CurrentCamera_upvr.FieldOfView + 4;
			}):Play()
			local var26 = ColorCorrectionEffect_upvr
			var26.Brightness += 0.1
			local Color3_new_result1 = Color3.new(1, 1, 1)
			screenFlash_upvr(Color3_new_result1, 0.6)
			local clone_4 = Ultimate_upvr.VFX:Clone()
			clone_4.Parent = workspace
			clone_4.CFrame = CurrentCamera_upvr.CFrame + CurrentCamera_upvr.CFrame.LookVector * 20 + CurrentCamera_upvr.CFrame.RightVector * math.random(-10, 10) + CurrentCamera_upvr.CFrame.UpVector * math.random(-10, 10)
			var3_upvw.EmitAllDescendants(clone_4)
			game.Debris:AddItem(clone_4, 5)
			local hitSFX = clone_4.ExplosionVFX.hitSFX
			hitSFX.PlaybackSpeed += math.random(-3, 3) * 0.1
			clone_4.ExplosionVFX.hitSFX:Play()
			for _, v in clone_4:GetDescendants() do
				if v:IsA("ParticleEmitter") then
					v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3_new_result1), ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))})
				end
			end
			task.wait(var19_upvw)
			if 0.1 < var19_upvw then
				var19_upvw -= 0.2
			else
				var19_upvw = 0.05
			end
		end
		camShake_upvr("Bump")
		TweenService_upvr:Create(workspace.CurrentCamera, TweenInfo.new(2), {
			FieldOfView = 80;
		}):Play()
		TweenService_upvr:Create(ColorCorrectionEffect_upvr, TweenInfo.new(2), {
			Brightness = 0;
		}):Play()
	end)
end
return module