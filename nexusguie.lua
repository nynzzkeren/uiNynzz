-- ============================================
-- CUSTOM UI LIBRARY: MiniBoxUI
-- Kotak kecil, bisa minimize, 1 toggle master
-- ============================================

local MiniBoxUI = {}

function MiniBoxUI:Create(config)
    config = config or {}
    local Title = config.Title or "KAITUN"
    local Subtitle = config.Subtitle or "by User"
    local Width = config.Width or 220
    local Height = config.Height or 140
    
    -- Services
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer
    local mouse = player:GetMouse()
    
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MiniBoxUI_" .. Title
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, Width, 0, Height)
    MainFrame.Position = UDim2.new(0.85, 0, 0.1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.ZIndex = 0
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    -- Fix corner biar bawahnya flat
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 8)
    TitleFix.Position = UDim2.new(0, 0, 1, -8)
    TitleFix.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = TitleBar
    
    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "Title"
    TitleText.Size = UDim2.new(1, -60, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = Title
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 14
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Subtitle
    local SubtitleText = Instance.new("TextLabel")
    SubtitleText.Name = "Subtitle"
    SubtitleText.Size = UDim2.new(1, -20, 0, 16)
    SubtitleText.Position = UDim2.new(0, 10, 0, 34)
    SubtitleText.BackgroundTransparency = 1
    SubtitleText.Text = Subtitle
    SubtitleText.TextColor3 = Color3.fromRGB(180, 180, 180)
    SubtitleText.TextSize = 10
    SubtitleText.Font = Enum.Font.Gotham
    SubtitleText.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleText.Parent = MainFrame
    
    -- Minimize Button
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
    MinimizeBtn.Position = UDim2.new(1, -52, 0, 4)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    MinimizeBtn.TextSize = 16
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Parent = TitleBar
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 4)
    MinCorner.Parent = MinimizeBtn
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Position = UDim2.new(1, -28, 0, 4)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 12
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseBtn
    
    -- Content Frame (isi konten)
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, -20, 1, -70)
    ContentFrame.Position = UDim2.new(0, 10, 0, 54)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    
    -- MASTER TOGGLE (The One Toggle to Rule Them All)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "MasterToggle"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = ContentFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = "🤖 KAITUN ON/OFF"
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 12
    ToggleLabel.Font = Enum.Font.GothamBold
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    -- Toggle Switch
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Size = UDim2.new(0, 44, 0, 22)
    ToggleBtn.Position = UDim2.new(1, -54, 0.5, -11)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    ToggleBtn.Text = ""
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = ToggleFrame
    
    local ToggleBtnCorner = Instance.new("UICorner")
    ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
    ToggleBtnCorner.Parent = ToggleBtn
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Name = "Circle"
    ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -9)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Parent = ToggleBtn
    
    local ToggleCircleCorner = Instance.new("UICorner")
    ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCircleCorner.Parent = ToggleCircle
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "Status"
    StatusLabel.Size = UDim2.new(1, 0, 0, 16)
    StatusLabel.Position = UDim2.new(0, 0, 0, 40)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "⏹️ STOPPED"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    StatusLabel.TextSize = 10
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.Parent = ContentFrame
    
    -- Stats Display (mini)
    local StatsFrame = Instance.new("Frame")
    StatsFrame.Name = "Stats"
    StatsFrame.Size = UDim2.new(1, 0, 0, 20)
    StatsFrame.Position = UDim2.new(0, 0, 1, -20)
    StatsFrame.BackgroundTransparency = 1
    StatsFrame.Parent = ContentFrame
    
    local StatsText = Instance.new("TextLabel")
    StatsText.Name = "StatsText"
    StatsText.Size = UDim2.new(1, 0, 1, 0)
    StatsText.BackgroundTransparency = 1
    StatsText.Text = "STR: - | CASH: - | GEM: -"
    StatsText.TextColor3 = Color3.fromRGB(150, 150, 150)
    StatsText.TextSize = 9
    StatsText.Font = Enum.Font.Gotham
    StatsText.TextXAlignment = Enum.TextXAlignment.Left
    StatsText.Parent = StatsFrame
    
    -- State
    local isMinimized = false
    local isToggled = false
    local originalHeight = Height
    local minimizedHeight = 32
    
    -- Drag functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Minimize
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, Width, 0, minimizedHeight) or UDim2.new(0, Width, 0, originalHeight)
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
        MinimizeBtn.Text = isMinimized and "+" or "-"
        ContentFrame.Visible = not isMinimized
        SubtitleText.Visible = not isMinimized
    end)
    
    -- Close
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Master Toggle Function
    local function SetToggle(state)
        isToggled = state
        local targetColor = isToggled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
        local targetPos = isToggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        
        StatusLabel.Text = isToggled and "▶️ RUNNING..." or "⏹️ STOPPED"
        StatusLabel.TextColor3 = isToggled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 80, 80)
    end
    
    ToggleBtn.MouseButton1Click:Connect(function()
        SetToggle(not isToggled)
    end)
    
    -- Public API
    local UI = {}
    
    function UI:GetToggleState()
        return isToggled
    end
    
    function UI:SetToggleState(state)
        SetToggle(state)
    end
    
    function UI:UpdateStats(str, cash, gem)
        StatsText.Text = string.format("STR: %s | CASH: %s | GEM: %s", str or "-", cash or "-", gem or "-")
    end
    
    function UI:UpdateStatus(text, color)
        StatusLabel.Text = text
        StatusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    end
    
    function UI:Destroy()
        ScreenGui:Destroy()
    end
    
    return UI
end

return MiniBoxUI
