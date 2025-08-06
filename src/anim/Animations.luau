--// MODULE CREATED BY CARLITO [DO NOT MODIFY IF YOU DON'T KNOW WHAT YOU ARE DOING]

local AnimationFunctions = require(script.Parent.Util)

local Main = nil

local EasyAnimations = {}
EasyAnimations.__index = EasyAnimations

function EasyAnimations:BindButtonToFrame(GuiButton: GuiButton, Frame: GuiObject, Callback)
	if Frame:IsA("GuiObject") then
		Main:BindButtonToFrame(GuiButton, Frame, Callback)
	else
		warn("Frame needs to be a GUIobject")
	end
end

function EasyAnimations:BindCloseButtonToFrame(GuiButton: GuiButton, Frame: GuiObject, Callback)
	if Frame:IsA("GuiObject") then
		Main:BindCloseButtonToFrame(GuiButton, Frame, Callback)
	else
		warn("Frame needs to be a GUIobject")
	end
end

function EasyAnimations:OpenFrame(Frame: GuiObject, otherInfo)
	if Frame:IsA("GuiObject") then
		Main:CloseAllFrames()
		Main:OpenFrame(Frame, otherInfo)
	else
		warn("Frame needs to be a GUIobject")
	end
end

function EasyAnimations:ForceOpen(Frame: GuiObject)
	if Frame:IsA("GuiObject") then
		Main:CloseAllFrames()
	else
		warn("Frame needs to be a GUIobject")
	end
end

function EasyAnimations:CloseFrame(Frame: GuiObject)
	if Frame:IsA("GuiObject") then
		Main:CloseFrame(Frame)
	else
		warn("Frame needs to be a GUIobject")
	end
end

Main = AnimationFunctions.new()

return EasyAnimations
