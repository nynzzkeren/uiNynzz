--[[
    Omverd Hub - Custom UI Library
    Version: 1.0.0
    Author: ShieldTeam
    Style: WindUI-inspired, Glassmorphism, Dark Theme
    Compatible: Delta, Solara, Fluxus, Hydrogen, Codex, Xeno
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Omverd = {}
Omverd.__index = Omverd

-- ==================== UTILITIES ====================

local function ProtectGui(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    elseif gethui then
        pcall(function()
            gui.Parent = gethui()
        end)
    end
    return gui
end

local function GetScreenGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "OmverdHub_" .. tostring(math.random(100000, 999999))
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 999
    
    if syn and syn.protect_gui then
        syn.protect_gui(sg)
        sg.Parent = CoreGui
    elseif gethui then
        sg.Parent = gethui()
    else
        sg.Parent = CoreGui
    end
    return sg
end

local function Tween(instance, properties, duration, style, direction)
    duration = duration or 0.2
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

local function Create(class, properties, children)
    local instance = Instance.new(class)
    if properties then
        for prop, value in pairs(properties) do
            instance[prop] = value
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = instance
        end
    end
    return instance
end

local function AddCorner(parent, radius)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Color3.fromHex("#30FF6A"),
        Thickness = thickness or 1,
        Transparency = 0.7,
        Parent = parent
    })
end

local function AddGradient(parent, colors, rotation)
    local gradient = Create("UIGradient", {
        Color = ColorSequence.new(colors or {Color3.fromHex("#30FF6A"), Color3.fromHex("#e7ff2f")}),
        Rotation = rotation or 0,
        Parent = parent
    })
    return gradient
end

local function AddPadding(parent, padding)
    padding = padding or 8
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, padding),
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        Parent = parent
    })
end

local function AddListLayout(parent, padding, direction)
    return Create("UIListLayout", {
        Padding = UDim.new(0, padding or 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = direction or Enum.FillDirection.Vertical,
        Parent = parent
    })
end

-- ==================== DRAG FUNCTIONALITY ====================

local function MakeDraggable(frame, dragToggle, dragSpeed)
    dragSpeed = dragSpeed or 0.1
    local dragging, dragInput, dragStart, startPos
    
    local function Update(input)
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        Tween(frame, {Position = newPosition}, dragSpeed, Enum.EasingStyle.Sine)
    end
    
    dragToggle.InputBegan:Connect(function(input)
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
    
    dragToggle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Update(input)
        end
    end)
end

-- ==================== NOTIFICATIONS ====================

local NotificationContainer
local Notifications = {}

local function CreateNotificationContainer()
    if NotificationContainer then return end
    local screenGui = GetScreenGui()
    NotificationContainer = Create("Frame", {
        Name = "NotificationContainer",
        Size = UDim2.new(0, 320, 1, 0),
        Position = UDim2.new(1, -330, 0, 10),
        BackgroundTransparency = 1,
        Parent = screenGui
    })
    local layout = AddListLayout(NotificationContainer, 8)
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
end

function Omverd:Notify(config)
    config = config or {}
    local Title = config.Title or "Notification"
    local Content = config.Content or ""
    local Duration = config.Duration or 5
    local Type = config.Type or "Info"
    
    CreateNotificationContainer()
    
    local typeColors = {
        Success = Color3.fromHex("#30FF6A"),
        Error = Color3.fromHex("#FF4444"),
        Info = Color3.fromHex("#44AAFF"),
        Warning = Color3.fromHex("#FFB844")
    }
    
    local typeIcons = {
        Success = "rbxassetid://7072706796",
        Error = "rbxassetid://7072706640",
        Info = "rbxassetid://7072706716",
        Warning = "rbxassetid://7072706820"
    }
    
    local accentColor = typeColors[Type] or typeColors.Info
    local icon = typeIcons[Type] or typeIcons.Info
    
    local notifFrame = Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Color3.fromHex("#1A1A2E"),
        BackgroundTransparency = 0.1,
        ClipsDescendants = true,
        Parent = NotificationContainer,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    AddCorner(notifFrame, 10)
    AddStroke(notifFrame, accentColor, 1)
    
    local topBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = accentColor,
        LayoutOrder = 0,
        Parent = notifFrame
    })
    
    local content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
        Parent = notifFrame
    })
    AddPadding(content, 12)
    
    local iconLabel = Create("ImageLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 20, 0, 20),
        Image = icon,
        ImageColor3 = accentColor,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 2),
        Parent = content
    })
    
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -30, 0, 20),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        Text = Title,
        TextColor3 = Color3.fromHex("#FFFFFF"),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = content
    })
    
    local descLabel = Create("TextLabel", {
        Name = "Description",
        Size = UDim2.new(1, -30, 0, 0),
        Position = UDim2.new(0, 28, 0, 22),
        BackgroundTransparency = 1,
        Text = Content,
        TextColor3 = Color3.fromHex("#AAAAAA"),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = content
    })
    
    local closeBtn = Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 0, 2),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Color3.fromHex("#888888"),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = content
    })
    
    -- Animate in
    notifFrame.Size = UDim2.new(1, 30, 0, 0)
    notifFrame.BackgroundTransparency = 1
    Tween(notifFrame, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 0.1}, 0.2, Enum.EasingStyle.Quad)
    task.wait(0.05)
    Tween(notifFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.15, Enum.EasingStyle.Quad)
    
    local function Dismiss()
        Tween(notifFrame, {Size = UDim2.new(1, -40, 0, notifFrame.AbsoluteSize.Y), BackgroundTransparency = 1}, 0.2, Enum.EasingStyle.Quad)
        task.delay(0.2, function()
            notifFrame:Destroy()
        end)
    end
    
    closeBtn.MouseButton1Click:Connect(Dismiss)
    
    -- Auto dismiss
    task.delay(Duration, function()
        if notifFrame.Parent then
            Dismiss()
        end
    end)
end

-- ==================== WINDOW ====================

function Omverd:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Omverd Hub"
    local SubTitle = config.SubTitle or ""
    local Size = config.Size or UDim2.fromOffset(620, 420)
    local AccentColor = config.AccentColor or Color3.fromHex("#30FF6A")
    local Theme = config.Theme or "Dark"
    local OpenButtonConfig = config.OpenButton or { Enabled = true }
    
    local screenGui = GetScreenGui()
    
    -- Theme colors
    local themeColors = {
        Dark = {
            Background = Color3.fromHex("#0D0D14"),
            Sidebar = Color3.fromHex("#12121C"),
            Element = Color3.fromHex("#16162A"),
            Text = Color3.fromHex("#FFFFFF"),
            SubText = Color3.fromHex("#888899"),
            Border = Color3.fromHex("#2A2A3E")
        },
        Light = {
            Background = Color3.fromHex("#F0F0F5"),
            Sidebar = Color3.fromHex("#E8E8EE"),
            Element = Color3.fromHex("#FFFFFF"),
            Text = Color3.fromHex("#1A1A2E"),
            SubText = Color3.fromHex("#666677"),
            Border = Color3.fromHex("#CCCCCC")
        }
    }
    
    local theme = themeColors[Theme] or themeColors.Dark
    
    -- Main Frame
    local MainFrame = Create("Frame", {
        Name = "OmverdMainFrame",
        Size = Size,
        Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2),
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = 0.05,
        ClipsDescendants = true,
        Visible = false,
        Parent = screenGui
    })
    AddCorner(MainFrame, 12)
    AddStroke(MainFrame, theme.Border, 1.5)
    
    -- Glass overlay gradient
    local glassGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#1A1A30")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#0D0D18")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#1A1A2A"))
        }),
        Rotation = 135,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.85),
            NumberSequenceKeypoint.new(0.5, 0.7),
            NumberSequenceKeypoint.new(1, 0.85)
        }),
        Parent = MainFrame
    })
    
    -- Top Bar (Title bar / drag area)
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = theme.Sidebar,
        BackgroundTransparency = 0.3,
        Parent = MainFrame
    })
    
    local topBarStroke = Create("UIStroke", {
        Color = theme.Border,
        Thickness = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = TopBar
    })
    
    -- Title
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = Title,
        TextColor3 = theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })
    
    -- Subtitle
    local SubtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(0, 200, 0, 14),
        Position = UDim2.new(0, 14, 0, 28),
        BackgroundTransparency = 1,
        Text = SubTitle,
        TextColor3 = theme.SubText,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })
    
    -- Close Button
    local CloseButton = Create("TextButton", {
        Name = "CloseBtn",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -38, 0, 7),
        BackgroundColor3 = Color3.fromHex("#FF4444"),
        BackgroundTransparency = 0.3,
        Text = "×",
        TextColor3 = Color3.fromHex("#FF6666"),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = TopBar
    })
    AddCorner(CloseButton, 6)
    
    -- Minimize Button
    local MinimizeButton = Create("TextButton", {
        Name = "MinimizeBtn",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -74, 0, 7),
        BackgroundColor3 = Color3.fromHex("#FFB844"),
        BackgroundTransparency = 0.3,
        Text = "—",
        TextColor3 = Color3.fromHex("#FFCC44"),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = TopBar
    })
    AddCorner(MinimizeButton, 6)
    
    -- Content area
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -160, 1, -55),
        Position = UDim2.new(0, 155, 0, 50),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = MainFrame
    })
    
    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 150, 1, -50),
        Position = UDim2.new(0, 0, 0, 46),
        BackgroundColor3 = theme.Sidebar,
        BackgroundTransparency = 0.4,
        Parent = MainFrame
    })
    
    local sidebarStroke = Create("UIStroke", {
        Color = theme.Border,
        Thickness = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = Sidebar
    })
    
    local TabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Sidebar
    })
    local tabLayout = AddListLayout(TabList, 4)
    tabLayout.Padding = UDim.new(0, 4)
    
    -- Accent line at bottom of topbar
    local accentLine = Create("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -1),
        Parent = TopBar
    })
    AddGradient(accentLine, {AccentColor, Color3.fromHex("#e7ff2f")}, 0)
    
    -- Make window draggable
    MakeDraggable(MainFrame, TopBar, 0.05)
    
    -- Window state
    local Window = {}
    local Tabs = {}
    local CurrentTab = nil
    local IsMinimized = false
    local Connections = {}
    
    -- ==================== TAB CREATION ====================
    
    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local TabTitle = tabConfig.Title or "Tab"
        local TabIcon = tabConfig.Icon or "rbxassetid://7072706796"
        
        local TabFrame = Create("ScrollingFrame", {
            Name = "Tab_" .. TabTitle,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = AccentColor,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentArea
        })
        
        local tabPadding = AddPadding(TabFrame, 8)
        local tabLayoutInner = AddListLayout(TabFrame, 6)
        
        -- Tab button in sidebar
        local TabButton = Create("TextButton", {
            Name = "TabBtn_" .. TabTitle,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = theme.Element,
            BackgroundTransparency = 0.5,
            Text = "",
            AutoButtonColor = false,
            Parent = TabList
        })
        AddCorner(TabButton, 8)
        
        local tabIcon = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 10, 0.5, -9),
            Image = TabIcon,
            ImageColor3 = theme.SubText,
            BackgroundTransparency = 1,
            Parent = TabButton
        })
        
        local tabTitleLabel = Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -36, 1, 0),
            Position = UDim2.new(0, 34, 0, 0),
            BackgroundTransparency = 1,
            Text = TabTitle,
            TextColor3 = theme.SubText,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })
        
        -- Indicator bar
        local indicator = Create("Frame", {
            Name = "Indicator",
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = AccentColor,
            Parent = TabButton
        })
        AddCorner(indicator, 2)
        
        local tabData = {
            Frame = TabFrame,
            Button = TabButton,
            Indicator = indicator,
            Icon = tabIcon,
            TitleLabel = tabTitleLabel
        }
        
        table.insert(Tabs, tabData)
        
        local function SelectTab()
            for _, tab in ipairs(Tabs) do
                -- Hide all tabs
                Tween(tab.Frame, {Size = UDim2.new(1, 0, 1, 0)}, 0.15)
                tab.Frame.Visible = false
                -- Reset button style
                Tween(tab.Button, {BackgroundTransparency = 0.5}, 0.15)
                Tween(tab.Icon, {ImageColor3 = theme.SubText}, 0.15)
                Tween(tab.TitleLabel, {TextColor3 = theme.SubText}, 0.15)
                Tween(tab.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.15)
            end
            
            -- Show selected tab
            TabFrame.Visible = true
            TabFrame.Size = UDim2.new(1, -20, 1, 0)
            Tween(TabFrame, {Size = UDim2.new(1, 0, 1, 0)}, 0.15, Enum.EasingStyle.Sine)
            Tween(TabButton, {BackgroundTransparency = 0.2}, 0.15)
            Tween(tabIcon, {ImageColor3 = AccentColor}, 0.15)
            Tween(tabTitleLabel, {TextColor3 = AccentColor}, 0.15)
            Tween(indicator, {Size = UDim2.new(0, 3, 0.6, 0)}, 0.15, Enum.EasingStyle.Quad)
            CurrentTab = tabData
        end
        
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        -- Hover effects
        TabButton.MouseEnter:Connect(function()
            if CurrentTab ~= tabData then
                Tween(TabButton, {BackgroundTransparency = 0.3}, 0.1)
                Tween(tabTitleLabel, {TextColor3 = theme.Text}, 0.1)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if CurrentTab ~= tabData then
                Tween(TabButton, {BackgroundTransparency = 0.5}, 0.1)
                Tween(tabTitleLabel, {TextColor3 = theme.SubText}, 0.1)
            end
        end)
        
        -- Select first tab automatically
        if #Tabs == 1 then
            SelectTab()
        end
        
        -- ==================== ELEMENT CREATION ====================
        local Tab = {}
        
        -- Helper to create element container
        local function CreateElementBase(elementConfig)
            elementConfig = elementConfig or {}
            local elemTitle = elementConfig.Title or ""
            local elemDesc = elementConfig.Description or ""
            local elemHeight = elementConfig.Height or 44
            local elemIcon = elementConfig.Icon or ""
            
            local elementFrame = Create("Frame", {
                Name = "Element_" .. elemTitle,
                Size = UDim2.new(1, 0, 0, elemHeight),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.3,
                Parent = TabFrame
            })
            AddCorner(elementFrame, 8)
            AddStroke(elementFrame, theme.Border, 0.5)
            
            local padding = AddPadding(elementFrame, 12)
            
            if elemIcon ~= "" then
                local iconImg = Create("ImageLabel", {
                    Name = "Icon",
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 12, 0.5, -9),
                    Image = elemIcon,
                    ImageColor3 = AccentColor,
                    BackgroundTransparency = 1,
                    Parent = elementFrame
                })
            end
            
            return elementFrame
        end
        
        -- ==================== TOGGLE ====================
        function Tab:CreateToggle(toggleConfig)
            toggleConfig = toggleConfig or {}
            local Title = toggleConfig.Title or "Toggle"
            local Description = toggleConfig.Description or ""
            local Default = toggleConfig.Default or false
            local Callback = toggleConfig.Callback or function() end
            
            local height = Description ~= "" and 52 or 44
            
            local elementFrame = Create("Frame", {
                Name = "Toggle_" .. Title,
                Size = UDim2.new(1, 0, 0, height),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.3,
                Parent = TabFrame
            })
            AddCorner(elementFrame, 8)
            AddStroke(elementFrame, theme.Border, 0.5)
            
            local titleLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -70, 0, Description ~= "" and 18 or 22),
                Position = UDim2.new(0, 14, 0, Description ~= "" and 8 or 11),
                BackgroundTransparency = 1,
                Text = Title,
                TextColor3 = theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = elementFrame
            })
            
            if Description ~= "" then
                local descLabel = Create("TextLabel", {
                    Name = "Desc",
                    Size = UDim2.new(1, -70, 0, 14),
                    Position = UDim2.new(0, 14, 0, 28),
                    BackgroundTransparency = 1,
                    Text = Description,
                    TextColor3 = theme.SubText,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = elementFrame
                })
            end
            
            -- Toggle visual
            local toggleBg = Create("Frame", {
                Name = "ToggleBg",
                Size = UDim2.new(0, 40, 0, 22),
                Position = UDim2.new(1, -54, 0.5, -11),
                BackgroundColor3 = Color3.fromHex("#2A2A3E"),
                Parent = elementFrame
            })
            AddCorner(toggleBg, 11)
            
            local toggleCircle = Create("Frame", {
                Name = "Circle",
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = Color3.fromHex("#888888"),
                Parent = toggleBg
            })
            AddCorner(toggleCircle, 8)
            
            local toggleBtn = Create("TextButton", {
                Name = "ToggleBtn",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = elementFrame
            })
            
            local toggleState = Default
            local ToggleObj = {}
            
            local function UpdateToggle(value)
                toggleState = value
                if value then
                    Tween(toggleBg, {BackgroundColor3 = AccentColor}, 0.15, Enum.EasingStyle.Quad)
                    Tween(toggleCircle, {Position = UDim2.new(0, 21, 0.5, -8), BackgroundColor3 = Color3.fromHex("#FFFFFF")}, 0.15, Enum.EasingStyle.Quad)
                else
                    Tween(toggleBg, {BackgroundColor3 = Color3.fromHex("#2A2A3E")}, 0.15, Enum.EasingStyle.Quad)
                    Tween(toggleCircle, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromHex("#888888")}, 0.15, Enum.EasingStyle.Quad)
                end
                pcall(Callback, value)
            end
            
            toggleBtn.MouseButton1Click:Connect(function()
                UpdateToggle(not toggleState)
            end)
            
            function ToggleObj:Set(value)
                UpdateToggle(value)
            end
            
            function ToggleObj:Get()
                return toggleState
            end
            
            -- Set default
            if Default then
                UpdateToggle(true)
            end
            
            return ToggleObj
        end
        
        -- ==================== SLIDER ====================
        function Tab:CreateSlider(sliderConfig)
            sliderConfig = sliderConfig or {}
            local Title = sliderConfig.Title or "Slider"
            local Min = sliderConfig.Min or 0
            local Max = sliderConfig.Max or 100
            local Default = sliderConfig.Default or 50
            local Increment = sliderConfig.Increment or 1
            local Suffix = sliderConfig.Suffix or ""
            local Callback = sliderConfig.Callback or function() end
            
            local elementFrame = Create("Frame", {
                Name = "Slider_" .. Title,
                Size = UDim2.new(1, 0, 0, 58),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.3,
                Parent = TabFrame
            })
            AddCorner(elementFrame, 8)
            AddStroke(elementFrame, theme.Border, 0.5)
            
            local titleLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -80, 0, 18),
                Position = UDim2.new(0, 14, 0, 8),
                BackgroundTransparency = 1,
                Text = Title,
                TextColor3 = theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = elementFrame
            })
            
            local valueLabel = Create("TextLabel", {
                Name = "Value",
                Size = UDim2.new(0, 60, 0, 18),
                Position = UDim2.new(1, -74, 0, 8),
                BackgroundTransparency = 1,
                Text = Default .. Suffix,
                TextColor3 = AccentColor,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = elementFrame
            })
            
            -- Slider track
            local sliderTrack = Create("Frame", {
                Name = "Track",
                Size = UDim2.new(1, -28, 0, 6),
                Position = UDim2.new(0, 14, 0, 38),
                BackgroundColor3 = Color3.fromHex("#2A2A3E"),
                Parent = elementFrame
            })
            AddCorner(sliderTrack, 3)
            
            local sliderFill = Create("Frame", {
                Name = "Fill",
                Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0),
                BackgroundColor3 = AccentColor,
                Parent = sliderTrack
            })
            AddCorner(sliderFill, 3)
            AddGradient(sliderFill, {AccentColor, Color3.fromHex("#e7ff2f")}, 0)
            
            local sliderThumb = Create("Frame", {
                Name = "Thumb",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new((Default - Min) / (Max - Min), -7, 0.5, -7),
                BackgroundColor3 = Color3.fromHex("#FFFFFF"),
                Parent = sliderTrack
            })
            AddCorner(sliderThumb, 7)
            AddStroke(sliderThumb, AccentColor, 2)
            
            local SliderObj = {}
            local currentValue = Default
            local dragging = false
            
            local function UpdateSlider(value)
                value = math.clamp(value, Min, Max)
                value = math.floor(value / Increment) * Increment
                currentValue = value
                
                local ratio = (value - Min) / (Max - Min)
                Tween(sliderFill, {Size = UDim2.new(ratio, 0, 1, 0)}, 0.1, Enum.EasingStyle.Linear)
                Tween(sliderThumb, {Position = UDim2.new(ratio, -7, 0.5, -7)}, 0.1, Enum.EasingStyle.Linear)
                valueLabel.Text = value .. Suffix
                pcall(Callback, value)
            end
            
            local function HandleInput(input)
                local trackAbsPos = sliderTrack.AbsolutePosition.X
                local trackAbsSize = sliderTrack.AbsoluteSize.X
                local ratio = math.clamp((input.Position.X - trackAbsPos) / trackAbsSize, 0, 1)
                local value = Min + (Max - Min) * ratio
                UpdateSlider(value)
            end
            
            sliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    HandleInput(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    HandleInput(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            function SliderObj:Set(value)
                UpdateSlider(value)
            end
            
            function SliderObj:Get()
                return currentValue
            end
            
            UpdateSlider(Default)
            return SliderObj
        end
        
        -- ==================== DROPDOWN ====================
        function Tab:CreateDropdown(dropdownConfig)
            dropdownConfig = dropdownConfig or {}
            local Title = dropdownConfig.Title or "Dropdown"
            local Options = dropdownConfig.Options or {}
            local Multi = dropdownConfig.Multi or false
            local Default = dropdownConfig.Default
            local Callback = dropdownConfig.Callback or function() end
            
            local isOpen = false
            local selectedValues = {}
            if Default then
                if type(Default) == "table" then
                    selectedValues = Default
                else
                    selectedValues = {Default}
                end
            end
            
            local closedHeight = 44
            local optionHeight = 32
            local maxVisibleOptions = 6
            
            local elementFrame = Create("Frame", {
                Name = "Dropdown_" .. Title,
                Size = UDim2.new(1, 0, 0, closedHeight),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.3,
                ClipsDescendants = true,
                Parent = TabFrame
            })
            AddCorner(elementFrame, 8)
            AddStroke(elementFrame, theme.Border, 0.5)
            
            local titleLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -100, 0, 18),
                Position = UDim2.new(0, 14, 0, 6),
                BackgroundTransparency = 1,
                Text = Title,
                TextColor3 = theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = elementFrame
            })
            
            local selectedLabel = Create("TextLabel", {
                Name = "Selected",
                Size = UDim2.new(1, -60, 0, 14),
                Position = UDim2.new(0, 14, 0, 24),
                BackgroundTransparency = 1,
                Text = "Select...",
                TextColor3 = theme.SubText,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = elementFrame
            })
            
            -- Arrow indicator
            local arrowLabel = Create("TextLabel", {
                Name = "Arrow",
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -34, 0, 10),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = theme.SubText,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                Parent = elementFrame
            })
            
            -- Toggle button
            local dropBtn = Create("TextButton", {
                Name = "DropBtn",
                Size = UDim2.new(1, 0, 0, closedHeight),
                BackgroundTransparency = 1,
                Text = "",
                Parent = elementFrame
            })
            
            -- Options container
            local optionsFrame = Create("ScrollingFrame", {
                Name = "Options",
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, closedHeight + 4),
                BackgroundTransparency = 1,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = AccentColor,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Parent = elementFrame
            })
            AddListLayout(optionsFrame, 2)
            
            local DropdownObj = {}
            local optionButtons = {}
            
            local function UpdateSelectedDisplay()
                if #selectedValues == 0 then
                    selectedLabel.Text = "Select..."
                    selectedLabel.TextColor3 = theme.SubText
                else
                    local displayText = table.concat(selectedValues, ", ")
                    if #displayText > 40 then
                        displayText = string.sub(displayText, 1, 37) .. "..."
                    end
                    selectedLabel.Text = displayText
                    selectedLabel.TextColor3 = AccentColor
                end
                
                -- Update option highlight
                for _, optData in ipairs(optionButtons) do
                    local isSelected = false
                    for _, val in ipairs(selectedValues) do
                        if val == optData.Value then
                            isSelected = true
                            break
                        end
                    end
                    if isSelected then
                        Tween(optData.Button, {BackgroundColor3 = AccentColor, BackgroundTransparency = 0.7}, 0.1)
                        Tween(optData.Label, {TextColor3 = AccentColor}, 0.1)
                    else
                        Tween(optData.Button, {BackgroundColor3 = theme.Element, BackgroundTransparency = 0.5}, 0.1)
                        Tween(optData.Label, {TextColor3 = theme.Text}, 0.1)
                    end
                end
            end
            
            local function PopulateOptions(optionsList)
                -- Clear existing
                for _, child in ipairs(optionsFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                optionButtons = {}
                
                for i, option in ipairs(optionsList) do
                    local optValue = option
                    local optDisplay = option
                    if type(option) == "table" then
                        optValue = option.Value or option.Name or tostring(i)
                        optDisplay = option.Name or option.Display or tostring(i)
                    end
                    
                    local optBtn = Create("TextButton", {
                        Name = "Option_" .. optDisplay,
                        Size = UDim2.new(1, 0, 0, optionHeight),
                        BackgroundColor3 = theme.Element,
                        BackgroundTransparency = 0.5,
                        Text = "",
                        AutoButtonColor = false,
                        Parent = optionsFrame
                    })
                    AddCorner(optBtn, 6)
                    
                    local optLabel = Create("TextLabel", {
                        Name = "Label",
                        Size = UDim2.new(1, -20, 1, 0),
                        Position = UDim2.new(0, 10, 0, 0),
                        BackgroundTransparency = 1,
                        Text = optDisplay,
                        TextColor3 = theme.Text,
                        TextSize = 12,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = optBtn
                    })
                    
                    table.insert(optionButtons, {Button = optBtn, Label = optLabel, Value = optValue})
                    
                    optBtn.MouseButton1Click:Connect(function()
                        if Multi then
                            local found = false
                            for idx, val in ipairs(selectedValues) do
                                if val == optValue then
                                    table.remove(selectedValues, idx)
                                    found = true
                                    break
                                end
                            end
                            if not found then
                                table.insert(selectedValues, optValue)
                            end
                            UpdateSelectedDisplay()
                            pcall(Callback, selectedValues)
                        else
                            selectedValues = {optValue}
                            UpdateSelectedDisplay()
                            pcall(Callback, optValue)
                            -- Close dropdown
                            if isOpen then
                                isOpen = false
                                Tween(elementFrame, {Size = UDim2.new(1, 0, 0, closedHeight)}, 0.2, Enum.EasingStyle.Quad)
                                Tween(arrowLabel, {Rotation = 0}, 0.2)
                            end
                        end
                    end)
                    
                    -- Hover effect
                    optBtn.MouseEnter:Connect(function()
                        Tween(optBtn, {BackgroundTransparency = 0.3}, 0.1)
                    end)
                    optBtn.MouseLeave:Connect(function()
                        local isSelected = false
                        for _, val in ipairs(selectedValues) do
                            if val == optValue then isSelected = true break end
                        end
                        Tween(optBtn, {BackgroundTransparency = isSelected and 0.7 or 0.5}, 0.1)
                    end)
                end
                
                optionsFrame.CanvasSize = UDim2.new(0, 0, 0, #optionsList * (optionHeight + 2))
            end
            
            PopulateOptions(Options)
            UpdateSelectedDisplay()
            
            dropBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    local visibleCount = math.min(#Options, maxVisibleOptions)
                    local expandedHeight = closedHeight + visibleCount * (optionHeight + 2) + 12
                    Tween(elementFrame, {Size = UDim2.new(1, 0, 0, expandedHeight)}, 0.2, Enum.EasingStyle.Quad)
                    Tween(arrowLabel, {Rotation = 180}, 0.2)
                else
                    Tween(elementFrame, {Size = UDim2.new(1, 0, 0, closedHeight)}, 0.2, Enum.EasingStyle.Quad)
                    Tween(arrowLabel, {Rotation = 0}, 0.2)
                end
            end)
            
            function DropdownObj:Set(value)
                if type(value) == "table" then
                    selectedValues = value
                else
                    selectedValues = {value}
                end
                UpdateSelectedDisplay()
                pcall(Callback, Multi and selectedValues or selectedValues[1])
            end
            
            function DropdownObj:Get()
                return Multi and selectedValues or selectedValues[1]
            end
            
            function DropdownObj:Refresh(newOptions)
                Options = newOptions
                PopulateOptions(newOptions)
                UpdateSelectedDisplay()
            end
            
            return DropdownObj
        end
        
        -- ==================== INPUT ====================
        function Tab:CreateInput(inputConfig)
            inputConfig = inputConfig or {}
            local Title = inputConfig.Title or "Input"
            local Placeholder = inputConfig.Placeholder or ""
            local Default = inputConfig.Default or ""
            local Callback = inputConfig.Callback or function() end
            
            local elementFrame = Create("Frame", {
                Name = "Input_" .. Title,
                Size = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.3,
                Parent = TabFrame
            })
            AddCorner(elementFrame, 8)
            AddStroke(elementFrame, theme.Border, 0.5)
            
            local titleLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -200, 0, 18),
                Position = UDim2.new(0, 14, 0, 6),
                BackgroundTransparency = 1,
                Text = Title,
                TextColor3 = theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = elementFrame
            })
            
            local inputBox = Create("TextBox", {
                Name = "InputBox",
                Size = UDim2.new(0, 180, 0, 28),
                Position = UDim2.new(1, -194, 0.5, -14),
                BackgroundColor3 = Color3.fromHex("#1A1A30"),
                BackgroundTransparency = 0.2,
                Text = Default,
                PlaceholderText = Placeholder,
                PlaceholderColor3 = theme.SubText,
                TextColor3 = theme.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = elementFrame
            })
            AddCorner(inputBox, 6)
            AddStroke(inputBox, theme.Border, 0.5)
            AddPadding(inputBox, 8)
            
            local InputObj = {}
            
            inputBox.FocusLost:Connect(function(enterPressed)
                pcall(Callback, inputBox.Text)
            end)
            
            inputBox.Focused:Connect(function()
                Tween(inputBox, {BackgroundColor3 = Color3.fromHex("#222244")}, 0.1)
            end)
            
            inputBox.FocusLost:Connect(function()
                Tween(inputBox, {BackgroundColor3 = Color3.fromHex("#1A1A30")}, 0.1)
            end)
            
            function InputObj:Set(text)
                inputBox.Text = text
            end
            
            function InputObj:Get()
                return inputBox.Text
            end
            
            return InputObj
        end
        
        -- ==================== BUTTON ====================
        function Tab:CreateButton(buttonConfig)
            buttonConfig = buttonConfig or {}
            local Title = buttonConfig.Title or "Button"
            local Description = buttonConfig.Description or ""
            local Callback = buttonConfig.Callback or function() end
            
            local height = Description ~= "" and 52 or 44
            
            local elementFrame = Create("TextButton", {
                Name = "Button_" .. Title,
                Size = UDim2.new(1, 0, 0, height),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.3,
                Text = "",
                AutoButtonColor = false,
                Parent = TabFrame
            })
            AddCorner(elementFrame, 8)
            AddStroke(elementFrame, theme.Border, 0.5)
            
            local titleLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -60, 0, Description ~= "" and 18 or 22),
                Position = UDim2.new(0, 14, 0, Description ~= "" and 8 or 11),
                BackgroundTransparency = 1,
                Text = Title,
                TextColor3 = theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = elementFrame
            })
            
            if Description ~= "" then
                local descLabel = Create("TextLabel", {
                    Name = "Desc",
                    Size = UDim2.new(1, -60, 0, 14),
                    Position = UDim2.new(0, 14, 0, 28),
                    BackgroundTransparency = 1,
                    Text = Description,
                    TextColor3 = theme.SubText,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = elementFrame
                })
            end
            
            -- Execute icon
            local execIcon = Create("TextLabel", {
                Name = "ExecIcon",
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -36, 0.5, -12),
                BackgroundTransparency = 1,
                Text = "▶",
                TextColor3 = AccentColor,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                Parent = elementFrame
            })
            
            local ButtonObj = {}
            local isExecuting = false
            
            elementFrame.MouseButton1Click:Connect(function()
                if isExecuting then return end
                isExecuting = true
                
                -- Click animation
                Tween(elementFrame, {BackgroundTransparency = 0.1, Size = UDim2.new(1, -4, 0, height - 2)}, 0.08, Enum.EasingStyle.Quad)
                Tween(execIcon, {TextColor3 = Color3.fromHex("#FFFFFF")}, 0.08)
                task.wait(0.08)
                Tween(elementFrame, {BackgroundTransparency = 0.3, Size = UDim2.new(1, 0, 0, height)}, 0.12, Enum.EasingStyle.Quad)
                Tween(execIcon, {TextColor3 = AccentColor}, 0.12)
                
                pcall(Callback)
                isExecuting = false
            end)
            
            elementFrame.MouseEnter:Connect(function()
                Tween(elementFrame, {BackgroundTransparency = 0.15}, 0.1)
                Tween(execIcon, {TextColor3 = Color3.fromHex("#FFFFFF")}, 0.1)
            end)
            
            elementFrame.MouseLeave:Connect(function()
                Tween(elementFrame, {BackgroundTransparency = 0.3}, 0.1)
                Tween(execIcon, {TextColor3 = AccentColor}, 0.1)
            end)
            
            function ButtonObj:Fire()
                pcall(Callback)
            end
            
            return ButtonObj
        end
        
        -- ==================== LABEL ====================
        function Tab:CreateLabel(labelConfig)
            labelConfig = labelConfig or {}
            local Title = labelConfig.Title or "Label"
            local Description = labelConfig.Description or ""
            
            local height = Description ~= "" and 48 or 36
            
            local elementFrame = Create("Frame", {
                Name = "Label_" .. Title,
                Size = UDim2.new(1, 0, 0, height),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.3,
                Parent = TabFrame
            })
            AddCorner(elementFrame, 8)
            AddStroke(elementFrame, theme.Border, 0.5)
            
            local titleLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -28, 0, Description ~= "" and 18 or 22),
                Position = UDim2.new(0, 14, 0, Description ~= "" and 6 or 7),
                BackgroundTransparency = 1,
                Text = Title,
                TextColor3 = theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = elementFrame
            })
            
            if Description ~= "" then
                local descLabel = Create("TextLabel", {
                    Name = "Desc",
                    Size = UDim2.new(1, -28, 0, 14),
                    Position = UDim2.new(0, 14, 0, 26),
                    BackgroundTransparency = 1,
                    Text = Description,
                    TextColor3 = theme.SubText,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = elementFrame
                })
            end
            
            local LabelObj = {}
            
            function LabelObj:Set(title, desc)
                if title then titleLabel.Text = title end
                if desc then
                    local d = elementFrame:FindFirstChild("Desc")
                    if d then d.Text = desc end
                end
            end
            
            return LabelObj
        end
        
        -- ==================== PARAGRAPH ====================
        function Tab:CreateParagraph(paraConfig)
            paraConfig = paraConfig or {}
            local Title = paraConfig.Title or "Info"
            local Content = paraConfig.Content or ""
            
            local elementFrame = Create("Frame", {
                Name = "Paragraph_" .. Title,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.3,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = TabFrame
            })
            AddCorner(elementFrame, 8)
            AddStroke(elementFrame, AccentColor, 1)
            
            local padding = AddPadding(elementFrame, 14)
            
            local titleLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = Title,
                TextColor3 = AccentColor,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 0,
                Parent = elementFrame
            })
            
            local contentLabel = Create("TextLabel", {
                Name = "Content",
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = Content,
                TextColor3 = theme.SubText,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = 1,
                Parent = elementFrame
            })
            
            local layout = Create("UIListLayout", {
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = elementFrame
            })
            
            local ParaObj = {}
            
            function ParaObj:Set(title, content)
                if title then titleLabel.Text = title end
                if content then contentLabel.Text = content end
            end
            
            return ParaObj
        end
        
        -- ==================== SECTION (Header) ====================
        function Tab:CreateSection(sectionConfig)
            sectionConfig = sectionConfig or {}
            local SectionTitle = sectionConfig.Title or "Section"
            local SectionIcon = sectionConfig.Icon or ""
            
            local sectionFrame = Create("Frame", {
                Name = "Section_" .. SectionTitle,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = TabFrame
            })
            
            if SectionIcon ~= "" then
                local iconImg = Create("ImageLabel", {
                    Name = "Icon",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 4, 0.5, -8),
                    Image = SectionIcon,
                    ImageColor3 = AccentColor,
                    BackgroundTransparency = 1,
                    Parent = sectionFrame
                })
            end
            
            local sectionLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(0, 150, 1, 0),
                Position = UDim2.new(0, SectionIcon ~= "" and 24 or 4, 0, 0),
                BackgroundTransparency = 1,
                Text = SectionTitle,
                TextColor3 = theme.SubText,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionFrame
            })
            
            local line = Create("Frame", {
                Name = "Line",
                Size = UDim2.new(1, SectionIcon ~= "" and -178 or -158, 0, 1),
                Position = UDim2.new(0, SectionIcon ~= "" and 174 or 154, 0.5, 0),
                BackgroundColor3 = theme.Border,
                BackgroundTransparency = 0.5,
                Parent = sectionFrame
            })
            
            return sectionFrame
        end
        
        return Tab
    end
    
    -- ==================== WINDOW CONTROLS ====================
    
    local function OpenWindow()
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, Size.X.Offset * 0.9, 0, Size.Y.Offset * 0.9)
        MainFrame.Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2)
        MainFrame.BackgroundTransparency = 1
        
        Tween(MainFrame, {Size = Size, BackgroundTransparency = 0.05}, 0.25, Enum.EasingStyle.Quad)
    end
    
    local function CloseWindow()
        Tween(MainFrame, {Size = UDim2.new(0, Size.X.Offset * 0.9, 0, Size.Y.Offset * 0.9), BackgroundTransparency = 1}, 0.2, Enum.EasingStyle.Quad)
        task.delay(0.2, function()
            MainFrame.Visible = false
            MainFrame.Size = Size
        end)
    end
    
    local function ToggleMinimize()
        IsMinimized = not IsMinimized
        if IsMinimized then
            Tween(MainFrame, {Size = UDim2.new(0, Size.X.Offset, 0, 45)}, 0.25, Enum.EasingStyle.Quad)
            ContentArea.Visible = false
            Sidebar.Visible = false
        else
            Tween(MainFrame, {Size = Size}, 0.25, Enum.EasingStyle.Quad)
            ContentArea.Visible = true
            Sidebar.Visible = true
        end
    end
    
    CloseButton.MouseButton1Click:Connect(function()
        if OpenButtonConfig.Enabled then
            CloseWindow()
            if openButton then openButton.Visible = true end
        else
            CloseWindow()
        end
    end)
    
    MinimizeButton.MouseButton1Click:Connect(ToggleMinimize)
    
    -- Hover effects on control buttons
    CloseButton.MouseEnter:Connect(function() Tween(CloseButton, {BackgroundTransparency = 0}, 0.1) end)
    CloseButton.MouseLeave:Connect(function() Tween(CloseButton, {BackgroundTransparency = 0.3}, 0.1) end)
    MinimizeButton.MouseEnter:Connect(function() Tween(MinimizeButton, {BackgroundTransparency = 0}, 0.1) end)
    MinimizeButton.MouseLeave:Connect(function() Tween(MinimizeButton, {BackgroundTransparency = 0.3}, 0.1) end)
    
    -- ==================== OPEN BUTTON ====================
    local openButton = nil
    
    if OpenButtonConfig.Enabled then
        local btnColor = OpenButtonConfig.Color or ColorSequence.new(AccentColor, Color3.fromHex("#e7ff2f"))
        
        openButton = Create("TextButton", {
            Name = "OmverdOpenBtn",
            Size = UDim2.new(0, 160, 0, 44),
            Position = UDim2.new(0, 20, 0.5, -22),
            BackgroundColor3 = Color3.fromHex("#1A1A2E"),
            BackgroundTransparency = 0.1,
            Text = "",
            AutoButtonColor = false,
            Visible = true,
            Parent = screenGui
        })
        AddCorner(openButton, 10)
        AddStroke(openButton, AccentColor, 1.5)
        
        local btnGradient = Create("UIGradient", {
            Color = btnColor,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.85),
                NumberSequenceKeypoint.new(1, 0.85)
            }),
            Rotation = 45,
            Parent = openButton
        })
        
        local btnLabel = Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 36, 0, 0),
            BackgroundTransparency = 1,
            Text = OpenButtonConfig.Title or "Open Omverd",
            TextColor3 = AccentColor,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = openButton
        })
        
        local btnIcon = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(0, 10, 0.5, -11),
            Image = "rbxassetid://7072706796",
            ImageColor3 = AccentColor,
            BackgroundTransparency = 1,
            Parent = openButton
        })
        
        if OpenButtonConfig.Draggable then
            MakeDraggable(openButton, openButton, 0.08)
        end
        
        openButton.MouseButton1Click:Connect(function()
            openButton.Visible = false
            OpenWindow()
        end)
        
        openButton.MouseEnter:Connect(function()
            Tween(openButton, {BackgroundTransparency = 0}, 0.1)
        end)
        openButton.MouseLeave:Connect(function()
            Tween(openButton, {BackgroundTransparency = 0.1}, 0.1)
        end)
    end
    
    -- Open window by default
    if not OpenButtonConfig.Enabled then
        MainFrame.Visible = true
    else
        OpenWindow()
    end
    
    -- Window object methods
    Window.ScreenGui = screenGui
    Window.MainFrame = MainFrame
    
    function Window:Destroy()
        for _, conn in ipairs(Connections) do
            conn:Disconnect()
        end
        screenGui:Destroy()
    end
    
    function Window:Toggle()
        if MainFrame.Visible then
            CloseWindow()
        else
            OpenWindow()
            if openButton then openButton.Visible = false end
        end
    end
    
    return Window
end

-- ==================== KEYBIND SUPPORT ====================

function Omverd:BindKey(key, callback)
    local connection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == key then
            pcall(callback)
        end
    end)
    return connection
end

return Omverd

