-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:10
-- Luau version 6, Types version 3
-- Time taken: 0.005347 seconds

local module = {}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local var6_upvw
	local Charge_upvr = ReplicatedStorage_upvr.Skills["Titans Edge"].Ultimate.Charge
	var6_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnClientEvent:Connect(function(arg1_2) -- Line 24
		--[[ Upvalues[3]:
			[1]: var6_upvw (read and write)
			[2]: TweenService_upvr (copied, readonly)
			[3]: Charge_upvr (readonly)
		]]
		if arg1_2 ~= "Charge" then
		else
			var6_upvw:Disconnect()
			local ColorCorrectionEffect_upvr = Instance.new("ColorCorrectionEffect", game.Lighting)
			game.Debris:AddItem(ColorCorrectionEffect_upvr, 5)
			TweenService_upvr:Create(ColorCorrectionEffect_upvr, TweenInfo.new(0.3), {
				Brightness = Charge_upvr.ColorCorrection.Brightness;
				Contrast = Charge_upvr.ColorCorrection.Contrast;
				Saturation = Charge_upvr.ColorCorrection.Saturation;
			}):Play()
			local DepthOfFieldEffect_upvr = Instance.new("DepthOfFieldEffect", game.Lighting)
			game.Debris:AddItem(DepthOfFieldEffect_upvr, 5)
			TweenService_upvr:Create(DepthOfFieldEffect_upvr, TweenInfo.new(0.3), {
				FarIntensity = Charge_upvr.DepthOfField.FarIntensity;
				FocusDistance = Charge_upvr.DepthOfField.FocusDistance;
				InFocusRadius = Charge_upvr.DepthOfField.InFocusRadius;
				NearIntensity = Charge_upvr.DepthOfField.NearIntensity;
			}):Play()
			task.delay(1, function() -- Line 45
				--[[ Upvalues[3]:
					[1]: DepthOfFieldEffect_upvr (readonly)
					[2]: TweenService_upvr (copied, readonly)
					[3]: ColorCorrectionEffect_upvr (readonly)
				]]
				game.Debris:AddItem(DepthOfFieldEffect_upvr, 0)
				TweenService_upvr:Create(ColorCorrectionEffect_upvr, TweenInfo.new(0.3), {
					Brightness = 0;
					Contrast = 0;
					Saturation = 0;
				}):Play()
			end)
		end
	end), 60)
	task.delay(5, function() -- Line 56
		--[[ Upvalues[1]:
			[1]: var6_upvw (read and write)
		]]
		var6_upvw:Disconnect()
	end)
end
return module