local ReplicatedStorage = game:GetService("ReplicatedStorage")
local networker = require(ReplicatedStorage.Packages.networker)

local ExampleServiceClient = {
	net = {} :: networker.Client,
}

-- UTILITIES --

-- SERVER ACCESSED FUNCTIONS --

-- CLIENT ONLY FUNCTIONS --

function ExampleServiceClient:init(net)
	print(script.Name, "has been initialized")
	self.net = net
end

function ExampleServiceClient:start() end

return ExampleServiceClient
