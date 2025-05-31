--!strict
--!optimize 2
--!native

return function(model: Model): { Seat }
	local seats: { Seat } = {}

	for _, descendant in model:GetDescendants() do
		if descendant:IsA("Seat") or descendant:IsA("VehicleSeat") then
			print(`Found a seat '{descendant}'`)
			table.insert(seats, descendant :: Seat)
		end
	end

	return seats
end
