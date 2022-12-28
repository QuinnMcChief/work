local Object = {}

local ServerStorage = game.ServerStorage;
local ts = game:GetService("TweenService");

local CollisionGroups = require(ServerStorage.Modules.CollisionGroups)

local tweenLength = 0.5;
local downwardsDistance = Vector3.new(0, 5, 0);
local tInfo = TweenInfo.new(tweenLength, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut);

local taskWaitLength = 0.015;

local function getPartClosestToCenter(object)
	local objCenter = object:GetBoundingBox();
	local closestPart;
	for _, v in (tycoonObject:GetDescendants()) do
		if (not v:IsA("Part")) then continue; end;
		if (closestPart) then
			if ((objCenter.Position - v.Position).Magnitude < (objCenter.Position - closestPart.Position).Magnitude) then
				closestPart = v;
			end
		else
			closestPart = v;
		end
	end
	return closestPart;
end

local function playPurchaseAndBuildSounds(centerPart)
	--> Clone sounds, place them in centerPart and play them.
end

function Object.construct(object)
	
	--> Play sounds when object begins construction
	local playSounds = coroutine.create(playPurchaseAndBuildSounds);
	coroutine.resume(playSounds, getPartClosestToCenter(tycoonObject));
	
	local objectPartsToTween = {};
	
	--> Sort parts by Y positions (height relative to each other)
	for _, instance in (object:GetDescendants()) do
		if (instance:IsA("BasePart")) then
			local objectHeight = instance.Position.Y;
			table.insert(objectPartsToTween, {instance, objectHeight});
		end
	end
	table.sort(objectPartsToTween, function(a, b)
		return a[2] < b[2];
	end)

	--> Initiate tween on all clients (visual purposes), you'll have to include this event yourself
  --[[some event]]:FireAllClients(objectPartsToTween, tweenLength, downwardsDistance, false);
  --> calculate wait time before verifying position on server.
	task.wait((tweenLength * 2) + (#objectPartsToTween * taskWaitLength))
	--> Moves the parts downwards on the server to match the location where the client tweened the parts to be (will look smooth, as if the whole thing was tweened on the server)
	for _, instanceAndPositionPair in (objectPartsToTween) do
		local part = instanceAndPositionPair[1];
		part.Position -= downwardsDistance;
		part.Transparency = 0;
		for _, descendant in (part:GetDescendants()) do
			if (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) then
				descendant.TextTransparency = 0;

			elseif (descendant:IsA("ImageLabel") or descendant:IsA("ImageButton")) then
				descendant.ImageTransparency = 0;

			elseif (descendant:IsA("Decal")) then
				descendant.Transparency = 0;
			end
		end
		task.wait();
	end
end

return Object;
