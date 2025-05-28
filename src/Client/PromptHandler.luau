--!strict
--!optimize 2

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PromptDesigner = require(ReplicatedStorage.Classes.PromptDesigner)
local Constants = require(ReplicatedStorage.Classes.PromptDesigner.Constants)

local function _HandleAdded(instance: Instance): ()
	if not instance:IsA("ProximityPrompt") then
		return warn(
			`Prompt designer only accepts proximity prompts. Instance '{instance.Name}' is not a proximity prompt. Did you tagged wrong instance?`
		)
	end

	PromptDesigner.new(instance)

	print(`Design applied to '{instance.Name}'`)
end

local function _HandleRemoved(instance: Instance): ()
	if not instance:IsA("ProximityPrompt") then
		return warn(
			`Prompt designer only accepts proximity prompts. Instance '{instance.Name}' is not a proximity prompt. Did you tagged wrong instance?`
		)
	end

	local designer = PromptDesigner.Get(instance)

	if not designer then
		return
	end

	designer:Destroy()
end

CollectionService:GetInstanceAddedSignal(Constants.Tags.PROMPT_DESIGNER_TAG):Connect(_HandleAdded)
CollectionService:GetInstanceRemovedSignal(Constants.Tags.PROMPT_DESIGNER_TAG):Connect(_HandleRemoved)

return {}
