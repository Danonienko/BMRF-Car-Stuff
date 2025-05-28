--!strict
--!optimize 2

export type PromptDesigner = typeof(setmetatable(
	{} :: {
		Prompt: ProximityPrompt,
		Design: BillboardGui,
	},
	{} :: IPromptDesigner
))

export type IPromptDesigner = {
	__index: IPromptDesigner,
	__tostring: () -> string,

	Show: (self: PromptDesigner) -> (),
	Hide: (self: PromptDesigner) -> (),

	Destroy: (self: PromptDesigner) -> (),
}

return nil
