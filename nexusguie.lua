--[[
 ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗  ██╗   ██╗██╗
 ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝  ██║   ██║██║
 ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗  ██║   ██║██║
 ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║  ██║   ██║██║
 ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║  ╚██████╔╝██║
 ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝   ╚═════╝ ╚═╝

 NexusUI v2.0.0 — Improved Roblox UI Library
 • Compact size       • Transparent BG     • Rounded corners
 • Minimize fix       • Loading screen     • Theme changer
 • Improved notifs    • Smooth animations  • KRNL-style polish
--]]

-- ══════════════════════════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════
-- THEME PRESETS
-- ══════════════════════════════════════════════════════════════
local Themes = {

    ["Dark"] = {
        Background      = Color3.fromRGB(12,  12,  16),
        Surface         = Color3.fromRGB(18,  18,  24),
        SurfaceLight    = Color3.fromRGB(24,  24,  32),
        SurfaceLighter  = Color3.fromRGB(32,  32,  44),
        Border          = Color3.fromRGB(42,  42,  58),
        BorderBright    = Color3.fromRGB(65,  65,  88),
        TextPrimary     = Color3.fromRGB(225, 225, 235),
        TextSecondary   = Color3.fromRGB(125, 125, 145),
        TextMuted       = Color3.fromRGB(65,  65,  85),
        Accent          = Color3.fromRGB(80,  220, 255),
        AccentDim       = Color3.fromRGB(40,  110, 130),
        AccentGlow      = Color3.fromRGB(18,  55,  70),
        Success         = Color3.fromRGB(60,  220, 130),
        Warning         = Color3.fromRGB(255, 195, 50),
        Danger          = Color3.fromRGB(255, 70,  80),
        BgTransparency  = 0.25,
        SurfTransparency = 0.15,
    },

    ["Cyber B&W"] = {
        Background      = Color3.fromRGB(6,   6,   6),
        Surface         = Color3.fromRGB(14,  14,  14),
        SurfaceLight    = Color3.fromRGB(22,  22,  22),
        SurfaceLighter  = Color3.fromRGB(32,  32,  32),
        Border          = Color3.fromRGB(50,  50,  50),
        BorderBright    = Color3.fromRGB(90,  90,  90),
        TextPrimary     = Color3.fromRGB(240, 240, 240),
        TextSecondary   = Color3.fromRGB(150, 150, 150),
        TextMuted       = Color3.fromRGB(80,  80,  80),
        Accent          = Color3.fromRGB(220, 220, 220),
        AccentDim       = Color3.fromRGB(120, 120, 120),
        AccentGlow      = Color3.fromRGB(40,  40,  40),
        Success         = Color3.fromRGB(180, 240, 180),
        Warning         = Color3.fromRGB(240, 210, 120),
        Danger          = Color3.fromRGB(240, 100, 100),
        BgTransparency  = 0.2,
        SurfTransparency = 0.1,
    },

    ["KRNL"] = {
        Background      = Color3.fromRGB(20,  20,  28),
        Surface         = Color3.fromRGB(28,  28,  38),
        SurfaceLight    = Color3.fromRGB(36,  36,  50),
        SurfaceLighter  = Color3.fromRGB(46,  46,  64),
        Border          = Color3.fromRGB(55,  55,  76),
        BorderBright    = Color3.fromRGB(80,  80,  110),
        TextPrimary     = Color3.fromRGB(220, 220, 235),
        TextSecondary   = Color3.fromRGB(140, 140, 165),
        TextMuted       = Color3.fromRGB(75,  75,  100),
        Accent          = Color3.fromRGB(138, 100, 255),
        AccentDim       = Color3.fromRGB(80,  55,  160),
        AccentGlow      = Color3.fromRGB(35,  25,  70),
        Success         = Color3.fromRGB(80,  210, 140),
        Warning         = Color3.fromRGB(255, 190, 60),
        Danger          = Color3.fromRGB(255, 75,  85),
        BgTransparency  = 0.2,
        SurfTransparency = 0.12,
    },

    ["Soft Dark"] = {
        Background      = Color3.fromRGB(22,  24,  30),
        Surface         = Color3.fromRGB(30,  33,  42),
        SurfaceLight    = Color3.fromRGB(38,  42,  54),
        SurfaceLighter  = Color3.fromRGB(48,  53,  68),
        Border          = Color3.fromRGB(58,  64,  82),
        BorderBright    = Color3.fromRGB(85,  93,  118),
        TextPrimary     = Color3.fromRGB(215, 218, 230),
        TextSecondary   = Color3.fromRGB(130, 136, 160),
        TextMuted       = Color3.fromRGB(72,  78,  98),
        Accent          = Color3.fromRGB(100, 200, 170),
        AccentDim       = Color3.fromRGB(55,  110, 95),
        AccentGlow      = Color3.fromRGB(25,  50,  45),
        Success         = Color3.fromRGB(90,  215, 145),
        Warning         = Color3.fromRGB(240, 185, 65),
        Danger          = Color3.fromRGB(240, 80,  90),
        BgTransparency  = 0.3,
        SurfTransparency = 0.18,
    },
}

-- Active theme (mutable reference, all UI reads from here)
local T = {}
for k, v in pairs(Themes["Dark"]) do T[k] = v end

-- Tween presets (not theme-dependent)
local TweenFast   = TweenInfo.new(0.12, Enum.EasingStyle.Quad,   Enum.EasingDirection.Out)
local TweenMed    = TweenInfo.new(0.20, Enum.EasingStyle.Quad,   Enum.EasingDirection.Out)
local TweenSlow   = TweenInfo.new(0.38, Enum.EasingStyle.Quint,  Enum.EasingDirection.Out)
local TweenBounce = TweenInfo.new(0.32, Enum.EasingStyle.Back,   Enum.EasingDirection.Out)

-- ══════════════════════════════════════════════════════════════
-- UTILITY
-- ══════════════════════════════════════════════════════════════
local Util = {}

function Util.Tween(obj, info, props)
    if not obj or not obj.Parent then return end
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

function Util.Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

function Util.Corner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

function Util.Stroke(thick, col, trans, p)
    local s = Instance.new("UIStroke")
    s.Thickness       = thick or 1
    s.Color           = col   or T.Border
    s.Transparency    = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

function Util.Pad(t, b, l, r, p)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, t or 0)
    pad.PaddingBottom = UDim.new(0, b or 0)
    pad.PaddingLeft   = UDim.new(0, l or 0)
    pad.PaddingRight  = UDim.new(0, r or 0)
    pad.Parent = p
    return pad
end

function Util.List(spacing, p, dir, ha, va)
    local l = Instance.new("UIListLayout")
    l.Padding             = UDim.new(0, spacing or 5)
    l.FillDirection       = dir or Enum.FillDirection.Vertical
    l.HorizontalAlignment = ha  or Enum.HorizontalAlignment.Left
    l.VerticalAlignment   = va  or Enum.VerticalAlignment.Top
    l.SortOrder           = Enum.SortOrder.LayoutOrder
    l.Parent = p
    return l
end

function Util.AutoCanvas(sf, ll)
    local function upd()
        sf.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 16)
    end
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
    upd()
end

-- Draggable helper for any frame
function Util.MakeDraggable(handle, mover)
    mover = mover or handle
    local drag, start, origin = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; start = i.Position; origin = mover.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - start
            mover.Position = UDim2.new(
                origin.X.Scale, origin.X.Offset + d.X,
                origin.Y.Scale, origin.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- LIBRARY CORE
-- ══════════════════════════════════════════════════════════════
local NexusUI          = {}
NexusUI.__index        = NexusUI
NexusUI._NotifCount    = 0
NexusUI._NotifContainer = nil
NexusUI._ThemeListeners = {}  -- registered frames to re-theme

-- ── Get / Create ScreenGui ──────────────────────────────────
function NexusUI:_GetGui()
    if self._ScreenGui and self._ScreenGui.Parent then
        return self._ScreenGui
    end
    local gui
    local ok = pcall(function()
        gui = Util.Create("ScreenGui", {
            Name           = "NexusUI_v2",
            ResetOnSpawn   = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder   = 999,
            IgnoreGuiInset = true,
            Parent         = CoreGui,
        })
    end)
    if not ok then
        gui = Util.Create("ScreenGui", {
            Name           = "NexusUI_v2",
            ResetOnSpawn   = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder   = 999,
            IgnoreGuiInset = true,
            Parent         = LocalPlayer:WaitForChild("PlayerGui"),
        })
    end
    self._ScreenGui = gui
    return gui
end

-- ══════════════════════════════════════════════════════════════
-- LOADING SCREEN
-- ══════════════════════════════════════════════════════════════
function NexusUI:_ShowLoader(gui, title, onDone)
    local overlay = Util.Create("Frame", {
        Name               = "Loader",
        Size               = UDim2.new(1, 0, 1, 0),
        BackgroundColor3   = Color3.fromRGB(6, 6, 8),
        BackgroundTransparency = 0,
        ZIndex             = 100,
        Parent             = gui,
    })

    -- Centered card
    local card = Util.Create("Frame", {
        Name               = "Card",
        Size               = UDim2.new(0, 220, 0, 130),
        Position           = UDim2.new(0.5, -110, 0.5, -65),
        BackgroundColor3   = T.Surface,
        BackgroundTransparency = 0.1,
        BorderSizePixel    = 0,
        ZIndex             = 101,
        Parent             = overlay,
    })
    Util.Corner(12, card)
    Util.Stroke(1, T.Border, 0, card)

    -- Top accent line on card
    local cardAccent = Util.Create("Frame", {
        Size             = UDim2.new(0, 0, 0, 2),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 102,
        Parent           = card,
    })
    Util.Corner(2, cardAccent)

    -- Logo glyph
    Util.Create("TextLabel", {
        Size                   = UDim2.new(1, 0, 0, 38),
        Position               = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        Text                   = "⬡",
        TextColor3             = T.Accent,
        TextSize               = 28,
        Font                   = Enum.Font.GothamBold,
        ZIndex                 = 102,
        Parent                 = card,
    })

    -- Title
    Util.Create("TextLabel", {
        Size                   = UDim2.new(1, 0, 0, 18),
        Position               = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        Text                   = title or "NexusUI",
        TextColor3             = T.TextPrimary,
        TextSize               = 14,
        Font                   = Enum.Font.GothamBold,
        ZIndex                 = 102,
        Parent                 = card,
    })

    -- Status text
    local statusLbl = Util.Create("TextLabel", {
        Size                   = UDim2.new(1, 0, 0, 14),
        Position               = UDim2.new(0, 0, 0, 72),
        BackgroundTransparency = 1,
        Text                   = "Initializing...",
        TextColor3             = T.TextMuted,
        TextSize               = 10,
        Font                   = Enum.Font.Gotham,
        ZIndex                 = 102,
        Parent                 = card,
    })

    -- Progress track
    local trackBg = Util.Create("Frame", {
        Size             = UDim2.new(1, -28, 0, 3),
        Position         = UDim2.new(0, 14, 1, -14),
        BackgroundColor3 = T.SurfaceLighter,
        BorderSizePixel  = 0,
        ZIndex           = 102,
        Parent           = card,
    })
    Util.Corner(4, trackBg)

    local bar = Util.Create("Frame", {
        Size             = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 103,
        Parent           = trackBg,
    })
    Util.Corner(4, bar)

    -- Animate accent line
    Util.Tween(cardAccent, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {Size = UDim2.new(1, 0, 0, 2)})

    -- Progress sequence
    local steps = {
        {t = 0.0, w = 0.0,  s = "Loading modules..."},
        {t = 0.4, w = 0.35, s = "Building interface..."},
        {t = 0.75,w = 0.65, s = "Applying theme..."},
        {t = 1.1, w = 0.88, s = "Almost ready..."},
        {t = 1.5, w = 1.0,  s = "Done!"},
    }

    task.spawn(function()
        for _, step in ipairs(steps) do
            task.wait(step.t)
            statusLbl.Text = step.s
            Util.Tween(bar, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(step.w, 0, 1, 0)})
        end
        task.wait(0.4)
        -- Fade out overlay
        Util.Tween(overlay, TweenMed, {BackgroundTransparency = 1})
        Util.Tween(card,    TweenMed, {BackgroundTransparency = 1})
        for _, child in ipairs(card:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("Frame") then
                pcall(function()
                    Util.Tween(child, TweenMed, {BackgroundTransparency = 1, TextTransparency = 1})
                end)
            end
        end
        task.wait(0.25)
        overlay:Destroy()
        if onDone then onDone() end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM  (improved)
-- ══════════════════════════════════════════════════════════════
function NexusUI:Notify(cfg)
    cfg = cfg or {}
    local title    = cfg.Title    or "Notice"
    local text     = cfg.Text     or ""
    local duration = cfg.Duration or 4
    local nType    = cfg.Type     or "info"

    local gui = self:_GetGui()
    self._NotifCount = self._NotifCount + 1

    if not self._NotifContainer or not self._NotifContainer.Parent then
        self._NotifContainer = Util.Create("Frame", {
            Name                   = "NotifHolder",
            Size                   = UDim2.new(0, 260, 1, 0),
            Position               = UDim2.new(1, -272, 0, 0),
            BackgroundTransparency = 1,
            ZIndex                 = 200,
            Parent                 = gui,
        })
        local l = Util.List(6, self._NotifContainer)
        l.VerticalAlignment = Enum.VerticalAlignment.Bottom
        Util.Pad(8, 8, 0, 0, self._NotifContainer)
    end

    local accentCol = ({
        info    = T.Accent,
        success = T.Success,
        warning = T.Warning,
        error   = T.Danger,
    })[nType] or T.Accent

    local icons = {
        info = "ℹ", success = "✓", warning = "⚠", error = "✕"
    }

    -- Card
    local card = Util.Create("Frame", {
        Size               = UDim2.new(1, 0, 0, 64),
        BackgroundColor3   = T.Surface,
        BackgroundTransparency = T.SurfTransparency,
        BorderSizePixel    = 0,
        ClipsDescendants   = false,
        ZIndex             = 201,
        Parent             = self._NotifContainer,
    })
    Util.Corner(8, card)
    Util.Stroke(1, T.Border, 0.2, card)

    -- Left accent bar
    local abar = Util.Create("Frame", {
        Size             = UDim2.new(0, 3, 0.7, 0),
        Position         = UDim2.new(0, 0, 0.15, 0),
        BackgroundColor3 = accentCol,
        BorderSizePixel  = 0,
        ZIndex           = 202,
        Parent           = card,
    })
    Util.Corner(3, abar)

    -- Icon badge
    local badge = Util.Create("Frame", {
        Size             = UDim2.new(0, 24, 0, 24),
        Position         = UDim2.new(0, 12, 0.5, -12),
        BackgroundColor3 = accentCol,
        BackgroundTransparency = 0.75,
        BorderSizePixel  = 0,
        ZIndex           = 202,
        Parent           = card,
    })
    Util.Corner(6, badge)
    Util.Create("TextLabel", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = icons[nType] or "ℹ",
        TextColor3             = accentCol,
        TextSize               = 12,
        Font                   = Enum.Font.GothamBold,
        ZIndex                 = 203,
        Parent                 = badge,
    })

    -- Title
    Util.Create("TextLabel", {
        Size                   = UDim2.new(1, -50, 0, 16),
        Position               = UDim2.new(0, 44, 0, 10),
        BackgroundTransparency = 1,
        Text                   = title,
        TextColor3             = T.TextPrimary,
        TextSize               = 12,
        Font                   = Enum.Font.GothamBold,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextTruncate           = Enum.TextTruncate.AtEnd,
        ZIndex                 = 202,
        Parent                 = card,
    })

    -- Body
    Util.Create("TextLabel", {
        Size                   = UDim2.new(1, -50, 0, 26),
        Position               = UDim2.new(0, 44, 0, 28),
        BackgroundTransparency = 1,
        Text                   = text,
        TextColor3             = T.TextSecondary,
        TextSize               = 10,
        Font                   = Enum.Font.Gotham,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
        ZIndex                 = 202,
        Parent                 = card,
    })

    -- Progress bar
    local pbg = Util.Create("Frame", {
        Size             = UDim2.new(1, -6, 0, 2),
        Position         = UDim2.new(0, 3, 1, -4),
        BackgroundColor3 = T.SurfaceLighter,
        BorderSizePixel  = 0,
        ZIndex           = 202,
        Parent           = card,
    })
    Util.Corner(2, pbg)
    local pbar = Util.Create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accentCol,
        BorderSizePixel  = 0,
        ZIndex           = 203,
        Parent           = pbg,
    })
    Util.Corner(2, pbar)

    -- Slide-in from right
    card.Position = UDim2.new(1.1, 0, 0, 0)
    Util.Tween(card, TweenBounce, {Position = UDim2.new(0, 0, 0, 0)})

    -- Progress countdown
    Util.Tween(pbar, TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 1, 0)})

    -- Dismiss on click
    local hitbox = Util.Create("TextButton", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = "",
        ZIndex                 = 210,
        Parent                 = card,
    })
    local function dismiss()
        Util.Tween(card, TweenMed,
            {Position = UDim2.new(1.1, 0, 0, 0), BackgroundTransparency = 1})
        task.delay(0.22, function() pcall(function() card:Destroy() end) end)
    end
    hitbox.MouseButton1Click:Connect(dismiss)
    task.delay(duration, dismiss)
end

-- ══════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ══════════════════════════════════════════════════════════════
function NexusUI:CreateWindow(cfg)
    cfg = cfg or {}
    local title      = cfg.Title      or "NexusUI"
    local toggleKey  = cfg.ToggleKey  or Enum.KeyCode.RightShift
    local themeName  = cfg.Theme      or "Dark"
    local showLoader = cfg.Loader     ~= false  -- default true
    local loaderTitle = cfg.LoaderTitle or title

    -- Apply initial theme
    local tdata = Themes[themeName] or Themes["Dark"]
    for k, v in pairs(tdata) do T[k] = v end

    -- Window constants (compact size)
    local WIN_W  = 480
    local WIN_H  = 350
    local TOPBAR = 32
    local NAVW   = 110

    local gui = self:_GetGui()

    -- ── Shadow ───────────────────────────────────────────────
    local shadow = Util.Create("Frame", {
        Name               = "Shadow",
        Size               = UDim2.new(0, WIN_W + 24, 0, WIN_H + 24),
        Position           = UDim2.new(0.5, -(WIN_W/2) - 12, 0.5, -(WIN_H/2) - 12),
        BackgroundColor3   = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.55,
        BorderSizePixel    = 0,
        ZIndex             = 9,
        Visible            = false,
        Parent             = gui,
    })
    Util.Corner(14, shadow)

    -- ── Main Frame ───────────────────────────────────────────
    local win = Util.Create("Frame", {
        Name               = "NexusWindow",
        Size               = UDim2.new(0, WIN_W, 0, WIN_H),
        Position           = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
        BackgroundColor3   = T.Background,
        BackgroundTransparency = T.BgTransparency,
        BorderSizePixel    = 0,
        ClipsDescendants   = true,
        ZIndex             = 10,
        Visible            = false,
        Parent             = gui,
    })
    Util.Corner(10, win)
    Util.Stroke(1, T.Border, 0.3, win)

    -- ── TOP BAR ──────────────────────────────────────────────
    local topbar = Util.Create("Frame", {
        Name             = "TopBar",
        Size             = UDim2.new(1, 0, 0, TOPBAR),
        BackgroundColor3 = T.Surface,
        BackgroundTransparency = T.SurfTransparency,
        BorderSizePixel  = 0,
        ZIndex           = 12,
        Parent           = win,
    })
    Util.Corner(10, topbar)  -- only top rounded via clipping

    -- Bottom border of topbar
    Util.Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border,
        BackgroundTransparency = 0.4,
        BorderSizePixel  = 0,
        ZIndex           = 13,
        Parent           = topbar,
    })

    -- Animated top accent line
    local topAccent = Util.Create("Frame", {
        Size             = UDim2.new(0, 0, 0, 2),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 14,
        Parent           = topbar,
    })
    Util.Corner(2, topAccent)

    -- Logo icon (hexagon glyph in a badge)
    local logoBadge = Util.Create("Frame", {
        Size             = UDim2.new(0, 22, 0, 22),
        Position         = UDim2.new(0, 7, 0.5, -11),
        BackgroundColor3 = T.AccentGlow,
        BorderSizePixel  = 0,
        ZIndex           = 13,
        Parent           = topbar,
    })
    Util.Corner(6, logoBadge)
    Util.Stroke(1, T.AccentDim, 0, logoBadge)
    Util.Create("TextLabel", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = "⬡",
        TextColor3             = T.Accent,
        TextSize               = 12,
        Font                   = Enum.Font.GothamBold,
        ZIndex                 = 14,
        Parent                 = logoBadge,
    })

    -- Title
    local titleLbl = Util.Create("TextLabel", {
        Size                   = UDim2.new(0, 160, 1, 0),
        Position               = UDim2.new(0, 36, 0, 0),
        BackgroundTransparency = 1,
        Text                   = title,
        TextColor3             = T.TextPrimary,
        TextSize               = 12,
        Font                   = Enum.Font.GothamBold,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 13,
        Parent                 = topbar,
    })

    -- Toggle hint
    Util.Create("TextLabel", {
        Size                   = UDim2.new(0, 120, 0, 12),
        Position               = UDim2.new(0, 36, 1, -14),
        BackgroundTransparency = 1,
        Text                   = toggleKey.Name:upper() .. " — TOGGLE",
        TextColor3             = T.TextMuted,
        TextSize               = 9,
        Font                   = Enum.Font.Gotham,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 13,
        Parent                 = topbar,
    })

    -- ── Control buttons factory ───────────────────────────────
    local function ctrlBtn(label, xOff, hoverCol)
        local b = Util.Create("TextButton", {
            Size               = UDim2.new(0, 22, 0, 22),
            Position           = UDim2.new(1, xOff, 0.5, -11),
            BackgroundColor3   = T.SurfaceLight,
            BackgroundTransparency = 0.4,
            Text               = "",
            AutoButtonColor    = false,
            BorderSizePixel    = 0,
            ZIndex             = 14,
            Parent             = topbar,
        })
        Util.Corner(6, b)
        local lbl = Util.Create("TextLabel", {
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                   = label,
            TextColor3             = T.TextSecondary,
            TextSize               = 13,
            Font                   = Enum.Font.GothamBold,
            ZIndex                 = 15,
            Parent                 = b,
        })
        b.MouseEnter:Connect(function()
            Util.Tween(b,   TweenFast, {BackgroundColor3 = hoverCol,     BackgroundTransparency = 0})
            Util.Tween(lbl, TweenFast, {TextColor3 = T.TextPrimary})
        end)
        b.MouseLeave:Connect(function()
            Util.Tween(b,   TweenFast, {BackgroundColor3 = T.SurfaceLight, BackgroundTransparency = 0.4})
            Util.Tween(lbl, TweenFast, {TextColor3 = T.TextSecondary})
        end)
        return b, lbl
    end

    local closeBtn, _ = ctrlBtn("×", -6,  Color3.fromRGB(180, 40, 50))
    local minBtn,   _ = ctrlBtn("–", -32, T.SurfaceLighter)

    -- ── BODY ─────────────────────────────────────────────────
    local body = Util.Create("Frame", {
        Name               = "Body",
        Size               = UDim2.new(1, 0, 1, -TOPBAR),
        Position           = UDim2.new(0, 0, 0, TOPBAR),
        BackgroundTransparency = 1,
        ZIndex             = 11,
        Parent             = win,
    })

    -- ── LEFT NAV ─────────────────────────────────────────────
    local nav = Util.Create("Frame", {
        Name             = "Nav",
        Size             = UDim2.new(0, NAVW, 1, 0),
        BackgroundColor3 = T.Surface,
        BackgroundTransparency = T.SurfTransparency + 0.05,
        BorderSizePixel  = 0,
        ZIndex           = 12,
        Parent           = body,
    })

    -- Right border
    Util.Create("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = T.Border,
        BackgroundTransparency = 0.5,
        BorderSizePixel  = 0,
        ZIndex           = 13,
        Parent           = nav,
    })

    local navScroll = Util.Create("ScrollingFrame", {
        Size                  = UDim2.new(1, 0, 1, -6),
        Position              = UDim2.new(0, 0, 0, 6),
        BackgroundTransparency = 1,
        ScrollBarThickness    = 0,
        BorderSizePixel       = 0,
        ZIndex                = 13,
        Parent                = nav,
    })
    Util.Pad(0, 4, 6, 6, navScroll)
    local navList = Util.List(3, navScroll)
    Util.AutoCanvas(navScroll, navList)

    -- ── CONTENT ───────────────────────────────────────────────
    local content = Util.Create("Frame", {
        Name               = "Content",
        Size               = UDim2.new(1, -NAVW, 1, 0),
        Position           = UDim2.new(0, NAVW, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants   = true,
        ZIndex             = 12,
        Parent             = body,
    })

    -- ── DRAG ─────────────────────────────────────────────────
    do
        local drag, start, origin = false, nil, nil
        topbar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                drag = true; start = i.Position
                origin = win.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - start
                local np = UDim2.new(origin.X.Scale, origin.X.Offset + d.X,
                                     origin.Y.Scale, origin.Y.Offset + d.Y)
                win.Position    = np
                shadow.Position = UDim2.new(np.X.Scale, np.X.Offset - 12,
                                             np.Y.Scale, np.Y.Offset - 12)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
        end)
    end

    -- ── MINIMIZE LOGIC (with floating restore button) ─────────
    local visible   = false  -- starts hidden (shown after loader)
    local minimized = false

    -- Floating restore pill (shown when minimized)
    local restoreBtn = Util.Create("TextButton", {
        Name               = "RestoreBtn",
        Size               = UDim2.new(0, 110, 0, 28),
        Position           = UDim2.new(0, 12, 0, 12),
        BackgroundColor3   = T.Surface,
        BackgroundTransparency = 0.1,
        Text               = "",
        AutoButtonColor    = false,
        BorderSizePixel    = 0,
        ZIndex             = 50,
        Visible            = false,
        Parent             = gui,
    })
    Util.Corner(8, restoreBtn)
    Util.Stroke(1, T.AccentDim, 0, restoreBtn)

    -- Icon + label inside restore btn
    Util.Create("TextLabel", {
        Size                   = UDim2.new(0, 20, 1, 0),
        Position               = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text                   = "⬡",
        TextColor3             = T.Accent,
        TextSize               = 12,
        Font                   = Enum.Font.GothamBold,
        ZIndex                 = 51,
        Parent                 = restoreBtn,
    })
    Util.Create("TextLabel", {
        Size                   = UDim2.new(1, -32, 1, 0),
        Position               = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        Text                   = title,
        TextColor3             = T.TextPrimary,
        TextSize               = 11,
        Font                   = Enum.Font.GothamMedium,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 51,
        Parent                 = restoreBtn,
    })

    -- Make restore button draggable
    Util.MakeDraggable(restoreBtn, restoreBtn)

    -- Hover glow on restore btn
    restoreBtn.MouseEnter:Connect(function()
        Util.Tween(restoreBtn, TweenFast,
            {BackgroundColor3 = T.AccentGlow, BackgroundTransparency = 0})
    end)
    restoreBtn.MouseLeave:Connect(function()
        Util.Tween(restoreBtn, TweenFast,
            {BackgroundColor3 = T.Surface, BackgroundTransparency = 0.1})
    end)

    local function showWindow()
        visible   = true
        minimized = false
        win.Visible    = true
        shadow.Visible = true
        restoreBtn.Visible = false
        Util.Tween(win, TweenBounce, {
            Size = UDim2.new(0, WIN_W, 0, WIN_H),
            BackgroundTransparency = T.BgTransparency,
        })
        Util.Tween(shadow, TweenSlow, {BackgroundTransparency = 0.55})
    end

    local function hideWindow()
        visible = false
        Util.Tween(win, TweenMed, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
        })
        Util.Tween(shadow, TweenMed, {BackgroundTransparency = 1})
        task.delay(0.22, function()
            win.Visible    = false
            shadow.Visible = false
        end)
    end

    local function minimizeWindow()
        minimized  = true
        visible    = false
        Util.Tween(win, TweenSlow, {
            Size = UDim2.new(0, WIN_W, 0, TOPBAR),
            BackgroundTransparency = T.BgTransparency,
        })
        task.delay(0.2, function()
            win.Visible    = false
            shadow.Visible = false
            restoreBtn.Visible = true
            -- Animate restore button in
            restoreBtn.Size = UDim2.new(0, 0, 0, 28)
            Util.Tween(restoreBtn, TweenBounce, {Size = UDim2.new(0, 110, 0, 28)})
        end)
    end

    -- Restore from minimized
    restoreBtn.MouseButton1Click:Connect(function()
        Util.Tween(restoreBtn, TweenFast, {Size = UDim2.new(0, 0, 0, 28)})
        task.delay(0.15, function()
            restoreBtn.Visible = false
            win.Visible    = true
            shadow.Visible = true
            win.Size = UDim2.new(0, WIN_W, 0, TOPBAR)
            showWindow()
        end)
    end)

    minBtn.MouseButton1Click:Connect(minimizeWindow)

    closeBtn.MouseButton1Click:Connect(function()
        Util.Tween(win, TweenMed, {
            Size                   = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
        })
        Util.Tween(shadow, TweenMed, {BackgroundTransparency = 1})
        restoreBtn.Visible = false
        task.delay(0.25, function()
            win:Destroy()
            shadow:Destroy()
            restoreBtn:Destroy()
        end)
    end)

    -- Toggle key
    UserInputService.InputBegan:Connect(function(i, gp)
        if not gp and i.KeyCode == toggleKey then
            if minimized then
                restoreBtn.Size = UDim2.new(0, 0, 0, 28)
                restoreBtn.Visible = false
                win.Visible    = true
                shadow.Visible = true
                win.Size = UDim2.new(0, WIN_W, 0, TOPBAR)
                showWindow()
            elseif visible then
                hideWindow()
            else
                showWindow()
            end
        end
    end)

    -- ── Animate open accent line ──────────────────────────────
    task.spawn(function()
        task.wait(0.1)
        Util.Tween(topAccent, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {Size = UDim2.new(1, 0, 0, 2)})
    end)

    -- ══════════════════════════════════════════════════════════
    -- WINDOW OBJECT
    -- ══════════════════════════════════════════════════════════
    local Window     = {}
    Window._Tabs     = {}
    Window._TabBtns  = {}
    Window._Active   = nil
    Window._Win      = win
    Window._Shadow   = shadow

    -- ── Theme changer (call from settings tab) ────────────────
    function Window:SetTheme(name)
        local td = Themes[name]
        if not td then return end
        for k, v in pairs(td) do T[k] = v end
        -- Update visible frames
        win.BackgroundColor3   = T.Background
        win.BackgroundTransparency = T.BgTransparency
        topbar.BackgroundColor3   = T.Surface
        nav.BackgroundColor3      = T.Surface
        logoBadge.BackgroundColor3 = T.AccentGlow
        topAccent.BackgroundColor3 = T.Accent
        titleLbl.TextColor3        = T.TextPrimary
        -- Notify change
        NexusUI.Notify(NexusUI, {
            Title = "Theme Changed",
            Text  = "Applied: " .. name,
            Type  = "info",
            Duration = 2,
        })
    end

    -- ── CreateTab ─────────────────────────────────────────────
    function Window:CreateTab(name, icon)
        local tab      = {}
        tab._Name      = name
        tab._Sections  = {}

        -- Nav button
        local tabBtn = Util.Create("TextButton", {
            Size               = UDim2.new(1, 0, 0, 28),
            BackgroundColor3   = T.SurfaceLight,
            BackgroundTransparency = 1,
            Text               = "",
            AutoButtonColor    = false,
            BorderSizePixel    = 0,
            ZIndex             = 14,
            Parent             = navScroll,
        })
        Util.Corner(6, tabBtn)

        -- Indicator bar
        local indicator = Util.Create("Frame", {
            Size             = UDim2.new(0, 2, 0.55, 0),
            Position         = UDim2.new(0, 0, 0.225, 0),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ZIndex           = 15,
            Parent           = tabBtn,
        })
        Util.Corner(2, indicator)

        -- Icon badge
        local glyph = icon or name:sub(1,1):upper()
        local iconBadge = Util.Create("Frame", {
            Size             = UDim2.new(0, 18, 0, 18),
            Position         = UDim2.new(0, 8, 0.5, -9),
            BackgroundColor3 = T.SurfaceLighter,
            BorderSizePixel  = 0,
            ZIndex           = 15,
            Parent           = tabBtn,
        })
        Util.Corner(5, iconBadge)
        Util.Create("TextLabel", {
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                   = glyph,
            TextColor3             = T.TextMuted,
            TextSize               = 9,
            Font                   = Enum.Font.GothamBold,
            ZIndex                 = 16,
            Parent                 = iconBadge,
        })

        -- Label
        local tabLbl = Util.Create("TextLabel", {
            Size                   = UDim2.new(1, -32, 1, 0),
            Position               = UDim2.new(0, 30, 0, 0),
            BackgroundTransparency = 1,
            Text                   = name,
            TextColor3             = T.TextSecondary,
            TextSize               = 11,
            Font                   = Enum.Font.GothamMedium,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 15,
            Parent                 = tabBtn,
        })

        -- Page (scrollable)
        local page = Util.Create("ScrollingFrame", {
            Name                  = "Page_" .. name,
            Size                  = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness    = 2,
            ScrollBarImageColor3  = T.BorderBright,
            BorderSizePixel       = 0,
            Visible               = false,
            ZIndex                = 13,
            Parent                = content,
        })
        Util.Pad(8, 8, 8, 8, page)
        local pageList = Util.List(6, page)
        Util.AutoCanvas(page, pageList)

        -- Activate function
        local function activate()
            for _, t in ipairs(Window._Tabs) do
                if t._Page then t._Page.Visible = false end
            end
            for _, r in ipairs(Window._TabBtns) do
                Util.Tween(r.btn,  TweenFast, {BackgroundTransparency = 1})
                Util.Tween(r.icon, TweenFast,
                    {BackgroundColor3 = T.SurfaceLighter})
                r.icon:FindFirstChildWhichIsA("TextLabel").TextColor3 = T.TextMuted
                Util.Tween(r.lbl,  TweenFast, {TextColor3 = T.TextSecondary})
                Util.Tween(r.ind,  TweenFast, {BackgroundTransparency = 1})
            end
            page.Visible = true
            Util.Tween(tabBtn,   TweenFast, {BackgroundTransparency = 0.8})
            Util.Tween(iconBadge, TweenFast, {BackgroundColor3 = T.AccentGlow})
            iconBadge:FindFirstChildWhichIsA("TextLabel").TextColor3 = T.Accent
            Util.Tween(tabLbl,   TweenFast, {TextColor3 = T.TextPrimary})
            Util.Tween(indicator, TweenFast, {BackgroundTransparency = 0})
            Window._Active = tab
        end

        table.insert(Window._TabBtns, {
            btn = tabBtn, icon = iconBadge, lbl = tabLbl, ind = indicator
        })

        tabBtn.MouseButton1Click:Connect(activate)
        tabBtn.MouseEnter:Connect(function()
            if Window._Active ~= tab then
                Util.Tween(tabBtn, TweenFast, {BackgroundTransparency = 0.9})
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if Window._Active ~= tab then
                Util.Tween(tabBtn, TweenFast, {BackgroundTransparency = 1})
            end
        end)

        tab._Page     = page
        tab._List     = pageList
        tab._Activate = activate
        table.insert(Window._Tabs, tab)
        if #Window._Tabs == 1 then task.spawn(activate) end

        -- ── CreateSection ─────────────────────────────────────
        function tab:CreateSection(secName)
            local sec  = {}

            local secFrame = Util.Create("Frame", {
                Name             = "Sec_" .. secName,
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = T.Surface,
                BackgroundTransparency = T.SurfTransparency,
                BorderSizePixel  = 0,
                ZIndex           = 14,
                Parent           = page,
            })
            Util.Corner(8, secFrame)
            Util.Stroke(1, T.Border, 0.35, secFrame)
            Util.Pad(8, 8, 8, 8, secFrame)
            local secList = Util.List(5, secFrame)

            -- Section header
            local hdr = Util.Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                ZIndex           = 15,
                Parent           = secFrame,
            })
            Util.Create("TextLabel", {
                Size                   = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text                   = secName:upper(),
                TextColor3             = T.TextMuted,
                TextSize               = 9,
                Font                   = Enum.Font.GothamBold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 16,
                Parent                 = hdr,
            })
            Util.Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = T.Border,
                BackgroundTransparency = 0.4,
                BorderSizePixel  = 0,
                ZIndex           = 15,
                Parent           = hdr,
            })

            sec._Frame = secFrame
            sec._List  = secList

            -- ─── SEPARATOR ────────────────────────────────────
            function sec:CreateSeparator()
                local f = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = T.Border,
                    BackgroundTransparency = 0.4,
                    BorderSizePixel  = 0,
                    ZIndex           = 15,
                    Parent           = secFrame,
                })
            end

            -- ─── LABEL ────────────────────────────────────────
            function sec:CreateLabel(cfg2)
                cfg2 = cfg2 or {}
                local lbl = Util.Create("TextLabel", {
                    Size                   = UDim2.new(1, 0, 0, 20),
                    AutomaticSize          = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text                   = cfg2.Text  or "Label",
                    TextColor3             = cfg2.Color or T.TextSecondary,
                    TextSize               = cfg2.Size  or 11,
                    Font                   = Enum.Font.Gotham,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextWrapped            = true,
                    ZIndex                 = 15,
                    Parent                 = secFrame,
                })
                local api = {}
                function api:Set(t2) lbl.Text = t2 end
                return api
            end

            -- ─── BUTTON ───────────────────────────────────────
            function sec:CreateButton(cfg2)
                cfg2 = cfg2 or {}
                local nm  = cfg2.Name     or "Button"
                local cb  = cfg2.Callback or function() end

                local row = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = T.SurfaceLight,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel  = 0,
                    ZIndex           = 15,
                    Parent           = secFrame,
                })
                Util.Corner(6, row)
                Util.Stroke(1, T.Border, 0.5, row)

                -- Left glow indicator (hidden by default)
                local glow = Util.Create("Frame", {
                    Size             = UDim2.new(0, 2, 0.6, 0),
                    Position         = UDim2.new(0, 0, 0.2, 0),
                    BackgroundColor3 = T.Accent,
                    BackgroundTransparency = 1,
                    BorderSizePixel  = 0,
                    ZIndex           = 16,
                    Parent           = row,
                })
                Util.Corner(2, glow)

                Util.Create("TextLabel", {
                    Size                   = UDim2.new(1, -26, 1, 0),
                    Position               = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = nm,
                    TextColor3             = T.TextPrimary,
                    TextSize               = 11,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ZIndex                 = 16,
                    Parent                 = row,
                })
                Util.Create("TextLabel", {
                    Size                   = UDim2.new(0, 16, 1, 0),
                    Position               = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = "›",
                    TextColor3             = T.TextMuted,
                    TextSize               = 13,
                    Font                   = Enum.Font.GothamBold,
                    ZIndex                 = 16,
                    Parent                 = row,
                })

                local hit = Util.Create("TextButton", {
                    Size               = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text               = "",
                    ZIndex             = 17,
                    Parent             = row,
                })
                hit.MouseEnter:Connect(function()
                    Util.Tween(row,  TweenFast, {BackgroundColor3 = T.SurfaceLighter, BackgroundTransparency = 0.1})
                    Util.Tween(glow, TweenFast, {BackgroundTransparency = 0})
                end)
                hit.MouseLeave:Connect(function()
                    Util.Tween(row,  TweenFast, {BackgroundColor3 = T.SurfaceLight, BackgroundTransparency = 0.3})
                    Util.Tween(glow, TweenFast, {BackgroundTransparency = 1})
                end)
                hit.MouseButton1Down:Connect(function()
                    Util.Tween(row, TweenFast, {BackgroundColor3 = T.AccentGlow, BackgroundTransparency = 0})
                end)
                hit.MouseButton1Up:Connect(function()
                    Util.Tween(row, TweenFast, {BackgroundColor3 = T.SurfaceLighter, BackgroundTransparency = 0.1})
                end)
                hit.MouseButton1Click:Connect(function()
                    pcall(cb)
                end)
            end

            -- ─── TOGGLE ───────────────────────────────────────
            function sec:CreateToggle(cfg2)
                cfg2 = cfg2 or {}
                local nm  = cfg2.Name     or "Toggle"
                local def = cfg2.Default  or false
                local cb  = cfg2.Callback or function() end
                local st  = def

                local row = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = T.SurfaceLight,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel  = 0,
                    ZIndex           = 15,
                    Parent           = secFrame,
                })
                Util.Corner(6, row)
                Util.Stroke(1, T.Border, 0.5, row)

                Util.Create("TextLabel", {
                    Size                   = UDim2.new(1, -50, 1, 0),
                    Position               = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = nm,
                    TextColor3             = T.TextPrimary,
                    TextSize               = 11,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ZIndex                 = 16,
                    Parent                 = row,
                })

                local pill = Util.Create("Frame", {
                    Size             = UDim2.new(0, 34, 0, 17),
                    Position         = UDim2.new(1, -42, 0.5, -8.5),
                    BackgroundColor3 = st and T.Accent or T.SurfaceLighter,
                    BorderSizePixel  = 0,
                    ZIndex           = 16,
                    Parent           = row,
                })
                Util.Corner(10, pill)
                Util.Stroke(1, st and T.AccentDim or T.Border, 0.2, pill)

                local knob = Util.Create("Frame", {
                    Size             = UDim2.new(0, 12, 0, 12),
                    Position         = st and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6),
                    BackgroundColor3 = Color3.fromRGB(230, 230, 240),
                    BorderSizePixel  = 0,
                    ZIndex           = 17,
                    Parent           = pill,
                })
                Util.Corner(10, knob)

                local function refresh()
                    Util.Tween(pill,  TweenMed,
                        {BackgroundColor3 = st and T.Accent or T.SurfaceLighter})
                    local stroke = pill:FindFirstChildOfClass("UIStroke")
                    if stroke then stroke.Color = st and T.AccentDim or T.Border end
                    Util.Tween(knob, TweenMed,
                        {Position = st and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)})
                end

                local hit = Util.Create("TextButton", {
                    Size               = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text               = "",
                    ZIndex             = 18,
                    Parent             = row,
                })
                hit.MouseEnter:Connect(function()
                    Util.Tween(row, TweenFast, {BackgroundTransparency = 0.15})
                end)
                hit.MouseLeave:Connect(function()
                    Util.Tween(row, TweenFast, {BackgroundTransparency = 0.3})
                end)
                hit.MouseButton1Click:Connect(function()
                    st = not st
                    refresh()
                    pcall(cb, st)
                end)

                local api = {}
                function api:Set(v) st = v; refresh() end
                function api:Get() return st end
                return api
            end

            -- ─── SLIDER ───────────────────────────────────────
            function sec:CreateSlider(cfg2)
                cfg2 = cfg2 or {}
                local nm   = cfg2.Name     or "Slider"
                local mn   = cfg2.Min      or 0
                local mx   = cfg2.Max      or 100
                local def  = cfg2.Default  or mn
                local suf  = cfg2.Suffix   or ""
                local dec  = cfg2.Decimals or 0
                local cb   = cfg2.Callback or function() end
                local val  = math.clamp(def, mn, mx)

                local wrap = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 46),
                    BackgroundColor3 = T.SurfaceLight,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel  = 0,
                    ZIndex           = 15,
                    Parent           = secFrame,
                })
                Util.Corner(6, wrap)
                Util.Stroke(1, T.Border, 0.5, wrap)

                Util.Create("TextLabel", {
                    Size                   = UDim2.new(0.6, 0, 0, 20),
                    Position               = UDim2.new(0, 10, 0, 4),
                    BackgroundTransparency = 1,
                    Text                   = nm,
                    TextColor3             = T.TextPrimary,
                    TextSize               = 11,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ZIndex                 = 16,
                    Parent                 = wrap,
                })

                local valLbl = Util.Create("TextLabel", {
                    Size                   = UDim2.new(0.4, -10, 0, 20),
                    Position               = UDim2.new(0.6, 0, 0, 4),
                    BackgroundTransparency = 1,
                    Text                   = tostring(val) .. suf,
                    TextColor3             = T.Accent,
                    TextSize               = 11,
                    Font                   = Enum.Font.GothamBold,
                    TextXAlignment         = Enum.TextXAlignment.Right,
                    ZIndex                 = 16,
                    Parent                 = wrap,
                })

                local track = Util.Create("Frame", {
                    Size             = UDim2.new(1, -20, 0, 4),
                    Position         = UDim2.new(0, 10, 0, 32),
                    BackgroundColor3 = T.SurfaceLighter,
                    BorderSizePixel  = 0,
                    ZIndex           = 16,
                    Parent           = wrap,
                })
                Util.Corner(4, track)

                local r0 = (val - mn) / (mx - mn)
                local fill = Util.Create("Frame", {
                    Size             = UDim2.new(r0, 0, 1, 0),
                    BackgroundColor3 = T.Accent,
                    BorderSizePixel  = 0,
                    ZIndex           = 17,
                    Parent           = track,
                })
                Util.Corner(4, fill)

                local knob = Util.Create("Frame", {
                    Size             = UDim2.new(0, 11, 0, 11),
                    Position         = UDim2.new(r0, -5.5, 0.5, -5.5),
                    BackgroundColor3 = Color3.fromRGB(230, 230, 240),
                    BorderSizePixel  = 0,
                    ZIndex           = 18,
                    Parent           = track,
                })
                Util.Corner(10, knob)

                local sliding = false
                local function upd(x)
                    local abs = track.AbsolutePosition
                    local sz  = track.AbsoluteSize
                    local r   = math.clamp((x - abs.X) / sz.X, 0, 1)
                    local raw = mn + (mx - mn) * r
                    local fmt = 10^dec
                    val = math.floor(raw * fmt + 0.5) / fmt
                    local rv = (val - mn) / (mx - mn)
                    Util.Tween(fill,  TweenFast, {Size     = UDim2.new(rv, 0, 1, 0)})
                    Util.Tween(knob,  TweenFast, {Position = UDim2.new(rv, -5.5, 0.5, -5.5)})
                    valLbl.Text = tostring(val) .. suf
                    pcall(cb, val)
                end

                local hit = Util.Create("TextButton", {
                    Size               = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text               = "",
                    ZIndex             = 19,
                    Parent             = track,
                })
                hit.MouseButton1Down:Connect(function(x) sliding = true; upd(x) end)
                hit.MouseButton1Up:Connect(function()    sliding = false end)
                UserInputService.InputChanged:Connect(function(i)
                    if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                        upd(i.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)

                local api = {}
                function api:Set(v)
                    val = math.clamp(v, mn, mx)
                    local rv = (val-mn)/(mx-mn)
                    fill.Size     = UDim2.new(rv, 0, 1, 0)
                    knob.Position = UDim2.new(rv, -5.5, 0.5, -5.5)
                    valLbl.Text   = tostring(val) .. suf
                end
                function api:Get() return val end
                return api
            end

            -- ─── DROPDOWN ─────────────────────────────────────
            function sec:CreateDropdown(cfg2)
                cfg2 = cfg2 or {}
                local nm   = cfg2.Name     or "Dropdown"
                local opts = cfg2.Options  or {}
                local def  = cfg2.Default  or (opts[1] or "")
                local cb   = cfg2.Callback or function() end
                local sel  = def
                local open = false

                local wrap = Util.Create("Frame", {
                    Size               = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    ZIndex             = 20,
                    ClipsDescendants   = false,
                    Parent             = secFrame,
                })

                local row = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = T.SurfaceLight,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel  = 0,
                    ZIndex           = 21,
                    Parent           = wrap,
                })
                Util.Corner(6, row)
                Util.Stroke(1, T.Border, 0.5, row)

                Util.Create("TextLabel", {
                    Size                   = UDim2.new(0.5, 0, 1, 0),
                    Position               = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = nm,
                    TextColor3             = T.TextPrimary,
                    TextSize               = 11,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ZIndex                 = 22,
                    Parent                 = row,
                })

                local selLbl = Util.Create("TextLabel", {
                    Size                   = UDim2.new(0.5, -24, 1, 0),
                    Position               = UDim2.new(0.5, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = sel,
                    TextColor3             = T.Accent,
                    TextSize               = 11,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Right,
                    ZIndex                 = 22,
                    Parent                 = row,
                })

                local arrow = Util.Create("TextLabel", {
                    Size                   = UDim2.new(0, 16, 1, 0),
                    Position               = UDim2.new(1, -18, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = "▾",
                    TextColor3             = T.TextMuted,
                    TextSize               = 11,
                    Font                   = Enum.Font.GothamBold,
                    ZIndex                 = 22,
                    Parent                 = row,
                })

                -- Panel
                local itemH = 26
                local panH  = #opts * itemH + 8
                local panel = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    Position         = UDim2.new(0, 0, 1, 3),
                    BackgroundColor3 = T.Surface,
                    BackgroundTransparency = 0.1,
                    BorderSizePixel  = 0,
                    ClipsDescendants = true,
                    ZIndex           = 25,
                    Visible          = false,
                    Parent           = row,
                })
                Util.Corner(6, panel)
                Util.Stroke(1, T.Border, 0.3, panel)
                Util.Pad(4, 4, 4, 4, panel)
                Util.List(2, panel)

                for _, opt in ipairs(opts) do
                    local item = Util.Create("TextButton", {
                        Size               = UDim2.new(1, 0, 0, itemH-2),
                        BackgroundColor3   = T.SurfaceLight,
                        BackgroundTransparency = 1,
                        Text               = "",
                        AutoButtonColor    = false,
                        BorderSizePixel    = 0,
                        ZIndex             = 26,
                        Parent             = panel,
                    })
                    Util.Corner(5, item)
                    local il = Util.Create("TextLabel", {
                        Size                   = UDim2.new(1, -8, 1, 0),
                        Position               = UDim2.new(0, 6, 0, 0),
                        BackgroundTransparency = 1,
                        Text                   = opt,
                        TextColor3             = opt == sel and T.Accent or T.TextSecondary,
                        TextSize               = 11,
                        Font                   = Enum.Font.GothamMedium,
                        TextXAlignment         = Enum.TextXAlignment.Left,
                        ZIndex                 = 27,
                        Parent                 = item,
                    })
                    item.MouseEnter:Connect(function()
                        Util.Tween(item, TweenFast, {BackgroundTransparency = 0})
                    end)
                    item.MouseLeave:Connect(function()
                        Util.Tween(item, TweenFast, {BackgroundTransparency = 1})
                    end)
                    item.MouseButton1Click:Connect(function()
                        sel = opt; selLbl.Text = opt
                        for _, c in ipairs(panel:GetChildren()) do
                            if c:IsA("TextButton") then
                                local l2 = c:FindFirstChildWhichIsA("TextLabel")
                                if l2 then
                                    l2.TextColor3 = l2.Text == opt and T.Accent or T.TextSecondary
                                end
                            end
                        end
                        open = false
                        Util.Tween(panel, TweenMed, {Size = UDim2.new(1,0,0,0)})
                        Util.Tween(arrow, TweenFast, {Rotation = 0})
                        task.delay(0.22, function() panel.Visible = false end)
                        wrap.Size = UDim2.new(1, 0, 0, 30)
                        pcall(cb, sel)
                    end)
                end

                local hit = Util.Create("TextButton", {
                    Size               = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text               = "",
                    ZIndex             = 23,
                    Parent             = row,
                })
                hit.MouseEnter:Connect(function()
                    Util.Tween(row, TweenFast, {BackgroundTransparency = 0.15})
                end)
                hit.MouseLeave:Connect(function()
                    Util.Tween(row, TweenFast, {BackgroundTransparency = 0.3})
                end)
                hit.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        panel.Visible = true
                        panel.Size    = UDim2.new(1, 0, 0, 0)
                        Util.Tween(panel, TweenMed, {Size = UDim2.new(1,0,0,panH)})
                        Util.Tween(arrow, TweenFast, {Rotation = 180})
                        wrap.Size = UDim2.new(1,0,0, 30 + panH + 6)
                    else
                        Util.Tween(panel, TweenMed, {Size = UDim2.new(1,0,0,0)})
                        Util.Tween(arrow, TweenFast, {Rotation = 0})
                        task.delay(0.22, function() panel.Visible = false end)
                        wrap.Size = UDim2.new(1, 0, 0, 30)
                    end
                end)

                local api = {}
                function api:Set(v) sel = v; selLbl.Text = v end
                function api:Get() return sel end
                return api
            end

            -- ─── TEXTBOX ──────────────────────────────────────
            function sec:CreateTextbox(cfg2)
                cfg2 = cfg2 or {}
                local nm  = cfg2.Name        or "Textbox"
                local ph  = cfg2.Placeholder or "Type here..."
                local def = cfg2.Default     or ""
                local cb  = cfg2.Callback    or function() end

                local wrap = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 46),
                    BackgroundColor3 = T.SurfaceLight,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel  = 0,
                    ZIndex           = 15,
                    Parent           = secFrame,
                })
                Util.Corner(6, wrap)
                Util.Stroke(1, T.Border, 0.5, wrap)

                Util.Create("TextLabel", {
                    Size                   = UDim2.new(1, -10, 0, 18),
                    Position               = UDim2.new(0, 10, 0, 4),
                    BackgroundTransparency = 1,
                    Text                   = nm,
                    TextColor3             = T.TextPrimary,
                    TextSize               = 11,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ZIndex                 = 16,
                    Parent                 = wrap,
                })

                local ibg = Util.Create("Frame", {
                    Size             = UDim2.new(1, -20, 0, 18),
                    Position         = UDim2.new(0, 10, 0, 24),
                    BackgroundColor3 = T.Background,
                    BackgroundTransparency = 0.1,
                    BorderSizePixel  = 0,
                    ZIndex           = 16,
                    Parent           = wrap,
                })
                Util.Corner(5, ibg)
                local iStroke = Util.Stroke(1, T.Border, 0.4, ibg)

                local box = Util.Create("TextBox", {
                    Size                   = UDim2.new(1, -10, 1, 0),
                    Position               = UDim2.new(0, 6, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = def,
                    PlaceholderText        = ph,
                    PlaceholderColor3      = T.TextMuted,
                    TextColor3             = T.TextPrimary,
                    TextSize               = 11,
                    Font                   = Enum.Font.Gotham,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ClearTextOnFocus       = false,
                    ZIndex                 = 17,
                    Parent                 = ibg,
                })
                box.Focused:Connect(function()
                    Util.Tween(ibg,    TweenFast, {BackgroundColor3 = T.SurfaceLight})
                    iStroke.Color = T.Accent; iStroke.Transparency = 0
                end)
                box.FocusLost:Connect(function(enter)
                    Util.Tween(ibg, TweenFast, {BackgroundColor3 = T.Background})
                    iStroke.Color = T.Border; iStroke.Transparency = 0.4
                    if enter then pcall(cb, box.Text) end
                end)

                local api = {}
                function api:Set(v) box.Text = v end
                function api:Get() return box.Text end
                return api
            end

            -- ─── KEYBIND ──────────────────────────────────────
            function sec:CreateKeybind(cfg2)
                cfg2 = cfg2 or {}
                local nm  = cfg2.Name     or "Keybind"
                local def = cfg2.Default  or Enum.KeyCode.Unknown
                local cb  = cfg2.Callback or function() end
                local cur = def
                local lst = false

                local row = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = T.SurfaceLight,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel  = 0,
                    ZIndex           = 15,
                    Parent           = secFrame,
                })
                Util.Corner(6, row)
                Util.Stroke(1, T.Border, 0.5, row)

                Util.Create("TextLabel", {
                    Size                   = UDim2.new(0.6, 0, 1, 0),
                    Position               = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = nm,
                    TextColor3             = T.TextPrimary,
                    TextSize               = 11,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ZIndex                 = 16,
                    Parent                 = row,
                })

                local badge = Util.Create("Frame", {
                    Size             = UDim2.new(0, 70, 0, 18),
                    Position         = UDim2.new(1, -76, 0.5, -9),
                    BackgroundColor3 = T.SurfaceLighter,
                    BorderSizePixel  = 0,
                    ZIndex           = 16,
                    Parent           = row,
                })
                Util.Corner(5, badge)
                local bStroke = Util.Stroke(1, T.Border, 0.3, badge)

                local kLbl = Util.Create("TextLabel", {
                    Size                   = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                   = cur == Enum.KeyCode.Unknown and "NONE" or cur.Name,
                    TextColor3             = T.Accent,
                    TextSize               = 10,
                    Font                   = Enum.Font.GothamBold,
                    ZIndex                 = 17,
                    Parent                 = badge,
                })

                local hit = Util.Create("TextButton", {
                    Size               = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text               = "",
                    ZIndex             = 18,
                    Parent             = row,
                })
                hit.MouseEnter:Connect(function()
                    Util.Tween(row, TweenFast, {BackgroundTransparency = 0.15})
                end)
                hit.MouseLeave:Connect(function()
                    Util.Tween(row, TweenFast, {BackgroundTransparency = 0.3})
                end)
                hit.MouseButton1Click:Connect(function()
                    lst = true
                    kLbl.Text = "..."; kLbl.TextColor3 = T.Warning
                    Util.Tween(badge, TweenFast, {BackgroundColor3 = T.AccentGlow})
                    bStroke.Color = T.Accent; bStroke.Transparency = 0
                end)

                UserInputService.InputBegan:Connect(function(i, gp)
                    if not gp and lst and i.UserInputType == Enum.UserInputType.Keyboard then
                        lst = false; cur = i.KeyCode
                        kLbl.Text = cur.Name; kLbl.TextColor3 = T.Accent
                        Util.Tween(badge, TweenFast, {BackgroundColor3 = T.SurfaceLighter})
                        bStroke.Color = T.Border; bStroke.Transparency = 0.3
                        pcall(cb, cur)
                    elseif not gp and not lst and i.KeyCode == cur then
                        pcall(cb, cur)
                    end
                end)

                local api = {}
                function api:Set(k) cur = k; kLbl.Text = k.Name end
                function api:Get() return cur end
                return api
            end

            -- ─── COLOR INDICATOR ──────────────────────────────
            function sec:CreateColorIndicator(cfg2)
                cfg2 = cfg2 or {}
                local nm  = cfg2.Name  or "Color"
                local col = cfg2.Color or T.Accent

                local row = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = T.SurfaceLight,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel  = 0,
                    ZIndex           = 15,
                    Parent           = secFrame,
                })
                Util.Corner(6, row)
                Util.Stroke(1, T.Border, 0.5, row)

                Util.Create("TextLabel", {
                    Size                   = UDim2.new(0.6, 0, 1, 0),
                    Position               = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = nm,
                    TextColor3             = T.TextPrimary,
                    TextSize               = 11,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ZIndex                 = 16,
                    Parent                 = row,
                })

                local hex = Util.Create("TextLabel", {
                    Size                   = UDim2.new(0, 60, 1, 0),
                    Position               = UDim2.new(1, -90, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = string.format("#%02X%02X%02X",
                        math.floor(col.R*255), math.floor(col.G*255), math.floor(col.B*255)),
                    TextColor3             = T.TextSecondary,
                    TextSize               = 10,
                    Font                   = Enum.Font.GothamMedium,
                    ZIndex                 = 16,
                    Parent                 = row,
                })

                local sw = Util.Create("Frame", {
                    Size             = UDim2.new(0, 20, 0, 20),
                    Position         = UDim2.new(1, -26, 0.5, -10),
                    BackgroundColor3 = col,
                    BorderSizePixel  = 0,
                    ZIndex           = 16,
                    Parent           = row,
                })
                Util.Corner(5, sw)
                Util.Stroke(1, T.Border, 0.3, sw)

                local api = {}
                function api:Set(c)
                    sw.BackgroundColor3 = c
                    hex.Text = string.format("#%02X%02X%02X",
                        math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
                end
                function api:Get() return sw.BackgroundColor3 end
                return api
            end

            -- ─── THEME PICKER (built-in component) ────────────
            function sec:CreateThemePicker()
                local themeNames = {"Dark", "Cyber B&W", "KRNL", "Soft Dark"}

                local wrapper = Util.Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = T.SurfaceLight,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel  = 0,
                    ZIndex           = 15,
                    Parent           = secFrame,
                })
                Util.Corner(6, wrapper)
                Util.Stroke(1, T.Border, 0.5, wrapper)

                Util.Create("TextLabel", {
                    Size                   = UDim2.new(0.4, 0, 1, 0),
                    Position               = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = "Theme",
                    TextColor3             = T.TextPrimary,
                    TextSize               = 11,
                    Font                   = Enum.Font.GothamMedium,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ZIndex                 = 16,
                    Parent                 = wrapper,
                })

                -- Dot selector row
                local dotRow = Util.Create("Frame", {
                    Size               = UDim2.new(0.6, -10, 1, 0),
                    Position           = UDim2.new(0.4, 0, 0, 0),
                    BackgroundTransparency = 1,
                    ZIndex             = 16,
                    Parent             = wrapper,
                })
                local dotList = Util.List(6, dotRow, Enum.FillDirection.Horizontal,
                    Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

                local themeColors = {
                    ["Dark"]      = Color3.fromRGB(80, 220, 255),
                    ["Cyber B&W"] = Color3.fromRGB(210, 210, 210),
                    ["KRNL"]      = Color3.fromRGB(138, 100, 255),
                    ["Soft Dark"] = Color3.fromRGB(100, 200, 170),
                }

                for _, tn in ipairs(themeNames) do
                    local dot = Util.Create("TextButton", {
                        Size               = UDim2.new(0, 16, 0, 16),
                        BackgroundColor3   = themeColors[tn],
                        BackgroundTransparency = 0.3,
                        Text               = "",
                        AutoButtonColor    = false,
                        BorderSizePixel    = 0,
                        ZIndex             = 17,
                        Parent             = dotRow,
                    })
                    Util.Corner(10, dot)
                    Util.Stroke(1, T.Border, 0.4, dot)

                    dot.MouseEnter:Connect(function()
                        Util.Tween(dot, TweenFast, {BackgroundTransparency = 0,
                            Size = UDim2.new(0, 18, 0, 18)})
                    end)
                    dot.MouseLeave:Connect(function()
                        Util.Tween(dot, TweenFast, {BackgroundTransparency = 0.3,
                            Size = UDim2.new(0, 16, 0, 16)})
                    end)
                    dot.MouseButton1Click:Connect(function()
                        Window:SetTheme(tn)
                    end)
                end
            end

            return sec
        end -- CreateSection

        return tab
    end -- CreateTab

    -- ── Show window (after loader or immediately) ─────────────
    local function revealUI()
        win.Size       = UDim2.new(0, 0, 0, 0)
        win.Position   = UDim2.new(0.5, 0, 0.5, 0)
        win.Visible    = true
        shadow.Visible = true
        visible        = true
        Util.Tween(win, TweenBounce, {
            Size     = UDim2.new(0, WIN_W, 0, WIN_H),
            Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
            BackgroundTransparency = T.BgTransparency,
        })
        Util.Tween(shadow, TweenSlow, {BackgroundTransparency = 0.55})
    end

    if showLoader then
        task.spawn(function()
            NexusUI._ShowLoader(NexusUI, gui, loaderTitle, revealUI)
        end)
    else
        task.spawn(function()
            task.wait(0.05)
            revealUI()
        end)
    end

    return Window
end -- CreateWindow

-- ══════════════════════════════════════════════════════════════
-- LIBRARY EXPORT
-- ══════════════════════════════════════════════════════════════
local Library      = setmetatable({}, NexusUI)
Library.__index    = Library

function Library:CreateWindow(cfg)
    return NexusUI.CreateWindow(self, cfg)
end

function Library:Notify(cfg)
    return NexusUI.Notify(self, cfg)
end

return Library
