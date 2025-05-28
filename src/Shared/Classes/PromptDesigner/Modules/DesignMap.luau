--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PromptUI = ReplicatedStorage.Assets.UI.PromptUI

return table.freeze({
	VehicleDrive = PromptUI.VehiclePrompts.VehicleDrivePrompt,
	VehicleSit = PromptUI.VehiclePrompts.VehicleSitPrompt,
})
