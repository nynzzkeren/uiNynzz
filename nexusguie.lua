--[[
    ╔══════════════════════════════════════════════════╗
    ║  ObsidiaModern UI Library                       ║
    ║  Style: Classic-Modern Obsidia                  ║
    ║  Theme: Purple Black (#7C3AED accent)           ║
    ║  API: Rayfield-style                           ║
    ║  Minimize: "-" logo button (no toggle)         ║
    ╚══════════════════════════════════════════════════╝
]]

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- ==================== THEME ====================
local Theme = {
    -- Background layers
    Background = Color3.fromRGB(18, 18, 22),       -- Deep dark
    Surface = Color3.fromRGB(28, 28, 36),           -- Card/Section bg
    Surface2 = Color3.fromRGB(35, 35, 45),          -- Element bg
    Surface3 = Color3.fromRGB(45, 45, 58),          -- Hover state
    
    -- Accent (Purple)
    Accent = Color3.fromRGB(124, 58, 237),          -- #7C3AED
    AccentLight = Color3.fromRGB(167, 139, 250),    -- Hover accent
    AccentDark = Color3.fromRGB(109, 40, 217),      -- Pressed accent
    
    -- Text
    Text = Color3.fromRGB(220, 220, 230),
    TextSecondary = Color3.fromRGB(150, 150, 165),
    TextMuted = Color3.fromRGB(100, 100, 115),
    
    -- Borders & Dividers
    Border = Color3.fromRGB(50, 50, 62),
    Divider = Color3.fromRGB(45, 45, 55),
    
    -- Special
    Shadow = Color3.fromRGB(0, 0, 0),
    Success = Color3.fromRGB(34, 197, 94),
    Danger = Color3.fromRGB(239, 68, 68),
    Warning = Color3.fromRGB(234, 179, 8),
    
    -- Typography
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    FontSize = {
        Title = 18,
        Header = 15,
        Body = 13,
        Caption = 11,
    },
    
    -- Sizing
    Radius = 6,
    RadiusSm = 4,
    RadiusLg = 10,
    Padding = 12,
    ElementHeight = 38,
    SidebarWidth = 160,
    TabHeight = 42,
    SectionSpacing = 8,
}

-- ==================== UTILS ====================
local Utils = {}

function Utils.CreateInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        if prop == "Children" then
            for _, child in ipairs(value) do
                child.Parent = instance
            end
        else
            instance[prop] = value
        end
    end
    return instance
end

function Utils.Tween(instance, properties, duration, easingStyle, easingDirection)
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    duration = duration or 0.2
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utils.Round(num, decimalPlaces)
    local mult = 10 ^ (decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- ==================== SIGNAL CLASS ====================
local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({}, Signal)
    self._connections = {}
    return self
end

function Signal:Connect(callback)
    local connection = { Callback = callback, Connected = true }
    table.insert(self._connections, connection)
    return {
        Disconnect = function()
            connection.Connected = false
            for i, conn in ipairs(self._connections) do
                if conn == connection then
                    table.remove(self._connections, i)
                    break
                end
            end
        end
    }
end

function Signal:Fire(...)
    for _, conn in ipairs(self._connections) do
        if conn.Connected then
            coroutine.wrap(conn.Callback)(...)
        end
    end
end

function Signal:Destroy()
    self._connections = {}
end

-- ==================== UI CORNER + STROKE HELPER ====================
local function ApplyStyling(instance, options)
    options = options or {}
    
    if options.CornerRadius then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, options.CornerRadius)
        corner.Parent = instance
    end
    
    if options.StrokeColor then
        local stroke = Instance.new("UIStroke")
        stroke.Color = options.StrokeColor or Theme.Border
        stroke.Thickness = options.StrokeThickness or 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = instance
    end
    
    if options.Padding then
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, options.Padding)
        padding.PaddingBottom = UDim.new(0, options.Padding)
        padding.PaddingLeft = UDim.new(0, options.Padding)
        padding.PaddingRight = UDim.new(0, options.Padding)
        padding.Parent = instance
    end
end

-- ==================== MAIN LIBRARY CLASS ====================
local Library = {}
Library.__index = Library

function Library.new(title)
    local self = setmetatable({}, Library)
    
    self.Title = title or "ObsidiaModern"
    self.Theme = Theme
    self.Tabs = {}
    self.ActiveTab = nil
    self.Minimized = false
    self.Windows = {}
    
    -- Create ScreenGui
    self.ScreenGui = Utils.CreateInstance("ScreenGui", {
        Name = "ObsidiaModern",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    })
    
    -- Create Notification holder
    self.NotificationHolder = Utils.CreateInstance("Frame", {
        Name = "Notifications",
        Parent = self.ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
        AnchorPoint = Vector2.new(1, 1),
        Size = UDim2.new(0, 300, 0, 0),
        ZIndex = 1000,
    })
    
    local notifList = Utils.CreateInstance("UIListLayout", {
        Parent = self.NotificationHolder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 8),
    })
    
    -- Build Main Window
    self:BuildMainWindow()
    
    return self
end

function Library:BuildMainWindow()
    local mainWindow = Utils.CreateInstance("Frame", {
        Name = "MainWindow",
        Parent = self.ScreenGui,
        BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        ClipsDescendants = true,
        ZIndex = 10,
    })
    ApplyStyling(mainWindow, { CornerRadius = Theme.RadiusLg, StrokeColor = Theme.Border, StrokeThickness = 1 })
    
    -- Drop shadow effect
    local shadow = Utils.CreateInstance("ImageLabel", {
        Parent = mainWindow,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -8, 0, -8),
        Size = UDim2.new(1, 16, 1, 16),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Theme.Shadow,
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(8, 8, 9, 9),
        ZIndex = 9,
    })
    
    self.MainFrame = mainWindow
    
    -- Title Bar
    local titleBar = Utils.CreateInstance("Frame", {
        Name = "TitleBar",
        Parent = mainWindow,
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 11,
    })
    ApplyStyling(titleBar, { CornerRadius = Theme.RadiusLg })
    
    -- Round only top corners
    local titleCorner = titleBar:FindFirstChild("UICorner")
    if titleCorner then titleCorner:Destroy() end
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, Theme.RadiusLg)
    topCorner.Parent = titleBar
    
    -- Fix bottom corners (square)
    local bottomFrame = Utils.CreateInstance("Frame", {
        Parent = titleBar,
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(0, 0, 1, -Theme.RadiusLg),
        Size = UDim2.new(1, 0, 0, Theme.RadiusLg),
        ZIndex = 11,
    })
    
    -- Title text
    local titleLabel = Utils.CreateInstance("TextLabel", {
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        Text = self.Title,
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = Theme.FontSize.Header,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    })
    
    -- Minimize button (the "-" logo)
    local minimizeBtn = Utils.CreateInstance("TextButton", {
        Name = "MinimizeButton",
        Parent = titleBar,
        BackgroundColor3 = Theme.Surface2,
        Position = UDim2.new(1, -72, 0.5, -10),
        Size = UDim2.new(0, 28, 0, 20),
        Text = "—",  -- Em dash as minimize symbol
        TextColor3 = Theme.TextSecondary,
        Font = Theme.FontBold,
        TextSize = 16,
        ZIndex = 12,
    })
    ApplyStyling(minimizeBtn, { CornerRadius = Theme.RadiusSm })
    
    -- Close button
    local closeBtn = Utils.CreateInstance("TextButton", {
        Name = "CloseButton",
        Parent = titleBar,
        BackgroundColor3 = Theme.Danger,
        Position = UDim2.new(1, -36, 0.5, -10),
        Size = UDim2.new(0, 28, 0, 20),
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Theme.FontBold,
        TextSize = 14,
        ZIndex = 12,
    })
    ApplyStyling(closeBtn, { CornerRadius = Theme.RadiusSm })
    
    -- Content container (sidebar + main content)
    local contentContainer = Utils.CreateInstance("Frame", {
        Name = "ContentContainer",
        Parent = mainWindow,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 36),
        Size = UDim2.new(1, 0, 1, -36),
        ZIndex = 10,
    })
    
    -- Sidebar
    self.Sidebar = Utils.CreateInstance("Frame", {
        Name = "Sidebar",
        Parent = contentContainer,
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(0, Theme.SidebarWidth, 1, 0),
        ZIndex = 10,
    })
    
    -- Sidebar top logo area
    local sidebarLogo = Utils.CreateInstance("Frame", {
        Parent = self.Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 11,
    })
    
    local logoText = Utils.CreateInstance("TextLabel", {
        Parent = sidebarLogo,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Theme.Padding, 0, 0),
        Size = UDim2.new(1, -Theme.Padding * 2, 1, 0),
        Text = "Obsidia",
        TextColor3 = Theme.AccentLight,
        Font = Theme.FontBold,
        TextSize = Theme.FontSize.Header,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    })
    
    -- Divider under logo
    Utils.CreateInstance("Frame", {
        Parent = self.Sidebar,
        BackgroundColor3 = Theme.Divider,
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.new(0, 10, 0, 40),
        ZIndex = 11,
    })
    
    -- Tab buttons container
    self.TabButtonsContainer = Utils.CreateInstance("ScrollingFrame", {
        Name = "TabButtons",
        Parent = self.Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 46),
        Size = UDim2.new(1, 0, 1, -46),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 10,
    })
    
    local tabListLayout = Utils.CreateInstance("UIListLayout", {
        Parent = self.TabButtonsContainer,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    })
    
    -- Main content area (right side)
    self.ContentArea = Utils.CreateInstance("Frame", {
        Name = "ContentArea",
        Parent = contentContainer,
        BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0, Theme.SidebarWidth, 0, 0),
        Size = UDim2.new(1, -Theme.SidebarWidth, 1, 0),
        ZIndex = 10,
    })
    
    -- Pages container (for tabs)
    self.PagesContainer = Utils.CreateInstance("Frame", {
        Name = "Pages",
        Parent = self.ContentArea,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = true,
        ZIndex = 10,
    })
    
    -- Minimized state bar (hidden by default)
    self.MinimizedBar = Utils.CreateInstance("Frame", {
        Name = "MinimizedBar",
        Parent = self.ScreenGui,
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(0.5, -40, 0, 10),
        Size = UDim2.new(0, 80, 0, 30),
        Visible = false,
        ZIndex = 20,
    })
    ApplyStyling(self.MinimizedBar, { CornerRadius = Theme.RadiusLg, StrokeColor = Theme.Accent, StrokeThickness = 1.5 })
    
    local restoreBtn = Utils.CreateInstance("TextButton", {
        Parent = self.MinimizedBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "+",
        TextColor3 = Theme.AccentLight,
        Font = Theme.FontBold,
        TextSize = 20,
        ZIndex = 21,
    })
    
    -- Minimize functionality
    minimizeBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    restoreBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Close functionality
    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Dragging
    self:MakeDraggable(mainWindow, titleBar)
    
    -- Store references
    self.TitleBar = titleBar
    self.MinimizeBtn = minimizeBtn
end

function Library:ToggleMinimize()
    self.Minimized = not self.Minimized
    self.MainFrame.Visible = not self.Minimized
    self.MinimizedBar.Visible = self.Minimized
    
    if self.Minimized then
        Utils.Tween(self.MainFrame, { Size = UDim2.new(0, 0, 0, 0) }, 0.2)
    else
        self.MainFrame.Size = UDim2.new(0, 600, 0, 400)
        Utils.Tween(self.MainFrame, {}, 0)
    end
end

function Library:MakeDraggable(frame, handle)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function Library:CreateWindow(title)
    -- For simplicity, we support single window for now
    -- But we can extend to multi-window
    if #self.Windows > 0 then
        warn("ObsidiaModern: Multi-window support is limited. Creating additional window.")
    end
    
    local window = {
        Title = title or "Window",
        Library = self,
        Tabs = {},
    }
    table.insert(self.Windows, window)
    return window
end

function Library:AddTab(name, icon)
    icon = icon or ""
    local tabIndex = #self.Tabs + 1
    
    local tabButton = Utils.CreateInstance("TextButton", {
        Name = "Tab_" .. name,
        Parent = self.TabButtonsContainer,
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, -16, 0, Theme.TabHeight),
        Text = "  " .. icon .. "  " .. name,
        TextColor3 = Theme.TextSecondary,
        Font = Theme.FontMedium,
        TextSize = Theme.FontSize.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11,
        LayoutOrder = tabIndex,
    })
    ApplyStyling(tabButton, { CornerRadius = Theme.Radius })
    
    -- Page for this tab
    local page = Utils.CreateInstance("ScrollingFrame", {
        Name = "Page_" .. name,
        Parent = self.PagesContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 500),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.AccentDark,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
        ZIndex = 10,
    })
    
    local pageLayout = Utils.CreateInstance("UIListLayout", {
        Parent = page,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, Theme.SectionSpacing),
    })
    
    -- Padding at top
    Utils.CreateInstance("UIPadding", {
        Parent = page,
        PaddingTop = UDim.new(0, Theme.Padding),
        PaddingBottom = UDim.new(0, Theme.Padding),
    })
    
    local tabData = {
        Name = name,
        Icon = icon,
        Button = tabButton,
        Page = page,
        Sections = {},
        Active = false,
    }
    
    -- Tab click handler
    tabButton.MouseButton1Click:Connect(function()
        self:SetActiveTab(tabData)
    end)
    
    -- Hover effects
    tabButton.MouseEnter:Connect(function()
        if not tabData.Active then
            Utils.Tween(tabButton, { BackgroundColor3 = Theme.Surface2 }, 0.15)
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if not tabData.Active then
            Utils.Tween(tabButton, { BackgroundColor3 = Theme.Surface }, 0.15)
        end
    end)
    
    table.insert(self.Tabs, tabData)
    
    -- Auto-select first tab
    if #self.Tabs == 1 then
        self:SetActiveTab(tabData)
    end
    
    -- Create Tab object for Rayfield-style API
    local TabObj = {}
    TabObj.__index = TabObj
    
    function TabObj:CreateSection(name)
        return self.Library:CreateSection(tabData, name)
    end
    
    local tabInstance = setmetatable({
        Library = self,
        TabData = tabData,
    }, TabObj)
    
    return tabInstance
end

function Library:SetActiveTab(tabData)
    if self.ActiveTab == tabData then return end
    
    -- Deactivate previous tab
    if self.ActiveTab then
        self.ActiveTab.Active = false
        self.ActiveTab.Page.Visible = false
        Utils.Tween(self.ActiveTab.Button, {
            BackgroundColor3 = Theme.Surface,
            TextColor3 = Theme.TextSecondary,
        }, 0.15)
    end
    
    -- Activate new tab
    tabData.Active = true
    tabData.Page.Visible = true
    Utils.Tween(tabData.Button, {
        BackgroundColor3 = Theme.Accent,
        TextColor3 = Color3.fromRGB(255, 255, 255),
    }, 0.15)
    
    self.ActiveTab = tabData
end

function Library:CreateSection(tabData, name)
    local sectionFrame = Utils.CreateInstance("Frame", {
        Name = "Section_" .. name,
        Parent = tabData.Page,
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, -Theme.Padding * 2, 0, 10),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 10,
        LayoutOrder = #tabData.Sections + 1,
    })
    ApplyStyling(sectionFrame, { CornerRadius = Theme.Radius, StrokeColor = Theme.Border, StrokeThickness = 0.5 })
    
    -- Section header
    local headerFrame = Utils.CreateInstance("Frame", {
        Parent = sectionFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 11,
    })
    
    local headerText = Utils.CreateInstance("TextLabel", {
        Parent = headerFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Theme.Padding, 0, 0),
        Size = UDim2.new(1, -Theme.Padding * 2, 1, 0),
        Text = name,
        TextColor3 = Theme.AccentLight,
        Font = Theme.FontBold,
        TextSize = Theme.FontSize.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    })
    
    -- Accent line under header
    Utils.CreateInstance("Frame", {
        Parent = sectionFrame,
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0, Theme.Padding, 0, 30),
        Size = UDim2.new(1, -Theme.Padding * 2, 0, 1),
        ZIndex = 11,
    })
    
    -- Elements container
    local elementsContainer = Utils.CreateInstance("Frame", {
        Name = "Elements",
        Parent = sectionFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 0, 10),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 10,
    })
    
    local elementsLayout = Utils.CreateInstance("UIListLayout", {
        Parent = elementsContainer,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    })
    
    Utils.CreateInstance("UIPadding", {
        Parent = elementsContainer,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, Theme.Padding),
        PaddingRight = UDim.new(0, Theme.Padding),
    })
    
    local sectionData = {
        Name = name,
        Frame = sectionFrame,
        ElementsContainer = elementsContainer,
        Elements = {},
    }
    
    table.insert(tabData.Sections, sectionData)
    
    -- Section object for API
    local SectionObj = {}
    SectionObj.__index = SectionObj
    
    function SectionObj:CreateButton(name, callback)
        return self.Library:CreateButton(sectionData, name, callback)
    end
    
    function SectionObj:CreateToggle(name, default, callback)
        return self.Library:CreateToggle(sectionData, name, default, callback)
    end
    
    function SectionObj:CreateSlider(name, min, max, default, callback)
        return self.Library:CreateSlider(sectionData, name, min, max, default, callback)
    end
    
    function SectionObj:CreateDropdown(name, options, default, callback)
        return self.Library:CreateDropdown(sectionData, name, options, default, callback)
    end
    
    function SectionObj:CreateLabel(text)
        return self.Library:CreateLabel(sectionData, text)
    end
    
    function SectionObj:CreateDescription(text)
        return self.Library:CreateDescription(sectionData, text)
    end
    
    local sectionInstance = setmetatable({
        Library = self,
        SectionData = sectionData,
    }, SectionObj)
    
    return sectionInstance
end

-- ==================== ELEMENTS ====================

-- BUTTON
function Library:CreateButton(sectionData, name, callback)
    local button = Utils.CreateInstance("TextButton", {
        Name = "Button_" .. name,
        Parent = sectionData.ElementsContainer,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight),
        Text = name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Theme.FontMedium,
        TextSize = Theme.FontSize.Body,
        ZIndex = 11,
        LayoutOrder = #sectionData.Elements + 1,
    })
    ApplyStyling(button, { CornerRadius = Theme.RadiusSm })
    
    local ripple = Utils.CreateInstance("Frame", {
        Parent = button,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 12,
    })
    ApplyStyling(ripple, { CornerRadius = 100 })
    
    button.MouseButton1Click:Connect(function()
        -- Ripple effect
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.BackgroundTransparency = 0.4
        Utils.Tween(ripple, {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1,
        }, 0.4, Enum.EasingStyle.Quad)
        
        if callback then
            callback()
        end
    end)
    
    button.MouseEnter:Connect(function()
        Utils.Tween(button, { BackgroundColor3 = Theme.AccentLight }, 0.15)
    end)
    
    button.MouseLeave:Connect(function()
        Utils.Tween(button, { BackgroundColor3 = Theme.Accent }, 0.15)
    end)
    
    local elementData = { Instance = button, Type = "Button" }
    table.insert(sectionData.Elements, elementData)
    return elementData
end

-- TOGGLE
function Library:CreateToggle(sectionData, name, default, callback)
    default = default or false
    local toggled = default
    
    local toggleFrame = Utils.CreateInstance("Frame", {
        Name = "Toggle_" .. name,
        Parent = sectionData.ElementsContainer,
        BackgroundColor3 = Theme.Surface2,
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight),
        ZIndex = 11,
        LayoutOrder = #sectionData.Elements + 1,
    })
    ApplyStyling(toggleFrame, { CornerRadius = Theme.RadiusSm })
    
    -- Label
    local label = Utils.CreateInstance("TextLabel", {
        Parent = toggleFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Theme.Padding, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        Text = name,
        TextColor3 = Theme.Text,
        Font = Theme.FontMedium,
        TextSize = Theme.FontSize.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    })
    
    -- Toggle switch background
    local switchBg = Utils.CreateInstance("Frame", {
        Parent = toggleFrame,
        BackgroundColor3 = default and Theme.Accent or Theme.Surface3,
        Position = UDim2.new(1, -50, 0.5, -10),
        Size = UDim2.new(0, 38, 0, 20),
        ZIndex = 12,
    })
    ApplyStyling(switchBg, { CornerRadius = 10 })
    
    -- Toggle knob
    local knob = Utils.CreateInstance("Frame", {
        Parent = switchBg,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 16, 0, 16),
        Position = default 
            and UDim2.new(1, -18, 0.5, -8) 
            or UDim2.new(0, 2, 0.5, -8),
        ZIndex = 13,
    })
    ApplyStyling(knob, { CornerRadius = 8 })
    
    local function updateToggle()
        toggled = not toggled
        local targetColor = toggled and Theme.Accent or Theme.Surface3
        local targetPos = toggled 
            and UDim2.new(1, -18, 0.5, -8) 
            or UDim2.new(0, 2, 0.5, -8)
        
        Utils.Tween(switchBg, { BackgroundColor3 = targetColor }, 0.2)
        Utils.Tween(knob, { Position = targetPos }, 0.2)
        
        if callback then
            callback(toggled)
        end
    end
    
    switchBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateToggle()
        end
    end)
    
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateToggle()
        end
    end)
    
    local elementData = { 
        Instance = toggleFrame, 
        Type = "Toggle",
        SetValue = function(val)
            if toggled ~= val then
                updateToggle()
            end
        end,
        GetValue = function()
            return toggled
        end,
    }
    table.insert(sectionData.Elements, elementData)
    return elementData
end

-- SLIDER
function Library:CreateSlider(sectionData, name, min, max, default, callback)
    default = default or min
    local currentValue = math.clamp(default, min, max)
    local range = max - min
    
    local sliderFrame = Utils.CreateInstance("Frame", {
        Name = "Slider_" .. name,
        Parent = sectionData.ElementsContainer,
        BackgroundColor3 = Theme.Surface2,
        Size = UDim2.new(1, 0, 0, 54),
        ZIndex = 11,
        LayoutOrder = #sectionData.Elements + 1,
    })
    ApplyStyling(sliderFrame, { CornerRadius = Theme.RadiusSm })
    
    -- Header row
    local headerRow = Utils.CreateInstance("Frame", {
        Parent = sliderFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -Theme.Padding * 2, 0, 20),
        Position = UDim2.new(0, Theme.Padding, 0, 4),
        ZIndex = 12,
    })
    
    local nameLabel = Utils.CreateInstance("TextLabel", {
        Parent = headerRow,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, 0, 1, 0),
        Text = name,
        TextColor3 = Theme.Text,
        Font = Theme.FontMedium,
        TextSize = Theme.FontSize.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
    })
    
    local valueLabel = Utils.CreateInstance("TextLabel", {
        Parent = headerRow,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.7, 0, 0, 0),
        Size = UDim2.new(0.3, 0, 1, 0),
        Text = tostring(currentValue),
        TextColor3 = Theme.AccentLight,
        Font = Theme.FontBold,
        TextSize = Theme.FontSize.Body,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 13,
    })
    
    -- Slider track background
    local trackBg = Utils.CreateInstance("Frame", {
        Parent = sliderFrame,
        BackgroundColor3 = Theme.Surface3,
        Position = UDim2.new(0, Theme.Padding, 0, 28),
        Size = UDim2.new(1, -Theme.Padding * 2, 0, 6),
        ZIndex = 12,
    })
    ApplyStyling(trackBg, { CornerRadius = 3 })
    
    -- Filled track
    local fillPercent = (currentValue - min) / range
    local fillTrack = Utils.CreateInstance("Frame", {
        Parent = trackBg,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(fillPercent, 0, 1, 0),
        ZIndex = 13,
    })
    ApplyStyling(fillTrack, { CornerRadius = 3 })
    
    -- Draggable knob
    local knob = Utils.CreateInstance("Frame", {
        Parent = trackBg,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(fillPercent, -7, 0.5, -7),
        ZIndex = 14,
    })
    ApplyStyling(knob, { CornerRadius = 7 })
    
    local function updateSlider(input)
        local relativePos = math.clamp((input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
        currentValue = math.floor(min + relativePos * range + 0.5)
        currentValue = math.clamp(currentValue, min, max)
        
        local fillPct = (currentValue - min) / range
        fillTrack.Size = UDim2.new(fillPct, 0, 1, 0)
        knob.Position = UDim2.new(fillPct, -7, 0.5, -7)
        valueLabel.Text = tostring(currentValue)
        
        if callback then
            callback(currentValue)
        end
    end
    
    -- Slider dragging
    local dragging = false
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    trackBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    local elementData = { 
        Instance = sliderFrame, 
        Type = "Slider",
        SetValue = function(val)
            currentValue = math.clamp(val, min, max)
            local fillPct = (currentValue - min) / range
            fillTrack.Size = UDim2.new(fillPct, 0, 1, 0)
            knob.Position = UDim2.new(fillPct, -7, 0.5, -7)
            valueLabel.Text = tostring(currentValue)
            if callback then callback(currentValue) end
        end,
        GetValue = function()
            return currentValue
        end,
    }
    table.insert(sectionData.Elements, elementData)
    return elementData
end

-- DROPDOWN
function Library:CreateDropdown(sectionData, name, options, default, callback)
    options = options or {}
    default = default or (options[1] or "")
    local selectedOption = default
    local isOpen = false
    
    local dropdownFrame = Utils.CreateInstance("Frame", {
        Name = "Dropdown_" .. name,
        Parent = sectionData.ElementsContainer,
        BackgroundColor3 = Theme.Surface2,
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight),
        ZIndex = 11,
        LayoutOrder = #sectionData.Elements + 1,
        ClipsDescendants = false,
    })
    ApplyStyling(dropdownFrame, { CornerRadius = Theme.RadiusSm })
    
    -- Label
    local label = Utils.CreateInstance("TextLabel", {
        Parent = dropdownFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Theme.Padding, 0, 0),
        Size = UDim2.new(0.4, 0, 1, 0),
        Text = name,
        TextColor3 = Theme.Text,
        Font = Theme.FontMedium,
        TextSize = Theme.FontSize.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    })
    
    -- Selected option display
    local selectedDisplay = Utils.CreateInstance("TextButton", {
        Parent = dropdownFrame,
        BackgroundColor3 = Theme.Surface3,
        Position = UDim2.new(0.42, 0, 0.5, -13),
        Size = UDim2.new(0.55, -Theme.Padding, 0, 26),
        Text = "  " .. selectedOption .. "  ▼",
        TextColor3 = Theme.TextSecondary,
        Font = Theme.FontMedium,
        TextSize = Theme.FontSize.Caption,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    })
    ApplyStyling(selectedDisplay, { CornerRadius = Theme.RadiusSm })
    
    -- Options list (hidden by default, renders above/below)
    local optionsList = Utils.CreateInstance("ScrollingFrame", {
        Name = "OptionsList",
        Parent = self.ScreenGui, -- Parent to ScreenGui to avoid clipping
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(0, dropdownFrame.AbsoluteSize.X * 0.55, 0, 0),
        Position = UDim2.new(0, selectedDisplay.AbsolutePosition.X, 0, selectedDisplay.AbsolutePosition.Y + 26),
        Visible = false,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.AccentDark,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 100,
    })
    ApplyStyling(optionsList, { CornerRadius = Theme.RadiusSm, StrokeColor = Theme.Accent, StrokeThickness = 1 })
    
    local optionsLayout = Utils.CreateInstance("UIListLayout", {
        Parent = optionsList,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    
    -- Populate options
    for i, opt in ipairs(options) do
        local optBtn = Utils.CreateInstance("TextButton", {
            Parent = optionsList,
            BackgroundColor3 = Theme.Surface,
            Size = UDim2.new(1, 0, 0, 28),
            Text = "  " .. opt,
            TextColor3 = Theme.TextSecondary,
            Font = Theme.FontMedium,
            TextSize = Theme.FontSize.Caption,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 101,
            LayoutOrder = i,
        })
        
        optBtn.MouseEnter:Connect(function()
            Utils.Tween(optBtn, { BackgroundColor3 = Theme.Surface2 }, 0.1)
        end)
        
        optBtn.MouseLeave:Connect(function()
            Utils.Tween(optBtn, { BackgroundColor3 = Theme.Surface }, 0.1)
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            selectedOption = opt
            selectedDisplay.Text = "  " .. opt .. "  ▼"
            optionsList.Visible = false
            isOpen = false
            if callback then
                callback(opt)
            end
        end)
    end
    
    -- Update canvas size
    optionsList.CanvasSize = UDim2.new(0, 0, 0, #options * 28)
    optionsList.Size = UDim2.new(0, optionsList.AbsoluteSize.X, 0, math.min(#options * 28, 140))
    
    -- Toggle dropdown
    selectedDisplay.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        optionsList.Visible = isOpen
        -- Reposition
        optionsList.Position = UDim2.new(0, selectedDisplay.AbsolutePosition.X, 0, selectedDisplay.AbsolutePosition.Y + 26)
    end)
    
    -- Close when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
            if not (input.Position.X >= optionsList.AbsolutePosition.X 
                and input.Position.X <= optionsList.AbsolutePosition.X + optionsList.AbsoluteSize.X
                and input.Position.Y >= optionsList.AbsolutePosition.Y 
                and input.Position.Y <= optionsList.AbsolutePosition.Y + optionsList.AbsoluteSize.Y
                or input.Position.X >= selectedDisplay.AbsolutePosition.X
                and input.Position.X <= selectedDisplay.AbsolutePosition.X + selectedDisplay.AbsoluteSize.X
                and input.Position.Y >= selectedDisplay.AbsolutePosition.Y
                and input.Position.Y <= selectedDisplay.AbsolutePosition.Y + selectedDisplay.AbsoluteSize.Y) then
                optionsList.Visible = false
                isOpen = false
            end
        end
    end)
    
    local elementData = { 
        Instance = dropdownFrame, 
        Type = "Dropdown",
        SetValue = function(val)
            selectedOption = val
            selectedDisplay.Text = "  " .. val .. "  ▼"
            if callback then callback(val) end
        end,
        GetValue = function()
            return selectedOption
        end,
        Refresh = function(newOptions)
            -- Clear and rebuild options
            for _, child in ipairs(optionsList:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for i, opt in ipairs(newOptions) do
                local optBtn = Utils.CreateInstance("TextButton", {
                    Parent = optionsList,
                    BackgroundColor3 = Theme.Surface,
                    Size = UDim2.new(1, 0, 0, 28),
                    Text = "  " .. opt,
                    TextColor3 = Theme.TextSecondary,
                    Font = Theme.FontMedium,
                    TextSize = Theme.FontSize.Caption,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 101,
                    LayoutOrder = i,
                })
                optBtn.MouseEnter:Connect(function()
                    Utils.Tween(optBtn, { BackgroundColor3 = Theme.Surface2 }, 0.1)
                end)
                optBtn.MouseLeave:Connect(function()
                    Utils.Tween(optBtn, { BackgroundColor3 = Theme.Surface }, 0.1)
                end)
                optBtn.MouseButton1Click:Connect(function()
                    selectedOption = opt
                    selectedDisplay.Text = "  " .. opt .. "  ▼"
                    optionsList.Visible = false
                    isOpen = false
                    if callback then callback(opt) end
                end)
            end
            optionsList.CanvasSize = UDim2.new(0, 0, 0, #newOptions * 28)
        end,
    }
    table.insert(sectionData.Elements, elementData)
    return elementData
end

-- LABEL (Placeholder)
function Library:CreateLabel(sectionData, text)
    local label = Utils.CreateInstance("TextLabel", {
        Name = "Label",
        Parent = sectionData.ElementsContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight),
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.FontMedium,
        TextSize = Theme.FontSize.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11,
        LayoutOrder = #sectionData.Elements + 1,
    })
    
    Utils.CreateInstance("UIPadding", {
        Parent = label,
        PaddingLeft = UDim.new(0, Theme.Padding),
    })
    
    local elementData = { Instance = label, Type = "Label", SetText = function(t) label.Text = t end }
    table.insert(sectionData.Elements, elementData)
    return elementData
end

-- DESCRIPTION (secondary text)
function Library:CreateDescription(sectionData, text)
    local desc = Utils.CreateInstance("TextLabel", {
        Name = "Description",
        Parent = sectionData.ElementsContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Text = text,
        TextColor3 = Theme.TextMuted,
        Font = Theme.Font,
        TextSize = Theme.FontSize.Caption,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 11,
        LayoutOrder = #sectionData.Elements + 1,
    })
    
    Utils.CreateInstance("UIPadding", {
        Parent = desc,
        PaddingLeft = UDim.new(0, Theme.Padding),
    })
    
    local elementData = { Instance = desc, Type = "Description", SetText = function(t) desc.Text = t end }
    table.insert(sectionData.Elements, elementData)
    return elementData
end

-- ==================== NOTIFICATIONS ====================
function Library:Notify(title, message, duration)
    duration = duration or 3
    local notif = Utils.CreateInstance("Frame", {
        Name = "Notification",
        Parent = self.NotificationHolder,
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, 0, 0, 60),
        ZIndex = 1001,
        LayoutOrder = -1, -- top of list
    })
    ApplyStyling(notif, { CornerRadius = Theme.Radius, StrokeColor = Theme.Accent, StrokeThickness = 1 })
    
    -- Accent left bar
    Utils.CreateInstance("Frame", {
        Parent = notif,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 3, 1, 0),
        ZIndex = 1002,
    })
    
    local titleLabel = Utils.CreateInstance("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Theme.Padding + 6, 0, 4),
        Size = UDim2.new(1, -Theme.Padding * 2 - 6, 0, 20),
        Text = title,
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = Theme.FontSize.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1002,
    })
    
    local messageLabel = Utils.CreateInstance("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Theme.Padding + 6, 0, 24),
        Size = UDim2.new(1, -Theme.Padding * 2 - 6, 0, 30),
        Text = message,
        TextColor3 = Theme.TextSecondary,
        Font = Theme.Font,
        TextSize = Theme.FontSize.Caption,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 1002,
    })
    
    -- Auto remove
    task.delay(duration, function()
        Utils.Tween(notif, { 
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
        }, 0.3, Enum.EasingStyle.Quad)
        task.wait(0.3)
        notif:Destroy()
    end)
    
    return notif
end

-- ==================== DESTROY ====================
function Library:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

-- ==================== EXPORT ====================
return Library
