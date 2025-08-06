local ReplicatedStorage = game:GetService("ReplicatedStorage")
local viewport = require(ReplicatedStorage.Packages.viewport)
local viewportHandler = {}
viewportHandler.__index = viewportHandler

function viewportHandler.new(vw: ViewportFrame, model: Model)
	model = model:Clone()
	model.Parent = vw
	local cam = Instance.new("Camera")
	vw.CurrentCamera = cam
	cam.Parent = vw

	local viewportUtil = viewport.new(vw, cam)
	viewportUtil:SetModel(model)

	viewport:GetMinimumFitCFrame(Vector3.new(15, 20, 0))
	local rotation = CFrame.Angles(math.rad(-15), math.rad(45), 0)
	local camCFrame = viewport:GetMinimumFitCFrame(rotation)
	cam.CFrame = camCFrame
	return viewportUtil
end

export type viewportHandler = typeof(viewportHandler) & {}

return viewportHandler
