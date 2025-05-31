--!strict
--!optimize 2
--!native

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Car_d = require(ReplicatedStorage.Types["Car.d"])

return function(carModel: Model): { Car_d.CarSeat }
	local carSeats: { Car_d.CarSeat } = {}

	for _, descendant in carModel:GetDescendants() do
		if not (descendant:IsA("Seat") or descendant:IsA("VehicleSeat")) then
			continue
		end

		local seatPrompt: ProximityPrompt? = descendant:FindFirstChildOfClass("ProximityPrompt")

		if not seatPrompt then
			print(`No prompt found for seat '{descendant}'`)
			continue
		end

		print(`Found prompt in seat '{descendant}'`)

		local seatAttachment: Attachment? = descendant:FindFirstChildOfClass("Attachment")

		if not seatAttachment then
			print(`No attachment found for seat '{descendant}'`)
			continue
		end

		print(`Found attachment in seat '{descendant}'`)

		local carSeat = {} :: Car_d.CarSeat
		carSeat.Seat = descendant :: Seat
		carSeat.Prompt = seatPrompt
		carSeat.Attachment = seatAttachment
		carSeat.Occupied = false

		table.insert(carSeats, carSeat)
		
		print(`Initialized seat '{descendant}'`)
	end

	return carSeats
end
