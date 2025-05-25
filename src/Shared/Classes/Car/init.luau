--!strict
--!optimize 2
--!native

-------------------------------
-- == SERVICES & REQUIRES == --
-------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(script.Constants)
local GetOutsidePosition = require(script.Scripts.GetOutsidePosition)
local GetSeatPrompts = require(script.Scripts.GetSeatPrompts)
local GetSeats = require(script.Scripts.GetSeats)
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

local function _HandlePromptTriggered(self: Car_d.Car, player: Player, seat: Seat): ()
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	seat:Sit(humanoid)

	private[self].Trove:Add(seat:GetPropertyChangedSignal("Occupant"):Once(function(): ()
		local occupant = seat.Occupant

		if not occupant then
			return
		end

		if occupant ~= humanoid then
			return
		end

		self.Model:SetAttribute(Constants.Attributes.PLAYER_IN_CAR, true)

		private[self].Trove:Add(seat:GetPropertyChangedSignal("Occupant"):Once(function(): ()
			if not seat.Occupant then
				local rootPart = humanoid.RootPart

				if not rootPart then
					return
				end

				rootPart:PivotTo(GetOutsidePosition(seat))

				self.Model:SetAttribute(Constants.Attributes.PLAYER_IN_CAR, false)
			end
		end))
	end))
end

local function _HandlePlayerInCarAttributeChanged(self: Car_d.Car): ()
	for _, prompt in self.Seats do
		if self:IsPlayerInCar() then
			prompt.Enabled = false
		else
			prompt.Enabled = true
		end
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
		Initialized = false,
	}

	self.Model = model
	self.Seats = GetSeatPrompts(GetSeats(model))

	for seat, prompt in self.Seats do
		private[self].Trove:Connect(prompt.Triggered, function(player: Player)
			_HandlePromptTriggered(self, player, seat)
		end)
	end

	private[self].Trove:Connect(model:GetAttributeChangedSignal(Constants.Attributes.PLAYER_IN_CAR), function()
		_HandlePlayerInCarAttributeChanged(self)
	end)

	carCollection[model] = self

	print(`Car '{model}' initialized`)

	return self
end

-------------------------------
-- == PUBLIC FUNCTIONS == --
-------------------------------

function CarMeta:IsPlayerInCar(): boolean
	local attribute = self.Model:GetAttribute(Constants.Attributes.PLAYER_IN_CAR)

	return typeof(attribute) == "boolean" and attribute or false
end

function CarMeta:Destroy(): ()
	private[self].Trove:Destroy()

	table.clear(private[self])
	table.clear(self :: any)
end

return Car
