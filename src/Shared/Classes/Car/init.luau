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
local Remotes = require(ReplicatedStorage.Remotes)
local Car_d = require(ReplicatedStorage.Types["Car.d"])
local Car = {}

-------------------------------
-- == VARIABLES == --
-------------------------------

local CarRemotes = Remotes.Client:GetNamespace("Car")

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

local function _IsExitObstructed(origin: Vector3, destination: Vector3, excludeList: { Instance }): boolean
	local direction = (destination - origin).Unit
	local distance = (destination - origin).Magnitude

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	params:AddToFilter(excludeList)

	local raycastResult = workspace:Raycast(origin, direction * distance, params)

	if not raycastResult then
		return false
	end

	if raycastResult.Instance then
		return true
	end

	return false
end

local function _HandleOccupantChanged(self: Car_d.Car, carSeat: Car_d.CarSeat): ()
	local occupant: Humanoid? = carSeat.Seat.Occupant

	if occupant then
		-- Disable jumping, disable prompts, set player sitting flag to true and bind exit action
		occupant:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		ProximityPromptService.Enabled = false
		carSeat.IsPlayerSitting = true
		carSeat.PlayerHumanoid = occupant

		ContextActionService:BindAction(Constants.Actions.EXIT_ACTION, function(_, inputState: Enum.UserInputState)
			if inputState == Enum.UserInputState.Begin then
				self:Exit()
			end

			return Enum.ContextActionResult.Sink
		end, true, Constants.KeyMap.EXIT_KEY)
	else
		-- Get previously sitting humanoid
		local humanoid: Humanoid? = carSeat.PlayerHumanoid

		-- No humanoid, cannot do anything
		if not humanoid then
			return
		end

		local rootPart = humanoid.RootPart

		if not rootPart then
			return
		end

		if
			_IsExitObstructed(
				carSeat.Seat.Position,
				carSeat.Attachment.WorldPosition,
				{ self.Model, humanoid.Parent :: any }
			)
		then
			rootPart:PivotTo(rootPart:GetPivot() * CFrame.new(0, 10, 0))
		else
			rootPart:PivotTo(carSeat.Attachment.WorldCFrame)
		end

		-- Enable jumping, enable prompts, set player sitting flag to false and unbind exit action
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		ProximityPromptService.Enabled = true
		carSeat.IsPlayerSitting = false
		carSeat.PlayerHumanoid = nil

		ContextActionService:UnbindAction(Constants.Actions.EXIT_ACTION)
	end
end

local function _Initialize(self: Car_d.Car): ()
	for _, carSeat in self.CarSeats do
		private[self].Trove:Connect(carSeat.Prompt.Triggered, function(player: Player): ()
			self:Sit(player, carSeat)
		end)
		private[self].Trove:Connect(carSeat.Seat:GetPropertyChangedSignal("Occupant"), function(): ()
			_HandleOccupantChanged(self, carSeat)
		end)

		print(`Connected events for '{carSeat.Seat}' seat`)
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

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	-- Fire the `Sit` remote
	(CarRemotes:Get("Sit") :: any):SendToServer(carSeat.Seat, humanoid)
end

function CarMeta:Exit(): ()
	-- Get the seat we are sitting on
	local occupiedCarSeat: Car_d.CarSeat?

	for _, carSeat in self.CarSeats do
		if not carSeat.IsPlayerSitting then
			continue
		end

		occupiedCarSeat = carSeat
	end

	if not occupiedCarSeat then
		return
	end

	-- Fire `Exit` remote
	(CarRemotes:Get("Exit") :: any):SendToServer(occupiedCarSeat)
end

function CarMeta:Destroy(): ()
	carCollection[self.Model] = nil
	private[self].Trove:Destroy()

	private[self] = nil
	table.clear(self :: any)
end

return Car
