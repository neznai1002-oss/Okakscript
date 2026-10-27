--=============================================================================--
--                   FEMBOYHUB V8 | ULTRA STABLE & MEGA EDITION                --
--   TOP PILL ISLAND + RESIZABLE UI + WALLSHOT + SILENT AIM + ANTI-CRASH CORE  --
--                        [ PART 1 / 5 : CORE & PILL UI ]                      --
--=============================================================================--

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local Stats = game:GetService("Stats")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-------------------------------------------------------------------------
-- 1. БЕЗОПАСНОЕ ЯДРО (ANTI-CRASH GUARD & EXECUTOR FILE SYSTEM)
-------------------------------------------------------------------------
local function SafeCall(fn, ...)
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local guiParent = SafeCall(function()
    return (gethui and gethui()) or CoreGui
end) or LocalPlayer:WaitForChild("PlayerGui")

-- Очистка всех старых версий без риска краша
for _, oldName in ipairs({"FemboyHub_V8", "FemboyHub_V7", "FemboyHub_V6", "FemboyHub_BlackUI", "FemboyHub_ShitaroUI"}) do
    SafeCall(function()
        if guiParent:FindFirstChild(oldName) then
            guiParent[oldName]:Destroy()
        end
    end)
end
SafeCall(function()
    if Lighting:FindFirstChild("FH_IntroBlur") then
        Lighting.FH_IntroBlur:Destroy()
    end
end)

-- Инициализация папки для реального сохранения конфигов
local CONFIG_FOLDER = "FemboyHub_V8_Configs"
SafeCall(function()
    if isfolder and makefolder and not isfolder(CONFIG_FOLDER) then
        makefolder(CONFIG_FOLDER)
    end
end)

-- Цветовая схема (Pitch-Black + Неоновый акцент островка)
local Theme = {
    Accent = Color3.fromRGB(85, 175, 255),       -- Голубой неон как на рамке иконки со скриншота
    AccentWhite = Color3.fromRGB(255, 255, 255),
    BgMain = Color3.fromRGB(8, 8, 11),
    BgSidebar = Color3.fromRGB(11, 11, 15),
    BgCard = Color3.fromRGB(14, 14, 19),
    BgElement = Color3.fromRGB(19, 19, 26),
    BgElementHover = Color3.fromRGB(28, 28, 38),
    Border = Color3.fromRGB(32, 32, 42),
    BorderActive = Color3.fromRGB(85, 175, 255),
    TextWhite = Color3.fromRGB(245, 245, 252),
    TextGray = Color3.fromRGB(135, 135, 150),
    Success = Color3.fromRGB(80, 255, 145),
    Danger = Color3.fromRGB(255, 75, 95)
}

local DefaultLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogColor = Lighting.FogColor,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    ExposureCompensation = Lighting.ExposureCompensation
}

-- Глобальные таблицы управления и пулы объектов (чтобы скрипт НИКОГДА не крашил)
local Connections = {}
local VisualObjects = {}
local AccentObjects = {}
local AccentStrokes = {}
local AllSearchRows = {}
local ToggleSetters = {}
local SliderSetters = {}
local DropdownSetters = {}
local WallShotModifiedParts = {}
local OriginalHitboxSizes = {}
local ActiveEmoteTrack = nil
local MenuKeybind = Enum.KeyCode.RightShift
local CurrentAimbotTarget = nil
local CurrentTargetPart = nil

-- Базовые пресеты конфигов в памяти (дополняются файлами с устройства)
local SavedConfigs = {
    ["Legit_V8"] = {},
    ["Rage_WallShot"] = {},
    ["Visual_Max"] = {},
    ["Default"] = {}
}

-------------------------------------------------------------------------
-- 2. ГЛОБАЛЬНОЕ СОСТОЯНИЕ ВСЕХ ФУНКЦИЙ (STATE TABLE)
-------------------------------------------------------------------------
local State = {
    -- Настройки окна, Островка и Анимаций
    MenuScalePct = 95,
    ShowTopPillIsland = true,
    PillShowAvatarBox = true,
    Watermark = true,
    Preview3DWindow = true,
    PreviewESP = true,
    Notifications = true,
    ActiveArrayList = true,
    UIRippleFX = true,
    UIHoverGlow = true,
    UITabSlide = true,
    MascotAliveAnim = true,
    KeystrokesHUD = false,
    CustomCrosshair = false,
    CrosshairSpin = true,
    CrosshairGap = 8,
    AntiCrashGuard = true,

    -- COMBAT: Camera Aimbot
    AimbotEnabled = false,
    AimbotHoldMouse2 = false,
    AimbotSmoothness = 16,
    AimbotFOV = 120,
    ShowFOVCircle = false,
    RainbowFOV = false,
    FilledFOVCircle = false,
    AimbotHitPart = "Head",
    AimbotTeamCheck = false,
    AimbotWallCheck = false,
    AimbotAliveCheck = true,
    AimbotPrediction = false,
    AimbotPredictVal = 15,
    LockTracerLine = false,
    TargetHUDPanel = false,
    TargetOrbitStrafe = false,
    TargetStrafeRadius = 8,
    TargetStrafeSpeed = 12,

    -- COMBAT: Silent Aim, WallShot & Hitboxes (ИСПРАВЛЕННЫЕ)
    SilentAimEnabled = false,
    SilentAimHitChance = 100,
    SilentAimUseFOV = true,
    SilentAimMethod = "Hybrid", -- "Hybrid", "MouseHit", "MicroFlick"
    SilentAimHeadshotRate = 85,
    WallShotEnabled = false,
    WallShotMaxWalls = 6,
    WallShotVisualRay = true,
    HitboxExpander = false,
    HitboxTargetBone = "HumanoidRootPart", -- "Head", "HumanoidRootPart"
    HitboxSize = 14,
    HitboxTransparency = 75,
    TriggerBot = false,
    TriggerDelay = 45,
    AutoShootTarget = false,

    -- ANTI-CHEAT BYPASS V2
    BypassSpeedSpoof = true,
    BypassSizeSpoof = true,
    BypassAntiKick = true,
    BypassVelocityClamp = false,
    BypassHumanoidState = false,
    BypassNoFallDamage = false,

    -- Движение и Физика
    Fly = false,
    FlySpeed = 65,
    Noclip = false,
    WalkSpeedOn = false,
    WalkSpeed = 46,
    JumpPowerOn = false,
    JumpPower = 90,
    Bhop = false,
    InfiniteJump = false,
    Wallhop = false,
    AirWalk = false,
    SpiderClimb = false,
    ClickTP = false,
    Spinbot = false,
    SpinSpeed = 45,
    AspectRatioOn = false,
    AspectRatio = 74,
    CustomFOVOn = false,
    CustomFOV = 108,

    -- Десинки и Защита
    FakePos = false,
    VelDesync = false,
    AntiFling = false,
    AntiVoid = false,
    AntiSit = false,
    AntiRagdoll = false,

    -- Шейдеры и Погода
    RTXShaders = false,
    MotionBlur = false,
    Fullbright = false,
    XRayWalls = false,
    SakuraWeather = false,
    SnowWeather = false,
    NeonRain = false,
    VoidAsh = false,
    StarfallWeather = false,

    -- 3D Ауры, Экипировка и Шлейфы
    Constellations3D = false,
    ChinaHat = false,
    Halo = false,
    AngelWings = false,
    MagicCircle = false,
    FloatingSwords = false,
    CyberRing = false,
    OrbitPlanets = false,
    TeslaLightning = false,
    DNAHelixAura = false,
    BlackholeCore = false,
    RunicPillars = false,
    SeraphimEyes = false,
    EnergyShieldSphere = false,
    NeonRibbonTrail = false,
    GhostTrail = false,
    JumpRings = false,
    FireFootsteps = false,
    PointLightGlow = false,

    -- ESP и Кастомизация Персонажа
    HighlightESP = false,
    NameESP = false,
    TracersESP = false,
    Box2DESP = false,
    HeadDotESP = false,
    LookLaserESP = false,
    DamagePopupESP = false,
    Radar2D = false,
    FakeHeadless = false,
    FakeKorblox = false,
    SelfChams = false,
    RainbowBody = false,
    GhostBody = false,

    -- Модификаторы Анимаций
    HyperAnims = false,
    SlowAnims = false,
    FreezePose = false,
    MatrixLean = false,
    HelicopterTilt = false
}

-------------------------------------------------------------------------
-- 3. МЕНЕДЖЕР РЕСУРСОВ И ПУЛ ОБЪЕКТОВ (ЗАЩИТА ОТ ЛАГОВ И ВЫЛЕТОВ)
-------------------------------------------------------------------------
local function Disconnect(name)
    if Connections[name] then
        SafeCall(function() Connections[name]:Disconnect() end)
        Connections[name] = nil
    end
end

local function ClearVisual(name)
    if VisualObjects[name] then
        SafeCall(function()
            if typeof(VisualObjects[name]) == "Instance" then
                VisualObjects[name]:Destroy()
            elseif type(VisualObjects[name]) == "table" then
                for _, v in pairs(VisualObjects[name]) do
                    if typeof(v) == "Instance" then v:Destroy() end
                end
            end
        end)
        VisualObjects[name] = nil
    end
end

local function RestoreWallShotParts()
    for part, origCanQuery in pairs(WallShotModifiedParts) do
        SafeCall(function()
            if part and part.Parent then
                part.CanQuery = origCanQuery
            end
        end)
    end
    table.clear(WallShotModifiedParts)
end

local function RestoreHitboxes()
    for plr, data in pairs(OriginalHitboxSizes) do
        SafeCall(function()
            if plr and plr.Character then
                for boneName, origProps in pairs(data) do
                    local b = plr.Character:FindFirstChild(boneName)
                    if b and b:IsA("BasePart") then
                        b.Size = origProps.Size
                        b.Transparency = origProps.Transparency
                        b.Material = origProps.Material
                        b.CanCollide = origProps.CanCollide
                    end
                end
            end
        end)
    end
    table.clear(OriginalHitboxSizes)
end

local function PlaySound(id, vol, pitch)
    SafeCall(function()
        local s = Instance.new("Sound", SoundService)
        s.SoundId = "rbxassetid://" .. tostring(id)
        s.Volume = vol or 0.45
        s.PlaybackSpeed = pitch or 1
        s:Play()
        Debris:AddItem(s, 2.5)
    end)
end

local function QuickTween(obj, duration, style, dir, props)
    if not obj then return nil end
    local tw = TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props
    )
    tw:Play()
    return tw
end

-- Анимация волны клика (Ripple) + микровспышка
local function SpawnRipple(btn, clickPos)
    if not State.UIRippleFX or not btn then return end
    SafeCall(function()
        btn.ClipsDescendants = true
        local ripple = Instance.new("Frame", btn)
        ripple.Name = "UIRipple"
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Theme.Accent
        ripple.BackgroundTransparency = 0.6
        ripple.BorderSizePixel = 0
        ripple.ZIndex = btn.ZIndex + 3
        Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)

        local relX = clickPos and (clickPos.X - btn.AbsolutePosition.X) or (btn.AbsoluteSize.X / 2)
        local relY = clickPos and (clickPos.Y - btn.AbsolutePosition.Y) or (btn.AbsoluteSize.Y / 2)
        ripple.Position = UDim2.new(0, relX, 0, relY)
        ripple.Size = UDim2.new(0, 0, 0, 0)

        local maxDiam = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.2
        local tw = QuickTween(ripple, 0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
            Size = UDim2.new(0, maxDiam, 0, maxDiam),
            BackgroundTransparency = 1
        })
        if tw then
            tw.Completed:Connect(function()
                if ripple then ripple:Destroy() end
            end)
        end
    end)
end

local function BindInteractiveHover(btn, strokeObj, labelObj, basePadX)
    btn.MouseEnter:Connect(function()
        if not State.UIHoverGlow then return end
        if strokeObj then
            QuickTween(strokeObj, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Color = Theme.Accent})
        end
        if labelObj and basePadX then
            QuickTween(labelObj, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
                Position = UDim2.new(0, basePadX + 4, 0, 0)
            })
        end
    end)
    btn.MouseLeave:Connect(function()
        if strokeObj then
            QuickTween(strokeObj, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Color = Theme.Border})
        end
        if labelObj and basePadX then
            QuickTween(labelObj, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                Position = UDim2.new(0, basePadX, 0, 0)
            })
        end
    end)
end

-------------------------------------------------------------------------
-- 4. СОЗДАНИЕ SCREEN GUI И УВЕДОМЛЕНИЙ (TOAST NOTIFICATIONS)
-------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FemboyHub_V8"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = guiParent

local NotifyHolder = Instance.new("Frame", ScreenGui)
NotifyHolder.Size = UDim2.new(0, 240, 1, -24)
NotifyHolder.Position = UDim2.new(1, -252, 0, 12)
NotifyHolder.BackgroundTransparency = 1
NotifyHolder.ZIndex = 90

local NotifyLayout = Instance.new("UIListLayout", NotifyHolder)
NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifyLayout.Padding = UDim.new(0, 6)
NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function Notify(title, msg, duration)
    if not State.Notifications then return end
    SafeCall(function()
        local Wrapper = Instance.new("Frame", NotifyHolder)
        Wrapper.Size = UDim2.new(1, 0, 0, 44)
        Wrapper.BackgroundTransparency = 1

        local Card = Instance.new("Frame", Wrapper)
        Card.Size = UDim2.new(1, 0, 1, 0)
        Card.Position = UDim2.new(1, 50, 0, 0)
        Card.BackgroundColor3 = Theme.BgMain
        Card.BorderSizePixel = 0
        Card.ClipsDescendants = true
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
        local st = Instance.new("UIStroke", Card)
        st.Color = Theme.Border
        table.insert(AccentStrokes, st)

        local SideBar = Instance.new("Frame", Card)
        SideBar.Size = UDim2.new(0, 2, 1, -10)
        SideBar.Position = UDim2.new(0, 4, 0, 5)
        SideBar.BackgroundColor3 = Theme.Accent
        SideBar.BorderSizePixel = 0
        table.insert(AccentObjects, SideBar)

        local TimerBar = Instance.new("Frame", Card)
        TimerBar.Size = UDim2.new(1, 0, 0, 2)
        TimerBar.Position = UDim2.new(0, 0, 1, -2)
        TimerBar.BackgroundColor3 = Theme.Accent
        TimerBar.BorderSizePixel = 0
        table.insert(AccentObjects, TimerBar)

        local T1 = Instance.new("TextLabel", Card)
        T1.Size = UDim2.new(1, -18, 0, 15)
        T1.Position = UDim2.new(0, 12, 0, 5)
        T1.BackgroundTransparency = 1
        T1.Text = "✦ " .. tostring(title)
        T1.TextColor3 = Theme.TextWhite
        T1.Font = Enum.Font.GothamBold
        T1.TextSize = 11
        T1.TextXAlignment = Enum.TextXAlignment.Left

        local T2 = Instance.new("TextLabel", Card)
        T2.Size = UDim2.new(1, -18, 0, 15)
        T2.Position = UDim2.new(0, 12, 0, 21)
        T2.BackgroundTransparency = 1
        T2.Text = tostring(msg)
        T2.TextColor3 = Theme.TextGray
        T2.Font = Enum.Font.Gotham
        T2.TextSize = 10
        T2.TextXAlignment = Enum.TextXAlignment.Left

        local life = duration or 2.2
        QuickTween(Card, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Position = UDim2.new(0, 0, 0, 0)})
        QuickTween(TimerBar, life, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, {Size = UDim2.new(0, 0, 0, 2)})

        task.delay(life, function()
            if Card and Card.Parent then
                local outTw = QuickTween(Card, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In, {
                    Position = UDim2.new(1, 60, 0, 0)
                })
                if outTw then outTw.Completed:Wait() end
                if Wrapper then Wrapper:Destroy() end
            end
        end)
    end)
end

-------------------------------------------------------------------------
-- 5. СКРУГЛЕННАЯ ВЕРХНЯЯ КНОПКА-ОСТРОВОК (1:1 КАК НА СКРИНШОТЕ PULSE HUB)
-------------------------------------------------------------------------
-- Держит сверху квадратную иконку с неоновой рамкой и скруглённую чёрную капсулу [ — FemboyHub ]
local TopIslandContainer = Instance.new("Frame", ScreenGui)
TopIslandContainer.Name = "TopPillIsland"
TopIslandContainer.Size = UDim2.new(0, 156, 0, 62)
TopIslandContainer.Position = UDim2.new(0.5, -78, 0, 8)
TopIslandContainer.BackgroundTransparency = 1
TopIslandContainer.Visible = false
TopIslandContainer.ZIndex = 75

-- Верхний квадратный блок с аватаркой/эмблемой и голубой светящейся рамкой (как на фото)
local IslandIconBox = Instance.new("Frame", TopIslandContainer)
IslandIconBox.Name = "IconSquare"
IslandIconBox.Size = UDim2.new(0, 36, 0, 36)
IslandIconBox.Position = UDim2.new(0.5, -18, 0, 0)
IslandIconBox.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
IslandIconBox.ZIndex = 75
Instance.new("UICorner", IslandIconBox).CornerRadius = UDim.new(0, 9)

local IslandIconStroke = Instance.new("UIStroke", IslandIconBox)
IslandIconStroke.Color = Theme.Accent
IslandIconStroke.Thickness = 2
table.insert(AccentStrokes, IslandIconStroke)

local IslandAvatar = Instance.new("ImageLabel", IslandIconBox)
IslandAvatar.Size = UDim2.new(1, -4, 1, -4)
IslandAvatar.Position = UDim2.new(0, 2, 0, 2)
IslandAvatar.BackgroundTransparency = 1
IslandAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
IslandAvatar.ZIndex = 76
Instance.new("UICorner", IslandAvatar).CornerRadius = UDim.new(0, 7)

-- Нижняя скруглённая тёмная капсула (Pill Button) с полоской-индикатором и текстом
local PillButton = Instance.new("TextButton", TopIslandContainer)
PillButton.Name = "PillButton"
PillButton.Size = UDim2.new(0, 146, 0, 30)
PillButton.Position = UDim2.new(0.5, -73, 0, 27)
PillButton.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
PillButton.BackgroundTransparency = 0.08
PillButton.Text = ""
PillButton.AutoButtonColor = false
PillButton.ZIndex = 77
Instance.new("UICorner", PillButton).CornerRadius = UDim.new(1, 0)

local PillStroke = Instance.new("UIStroke", PillButton)
PillStroke.Color = Color3.fromRGB(38, 38, 48)
PillStroke.Thickness = 1.2

-- Белая горизонтальная полоска слева внутри капсулы: [ — FemboyHub ]
local PillDashBar = Instance.new("Frame", PillButton)
PillDashBar.Size = UDim2.new(0, 15, 0, 3)
PillDashBar.Position = UDim2.new(0, 20, 0.5, -1)
PillDashBar.BackgroundColor3 = Theme.TextWhite
PillDashBar.BorderSizePixel = 0
PillDashBar.ZIndex = 78
Instance.new("UICorner", PillDashBar).CornerRadius = UDim.new(1, 0)
table.insert(AccentObjects, PillDashBar)

local PillTitle = Instance.new("TextLabel", PillButton)
PillTitle.Size = UDim2.new(1, -46, 1, 0)
PillTitle.Position = UDim2.new(0, 42, 0, 0)
PillTitle.BackgroundTransparency = 1
PillTitle.Text = "FemboyHub"
PillTitle.TextColor3 = Theme.TextWhite
PillTitle.Font = Enum.Font.GothamBold
PillTitle.TextSize = 12
PillTitle.TextXAlignment = Enum.TextXAlignment.Left
PillTitle.ZIndex = 78

-- Анимация при наведении на капсулу
PillButton.MouseEnter:Connect(function()
    QuickTween(PillButton, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
        Size = UDim2.new(0, 154, 0, 32),
        Position = UDim2.new(0.5, -77, 0, 26)
    })
    QuickTween(PillStroke, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Color = Theme.Accent})
    QuickTween(PillDashBar, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Size = UDim2.new(0, 20, 0, 3)})
end)

PillButton.MouseLeave:Connect(function()
    QuickTween(PillButton, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
        Size = UDim2.new(0, 146, 0, 30),
        Position = UDim2.new(0.5, -73, 0, 27)
    })
    QuickTween(PillStroke, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Color = Color3.fromRGB(38, 38, 48)})
    QuickTween(PillDashBar, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Size = UDim2.new(0, 15, 0, 3)})
end)

-------------------------------------------------------------------------
-- 6. КОМПАКТНОЕ ИНТРО (НЕ НА ВЕСЬ ЭКРАН)
-------------------------------------------------------------------------
local function RunCompactCinematicIntro(onComplete)
    local IntroCard = Instance.new("Frame", ScreenGui)
    IntroCard.Name = "CompactIntroWindow"
    IntroCard.Size = UDim2.new(0, 0, 0, 0)
    IntroCard.Position = UDim2.new(0.5, 0, 0.5, 0)
    IntroCard.AnchorPoint = Vector2.new(0.5, 0.5)
    IntroCard.BackgroundColor3 = Theme.BgMain
    IntroCard.ClipsDescendants = true
    IntroCard.ZIndex = 120
    Instance.new("UICorner", IntroCard).CornerRadius = UDim.new(0, 8)

    local IntroStroke = Instance.new("UIStroke", IntroCard)
    IntroStroke.Color = Theme.Accent
    IntroStroke.Thickness = 1.4

    local StrokeGrad = Instance.new("UIGradient", IntroStroke)
    StrokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 30, 42)),
        ColorSequenceKeypoint.new(1, Theme.Accent)
    })

    local Badge = Instance.new("TextLabel", IntroCard)
    Badge.Size = UDim2.new(0, 96, 0, 18)
    Badge.Position = UDim2.new(0.5, -48, 0, 12)
    Badge.BackgroundColor3 = Theme.BgElement
    Badge.Text = "V8 STABLE"
    Badge.TextColor3 = Theme.Accent
    Badge.Font = Enum.Font.Code
    Badge.TextSize = 10
    Badge.ZIndex = 122
    Instance.new("UICorner", Badge).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", Badge).Color = Theme.Border

    local LogoBig = Instance.new("TextLabel", IntroCard)
    LogoBig.Size = UDim2.new(1, 0, 0, 28)
    LogoBig.Position = UDim2.new(0, 0, 0, 34)
    LogoBig.BackgroundTransparency = 1
    LogoBig.Text = "F E M B O Y H U B"
    LogoBig.TextColor3 = Theme.TextWhite
    LogoBig.Font = Enum.Font.GothamBold
    LogoBig.TextSize = 20
    LogoBig.TextTransparency = 1
    LogoBig.ZIndex = 122

    local SubTitle = Instance.new("TextLabel", IntroCard)
    SubTitle.Size = UDim2.new(1, 0, 0, 15)
    SubTitle.Position = UDim2.new(0, 0, 0, 62)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "WALLSHOT • SILENT AIM • BYPASS V2 • NO-CRASH"
    SubTitle.TextColor3 = Theme.TextGray
    SubTitle.Font = Enum.Font.Code
    SubTitle.TextSize = 9
    SubTitle.TextTransparency = 1
    SubTitle.ZIndex = 122

    local StepText = Instance.new("TextLabel", IntroCard)
    StepText.Size = UDim2.new(1, -40, 0, 16)
    StepText.Position = UDim2.new(0, 20, 0, 98)
    StepText.BackgroundTransparency = 1
    StepText.Text = "Initializing Anti-Crash Pool..."
    StepText.TextColor3 = Theme.TextWhite
    StepText.Font = Enum.Font.GothamMedium
    StepText.TextSize = 10
    StepText.TextXAlignment = Enum.TextXAlignment.Left
    StepText.ZIndex = 122

    local PctText = Instance.new("TextLabel", IntroCard)
    PctText.Size = UDim2.new(0, 48, 0, 16)
    PctText.Position = UDim2.new(1, -68, 0, 98)
    PctText.BackgroundTransparency = 1
    PctText.Text = "0%"
    PctText.TextColor3 = Theme.Accent
    PctText.Font = Enum.Font.GothamBold
    PctText.TextSize = 10
    PctText.TextXAlignment = Enum.TextXAlignment.Right
    PctText.ZIndex = 122

    local BarBack = Instance.new("Frame", IntroCard)
    BarBack.Size = UDim2.new(1, -40, 0, 5)
    BarBack.Position = UDim2.new(0, 20, 0, 118)
    BarBack.BackgroundColor3 = Theme.BgElement
    BarBack.BorderSizePixel = 0
    BarBack.ZIndex = 122
    Instance.new("UICorner", BarBack).CornerRadius = UDim.new(1, 0)

    local BarFill = Instance.new("Frame", BarBack)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Theme.Accent
    BarFill.BorderSizePixel = 0
    BarFill.ZIndex = 123
    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

    local gradConn = RunService.RenderStepped:Connect(function(dt)
        StrokeGrad.Rotation = (StrokeGrad.Rotation + dt * 160) % 360
    end)

    PlaySound(9119713951, 0.45, 1.05)

    QuickTween(IntroCard, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
        Size = UDim2.new(0, 340, 0, 142)
    })
    task.wait(0.2)
    QuickTween(LogoBig, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = 0})
    QuickTween(SubTitle, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = 0})

    local steps = {
        {pct = 0.25, txt = "Mounting Anti-Cheat Bypass V2..."},
        {pct = 0.55, txt = "Hooking Silent Aim & WallShot Piercer..."},
        {pct = 0.82, txt = "Syncing FileSystem Configs & 3D Pool..."},
        {pct = 1.00, txt = "Welcome, @" .. LocalPlayer.Name .. "!"}
    }

    for _, st in ipairs(steps) do
        StepText.Text = st.txt
        PctText.Text = math.floor(st.pct * 100) .. "%"
        QuickTween(BarFill, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
            Size = UDim2.new(st.pct, 0, 1, 0)
        })
        task.wait(0.22)
    end

    PlaySound(6895079853, 0.5, 1.08)
    task.wait(0.15)

    if gradConn then gradConn:Disconnect() end
    local closeTw = QuickTween(IntroCard, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.In, {
        Size = UDim2.new(0, 0, 0, 0)
    })
    if closeTw then closeTw.Completed:Wait() end
    IntroCard:Destroy()
    if onComplete then onComplete() end
end

-------------------------------------------------------------------------
-- [ PART 2 / 5 : HUD OVERLAYS, RESIZABLE COMPACT UI & WIDGET BUILDER ]
-------------------------------------------------------------------------

-- 1. Круг радиуса Aimbot / Silent Aim (FOV Circle)
local FOVCircleFrame = Instance.new("Frame", ScreenGui)
FOVCircleFrame.Name = "AimbotFOVCircle"
FOVCircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircleFrame.Size = UDim2.new(0, State.AimbotFOV * 2, 0, State.AimbotFOV * 2)
FOVCircleFrame.BackgroundColor3 = Theme.Accent
FOVCircleFrame.BackgroundTransparency = 1
FOVCircleFrame.BorderSizePixel = 0
FOVCircleFrame.Visible = false
FOVCircleFrame.ZIndex = 15
Instance.new("UICorner", FOVCircleFrame).CornerRadius = UDim.new(1, 0)

local FOVStroke = Instance.new("UIStroke", FOVCircleFrame)
FOVStroke.Color = Theme.Accent
FOVStroke.Thickness = 1.4
FOVStroke.Transparency = 0.15
table.insert(AccentObjects, FOVCircleFrame)
table.insert(AccentStrokes, FOVStroke)

-- 2. Линия захвата цели (Snapline)
local AimbotSnapline = Instance.new("Frame", ScreenGui)
AimbotSnapline.Name = "AimbotSnapline"
AimbotSnapline.AnchorPoint = Vector2.new(0.5, 0.5)
AimbotSnapline.BackgroundColor3 = Theme.Accent
AimbotSnapline.BorderSizePixel = 0
AimbotSnapline.Visible = false
AimbotSnapline.ZIndex = 16
table.insert(AccentObjects, AimbotSnapline)

-- Индикатор активного WallShot на экране
local WallShotBadge = Instance.new("TextLabel", ScreenGui)
WallShotBadge.Size = UDim2.new(0, 120, 0, 18)
WallShotBadge.Position = UDim2.new(0.5, -60, 0.5, 28)
WallShotBadge.BackgroundColor3 = Theme.BgMain
WallShotBadge.BackgroundTransparency = 0.25
WallShotBadge.Text = "⚡ WALLSHOT READY"
WallShotBadge.TextColor3 = Theme.Success
WallShotBadge.Font = Enum.Font.Code
WallShotBadge.TextSize = 10
WallShotBadge.Visible = false
WallShotBadge.ZIndex = 17
Instance.new("UICorner", WallShotBadge).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", WallShotBadge).Color = Theme.Border

-- 3. Анимированный кастомный прицел (Spinning Neon Crosshair)
local CrosshairHolder = Instance.new("Frame", ScreenGui)
CrosshairHolder.Size = UDim2.new(0, 36, 0, 36)
CrosshairHolder.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
CrosshairHolder.BackgroundTransparency = 1
CrosshairHolder.Visible = false
CrosshairHolder.ZIndex = 18

local CrossCenterDot = Instance.new("Frame", CrosshairHolder)
CrossCenterDot.Size = UDim2.new(0, 3, 0, 3)
CrossCenterDot.AnchorPoint = Vector2.new(0.5, 0.5)
CrossCenterDot.Position = UDim2.new(0.5, 0, 0.5, 0)
CrossCenterDot.BackgroundColor3 = Theme.Accent
CrossCenterDot.BorderSizePixel = 0
Instance.new("UICorner", CrossCenterDot).CornerRadius = UDim.new(1, 0)
table.insert(AccentObjects, CrossCenterDot)

local CrossBars = {}
local barOffsets = {
    {x = 0, y = -1, w = 2, h = 7},
    {x = 0, y = 1,  w = 2, h = 7},
    {x = -1, y = 0, w = 7, h = 2},
    {x = 1, y = 0,  w = 7, h = 2}
}
for _, off in ipairs(barOffsets) do
    local b = Instance.new("Frame", CrosshairHolder)
    b.Size = UDim2.new(0, off.w, 0, off.h)
    b.AnchorPoint = Vector2.new(0.5, 0.5)
    b.Position = UDim2.new(0.5, off.x * 9, 0.5, off.y * 9)
    b.BackgroundColor3 = Theme.Accent
    b.BorderSizePixel = 0
    table.insert(AccentObjects, b)
    table.insert(CrossBars, {ui = b, dirX = off.x, dirY = off.y})
end

-- 4. Target HUD (Плавающая карточка цели)
local TargetHUD = Instance.new("Frame", ScreenGui)
TargetHUD.Name = "TargetHUD"
TargetHUD.Size = UDim2.new(0, 210, 0, 58)
TargetHUD.Position = UDim2.new(0.5, -105, 0.79, 0)
TargetHUD.BackgroundColor3 = Theme.BgMain
TargetHUD.BorderSizePixel = 0
TargetHUD.Visible = false
TargetHUD.ZIndex = 25
Instance.new("UICorner", TargetHUD).CornerRadius = UDim.new(0, 6)
local THUDStroke = Instance.new("UIStroke", TargetHUD)
THUDStroke.Color = Theme.Accent
table.insert(AccentStrokes, THUDStroke)

local THUDAvatar = Instance.new("ImageLabel", TargetHUD)
THUDAvatar.Size = UDim2.new(0, 40, 0, 40)
THUDAvatar.Position = UDim2.new(0, 8, 0.5, -20)
THUDAvatar.BackgroundColor3 = Theme.BgElement
THUDAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", THUDAvatar).CornerRadius = UDim.new(0, 6)

local THUDName = Instance.new("TextLabel", TargetHUD)
THUDName.Size = UDim2.new(1, -58, 0, 15)
THUDName.Position = UDim2.new(0, 54, 0, 7)
THUDName.BackgroundTransparency = 1
THUDName.Text = "Target: None"
THUDName.TextColor3 = Theme.TextWhite
THUDName.Font = Enum.Font.GothamBold
THUDName.TextSize = 11
THUDName.TextXAlignment = Enum.TextXAlignment.Left

local THUDInfo = Instance.new("TextLabel", TargetHUD)
THUDInfo.Size = UDim2.new(1, -58, 0, 13)
THUDInfo.Position = UDim2.new(0, 54, 0, 22)
THUDInfo.BackgroundTransparency = 1
THUDInfo.Text = "HP: 100 | Dist: 0m"
THUDInfo.TextColor3 = Theme.TextGray
THUDInfo.Font = Enum.Font.Code
THUDInfo.TextSize = 10
THUDInfo.TextXAlignment = Enum.TextXAlignment.Left

local THUDHpBg = Instance.new("Frame", TargetHUD)
THUDHpBg.Size = UDim2.new(1, -62, 0, 6)
THUDHpBg.Position = UDim2.new(0, 54, 0, 41)
THUDHpBg.BackgroundColor3 = Theme.BgElement
THUDHpBg.BorderSizePixel = 0
Instance.new("UICorner", THUDHpBg).CornerRadius = UDim.new(1, 0)

local THUDHpFill = Instance.new("Frame", THUDHpBg)
THUDHpFill.Size = UDim2.new(1, 0, 1, 0)
THUDHpFill.BackgroundColor3 = Theme.Accent
THUDHpFill.BorderSizePixel = 0
Instance.new("UICorner", THUDHpFill).CornerRadius = UDim.new(1, 0)
table.insert(AccentObjects, THUDHpFill)

-- 5. Active ArrayList (Список включённых модулей справа сверху)
local ArrayListFrame = Instance.new("Frame", ScreenGui)
ArrayListFrame.Name = "ActiveArrayList"
ArrayListFrame.Size = UDim2.new(0, 165, 0, 300)
ArrayListFrame.Position = UDim2.new(1, -175, 0, 10)
ArrayListFrame.BackgroundTransparency = 1
ArrayListFrame.ZIndex = 20

local ArrayLayout = Instance.new("UIListLayout", ArrayListFrame)
ArrayLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ArrayLayout.Padding = UDim.new(0, 3)
ArrayLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ArrayItems = {}
local function UpdateArrayList(modName, enabled)
    SafeCall(function()
        if not State.ActiveArrayList then
            ArrayListFrame.Visible = false
            return
        end
        ArrayListFrame.Visible = true
        if enabled and not ArrayItems[modName] then
            local tag = Instance.new("Frame", ArrayListFrame)
            tag.Name = modName
            tag.Size = UDim2.new(0, 0, 0, 19)
            tag.BackgroundColor3 = Theme.BgMain
            tag.BackgroundTransparency = 0.12
            tag.ClipsDescendants = true
            Instance.new("UICorner", tag).CornerRadius = UDim.new(0, 4)

            local side = Instance.new("Frame", tag)
            side.Size = UDim2.new(0, 2, 1, 0)
            side.Position = UDim2.new(1, -2, 0, 0)
            side.BackgroundColor3 = Theme.Accent
            side.BorderSizePixel = 0
            table.insert(AccentObjects, side)

            local lbl = Instance.new("TextLabel", tag)
            lbl.Size = UDim2.new(1, -10, 1, 0)
            lbl.Position = UDim2.new(0, 5, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = modName
            lbl.TextColor3 = Theme.TextWhite
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 10
            lbl.TextXAlignment = Enum.TextXAlignment.Right

            local targetW = math.clamp(#modName * 6.2 + 18, 65, 165)
            ArrayItems[modName] = tag
            QuickTween(tag, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Size = UDim2.new(0, targetW, 0, 19)})
        elseif not enabled and ArrayItems[modName] then
            local oldTag = ArrayItems[modName]
            ArrayItems[modName] = nil
            local tw = QuickTween(oldTag, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {Size = UDim2.new(0, 0, 0, 19)})
            if tw then
                tw.Completed:Connect(function()
                    if oldTag then oldTag:Destroy() end
                end)
            end
        end
    end)
end

-- 6. 2D Mini-Radar HUD (Мини-радар игроков)
local RadarFrame = Instance.new("Frame", ScreenGui)
RadarFrame.Name = "MiniRadar2D"
RadarFrame.Size = UDim2.new(0, 110, 0, 110)
RadarFrame.Position = UDim2.new(0, 14, 0, 44)
RadarFrame.BackgroundColor3 = Theme.BgMain
RadarFrame.BackgroundTransparency = 0.12
RadarFrame.Visible = false
RadarFrame.ClipsDescendants = true
RadarFrame.ZIndex = 22
Instance.new("UICorner", RadarFrame).CornerRadius = UDim.new(0, 8)
local RadarStroke = Instance.new("UIStroke", RadarFrame)
RadarStroke.Color = Theme.Border

local RadarCrossH = Instance.new("Frame", RadarFrame)
RadarCrossH.Size = UDim2.new(1, 0, 0, 1)
RadarCrossH.Position = UDim2.new(0, 0, 0.5, 0)
RadarCrossH.BackgroundColor3 = Theme.Border
RadarCrossH.BorderSizePixel = 0

local RadarCrossV = Instance.new("Frame", RadarFrame)
RadarCrossV.Size = UDim2.new(0, 1, 1, 0)
RadarCrossV.Position = UDim2.new(0.5, 0, 0, 0)
RadarCrossV.BackgroundColor3 = Theme.Border
RadarCrossV.BorderSizePixel = 0

local RadarSelfDot = Instance.new("Frame", RadarFrame)
RadarSelfDot.Size = UDim2.new(0, 5, 0, 5)
RadarSelfDot.AnchorPoint = Vector2.new(0.5, 0.5)
RadarSelfDot.Position = UDim2.new(0.5, 0, 0.5, 0)
RadarSelfDot.BackgroundColor3 = Theme.Success
Instance.new("UICorner", RadarSelfDot).CornerRadius = UDim.new(1, 0)

local RadarBlipsPool = {}

-- 7. Keystrokes HUD (Индикатор клавиш W A S D)
local KeystrokesFrame = Instance.new("Frame", ScreenGui)
KeystrokesFrame.Size = UDim2.new(0, 108, 0, 72)
KeystrokesFrame.Position = UDim2.new(0, 14, 1, -86)
KeystrokesFrame.BackgroundTransparency = 1
KeystrokesFrame.Visible = false
KeystrokesFrame.ZIndex = 20

local KeyBoxes = {}
local keyDefs = {
    {k = Enum.KeyCode.W, txt = "W", x = 36, y = 0, w = 32, h = 32},
    {k = Enum.KeyCode.A, txt = "A", x = 0,  y = 36, w = 32, h = 32},
    {k = Enum.KeyCode.S, txt = "S", x = 36, y = 36, w = 32, h = 32},
    {k = Enum.KeyCode.D, txt = "D", x = 72, y = 36, w = 32, h = 32}
}
for _, kd in ipairs(keyDefs) do
    local f = Instance.new("Frame", KeystrokesFrame)
    f.Size = UDim2.new(0, kd.w, 0, kd.h)
    f.Position = UDim2.new(0, kd.x, 0, kd.y)
    f.BackgroundColor3 = Theme.BgMain
    f.BackgroundTransparency = 0.15
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
    local st = Instance.new("UIStroke", f)
    st.Color = Theme.Border
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = kd.txt
    lbl.TextColor3 = Theme.TextWhite
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    KeyBoxes[kd.k] = {frame = f, stroke = st, label = lbl}
end

UserInputService.InputBegan:Connect(function(inp, gpe)
    if not gpe and KeyBoxes[inp.KeyCode] and State.KeystrokesHUD then
        local kb = KeyBoxes[inp.KeyCode]
        QuickTween(kb.frame, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundColor3 = Theme.Accent})
        kb.label.TextColor3 = Color3.fromRGB(10, 10, 12)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if KeyBoxes[inp.KeyCode] then
        local kb = KeyBoxes[inp.KeyCode]
        QuickTween(kb.frame, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundColor3 = Theme.BgMain})
        kb.label.TextColor3 = Theme.TextWhite
    end
end)

-- 8. Watermark (Компактный FPS + Ping в левом верхнем углу)
local Watermark = Instance.new("Frame", ScreenGui)
Watermark.Size = UDim2.new(0, 265, 0, 24)
Watermark.Position = UDim2.new(0, 14, 0, 10)
Watermark.BackgroundColor3 = Theme.BgMain
Watermark.BorderSizePixel = 0
Watermark.Visible = false
Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", Watermark).Color = Theme.Border

local WmBar = Instance.new("Frame", Watermark)
WmBar.Size = UDim2.new(0, 2, 1, -8)
WmBar.Position = UDim2.new(0, 4, 0, 4)
WmBar.BackgroundColor3 = Theme.Accent
WmBar.BorderSizePixel = 0
table.insert(AccentObjects, WmBar)

local WmLabel = Instance.new("TextLabel", Watermark)
WmLabel.Size = UDim2.new(1, -14, 1, 0)
WmLabel.Position = UDim2.new(0, 10, 0, 0)
WmLabel.BackgroundTransparency = 1
WmLabel.Text = "FemboyHub V8 | @" .. LocalPlayer.Name .. " | 60 FPS"
WmLabel.TextColor3 = Theme.TextWhite
WmLabel.Font = Enum.Font.GothamBold
WmLabel.TextSize = 10
WmLabel.TextXAlignment = Enum.TextXAlignment.Left

local fpsCount, lastFpsTime = 0, tick()
Connections.WatermarkFPS = RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    if tick() - lastFpsTime >= 1 then
        local ping = 0
        SafeCall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        WmLabel.Text = string.format("FemboyHub V8 | %d FPS | %dms", fpsCount, ping)
        fpsCount = 0
        lastFpsTime = tick()
    end
end)

-------------------------------------------------------------------------
-- УМЕНЬШЕННОЕ И МАСШТАБИРУЕМОЕ ГЛАВНОЕ МЕНЮ (COMPACT & RESIZABLE UI)
-------------------------------------------------------------------------
local BASE_WIDTH = 620
local BASE_HEIGHT = 350

local MasterFrame = Instance.new("Frame", ScreenGui)
MasterFrame.Name = "MasterFrame"
MasterFrame.Size = UDim2.new(0, BASE_WIDTH, 0, BASE_HEIGHT)
MasterFrame.Position = UDim2.new(0.5, -math.floor(BASE_WIDTH / 2), 0.5, -math.floor(BASE_HEIGHT / 2) + 14)
MasterFrame.BackgroundTransparency = 1
MasterFrame.Active = true
MasterFrame.Visible = false

local MasterScale = Instance.new("UIScale", MasterFrame)
MasterScale.Scale = State.MenuScalePct / 100

local menuOpenState = true
local function SetMenuScale(pct)
    pct = math.clamp(pct, 55, 135)
    State.MenuScalePct = pct
    if menuOpenState then
        QuickTween(MasterScale, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {Scale = pct / 100})
    end
end

local function ToggleMenuAnimated()
    menuOpenState = not menuOpenState
    PlaySound(6895079853, 0.35, menuOpenState and 1.12 or 0.92)
    if menuOpenState then
        MasterFrame.Visible = true
        MasterScale.Scale = (State.MenuScalePct / 100) * 0.85
        QuickTween(MasterScale, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
            Scale = State.MenuScalePct / 100
        })
        QuickTween(PillDashBar, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(0, 18, 0, 3)
        })
        PillTitle.Text = "FemboyHub"
    else
        QuickTween(PillDashBar, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            BackgroundColor3 = Theme.TextGray,
            Size = UDim2.new(0, 12, 0, 3)
        })
        PillTitle.Text = "Open Menu"
        local tw = QuickTween(MasterScale, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In, {
            Scale = (State.MenuScalePct / 100) * 0.82
        })
        if tw then
            tw.Completed:Connect(function()
                if not menuOpenState then MasterFrame.Visible = false end
            end)
        end
    end
end

local function MakeDraggable(handle, target)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            QuickTween(target, 0.07, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            })
        end
    end)
end

-- Делаем верхнюю скруглённую кнопку-островок кликабельной и перетаскиваемой
MakeDraggable(TopIslandContainer, TopIslandContainer)
MakeDraggable(IslandIconBox, TopIslandContainer)
MakeDraggable(TargetHUD, TargetHUD)
MakeDraggable(RadarFrame, RadarFrame)
MakeDraggable(KeystrokesFrame, KeystrokesFrame)

PillButton.MouseButton1Click:Connect(function()
    SpawnRipple(PillButton, UserInputService:GetMouseLocation())
    ToggleMenuAnimated()
end)

-------------------------------------------------------------------------
-- ЛЕВОЕ ОСНОВНОЕ ОКНО МЕНЮ (КОМПАКТНОЕ + RESIZABLE)
-------------------------------------------------------------------------
local MainBox = Instance.new("Frame", MasterFrame)
MainBox.Size = UDim2.new(1, -168, 1, 0)
MainBox.BackgroundColor3 = Theme.BgMain
MainBox.BorderSizePixel = 0
Instance.new("UICorner", MainBox).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", MainBox).Color = Theme.Border

local Sidebar = Instance.new("Frame", MainBox)
Sidebar.Size = UDim2.new(0, 128, 1, 0)
Sidebar.BackgroundColor3 = Theme.BgSidebar
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)

local SidebarLine = Instance.new("Frame", Sidebar)
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, 0, 0, 0)
SidebarLine.BackgroundColor3 = Theme.Border
SidebarLine.BorderSizePixel = 0

-- Верхний блок с компактным живым маскотом
local MascotZone = Instance.new("Frame", Sidebar)
MascotZone.Size = UDim2.new(1, 0, 0, 86)
MascotZone.BackgroundTransparency = 1

local MascotArt = Instance.new("Frame", MascotZone)
MascotArt.Size = UDim2.new(0, 102, 0, 78)
MascotArt.Position = UDim2.new(0, 12, 0, 4)
MascotArt.BackgroundTransparency = 1
MascotArt.ZIndex = 8

local Tail = Instance.new("Frame", MascotArt)
Tail.Size = UDim2.new(0, 26, 0, 18)
Tail.Position = UDim2.new(0, -4, 1, -20)
Tail.BackgroundColor3 = Color3.fromRGB(245, 185, 200)
Instance.new("UICorner", Tail).CornerRadius = UDim.new(1, 0)

local HeadCircle = Instance.new("Frame", MascotArt)
HeadCircle.Size = UDim2.new(0, 30, 0, 28)
HeadCircle.Position = UDim2.new(0, 8, 0, 5)
HeadCircle.BackgroundColor3 = Color3.fromRGB(248, 248, 252)
Instance.new("UICorner", HeadCircle).CornerRadius = UDim.new(1, 0)

local EarL = Instance.new("Frame", HeadCircle)
EarL.Size = UDim2.new(0, 10, 0, 10)
EarL.Position = UDim2.new(0, 1, 0, -4)
EarL.Rotation = 35
EarL.BackgroundColor3 = Color3.fromRGB(248, 248, 252)

local EarR = Instance.new("Frame", HeadCircle)
EarR.Size = UDim2.new(0, 10, 0, 10)
EarR.Position = UDim2.new(1, -11, 0, -4)
EarR.Rotation = -35
EarR.BackgroundColor3 = Color3.fromRGB(248, 248, 252)

local FaceTxt = Instance.new("TextLabel", HeadCircle)
FaceTxt.Size = UDim2.new(1, 0, 1, 0)
FaceTxt.Position = UDim2.new(0, 0, 0, 2)
FaceTxt.BackgroundTransparency = 1
FaceTxt.Text = "• ω •"
FaceTxt.TextColor3 = Color3.fromRGB(45, 35, 50)
FaceTxt.Font = Enum.Font.GothamBold
FaceTxt.TextSize = 9

local TorsoBox = Instance.new("Frame", MascotArt)
TorsoBox.Size = UDim2.new(0, 28, 0, 26)
TorsoBox.Position = UDim2.new(0, 10, 0, 31)
TorsoBox.BackgroundColor3 = Color3.fromRGB(165, 165, 190)
Instance.new("UICorner", TorsoBox).CornerRadius = UDim.new(0, 5)

local LegsBox = Instance.new("Frame", MascotArt)
LegsBox.Size = UDim2.new(0, 40, 0, 20)
LegsBox.Position = UDim2.new(0, 34, 0, 38)
LegsBox.Rotation = -18
LegsBox.BackgroundColor3 = Color3.fromRGB(88, 56, 72)
Instance.new("UICorner", LegsBox).CornerRadius = UDim.new(0, 5)

local Laptop = Instance.new("Frame", MascotArt)
Laptop.Size = UDim2.new(0, 22, 0, 15)
Laptop.Position = UDim2.new(0, 28, 0, 28)
Laptop.Rotation = -12
Laptop.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
Instance.new("UICorner", Laptop).CornerRadius = UDim.new(0, 3)

local mascotTick = 0
Connections.MascotLive = RunService.RenderStepped:Connect(function(dt)
    if not MasterFrame.Visible or not State.MascotAliveAnim then return end
    mascotTick = mascotTick + dt * 3.2
    Tail.Rotation = math.sin(mascotTick * 1.4) * 14
    EarL.Rotation = 35 + math.sin(mascotTick * 2) * 6
    EarR.Rotation = -35 - math.cos(mascotTick * 2) * 6
    HeadCircle.Position = UDim2.new(0, 8, 0, 5 + math.sin(mascotTick) * 1.4)
    FaceTxt.Text = (math.floor(mascotTick * 2) % 19 == 0) and "- ω -" or "• ω •"
end)

local SidebarTopLine = Instance.new("Frame", Sidebar)
SidebarTopLine.Size = UDim2.new(1, 0, 0, 1)
SidebarTopLine.Position = UDim2.new(0, 0, 0, 86)
SidebarTopLine.BackgroundColor3 = Theme.Border
SidebarTopLine.BorderSizePixel = 0

local NavScroll = Instance.new("ScrollingFrame", Sidebar)
NavScroll.Size = UDim2.new(1, 0, 1, -126)
NavScroll.Position = UDim2.new(0, 0, 0, 90)
NavScroll.BackgroundTransparency = 1
NavScroll.ScrollBarThickness = 0
NavScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local NavLayout = Instance.new("UIListLayout", NavScroll)
NavLayout.Padding = UDim.new(0, 2)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    NavScroll.CanvasSize = UDim2.new(0, 0, 0, NavLayout.AbsoluteContentSize.Y + 12)
end)

-- Нижний профиль пользователя
local SidebarBotLine = Instance.new("Frame", Sidebar)
SidebarBotLine.Size = UDim2.new(1, 0, 0, 1)
SidebarBotLine.Position = UDim2.new(0, 0, 1, -36)
SidebarBotLine.BackgroundColor3 = Theme.Border
SidebarBotLine.BorderSizePixel = 0

local AvatarCircle = Instance.new("ImageLabel", Sidebar)
AvatarCircle.Size = UDim2.new(0, 24, 0, 24)
AvatarCircle.Position = UDim2.new(0, 8, 1, -30)
AvatarCircle.BackgroundColor3 = Theme.BgElement
AvatarCircle.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", AvatarCircle).CornerRadius = UDim.new(1, 0)

local ProfileDisplay = Instance.new("TextLabel", Sidebar)
ProfileDisplay.Size = UDim2.new(1, -38, 0, 13)
ProfileDisplay.Position = UDim2.new(0, 36, 1, -30)
ProfileDisplay.BackgroundTransparency = 1
ProfileDisplay.Text = LocalPlayer.DisplayName
ProfileDisplay.TextColor3 = Theme.TextWhite
ProfileDisplay.Font = Enum.Font.GothamBold
ProfileDisplay.TextSize = 10
ProfileDisplay.TextXAlignment = Enum.TextXAlignment.Left

local ProfileUser = Instance.new("TextLabel", Sidebar)
ProfileUser.Size = UDim2.new(1, -38, 0, 11)
ProfileUser.Position = UDim2.new(0, 36, 1, -18)
ProfileUser.BackgroundTransparency = 1
ProfileUser.Text = "@" .. LocalPlayer.Name
ProfileUser.TextColor3 = Theme.TextGray
ProfileUser.Font = Enum.Font.Gotham
ProfileUser.TextSize = 9
ProfileUser.TextXAlignment = Enum.TextXAlignment.Left

-- Верхняя панель с Поиском и Кнопками Масштаба [-], [+], [—]
local TopBar = Instance.new("Frame", MainBox)
TopBar.Size = UDim2.new(1, -128, 0, 32)
TopBar.Position = UDim2.new(0, 128, 0, 0)
TopBar.BackgroundTransparency = 1
MakeDraggable(TopBar, MasterFrame)
MakeDraggable(MascotZone, MasterFrame)

local TopBarLine = Instance.new("Frame", TopBar)
TopBarLine.Size = UDim2.new(1, 0, 0, 1)
TopBarLine.Position = UDim2.new(0, 0, 1, -1)
TopBarLine.BackgroundColor3 = Theme.Border
TopBarLine.BorderSizePixel = 0

local SearchBox = Instance.new("TextBox", TopBar)
SearchBox.Size = UDim2.new(1, -92, 1, -6)
SearchBox.Position = UDim2.new(0, 10, 0, 3)
SearchBox.BackgroundTransparency = 1
SearchBox.Text = ""
SearchBox.PlaceholderText = "🔍 Search modules (WallShot, Silent Aim, Packs)..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(95, 95, 110)
SearchBox.TextColor3 = Theme.TextWhite
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 11
SearchBox.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопки быстрого уменьшения/увеличения и сворачивания окна в шапке
local function CreateHeaderBtn(txt, offsetRight, callback)
    local b = Instance.new("TextButton", TopBar)
    b.Size = UDim2.new(0, 22, 0, 20)
    b.Position = UDim2.new(1, offsetRight, 0.5, -10)
    b.BackgroundColor3 = Theme.BgElement
    b.Text = txt
    b.TextColor3 = Theme.TextWhite
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local st = Instance.new("UIStroke", b)
    st.Color = Theme.Border
    BindInteractiveHover(b, st, nil, nil)
    b.MouseButton1Click:Connect(function()
        SpawnRipple(b, UserInputService:GetMouseLocation())
        callback()
    end)
    return b
end

CreateHeaderBtn("−", -76, function()
    SetMenuScale(State.MenuScalePct - 10)
    if SliderSetters["MenuScalePct"] then SliderSetters["MenuScalePct"](State.MenuScalePct) end
    Notify("UI Scale", "Menu scale: " .. State.MenuScalePct .. "%", 1.2)
end)

CreateHeaderBtn("+", -51, function()
    SetMenuScale(State.MenuScalePct + 10)
    if SliderSetters["MenuScalePct"] then SliderSetters["MenuScalePct"](State.MenuScalePct) end
    Notify("UI Scale", "Menu scale: " .. State.MenuScalePct .. "%", 1.2)
end)

CreateHeaderBtn("—", -26, function()
    ToggleMenuAnimated()
end)

-------------------------------------------------------------------------
-- РАБОЧАЯ ОБЛАСТЬ + ФОНОВОЕ СОЗВЕЗДИЕ (PLEXUS CONSTELLATION)
-------------------------------------------------------------------------
local ContentArea = Instance.new("Frame", MainBox)
ContentArea.Size = UDim2.new(1, -128, 1, -32)
ContentArea.Position = UDim2.new(0, 128, 0, 32)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true

local PlexusLayer = Instance.new("Frame", ContentArea)
PlexusLayer.Size = UDim2.new(1, 0, 1, 0)
PlexusLayer.BackgroundTransparency = 1
PlexusLayer.ZIndex = 1

local PlexusNodes = {}
local NUM_PLEXUS = 11
for i = 1, NUM_PLEXUS do
    local pDot = Instance.new("Frame", PlexusLayer)
    pDot.Size = UDim2.new(0, 3, 0, 3)
    pDot.AnchorPoint = Vector2.new(0.5, 0.5)
    pDot.BackgroundColor3 = Theme.Accent
    pDot.BorderSizePixel = 0
    Instance.new("UICorner", pDot).CornerRadius = UDim.new(1, 0)
    table.insert(AccentObjects, pDot)
    table.insert(PlexusNodes, {
        ui = pDot,
        x = math.random(20, 300),
        y = math.random(40, 290),
        vx = (math.random() - 0.5) * 32,
        vy = (math.random() - 0.5) * 32
    })
end

local PlexusLines = {}
for i = 1, 28 do
    local pLine = Instance.new("Frame", PlexusLayer)
    pLine.AnchorPoint = Vector2.new(0.5, 0.5)
    pLine.BackgroundColor3 = Theme.Accent
    pLine.BorderSizePixel = 0
    pLine.Visible = false
    table.insert(AccentObjects, pLine)
    table.insert(PlexusLines, pLine)
end

Connections.PlexusAnim = RunService.RenderStepped:Connect(function(dt)
    if not MasterFrame.Visible then return end
    local maxW = math.max(ContentArea.AbsoluteSize.X, 240)
    local maxH = math.max(ContentArea.AbsoluteSize.Y, 220)
    for _, n in ipairs(PlexusNodes) do
        n.x = n.x + n.vx * dt
        n.y = n.y + n.vy * dt
        if n.x < 10 or n.x > (maxW - 10) then n.vx = -n.vx end
        if n.y < 20 or n.y > (maxH - 10) then n.vy = -n.vy end
        n.ui.Position = UDim2.new(0, n.x, 0, n.y)
    end
    local idx = 1
    for i = 1, NUM_PLEXUS do
        for j = i + 1, NUM_PLEXUS do
            local dx = PlexusNodes[j].x - PlexusNodes[i].x
            local dy = PlexusNodes[j].y - PlexusNodes[i].y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist < 120 and idx <= #PlexusLines then
                local l = PlexusLines[idx]
                l.Visible = true
                l.Position = UDim2.new(0, (PlexusNodes[i].x + PlexusNodes[j].x) / 2, 0, (PlexusNodes[i].y + PlexusNodes[j].y) / 2)
                l.Size = UDim2.new(0, dist, 0, 1)
                l.Rotation = math.deg(math.atan2(dy, dx))
                l.BackgroundTransparency = math.clamp(dist / 120, 0.2, 0.92)
                idx = idx + 1
            end
        end
    end
    for k = idx, #PlexusLines do
        PlexusLines[k].Visible = false
    end
end)

-- Уголок изменения размера окна (Bottom-Right Resize Handle ◢)
local ResizeHandle = Instance.new("TextButton", MainBox)
ResizeHandle.Size = UDim2.new(0, 18, 0, 18)
ResizeHandle.Position = UDim2.new(1, -18, 1, -18)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Text = "◢"
ResizeHandle.TextColor3 = Theme.TextGray
ResizeHandle.Font = Enum.Font.GothamBold
ResizeHandle.TextSize = 12
ResizeHandle.ZIndex = 20

local resizingUI = false
local resizeStartPos, resizeStartSize
ResizeHandle.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        resizingUI = true
        resizeStartPos = inp.Position
        resizeStartSize = MasterFrame.Size
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then resizingUI = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if resizingUI and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = inp.Position - resizeStartPos
        local newW = math.clamp(resizeStartSize.X.Offset + delta.X, 500, 880)
        local newH = math.clamp(resizeStartSize.Y.Offset + delta.Y, 270, 540)
        MasterFrame.Size = UDim2.new(0, newW, 0, newH)
    end
end)

-------------------------------------------------------------------------
-- ПРАВОЕ ОКНО 3D-ПРЕВЬЮ ПЕРСОНАЖА (ИНТЕРАКТИВНОЕ ВРАЩЕНИЕ)
-------------------------------------------------------------------------
local PreviewBox = Instance.new("Frame", MasterFrame)
PreviewBox.Size = UDim2.new(0, 160, 1, 0)
PreviewBox.Position = UDim2.new(1, -160, 0, 0)
PreviewBox.BackgroundColor3 = Theme.BgMain
PreviewBox.BorderSizePixel = 0
Instance.new("UICorner", PreviewBox).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", PreviewBox).Color = Theme.Border

local PreviewTop = Instance.new("Frame", PreviewBox)
PreviewTop.Size = UDim2.new(1, 0, 0, 32)
PreviewTop.BackgroundTransparency = 1
MakeDraggable(PreviewTop, MasterFrame)

local PreviewTopLine = Instance.new("Frame", PreviewTop)
PreviewTopLine.Size = UDim2.new(1, 0, 0, 1)
PreviewTopLine.Position = UDim2.new(0, 0, 1, -1)
PreviewTopLine.BackgroundColor3 = Theme.Border
PreviewTopLine.BorderSizePixel = 0

local PreviewTitle = Instance.new("TextLabel", PreviewTop)
PreviewTitle.Size = UDim2.new(0.55, 0, 1, 0)
PreviewTitle.Position = UDim2.new(0, 8, 0, 0)
PreviewTitle.BackgroundTransparency = 1
PreviewTitle.Text = "👤 Preview"
PreviewTitle.TextColor3 = Theme.TextWhite
PreviewTitle.Font = Enum.Font.GothamBold
PreviewTitle.TextSize = 10
PreviewTitle.TextXAlignment = Enum.TextXAlignment.Left

local RefreshNowBtn = Instance.new("TextButton", PreviewTop)
RefreshNowBtn.Size = UDim2.new(0, 68, 0, 20)
RefreshNowBtn.Position = UDim2.new(1, -74, 0.5, -10)
RefreshNowBtn.BackgroundTransparency = 1
RefreshNowBtn.Text = "↻ Refresh"
RefreshNowBtn.TextColor3 = Theme.Accent
RefreshNowBtn.Font = Enum.Font.GothamBold
RefreshNowBtn.TextSize = 10
RefreshNowBtn.TextXAlignment = Enum.TextXAlignment.Right

local PreviewESPLabel = Instance.new("TextLabel", PreviewBox)
PreviewESPLabel.Size = UDim2.new(1, 0, 0, 18)
PreviewESPLabel.Position = UDim2.new(0, 0, 0, 42)
PreviewESPLabel.BackgroundTransparency = 1
PreviewESPLabel.Text = LocalPlayer.DisplayName
PreviewESPLabel.TextColor3 = Color3.fromRGB(165, 195, 235)
PreviewESPLabel.Font = Enum.Font.Code
PreviewESPLabel.TextSize = 12
PreviewESPLabel.ZIndex = 5

local Viewport = Instance.new("ViewportFrame", PreviewBox)
Viewport.Size = UDim2.new(1, -10, 1, -38)
Viewport.Position = UDim2.new(0, 5, 0, 34)
Viewport.BackgroundTransparency = 1
Viewport.Ambient = Color3.fromRGB(220, 220, 225)
Viewport.LightColor = Color3.fromRGB(255, 255, 255)

local ViewCam = Instance.new("Camera", Viewport)
Viewport.CurrentCamera = ViewCam
local ViewportClone = nil

local function Refresh3DPreview()
    SafeCall(function()
        Viewport:ClearAllChildren()
        local char = LocalPlayer.Character
        if not char then return end
        char.Archivable = true
        local clone = char:Clone()
        for _, obj in ipairs(clone:GetDescendants()) do
            if obj:IsA("LocalScript") or obj:IsA("Script") then obj:Destroy() end
        end
        clone.Parent = Viewport
        ViewportClone = clone
    end)
end
task.spawn(Refresh3DPreview)

RefreshNowBtn.MouseButton1Click:Connect(function()
    Refresh3DPreview()
    Notify("3D Preview", "Character model updated!", 1.4)
end)

local previewAngle = 0
Connections.PreviewCamera = RunService.RenderStepped:Connect(function(dt)
    if MasterFrame.Visible and PreviewBox.Visible and ViewportClone and ViewportClone:FindFirstChild("HumanoidRootPart") then
        previewAngle = previewAngle + dt * 0.6
        local hrp = ViewportClone.HumanoidRootPart
        local camPos = hrp.Position + Vector3.new(math.cos(previewAngle) * 4.8, -0.15, math.sin(previewAngle) * 4.8)
        ViewCam.CFrame = CFrame.new(camPos, hrp.Position + Vector3.new(0, -0.15, 0))
    end
end)

-------------------------------------------------------------------------
-- УМНЫЙ UI БИЛДЕР (С ПОДДЕРЖКОЙ КОНФИГОВ ДЛЯ ЧЕКБОКСОВ, СЛАЙДЕРОВ И СПИСКОВ)
-------------------------------------------------------------------------
local AllPages = {}
local ActiveBars = {}
local ActiveLabels = {}

local function CreatePage(pageName, isDefault)
    local Page = Instance.new("ScrollingFrame", ContentArea)
    Page.Name = pageName
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.Visible = isDefault or false
    Page.ZIndex = 2

    local LeftCol = Instance.new("Frame", Page)
    LeftCol.Size = UDim2.new(0.5, -12, 1, 0)
    LeftCol.Position = UDim2.new(0, 8, 0, 8)
    LeftCol.BackgroundTransparency = 1
    local LeftLayout = Instance.new("UIListLayout", LeftCol)
    LeftLayout.Padding = UDim.new(0, 8)
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local RightCol = Instance.new("Frame", Page)
    RightCol.Size = UDim2.new(0.5, -12, 1, 0)
    RightCol.Position = UDim2.new(0.5, 4, 0, 8)
    RightCol.BackgroundTransparency = 1
    local RightLayout = Instance.new("UIListLayout", RightCol)
    RightLayout.Padding = UDim.new(0, 8)
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function RecalcCanvas()
        local maxH = math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y)
        Page.CanvasSize = UDim2.new(0, 0, 0, maxH + 28)
    end
    LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RecalcCanvas)
    RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RecalcCanvas)

    local pObj = {Page = Page, Left = LeftCol, Right = RightCol}
    table.insert(AllPages, pObj)
    return pObj
end

local function SwitchToPage(pageObj, barIndicator, labelObj)
    for _, p in ipairs(AllPages) do p.Page.Visible = false end
    for _, b in ipairs(ActiveBars) do b.Visible = false end
    for _, l in ipairs(ActiveLabels) do
        QuickTween(l, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextColor3 = Theme.TextGray})
    end
    pageObj.Page.Visible = true
    if State.UITabSlide then
        pageObj.Left.Position = UDim2.new(0, 8, 0, 22)
        pageObj.Right.Position = UDim2.new(0.5, 4, 0, 22)
        QuickTween(pageObj.Left, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {Position = UDim2.new(0, 8, 0, 8)})
        QuickTween(pageObj.Right, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {Position = UDim2.new(0.5, 4, 0, 8)})
    end
    if barIndicator then
        barIndicator.Visible = true
        barIndicator.Size = UDim2.new(0, 2, 0, 2)
        QuickTween(barIndicator, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Size = UDim2.new(0, 2, 0, 14)})
    end
    if labelObj then
        QuickTween(labelObj, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextColor3 = Theme.TextWhite})
    end
end

local function CreateNavCategory(icon, title, subTabsList, defaultPageObj)
    local Wrapper = Instance.new("Frame", NavScroll)
    Wrapper.Size = UDim2.new(1, 0, 0, 26)
    Wrapper.BackgroundTransparency = 1
    Wrapper.ClipsDescendants = true

    local MainBtn = Instance.new("TextButton", Wrapper)
    MainBtn.Size = UDim2.new(1, 0, 0, 26)
    MainBtn.BackgroundTransparency = 1
    MainBtn.Text = ""

    local Bar = Instance.new("Frame", MainBtn)
    Bar.Size = UDim2.new(0, 2, 0, 14)
    Bar.Position = UDim2.new(0, 0, 0.5, -7)
    Bar.BackgroundColor3 = Theme.Accent
    Bar.BorderSizePixel = 0
    Bar.Visible = (defaultPageObj ~= nil and defaultPageObj.Page.Visible)
    table.insert(AccentObjects, Bar)
    table.insert(ActiveBars, Bar)

    local Lbl = Instance.new("TextLabel", MainBtn)
    Lbl.Size = UDim2.new(1, -24, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = icon .. " " .. title
    Lbl.TextColor3 = Bar.Visible and Theme.TextWhite or Theme.TextGray
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 10
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(ActiveLabels, Lbl)

    BindInteractiveHover(MainBtn, nil, Lbl, 10)

    if subTabsList and #subTabsList > 0 then
        local Chev = Instance.new("TextLabel", MainBtn)
        Chev.Size = UDim2.new(0, 16, 1, 0)
        Chev.Position = UDim2.new(1, -18, 0, 0)
        Chev.BackgroundTransparency = 1
        Chev.Text = "⌄"
        Chev.TextColor3 = Theme.TextGray
        Chev.Font = Enum.Font.GothamBold
        Chev.TextSize = 11

        local SubHolder = Instance.new("Frame", Wrapper)
        SubHolder.Size = UDim2.new(1, 0, 0, #subTabsList * 22)
        SubHolder.Position = UDim2.new(0, 0, 0, 26)
        SubHolder.BackgroundTransparency = 1
        local SubLayout = Instance.new("UIListLayout", SubHolder)
        SubLayout.SortOrder = Enum.SortOrder.LayoutOrder

        for _, sub in ipairs(subTabsList) do
            local SubBtn = Instance.new("TextButton", SubHolder)
            SubBtn.Size = UDim2.new(1, 0, 0, 22)
            SubBtn.BackgroundTransparency = 1
            SubBtn.Text = ""

            local SubBar = Instance.new("Frame", SubBtn)
            SubBar.Size = UDim2.new(0, 2, 0, 10)
            SubBar.Position = UDim2.new(0, 5, 0.5, -5)
            SubBar.BackgroundColor3 = Theme.Accent
            SubBar.BorderSizePixel = 0
            SubBar.Visible = false
            table.insert(AccentObjects, SubBar)
            table.insert(ActiveBars, SubBar)

            local SubLbl = Instance.new("TextLabel", SubBtn)
            SubLbl.Size = UDim2.new(1, -20, 1, 0)
            SubLbl.Position = UDim2.new(0, 16, 0, 0)
            SubLbl.BackgroundTransparency = 1
            SubLbl.Text = sub.Name
            SubLbl.TextColor3 = Theme.TextGray
            SubLbl.Font = Enum.Font.GothamBold
            SubLbl.TextSize = 9
            SubLbl.TextXAlignment = Enum.TextXAlignment.Left
            table.insert(ActiveLabels, SubLbl)

            BindInteractiveHover(SubBtn, nil, SubLbl, 16)

            SubBtn.MouseButton1Click:Connect(function()
                SpawnRipple(SubBtn, UserInputService:GetMouseLocation())
                SwitchToPage(sub.PageObj, SubBar, SubLbl)
            end)
        end

        local expanded = false
        MainBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            Chev.Text = expanded and "^" or "⌄"
            QuickTween(Wrapper, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
                Size = UDim2.new(1, 0, 0, expanded and (26 + #subTabsList * 22) or 26)
            })
            if subTabsList[1] then
                SwitchToPage(subTabsList[1].PageObj, Bar, Lbl)
            end
        end)
    else
        MainBtn.MouseButton1Click:Connect(function()
            SpawnRipple(MainBtn, UserInputService:GetMouseLocation())
            SwitchToPage(defaultPageObj, Bar, Lbl)
        end)
    end
end

local function CreateCard(pageObj, side, titleText, hasCollapseArrow)
    local parentCol = (side == "Left") and pageObj.Left or pageObj.Right

    local Card = Instance.new("Frame", parentCol)
    Card.Size = UDim2.new(1, 0, 0, 34)
    Card.BackgroundColor3 = Theme.BgCard
    Card.BorderSizePixel = 0
    Card.ClipsDescendants = true
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 5)
    local CardStroke = Instance.new("UIStroke", Card)
    CardStroke.Color = Theme.Border

    local HeaderBtn = Instance.new("TextButton", Card)
    HeaderBtn.Size = UDim2.new(1, 0, 0, 24)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = ""

    local Title = Instance.new("TextLabel", HeaderBtn)
    Title.Size = UDim2.new(1, -24, 1, 0)
    Title.Position = UDim2.new(0, 8, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Theme.TextWhite
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 10
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local ArrowLbl = nil
    if hasCollapseArrow then
        ArrowLbl = Instance.new("TextLabel", HeaderBtn)
        ArrowLbl.Size = UDim2.new(0, 18, 1, 0)
        ArrowLbl.Position = UDim2.new(1, -20, 0, 0)
        ArrowLbl.BackgroundTransparency = 1
        ArrowLbl.Text = "^"
        ArrowLbl.TextColor3 = Theme.TextGray
        ArrowLbl.Font = Enum.Font.GothamBold
        ArrowLbl.TextSize = 11
    end

    local SepLine = Instance.new("Frame", Card)
    SepLine.Size = UDim2.new(1, -12, 0, 1)
    SepLine.Position = UDim2.new(0, 6, 0, 24)
    SepLine.BackgroundColor3 = Theme.Border
    SepLine.BorderSizePixel = 0

    local Body = Instance.new("Frame", Card)
    Body.Size = UDim2.new(1, -12, 0, 8)
    Body.Position = UDim2.new(0, 6, 0, 29)
    Body.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout", Body)
    Layout.Padding = UDim.new(0, 5)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local collapsed = false
    local function UpdateHeight()
        Body.Size = UDim2.new(1, -12, 0, Layout.AbsoluteContentSize.Y)
        if not collapsed then
            Card.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y + 36)
        end
    end
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateHeight)

    if hasCollapseArrow then
        HeaderBtn.MouseButton1Click:Connect(function()
            collapsed = not collapsed
            ArrowLbl.Text = collapsed and "⌄" or "^"
            QuickTween(Card, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
                Size = UDim2.new(1, 0, 0, collapsed and 24 or (Layout.AbsoluteContentSize.Y + 36))
            })
        end)
    end

    return Body
end

local function AddCheckbox(cardBody, stateKey, labelText, callback)
    local Row = Instance.new("TextButton", cardBody)
    Row.Name = labelText
    Row.Size = UDim2.new(1, 0, 0, 20)
    Row.BackgroundTransparency = 1
    Row.Text = ""

    local Box = Instance.new("Frame", Row)
    Box.Size = UDim2.new(0, 13, 0, 13)
    Box.Position = UDim2.new(0, 2, 0.5, -6)
    Box.BackgroundColor3 = State[stateKey] and Theme.Accent or Theme.BgElement
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 3)
    local BoxStroke = Instance.new("UIStroke", Box)
    BoxStroke.Color = Theme.Border

    local Check = Instance.new("TextLabel", Box)
    Check.Size = UDim2.new(1, 0, 1, 0)
    Check.BackgroundTransparency = 1
    Check.Text = State[stateKey] and "✓" or ""
    Check.TextColor3 = Color3.fromRGB(8, 8, 10)
    Check.Font = Enum.Font.GothamBold
    Check.TextSize = 10

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Size = UDim2.new(1, -20, 1, 0)
    Lbl.Position = UDim2.new(0, 19, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = labelText
    Lbl.TextColor3 = Theme.TextWhite
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 10
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    BindInteractiveHover(Row, BoxStroke, Lbl, 19)

    local function SetVal(newVal, silent)
        State[stateKey] = newVal
        QuickTween(Box, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            BackgroundColor3 = newVal and Theme.Accent or Theme.BgElement
        })
        Check.Text = newVal and "✓" or ""
        UpdateArrayList(labelText, newVal)
        if not silent then
            PlaySound(6895079853, 0.25, newVal and 1.15 or 0.9)
            Notify(labelText, newVal and "Enabled [ON]" or "Disabled [OFF]", 1.5)
        end
        if callback then task.spawn(function() SafeCall(callback, newVal) end) end
    end

    ToggleSetters[stateKey] = SetVal
    Row.MouseButton1Click:Connect(function()
        SpawnRipple(Row, UserInputService:GetMouseLocation())
        SetVal(not State[stateKey], false)
    end)

    table.insert(AllSearchRows, Row)
end

local function AddSlider(cardBody, stateKey, labelText, minVal, maxVal, callback)
    local Row = Instance.new("Frame", cardBody)
    Row.Name = labelText
    Row.Size = UDim2.new(1, 0, 0, 30)
    Row.BackgroundTransparency = 1

    local TopLbl = Instance.new("TextLabel", Row)
    TopLbl.Size = UDim2.new(1, 0, 0, 13)
    TopLbl.BackgroundTransparency = 1
    TopLbl.Text = labelText .. ": " .. tostring(State[stateKey])
    TopLbl.TextColor3 = Theme.TextGray
    TopLbl.Font = Enum.Font.GothamBold
    TopLbl.TextSize = 9
    TopLbl.TextXAlignment = Enum.TextXAlignment.Left

    local Track = Instance.new("TextButton", Row)
    Track.Size = UDim2.new(1, 0, 0, 7)
    Track.Position = UDim2.new(0, 0, 0, 17)
    Track.BackgroundColor3 = Theme.BgElement
    Track.Text = ""
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    local TrackStroke = Instance.new("UIStroke", Track)
    TrackStroke.Color = Theme.Border

    local initPct = math.clamp((State[stateKey] - minVal) / (maxVal - minVal), 0, 1)
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new(initPct, 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    table.insert(AccentObjects, Fill)

    BindInteractiveHover(Track, TrackStroke, nil, nil)

    local function SetSliderValue(val, silent)
        val = math.clamp(math.floor(tonumber(val) or minVal), minVal, maxVal)
        State[stateKey] = val
        local relX = math.clamp((val - minVal) / (maxVal - minVal), 0, 1)
        QuickTween(Fill, 0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {Size = UDim2.new(relX, 0, 1, 0)})
        TopLbl.Text = labelText .. ": " .. tostring(val)
        if callback and not silent then
            task.spawn(function() SafeCall(callback, val) end)
        end
    end

    SliderSetters[stateKey] = SetSliderValue

    local sliding = false
    local function UpdateFromInput(input)
        local relX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * relX)
        SetSliderValue(val, false)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            UpdateFromInput(input)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then sliding = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateFromInput(input)
        end
    end)

    table.insert(AllSearchRows, Row)
end

-- Циклическая кнопка выбора режима (Dropdown Selector) с сохранением в конфиг
local function AddSelector(cardBody, stateKey, labelText, optionsList, callback)
    local Btn = Instance.new("TextButton", cardBody)
    Btn.Name = labelText
    Btn.Size = UDim2.new(1, 0, 0, 23)
    Btn.BackgroundColor3 = Theme.BgElement
    Btn.Text = labelText .. ": [" .. tostring(State[stateKey]) .. "]"
    Btn.TextColor3 = Theme.TextWhite
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Color = Theme.Border

    BindInteractiveHover(Btn, BtnStroke, nil, nil)

    local curIndex = 1
    for i, opt in ipairs(optionsList) do
        if opt == State[stateKey] then curIndex = i break end
    end

    local function SetOption(newOpt, silent)
        State[stateKey] = newOpt
        Btn.Text = labelText .. ": [" .. tostring(newOpt) .. "]"
        if not silent then
            Notify(labelText, "Selected: " .. tostring(newOpt), 1.4)
        end
        if callback then task.spawn(function() SafeCall(callback, newOpt) end) end
    end

    DropdownSetters[stateKey] = SetOption

    Btn.MouseButton1Click:Connect(function()
        SpawnRipple(Btn, UserInputService:GetMouseLocation())
        curIndex = (curIndex % #optionsList) + 1
        SetOption(optionsList[curIndex], false)
    end)

    table.insert(AllSearchRows, Btn)
end

local function AddButton(cardBody, labelText, callback)
    local Btn = Instance.new("TextButton", cardBody)
    Btn.Name = labelText
    Btn.Size = UDim2.new(1, 0, 0, 23)
    Btn.BackgroundColor3 = Theme.BgElement
    Btn.Text = labelText
    Btn.TextColor3 = Theme.TextWhite
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Color = Theme.Border

    Btn.MouseEnter:Connect(function()
        if State.UIHoverGlow then
            QuickTween(Btn, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundColor3 = Theme.BgElementHover})
            QuickTween(BtnStroke, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Color = Theme.Accent})
        end
    end)
    Btn.MouseLeave:Connect(function()
        QuickTween(Btn, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundColor3 = Theme.BgElement})
        QuickTween(BtnStroke, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Color = Theme.Border})
    end)

    Btn.MouseButton1Click:Connect(function()
        SpawnRipple(Btn, UserInputService:GetMouseLocation())
        task.spawn(function() SafeCall(callback) end)
    end)

    table.insert(AllSearchRows, Btn)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(SearchBox.Text)
    for _, row in ipairs(AllSearchRows) do
        row.Visible = (q == "") or (string.find(string.lower(row.Name), q) ~= nil)
    end
end)

-------------------------------------------------------------------------
-- ИНИЦИАЛИЗАЦИЯ ВСЕХ СТРАНИЦ МЕНЮ
-------------------------------------------------------------------------
local PageCombatAim    = CreatePage("CombatAim", false)
local PageCombatSilent = CreatePage("CombatSilent", false)
local PageCombatBypass = CreatePage("CombatBypass", false)

local PageVisShaders   = CreatePage("VisShaders", false)
local PageVis3DAuras   = CreatePage("Vis3DAuras", false)
local PageVisTrails    = CreatePage("VisTrails", false)
local PageVisESP       = CreatePage("VisESP", false)

local PageMiscMove     = CreatePage("MiscMove", false)
local PageMiscPacks    = CreatePage("MiscPacks", false)
local PageMiscEmotes   = CreatePage("MiscEmotes", false)
local PageMiscTarget   = CreatePage("MiscTarget", false)

local PageColors       = CreatePage("Colors", false)
local PageSettings     = CreatePage("Settings", true)

CreateNavCategory("🎯", "COMBAT", {
    {Name = "• Camera Aimbot", PageObj = PageCombatAim},
    {Name = "• Silent & WallShot", PageObj = PageCombatSilent},
    {Name = "• Bypass V2 & Hitbox", PageObj = PageCombatBypass}
}, nil)

CreateNavCategory("👁", "VISUALS", {
    {Name = "• Shaders & Sky (12)", PageObj = PageVisShaders},
    {Name = "• 3D Auras & Gear", PageObj = PageVis3DAuras},
    {Name = "• Trails & Weather", PageObj = PageVisTrails},
    {Name = "• ESP & Radar 2D", PageObj = PageVisESP}
}, nil)

CreateNavCategory("⚙", "MISC", {
    {Name = "• Movement & Fly", PageObj = PageMiscMove},
    {Name = "• R15 Anim Packs (16)", PageObj = PageMiscPacks},
    {Name = "• Emotes & Tricks", PageObj = PageMiscEmotes},
    {Name = "• Desync & Target", PageObj = PageMiscTarget}
}, nil)

CreateNavCategory("🎨", "COLORS", nil, PageColors)
CreateNavCategory("🔧", "SETTINGS", nil, PageSettings)

-------------------------------------------------------------------------
-- [ PART 3 / 5 : WALLSHOT, SILENT AIM, BYPASS V2 & REAL CONFIG SYSTEM ]
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- 1. НОВЫЙ ОБХОД АНТИЧИТА (ANTI-CHEAT BYPASS V2 & METAMETHOD SPOOFER)
-------------------------------------------------------------------------
local BypassInstalled = false
local function SetupAntiCheatBypassV2()
    if BypassInstalled then return end
    BypassInstalled = true

    SafeCall(function()
        if not hookmetamethod or not getnamecallmethod then return end

        -- Перехват __index для скрытия изменённых Хитбоксов, WalkSpeed и JumpPower от античита игры
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", function(self, key)
            if not checkcaller() then
                if key == "Size" and State.BypassSizeSpoof and typeof(self) == "Instance" and self:IsA("BasePart") then
                    if self.Name == "HumanoidRootPart" then
                        return Vector3.new(2, 2, 1)
                    elseif self.Name == "Head" then
                        return Vector3.new(2, 1, 1)
                    end
                elseif (key == "WalkSpeed" or key == "JumpPower") and State.BypassSpeedSpoof and typeof(self) == "Instance" and self:IsA("Humanoid") then
                    if key == "WalkSpeed" then return 16 end
                    if key == "JumpPower" then return 50 end
                elseif (key == "Hit" or key == "Target") and State.SilentAimEnabled and self == Mouse and CurrentTargetPart then
                    if math.random(1, 100) <= State.SilentAimHitChance then
                        if key == "Hit" then
                            local pred = Vector3.zero
                            if State.AimbotPrediction and CurrentTargetPart.Parent:FindFirstChild("HumanoidRootPart") then
                                pred = CurrentTargetPart.Parent.HumanoidRootPart.Velocity * (State.AimbotPredictVal / 100)
                            end
                            return CFrame.new(CurrentTargetPart.Position + pred)
                        elseif key == "Target" then
                            return CurrentTargetPart
                        end
                    end
                end
            end
            return oldIndex(self, key)
        end)

        -- Перехват __namecall для Silent Aim (Raycast / FindPartOnRay), WallShot и защиты от Kick
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if not checkcaller() then
                -- Защита от клиентского Kick
                if (method == "Kick" or method == "kick") and State.BypassAntiKick and self == LocalPlayer then
                    return nil
                end

                -- Перехват лучей выстрела для Silent Aim + WallShot
                if State.SilentAimEnabled and CurrentTargetPart and math.random(1, 100) <= State.SilentAimHitChance then
                    if self == Workspace and (method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") then
                        local pred = Vector3.zero
                        if State.AimbotPrediction and CurrentTargetPart.Parent:FindFirstChild("HumanoidRootPart") then
                            pred = CurrentTargetPart.Parent.HumanoidRootPart.Velocity * (State.AimbotPredictVal / 100)
                        end
                        local targetPos = CurrentTargetPart.Position + pred

                        if method == "Raycast" and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                            local origin = args[1]
                            args[2] = (targetPos - origin).Unit * math.max(args[2].Magnitude, (targetPos - origin).Magnitude + 15)
                            if State.WallShotEnabled and CurrentAimbotTarget and CurrentAimbotTarget.Character then
                                local rp = RaycastParams.new()
                                rp.FilterType = Enum.RaycastFilterType.Include
                                rp.FilterDescendantsInstances = {CurrentAimbotTarget.Character}
                                args[3] = rp
                            end
                            return oldNamecall(self, unpack(args))
                        elseif (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") and typeof(args[1]) == "Ray" then
                            local origin = args[1].Origin
                            local dir = (targetPos - origin).Unit * math.max(args[1].Direction.Magnitude, (targetPos - origin).Magnitude + 15)
                            args[1] = Ray.new(origin, dir)
                            return oldNamecall(self, unpack(args))
                        end
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
end
task.spawn(SetupAntiCheatBypassV2)

-------------------------------------------------------------------------
-- 2. ЯДРО COMBAT: ПОИСК ЦЕЛИ, WALLSHOT PIERCER, SILENT AIM & HITBOXES
-------------------------------------------------------------------------
local function GetTargetBone(char)
    if not char then return nil end
    if State.AimbotHitPart == "Head" and char:FindFirstChild("Head") then
        return char.Head
    elseif State.AimbotHitPart == "Random" then
        if math.random(1, 100) <= State.SilentAimHeadshotRate and char:FindFirstChild("Head") then
            return char.Head
        end
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Head")
    end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
end

local function IsTargetVisible(targetPart, targetChar)
    -- Если включён WallShot, стены игнорируются!
    if State.WallShotEnabled or not State.AimbotWallCheck then return true end
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {myChar, Camera}
    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin)
    local result = Workspace:Raycast(origin, dir, params)
    if not result then return true end
    return result.Instance:IsDescendantOf(targetChar)
end

-- Физический пробиватель стен (WallShot Piercer) — работает даже без хуков на любых телефонах!
local function ProcessWallShotTunnel(targetPart, targetChar)
    RestoreWallShotParts()
    if not State.WallShotEnabled or not targetPart or not targetChar then
        WallShotBadge.Visible = false
        return
    end
    local myChar = LocalPlayer.Character
    if not myChar then return end

    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin)
    local excludeList = {myChar, targetChar, Camera}
    local piercedCount = 0

    for _ = 1, State.WallShotMaxWalls do
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = excludeList
        local hit = Workspace:Raycast(origin, dir, rp)
        if hit and hit.Instance and hit.Instance:IsA("BasePart") and hit.Instance.Name ~= "Terrain" then
            local part = hit.Instance
            if WallShotModifiedParts[part] == nil then
                WallShotModifiedParts[part] = part.CanQuery
            end
            part.CanQuery = false
            table.insert(excludeList, part)
            piercedCount = piercedCount + 1
        else
            break
        end
    end
    WallShotBadge.Visible = (piercedCount > 0)
    if piercedCount > 0 then
        WallShotBadge.Text = string.format("⚡ WALLSHOT (%d WALLS)", piercedCount)
    end
end

local function GetClosestPlayerInFOV()
    local bestPlr = nil
    local bestPart = nil
    local useRadius = (State.ShowFOVCircle or State.SilentAimUseFOV) and State.AimbotFOV or 9999
    local shortestDist = useRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local bone = GetTargetBone(plr.Character)
            local teamOk = (not State.AimbotTeamCheck) or (plr.Team ~= LocalPlayer.Team)
            local aliveOk = (not State.AimbotAliveCheck) or (hum and hum.Health > 0)

            if bone and teamOk and aliveOk then
                local screenPos, onScreen = Camera:WorldToViewportPoint(bone.Position)
                if onScreen then
                    local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist2D <= shortestDist and IsTargetVisible(bone, plr.Character) then
                        shortestDist = dist2D
                        bestPlr = plr
                        bestPart = bone
                    end
                end
            end
        end
    end
    return bestPlr, bestPart
end

-- Безопасный пул для 2D Радара
local function Update2DRadar()
    RadarFrame.Visible = State.Radar2D
    if not State.Radar2D then return end
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end

    local camLook = Camera.CFrame.LookVector
    local camYaw = math.atan2(-camLook.X, -camLook.Z)

    local activePlrs = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            activePlrs[plr] = true
            local blip = RadarBlipsPool[plr]
            if not blip then
                blip = Instance.new("Frame", RadarFrame)
                blip.Size = UDim2.new(0, 5, 0, 5)
                blip.AnchorPoint = Vector2.new(0.5, 0.5)
                blip.BackgroundColor3 = Theme.Danger
                Instance.new("UICorner", blip).CornerRadius = UDim.new(1, 0)
                RadarBlipsPool[plr] = blip
            end
            local rel = plr.Character.HumanoidRootPart.Position - myHrp.Position
            local dist = math.clamp(Vector2.new(rel.X, rel.Z).Magnitude * 0.45, 0, 48)
            local ang = math.atan2(rel.X, rel.Z) - camYaw
            local rx = math.sin(ang) * dist
            local ry = -math.cos(ang) * dist
            blip.Position = UDim2.new(0.5, rx, 0.5, ry)
            blip.BackgroundColor3 = (plr == CurrentAimbotTarget) and Theme.Accent or Theme.Danger
            blip.Visible = true
        end
    end
    for plr, blip in pairs(RadarBlipsPool) do
        if not activePlrs[plr] then
            blip.Visible = false
        end
    end
end

-- Главный боевой цикл (RenderStepped) с защитой от вылетов
local crossAngle = 0
local strafeAngle = 0
Connections.MasterCombatLoop = RunService.RenderStepped:Connect(function(dt)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- 1. Круг FOV
    FOVCircleFrame.Visible = State.ShowFOVCircle
    if State.ShowFOVCircle then
        FOVCircleFrame.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
        FOVCircleFrame.Size = UDim2.new(0, State.AimbotFOV * 2, 0, State.AimbotFOV * 2)
        FOVCircleFrame.BackgroundTransparency = State.FilledFOVCircle and 0.88 or 1
        if State.RainbowFOV then
            local rCol = Color3.fromHSV((tick() * 0.35) % 1, 0.75, 1)
            FOVStroke.Color = rCol
            FOVCircleFrame.BackgroundColor3 = rCol
        else
            FOVStroke.Color = Theme.Accent
            FOVCircleFrame.BackgroundColor3 = Theme.Accent
        end
    end

    -- 2. Неоновый прицел
    CrosshairHolder.Visible = State.CustomCrosshair
    if State.CustomCrosshair then
        CrosshairHolder.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
        if State.CrosshairSpin then
            crossAngle = (crossAngle + dt * 135) % 360
            CrosshairHolder.Rotation = crossAngle
        else
            CrosshairHolder.Rotation = 0
        end
        for _, cb in ipairs(CrossBars) do
            cb.ui.Position = UDim2.new(0.5, cb.dirX * State.CrosshairGap, 0.5, cb.dirY * State.CrosshairGap)
        end
    end

    -- 3. Поиск цели + обработка WallShot
    local targetPlr, targetBone = GetClosestPlayerInFOV()
    CurrentAimbotTarget = targetPlr
    CurrentTargetPart = targetBone

    if State.WallShotEnabled and targetBone and targetPlr and targetPlr.Character then
        ProcessWallShotTunnel(targetBone, targetPlr.Character)
    else
        if next(WallShotModifiedParts) ~= nil then RestoreWallShotParts() end
        WallShotBadge.Visible = false
    end

    -- 4. Линия захвата (Snapline)
    if State.LockTracerLine and targetBone then
        local sp, onScr = Camera:WorldToViewportPoint(targetBone.Position)
        if onScr then
            local p2 = Vector2.new(sp.X, sp.Y)
            local diff = p2 - screenCenter
            AimbotSnapline.Visible = true
            AimbotSnapline.Position = UDim2.new(0, (screenCenter.X + p2.X) / 2, 0, (screenCenter.Y + p2.Y) / 2)
            AimbotSnapline.Size = UDim2.new(0, diff.Magnitude, 0, 1.4)
            AimbotSnapline.Rotation = math.deg(math.atan2(diff.Y, diff.X))
        else
            AimbotSnapline.Visible = false
        end
    else
        AimbotSnapline.Visible = false
    end

    -- 5. Target HUD
    TargetHUD.Visible = (State.TargetHUDPanel and targetPlr ~= nil)
    if State.TargetHUDPanel and targetPlr and targetPlr.Character then
        local hum = targetPlr.Character:FindFirstChildOfClass("Humanoid")
        local hrp = targetPlr.Character:FindFirstChild("HumanoidRootPart")
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local dist = (hrp and myHrp) and math.floor((hrp.Position - myHrp.Position).Magnitude) or 0
        local hp = hum and math.floor(hum.Health) or 0
        local maxHp = (hum and hum.MaxHealth > 0) and hum.MaxHealth or 100

        THUDName.Text = "🎯 " .. targetPlr.DisplayName
        THUDInfo.Text = string.format("HP: %d/%d | %dm %s", hp, math.floor(maxHp), dist, State.WallShotEnabled and "[WS]" or "")
        THUDAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. targetPlr.UserId .. "&w=150&h=150"
        THUDHpFill.Size = UDim2.new(math.clamp(hp / maxHp, 0, 1), 0, 1, 0)
    end

    -- 6. Кружение вокруг цели (Target Orbit Strafe)
    if State.TargetOrbitStrafe and targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then
            strafeAngle = strafeAngle + dt * State.TargetStrafeSpeed
            local tPos = targetPlr.Character.HumanoidRootPart.Position
            local offset = Vector3.new(math.cos(strafeAngle) * State.TargetStrafeRadius, 0.5, math.sin(strafeAngle) * State.TargetStrafeRadius)
            myHrp.CFrame = CFrame.new(tPos + offset, tPos)
        end
    end

    -- 7. Доводка камеры (Camera Aimbot)
    if State.AimbotEnabled and targetBone then
        local holdOk = (not State.AimbotHoldMouse2) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if holdOk then
            local aimPos = targetBone.Position
            if State.AimbotPrediction and targetBone.Parent:FindFirstChild("HumanoidRootPart") then
                local vel = targetBone.Parent.HumanoidRootPart.Velocity
                aimPos = aimPos + (vel * (State.AimbotPredictVal / 100))
            end
            local goalCF = CFrame.new(Camera.CFrame.Position, aimPos)
            local alpha = math.clamp(1 / math.max(State.AimbotSmoothness / 4.5, 1), 0.05, 1)
            Camera.CFrame = Camera.CFrame:Lerp(goalCF, alpha)
        end
    end

    -- 8. Обновление 2D радара
    Update2DRadar()
end)

-- Цикл исправленных Хитбоксов и Silent Aim (НЕ ломает физику благодаря Massless = true)
Connections.HitboxAndSilentLoop = RunService.Heartbeat:Connect(function()
    if not State.HitboxExpander and not State.SilentAimEnabled then
        if next(OriginalHitboxSizes) ~= nil then RestoreHitboxes() end
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local isEnemy = (not State.AimbotTeamCheck) or (plr.Team ~= LocalPlayer.Team)
            local boneName = State.HitboxTargetBone or "HumanoidRootPart"
            local bone = plr.Character:FindFirstChild(boneName) or plr.Character:FindFirstChild("HumanoidRootPart")

            if bone and bone:IsA("BasePart") then
                if not OriginalHitboxSizes[plr] then OriginalHitboxSizes[plr] = {} end
                if not OriginalHitboxSizes[plr][bone.Name] then
                    OriginalHitboxSizes[plr][bone.Name] = {
                        Size = bone.Size,
                        Transparency = bone.Transparency,
                        Material = bone.Material,
                        CanCollide = bone.CanCollide
                    }
                end

                if State.HitboxExpander and isEnemy then
                    local sz = State.HitboxSize
                    bone.Size = Vector3.new(sz, sz, sz)
                    bone.Transparency = State.HitboxTransparency / 100
                    bone.Color = Theme.Accent
                    bone.Material = Enum.Material.ForceField
                    bone.Massless = true
                    bone.CanCollide = false
                elseif State.SilentAimEnabled and plr == CurrentAimbotTarget and isEnemy then
                    -- Невидимый магнитный буфер для гарантированной регистрации пули
                    bone.Size = Vector3.new(11, 11, 11)
                    bone.Transparency = 0.96
                    bone.Massless = true
                    bone.CanCollide = false
                else
                    local orig = OriginalHitboxSizes[plr][bone.Name]
                    if orig then
                        bone.Size = orig.Size
                        bone.Transparency = orig.Transparency
                        bone.Material = orig.Material
                        bone.CanCollide = orig.CanCollide
                    end
                end
            end
        end
    end
end)

-- Гарантированный Silent Aim редирект при клике мыши / тапе на экране (для всех мобильных оружия)
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        if State.SilentAimEnabled and CurrentTargetPart and (State.SilentAimMethod == "Hybrid" or State.SilentAimMethod == "MicroFlick") then
            if math.random(1, 100) <= State.SilentAimHitChance then
                SafeCall(function()
                    local pred = Vector3.zero
                    if State.AimbotPrediction and CurrentTargetPart.Parent:FindFirstChild("HumanoidRootPart") then
                        pred = CurrentTargetPart.Parent.HumanoidRootPart.Velocity * (State.AimbotPredictVal / 100)
                    end
                    local targetPos = CurrentTargetPart.Position + pred
                    local savedCF = Camera.CFrame
                    Camera.CFrame = CFrame.new(savedCF.Position, targetPos)
                    task.delay(0.035, function()
                        if not State.AimbotEnabled then
                            Camera.CFrame = savedCF
                        end
                    end)
                end)
            end
        end
    end
end)

-------------------------------------------------------------------------
-- 3. ЗАПОЛНЕНИЕ ВКЛАДКИ COMBAT (CAMERA AIMBOT, SILENT AIM, WALLSHOT, BYPASS)
-------------------------------------------------------------------------
local CardAimMain   = CreateCard(PageCombatAim, "Left", "🎯 Camera Aimbot", true)
local CardAimFOV    = CreateCard(PageCombatAim, "Right", "⭕ FOV & Target Strafe", true)

AddCheckbox(CardAimMain, "AimbotEnabled", "Enable Camera Aimbot", function() end)
AddCheckbox(CardAimMain, "AimbotHoldMouse2", "Hold Right Click (ПКМ) Only", function() end)
AddSlider(CardAimMain, "AimbotSmoothness", "Aimbot Smoothness", 4, 100)
AddSelector(CardAimMain, "AimbotHitPart", "Target HitPart", {"Head", "HumanoidRootPart", "Random"})
AddCheckbox(CardAimMain, "AimbotPrediction", "Velocity Prediction (Упреждение)", function() end)
AddSlider(CardAimMain, "AimbotPredictVal", "Prediction Factor (%)", 4, 45)
AddCheckbox(CardAimMain, "AimbotWallCheck", "Visible Check (Проверка стен)", function() end)
AddCheckbox(CardAimMain, "AimbotTeamCheck", "Team Check (Не бить своих)", function() end)
AddCheckbox(CardAimMain, "AimbotAliveCheck", "Alive Check (Только живые)", function() end)

AddCheckbox(CardAimFOV, "ShowFOVCircle", "Draw 2D FOV Circle", function() end)
AddSlider(CardAimFOV, "AimbotFOV", "FOV Circle Radius (px)", 30, 320)
AddCheckbox(CardAimFOV, "RainbowFOV", "Rainbow FOV Circle", function() end)
AddCheckbox(CardAimFOV, "FilledFOVCircle", "Filled Translucent FOV", function() end)
AddCheckbox(CardAimFOV, "LockTracerLine", "Target Snapline (Линия до цели)", function() end)
AddCheckbox(CardAimFOV, "TargetHUDPanel", "Target HUD Card (Панель врага)", function() end)
AddCheckbox(CardAimFOV, "TargetOrbitStrafe", "Target Orbit Strafe (Кружение)", function() end)
AddSlider(CardAimFOV, "TargetStrafeRadius", "Orbit Radius (Studs)", 4, 22)
AddSlider(CardAimFOV, "TargetStrafeSpeed", "Orbit Speed", 4, 30)

-- Подвкладка 2: SILENT AIM & WALLSHOT
local CardSilent   = CreateCard(PageCombatSilent, "Left", "👻 Silent Aim V2 (Fixed)", true)
local CardWallShot = CreateCard(PageCombatSilent, "Right", "🧱 WallShot & TriggerBot", true)

AddCheckbox(CardSilent, "SilentAimEnabled", "Enable Silent Aim (Сайлент Аим)", function(val)
    if not val then RestoreHitboxes() end
end)
AddSelector(CardSilent, "SilentAimMethod", "Silent Aim Mode", {"Hybrid", "MouseHit", "MicroFlick"})
AddSlider(CardSilent, "SilentAimHitChance", "Hit Chance (%)", 15, 100)
AddSlider(CardSilent, "SilentAimHeadshotRate", "Headshot Chance (%)", 10, 100)
AddCheckbox(CardSilent, "SilentAimUseFOV", "Limit Silent Aim to FOV Circle", function() end)
AddCheckbox(CardSilent, "CustomCrosshair", "Neon Spinning Crosshair", function() end)
AddCheckbox(CardSilent, "CrosshairSpin", "Rotate Crosshair 360°", function() end)
AddSlider(CardSilent, "CrosshairGap", "Crosshair Gap", 4, 22)

AddCheckbox(CardWallShot, "WallShotEnabled", "Enable WallShot (Прострел стен)", function(val)
    if not val then
        RestoreWallShotParts()
        WallShotBadge.Visible = false
    end
end)
AddSlider(CardWallShot, "WallShotMaxWalls", "Max Pierced Walls (Стен подряд)", 1, 14)

AddCheckbox(CardWallShot, "TriggerBot", "Auto TriggerBot (Авто-выстрел)", function(state)
    Disconnect("TriggerBot")
    if state then
        Connections.TriggerBot = RunService.RenderStepped:Connect(function()
            local t = Mouse.Target
            if t and t.Parent then
                local plr = Players:GetPlayerFromCharacter(t.Parent) or Players:GetPlayerFromCharacter(t.Parent.Parent)
                if plr and plr ~= LocalPlayer then
                    local teamOk = (not State.AimbotTeamCheck) or (plr.Team ~= LocalPlayer.Team)
                    if teamOk then
                        SafeCall(function()
                            if mouse1click then
                                mouse1click()
                            else
                                VirtualInputManager:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 1)
                                task.wait(0.02)
                                VirtualInputManager:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 1)
                            end
                        end)
                    end
                end
            end
        end)
    end
end)

-- Подвкладка 3: HITBOX EXPANDER & BYPASS V2
local CardHitbox = CreateCard(PageCombatBypass, "Left", "📦 Massless Hitbox Expander", true)
local CardBypass = CreateCard(PageCombatBypass, "Right", "🛡 Anti-Cheat Bypass V2", true)

AddCheckbox(CardHitbox, "HitboxExpander", "Enable Hitbox Expander (Рабочие хитбоксы)", function(val)
    if not val then RestoreHitboxes() end
end)
AddSelector(CardHitbox, "HitboxTargetBone", "Hitbox Part", {"HumanoidRootPart", "Head"})
AddSlider(CardHitbox, "HitboxSize", "Hitbox Size (Studs)", 4, 35)
AddSlider(CardHitbox, "HitboxTransparency", "Hitbox Transparency (%)", 10, 95)
AddButton(CardHitbox, "🔄 Restore All Default Hitboxes", function()
    RestoreHitboxes()
    Notify("Hitboxes", "All player hitboxes restored!", 1.4)
end)

AddCheckbox(CardBypass, "BypassSizeSpoof", "Spoof Hitbox Size (__index Hook)", function() end)
AddCheckbox(CardBypass, "BypassSpeedSpoof", "Spoof WalkSpeed & JumpPower", function() end)
AddCheckbox(CardBypass, "BypassAntiKick", "Block Client Kick Attempts", function() end)
AddCheckbox(CardBypass, "BypassVelocityClamp", "Velocity Anti-Rubberband Clamp", function(state)
    Disconnect("VelClamp")
    if state then
        Connections.VelClamp = RunService.Heartbeat:Connect(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Velocity.Magnitude > 165 and not State.Fly then
                hrp.Velocity = hrp.Velocity.Unit * 140
            end
        end)
    end
end)

AddCheckbox(CardBypass, "BypassNoFallDamage", "No Fall Damage Bypass", function(state)
    Disconnect("NoFall")
    if state then
        Connections.NoFall = RunService.Heartbeat:Connect(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
                hum:ChangeState(Enum.HumanoidStateType.Landed)
            end
        end)
    end
end)

-------------------------------------------------------------------------
-- 4. СТРАНИЦА SETTINGS + РЕАЛЬНОЕ ФАЙЛОВОЕ СОХРАНЕНИЕ КОНФИГОВ
-------------------------------------------------------------------------
local CardMenu = CreateCard(PageSettings, "Left", "✨ Menu Size, Top Pill & UI", true)
local CardConfigs = CreateCard(PageSettings, "Right", "💾 Real FileSystem Configs", false)

AddSlider(CardMenu, "MenuScalePct", "Menu Scale Size (%)", 55, 135, function(val)
    SetMenuScale(val)
end)

AddCheckbox(CardMenu, "ShowTopPillIsland", "Top Rounded Pill Island (Кнопка сверху)", function(val)
    TopIslandContainer.Visible = val
end)

AddCheckbox(CardMenu, "PillShowAvatarBox", "Show Avatar Icon Above Pill", function(val)
    IslandIconBox.Visible = val
end)

AddCheckbox(CardMenu, "Preview3DWindow", "Show Right 3D Character Window", function(val)
    PreviewBox.Visible = val
    MainBox.Size = val and UDim2.new(1, -168, 1, 0) or UDim2.new(1, 0, 1, 0)
end)

local KbRow = Instance.new("Frame", CardMenu)
KbRow.Size = UDim2.new(1, 0, 0, 22)
KbRow.BackgroundTransparency = 1

local KbLbl = Instance.new("TextLabel", KbRow)
KbLbl.Size = UDim2.new(0.55, 0, 1, 0)
KbLbl.BackgroundTransparency = 1
KbLbl.Text = "Menu Keybind"
KbLbl.TextColor3 = Theme.TextGray
KbLbl.Font = Enum.Font.GothamBold
KbLbl.TextSize = 10
KbLbl.TextXAlignment = Enum.TextXAlignment.Left

local KbBtn = Instance.new("TextButton", KbRow)
KbBtn.Size = UDim2.new(0, 56, 0, 18)
KbBtn.Position = UDim2.new(1, -56, 0.5, -9)
KbBtn.BackgroundColor3 = Theme.BgElement
KbBtn.Text = "RShift"
KbBtn.TextColor3 = Theme.TextWhite
KbBtn.Font = Enum.Font.GothamBold
KbBtn.TextSize = 9
Instance.new("UICorner", KbBtn).CornerRadius = UDim.new(0, 3)
Instance.new("UIStroke", KbBtn).Color = Theme.Border

local waitingBind = false
KbBtn.MouseButton1Click:Connect(function()
    waitingBind = true
    KbBtn.Text = "..."
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if waitingBind and input.UserInputType == Enum.UserInputType.Keyboard then
        MenuKeybind = input.KeyCode
        KbBtn.Text = input.KeyCode.Name
        waitingBind = false
        Notify("Keybind", "Bound to " .. input.KeyCode.Name, 1.5)
        return
    end
    if not gpe and input.KeyCode == MenuKeybind then
        ToggleMenuAnimated()
    end
end)

AddCheckbox(CardMenu, "Watermark", "Show Top Watermark (FPS & Ping)", function(val)
    Watermark.Visible = val
end)
AddCheckbox(CardMenu, "ActiveArrayList", "Show Active ArrayList (Справа)", function(val)
    ArrayListFrame.Visible = val
end)
AddCheckbox(CardMenu, "KeystrokesHUD", "WASD Keystrokes HUD", function(val)
    KeystrokesFrame.Visible = val
end)
AddCheckbox(CardMenu, "Notifications", "Toast Notifications", function() end)
AddCheckbox(CardMenu, "UIRippleFX", "UI Ripple Click Wave", function() end)
AddCheckbox(CardMenu, "UIHoverGlow", "UI Hover Glow & Slide", function() end)

AddButton(CardMenu, "🎬 Replay Compact Intro", function()
    MasterFrame.Visible = false
    RunCompactCinematicIntro(function()
        MasterFrame.Visible = true
        SetMenuScale(State.MenuScalePct)
    end)
end)

AddButton(CardMenu, "🗑 Unload FemboyHub V8 Safely", function()
    RestoreWallShotParts()
    RestoreHitboxes()
    for k, _ in pairs(Connections) do Disconnect(k) end
    for k, _ in pairs(VisualObjects) do ClearVisual(k) end
    ScreenGui:Destroy()
end)

-- РЕАЛЬНЫЙ ФАЙЛОВЫЙ МЕНЕДЖЕР КОНФИГОВ (Правая колонка Settings)
local CfgListBox = Instance.new("ScrollingFrame", CardConfigs)
CfgListBox.Size = UDim2.new(1, 0, 0, 96)
CfgListBox.BackgroundColor3 = Color3.fromRGB(9, 9, 12)
CfgListBox.ScrollBarThickness = 2
CfgListBox.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", CfgListBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", CfgListBox).Color = Theme.Border

local CfgListLayout = Instance.new("UIListLayout", CfgListBox)
CfgListLayout.Padding = UDim.new(0, 2)
CfgListLayout.SortOrder = Enum.SortOrder.LayoutOrder
CfgListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    CfgListBox.CanvasSize = UDim2.new(0, 0, 0, CfgListLayout.AbsoluteContentSize.Y + 4)
end)

local CfgNameBox = Instance.new("TextBox", CardConfigs)
CfgNameBox.Size = UDim2.new(1, 0, 0, 22)
CfgNameBox.BackgroundColor3 = Color3.fromRGB(9, 9, 12)
CfgNameBox.Text = "Default"
CfgNameBox.PlaceholderText = "Enter config name..."
CfgNameBox.TextColor3 = Theme.TextWhite
CfgNameBox.Font = Enum.Font.GothamBold
CfgNameBox.TextSize = 10
Instance.new("UICorner", CfgNameBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", CfgNameBox).Color = Theme.Border

local CfgBtnRow = Instance.new("Frame", CardConfigs)
CfgBtnRow.Size = UDim2.new(1, 0, 0, 24)
CfgBtnRow.BackgroundTransparency = 1
local CfgBtnLayout = Instance.new("UIListLayout", CfgBtnRow)
CfgBtnLayout.FillDirection = Enum.FillDirection.Horizontal
CfgBtnLayout.Padding = UDim.new(0, 5)

local CfgStatus = Instance.new("TextLabel", CardConfigs)
CfgStatus.Size = UDim2.new(1, 0, 0, 14)
CfgStatus.BackgroundTransparency = 1
CfgStatus.Text = "Status: Ready"
CfgStatus.TextColor3 = Theme.Accent
CfgStatus.Font = Enum.Font.GothamBold
CfgStatus.TextSize = 9
CfgStatus.TextXAlignment = Enum.TextXAlignment.Left

local function GetConfigFilePath(name)
    return CONFIG_FOLDER .. "/" .. name .. ".json"
end

-- Сканирование сохранённых JSON файлов на устройстве
local function SyncDiskConfigs()
    SafeCall(function()
        if listfiles and isfolder and isfolder(CONFIG_FOLDER) then
            for _, filePath in ipairs(listfiles(CONFIG_FOLDER)) do
                local fileName = string.match(filePath, "([^/\\]+)%.json$")
                if fileName and not SavedConfigs[fileName] then
                    SavedConfigs[fileName] = {}
                end
            end
        end
    end)
end
SyncDiskConfigs()

local function RebuildConfigList(selectedName)
    SyncDiskConfigs()
    for _, v in ipairs(CfgListBox:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for cfgName, _ in pairs(SavedConfigs) do
        local isSel = (cfgName == selectedName)
        local Item = Instance.new("TextButton", CfgListBox)
        Item.Size = UDim2.new(1, 0, 0, 22)
        Item.BackgroundColor3 = Theme.BgElement
        Item.BackgroundTransparency = isSel and 0 or 1
        Item.Text = ""

        local Bar = Instance.new("Frame", Item)
        Bar.Size = UDim2.new(0, 2, 0, 12)
        Bar.Position = UDim2.new(0, 2, 0.5, -6)
        Bar.BackgroundColor3 = Theme.Accent
        Bar.BorderSizePixel = 0
        Bar.Visible = isSel

        local Txt = Instance.new("TextLabel", Item)
        Txt.Size = UDim2.new(1, -12, 1, 0)
        Txt.Position = UDim2.new(0, 8, 0, 0)
        Txt.BackgroundTransparency = 1
        Txt.Text = "📄 " .. cfgName
        Txt.TextColor3 = isSel and Theme.TextWhite or Theme.TextGray
        Txt.Font = Enum.Font.GothamBold
        Txt.TextSize = 10
        Txt.TextXAlignment = Enum.TextXAlignment.Left

        Item.MouseButton1Click:Connect(function()
            CfgNameBox.Text = cfgName
            RebuildConfigList(cfgName)
        end)
    end
end
RebuildConfigList("Default")

local function SaveConfigToDisk(name)
    name = (name and name ~= "") and name or "Default"
    local snap = {}
    for k, v in pairs(State) do
        if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
            snap[k] = v
        end
    end
    SavedConfigs[name] = snap
    local wroteDisk = false
    SafeCall(function()
        if writefile then
            writefile(GetConfigFilePath(name), HttpService:JSONEncode(snap))
            wroteDisk = true
        end
    end)
    RebuildConfigList(name)
    CfgStatus.Text = wroteDisk and ("Saved to disk: " .. name) or ("Saved in memory: " .. name)
    Notify("Config Saved", "Successfully saved [" .. name .. "]", 1.6)
end

local function LoadConfigFromDisk(name)
    name = (name and name ~= "") and name or "Default"
    local data = SavedConfigs[name]
    SafeCall(function()
        local path = GetConfigFilePath(name)
        if readfile and isfile and isfile(path) then
            data = HttpService:JSONDecode(readfile(path))
        elseif readfile and isfile and isfile("FemboyHub_" .. name .. ".json") then
            data = HttpService:JSONDecode(readfile("FemboyHub_" .. name .. ".json"))
        end
    end)
    if data and next(data) ~= nil then
        for k, v in pairs(data) do
            if type(v) == "boolean" and ToggleSetters[k] then
                ToggleSetters[k](v, true)
            elseif type(v) == "number" and SliderSetters[k] then
                SliderSetters[k](v, false)
            elseif type(v) == "string" and DropdownSetters[k] then
                DropdownSetters[k](v, true)
            else
                State[k] = v
            end
        end
        CfgStatus.Text = "Loaded: " .. name
        Notify("Config Loaded", "Applied all settings from [" .. name .. "]", 1.8)
    else
        CfgStatus.Text = "Empty config: " .. name
        Notify("Configs", "Config [" .. name .. "] is empty! Save it first.", 1.6)
    end
end

local cfgActions = {
    {icon = "💾", fn = function() SaveConfigToDisk(CfgNameBox.Text) end},
    {icon = "📂", fn = function() LoadConfigFromDisk(CfgNameBox.Text) end},
    {icon = "🔄", fn = function()
        RebuildConfigList(CfgNameBox.Text)
        CfgStatus.Text = "Synced disk files"
    end},
    {icon = "➕", fn = function()
        local name = CfgNameBox.Text
        if name ~= "" then SaveConfigToDisk(name) end
    end},
    {icon = "🗑", fn = function()
        local name = CfgNameBox.Text
        SavedConfigs[name] = nil
        SafeCall(function()
            if delfile and isfile and isfile(GetConfigFilePath(name)) then
                delfile(GetConfigFilePath(name))
            end
        end)
        RebuildConfigList("")
        CfgStatus.Text = "Deleted: " .. name
        Notify("Configs", "Deleted [" .. name .. "]", 1.5)
    end}
}

for _, act in ipairs(cfgActions) do
    local b = Instance.new("TextButton", CfgBtnRow)
    b.Size = UDim2.new(0, 31, 0, 22)
    b.BackgroundColor3 = Theme.BgElement
    b.Text = act.icon
    b.TextColor3 = Theme.TextWhite
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", b).Color = Theme.Border
    b.MouseButton1Click:Connect(function()
        SpawnRipple(b, UserInputService:GetMouseLocation())
        act.fn()
    end)
end

-------------------------------------------------------------------------
-- [ PART 4 / 5 : SHADERS, 3D AURAS, WEATHER & ANTI-CRASH POOLED ESP ]
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- 1. VISUALS -> SHADERS & SKY (12 пресетов ЦК, RTX Шейдеры, Motion Blur)
-------------------------------------------------------------------------
local CardShaders = CreateCard(PageVisShaders, "Left", "✨ RTX Shaders & World FX", true)
local CardCC      = CreateCard(PageVisShaders, "Right", "🌌 Sky & Color Presets (12)", true)

local function ClearLightingFX()
    SafeCall(function()
        for _, v in ipairs(Lighting:GetChildren()) do
            if string.sub(v.Name, 1, 3) == "FH_" then v:Destroy() end
        end
    end)
end

AddCheckbox(CardShaders, "RTXShaders", "RTX Glossy Shaders (Bloom + Rays + DOF)", function(state)
    ClearLightingFX()
    if state then
        Lighting.GlobalShadows = true
        Lighting.ExposureCompensation = 0.25
        local bloom = Instance.new("BloomEffect", Lighting)
        bloom.Name = "FH_Bloom"
        bloom.Intensity = 0.88
        bloom.Size = 30
        local rays = Instance.new("SunRaysEffect", Lighting)
        rays.Name = "FH_Rays"
        rays.Intensity = 0.25
        local dof = Instance.new("DepthOfFieldEffect", Lighting)
        dof.Name = "FH_DOF"
        dof.FarIntensity = 0.24
        dof.InFocusRadius = 35
    else
        Lighting.ExposureCompensation = DefaultLighting.ExposureCompensation
    end
end)

AddCheckbox(CardShaders, "MotionBlur", "Camera Motion Blur (Размытие поворота)", function(state)
    Disconnect("MotionBlur")
    SafeCall(function()
        if Lighting:FindFirstChild("FH_MotionBlur") then Lighting.FH_MotionBlur:Destroy() end
    end)
    if state then
        local mb = Instance.new("BlurEffect", Lighting)
        mb.Name = "FH_MotionBlur"
        mb.Size = 0
        local lastLook = Camera.CFrame.LookVector
        Connections.MotionBlur = RunService.RenderStepped:Connect(function()
            local curLook = Camera.CFrame.LookVector
            local diff = (curLook - lastLook).Magnitude
            mb.Size = math.clamp(diff * 85, 0, 18)
            lastLook = curLook
        end)
    end
end)

AddCheckbox(CardShaders, "Fullbright", "Fullbright (Максимальная яркость)", function(state)
    if state then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        for k, v in pairs(DefaultLighting) do Lighting[k] = v end
    end
end)

AddCheckbox(CardShaders, "XRayWalls", "X-Ray World Walls (Прозрачные стены)", function(state)
    SafeCall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (not LocalPlayer.Character or not obj:IsDescendantOf(LocalPlayer.Character)) and obj.Name ~= "Terrain" then
                if state and obj.Transparency < 0.5 then
                    obj:SetAttribute("FH_OrigTrans", obj.Transparency)
                    obj.Transparency = 0.65
                elseif not state and obj:GetAttribute("FH_OrigTrans") ~= nil then
                    obj.Transparency = obj:GetAttribute("FH_OrigTrans")
                end
            end
        end
    end)
end)

AddButton(CardShaders, "⚡ FPS Booster (Anti-Lag Materials)", function()
    SafeCall(function()
        Lighting.GlobalShadows = false
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 0.2
            end
        end
    end)
    Notify("FPS Booster", "World materials optimized for max FPS!", 1.6)
end)

local function ApplyCCPreset(name, clock, fogCol, tint, contrast, sat)
    ClearLightingFX()
    Lighting.ClockTime = clock
    Lighting.FogColor = fogCol
    Lighting.FogEnd = 580
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Name = "FH_CC"
    cc.Contrast = contrast
    cc.Saturation = sat
    cc.TintColor = tint
    Notify("Shader Preset", "Applied: " .. name, 1.5)
end

AddButton(CardCC, "🌌 Moody Night (Shitaro Blue)", function()
    ApplyCCPreset("Moody Night", 0, Color3.fromRGB(10, 16, 32), Color3.fromRGB(170, 205, 255), 0.28, -0.1)
end)
AddButton(CardCC, "🩸 Dead Star Crimson Sky", function()
    ApplyCCPreset("Dead Star Crimson", 18, Color3.fromRGB(45, 8, 15), Color3.fromRGB(255, 130, 145), 0.35, 0.25)
end)
AddButton(CardCC, "🌸 Pastel Femboy Sunset", function()
    ApplyCCPreset("Pastel Sunset", 17.6, Color3.fromRGB(255, 165, 220), Color3.fromRGB(255, 200, 240), 0.22, 0.35)
end)
AddButton(CardCC, "🖤 Pitch-Black Monochrome (Noir)", function()
    ApplyCCPreset("Noir Monochrome", 0, Color3.fromRGB(8, 8, 10), Color3.fromRGB(225, 225, 235), 0.45, -1.0)
end)
AddButton(CardCC, "💜 Cyberpunk Neon Violet", function()
    ApplyCCPreset("Cyberpunk Violet", 0, Color3.fromRGB(28, 10, 50), Color3.fromRGB(210, 160, 255), 0.35, 0.45)
end)
AddButton(CardCC, "💻 Matrix Digital Green", function()
    ApplyCCPreset("Matrix Green", 0, Color3.fromRGB(5, 25, 10), Color3.fromRGB(140, 255, 160), 0.38, 0.2)
end)
AddButton(CardCC, "🌅 Golden Hour Warmth", function()
    ApplyCCPreset("Golden Hour", 17.2, Color3.fromRGB(255, 190, 120), Color3.fromRGB(255, 215, 175), 0.25, 0.3)
end)
AddButton(CardCC, "❄️ Deep Subzero Ice", function()
    ApplyCCPreset("Subzero Ice", 12, Color3.fromRGB(185, 230, 255), Color3.fromRGB(190, 235, 255), 0.22, -0.25)
end)
AddButton(CardCC, "📼 VHS Dreamcore Haze", function()
    ApplyCCPreset("Dreamcore Haze", 19.5, Color3.fromRGB(85, 60, 110), Color3.fromRGB(240, 185, 255), 0.15, 0.55)
end)
AddButton(CardCC, "🔮 Abyssal Void Indigo", function()
    ApplyCCPreset("Abyssal Void", 0, Color3.fromRGB(6, 4, 24), Color3.fromRGB(145, 130, 255), 0.42, 0.35)
end)
AddButton(CardCC, "☢️ Toxic Wasteland Amber", function()
    ApplyCCPreset("Toxic Amber", 6.5, Color3.fromRGB(45, 55, 12), Color3.fromRGB(220, 255, 135), 0.32, 0.28)
end)
AddButton(CardCC, "🔄 Reset Lighting to Default", function()
    ClearLightingFX()
    for k, v in pairs(DefaultLighting) do Lighting[k] = v end
    Notify("Lighting", "Restored default lighting", 1.4)
end)

-------------------------------------------------------------------------
-- 2. VISUALS -> 3D AURAS & GEAR (НОВЫЕ 3D АУРЫ БЕЗ УТЕЧЕК ПАМЯТИ)
-------------------------------------------------------------------------
local Card3DGear  = CreateCard(PageVis3DAuras, "Left", "⚔️ 3D Gear, Seals & Rings", true)
local Card3DAuras = CreateCard(PageVis3DAuras, "Right", "🌀 3D Auras, DNA & Blackhole", true)

AddCheckbox(Card3DGear, "MagicCircle", "Rotating Magic Seal (Печать под ногами)", function(state)
    Disconnect("MagicCircle")
    ClearVisual("MagicCircle")
    if state then
        local folder = Instance.new("Folder", Workspace)
        VisualObjects.MagicCircle = folder

        local outerRing = Instance.new("Part", folder)
        outerRing.Size = Vector3.new(6.5, 0.06, 6.5)
        outerRing.Material = Enum.Material.Neon
        outerRing.Color = Theme.Accent
        outerRing.Transparency = 0.25
        outerRing.Anchored = true
        outerRing.CanCollide = false
        outerRing.CanQuery = false
        Instance.new("CylinderMesh", outerRing)

        local starNodes = {}
        local pts = 5
        for i = 1, pts do
            local p = Instance.new("Part", folder)
            p.Size = Vector3.new(0.25, 0.25, 0.25)
            p.Transparency = 1
            p.Anchored = true
            p.CanCollide = false
            p.CanQuery = false
            local att = Instance.new("Attachment", p)
            starNodes[i] = {part = p, att = att}
        end
        for i = 1, pts do
            local nextIdx = ((i + 1) % pts) + 1
            local beam = Instance.new("Beam", folder)
            beam.Attachment0 = starNodes[i].att
            beam.Attachment1 = starNodes[nextIdx].att
            beam.Width0 = 0.12
            beam.Width1 = 0.12
            beam.LightEmission = 1
            beam.Color = ColorSequence.new(Theme.Accent)
        end

        local rot = 0
        Connections.MagicCircle = RunService.RenderStepped:Connect(function(dt)
            rot = rot + dt * 1.8
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local basePos = hrp.Position - Vector3.new(0, 2.85, 0)
                outerRing.CFrame = CFrame.new(basePos)
                outerRing.Color = Theme.Accent
                for i, node in ipairs(starNodes) do
                    local a = rot + (i * math.pi * 2 / pts)
                    node.part.Position = basePos + Vector3.new(math.cos(a) * 3.1, 0.05, math.sin(a) * 3.1)
                end
            end
        end)
    end
end)

AddCheckbox(Card3DGear, "FloatingSwords", "Floating Neon Swords (4 Меча за спиной)", function(state)
    Disconnect("FloatingSwords")
    ClearVisual("FloatingSwords")
    if state then
        local folder = Instance.new("Folder", Workspace)
        VisualObjects.FloatingSwords = folder
        local swords = {}
        for i = 1, 4 do
            local blade = Instance.new("Part", folder)
            blade.Size = Vector3.new(0.18, 3.8, 0.35)
            blade.Material = Enum.Material.Neon
            blade.Color = Theme.Accent
            blade.Anchored = true
            blade.CanCollide = false
            blade.CanQuery = false
            swords[i] = blade
        end
        local t = 0
        Connections.FloatingSwords = RunService.RenderStepped:Connect(function(dt)
            t = t + dt * 2.5
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for i, sw in ipairs(swords) do
                    sw.Color = Theme.Accent
                    local spread = (i - 2.5) * 1.35
                    local bob = math.sin(t + i) * 0.35
                    sw.CFrame = hrp.CFrame * CFrame.new(spread, 1.2 + bob, 1.6) * CFrame.Angles(0, 0, math.rad(spread * 18))
                end
            end
        end)
    end
end)

AddCheckbox(Card3DGear, "CyberRing", "Cyber Archon Back Ring (Кольцо за спиной)", function(state)
    Disconnect("CyberRing")
    ClearVisual("CyberRing")
    if state then
        local folder = Instance.new("Folder", Workspace)
        VisualObjects.CyberRing = folder
        local segments = {}
        local count = 12
        for i = 1, count do
            local seg = Instance.new("Part", folder)
            seg.Size = Vector3.new(0.22, 0.22, 0.9)
            seg.Material = Enum.Material.Neon
            seg.Color = Theme.Accent
            seg.Anchored = true
            seg.CanCollide = false
            seg.CanQuery = false
            segments[i] = seg
        end
        local angle = 0
        Connections.CyberRing = RunService.RenderStepped:Connect(function(dt)
            angle = angle + dt * 1.5
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for i, seg in ipairs(segments) do
                    seg.Color = Theme.Accent
                    local a = angle + (i * math.pi * 2 / count)
                    local localOffset = CFrame.new(math.cos(a) * 2.6, math.sin(a) * 2.6 + 0.5, 1.4)
                    seg.CFrame = hrp.CFrame * localOffset * CFrame.Angles(0, 0, a)
                end
            end
        end)
    end
end)

-- НОВОЕ: Пересекающиеся Кольца Серафима (Seraphim Interlocking Rings)
AddCheckbox(Card3DGear, "SeraphimEyes", "Seraphim Interlocking Rings (Кольца Серафима)", function(state)
    Disconnect("Seraphim")
    ClearVisual("Seraphim")
    if state then
        local folder = Instance.new("Folder", Workspace)
        VisualObjects.Seraphim = folder
        local rings = {}
        for i = 1, 3 do
            local r = Instance.new("Part", folder)
            r.Size = Vector3.new(5.2, 0.08, 5.2)
            r.Material = Enum.Material.Neon
            r.Color = Theme.Accent
            r.Transparency = 0.35
            r.Anchored = true
            r.CanCollide = false
            r.CanQuery = false
            Instance.new("CylinderMesh", r)
            rings[i] = r
        end
        local t = 0
        Connections.Seraphim = RunService.RenderStepped:Connect(function(dt)
            t = t + dt * 1.7
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                rings[1].CFrame = CFrame.new(hrp.Position) * CFrame.Angles(t, t * 0.6, 0)
                rings[2].CFrame = CFrame.new(hrp.Position) * CFrame.Angles(-t * 0.8, 0, t)
                rings[3].CFrame = CFrame.new(hrp.Position) * CFrame.Angles(math.rad(60), t * 1.2, -t * 0.5)
                for _, r in ipairs(rings) do r.Color = Theme.Accent end
            end
        end)
    end
end)

AddCheckbox(Card3DGear, "RunicPillars", "Orbiting Runic Pillars (Колонны вокруг)", function(state)
    Disconnect("RunicPillars")
    ClearVisual("RunicPillars")
    if state then
        local folder = Instance.new("Folder", Workspace)
        VisualObjects.RunicPillars = folder
        local pillars = {}
        for i = 1, 4 do
            local p = Instance.new("Part", folder)
            p.Size = Vector3.new(0.32, 4.0, 0.32)
            p.Material = Enum.Material.Neon
            p.Color = Theme.Accent
            p.Transparency = 0.2
            p.Anchored = true
            p.CanCollide = false
            p.CanQuery = false
            pillars[i] = p
        end
        local rot = 0
        Connections.RunicPillars = RunService.RenderStepped:Connect(function(dt)
            rot = rot + dt * 1.25
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for i, p in ipairs(pillars) do
                    p.Color = Theme.Accent
                    local a = rot + (i * math.pi / 2)
                    p.CFrame = CFrame.new(hrp.Position + Vector3.new(math.cos(a) * 5.0, math.sin(rot * 2 + i) * 0.5, math.sin(a) * 5.0))
                end
            end
        end)
    end
end)

AddCheckbox(Card3DGear, "ChinaHat", "Neon Samurai China Hat (Шляпа)", function(state)
    Disconnect("ChinaHat")
    ClearVisual("ChinaHat")
    if state then
        local hat = Instance.new("Part", Workspace)
        hat.Size = Vector3.new(3, 1, 3)
        hat.Material = Enum.Material.Neon
        hat.Color = Theme.Accent
        hat.Transparency = 0.25
        hat.Anchored = true
        hat.CanCollide = false
        hat.CanQuery = false
        local mesh = Instance.new("SpecialMesh", hat)
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://1033714"
        mesh.Scale = Vector3.new(1.75, 0.6, 1.75)
        VisualObjects.ChinaHat = hat
        Connections.ChinaHat = RunService.RenderStepped:Connect(function()
            local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
            if head then
                hat.Color = Theme.Accent
                hat.CFrame = head.CFrame * CFrame.new(0, 1.1, 0)
            end
        end)
    end
end)

AddCheckbox(Card3DGear, "Halo", "Floating Neon Halo (Нимб)", function(state)
    Disconnect("Halo")
    ClearVisual("Halo")
    if state then
        local halo = Instance.new("Part", Workspace)
        halo.Size = Vector3.new(2.2, 0.15, 2.2)
        halo.Material = Enum.Material.Neon
        halo.Color = Theme.Accent
        halo.Anchored = true
        halo.CanCollide = false
        halo.CanQuery = false
        Instance.new("CylinderMesh", halo)
        VisualObjects.Halo = halo
        local t = 0
        Connections.Halo = RunService.RenderStepped:Connect(function(dt)
            t = t + dt * 2.5
            local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
            if head then
                halo.Color = Theme.Accent
                halo.CFrame = head.CFrame * CFrame.new(0, 1.8 + math.sin(t) * 0.15, 0)
            end
        end)
    end
end)

-- ПРАВАЯ КОЛОНКА 3D АУР
AddCheckbox(Card3DAuras, "DNAHelixAura", "3D Double DNA Helix (Двойная спираль ДНК)", function(state)
    Disconnect("DNAHelix")
    ClearVisual("DNAHelix")
    if state then
        local folder = Instance.new("Folder", Workspace)
        VisualObjects.DNAHelix = folder
        local strands = {}
        for i = 1, 14 do
            local s1 = Instance.new("Part", folder)
            s1.Shape = Enum.PartType.Ball
            s1.Size = Vector3.new(0.28, 0.28, 0.28)
            s1.Material = Enum.Material.Neon
            s1.Color = Theme.Accent
            s1.Anchored = true
            s1.CanCollide = false
            s1.CanQuery = false

            local s2 = s1:Clone()
            s2.Parent = folder
            strands[i] = {a = s1, b = s2}
        end
        local t = 0
        Connections.DNAHelix = RunService.RenderStepped:Connect(function(dt)
            t = t + dt * 3
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for i, pair in ipairs(strands) do
                    local yOff = -2.8 + (i * 0.4)
                    local ang = t + (i * 0.45)
                    pair.a.Color = Theme.Accent
                    pair.b.Color = Theme.Accent
                    pair.a.Position = hrp.Position + Vector3.new(math.cos(ang) * 2.5, yOff, math.sin(ang) * 2.5)
                    pair.b.Position = hrp.Position + Vector3.new(math.cos(ang + math.pi) * 2.5, yOff, math.sin(ang + math.pi) * 2.5)
                end
            end
        end)
    end
end)

AddCheckbox(Card3DAuras, "BlackholeCore", "Blackhole Singularity Orb (Чёрная дыра)", function(state)
    Disconnect("Blackhole")
    ClearVisual("Blackhole")
    if state then
        local folder = Instance.new("Folder", Workspace)
        VisualObjects.Blackhole = folder
        local core = Instance.new("Part", folder)
        core.Shape = Enum.PartType.Ball
        core.Size = Vector3.new(1.8, 1.8, 1.8)
        core.Material = Enum.Material.SmoothPlastic
        core.Color = Color3.fromRGB(5, 5, 8)
        core.Anchored = true
        core.CanCollide = false
        core.CanQuery = false

        local ring = Instance.new("Part", folder)
        ring.Size = Vector3.new(4.2, 0.08, 4.2)
        ring.Material = Enum.Material.Neon
        ring.Color = Theme.Accent
        ring.Anchored = true
        ring.CanCollide = false
        ring.CanQuery = false
        Instance.new("CylinderMesh", ring)

        local t = 0
        Connections.Blackhole = RunService.RenderStepped:Connect(function(dt)
            t = t + dt * 2.2
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos = hrp.Position + Vector3.new(0, 4.6 + math.sin(t) * 0.25, 0)
                core.Position = pos
                ring.Color = Theme.Accent
                ring.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(25), t, math.rad(15))
            end
        end)
    end
end)

-- НОВОЕ: Энергетическая силовая сфера вокруг игрока
AddCheckbox(Card3DAuras, "EnergyShieldSphere", "ForceField Energy Shield (Силовой купол)", function(state)
    Disconnect("EnergyShield")
    ClearVisual("EnergyShield")
    if state then
        local sphere = Instance.new("Part", Workspace)
        sphere.Shape = Enum.PartType.Ball
        sphere.Size = Vector3.new(6.8, 6.8, 6.8)
        sphere.Material = Enum.Material.ForceField
        sphere.Color = Theme.Accent
        sphere.Transparency = 0.45
        sphere.Anchored = true
        sphere.CanCollide = false
        sphere.CanQuery = false
        VisualObjects.EnergyShield = sphere
        Connections.EnergyShield = RunService.RenderStepped:Connect(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                sphere.Color = Theme.Accent
                sphere.Position = hrp.Position
            end
        end)
    end
end)

AddCheckbox(Card3DAuras, "Constellations3D", "3D Constellations (Созвездия вокруг)", function(state)
    Disconnect("Constellations")
    ClearVisual("Constellations")
    if state then
        local folder = Instance.new("Folder", Workspace)
        VisualObjects.Constellations = folder
        local nodes = {}
        local count = 6
        for i = 1, count do
            local star = Instance.new("Part", folder)
            star.Shape = Enum.PartType.Ball
            star.Size = Vector3.new(0.4, 0.4, 0.4)
            star.Material = Enum.Material.Neon
            star.Color = Theme.Accent
            star.Anchored = true
            star.CanCollide = false
            star.CanQuery = false
            local att = Instance.new("Attachment", star)
            nodes[i] = {part = star, att = att}
        end
        for i = 1, count do
            local beam = Instance.new("Beam", folder)
            beam.Attachment0 = nodes[i].att
            beam.Attachment1 = nodes[(i % count) + 1].att
            beam.Width0 = 0.08
            beam.Width1 = 0.08
            beam.LightEmission = 1
            beam.Color = ColorSequence.new(Theme.Accent)
        end
        local rot = 0
        Connections.Constellations = RunService.RenderStepped:Connect(function(dt)
            rot = rot + dt * 1.5
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for i, node in ipairs(nodes) do
                    node.part.Color = Theme.Accent
                    local a = rot + (i * math.pi * 2 / count)
                    node.part.Position = hrp.Position + Vector3.new(math.cos(a) * 4.5, math.sin(a * 2) * 1.4, math.sin(a) * 4.5)
                end
            end
        end)
    end
end)

AddCheckbox(Card3DAuras, "AngelWings", "Animated 3D Angel Wings (Крылья)", function(state)
    Disconnect("Wings")
    ClearVisual("Wings")
    if state then
        local folder = Instance.new("Folder", Workspace)
        VisualObjects.Wings = folder
        local feathers = {}
        for side = -1, 1, 2 do
            for i = 1, 4 do
                local p = Instance.new("Part", folder)
                p.Size = Vector3.new(0.18, 0.25, 2.2 - (i * 0.3))
                p.Material = Enum.Material.Neon
                p.Color = Theme.Accent
                p.Anchored = true
                p.CanCollide = false
                p.CanQuery = false
                table.insert(feathers, {part = p, side = side, idx = i})
            end
        end
        local flap = 0
        Connections.Wings = RunService.RenderStepped:Connect(function(dt)
            flap = flap + dt * 4
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, f in ipairs(feathers) do
                    f.part.Color = Theme.Accent
                    local ang = math.sin(flap - f.idx * 0.3) * 0.35
                    local cf = hrp.CFrame * CFrame.new(f.side * (0.8 + f.idx * 0.45), 0.8 - f.idx * 0.28, 0.9)
                    f.part.CFrame = cf * CFrame.Angles(0, f.side * (0.5 + ang), f.side * 0.2)
                end
            end
        end)
    end
end)

AddCheckbox(Card3DAuras, "TeslaLightning", "Tesla Lightning Aura (Разряды молний)", function(state)
    Disconnect("Tesla")
    ClearVisual("Tesla")
    if state then
        local folder = Instance.new("Folder", Workspace)
        VisualObjects.Tesla = folder
        local bolts = {}
        for i = 1, 6 do
            local p0 = Instance.new("Part", folder)
            p0.Size = Vector3.new(0.1, 0.1, 0.1)
            p0.Transparency = 1
            p0.Anchored = true
            p0.CanCollide = false
            p0.CanQuery = false
            local a0 = Instance.new("Attachment", p0)

            local p1 = p0:Clone()
            p1.Parent = folder
            local a1 = p1:FindFirstChildOfClass("Attachment")

            local beam = Instance.new("Beam", folder)
            beam.Attachment0 = a0
            beam.Attachment1 = a1
            beam.Width0 = 0.12
            beam.Width1 = 0.04
            beam.LightEmission = 1
            beam.Color = ColorSequence.new(Theme.Accent)
            bolts[i] = {p0 = p0, p1 = p1, beam = beam}
        end
        Connections.Tesla = RunService.RenderStepped:Connect(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, b in ipairs(bolts) do
                    b.p0.Position = hrp.Position + Vector3.new(math.random(-25, 25) / 10, math.random(-25, 25) / 10, math.random(-25, 25) / 10)
                    b.p1.Position = hrp.Position + Vector3.new(math.random(-35, 35) / 10, math.random(-25, 30) / 10, math.random(-35, 35) / 10)
                end
            end
        end)
    end
end)

AddCheckbox(Card3DAuras, "OrbitPlanets", "Orbiting Neon Spheres", function(state)
    Disconnect("Planets")
    ClearVisual("Planets")
    if state then
        local folder = Instance.new("Folder", Workspace)
        VisualObjects.Planets = folder
        local spheres = {}
        for i = 1, 3 do
            local s = Instance.new("Part", folder)
            s.Shape = Enum.PartType.Ball
            s.Size = Vector3.new(0.65, 0.65, 0.65)
            s.Material = Enum.Material.Neon
            s.Color = Theme.Accent
            s.Anchored = true
            s.CanCollide = false
            s.CanQuery = false
            spheres[i] = s
        end
        local t = 0
        Connections.Planets = RunService.RenderStepped:Connect(function(dt)
            t = t + dt * 2.5
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for i, s in ipairs(spheres) do
                    s.Color = Theme.Accent
                    local a = t + (i * math.pi * 2 / 3)
                    s.Position = hrp.Position + Vector3.new(math.cos(a) * 3.5, math.sin(a * 1.5) * 2, math.sin(a) * 3.5)
                end
            end
        end)
    end
end)

AddCheckbox(Card3DAuras, "PointLightGlow", "Character Neon PointLight (Свечение)", function(state)
    ClearVisual("CharLight")
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if state and hrp then
        local pl = Instance.new("PointLight", hrp)
        pl.Range = 22
        pl.Brightness = 3.5
        pl.Color = Theme.Accent
        VisualObjects.CharLight = pl
    end
end)

-------------------------------------------------------------------------
-- 3. VISUALS -> TRAILS & WEATHER (Шлейфы, Шаги, Погода)
-------------------------------------------------------------------------
local CardTrails  = CreateCard(PageVisTrails, "Left", "🌠 Trails, Footsteps & Clones", true)
local CardWeather = CreateCard(PageVisTrails, "Right", "🌧 World Weather & Particles", true)

AddCheckbox(CardTrails, "NeonRibbonTrail", "Dual Neon Ribbon Trails (Шлейф)", function(state)
    ClearVisual("RibbonTrails")
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if state and hrp then
        local a0 = Instance.new("Attachment", hrp)
        a0.Position = Vector3.new(0, 1.5, 0)
        local a1 = Instance.new("Attachment", hrp)
        a1.Position = Vector3.new(0, -1.5, 0)
        local tr = Instance.new("Trail", hrp)
        tr.Attachment0 = a0
        tr.Attachment1 = a1
        tr.Lifetime = 0.75
        tr.LightEmission = 1
        tr.Color = ColorSequence.new(Theme.Accent)
        tr.Transparency = NumberSequence.new(0.1, 1)
        VisualObjects.RibbonTrails = {a0, a1, tr}
    end
end)

AddCheckbox(CardTrails, "GhostTrail", "Afterimage Ghost Clones (Клоны при беге)", function()
    task.spawn(function()
        while State.GhostTrail do
            SafeCall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Velocity.Magnitude > 2 then
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            local g = Instance.new("Part", Workspace)
                            g.Size = part.Size
                            g.CFrame = part.CFrame
                            g.Anchored = true
                            g.CanCollide = false
                            g.CanQuery = false
                            g.Material = Enum.Material.Neon
                            g.Color = Theme.Accent
                            g.Transparency = 0.62
                            TweenService:Create(g, TweenInfo.new(0.38), {Transparency = 1}):Play()
                            Debris:AddItem(g, 0.38)
                        end
                    end
                end
            end)
            task.wait(0.16)
        end
    end)
end)

AddCheckbox(CardTrails, "JumpRings", "Jump & Step Shockwave Rings", function()
    task.spawn(function()
        while State.JumpRings do
            SafeCall(function()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Velocity.Magnitude > 2 then
                    local ring = Instance.new("Part", Workspace)
                    ring.Size = Vector3.new(1, 0.08, 1)
                    ring.CFrame = hrp.CFrame * CFrame.new(0, -2.8, 0)
                    ring.Anchored = true
                    ring.CanCollide = false
                    ring.CanQuery = false
                    ring.Material = Enum.Material.Neon
                    ring.Color = Theme.Accent
                    Instance.new("CylinderMesh", ring)
                    TweenService:Create(ring, TweenInfo.new(0.55), {Size = Vector3.new(6.5, 0.02, 6.5), Transparency = 1}):Play()
                    Debris:AddItem(ring, 0.55)
                end
            end)
            task.wait(0.24)
        end
    end)
end)

AddCheckbox(CardTrails, "FireFootsteps", "Neon Flame Footsteps (Следы шагов)", function()
    task.spawn(function()
        while State.FireFootsteps do
            SafeCall(function()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Velocity.Magnitude > 2 then
                    local pad = Instance.new("Part", Workspace)
                    pad.Size = Vector3.new(1.2, 0.1, 1.2)
                    pad.CFrame = hrp.CFrame * CFrame.new(math.random(-1, 1) * 0.6, -2.85, 0)
                    pad.Anchored = true
                    pad.CanCollide = false
                    pad.CanQuery = false
                    pad.Material = Enum.Material.Neon
                    pad.Color = Theme.Accent
                    TweenService:Create(pad, TweenInfo.new(0.7), {Size = Vector3.new(0.1, 0.1, 0.1), Transparency = 1}):Play()
                    Debris:AddItem(pad, 0.7)
                end
            end)
            task.wait(0.14)
        end
    end)
end)

local function SpawnWeatherEmitter(connName, visName, state, col1, col2, speedRange, sizeVal)
    Disconnect(connName)
    ClearVisual(visName)
    if state then
        local cloud = Instance.new("Part", Workspace)
        cloud.Size = Vector3.new(75, 1, 75)
        cloud.Transparency = 1
        cloud.Anchored = true
        cloud.CanCollide = false
        cloud.CanQuery = false
        VisualObjects[visName] = cloud
        local p = Instance.new("ParticleEmitter", cloud)
        p.Rate = 95
        p.Lifetime = NumberRange.new(4, 6)
        p.Speed = speedRange
        p.EmissionDirection = Enum.NormalId.Bottom
        p.Size = NumberSequence.new(sizeVal)
        p.Color = ColorSequence.new(col1, col2)
        p.LightEmission = 0.9
        Connections[connName] = RunService.RenderStepped:Connect(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then cloud.Position = hrp.Position + Vector3.new(0, 26, 0) end
        end)
    end
end

AddCheckbox(CardWeather, "SakuraWeather", "Sakura Petals Rain (Сакура)", function(state)
    SpawnWeatherEmitter("Sakura", "SakuraCloud", state, Color3.fromRGB(255, 150, 215), Color3.fromRGB(255, 225, 245), NumberRange.new(6, 11), 0.34)
end)

AddCheckbox(CardWeather, "SnowWeather", "Starry Snowfall (Звёздный снег)", function(state)
    SpawnWeatherEmitter("Snow", "SnowCloud", state, Color3.fromRGB(255, 255, 255), Color3.fromRGB(185, 225, 255), NumberRange.new(8, 14), 0.28)
end)

AddCheckbox(CardWeather, "NeonRain", "Cyberpunk Acid Rain (Неоновый дождь)", function(state)
    SpawnWeatherEmitter("NeonRain", "RainCloud", state, Color3.fromRGB(130, 195, 255), Color3.fromRGB(210, 140, 255), NumberRange.new(25, 35), 0.2)
end)

AddCheckbox(CardWeather, "VoidAsh", "Floating Void Ash (Пепел Бездны)", function(state)
    SpawnWeatherEmitter("VoidAsh", "AshCloud", state, Color3.fromRGB(220, 220, 235), Color3.fromRGB(90, 90, 110), NumberRange.new(3, 6), 0.24)
end)

AddCheckbox(CardWeather, "StarfallWeather", "Cosmic Shooting Stars (Звездопад)", function(state)
    SpawnWeatherEmitter("Starfall", "StarCloud", state, Color3.fromRGB(255, 245, 160), Color3.fromRGB(130, 210, 255), NumberRange.new(32, 48), 0.42)
end)

-------------------------------------------------------------------------
-- 4. VISUALS -> ESP, RADAR 2D & FAKE ITEMS (ЗАЩИЩЁННЫЙ ПУЛ ОБЪЕКТОВ БЕЗ КРАШЕЙ)
-------------------------------------------------------------------------
local CardESP  = CreateCard(PageVisESP, "Left", "👁 Pooled ESP, 2D Boxes & Radar", true)
local CardFake = CreateCard(PageVisESP, "Right", "🎭 Fake Items & Body Chams", true)

AddCheckbox(CardESP, "Radar2D", "2D Mini-Radar HUD (Мини-радар сверху)", function(val)
    RadarFrame.Visible = val
end)

AddCheckbox(CardESP, "HighlightESP", "Highlight Chams ESP", function(state)
    if not state then
        for _, plr in ipairs(Players:GetPlayers()) do
            SafeCall(function()
                if plr.Character and plr.Character:FindFirstChild("FH_HL") then
                    plr.Character.FH_HL:Destroy()
                end
            end)
        end
    else
        task.spawn(function()
            while State.HighlightESP do
                for _, plr in ipairs(Players:GetPlayers()) do
                    SafeCall(function()
                        if plr ~= LocalPlayer and plr.Character and not plr.Character:FindFirstChild("FH_HL") then
                            local hl = Instance.new("Highlight", plr.Character)
                            hl.Name = "FH_HL"
                            hl.FillColor = Theme.Accent
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.55
                        end
                    end)
                end
                task.wait(0.9)
            end
        end)
    end
end)

AddCheckbox(CardESP, "NameESP", "Name, Distance & HP Tags", function(state)
    if not state then
        for _, plr in ipairs(Players:GetPlayers()) do
            SafeCall(function()
                if plr.Character and plr.Character:FindFirstChild("Head") and plr.Character.Head:FindFirstChild("FH_Tag") then
                    plr.Character.Head.FH_Tag:Destroy()
                end
            end)
        end
    else
        task.spawn(function()
            while State.NameESP do
                for _, plr in ipairs(Players:GetPlayers()) do
                    SafeCall(function()
                        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                            local head = plr.Character.Head
                            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                            local tag = head:FindFirstChild("FH_Tag")
                            if not tag then
                                tag = Instance.new("BillboardGui", head)
                                tag.Name = "FH_Tag"
                                tag.Size = UDim2.new(0, 150, 0, 26)
                                tag.StudsOffset = Vector3.new(0, 2.6, 0)
                                tag.AlwaysOnTop = true
                                local txt = Instance.new("TextLabel", tag)
                                txt.Name = "Lbl"
                                txt.Size = UDim2.new(1, 0, 1, 0)
                                txt.BackgroundTransparency = 1
                                txt.TextColor3 = Theme.TextWhite
                                txt.TextStrokeTransparency = 0.15
                                txt.Font = Enum.Font.Code
                                txt.TextSize = 12
                            end
                            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local dist = myHrp and math.floor((myHrp.Position - head.Position).Magnitude) or 0
                            local hp = hum and math.floor(hum.Health) or 100
                            tag.Lbl.Text = string.format("%s [%dm] (%dHP)", plr.DisplayName, dist, hp)
                        end
                    end)
                end
                task.wait(0.22)
            end
        end)
    end
end)

AddCheckbox(CardESP, "Box2DESP", "2D Box & HealthBar ESP (Боксы)", function(state)
    if not state then
        for _, plr in ipairs(Players:GetPlayers()) do
            SafeCall(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.HumanoidRootPart:FindFirstChild("FH_Box2D") then
                    plr.Character.HumanoidRootPart.FH_Box2D:Destroy()
                end
            end)
        end
    else
        task.spawn(function()
            while State.Box2DESP do
                for _, plr in ipairs(Players:GetPlayers()) do
                    SafeCall(function()
                        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            local hrp = plr.Character.HumanoidRootPart
                            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                            local bGui = hrp:FindFirstChild("FH_Box2D")
                            if not bGui then
                                bGui = Instance.new("BillboardGui", hrp)
                                bGui.Name = "FH_Box2D"
                                bGui.Size = UDim2.new(4.4, 0, 5.8, 0)
                                bGui.AlwaysOnTop = true

                                local boxFrame = Instance.new("Frame", bGui)
                                boxFrame.Size = UDim2.new(1, -8, 1, 0)
                                boxFrame.Position = UDim2.new(0, 8, 0, 0)
                                boxFrame.BackgroundTransparency = 0.88
                                boxFrame.BackgroundColor3 = Theme.Accent
                                local st = Instance.new("UIStroke", boxFrame)
                                st.Color = Theme.Accent
                                st.Thickness = 1.4

                                local hpBg = Instance.new("Frame", bGui)
                                hpBg.Name = "HpBg"
                                hpBg.Size = UDim2.new(0, 4, 1, 0)
                                hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                                hpBg.BorderSizePixel = 0

                                local hpFill = Instance.new("Frame", hpBg)
                                hpFill.Name = "Fill"
                                hpFill.Size = UDim2.new(1, 0, 1, 0)
                                hpFill.AnchorPoint = Vector2.new(0, 1)
                                hpFill.Position = UDim2.new(0, 0, 1, 0)
                                hpFill.BackgroundColor3 = Theme.Success
                                hpFill.BorderSizePixel = 0
                            end
                            if hum and bGui:FindFirstChild("HpBg") then
                                local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                                bGui.HpBg.Fill.Size = UDim2.new(1, 0, pct, 0)
                            end
                        end
                    end)
                end
                task.wait(0.22)
            end
        end)
    end
end)

AddCheckbox(CardESP, "HeadDotESP", "Neon Head Dot ESP (Точка на голове)", function(state)
    if not state then
        for _, plr in ipairs(Players:GetPlayers()) do
            SafeCall(function()
                if plr.Character and plr.Character:FindFirstChild("Head") and plr.Character.Head:FindFirstChild("FH_HeadDot") then
                    plr.Character.Head.FH_HeadDot:Destroy()
                end
            end)
        end
    else
        task.spawn(function()
            while State.HeadDotESP do
                for _, plr in ipairs(Players:GetPlayers()) do
                    SafeCall(function()
                        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                            local head = plr.Character.Head
                            if not head:FindFirstChild("FH_HeadDot") then
                                local bg = Instance.new("BillboardGui", head)
                                bg.Name = "FH_HeadDot"
                                bg.Size = UDim2.new(0, 10, 0, 10)
                                bg.AlwaysOnTop = true
                                local dot = Instance.new("Frame", bg)
                                dot.Size = UDim2.new(1, 0, 1, 0)
                                dot.BackgroundColor3 = Theme.Accent
                                Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
                                Instance.new("UIStroke", dot).Color = Color3.fromRGB(0, 0, 0)
                            end
                        end
                    end)
                end
                task.wait(0.8)
            end
        end)
    end
end)

-- БЕЗОПАСНЫЙ ПУЛ ДЛЯ ЛАЗЕРОВ ВЗГЛЯДА (НЕ КРАШИТ И НЕ ВЫЗЫВАЕТ ClearAllChildren!)
local LookLaserPool = {}
AddCheckbox(CardESP, "LookLaserESP", "Enemy Look Direction Laser (Pooled)", function(state)
    Disconnect("LookLasers")
    ClearVisual("LookLaserFolder")
    table.clear(LookLaserPool)
    if state then
        local folder = Instance.new("Folder", Workspace)
        folder.Name = "FH_PooledLasers"
        VisualObjects.LookLaserFolder = folder
        Connections.LookLasers = RunService.RenderStepped:Connect(function()
            local active = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    active[plr] = true
                    local head = plr.Character.Head
                    local laser = LookLaserPool[plr]
                    if not laser or not laser.Parent then
                        laser = Instance.new("Part", folder)
                        laser.Size = Vector3.new(0.08, 0.08, 12)
                        laser.Material = Enum.Material.Neon
                        laser.Anchored = true
                        laser.CanCollide = false
                        laser.CanQuery = false
                        LookLaserPool[plr] = laser
                    end
                    laser.Color = Theme.Accent
                    laser.Transparency = 0.25
                    laser.CFrame = head.CFrame * CFrame.new(0, 0, -6)
                end
            end
            for plr, laser in pairs(LookLaserPool) do
                if not active[plr] and laser then
                    laser.Transparency = 1
                end
            end
        end)
    end
end)

-- БЕЗОПАСНЫЙ ПУЛ ДЛЯ 3D ТРЕЙСЕРОВ (БЕЗ ПЕРЕСОЗДАНИЯ BEAM КАЖДЫЙ КАДР!)
local TracerBeamPool = {}
AddCheckbox(CardESP, "TracersESP", "3D Beam Tracers to Players (Pooled)", function(state)
    Disconnect("Tracers")
    ClearVisual("TracersFolder")
    table.clear(TracerBeamPool)
    if state then
        local folder = Instance.new("Folder", Workspace)
        folder.Name = "FH_PooledTracers"
        VisualObjects.TracersFolder = folder
        Connections.Tracers = RunService.RenderStepped:Connect(function()
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myHrp then return end
            local a0 = myHrp:FindFirstChild("FH_TracerAtt")
            if not a0 then
                a0 = Instance.new("Attachment", myHrp)
                a0.Name = "FH_TracerAtt"
            end
            local active = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    active[plr] = true
                    local tHrp = plr.Character.HumanoidRootPart
                    local a1 = tHrp:FindFirstChild("FH_TracerAtt")
                    if not a1 then
                        a1 = Instance.new("Attachment", tHrp)
                        a1.Name = "FH_TracerAtt"
                    end
                    local beam = TracerBeamPool[plr]
                    if not beam or not beam.Parent then
                        beam = Instance.new("Beam", folder)
                        beam.Width0 = 0.06
                        beam.Width1 = 0.06
                        beam.LightEmission = 1
                        beam.FaceCamera = true
                        TracerBeamPool[plr] = beam
                    end
                    beam.Enabled = true
                    beam.Attachment0 = a0
                    beam.Attachment1 = a1
                    beam.Color = ColorSequence.new(Theme.Accent)
                end
            end
            for plr, beam in pairs(TracerBeamPool) do
                if not active[plr] and beam then
                    beam.Enabled = false
                end
            end
        end)
    end
end)

AddCheckbox(CardESP, "DamagePopupESP", "3D Floating Damage Popups (Цифры урона)", function(state)
    Disconnect("DamagePopups")
    if state then
        local lastHpMap = {}
        Connections.DamagePopups = RunService.Heartbeat:Connect(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local prev = lastHpMap[plr] or hum.Health
                        if hum.Health < prev and (prev - hum.Health) >= 1 then
                            local dmg = math.floor(prev - hum.Health)
                            local p = Instance.new("Part", Workspace)
                            p.Size = Vector3.new(0.2, 0.2, 0.2)
                            p.Position = plr.Character.Head.Position + Vector3.new(math.random(-2, 2), 1.5, math.random(-2, 2))
                            p.Transparency = 1
                            p.Anchored = true
                            p.CanCollide = false
                            p.CanQuery = false
                            local bg = Instance.new("BillboardGui", p)
                            bg.Size = UDim2.new(0, 80, 0, 28)
                            bg.AlwaysOnTop = true
                            local txt = Instance.new("TextLabel", bg)
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.Text = "-" .. tostring(dmg) .. " HP"
                            txt.TextColor3 = Theme.Danger
                            txt.TextStrokeTransparency = 0
                            txt.Font = Enum.Font.GothamBold
                            txt.TextSize = 14
                            QuickTween(p, 0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
                                Position = p.Position + Vector3.new(0, 4.2, 0)
                            })
                            Debris:AddItem(p, 0.8)
                        end
                        lastHpMap[plr] = hum.Health
                    end
                end
            end
        end)
    end
end)

-- Правая колонка: Fake Items & Body Chams
AddCheckbox(CardFake, "FakeHeadless", "Fake Headless (Невидимая голова)", function(state)
    SafeCall(function()
        local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
        if head then
            head.Transparency = state and 1 or 0
            for _, d in ipairs(head:GetChildren()) do
                if d:IsA("Decal") then d.Transparency = state and 1 or 0 end
            end
        end
    end)
    Refresh3DPreview()
end)

AddCheckbox(CardFake, "FakeKorblox", "Fake Korblox (Правая нога)", function(state)
    SafeCall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, n in ipairs({"RightLowerLeg", "RightFoot", "Right Leg"}) do
            local p = char:FindFirstChild(n)
            if p and p:IsA("BasePart") then p.Transparency = state and 1 or 0 end
        end
    end)
    Refresh3DPreview()
end)

AddCheckbox(CardFake, "SelfChams", "ForceField Material Body", function(state)
    SafeCall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetChildren()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.Material = state and Enum.Material.ForceField or Enum.Material.Plastic
            end
        end
    end)
    Refresh3DPreview()
end)

AddCheckbox(CardFake, "RainbowBody", "Rainbow Neon Body (Радуга)", function(state)
    Disconnect("RainbowBody")
    local char = LocalPlayer.Character
    if state and char then
        Connections.RainbowBody = RunService.RenderStepped:Connect(function()
            local col = Color3.fromHSV((tick() * 0.28) % 1, 0.65, 1)
            if LocalPlayer.Character then
                for _, p in ipairs(LocalPlayer.Character:GetChildren()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                        p.Color = col
                    end
                end
            end
        end)
    end
end)

AddCheckbox(CardFake, "GhostBody", "Semi-Transparent Ghost Body", function(state)
    SafeCall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetChildren()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "Head" then
                p.Transparency = state and 0.55 or 0
            end
        end
    end)
    Refresh3DPreview()
end)

-------------------------------------------------------------------------
-- [ PART 5 / 5 : MOVEMENT, R15 PACKS, EMOTES, DESYNC, COLORS & START ]
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- 1. MISC -> MOVEMENT & FLY (ПОЛЁТ, ПАРКУР, CLICK TP, СПИНБОТ, КАМЕРА)
-------------------------------------------------------------------------
local CardMoveLeft  = CreateCard(PageMiscMove, "Left", "🚀 Fly, Noclip & Parkour", true)
local CardMoveRight = CreateCard(PageMiscMove, "Right", "⚡ Speed, Spinbot & Camera", true)

AddCheckbox(CardMoveLeft, "Fly", "Fly (Mobile Joystick & PC WASD)", function(state)
    Disconnect("Fly")
    ClearVisual("FlyPhysics")
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if state and hrp and hum then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.zero
        local bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 9e4
        bg.CFrame = Camera.CFrame
        VisualObjects.FlyPhysics = {bv, bg}
        hum.PlatformStand = true
        Connections.Fly = RunService.RenderStepped:Connect(function()
            if not hrp or not hum then return end
            bg.CFrame = Camera.CFrame
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                local camCF = Camera.CFrame
                local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
                if flatLook.Magnitude > 0.001 then
                    flatLook = flatLook.Unit
                end
                local fDot = flatLook:Dot(moveDir)
                local rDot = camCF.RightVector:Dot(moveDir)
                bv.Velocity = (camCF.LookVector * fDot + camCF.RightVector * rDot) * State.FlySpeed
            else
                bv.Velocity = Vector3.zero
            end
        end)
    else
        if hum then hum.PlatformStand = false end
    end
end)

AddSlider(CardMoveLeft, "FlySpeed", "Fly Speed", 16, 220)

AddCheckbox(CardMoveLeft, "Noclip", "Noclip (Проход сквозь стены)", function(state)
    Disconnect("Noclip")
    if state then
        Connections.Noclip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

AddCheckbox(CardMoveLeft, "Bhop", "Auto Bhop (Авто-распрыжка)", function(state)
    Disconnect("Bhop")
    if state then
        Connections.Bhop = RunService.RenderStepped:Connect(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0 and hum.FloorMaterial ~= Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

AddCheckbox(CardMoveLeft, "Wallhop", "Wallhop (Отскок от стен)", function(state)
    Disconnect("Wallhop")
    if state then
        Connections.Wallhop = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {char}
                params.FilterType = Enum.RaycastFilterType.Exclude
                if Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 3.2, params) then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 54, hrp.Velocity.Z) - (hrp.CFrame.LookVector * 18)
                end
            end
        end)
    end
end)

AddCheckbox(CardMoveLeft, "AirWalk", "Air Walk Platform (Ходить по воздуху)", function(state)
    Disconnect("AirWalk")
    ClearVisual("AirWalkPart")
    if state then
        local plat = Instance.new("Part", Workspace)
        plat.Size = Vector3.new(7, 0.4, 7)
        plat.Material = Enum.Material.Neon
        plat.Color = Theme.Accent
        plat.Transparency = 0.65
        plat.Anchored = true
        plat.CanQuery = false
        VisualObjects.AirWalkPart = plat
        Connections.AirWalk = RunService.RenderStepped:Connect(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                plat.Color = Theme.Accent
                plat.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - 3.1, hrp.Position.Z)
            end
        end)
    end
end)

AddCheckbox(CardMoveLeft, "SpiderClimb", "Spider Wall Climb (Лазать по стенам)", function(state)
    Disconnect("SpiderClimb")
    if state then
        Connections.SpiderClimb = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {char}
                params.FilterType = Enum.RaycastFilterType.Exclude
                if Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 2.5, params) then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 28, hrp.Velocity.Z)
                end
            end
        end)
    end
end)

AddCheckbox(CardMoveLeft, "InfiniteJump", "Infinite Jump (Бесконечный прыжок)", function(state)
    Disconnect("InfJump")
    if state then
        Connections.InfJump = UserInputService.JumpRequest:Connect(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

-- НОВОЕ: Click TP (Телепорт туда, куда нажал с зажатым Ctrl или тапом при закрытом меню)
AddCheckbox(CardMoveLeft, "ClickTP", "Click / Touch Teleport (Ctrl + Click)", function(state)
    Disconnect("ClickTP")
    if state then
        Connections.ClickTP = Mouse.Button1Down:Connect(function()
            if not MasterFrame.Visible or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and Mouse.Hit then
                    hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3.2, 0))
                end
            end
        end)
    end
end)

-- Правая колонка движения
AddCheckbox(CardMoveRight, "WalkSpeedOn", "Enable WalkSpeed", function(state)
    Disconnect("WalkSpeed")
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if state then
        Connections.WalkSpeed = RunService.RenderStepped:Connect(function()
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = State.WalkSpeed end
        end)
    elseif hum then
        hum.WalkSpeed = 16
    end
end)

AddSlider(CardMoveRight, "WalkSpeed", "WalkSpeed Value", 16, 180)

AddCheckbox(CardMoveRight, "JumpPowerOn", "Enable JumpPower", function(state)
    Disconnect("JumpPower")
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if state then
        Connections.JumpPower = RunService.RenderStepped:Connect(function()
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h.UseJumpPower = true h.JumpPower = State.JumpPower end
        end)
    elseif hum then
        hum.JumpPower = 50
    end
end)

AddSlider(CardMoveRight, "JumpPower", "JumpPower Value", 50, 220)

AddCheckbox(CardMoveRight, "Spinbot", "Smooth Spinbot 360°", function(state)
    ClearVisual("SpinBAV")
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if state and hrp and hum then
        hum.AutoRotate = false
        local bav = Instance.new("BodyAngularVelocity", hrp)
        bav.MaxTorque = Vector3.new(0, math.huge, 0)
        bav.AngularVelocity = Vector3.new(0, State.SpinSpeed, 0)
        VisualObjects.SpinBAV = bav
    else
        if hum then hum.AutoRotate = true end
    end
end)

AddSlider(CardMoveRight, "SpinSpeed", "Spinbot Speed", 10, 140, function(val)
    if VisualObjects.SpinBAV then
        VisualObjects.SpinBAV.AngularVelocity = Vector3.new(0, val, 0)
    end
end)

AddCheckbox(CardMoveRight, "AspectRatioOn", "Aspect Ratio (Растяг 4:3)", function(state)
    Disconnect("Aspect")
    if state then
        Connections.Aspect = RunService.RenderStepped:Connect(function()
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, State.AspectRatio / 100, 0, 0, 0, 1)
        end)
    end
end)

AddSlider(CardMoveRight, "AspectRatio", "Aspect Ratio Stretch (%)", 50, 100)

AddCheckbox(CardMoveRight, "CustomFOVOn", "Custom FOV (Поле зрения)", function(state)
    Disconnect("FOV")
    if state then
        Connections.FOV = RunService.RenderStepped:Connect(function()
            Camera.FieldOfView = State.CustomFOV
        end)
    else
        Camera.FieldOfView = 70
    end
end)

AddSlider(CardMoveRight, "CustomFOV", "Camera FOV Value", 70, 120)

-------------------------------------------------------------------------
-- 2. MISC -> R15 ANIM PACKS (16 ПОЛНЫХ ПАКОВ АНИМАЦИИ ПОХОДКИ)
-------------------------------------------------------------------------
local CardPacks1 = CreateCard(PageMiscPacks, "Left", "🕺 R15 Animation Packs (1 - 8)", true)
local CardPacks2 = CreateCard(PageMiscPacks, "Right", "🎭 R15 Animation Packs (9 - 16)", true)

local function SetAnimPack(packName, idle1, walk, run, jump, fall)
    SafeCall(function()
        local anim = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Animate")
        if anim then
            anim.Disabled = true
            anim.idle.Animation1.AnimationId = "rbxassetid://" .. tostring(idle1)
            anim.walk.WalkAnim.AnimationId = "rbxassetid://" .. tostring(walk)
            anim.run.RunAnim.AnimationId = "rbxassetid://" .. tostring(run)
            anim.jump.JumpAnim.AnimationId = "rbxassetid://" .. tostring(jump)
            anim.fall.FallAnim.AnimationId = "rbxassetid://" .. tostring(fall)
            anim.Disabled = false
            Notify("Animation Pack", "Equipped: " .. packName, 1.5)
        end
    end)
end

AddButton(CardPacks1, "✨ Pack: Levitation (Левитация)", function() SetAnimPack("Levitation", 616006778, 616013216, 616010382, 616008936, 616005863) end)
AddButton(CardPacks1, "🦇 Pack: Vampire (Вампир)", function() SetAnimPack("Vampire", 1083445855, 1083473930, 1083462077, 1083455352, 1083443587) end)
AddButton(CardPacks1, "🥷 Pack: Ninja (Ниндзя)", function() SetAnimPack("Ninja", 656117400, 656121766, 656118852, 656117878, 656115606) end)
AddButton(CardPacks1, "🔮 Pack: Mage (Маг)", function() SetAnimPack("Mage", 707742142, 707897309, 707861613, 707853694, 707829716) end)
AddButton(CardPacks1, "🧟 Pack: Zombie (Зомби)", function() SetAnimPack("Zombie", 616158929, 616168032, 616163682, 616161997, 616157476) end)
AddButton(CardPacks1, "🚀 Pack: Astronaut (Астронавт)", function() SetAnimPack("Astronaut", 891621366, 891636393, 891636393, 891627522, 891617961) end)
AddButton(CardPacks1, "🐺 Pack: Werewolf (Оборотень)", function() SetAnimPack("Werewolf", 1083195517, 1083178339, 1083216690, 1083218792, 1083189019) end)
AddButton(CardPacks1, "🦸 Pack: Superhero (Супергерой)", function() SetAnimPack("Superhero", 616111295, 616122287, 616117076, 616115533, 616108001) end)

AddButton(CardPacks2, "🎭 Pack: Cartoony (Мультяшный)", function() SetAnimPack("Cartoony", 742637544, 742640026, 742638842, 742637942, 742637151) end)
AddButton(CardPacks2, "⚔️ Pack: Knight (Рыцарь)", function() SetAnimPack("Knight", 657595757, 657552124, 657564596, 658409194, 657600338) end)
AddButton(CardPacks2, "🏴‍☠️ Pack: Pirate (Пират)", function() SetAnimPack("Pirate", 750781874, 750785693, 750783738, 750782230, 750780242) end)
AddButton(CardPacks2, "💅 Pack: Stylish (Стильный)", function() SetAnimPack("Stylish", 616136790, 616146177, 616140816, 616139451, 616134815) end)
AddButton(CardPacks2, "🤖 Pack: Robot (Робот)", function() SetAnimPack("Robot", 616088211, 616095330, 616091570, 616090535, 616087089) end)
AddButton(CardPacks2, "🧸 Pack: Toy (Игрушка)", function() SetAnimPack("Toy", 782841498, 782843345, 782842708, 782847020, 782846423) end)
AddButton(CardPacks2, "🕹️ Pack: Oldschool (Олдскул)", function() SetAnimPack("Oldschool", 5319828216, 5319847204, 5319844329, 5319841935, 5319839762) end)
AddButton(CardPacks2, "🫧 Pack: Bubbly (Воздушный)", function() SetAnimPack("Bubbly", 910004836, 910034870, 910025107, 910016857, 910001910) end)

-------------------------------------------------------------------------
-- 3. MISC -> EMOTES & TRICKS (ТАНЦЫ, ЭМОЦИИ, САЛЬТО, МОДИФИКАТОРЫ)
-------------------------------------------------------------------------
local CardEmotes = CreateCard(PageMiscEmotes, "Left", "💃 Dances & Emotes Player", true)
local CardTricks = CreateCard(PageMiscEmotes, "Right", "🤸 Procedural Tricks & Anims", true)

local function PlayDirectEmote(emoteName, animId, looped)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if ActiveEmoteTrack then
        SafeCall(function() ActiveEmoteTrack:Stop() end)
        ActiveEmoteTrack = nil
    end
    SafeCall(function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. tostring(animId)
        local track = hum:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action
        track.Looped = (looped ~= false)
        track:Play()
        ActiveEmoteTrack = track
        Notify("Emote Player", "Playing: " .. emoteName, 1.4)
    end)
end

AddButton(CardEmotes, "💃 Dance: Floss Dance", function() PlayDirectEmote("Floss", 5917459365, true) end)
AddButton(CardEmotes, "🐬 Dance: Dolphin Dance", function() PlayDirectEmote("Dolphin", 5918726674, true) end)
AddButton(CardEmotes, "🕺 Dance: Classic Dance 1", function() PlayDirectEmote("Dance 1", 507771019, true) end)
AddButton(CardEmotes, "🔥 Dance: Hype Dance 2", function() PlayDirectEmote("Dance 2", 507776043, true) end)
AddButton(CardEmotes, "🎶 Dance: Groove Dance 3", function() PlayDirectEmote("Dance 3", 507777268, true) end)
AddButton(CardEmotes, "🫡 Emote: Military Salute", function() PlayDirectEmote("Salute", 3360689775, false) end)
AddButton(CardEmotes, "🤷 Emote: Shrug", function() PlayDirectEmote("Shrug", 3360692915, false) end)
AddButton(CardEmotes, "🎉 Emote: Cheer", function() PlayDirectEmote("Cheer", 507770677, false) end)
AddButton(CardEmotes, "😂 Emote: Laugh", function() PlayDirectEmote("Laugh", 507770818, false) end)
AddButton(CardEmotes, "⏹️ Stop Current Emote", function()
    if ActiveEmoteTrack then
        SafeCall(function() ActiveEmoteTrack:Stop() end)
        ActiveEmoteTrack = nil
    end
    Notify("Emote Player", "Stopped emote", 1.3)
end)

AddButton(CardTricks, "🤸 Do 360° Backflip (Сальто назад)", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        hum.Sit = true
        hrp.Velocity = Vector3.new(hrp.Velocity.X, 46, hrp.Velocity.Z) - (hrp.CFrame.LookVector * 14)
        for _ = 1, 24 do
            if not hrp.Parent then break end
            hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(15), 0, 0)
            RunService.RenderStepped:Wait()
        end
        hum.Sit = false
    end
end)

AddButton(CardTricks, "⚡ Do 360° Frontflip (Сальто вперёд)", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        hum.Sit = true
        hrp.Velocity = Vector3.new(hrp.Velocity.X, 46, hrp.Velocity.Z) + (hrp.CFrame.LookVector * 16)
        for _ = 1, 24 do
            if not hrp.Parent then break end
            hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(-15), 0, 0)
            RunService.RenderStepped:Wait()
        end
        hum.Sit = false
    end
end)

AddCheckbox(CardTricks, "MatrixLean", "Matrix Dodge Lean (Наклон Матрицы)", function(state)
    SafeCall(function()
        local char = LocalPlayer.Character
        local lowerTorso = char and char:FindFirstChild("LowerTorso")
        local rootJoint = (lowerTorso and lowerTorso:FindFirstChild("Root")) or (char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("RootJoint"))
        if rootJoint then
            rootJoint.C0 = state and (rootJoint.C0 * CFrame.Angles(math.rad(-42), 0, 0)) or CFrame.new(0, 0, 0)
        end
    end)
end)

AddCheckbox(CardTricks, "HelicopterTilt", "Helicopter Horizontal Spin", function(state)
    Disconnect("HeliSpin")
    local char = LocalPlayer.Character
    local lowerTorso = char and char:FindFirstChild("LowerTorso")
    local rootJoint = (lowerTorso and lowerTorso:FindFirstChild("Root")) or (char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("RootJoint"))
    if state and rootJoint then
        local a = 0
        Connections.HeliSpin = RunService.RenderStepped:Connect(function(dt)
            a = a + dt * 18
            if rootJoint and rootJoint.Parent then
                rootJoint.C0 = CFrame.Angles(math.rad(85), 0, a)
            end
        end)
    elseif rootJoint then
        rootJoint.C0 = CFrame.new(0, 0, 0)
    end
end)

AddCheckbox(CardTricks, "HyperAnims", "Hyper Speed Anims (3.8x)", function(state)
    Disconnect("HyperAnim")
    if state then
        Connections.HyperAnim = RunService.RenderStepped:Connect(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(3.8) end
            end
        end)
    end
end)

AddCheckbox(CardTricks, "SlowAnims", "Slow-Motion Anims (0.2x)", function(state)
    Disconnect("SlowAnim")
    if state then
        Connections.SlowAnim = RunService.RenderStepped:Connect(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(0.2) end
            end
        end)
    end
end)

AddCheckbox(CardTricks, "FreezePose", "Freeze Current Pose (Застыть)", function(state)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(state and 0 or 1) end
    end
end)

-------------------------------------------------------------------------
-- 4. MISC -> DESYNC & TARGET (ДЕСИНКИ, ЗАЩИТА, АВТООБНОВЛЯЕМЫЙ ТАРГЕТ)
-------------------------------------------------------------------------
local CardDesync = CreateCard(PageMiscTarget, "Left", "🛡 Desync & Character Guard", true)
local CardTarget = CreateCard(PageMiscTarget, "Right", "🎯 Target Player Actions", true)

AddCheckbox(CardDesync, "FakePos", "Fake Position Hologram", function(state)
    ClearVisual("FakePosClone")
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if state and hrp then
        local marker = Instance.new("Part", Workspace)
        marker.Size = Vector3.new(2, 5, 1)
        marker.CFrame = hrp.CFrame
        marker.Anchored = true
        marker.CanCollide = false
        marker.CanQuery = false
        marker.Material = Enum.Material.ForceField
        marker.Color = Theme.Accent
        VisualObjects.FakePosClone = marker
    end
end)

AddCheckbox(CardDesync, "VelDesync", "Velocity Desync (Сбив прицела)", function(state)
    Disconnect("VelDesync")
    if state then
        Connections.VelDesync = RunService.Heartbeat:Connect(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local old = hrp.Velocity
                hrp.Velocity = Vector3.new(math.random(-130, 130), math.random(-55, 130), math.random(-130, 130))
                RunService.RenderStepped:Wait()
                if hrp and hrp.Parent then hrp.Velocity = old end
            end
        end)
    end
end)

AddCheckbox(CardDesync, "AntiFling", "Anti-Fling Protection", function(state)
    Disconnect("AntiFling")
    if state then
        Connections.AntiFling = RunService.Stepped:Connect(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    for _, part in ipairs(plr.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
    end
end)

AddCheckbox(CardDesync, "AntiVoid", "Anti-Void Bounce (Не падать в бездну)", function(state)
    Disconnect("AntiVoid")
    if state then
        Connections.AntiVoid = RunService.Heartbeat:Connect(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y < -55 then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 145, hrp.Velocity.Z)
            end
        end)
    end
end)

AddCheckbox(CardDesync, "AntiSit", "Anti-Sit Lock (Защита от усаживания)", function(state)
    Disconnect("AntiSit")
    if state then
        Connections.AntiSit = RunService.Heartbeat:Connect(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Sit then hum.Sit = false end
        end)
    end
end)

AddCheckbox(CardDesync, "AntiRagdoll", "Anti-Ragdoll Stabilizer", function(state)
    Disconnect("AntiRagdoll")
    if state then
        Connections.AntiRagdoll = RunService.Heartbeat:Connect(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end
        end)
    end
end)

local SelectedPlr = nil
AddButton(CardTarget, "⚡ Teleport Behind Selected Target", function()
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tHrp = SelectedPlr and SelectedPlr.Character and SelectedPlr.Character:FindFirstChild("HumanoidRootPart")
    if myHrp and tHrp then
        myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 3.2)
        Notify("Target", "Teleported to " .. SelectedPlr.DisplayName, 1.5)
    end
end)

AddButton(CardTarget, "👁 Spectate / Unspectate Target", function()
    if SelectedPlr and SelectedPlr.Character and SelectedPlr.Character:FindFirstChildOfClass("Humanoid") then
        local tHum = SelectedPlr.Character:FindFirstChildOfClass("Humanoid")
        local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Camera.CameraSubject == tHum and myHum then
            Camera.CameraSubject = myHum
        else
            Camera.CameraSubject = tHum
        end
    end
end)

local TargetButtonsList = {}
local function RefreshTargetPlayersList()
    for _, b in ipairs(TargetButtonsList) do
        SafeCall(function() b:Destroy() end)
    end
    table.clear(TargetButtonsList)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local b = Instance.new("TextButton", CardTarget)
            b.Name = "Select: " .. plr.DisplayName
            b.Size = UDim2.new(1, 0, 0, 22)
            b.BackgroundColor3 = Theme.BgElement
            b.Text = "🎯 " .. plr.DisplayName .. " (@" .. plr.Name .. ")"
            b.TextColor3 = (SelectedPlr == plr) and Theme.Accent or Theme.TextWhite
            b.Font = Enum.Font.GothamBold
            b.TextSize = 10
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            Instance.new("UIStroke", b).Color = Theme.Border
            b.MouseButton1Click:Connect(function()
                SelectedPlr = plr
                RefreshTargetPlayersList()
                Notify("Target Locked", "Selected: " .. plr.DisplayName, 1.4)
            end)
            table.insert(TargetButtonsList, b)
        end
    end
end
RefreshTargetPlayersList()

AddButton(CardTarget, "🔄 Refresh Server Players List", function()
    RefreshTargetPlayersList()
    Notify("Target List", "Player list updated!", 1.3)
end)

-------------------------------------------------------------------------
-- 5. ВКЛАДКА COLORS (СМЕНА АКЦЕНТА МЕНЮ, ОСТРОВКА И 3D-ЭФФЕКТОВ)
-------------------------------------------------------------------------
local CardColors = CreateCard(PageColors, "Left", "🎨 UI, Pill Island & 3D Accent", true)
local CardScalePresets = CreateCard(PageColors, "Right", "📐 Quick Window Size Presets", true)

local function ApplyThemeColor(col, name)
    Disconnect("RainbowUI")
    Theme.Accent = col
    Theme.BorderActive = col
    for _, obj in ipairs(AccentObjects) do
        SafeCall(function() obj.BackgroundColor3 = col end)
    end
    for _, st in ipairs(AccentStrokes) do
        SafeCall(function() st.Color = col end)
    end
    Notify("Theme Color", "Accent set to " .. name, 1.5)
end

AddButton(CardColors, "💎 Pulse Neon Blue (Как на фото)", function() ApplyThemeColor(Color3.fromRGB(85, 175, 255), "Pulse Neon Blue") end)
AddButton(CardColors, "⚪ Pure White (1:1 Pitch-Black)", function() ApplyThemeColor(Color3.fromRGB(255, 255, 255), "Pure White") end)
AddButton(CardColors, "🌸 Pastel Femboy Pink", function() ApplyThemeColor(Color3.fromRGB(255, 145, 215), "Pastel Pink") end)
AddButton(CardColors, "💜 Cyberpunk Violet", function() ApplyThemeColor(Color3.fromRGB(185, 115, 255), "Cyberpunk Violet") end)
AddButton(CardColors, "🩸 Crimson Red", function() ApplyThemeColor(Color3.fromRGB(255, 75, 95), "Crimson Red") end)
AddButton(CardColors, "💚 Matrix Emerald", function() ApplyThemeColor(Color3.fromRGB(80, 255, 140), "Matrix Emerald") end)
AddButton(CardColors, "🌟 Golden Amber", function() ApplyThemeColor(Color3.fromRGB(255, 200, 75), "Golden Amber") end)
AddButton(CardColors, "🌈 Rainbow Chroma UI (Перелив)", function()
    Disconnect("RainbowUI")
    Connections.RainbowUI = RunService.RenderStepped:Connect(function()
        local c = Color3.fromHSV((tick() * 0.25) % 1, 0.72, 1)
        Theme.Accent = c
        Theme.BorderActive = c
        for _, obj in ipairs(AccentObjects) do
            SafeCall(function() obj.BackgroundColor3 = c end)
        end
        for _, st in ipairs(AccentStrokes) do
            SafeCall(function() st.Color = c end)
        end
    end)
    Notify("Theme Color", "Rainbow Chroma UI enabled!", 1.5)
end)

AddButton(CardScalePresets, "📱 Mobile Mini Size (75%)", function()
    SetMenuScale(75)
    if SliderSetters["MenuScalePct"] then SliderSetters["MenuScalePct"](75, true) end
end)
AddButton(CardScalePresets, "✨ Compact Default (95%)", function()
    SetMenuScale(95)
    if SliderSetters["MenuScalePct"] then SliderSetters["MenuScalePct"](95, true) end
end)
AddButton(CardScalePresets, "🖥 Desktop Large (115%)", function()
    SetMenuScale(115)
    if SliderSetters["MenuScalePct"] then SliderSetters["MenuScalePct"](115, true) end
end)

-------------------------------------------------------------------------
-- 6. ЗАПУСК КОМПАКТНОГО ИНТРО, ВЕРХНЕГО ОСТРОВКА И МЕНЮ
-------------------------------------------------------------------------
task.spawn(function()
    RunCompactCinematicIntro(function()
        Watermark.Visible = State.Watermark
        TopIslandContainer.Visible = State.ShowTopPillIsland
        MasterFrame.Visible = true
        MasterScale.Scale = 0.8
        QuickTween(MasterScale, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
            Scale = State.MenuScalePct / 100
        })
        Notify("FemboyHub V8", "WallShot, Silent Aim & Top Pill Loaded!", 2.8)
    end)
end)
