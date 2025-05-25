--!strict
--!optimize 2

export type Car = typeof(setmetatable(
	{} :: {
		Model: Model,
		Seats: { [Seat]: ProximityPrompt },
	},
	{} :: ICar
))

export type ICar = {
	__index: ICar,
	__tostring: () -> string,

	IsPlayerInCar: (self: Car) -> boolean,

	Destroy: (self: Car) -> (),
}

return nil
