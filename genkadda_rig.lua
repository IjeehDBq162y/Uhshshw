local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local SCALE = 4.5
local FLY_MAX_SPEED = 80
local AMBIENT_SOUND_ID = "rbxassetid://238510574"
local SLASH_SOUND_IDS = {"rbxassetid://161006212", "rbxassetid://161006195"}
local STAB_SOUND_ID = "rbxassetid://206083107"
local JOKE_SOUND_ID = "rbxassetid://261303790"
local PITCHES = {0.7, 0.8, 0.9, 1}
local JOKE_PITCHES = {6.6, 6.8, 7, 7.2, 7.4}
local REAPER_MESH_ID = "rbxassetid://16150814"
local REAPER_TEXTURE_ID = "rbxassetid://16150799"

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")
local torso = char:WaitForChild("Torso")
local head = char:WaitForChild("Head")
local rarm = char:WaitForChild("Right Arm")
local larm = char:WaitForChild("Left Arm")
local rleg = char:WaitForChild("Right Leg")
local lleg = char:WaitForChild("Left Leg")
local cam = workspace.CurrentCamera

hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
for _, child in ipairs(char:GetChildren()) do
	if child:IsA("Accessory") then
		child:Destroy()
	end
end
for _, sound in ipairs(head:GetChildren()) do
	if sound:IsA("Sound") then
		sound:Destroy()
	end
end
for _, motor in ipairs(char:GetDescendants()) do
	if motor:IsA("Motor6D") then
		motor:Destroy()
	end
end

local function joint(part0, part1, c0, c1)
	local weld = Instance.new("Weld")
	weld.Name = "Weld"
	weld.Part0 = part0
	weld.Part1 = part1
	weld.C0 = c0
	weld.C1 = c1 or CFrame.new()
	weld.Parent = part1
	return weld
end

for _, part in ipairs({rarm, larm, rleg, lleg, torso, head, root}) do
	part.Size = part.Size * SCALE
end

local rootJoint = joint(root, torso, CFrame.new())
local rArmJoint = joint(torso, rarm, CFrame.new(1.5, 0.5, 0), CFrame.new(-5.2, 0.5, 0))
local lArmJoint = joint(torso, larm, CFrame.new(-1.5, 0.5, 0), CFrame.new(5.2, 0.5, 0))
local headJoint = joint(torso, head, CFrame.new(0, 6.8, 0))
local rLegJoint = joint(torso, rleg, CFrame.new(0.5, -1, 0), CFrame.new(-1.7, 8, 0))
local lLegJoint = joint(torso, lleg, CFrame.new(-0.5, -1, 0), CFrame.new(1.7, 8, 0))

local joints = {RA = rArmJoint, LA = lArmJoint, H = headJoint, T = rootJoint, LL = lLegJoint, RL = rLegJoint}

local function P(x, y, z, rx, ry, rz)
	return CFrame.new(x, y, z) * CFrame.Angles(math.rad(rx or 0), math.rad(ry or 0), math.rad(rz or 0))
end

local function idlePose(t)
	local c = math.cos(t / 14)
	return {
		RA = P(3, -2.2 + 0.1 * c, 0, 0, 0, 40 + 2 * c),
		LA = P(-1.5, -0.65 + 0.1 * c, 0, -20, 0, -20 - 2 * c),
		H = P(0, 6.8, -0.2, -14 + c, 50, 0),
		T = P(0, -1, 0, 0, -50, 0),
		LL = P(0, -1.2, -0.5, 10, 30, -20),
		RL = P(0, -1.2, -0.5, 0, -15, 20),
	}
end

local function walkPose(t)
	local s = math.sin(t / 8)
	local c8 = math.cos(t / 8)
	local c4 = math.cos(t / 4)
	return {
		RA = P(3, -2.2, 0, -20, -20, 40),
		LA = CFrame.new(-1.5, 0, -s / 2.8) * CFrame.Angles(s / 4, -s / 2, math.rad(-10)),
		H = P(0, 6.8, 0, -8 + 2 * c4),
		T = P(0, -1 + 0.1 * c4, 0, -4 + 2 * c4),
		LL = CFrame.new(-0.5, -1 - 0.05 * c8, -0.05 + s / 3.4) * CFrame.Angles(math.rad(-10) - s / 2.3, 0, 0),
		RL = CFrame.new(0.5, -1 + 0.05 * c8, -0.05 - s / 3.4) * CFrame.Angles(math.rad(-10) + s / 2.3, 0, 0),
	}
end

local function runPose(t)
	local c = math.cos(t / 14)
	return {
		RA = P(4, -0.5, 0, 0, -50, 40),
		LA = P(-4, -0.5, 0, 0, 50, -40),
		H = P(0, 6.8, 0, 44, 0, 0),
		T = CFrame.new(0, 1 - 0.1 * c, -1) * CFrame.Angles(math.rad(-80), 0, 0),
		LL = P(-0.1, -1, 0, 8, 0, -10),
		RL = P(0.1, -1, 0, 8, 0, 10),
	}
end

local function floatPose(t)
	local c = math.cos(t / 14)
	return {
		RA = P(1.5, -0.62 + 0.1 * c, 0, -16, -12, 10 + 2 * c),
		LA = P(-1.5, -0.62 + 0.1 * c, 0, -16, 12, -10 - 2 * c),
		H = P(0, 6.8, -0.2, -14 + c, 0, 0),
		T = CFrame.new(0, -1 - 0.4 * c, 0),
		LL = P(-0.1, -1, 0, 0, 0, -8 - 2 * c),
		RL = P(0.1, -1, 0, 0, 0, 8 + 2 * c),
	}
end

local function meleePose(t)
	local c = math.cos(t / 14)
	return {
		RA = P(1.5, -0.65 + 0.1 * c, 0, 0, 0, 20 + 2 * c),
		LA = P(-1.5, -0.65 + 0.1 * c, 0, 0, 0, -20 - 2 * c),
		H = P(0, 6.8, -0.2, -20 + c, 0, 0),
		T = P(0, -1, 0, 0, 0, 0),
		LL = P(-0.1, -1, 0, 0, 0, -10),
		RL = P(0.1, -1, 0, 0, 0, 10),
	}
end

local SLASH_WIND = {
	RA = P(5, 0.65, -6, 60, 70, 70),
	LA = P(-1.5, -1, 2.2, -20, 0, -40),
	H = P(0, 6.8, 0, 0, -50, 0),
	T = P(-0.4, -1, 0, 0, 70, 0),
	LL = P(-0.1, -1, 0, -10, 0, -10),
	RL = P(0.1, -1, 0, 10, 0, 10),
}
local SLASH_STRIKE = {
	RA = P(2, -2, 3, -40, -20, 40),
	LA = P(-1, 0.65, -0.3, 65, -20, 30),
	H = P(0, 6.8, 0, -9, 35, 0),
	T = P(0, -1, 1, 0, -65, 0),
	LL = P(-0.1, -1, 0, 10, 0, -10),
	RL = P(0.1, -1, 0, -10, 0, 10),
}
local STAB_RAISE = {
	LA = P(-1.1, 0.6, -0.4, 130, 0, 40),
	RA = P(1.1, 0.6, -0.4, 130, 0, -40),
	T = P(0, -1, 0, 30, 0, 0),
	H = P(0, 6.8, 0, 50, 0, 0),
	LL = P(-0.5, -1, 0, -30, 0, 0),
	RL = P(0.5, -0.2, -0.5, -10, 0, 0),
}
local STAB_THRUST = {
	LA = P(-1.1, 0.6, -0.4, 50, 0, 40),
	RA = P(1.1, 0.6, -0.4, 50, 0, -40),
	T = P(0, -2, 0, -30, 0, 0),
	H = P(0, 6.8, 0, 10, 0, 0),
	LL = P(-0.5, 0, -0.7, 20, 0, 0),
	RL = P(0.5, -1, -0.1, -40, 0, 0),
}
local SPIN_LUNGE = {
	RA = P(8.2, -2.9, 0, 0, 0, 90),
	LA = P(-8.2, -2.9, 0, 0, 0, -90),
	T = P(0, -1, 0, 0, 0, 0),
	H = P(0, 6.8, 0, 0, 0, 0),
	LL = P(-0.5, -1, 0, 0, 0, 0),
	RL = P(0.5, -1, 0, 0, 0, 0),
}

local sine = 0
local override = nil
local flyToggled = false
local meleeStance = false
local attacking = false
local jokeReady = true

local function computePose(t)
	if flyToggled then
		return floatPose(t)
	end
	if meleeStance then
		return meleePose(t)
	end
	local v = root.AssemblyLinearVelocity
	local speed = Vector3.new(v.X, 0, v.Z).Magnitude
	if speed > 20 then
		return runPose(t)
	end
	if speed > 2 then
		return walkPose(t)
	end
	return idlePose(t)
end

RunService.RenderStepped:Connect(function()
	sine += 1
	local pose = override or computePose(sine)
	local alpha = override and 0.35 or 0.2
	for name, target in pairs(pose) do
		local weld = joints[name]
		weld.C0 = weld.C0:Lerp(target, alpha)
	end
end)

local weaponModel = Instance.new("Model")
weaponModel.Name = "Genkadda"
weaponModel.Parent = char

local holder = Instance.new("Part")
holder.Name = "Thingy"
holder.Size = Vector3.new(5.5, 5.5, 5.5)
holder.Transparency = 1
holder.CanCollide = false
holder.Massless = true
holder.CFrame = rarm.CFrame
holder.Parent = weaponModel
joint(rarm, holder, CFrame.new(0, -3, 0))

local WEAPON_PARTS = {
	{"Handle", Vector3.new(0.54, 4.96, 1.03), Vector3.new(0, 0, 0), Color3.fromRGB(27, 42, 53), Enum.Material.Granite},
	{"Guard", Vector3.new(0.52, 0.2, 4.93), Vector3.new(0, 2.5, 0), Color3.fromRGB(17, 17, 17), Enum.Material.Granite},
	{"Shaft", Vector3.new(0.54, 20, 3.03), Vector3.new(0, 12.5, 0), Color3.fromRGB(17, 17, 17), Enum.Material.Granite},
	{"Edge", Vector3.new(0.4, 20, 5.03), Vector3.new(0, 12.5, 0), Color3.fromRGB(245, 221, 0), Enum.Material.Neon},
	{"Tip", Vector3.new(0.86, 0.66, 5.66), Vector3.new(0, 24, 0), Color3.fromRGB(245, 221, 0), Enum.Material.Neon},
}

local weaponParts = {}
for _, spec in ipairs(WEAPON_PARTS) do
	local part = Instance.new("Part")
	part.Name = spec[1]
	part.Size = spec[2]
	part.Color = spec[4]
	part.Material = spec[5]
	part.CanCollide = false
	part.Massless = true
	part.TopSurface = Enum.SurfaceType.SmoothNoOutlines
	part.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
	part.CFrame = holder.CFrame * CFrame.new(spec[3])
	part.Parent = weaponModel
	joint(holder, part, CFrame.new(spec[3]))
	table.insert(weaponParts, part)
end

for _, x in ipairs({-0.7, 0.7}) do
	local eye = Instance.new("Part")
	eye.Name = "Eye"
	eye.Shape = Enum.PartType.Ball
	eye.Size = Vector3.new(1, 1, 1)
	eye.Material = Enum.Material.Neon
	eye.Color = Color3.fromRGB(255, 0, 0)
	eye.CanCollide = false
	eye.Massless = true
	eye.TopSurface = Enum.SurfaceType.Smooth
	eye.BottomSurface = Enum.SurfaceType.Smooth
	eye.CFrame = head.CFrame
	eye.Parent = char
	joint(head, eye, CFrame.new(x, 0.6, -3.8))
end

local reaper = Instance.new("Part")
reaper.Name = "Reaper"
reaper.Size = Vector3.new(1, 1, 1)
reaper.CanCollide = false
reaper.Massless = true
reaper.TopSurface = Enum.SurfaceType.Smooth
reaper.BottomSurface = Enum.SurfaceType.Smooth
reaper.CFrame = head.CFrame
reaper.Parent = char
joint(head, reaper, CFrame.new(0, 1, 0))
local reaperMesh = Instance.new("SpecialMesh")
reaperMesh.MeshId = REAPER_MESH_ID
reaperMesh.TextureId = REAPER_TEXTURE_ID
reaperMesh.Scale = Vector3.new(5.181, 5.181, 5.181)
reaperMesh.VertexColor = Vector3.new(0.3, 0.3, 0.3)
reaperMesh.Parent = reaper

local ambient = Instance.new("Sound")
ambient.SoundId = AMBIENT_SOUND_ID
ambient.Looped = true
ambient.Volume = 1
ambient.Pitch = 0.72
ambient.Parent = char
task.delay(1, function()
	ambient:Play()
end)

local function sfx(id, pitch, volume, parent)
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Pitch = pitch
	s.Volume = volume
	s.Parent = parent or head
	s:Play()
	Debris:AddItem(s, 4)
end

local bodyVel = Instance.new("BodyVelocity")
bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
local bodyGyro = Instance.new("BodyGyro")
bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
local bodyPos = Instance.new("BodyPosition")
bodyPos.MaxForce = Vector3.new(0, math.huge, 0)
local flySpeed = 0

local function setFly(on)
	flyToggled = on
	if on then
		hum.PlatformStand = true
		bodyGyro.Parent = root
	else
		hum.PlatformStand = false
		bodyVel.Parent = nil
		bodyPos.Parent = nil
		bodyGyro.Parent = nil
		flySpeed = 0
	end
end

RunService.Heartbeat:Connect(function()
	if not flyToggled then
		return
	end
	local f, s = 0, 0
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then f += 1 end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then f -= 1 end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then s -= 1 end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then s += 1 end

	if f ~= 0 or s ~= 0 then
		flySpeed = math.min(flySpeed + 1 + flySpeed / FLY_MAX_SPEED, FLY_MAX_SPEED)
		bodyPos.Parent = nil
		bodyVel.Parent = root
	else
		flySpeed = math.max(flySpeed - 1, 0)
		bodyPos.Position = root.Position
		bodyPos.Parent = root
		bodyVel.Parent = nil
	end

	local camCF = cam.CFrame
	local dir = camCF.LookVector * f + camCF.RightVector * s
	if dir.Magnitude > 0 then
		dir = dir.Unit
	end
	bodyVel.Velocity = dir * flySpeed

	local flat = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
	if flat.Magnitude > 0 then
		bodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + flat)
	end
end)

local function playFrames(frames)
	for _, frame in ipairs(frames) do
		override = frame.pose
		task.wait(frame.time)
	end
	override = nil
end

local function slash()
	sfx(SLASH_SOUND_IDS[math.random(#SLASH_SOUND_IDS)], PITCHES[math.random(#PITCHES)], 1)
	playFrames({{pose = SLASH_WIND, time = 0.35}, {pose = SLASH_STRIKE, time = 0.4}})
end

local function stab()
	sfx(STAB_SOUND_ID, 0.75, 0.65)
	playFrames({{pose = STAB_RAISE, time = 0.35}, {pose = STAB_THRUST, time = 0.35}})
end

local function spin()
	playFrames({{pose = SPIN_LUNGE, time = 0.4}})
	for i = 0, 1440, 48 do
		rootJoint.C1 = CFrame.new(0, -1, 0) * CFrame.Angles(0, math.rad(i), 0)
		task.wait(0.07)
	end
	rootJoint.C1 = CFrame.new()
end

local function runAction(fn)
	if attacking then
		return
	end
	attacking = true
	task.spawn(function()
		fn()
		override = nil
		attacking = false
	end)
end

local function setWeaponVisible(visible)
	for step = 1, 10 do
		local t = step / 10
		for _, part in ipairs(weaponParts) do
			part.Transparency = visible and (1 - t) or t
		end
		task.wait()
	end
end

local function toggleMelee()
	meleeStance = not meleeStance
	task.spawn(setWeaponVisible, not meleeStance)
end

local function joke()
	if not jokeReady then
		return
	end
	jokeReady = false
	local pitch = JOKE_PITCHES[math.random(#JOKE_PITCHES)]
	for _ = 1, 3 do
		sfx(JOKE_SOUND_ID, pitch, 1, char)
	end
	task.delay(1.5, function()
		jokeReady = true
	end)
end

local function groundWave()
	local wave = Instance.new("Part")
	wave.Shape = Enum.PartType.Ball
	wave.Anchored = true
	wave.CanCollide = false
	wave.Material = Enum.Material.Neon
	wave.Color = Color3.fromRGB(10, 10, 10)
	wave.Size = Vector3.new(1, 1, 1)
	wave.CFrame = CFrame.new(root.Position - Vector3.new(0, 3, 0))
	wave.Parent = workspace
	Debris:AddItem(wave, 1.5)
	task.spawn(function()
		for i = 1, 20 do
			local s = 2 + i * 2
			wave.Size = Vector3.new(s, s, s)
			wave.Transparency = 0.35 + (i / 20) * 0.65
			task.wait()
		end
	end)
end

local function jitter(o)
	return Vector3.new(math.random(-o, o), math.random(-o, o), math.random(-o, o))
end

local function bolt(a, b, segments, offset, thickness, transparency)
	local cur = a
	for i = 1, segments do
		local target = (i == segments) and b or (a:Lerp(b, i / segments) + jitter(offset))
		local seg = Instance.new("Part")
		seg.Anchored = true
		seg.CanCollide = false
		seg.Material = Enum.Material.Neon
		seg.Color = Color3.fromRGB(245, 221, 0)
		seg.Transparency = transparency
		seg.Size = Vector3.new(thickness, thickness, math.max((target - cur).Magnitude, 0.05))
		seg.CFrame = CFrame.lookAt((cur + target) / 2, target)
		seg.Parent = workspace
		Debris:AddItem(seg, 0.1)
		cur = target
	end
end

local function randomPointOn(part)
	local half = part.Size / 2
	local local_ = Vector3.new(
		(math.random() * 2 - 1) * half.X,
		(math.random() * 2 - 1) * half.Y,
		(math.random() * 2 - 1) * half.Z
	)
	return part.CFrame:PointToWorldSpace(local_)
end

local limbs = {torso, head, larm, rarm, lleg, rleg}

task.spawn(function()
	while char.Parent do
		groundWave()
		task.wait(5)
	end
end)

task.spawn(function()
	while char.Parent do
		local a = limbs[math.random(#limbs)]
		local b = limbs[math.random(#limbs)]
		bolt(randomPointOn(a), randomPointOn(b), 4, 3, 0.3, 0.56)
		task.wait(0.05)
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	local key = input.KeyCode
	if key == Enum.KeyCode.F then
		setFly(not flyToggled)
	elseif key == Enum.KeyCode.Q then
		runAction(slash)
	elseif key == Enum.KeyCode.R then
		runAction(stab)
	elseif key == Enum.KeyCode.G then
		runAction(spin)
	elseif key == Enum.KeyCode.H then
		joke()
	elseif key == Enum.KeyCode.M then
		toggleMelee()
	elseif key == Enum.KeyCode.Zero and not flyToggled then
		hum.WalkSpeed = 80
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Zero then
		hum.WalkSpeed = 16
	end
end)
