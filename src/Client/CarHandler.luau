--!strict
--!optimize 2

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Car = require(ReplicatedStorage.Classes.Car)
local Constants = require(ReplicatedStorage.Classes.Car.Constants)

local function _HandleAdded(instance: Instance): ()
	if not instance:IsA("Model") then
		return
	end

	Car.new(instance)
end

local function _HandleRemoved(instance: Instance): ()
	if not instance:IsA("Model") then
		return
	end

	local car = Car.GetCar(instance)

	if not car then
		return
	end

	car:Destroy()
end

CollectionService:GetInstanceAddedSignal(Constants.Tags.CAR_TAG):Connect(_HandleAdded)
CollectionService:GetInstanceRemovedSignal(Constants.Tags.CAR_TAG):Connect(_HandleRemoved)

return {}
