--[[
    ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗    ██╗   ██╗██╗
    ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝    ██║   ██║██║
    ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗    ██║   ██║██║
    ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║    ██║   ██║██║
    ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║    ╚██████╔╝██║
    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚═╝

    NexusUI v1.0.0 — Professional Roblox UI Library
    Cyber-Minimal Aesthetic | Black & White | Smooth Animations
    
    Author   : NexusUI
    Version  : 1.0.0
    License  : Free to use / modify
--]]

-- ─────────────────────────────────────────────────────────────
-- SERVICES
-- ─────────────────────────────────────────────────────────────
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local CoreGui            = game:GetService("CoreGui")
local TextService        = game:GetService("TextService")

local LocalPlayer        = Players.LocalPlayer
local Mouse              = LocalPlayer:GetMouse()

-- ─────────────────────────────────────────────────────────────
-- THEME
-- ─────────────────────────────────────────────────────────────
local Theme = {
    -- Base Palette
    Background      = Color3.fromRGB(8,   8,   10),
    Surface         = Color3.fromRGB(14,  14,  18),
    SurfaceLight    = Color3.fromRGB(20,  20,  26),
    SurfaceLighter  = Color3.fromRGB(28,  28,  36),

    -- Borders
    Border          = Color3.fromRGB(38,  38,  50),
    BorderBright    = Color3.fromRGB(60,  60,  80),

    -- Text
    TextPrimary     = Color3.fromRGB(230, 230, 240),
    TextSecondary   = Color3.fromRGB(130, 130, 150),
    TextMuted       = Color3.fromRGB(70,  70,  90),

    -- Accent — electric cyan glow
    Accent          = Color3.fromRGB(80,  220, 255),
    AccentDim       = Color3.fromRGB(40,  110, 130),
    AccentGlow      = Color3.fromRGB(20,  60,  75),

    -- Status
    Success         = Color3.fromRGB(60,  220, 130),
    Warning         = Color3.fromRGB(255, 195, 50),
    Danger          = Color3.fromRGB(255, 70,  80),

    -- Interaction
    HoverOverlay    = Color3.fromRGB(255, 255, 255),
    PressOverlay    = Color3.fromRGB(80,  220, 255),

    -- Tween speeds
    TweenFast       = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TweenMed        = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TweenSlow       = TweenInfo.new(0.40, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    TweenBounce     = TweenInfo.new(0.35, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
    TweenSpring     = TweenInfo.new(0.45, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
}

-- ─────────────────────────────────────────────────────────────
-- UTILITY FUNCTIONS
-- ─────────────────────────────────────────────────────────────
local Util = {}

function Util.Tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

function Util.Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

function Util.MakeCorner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

function Util.MakeStroke(thickness, color, transparency, parent)
    local s = Instance.new("UIStroke")
    s.Thickness      = thickness or 1
    s.Color          = color or Theme.Border
    s.Transparency   = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

function Util.MakePadding(top, bottom, left, right, parent)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.Parent = parent
    return p
end

function Util.MakeList(spacing, parent, fillDir, horAlign, verAlign, sortOrder)
    local l = Instance.new("UIListLayout")
    l.Padding            = UDim.new(0, spacing or 6)
    l.FillDirection      = fillDir  or Enum.FillDirection.Vertical
    l.HorizontalAlignment = horAlign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment   = verAlign or Enum.VerticalAlignment.Top
    l.SortOrder          = sortOrder or Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

function Util.AddHover(frame, normalColor, hoverColor, tweenInfo)
    tweenInfo = tweenInfo or Theme.TweenFast
    frame.MouseEnter:Connect(function()
        Util.Tween(frame, tweenInfo, {BackgroundColor3 = hoverColor})
    end)
    frame.MouseLeave:Connect(function()
        Util.Tween(frame, tweenInfo, {BackgroundColor3 = normalColor})
    end)
end

function Util.AddButtonPress(button, normalColor, pressColor)
    button.MouseButton1Down:Connect(function()
        Util.Tween(button, Theme.TweenFast, {BackgroundColor3 = pressColor})
    end)
    button.MouseButton1Up:Connect(function()
        Util.Tween(button, Theme.TweenFast, {BackgroundColor3 = normalColor})
    end)
    button.MouseLeave:Connect(function()
        Util.Tween(button, Theme.TweenFast, {BackgroundColor3 = normalColor})
    end)
end

-- Auto-resize a frame's canvas to fit its UIListLayout content
function Util.AutoCanvas(scrollFrame, listLayout)
    local function update()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

-- ─────────────────────────────────────────────────────────────
-- ICONS (minimal SVG-style via ImageLabels — using Roblox asset IDs)
-- We'll use text-based glyphs for portability
-- ─────────────────────────────────────────────────────────────
local Icons = {
    Close    = "×",
    Minimize = "–",
    Logo     = "⬡",    -- hexagon as a cyber logo glyph
    Arrow    = "›",
    Check    = "✓",
    Dot      = "●",
    Info     = "ℹ",
    Warn     = "⚠",
    Success  = "✓",
}

-- ─────────────────────────────────────────────────────────────
-- LIBRARY CORE
-- ─────────────────────────────────────────────────────────────
local NexusUI = {}
NexusUI.__index = NexusUI

NexusUI._Windows       = {}
NexusUI._Notifications = {}
NexusUI._NotifCount    = 0

-- Create or recycle the ScreenGui
function NexusUI:_GetGui()
    if self._ScreenGui and self._ScreenGui.Parent then
        return self._ScreenGui
    end
    -- Try to parent to CoreGui (executor environment) else PlayerGui
    local success, gui = pcall(function()
        local g = Instance.new("ScreenGui")
        g.Name             = "NexusUI"
        g.ResetOnSpawn     = false
        g.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
        g.DisplayOrder     = 999
        g.IgnoreGuiInset   = true
        g.Parent           = CoreGui
        return g
    end)
    if not success then
        local g = Instance.new("ScreenGui")
        g.Name             = "NexusUI"
        g.ResetOnSpawn     = false
        g.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
        g.DisplayOrder     = 999
        g.IgnoreGuiInset   = true
        g.Parent           = LocalPlayer:WaitForChild("PlayerGui")
        gui = g
    end
    -- Blur effect
    local blur = Instance.new("BlurEffect")
    blur.Size   = 0
    blur.Parent = game:GetService("Lighting")
    self._Blur  = blur
    self._ScreenGui = gui
    return gui
end

-- ─────────────────────────────────────────────────────────────
-- NOTIFICATION SYSTEM
-- ─────────────────────────────────────────────────────────────
function NexusUI:Notify(config)
    config = config or {}
    local title    = config.Title   or "Notification"
    local text     = config.Text    or ""
    local duration = config.Duration or 4
    local nType    = config.Type    or "info"   -- info | success | warning | error

    local gui = self:_GetGui()
    self._NotifCount = self._NotifCount + 1

    -- Container anchor (bottom-right)
    if not self._NotifContainer then
        self._NotifContainer = Util.Create("Frame", {
            Name            = "NotifContainer",
            Size            = UDim2.new(0, 280, 1, 0),
            Position        = UDim2.new(1, -295, 0, 0),
            BackgroundTransparency = 1,
            Parent          = gui,
        })
        local list = Util.MakeList(8, self._NotifContainer)
        list.VerticalAlignment   = Enum.VerticalAlignment.Bottom
        list.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Util.MakePadding(10, 10, 0, 0, self._NotifContainer)
    end

    -- Accent colour per type
    local accentCol = ({
        info    = Theme.Accent,
        success = Theme.Success,
        warning = Theme.Warning,
        error   = Theme.Danger,
    })[nType] or Theme.Accent

    local iconGlyph = ({
        info    = Icons.Info,
        success = Icons.Success,
        warning = Icons.Warn,
        error   = Icons.Close,
    })[nType] or Icons.Info

    -- Notification card
    local card = Util.Create("Frame", {
        Name               = "Notif_" .. self._NotifCount,
        Size               = UDim2.new(1, 0, 0, 70),
        BackgroundColor3   = Theme.Surface,
        BorderSizePixel    = 0,
        ClipsDescendants   = true,
        LayoutOrder        = self._NotifCount,
        Parent             = self._NotifContainer,
    })
    Util.MakeCorner(8, card)
    Util.MakeStroke(1, Theme.Border, 0, card)

    -- Left accent bar
    local accentBar = Util.Create("Frame", {
        Name             = "AccentBar",
        Size             = UDim2.new(0, 3, 1, 0),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = accentCol,
        BorderSizePixel  = 0,
        Parent           = card,
    })
    Util.MakeCorner(3, accentBar)

    -- Glow behind accent bar
    local glow = Util.Create("Frame", {
        Size             = UDim2.new(0, 40, 1, 0),
        BackgroundColor3 = accentCol,
        BackgroundTransparency = 0.85,
        BorderSizePixel  = 0,
        Parent           = card,
    })
    Util.MakeCorner(8, glow)

    -- Icon
    local icon = Util.Create("TextLabel", {
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(0, 14, 0.5, -14),
        BackgroundColor3 = accentCol,
        BackgroundTransparency = 0.8,
        Text             = iconGlyph,
        TextColor3       = accentCol,
        TextSize         = 14,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Center,
        BorderSizePixel  = 0,
        Parent           = card,
    })
    Util.MakeCorner(6, icon)

    -- Title
    Util.Create("TextLabel", {
        Size             = UDim2.new(1, -58, 0, 18),
        Position         = UDim2.new(0, 50, 0, 12),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = Theme.TextPrimary,
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextTruncate     = Enum.TextTruncate.AtEnd,
        Parent           = card,
    })

    -- Body text
    Util.Create("TextLabel", {
        Size             = UDim2.new(1, -58, 0, 28),
        Position         = UDim2.new(0, 50, 0, 32),
        BackgroundTransparency = 1,
        Text             = text,
        TextColor3       = Theme.TextSecondary,
        TextSize         = 11,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        Parent           = card,
    })

    -- Progress bar
    local progressBg = Util.Create("Frame", {
        Size             = UDim2.new(1, -4, 0, 2),
        Position         = UDim2.new(0, 2, 1, -4),
        BackgroundColor3 = Theme.SurfaceLighter,
        BorderSizePixel  = 0,
        Parent           = card,
    })
    Util.MakeCorner(2, progressBg)

    local progress = Util.Create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accentCol,
        BorderSizePixel  = 0,
        Parent           = progressBg,
    })
    Util.MakeCorner(2, progress)

    -- Animate in (slide from right)
    card.Position = UDim2.new(1.2, 0, card.Position.Y.Scale, card.Position.Y.Offset)
    Util.Tween(card, Theme.TweenBounce, {Position = UDim2.new(0, 0, card.Position.Y.Scale, card.Position.Y.Offset)})

    -- Progress countdown
    Util.Tween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})

    -- Animate out after duration
    task.delay(duration, function()
        Util.Tween(card, Theme.TweenMed, {Position = UDim2.new(1.2, 0, 0, 0), BackgroundTransparency = 1})
        task.wait(0.25)
        card:Destroy()
    end)
end

-- ─────────────────────────────────────────────────────────────
-- CREATE WINDOW
-- ─────────────────────────────────────────────────────────────
function NexusUI:CreateWindow(config)
    config = config or {}
    local title        = config.Title      or "NexusUI"
    local size         = config.Size       or UDim2.new(0, 560, 0, 400)
    local position     = config.Position   or UDim2.new(0.5, -280, 0.5, -200)
    local toggleKey    = config.ToggleKey  or Enum.KeyCode.RightShift

    local gui = self:_GetGui()

    -- ── Outer shadow layer ──────────────────────────────────
    local shadowFrame = Util.Create("Frame", {
        Name               = "Shadow",
        Size               = UDim2.new(size.X.Scale, size.X.Offset + 30,
                                       size.Y.Scale, size.Y.Offset + 30),
        Position           = UDim2.new(position.X.Scale, position.X.Offset - 15,
                                       position.Y.Scale, position.Y.Offset - 15),
        BackgroundColor3   = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel    = 0,
        ZIndex             = 9,
        Parent             = gui,
    })
    Util.MakeCorner(12, shadowFrame)

    -- ── Main window frame ───────────────────────────────────
    local winFrame = Util.Create("Frame", {
        Name               = "NexusWindow",
        Size               = size,
        Position           = position,
        BackgroundColor3   = Theme.Background,
        BorderSizePixel    = 0,
        ClipsDescendants   = true,
        ZIndex             = 10,
        Parent             = gui,
    })
    Util.MakeCorner(10, winFrame)
    Util.MakeStroke(1, Theme.Border, 0, winFrame)

    -- ── Scanline texture overlay (subtle cyber feel) ────────
    local scanline = Util.Create("Frame", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundColor3       = Color3.fromRGB(80, 220, 255),
        BackgroundTransparency = 0.97,
        BorderSizePixel        = 0,
        ZIndex                 = 11,
        Parent                 = winFrame,
    })

    -- ── TOP BAR ──────────────────────────────────────────────
    local topBar = Util.Create("Frame", {
        Name             = "TopBar",
        Size             = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 12,
        Parent           = winFrame,
    })

    -- Top bar bottom separator line
    Util.Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel  = 0,
        ZIndex           = 13,
        Parent           = topBar,
    })

    -- Accent line at very top of top bar
    local topAccent = Util.Create("Frame", {
        Size             = UDim2.new(0, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 14,
        Parent           = topBar,
    })
    -- Animate accent line expanding on load
    Util.Tween(topAccent, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {Size = UDim2.new(1, 0, 0, 1)})

    -- Logo / Icon
    local logoFrame = Util.Create("Frame", {
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(0, 8, 0.5, -14),
        BackgroundColor3 = Theme.AccentGlow,
        BorderSizePixel  = 0,
        ZIndex           = 13,
        Parent           = topBar,
    })
    Util.MakeCorner(6, logoFrame)
    Util.MakeStroke(1, Theme.AccentDim, 0, logoFrame)

    Util.Create("TextLabel", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = Icons.Logo,
        TextColor3             = Theme.Accent,
        TextSize               = 14,
        Font                   = Enum.Font.GothamBold,
        ZIndex                 = 14,
        Parent                 = logoFrame,
    })

    -- Title text
    Util.Create("TextLabel", {
        Size                   = UDim2.new(0, 200, 1, 0),
        Position               = UDim2.new(0, 44, 0, 0),
        BackgroundTransparency = 1,
        Text                   = title,
        TextColor3             = Theme.TextPrimary,
        TextSize               = 13,
        Font                   = Enum.Font.GothamBold,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 13,
        Parent                 = topBar,
    })

    -- Subtitle / key hint
    Util.Create("TextLabel", {
        Size                   = UDim2.new(0, 140, 1, 0),
        Position               = UDim2.new(0, 44, 0, 0),
        BackgroundTransparency = 1,
        Text                   = "TOGGLE: " .. tostring(toggleKey.Name):upper(),
        TextColor3             = Theme.TextMuted,
        TextSize               = 10,
        Font                   = Enum.Font.GothamMedium,
        TextXAlignment         = Enum.TextXAlignment.Left,
        AnchorPoint            = Vector2.new(0, 0),
        Position               = UDim2.new(0, 44, 0.55, 0),
        ZIndex                 = 13,
        Parent                 = topBar,
    })

    -- ── Window Control Buttons ──────────────────────────────
    local function makeControlBtn(label, xOffset, normalBg, hoverBg, pressedBg)
        local btn = Util.Create("TextButton", {
            Size             = UDim2.new(0, 26, 0, 26),
            Position         = UDim2.new(1, xOffset, 0.5, -13),
            BackgroundColor3 = normalBg,
            Text             = "",
            AutoButtonColor  = false,
            BorderSizePixel  = 0,
            ZIndex           = 14,
            Parent           = topBar,
        })
        Util.MakeCorner(6, btn)
        Util.Create("TextLabel", {
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                   = label,
            TextColor3             = Theme.TextSecondary,
            TextSize               = 14,
            Font                   = Enum.Font.GothamBold,
            ZIndex                 = 15,
            Parent                 = btn,
        })
        btn.MouseEnter:Connect(function()
            Util.Tween(btn, Theme.TweenFast, {BackgroundColor3 = hoverBg})
            Util.Tween(btn:FindFirstChildOfClass("TextLabel"), Theme.TweenFast,
                {TextColor3 = Theme.TextPrimary})
        end)
        btn.MouseLeave:Connect(function()
            Util.Tween(btn, Theme.TweenFast, {BackgroundColor3 = normalBg})
            Util.Tween(btn:FindFirstChildOfClass("TextLabel"), Theme.TweenFast,
                {TextColor3 = Theme.TextSecondary})
        end)
        btn.MouseButton1Down:Connect(function()
            Util.Tween(btn, Theme.TweenFast, {BackgroundColor3 = pressedBg})
        end)
        btn.MouseButton1Up:Connect(function()
            Util.Tween(btn, Theme.TweenFast, {BackgroundColor3 = hoverBg})
        end)
        return btn
    end

    local closeBtn    = makeControlBtn(Icons.Close,    -8,  Theme.SurfaceLight,
                            Color3.fromRGB(160, 30, 40),  Color3.fromRGB(200, 50, 60))
    local minimizeBtn = makeControlBtn(Icons.Minimize, -40, Theme.SurfaceLight,
                            Theme.SurfaceLighter,         Theme.BorderBright)

    -- ── BODY (holds tab nav + content) ──────────────────────
    local bodyFrame = Util.Create("Frame", {
        Name             = "Body",
        Size             = UDim2.new(1, 0, 1, -38),
        Position         = UDim2.new(0, 0, 0, 38),
        BackgroundTransparency = 1,
        ZIndex           = 11,
        Parent           = winFrame,
    })

    -- ── LEFT TAB NAV ─────────────────────────────────────────
    local tabNav = Util.Create("Frame", {
        Name             = "TabNav",
        Size             = UDim2.new(0, 130, 1, 0),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 12,
        Parent           = bodyFrame,
    })

    -- Right border of tab nav
    Util.Create("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel  = 0,
        ZIndex           = 13,
        Parent           = tabNav,
    })

    -- Tab nav scroll container
    local tabNavScroll = Util.Create("ScrollingFrame", {
        Name                  = "NavScroll",
        Size                  = UDim2.new(1, 0, 1, -10),
        Position              = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        ScrollBarThickness    = 0,
        BorderSizePixel       = 0,
        ZIndex                = 13,
        Parent                = tabNav,
    })
    Util.MakePadding(0, 0, 8, 8, tabNavScroll)
    local tabNavList = Util.MakeList(4, tabNavScroll)
    Util.AutoCanvas(tabNavScroll, tabNavList)

    -- ── CONTENT AREA ────────────────────────────────────────
    local contentArea = Util.Create("Frame", {
        Name             = "ContentArea",
        Size             = UDim2.new(1, -130, 1, 0),
        Position         = UDim2.new(0, 130, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex           = 12,
        Parent           = bodyFrame,
    })

    -- ── DRAG LOGIC ───────────────────────────────────────────
    do
        local dragging, dragStart, startPos
        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging  = true
                dragStart = input.Position
                startPos  = winFrame.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta  = input.Position - dragStart
                local newPos = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
                winFrame.Position   = newPos
                shadowFrame.Position = UDim2.new(
                    newPos.X.Scale, newPos.X.Offset - 15,
                    newPos.Y.Scale, newPos.Y.Offset - 15
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    -- ── TOGGLE VISIBILITY ────────────────────────────────────
    local visible = true
    local minimized = false

    local function setVisible(state)
        visible = state
        winFrame.Visible   = state
        shadowFrame.Visible = state
        if self._Blur then
            Util.Tween(self._Blur, Theme.TweenMed, {Size = state and 4 or 0})
        end
    end

    -- Open animation (scale from center)
    winFrame.Size     = UDim2.new(0, 0, 0, 0)
    winFrame.Position = UDim2.new(position.X.Scale,
                            position.X.Offset + size.X.Offset/2,
                            position.Y.Scale,
                            position.Y.Offset + size.Y.Offset/2)
    task.spawn(function()
        task.wait(0.05)
        Util.Tween(winFrame, Theme.TweenBounce, {
            Size     = size,
            Position = position,
        })
        Util.Tween(shadowFrame, Theme.TweenBounce, {
            Size     = UDim2.new(size.X.Scale, size.X.Offset + 30,
                                  size.Y.Scale, size.Y.Offset + 30),
            Position = UDim2.new(position.X.Scale, position.X.Offset - 15,
                                  position.Y.Scale, position.Y.Offset - 15),
        })
        if self._Blur then
            Util.Tween(self._Blur, Theme.TweenMed, {Size = 4})
        end
    end)

    -- Minimize
    local originalSize = size
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Util.Tween(winFrame,   Theme.TweenSlow, {Size = UDim2.new(0, size.X.Offset, 0, 38)})
            Util.Tween(shadowFrame, Theme.TweenSlow, {Size = UDim2.new(0, size.X.Offset + 30, 0, 68)})
            Util.Tween(bodyFrame, Theme.TweenFast, {BackgroundTransparency = 1})
        else
            Util.Tween(winFrame,   Theme.TweenBounce, {Size = size})
            Util.Tween(shadowFrame, Theme.TweenBounce, {
                Size = UDim2.new(size.X.Scale, size.X.Offset + 30,
                                  size.Y.Scale, size.Y.Offset + 30)
            })
        end
    end)

    -- Close
    closeBtn.MouseButton1Click:Connect(function()
        Util.Tween(winFrame, Theme.TweenMed, {
            Size     = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(position.X.Scale, position.X.Offset + size.X.Offset/2,
                                  position.Y.Scale, position.Y.Offset + size.Y.Offset/2),
            BackgroundTransparency = 1,
        })
        Util.Tween(shadowFrame, Theme.TweenMed, {BackgroundTransparency = 1})
        if self._Blur then
            Util.Tween(self._Blur, Theme.TweenMed, {Size = 0})
        end
        task.delay(0.25, function() winFrame:Destroy() shadowFrame:Destroy() end)
    end)

    -- Toggle key
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == toggleKey then
            setVisible(not visible)
        end
    end)

    -- ── WINDOW OBJECT ────────────────────────────────────────
    local Window    = {}
    Window._Tabs    = {}
    Window._TabBtns = {}
    Window._Active  = nil
    Window._Nav     = tabNavScroll
    Window._Content = contentArea

    function Window:CreateTab(name, icon)
        local tab       = {}
        tab._Sections   = {}
        tab._Name       = name

        -- Tab button in left nav
        local tabBtn = Util.Create("TextButton", {
            Name             = "Tab_" .. name,
            Size             = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.SurfaceLight,
            BackgroundTransparency = 1,
            Text             = "",
            AutoButtonColor  = false,
            BorderSizePixel  = 0,
            ZIndex           = 14,
            Parent           = tabNavScroll,
        })
        Util.MakeCorner(6, tabBtn)

        -- Active indicator bar
        local indicator = Util.Create("Frame", {
            Size             = UDim2.new(0, 2, 0.6, 0),
            Position         = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ZIndex           = 15,
            Parent           = tabBtn,
        })
        Util.MakeCorner(2, indicator)

        -- Icon glyph (optional, uses first letter if none provided)
        local iconGlyph = icon or name:sub(1, 1):upper()
        local iconLbl = Util.Create("TextLabel", {
            Size                   = UDim2.new(0, 20, 0, 20),
            Position               = UDim2.new(0, 10, 0.5, -10),
            BackgroundColor3       = Theme.SurfaceLighter,
            Text                   = iconGlyph,
            TextColor3             = Theme.TextMuted,
            TextSize               = 11,
            Font                   = Enum.Font.GothamBold,
            ZIndex                 = 15,
            BorderSizePixel        = 0,
            Parent                 = tabBtn,
        })
        Util.MakeCorner(4, iconLbl)

        Util.Create("TextLabel", {
            Size                   = UDim2.new(1, -38, 1, 0),
            Position               = UDim2.new(0, 36, 0, 0),
            BackgroundTransparency = 1,
            Text                   = name,
            TextColor3             = Theme.TextSecondary,
            TextSize               = 12,
            Font                   = Enum.Font.GothamMedium,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 15,
            Parent                 = tabBtn,
        })

        -- Tab content page
        local page = Util.Create("ScrollingFrame", {
            Name                  = "Page_" .. name,
            Size                  = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness    = 3,
            ScrollBarImageColor3  = Theme.BorderBright,
            BorderSizePixel       = 0,
            Visible               = false,
            ZIndex                = 13,
            Parent                = contentArea,
        })
        Util.MakePadding(12, 12, 10, 10, page)
        local pageList = Util.MakeList(8, page)
        Util.AutoCanvas(page, pageList)

        -- Activate this tab
        local function activate()
            -- Deactivate others
            for _, other in pairs(Window._Tabs) do
                if other._Page then
                    other._Page.Visible = false
                end
            end
            for _, btn in pairs(Window._TabBtns) do
                if btn._Btn then
                    Util.Tween(btn._Btn, Theme.TweenFast, {BackgroundTransparency = 1})
                    Util.Tween(btn._Icon, Theme.TweenFast,
                        {BackgroundColor3 = Theme.SurfaceLighter, TextColor3 = Theme.TextMuted})
                    Util.Tween(btn._Label, Theme.TweenFast, {TextColor3 = Theme.TextSecondary})
                    Util.Tween(btn._Indicator, Theme.TweenFast, {BackgroundTransparency = 1})
                end
            end
            -- Activate this
            page.Visible = true
            Util.Tween(tabBtn,  Theme.TweenFast, {BackgroundTransparency = 0.85})
            Util.Tween(iconLbl, Theme.TweenFast,
                {BackgroundColor3 = Theme.AccentGlow, TextColor3 = Theme.Accent})
            Util.Tween(tabBtn:FindFirstChild("TextLabel", true), Theme.TweenFast,
                -- TextLabel is actually a child but we ref via our stored refs below
                nil)
            Util.Tween(indicator, Theme.TweenFast, {BackgroundTransparency = 0})
            Window._Active = tab
        end

        -- Store refs for deactivation
        local btnRef = {
            _Btn       = tabBtn,
            _Icon      = iconLbl,
            _Label     = tabBtn:FindFirstChildWhichIsA("TextLabel"),
            _Indicator = indicator,
        }
        table.insert(Window._TabBtns, btnRef)

        -- Fix: store label ref properly
        for _, c in ipairs(tabBtn:GetChildren()) do
            if c:IsA("TextLabel") and c.Text == name then
                btnRef._Label = c
            end
        end

        tabBtn.MouseButton1Click:Connect(activate)
        tabBtn.MouseEnter:Connect(function()
            if Window._Active ~= tab then
                Util.Tween(tabBtn, Theme.TweenFast, {BackgroundTransparency = 0.92})
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if Window._Active ~= tab then
                Util.Tween(tabBtn, Theme.TweenFast, {BackgroundTransparency = 1})
            end
        end)

        tab._Page    = page
        tab._List    = pageList
        tab._Activate = activate
        table.insert(Window._Tabs, tab)

        -- Auto-activate first tab
        if #Window._Tabs == 1 then
            task.spawn(activate)
        end

        -- ── SECTION CREATOR ──────────────────────────────────
        function tab:CreateSection(sectionName)
            local section = {}

            -- Section wrapper
            local secFrame = Util.Create("Frame", {
                Name             = "Section_" .. sectionName,
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel  = 0,
                ZIndex           = 14,
                Parent           = page,
            })
            Util.MakeCorner(8, secFrame)
            Util.MakeStroke(1, Theme.Border, 0, secFrame)
            Util.MakePadding(10, 10, 10, 10, secFrame)

            local secList = Util.MakeList(6, secFrame)
            secList.Padding = UDim.new(0, 6)

            -- Section header
            local headerFrame = Util.Create("Frame", {
                Name             = "Header",
                Size             = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                ZIndex           = 15,
                Parent           = secFrame,
            })

            Util.Create("TextLabel", {
                Size                   = UDim2.new(1, -10, 1, 0),
                BackgroundTransparency = 1,
                Text                   = sectionName:upper(),
                TextColor3             = Theme.TextMuted,
                TextSize               = 10,
                Font                   = Enum.Font.GothamBold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                LetterSpacing          = 2,
                ZIndex                 = 16,
                Parent                 = headerFrame,
            })

            -- Thin separator under header
            Util.Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel  = 0,
                ZIndex           = 15,
                Parent           = headerFrame,
            })

            section._Frame = secFrame
            section._List  = secList

            -- ── COMPONENT: Separator ──────────────────────
            function section:CreateSeparator()
                Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = Theme.Border,
                    BorderSizePixel  = 0,
                    ZIndex           = 15,
                    Parent           = secFrame,
                })
            end

            -- ── COMPONENT: TextLabel ──────────────────────
            function section:CreateLabel(config)
                config = config or {}
                local lbl = Util.Create("TextLabel", {
                    Size                   = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Text                   = config.Text or "Label",
                    TextColor3             = config.Color or Theme.TextSecondary,
                    TextSize               = config.Size or 12,
                    Font                   = Enum.Font.Gotham,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextWrapped            = true,
                    AutomaticSize          = Enum.AutomaticSize.Y,
                    ZIndex                 = 15,
                    Parent                 = secFrame,
                })
                local api = {}
                function api:Set(text)
                    lbl.Text = text
                end
                return api
            end

            -- ── COMPONENT: Button ─────────────────────────
            function section:CreateButton(config)
                config = config or {}
                local name_     = config.Name     or "Button"
                local callback  = config.Callback or function() end
                local desc      = config.Description

                local btnFrame = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = Theme.SurfaceLight,
                    BorderSizePixel  = 0,
                    ZIndex           = 15,
                    Parent           = secFrame,
                })
                Util.MakeCorner(6, btnFrame)
                Util.MakeStroke(1, Theme.Border, 0, btnFrame)

                -- Glow line on left
                local gline = Util.Create("Frame", {
                    Size             = UDim2.new(0, 2, 0.6, 0),
                    Position         = UDim2.new(0, 0, 0.2, 0),
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 1,
                    BorderSizePixel  = 0,
                    ZIndex           = 16,
                    Parent           = btnFrame,
                })
                Util.MakeCorner(2, gline)

                Util.Create("TextLabel", {
                    Size                   = UDim2.new(1, -20, 0, 36),
                    Position               = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = name_,
                    TextColor3             = Theme.TextPrimary,
                    TextSize               = 12,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ZIndex                 = 16,
                    Parent                 = btnFrame,
                })

                -- Chevron
                Util.Create("TextLabel", {
                    Size                   = UDim2.new(0, 20, 1, 0),
                    Position               = UDim2.new(1, -24, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = Icons.Arrow,
                    TextColor3             = Theme.TextMuted,
                    TextSize               = 14,
                    Font                   = Enum.Font.GothamBold,
                    ZIndex                 = 16,
                    Parent                 = btnFrame,
                })

                local hitbox = Util.Create("TextButton", {
                    Size                   = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                   = "",
                    ZIndex                 = 17,
                    Parent                 = btnFrame,
                })

                hitbox.MouseEnter:Connect(function()
                    Util.Tween(btnFrame, Theme.TweenFast, {BackgroundColor3 = Theme.SurfaceLighter})
                    Util.Tween(gline,    Theme.TweenFast, {BackgroundTransparency = 0})
                end)
                hitbox.MouseLeave:Connect(function()
                    Util.Tween(btnFrame, Theme.TweenFast, {BackgroundColor3 = Theme.SurfaceLight})
                    Util.Tween(gline,    Theme.TweenFast, {BackgroundTransparency = 1})
                end)
                hitbox.MouseButton1Down:Connect(function()
                    Util.Tween(btnFrame, Theme.TweenFast, {BackgroundColor3 = Theme.AccentGlow})
                end)
                hitbox.MouseButton1Up:Connect(function()
                    Util.Tween(btnFrame, Theme.TweenFast, {BackgroundColor3 = Theme.SurfaceLighter})
                end)
                hitbox.MouseButton1Click:Connect(function()
                    local ok, err = pcall(callback)
                    if not ok then warn("[NexusUI] Button callback error: " .. tostring(err)) end
                end)
            end

            -- ── COMPONENT: Toggle ─────────────────────────
            function section:CreateToggle(config)
                config = config or {}
                local name_    = config.Name     or "Toggle"
                local default  = config.Default  or false
                local callback = config.Callback or function() end

                local state = default

                local row = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = Theme.SurfaceLight,
                    BorderSizePixel  = 0,
                    ZIndex           = 15,
                    Parent           = secFrame,
                })
                Util.MakeCorner(6, row)
                Util.MakeStroke(1, Theme.Border, 0, row)

                Util.Create("TextLabel", {
                    Size                   = UDim2.new(1, -60, 1, 0),
                    Position               = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = name_,
                    TextColor3             = Theme.TextPrimary,
                    TextSize               = 12,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ZIndex                 = 16,
                    Parent                 = row,
                })

                -- Toggle pill
                local pill = Util.Create("Frame", {
                    Size             = UDim2.new(0, 40, 0, 20),
                    Position         = UDim2.new(1, -50, 0.5, -10),
                    BackgroundColor3 = state and Theme.Accent or Theme.SurfaceLighter,
                    BorderSizePixel  = 0,
                    ZIndex           = 16,
                    Parent           = row,
                })
                Util.MakeCorner(10, pill)
                Util.MakeStroke(1, state and Theme.AccentDim or Theme.Border, 0, pill)

                local knob = Util.Create("Frame", {
                    Size             = UDim2.new(0, 14, 0, 14),
                    Position         = state and UDim2.new(1, -17, 0.5, -7)
                                              or UDim2.new(0, 3, 0.5, -7),
                    BackgroundColor3 = Theme.TextPrimary,
                    BorderSizePixel  = 0,
                    ZIndex           = 17,
                    Parent           = pill,
                })
                Util.MakeCorner(10, knob)

                local function refreshToggle()
                    Util.Tween(pill, Theme.TweenMed,
                        {BackgroundColor3 = state and Theme.Accent or Theme.SurfaceLighter})
                    pill:FindFirstChildOfClass("UIStroke").Color =
                        state and Theme.AccentDim or Theme.Border
                    Util.Tween(knob, Theme.TweenMed,
                        {Position = state and UDim2.new(1, -17, 0.5, -7)
                                           or UDim2.new(0, 3, 0.5, -7)})
                end

                local hitbox = Util.Create("TextButton", {
                    Size                   = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                   = "",
                    ZIndex                 = 18,
                    Parent                 = row,
                })
                hitbox.MouseButton1Click:Connect(function()
                    state = not state
                    refreshToggle()
                    local ok, err = pcall(callback, state)
                    if not ok then warn("[NexusUI] Toggle callback error: " .. tostring(err)) end
                end)
                hitbox.MouseEnter:Connect(function()
                    Util.Tween(row, Theme.TweenFast, {BackgroundColor3 = Theme.SurfaceLighter})
                end)
                hitbox.MouseLeave:Connect(function()
                    Util.Tween(row, Theme.TweenFast, {BackgroundColor3 = Theme.SurfaceLight})
                end)

                local api = {}
                function api:Set(val)
                    state = val
                    refreshToggle()
                end
                function api:Get() return state end
                return api
            end

            -- ── COMPONENT: Slider ─────────────────────────
            function section:CreateSlider(config)
                config = config or {}
                local name_    = config.Name     or "Slider"
                local min      = config.Min      or 0
                local max      = config.Max      or 100
                local default  = config.Default  or min
                local suffix   = config.Suffix   or ""
                local callback = config.Callback or function() end
                local decimals = config.Decimals or 0

                local value = math.clamp(default, min, max)

                local sliderFrame = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 52),
                    BackgroundColor3 = Theme.SurfaceLight,
                    BorderSizePixel  = 0,
                    ZIndex           = 15,
                    Parent           = secFrame,
                })
                Util.MakeCorner(6, sliderFrame)
                Util.MakeStroke(1, Theme.Border, 0, sliderFrame)

                local nameLbl = Util.Create("TextLabel", {
                    Size                   = UDim2.new(0.6, 0, 0, 22),
                    Position               = UDim2.new(0, 12, 0, 6),
                    BackgroundTransparency = 1,
                    Text                   = name_,
                    TextColor3             = Theme.TextPrimary,
                    TextSize               = 12,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ZIndex                 = 16,
                    Parent                 = sliderFrame,
                })

                local valLbl = Util.Create("TextLabel", {
                    Size                   = UDim2.new(0.4, -12, 0, 22),
                    Position               = UDim2.new(0.6, 0, 0, 6),
                    BackgroundTransparency = 1,
                    Text                   = tostring(value) .. suffix,
                    TextColor3             = Theme.Accent,
                    TextSize               = 12,
                    Font                   = Enum.Font.GothamBold,
                    TextXAlignment         = Enum.TextXAlignment.Right,
                    ZIndex                 = 16,
                    Parent                 = sliderFrame,
                })

                -- Track background
                local trackBg = Util.Create("Frame", {
                    Size             = UDim2.new(1, -24, 0, 4),
                    Position         = UDim2.new(0, 12, 0, 36),
                    BackgroundColor3 = Theme.SurfaceLighter,
                    BorderSizePixel  = 0,
                    ZIndex           = 16,
                    Parent           = sliderFrame,
                })
                Util.MakeCorner(4, trackBg)

                -- Filled portion
                local fillRatio = (value - min) / (max - min)
                local trackFill = Util.Create("Frame", {
                    Size             = UDim2.new(fillRatio, 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel  = 0,
                    ZIndex           = 17,
                    Parent           = trackBg,
                })
                Util.MakeCorner(4, trackFill)

                -- Knob
                local knob = Util.Create("Frame", {
                    Size             = UDim2.new(0, 12, 0, 12),
                    Position         = UDim2.new(fillRatio, -6, 0.5, -6),
                    BackgroundColor3 = Theme.TextPrimary,
                    BorderSizePixel  = 0,
                    ZIndex           = 18,
                    Parent           = trackBg,
                })
                Util.MakeCorner(10, knob)

                -- Glow on knob
                local knobGlow = Util.Create("Frame", {
                    Size             = UDim2.new(0, 18, 0, 18),
                    Position         = UDim2.new(fillRatio, -9, 0.5, -9),
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 0.7,
                    BorderSizePixel  = 0,
                    ZIndex           = 17,
                    Parent           = trackBg,
                })
                Util.MakeCorner(10, knobGlow)

                local sliding = false

                local function updateSlider(inputX)
                    local abs  = trackBg.AbsolutePosition
                    local size = trackBg.AbsoluteSize
                    local ratio = math.clamp((inputX - abs.X) / size.X, 0, 1)
                    local raw   = min + (max - min) * ratio
                    local fmt   = 10^decimals
                    value = math.floor(raw * fmt + 0.5) / fmt

                    local r = (value - min) / (max - min)
                    Util.Tween(trackFill, Theme.TweenFast, {Size = UDim2.new(r, 0, 1, 0)})
                    Util.Tween(knob,      Theme.TweenFast, {Position = UDim2.new(r, -6, 0.5, -6)})
                    Util.Tween(knobGlow,  Theme.TweenFast, {Position = UDim2.new(r, -9, 0.5, -9)})
                    valLbl.Text = tostring(value) .. suffix
                    local ok, err = pcall(callback, value)
                    if not ok then warn("[NexusUI] Slider callback error: " .. tostring(err)) end
                end

                local hitbox = Util.Create("TextButton", {
                    Size                   = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                   = "",
                    ZIndex                 = 19,
                    Parent                 = trackBg,
                })
                hitbox.MouseButton1Down:Connect(function(x, y)
                    sliding = true
                    Util.Tween(knob, Theme.TweenFast, {
                        Size     = UDim2.new(0, 14, 0, 14),
                        Position = UDim2.new((value - min)/(max - min), -7, 0.5, -7)
                    })
                    updateSlider(x)
                end)
                hitbox.MouseButton1Up:Connect(function()
                    sliding = false
                    Util.Tween(knob, Theme.TweenFast, {
                        Size     = UDim2.new(0, 12, 0, 12),
                        Position = UDim2.new((value - min)/(max - min), -6, 0.5, -6)
                    })
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                        Util.Tween(knob, Theme.TweenFast, {
                            Size     = UDim2.new(0, 12, 0, 12),
                            Position = UDim2.new((value - min)/(max - min), -6, 0.5, -6)
                        })
                    end
                end)

                local api = {}
                function api:Set(val)
                    value = math.clamp(val, min, max)
                    local r = (value - min) / (max - min)
                    trackFill.Size     = UDim2.new(r, 0, 1, 0)
                    knob.Position      = UDim2.new(r, -6, 0.5, -6)
                    knobGlow.Position  = UDim2.new(r, -9, 0.5, -9)
                    valLbl.Text = tostring(value) .. suffix
                end
                function api:Get() return value end
                return api
            end

            -- ── COMPONENT: Dropdown ───────────────────────
            function section:CreateDropdown(config)
                config = config or {}
                local name_    = config.Name     or "Dropdown"
                local options  = config.Options  or {}
                local default  = config.Default  or (options[1] or "")
                local callback = config.Callback or function() end

                local selected = default
                local open     = false

                local dropWrapper = Util.Create("Frame", {
                    Name             = "DropWrapper",
                    Size             = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    AutomaticSize    = Enum.AutomaticSize.None,
                    ZIndex           = 20,
                    ClipsDescendants = false,
                    Parent           = secFrame,
                })

                local dropRow = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = Theme.SurfaceLight,
                    BorderSizePixel  = 0,
                    ZIndex           = 21,
                    Parent           = dropWrapper,
                })
                Util.MakeCorner(6, dropRow)
                Util.MakeStroke(1, Theme.Border, 0, dropRow)

                Util.Create("TextLabel", {
                    Size                   = UDim2.new(0.5, 0, 1, 0),
                    Position               = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = name_,
                    TextColor3             = Theme.TextPrimary,
                    TextSize               = 12,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ZIndex                 = 22,
                    Parent                 = dropRow,
                })

                local selectedLbl = Util.Create("TextLabel", {
                    Size                   = UDim2.new(0.5, -36, 1, 0),
                    Position               = UDim2.new(0.5, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = selected,
                    TextColor3             = Theme.Accent,
                    TextSize               = 12,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Right,
                    ZIndex                 = 22,
                    Parent                 = dropRow,
                })

                local arrowLbl = Util.Create("TextLabel", {
                    Size                   = UDim2.new(0, 20, 1, 0),
                    Position               = UDim2.new(1, -24, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = "▾",
                    TextColor3             = Theme.TextMuted,
                    TextSize               = 12,
                    Font                   = Enum.Font.GothamBold,
                    ZIndex                 = 22,
                    Parent                 = dropRow,
                })

                -- Dropdown list panel
                local panel = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    Position         = UDim2.new(0, 0, 1, 4),
                    BackgroundColor3 = Theme.Surface,
                    BorderSizePixel  = 0,
                    ClipsDescendants = true,
                    ZIndex           = 25,
                    Visible          = false,
                    Parent           = dropRow,
                })
                Util.MakeCorner(6, panel)
                Util.MakeStroke(1, Theme.Border, 0, panel)
                Util.MakePadding(4, 4, 4, 4, panel)
                local panelList = Util.MakeList(2, panel)

                -- Build option items
                local targetH = 8 + #options * 28 + (#options - 1) * 2

                for _, opt in ipairs(options) do
                    local item = Util.Create("TextButton", {
                        Size             = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = Theme.SurfaceLight,
                        BackgroundTransparency = 1,
                        Text             = "",
                        AutoButtonColor  = false,
                        BorderSizePixel  = 0,
                        ZIndex           = 26,
                        Parent           = panel,
                    })
                    Util.MakeCorner(5, item)
                    local lbl = Util.Create("TextLabel", {
                        Size                   = UDim2.new(1, -10, 1, 0),
                        Position               = UDim2.new(0, 8, 0, 0),
                        BackgroundTransparency = 1,
                        Text                   = opt,
                        TextColor3             = opt == selected and Theme.Accent or Theme.TextSecondary,
                        TextSize               = 12,
                        Font                   = Enum.Font.GothamMedium,
                        TextXAlignment         = Enum.TextXAlignment.Left,
                        ZIndex                 = 27,
                        Parent                 = item,
                    })
                    item.MouseEnter:Connect(function()
                        Util.Tween(item, Theme.TweenFast, {BackgroundTransparency = 0})
                    end)
                    item.MouseLeave:Connect(function()
                        Util.Tween(item, Theme.TweenFast, {BackgroundTransparency = 1})
                    end)
                    item.MouseButton1Click:Connect(function()
                        selected         = opt
                        selectedLbl.Text = opt
                        -- Update all option colors
                        for _, c in ipairs(panel:GetChildren()) do
                            if c:IsA("TextButton") then
                                local l = c:FindFirstChildWhichIsA("TextLabel")
                                if l then
                                    l.TextColor3 = l.Text == opt and Theme.Accent or Theme.TextSecondary
                                end
                            end
                        end
                        -- Close
                        open = false
                        Util.Tween(panel, Theme.TweenMed, {Size = UDim2.new(1, 0, 0, 0)})
                        Util.Tween(arrowLbl, Theme.TweenFast, {Rotation = 0})
                        task.delay(0.25, function() panel.Visible = false end)
                        dropWrapper.Size = UDim2.new(1, 0, 0, 36)
                        local ok, err = pcall(callback, selected)
                        if not ok then warn("[NexusUI] Dropdown callback error: " .. tostring(err)) end
                    end)
                end

                local hitbox = Util.Create("TextButton", {
                    Size                   = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                   = "",
                    ZIndex                 = 23,
                    Parent                 = dropRow,
                })
                hitbox.MouseEnter:Connect(function()
                    Util.Tween(dropRow, Theme.TweenFast, {BackgroundColor3 = Theme.SurfaceLighter})
                end)
                hitbox.MouseLeave:Connect(function()
                    Util.Tween(dropRow, Theme.TweenFast, {BackgroundColor3 = Theme.SurfaceLight})
                end)
                hitbox.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        panel.Visible = true
                        panel.Size    = UDim2.new(1, 0, 0, 0)
                        Util.Tween(panel, Theme.TweenMed,
                            {Size = UDim2.new(1, 0, 0, targetH)})
                        Util.Tween(arrowLbl, Theme.TweenFast, {Rotation = 180})
                        dropWrapper.Size = UDim2.new(1, 0, 0, 36 + targetH + 8)
                    else
                        Util.Tween(panel, Theme.TweenMed, {Size = UDim2.new(1, 0, 0, 0)})
                        Util.Tween(arrowLbl, Theme.TweenFast, {Rotation = 0})
                        task.delay(0.25, function() panel.Visible = false end)
                        dropWrapper.Size = UDim2.new(1, 0, 0, 36)
                    end
                end)

                local api = {}
                function api:Set(val)
                    selected = val
                    selectedLbl.Text = val
                end
                function api:Get() return selected end
                return api
            end

            -- ── COMPONENT: Textbox ────────────────────────
            function section:CreateTextbox(config)
                config = config or {}
                local name_       = config.Name        or "Textbox"
                local placeholder = config.Placeholder or "Enter value..."
                local default     = config.Default     or ""
                local callback    = config.Callback    or function() end

                local tbFrame = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 52),
                    BackgroundColor3 = Theme.SurfaceLight,
                    BorderSizePixel  = 0,
                    ZIndex           = 15,
                    Parent           = secFrame,
                })
                Util.MakeCorner(6, tbFrame)
                Util.MakeStroke(1, Theme.Border, 0, tbFrame)

                Util.Create("TextLabel", {
                    Size                   = UDim2.new(1, -12, 0, 22),
                    Position               = UDim2.new(0, 12, 0, 4),
                    BackgroundTransparency = 1,
                    Text                   = name_,
                    TextColor3             = Theme.TextPrimary,
                    TextSize               = 12,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ZIndex                 = 16,
                    Parent                 = tbFrame,
                })

                local inputBg = Util.Create("Frame", {
                    Size             = UDim2.new(1, -24, 0, 22),
                    Position         = UDim2.new(0, 12, 0, 26),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel  = 0,
                    ZIndex           = 16,
                    Parent           = tbFrame,
                })
                Util.MakeCorner(5, inputBg)
                local inputStroke = Util.MakeStroke(1, Theme.Border, 0, inputBg)

                local input = Util.Create("TextBox", {
                    Size                   = UDim2.new(1, -10, 1, 0),
                    Position               = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = default,
                    PlaceholderText        = placeholder,
                    PlaceholderColor3      = Theme.TextMuted,
                    TextColor3             = Theme.TextPrimary,
                    TextSize               = 11,
                    Font                   = Enum.Font.Gotham,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ClearTextOnFocus       = false,
                    ZIndex                 = 17,
                    Parent                 = inputBg,
                })

                input.Focused:Connect(function()
                    Util.Tween(inputBg, Theme.TweenFast, {BackgroundColor3 = Theme.SurfaceLight})
                    inputStroke.Color = Theme.Accent
                end)
                input.FocusLost:Connect(function(enterPressed)
                    Util.Tween(inputBg, Theme.TweenFast, {BackgroundColor3 = Theme.Background})
                    inputStroke.Color = Theme.Border
                    if enterPressed then
                        local ok, err = pcall(callback, input.Text)
                        if not ok then warn("[NexusUI] Textbox callback error: " .. tostring(err)) end
                    end
                end)

                local api = {}
                function api:Set(val) input.Text = val end
                function api:Get() return input.Text end
                return api
            end

            -- ── COMPONENT: Keybind ────────────────────────
            function section:CreateKeybind(config)
                config = config or {}
                local name_    = config.Name     or "Keybind"
                local default  = config.Default  or Enum.KeyCode.Unknown
                local callback = config.Callback or function() end

                local currentKey = default
                local listening  = false

                local kbRow = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = Theme.SurfaceLight,
                    BorderSizePixel  = 0,
                    ZIndex           = 15,
                    Parent           = secFrame,
                })
                Util.MakeCorner(6, kbRow)
                Util.MakeStroke(1, Theme.Border, 0, kbRow)

                Util.Create("TextLabel", {
                    Size                   = UDim2.new(0.6, 0, 1, 0),
                    Position               = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = name_,
                    TextColor3             = Theme.TextPrimary,
                    TextSize               = 12,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ZIndex                 = 16,
                    Parent                 = kbRow,
                })

                local keyBadge = Util.Create("Frame", {
                    Size             = UDim2.new(0, 80, 0, 22),
                    Position         = UDim2.new(1, -88, 0.5, -11),
                    BackgroundColor3 = Theme.SurfaceLighter,
                    BorderSizePixel  = 0,
                    ZIndex           = 16,
                    Parent           = kbRow,
                })
                Util.MakeCorner(5, keyBadge)
                Util.MakeStroke(1, Theme.Border, 0, keyBadge)

                local keyLbl = Util.Create("TextLabel", {
                    Size                   = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                   = currentKey == Enum.KeyCode.Unknown and "NONE" or currentKey.Name,
                    TextColor3             = Theme.Accent,
                    TextSize               = 11,
                    Font                   = Enum.Font.GothamBold,
                    ZIndex                 = 17,
                    Parent                 = keyBadge,
                })

                local hitbox = Util.Create("TextButton", {
                    Size                   = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                   = "",
                    ZIndex                 = 18,
                    Parent                 = kbRow,
                })
                hitbox.MouseEnter:Connect(function()
                    Util.Tween(kbRow, Theme.TweenFast, {BackgroundColor3 = Theme.SurfaceLighter})
                end)
                hitbox.MouseLeave:Connect(function()
                    Util.Tween(kbRow, Theme.TweenFast, {BackgroundColor3 = Theme.SurfaceLight})
                end)
                hitbox.MouseButton1Click:Connect(function()
                    listening = true
                    keyLbl.Text      = "..."
                    keyLbl.TextColor3 = Theme.Warning
                    Util.Tween(keyBadge, Theme.TweenFast,
                        {BackgroundColor3 = Theme.AccentGlow})
                    keyBadge:FindFirstChildOfClass("UIStroke").Color = Theme.Accent
                end)

                UserInputService.InputBegan:Connect(function(input, gp)
                    if not gp and listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            listening    = false
                            currentKey   = input.KeyCode
                            keyLbl.Text  = currentKey.Name
                            keyLbl.TextColor3 = Theme.Accent
                            Util.Tween(keyBadge, Theme.TweenFast,
                                {BackgroundColor3 = Theme.SurfaceLighter})
                            keyBadge:FindFirstChildOfClass("UIStroke").Color = Theme.Border
                            local ok, err = pcall(callback, currentKey)
                            if not ok then warn("[NexusUI] Keybind callback error: " .. tostring(err)) end
                        end
                    elseif not gp and input.KeyCode == currentKey then
                        -- fire bound action
                        local ok, err = pcall(callback, currentKey)
                        if not ok then warn("[NexusUI] Keybind fire error: " .. tostring(err)) end
                    end
                end)

                local api = {}
                function api:Set(key)
                    currentKey   = key
                    keyLbl.Text  = key.Name
                end
                function api:Get() return currentKey end
                return api
            end

            -- ── COMPONENT: ColorIndicator ─────────────────
            function section:CreateColorIndicator(config)
                config = config or {}
                local name_  = config.Name  or "Color"
                local color  = config.Color or Color3.fromRGB(80, 220, 255)
                local label  = config.Label or ""

                local ciRow = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = Theme.SurfaceLight,
                    BorderSizePixel  = 0,
                    ZIndex           = 15,
                    Parent           = secFrame,
                })
                Util.MakeCorner(6, ciRow)
                Util.MakeStroke(1, Theme.Border, 0, ciRow)

                Util.Create("TextLabel", {
                    Size                   = UDim2.new(0.6, 0, 1, 0),
                    Position               = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = name_,
                    TextColor3             = Theme.TextPrimary,
                    TextSize               = 12,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ZIndex                 = 16,
                    Parent                 = ciRow,
                })

                local swatch = Util.Create("Frame", {
                    Size             = UDim2.new(0, 22, 0, 22),
                    Position         = UDim2.new(1, -34, 0.5, -11),
                    BackgroundColor3 = color,
                    BorderSizePixel  = 0,
                    ZIndex           = 16,
                    Parent           = ciRow,
                })
                Util.MakeCorner(6, swatch)
                Util.MakeStroke(1, Theme.Border, 0, swatch)

                local hexLbl = Util.Create("TextLabel", {
                    Size                   = UDim2.new(0, 90, 1, 0),
                    Position               = UDim2.new(1, -130, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = label ~= "" and label or
                                             string.format("#%02X%02X%02X",
                                                math.floor(color.R * 255),
                                                math.floor(color.G * 255),
                                                math.floor(color.B * 255)),
                    TextColor3             = Theme.TextSecondary,
                    TextSize               = 11,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Right,
                    ZIndex                 = 16,
                    Parent                 = ciRow,
                })

                local api = {}
                function api:Set(col)
                    swatch.BackgroundColor3 = col
                    hexLbl.Text = string.format("#%02X%02X%02X",
                        math.floor(col.R * 255),
                        math.floor(col.G * 255),
                        math.floor(col.B * 255))
                end
                function api:Get() return swatch.BackgroundColor3 end
                return api
            end

            return section
        end -- CreateSection

        return tab
    end -- CreateTab

    return Window
end -- CreateWindow

-- ─────────────────────────────────────────────────────────────
-- LIBRARY INIT
-- ─────────────────────────────────────────────────────────────
local Library = setmetatable({}, NexusUI)
Library.__index = Library

function Library:CreateWindow(config)
    return NexusUI.CreateWindow(self, config)
end

function Library:Notify(config)
    return NexusUI.Notify(self, config)
end

return Library
