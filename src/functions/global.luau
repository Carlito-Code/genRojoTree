local ReplicatedStorage = game:GetService("ReplicatedStorage")
local networker = require(ReplicatedStorage.Packages.networker)

local net = networker.server.new("_global")
return function(callbackName, players, ...)
	net:fire(players, callbackName, ...)
end
