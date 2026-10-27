--=============================================================================--
--                      FEMBOYHUB V6 | MEGA EXPANSION EDITION                  --
--     CINEMATIC INTRO + 1:1 PITCH-BLACK UI + 85+ VISUALS, SHADERS & ANIMS     --
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

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Очистка предыдущих запусков
local guiParent = (gethui and gethui()) or CoreGui
for _, oldName in ipairs({"FemboyHub_V6", "FemboyHub_BlackUI", "FemboyHub_ShitaroUI", "FemboyHubUI", "ShitaroVisualsUI"}) do
    if guiParent:FindFirstChild(oldName) then
        guiParent[oldName]:Destroy()
    end
end
if Lighting:FindFirstChild("FH_IntroBlur") then
    Lighting.FH_IntroBlur:Destroy()
end

-- Цветовая схема (1:1 Pitch-Black со второго скриншота)
local Theme = {
    Accent = Color3.fromRGB(255, 255, 255),
    BgMain = Color3.fromRGB(7, 7, 9),
    BgSidebar = Color3.fromRGB(10, 10, 13),
    BgCard = Color3.fromRGB(12, 12, 16),
    BgElement = Color3.fromRGB(17, 17, 22),
    Border = Color3.fromRGB(28, 28, 35),
    TextWhite = Color3.fromRGB(244, 244, 250),
    TextGray = Color3.fromRGB(130, 130, 144)
}

-- Сохранение стандартных настроек мира
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

local Connections = {}
local VisualObjects = {}
local AccentObjects = {}
local AllSearchRows = {}
local ToggleSetters = {}
local ActiveEmoteTrack = nil
local MenuKeybind = Enum.KeyCode.RightShift

local SavedConfigs = {
    ["asd"] = {},
    ["asda"] = {},
    ["IDK"] = {}
}

-- Глобальное состояние всех функций
local State = {
    Watermark = true,
    PreviewESP = true,
    Notifications = true,
    -- Движение и физика
    Fly = false,
    FlySpeed = 60,
    Noclip = false,
    WalkSpeedOn = false,
    WalkSpeed = 46,
    JumpPowerOn = false,
    JumpPower = 90,
    Bhop = false,
    InfiniteJump = false,
    Wallhop = false,
    PixelSurf = false,
    AirWalk = false,
    SpiderClimb = false,
    Spinbot = false,
    SpinSpeed = 42,
    JitterSpin = false,
    AspectRatioOn = false,
    AspectRatio = 72,
    CustomFOVOn = false,
    CustomFOV = 110,
    -- Десинки и Защита
    FakePos = false,
    VelDesync = false,
    AntiFling = false,
    -- Шейдеры и Мир
    RTXShaders = false,
    MotionBlur = false,
    Fullbright = false,
    XRayWalls = false,
    LowGravity = false,
    SakuraWeather = false,
    SnowWeather = false,
    NeonRain = false,
    VoidAsh = false,
    -- 3D Визуалы и Экипировка
    Constellations3D = false,
    ChinaHat = false,
    Halo = false,
    AngelWings = false,
    MagicCircle = false,
    FloatingSwords = false,
    CyberRing = false,
    OrbitPlanets = false,
    TeslaLightning = false,
    VortexAura = false,
    HeartAura = false,
    NeonRibbonTrail = false,
    GhostTrail = false,
    JumpRings = false,
    FireFootsteps = false,
    PointLightGlow = false,
    -- ESP и Персонаж
    HighlightESP = false,
    NameESP = false,
    TracersESP = false,
    FakeHeadless = false,
    FakeKorblox = false,
    SelfChams = false,
    RainbowBody = false,
    GhostBody = false,
    -- Модификаторы анимаций
    HyperAnims = false,
    SlowAnims = false,
    FreezePose = false,
    MoonwalkMod = false,
    MatrixLean = false,
    HelicopterTilt = false
}

local function Disconnect(name)
    if Connections[name] then
        Connections[name]:Disconnect()
        Connections[name] = nil
    end
end

local function ClearVisual(name)
    if VisualObjects[name] then
        if typeof(VisualObjects[name]) == "Instance" then
            VisualObjects[name]:Destroy()
        elseif type(VisualObjects[name]) == "table" then
            for _, v in ipairs(VisualObjects[name]) do
                if typeof(v) == "Instance" then v:Destroy() end
            end
        end
        VisualObjects[name] = nil
    end
end

local function PlaySound(id, vol, pitch)
    pcall(function()
        local s = Instance.new("Sound", SoundService)
        s.SoundId = "rbxassetid://" .. tostring(id)
        s.Volume = vol or 0.5
        s.PlaybackSpeed = pitch or 1
        s:Play()
        Debris:AddItem(s, 3)
    end)
end

-------------------------------------------------------------------------
-- СОЗДАНИЕ SCREEN GUI И СИСТЕМЫ УВЕДОМЛЕНИЙ (TOAST NOTIFICATIONS)
-------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FemboyHub_V6"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = guiParent

local NotifyHolder = Instance.new("Frame", ScreenGui)
NotifyHolder.Size = UDim2.new(0, 240, 1, -20)
NotifyHolder.Position = UDim2.new(1, -252, 0, 10)
NotifyHolder.BackgroundTransparency = 1
NotifyHolder.ZIndex = 50

local NotifyLayout = Instance.new("UIListLayout", NotifyHolder)
NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifyLayout.Padding = UDim.new(0, 6)
NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function Notify(title, msg, duration)
    if not State.Notifications then return end
    local Card = Instance.new("Frame", NotifyHolder)
    Card.Size = UDim2.new(1, 0, 0, 44)
    Card.BackgroundColor3 = Theme.BgMain
    Card.BorderSizePixel = 0
    Card.BackgroundTransparency = 1
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 4)
    local st = Instance.new("UIStroke", Card)
    st.Color = Theme.Border
    st.Transparency = 1

    local SideBar = Instance.new("Frame", Card)
    SideBar.Size = UDim2.new(0, 2, 1, -10)
    SideBar.Position = UDim2.new(0, 4, 0, 5)
    SideBar.BackgroundColor3 = Theme.Accent
    SideBar.BorderSizePixel = 0
    table.insert(AccentObjects, SideBar)

    local T1 = Instance.new("TextLabel", Card)
    T1.Size = UDim2.new(1, -18, 0, 16)
    T1.Position = UDim2.new(0, 12, 0, 5)
    T1.BackgroundTransparency = 1
    T1.Text = title
    T1.TextColor3 = Theme.TextWhite
    T1.Font = Enum.Font.GothamBold
    T1.TextSize = 11
    T1.TextXAlignment = Enum.TextXAlignment.Left
    T1.TextTransparency = 1

    local T2 = Instance.new("TextLabel", Card)
    T2.Size = UDim2.new(1, -18, 0, 16)
    T2.Position = UDim2.new(0, 12, 0, 21)
    T2.BackgroundTransparency = 1
    T2.Text = msg
    T2.TextColor3 = Theme.TextGray
    T2.Font = Enum.Font.Gotham
    T2.TextSize = 10
    T2.TextXAlignment = Enum.TextXAlignment.Left
    T2.TextTransparency = 1

    TweenService:Create(Card, TweenInfo.new(0.22), {BackgroundTransparency = 0.05}):Play()
    TweenService:Create(st, TweenInfo.new(0.22), {Transparency = 0}):Play()
    TweenService:Create(T1, TweenInfo.new(0.22), {TextTransparency = 0}):Play()
    TweenService:Create(T2, TweenInfo.new(0.22), {TextTransparency = 0}):Play()

    task.delay(duration or 2.4, function()
        if Card and Card.Parent then
            local tw = TweenService:Create(Card, TweenInfo.new(0.25), {BackgroundTransparency = 1})
            TweenService:Create(st, TweenInfo.new(0.25), {Transparency = 1}):Play()
            TweenService:Create(T1, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
            TweenService:Create(T2, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
            tw:Play()
            tw.Completed:Wait()
            if Card then Card:Destroy() end
        end
    end)
end

-------------------------------------------------------------------------
-- КИНЕМАТОГРАФИЧНОЕ ЗАГРУЗОЧНОЕ ИНТРО (CINEMATIC INTRO)
-------------------------------------------------------------------------
local function RunCinematicIntro(onComplete)
    local IntroBlur = Instance.new("BlurEffect", Lighting)
    IntroBlur.Name = "FH_IntroBlur"
    IntroBlur.Size = 0
    TweenService:Create(IntroBlur, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 22}):Play()

    local IntroBg = Instance.new("Frame", ScreenGui)
    IntroBg.Name = "IntroOverlay"
    IntroBg.Size = UDim2.new(1, 0, 1, 0)
    IntroBg.BackgroundColor3 = Color3.fromRGB(4, 4, 6)
    IntroBg.BackgroundTransparency = 0.25
    IntroBg.ZIndex = 100

    local IntroCard = Instance.new("Frame", IntroBg)
    IntroCard.Size = UDim2.new(0, 0, 0, 0)
    IntroCard.Position = UDim2.new(0.5, 0, 0.5, 0)
    IntroCard.AnchorPoint = Vector2.new(0.5, 0.5)
    IntroCard.BackgroundColor3 = Theme.BgMain
    IntroCard.ClipsDescendants = true
    IntroCard.ZIndex = 101
    Instance.new("UICorner", IntroCard).CornerRadius = UDim.new(0, 6)
    local IntroStroke = Instance.new("UIStroke", IntroCard)
    IntroStroke.Color = Theme.Border
    IntroStroke.Thickness = 1.2

    -- Мини-созвездие внутри интро
    local IntroStars = {}
    for i = 1, 14 do
        local st = Instance.new("Frame", IntroCard)
        st.Size = UDim2.new(0, 3, 0, 3)
        st.Position = UDim2.new(math.random(5, 95) / 100, 0, math.random(10, 90) / 100, 0)
        st.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        st.BackgroundTransparency = 0.45
        st.BorderSizePixel = 0
        st.ZIndex = 102
        Instance.new("UICorner", st).CornerRadius = UDim.new(1, 0)
        table.insert(IntroStars, st)
    end

    local LogoBig = Instance.new("TextLabel", IntroCard)
    LogoBig.Size = UDim2.new(1, 0, 0, 36)
    LogoBig.Position = UDim2.new(0, 0, 0, 34)
    LogoBig.BackgroundTransparency = 1
    LogoBig.Text = "F E M B O Y H U B"
    LogoBig.TextColor3 = Theme.TextWhite
    LogoBig.Font = Enum.Font.GothamBold
    LogoBig.TextSize = 24
    LogoBig.TextTransparency = 1
    LogoBig.ZIndex = 103

    local SubTitle = Instance.new("TextLabel", IntroCard)
    SubTitle.Size = UDim2.new(1, 0, 0, 18)
    SubTitle.Position = UDim2.new(0, 0, 0, 70)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "PITCH-BLACK VISUAL & ANIMATION ENGINE V6"
    SubTitle.TextColor3 = Theme.TextGray
    SubTitle.Font = Enum.Font.Code
    SubTitle.TextSize = 11
    SubTitle.TextTransparency = 1
    SubTitle.ZIndex = 103

    local StepText = Instance.new("TextLabel", IntroCard)
    StepText.Size = UDim2.new(1, -48, 0, 18)
    StepText.Position = UDim2.new(0, 24, 0, 122)
    StepText.BackgroundTransparency = 1
    StepText.Text = "Initializing core..."
    StepText.TextColor3 = Theme.TextWhite
    StepText.Font = Enum.Font.GothamMedium
    StepText.TextSize = 11
    StepText.TextXAlignment = Enum.TextXAlignment.Left
    StepText.ZIndex = 103

    local PctText = Instance.new("TextLabel", IntroCard)
    PctText.Size = UDim2.new(0, 60, 0, 18)
    PctText.Position = UDim2.new(1, -84, 0, 122)
    PctText.BackgroundTransparency = 1
    PctText.Text = "0%"
    PctText.TextColor3 = Theme.TextWhite
    PctText.Font = Enum.Font.GothamBold
    PctText.TextSize = 11
    PctText.TextXAlignment = Enum.TextXAlignment.Right
    PctText.ZIndex = 103

    local BarBack = Instance.new("Frame", IntroCard)
    BarBack.Size = UDim2.new(1, -48, 0, 5)
    BarBack.Position = UDim2.new(0, 24, 0, 146)
    BarBack.BackgroundColor3 = Theme.BgElement
    BarBack.BorderSizePixel = 0
    BarBack.ZIndex = 103
    Instance.new("UICorner", BarBack).CornerRadius = UDim.new(1, 0)

    local BarFill = Instance.new("Frame", BarBack)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Theme.Accent
    BarFill.BorderSizePixel = 0
    BarFill.ZIndex = 104
    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

    PlaySound(9119713951, 0.5, 1)

    TweenService:Create(IntroCard, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 410, 0, 185)
    }):Play()
    task.wait(0.25)
    TweenService:Create(LogoBig, TweenInfo.new(0.35), {TextTransparency = 0}):Play()
    TweenService:Create(SubTitle, TweenInfo.new(0.45), {TextTransparency = 0}):Play()

    local steps = {
        {pct = 0.22, txt = "Loading Pitch-Black Constellation UI..."},
        {pct = 0.48, txt = "Compiling RTX Shaders & 3D Auras..."},
        {pct = 0.76, txt = "Injecting R15 Animation Packs & Emotes..."},
        {pct = 0.94, txt = "Mounting 3D Character Viewport & Configs..."},
        {pct = 1.00, txt = "Welcome, @" .. LocalPlayer.Name .. "!"}
    }

    for _, st in ipairs(steps) do
        StepText.Text = st.txt
        PctText.Text = math.floor(st.pct * 100) .. "%"
        TweenService:Create(BarFill, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(st.pct, 0, 1, 0)
        }):Play()
        task.wait(0.28)
    end

    PlaySound(6895079853, 0.6, 1.05)
    task.wait(0.2)

    TweenService:Create(IntroBlur, TweenInfo.new(0.45), {Size = 0}):Play()
    TweenService:Create(IntroBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    local closeTw = TweenService:Create(IntroCard, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    closeTw:Play()
    closeTw.Completed:Wait()
    IntroBlur:Destroy()
    IntroBg:Destroy()
    if onComplete then onComplete() end
end

-------------------------------------------------------------------------
-- WATERMARK & ПЛАВАЮЩАЯ МОБИЛЬНАЯ КНОПКА
-------------------------------------------------------------------------
local Watermark = Instance.new("Frame", ScreenGui)
Watermark.Size = UDim2.new(0, 275, 0, 26)
Watermark.Position = UDim2.new(0, 14, 0, 10)
Watermark.BackgroundColor3 = Theme.BgMain
Watermark.BorderSizePixel = 0
Watermark.Visible = false
Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", Watermark).Color = Theme.Border

local WmBar = Instance.new("Frame", Watermark)
WmBar.Size = UDim2.new(0, 2, 1, -8)
WmBar.Position = UDim2.new(0, 4, 0, 4)
WmBar.BackgroundColor3 = Theme.Accent
WmBar.BorderSizePixel = 0
table.insert(AccentObjects, WmBar)

local WmLabel = Instance.new("TextLabel", Watermark)
WmLabel.Size = UDim2.new(1, -16, 1, 0)
WmLabel.Position = UDim2.new(0, 12, 0, 0)
WmLabel.BackgroundTransparency = 1
WmLabel.Text = "FemboyHub V6 | @" .. LocalPlayer.Name .. " | 60 FPS"
WmLabel.TextColor3 = Theme.TextWhite
WmLabel.Font = Enum.Font.GothamBold
WmLabel.TextSize = 11
WmLabel.TextXAlignment = Enum.TextXAlignment.Left

local fpsCount, lastFpsTime = 0, tick()
Connections.WatermarkFPS = RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    if tick() - lastFpsTime >= 1 then
        WmLabel.Text = string.format("FemboyHub V6 | @%s | %d FPS", LocalPlayer.Name, fpsCount)
        fpsCount = 0
        lastFpsTime = tick()
    end
end)

local MobileToggle = Instance.new("TextButton", ScreenGui)
MobileToggle.Size = UDim2.new(0, 96, 0, 26)
MobileToggle.Position = UDim2.new(0, 14, 0, 42)
MobileToggle.BackgroundColor3 = Theme.BgMain
MobileToggle.TextColor3 = Theme.TextWhite
MobileToggle.Font = Enum.Font.GothamBold
MobileToggle.TextSize = 11
MobileToggle.Text = "FemboyHub"
MobileToggle.Visible = false
Instance.new("UICorner", MobileToggle).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", MobileToggle).Color = Theme.Border

-- Главный контейнер (Держит основное окно + правое окно 3D превью)
local MasterFrame = Instance.new("Frame", ScreenGui)
MasterFrame.Name = "MasterFrame"
MasterFrame.Size = UDim2.new(0, 835, 0, 455)
MasterFrame.Position = UDim2.new(0.5, -417, 0.5, -227)
MasterFrame.BackgroundTransparency = 1
MasterFrame.Active = true
MasterFrame.Visible = false

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
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

MakeDraggable(MobileToggle, MobileToggle)

-------------------------------------------------------------------------
-- ЛЕВОЕ ОСНОВНОЕ ОКНО МЕНЮ (1:1 СО СКРИНШОТОМ 2)
-------------------------------------------------------------------------
local MainBox = Instance.new("Frame", MasterFrame)
MainBox.Size = UDim2.new(0, 605, 1, 0)
MainBox.BackgroundColor3 = Theme.BgMain
MainBox.BorderSizePixel = 0
Instance.new("UICorner", MainBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", MainBox).Color = Theme.Border

local Sidebar = Instance.new("Frame", MainBox)
Sidebar.Size = UDim2.new(0, 145, 1, 0)
Sidebar.BackgroundColor3 = Theme.BgSidebar
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 4)

local SidebarLine = Instance.new("Frame", Sidebar)
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, 0, 0, 0)
SidebarLine.BackgroundColor3 = Theme.Border
SidebarLine.BorderSizePixel = 0

-- Верхний блок с маскотом (кошачьи ушки, чулки, ноутбук, хвостик)
local MascotZone = Instance.new("Frame", Sidebar)
MascotZone.Size = UDim2.new(1, 0, 0, 108)
MascotZone.BackgroundTransparency = 1

local MascotArt = Instance.new("Frame", MascotZone)
MascotArt.Size = UDim2.new(0, 112, 0, 96)
MascotArt.Position = UDim2.new(0, 14, 0, 4)
MascotArt.BackgroundTransparency = 1
MascotArt.ZIndex = 8

local Tail = Instance.new("Frame", MascotArt)
Tail.Size = UDim2.new(0, 32, 0, 22)
Tail.Position = UDim2.new(0, -6, 1, -24)
Tail.BackgroundColor3 = Color3.fromRGB(245, 185, 200)
Instance.new("UICorner", Tail).CornerRadius = UDim.new(1, 0)

local HeadCircle = Instance.new("Frame", MascotArt)
HeadCircle.Size = UDim2.new(0, 36, 0, 34)
HeadCircle.Position = UDim2.new(0, 10, 0, 6)
HeadCircle.BackgroundColor3 = Color3.fromRGB(248, 248, 252)
Instance.new("UICorner", HeadCircle).CornerRadius = UDim.new(1, 0)

local EarL = Instance.new("Frame", HeadCircle)
EarL.Size = UDim2.new(0, 12, 0, 12)
EarL.Position = UDim2.new(0, 1, 0, -5)
EarL.Rotation = 35
EarL.BackgroundColor3 = Color3.fromRGB(248, 248, 252)

local EarR = Instance.new("Frame", HeadCircle)
EarR.Size = UDim2.new(0, 12, 0, 12)
EarR.Position = UDim2.new(1, -13, 0, -5)
EarR.Rotation = -35
EarR.BackgroundColor3 = Color3.fromRGB(248, 248, 252)

local FaceTxt = Instance.new("TextLabel", HeadCircle)
FaceTxt.Size = UDim2.new(1, 0, 1, 0)
FaceTxt.Position = UDim2.new(0, 0, 0, 3)
FaceTxt.BackgroundTransparency = 1
FaceTxt.Text = "• ω •"
FaceTxt.TextColor3 = Color3.fromRGB(45, 35, 50)
FaceTxt.Font = Enum.Font.GothamBold
FaceTxt.TextSize = 10

local TorsoBox = Instance.new("Frame", MascotArt)
TorsoBox.Size = UDim2.new(0, 34, 0, 32)
TorsoBox.Position = UDim2.new(0, 12, 0, 38)
TorsoBox.BackgroundColor3 = Color3.fromRGB(165, 165, 190)
Instance.new("UICorner", TorsoBox).CornerRadius = UDim.new(0, 6)

local LegsBox = Instance.new("Frame", MascotArt)
LegsBox.Size = UDim2.new(0, 48, 0, 26)
LegsBox.Position = UDim2.new(0, 42, 0, 48)
LegsBox.Rotation = -18
LegsBox.BackgroundColor3 = Color3.fromRGB(88, 56, 72)
Instance.new("UICorner", LegsBox).CornerRadius = UDim.new(0, 6)

local Laptop = Instance.new("Frame", MascotArt)
Laptop.Size = UDim2.new(0, 26, 0, 18)
Laptop.Position = UDim2.new(0, 34, 0, 34)
Laptop.Rotation = -12
Laptop.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
Instance.new("UICorner", Laptop).CornerRadius = UDim.new(0, 3)

local SidebarTopLine = Instance.new("Frame", Sidebar)
SidebarTopLine.Size = UDim2.new(1, 0, 0, 1)
SidebarTopLine.Position = UDim2.new(0, 0, 0, 108)
SidebarTopLine.BackgroundColor3 = Theme.Border
SidebarTopLine.BorderSizePixel = 0

local NavScroll = Instance.new("ScrollingFrame", Sidebar)
NavScroll.Size = UDim2.new(1, 0, 1, -156)
NavScroll.Position = UDim2.new(0, 0, 0, 112)
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
SidebarBotLine.Position = UDim2.new(0, 0, 1, -44)
SidebarBotLine.BackgroundColor3 = Theme.Border
SidebarBotLine.BorderSizePixel = 0

local AvatarCircle = Instance.new("ImageLabel", Sidebar)
AvatarCircle.Size = UDim2.new(0, 28, 0, 28)
AvatarCircle.Position = UDim2.new(0, 10, 1, -36)
AvatarCircle.BackgroundColor3 = Theme.BgElement
AvatarCircle.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", AvatarCircle).CornerRadius = UDim.new(1, 0)

local ProfileDisplay = Instance.new("TextLabel", Sidebar)
ProfileDisplay.Size = UDim2.new(1, -46, 0, 14)
ProfileDisplay.Position = UDim2.new(0, 44, 1, -35)
ProfileDisplay.BackgroundTransparency = 1
ProfileDisplay.Text = LocalPlayer.DisplayName
ProfileDisplay.TextColor3 = Theme.TextWhite
ProfileDisplay.Font = Enum.Font.GothamBold
ProfileDisplay.TextSize = 11
ProfileDisplay.TextXAlignment = Enum.TextXAlignment.Left

local ProfileUser = Instance.new("TextLabel", Sidebar)
ProfileUser.Size = UDim2.new(1, -46, 0, 12)
ProfileUser.Position = UDim2.new(0, 44, 1, -21)
ProfileUser.BackgroundTransparency = 1
ProfileUser.Text = "@" .. LocalPlayer.Name
ProfileUser.TextColor3 = Theme.TextGray
ProfileUser.Font = Enum.Font.Gotham
ProfileUser.TextSize = 10
ProfileUser.TextXAlignment = Enum.TextXAlignment.Left

-- Верхняя панель с Поиском
local TopBar = Instance.new("Frame", MainBox)
TopBar.Size = UDim2.new(1, -145, 0, 36)
TopBar.Position = UDim2.new(0, 145, 0, 0)
TopBar.BackgroundTransparency = 1
MakeDraggable(TopBar, MasterFrame)
MakeDraggable(MascotZone, MasterFrame)

local TopBarLine = Instance.new("Frame", TopBar)
TopBarLine.Size = UDim2.new(1, 0, 0, 1)
TopBarLine.Position = UDim2.new(0, 0, 1, -1)
TopBarLine.BackgroundColor3 = Theme.Border
TopBarLine.BorderSizePixel = 0

local SearchBox = Instance.new("TextBox", TopBar)
SearchBox.Size = UDim2.new(1, -45, 1, -6)
SearchBox.Position = UDim2.new(0, 12, 0, 3)
SearchBox.BackgroundTransparency = 1
SearchBox.Text = ""
SearchBox.PlaceholderText = "Search 85+ features..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 102)
SearchBox.TextColor3 = Theme.TextWhite
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 12
SearchBox.TextXAlignment = Enum.TextXAlignment.Left

local SearchIcon = Instance.new("TextLabel", TopBar)
SearchIcon.Size = UDim2.new(0, 24, 0, 24)
SearchIcon.Position = UDim2.new(1, -30, 0.5, -12)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextColor3 = Theme.TextWhite
SearchIcon.Font = Enum.Font.GothamBold
SearchIcon.TextSize = 13

-------------------------------------------------------------------------
-- РАБОЧАЯ ОБЛАСТЬ + ФОНОВОЕ СОЗВЕЗДИЕ (PLEXUS CONSTELLATION)
-------------------------------------------------------------------------
local ContentArea = Instance.new("Frame", MainBox)
ContentArea.Size = UDim2.new(1, -145, 1, -36)
ContentArea.Position = UDim2.new(0, 145, 0, 36)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true

local PlexusLayer = Instance.new("Frame", ContentArea)
PlexusLayer.Size = UDim2.new(1, 0, 1, 0)
PlexusLayer.BackgroundTransparency = 1
PlexusLayer.ZIndex = 1

local PlexusNodes = {}
local NUM_PLEXUS = 13
for i = 1, NUM_PLEXUS do
    local pDot = Instance.new("Frame", PlexusLayer)
    pDot.Size = UDim2.new(0, 4, 0, 4)
    pDot.AnchorPoint = Vector2.new(0.5, 0.5)
    pDot.BackgroundColor3 = Theme.Accent
    pDot.BorderSizePixel = 0
    Instance.new("UICorner", pDot).CornerRadius = UDim.new(1, 0)
    table.insert(AccentObjects, pDot)
    table.insert(PlexusNodes, {
        ui = pDot,
        x = math.random(25, 435),
        y = math.random(120, 395),
        vx = (math.random() - 0.5) * 34,
        vy = (math.random() - 0.5) * 34
    })
end

local PlexusLines = {}
for i = 1, 38 do
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
    local maxW, maxH = 450, 410
    for _, n in ipairs(PlexusNodes) do
        n.x = n.x + n.vx * dt
        n.y = n.y + n.vy * dt
        if n.x < 15 or n.x > (maxW - 15) then n.vx = -n.vx end
        if n.y < 95 or n.y > (maxH - 12) then n.vy = -n.vy end
        n.ui.Position = UDim2.new(0, n.x, 0, n.y)
    end
    local idx = 1
    for i = 1, NUM_PLEXUS do
        for j = i + 1, NUM_PLEXUS do
            local dx = PlexusNodes[j].x - PlexusNodes[i].x
            local dy = PlexusNodes[j].y - PlexusNodes[i].y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist < 155 and idx <= #PlexusLines then
                local l = PlexusLines[idx]
                l.Visible = true
                l.Position = UDim2.new(0, (PlexusNodes[i].x + PlexusNodes[j].x) / 2, 0, (PlexusNodes[i].y + PlexusNodes[j].y) / 2)
                l.Size = UDim2.new(0, dist, 0, 1)
                l.Rotation = math.deg(math.atan2(dy, dx))
                l.BackgroundTransparency = math.clamp(dist / 155, 0.15, 0.9)
                idx = idx + 1
            end
        end
    end
    for k = idx, #PlexusLines do
        PlexusLines[k].Visible = false
    end
end)

-------------------------------------------------------------------------
-- ПРАВОЕ ОКНО 3D-ПРЕВЬЮ ПЕРСОНАЖА (С ESP И REFRESH NOW)
-------------------------------------------------------------------------
local PreviewBox = Instance.new("Frame", MasterFrame)
PreviewBox.Size = UDim2.new(0, 218, 1, 0)
PreviewBox.Position = UDim2.new(1, -218, 0, 0)
PreviewBox.BackgroundColor3 = Theme.BgMain
PreviewBox.BorderSizePixel = 0
Instance.new("UICorner", PreviewBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", PreviewBox).Color = Theme.Border

local PreviewTop = Instance.new("Frame", PreviewBox)
PreviewTop.Size = UDim2.new(1, 0, 0, 36)
PreviewTop.BackgroundTransparency = 1
MakeDraggable(PreviewTop, MasterFrame)

local PreviewTopLine = Instance.new("Frame", PreviewTop)
PreviewTopLine.Size = UDim2.new(1, 0, 0, 1)
PreviewTopLine.Position = UDim2.new(0, 0, 1, -1)
PreviewTopLine.BackgroundColor3 = Theme.Border
PreviewTopLine.BorderSizePixel = 0

local PreviewTitle = Instance.new("TextLabel", PreviewTop)
PreviewTitle.Size = UDim2.new(0.55, 0, 1, 0)
PreviewTitle.Position = UDim2.new(0, 12, 0, 0)
PreviewTitle.BackgroundTransparency = 1
PreviewTitle.Text = "👤 " .. LocalPlayer.DisplayName
PreviewTitle.TextColor3 = Theme.TextWhite
PreviewTitle.Font = Enum.Font.GothamBold
PreviewTitle.TextSize = 11
PreviewTitle.TextXAlignment = Enum.TextXAlignment.Left

local RefreshNowBtn = Instance.new("TextButton", PreviewTop)
RefreshNowBtn.Size = UDim2.new(0, 82, 0, 22)
RefreshNowBtn.Position = UDim2.new(1, -90, 0.5, -11)
RefreshNowBtn.BackgroundTransparency = 1
RefreshNowBtn.Text = "Refresh now"
RefreshNowBtn.TextColor3 = Theme.TextWhite
RefreshNowBtn.Font = Enum.Font.GothamBold
RefreshNowBtn.TextSize = 10
RefreshNowBtn.TextXAlignment = Enum.TextXAlignment.Right

local PreviewESPLabel = Instance.new("TextLabel", PreviewBox)
PreviewESPLabel.Size = UDim2.new(1, 0, 0, 22)
PreviewESPLabel.Position = UDim2.new(0, 0, 0, 150)
PreviewESPLabel.BackgroundTransparency = 1
PreviewESPLabel.Text = LocalPlayer.DisplayName
PreviewESPLabel.TextColor3 = Color3.fromRGB(165, 175, 195)
PreviewESPLabel.Font = Enum.Font.Code
PreviewESPLabel.TextSize = 15
PreviewESPLabel.ZIndex = 5

local Viewport = Instance.new("ViewportFrame", PreviewBox)
Viewport.Size = UDim2.new(1, -12, 1, -46)
Viewport.Position = UDim2.new(0, 6, 0, 40)
Viewport.BackgroundTransparency = 1
Viewport.Ambient = Color3.fromRGB(220, 220, 225)
Viewport.LightColor = Color3.fromRGB(255, 255, 255)

local ViewCam = Instance.new("Camera", Viewport)
Viewport.CurrentCamera = ViewCam
local ViewportClone = nil

local function Refresh3DPreview()
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
end
task.spawn(Refresh3DPreview)

RefreshNowBtn.MouseButton1Click:Connect(function()
    RefreshNowBtn.TextColor3 = Theme.TextGray
    Refresh3DPreview()
    Notify("3D Preview", "Character model refreshed!", 1.5)
    task.delay(0.15, function() RefreshNowBtn.TextColor3 = Theme.TextWhite end)
end)

local previewAngle = 0
Connections.PreviewCamera = RunService.RenderStepped:Connect(function(dt)
    if MasterFrame.Visible and ViewportClone and ViewportClone:FindFirstChild("HumanoidRootPart") then
        previewAngle = previewAngle + dt * 0.55
        local hrp = ViewportClone.HumanoidRootPart
        local camPos = hrp.Position + Vector3.new(math.cos(previewAngle) * 5.0, -0.25, math.sin(previewAngle) * 5.0)
        ViewCam.CFrame = CFrame.new(camPos, hrp.Position + Vector3.new(0, -0.2, 0))
    end
end)

-------------------------------------------------------------------------
-- UI БИЛДЕР (СТРАНИЦЫ, ВЫПАДАЮЩИЕ ПОДВКЛАДКИ, КАРТОЧКИ, ЧЕКБОКСЫ)
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
    Page.ScrollBarImageColor3 = Theme.TextWhite
    Page.Visible = isDefault or false
    Page.ZIndex = 2

    local LeftCol = Instance.new("Frame", Page)
    LeftCol.Size = UDim2.new(0.5, -16, 1, 0)
    LeftCol.Position = UDim2.new(0, 10, 0, 10)
    LeftCol.BackgroundTransparency = 1
    local LeftLayout = Instance.new("UIListLayout", LeftCol)
    LeftLayout.Padding = UDim.new(0, 10)
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local RightCol = Instance.new("Frame", Page)
    RightCol.Size = UDim2.new(0.5, -16, 1, 0)
    RightCol.Position = UDim2.new(0.5, 6, 0, 10)
    RightCol.BackgroundTransparency = 1
    local RightLayout = Instance.new("UIListLayout", RightCol)
    RightLayout.Padding = UDim.new(0, 10)
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function RecalcCanvas()
        local maxH = math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y)
        Page.CanvasSize = UDim2.new(0, 0, 0, maxH + 32)
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
    for _, l in ipairs(ActiveLabels) do l.TextColor3 = Theme.TextGray end
    pageObj.Page.Visible = true
    if barIndicator then barIndicator.Visible = true end
    if labelObj then labelObj.TextColor3 = Theme.TextWhite end
end

local function CreateNavCategory(icon, title, subTabsList, defaultPageObj)
    local Wrapper = Instance.new("Frame", NavScroll)
    Wrapper.Size = UDim2.new(1, 0, 0, 30)
    Wrapper.BackgroundTransparency = 1
    Wrapper.ClipsDescendants = true

    local MainBtn = Instance.new("TextButton", Wrapper)
    MainBtn.Size = UDim2.new(1, 0, 0, 30)
    MainBtn.BackgroundTransparency = 1
    MainBtn.Text = ""

    local Bar = Instance.new("Frame", MainBtn)
    Bar.Size = UDim2.new(0, 2, 0, 15)
    Bar.Position = UDim2.new(0, 0, 0.5, -7)
    Bar.BackgroundColor3 = Theme.Accent
    Bar.BorderSizePixel = 0
    Bar.Visible = (defaultPageObj ~= nil and defaultPageObj.Page.Visible)
    table.insert(AccentObjects, Bar)
    table.insert(ActiveBars, Bar)

    local Lbl = Instance.new("TextLabel", MainBtn)
    Lbl.Size = UDim2.new(1, -30, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = icon .. "  " .. title
    Lbl.TextColor3 = Bar.Visible and Theme.TextWhite or Theme.TextGray
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(ActiveLabels, Lbl)

    if subTabsList and #subTabsList > 0 then
        local Chev = Instance.new("TextLabel", MainBtn)
        Chev.Size = UDim2.new(0, 18, 1, 0)
        Chev.Position = UDim2.new(1, -22, 0, 0)
        Chev.BackgroundTransparency = 1
        Chev.Text = "⌄"
        Chev.TextColor3 = Theme.TextGray
        Chev.Font = Enum.Font.GothamBold
        Chev.TextSize = 12

        local SubHolder = Instance.new("Frame", Wrapper)
        SubHolder.Size = UDim2.new(1, 0, 0, #subTabsList * 25)
        SubHolder.Position = UDim2.new(0, 0, 0, 30)
        SubHolder.BackgroundTransparency = 1
        local SubLayout = Instance.new("UIListLayout", SubHolder)
        SubLayout.SortOrder = Enum.SortOrder.LayoutOrder

        for _, sub in ipairs(subTabsList) do
            local SubBtn = Instance.new("TextButton", SubHolder)
            SubBtn.Size = UDim2.new(1, 0, 0, 25)
            SubBtn.BackgroundTransparency = 1
            SubBtn.Text = ""

            local SubBar = Instance.new("Frame", SubBtn)
            SubBar.Size = UDim2.new(0, 2, 0, 12)
            SubBar.Position = UDim2.new(0, 6, 0.5, -6)
            SubBar.BackgroundColor3 = Theme.Accent
            SubBar.BorderSizePixel = 0
            SubBar.Visible = false
            table.insert(AccentObjects, SubBar)
            table.insert(ActiveBars, SubBar)

            local SubLbl = Instance.new("TextLabel", SubBtn)
            SubLbl.Size = UDim2.new(1, -24, 1, 0)
            SubLbl.Position = UDim2.new(0, 20, 0, 0)
            SubLbl.BackgroundTransparency = 1
            SubLbl.Text = sub.Name
            SubLbl.TextColor3 = Theme.TextGray
            SubLbl.Font = Enum.Font.GothamBold
            SubLbl.TextSize = 10
            SubLbl.TextXAlignment = Enum.TextXAlignment.Left
            table.insert(ActiveLabels, SubLbl)

            SubBtn.MouseButton1Click:Connect(function()
                SwitchToPage(sub.PageObj, SubBar, SubLbl)
            end)
        end

        local expanded = false
        MainBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            Chev.Text = expanded and "^" or "⌄"
            TweenService:Create(Wrapper, TweenInfo.new(0.18), {
                Size = UDim2.new(1, 0, 0, expanded and (30 + #subTabsList * 25) or 30)
            }):Play()
            if subTabsList[1] then
                SwitchToPage(subTabsList[1].PageObj, Bar, Lbl)
            end
        end)
    else
        MainBtn.MouseButton1Click:Connect(function()
            SwitchToPage(defaultPageObj, Bar, Lbl)
        end)
    end
end

local function CreateCard(pageObj, side, titleText, hasCollapseArrow)
    local parentCol = (side == "Left") and pageObj.Left or pageObj.Right

    local Card = Instance.new("Frame", parentCol)
    Card.Size = UDim2.new(1, 0, 0, 38)
    Card.BackgroundColor3 = Theme.BgCard
    Card.BorderSizePixel = 0
    Card.ClipsDescendants = true
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", Card).Color = Theme.Border

    local HeaderBtn = Instance.new("TextButton", Card)
    HeaderBtn.Size = UDim2.new(1, 0, 0, 28)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = ""

    local Title = Instance.new("TextLabel", HeaderBtn)
    Title.Size = UDim2.new(1, -30, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Theme.TextWhite
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 11
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local ArrowLbl = nil
    if hasCollapseArrow then
        ArrowLbl = Instance.new("TextLabel", HeaderBtn)
        ArrowLbl.Size = UDim2.new(0, 20, 1, 0)
        ArrowLbl.Position = UDim2.new(1, -24, 0, 0)
        ArrowLbl.BackgroundTransparency = 1
        ArrowLbl.Text = "^"
        ArrowLbl.TextColor3 = Theme.TextGray
        ArrowLbl.Font = Enum.Font.GothamBold
        ArrowLbl.TextSize = 12
    end

    local SepLine = Instance.new("Frame", Card)
    SepLine.Size = UDim2.new(1, -16, 0, 1)
    SepLine.Position = UDim2.new(0, 8, 0, 28)
    SepLine.BackgroundColor3 = Theme.Border
    SepLine.BorderSizePixel = 0

    local Body = Instance.new("Frame", Card)
    Body.Size = UDim2.new(1, -16, 0, 10)
    Body.Position = UDim2.new(0, 8, 0, 34)
    Body.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout", Body)
    Layout.Padding = UDim.new(0, 6)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local collapsed = false
    local function UpdateHeight()
        Body.Size = UDim2.new(1, -16, 0, Layout.AbsoluteContentSize.Y)
        if not collapsed then
            Card.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y + 42)
        end
    end
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateHeight)

    if hasCollapseArrow then
        HeaderBtn.MouseButton1Click:Connect(function()
            collapsed = not collapsed
            ArrowLbl.Text = collapsed and "⌄" or "^"
            TweenService:Create(Card, TweenInfo.new(0.18), {
                Size = UDim2.new(1, 0, 0, collapsed and 28 or (Layout.AbsoluteContentSize.Y + 42))
            }):Play()
        end)
    end

    return Body
end

local function AddCheckbox(cardBody, stateKey, labelText, callback)
    local Row = Instance.new("TextButton", cardBody)
    Row.Name = labelText
    Row.Size = UDim2.new(1, 0, 0, 22)
    Row.BackgroundTransparency = 1
    Row.Text = ""

    local Box = Instance.new("Frame", Row)
    Box.Size = UDim2.new(0, 14, 0, 14)
    Box.Position = UDim2.new(0, 2, 0.5, -7)
    Box.BackgroundColor3 = State[stateKey] and Theme.Accent or Theme.BgElement
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 3)
    Instance.new("UIStroke", Box).Color = Theme.Border

    local Check = Instance.new("TextLabel", Box)
    Check.Size = UDim2.new(1, 0, 1, 0)
    Check.BackgroundTransparency = 1
    Check.Text = State[stateKey] and "✓" or ""
    Check.TextColor3 = Color3.fromRGB(10, 10, 12)
    Check.Font = Enum.Font.GothamBold
    Check.TextSize = 11

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Size = UDim2.new(1, -24, 1, 0)
    Lbl.Position = UDim2.new(0, 22, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = labelText
    Lbl.TextColor3 = Theme.TextWhite
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local function SetVal(newVal, silent)
        State[stateKey] = newVal
        Box.BackgroundColor3 = newVal and Theme.Accent or Theme.BgElement
        Check.Text = newVal and "✓" or ""
        if not silent then
            Notify(labelText, newVal and "Enabled [ON]" or "Disabled [OFF]", 1.6)
        end
        task.spawn(function() callback(newVal) end)
    end

    ToggleSetters[stateKey] = SetVal
    Row.MouseButton1Click:Connect(function()
        SetVal(not State[stateKey], false)
    end)

    table.insert(AllSearchRows, Row)
end

local function AddSlider(cardBody, stateKey, labelText, minVal, maxVal, callback)
    local Row = Instance.new("Frame", cardBody)
    Row.Name = labelText
    Row.Size = UDim2.new(1, 0, 0, 34)
    Row.BackgroundTransparency = 1

    local TopLbl = Instance.new("TextLabel", Row)
    TopLbl.Size = UDim2.new(1, 0, 0, 14)
    TopLbl.BackgroundTransparency = 1
    TopLbl.Text = labelText .. ": " .. tostring(State[stateKey])
    TopLbl.TextColor3 = Theme.TextGray
    TopLbl.Font = Enum.Font.GothamBold
    TopLbl.TextSize = 10
    TopLbl.TextXAlignment = Enum.TextXAlignment.Left

    local Track = Instance.new("TextButton", Row)
    Track.Size = UDim2.new(1, 0, 0, 8)
    Track.Position = UDim2.new(0, 0, 0, 20)
    Track.BackgroundColor3 = Theme.BgElement
    Track.Text = ""
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", Track).Color = Theme.Border

    local initPct = math.clamp((State[stateKey] - minVal) / (maxVal - minVal), 0, 1)
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new(initPct, 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    table.insert(AccentObjects, Fill)

    local sliding = false
    local function UpdateFromInput(input)
        local relX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * relX)
        State[stateKey] = val
        Fill.Size = UDim2.new(relX, 0, 1, 0)
        TopLbl.Text = labelText .. ": " .. tostring(val)
        if callback then task.spawn(function() callback(val) end) end
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

local function AddButton(cardBody, labelText, callback)
    local Btn = Instance.new("TextButton", cardBody)
    Btn.Name = labelText
    Btn.Size = UDim2.new(1, 0, 0, 25)
    Btn.BackgroundColor3 = Theme.BgElement
    Btn.Text = labelText
    Btn.TextColor3 = Theme.TextWhite
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", Btn).Color = Theme.Border

    Btn.MouseButton1Click:Connect(function()
        Btn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
        task.delay(0.12, function() Btn.BackgroundColor3 = Theme.BgElement end)
        task.spawn(callback)
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
-- СТРУКТУРА ВКЛАДОК И ПОДВКЛАДОК САЙДБАРА
-------------------------------------------------------------------------
local PageVisShaders = CreatePage("VisShaders", false)
local PageVis3DAuras = CreatePage("Vis3DAuras", false)
local PageVisTrails  = CreatePage("VisTrails", false)
local PageVisESP     = CreatePage("VisESP", false)

local PageMiscMove   = CreatePage("MiscMove", false)
local PageMiscPacks  = CreatePage("MiscPacks", false)
local PageMiscEmotes = CreatePage("MiscEmotes", false)
local PageMiscTarget = CreatePage("MiscTarget", false)

local PageColors     = CreatePage("Colors", false)
local PageSettings   = CreatePage("Settings", true) -- Открыта по умолчанию, как на скриншоте 2

CreateNavCategory("👁", "VISUALS", {
    {Name = "• Shaders & Sky (12)", PageObj = PageVisShaders},
    {Name = "• 3D Auras & Gear", PageObj = PageVis3DAuras},
    {Name = "• Trails & Weather", PageObj = PageVisTrails},
    {Name = "• ESP & Fake Items", PageObj = PageVisESP}
}, nil)

CreateNavCategory("⚙", "MISC", {
    {Name = "• Movement & Fly", PageObj = PageMiscMove},
    {Name = "• R15 Anim Packs (16)", PageObj = PageMiscPacks},
    {Name = "• Emotes & Tricks (18)", PageObj = PageMiscEmotes},
    {Name = "• Desync & Target", PageObj = PageMiscTarget}
}, nil)

CreateNavCategory("🎨", "COLORS", nil, PageColors)
CreateNavCategory("🔧", "SETTINGS", nil, PageSettings)

-------------------------------------------------------------------------
-- 1. СТРАНИЦА SETTINGS (1:1 КАК НА СКРИНШОТЕ 2: MENU + CONFIGS)
-------------------------------------------------------------------------
local CardMenu = CreateCard(PageSettings, "Left", "Menu", true)
local CardConfigs = CreateCard(PageSettings, "Right", "💾  Configs", false)

local KbRow = Instance.new("Frame", CardMenu)
KbRow.Size = UDim2.new(1, 0, 0, 24)
KbRow.BackgroundTransparency = 1

local KbLbl = Instance.new("TextLabel", KbRow)
KbLbl.Size = UDim2.new(0.55, 0, 1, 0)
KbLbl.BackgroundTransparency = 1
KbLbl.Text = "Menu Keybind"
KbLbl.TextColor3 = Theme.TextGray
KbLbl.Font = Enum.Font.GothamBold
KbLbl.TextSize = 11
KbLbl.TextXAlignment = Enum.TextXAlignment.Left

local KbGear = Instance.new("TextLabel", KbRow)
KbGear.Size = UDim2.new(0, 20, 0, 20)
KbGear.Position = UDim2.new(1, -78, 0.5, -10)
KbGear.BackgroundColor3 = Theme.BgElement
KbGear.Text = "⚙"
KbGear.TextColor3 = Theme.TextGray
KbGear.Font = Enum.Font.GothamBold
KbGear.TextSize = 11
Instance.new("UICorner", KbGear).CornerRadius = UDim.new(0, 3)
Instance.new("UIStroke", KbGear).Color = Theme.Border

local KbBtn = Instance.new("TextButton", KbRow)
KbBtn.Size = UDim2.new(0, 52, 0, 20)
KbBtn.Position = UDim2.new(1, -52, 0.5, -10)
KbBtn.BackgroundColor3 = Theme.BgElement
KbBtn.Text = "RShift"
KbBtn.TextColor3 = Theme.TextWhite
KbBtn.Font = Enum.Font.GothamBold
KbBtn.TextSize = 10
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
        MasterFrame.Visible = not MasterFrame.Visible
    end
end)

MobileToggle.MouseButton1Click:Connect(function()
    MasterFrame.Visible = not MasterFrame.Visible
end)

AddCheckbox(CardMenu, "Watermark", "Watermark", function(val)
    Watermark.Visible = val
end)

AddCheckbox(CardMenu, "PreviewESP", "3D Preview ESP Name", function(val)
    PreviewESPLabel.Visible = val
end)

AddCheckbox(CardMenu, "Notifications", "Toast Notifications", function() end)

AddButton(CardMenu, "🎬  Replay Intro Animation", function()
    MasterFrame.Visible = false
    RunCinematicIntro(function()
        MasterFrame.Visible = true
    end)
end)

AddButton(CardMenu, "🗑  Unload", function()
    for k, _ in pairs(Connections) do Disconnect(k) end
    for k, _ in pairs(VisualObjects) do ClearVisual(k) end
    ScreenGui:Destroy()
end)

-- ПРАВАЯ КАРТОЧКА: CONFIGS
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
CfgNameBox.Size = UDim2.new(1, 0, 0, 24)
CfgNameBox.BackgroundColor3 = Color3.fromRGB(9, 9, 12)
CfgNameBox.Text = "IDK"
CfgNameBox.PlaceholderText = "Config name..."
CfgNameBox.TextColor3 = Theme.TextWhite
CfgNameBox.Font = Enum.Font.GothamBold
CfgNameBox.TextSize = 11
Instance.new("UICorner", CfgNameBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", CfgNameBox).Color = Theme.Border

local CfgBtnRow = Instance.new("Frame", CardConfigs)
CfgBtnRow.Size = UDim2.new(1, 0, 0, 26)
CfgBtnRow.BackgroundTransparency = 1
local CfgBtnLayout = Instance.new("UIListLayout", CfgBtnRow)
CfgBtnLayout.FillDirection = Enum.FillDirection.Horizontal
CfgBtnLayout.Padding = UDim.new(0, 6)

local CfgStatus = Instance.new("TextLabel", CardConfigs)
CfgStatus.Size = UDim2.new(1, 0, 0, 16)
CfgStatus.BackgroundTransparency = 1
CfgStatus.Text = "Loaded IDK"
CfgStatus.TextColor3 = Theme.TextWhite
CfgStatus.Font = Enum.Font.GothamBold
CfgStatus.TextSize = 10
CfgStatus.TextXAlignment = Enum.TextXAlignment.Left

local function RebuildConfigList(selectedName)
    for _, v in ipairs(CfgListBox:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for cfgName, _ in pairs(SavedConfigs) do
        local isSel = (cfgName == selectedName)
        local Item = Instance.new("TextButton", CfgListBox)
        Item.Size = UDim2.new(1, 0, 0, 24)
        Item.BackgroundColor3 = Theme.BgElement
        Item.BackgroundTransparency = isSel and 0 or 1
        Item.Text = ""

        local Bar = Instance.new("Frame", Item)
        Bar.Size = UDim2.new(0, 2, 0, 14)
        Bar.Position = UDim2.new(0, 2, 0.5, -7)
        Bar.BackgroundColor3 = Theme.Accent
        Bar.BorderSizePixel = 0
        Bar.Visible = isSel

        local Txt = Instance.new("TextLabel", Item)
        Txt.Size = UDim2.new(1, -14, 1, 0)
        Txt.Position = UDim2.new(0, 10, 0, 0)
        Txt.BackgroundTransparency = 1
        Txt.Text = "📄  " .. cfgName
        Txt.TextColor3 = isSel and Theme.TextWhite or Theme.TextGray
        Txt.Font = Enum.Font.GothamBold
        Txt.TextSize = 11
        Txt.TextXAlignment = Enum.TextXAlignment.Left

        Item.MouseButton1Click:Connect(function()
            CfgNameBox.Text = cfgName
            RebuildConfigList(cfgName)
        end)
    end
end
RebuildConfigList("IDK")

local cfgActions = {
    {icon = "💾", fn = function()
        local name = CfgNameBox.Text ~= "" and CfgNameBox.Text or "IDK"
        local snap = {}
        for k, v in pairs(State) do snap[k] = v end
        SavedConfigs[name] = snap
        pcall(function()
            if writefile then writefile("FemboyHub_" .. name .. ".json", HttpService:JSONEncode(snap)) end
        end)
        RebuildConfigList(name)
        CfgStatus.Text = "Saved " .. name
        Notify("Configs", "Saved config: " .. name, 1.8)
    end},
    {icon = "📂", fn = function()
        local name = CfgNameBox.Text ~= "" and CfgNameBox.Text or "IDK"
        local data = SavedConfigs[name]
        pcall(function()
            if readfile and isfile and isfile("FemboyHub_" .. name .. ".json") then
                data = HttpService:JSONDecode(readfile("FemboyHub_" .. name .. ".json"))
            end
        end)
        if data then
            for k, v in pairs(data) do
                if ToggleSetters[k] and type(v) == "boolean" then
                    ToggleSetters[k](v, true)
                else
                    State[k] = v
                end
            end
            CfgStatus.Text = "Loaded " .. name
            Notify("Configs", "Loaded config: " .. name, 1.8)
        end
    end},
    {icon = "🔄", fn = function()
        RebuildConfigList(CfgNameBox.Text)
        CfgStatus.Text = "Refreshed list"
    end},
    {icon = "➕", fn = function()
        local name = CfgNameBox.Text
        if name ~= "" then
            SavedConfigs[name] = {}
            RebuildConfigList(name)
            CfgStatus.Text = "Created " .. name
            Notify("Configs", "Created config: " .. name, 1.8)
        end
    end},
    {icon = "🗑", fn = function()
        local name = CfgNameBox.Text
        if SavedConfigs[name] then
            SavedConfigs[name] = nil
            RebuildConfigList("")
            CfgStatus.Text = "Deleted " .. name
            Notify("Configs", "Deleted config: " .. name, 1.8)
        end
    end}
}

for _, act in ipairs(cfgActions) do
    local b = Instance.new("TextButton", CfgBtnRow)
    b.Size = UDim2.new(0, 34, 0, 24)
    b.BackgroundColor3 = Theme.BgElement
    b.Text = act.icon
    b.TextColor3 = Theme.TextWhite
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", b).Color = Theme.Border
    b.MouseButton1Click:Connect(act.fn)
end

-------------------------------------------------------------------------
-- 2. VISUALS -> SHADERS & SKY (12 пресетов ЦК, RTX Шейдеры, Motion Blur)
-------------------------------------------------------------------------
local CardShaders = CreateCard(PageVisShaders, "Left", "RTX Shaders & Camera FX", true)
local CardCC      = CreateCard(PageVisShaders, "Right", "Color Correction Presets (10)", true)

local function ClearLightingFX()
    for _, v in ipairs(Lighting:GetChildren()) do
        if string.sub(v.Name, 1, 3) == "FH_" then v:Destroy() end
    end
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
    if Lighting:FindFirstChild("FH_MotionBlur") then Lighting.FH_MotionBlur:Destroy() end
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
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) and obj.Name ~= "Terrain" then
            if state and obj.Transparency < 0.5 then
                obj:SetAttribute("FH_OrigTrans", obj.Transparency)
                obj.Transparency = 0.65
            elseif not state and obj:GetAttribute("FH_OrigTrans") ~= nil then
                obj.Transparency = obj:GetAttribute("FH_OrigTrans")
            end
        end
    end
end)

AddButton(CardShaders, "⚡ FPS Booster (SmoothPlastic)", function()
    Lighting.GlobalShadows = false
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
    end
    Notify("FPS Booster", "World materials optimized!", 1.8)
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
    Notify("Shader Preset", "Applied: " .. name, 1.6)
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
AddButton(CardCC, "🔄 Reset Lighting to Default", function()
    ClearLightingFX()
    for k, v in pairs(DefaultLighting) do Lighting[k] = v end
    Notify("Lighting", "Restored default lighting", 1.5)
end)

-------------------------------------------------------------------------
-- 3. VISUALS -> 3D AURAS & GEAR (Пентаграмма, Мечи, Кибер-Кольцо, Молнии)
-------------------------------------------------------------------------
local Card3DGear  = CreateCard(PageVis3DAuras, "Left", "3D Gear, Swords & Magic Seals", true)
local Card3DAuras = CreateCard(PageVis3DAuras, "Right", "3D Auras, Wings & Orbits", true)

-- Вращающаяся неоновая печать/пентаграмма под ногами
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
        Instance.new("CylinderMesh", outerRing)

        local starNodes = {}
        local pts = 5
        for i = 1, pts do
            local p = Instance.new("Part", folder)
            p.Size = Vector3.new(0.25, 0.25, 0.25)
            p.Transparency = 1
            p.Anchored = true
            p.CanCollide = false
            local att = Instance.new("Attachment", p)
            starNodes[i] = {part = p, att = att}
        end
        -- Соединяем вершины по звезде (1->3->5->2->4->1)
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
                for i, node in ipairs(starNodes) do
                    local a = rot + (i * math.pi * 2 / pts)
                    node.part.Position = basePos + Vector3.new(math.cos(a) * 3.1, 0.05, math.sin(a) * 3.1)
                end
            end
        end)
    end
end)

-- Парящие неоновые мечи за спиной
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
            swords[i] = blade
        end
        local t = 0
        Connections.FloatingSwords = RunService.RenderStepped:Connect(function(dt)
            t = t + dt * 2.5
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for i, sw in ipairs(swords) do
                    local spread = (i - 2.5) * 1.35
                    local bob = math.sin(t + i) * 0.35
                    local cf = hrp.CFrame * CFrame.new(spread, 1.2 + bob, 1.6) * CFrame.Angles(0, 0, math.rad(spread * 18))
                    sw.CFrame = cf
                end
            end
        end)
    end
end)

-- Кибернетическое кольцо Архонта за спиной
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
            segments[i] = seg
        end
        local angle = 0
        Connections.CyberRing = RunService.RenderStepped:Connect(function(dt)
            angle = angle + dt * 1.5
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for i, seg in ipairs(segments) do
                    local a = angle + (i * math.pi * 2 / count)
                    local localOffset = CFrame.new(math.cos(a) * 2.6, math.sin(a) * 2.6 + 0.5, 1.4)
                    seg.CFrame = hrp.CFrame * localOffset * CFrame.Angles(0, 0, a)
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
        local mesh = Instance.new("SpecialMesh", hat)
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://1033714"
        mesh.Scale = Vector3.new(1.75, 0.6, 1.75)
        VisualObjects.ChinaHat = hat
        Connections.ChinaHat = RunService.RenderStepped:Connect(function()
            local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
            if head then hat.CFrame = head.CFrame * CFrame.new(0, 1.1, 0) end
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
        Instance.new("CylinderMesh", halo)
        VisualObjects.Halo = halo
        local t = 0
        Connections.Halo = RunService.RenderStepped:Connect(function(dt)
            t = t + dt * 2.5
            local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
            if head then halo.CFrame = head.CFrame * CFrame.new(0, 1.8 + math.sin(t) * 0.15, 0) end
        end)
    end
end)

-- 3D Ауры справа
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
            star.Size = Vector3.new(0.42, 0.42, 0.42)
            star.Material = Enum.Material.Neon
            star.Color = Theme.Accent
            star.Anchored = true
            star.CanCollide = false
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
                table.insert(feathers, {part = p, side = side, idx = i})
            end
        end
        local flap = 0
        Connections.Wings = RunService.RenderStepped:Connect(function(dt)
            flap = flap + dt * 4
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, f in ipairs(feathers) do
                    local ang = math.sin(flap - f.idx * 0.3) * 0.35
                    local cf = hrp.CFrame * CFrame.new(f.side * (0.8 + f.idx * 0.45), 0.8 - f.idx * 0.28, 0.9)
                    f.part.CFrame = cf * CFrame.Angles(0, f.side * (0.5 + ang), f.side * 0.2)
                end
            end
        end)
    end
end)

-- Электрические разряды молний вокруг игрока
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
            bolts[i] = {p0 = p0, p1 = p1}
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
            spheres[i] = s
        end
        local t = 0
        Connections.Planets = RunService.RenderStepped:Connect(function(dt)
            t = t + dt * 2.5
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for i, s in ipairs(spheres) do
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
-- 4. VISUALS -> TRAILS & WEATHER (Шлейфы, Шаги, Погода)
-------------------------------------------------------------------------
local CardTrails  = CreateCard(PageVisTrails, "Left", "Trails, Footsteps & Clones", true)
local CardWeather = CreateCard(PageVisTrails, "Right", "World Weather & Particles", true)

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
                        g.Material = Enum.Material.Neon
                        g.Color = Theme.Accent
                        g.Transparency = 0.6
                        TweenService:Create(g, TweenInfo.new(0.4), {Transparency = 1}):Play()
                        Debris:AddItem(g, 0.4)
                    end
                end
            end
            task.wait(0.14)
        end
    end)
end)

AddCheckbox(CardTrails, "JumpRings", "Jump & Step Shockwave Rings", function()
    task.spawn(function()
        while State.JumpRings do
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Velocity.Magnitude > 2 then
                local ring = Instance.new("Part", Workspace)
                ring.Size = Vector3.new(1, 0.08, 1)
                ring.CFrame = hrp.CFrame * CFrame.new(0, -2.8, 0)
                ring.Anchored = true
                ring.CanCollide = false
                ring.Material = Enum.Material.Neon
                ring.Color = Theme.Accent
                Instance.new("CylinderMesh", ring)
                TweenService:Create(ring, TweenInfo.new(0.55), {Size = Vector3.new(6.5, 0.02, 6.5), Transparency = 1}):Play()
                Debris:AddItem(ring, 0.55)
            end
            task.wait(0.24)
        end
    end)
end)

AddCheckbox(CardTrails, "FireFootsteps", "Neon Flame Footsteps (Следы шагов)", function()
    task.spawn(function()
        while State.FireFootsteps do
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Velocity.Magnitude > 2 then
                local pad = Instance.new("Part", Workspace)
                pad.Size = Vector3.new(1.2, 0.1, 1.2)
                pad.CFrame = hrp.CFrame * CFrame.new(math.random(-1, 1) * 0.6, -2.85, 0)
                pad.Anchored = true
                pad.CanCollide = false
                pad.Material = Enum.Material.Neon
                pad.Color = Theme.Accent
                TweenService:Create(pad, TweenInfo.new(0.75), {Size = Vector3.new(0.1, 0.1, 0.1), Transparency = 1}):Play()
                Debris:AddItem(pad, 0.75)
            end
            task.wait(0.12)
        end
    end)
end)

-- Погодные эффекты
local function SpawnWeatherEmitter(connName, visName, state, col1, col2, speedRange, sizeVal)
    Disconnect(connName)
    ClearVisual(visName)
    if state then
        local cloud = Instance.new("Part", Workspace)
        cloud.Size = Vector3.new(75, 1, 75)
        cloud.Transparency = 1
        cloud.Anchored = true
        cloud.CanCollide = false
        VisualObjects[visName] = cloud
        local p = Instance.new("ParticleEmitter", cloud)
        p.Rate = 105
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

-------------------------------------------------------------------------
-- 5. VISUALS -> ESP & FAKE ITEMS (Chams, Tracers, Korblox, Headless)
-------------------------------------------------------------------------
local CardESP  = CreateCard(PageVisESP, "Left", "Player ESP, Tags & Tracers", true)
local CardFake = CreateCard(PageVisESP, "Right", "Fake Items & Body Chams", true)

AddCheckbox(CardESP, "HighlightESP", "Highlight Chams ESP", function(state)
    if not state then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("FH_HL") then
                plr.Character.FH_HL:Destroy()
            end
        end
    else
        task.spawn(function()
            while State.HighlightESP do
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and not plr.Character:FindFirstChild("FH_HL") then
                        local hl = Instance.new("Highlight", plr.Character)
                        hl.Name = "FH_HL"
                        hl.FillColor = Theme.Accent
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.55
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

AddCheckbox(CardESP, "NameESP", "Name, Distance & HP Tags", function(state)
    if not state then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("Head") and plr.Character.Head:FindFirstChild("FH_Tag") then
                plr.Character.Head.FH_Tag:Destroy()
            end
        end
    else
        task.spawn(function()
            while State.NameESP do
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                        local head = plr.Character.Head
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        local tag = head:FindFirstChild("FH_Tag")
                        if not tag then
                            tag = Instance.new("BillboardGui", head)
                            tag.Name = "FH_Tag"
                            tag.Size = UDim2.new(0, 150, 0, 28)
                            tag.StudsOffset = Vector3.new(0, 2.6, 0)
                            tag.AlwaysOnTop = true
                            local txt = Instance.new("TextLabel", tag)
                            txt.Name = "Lbl"
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.TextColor3 = Theme.TextWhite
                            txt.TextStrokeTransparency = 0.15
                            txt.Font = Enum.Font.Code
                            txt.TextSize = 13
                        end
                        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local dist = myHrp and math.floor((myHrp.Position - head.Position).Magnitude) or 0
                        local hp = hum and math.floor(hum.Health) or 100
                        tag.Lbl.Text = string.format("%s [%dm] (%dHP)", plr.DisplayName, dist, hp)
                    end
                end
                task.wait(0.25)
            end
        end)
    end
end)

-- 3D Beam Tracers от вашего персонажа ко всем игрокам
AddCheckbox(CardESP, "TracersESP", "3D Beam Tracers to Players", function(state)
    Disconnect("Tracers")
    ClearVisual("TracersFolder")
    if state then
        local folder = Instance.new("Folder", Workspace)
        VisualObjects.TracersFolder = folder
        Connections.Tracers = RunService.RenderStepped:Connect(function()
            folder:ClearAllChildren()
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myHrp then return end
            local a0 = myHrp:FindFirstChild("FH_TracerAtt") or Instance.new("Attachment", myHrp)
            a0.Name = "FH_TracerAtt"
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local tHrp = plr.Character.HumanoidRootPart
                    local a1 = tHrp:FindFirstChild("FH_TracerAtt") or Instance.new("Attachment", tHrp)
                    a1.Name = "FH_TracerAtt"
                    local beam = Instance.new("Beam", folder)
                    beam.Attachment0 = a0
                    beam.Attachment1 = a1
                    beam.Width0 = 0.05
                    beam.Width1 = 0.05
                    beam.LightEmission = 1
                    beam.FaceCamera = true
                    beam.Color = ColorSequence.new(Theme.Accent)
                end
            end
        end)
    end
end)

AddCheckbox(CardFake, "FakeHeadless", "Fake Headless (Невидимая голова)", function(state)
    local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if head then
        head.Transparency = state and 1 or 0
        for _, d in ipairs(head:GetChildren()) do
            if d:IsA("Decal") then d.Transparency = state and 1 or 0 end
        end
    end
    Refresh3DPreview()
end)

AddCheckbox(CardFake, "FakeKorblox", "Fake Korblox (Правая нога)", function(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, n in ipairs({"RightLowerLeg", "RightFoot", "Right Leg"}) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then p.Transparency = state and 1 or 0 end
    end
    Refresh3DPreview()
end)

AddCheckbox(CardFake, "SelfChams", "ForceField Material Body", function(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.Material = state and Enum.Material.ForceField or Enum.Material.Plastic
        end
    end
    Refresh3DPreview()
end)

AddCheckbox(CardFake, "RainbowBody", "Rainbow Neon Body (Радуга)", function(state)
    Disconnect("RainbowBody")
    local char = LocalPlayer.Character
    if state and char then
        Connections.RainbowBody = RunService.RenderStepped:Connect(function()
            local col = Color3.fromHSV((tick() * 0.28) % 1, 0.65, 1)
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.Color = col
                end
            end
        end)
    end
end)

AddCheckbox(CardFake, "GhostBody", "Semi-Transparent Ghost Body", function(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "Head" then
            p.Transparency = state and 0.55 or 0
        end
    end
    Refresh3DPreview()
end)

-------------------------------------------------------------------------
-- 6. MISC -> MOVEMENT & FLY (Все функции движения + новые фишки)
-------------------------------------------------------------------------
local CardMoveLeft  = CreateCard(PageMiscMove, "Left", "Fly, Noclip & Parkour", true)
local CardMoveRight = CreateCard(PageMiscMove, "Right", "Speed, Spinbot & Camera", true)

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
                local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
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

AddCheckbox(CardMoveLeft, "Bhop", "Auto Bhop", function(state)
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

-- Хождение по воздуху на неоновой платформе
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
        VisualObjects.AirWalkPart = plat
        Connections.AirWalk = RunService.RenderStepped:Connect(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                plat.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - 3.1, hrp.Position.Z)
            end
        end)
    end
end)

-- Лазание по вертикальным стенам (Spider Climb)
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

AddCheckbox(CardMoveLeft, "InfiniteJump", "Infinite Jump", function(state)
    Disconnect("InfJump")
    if state then
        Connections.InfJump = UserInputService.JumpRequest:Connect(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
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

AddCheckbox(CardMoveRight, "CustomFOVOn", "Custom FOV (110°)", function(state)
    Disconnect("FOV")
    if state then
        Connections.FOV = RunService.RenderStepped:Connect(function()
            Camera.FieldOfView = State.CustomFOV
        end)
    else
        Camera.FieldOfView = 70
    end
end)

-------------------------------------------------------------------------
-- 7. MISC -> R15 ANIM PACKS (16 полных паков анимации походки)
-------------------------------------------------------------------------
local CardPacks1 = CreateCard(PageMiscPacks, "Left", "R15 Animation Packs (1 - 8)", true)
local CardPacks2 = CreateCard(PageMiscPacks, "Right", "R15 Animation Packs (9 - 16)", true)

local function SetAnimPack(packName, idle1, walk, run, jump, fall)
    local anim = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Animate")
    if anim then
        anim.Disabled = true
        pcall(function()
            anim.idle.Animation1.AnimationId = "rbxassetid://" .. tostring(idle1)
            anim.walk.WalkAnim.AnimationId = "rbxassetid://" .. tostring(walk)
            anim.run.RunAnim.AnimationId = "rbxassetid://" .. tostring(run)
            anim.jump.JumpAnim.AnimationId = "rbxassetid://" .. tostring(jump)
            anim.fall.FallAnim.AnimationId = "rbxassetid://" .. tostring(fall)
        end)
        anim.Disabled = false
        Notify("Animation Pack", "Equipped: " .. packName, 1.6)
    end
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
-- 8. MISC -> EMOTES & TRICKS (Танцы, Эмоции, Сальто назад, Трюки)
-------------------------------------------------------------------------
local CardEmotes = CreateCard(PageMiscEmotes, "Left", "Dances & Emotes Player", true)
local CardTricks = CreateCard(PageMiscEmotes, "Right", "Procedural Tricks & Modifiers", true)

local function PlayDirectEmote(emoteName, animId, looped)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if ActiveEmoteTrack then
        ActiveEmoteTrack:Stop()
        ActiveEmoteTrack = nil
    end
    pcall(function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. tostring(animId)
        local track = hum:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action
        track.Looped = (looped ~= false)
        track:Play()
        ActiveEmoteTrack = track
        Notify("Emote Player", "Playing: " .. emoteName, 1.5)
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
    if ActiveEmoteTrack then ActiveEmoteTrack:Stop() ActiveEmoteTrack = nil end
    Notify("Emote Player", "Stopped emote", 1.4)
end)

-- Процедурное Сальто Назад (360° Backflip)
AddButton(CardTricks, "🤸 Do 360° Backflip (Сальто назад)", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        hum.Sit = true
        hrp.Velocity = Vector3.new(hrp.Velocity.X, 46, hrp.Velocity.Z) - (hrp.CFrame.LookVector * 14)
        for i = 1, 24 do
            hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(15), 0, 0)
            RunService.RenderStepped:Wait()
        end
        hum.Sit = false
    end
end)

-- Процедурное Сальто Вперёд (Frontflip)
AddButton(CardTricks, "⚡ Do 360° Frontflip (Сальто вперёд)", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        hum.Sit = true
        hrp.Velocity = Vector3.new(hrp.Velocity.X, 46, hrp.Velocity.Z) + (hrp.CFrame.LookVector * 16)
        for i = 1, 24 do
            hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(-15), 0, 0)
            RunService.RenderStepped:Wait()
        end
        hum.Sit = false
    end
end)

AddCheckbox(CardTricks, "MatrixLean", "Matrix Dodge Lean (Наклон Матрицы)", function(state)
    local char = LocalPlayer.Character
    local lowerTorso = char and char:FindFirstChild("LowerTorso")
    local rootJoint = (lowerTorso and lowerTorso:FindFirstChild("Root")) or (char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("RootJoint"))
    if rootJoint then
        rootJoint.C0 = state and (rootJoint.C0 * CFrame.Angles(math.rad(-42), 0, 0)) or CFrame.new(0, 0, 0)
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
-- 9. MISC -> DESYNC & TARGET (Десинки со скриншота 1 + Target система)
-------------------------------------------------------------------------
local CardDesync = CreateCard(PageMiscTarget, "Left", "Desync & Anti-Aim", true)
local CardTarget = CreateCard(PageMiscTarget, "Right", "Target Player Actions", true)

AddCheckbox(CardDesync, "FakePos", "Fake Position Hologram", function(state)
    ClearVisual("FakePosClone")
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if state and hrp then
        local marker = Instance.new("Part", Workspace)
        marker.Size = Vector3.new(2, 5, 1)
        marker.CFrame = hrp.CFrame
        marker.Anchored = true
        marker.CanCollide = false
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
                if hrp then hrp.Velocity = old end
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

local SelectedPlr = nil
AddButton(CardTarget, "⚡ Teleport to Selected Target", function()
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tHrp = SelectedPlr and SelectedPlr.Character and SelectedPlr.Character:FindFirstChild("HumanoidRootPart")
    if myHrp and tHrp then
        myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 3)
        Notify("Target", "Teleported to " .. SelectedPlr.DisplayName, 1.5)
    end
end)

AddButton(CardTarget, "👁 Spectate / Unspectate Target", function()
    if SelectedPlr and SelectedPlr.Character and SelectedPlr.Character:FindFirstChildOfClass("Humanoid") then
        if Camera.CameraSubject == SelectedPlr.Character:FindFirstChildOfClass("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        else
            Camera.CameraSubject = SelectedPlr.Character:FindFirstChildOfClass("Humanoid")
        end
    end
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        AddButton(CardTarget, "🎯 Select: " .. plr.DisplayName, function()
            SelectedPlr = plr
            Notify("Target", "Selected: " .. plr.DisplayName, 1.5)
        end)
    end
end

-------------------------------------------------------------------------
-- 10. ВКЛАДКА COLORS (Смена акцента меню, созвездий и 3D-эффектов)
-------------------------------------------------------------------------
local CardColors = CreateCard(PageColors, "Left", "UI & Constellation Accent Color", true)

local function ApplyThemeColor(col, name)
    Theme.Accent = col
    for _, obj in ipairs(AccentObjects) do
        obj.BackgroundColor3 = col
    end
    Notify("Theme Color", "Accent set to " .. name, 1.5)
end

AddButton(CardColors, "⚪ Pure White (1:1 Screenshot)", function() ApplyThemeColor(Color3.fromRGB(255, 255, 255), "Pure White") end)
AddButton(CardColors, "🌸 Pastel Femboy Pink", function() ApplyThemeColor(Color3.fromRGB(255, 145, 215), "Pastel Pink") end)
AddButton(CardColors, "💎 Shitaro Ice Blue", function() ApplyThemeColor(Color3.fromRGB(95, 175, 255), "Ice Blue") end)
AddButton(CardColors, "💜 Cyberpunk Violet", function() ApplyThemeColor(Color3.fromRGB(185, 115, 255), "Cyberpunk Violet") end)
AddButton(CardColors, "🩸 Crimson Red", function() ApplyThemeColor(Color3.fromRGB(255, 75, 95), "Crimson Red") end)
AddButton(CardColors, "💚 Matrix Emerald", function() ApplyThemeColor(Color3.fromRGB(80, 255, 140), "Matrix Emerald") end)

-------------------------------------------------------------------------
-- ЗАПУСК КИНЕМАТОГРАФИЧНОГО ИНТРО И ОТКРЫТИЕ МЕНЮ
-------------------------------------------------------------------------
task.spawn(function()
    RunCinematicIntro(function()
        Watermark.Visible = State.Watermark
        MobileToggle.Visible = true
        MasterFrame.Visible = true
        Notify("FemboyHub V6", "Successfully loaded 85+ modules!", 3)
    end)
end)
