--[[
    Premium Cyber-Minimalist UI Library - FIXED VERSION
    Fixes: Frame MouseButton1Click error, Transparent BG, Floating Icon, Smaller Size
    Size: 520x320 | Transparent: 0.35 | Gradient: Purple-Black
]]

local Library = {}
local Services = {
    CoreGui = game:GetService("CoreGui"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService")
}

-- ==========================================
-- CONFIGURATION & ICON ASSETS
-- ==========================================
local Icons = {
    Minimize = "rbxassetid://10709792206",
    Close = "rbxassetid://10747384394",
    Logo = "rbxassetid://10709751923",
    TabHome = "rbxassetid://10709768704",
    TabSettings = "rbxassetid://10709818812",
    TabPlayer = "rbxassetid://10709779149",
    TabVisuals = "rbxassetid://10709783583",
    ToggleOn = "rbxassetid://10709799954",
    ToggleOff = "rbxassetid://10709808317",
    DropdownArrow = "rbxassetid://10709765737",
    SliderKnob = "rbxassetid://10709796693",
    FloatingOpen = "rbxassetid://10709751923"
}

-- ==========================================
-- THEME CONFIG
-- ==========================================
local Theme = {
    Background = Color3.fromRGB(10, 8, 18),
    Surface = Color3.fromRGB(18, 15, 28),
    Element = Color3.fromRGB(25, 22, 35),
    Accent = Color3.fromRGB(168, 85, 247),
    AccentSecondary = Color3.fromRGB(85, 220, 247),
    Text = Color3.fromRGB(240, 240, 250),
    TextDim = Color3.fromRGB(140, 140, 160),
    Border = Color3.fromRGB(60, 50, 80)
}

-- ==========================================
-- UTILITY FUNCTIONS
-- ==========================================
local function Tween(instance, properties, duration, easingStyle, easingDirection, delayTime)
    local tweenInfo = TweenInfo.new(
        duration or 0.35,
        easingStyle or Enum.EasingStyle.Quart,
        easingDirection or Enum.EasingDirection.Out,
        0,
        false,
        delayTime or 0
    )
    local tween = Services.TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function CreateShadow(parent, offset, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DropShadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, offset or 4)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ==========================================
-- MAIN LIBRARY
-- ==========================================
function Library:CreateWindow(config)
    config = config or {}
    local titleText = config.Title or "Nynzz Hub"
    local subTitle = config.SubTitle or "PREMIUM"

    -- ==========================================
    -- SCREEN GUI
    -- ==========================================
    local ShieldGui = Instance.new("ScreenGui")
    ShieldGui.Name = "ShieldUI_" .. tostring(math.random(1000, 9999))
    ShieldGui.ResetOnSpawn = false
    ShieldGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ShieldGui.DisplayOrder = 999

    local success = pcall(function()
        ShieldGui.Parent = Services.CoreGui
    end)
    if not success then
        ShieldGui.Parent = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    -- ==========================================
    -- FLOATING OPEN ICON (MINIMIZED STATE)
    -- ==========================================
    local FloatingIcon = Instance.new("ImageButton")
    FloatingIcon.Name = "FloatingIcon"
    FloatingIcon.Size = UDim2.new(0, 48, 0, 48)
    FloatingIcon.Position = UDim2.new(0, 20, 0.5, -24)
    FloatingIcon.BackgroundColor3 = Theme.Surface
    FloatingIcon.BackgroundTransparency = 0.1
    FloatingIcon.Image = Icons.FloatingOpen
    FloatingIcon.ImageColor3 = Theme.Accent
    FloatingIcon.ImageTransparency = 0
    FloatingIcon.ScaleType = Enum.ScaleType.Fit
    FloatingIcon.Visible = false
    FloatingIcon.Active = true
    FloatingIcon.ZIndex = 50
    FloatingIcon.Parent = ShieldGui

    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(1, 0)
    FloatCorner.Parent = FloatingIcon

    local FloatStroke = Instance.new("UIStroke")
    FloatStroke.Color = Theme.Accent
    FloatStroke.Thickness = 2
    FloatStroke.Transparency = 0.3
    FloatStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    FloatStroke.Parent = FloatingIcon

    local FloatShadow = Instance.new("ImageLabel")
    FloatShadow.Name = "IconShadow"
    FloatShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    FloatShadow.BackgroundTransparency = 1
    FloatShadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    FloatShadow.Size = UDim2.new(1, 16, 1, 16)
    FloatShadow.Image = "rbxassetid://5554236805"
    FloatShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    FloatShadow.ImageTransparency = 0.7
    FloatShadow.ScaleType = Enum.ScaleType.Slice
    FloatShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    FloatShadow.ZIndex = 49
    FloatShadow.Parent = FloatingIcon

    local FloatGradient = Instance.new("UIGradient")
    FloatGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.Background)
    })
    FloatGradient.Rotation = 45
    FloatGradient.Transparency = NumberSequence.new(0.85, 1)
    FloatGradient.Parent = FloatingIcon

    MakeDraggable(FloatingIcon)

    -- ==========================================
    -- MAIN WINDOW FRAME (UKURAN KECIL + TRANSPARAN)
    -- ==========================================
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainWindow"
    MainFrame.Size = UDim2.new(0, 520, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BackgroundTransparency = 0.35
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.ZIndex = 10
    MainFrame.Parent = ShieldGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Border
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.5
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainFrame

    -- GRADIENT UNGU-HITAM BACKGROUND
    local MainGradient = Instance.new("UIGradient")
    MainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(168, 85, 247)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 15, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 8, 18))
    })
    MainGradient.Rotation = 135
    MainGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(0.5, 0.7),
        NumberSequenceKeypoint.new(1, 0.6)
    })
    MainGradient.Parent = MainFrame

    local LightOverlay = Instance.new("Frame")
    LightOverlay.Name = "LightOverlay"
    LightOverlay.Size = UDim2.new(1, 0, 0.4, 0)
    LightOverlay.Position = UDim2.new(0, 0, 0, 0)
    LightOverlay.BackgroundTransparency = 0.9
    LightOverlay.BorderSizePixel = 0
    LightOverlay.ZIndex = 11
    LightOverlay.Parent = MainFrame

    local LightGrad = Instance.new("UIGradient")
    LightGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(168, 85, 247)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 8, 18))
    })
    LightGrad.Transparency = NumberSequence.new(0.92, 1)
    LightGrad.Rotation = 90
    LightGrad.Parent = LightOverlay

    local LightCorner = Instance.new("UICorner")
    LightCorner.CornerRadius = UDim.new(0, 12)
    LightCorner.Parent = LightOverlay

    local MainShadow = CreateShadow(MainFrame, 6, 0.5)
    MainShadow.ZIndex = 9

    -- ==========================================
    -- TOPBAR
    -- ==========================================
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundColor3 = Theme.Surface
    Topbar.BackgroundTransparency = 0.5
    Topbar.BorderSizePixel = 0
    Topbar.ZIndex = 15
    Topbar.Parent = MainFrame

    local TopbarCorner = Instance.new("UICorner")
    TopbarCorner.CornerRadius = UDim.new(0, 12)
    TopbarCorner.Parent = Topbar

    local TopbarFix = Instance.new("Frame")
    TopbarFix.Size = UDim2.new(1, 0, 0, 12)
    TopbarFix.Position = UDim2.new(0, 0, 1, -12)
    TopbarFix.BackgroundColor3 = Theme.Surface
    TopbarFix.BackgroundTransparency = 0.5
    TopbarFix.BorderSizePixel = 0
    TopbarFix.ZIndex = 15
    TopbarFix.Parent = Topbar

    MakeDraggable(MainFrame, Topbar)

    local LogoIcon = Instance.new("ImageLabel")
    LogoIcon.Size = UDim2.new(0, 22, 0, 22)
    LogoIcon.Position = UDim2.new(0, 12, 0, 9)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Image = Icons.Logo
    LogoIcon.ImageColor3 = Theme.Accent
    LogoIcon.ZIndex = 16
    LogoIcon.Parent = Topbar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 180, 0, 40)
    TitleLabel.Position = UDim2.new(0, 40, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = titleText
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 16
    TitleLabel.Parent = Topbar

    local SubTitleLabel = Instance.new("TextLabel")
    SubTitleLabel.Size = UDim2.new(0, 60, 0, 14)
    SubTitleLabel.Position = UDim2.new(0, 40, 0, 24)
    SubTitleLabel.BackgroundTransparency = 1
    SubTitleLabel.Text = subTitle
    SubTitleLabel.TextColor3 = Theme.Accent
    SubTitleLabel.Font = Enum.Font.GothamBold
    SubTitleLabel.TextSize = 9
    SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubTitleLabel.ZIndex = 16
    SubTitleLabel.Parent = Topbar

    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(0, 85, 1, 0)
    Controls.Position = UDim2.new(1, -90, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.ZIndex = 16
    Controls.Parent = Topbar

    local ControlsLayout = Instance.new("UIListLayout")
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsLayout.Padding = UDim.new(0, 10)
    ControlsLayout.Parent = Controls

    local MinimizeBtn = Instance.new("ImageButton")
    MinimizeBtn.Name = "Minimize"
    MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
    MinimizeBtn.BackgroundColor3 = Theme.Element
    MinimizeBtn.Image = Icons.Minimize
    MinimizeBtn.ImageColor3 = Theme.TextDim
    MinimizeBtn.ImageTransparency = 0.2
    MinimizeBtn.ScaleType = Enum.ScaleType.Fit
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.ZIndex = 17
    MinimizeBtn.Parent = Controls

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 8)
    MinCorner.Parent = MinimizeBtn

    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.BackgroundColor3 = Theme.Element
    CloseBtn.Image = Icons.Close
    CloseBtn.ImageColor3 = Color3.fromRGB(247, 85, 85)
    CloseBtn.ImageTransparency = 0.2
    CloseBtn.ScaleType = Enum.ScaleType.Fit
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 17
    CloseBtn.Parent = Controls

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    local function SetupHover(button, hoverColor, normalColor)
        button.MouseEnter:Connect(function()
            Tween(button, {BackgroundColor3 = hoverColor, Size = UDim2.new(0, button.Size.X.Offset + 2, 0, button.Size.Y.Offset + 2)}, 0.2)
        end)
        button.MouseLeave:Connect(function()
            Tween(button, {BackgroundColor3 = normalColor, Size = UDim2.new(0, button.Size.X.Offset - 2, 0, button.Size.Y.Offset - 2)}, 0.2)
        end)
    end

    SetupHover(MinimizeBtn, Color3.fromRGB(40, 35, 55), Theme.Element)
    SetupHover(CloseBtn, Color3.fromRGB(80, 35, 40), Theme.Element)

    -- ==========================================
    -- CLOSE CONFIRMATION MODAL
    -- ==========================================
    local ModalBackdrop = Instance.new("Frame")
    ModalBackdrop.Name = "ModalBackdrop"
    ModalBackdrop.Size = UDim2.new(1, 0, 1, 0)
    ModalBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ModalBackdrop.BackgroundTransparency = 1
    ModalBackdrop.BorderSizePixel = 0
    ModalBackdrop.ZIndex = 100
    ModalBackdrop.Visible = false
    ModalBackdrop.Active = true
    ModalBackdrop.Parent = MainFrame

    local ModalFrame = Instance.new("Frame")
    ModalFrame.Name = "ConfirmModal"
    ModalFrame.Size = UDim2.new(0, 300, 0, 150)
    ModalFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    ModalFrame.BackgroundColor3 = Theme.Surface
    ModalFrame.BackgroundTransparency = 0.1
    ModalFrame.BorderSizePixel = 0
    ModalFrame.ZIndex = 101
    ModalFrame.Visible = false
    ModalFrame.Parent = ModalBackdrop

    local ModalCorner = Instance.new("UICorner")
    ModalCorner.CornerRadius = UDim.new(0, 14)
    ModalCorner.Parent = ModalFrame

    local ModalStroke = Instance.new("UIStroke")
    ModalStroke.Color = Theme.Accent
    ModalStroke.Thickness = 2
    ModalStroke.Transparency = 0.6
    ModalStroke.Parent = ModalFrame

    local ModalShadow = CreateShadow(ModalFrame, 8, 0.4)
    ModalShadow.ZIndex = 100

    local ModalAccent = Instance.new("Frame")
    ModalAccent.Size = UDim2.new(1, 0, 0, 3)
    ModalAccent.Position = UDim2.new(0, 0, 0, 0)
    ModalAccent.BackgroundColor3 = Theme.Accent
    ModalAccent.BorderSizePixel = 0
    ModalAccent.ZIndex = 102
    ModalAccent.Parent = ModalFrame

    local ModalAccentCorner = Instance.new("UICorner")
    ModalAccentCorner.CornerRadius = UDim.new(0, 3)
    ModalAccentCorner.Parent = ModalAccent

    local ModalTitle = Instance.new("TextLabel")
    ModalTitle.Size = UDim2.new(1, -30, 0, 28)
    ModalTitle.Position = UDim2.new(0, 15, 0, 14)
    ModalTitle.BackgroundTransparency = 1
    ModalTitle.Text = "Confirm Action"
    ModalTitle.TextColor3 = Theme.Text
    ModalTitle.Font = Enum.Font.GothamBold
    ModalTitle.TextSize = 15
    ModalTitle.TextXAlignment = Enum.TextXAlignment.Left
    ModalTitle.ZIndex = 102
    ModalTitle.Parent = ModalFrame

    local ModalText = Instance.new("TextLabel")
    ModalText.Size = UDim2.new(1, -30, 0, 36)
    ModalText.Position = UDim2.new(0, 15, 0, 46)
    ModalText.BackgroundTransparency = 1
    ModalText.Text = "Are you sure you want to close this UI?"
    ModalText.TextColor3 = Theme.TextDim
    ModalText.Font = Enum.Font.Gotham
    ModalText.TextSize = 12
    ModalText.TextWrapped = true
    ModalText.TextXAlignment = Enum.TextXAlignment.Left
    ModalText.ZIndex = 102
    ModalText.Parent = ModalFrame

    local ModalButtons = Instance.new("Frame")
    ModalButtons.Size = UDim2.new(1, -30, 0, 34)
    ModalButtons.Position = UDim2.new(0, 15, 1, -52)
    ModalButtons.BackgroundTransparency = 1
    ModalButtons.ZIndex = 102
    ModalButtons.Parent = ModalFrame

    local ModalBtnLayout = Instance.new("UIListLayout")
    ModalBtnLayout.FillDirection = Enum.FillDirection.Horizontal
    ModalBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ModalBtnLayout.Padding = UDim.new(0, 10)
    ModalBtnLayout.Parent = ModalButtons

    local NoBtn = Instance.new("TextButton")
    NoBtn.Size = UDim2.new(0, 75, 1, 0)
    NoBtn.BackgroundColor3 = Theme.Element
    NoBtn.Text = "No"
    NoBtn.TextColor3 = Theme.TextDim
    NoBtn.Font = Enum.Font.GothamBold
    NoBtn.TextSize = 12
    NoBtn.AutoButtonColor = false
    NoBtn.ZIndex = 103
    NoBtn.Parent = ModalButtons

    local NoCorner = Instance.new("UICorner")
    NoCorner.CornerRadius = UDim.new(0, 8)
    NoCorner.Parent = NoBtn

    local YesBtn = Instance.new("TextButton")
    YesBtn.Size = UDim2.new(0, 75, 1, 0)
    YesBtn.BackgroundColor3 = Theme.Accent
    YesBtn.Text = "Yes"
    YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesBtn.Font = Enum.Font.GothamBold
    YesBtn.TextSize = 12
    YesBtn.AutoButtonColor = false
    YesBtn.ZIndex = 103
    YesBtn.Parent = ModalButtons

    local YesCorner = Instance.new("UICorner")
    YesCorner.CornerRadius = UDim.new(0, 8)
    YesCorner.Parent = YesBtn

    NoBtn.MouseEnter:Connect(function()
        Tween(NoBtn, {BackgroundColor3 = Color3.fromRGB(50, 45, 65), TextColor3 = Theme.Text}, 0.2)
    end)
    NoBtn.MouseLeave:Connect(function()
        Tween(NoBtn, {BackgroundColor3 = Theme.Element, TextColor3 = Theme.TextDim}, 0.2)
    end)

    YesBtn.MouseEnter:Connect(function()
        Tween(YesBtn, {BackgroundColor3 = Color3.fromRGB(188, 105, 267), Size = UDim2.new(0, 79, 1, 0)}, 0.2)
    end)
    YesBtn.MouseLeave:Connect(function()
        Tween(YesBtn, {BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 75, 1, 0)}, 0.2)
    end)

    -- ==========================================
    -- ANIMATION STATES
    -- ==========================================
    local isMinimized = false
    local isClosing = false

    -- MINIMIZE LOGIC (FIXED - Floating Icon muncul)
    MinimizeBtn.MouseButton1Click:Connect(function()
        if isMinimized then return end
        isMinimized = true

        local centerX = MainFrame.Position.X.Scale
        local centerY = MainFrame.Position.Y.Scale

        Tween(MainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(centerX, 0, centerY, 0),
            BackgroundTransparency = 1
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)

        Tween(MainStroke, {Transparency = 1}, 0.3)
        Tween(MainShadow, {ImageTransparency = 1}, 0.3)

        for _, child in pairs(MainFrame:GetDescendants()) do
            if child:IsA("GuiObject") and child ~= MainFrame then
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    Tween(child, {TextTransparency = 1}, 0.2)
                end
                if child:IsA("Frame") or child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    Tween(child, {BackgroundTransparency = 1, ImageTransparency = 1}, 0.2)
                end
                if child:IsA("UIStroke") then
                    Tween(child, {Transparency = 1}, 0.2)
                end
            end
        end

        task.delay(0.4, function()
            MainFrame.Visible = false
            FloatingIcon.Visible = true
            FloatingIcon.Size = UDim2.new(0, 0, 0, 0)
            FloatingIcon.ImageTransparency = 1
            FloatStroke.Transparency = 1

            Tween(FloatingIcon, {Size = UDim2.new(0, 48, 0, 48), ImageTransparency = 0}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            Tween(FloatStroke, {Transparency = 0.3}, 0.5)
        end)
    end)

    -- FLOATING ICON CLICK (RESTORE)
    FloatingIcon.MouseButton1Click:Connect(function()
        if not isMinimized then return end
        isMinimized = false

        Tween(FloatingIcon, {Size = UDim2.new(0, 0, 0, 0), ImageTransparency = 1}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        Tween(FloatStroke, {Transparency = 1}, 0.3)

        task.delay(0.3, function()
            FloatingIcon.Visible = false

            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            MainFrame.BackgroundTransparency = 1

            Tween(MainFrame, {
                Size = UDim2.new(0, 520, 0, 320),
                Position = UDim2.new(0.5, -260, 0.5, -160),
                BackgroundTransparency = 0.35
            }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

            Tween(MainStroke, {Transparency = 0.5}, 0.5)
            Tween(MainShadow, {ImageTransparency = 0.5}, 0.5)

            task.delay(0.2, function()
                for _, child in pairs(MainFrame:GetDescendants()) do
                    if child:IsA("GuiObject") and child ~= MainFrame and child ~= ModalBackdrop and child ~= ModalFrame then
                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                            Tween(child, {TextTransparency = 0}, 0.3)
                        end
                        if child:IsA("Frame") and child.Name ~= "LightOverlay" then
                            if child.BackgroundTransparency < 1 then
                                Tween(child, {BackgroundTransparency = child.BackgroundTransparency}, 0.3)
                            end
                        end
                        if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                            if child.ImageTransparency < 1 then
                                Tween(child, {ImageTransparency = child.ImageTransparency}, 0.3)
                            end
                        end
                        if child:IsA("UIStroke") then
                            Tween(child, {Transparency = 0.5}, 0.3)
                        end
                    end
                end
            end)
        end)
    end)

    -- CLOSE LOGIC
    CloseBtn.MouseButton1Click:Connect(function()
        if isClosing then return end

        ModalBackdrop.Visible = true
        ModalFrame.Visible = true
        ModalFrame.Size = UDim2.new(0, 260, 0, 130)
        ModalFrame.BackgroundTransparency = 1
        ModalStroke.Transparency = 1
        ModalBackdrop.BackgroundTransparency = 1

        Tween(ModalBackdrop, {BackgroundTransparency = 0.6}, 0.3)
        Tween(ModalFrame, {Size = UDim2.new(0, 300, 0, 150), BackgroundTransparency = 0.1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Tween(ModalStroke, {Transparency = 0.6}, 0.4)
    end)

    local function CloseModal()
        Tween(ModalFrame, {Size = UDim2.new(0, 260, 0, 130), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        Tween(ModalStroke, {Transparency = 1}, 0.3)
        Tween(ModalBackdrop, {BackgroundTransparency = 1}, 0.3)
        task.delay(0.3, function()
            ModalBackdrop.Visible = false
            ModalFrame.Visible = false
        end)
    end

    NoBtn.MouseButton1Click:Connect(CloseModal)

    YesBtn.MouseButton1Click:Connect(function()
        if isClosing then return end
        isClosing = true
        CloseModal()

        task.delay(0.35, function()
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            Tween(MainStroke, {Transparency = 1}, 0.4)
            Tween(MainShadow, {ImageTransparency = 1}, 0.4)

            for _, child in pairs(MainFrame:GetDescendants()) do
                if child:IsA("GuiObject") then
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        Tween(child, {TextTransparency = 1}, 0.3)
                    elseif child:IsA("Frame") or child:IsA("ImageLabel") or child:IsA("ImageButton") then
                        Tween(child, {BackgroundTransparency = 1, ImageTransparency = 1}, 0.3)
                    end
                end
            end

            task.delay(0.6, function()
                ShieldGui:Destroy()
            end)
        end)
    end)

    -- ==========================================
    -- SIDEBAR & CONTENT
    -- ==========================================
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 140, 1, -50)
    Sidebar.Position = UDim2.new(0, 8, 0, 46)
    Sidebar.BackgroundColor3 = Theme.Surface
    Sidebar.BackgroundTransparency = 0.4
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 12
    Sidebar.Parent = MainFrame

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    SidebarCorner.Parent = Sidebar

    local SidebarStroke = Instance.new("UIStroke")
    SidebarStroke.Color = Theme.Border
    SidebarStroke.Thickness = 1
    SidebarStroke.Transparency = 0.7
    SidebarStroke.Parent = Sidebar

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.Parent = Sidebar

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 8)
    SidebarPadding.PaddingLeft = UDim.new(0, 8)
    SidebarPadding.PaddingRight = UDim.new(0, 8)
    SidebarPadding.PaddingBottom = UDim.new(0, 8)
    SidebarPadding.Parent = Sidebar

    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "PageContainer"
    PageContainer.Size = UDim2.new(1, -160, 1, -50)
    PageContainer.Position = UDim2.new(0, 156, 0, 46)
    PageContainer.BackgroundTransparency = 1
    PageContainer.ZIndex = 12
    PageContainer.Parent = MainFrame

    -- ==========================================
    -- TAB SYSTEM
    -- ==========================================
    local Tabs = {}
    local TabCount = 0
    local ActiveTab = nil

    function Tabs:CreateTab(tabConfig)
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon or Icons.TabHome
        TabCount = TabCount + 1

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName .. "_Tab"
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Theme.Accent
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.ZIndex = 13
        TabBtn.Parent = Sidebar

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 8)
        TabBtnCorner.Parent = TabBtn

        local TabIconImg = Instance.new("ImageLabel")
        TabIconImg.Size = UDim2.new(0, 18, 0, 18)
        TabIconImg.Position = UDim2.new(0, 8, 0, 7)
        TabIconImg.BackgroundTransparency = 1
        TabIconImg.Image = tabIcon
        TabIconImg.ImageColor3 = Theme.TextDim
        TabIconImg.ZIndex = 14
        TabIconImg.Parent = TabBtn

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -32, 1, 0)
        TabLabel.Position = UDim2.new(0, 30, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName
        TabLabel.TextColor3 = Theme.TextDim
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.TextSize = 11
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.ZIndex = 14
        TabLabel.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.ScrollBarImageTransparency = 0.5
        Page.Visible = false
        Page.ZIndex = 12
        Page.Parent = PageContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.Parent = Page

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingRight = UDim.new(0, 8)
        PagePadding.PaddingBottom = UDim.new(0, 10)
        PagePadding.Parent = Page

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
        end)

        local function Activate()
            if ActiveTab == TabBtn then return end

            if ActiveTab then
                local prevPage = PageContainer:FindFirstChild(ActiveTab.Name:gsub("_Tab", "_Page"))
                if prevPage then
                    prevPage.Visible = false
                end
                Tween(ActiveTab, {BackgroundTransparency = 1}, 0.3)
                local prevIcon = ActiveTab:FindFirstChildOfClass("ImageLabel")
                local prevLabel = ActiveTab:FindFirstChildOfClass("TextLabel")
                if prevIcon then Tween(prevIcon, {ImageColor3 = Theme.TextDim}, 0.3) end
                if prevLabel then Tween(prevLabel, {TextColor3 = Theme.TextDim}, 0.3) end
            end

            ActiveTab = TabBtn
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.85}, 0.3)
            Tween(TabIconImg, {ImageColor3 = Theme.Accent}, 0.3)
            Tween(TabLabel, {TextColor3 = Theme.Text}, 0.3)
        end

        TabBtn.MouseButton1Click:Connect(Activate)

        TabBtn.MouseEnter:Connect(function()
            if ActiveTab ~= TabBtn then
                Tween(TabBtn, {BackgroundTransparency = 0.95}, 0.2)
                Tween(TabIconImg, {ImageColor3 = Color3.fromRGB(180, 180, 200)}, 0.2)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if ActiveTab ~= TabBtn then
                Tween(TabBtn, {BackgroundTransparency = 1}, 0.2)
                Tween(TabIconImg, {ImageColor3 = Theme.TextDim}, 0.2)
            end
        end)

        if TabCount == 1 then
            task.delay(0.1, Activate)
        end

        -- ==========================================
        -- SECTIONS
        -- ==========================================
        local Sections = {}

        function Sections:CreateSection(sectionConfig)
            local sectionTitle = sectionConfig.Name or "Section"
            local sectionIcon = sectionConfig.Icon

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = sectionTitle .. "_Section"
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.BackgroundColor3 = Theme.Surface
            SectionFrame.BackgroundTransparency = 0.2
            SectionFrame.BorderSizePixel = 0
            SectionFrame.ClipsDescendants = true
            SectionFrame.ZIndex = 13
            SectionFrame.Parent = Page

            local SecCorner = Instance.new("UICorner")
            SecCorner.CornerRadius = UDim.new(0, 10)
            SecCorner.Parent = SectionFrame

            local SecStroke = Instance.new("UIStroke")
            SecStroke.Color = Theme.Border
            SecStroke.Thickness = 1
            SecStroke.Transparency = 0.8
            SecStroke.Parent = SectionFrame

            local SecShadow = CreateShadow(SectionFrame, 4, 0.7)
            SecShadow.ZIndex = 12

            local SecHeader = Instance.new("Frame")
            SecHeader.Size = UDim2.new(1, 0, 0, 32)
            SecHeader.BackgroundTransparency = 1
            SecHeader.ZIndex = 14
            SecHeader.Parent = SectionFrame

            if sectionIcon then
                local SecIcon = Instance.new("ImageLabel")
                SecIcon.Size = UDim2.new(0, 16, 0, 16)
                SecIcon.Position = UDim2.new(0, 10, 0, 8)
                SecIcon.BackgroundTransparency = 1
                SecIcon.Image = sectionIcon
                SecIcon.ImageColor3 = Theme.Accent
                SecIcon.ZIndex = 15
                SecIcon.Parent = SecHeader

                local SecTitle = Instance.new("TextLabel")
                SecTitle.Size = UDim2.new(1, -36, 1, 0)
                SecTitle.Position = UDim2.new(0, 32, 0, 0)
                SecTitle.BackgroundTransparency = 1
                SecTitle.Text = sectionTitle
                SecTitle.TextColor3 = Theme.Accent
                SecTitle.Font = Enum.Font.GothamBold
                SecTitle.TextSize = 11
                SecTitle.TextXAlignment = Enum.TextXAlignment.Left
                SecTitle.ZIndex = 15
                SecTitle.Parent = SecHeader
            else
                local SecTitle = Instance.new("TextLabel")
                SecTitle.Size = UDim2.new(1, -16, 1, 0)
                SecTitle.Position = UDim2.new(0, 10, 0, 0)
                SecTitle.BackgroundTransparency = 1
                SecTitle.Text = sectionTitle
                SecTitle.TextColor3 = Theme.Accent
                SecTitle.Font = Enum.Font.GothamBold
                SecTitle.TextSize = 11
                SecTitle.TextXAlignment = Enum.TextXAlignment.Left
                SecTitle.ZIndex = 15
                SecTitle.Parent = SecHeader
            end

            local SecLayout = Instance.new("UIListLayout")
            SecLayout.Padding = UDim.new(0, 6)
            SecLayout.Parent = SectionFrame

            local SecPadding = Instance.new("UIPadding")
            SecPadding.PaddingTop = UDim.new(0, 36)
            SecPadding.PaddingBottom = UDim.new(0, 10)
            SecPadding.PaddingLeft = UDim.new(0, 10)
            SecPadding.PaddingRight = UDim.new(0, 10)
            SecPadding.Parent = SectionFrame

            SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, SecLayout.AbsoluteContentSize.Y + 46)
            end)

            -- ==========================================
            -- ELEMENTS
            -- ==========================================
            local Elements = {}

            -- 1. BUTTON
            function Elements:CreateButton(btnConfig)
                local btnName = btnConfig.Name or "Button"
                local callback = btnConfig.Callback or function() end

                local BtnContainer = Instance.new("Frame")
                BtnContainer.Size = UDim2.new(1, 0, 0, 32)
                BtnContainer.BackgroundTransparency = 1
                BtnContainer.ZIndex = 14
                BtnContainer.Parent = SectionFrame

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.BackgroundColor3 = Theme.Element
                Btn.Text = btnName
                Btn.TextColor3 = Theme.Text
                Btn.Font = Enum.Font.GothamMedium
                Btn.TextSize = 11
                Btn.AutoButtonColor = false
                Btn.ZIndex = 15
                Btn.Parent = BtnContainer

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 8)
                BtnCorner.Parent = Btn

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Theme.Border
                BtnStroke.Thickness = 1
                BtnStroke.Transparency = 0.9
                BtnStroke.Parent = Btn

                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Color3.fromRGB(40, 35, 55)}, 0.2)
                    Tween(BtnStroke, {Transparency = 0.6, Color = Theme.Accent}, 0.2)
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Theme.Element}, 0.2)
                    Tween(BtnStroke, {Transparency = 0.9, Color = Theme.Border}, 0.2)
                end)
                Btn.MouseButton1Down:Connect(function()
                    Tween(Btn, {Size = UDim2.new(0.98, 0, 0.95, 0)}, 0.1)
                end)
                Btn.MouseButton1Up:Connect(function()
                    Tween(Btn, {Size = UDim2.new(1, 0, 1, 0)}, 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                end)
                Btn.MouseButton1Click:Connect(function()
                    task.spawn(function()
                        local success, err = pcall(callback)
                        if not success then warn("Button error: " .. tostring(err)) end
                    end)
                end)

                return Btn
            end

            -- 2. TOGGLE (FIXED - Pakai TextButton, bukan Frame)
            function Elements:CreateToggle(toggleConfig)
                local toggleName = toggleConfig.Name or "Toggle"
                local default = toggleConfig.Default or false
                local callback = toggleConfig.Callback or function() end

                local ToggleFrame = Instance.new("TextButton")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 32)
                ToggleFrame.BackgroundColor3 = Theme.Element
                ToggleFrame.BackgroundTransparency = 0.3
                ToggleFrame.Text = ""
                ToggleFrame.AutoButtonColor = false
                ToggleFrame.ZIndex = 14
                ToggleFrame.Parent = SectionFrame

                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(0, 8)
                ToggleCorner.Parent = ToggleFrame

                local ToggleStroke = Instance.new("UIStroke")
                ToggleStroke.Color = Theme.Border
                ToggleStroke.Thickness = 1
                ToggleStroke.Transparency = 0.9
                ToggleStroke.Parent = ToggleFrame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.7, 0, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = toggleName
                Label.TextColor3 = Theme.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 15
                Label.Parent = ToggleFrame

                local SwitchBg = Instance.new("TextButton")
                SwitchBg.Size = UDim2.new(0, 40, 0, 20)
                SwitchBg.Position = UDim2.new(1, -52, 0.5, -10)
                SwitchBg.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(45, 40, 60)
                SwitchBg.Text = ""
                SwitchBg.AutoButtonColor = false
                SwitchBg.ZIndex = 15
                SwitchBg.Parent = ToggleFrame

                local SwitchCorner = Instance.new("UICorner")
                SwitchCorner.CornerRadius = UDim.new(1, 0)
                SwitchCorner.Parent = SwitchBg

                local SwitchCircle = Instance.new("Frame")
                SwitchCircle.Size = UDim2.new(0, 14, 0, 14)
                SwitchCircle.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                SwitchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SwitchCircle.BorderSizePixel = 0
                SwitchCircle.ZIndex = 16
                SwitchCircle.Parent = SwitchBg

                local CircleCorner = Instance.new("UICorner")
                CircleCorner.CornerRadius = UDim.new(1, 0)
                CircleCorner.Parent = SwitchCircle

                local SwitchGlow = Instance.new("ImageLabel")
                SwitchGlow.Size = UDim2.new(1, 8, 1, 8)
                SwitchGlow.Position = UDim2.new(0.5, -4, 0.5, -4)
                SwitchGlow.BackgroundTransparency = 1
                SwitchGlow.Image = "rbxassetid://4996891970"
                SwitchGlow.ImageColor3 = Theme.Accent
                SwitchGlow.ImageTransparency = default and 0.7 or 1
                SwitchGlow.ZIndex = 14
                SwitchGlow.Parent = SwitchBg

                local toggled = default

                local function UpdateToggle()
                    toggled = not toggled
                    Tween(SwitchBg, {BackgroundColor3 = toggled and Theme.Accent or Color3.fromRGB(45, 40, 60)}, 0.3)
                    Tween(SwitchCircle, {Position = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                    Tween(SwitchGlow, {ImageTransparency = toggled and 0.7 or 1}, 0.3)
                    Tween(ToggleStroke, {Color = toggled and Theme.Accent or Theme.Border, Transparency = toggled and 0.6 or 0.9}, 0.3)

                    task.spawn(function()
                        local success, err = pcall(callback, toggled)
                        if not success then warn("Toggle error: " .. tostring(err)) end
                    end)
                end

                SwitchBg.MouseButton1Click:Connect(UpdateToggle)
                ToggleFrame.MouseButton1Click:Connect(UpdateToggle)

                ToggleFrame.MouseEnter:Connect(function()
                    Tween(ToggleFrame, {BackgroundColor3 = Color3.fromRGB(35, 30, 50)}, 0.2)
                end)
                ToggleFrame.MouseLeave:Connect(function()
                    Tween(ToggleFrame, {BackgroundColor3 = Theme.Element}, 0.2)
                end)

                return {
                    Set = function(value)
                        if toggled ~= value then UpdateToggle() end
                    end,
                    Get = function() return toggled end
                }
            end

            -- 3. SLIDER
            function Elements:CreateSlider(sliderConfig)
                local sliderName = sliderConfig.Name or "Slider"
                local min = sliderConfig.Min or 0
                local max = sliderConfig.Max or 100
                local default = math.clamp(sliderConfig.Default or min, min, max)
                local increment = sliderConfig.Increment or 1
                local callback = sliderConfig.Callback or function() end

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 46)
                SliderFrame.BackgroundColor3 = Theme.Element
                SliderFrame.BackgroundTransparency = 0.3
                SliderFrame.BorderSizePixel = 0
                SliderFrame.ZIndex = 14
                SliderFrame.Parent = SectionFrame

                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(0, 8)
                SliderCorner.Parent = SliderFrame

                local SliderStroke = Instance.new("UIStroke")
                SliderStroke.Color = Theme.Border
                SliderStroke.Thickness = 1
                SliderStroke.Transparency = 0.9
                SliderStroke.Parent = SliderFrame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.6, 0, 0, 18)
                Label.Position = UDim2.new(0, 10, 0, 4)
                Label.BackgroundTransparency = 1
                Label.Text = sliderName
                Label.TextColor3 = Theme.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 15
                Label.Parent = SliderFrame

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0.3, 0, 0, 18)
                ValueLabel.Position = UDim2.new(0.7, -5, 0, 4)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(default)
                ValueLabel.TextColor3 = Theme.Accent
                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.TextSize = 11
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.ZIndex = 15
                ValueLabel.Parent = SliderFrame

                local Track = Instance.new("Frame")
                Track.Size = UDim2.new(1, -20, 0, 5)
                Track.Position = UDim2.new(0, 10, 0, 28)
                Track.BackgroundColor3 = Color3.fromRGB(35, 30, 50)
                Track.BorderSizePixel = 0
                Track.ZIndex = 15
                Track.Parent = SliderFrame

                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(1, 0)
                TrackCorner.Parent = Track

                local Fill = Instance.new("Frame")
                local fillPercent = (default - min) / (max - min)
                Fill.Size = UDim2.new(fillPercent, 0, 1, 0)
                Fill.BackgroundColor3 = Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.ZIndex = 16
                Fill.Parent = Track

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = Fill

                local Knob = Instance.new("ImageLabel")
                Knob.Size = UDim2.new(0, 12, 0, 12)
                Knob.Position = UDim2.new(fillPercent, -6, 0.5, -6)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.Image = Icons.SliderKnob
                Knob.ImageColor3 = Color3.fromRGB(255, 255, 255)
                Knob.ZIndex = 17
                Knob.Parent = Track

                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = Knob

                local sliding = false

                local function UpdateSlider(input)
                    local trackAbs = Track.AbsolutePosition.X
                    local trackSize = Track.AbsoluteSize.X
                    local pos = math.clamp((input.Position.X - trackAbs) / trackSize, 0, 1)
                    local rawVal = min + (pos * (max - min))
                    local val = math.floor((rawVal / increment) + 0.5) * increment
                    val = math.clamp(val, min, max)

                    ValueLabel.Text = tostring(val)
                    Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.05)
                    Tween(Knob, {Position = UDim2.new(pos, -6, 0.5, -6)}, 0.05)

                    task.spawn(function()
                        local success, err = pcall(callback, val)
                        if not success then warn("Slider error: " .. tostring(err)) end
                    end)

                    return val
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        UpdateSlider(input)
                    end
                end)

                Services.UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)

                Services.UserInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input)
                    end
                end)

                SliderFrame.MouseEnter:Connect(function()
                    Tween(SliderFrame, {BackgroundColor3 = Color3.fromRGB(35, 30, 50)}, 0.2)
                end)
                SliderFrame.MouseLeave:Connect(function()
                    Tween(SliderFrame, {BackgroundColor3 = Theme.Element}, 0.2)
                end)

                return {
                    Set = function(value)
                        value = math.clamp(value, min, max)
                        local pos = (value - min) / (max - min)
                        ValueLabel.Text = tostring(value)
                        Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.3)
                        Tween(Knob, {Position = UDim2.new(pos, -6, 0.5, -6)}, 0.3)
                        task.spawn(callback, value)
                    end,
                    Get = function() return tonumber(ValueLabel.Text) end
                }
            end

            -- 4. DROPDOWN
            function Elements:CreateDropdown(dropConfig)
                local dropName = dropConfig.Name or "Dropdown"
                local options = dropConfig.Options or {}
                local default = dropConfig.Default or (options[1] and tostring(options[1])) or ""
                local callback = dropConfig.Callback or function() end

                local DropFrame = Instance.new("Frame")
                DropFrame.Size = UDim2.new(1, 0, 0, 32)
                DropFrame.BackgroundColor3 = Theme.Element
                DropFrame.BackgroundTransparency = 0.3
                DropFrame.BorderSizePixel = 0
                DropFrame.ClipsDescendants = true
                DropFrame.ZIndex = 14
                DropFrame.Parent = SectionFrame

                local DropCorner = Instance.new("UICorner")
                DropCorner.CornerRadius = UDim.new(0, 8)
                DropCorner.Parent = DropFrame

                local DropStroke = Instance.new("UIStroke")
                DropStroke.Color = Theme.Border
                DropStroke.Thickness = 1
                DropStroke.Transparency = 0.9
                DropStroke.Parent = DropFrame

                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(1, 0, 0, 32)
                DropBtn.BackgroundTransparency = 1
                DropBtn.Text = ""
                DropBtn.ZIndex = 15
                DropBtn.Parent = DropFrame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.5, 0, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = dropName
                Label.TextColor3 = Theme.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 16
                Label.Parent = DropBtn

                local SelectedLabel = Instance.new("TextLabel")
                SelectedLabel.Size = UDim2.new(0.4, -25, 1, 0)
                SelectedLabel.Position = UDim2.new(0.6, 0, 0, 0)
                SelectedLabel.BackgroundTransparency = 1
                SelectedLabel.Text = default
                SelectedLabel.TextColor3 = Theme.Accent
                SelectedLabel.Font = Enum.Font.GothamBold
                SelectedLabel.TextSize = 10
                SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
                SelectedLabel.ZIndex = 16
                SelectedLabel.Parent = DropBtn

                local ArrowIcon = Instance.new("ImageLabel")
                ArrowIcon.Size = UDim2.new(0, 14, 0, 14)
                ArrowIcon.Position = UDim2.new(1, -22, 0.5, -7)
                ArrowIcon.BackgroundTransparency = 1
                ArrowIcon.Image = Icons.DropdownArrow
                ArrowIcon.ImageColor3 = Theme.TextDim
                ArrowIcon.ZIndex = 16
                ArrowIcon.Parent = DropBtn

                local OptionContainer = Instance.new("Frame")
                OptionContainer.Size = UDim2.new(1, -8, 0, #options * 26)
                OptionContainer.Position = UDim2.new(0, 4, 0, 34)
                OptionContainer.BackgroundTransparency = 1
                OptionContainer.ZIndex = 15
                OptionContainer.Parent = DropFrame

                local OptLayout = Instance.new("UIListLayout")
                OptLayout.Padding = UDim.new(0, 3)
                OptLayout.Parent = OptionContainer

                local isOpen = false

                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 24)
                    OptBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 50)
                    OptBtn.Text = opt
                    OptBtn.TextColor3 = Theme.TextDim
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 10
                    OptBtn.AutoButtonColor = false
                    OptBtn.ZIndex = 16
                    OptBtn.Parent = OptionContainer

                    local OptCorner = Instance.new("UICorner")
                    OptCorner.CornerRadius = UDim.new(0, 6)
                    OptCorner.Parent = OptBtn

                    OptBtn.MouseEnter:Connect(function()
                        Tween(OptBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        Tween(OptBtn, {BackgroundColor3 = Color3.fromRGB(35, 30, 50), TextColor3 = Theme.TextDim}, 0.2)
                    end)

                    OptBtn.MouseButton1Click:Connect(function()
                        SelectedLabel.Text = opt
                        isOpen = false
                        Tween(ArrowIcon, {Rotation = 0}, 0.3)
                        Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 32)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)

                        task.spawn(function()
                            local success, err = pcall(callback, opt)
                            if not success then warn("Dropdown error: " .. tostring(err)) end
                        end)
                    end)
                end

                DropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    local targetSize = isOpen and UDim2.new(1, 0, 0, 38 + (#options * 26)) or UDim2.new(1, 0, 0, 32)
                    Tween(ArrowIcon, {Rotation = isOpen and 180 or 0}, 0.3)
                    Tween(DropFrame, {Size = targetSize}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
                    Tween(DropStroke, {Color = isOpen and Theme.Accent or Theme.Border, Transparency = isOpen and 0.6 or 0.9}, 0.3)
                end)

                DropBtn.MouseEnter:Connect(function()
                    Tween(DropFrame, {BackgroundColor3 = Color3.fromRGB(35, 30, 50)}, 0.2)
                end)
                DropBtn.MouseLeave:Connect(function()
                    if not isOpen then
                        Tween(DropFrame, {BackgroundColor3 = Theme.Element}, 0.2)
                    end
                end)

                return {
                    Set = function(value)
                        if table.find(options, value) then
                            SelectedLabel.Text = value
                            task.spawn(callback, value)
                        end
                    end,
                    Get = function() return SelectedLabel.Text end,
                    Refresh = function(newOptions, newDefault)
                        for _, child in pairs(OptionContainer:GetChildren()) do
                            if child:IsA("TextButton") then child:Destroy() end
                        end
                        options = newOptions
                    end
                }
            end

            -- 5. INPUT / TEXTBOX
            function Elements:CreateInput(inputConfig)
                local inputName = inputConfig.Name or "Input"
                local default = inputConfig.Default or ""
                local placeholder = inputConfig.Placeholder or "Enter text..."
                local callback = inputConfig.Callback or function() end

                local InputFrame = Instance.new("Frame")
                InputFrame.Size = UDim2.new(1, 0, 0, 32)
                InputFrame.BackgroundColor3 = Theme.Element
                InputFrame.BackgroundTransparency = 0.3
                InputFrame.BorderSizePixel = 0
                InputFrame.ZIndex = 14
                InputFrame.Parent = SectionFrame

                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 8)
                InputCorner.Parent = InputFrame

                local InputStroke = Instance.new("UIStroke")
                InputStroke.Color = Theme.Border
                InputStroke.Thickness = 1
                InputStroke.Transparency = 0.9
                InputStroke.Parent = InputFrame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.4, 0, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = inputName
                Label.TextColor3 = Theme.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 15
                Label.Parent = InputFrame

                local TextBox = Instance.new("TextBox")
                TextBox.Size = UDim2.new(0.55, -8, 0, 24)
                TextBox.Position = UDim2.new(0.45, 0, 0.5, -12)
                TextBox.BackgroundColor3 = Color3.fromRGB(20, 18, 30)
                TextBox.Text = default
                TextBox.PlaceholderText = placeholder
                TextBox.TextColor3 = Theme.Text
                TextBox.PlaceholderColor3 = Theme.TextDim
                TextBox.Font = Enum.Font.Gotham
                TextBox.TextSize = 10
                TextBox.ClearTextOnFocus = false
                TextBox.ZIndex = 15
                TextBox.Parent = InputFrame

                local TextCorner = Instance.new("UICorner")
                TextCorner.CornerRadius = UDim.new(0, 6)
                TextCorner.Parent = TextBox

                TextBox.Focused:Connect(function()
                    Tween(InputStroke, {Color = Theme.Accent, Transparency = 0.5}, 0.2)
                    Tween(TextBox, {BackgroundColor3 = Color3.fromRGB(30, 25, 45)}, 0.2)
                end)
                TextBox.FocusLost:Connect(function()
                    Tween(InputStroke, {Color = Theme.Border, Transparency = 0.9}, 0.2)
                    Tween(TextBox, {BackgroundColor3 = Color3.fromRGB(20, 18, 30)}, 0.2)
                    task.spawn(function()
                        local success, err = pcall(callback, TextBox.Text)
                        if not success then warn("Input error: " .. tostring(err)) end
                    end)
                end)

                return {
                    Set = function(text) TextBox.Text = text end,
                    Get = function() return TextBox.Text end
                }
            end

            -- 6. LABEL
            function Elements:CreateLabel(labelConfig)
                local labelText = labelConfig.Text or "Label"
                local labelColor = labelConfig.Color or Theme.TextDim

                local LabelFrame = Instance.new("Frame")
                LabelFrame.Size = UDim2.new(1, 0, 0, 22)
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.ZIndex = 14
                LabelFrame.Parent = SectionFrame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -8, 1, 0)
                Label.Position = UDim2.new(0, 4, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = labelText
                Label.TextColor3 = labelColor
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 11
                Label.TextWrapped = true
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 15
                Label.Parent = LabelFrame

                return Label
            end

            return Elements
        end
        return Sections
    end
    return Tabs
end

return Library
