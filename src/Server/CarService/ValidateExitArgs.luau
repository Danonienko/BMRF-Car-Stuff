--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local t = require(ReplicatedStorage.Packages.t)
local Car_d = require(ReplicatedStorage.Types["Car.d"])

local IsCarSeatInterface = t.strictInterface({
	Seat = t.instanceIsA("Seat"),
	Prompt = t.instanceIsA("ProximityPrompt"),
	Attachment = t.instanceIsA("Attachment"),
	IsPlayerSitting = t.boolean,
	PlayerHumanoid = t.optional(t.instanceIsA("Humanoid")),
})

return function(carSeat: Car_d.CarSeat): boolean
	return IsCarSeatInterface(carSeat)
end
