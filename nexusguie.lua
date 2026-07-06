local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Helper untuk animasi mulus
local function Tween(instance, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Library:CreateWindow(config)
    local title = config.Title or "Shield Team"
    
    local ShieldGui = Instance.new("ScreenGui")
    ShieldGui.Name = "ShieldTeam_UI"
    -- Fallback ke PlayerGui kalau di test di Roblox Studio biasa
    local success = pcall(function() ShieldGui.Parent = CoreGui end)
    if not success then ShieldGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- State Ukuran
    local isMinimized = false
    local isExpanded = false
    local normalSize = UDim2.new(0, 750, 0, 450)
    local expandedSize = UDim2.new(0, 920, 0, 520)

    -- Window Utama
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = normalSize
    MainFrame.Position = UDim2.new(0.5, -375, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 9, 18)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ShieldGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(168, 85, 247)
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.4
    MainStroke.Parent = MainFrame

    -- Sistem Drag Window
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = MainFrame

    local dragging, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar

    -- Container Tombol Topbar (Minimize, Expand, Close)
    local ControlContainer = Instance.new("Frame")
    ControlContainer.Size = UDim2.new(0, 100, 1, 0)
    ControlContainer.Position = UDim2.new(1, -110, 0, 0)
    ControlContainer.BackgroundTransparency = 1
    ControlContainer.Parent = Topbar

    local ControlLayout = Instance.new("UIListLayout")
    ControlLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ControlLayout.Padding = UDim.new(0, 6)
    ControlLayout.Parent = ControlContainer

    local function CreateControlButton(name, text, layoutOrder)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 26, 0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(150, 150, 160)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.LayoutOrder = layoutOrder
        btn.Parent = ControlContainer
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Color3.fromRGB(168, 85, 247), TextColor3 = Color3.fromRGB(255, 255, 255)}) end)
        btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = Color3.fromRGB(20, 15, 30), TextColor3 = Color3.fromRGB(150, 150, 160)}) end)
        return btn
    end

    local MinimizeBtn = CreateControlButton("Minimize", "-", 1)
    local ExpandBtn = CreateControlButton("Expand", "▢", 2)
    local CloseBtn = CreateControlButton("Close", "X", 3)
    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(239, 68, 68)}) end)

    -- Partisi Layout Persis Gambar (Sidebar Kiri, Konten Kanan)
    local ContentWrapper = Instance.new("Frame")
    ContentWrapper.Size = UDim2.new(1, -20, 1, -50)
    ContentWrapper.Position = UDim2.new(0, 10, 0, 40)
    ContentWrapper.BackgroundTransparency = 1
    ContentWrapper.Parent = MainFrame

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(8, 6, 12)
    Sidebar.Parent = ContentWrapper
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)
    local SidebarStroke = Instance.new("UIStroke", Sidebar)
    SidebarStroke.Color = Color3.fromRGB(168, 85, 247)
    SidebarStroke.Transparency = 0.7

    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Padding = UDim.new(0, 4)
    local SidebarPadding = Instance.new("UIPadding", Sidebar)
    SidebarPadding.PaddingTop = UDim.new(0, 8)
    SidebarPadding.PaddingLeft = UDim.new(0, 8)
    SidebarPadding.PaddingRight = UDim.new(0, 8)

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -190, 1, 0)
    PageContainer.Position = UDim2.new(0, 190, 0, 0)
    PageContainer.BackgroundColor3 = Color3.fromRGB(8, 6, 12)
    PageContainer.Parent = ContentWrapper
    Instance.new("UICorner", PageContainer).CornerRadius = UDim.new(0, 6)
    local PageStroke = Instance.new("UIStroke", PageContainer)
    PageStroke.Color = Color3.fromRGB(168, 85, 247)
    PageStroke.Transparency = 0.7

    -- Logic Tombol Window
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Tween(MainFrame, {Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, 40)})
            ContentWrapper.Visible = false
        else
            Tween(MainFrame, {Size = isExpanded and expandedSize or normalSize})
            ContentWrapper.Visible = true
        end
    end)

    ExpandBtn.MouseButton1Click:Connect(function()
        if isMinimized then return end
        isExpanded = not isExpanded
        if isExpanded then
            Tween(MainFrame, {Size = expandedSize, Position = UDim2.new(0.5, -460, 0.5, -260)})
        else
            Tween(MainFrame, {Size = normalSize, Position = UDim2.new(0.5, -375, 0.5, -225)})
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function() ShieldGui:Destroy() end)

    -- Tab System
    local Tabs = {}
    local firstTab = true

    function Tabs:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = "  " .. tabName
        TabBtn.TextColor3 = Color3.fromRGB(120, 120, 130)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = Sidebar
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
        Page.Visible = false
        Page.Parent = PageContainer
        
        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 10)
        local PagePadding = Instance.new("UIPadding", Page)
        PagePadding.PaddingTop = UDim.new(0, 10)
        PagePadding.PaddingBottom = UDim.new(0, 10)
        PagePadding.PaddingLeft = UDim.new(0, 12)
        PagePadding.PaddingRight = UDim.new(0, 12)

        if firstTab then
            firstTab = false
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.85
            TabBtn.TextColor3 = Color3.fromRGB(168, 85, 247)
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(PageContainer:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            for _, b in pairs(Sidebar:GetChildren()) do
                if b:IsA("TextButton") then 
                    Tween(b, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(120, 120, 130)})
                end
            end
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.85, TextColor3 = Color3.fromRGB(168, 85, 247)})
        end)

        local Sections = {}

        function Sections:CreateSection(sectionTitle)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.BackgroundColor3 = Color3.fromRGB(14, 11, 20)
            SectionFrame.Parent = Page
            Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 6)
            local SecStroke = Instance.new("UIStroke", SectionFrame)
            SecStroke.Color = Color3.fromRGB(168, 85, 247)
            SecStroke.Transparency = 0.85

            local SecLayout = Instance.new("UIListLayout", SectionFrame)
            SecLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SecLayout.Padding = UDim.new(0, 6)
            local SecPadding = Instance.new("UIPadding", SectionFrame)
            SecPadding.PaddingTop = UDim.new(0, 30)
            SecPadding.PaddingBottom = UDim.new(0, 10)
            SecPadding.PaddingLeft = UDim.new(0, 10)
            SecPadding.PaddingRight = UDim.new(0, 10)

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, 0, 0, 20)
            Title.Position = UDim2.new(0, 10, 0, 5)
            Title.BackgroundTransparency = 1
            Title.Text = sectionTitle
            Title.TextColor3 = Color3.fromRGB(168, 85, 247)
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 12
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = SectionFrame

            local function UpdateCanvas()
                SectionFrame.Size = UDim2.new(1, 0, 0, SecLayout.AbsoluteContentSize.Y + 40)
                Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
            end
            SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

            local Elements = {}

            -- TOGGLE
            function Elements:CreateToggle(name, default, callback)
                local toggled = default or false
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 34)
                ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
                ToggleFrame.Parent = SectionFrame
                Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 4)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.7, 0, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = name
                Label.TextColor3 = Color3.fromRGB(220, 220, 225)
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = ToggleFrame

                local ToggleBtn = Instance.new("TextButton")
                ToggleBtn.Size = UDim2.new(0, 34, 0, 18)
                ToggleBtn.Position = UDim2.new(1, -44, 0.5, -9)
                ToggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(35, 30, 45)
                ToggleBtn.Text = ""
                ToggleBtn.Parent = ToggleFrame
                Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

                local Circle = Instance.new("Frame")
                Circle.Size = UDim2.new(0, 12, 0, 12)
                Circle.Position = toggled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
                Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Circle.Parent = ToggleBtn
                Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

                ToggleBtn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Tween(ToggleBtn, {BackgroundColor3 = toggled and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(35, 30, 45)})
                    Tween(Circle, {Position = toggled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)})
                    pcall(callback, toggled)
                end)
            end

            -- SLIDER
            function Elements:CreateSlider(name, min, max, default, callback)
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 42)
                SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
                SliderFrame.Parent = SectionFrame
                Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 4)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.5, 0, 0, 20)
                Label.Position = UDim2.new(0, 10, 0, 2)
                Label.BackgroundTransparency = 1
                Label.Text = name
                Label.TextColor3 = Color3.fromRGB(220, 220, 225)
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = SliderFrame

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0.5, -10, 0, 20)
                ValueLabel.Position = UDim2.new(0.5, 0, 0, 2)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(default)
                ValueLabel.TextColor3 = Color3.fromRGB(168, 85, 247)
                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.TextSize = 12
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = SliderFrame

                local SliderBar = Instance.new("TextButton")
                SliderBar.Size = UDim2.new(1, -20, 0, 4)
                SliderBar.Position = UDim2.new(0, 10, 1, -12)
                SliderBar.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
                SliderBar.Text = ""
                SliderBar.Parent = SliderFrame
                Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)

                local SliderFill = Instance.new("Frame")
                local fillPercent = (default - min) / (max - min)
                SliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
                SliderFill.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
                SliderFill.Parent = SliderBar
                Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

                local sliding = false
                local function move(input)
                    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (pos * (max - min)))
                    ValueLabel.Text = tostring(val)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    pcall(callback, val)
                end

                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true; move(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then move(input) end
                end)
            end

            return Elements
        end
        return Sections
    end
    return Tabs
end

return Library
