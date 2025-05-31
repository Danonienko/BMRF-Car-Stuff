--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)

return Net.CreateDefinitions({
	Car = Net.Definitions.Namespace({
		Sit = Net.Definitions.ClientToServerEvent(),
		Exit = Net.Definitions.ClientToServerEvent(),
	}),
})
