--!strict
--!optimize 2

return table.freeze({
	Tags = {
		CAR_TAG = "Car",
	},
	Attributes = {
		PLAYER_IN_CAR = "PlayerInCar",
	},
	Actions = {
		EXIT_ACTION = "Exit",
	},
	KeyMap = {
		EXIT_KEY = Enum.KeyCode.Z
	}
})
