local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local networker = require(ReplicatedStorage.Packages.networker)
local global = require(ReplicatedStorage.Shared.Functions.global)

local Services = ServerScriptService.Services

for _, ser in pairs(Services:GetChildren()) do
	for _, v in pairs(ser) do
		if v:IsA("ModuleScript") then
			local e = require(v)
			local lowered = string.lower(v.Name)
			local isServer = string.find(lowered, "server")

			if isServer then
				local net = isServer and networker.server.new(ser.Name, e, e.ClientAccess)
				pcall(function()
					e:start()
					e:init(net)
				end)
			end
		end
	end
end
