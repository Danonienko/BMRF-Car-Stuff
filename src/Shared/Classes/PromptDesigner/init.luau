--!strict
--!optimize 2
--!native

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GetDesign = require(script.Scripts.GetDesign)
local Trove = require(ReplicatedStorage.Packages.Trove)
local PromptDesigner_d = require(ReplicatedStorage.Types["PromptDesigner.d"])

local PromptDesigner = {}

local DesignerMeta: PromptDesigner_d.IPromptDesigner = {} :: PromptDesigner_d.IPromptDesigner
DesignerMeta.__index = DesignerMeta
DesignerMeta.__tostring = function()
	return "Prompt Designer"
end

local private = {}

local promptCollection: { [ProximityPrompt]: PromptDesigner_d.PromptDesigner } = {}

function PromptDesigner.Get(prompt: ProximityPrompt): PromptDesigner_d.PromptDesigner?
	return promptCollection[prompt]
end

function PromptDesigner.new(prompt: ProximityPrompt): PromptDesigner_d.PromptDesigner
	local self: PromptDesigner_d.PromptDesigner = setmetatable({}, DesignerMeta) :: PromptDesigner_d.PromptDesigner

	private[self] = {
		Trove = Trove.new(),
	}

	self.Prompt = prompt
	self.Design = GetDesign(prompt)

	self.Design.Parent = Players.LocalPlayer.PlayerGui

	private[self].Trove:Connect(prompt.PromptShown, function()
		self:Show()
	end)
	private[self].Trove:Connect(prompt.PromptHidden, function()
		self:Hide()
	end)

	promptCollection[prompt] = self

	return self
end

function DesignerMeta:Show(): ()
	local promptParent = self.Prompt.Parent

	if not promptParent then
		return
	end

	self.Design.Adornee = promptParent
	self.Design.Enabled = true
end

function DesignerMeta:Hide(): ()
	self.Design.Enabled = false
	self.Design.Adornee = nil :: any
end

function DesignerMeta:Destroy(): ()
	promptCollection[self.Prompt] = nil
	private[self].Trove:Destroy()

	private[self] = nil
	table.clear(self :: any)
end

return PromptDesigner
