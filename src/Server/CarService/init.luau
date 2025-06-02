--!strict
--!optimize 2
--!native

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ValidateExitArgs = require(script.ValidateExitArgs)
local ValidateSitArgs = require(script.ValidateSitArgs)
local Remotes = require(ReplicatedStorage.Remotes)
local Car_d = require(ReplicatedStorage.Types["Car.d"])

local CarRemotes = Remotes.Server:GetNamespace("Car");

(CarRemotes:Get("Sit") :: any):Connect(function(player: Player, carSeat: Car_d.CarSeat, humanoid: Humanoid): ()
	if not ValidateSitArgs(carSeat, humanoid) then
		warn(`Invalid arguments received from player '{player}'`)
		return
	end

	carSeat.Seat:Sit(humanoid)

	carSeat.Prompt.Enabled = false
end);

(CarRemotes:Get("Exit") :: any):Connect(function(player: Player, carSeat: Car_d.CarSeat): ()
	if not ValidateExitArgs(carSeat) then
		warn(`Invalid arguments received from player '{player}'`)
		return
	end

	-- Get humanoid root part
	local rootPart: BasePart? = carSeat.PlayerHumanoid and carSeat.PlayerHumanoid.RootPart

	if not rootPart then
		return
	end

	-- Destroy weld
	local seatWeld: Instance? = carSeat.Seat:FindFirstChild("SeatWeld")

	if seatWeld then
		seatWeld:Destroy()
	end

	carSeat.Prompt.Enabled = true
end)

return {}
