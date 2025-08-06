local ReplicatedStorage = game:GetService("ReplicatedStorage")
local networker = require(ReplicatedStorage.Packages.networker)

local ExampleServiceClient = {
	net = {} :: networker.Client,
}

-- UTILITIES --

-- SERVER ACCESSED FUNCTIONS --

-- CLIENT ONLY FUNCTIONS --

function ExampleServiceClient.init(self: ExampleServiceClient, net: networker.Client)
	print(script.Name, "has been initialized")
	self.net = net
end

export type ExampleServiceClient = typeof(ExampleServiceClient) & {}

return ExampleServiceClient
