--!native
--!optimize 2

return function(seats: { Seat }): { [Seat]: ProximityPrompt }
	local seatPrompts: { [Seat]: ProximityPrompt } = {}

	for _, seat in seats do
		local prompt = seat:FindFirstChildOfClass("ProximityPrompt")

		if not prompt then
			print(`No prompt found in seat '{seat}'`)
			continue
		end

		print(`Found prompt in seat '{seat}'`)
		seatPrompts[seat] = prompt
	end

	return seatPrompts
end
