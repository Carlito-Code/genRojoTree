local ReplicatedStorage = game:GetService("ReplicatedStorage")
local networker = require(ReplicatedStorage.Packages.networker)

local ExampleServiceServer = {
	net = nil :: networker.Server,
}

-- LOCAL UTILITIES --

-- CLIENT EXPOSED FUNCTIONS --

-- SERVER FUNCTIONS --

-- INITIALIZATION --

function ExampleServiceServer.init(self: ExampleServiceServer)
	print("hi from ExampleServiceServer!")
end

export type ExampleServiceServer = typeof(ExampleServiceServer) & {}

return ExampleServiceServer
