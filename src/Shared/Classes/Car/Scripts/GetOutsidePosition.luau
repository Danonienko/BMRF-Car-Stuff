--!strict
--!optimize 2
--!native

local Workspace = game:GetService("Workspace")

return function(seat: Seat): CFrame
	local size = Vector3.new(3, 3, 3)

	-- Check Left Side
	local position = seat.CFrame * CFrame.new(-6, 2, 0)
	local overlappingParts = Workspace:GetPartBoundsInBox(position, size)

	if #overlappingParts == 0 then
		return position
	end

	-- Check Right Side
	position = seat.CFrame * CFrame.new(6, 2, 0)
	overlappingParts = Workspace:GetPartBoundsInBox(position, size)

	if #overlappingParts == 0 then
		return position
	end

	-- Check Top Side
	position = seat.CFrame * CFrame.new(0, 10, 0)
	overlappingParts = Workspace:GetPartBoundsInBox(position, size)

	if #overlappingParts == 0 then
		return position
	end

	-- Check Front Side
	position = seat.CFrame * CFrame.new(0, 3, 15)
	overlappingParts = workspace:GetPartBoundsInBox(position, size)

	if #overlappingParts == 0 then
		return position
	end

	-- Check Back Side
	position = seat.CFrame * CFrame.new(0, 3, -15)
	overlappingParts = Workspace:GetPartBoundsInBox(position, size)

	return position
end
