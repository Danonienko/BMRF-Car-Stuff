--!strict
--!optimize 2
--!native

-------------------------------
-- == SERVICES & REQUIRES == --
-------------------------------

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(script.Constants)
local GetCarSeats = require(script.Scripts.GetCarSeats)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Car_d = require(ReplicatedStorage.Types["Car.d"])
local Car = {}

-------------------------------
-- == VARIABLES == --
-------------------------------

local CarMeta: Car_d.ICar = {} :: Car_d.ICar
CarMeta.__index = CarMeta
CarMeta.__tostring = function()
	return "Car"
end

local carCollection: { [Model]: Car_d.Car } = {}

local private = {}

-------------------------------
-- == PRIVATE FUNCTIONS == --
-------------------------------

local function _Initialize(self: Car_d.Car): ()
	for _, carSeat in self.CarSeats do
		private[self].Trove:Connect(carSeat.Prompt.Triggered, function(player: Player): ()
			self:Sit(player, carSeat)
		end)

		print(`Connected prompt trigger for '{carSeat.Seat}' seat`)
	end
end

-------------------------------
-- == STATIC FUNCTIONS == --
-------------------------------

function Car.GetCar(model: Model): Car_d.Car?
	return carCollection[model]
end

function Car.CarList(): { string }
	local carList: { string } = {}

	for model, _ in carCollection do
		table.insert(carList, `{model}`)
	end

	return carList
end

function Car.new(model: Model): Car_d.Car
	local self: Car_d.Car = setmetatable({}, CarMeta) :: Car_d.Car

	private[self] = {
		Trove = Trove.new(),
	}

	self.Model = model
	self.CarSeats = GetCarSeats(model)

	_Initialize(self)

	carCollection[model] = self

	print(`Car '{model}' initialized`)

	return self
end

-------------------------------
-- == PUBLIC FUNCTIONS == --
-------------------------------

function CarMeta:Sit(player: Player, carSeat: Car_d.CarSeat): ()
	-- Check if the player who triggered prompt is you
	if player ~= Players.LocalPlayer then
		return
	end

	-- Sit!
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	ProximityPromptService.Enabled = false

	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	carSeat.Seat:Sit(humanoid)
	carSeat.Occupied = true

	ContextActionService:BindAction(Constants.Actions.EXIT_ACTION, function(_, inputState: Enum.UserInputState)
		if inputState == Enum.UserInputState.Begin then
			self:Exit()
		end

		return Enum.ContextActionResult.Sink
	end, true, Enum.KeyCode.E)
end

function CarMeta:Exit(): ()
	-- Get the seat that local player is sitting on
	local occupiedCarSeat: Car_d.CarSeat?

	for _, carSeat in self.CarSeats do
		if not carSeat.Occupied then
			continue
		end

		occupiedCarSeat = carSeat
	end

	if not occupiedCarSeat then
		return
	end

	local humanoid = occupiedCarSeat.Seat.Occupant
	local rootPart = humanoid and humanoid.RootPart

	if not rootPart then
		return
	end

	local seatWeld = occupiedCarSeat.Seat:FindFirstChild("SeatWeld")

	if seatWeld then
		seatWeld:Destroy()
	end

	rootPart:PivotTo(occupiedCarSeat.Attachment.WorldCFrame)

	occupiedCarSeat.Occupied = false
	(humanoid :: Humanoid):SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	ContextActionService:UnbindAction(Constants.Actions.EXIT_ACTION)
	ProximityPromptService.Enabled = true
end

function CarMeta:Destroy(): ()
	private[self].Trove:Destroy()

	for _, actionName: string in pairs(Constants.Actions) do
		ContextActionService:UnbindAction(actionName)
	end

	table.clear(private[self])
	table.clear(self :: any)
end

return Car
