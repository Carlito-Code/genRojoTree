local ReplicatedStorage = game:GetService("ReplicatedStorage")
local networker = require(ReplicatedStorage.Packages.networker)
local clientFunctions = require(ReplicatedStorage.Shared.Functions.clientFunctions)

local Services = ReplicatedStorage.Shared.Services

-- services startup
for _, ser in pairs(Services:GetChildren()) do
	for _, v in pairs(ser) do
		if v:IsA("ModuleScript") then
			local e = require(v)
			local lowered = string.lower(v.Name)
			local isServer = string.find(lowered, "client")

			if isServer then
				local net = isServer and networker.server.new(ser.Name, e, e.ClientAccess)
				pcall(function()
					e:init(net)
				end)
			end
		end
	end
end

-- global functions startup
local globalnet = networker.client.new("_global", clientFunctions)
