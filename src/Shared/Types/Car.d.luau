--!strict
--!optimize 2

export type Car = typeof(setmetatable(
	{} :: {
		Model: Model,
		CarSeats: { CarSeat },
	},
	{} :: ICar
))

export type ICar = {
	__index: ICar,
	__tostring: () -> string,

	Sit: (self: Car, player: Player, carSeat: CarSeat) -> (),
	Exit: (self: Car) -> (),
	ShowPrompts: (self: Car) -> (),
	HidePrompts: (self: Car) -> (),

	Destroy: (self: Car) -> (),
}

export type CarSeat = {
	Seat: Seat,
	Prompt: ProximityPrompt,
	Attachment: Attachment,
	--- If true, the local player (you) is currently sitting in the seat
	IsPlayerSitting: boolean,
	PlayerHumanoid: Humanoid?,
}

return nil
