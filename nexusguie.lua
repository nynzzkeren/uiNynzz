local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

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
    ShieldGui.ResetOnSpawn = false
    local success = pcall(function() ShieldGui.Parent = CoreGui end)
    if not success then ShieldGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- ==========================================
    -- FLOATING MINIMIZE ICON
    -- ==========================================
    local OpenIcon = Instance.new("TextButton")
    OpenIcon.Name = "OpenIcon"
    OpenIcon.Size = UDim2.new(0, 45, 0, 45)
    OpenIcon.Position = UDim2.new(0, 20, 0.5, -22)
    OpenIcon.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
    OpenIcon.BackgroundTransparency = 0.2
    OpenIcon.Text = "S"
    OpenIcon.TextColor3 = Color3.fromRGB(168, 85, 247)
    OpenIcon.Font = Enum.Font.GothamBold
    OpenIcon.TextSize = 20
    OpenIcon.Visible = false
    OpenIcon.Parent = ShieldGui

    Instance.new("UICorner", OpenIcon).CornerRadius = UDim.new(1, 0)
    local IconStroke = Instance.new("UIStroke", OpenIcon)
    IconStroke.Color = Color3.fromRGB(168, 85, 247)
    IconStroke.Thickness = 1.5
    IconStroke.Transparency = 0.5

    -- Drag Logic untuk Floating Icon
    local iconDragging, iconDragInput, iconDragStart, iconStartPos
    OpenIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            iconDragging = true
            iconDragStart = input.Position
            iconStartPos = OpenIcon.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then iconDragging = false end
            end)
        end
    end)
    OpenIcon.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then iconDragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == iconDragInput and iconDragging then
            local delta = input.Position - iconDragStart
            OpenIcon.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
        end
    end)

    -- ==========================================
    -- MAIN WINDOW (UI Sedang & Transparan)
    -- ==========================================
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 350) -- Ukuran Medium Profesional
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 8, 14)
    MainFrame.BackgroundTransparency = 0.15 -- Agak transparan
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ShieldGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8) -- Pinggiran melengkung
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(168, 85, 247)
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.6 -- Bezel tipis kalem
    MainStroke.Parent = MainFrame

    -- Drag Logic Window Utama
    local Topbar = Instance.new("Frame")
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
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar

    -- Window Controls (Cuma Minimize & Close)
    local ControlContainer = Instance.new("Frame")
    ControlContainer.Size = UDim2.new(0, 70, 1, 0)
    ControlContainer.Position = UDim2.new(1, -80, 0, 0)
    ControlContainer.BackgroundTransparency = 1
    ControlContainer.Parent = Topbar

    local ControlLayout = Instance.new("UIListLayout")
    ControlLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlLayout.Padding = UDim.new(0, 6)
    ControlLayout.Parent = ControlContainer

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Parent = ControlContainer
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = ControlContainer
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

    -- Logic Tombol Topbar
    MinimizeBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        OpenIcon.Visible = true
    end)
    OpenIcon.MouseButton1Click:Connect(function()
        OpenIcon.Visible = false
        MainFrame.Visible = true
    end)
    CloseBtn.MouseButton1Click:Connect(function() ShieldGui:Destroy() end)

    -- ==========================================
    -- SIDEBAR & CONTENT AREA
    -- ==========================================
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, -50)
    Sidebar.Position = UDim2.new(0, 10, 0, 40)
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 12, 20)
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.Parent = MainFrame
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)
    local SidebarStroke = Instance.new("UIStroke", Sidebar)
    SidebarStroke.Color = Color3.fromRGB(168, 85, 247)
    SidebarStroke.Transparency = 0.8

    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 4)
    local SidebarPadding = Instance.new("UIPadding", Sidebar)
    SidebarPadding.PaddingTop = UDim.new(0, 8)
    SidebarPadding.PaddingLeft = UDim.new(0, 8)
    SidebarPadding.PaddingRight = UDim.new(0, 8)

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -180, 1, -50)
    PageContainer.Position = UDim2.new(0, 170, 0, 40)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame

    -- Tab System
    local Tabs = {}
    local firstTab = true

    function Tabs:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 30)
        TabBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = "  " .. tabName
        TabBtn.TextColor3 = Color3.fromRGB(140, 140, 150)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 12
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
        PageLayout.Padding = UDim.new(0, 10)
        local PagePadding = Instance.new("UIPadding", Page)
        PagePadding.PaddingBottom = UDim.new(0, 10)
        PagePadding.PaddingRight = UDim.new(0, 10)

        if firstTab then
            firstTab = false
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.8
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(PageContainer:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            for _, b in pairs(Sidebar:GetChildren()) do
                if b:IsA("TextButton") then 
                    Tween(b, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(140, 140, 150)})
                end
            end
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.8, TextColor3 = Color3.fromRGB(255, 255, 255)})
        end)

        local Sections = {}

        function Sections:CreateSection(sectionTitle)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 20)
            SectionFrame.BackgroundTransparency = 0.3
            SectionFrame.ClipsDescendants = true
            SectionFrame.Parent = Page
            Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 6)
            local SecStroke = Instance.new("UIStroke", SectionFrame)
            SecStroke.Color = Color3.fromRGB(168, 85, 247)
            SecStroke.Transparency = 0.8

            local SecLayout = Instance.new("UIListLayout", SectionFrame)
            SecLayout.Padding = UDim.new(0, 6)
            local SecPadding = Instance.new("UIPadding", SectionFrame)
            SecPadding.PaddingTop = UDim.new(0, 26)
            SecPadding.PaddingBottom = UDim.new(0, 8)
            SecPadding.PaddingLeft = UDim.new(0, 8)
            SecPadding.PaddingRight = UDim.new(0, 8)

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, 0, 0, 20)
            Title.Position = UDim2.new(0, 8, 0, 4)
            Title.BackgroundTransparency = 1
            Title.Text = sectionTitle
            Title.TextColor3 = Color3.fromRGB(168, 85, 247)
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 11
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = SectionFrame

            local function UpdateCanvas()
                SectionFrame.Size = UDim2.new(1, 0, 0, SecLayout.AbsoluteContentSize.Y + 34)
                Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
            end
            SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

            local Elements = {}

            -- 1. BUTTON
            function Elements:CreateButton(name, callback)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 32)
                Btn.BackgroundColor3 = Color3.fromRGB(22, 18, 30)
                Btn.Text = name
                Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
                Btn.Font = Enum.Font.GothamMedium
                Btn.TextSize = 12
                Btn.Parent = SectionFrame
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
                
                Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Color3.fromRGB(32, 25, 45)}) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Color3.fromRGB(22, 18, 30)}) end)
                Btn.MouseButton1Click:Connect(function() pcall(callback) end)
            end

            -- 2. TOGGLE
            function Elements:CreateToggle(name, default, callback)
                local toggled = default or false
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 32)
                ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 18, 30)
                ToggleFrame.Parent = SectionFrame
                Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 4)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.7, 0, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = name
                Label.TextColor3 = Color3.fromRGB(220, 220, 220)
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = ToggleFrame

                local ToggleBtn = Instance.new("TextButton")
                ToggleBtn.Size = UDim2.new(0, 30, 0, 16)
                ToggleBtn.Position = UDim2.new(1, -40, 0.5, -8)
                ToggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(40, 35, 50)
                ToggleBtn.Text = ""
                ToggleBtn.Parent = ToggleFrame
                Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

                local Circle = Instance.new("Frame")
                Circle.Size = UDim2.new(0, 12, 0, 12)
                Circle.Position = toggled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Circle.Parent = ToggleBtn
                Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

                ToggleBtn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Tween(ToggleBtn, {BackgroundColor3 = toggled and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(40, 35, 50)})
                    Tween(Circle, {Position = toggled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)})
                    pcall(callback, toggled)
                end)
            end

            -- 3. SLIDER
            function Elements:CreateSlider(name, min, max, default, callback)
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 42)
                SliderFrame.BackgroundColor3 = Color3.fromRGB(22, 18, 30)
                SliderFrame.Parent = SectionFrame
                Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 4)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.5, 0, 0, 20)
                Label.Position = UDim2.new(0, 10, 0, 2)
                Label.BackgroundTransparency = 1
                Label.Text = name
                Label.TextColor3 = Color3.fromRGB(220, 220, 220)
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
                ValueLabel.TextSize = 11
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = SliderFrame

                local SliderBar = Instance.new("TextButton")
                SliderBar.Size = UDim2.new(1, -20, 0, 4)
                SliderBar.Position = UDim2.new(0, 10, 1, -12)
                SliderBar.BackgroundColor3 = Color3.fromRGB(40, 35, 50)
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
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; move(input) end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then move(input) end
                end)
            end

            -- 4. DROPDOWN
            function Elements:CreateDropdown(name, options, default, callback)
                local DropFrame = Instance.new("Frame")
                DropFrame.Size = UDim2.new(1, 0, 0, 32)
                DropFrame.BackgroundColor3 = Color3.fromRGB(22, 18, 30)
                DropFrame.ClipsDescendants = true
                DropFrame.Parent = SectionFrame
                Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 4)

                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(1, 0, 0, 32)
                DropBtn.BackgroundTransparency = 1
                DropBtn.Text = ""
                DropBtn.Parent = DropFrame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.5, 0, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = name
                Label.TextColor3 = Color3.fromRGB(220, 220, 220)
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = DropBtn

                local SelectedLabel = Instance.new("TextLabel")
                SelectedLabel.Size = UDim2.new(0.5, -30, 1, 0)
                SelectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
                SelectedLabel.BackgroundTransparency = 1
                SelectedLabel.Text = default or options[1] or ""
                SelectedLabel.TextColor3 = Color3.fromRGB(168, 85, 247)
                SelectedLabel.Font = Enum.Font.GothamBold
                SelectedLabel.TextSize = 11
                SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
                SelectedLabel.Parent = DropBtn

                local Arrow = Instance.new("TextLabel")
                Arrow.Size = UDim2.new(0, 20, 1, 0)
                Arrow.Position = UDim2.new(1, -25, 0, 0)
                Arrow.BackgroundTransparency = 1
                Arrow.Text = "v"
                Arrow.TextColor3 = Color3.fromRGB(140, 140, 150)
                Arrow.Font = Enum.Font.GothamBold
                Arrow.TextSize = 12
                Arrow.Parent = DropBtn

                local OptionContainer = Instance.new("Frame")
                OptionContainer.Size = UDim2.new(1, -10, 0, #options * 26)
                OptionContainer.Position = UDim2.new(0, 5, 0, 36)
                OptionContainer.BackgroundTransparency = 1
                OptionContainer.Parent = DropFrame
                
                local OptLayout = Instance.new("UIListLayout", OptionContainer)
                OptLayout.Padding = UDim.new(0, 2)

                local isOpen = false
                DropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    Tween(Arrow, {Rotation = isOpen and 180 or 0})
                    Tween(DropFrame, {Size = isOpen and UDim2.new(1, 0, 0, 38 + (#options * 26)) or UDim2.new(1, 0, 0, 32)})
                end)

                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 24)
                    OptBtn.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
                    OptBtn.Text = opt
                    OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 11
                    OptBtn.Parent = OptionContainer
                    Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

                    OptBtn.MouseEnter:Connect(function() Tween(OptBtn, {BackgroundColor3 = Color3.fromRGB(168, 85, 247), TextColor3 = Color3.fromRGB(255,255,255)}) end)
                    OptBtn.MouseLeave:Connect(function() Tween(OptBtn, {BackgroundColor3 = Color3.fromRGB(30, 25, 40), TextColor3 = Color3.fromRGB(200,200,200)}) end)
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        SelectedLabel.Text = opt
                        isOpen = false
                        Tween(Arrow, {Rotation = 0})
                        Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 32)})
                        pcall(callback, opt)
                    end)
                end
            end

            return Elements
        end
        return Sections
    end
    return Tabs
end

return Library
