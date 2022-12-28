
--[[
	OLD, LAGGY, AND DEPRECATED. USE NEW MODULE.
]]

local Construction = {}

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

function Construction.getCenter(object)
	local cframe, size = object:GetBoundingBox()
	local objPosition = cframe.p -- CFrame has two parameters when calculated: Position and Orientation. "p" is position
	local closestObject
	for i, v in pairs(object:GetChildren()) do
		if v:IsA("BasePart") or v:IsA("Part") then
			if closestObject ~= nil then
				if (objPosition - v.Position).Magnitude < (objPosition - closestObject.Position).Magnitude then
					closestObject = v
				end
			else
				closestObject = v
			end
		end
	end
	return closestObject
end

function Construction.makeSureSoundsExist(centralObject)
	local purchaseSounds = SoundService:WaitForChild("purchaseSounds")
	local constructionSounds = SoundService:WaitForChild("constructionSounds")

	for _, sound in pairs(purchaseSounds:GetChildren()) do
		if not centralObject:FindFirstChild(sound.Name) then
			local newSound = sound:Clone()
			newSound.Parent = centralObject -- "Center" object value pointing to the block I want to be the center (the part going to have sounds inserted into)
		end
	end
	
	for _, sound in pairs(constructionSounds:GetChildren()) do
		if not centralObject:FindFirstChild(sound.Name) then
			local newSound = sound:Clone()
			newSound.Name = sound.Name
			newSound.Parent = centralObject -- "Center" object value pointing to the block I want to be the center (the part going to have sounds inserted into)
		end
	end
end

function Construction.Purchase(center)
	for i, v in pairs(center:GetChildren()) do
		if v:IsA("Sound") then
			v:Play()
		end
	end
end

function Construction.Build(center, object)
	-- if sounds already playing, stop them
	for _, v in pairs(center:GetChildren()) do
		if v:IsA("Sound") then
			v:Stop()
		end
	end
	-- play the sound
	for _, v in pairs(center:GetChildren()) do
		if v:IsA("Sound") then
			v:Play()
		end
	end

	Construction.TweenBuild(object)
end

function Construction.TweenBuild(object)
	--object.Parent = purchased -- sets object's parent to the tycoon's purchased folder
	local order = {}
	for i ,v in ipairs(object:GetDescendants()) do
		if v:IsA("Part") or v:IsA("BasePart") then
			v.CanCollide = true
			local y = (v.Position - v.CFrame.UpVector * v.Size.Y/2).Y
			local itemTab = {v, v.Position}
			local items = order[y]
			if items then
				table.insert(items, itemTab)
			else
				order[y] = {itemTab}
			end
		end
	end

	table.sort(order)

	for i ,v in pairs(order) do
		for i ,item in ipairs(v) do
			item[1].Position += Vector3.new(0, 5, 0)
		end
	end

	local tweens = {}
	for i, items in pairs(order) do
		for _ ,item in ipairs(items) do
			local tween = game.TweenService:Create(item[1], TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = item[2]; Transparency = 0})
			table.insert(tweens, tween)
			tween:Play()
			wait()
		end
		order[i] = nil
		--wait()
	end
	for i, v in pairs(object:GetDescendants()) do -- Images / Labels / Decals
		local Info = TweenInfo.new(
			0.5,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.In,
			0,
			false,
			0
		)
		if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
			local Goal = {TextTransparency = 0}
			local tween = TweenService:Create(v, Info, Goal)
			tween:Play()
		elseif v:IsA("Decal") then
			local Goal = {Transparency = 0}
			local tween = TweenService:Create(v, Info, Goal)
			tween:Play()
		end
	end

	--for i = #tweens, 1, -1 do
		--local tween = tweens[i]
		--if tween.PlaybackState ~= Enum.PlaybackState.Completed then
		--	tween.Completed:Wait()
		--end
	--	tween:Destroy()
	--	table.remove(tweens, i)
	--end
end

function Construction.vanishMostTycoonStuff(tycoon)
	for _, button in pairs(tycoon.Buttons:GetChildren()) do
		if not button:FindFirstChild("Essential") then
			button.Head.Transparency = 1
			button.Head.CanCollide = false
			for _, GUI in pairs(button.Head:GetDescendants()) do -- Get BillboardGUIs in the buttonpart
				if GUI:IsA("TextLabel") then
					GUI.TextTransparency = 1
				end
			end
		else
			button.Head.Transparency = 0
			button.Head.CanCollide = true
			for _, label in pairs(button:GetDescendants()) do
				if label:IsA("TextLabel") then
					label.TextTransparency = 0
				end
			end
		end
	end
	-- Turn Buildings and Text-Related objects Transparency to 1 (in the Purchased folder of course, which means everything bought by the player vanishes)
	for _, building in pairs(tycoon.Purchases:GetChildren()) do
		for _, buildingParts in pairs(building:GetDescendants()) do
			if (buildingParts:IsA("Part") or buildingParts:IsA("BasePart")) and not building:FindFirstChild("Essential") then
				buildingParts.Transparency = 1
				buildingParts.CanCollide = false
				for _, GUI in pairs(building:GetDescendants()) do -- Get BillboardGUIs in the buttonpart
					if GUI:IsA("TextLabel") or GUI:IsA("TextBox") or GUI:IsA("TextButton") then 
						GUI.TextTransparency = 1
					elseif GUI:IsA("Decal") and not GUI:FindFirstChild("Ignore") then -- finds if its a decal instead of a GUI
						GUI.Transparency = 1
					end
				end
			end
		end
	end
	-- Destroy all chests
	for _, model in pairs(tycoon.Purchases:GetDescendants()) do
		if model.Name == "newChest" then model:Destroy() end
	end
end


return Construction
