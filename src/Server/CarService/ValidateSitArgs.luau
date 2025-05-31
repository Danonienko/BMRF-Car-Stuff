--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local t = require(ReplicatedStorage.Packages.t)

return function(seat: Seat, humanoid: Humanoid): boolean
	if not (t.instanceIsA("Seat")(seat) or t.instanceIsA("VehicleSeat")(seat)) then
		return false
	end

	if not t.instanceIsA("Humanoid")(humanoid) then
		return false
	end

	return true
end
