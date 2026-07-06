--[[
    Premium Cyber-Minimalist UI Library
    ModuleScript Architecture
    Author: Expert Lua UI Developer
    Features: Draggable window, floating icon, confirmation modal, 
              smooth tweens, 3D depth effects, custom rbxassetid icons
--]]

local Library = {}
local Services = {
    CoreGui = game:GetService("CoreGui"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    TextService = game:GetService("TextService")
}

-- ==========================================
-- CONFIGURATION & ICON ASSETS
-- Replace these with your own uploaded Image IDs
-- ==========================================
local Icons = {
    -- Topbar Controls
    Minimize = "rbxassetid://10709792206",  -- Minus symbol
    Close = "rbxassetid://10747384394",      -- X symbol
    Logo = "rbxassetid://10709751923",       -- Shield/Logo icon
    
    -- Tab & Element Icons
    TabHome = "rbxassetid://10709768704",
    TabSettings = "rbxassetid://10709818812",
    TabPlayer = "rbxassetid://10709779149",
    TabVisuals = "rbxassetid://10709783583",
    
    -- Component Icons
    ToggleOn = "rbxassetid://10709799954",
    ToggleOff = "rbxassetid://10709808317",
    DropdownArrow = "rbxassetid://10709765737",
    SliderKnob = "rbxassetid://10709796693",
    Checkmark = "rbxassetid://10709771242",
    
    -- Floating Icon
    FloatingOpen = "rbxassetid://10709751923"
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

local function CreateShadow(parent, offset, transparency, radius)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DropShadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, offset or 4)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Image = "rbxassetid://5554236805" -- Blur shadow asset
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

local function MakeDraggable(frame, handle, callback)
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
            local newPos = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
            frame.Position = newPos
            if callback then callback(newPos) end
        end
    end)
end

-- ==========================================
-- MAIN LIBRARY
-- ==========================================
function Library:CreateWindow(config)
    config = config or {}
    local titleText = config.Title or "Shield Team"
    local subTitle = config.SubTitle or "PREMIUM"
    local theme = config.Theme or {
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
    -- SCREEN GUI SETUP
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
    -- FLOATING OPEN ICON (Minimized State)
    -- ==========================================
    local FloatingIcon = Instance.new("ImageButton")
    FloatingIcon.Name = "FloatingIcon"
    FloatingIcon.Size = UDim2.new(0, 52, 0, 52)
    FloatingIcon.Position = UDim2.new(0, 25, 0.5, -26)
    FloatingIcon.BackgroundColor3 = theme.Surface
    FloatingIcon.BackgroundTransparency = 0.1
    FloatingIcon.Image = Icons.FloatingOpen
    FloatingIcon.ImageColor3 = theme.Accent
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
    FloatStroke.Color = theme.Accent
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
    
    -- Floating Icon Glow (subtle gradient)
    local FloatGradient = Instance.new("UIGradient")
    FloatGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.Accent),
        ColorSequenceKeypoint.new(1, theme.Background)
    })
    FloatGradient.Rotation = 45
    FloatGradient.Transparency = NumberSequence.new(0.85, 1)
    FloatGradient.Parent = FloatingIcon
    
    MakeDraggable(FloatingIcon)
    
    -- ==========================================
    -- MAIN WINDOW FRAME
    -- ==========================================
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainWindow"
    MainFrame.Size = UDim2.new(0, 650, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -200)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.ZIndex = 10
    MainFrame.Parent = ShieldGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    -- 3D Depth: Outer Glow/Stroke
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = theme.Border
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.5
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainFrame
    
    -- 3D Depth: Gradient Overlay for subtle light effect
    local MainGradient = Instance.new("Frame")
    MainGradient.Name = "GradientOverlay"
    MainGradient.Size = UDim2.new(1, 0, 0.5, 0)
    MainGradient.Position = UDim2.new(0, 0, 0, 0)
    MainGradient.BackgroundTransparency = 0.9
    MainGradient.BorderSizePixel = 0
    MainGradient.ZIndex = 11
    MainGradient.Parent = MainFrame
    
    local MainGradEffect = Instance.new("UIGradient")
    MainGradEffect.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    MainGradEffect.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.92),
        NumberSequenceKeypoint.new(1, 1)
    })
    MainGradEffect.Rotation = 90
    MainGradEffect.Parent = MainGradient
    
    local MainGradCorner = Instance.new("UICorner")
    MainGradCorner.CornerRadius = UDim.new(0, 12)
    MainGradCorner.Parent = MainGradient
    
    -- Drop Shadow behind MainFrame
    local MainShadow = CreateShadow(MainFrame, 6, 0.5, 12)
    MainShadow.ZIndex = 9
    
    -- ==========================================
    -- TOPBAR
    -- ==========================================
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 44)
    Topbar.BackgroundColor3 = theme.Surface
    Topbar.BackgroundTransparency = 0.4
    Topbar.BorderSizePixel = 0
    Topbar.ZIndex = 15
    Topbar.Parent = MainFrame
    
    local TopbarCorner = Instance.new("UICorner")
    TopbarCorner.CornerRadius = UDim.new(0, 12)
    TopbarCorner.Parent = Topbar
    
    -- Fix top corners only (mask bottom corners of topbar)
    local TopbarFix = Instance.new("Frame")
    TopbarFix.Size = UDim2.new(1, 0, 0, 12)
    TopbarFix.Position = UDim2.new(0, 0, 1, -12)
    TopbarFix.BackgroundColor3 = theme.Surface
    TopbarFix.BackgroundTransparency = 0.4
    TopbarFix.BorderSizePixel = 0
    TopbarFix.ZIndex = 15
    TopbarFix.Parent = Topbar
    
    -- Draggable area
    MakeDraggable(MainFrame, Topbar)
    
    -- Logo Icon
    local LogoIcon = Instance.new("ImageLabel")
    LogoIcon.Size = UDim2.new(0, 24, 0, 24)
    LogoIcon.Position = UDim2.new(0, 14, 0, 10)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Image = Icons.Logo
    LogoIcon.ImageColor3 = theme.Accent
    LogoIcon.ZIndex = 16
    LogoIcon.Parent = Topbar
    
    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 200, 0, 44)
    TitleLabel.Position = UDim2.new(0, 44, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = titleText
    TitleLabel.TextColor3 = theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 16
    TitleLabel.Parent = Topbar
    
    -- Subtitle (Premium tag)
    local SubTitleLabel = Instance.new("TextLabel")
    SubTitleLabel.Size = UDim2.new(0, 60, 0, 16)
    SubTitleLabel.Position = UDim2.new(0, 44, 0, 26)
    SubTitleLabel.BackgroundTransparency = 1
    SubTitleLabel.Text = subTitle
    SubTitleLabel.TextColor3 = theme.Accent
    SubTitleLabel.Font = Enum.Font.GothamBold
    SubTitleLabel.TextSize = 10
    SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubTitleLabel.ZIndex = 16
    SubTitleLabel.Parent = Topbar
    
    -- Window Controls Container
    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(0, 90, 1, 0)
    Controls.Position = UDim2.new(1, -95, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.ZIndex = 16
    Controls.Parent = Topbar
    
    local ControlsLayout = Instance.new("UIListLayout")
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsLayout.Padding = UDim.new(0, 10)
    ControlsLayout.Parent = Controls
    
    -- MINIMIZE BUTTON (Slightly larger)
    local MinimizeBtn = Instance.new("ImageButton")
    MinimizeBtn.Name = "Minimize"
    MinimizeBtn.Size = UDim2.new(0, 28, 0, 28) -- Larger than standard
    MinimizeBtn.BackgroundColor3 = theme.Element
    MinimizeBtn.Image = Icons.Minimize
    MinimizeBtn.ImageColor3 = theme.TextDim
    MinimizeBtn.ImageTransparency = 0.2
    MinimizeBtn.ScaleType = Enum.ScaleType.Fit
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.ZIndex = 17
    MinimizeBtn.Parent = Controls
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 8)
    MinCorner.Parent = MinimizeBtn
    
    -- CLOSE BUTTON (Standard size, distinct gap via UIListLayout padding)
    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.BackgroundColor3 = theme.Element
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
    
    -- Topbar Button Hover Effects
    local function SetupControlHover(button, hoverColor, normalColor)
        button.MouseEnter:Connect(function()
            Tween(button, {BackgroundColor3 = hoverColor, Size = UDim2.new(0, button.Size.X.Offset + 2, 0, button.Size.Y.Offset + 2)}, 0.2)
        end)
        button.MouseLeave:Connect(function()
            Tween(button, {BackgroundColor3 = normalColor, Size = UDim2.new(0, button.Size.X.Offset - 2, 0, button.Size.Y.Offset - 2)}, 0.2)
        end)
    end
    
    SetupControlHover(MinimizeBtn, Color3.fromRGB(40, 35, 55), theme.Element)
    SetupControlHover(CloseBtn, Color3.fromRGB(80, 35, 40), theme.Element)
    
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
    ModalFrame.Size = UDim2.new(0, 320, 0, 160)
    ModalFrame.Position = UDim2.new(0.5, -160, 0.5, -80)
    ModalFrame.BackgroundColor3 = theme.Surface
    ModalFrame.BackgroundTransparency = 0.1
    ModalFrame.BorderSizePixel = 0
    ModalFrame.ZIndex = 101
    ModalFrame.Visible = false
    ModalFrame.Parent = ModalBackdrop
    
    local ModalCorner = Instance.new("UICorner")
    ModalCorner.CornerRadius = UDim.new(0, 14)
    ModalCorner.Parent = ModalFrame
    
    local ModalStroke = Instance.new("UIStroke")
    ModalStroke.Color = theme.Accent
    ModalStroke.Thickness = 2
    ModalStroke.Transparency = 0.6
    ModalStroke.Parent = ModalFrame
    
    local ModalShadow = CreateShadow(ModalFrame, 8, 0.4, 14)
    ModalShadow.ZIndex = 100
    
    -- Modal Accent Bar (top)
    local ModalAccent = Instance.new("Frame")
    ModalAccent.Size = UDim2.new(1, 0, 0, 3)
    ModalAccent.Position = UDim2.new(0, 0, 0, 0)
    ModalAccent.BackgroundColor3 = theme.Accent
    ModalAccent.BorderSizePixel = 0
    ModalAccent.ZIndex = 102
    ModalAccent.Parent = ModalFrame
    
    local ModalAccentCorner = Instance.new("UICorner")
    ModalAccentCorner.CornerRadius = UDim.new(0, 3)
    ModalAccentCorner.Parent = ModalAccent
    
    -- Modal Title
    local ModalTitle = Instance.new("TextLabel")
    ModalTitle.Size = UDim2.new(1, -40, 0, 30)
    ModalTitle.Position = UDim2.new(0, 20, 0, 18)
    ModalTitle.BackgroundTransparency = 1
    ModalTitle.Text = "Confirm Action"
    ModalTitle.TextColor3 = theme.Text
    ModalTitle.Font = Enum.Font.GothamBold
    ModalTitle.TextSize = 16
    ModalTitle.TextXAlignment = Enum.TextXAlignment.Left
    ModalTitle.ZIndex = 102
    ModalTitle.Parent = ModalFrame
    
    -- Modal Message
    local ModalText = Instance.new("TextLabel")
    ModalText.Size = UDim2.new(1, -40, 0, 40)
    ModalText.Position = UDim2.new(0, 20, 0, 52)
    ModalText.BackgroundTransparency = 1
    ModalText.Text = "Are you sure you want to close this UI?"
    ModalText.TextColor3 = theme.TextDim
    ModalText.Font = Enum.Font.Gotham
    ModalText.TextSize = 13
    ModalText.TextWrapped = true
    ModalText.TextXAlignment = Enum.TextXAlignment.Left
    ModalText.ZIndex = 102
    ModalText.Parent = ModalFrame
    
    -- Modal Buttons Container
    local ModalButtons = Instance.new("Frame")
    ModalButtons.Size = UDim2.new(1, -40, 0, 36)
    ModalButtons.Position = UDim2.new(0, 20, 1, -56)
    ModalButtons.BackgroundTransparency = 1
    ModalButtons.ZIndex = 102
    ModalButtons.Parent = ModalFrame
    
    local ModalBtnLayout = Instance.new("UIListLayout")
    ModalBtnLayout.FillDirection = Enum.FillDirection.Horizontal
    ModalBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ModalBtnLayout.Padding = UDim.new(0, 12)
    ModalBtnLayout.Parent = ModalButtons
    
    -- NO BUTTON
    local NoBtn = Instance.new("TextButton")
    NoBtn.Name = "NoButton"
    NoBtn.Size = UDim2.new(0, 80, 1, 0)
    NoBtn.BackgroundColor3 = theme.Element
    NoBtn.Text = "No"
    NoBtn.TextColor3 = theme.TextDim
    NoBtn.Font = Enum.Font.GothamBold
    NoBtn.TextSize = 13
    NoBtn.AutoButtonColor = false
    NoBtn.ZIndex = 103
    NoBtn.Parent = ModalButtons
    
    local NoCorner = Instance.new("UICorner")
    NoCorner.CornerRadius = UDim.new(0, 8)
    NoCorner.Parent = NoBtn
    
    -- YES BUTTON
    local YesBtn = Instance.new("TextButton")
    YesBtn.Name = "YesButton"
    YesBtn.Size = UDim2.new(0, 80, 1, 0)
    YesBtn.BackgroundColor3 = theme.Accent
    YesBtn.Text = "Yes"
    YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesBtn.Font = Enum.Font.GothamBold
    YesBtn.TextSize = 13
    YesBtn.AutoButtonColor = false
    YesBtn.ZIndex = 103
    YesBtn.Parent = ModalButtons
    
    local YesCorner = Instance.new("UICorner")
    YesCorner.CornerRadius = UDim.new(0, 8)
    YesCorner.Parent = YesBtn
    
    -- Modal Button Hovers
    NoBtn.MouseEnter:Connect(function()
        Tween(NoBtn, {BackgroundColor3 = Color3.fromRGB(50, 45, 65), TextColor3 = theme.Text}, 0.2)
    end)
    NoBtn.MouseLeave:Connect(function()
        Tween(NoBtn, {BackgroundColor3 = theme.Element, TextColor3 = theme.TextDim}, 0.2)
    end)
    
    YesBtn.MouseEnter:Connect(function()
        Tween(YesBtn, {BackgroundColor3 = Color3.fromRGB(188, 105, 267), Size = UDim2.new(0, 84, 1, 0)}, 0.2)
    end)
    YesBtn.MouseLeave:Connect(function()
        Tween(YesBtn, {BackgroundColor3 = theme.Accent, Size = UDim2.new(0, 80, 1, 0)}, 0.2)
    end)
    
    -- ==========================================
    -- ANIMATION STATES
    -- ==========================================
    local isMinimized = false
    local isClosing = false
    
    -- Minimize Logic
    MinimizeBtn.MouseButton1Click:Connect(function()
        if isMinimized then return end
        isMinimized = true
        
        -- Animate MainFrame out
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset + 325, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset + 200), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        Tween(MainStroke, {Transparency = 1}, 0.3)
        Tween(MainShadow, {ImageTransparency = 1}, 0.3)
        
        -- Hide content
        for _, child in pairs(MainFrame:GetDescendants()) do
            if child:IsA("GuiObject") and child ~= MainFrame then
                Tween(child, {BackgroundTransparency = 1, TextTransparency = 1, ImageTransparency = 1}, 0.2)
            end
        end
        
        task.delay(0.4, function()
            MainFrame.Visible = false
            FloatingIcon.Visible = true
            FloatingIcon.Size = UDim2.new(0, 0, 0, 0)
            Tween(FloatingIcon, {Size = UDim2.new(0, 52, 0, 52)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            Tween(FloatStroke, {Transparency = 0.3}, 0.5)
        end)
    end)
    
    -- Floating Icon Open Logic
    FloatingIcon.MouseButton1Click:Connect(function()
        if not isMinimized then return end
        isMinimized = false
        
        Tween(FloatingIcon, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        Tween(FloatStroke, {Transparency = 1}, 0.3)
        
        task.delay(0.3, function()
            FloatingIcon.Visible = false
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset - 325, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset - 200)
            MainFrame.BackgroundTransparency = 1
            
            -- Restore content transparency
            for _, child in pairs(MainFrame:GetDescendants()) do
                if child:IsA("GuiObject") and child ~= MainFrame and child ~= ModalBackdrop and child ~= ModalFrame then
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        child.TextTransparency = 1
                        child.BackgroundTransparency = child.Name == "GradientOverlay" and 0.9 or (child.BackgroundTransparency > 0.9 and 1 or child.BackgroundTransparency)
                    elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                        child.ImageTransparency = 1
                        child.BackgroundTransparency = 1
                    end
                end
            end
            
            -- Animate MainFrame in
            Tween(MainFrame, {Size = UDim2.new(0, 650, 0, 400), Position = UDim2.new(0.5, -325, 0.5, -200), BackgroundTransparency = 0.05}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            Tween(MainStroke, {Transparency = 0.5}, 0.5)
            Tween(MainShadow, {ImageTransparency = 0.5}, 0.5)
            
            -- Fade content back in
            task.delay(0.2, function()
                for _, child in pairs(MainFrame:GetDescendants()) do
                    if child:IsA("GuiObject") and child ~= MainFrame and child ~= ModalBackdrop and child ~= ModalFrame then
                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                            Tween(child, {TextTransparency = 0}, 0.3)
                            if child.BackgroundTransparency < 1 and child.Name ~= "GradientOverlay" then
                                Tween(child, {BackgroundTransparency = 0}, 0.3)
                            end
                        elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                            Tween(child, {ImageTransparency = 0.2}, 0.3)
                            if child.BackgroundTransparency < 1 then
                                Tween(child, {BackgroundTransparency = 0.1}, 0.3)
                            end
                        end
                    end
                end
            end)
        end)
    end)
    
    -- Close Logic with Confirmation
    CloseBtn.MouseButton1Click:Connect(function()
        if isClosing then return end
        
        -- Show Modal with animation
        ModalBackdrop.Visible = true
        ModalFrame.Visible = true
        ModalFrame.Size = UDim2.new(0, 280, 0, 140)
        ModalFrame.BackgroundTransparency = 1
        ModalStroke.Transparency = 1
        ModalBackdrop.BackgroundTransparency = 1
        
        Tween(ModalBackdrop, {BackgroundTransparency = 0.6}, 0.3)
        Tween(ModalFrame, {Size = UDim2.new(0, 320, 0, 160), BackgroundTransparency = 0.1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Tween(ModalStroke, {Transparency = 0.6}, 0.4)
    end)
    
    local function CloseModal()
        Tween(ModalFrame, {Size = UDim2.new(0, 280, 0, 140), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
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
            -- Animate entire UI destruction
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            Tween(MainStroke, {Transparency = 1}, 0.4)
            Tween(MainShadow, {ImageTransparency = 1}, 0.4)
            
            for _, child in pairs(MainFrame:GetDescendants()) do
                if child:IsA("GuiObject") then
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        Tween(child, {TextTransparency = 1, BackgroundTransparency = 1}, 0.3)
                    elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                        Tween(child, {ImageTransparency = 1, BackgroundTransparency = 1}, 0.3)
                    else
                        Tween(child, {BackgroundTransparency = 1}, 0.3)
                    end
                end
            end
            
            task.delay(0.6, function()
                ShieldGui:Destroy()
            end)
        end)
    end)
    
    -- ==========================================
    -- SIDEBAR & CONTENT AREA
    -- ==========================================
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 170, 1, -54)
    Sidebar.Position = UDim2.new(0, 10, 0, 50)
    Sidebar.BackgroundColor3 = theme.Surface
    Sidebar.BackgroundTransparency = 0.3
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 12
    Sidebar.Parent = MainFrame
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    SidebarCorner.Parent = Sidebar
    
    local SidebarStroke = Instance.new("UIStroke")
    SidebarStroke.Color = theme.Border
    SidebarStroke.Thickness = 1
    SidebarStroke.Transparency = 0.7
    SidebarStroke.Parent = Sidebar
    
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 6)
    SidebarLayout.Parent = Sidebar
    
    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 10)
    SidebarPadding.PaddingLeft = UDim.new(0, 10)
    SidebarPadding.PaddingRight = UDim.new(0, 10)
    SidebarPadding.PaddingBottom = UDim.new(0, 10)
    SidebarPadding.Parent = Sidebar
    
    -- Page Container
    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "PageContainer"
    PageContainer.Size = UDim2.new(1, -200, 1, -54)
    PageContainer.Position = UDim2.new(0, 190, 0, 50)
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
        
        -- Tab Button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName .. "_Tab"
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundColor3 = theme.Accent
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.ZIndex = 13
        TabBtn.Parent = Sidebar
        
        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 8)
        TabBtnCorner.Parent = TabBtn
        
        -- Tab Icon
        local TabIconImg = Instance.new("ImageLabel")
        TabIconImg.Size = UDim2.new(0, 20, 0, 20)
        TabIconImg.Position = UDim2.new(0, 10, 0, 8)
        TabIconImg.BackgroundTransparency = 1
        TabIconImg.Image = tabIcon
        TabIconImg.ImageColor3 = theme.TextDim
        TabIconImg.ZIndex = 14
        TabIconImg.Parent = TabBtn
        
        -- Tab Label
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -40, 1, 0)
        TabLabel.Position = UDim2.new(0, 36, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName
        TabLabel.TextColor3 = theme.TextDim
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.TextSize = 12
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.ZIndex = 14
        TabLabel.Parent = TabBtn
        
        -- Page
        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = theme.Accent
        Page.ScrollBarImageTransparency = 0.5
        Page.Visible = false
        Page.ZIndex = 12
        Page.Parent = PageContainer
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 12)
        PageLayout.Parent = Page
        
        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingRight = UDim.new(0, 10)
        PagePadding.PaddingBottom = UDim.new(0, 15)
        PagePadding.Parent = Page
        
        -- Auto-update canvas size
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Tab Activation Logic
        local function Activate()
            if ActiveTab == TabBtn then return end
            
            -- Deactivate previous
            if ActiveTab then
                local prevPage = PageContainer:FindFirstChild(ActiveTab.Name:gsub("_Tab", "_Page"))
                if prevPage then
                    Tween(prevPage, {ScrollBarImageTransparency = 1}, 0.2)
                    for _, child in pairs(prevPage:GetDescendants()) do
                        if child:IsA("GuiObject") then
                            if child:IsA("TextLabel") or child:IsA("TextButton") then
                                Tween(child, {TextTransparency = 1}, 0.2)
                            end
                            if child:IsA("Frame") and child.BackgroundTransparency < 1 then
                                Tween(child, {BackgroundTransparency = 1}, 0.2)
                            end
                            if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                                Tween(child, {ImageTransparency = 1}, 0.2)
                            end
                        end
                    end
                    task.delay(0.2, function()
                        prevPage.Visible = false
                        -- Reset transparencies
                        for _, child in pairs(prevPage:GetDescendants()) do
                            if child:IsA("GuiObject") then
                                if child:IsA("TextLabel") or child:IsA("TextButton") then
                                    child.TextTransparency = 0
                                end
                                if child:IsA("Frame") and child.Name ~= "GradientOverlay" then
                                    child.BackgroundTransparency = 0.3
                                end
                                if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                                    child.ImageTransparency = 0.2
                                end
                            end
                        end
                    end)
                end
                
                Tween(ActiveTab, {BackgroundTransparency = 1}, 0.3)
                local prevIcon = ActiveTab:FindFirstChildOfClass("ImageLabel")
                local prevLabel = ActiveTab:FindFirstChildOfClass("TextLabel")
                if prevIcon then Tween(prevIcon, {ImageColor3 = theme.TextDim}, 0.3) end
                if prevLabel then Tween(prevLabel, {TextColor3 = theme.TextDim}, 0.3) end
            end
            
            -- Activate new
            ActiveTab = TabBtn
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.85}, 0.3)
            Tween(TabIconImg, {ImageColor3 = theme.Accent}, 0.3)
            Tween(TabLabel, {TextColor3 = theme.Text}, 0.3)
            
            -- Animate page content in
            for _, child in pairs(Page:GetDescendants()) do
                if child:IsA("GuiObject") and child:IsA("Frame") and child.BackgroundTransparency < 1 then
                    child.BackgroundTransparency = 1
                    Tween(child, {BackgroundTransparency = 0.3}, 0.3)
                end
            end
        end
        
        TabBtn.MouseButton1Click:Connect(Activate)
        
        -- Tab Hover
        TabBtn.MouseEnter:Connect(function()
            if ActiveTab ~= TabBtn then
                Tween(TabBtn, {BackgroundTransparency = 0.95}, 0.2)
                Tween(TabIconImg, {ImageColor3 = Color3.fromRGB(180, 180, 200)}, 0.2)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if ActiveTab ~= TabBtn then
                Tween(TabBtn, {BackgroundTransparency = 1}, 0.2)
                Tween(TabIconImg, {ImageColor3 = theme.TextDim}, 0.2)
            end
        end)
        
        -- Set first tab as active
        if TabCount == 1 then
            task.delay(0.1, Activate)
        end
        
        -- ==========================================
        -- SECTION SYSTEM
        -- ==========================================
        local Sections = {}
        
        function Sections:CreateSection(sectionConfig)
            local sectionTitle = sectionConfig.Name or "Section"
            local sectionIcon = sectionConfig.Icon
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = sectionTitle .. "_Section"
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.BackgroundColor3 = theme.Surface
            SectionFrame.BackgroundTransparency = 0.2
            SectionFrame.BorderSizePixel = 0
            SectionFrame.ClipsDescendants = true
            SectionFrame.ZIndex = 13
            SectionFrame.Parent = Page
            
            local SecCorner = Instance.new("UICorner")
            SecCorner.CornerRadius = UDim.new(0, 10)
            SecCorner.Parent = SectionFrame
            
            local SecStroke = Instance.new("UIStroke")
            SecStroke.Color = theme.Border
            SecStroke.Thickness = 1
            SecStroke.Transparency = 0.8
            SecStroke.Parent = SectionFrame
            
            local SecShadow = CreateShadow(SectionFrame, 4, 0.7, 10)
            SecShadow.ZIndex = 12
            
            -- Section Header
            local SecHeader = Instance.new("Frame")
            SecHeader.Size = UDim2.new(1, 0, 0, 36)
            SecHeader.BackgroundTransparency = 1
            SecHeader.ZIndex = 14
            SecHeader.Parent = SectionFrame
            
            if sectionIcon then
                local SecIcon = Instance.new("ImageLabel")
                SecIcon.Size = UDim2.new(0, 18, 0, 18)
                SecIcon.Position = UDim2.new(0, 12, 0, 9)
                SecIcon.BackgroundTransparency = 1
                SecIcon.Image = sectionIcon
                SecIcon.ImageColor3 = theme.Accent
                SecIcon.ZIndex = 15
                SecIcon.Parent = SecHeader
                
                local SecTitle = Instance.new("TextLabel")
                SecTitle.Size = UDim2.new(1, -40, 1, 0)
                SecTitle.Position = UDim2.new(0, 36, 0, 0)
                SecTitle.BackgroundTransparency = 1
                SecTitle.Text = sectionTitle
                SecTitle.TextColor3 = theme.Accent
                SecTitle.Font = Enum.Font.GothamBold
                SecTitle.TextSize = 12
                SecTitle.TextXAlignment = Enum.TextXAlignment.Left
                SecTitle.ZIndex = 15
                SecTitle.Parent = SecHeader
            else
                local SecTitle = Instance.new("TextLabel")
                SecTitle.Size = UDim2.new(1, -20, 1, 0)
                SecTitle.Position = UDim2.new(0, 12, 0, 0)
                SecTitle.BackgroundTransparency = 1
                SecTitle.Text = sectionTitle
                SecTitle.TextColor3 = theme.Accent
                SecTitle.Font = Enum.Font.GothamBold
                SecTitle.TextSize = 12
                SecTitle.TextXAlignment = Enum.TextXAlignment.Left
                SecTitle.ZIndex = 15
                SecTitle.Parent = SecHeader
            end
            
            local SecLayout = Instance.new("UIListLayout")
            SecLayout.Padding = UDim.new(0, 8)
            SecLayout.Parent = SectionFrame
            
            local SecPadding = Instance.new("UIPadding")
            SecPadding.PaddingTop = UDim.new(0, 40)
            SecPadding.PaddingBottom = UDim.new(0, 12)
            SecPadding.PaddingLeft = UDim.new(0, 12)
            SecPadding.PaddingRight = UDim.new(0, 12)
            SecPadding.Parent = SectionFrame
            
            -- Auto-resize section
            SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, SecLayout.AbsoluteContentSize.Y + 52)
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
                BtnContainer.Size = UDim2.new(1, 0, 0, 36)
                BtnContainer.BackgroundTransparency = 1
                BtnContainer.ZIndex = 14
                BtnContainer.Parent = SectionFrame
                
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.BackgroundColor3 = theme.Element
                Btn.Text = btnName
                Btn.TextColor3 = theme.Text
                Btn.Font = Enum.Font.GothamMedium
                Btn.TextSize = 12
                Btn.AutoButtonColor = false
                Btn.ZIndex = 15
                Btn.Parent = BtnContainer
                
                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 8)
                BtnCorner.Parent = Btn
                
                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = theme.Border
                BtnStroke.Thickness = 1
                BtnStroke.Transparency = 0.9
                BtnStroke.Parent = Btn
                
                -- Hover & Click
                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Color3.fromRGB(40, 35, 55), Size = UDim2.new(1, 4, 1, 4)}, 0.2)
                    Tween(BtnStroke, {Transparency = 0.6, Color = theme.Accent}, 0.2)
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {BackgroundColor3 = theme.Element, Size = UDim2.new(1, 0, 1, 0)}, 0.2)
                    Tween(BtnStroke, {Transparency = 0.9, Color = theme.Border}, 0.2)
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
                        if not success then warn("Button callback error: " .. tostring(err)) end
                    end)
                end)
                
                return Btn
            end
            
            -- 2. TOGGLE
            function Elements:CreateToggle(toggleConfig)
                local toggleName = toggleConfig.Name or "Toggle"
                local default = toggleConfig.Default or false
                local callback = toggleConfig.Callback or function() end
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
                ToggleFrame.BackgroundColor3 = theme.Element
                ToggleFrame.BackgroundTransparency = 0.3
                ToggleFrame.BorderSizePixel = 0
                ToggleFrame.ZIndex = 14
                ToggleFrame.Parent = SectionFrame
                
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(0, 8)
                ToggleCorner.Parent = ToggleFrame
                
                local ToggleStroke = Instance.new("UIStroke")
                ToggleStroke.Color = theme.Border
                ToggleStroke.Thickness = 1
                ToggleStroke.Transparency = 0.9
                ToggleStroke.Parent = ToggleFrame
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.7, 0, 1, 0)
                Label.Position = UDim2.new(0, 12, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = toggleName
                Label.TextColor3 = theme.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 15
                Label.Parent = ToggleFrame
                
                -- Toggle Switch Container
                local SwitchBg = Instance.new("TextButton")
                SwitchBg.Size = UDim2.new(0, 44, 0, 22)
                SwitchBg.Position = UDim2.new(1, -56, 0.5, -11)
                SwitchBg.BackgroundColor3 = default and theme.Accent or Color3.fromRGB(45, 40, 60)
                SwitchBg.Text = ""
                SwitchBg.AutoButtonColor = false
                SwitchBg.ZIndex = 15
                SwitchBg.Parent = ToggleFrame
                
                local SwitchCorner = Instance.new("UICorner")
                SwitchCorner.CornerRadius = UDim.new(1, 0)
                SwitchCorner.Parent = SwitchBg
                
                local SwitchCircle = Instance.new("Frame")
                SwitchCircle.Size = UDim2.new(0, 16, 0, 16)
                SwitchCircle.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                SwitchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SwitchCircle.BorderSizePixel = 0
                SwitchCircle.ZIndex = 16
                SwitchCircle.Parent = SwitchBg
                
                local CircleCorner = Instance.new("UICorner")
                CircleCorner.CornerRadius = UDim.new(1, 0)
                CircleCorner.Parent = SwitchCircle
                
                -- Glow effect when on
                local SwitchGlow = Instance.new("ImageLabel")
                SwitchGlow.Size = UDim2.new(1, 10, 1, 10)
                SwitchGlow.Position = UDim2.new(0.5, -5, 0.5, -5)
                SwitchGlow.BackgroundTransparency = 1
                SwitchGlow.Image = "rbxassetid://4996891970" -- Glow asset
                SwitchGlow.ImageColor3 = theme.Accent
                SwitchGlow.ImageTransparency = default and 0.7 or 1
                SwitchGlow.ZIndex = 14
                SwitchGlow.Parent = SwitchBg
                
                local toggled = default
                
                local function UpdateToggle()
                    toggled = not toggled
                    Tween(SwitchBg, {BackgroundColor3 = toggled and theme.Accent or Color3.fromRGB(45, 40, 60)}, 0.3)
                    Tween(SwitchCircle, {Position = toggled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                    Tween(SwitchGlow, {ImageTransparency = toggled and 0.7 or 1}, 0.3)
                    Tween(ToggleStroke, {Color = toggled and theme.Accent or theme.Border, Transparency = toggled and 0.6 or 0.9}, 0.3)
                    
                    task.spawn(function()
                        local success, err = pcall(callback, toggled)
                        if not success then warn("Toggle callback error: " .. tostring(err)) end
                    end)
                end
                
                SwitchBg.MouseButton1Click:Connect(UpdateToggle)
                ToggleFrame.MouseButton1Click:Connect(UpdateToggle)
                
                -- Hover
                ToggleFrame.MouseEnter:Connect(function()
                    Tween(ToggleFrame, {BackgroundColor3 = Color3.fromRGB(35, 30, 50)}, 0.2)
                end)
                ToggleFrame.MouseLeave:Connect(function()
                    Tween(ToggleFrame, {BackgroundColor3 = theme.Element}, 0.2)
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
                SliderFrame.Size = UDim2.new(1, 0, 0, 50)
                SliderFrame.BackgroundColor3 = theme.Element
                SliderFrame.BackgroundTransparency = 0.3
                SliderFrame.BorderSizePixel = 0
                SliderFrame.ZIndex = 14
                SliderFrame.Parent = SectionFrame
                
                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(0, 8)
                SliderCorner.Parent = SliderFrame
                
                local SliderStroke = Instance.new("UIStroke")
                SliderStroke.Color = theme.Border
                SliderStroke.Thickness = 1
                SliderStroke.Transparency = 0.9
                SliderStroke.Parent = SliderFrame
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.6, 0, 0, 20)
                Label.Position = UDim2.new(0, 12, 0, 6)
                Label.BackgroundTransparency = 1
                Label.Text = sliderName
                Label.TextColor3 = theme.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 15
                Label.Parent = SliderFrame
                
                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0.3, 0, 0, 20)
                ValueLabel.Position = UDim2.new(0.7, -5, 0, 6)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(default)
                ValueLabel.TextColor3 = theme.Accent
                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.TextSize = 12
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.ZIndex = 15
                ValueLabel.Parent = SliderFrame
                
                -- Slider Track
                local Track = Instance.new("Frame")
                Track.Size = UDim2.new(1, -24, 0, 6)
                Track.Position = UDim2.new(0, 12, 0, 32)
                Track.BackgroundColor3 = Color3.fromRGB(35, 30, 50)
                Track.BorderSizePixel = 0
                Track.ZIndex = 15
                Track.Parent = SliderFrame
                
                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(1, 0)
                TrackCorner.Parent = Track
                
                -- Slider Fill
                local Fill = Instance.new("Frame")
                local fillPercent = (default - min) / (max - min)
                Fill.Size = UDim2.new(fillPercent, 0, 1, 0)
                Fill.BackgroundColor3 = theme.Accent
                Fill.BorderSizePixel = 0
                Fill.ZIndex = 16
                Fill.Parent = Track
                
                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = Fill
                
                -- Slider Knob (Image)
                local Knob = Instance.new("ImageLabel")
                Knob.Size = UDim2.new(0, 14, 0, 14)
                Knob.Position = UDim2.new(fillPercent, -7, 0.5, -7)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.BackgroundTransparency = 0
                Knob.Image = Icons.SliderKnob
                Knob.ImageColor3 = Color3.fromRGB(255, 255, 255)
                Knob.ZIndex = 17
                Knob.Parent = Track
                
                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = Knob
                
                -- Knob Glow
                local KnobGlow = Instance.new("ImageLabel")
                KnobGlow.Size = UDim2.new(1, 8, 1, 8)
                KnobGlow.Position = UDim2.new(0.5, -4, 0.5, -4)
                KnobGlow.BackgroundTransparency = 1
                KnobGlow.Image = "rbxassetid://4996891970"
                KnobGlow.ImageColor3 = theme.Accent
                KnobGlow.ImageTransparency = 0.6
                KnobGlow.ZIndex = 16
                KnobGlow.Parent = Knob
                
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
                    Tween(Knob, {Position = UDim2.new(pos, -7, 0.5, -7)}, 0.05)
                    
                    task.spawn(function()
                        local success, err = pcall(callback, val)
                        if not success then warn("Slider callback error: " .. tostring(err)) end
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
                
                -- Hover
                SliderFrame.MouseEnter:Connect(function()
                    Tween(SliderFrame, {BackgroundColor3 = Color3.fromRGB(35, 30, 50)}, 0.2)
                    Tween(SliderStroke, {Transparency = 0.7}, 0.2)
                end)
                SliderFrame.MouseLeave:Connect(function()
                    Tween(SliderFrame, {BackgroundColor3 = theme.Element}, 0.2)
                    Tween(SliderStroke, {Transparency = 0.9}, 0.2)
                end)
                
                return {
                    Set = function(value)
                        value = math.clamp(value, min, max)
                        local pos = (value - min) / (max - min)
                        ValueLabel.Text = tostring(value)
                        Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.3)
                        Tween(Knob, {Position = UDim2.new(pos, -7, 0.5, -7)}, 0.3)
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
                DropFrame.Size = UDim2.new(1, 0, 0, 36)
                DropFrame.BackgroundColor3 = theme.Element
                DropFrame.BackgroundTransparency = 0.3
                DropFrame.BorderSizePixel = 0
                DropFrame.ClipsDescendants = true
                DropFrame.ZIndex = 14
                DropFrame.Parent = SectionFrame
                
                local DropCorner = Instance.new("UICorner")
                DropCorner.CornerRadius = UDim.new(0, 8)
                DropCorner.Parent = DropFrame
                
                local DropStroke = Instance.new("UIStroke")
                DropStroke.Color = theme.Border
                DropStroke.Thickness = 1
                DropStroke.Transparency = 0.9
                DropStroke.Parent = DropFrame
                
                -- Header Button
                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(1, 0, 0, 36)
                DropBtn.BackgroundTransparency = 1
                DropBtn.Text = ""
                DropBtn.ZIndex = 15
                DropBtn.Parent = DropFrame
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.5, 0, 1, 0)
                Label.Position = UDim2.new(0, 12, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = dropName
                Label.TextColor3 = theme.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 16
                Label.Parent = DropBtn
                
                local SelectedLabel = Instance.new("TextLabel")
                SelectedLabel.Size = UDim2.new(0.4, -30, 1, 0)
                SelectedLabel.Position = UDim2.new(0.6, 0, 0, 0)
                SelectedLabel.BackgroundTransparency = 1
                SelectedLabel.Text = default
                SelectedLabel.TextColor3 = theme.Accent
                SelectedLabel.Font = Enum.Font.GothamBold
                SelectedLabel.TextSize = 11
                SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
                SelectedLabel.ZIndex = 16
                SelectedLabel.Parent = DropBtn
                
                -- Arrow Icon
                local ArrowIcon = Instance.new("ImageLabel")
                ArrowIcon.Size = UDim2.new(0, 16, 0, 16)
                ArrowIcon.Position = UDim2.new(1, -26, 0.5, -8)
                ArrowIcon.BackgroundTransparency = 1
                ArrowIcon.Image = Icons.DropdownArrow
                ArrowIcon.ImageColor3 = theme.TextDim
                ArrowIcon.ZIndex = 16
                ArrowIcon.Parent = DropBtn
                
                -- Options Container
                local OptionContainer = Instance.new("Frame")
                OptionContainer.Size = UDim2.new(1, -10, 0, #options * 30)
                OptionContainer.Position = UDim2.new(0, 5, 0, 38)
                OptionContainer.BackgroundTransparency = 1
                OptionContainer.ZIndex = 15
                OptionContainer.Parent = DropFrame
                
                local OptLayout = Instance.new("UIListLayout")
                OptLayout.Padding = UDim.new(0, 4)
                OptLayout.Parent = OptionContainer
                
                local isOpen = false
                
                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 28)
                    OptBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 50)
                    OptBtn.Text = opt
                    OptBtn.TextColor3 = theme.TextDim
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 11
                    OptBtn.AutoButtonColor = false
                    OptBtn.ZIndex = 16
                    OptBtn.Parent = OptionContainer
                    
                    local OptCorner = Instance.new("UICorner")
                    OptCorner.CornerRadius = UDim.new(0, 6)
                    OptCorner.Parent = OptBtn
                    
                    OptBtn.MouseEnter:Connect(function()
                        Tween(OptBtn, {BackgroundColor3 = theme.Accent, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        Tween(OptBtn, {BackgroundColor3 = Color3.fromRGB(35, 30, 50), TextColor3 = theme.TextDim}, 0.2)
                    end)
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        SelectedLabel.Text = opt
                        isOpen = false
                        Tween(ArrowIcon, {Rotation = 0}, 0.3)
                        Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
                        
                        task.spawn(function()
                            local success, err = pcall(callback, opt)
                            if not success then warn("Dropdown callback error: " .. tostring(err)) end
                        end)
                    end)
                end
                
                DropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    local targetSize = isOpen and UDim2.new(1, 0, 0, 42 + (#options * 30)) or UDim2.new(1, 0, 0, 36)
                    Tween(ArrowIcon, {Rotation = isOpen and 180 or 0}, 0.3)
                    Tween(DropFrame, {Size = targetSize}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
                    Tween(DropStroke, {Color = isOpen and theme.Accent or theme.Border, Transparency = isOpen and 0.6 or 0.9}, 0.3)
                end)
                
                -- Hover
                DropBtn.MouseEnter:Connect(function()
                    Tween(DropFrame, {BackgroundColor3 = Color3.fromRGB(35, 30, 50)}, 0.2)
                end)
                DropBtn.MouseLeave:Connect(function()
                    if not isOpen then
                        Tween(DropFrame, {BackgroundColor3 = theme.Element}, 0.2)
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
                        -- Clear existing
                        for _, child in pairs(OptionContainer:GetChildren()) do
                            if child:IsA("TextButton") then child:Destroy() end
                        end
                        options = newOptions
                        -- Rebuild (simplified - full implementation would recreate options)
                    end
                }
            end
            
            -- 5. TEXTBOX / INPUT
            function Elements:CreateInput(inputConfig)
                local inputName = inputConfig.Name or "Input"
                local default = inputConfig.Default or ""
                local placeholder = inputConfig.Placeholder or "Enter text..."
                local callback = inputConfig.Callback or function() end
                
                local InputFrame = Instance.new("Frame")
                InputFrame.Size = UDim2.new(1, 0, 0, 36)
                InputFrame.BackgroundColor3 = theme.Element
                InputFrame.BackgroundTransparency = 0.3
                InputFrame.BorderSizePixel = 0
                InputFrame.ZIndex = 14
                InputFrame.Parent = SectionFrame
                
                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 8)
                InputCorner.Parent = InputFrame
                
                local InputStroke = Instance.new("UIStroke")
                InputStroke.Color = theme.Border
                InputStroke.Thickness = 1
                InputStroke.Transparency = 0.9
                InputStroke.Parent = InputFrame
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.4, 0, 1, 0)
                Label.Position = UDim2.new(0, 12, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = inputName
                Label.TextColor3 = theme.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 15
                Label.Parent = InputFrame
                
                local TextBox = Instance.new("TextBox")
                TextBox.Size = UDim2.new(0.55, -10, 0, 26)
                TextBox.Position = UDim2.new(0.45, 0, 0.5, -13)
                TextBox.BackgroundColor3 = Color3.fromRGB(20, 18, 30)
                TextBox.Text = default
                TextBox.PlaceholderText = placeholder
                TextBox.TextColor3 = theme.Text
                TextBox.PlaceholderColor3 = theme.TextDim
                TextBox.Font = Enum.Font.Gotham
                TextBox.TextSize = 11
                TextBox.ClearTextOnFocus = false
                TextBox.ZIndex = 15
                TextBox.Parent = InputFrame
                
                local TextCorner = Instance.new("UICorner")
                TextCorner.CornerRadius = UDim.new(0, 6)
                TextCorner.Parent = TextBox
                
                TextBox.Focused:Connect(function()
                    Tween(InputStroke, {Color = theme.Accent, Transparency = 0.5}, 0.2)
                    Tween(TextBox, {BackgroundColor3 = Color3.fromRGB(30, 25, 45)}, 0.2)
                end)
                TextBox.FocusLost:Connect(function()
                    Tween(InputStroke, {Color = theme.Border, Transparency = 0.9}, 0.2)
                    Tween(TextBox, {BackgroundColor3 = Color3.fromRGB(20, 18, 30)}, 0.2)
                    task.spawn(function()
                        local success, err = pcall(callback, TextBox.Text)
                        if not success then warn("Input callback error: " .. tostring(err)) end
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
                local labelColor = labelConfig.Color or theme.TextDim
                
                local LabelFrame = Instance.new("Frame")
                LabelFrame.Size = UDim2.new(1, 0, 0, 24)
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.ZIndex = 14
                LabelFrame.Parent = SectionFrame
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -10, 1, 0)
                Label.Position = UDim2.new(0, 5, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = labelText
                Label.TextColor3 = labelColor
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
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
