-- Goes through <code>container</code>'s children and emits particles from emitters based on their <code>EmitCount</code> attribute.
-- Also accounts for <code>EmitDelay</code> attribute (if it exists).
-- You can optionally search through all descendants.
return function(container: Instance, descendants: boolean?)
	local function handleChild(child: Instance)
		if child:IsA("ParticleEmitter") then
			local delay = child:GetAttribute("EmitDelay")
			local count = child:GetAttribute("EmitCount")
			if not count then
				warn(`emitter: {child} missing EmitCount attribute, defaulting to 1`)
				count = 1
			end
			if delay then
				task.delay(delay, function()
					child:Emit(count)
				end)
			else
				child:Emit(count)
			end
		end
	end

	if descendants then
		for _, descendant in ipairs(container:GetDescendants()) do
			handleChild(descendant)
		end
	else
		for _, child in ipairs(container:GetChildren()) do
			handleChild(child)
		end
	end
end
