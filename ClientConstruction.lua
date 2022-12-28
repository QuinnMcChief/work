local ts = game:GetService("TweenService");

local function tweenObject(objectParts, tweenLength: number, downwardsDistance: Vector3)
	local tInfo = TweenInfo.new(tweenLength, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut);
	for _, instanceAndPositionPair in (objectParts) do
		local part = instanceAndPositionPair[1];
		
		local positionTween     = ts:Create(part, tInfo, {Position = part.Position - downwardsDistance});
		local transparencyTween = ts:Create(part, tInfo, {Transparency = 0});

    positionTween:Play();
		transparencyTween:Play();
    
		--> Tween images/text to be visible
		for _, gui in (part:GetDescendants()) do
			if (gui:IsA("TextButton") or gui:IsA("TextBox") or gui:IsA("TextLabel")) then
				local transparencyTween = ts:Create(gui, tInfo, {TextTransparency = 0});
				transparencyTween:Play();

			elseif (gui:IsA("ImageLabel") or gui:IsA("ImageButton")) then
				local transparencyTween = ts:Create(gui, tInfo, {ImageTransparency = 0});
				transparencyTween:Play();

			elseif (gui:IsA("Decal")) then
				local transparencyTween = ts:Create(gui, tInfo,  {Transparency = 0});
				transparencyTween:Play();

			end
		end
		task.wait();
	end
end
script.Parent.OnClientEvent:Connect(tweenTycoonObject);
