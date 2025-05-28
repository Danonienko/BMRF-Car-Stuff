--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DesignMap = require(ReplicatedStorage.Classes.PromptDesigner.Modules.DesignMap)

return function(prompt: ProximityPrompt): BillboardGui
	local tags = prompt:GetTags()
	local billBoardGui: BillboardGui?

	for _, tag: string in tags do
		local design: BillboardGui? = DesignMap[tag]

		if design then
			billBoardGui = design
			break
		end
	end

	assert(billBoardGui, `Could not find design for '{prompt.Name}' prompt`)

	return billBoardGui
end
