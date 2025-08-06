--// Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

--// Settings
local AnimationSettings = require(script.Parent.Settings)

local random = Random.new()

--// Buttons Variables
local RoationEnabled = AnimationSettings.Roatation.Enabled
local RoationTime = AnimationSettings.Roatation.Duration
local RotationAmount = AnimationSettings.Roatation.Amount

local Roations = {
	-RotationAmount,
	RotationAmount,
}

local ImageDarkerwhenHovering = AnimationSettings.ImageDarkerWhenHovered

local AnimationFunctions = {}
AnimationFunctions.__index = AnimationFunctions

function AnimationFunctions:HandleButton(instance: GuiButton)
	task.defer(function()
		local ButtonNormalSize = instance.Size
		local ButtonRoation = instance.Rotation

		local LocalRoationEnabled = if instance:GetAttribute("RotationEnabled") == nil
			then RoationEnabled
			else instance:GetAttribute("RotationEnabled")
		local SizeEnabled = if instance:GetAttribute("SizeEnabled") == nil
			then true
			else instance:GetAttribute("SizeEnabled")

		local NormalImageColor = nil

		if instance:IsA("ImageButton") then
			NormalImageColor = instance.ImageColor3
		end

		instance.MouseEnter:Connect(function()
			local ButtonRoation = Roations[random:NextInteger(1, 2)]

			if SizeEnabled then
				local HoverTween = TweenService:Create(
					instance,
					TweenInfo.new(AnimationSettings.HoverDuration, Enum.EasingStyle.Sine),
					{ Size = ButtonNormalSize + AnimationSettings.HoverOffset }
				)
				HoverTween:Play()
			end

			if ImageDarkerwhenHovering == true then
				if instance:IsA("ImageButton") then
					instance.ImageColor3 = instance.ImageColor3:Lerp(Color3.fromRGB(0, 0, 0), 0.3)
				end
			end

			if LocalRoationEnabled == true then
				local RotationTween = TweenService:Create(
					instance,
					TweenInfo.new(RoationTime, Enum.EasingStyle.Sine),
					{ Rotation = ButtonRoation }
				)
				RotationTween:Play()
			end

			if AnimationSettings.HoverSoundEnabled == true and AnimationSettings.HoverSound then
				AnimationSettings.HoverSound:Play()
			else
				if AnimationSettings.Warnings == true then
					warn("HoverSound has not been provided")
				end
			end
		end)

		instance.MouseLeave:Connect(function()
			local HoverFinishTween = TweenService:Create(
				instance,
				TweenInfo.new(AnimationSettings.HoverDuration, Enum.EasingStyle.Sine),
				{ Size = ButtonNormalSize }
			)
			HoverFinishTween:Play()

			if ImageDarkerwhenHovering then
				if instance:IsA("ImageButton") then
					instance.ImageColor3 = NormalImageColor
				end
			end

			if LocalRoationEnabled == true then
				local RotationTween =
					TweenService:Create(instance, TweenInfo.new(RoationTime, Enum.EasingStyle.Sine), { Rotation = 0 })
				RotationTween:Play()
			end
		end)

		instance.MouseButton1Click:Connect(function()
			local ClickTween = TweenService:Create(
				instance,
				TweenInfo.new(AnimationSettings.ClickDuration, Enum.EasingStyle.Sine),
				{ Size = ButtonNormalSize + AnimationSettings.ClickOffset }
			)
			ClickTween:Play()

			ClickTween.Completed:Connect(function()
				local ClickEndTween = TweenService:Create(
					instance,
					TweenInfo.new(AnimationSettings.ClickDuration, Enum.EasingStyle.Sine),
					{ Size = ButtonNormalSize }
				)
				ClickEndTween:Play()
			end)

			if AnimationSettings.ClickSoundEnabled == true and AnimationSettings.ClickSound then
				AnimationSettings.ClickSound:Play()
			else
				if AnimationSettings.Warnings == true then
					warn("ClickSound has not been provided")
				end
			end
		end)
	end)
end

function AnimationFunctions:OpenFrame(FrameInstance, otherinfo)
	task.defer(function()
		--// Handling the frame in case it doesn't exist inside of the frames table
		if not self.Frames[FrameInstance.Name] then
			self:SetupFrameInSelf(FrameInstance)
		end

		if self.Frames[FrameInstance.Name].State == true then
			return
		end

		self.Frames[FrameInstance.Name].State = true

		if self.Frames[FrameInstance.Name].OC then
			self.Frames[FrameInstance.Name].OC(otherinfo)
		end

		--// In case blur is enabled we add a blur effect when opening the frame
		if AnimationSettings.BlurEffect == true then
			local NewBlur = Lighting:FindFirstChild("Blur")

			if not NewBlur then
				NewBlur = Instance.new("BlurEffect")
				NewBlur.Name = "Blur"
				NewBlur.Size = 0
				NewBlur.Parent = Lighting
			end

			self.NewBlur = NewBlur

			local BlurTween = TweenService:Create(
				NewBlur,
				TweenInfo.new(AnimationSettings.FrameOpeningSettings.Duration / 2, Enum.EasingStyle.Sine),
				{ Size = 15 }
			)
			BlurTween:Play()
		end

		--// In case camerazoom was enabled the zoom will start working
		if AnimationSettings.CameraZoom.Enabled == true then
			local CameraZoomTween = TweenService:Create(
				self.CurrentCamera,
				TweenInfo.new(AnimationSettings.CameraZoom.Duration, Enum.EasingStyle.Sine),
				{ FieldOfView = self.CurrentCameraNormalFOV - AnimationSettings.CameraZoom.Amount }
			)
			CameraZoomTween:Play()
		end

		--// Normal Opening
		local OpenTween = TweenService:Create(
			FrameInstance,
			TweenInfo.new(AnimationSettings.FrameOpeningSettings.Duration, Enum.EasingStyle.Quart),
			{ Position = self.Frames[FrameInstance.Name].Position }
		)
		OpenTween:Play()
	end)
end

function AnimationFunctions:CloseFrame(FrameInstance, CloseBlur)
	if CloseBlur == nil then
		CloseBlur = true
	end

	task.defer(function()
		--// Handling the frame in case it doesn't exist inside of the frames table
		if not self.Frames[FrameInstance.Name] then
			self:SetupFrameInSelf(FrameInstance)
		end

		if self.Frames[FrameInstance.Name].State == false then
			return
		end

		self.Frames[FrameInstance.Name].State = false

		--// In case blur is enabled we add a blur effect when opening the frame
		if CloseBlur == true then
			if self.NewBlur then
				local BlurTween = TweenService:Create(
					self.NewBlur,
					TweenInfo.new(AnimationSettings.FrameOpeningSettings.Duration / 2, Enum.EasingStyle.Sine),
					{ Size = 0 }
				)
				BlurTween:Play()

				self.NewBlur:Destroy()
			end
		end

		--// In case camerazoom was enabled the zoom will start working
		if CloseBlur == true then
			if AnimationSettings.CameraZoom ~= self.CurrentCameraNormalFOV then
				local CameraZoomTween = TweenService:Create(
					self.CurrentCamera,
					TweenInfo.new(AnimationSettings.CameraZoom.Duration, Enum.EasingStyle.Sine),
					{ FieldOfView = self.CurrentCameraNormalFOV }
				)
				CameraZoomTween:Play()
			end
		end

		--// Normal Closing
		local CloseTween = TweenService:Create(
			FrameInstance,
			TweenInfo.new(AnimationSettings.FrameOpeningSettings.Duration, Enum.EasingStyle.Quart),
			{ Position = self.Frames[FrameInstance.Name].ClosedPosition }
		)
		CloseTween:Play()
	end)
end

function AnimationFunctions:CloseAllFrames()
	task.defer(function()
		for name, info in pairs(self.Frames) do
			if info.State == true then
				self:CloseFrame(info.Object, false)
			end
		end
	end)
end

function AnimationFunctions:SetupFrameInSelf(FrameInstance, OpeningCallback)
	local YPosition = nil
	local XPosition = nil

	if not AnimationSettings.FramePositionWhenClosedX then
		XPosition = FrameInstance.Position.X
	else
		XPosition = AnimationSettings.FramePositionWhenClosedX
	end

	if not AnimationSettings.FramePositionWhenClosedY then
		YPosition = FrameInstance.Position.Y
	else
		YPosition = AnimationSettings.FramePositionWhenClosedY
	end

	self.Frames[FrameInstance.Name] = {
		State = false,
		Object = FrameInstance,
		Position = FrameInstance.Position,
		ClosedPosition = UDim2.new(XPosition, YPosition),
		OC = OpeningCallback,
	}

	FrameInstance.Position = UDim2.new(XPosition, YPosition)
end

function AnimationFunctions:BindButtonToFrame(buttonInstance: GuiButton, FrameInstance: GuiObject, Callback)
	if not buttonInstance or not FrameInstance then
		error("BindButtonToFrame Function cannot work withouth Buttoninstance or FrameInstance")
		return
	end
	--// Does a default setup and in case of 2 buttons to open a frame it handles both
	if not self.Frames[FrameInstance.Name] then
		self:SetupFrameInSelf(FrameInstance, Callback)
	end

	buttonInstance.Activated:Connect(function()
		local Frame = self.Frames[FrameInstance.Name]

		if Frame.State == false then
			self:CloseAllFrames()
			self:OpenFrame(FrameInstance)
		else
			self:CloseFrame(FrameInstance)
		end
	end)
end

function AnimationFunctions:BindCloseButtonToFrame(buttonInstance: GuiButton, FrameToClose: GuiObject, Callback)
	if not buttonInstance then
		warn("Button Instance not provided in cloe button function")
		return
	end

	buttonInstance.MouseButton1Click:Connect(function()
		if Callback then
			Callback()
		end

		self:CloseFrame(FrameToClose)
	end)
end

function AnimationFunctions:Initialize()
	--// Handles all of the buttons animations / sounds
	for _, instance: Instance in pairs(self.ButtonsContainer:GetDescendants()) do
		if instance:IsA("GuiButton") then
			self:HandleButton(instance)
		end
	end

	--// In case of any button added it will be handled by this function
	self.ButtonsContainer.DescendantAdded:Connect(function(InstanceAdded)
		if InstanceAdded:IsA("GuiButton") then
			self:HandleButton(InstanceAdded)
		end
	end)
end

function AnimationFunctions.new()
	if RunService:IsServer() then
		error("This module cannot be used on the server, it requires a client script to function")
		return
	end

	local self = setmetatable({}, AnimationFunctions)

	--// Variables that will be passed troughout all of the scripts
	self.Frames = {}
	self.ButtonsContainer = game.Players.LocalPlayer:WaitForChild("PlayerGui").MainGui

	--// Camera stuff
	self.CurrentCamera = game.Workspace.CurrentCamera
	self.CurrentCameraNormalFOV = self.CurrentCamera.FieldOfView

	self.Player = Players.LocalPlayer

	--// Initializes the module script withouth the needs of any external scripts
	self:Initialize()

	return self
end

return AnimationFunctions
