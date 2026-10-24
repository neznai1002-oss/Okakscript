repeat task.wait() until game:IsLoaded()

--// СЕРВИСЫ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local plr = Players.LocalPlayer
local Mouse = plr:GetMouse()
local Camera = workspace.CurrentCamera

-- Очистка предыдущего запуска FemboyHub v6
local GuiRootParent = (gethui and gethui()) or CoreGui
for _, name in ipairs({"FemboyHub_v6_Gui", "FemboyHub_v6_Intro"}) do
	if GuiRootParent:FindFirstChild(name) then
		GuiRootParent[name]:Destroy()
	end
end

--// НАСТРОЙКИ И СОСТОЯНИЯ FEMBOYHUB V6
local States = {
	-- Боевой модуль (Silent Aim / Aimbot / TriggerBot)
	SilentAim = false,
	SilentHitboxExpand = true, -- Гарантированный метод регистрации попаданий в радиусе FOV
	SilentHitboxSize = 9,
	SilentTargetPart = "Head", -- "Head", "HumanoidRootPart", "Random"
	SilentHitChance = 100,
	SilentPrediction = 0.125,
	ShowTargetLine = true,
	HighlightTarget = true,

	Aimbot = false,
	AimbotSmooth = 18, -- % плавности
	TriggerBot = false,
	TriggerDelay = 0.06,

	RapidFire = false,
	WallCheck = true,
	TeamCheck = true,
	ShowFOV = true,
	RainbowFOV = false,
	FOV_Radius = 135,

	-- Неоновый персонаж (Сохраняется после смерти)
	NeonChar = false,
	NeonMaterial = "Neon", -- "Neon" или "ForceField"
	RainbowNeon = false,
	NeonColor = Color3.fromRGB(255, 105, 180),
	ChinaHat = false,
	SpinningOrbs = false,
	CharTrail = false,
	CharSparkles = false,
	CharLightAura = false,

	-- Визуалы мира и ESP
	ESP_Enabled = false,
	ESP_Highlight = true,
	ESP_Names = true,
	ESP_Health = true,
	ESP_Distance = true,
	ESP_Tracers = false,
	CustomCrosshair = false,
	PinkWorld = false,
	Fullbright = false,
	CameraFOV = 70,

	-- Движение (Movement)
	Noclip = false,
	Fly = false,
	FlySpeed = 2,
	WalkSpeed = 16,
	JumpPower = 50,
	InfiniteJump = false,
	Spinbot = false,
	SpinSpeed = 25
}

-- Цветовая палитра FemboyHub v6
local Theme = {
	BgMain = Color3.fromRGB(18, 12, 26),
	BgSec = Color3.fromRGB(25, 16, 36),
	BgCard = Color3.fromRGB(33, 21, 48),
	BgHover = Color3.fromRGB(45, 28, 66),
	Pink = Color3.fromRGB(255, 105, 180),
	LightPink = Color3.fromRGB(255, 160, 220),
	Purple = Color3.fromRGB(190, 85, 255),
	Cyan = Color3.fromRGB(0, 230, 255),
	TextWhite = Color3.fromRGB(250, 240, 255),
	TextDim = Color3.fromRGB(185, 155, 205)
}

local SavedMaterials = {}
local SavedColors = {}
local OriginalHeadSizes = {}
local TracerPool = {}
local Connections = {}
local Unloaded = false
local CurrentTargetPlayer = nil

--// УТИЛИТЫ АНИМАЦИЙ И ЭФФЕКТОВ
local function Tween(obj, props, time, style, dir)
	if not obj then return end
	local tw = TweenService:Create(
		obj,
		TweenInfo.new(time or 0.28, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
		props
	)
	tw:Play()
	return tw
end

-- Эффект расходящейся неоновой волны при клике на любую кнопку (Ripple Effect)
local function SpawnRipple(btn, clickPos)
	task.spawn(function()
		local ripple = Instance.new("Frame", btn)
		ripple.Name = "RippleWave"
		ripple.AnchorPoint = Vector2.new(0.5, 0.5)
		local relX = clickPos.X - btn.AbsolutePosition.X
		local relY = clickPos.Y - btn.AbsolutePosition.Y
		ripple.Position = UDim2.fromOffset(relX, relY)
		ripple.Size = UDim2.fromOffset(0, 0)
		ripple.BackgroundColor3 = Theme.LightPink
		ripple.BackgroundTransparency = 0.45
		ripple.BorderSizePixel = 0
		ripple.ZIndex = btn.ZIndex + 2
		Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)

		local maxRadius = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.2
		Tween(ripple, {
			Size = UDim2.fromOffset(maxRadius, maxRadius),
			BackgroundTransparency = 1
		}, 0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		task.wait(0.56)
		if ripple then ripple:Destroy() end
	end)
end

-- Привязка анимаций наведения, свечения и волн к интерактивным элементам
local function AttachAnimatedInteractions(frameBtn, textLabel, strokeObj, baseColor, hoverColor)
	frameBtn.ClipsDescendants = true

	frameBtn.MouseEnter:Connect(function()
		Tween(frameBtn, {BackgroundColor3 = hoverColor or Theme.BgHover}, 0.22)
		if textLabel then
			Tween(textLabel, {Position = UDim2.fromOffset(18, 0), TextColor3 = Theme.LightPink}, 0.22)
		end
		if strokeObj then
			Tween(strokeObj, {Thickness = 1.6, Transparency = 0.1}, 0.22)
		end
	end)

	frameBtn.MouseLeave:Connect(function()
		Tween(frameBtn, {BackgroundColor3 = baseColor or Theme.BgCard}, 0.25)
		if textLabel then
			Tween(textLabel, {Position = UDim2.fromOffset(12, 0), TextColor3 = Theme.TextWhite}, 0.25)
		end
		if strokeObj then
			Tween(strokeObj, {Thickness = 1, Transparency = 0.45}, 0.25)
		end
	end)

	frameBtn.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			SpawnRipple(frameBtn, inp.Position)
		end
	end)
end

--// 1. ПОЛНОЭКРАННОЕ АНИМИРОВАННОЕ ИНТРО FEMBOYHUB V6
local function PlayFemboyHubV6Intro()
	local IntroGui = Instance.new("ScreenGui")
	IntroGui.Name = "FemboyHub_v6_Intro"
	IntroGui.IgnoreGuiInset = true -- Гарантирует 100% заполнение экрана без полосы сверху
	IntroGui.ResetOnSpawn = false
	IntroGui.DisplayOrder = 999999
	IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	IntroGui.Parent = GuiRootParent

	local Blur = Instance.new("BlurEffect", Lighting)
	Blur.Size = 0
	Tween(Blur, {Size = 26}, 0.65)

	local Bg = Instance.new("Frame", IntroGui)
	Bg.Size = UDim2.fromScale(1, 1)
	Bg.Position = UDim2.fromScale(0, 0)
	Bg.BackgroundColor3 = Color3.fromRGB(14, 8, 20)
	Bg.BorderSizePixel = 0

	local BgGrad = Instance.new("UIGradient", Bg)
	BgGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 8, 26)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(42, 16, 56)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 6, 18))
	})
	BgGrad.Rotation = 45

	-- Летающие неоновые частицы на фоне интро
	for i = 1, 16 do
		local dot = Instance.new("Frame", Bg)
		local sz = math.random(25, 110)
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.Position = UDim2.fromScale(math.random(5, 95) / 100, math.random(10, 90) / 100)
		dot.Size = UDim2.fromOffset(sz, sz)
		dot.BackgroundColor3 = (i % 2 == 0) and Theme.Pink or Theme.Purple
		dot.BackgroundTransparency = 0.86
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

		task.spawn(function()
			while dot and dot.Parent do
				Tween(dot, {
					Position = dot.Position + UDim2.fromScale(math.random(-10, 10) / 100, math.random(-10, 10) / 100),
					BackgroundTransparency = math.random(75, 92) / 100
				}, 1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
				task.wait(1.3)
			end
		end)
	end

	local Card = Instance.new("Frame", Bg)
	Card.AnchorPoint = Vector2.new(0.5, 0.5)
	Card.Position = UDim2.fromScale(0.5, 0.55)
	Card.Size = UDim2.fromOffset(420, 210)
	Card.BackgroundColor3 = Theme.BgSec
	Card.BackgroundTransparency = 1
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 16)

	local CardStroke = Instance.new("UIStroke", Card)
	CardStroke.Color = Theme.Pink
	CardStroke.Thickness = 2.2
	CardStroke.Transparency = 1

	Tween(Card, {Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 0.08}, 0.65, Enum.EasingStyle.Back)
	Tween(CardStroke, {Transparency = 0}, 0.65)

	local Title = Instance.new("TextLabel", Card)
	Title.Position = UDim2.new(0, 0, 0.14, 0)
	Title.Size = UDim2.new(1, 0, 0, 44)
	Title.BackgroundTransparency = 1
	Title.Font = Enum.Font.GothamBlack
	Title.Text = "🌸 FEMBOY HUB v6 🌸"
	Title.TextColor3 = Theme.LightPink
	Title.TextSize = 29

	local Sub = Instance.new("TextLabel", Card)
	Sub.Position = UDim2.new(0, 0, 0.42, 0)
	Sub.Size = UDim2.new(1, 0, 0, 24)
	Sub.BackgroundTransparency = 1
	Sub.Font = Enum.Font.GothamMedium
	Sub.Text = "Загрузка розовых визуалов и анимаций..."
	Sub.TextColor3 = Theme.TextDim
	Sub.TextSize = 14

	local BarBack = Instance.new("Frame", Card)
	BarBack.AnchorPoint = Vector2.new(0.5, 0.5)
	BarBack.Position = UDim2.new(0.5, 0, 0.75, 0)
	BarBack.Size = UDim2.new(0.82, 0, 0, 9)
	BarBack.BackgroundColor3 = Color3.fromRGB(45, 25, 62)
	Instance.new("UICorner", BarBack).CornerRadius = UDim.new(1, 0)

	local BarFill = Instance.new("Frame", BarBack)
	BarFill.Size = UDim2.new(0, 0, 1, 0)
	BarFill.BackgroundColor3 = Theme.Pink
	Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

	local BarGrad = Instance.new("UIGradient", BarFill)
	BarGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.Pink),
		ColorSequenceKeypoint.new(1, Theme.Purple)
	})

	task.spawn(function()
		Tween(BarFill, {Size = UDim2.new(0.36, 0, 1, 0)}, 0.4)
		task.wait(0.45)
		Sub.Text = "Активация Silent Aim, TriggerBot & Noclip..."
		Tween(BarFill, {Size = UDim2.new(0.75, 0, 1, 0)}, 0.45)
		task.wait(0.5)
		Sub.Text = "Добро пожаловать в FemboyHub v6!"
		Tween(BarFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.35)
		task.wait(0.45)

		Tween(Card, {Position = UDim2.fromScale(0.5, 0.44), BackgroundTransparency = 1}, 0.45, Enum.EasingStyle.Back)
		Tween(Title, {TextTransparency = 1}, 0.35)
		Tween(Sub, {TextTransparency = 1}, 0.35)
		Tween(BarBack, {BackgroundTransparency = 1}, 0.35)
		Tween(BarFill, {BackgroundTransparency = 1}, 0.35)
		Tween(CardStroke, {Transparency = 1}, 0.35)
		Tween(Bg, {BackgroundTransparency = 1}, 0.5)
		Tween(Blur, {Size = 0}, 0.5)
		task.wait(0.55)
		Blur:Destroy()
		IntroGui:Destroy()
	end)
end

PlayFemboyHubV6Intro()

--// 2. КОРНЕВОЙ GUI И АНИМИРОВАННЫЕ УВЕДОМЛЕНИЯ
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "FemboyHub_v6_Gui"
MainGui.IgnoreGuiInset = true
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.Parent = GuiRootParent

local NotifContainer = Instance.new("Frame", MainGui)
NotifContainer.AnchorPoint = Vector2.new(1, 1)
NotifContainer.Position = UDim2.new(0.985, 0, 0.965, 0)
NotifContainer.Size = UDim2.new(0, 280, 0, 360)
NotifContainer.BackgroundTransparency = 1

local NotifList = Instance.new("UIListLayout", NotifContainer)
NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifList.SortOrder = Enum.SortOrder.LayoutOrder
NotifList.Padding = UDim.new(0, 7)

local function Notify(title, text, duration)
	duration = duration or 2.8
	task.spawn(function()
		local Box = Instance.new("Frame", NotifContainer)
		Box.Size = UDim2.new(1, 0, 0, 0)
		Box.BackgroundColor3 = Theme.BgSec
		Box.BackgroundTransparency = 0.06
		Box.ClipsDescendants = true
		Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)

		local Stroke = Instance.new("UIStroke", Box)
		Stroke.Color = Theme.Pink
		Stroke.Thickness = 1.4

		local SideBar = Instance.new("Frame", Box)
		SideBar.Size = UDim2.new(0, 4, 1, 0)
		SideBar.BackgroundColor3 = Theme.Pink
		SideBar.BorderSizePixel = 0

		local T1 = Instance.new("TextLabel", Box)
		T1.Position = UDim2.fromOffset(14, 6)
		T1.Size = UDim2.new(1, -22, 0, 18)
		T1.BackgroundTransparency = 1
		T1.Font = Enum.Font.GothamBold
		T1.Text = "🌸 " .. title
		T1.TextColor3 = Theme.LightPink
		T1.TextSize = 13
		T1.TextXAlignment = Enum.TextXAlignment.Left

		local T2 = Instance.new("TextLabel", Box)
		T2.Position = UDim2.fromOffset(14, 24)
		T2.Size = UDim2.new(1, -22, 0, 28)
		T2.BackgroundTransparency = 1
		T2.Font = Enum.Font.Gotham
		T2.Text = text
		T2.TextColor3 = Theme.TextWhite
		T2.TextSize = 12
		T2.TextWrapped = true
		T2.TextXAlignment = Enum.TextXAlignment.Left

		-- Анимация раскрытия уведомления
		Tween(Box, {Size = UDim2.new(1, 0, 0, 58)}, 0.32, Enum.EasingStyle.Back)
		task.wait(duration)
		Tween(Box, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.26, Enum.EasingStyle.Quart)
		Tween(Stroke, {Transparency = 1}, 0.22)
		task.wait(0.28)
		Box:Destroy()
	end)
end

--// 3. НЕОНОВЫЙ ПЕРСОНАЖ И АКСЕССУАРЫ (СОХРАНЯЮТСЯ ПОСЛЕ СМЕРТИ)
local ChinaHatPart = nil
local TrailEffect = nil
local SparkleEffect = nil
local LightAura = nil
local OrbitFolder = nil

local function ApplyNeonCharacter(char)
	if not char then return end
	local mat = (States.NeonMaterial == "ForceField") and Enum.Material.ForceField or Enum.Material.Neon
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "FemboyHat" and part.Name ~= "FemboyOrb" then
			if States.NeonChar then
				if not SavedMaterials[part] then
					SavedMaterials[part] = part.Material
					SavedColors[part] = part.Color
				end
				part.Material = mat
				part.Color = States.NeonColor
			else
				if SavedMaterials[part] then
					part.Material = SavedMaterials[part]
					part.Color = SavedColors[part]
				end
			end
		elseif (part:IsA("Shirt") or part:IsA("Pants") or part:IsA("ShirtGraphic")) and States.NeonChar then
			part.Parent = nil
		end
	end
end

local function RebuildCharacterAddons(char)
	if not char then return end
	local head = char:FindFirstChild("Head")
	local hrp = char:FindFirstChild("HumanoidRootPart")

	-- 1. Коническая неоновая шляпа (ChinaHat)
	if ChinaHatPart then ChinaHatPart:Destroy() ChinaHatPart = nil end
	if States.ChinaHat and head then
		local hat = Instance.new("Part")
		hat.Name = "FemboyHat"
		hat.Size = Vector3.new(1, 1, 1)
		hat.CanCollide = false
		hat.Massless = true
		hat.Material = Enum.Material.Neon
		hat.Color = States.NeonColor
		hat.Transparency = 0.22

		local mesh = Instance.new("SpecialMesh", hat)
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://1033714"
		mesh.Scale = Vector3.new(2.25, 0.65, 2.25)

		local weld = Instance.new("Weld", hat)
		weld.Part0 = head
		weld.Part1 = hat
		weld.C0 = CFrame.new(0, 1.15, 0)

		hat.Parent = char
		ChinaHatPart = hat
	end

	-- 2. Неоновый шлейф (Trail)
	if TrailEffect then TrailEffect:Destroy() TrailEffect = nil end
	if States.CharTrail and hrp then
		local a0 = hrp:FindFirstChild("FH_Att0") or Instance.new("Attachment", hrp)
		a0.Name = "FH_Att0"
		a0.Position = Vector3.new(0, 1.45, 0)

		local a1 = hrp:FindFirstChild("FH_Att1") or Instance.new("Attachment", hrp)
		a1.Name = "FH_Att1"
		a1.Position = Vector3.new(0, -1.45, 0)

		local tr = Instance.new("Trail", hrp)
		tr.Attachment0 = a0
		tr.Attachment1 = a1
		tr.Lifetime = 0.7
		tr.LightEmission = 1
		tr.Color = ColorSequence.new(States.NeonColor, Theme.LightPink)
		tr.Transparency = NumberSequence.new(0.08, 1)
		TrailEffect = tr
	end

	-- 3. Неоновые искры (Sparkles)
	if SparkleEffect then SparkleEffect:Destroy() SparkleEffect = nil end
	if States.CharSparkles and hrp then
		local sp = Instance.new("Sparkles", hrp)
		sp.SparkleColor = States.NeonColor
		SparkleEffect = sp
	end

	-- 4. Свечение вокруг тела (PointLight)
	if LightAura then LightAura:Destroy() LightAura = nil end
	if States.CharLightAura and hrp then
		local pl = Instance.new("PointLight", hrp)
		pl.Color = States.NeonColor
		pl.Range = 20
		pl.Brightness = 3
		LightAura = pl
	end

	-- 5. Вращающиеся неоновые сферы вокруг персонажа (Spinning Orbs)
	if OrbitFolder then OrbitFolder:Destroy() OrbitFolder = nil end
	if States.SpinningOrbs and hrp then
		OrbitFolder = Instance.new("Folder", char)
		OrbitFolder.Name = "FemboyOrbs"
		for i = 1, 3 do
			local orb = Instance.new("Part", OrbitFolder)
			orb.Name = "FemboyOrb"
			orb.Shape = Enum.PartType.Ball
			orb.Size = Vector3.new(0.75, 0.75, 0.75)
			orb.Material = Enum.Material.Neon
			orb.Color = States.NeonColor
			orb.Anchored = true
			orb.CanCollide = false
			orb.CanTouch = false
			orb.CanQuery = false

			local a0 = Instance.new("Attachment", orb)
			a0.Position = Vector3.new(0, 0.25, 0)
			local a1 = Instance.new("Attachment", orb)
			a1.Position = Vector3.new(0, -0.25, 0)
			local tr = Instance.new("Trail", orb)
			tr.Attachment0 = a0
			tr.Attachment1 = a1
			tr.Lifetime = 0.35
			tr.LightEmission = 1
			tr.Color = ColorSequence.new(States.NeonColor, Color3.fromRGB(255, 255, 255))
			tr.Transparency = NumberSequence.new(0.2, 1)
		end
	end
end

-- Модификация скорострельности оружия (Rapid Fire)
local function ApplyRapidFireToTool(tool)
	if not States.RapidFire or not tool or not tool:IsA("Tool") then return end
	pcall(function()
		if tool:FindFirstChild("GunStates") then
			local gs = require(tool.GunStates)
			if type(gs) == "table" then
				gs["FireRate"] = 0.02
				gs["AutoFire"] = true
				gs["MaxAmmo"] = math.huge
				gs["StoredAmmo"] = math.huge
				gs["AmmoPerClip"] = math.huge
				gs["CurrentAmmo"] = math.huge
				gs["Spread"] = 0
			end
		end
	end)
end

-- Авто-восстановление всех эффектов после смерти (CharacterAdded)
local function OnCharacterSpawn(newChar)
	if Unloaded then return end
	local hrp = newChar:WaitForChild("HumanoidRootPart", 10)
	local hum = newChar:WaitForChild("Humanoid", 10)
	if not hrp or not hum then return end

	task.wait(0.2)
	if States.NeonChar then
		ApplyNeonCharacter(newChar)
	end
	RebuildCharacterAddons(newChar)

	if States.WalkSpeed ~= 16 then hum.WalkSpeed = States.WalkSpeed end
	if States.JumpPower ~= 50 then
		hum.UseJumpPower = true
		hum.JumpPower = States.JumpPower
	end

	newChar.DescendantAdded:Connect(function(desc)
		if States.NeonChar and desc:IsA("BasePart") and desc.Name ~= "HumanoidRootPart" and desc.Name ~= "FemboyHat" and desc.Name ~= "FemboyOrb" then
			task.wait()
			desc.Material = (States.NeonMaterial == "ForceField") and Enum.Material.ForceField or Enum.Material.Neon
			desc.Color = States.NeonColor
		end
	end)

	newChar.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			task.wait(0.05)
			ApplyRapidFireToTool(child)
		end
	end)
end

if plr.Character then
	task.spawn(OnCharacterSpawn, plr.Character)
end
Connections.CharAdded = plr.CharacterAdded:Connect(OnCharacterSpawn)

--// 4. ИСПРАВЛЕННЫЙ NOCLIP, SPINBOT И ТВОЙ ОРИГИНАЛЬНЫЙ FLY
local function SetCharacterCollision(state)
	if not plr.Character then return end
	for _, part in ipairs(plr.Character:GetDescendants()) do
		if part:IsA("BasePart") then
			if not state then
				part.CanCollide = false
			elseif part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "LowerTorso" or part.Name == "HumanoidRootPart" then
				part.CanCollide = true
			end
		end
	end
end

Connections.SteppedLoop = RunService.Stepped:Connect(function()
	if Unloaded then return end
	if States.Noclip and plr.Character then
		for _, part in ipairs(plr.Character:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end
end)

UserInputService.JumpRequest:Connect(function()
	if States.InfiniteJump and plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
		plr.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Оригинальный Fly (сохранен один-в-один по твоей просьбе)
local FlyConn = nil
local function ToggleFly(enable)
	if enable then
		if FlyConn then return end
		local Y = 1
		local Keys = {w = false, a = false, s = false, d = false}

		FlyConn = RunService.Heartbeat:Connect(function()
			if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = plr.Character.HumanoidRootPart
				hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(Mouse.Hit.LookVector.X, Mouse.Hit.LookVector.Y, Mouse.Hit.LookVector.Z))
			end
		end)

		local function MoveBy(cf)
			if not FlyConn or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
			plr.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * cf
		end

		Mouse.KeyDown:Connect(function(k)
			if k and Keys[k:lower()] ~= nil and FlyConn then Keys[k:lower()] = true end
		end)
		Mouse.KeyUp:Connect(function(k)
			if k and Keys[k:lower()] ~= nil and FlyConn then Keys[k:lower()] = false end
		end)

		UserInputService.InputBegan:Connect(function(inp, gp)
			if gp or not FlyConn then return end
			if inp.KeyCode == Enum.KeyCode.Space then Y = 20 end
			if inp.KeyCode == Enum.KeyCode.LeftShift then Y = -20 end
		end)
		UserInputService.InputEnded:Connect(function(inp)
			if inp.KeyCode == Enum.KeyCode.Space or inp.KeyCode == Enum.KeyCode.LeftShift then Y = 1 end
		end)

		RunService.RenderStepped:Connect(function()
			if FlyConn and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local spd = (tonumber(States.FlySpeed) or 2) / 2
				plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, Y, 0)
				if Keys.w then MoveBy(CFrame.new(0, 0, -spd)) end
				if Keys.a then MoveBy(CFrame.new(-spd, 0, 0)) end
				if Keys.s then MoveBy(CFrame.new(0, 0, spd)) end
				if Keys.d then MoveBy(CFrame.new(spd, 0, 0)) end
			end
		end)
	else
		if FlyConn then
			FlyConn:Disconnect()
			FlyConn = nil
		end
	end
end

--// 5. ДВОЙНОЙ SILENT AIM + TRIGGERBOT + AIMBOT + ВИЗУАЛИЗАЦИЯ ЦЕЛИ
local FOVCircle = Instance.new("Frame", MainGui)
FOVCircle.Name = "FemboyFOV"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Size = UDim2.fromOffset(States.FOV_Radius * 2, States.FOV_Radius * 2)
FOVCircle.Visible = false
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)

local FOVStroke = Instance.new("UIStroke", FOVCircle)
FOVStroke.Color = Theme.Pink
FOVStroke.Thickness = 1.8
FOVStroke.Transparency = 0.15

-- Линия захвата цели (Target Line)
local TargetLine = Instance.new("Frame", MainGui)
TargetLine.Name = "TargetTracerLine"
TargetLine.AnchorPoint = Vector2.new(0.5, 0.5)
TargetLine.BackgroundColor3 = Theme.LightPink
TargetLine.BorderSizePixel = 0
TargetLine.Visible = false

-- Подсветка текущей цели (Target Highlight)
local TargetHL = Instance.new("Highlight", MainGui)
TargetHL.Name = "TargetLockHighlight"
TargetHL.FillColor = Theme.Pink
TargetHL.OutlineColor = Color3.fromRGB(255, 255, 255)
TargetHL.FillTransparency = 0.45
TargetHL.OutlineTransparency = 0
TargetHL.Enabled = false

-- Индикатор захваченной цели на экране
local TargetBanner = Instance.new("TextLabel", MainGui)
TargetBanner.AnchorPoint = Vector2.new(0.5, 0)
TargetBanner.Position = UDim2.new(0.5, 0, 0.58, 0)
TargetBanner.Size = UDim2.fromOffset(240, 22)
TargetBanner.BackgroundTransparency = 1
TargetBanner.Font = Enum.Font.GothamBold
TargetBanner.Text = ""
TargetBanner.TextColor3 = Theme.LightPink
TargetBanner.TextStrokeTransparency = 0.2
TargetBanner.TextSize = 13
TargetBanner.Visible = false

-- Неоновый вращающийся прицел (Crosshair)
local Crosshair = Instance.new("Frame", MainGui)
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.fromScale(0.5, 0.5)
Crosshair.Size = UDim2.fromOffset(22, 22)
Crosshair.BackgroundTransparency = 1
Crosshair.Visible = false

local CH1 = Instance.new("Frame", Crosshair)
CH1.AnchorPoint = Vector2.new(0.5, 0.5)
CH1.Position = UDim2.fromScale(0.5, 0.5)
CH1.Size = UDim2.new(1, 0, 0, 2)
CH1.BackgroundColor3 = Theme.Pink
CH1.BorderSizePixel = 0

local CH2 = Instance.new("Frame", Crosshair)
CH2.AnchorPoint = Vector2.new(0.5, 0.5)
CH2.Position = UDim2.fromScale(0.5, 0.5)
CH2.Size = UDim2.new(0, 2, 1, 0)
CH2.BackgroundColor3 = Theme.Pink
CH2.BorderSizePixel = 0

-- Проверка видимости без стен (Raycast)
local function IsTargetVisible(part, charModel)
	if not States.WallCheck then return true end
	local params = RaycastParams.new()
	params.IgnoreWater = true
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {plr.Character, Camera}

	local origin = Camera.CFrame.Position
	local res = workspace:Raycast(origin, part.Position - origin, params)
	if not res then return true end
	return res.Instance and (res.Instance:IsDescendantOf(charModel) or res.Instance.Transparency >= 0.85)
end

local function GetAimPart(char)
	if not char then return nil end
	if States.SilentTargetPart == "Random" then
		local list = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"}
		return char:FindFirstChild(list[math.random(1, #list)]) or char:FindFirstChild("Head")
	end
	return char:FindFirstChild(States.SilentTargetPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

-- Поиск ближайшей цели внутри FOV круга
local function FindBestTargetInFOV()
	local bestPlr, bestPart, bestScreen = nil, nil, nil
	local shortest = States.FOV_Radius
	local refPos = UserInputService:GetMouseLocation()
	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		refPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= plr and p.Character then
			if States.TeamCheck and p.Team == plr.Team and p.Team ~= nil then
				continue
			end
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			local part = GetAimPart(p.Character)
			if hum and hum.Health > 0 and part and not p.Character:FindFirstChildOfClass("ForceField") then
				local vp, onScreen = Camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local pt2D = Vector2.new(vp.X, vp.Y)
					local dist = (pt2D - refPos).Magnitude
					if dist <= shortest and IsTargetVisible(part, p.Character) then
						shortest = dist
						bestPlr = p
						bestPart = part
						bestScreen = pt2D
					end
				end
			end
		end
	end
	return bestPlr, bestPart, bestScreen, refPos
end

-- Управление локальным хитбоксом для 100% работы Silent Aim на любых пушках
local function UpdateSilentHitboxes(lockedPlayer)
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= plr and p.Character then
			local head = p.Character:FindFirstChild("Head")
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if head and not OriginalHeadSizes[head] then
				OriginalHeadSizes[head] = head.Size
			end
			if States.SilentAim and States.SilentHitboxExpand and p == lockedPlayer then
				local targetPart = (States.SilentTargetPart == "HumanoidRootPart" and hrp) or head
				if targetPart then
					targetPart.Size = Vector3.new(States.SilentHitboxSize, States.SilentHitboxSize, States.SilentHitboxSize)
					targetPart.Transparency = 0.65
					targetPart.CanCollide = false
					targetPart.Massless = true
				end
			else
				if head and OriginalHeadSizes[head] then
					head.Size = OriginalHeadSizes[head]
					head.Transparency = 0
				end
				if hrp then
					hrp.Size = Vector3.new(2, 2, 1)
					hrp.Transparency = 1
				end
			end
		end
	end
end

-- Дополнительно: перехват Mouse.Hit / Target (если поддерживается экзекутором)
pcall(function()
	if getrawmetatable and newcclosure and setreadonly then
		local mt = getrawmetatable(game)
		local oldIndex = mt.__index
		setreadonly(mt, false)

		mt.__index = newcclosure(function(self, key)
			if States.SilentAim and not checkcaller() and self == Mouse then
				if key == "Hit" or key == "Target" or key == "UnitRay" then
					if math.random(1, 100) <= States.SilentHitChance then
						local _, part = FindBestTargetInFOV()
						if part then
							local vel = part.AssemblyLinearVelocity or Vector3.zero
							local pred = part.Position + (vel * States.SilentPrediction)
							if key == "Hit" then
								return CFrame.new(pred)
							elseif key == "Target" then
								return part
							elseif key == "UnitRay" then
								local orig = Camera.CFrame.Position
								return Ray.new(orig, (pred - orig).Unit)
							end
						end
					end
				end
			end
			return oldIndex(self, key)
		end)
		setreadonly(mt, true)
	end
end)

-- Основной цикл RenderStepped (Aimbot, Silent Aim, TriggerBot, Орбы, Радуга)
local LastTriggerFire = 0
Connections.RenderStepped = RunService.RenderStepped:Connect(function(dt)
	if Unloaded then return end

	local targetPlr, targetPart, screenPt, refPos = FindBestTargetInFOV()
	CurrentTargetPlayer = targetPlr

	-- Обновление круга FOV
	FOVCircle.Position = UDim2.fromOffset(refPos.X, refPos.Y)
	FOVCircle.Size = UDim2.fromOffset(States.FOV_Radius * 2, States.FOV_Radius * 2)
	FOVCircle.Visible = States.ShowFOV

	Crosshair.Visible = States.CustomCrosshair
	if States.CustomCrosshair then
		Crosshair.Rotation = (Crosshair.Rotation + 110 * dt) % 360
	end

	-- Радужная анимация цветов
	if States.RainbowNeon or States.RainbowFOV then
		local col = Color3.fromHSV((tick() * 0.24) % 1, 0.75, 1)
		if States.RainbowFOV then FOVStroke.Color = col end
		if States.RainbowNeon then
			States.NeonColor = col
			if States.NeonChar and plr.Character then ApplyNeonCharacter(plr.Character) end
			if ChinaHatPart then ChinaHatPart.Color = col end
			if LightAura then LightAura.Color = col end
		end
	end

	-- Вращение орбов вокруг персонажа
	if States.SpinningOrbs and OrbitFolder and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
		local hrpPos = plr.Character.HumanoidRootPart.Position
		local orbs = OrbitFolder:GetChildren()
		for i, orb in ipairs(orbs) do
			local angle = (tick() * 3.2) + (i * (math.pi * 2 / #orbs))
			local offset = Vector3.new(math.cos(angle) * 4, math.sin(tick() * 2 + i) * 1.5, math.sin(angle) * 4)
			orb.CFrame = CFrame.new(hrpPos + offset)
			orb.Color = States.NeonColor
		end
	end

	-- Spinbot
	if States.Spinbot and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
		plr.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(States.SpinSpeed), 0)
	end

	-- Обновление хитбоксов Silent Aim и визуальной линии захвата
	UpdateSilentHitboxes(targetPlr)

	if (States.SilentAim or States.Aimbot) and targetPlr and targetPart and screenPt then
		if States.ShowTargetLine then
			local delta = screenPt - refPos
			local mid = (refPos + screenPt) / 2
			TargetLine.Position = UDim2.fromOffset(mid.X, mid.Y)
			TargetLine.Size = UDim2.fromOffset(delta.Magnitude, 1.8)
			TargetLine.Rotation = math.deg(math.atan2(delta.Y, delta.X))
			TargetLine.Visible = true
		else
			TargetLine.Visible = false
		end

		if States.HighlightTarget and targetPlr.Character then
			TargetHL.Adornee = targetPlr.Character
			TargetHL.Enabled = true
		else
			TargetHL.Enabled = false
		end

		TargetBanner.Text = "🎯 Цель: " .. targetPlr.DisplayName
		TargetBanner.Visible = true
	else
		TargetLine.Visible = false
		TargetHL.Enabled = false
		TargetBanner.Visible = false
	end

	-- Плавный Aimbot
	if States.Aimbot and targetPart then
		local vel = targetPart.AssemblyLinearVelocity or Vector3.zero
		local predicted = targetPart.Position + (vel * States.SilentPrediction)
		local smooth = math.clamp(States.AimbotSmooth / 100, 0.03, 1)
		Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, predicted), smooth)
	end

	-- TriggerBot (срабатывает при наведении прицела на противника или при захвате в Silent Aim)
	if States.TriggerBot and (tick() - LastTriggerFire) >= States.TriggerDelay then
		local enemyToShoot = nil
		local mTarget = Mouse.Target
		if mTarget then
			local model = mTarget:FindFirstAncestorOfClass("Model")
			if model then enemyToShoot = Players:GetPlayerFromCharacter(model) end
		end
		if not enemyToShoot and States.SilentAim and targetPlr then
			-- Если враг в перекрестии с учетом расширенного хитбокса
			if screenPt and (screenPt - refPos).Magnitude <= 35 then
				enemyToShoot = targetPlr
			end
		end

		if enemyToShoot and enemyToShoot ~= plr and enemyToShoot.Character then
			if not (States.TeamCheck and enemyToShoot.Team == plr.Team and enemyToShoot.Team ~= nil) then
				local hum = enemyToShoot.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					LastTriggerFire = tick()
					local tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
					if tool then
						tool:Activate()
					end
				end
			end
		end
	end
end)

--// 6. ESP МОДУЛЬ (HIGHLIGHT + HP + ДИСТАНЦИЯ + 2D TRACERS)
local function UpdateESP()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= plr and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("HumanoidRootPart") then
			local char = p.Character
			local hum = char:FindFirstChildOfClass("Humanoid")

			local hl = char:FindFirstChild("FemboyV6_HL")
			if States.ESP_Enabled and States.ESP_Highlight then
				if not hl then
					hl = Instance.new("Highlight", char)
					hl.Name = "FemboyV6_HL"
				end
				hl.FillColor = States.NeonColor
				hl.OutlineColor = Color3.fromRGB(255, 255, 255)
				hl.FillTransparency = 0.55
				hl.OutlineTransparency = 0.08
			elseif hl then
				hl:Destroy()
			end

			local bb = char.Head:FindFirstChild("FemboyV6_BB")
			if States.ESP_Enabled and (States.ESP_Names or States.ESP_Health or States.ESP_Distance) and hum then
				if not bb then
					bb = Instance.new("BillboardGui", char.Head)
					bb.Name = "FemboyV6_BB"
					bb.AlwaysOnTop = true
					bb.Size = UDim2.fromOffset(175, 46)
					bb.StudsOffset = Vector3.new(0, 2.8, 0)

					local lbl = Instance.new("TextLabel", bb)
					lbl.Name = "Tag"
					lbl.Size = UDim2.fromScale(1, 1)
					lbl.BackgroundTransparency = 1
					lbl.Font = Enum.Font.GothamBold
					lbl.TextStrokeTransparency = 0.15
					lbl.TextSize = 12
				end
				local dist = math.floor((Camera.CFrame.Position - char.HumanoidRootPart.Position).Magnitude)
				local hp = math.floor(hum.Health)
				bb.Tag.TextColor3 = Theme.LightPink
				bb.Tag.Text = string.format("🌸 %s\n[HP: %d%% | %d м]", p.DisplayName, hp, dist)
			elseif bb then
				bb:Destroy()
			end
		end
	end
end

task.spawn(function()
	while not Unloaded do
		task.wait(0.25)
		pcall(UpdateESP)
	end
end)

--// 7. ГЛАВНОЕ ОКНО МЕНЮ FEMBOYHUB V6 (С АНИМАЦИЯМИ И ЧЕТКОЙ ВЕРСТКОЙ)
local Window = Instance.new("Frame", MainGui)
Window.Name = "FemboyHubV6_Window"
Window.AnchorPoint = Vector2.new(0.5, 0.5)
Window.Position = UDim2.fromScale(0.5, 0.5)
Window.Size = UDim2.fromOffset(530, 345)
Window.BackgroundColor3 = Theme.BgMain
Window.BorderSizePixel = 0
Window.ClipsDescendants = true
Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 14)

local WinStroke = Instance.new("UIStroke", Window)
WinStroke.Thickness = 2
WinStroke.Color = Color3.fromRGB(255, 255, 255)

local WinGrad = Instance.new("UIGradient", WinStroke)
WinGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Theme.Pink),
	ColorSequenceKeypoint.new(0.5, Theme.Purple),
	ColorSequenceKeypoint.new(1, Theme.Cyan)
})

task.spawn(function()
	while not Unloaded do
		task.wait(0.025)
		WinGrad.Rotation = (WinGrad.Rotation + 2) % 360
	end
end)

-- Верхняя шапка окна
local TopBar = Instance.new("Frame", Window)
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Theme.BgSec
TopBar.BorderSizePixel = 0

local TopDivider = Instance.new("Frame", TopBar)
TopDivider.Position = UDim2.new(0, 0, 1, -1)
TopDivider.Size = UDim2.new(1, 0, 0, 1)
TopDivider.BackgroundColor3 = Color3.fromRGB(65, 38, 90)
TopDivider.BorderSizePixel = 0

local HeaderTitle = Instance.new("TextLabel", TopBar)
HeaderTitle.Position = UDim2.fromOffset(16, 0)
HeaderTitle.Size = UDim2.new(0, 260, 1, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Font = Enum.Font.GothamBlack
HeaderTitle.Text = "🌸 FEMBOY HUB v6"
HeaderTitle.TextColor3 = Theme.LightPink
HeaderTitle.TextSize = 16
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

local SubBadge = Instance.new("TextLabel", TopBar)
SubBadge.Position = UDim2.fromOffset(178, 1)
SubBadge.Size = UDim2.new(0, 140, 1, 0)
SubBadge.BackgroundTransparency = 1
SubBadge.Font = Enum.Font.GothamBold
SubBadge.Text = "PINK & NEON EDITION"
SubBadge.TextColor3 = Theme.Purple
SubBadge.TextSize = 11
SubBadge.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.AnchorPoint = Vector2.new(1, 0.5)
MinBtn.Position = UDim2.new(1, -10, 0.5, 0)
MinBtn.Size = UDim2.fromOffset(30, 26)
MinBtn.BackgroundColor3 = Theme.BgCard
MinBtn.AutoButtonColor = false
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.LightPink
MinBtn.TextSize = 14
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 7)
AttachAnimatedInteractions(MinBtn, nil, nil, Theme.BgCard, Theme.Pink)

-- Круглая плавающая кнопка для быстрого открытия/закрытия меню
local FloatBtn = Instance.new("TextButton", MainGui)
FloatBtn.AnchorPoint = Vector2.new(0, 0.5)
FloatBtn.Position = UDim2.new(0.015, 0, 0.45, 0)
FloatBtn.Size = UDim2.fromOffset(48, 48)
FloatBtn.BackgroundColor3 = Theme.BgSec
FloatBtn.AutoButtonColor = false
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.Text = "🌸v6"
FloatBtn.TextColor3 = Theme.LightPink
FloatBtn.TextSize = 13
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Color = Theme.Pink
FloatStroke.Thickness = 2

-- Плавное инерционное перетаскивание окна и кнопки
local function EnableSmoothDrag(handle, targetFrame)
	local dragging, dragInput, dragStart, startPos
	handle.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = inp.Position
			startPos = targetFrame.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	handle.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
			dragInput = inp
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if inp == dragInput and dragging then
			local delta = inp.Position - dragStart
			Tween(targetFrame, {
				Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			}, 0.12, Enum.EasingStyle.Sine)
		end
	end)
end

EnableSmoothDrag(TopBar, Window)
EnableSmoothDrag(FloatBtn, FloatBtn)

local MenuVisible = true
local function ToggleWindow()
	MenuVisible = not MenuVisible
	if MenuVisible then
		Window.Visible = true
		Tween(Window, {Size = UDim2.fromOffset(530, 345), BackgroundTransparency = 0}, 0.34, Enum.EasingStyle.Back)
	else
		Tween(Window, {Size = UDim2.fromOffset(530, 0), BackgroundTransparency = 0.4}, 0.24, Enum.EasingStyle.Quart)
		task.delay(0.24, function()
			if not MenuVisible then Window.Visible = false end
		end)
	end
end

MinBtn.MouseButton1Click:Connect(ToggleWindow)
FloatBtn.MouseButton1Click:Connect(ToggleWindow)
UserInputService.InputBegan:Connect(function(inp, gp)
	if not gp and inp.KeyCode == Enum.KeyCode.RightShift then
		ToggleWindow()
	end
end)

-- Панель вкладок слева (Sidebar) со скользящим неоновым индикатором
local Sidebar = Instance.new("Frame", Window)
Sidebar.Position = UDim2.fromOffset(0, 42)
Sidebar.Size = UDim2.new(0, 145, 1, -42)
Sidebar.BackgroundColor3 = Theme.BgSec
Sidebar.BorderSizePixel = 0

local SideDivider = Instance.new("Frame", Sidebar)
SideDivider.Position = UDim2.new(1, -1, 0, 0)
SideDivider.Size = UDim2.new(0, 1, 1, 0)
SideDivider.BackgroundColor3 = Color3.fromRGB(65, 38, 90)
SideDivider.BorderSizePixel = 0

-- Скользящая полоска активной вкладки
local SlidingIndicator = Instance.new("Frame", Sidebar)
SlidingIndicator.Position = UDim2.fromOffset(4, 15)
SlidingIndicator.Size = UDim2.fromOffset(4, 22)
SlidingIndicator.BackgroundColor3 = Theme.Pink
SlidingIndicator.BorderSizePixel = 0
SlidingIndicator.ZIndex = 5
Instance.new("UICorner", SlidingIndicator).CornerRadius = UDim.new(1, 0)

local SideHolder = Instance.new("Frame", Sidebar)
SideHolder.Size = UDim2.fromScale(1, 1)
SideHolder.BackgroundTransparency = 1

local SideLayout = Instance.new("UIListLayout", SideHolder)
SideLayout.Padding = UDim.new(0, 6)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SidePadding = Instance.new("UIPadding", SideHolder)
SidePadding.PaddingTop = UDim.new(0, 10)

local PagesArea = Instance.new("Frame", Window)
PagesArea.Position = UDim2.fromOffset(145, 42)
PagesArea.Size = UDim2.new(1, -145, 1, -42)
PagesArea.BackgroundTransparency = 1
PagesArea.ClipsDescendants = true

local Tabs = {}

local function CreateTab(tabName)
	local idx = #Tabs + 1
	local Btn = Instance.new("TextButton", SideHolder)
	Btn.LayoutOrder = idx
	Btn.Size = UDim2.fromOffset(126, 34)
	Btn.BackgroundColor3 = (idx == 1) and Theme.Pink or Theme.BgCard
	Btn.AutoButtonColor = false
	Btn.Font = Enum.Font.GothamBold
	Btn.Text = tabName
	Btn.TextColor3 = (idx == 1) and Theme.TextWhite or Theme.TextDim
	Btn.TextSize = 12
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

	local Page = Instance.new("ScrollingFrame", PagesArea)
	Page.Size = UDim2.fromScale(1, 1)
	Page.BackgroundTransparency = 1
	Page.BorderSizePixel = 0
	Page.ScrollBarThickness = 3
	Page.ScrollBarImageColor3 = Theme.Pink
	Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Page.CanvasSize = UDim2.new(0, 0, 0, 0)
	Page.Visible = (idx == 1)

	local PLayout = Instance.new("UIListLayout", Page)
	PLayout.Padding = UDim.new(0, 7)
	PLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	PLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local PPad = Instance.new("UIPadding", Page)
	PPad.PaddingTop = UDim.new(0, 10)
	PPad.PaddingBottom = UDim.new(0, 12)

	table.insert(Tabs, {Btn = Btn, Page = Page, Index = idx})

	Btn.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			SpawnRipple(Btn, inp.Position)
		end
	end)

	Btn.MouseButton1Click:Connect(function()
		for _, t in ipairs(Tabs) do
			t.Page.Visible = false
			Tween(t.Btn, {BackgroundColor3 = Theme.BgCard, TextColor3 = Theme.TextDim}, 0.22)
		end
		Page.Visible = true
		Page.Position = UDim2.fromOffset(0, 16)
		Tween(Page, {Position = UDim2.fromOffset(0, 0)}, 0.28, Enum.EasingStyle.Quart)
		Tween(Btn, {BackgroundColor3 = Theme.Pink, TextColor3 = Theme.TextWhite}, 0.25)

		-- Плавный переезд неонового индикатора к нажатой вкладке
		local targetY = 10 + (idx - 1) * 40 + 6
		Tween(SlidingIndicator, {Position = UDim2.fromOffset(4, targetY)}, 0.32, Enum.EasingStyle.Back)
	end)

	return Page
end

-- Конструкторы элементов с богатой анимацией
local function AddSection(page, title)
	local Lbl = Instance.new("TextLabel", page)
	Lbl.Size = UDim2.fromOffset(360, 20)
	Lbl.BackgroundTransparency = 1
	Lbl.Font = Enum.Font.GothamBlack
	Lbl.Text = "🌸 " .. string.upper(title) .. " 🌸"
	Lbl.TextColor3 = Theme.LightPink
	Lbl.TextSize = 11
end

local function AddToggle(page, text, defaultVal, callback)
	local Card = Instance.new("TextButton", page)
	Card.Size = UDim2.fromOffset(362, 38)
	Card.BackgroundColor3 = Theme.BgCard
	Card.AutoButtonColor = false
	Card.Text = ""
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 9)

	local Stroke = Instance.new("UIStroke", Card)
	Stroke.Color = defaultVal and Theme.Pink or Color3.fromRGB(68, 42, 95)
	Stroke.Thickness = 1
	Stroke.Transparency = 0.45

	local Lbl = Instance.new("TextLabel", Card)
	Lbl.Position = UDim2.fromOffset(12, 0)
	Lbl.Size = UDim2.new(1, -72, 1, 0)
	Lbl.BackgroundTransparency = 1
	Lbl.Font = Enum.Font.GothamSemibold
	Lbl.Text = text
	Lbl.TextColor3 = Theme.TextWhite
	Lbl.TextSize = 12
	Lbl.TextXAlignment = Enum.TextXAlignment.Left

	AttachAnimatedInteractions(Card, Lbl, Stroke, Theme.BgCard, Theme.BgHover)

	local SwitchBg = Instance.new("Frame", Card)
	SwitchBg.AnchorPoint = Vector2.new(1, 0.5)
	SwitchBg.Position = UDim2.new(1, -12, 0.5, 0)
	SwitchBg.Size = UDim2.fromOffset(42, 20)
	SwitchBg.BackgroundColor3 = defaultVal and Theme.Pink or Color3.fromRGB(52, 32, 72)
	Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

	local Knob = Instance.new("Frame", SwitchBg)
	Knob.AnchorPoint = Vector2.new(0, 0.5)
	Knob.Position = defaultVal and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	Knob.Size = UDim2.fromOffset(14, 14)
	Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

	local state = defaultVal
	Card.MouseButton1Click:Connect(function()
		state = not state
		Tween(SwitchBg, {BackgroundColor3 = state and Theme.Pink or Color3.fromRGB(52, 32, 72)}, 0.22)
		Tween(Knob, {Position = state and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, 0.28, Enum.EasingStyle.Back)
		Tween(Stroke, {Color = state and Theme.Pink or Color3.fromRGB(68, 42, 95)}, 0.22)
		callback(state)
	end)
end

local function AddSlider(page, text, minVal, maxVal, defaultVal, callback)
	local Box = Instance.new("Frame", page)
	Box.Size = UDim2.fromOffset(362, 48)
	Box.BackgroundColor3 = Theme.BgCard
	Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 9)

	local Stroke = Instance.new("UIStroke", Box)
	Stroke.Color = Color3.fromRGB(68, 42, 95)
	Stroke.Thickness = 1
	Stroke.Transparency = 0.45

	local Lbl = Instance.new("TextLabel", Box)
	Lbl.Position = UDim2.fromOffset(12, 5)
	Lbl.Size = UDim2.new(1, -24, 0, 18)
	Lbl.BackgroundTransparency = 1
	Lbl.Font = Enum.Font.GothamSemibold
	Lbl.Text = text .. ": " .. tostring(defaultVal)
	Lbl.TextColor3 = Theme.TextWhite
	Lbl.TextSize = 12
	Lbl.TextXAlignment = Enum.TextXAlignment.Left

	local Track = Instance.new("Frame", Box)
	Track.Position = UDim2.fromOffset(12, 30)
	Track.Size = UDim2.new(1, -24, 0, 8)
	Track.BackgroundColor3 = Color3.fromRGB(48, 28, 68)
	Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

	local pct0 = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
	local Fill = Instance.new("Frame", Track)
	Fill.Size = UDim2.new(pct0, 0, 1, 0)
	Fill.BackgroundColor3 = Theme.Pink
	Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

	local FillGrad = Instance.new("UIGradient", Fill)
	FillGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.Pink),
		ColorSequenceKeypoint.new(1, Theme.Purple)
	})

	local dragging = false
	local function UpdateFromInput(inp)
		local pct = math.clamp((inp.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
		local val = math.floor(minVal + (maxVal - minVal) * pct)
		Tween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.08)
		Lbl.Text = text .. ": " .. tostring(val)
		callback(val)
	end

	Box.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			Tween(Stroke, {Color = Theme.Pink, Transparency = 0.1}, 0.2)
			UpdateFromInput(inp)
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			Tween(Stroke, {Color = Color3.fromRGB(68, 42, 95), Transparency = 0.45}, 0.25)
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			UpdateFromInput(inp)
		end
	end)
end

local function AddButton(page, text, callback)
	local Btn = Instance.new("TextButton", page)
	Btn.Size = UDim2.fromOffset(362, 36)
	Btn.BackgroundColor3 = Theme.BgCard
	Btn.AutoButtonColor = false
	Btn.Text = ""
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 9)

	local Stroke = Instance.new("UIStroke", Btn)
	Stroke.Color = Theme.Pink
	Stroke.Thickness = 1
	Stroke.Transparency = 0.45

	local Lbl = Instance.new("TextLabel", Btn)
	Lbl.Position = UDim2.fromOffset(12, 0)
	Lbl.Size = UDim2.new(1, -24, 1, 0)
	Lbl.BackgroundTransparency = 1
	Lbl.Font = Enum.Font.GothamBold
	Lbl.Text = text
	Lbl.TextColor3 = Theme.LightPink
	Lbl.TextSize = 12
	Lbl.TextXAlignment = Enum.TextXAlignment.Left

	AttachAnimatedInteractions(Btn, Lbl, Stroke, Theme.BgCard, Theme.BgHover)

	Btn.MouseButton1Click:Connect(callback)
end

--// 8. СОЗДАНИЕ ВСЕХ ВКЛАДОК FEMBOYHUB V6
local TabCombat = CreateTab("🎯 Сайлент & Бой")
local TabNeon = CreateTab("🌸 Неон Скин")
local TabVisuals = CreateTab("✨ Визуалы & ESP")
local TabMove = CreateTab("🚀 Движение")
local TabTeleports = CreateTab("📍 Телепорты")

-- 1. ВКЛАДКА: САЙЛЕНТ АИМ, ТРИГГЕР-БОТ И AIMBOT
AddSection(TabCombat, "Silent Aim (Двойной метод)")
AddToggle(TabCombat, "Включить Silent Aim (Наводка пуль в радиусе FOV)", false, function(v)
	States.SilentAim = v
	if not v then UpdateSilentHitboxes(nil) end
	Notify("Silent Aim", v and "Сайлент Аим включен! Наведи круг FOV на врага." or "Сайлент Аим выключен", 2.5)
end)

AddToggle(TabCombat, "Умное расширение хитбокса цели в FOV (100% Рег)", true, function(v)
	States.SilentHitboxExpand = v
	if not v then UpdateSilentHitboxes(nil) end
end)

AddSlider(TabCombat, "Размер хитбокса цели для Silent Aim", 4, 18, 9, function(val)
	States.SilentHitboxSize = val
end)

AddToggle(TabCombat, "Рисовать линию захвата до цели (Target Line)", true, function(v)
	States.ShowTargetLine = v
end)

AddToggle(TabCombat, "Подсвечивать захваченную цель (Highlight)", true, function(v)
	States.HighlightTarget = v
end)

AddButton(TabCombat, "Часть тела: Голова / Торс / Рандом (Сменить)", function()
	if States.SilentTargetPart == "Head" then
		States.SilentTargetPart = "HumanoidRootPart"
	elseif States.SilentTargetPart == "HumanoidRootPart" then
		States.SilentTargetPart = "Random"
	else
		States.SilentTargetPart = "Head"
	end
	Notify("Silent Aim", "Выбрана часть тела: " .. States.SilentTargetPart, 2)
end)

AddSection(TabCombat, "TriggerBot и Плавный Aimbot")
AddToggle(TabCombat, "TriggerBot (Авто-выстрел при наведении на врага)", false, function(v)
	States.TriggerBot = v
	Notify("TriggerBot", v and "Триггер-бот активирован!" or "Триггер-бот выключен", 2)
end)

AddToggle(TabCombat, "Aimbot (Плавная доводка камеры на цель)", false, function(v)
	States.Aimbot = v
	Notify("Aimbot", v and "Аимбот включен" or "Аимбот выключен", 2)
end)

AddSlider(TabCombat, "Плавность Aimbot (%)", 5, 65, 18, function(val)
	States.AimbotSmooth = val
end)

AddToggle(TabCombat, "Быстрый выстрел (Rapid Fire для пушек)", false, function(v)
	States.RapidFire = v
	if v and plr.Character then
		for _, t in ipairs(plr.Character:GetChildren()) do ApplyRapidFireToTool(t) end
	end
	if v and plr:FindFirstChild("Backpack") then
		for _, t in ipairs(plr.Backpack:GetChildren()) do ApplyRapidFireToTool(t) end
	end
	Notify("Rapid Fire", v and "Скорострельность увеличена!" or "Rapid Fire выключен", 2)
end)

AddSection(TabCombat, "Настройки FOV и Проверок")
AddToggle(TabCombat, "Показывать неоновый круг FOV", true, function(v)
	States.ShowFOV = v
end)

AddToggle(TabCombat, "Радужное переливание круга FOV", false, function(v)
	States.RainbowFOV = v
end)

AddSlider(TabCombat, "Радиус круга FOV (px)", 45, 320, 135, function(val)
	States.FOV_Radius = val
end)

AddToggle(TabCombat, "Проверка стен (WallCheck — не целиться сквозь стены)", true, function(v)
	States.WallCheck = v
end)

AddToggle(TabCombat, "Проверка команды (TeamCheck — не целиться в своих)", true, function(v)
	States.TeamCheck = v
end)

-- 2. ВКЛАДКА: НЕОНОВЫЙ ПЕРСОНАЖ (НЕ СБРАСЫВАЕТСЯ ПОСЛЕ СМЕРТИ)
AddSection(TabNeon, "Неоновый Персонаж (Сохраняется после смерти)")
AddToggle(TabNeon, "Включить Неонового персонажа", false, function(v)
	States.NeonChar = v
	if plr.Character then ApplyNeonCharacter(plr.Character) end
	Notify("Femboy Neon", v and "Неоновый скин включен и закреплен после смерти!" or "Неоновый скин выключен", 2.5)
end)

AddButton(TabNeon, "Шейдер тела: Neon / ForceField (Сменить)", function()
	States.NeonMaterial = (States.NeonMaterial == "Neon") and "ForceField" or "Neon"
	if plr.Character and States.NeonChar then ApplyNeonCharacter(plr.Character) end
	Notify("Материал скина", "Выбран: " .. States.NeonMaterial, 2)
end)

AddToggle(TabNeon, "Радужный перелив Неона (Rainbow Femboy)", false, function(v)
	States.RainbowNeon = v
	if not v then
		States.NeonColor = Theme.Pink
		if plr.Character then
			if States.NeonChar then ApplyNeonCharacter(plr.Character) end
			RebuildCharacterAddons(plr.Character)
		end
	end
end)

AddButton(TabNeon, "Сменить цвет Неона (Розовый / Фиолетовый / Голубой / Мятный)", function()
	local palette = {
		Color3.fromRGB(255, 105, 180),
		Color3.fromRGB(185, 80, 255),
		Color3.fromRGB(0, 230, 255),
		Color3.fromRGB(80, 255, 165),
		Color3.fromRGB(255, 210, 75)
	}
	States.NeonColor = palette[math.random(1, #palette)]
	if plr.Character then
		if States.NeonChar then ApplyNeonCharacter(plr.Character) end
		RebuildCharacterAddons(plr.Character)
	end
end)

AddSection(TabNeon, "Неоновые Аксессуары и Эффекты")
AddToggle(TabNeon, "Неоновая коническая шляпа (ChinaHat)", false, function(v)
	States.ChinaHat = v
	if plr.Character then RebuildCharacterAddons(plr.Character) end
end)

AddToggle(TabNeon, "Вращающиеся неоновые сферы вокруг тела (Orbs)", false, function(v)
	States.SpinningOrbs = v
	if plr.Character then RebuildCharacterAddons(plr.Character) end
end)

AddToggle(TabNeon, "Неоновый шлейф за персонажем (Trail)", false, function(v)
	States.CharTrail = v
	if plr.Character then RebuildCharacterAddons(plr.Character) end
end)

AddToggle(TabNeon, "Неоновые искры (Sparkles)", false, function(v)
	States.CharSparkles = v
	if plr.Character then RebuildCharacterAddons(plr.Character) end
end)

AddToggle(TabNeon, "Свечение вокруг персонажа (Light Aura)", false, function(v)
	States.CharLightAura = v
	if plr.Character then RebuildCharacterAddons(plr.Character) end
end)

-- 3. ВКЛАДКА: ВИЗУАЛЫ И ESP
AddSection(TabVisuals, "ESP Подсветка Игроков")
AddToggle(TabVisuals, "Включить ESP (Highlight + Имя + HP + Дистанция)", false, function(v)
	States.ESP_Enabled = v
	UpdateESP()
end)

AddToggle(TabVisuals, "Кастомный вращающийся прицел (Crosshair)", false, function(v)
	States.CustomCrosshair = v
end)

AddSection(TabVisuals, "Визуалы Мира и Камеры")
AddToggle(TabVisuals, "Розовая атмосфера мира (Pink Ambience)", false, function(v)
	States.PinkWorld = v
	if v then
		Lighting.Ambient = Color3.fromRGB(255, 145, 210)
		Lighting.OutdoorAmbient = Color3.fromRGB(255, 125, 195)
		Lighting.ColorShift_Top = Color3.fromRGB(255, 105, 180)
	else
		Lighting.Ambient = Color3.fromRGB(127, 127, 127)
		Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
		Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
	end
end)

AddToggle(TabVisuals, "Fullbright (Максимальная яркость без теней)", false, function(v)
	States.Fullbright = v
	if v then
		Lighting.Brightness = 2.6
		Lighting.ClockTime = 14
		Lighting.GlobalShadows = false
	else
		Lighting.GlobalShadows = true
	end
end)

AddSlider(TabVisuals, "Поле зрения камеры (FOV)", 70, 120, 70, function(val)
	States.CameraFOV = val
	Camera.FieldOfView = val
end)

-- 4. ВКЛАДКА: ДВИЖЕНИЕ (ИСПРАВЛЕННЫЙ NOCLIP + ТВОЙ FLY)
AddSection(TabMove, "Полет и Проход сквозь стены")
AddToggle(TabMove, "Рабочий Noclip (Исправленный проход сквозь стены)", false, function(v)
	States.Noclip = v
	if not v then SetCharacterCollision(true) end
	Notify("Noclip", v and "Ноуклип включен — стены отключены!" or "Ноуклип выключен", 2)
end)

AddToggle(TabMove, "Fly (Твой идеальный полет)", false, function(v)
	States.Fly = v
	ToggleFly(v)
	Notify("Fly", v and "Полет активирован!" or "Полет выключен", 2)
end)

AddSlider(TabMove, "Скорость полета (FlySpeed)", 1, 14, 2, function(val)
	States.FlySpeed = val
end)

AddSection(TabMove, "Скорость, Прыжок и Spinbot")
AddToggle(TabMove, "Infinite Jump (Бесконечный прыжок в воздухе)", false, function(v)
	States.InfiniteJump = v
end)

AddToggle(TabMove, "Spinbot (Быстрое вращение персонажа)", false, function(v)
	States.Spinbot = v
end)

AddSlider(TabMove, "Скорость бега (WalkSpeed)", 16, 120, 16, function(val)
	States.WalkSpeed = val
	if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
		plr.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
	end
end)

AddSlider(TabMove, "Сила прыжка (JumpPower)", 50, 180, 50, function(val)
	States.JumpPower = val
	if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
		local h = plr.Character:FindFirstChildOfClass("Humanoid")
		h.UseJumpPower = true
		h.JumpPower = val
	end
end)

-- 5. ВКЛАДКА: ВСЕ 16 ТЕЛЕПОРТОВ ИЗ ADMINO4KA.LUA
AddSection(TabTeleports, "Все 16 Телепортов из Админки")

local AllAdminTeleports = {
	{"Nexus / Prison (Главный коридор)", CFrame.new(918.77, 100, 2379.07)},
	{"Yard (Двор тюрьмы)", CFrame.new(791, 98, 2498)},
	{"CrimBase (База криминалов)", CFrame.new(-858.0899, 94.476, 2093.8288)},
	{"Armory (Оружейная охраны)", CFrame.new(789, 100, 2260)},
	{"Cafe (Столовая)", CFrame.new(877, 100, 2256)},
	{"Lunchroom (Зал столовой)", CFrame.new(905, 100, 2226)},
	{"BackCafe (Задняя кухня кафе)", CFrame.new(918, 100, 2223)},
	{"TopNex (Крыша корпуса Nexus)", CFrame.new(829, 119, 2332)},
	{"Gate (Главные ворота)", CFrame.new(506, 118, 2251)},
	{"GateTower (Башня у ворот 1)", CFrame.new(502, 126, 2306)},
	{"GateTower 2 (Башня у ворот 2)", CFrame.new(505, 125, 2149)},
	{"Tower (Главная вышка во дворе)", CFrame.new(822, 131, 2588)},
	{"Sewers (Канализация)", CFrame.new(916, 79, 2311)},
	{"Bridge (Мост)", CFrame.new(54, 33, 1311)},
	{"Gas Station (Заправка)", CFrame.new(-518, 54, 1655)},
	{"Shooting Range (Стрельбище)", CFrame.new(403, 11, 1173)}
}

for _, loc in ipairs(AllAdminTeleports) do
	AddButton(TabTeleports, "📍 " .. loc[1], function()
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.Sit = false end
			plr.Character.HumanoidRootPart.CFrame = loc[2]
			Notify("Телепорт", "Перемещено в: " .. loc[1], 1.8)
		end
	end)
end

Notify("FemboyHub v6 Загружен!", "Нажми на круглую кнопку 🌸v6 слева или RightShift для меню.", 3.5)
