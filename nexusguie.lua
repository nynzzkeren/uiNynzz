--[[
╔═══════════════════════════════════════════════════════════╗
║   _   _       _       _                 _   _       _     ║
║  | \ | | __ _| |_ ___(_)_ __ __ _     | | | |_   _| |__  ║
║  |  \| |/ _` | __/ _ \ | '__/ _` |    | |_| | | | | '_ \ ║
║  | |\  | (_| | ||  __/ | | | (_| |    |  _  | |_| | |_) |║
║  |_| \_|\__,_|\__\___|_|_|  \__,_|    |_| |_|\__,_|_.__/ ║
╠═══════════════════════════════════════════════════════════╣
║  v4.0.0  ·  Nateira Hub  ·  Roblox UI Library             ║
║  • Circular float icon   • Collapsible sections           ║
║  • Nateira branding      • Smooth collapse tweens         ║
╚═══════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
--  THEME SYSTEM
-- ═══════════════════════════════════════════════════════════
local Themes = {
    ["Dark"] = {
        Bg              = Color3.fromRGB(10,  10,  14),
        Surface         = Color3.fromRGB(16,  16,  22),
        SurfaceHi       = Color3.fromRGB(22,  22,  30),
        SurfaceHiHi     = Color3.fromRGB(30,  30,  42),
        Border          = Color3.fromRGB(40,  40,  56),
        BorderHi        = Color3.fromRGB(62,  62,  84),
        Text            = Color3.fromRGB(228, 228, 238),
        TextSub         = Color3.fromRGB(120, 120, 142),
        TextDim         = Color3.fromRGB(58,  58,  78),
        Accent          = Color3.fromRGB(80,  220, 255),
        AccentMid       = Color3.fromRGB(40,  110, 132),
        AccentLow       = Color3.fromRGB(16,  52,  66),
        Ok              = Color3.fromRGB(55,  218, 128),
        Warn            = Color3.fromRGB(255, 193, 48),
        Bad             = Color3.fromRGB(255, 66,  76),
        BgAlpha         = 0.22,
        SurfAlpha       = 0.12,
    },
    ["Cyber B&W"] = {
        Bg              = Color3.fromRGB(6,   6,   6),
        Surface         = Color3.fromRGB(13,  13,  13),
        SurfaceHi       = Color3.fromRGB(21,  21,  21),
        SurfaceHiHi     = Color3.fromRGB(30,  30,  30),
        Border          = Color3.fromRGB(48,  48,  48),
        BorderHi        = Color3.fromRGB(86,  86,  86),
        Text            = Color3.fromRGB(238, 238, 238),
        TextSub         = Color3.fromRGB(148, 148, 148),
        TextDim         = Color3.fromRGB(76,  76,  76),
        Accent          = Color3.fromRGB(218, 218, 218),
        AccentMid       = Color3.fromRGB(118, 118, 118),
        AccentLow       = Color3.fromRGB(38,  38,  38),
        Ok              = Color3.fromRGB(178, 238, 178),
        Warn            = Color3.fromRGB(238, 208, 118),
        Bad             = Color3.fromRGB(238, 98,  98),
        BgAlpha         = 0.18,
        SurfAlpha       = 0.08,
    },
    ["KRNL"] = {
        Bg              = Color3.fromRGB(18,  18,  26),
        Surface         = Color3.fromRGB(26,  26,  36),
        SurfaceHi       = Color3.fromRGB(34,  34,  48),
        SurfaceHiHi     = Color3.fromRGB(44,  44,  62),
        Border          = Color3.fromRGB(52,  52,  74),
        BorderHi        = Color3.fromRGB(78,  78,  108),
        Text            = Color3.fromRGB(218, 218, 232),
        TextSub         = Color3.fromRGB(138, 138, 162),
        TextDim         = Color3.fromRGB(72,  72,  98),
        Accent          = Color3.fromRGB(136, 98,  255),
        AccentMid       = Color3.fromRGB(78,  52,  158),
        AccentLow       = Color3.fromRGB(32,  22,  68),
        Ok              = Color3.fromRGB(78,  208, 138),
        Warn            = Color3.fromRGB(255, 188, 58),
        Bad             = Color3.fromRGB(255, 72,  82),
        BgAlpha         = 0.18,
        SurfAlpha       = 0.10,
    },
    ["Soft Dark"] = {
        Bg              = Color3.fromRGB(20,  22,  28),
        Surface         = Color3.fromRGB(28,  31,  40),
        SurfaceHi       = Color3.fromRGB(36,  40,  52),
        SurfaceHiHi     = Color3.fromRGB(46,  51,  66),
        Border          = Color3.fromRGB(56,  62,  80),
        BorderHi        = Color3.fromRGB(82,  90,  116),
        Text            = Color3.fromRGB(212, 216, 228),
        TextSub         = Color3.fromRGB(128, 134, 158),
        TextDim         = Color3.fromRGB(70,  76,  96),
        Accent          = Color3.fromRGB(98,  198, 168),
        AccentMid       = Color3.fromRGB(52,  108, 92),
        AccentLow       = Color3.fromRGB(22,  48,  42),
        Ok              = Color3.fromRGB(88,  212, 142),
        Warn            = Color3.fromRGB(238, 182, 62),
        Bad             = Color3.fromRGB(238, 78,  88),
        BgAlpha         = 0.28,
        SurfAlpha       = 0.16,
    },
}

-- Live theme table (mutated on theme change — all UI refs this)
local T = {}
do
    for k, v in pairs(Themes["Dark"]) do T[k] = v end
end

-- ═══════════════════════════════════════════════════════════
--  TWEEN INFO PRESETS
-- ═══════════════════════════════════════════════════════════
local TI = {
    Fast   = TweenInfo.new(0.10, Enum.EasingStyle.Quad,    Enum.EasingDirection.Out),
    Med    = TweenInfo.new(0.20, Enum.EasingStyle.Quad,    Enum.EasingDirection.Out),
    Slow   = TweenInfo.new(0.36, Enum.EasingStyle.Quint,   Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.30, Enum.EasingStyle.Back,    Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.42, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
    Linear = function(t) return TweenInfo.new(t, Enum.EasingStyle.Linear) end,
}

-- ═══════════════════════════════════════════════════════════
--  UTILITY
-- ═══════════════════════════════════════════════════════════
local U = {}

function U.Tw(obj, info, props)
    if not obj or not obj.Parent then return end
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

function U.New(cls, props)
    local i = Instance.new(cls)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then i[k] = v end
    end
    if props and props.Parent then i.Parent = props.Parent end
    return i
end

function U.Corner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

function U.Stroke(th, col, tr, p)
    local s = Instance.new("UIStroke")
    s.Thickness       = th  or 1
    s.Color           = col or T.Border
    s.Transparency    = tr  or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

function U.Pad(t, b, l, r, p)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, t or 0)
    pad.PaddingBottom = UDim.new(0, b or 0)
    pad.PaddingLeft   = UDim.new(0, l or 0)
    pad.PaddingRight  = UDim.new(0, r or 0)
    pad.Parent = p
    return pad
end

function U.List(gap, p, dir, ha, va)
    local l = Instance.new("UIListLayout")
    l.Padding             = UDim.new(0, gap or 4)
    l.FillDirection       = dir or Enum.FillDirection.Vertical
    l.HorizontalAlignment = ha  or Enum.HorizontalAlignment.Left
    l.VerticalAlignment   = va  or Enum.VerticalAlignment.Top
    l.SortOrder           = Enum.SortOrder.LayoutOrder
    l.Parent = p
    return l
end

function U.AutoCanvas(sf, ll, extra)
    local function upd()
        sf.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + (extra or 12))
    end
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
    upd()
end

-- Draggable — separate handle from mover
function U.Drag(handle, mover)
    mover = mover or handle
    local drag, s0, p0 = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            s0   = i.Position
            p0   = mover.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - s0
            mover.Position = UDim2.new(
                p0.X.Scale, p0.X.Offset + d.X,
                p0.Y.Scale, p0.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  NEXUSUI CORE
-- ═══════════════════════════════════════════════════════════
local NexusUI       = {}
NexusUI.__index     = NexusUI
NexusUI._NC         = 0     -- notif counter
NexusUI._NCon       = nil   -- notif container

-- ── ScreenGui ───────────────────────────────────────────────
function NexusUI:_Gui()
    if self._SG and self._SG.Parent then return self._SG end
    local g
    local ok = pcall(function()
        g = U.New("ScreenGui", {
            Name           = "NateirHub_v4",
            ResetOnSpawn   = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder   = 999,
            IgnoreGuiInset = true,
            Parent         = CoreGui,
        })
    end)
    if not ok then
        g = U.New("ScreenGui", {
            Name           = "NateirHub_v4",
            ResetOnSpawn   = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder   = 999,
            IgnoreGuiInset = true,
            Parent         = LocalPlayer:WaitForChild("PlayerGui"),
        })
    end
    self._SG = g
    return g
end

-- ═══════════════════════════════════════════════════════════
--  PREMIUM LOADING SCREEN
-- ═══════════════════════════════════════════════════════════
function NexusUI:_Loader(gui, title, done)

    -- Full overlay
    local overlay = U.New("Frame", {
        Name               = "NexusLoader",
        Size               = UDim2.new(1, 0, 1, 0),
        BackgroundColor3   = Color3.fromRGB(4, 4, 6),
        BackgroundTransparency = 0,
        ZIndex             = 500,
        Parent             = gui,
    })

    -- Center card
    local card = U.New("Frame", {
        Size               = UDim2.new(0, 200, 0, 160),
        Position           = UDim2.new(0.5, -100, 0.5, -80),
        BackgroundColor3   = T.Surface,
        BackgroundTransparency = 0,
        BorderSizePixel    = 0,
        ZIndex             = 501,
        Parent             = overlay,
    })
    U.Corner(12, card)
    U.Stroke(1, T.Border, 0, card)

    -- Card top accent bar (animates in)
    local cardTop = U.New("Frame", {
        Size             = UDim2.new(0, 0, 0, 2),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 502,
        Parent           = card,
    })
    U.Corner(2, cardTop)

    -- Outer glow ring (decorative)
    local glowRing = U.New("Frame", {
        Size               = UDim2.new(0, 60, 0, 60),
        Position           = UDim2.new(0.5, -30, 0, 22),
        BackgroundColor3   = T.AccentLow,
        BackgroundTransparency = 0,
        BorderSizePixel    = 0,
        ZIndex             = 502,
        Parent             = card,
    })
    U.Corner(30, glowRing)

    -- Inner logo hexagon
    local logoFrame = U.New("Frame", {
        Size               = UDim2.new(0, 44, 0, 44),
        Position           = UDim2.new(0.5, -22, 0, 30),
        BackgroundColor3   = T.AccentMid,
        BackgroundTransparency = 0,
        BorderSizePixel    = 0,
        ZIndex             = 503,
        Parent             = card,
    })
    U.Corner(12, logoFrame)

    local logoText = U.New("TextLabel", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = "⬡",
        TextColor3             = T.Accent,
        TextSize               = 24,
        Font                   = Enum.Font.GothamBold,
        ZIndex                 = 504,
        Parent                 = logoFrame,
    })

    -- Title
    local titleLbl = U.New("TextLabel", {
        Size                   = UDim2.new(1, -20, 0, 16),
        Position               = UDim2.new(0, 10, 0, 94),
        BackgroundTransparency = 1,
        Text                   = title or "Nateira Hub",
        TextColor3             = T.Text,
        TextSize               = 13,
        Font                   = Enum.Font.GothamBold,
        ZIndex                 = 502,
        Parent                 = card,
    })

    -- Status label
    local statusLbl = U.New("TextLabel", {
        Size                   = UDim2.new(1, -20, 0, 12),
        Position               = UDim2.new(0, 10, 0, 112),
        BackgroundTransparency = 1,
        Text                   = "Initializing...",
        TextColor3             = T.TextDim,
        TextSize               = 9,
        Font                   = Enum.Font.Gotham,
        ZIndex                 = 502,
        Parent                 = card,
    })

    -- Progress track
    local pTrack = U.New("Frame", {
        Size             = UDim2.new(1, -20, 0, 3),
        Position         = UDim2.new(0, 10, 1, -16),
        BackgroundColor3 = T.SurfaceHiHi,
        BorderSizePixel  = 0,
        ZIndex           = 502,
        Parent           = card,
    })
    U.Corner(4, pTrack)

    local pBar = U.New("Frame", {
        Size             = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 503,
        Parent           = pTrack,
    })
    U.Corner(4, pBar)

    -- Checkmark (hidden until done)
    local checkLbl = U.New("TextLabel", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = "✓",
        TextColor3             = T.Ok,
        TextSize               = 0,
        Font                   = Enum.Font.GothamBold,
        ZIndex                 = 505,
        TextTransparency       = 1,
        Parent                 = logoFrame,
    })

    -- ── Animate sequence ─────────────────────────────────────
    task.spawn(function()

        -- 1. Accent bar sweeps in
        task.wait(0.15)
        U.Tw(cardTop, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {Size = UDim2.new(1, 0, 0, 2)})

        -- 2. Logo pulses in
        task.wait(0.2)
        logoFrame.Size     = UDim2.new(0, 0, 0, 0)
        logoFrame.Position = UDim2.new(0.5, 0, 0, 52)
        U.Tw(logoFrame, TI.Bounce,
            {Size = UDim2.new(0, 44, 0, 44), Position = UDim2.new(0.5, -22, 0, 30)})
        U.Tw(glowRing, TI.Med,
            {BackgroundColor3 = T.AccentLow})

        -- 3. Glow ring pulses
        task.spawn(function()
            local pulse = true
            task.delay(1.8, function() pulse = false end)
            while pulse do
                U.Tw(glowRing, TI.Slow, {BackgroundTransparency = 0.5})
                task.wait(0.4)
                U.Tw(glowRing, TI.Slow, {BackgroundTransparency = 0.1})
                task.wait(0.4)
            end
        end)

        -- 4. Progress steps
        local steps = {
            {p = 0.20, s = "Loading modules...",      w = 0.45},
            {p = 0.45, s = "Building interface...",   w = 0.35},
            {p = 0.68, s = "Applying theme...",       w = 0.30},
            {p = 0.88, s = "Finalizing...",           w = 0.25},
            {p = 1.00, s = "Ready!",                  w = 0.20},
        }
        for _, step in ipairs(steps) do
            task.wait(step.w)
            statusLbl.Text = step.s
            U.Tw(pBar, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(step.p, 0, 1, 0)})
        end

        -- 5. Checkmark reveal — logo flips to check
        task.wait(0.25)
        U.Tw(logoText,  TI.Fast, {TextTransparency = 1, TextSize = 0})
        U.Tw(checkLbl,  TI.Bounce, {TextTransparency = 0, TextSize = 26})
        U.Tw(logoFrame, TI.Med,   {BackgroundColor3 = T.AccentLow})
        U.Tw(pBar,      TI.Med,   {BackgroundColor3 = T.Ok})

        task.wait(0.55)

        -- 6. Fade everything out
        local toFade = {overlay, card}
        for _, f in ipairs(toFade) do
            U.Tw(f, TI.Slow, {BackgroundTransparency = 1})
        end
        for _, d in ipairs(card:GetDescendants()) do
            pcall(function()
                if d:IsA("TextLabel") then
                    U.Tw(d, TI.Med, {TextTransparency = 1})
                elseif d:IsA("Frame") or d:IsA("ImageLabel") then
                    U.Tw(d, TI.Med, {BackgroundTransparency = 1})
                end
            end)
        end

        task.wait(0.38)
        overlay:Destroy()
        if done then done() end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════
function NexusUI:Notify(cfg)
    cfg = cfg or {}
    local ttl  = cfg.Title    or "Notice"
    local body = cfg.Text     or ""
    local dur  = cfg.Duration or 4
    local kind = cfg.Type     or "info"

    local gui = self:_Gui()
    self._NC  = self._NC + 1

    -- Container (right edge, stacks bottom-up)
    if not self._NCon or not self._NCon.Parent then
        self._NCon = U.New("Frame", {
            Name                   = "NotifContainer",
            Size                   = UDim2.new(0, 255, 1, 0),
            Position               = UDim2.new(1, -268, 0, 0),
            BackgroundTransparency = 1,
            ZIndex                 = 300,
            Parent                 = gui,
        })
        local l = U.List(6, self._NCon)
        l.VerticalAlignment = Enum.VerticalAlignment.Bottom
        U.Pad(8, 8, 0, 0, self._NCon)
    end

    local accent = ({
        info    = T.Accent,
        success = T.Ok,
        warning = T.Warn,
        error   = T.Bad,
    })[kind] or T.Accent

    local icon = ({info="ℹ", success="✓", warning="⚠", error="✕"})[kind] or "ℹ"

    -- Card
    local card = U.New("Frame", {
        Size               = UDim2.new(1, 0, 0, 62),
        BackgroundColor3   = T.Surface,
        BackgroundTransparency = T.SurfAlpha,
        BorderSizePixel    = 0,
        ClipsDescendants   = false,
        ZIndex             = 301,
        Parent             = self._NCon,
    })
    U.Corner(8, card)
    U.Stroke(1, T.Border, 0.3, card)

    -- Left accent strip
    local strip = U.New("Frame", {
        Size             = UDim2.new(0, 3, 0.65, 0),
        Position         = UDim2.new(0, 0, 0.175, 0),
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        ZIndex           = 302,
        Parent           = card,
    })
    U.Corner(3, strip)

    -- Icon badge
    local ibadge = U.New("Frame", {
        Size               = UDim2.new(0, 22, 0, 22),
        Position           = UDim2.new(0, 11, 0.5, -11),
        BackgroundColor3   = accent,
        BackgroundTransparency = 0.72,
        BorderSizePixel    = 0,
        ZIndex             = 302,
        Parent             = card,
    })
    U.Corner(6, ibadge)
    U.New("TextLabel", {
        Size = UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text=icon, TextColor3=accent, TextSize=11,
        Font=Enum.Font.GothamBold, ZIndex=303, Parent=ibadge,
    })

    -- Title
    U.New("TextLabel", {
        Size=UDim2.new(1,-46,0,15), Position=UDim2.new(0,40,0,9),
        BackgroundTransparency=1, Text=ttl, TextColor3=T.Text,
        TextSize=12, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=302, Parent=card,
    })

    -- Body
    U.New("TextLabel", {
        Size=UDim2.new(1,-46,0,24), Position=UDim2.new(0,40,0,25),
        BackgroundTransparency=1, Text=body, TextColor3=T.TextSub,
        TextSize=10, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true, ZIndex=302, Parent=card,
    })

    -- Progress bar
    local pbg = U.New("Frame", {
        Size=UDim2.new(1,-6,0,2), Position=UDim2.new(0,3,1,-4),
        BackgroundColor3=T.SurfaceHiHi, BorderSizePixel=0, ZIndex=302, Parent=card,
    })
    U.Corner(2, pbg)
    local pbar = U.New("Frame", {
        Size=UDim2.new(1,0,1,0), BackgroundColor3=accent,
        BorderSizePixel=0, ZIndex=303, Parent=pbg,
    })
    U.Corner(2, pbar)

    -- Slide in
    card.Position = UDim2.new(1.15, 0, 0, 0)
    U.Tw(card, TI.Bounce, {Position = UDim2.new(0, 0, 0, 0)})
    U.Tw(pbar, TI.Linear(dur), {Size = UDim2.new(0, 0, 1, 0)})

    -- Dismiss
    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        U.Tw(card, TI.Med, {Position=UDim2.new(1.15,0,0,0), BackgroundTransparency=1})
        task.delay(0.22, function() pcall(function() card:Destroy() end) end)
    end

    local hit = U.New("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="", ZIndex=310, Parent=card,
    })
    hit.MouseButton1Click:Connect(dismiss)
    task.delay(dur, dismiss)
end

-- ═══════════════════════════════════════════════════════════
--  CREATE WINDOW
-- ═══════════════════════════════════════════════════════════
function NexusUI:CreateWindow(cfg)
    cfg = cfg or {}
    local winTitle   = cfg.Title      or "Nateira Hub"
    local toggleKey  = cfg.ToggleKey  or Enum.KeyCode.RightShift
    local themeName  = cfg.Theme      or "Dark"
    local useLoader  = cfg.Loader     ~= false
    local loaderTitle = cfg.LoaderTitle or winTitle

    -- Apply theme
    do
        local td = Themes[themeName] or Themes["Dark"]
        for k, v in pairs(td) do T[k] = v end
    end

    -- Dimensions — compact, KRNL-style
    local W, H     = 470, 340
    local TOPBAR_H = 34
    local NAV_W    = 108

    local gui = self:_Gui()

    -- ── Drop shadow ──────────────────────────────────────────
    local shadow = U.New("Frame", {
        Name               = "Shadow",
        Size               = UDim2.new(0, W+20, 0, H+20),
        Position           = UDim2.new(0.5, -(W/2)-10, 0.5, -(H/2)-10),
        BackgroundColor3   = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.50,
        BorderSizePixel    = 0,
        ZIndex             = 9,
        Visible            = false,
        Parent             = gui,
    })
    U.Corner(14, shadow)

    -- ── Main window (NO ClipsDescendants on root) ─────────────
    local win = U.New("Frame", {
        Name               = "NexusWindow",
        Size               = UDim2.new(0, W, 0, H),
        Position           = UDim2.new(0.5, -W/2, 0.5, -H/2),
        BackgroundColor3   = T.Bg,
        BackgroundTransparency = T.BgAlpha,
        BorderSizePixel    = 0,
        ClipsDescendants   = false,   -- ← IMPORTANT: don't clip, fixes button cutoff
        ZIndex             = 10,
        Visible            = false,
        Parent             = gui,
    })
    U.Corner(10, win)

    -- Inner clip frame so content clips but buttons don't
    local winClip = U.New("Frame", {
        Name               = "WinClip",
        Size               = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel    = 0,
        ClipsDescendants   = true,
        ZIndex             = 10,
        Parent             = win,
    })
    U.Corner(10, winClip)
    U.Stroke(1, T.Border, 0.3, winClip)

    -- ── TOP BAR ──────────────────────────────────────────────
    -- TopBar lives in win (not winClip) so buttons won't get clipped
    local topbar = U.New("Frame", {
        Name             = "TopBar",
        Size             = UDim2.new(1, 0, 0, TOPBAR_H),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = T.Surface,
        BackgroundTransparency = T.SurfAlpha,
        BorderSizePixel  = 0,
        ClipsDescendants = false,  -- never clip the topbar
        ZIndex           = 20,
        Parent           = win,    -- parent to win, not winClip
    })
    -- Top-bar bottom border
    U.New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border,
        BackgroundTransparency = 0.4,
        BorderSizePixel  = 0,
        ZIndex           = 21,
        Parent           = topbar,
    })

    -- Animated accent sweep line
    local accentLine = U.New("Frame", {
        Size             = UDim2.new(0, 0, 0, 2),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 22,
        Parent           = topbar,
    })
    U.Corner(2, accentLine)

    -- Logo badge  (N for Nateira)
    local logoBadge = U.New("Frame", {
        Size             = UDim2.new(0, 20, 0, 20),
        Position         = UDim2.new(0, 8, 0.5, -10),
        BackgroundColor3 = T.AccentLow,
        BorderSizePixel  = 0,
        ZIndex           = 22,
        Parent           = topbar,
    })
    U.Corner(10, logoBadge)   -- fully circular badge
    U.Stroke(1, T.AccentMid, 0, logoBadge)
    U.New("TextLabel", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="N", TextColor3=T.Accent, TextSize=11,
        Font=Enum.Font.GothamBold, ZIndex=23, Parent=logoBadge,
    })

    -- Title label
    U.New("TextLabel", {
        Size=UDim2.new(0,160,1,0), Position=UDim2.new(0,34,0,0),
        BackgroundTransparency=1, Text=winTitle,
        TextColor3=T.Text, TextSize=12, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=22, Parent=topbar,
    })

    -- Key hint (small, bottom of topbar)
    U.New("TextLabel", {
        Size=UDim2.new(0,130,0,10), Position=UDim2.new(0,34,1,-12),
        BackgroundTransparency=1,
        Text=toggleKey.Name:upper().." — TOGGLE",
        TextColor3=T.TextDim, TextSize=8, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=22, Parent=topbar,
    })

    -- ── Control buttons — FIXED: proper right-alignment, no clip ──
    -- We place buttons directly on win so they can never be clipped
    local function mkCtrl(glyph, rightOff, hoverBg)
        local btn = U.New("TextButton", {
            Size               = UDim2.new(0, 20, 0, 20),
            Position           = UDim2.new(1, rightOff, 0, (TOPBAR_H - 20) / 2),
            BackgroundColor3   = T.SurfaceHi,
            BackgroundTransparency = 0.3,
            Text               = "",
            AutoButtonColor    = false,
            BorderSizePixel    = 0,
            ZIndex             = 30,     -- above everything
            Parent             = win,    -- parent to win, NOT topbar
        })
        U.Corner(5, btn)
        local lbl = U.New("TextLabel", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
            Text=glyph, TextColor3=T.TextSub, TextSize=12,
            Font=Enum.Font.GothamBold, ZIndex=31, Parent=btn,
        })
        btn.MouseEnter:Connect(function()
            U.Tw(btn, TI.Fast, {BackgroundColor3=hoverBg, BackgroundTransparency=0})
            U.Tw(lbl, TI.Fast, {TextColor3=T.Text})
        end)
        btn.MouseLeave:Connect(function()
            U.Tw(btn, TI.Fast, {BackgroundColor3=T.SurfaceHi, BackgroundTransparency=0.3})
            U.Tw(lbl, TI.Fast, {TextColor3=T.TextSub})
        end)
        btn.MouseButton1Down:Connect(function()
            U.Tw(btn, TI.Fast, {BackgroundTransparency=0.1})
        end)
        return btn
    end

    -- Close at -6 from right, Minimize at -30 from right
    local closeBtn = mkCtrl("×", -6,  Color3.fromRGB(176, 36, 46))
    local minBtn   = mkCtrl("–", -30, T.SurfaceHiHi)

    -- ── BODY (inside winClip so it clips properly) ───────────
    local body = U.New("Frame", {
        Name               = "Body",
        Size               = UDim2.new(1, 0, 1, -TOPBAR_H),
        Position           = UDim2.new(0, 0, 0, TOPBAR_H),
        BackgroundTransparency = 1,
        BorderSizePixel    = 0,
        ZIndex             = 11,
        Parent             = winClip,
    })

    -- ── LEFT NAV ─────────────────────────────────────────────
    local nav = U.New("Frame", {
        Name             = "Nav",
        Size             = UDim2.new(0, NAV_W, 1, 0),
        BackgroundColor3 = T.Surface,
        BackgroundTransparency = T.SurfAlpha + 0.04,
        BorderSizePixel  = 0,
        ZIndex           = 12,
        Parent           = body,
    })
    -- Right border
    U.New("Frame", {
        Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,-1,0,0),
        BackgroundColor3=T.Border, BackgroundTransparency=0.5,
        BorderSizePixel=0, ZIndex=13, Parent=nav,
    })

    local navScroll = U.New("ScrollingFrame", {
        Size=UDim2.new(1,0,1,-4), Position=UDim2.new(0,0,0,4),
        BackgroundTransparency=1, ScrollBarThickness=0,
        BorderSizePixel=0, ZIndex=13, Parent=nav,
    })
    U.Pad(0,4,5,5, navScroll)
    local navList = U.List(3, navScroll)
    U.AutoCanvas(navScroll, navList)

    -- ── CONTENT ───────────────────────────────────────────────
    local content = U.New("Frame", {
        Name=            "Content",
        Size=            UDim2.new(1, -NAV_W, 1, 0),
        Position=        UDim2.new(0, NAV_W, 0, 0),
        BackgroundTransparency=1,
        ClipsDescendants=true,
        ZIndex=          12,
        Parent=          body,
    })

    -- ── DRAG (topbar as handle, win as mover) ─────────────────
    U.Drag(topbar, win)
    -- Keep shadow in sync with win movement
    RunService.Heartbeat:Connect(function()
        if win.Visible then
            shadow.Position = UDim2.new(
                win.Position.X.Scale, win.Position.X.Offset - 10,
                win.Position.Y.Scale, win.Position.Y.Offset - 10)
        end
    end)

    -- ═══════════════════════════════════════════════════════
    --  FLOATING MINIMIZE ICON  — rounded-square app icon style
    -- ═══════════════════════════════════════════════════════
    -- Subtle outer glow shadow (slightly larger, behind the icon)
    local floatRing = U.New("Frame", {
        Name               = "FloatRing",
        Size               = UDim2.new(0, 64, 0, 64),
        Position           = UDim2.new(0, 8, 0, 8),
        BackgroundColor3   = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.55,
        BorderSizePixel    = 0,
        ZIndex             = 197,
        Visible            = false,
        Parent             = gui,
    })
    U.Corner(18, floatRing)   -- matches icon corner

    -- Main rounded-square icon body (dark, like in the photo)
    local floatBtn = U.New("Frame", {
        Name               = "FloatIcon",
        Size               = UDim2.new(0, 54, 0, 54),
        Position           = UDim2.new(0, 16, 0, 16),
        BackgroundColor3   = Color3.fromRGB(14, 14, 18),  -- near-black
        BackgroundTransparency = 0,
        BorderSizePixel    = 0,
        ZIndex             = 198,
        Visible            = false,
        Parent             = gui,
    })
    U.Corner(14, floatBtn)    -- iOS-style rounded square

    -- Thin accent border
    local floatStroke = U.Stroke(1, T.AccentMid, 0.2, floatBtn)

    -- ── Geometric N logo  (two diagonal strokes, like in photo) ──
    -- Left vertical bar of N
    local nLeft = U.New("Frame", {
        Size             = UDim2.new(0, 3, 0, 26),
        Position         = UDim2.new(0.5, -13, 0.5, -13),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 0.15,
        BorderSizePixel  = 0,
        ZIndex           = 200,
        Parent           = floatBtn,
    })
    U.Corner(2, nLeft)

    -- Right vertical bar of N
    local nRight = U.New("Frame", {
        Size             = UDim2.new(0, 3, 0, 26),
        Position         = UDim2.new(0.5, 10, 0.5, -13),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 0.15,
        BorderSizePixel  = 0,
        ZIndex           = 200,
        Parent           = floatBtn,
    })
    U.Corner(2, nRight)

    -- Diagonal stroke of N (top-left to bottom-right)
    local nDiag = U.New("Frame", {
        Size             = UDim2.new(0, 3, 0, 30),
        Position         = UDim2.new(0.5, -5, 0.5, -15),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 0.15,
        Rotation         = 22,   -- diagonal angle
        BorderSizePixel  = 0,
        ZIndex           = 200,
        Parent           = floatBtn,
    })
    U.Corner(2, nDiag)

    -- Tooltip pill — slides out to the right on hover
    local floatTip = U.New("Frame", {
        Size               = UDim2.new(0, 0, 0, 24),
        Position           = UDim2.new(1, 8, 0.5, -12),
        BackgroundColor3   = Color3.fromRGB(14, 14, 18),
        BackgroundTransparency = 0,
        BorderSizePixel    = 0,
        ClipsDescendants   = true,
        ZIndex             = 201,
        Visible            = false,
        Parent             = floatBtn,
    })
    U.Corner(7, floatTip)
    U.Stroke(1, T.Border, 0.3, floatTip)
    U.New("TextLabel", {
        Size               = UDim2.new(1,-12,1,0),
        Position           = UDim2.new(0,6,0,0),
        BackgroundTransparency = 1,
        Text               = winTitle,
        TextColor3         = T.Text,
        TextSize           = 10,
        Font               = Enum.Font.GothamMedium,
        ZIndex             = 202,
        Parent             = floatTip,
    })

    -- Invisible hitbox
    local floatHit = U.New("TextButton", {
        Size               = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text               = "",
        ZIndex             = 203,
        Parent             = floatBtn,
    })

    -- Hover — subtle brightness lift + tooltip slide
    floatHit.MouseEnter:Connect(function()
        U.Tw(floatBtn, TI.Fast, {BackgroundColor3 = Color3.fromRGB(22, 22, 30)})
        U.Tw(floatStroke, TI.Fast, {Color = T.Accent, Transparency = 0})
        floatTip.Visible = true
        U.Tw(floatTip, TI.Med, {Size = UDim2.new(0, 90, 0, 24)})
    end)
    floatHit.MouseLeave:Connect(function()
        U.Tw(floatBtn, TI.Fast, {BackgroundColor3 = Color3.fromRGB(14, 14, 18)})
        U.Tw(floatStroke, TI.Fast, {Color = T.AccentMid, Transparency = 0.2})
        U.Tw(floatTip, TI.Fast, {Size = UDim2.new(0, 0, 0, 24)})
        task.delay(0.14, function() floatTip.Visible = false end)
    end)
    floatHit.MouseButton1Down:Connect(function()
        U.Tw(floatBtn, TI.Fast, {BackgroundColor3 = T.AccentLow})
    end)
    floatHit.MouseButton1Up:Connect(function()
        U.Tw(floatBtn, TI.Fast, {BackgroundColor3 = Color3.fromRGB(22, 22, 30)})
    end)

    -- Keep shadow in sync when dragged
    local function syncRing()
        floatRing.Position = UDim2.new(
            floatBtn.Position.X.Scale, floatBtn.Position.X.Offset - 8,
            floatBtn.Position.Y.Scale, floatBtn.Position.Y.Offset - 8)
    end

    -- Drag (icon + shadow move together)
    do
        local drag, s0, p0 = false, nil, nil
        floatBtn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                drag = true; s0 = i.Position; p0 = floatBtn.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - s0
                floatBtn.Position = UDim2.new(
                    p0.X.Scale, p0.X.Offset + d.X,
                    p0.Y.Scale, p0.Y.Offset + d.Y)
                syncRing()
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
        end)
    end

    -- Subtle idle pulse on the N glow
    task.spawn(function()
        while floatBtn.Parent do
            if floatBtn.Visible then
                U.Tw(nLeft,  TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {BackgroundTransparency = 0.5})
                U.Tw(nRight, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {BackgroundTransparency = 0.5})
                U.Tw(nDiag,  TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {BackgroundTransparency = 0.5})
                task.wait(1.2)
                U.Tw(nLeft,  TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {BackgroundTransparency = 0.05})
                U.Tw(nRight, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {BackgroundTransparency = 0.05})
                U.Tw(nDiag,  TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {BackgroundTransparency = 0.05})
                task.wait(1.2)
            else
                task.wait(0.5)
            end
        end
    end)

    -- ═══════════════════════════════════════════════════════
    --  VISIBILITY STATE MACHINE
    -- ═══════════════════════════════════════════════════════
    local visible    = false
    local minimized  = false

    local function showMain()
        visible   = true
        minimized = false
        floatBtn.Visible = false
        win.Visible    = true
        shadow.Visible = true
        win.Size = UDim2.new(0, 0, 0, 0)
        win.Position = UDim2.new(0.5, 0, 0.5, 0)
        U.Tw(win, TI.Bounce, {
            Size     = UDim2.new(0, W, 0, H),
            Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
            BackgroundTransparency = T.BgAlpha,
        })
        U.Tw(shadow, TI.Slow, {BackgroundTransparency = 0.50})
    end

    local function hideMain(cb)
        visible = false
        U.Tw(win, TI.Med, {
            Size = UDim2.new(0, W, 0, 0),
            BackgroundTransparency = 1,
        })
        U.Tw(shadow, TI.Med, {BackgroundTransparency = 1})
        task.delay(0.22, function()
            win.Visible    = false
            shadow.Visible = false
            if cb then cb() end
        end)
    end

    local function doMinimize()
        minimized = true
        hideMain(function()
            floatBtn.Position = UDim2.new(0, 16, 0, 16)
            floatBtn.Size     = UDim2.new(0, 0, 0, 0)
            floatBtn.Visible  = true
            floatRing.Visible = true
            syncRing()
            U.Tw(floatBtn, TI.Bounce, {Size = UDim2.new(0, 54, 0, 54)})
        end)
    end

    local function doRestore()
        U.Tw(floatBtn, TI.Fast, {Size = UDim2.new(0, 0, 0, 0)})
        U.Tw(floatRing, TI.Fast, {BackgroundTransparency = 1})
        task.delay(0.14, function()
            floatBtn.Visible  = false
            floatRing.Visible = false
            floatRing.BackgroundTransparency = 0.55
            showMain()
        end)
    end

    -- Wire buttons
    minBtn.MouseButton1Click:Connect(doMinimize)
    floatHit.MouseButton1Click:Connect(doRestore)

    closeBtn.MouseButton1Click:Connect(function()
        visible   = false
        minimized = false
        floatBtn.Visible  = false
        floatRing.Visible = false
        U.Tw(win, TI.Med, {
            Size=UDim2.new(0,0,0,0),
            Position=UDim2.new(0.5,0,0.5,0),
            BackgroundTransparency=1,
        })
        U.Tw(shadow, TI.Med, {BackgroundTransparency=1})
        task.delay(0.3, function()
            pcall(function() win:Destroy() end)
            pcall(function() shadow:Destroy() end)
            pcall(function() floatBtn:Destroy() end)
            pcall(function() floatRing:Destroy() end)
        end)
    end)

    -- Toggle key
    UserInputService.InputBegan:Connect(function(i, gp)
        if not gp and i.KeyCode == toggleKey then
            if minimized then
                doRestore()
            elseif visible then
                hideMain()
            else
                showMain()
            end
        end
    end)

    -- Accent sweep (cosmetic)
    task.spawn(function()
        task.wait(0.1)
        U.Tw(accentLine,
            TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {Size = UDim2.new(1, 0, 0, 2)})
    end)

    -- ═══════════════════════════════════════════════════════
    --  WINDOW OBJECT
    -- ═══════════════════════════════════════════════════════
    local Window    = {}
    Window._Tabs    = {}
    Window._TBtns   = {}
    Window._Active  = nil

    -- Theme setter
    function Window:SetTheme(name)
        local td = Themes[name]
        if not td then return end
        for k, v in pairs(td) do T[k] = v end
        win.BackgroundColor3       = T.Bg
        topbar.BackgroundColor3    = T.Surface
        nav.BackgroundColor3       = T.Surface
        logoBadge.BackgroundColor3 = T.AccentLow
        accentLine.BackgroundColor3 = T.Accent
        floatRing.BackgroundColor3 = T.Accent
        floatBtn.BackgroundColor3  = T.Surface
        floatInner.BackgroundColor3 = T.AccentLow
        NexusUI.Notify(NexusUI, {
            Title="Theme", Text="Applied: "..name, Type="info", Duration=2
        })
    end

    -- ── CreateTab ─────────────────────────────────────────────
    function Window:CreateTab(name, glyph)
        local tab = {_Name=name, _Secs={}}

        -- Nav button
        local tbtn = U.New("TextButton", {
            Size               = UDim2.new(1, 0, 0, 26),
            BackgroundColor3   = T.SurfaceHi,
            BackgroundTransparency = 1,
            Text               = "",
            AutoButtonColor    = false,
            BorderSizePixel    = 0,
            ZIndex             = 14,
            Parent             = navScroll,
        })
        U.Corner(6, tbtn)

        -- Active indicator
        local ind = U.New("Frame", {
            Size=UDim2.new(0,2,0.5,0), Position=UDim2.new(0,0,0.25,0),
            BackgroundColor3=T.Accent, BackgroundTransparency=1,
            BorderSizePixel=0, ZIndex=15, Parent=tbtn,
        })
        U.Corner(2, ind)

        -- Icon badge
        local ibg = U.New("Frame", {
            Size=UDim2.new(0,16,0,16), Position=UDim2.new(0,7,0.5,-8),
            BackgroundColor3=T.SurfaceHiHi, BorderSizePixel=0, ZIndex=15, Parent=tbtn,
        })
        U.Corner(5, ibg)
        local iglp = U.New("TextLabel", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
            Text=glyph or name:sub(1,1):upper(),
            TextColor3=T.TextDim, TextSize=8,
            Font=Enum.Font.GothamBold, ZIndex=16, Parent=ibg,
        })

        -- Label
        local tlbl = U.New("TextLabel", {
            Size=UDim2.new(1,-28,1,0), Position=UDim2.new(0,27,0,0),
            BackgroundTransparency=1, Text=name,
            TextColor3=T.TextSub, TextSize=10,
            Font=Enum.Font.GothamMedium,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=15, Parent=tbtn,
        })

        -- Page
        local page = U.New("ScrollingFrame", {
            Name=                "Page_"..name,
            Size=                UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            ScrollBarThickness=  2,
            ScrollBarImageColor3=T.BorderHi,
            BorderSizePixel=     0,
            Visible=             false,
            ZIndex=              13,
            Parent=              content,
        })
        U.Pad(6,6,7,7, page)
        local pList = U.List(5, page)
        U.AutoCanvas(page, pList)

        -- Activate
        local function activate()
            for _, t in ipairs(Window._Tabs) do
                if t._Page then t._Page.Visible = false end
            end
            for _, r in ipairs(Window._TBtns) do
                U.Tw(r.btn, TI.Fast, {BackgroundTransparency=1})
                U.Tw(r.ibg, TI.Fast, {BackgroundColor3=T.SurfaceHiHi})
                r.iglp.TextColor3 = T.TextDim
                U.Tw(r.lbl, TI.Fast, {TextColor3=T.TextSub})
                U.Tw(r.ind, TI.Fast, {BackgroundTransparency=1})
            end
            page.Visible = true
            U.Tw(tbtn, TI.Fast, {BackgroundTransparency=0.80})
            U.Tw(ibg,  TI.Fast, {BackgroundColor3=T.AccentLow})
            iglp.TextColor3 = T.Accent
            U.Tw(tlbl, TI.Fast, {TextColor3=T.Text})
            U.Tw(ind,  TI.Fast, {BackgroundTransparency=0})
            Window._Active = tab
        end

        table.insert(Window._TBtns, {btn=tbtn, ibg=ibg, iglp=iglp, lbl=tlbl, ind=ind})

        tbtn.MouseButton1Click:Connect(activate)
        tbtn.MouseEnter:Connect(function()
            if Window._Active ~= tab then
                U.Tw(tbtn, TI.Fast, {BackgroundTransparency=0.88})
            end
        end)
        tbtn.MouseLeave:Connect(function()
            if Window._Active ~= tab then
                U.Tw(tbtn, TI.Fast, {BackgroundTransparency=1})
            end
        end)

        tab._Page     = page
        tab._PList    = pList
        tab._Activate = activate
        table.insert(Window._Tabs, tab)
        if #Window._Tabs == 1 then task.spawn(activate) end

        -- ── CreateSection  (collapsible) ──────────────────────
        function tab:CreateSection(cfgOrName)
            -- Accept either a string or a table  {Name="..."}
            local secName
            if type(cfgOrName) == "string" then
                secName = cfgOrName
            else
                cfgOrName = cfgOrName or {}
                secName   = cfgOrName.Name or "Section"
            end

            local sec         = {}
            local isOpen      = true   -- starts expanded
            local HEADER_H    = 26     -- fixed header height

            -- ── Outer wrapper (AutomaticSize disabled — we control height manually)
            local sf = U.New("Frame", {
                Name             = "Sec_"..secName,
                Size             = UDim2.new(1, 0, 0, 0),  -- height set after build
                BackgroundColor3 = T.Surface,
                BackgroundTransparency = T.SurfAlpha,
                BorderSizePixel  = 0,
                ClipsDescendants = true,         -- clips body when collapsing
                ZIndex           = 14,
                Parent           = page,
            })
            U.Corner(8, sf)
            U.Stroke(1, T.Border, 0.38, sf)

            -- ── Clickable header row ─────────────────────────
            local hdr = U.New("TextButton", {
                Name             = "Header",
                Size             = UDim2.new(1, 0, 0, HEADER_H),
                BackgroundColor3 = T.SurfaceHi,
                BackgroundTransparency = 0.35,
                Text             = "",
                AutoButtonColor  = false,
                BorderSizePixel  = 0,
                ZIndex           = 15,
                Parent           = sf,
            })
            -- Top-corner mask so header corners match sf
            U.Corner(8, hdr)

            -- Accent left bar on header
            local hdrBar = U.New("Frame", {
                Size             = UDim2.new(0, 2, 0.55, 0),
                Position         = UDim2.new(0, 0, 0.225, 0),
                BackgroundColor3 = T.Accent,
                BackgroundTransparency = 0.3,
                BorderSizePixel  = 0,
                ZIndex           = 16,
                Parent           = hdr,
            })
            U.Corner(2, hdrBar)

            -- Section name label
            U.New("TextLabel", {
                Size             = UDim2.new(1, -34, 1, 0),
                Position         = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text             = secName:upper(),
                TextColor3       = T.TextSub,
                TextSize         = 9,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 16,
                Parent           = hdr,
            })

            -- Arrow chevron (rotates 180° when collapsed)
            local arrow = U.New("TextLabel", {
                Size             = UDim2.new(0, 20, 1, 0),
                Position         = UDim2.new(1, -22, 0, 0),
                BackgroundTransparency = 1,
                Text             = "⌄",
                TextColor3       = T.TextDim,
                TextSize         = 13,
                Font             = Enum.Font.GothamBold,
                ZIndex           = 16,
                Parent           = hdr,
            })

            -- Header separator line (shown when open)
            local hdrLine = U.New("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = T.Border,
                BackgroundTransparency = 0.45,
                BorderSizePixel  = 0,
                ZIndex           = 15,
                Parent           = hdr,
            })

            -- ── Body container (items live here) ─────────────
            local body = U.New("Frame", {
                Name             = "Body",
                Size             = UDim2.new(1, 0, 0, 0),   -- height auto below
                Position         = UDim2.new(0, 0, 0, HEADER_H),
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                AutomaticSize    = Enum.AutomaticSize.Y,
                ZIndex           = 15,
                Parent           = sf,
            })
            U.Pad(6, 8, 8, 8, body)
            local sl = U.List(5, body)

            -- Compute and set sf height based on body content
            local function recalcHeight()
                local bodyH = body.AbsoluteSize.Y
                sf.Size = UDim2.new(1, 0, 0, HEADER_H + (isOpen and bodyH or 0))
            end

            -- Body size changes → recompute wrapper
            body:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                if isOpen then recalcHeight() end
            end)

            -- ── Toggle collapse ───────────────────────────────
            local function setOpen(state, animate)
                isOpen = state
                local targetBodyH = isOpen and body.AbsoluteSize.Y or 0
                local targetSfH   = HEADER_H + targetBodyH

                if animate then
                    -- Arrow rotates
                    U.Tw(arrow, TI.Med, {Rotation = isOpen and 0 or -90})
                    U.Tw(hdrBar, TI.Fast, {BackgroundTransparency = isOpen and 0.3 or 0.6})
                    -- Smoothly resize the outer frame
                    U.Tw(sf, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                        {Size = UDim2.new(1, 0, 0, targetSfH)})
                    -- Fade separator
                    U.Tw(hdrLine, TI.Fast, {BackgroundTransparency = isOpen and 0.45 or 1})
                else
                    arrow.Rotation = isOpen and 0 or -90
                    sf.Size        = UDim2.new(1, 0, 0, targetSfH)
                    hdrLine.BackgroundTransparency = isOpen and 0.45 or 1
                end
            end

            -- Initial sizing (after a frame so AutomaticSize settles)
            task.defer(function()
                setOpen(true, false)
            end)

            -- Header hover effects
            hdr.MouseEnter:Connect(function()
                U.Tw(hdr, TI.Fast, {BackgroundTransparency = 0.20})
                U.Tw(arrow, TI.Fast, {TextColor3 = T.Accent})
            end)
            hdr.MouseLeave:Connect(function()
                U.Tw(hdr, TI.Fast, {BackgroundTransparency = 0.35})
                U.Tw(arrow, TI.Fast, {TextColor3 = T.TextDim})
            end)
            hdr.MouseButton1Down:Connect(function()
                U.Tw(hdr, TI.Fast, {BackgroundColor3 = T.AccentLow, BackgroundTransparency = 0})
            end)
            hdr.MouseButton1Up:Connect(function()
                U.Tw(hdr, TI.Fast, {BackgroundColor3 = T.SurfaceHi, BackgroundTransparency = 0.20})
            end)
            hdr.MouseButton1Click:Connect(function()
                setOpen(not isOpen, true)
            end)

            sec._Frame  = sf
            sec._Body   = body
            sec._List   = sl

            -- Public collapse/expand API
            function sec:Collapse() setOpen(false, true) end
            function sec:Expand()   setOpen(true,  true) end
            function sec:Toggle()   setOpen(not isOpen, true) end

            -- ────────────────────────────────────────────────
            --  SEPARATOR
            -- ────────────────────────────────────────────────
            function sec:CreateSeparator()
                U.New("Frame", {
                    Size=UDim2.new(1,0,0,1),
                    BackgroundColor3=T.Border, BackgroundTransparency=0.45,
                    BorderSizePixel=0, ZIndex=15, Parent=body,
                })
            end

            -- ────────────────────────────────────────────────
            --  LABEL
            -- ────────────────────────────────────────────────
            function sec:CreateLabel(c2)
                c2 = c2 or {}
                local l = U.New("TextLabel", {
                    Size=UDim2.new(1,0,0,18), AutomaticSize=Enum.AutomaticSize.Y,
                    BackgroundTransparency=1, Text=c2.Text or "Label",
                    TextColor3=c2.Color or T.TextSub, TextSize=c2.Size or 11,
                    Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,
                    TextWrapped=true, ZIndex=15, Parent=body,
                })
                local api = {}
                function api:Set(t2) l.Text = t2 end
                return api
            end

            -- ────────────────────────────────────────────────
            --  BUTTON  (with click ripple + hover glow bar)
            -- ────────────────────────────────────────────────
            function sec:CreateButton(c2)
                c2 = c2 or {}
                local nm = c2.Name     or "Button"
                local cb = c2.Callback or function() end

                local row = U.New("Frame", {
                    Size=UDim2.new(1,0,0,30),
                    BackgroundColor3=T.SurfaceHi, BackgroundTransparency=0.25,
                    BorderSizePixel=0, ZIndex=15, Parent=body,
                })
                U.Corner(6, row)
                U.Stroke(1, T.Border, 0.50, row)

                -- Left glow bar (hidden until hover)
                local gbar = U.New("Frame", {
                    Size=UDim2.new(0,2,0.55,0), Position=UDim2.new(0,0,0.225,0),
                    BackgroundColor3=T.Accent, BackgroundTransparency=1,
                    BorderSizePixel=0, ZIndex=16, Parent=row,
                })
                U.Corner(2, gbar)

                -- Label
                U.New("TextLabel", {
                    Size=UDim2.new(1,-24,1,0), Position=UDim2.new(0,10,0,0),
                    BackgroundTransparency=1, Text=nm, TextColor3=T.Text,
                    TextSize=11, Font=Enum.Font.GothamMedium,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=16, Parent=row,
                })

                -- Arrow
                U.New("TextLabel", {
                    Size=UDim2.new(0,14,1,0), Position=UDim2.new(1,-18,0,0),
                    BackgroundTransparency=1, Text="›", TextColor3=T.TextDim,
                    TextSize=13, Font=Enum.Font.GothamBold, ZIndex=16, Parent=row,
                })

                local hit = U.New("TextButton", {
                    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                    Text="", ZIndex=17, Parent=row,
                })

                hit.MouseEnter:Connect(function()
                    U.Tw(row,  TI.Fast, {BackgroundTransparency=0.10, BackgroundColor3=T.SurfaceHiHi})
                    U.Tw(gbar, TI.Fast, {BackgroundTransparency=0})
                end)
                hit.MouseLeave:Connect(function()
                    U.Tw(row,  TI.Fast, {BackgroundTransparency=0.25, BackgroundColor3=T.SurfaceHi})
                    U.Tw(gbar, TI.Fast, {BackgroundTransparency=1})
                end)
                hit.MouseButton1Down:Connect(function()
                    U.Tw(row, TI.Fast, {BackgroundColor3=T.AccentLow, BackgroundTransparency=0})
                end)
                hit.MouseButton1Up:Connect(function()
                    U.Tw(row, TI.Fast, {BackgroundColor3=T.SurfaceHiHi, BackgroundTransparency=0.10})
                end)
                hit.MouseButton1Click:Connect(function()
                    pcall(cb)
                end)
            end

            -- ────────────────────────────────────────────────
            --  TOGGLE  (smooth pill animation)
            -- ────────────────────────────────────────────────
            function sec:CreateToggle(c2)
                c2  = c2 or {}
                local nm  = c2.Name     or "Toggle"
                local def = c2.Default  or false
                local cb  = c2.Callback or function() end
                local st  = def

                local row = U.New("Frame", {
                    Size=UDim2.new(1,0,0,30),
                    BackgroundColor3=T.SurfaceHi, BackgroundTransparency=0.25,
                    BorderSizePixel=0, ZIndex=15, Parent=body,
                })
                U.Corner(6, row)
                U.Stroke(1, T.Border, 0.50, row)

                U.New("TextLabel", {
                    Size=UDim2.new(1,-50,1,0), Position=UDim2.new(0,10,0,0),
                    BackgroundTransparency=1, Text=nm, TextColor3=T.Text,
                    TextSize=11, Font=Enum.Font.GothamMedium,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=16, Parent=row,
                })

                -- Status label ("ON" / "OFF")
                local stLbl = U.New("TextLabel", {
                    Size=UDim2.new(0,24,1,0), Position=UDim2.new(1,-68,0,0),
                    BackgroundTransparency=1,
                    Text= st and "ON" or "OFF",
                    TextColor3= st and T.Accent or T.TextDim,
                    TextSize=9, Font=Enum.Font.GothamBold, ZIndex=16, Parent=row,
                })

                -- Pill
                local pill = U.New("Frame", {
                    Size=UDim2.new(0,32,0,16), Position=UDim2.new(1,-40,0.5,-8),
                    BackgroundColor3= st and T.Accent or T.SurfaceHiHi,
                    BorderSizePixel=0, ZIndex=16, Parent=row,
                })
                U.Corner(10, pill)
                local pStr = U.Stroke(1, st and T.AccentMid or T.Border, 0.2, pill)

                -- Knob
                local knob = U.New("Frame", {
                    Size=UDim2.new(0,11,0,11),
                    Position= st and UDim2.new(1,-13,0.5,-5.5) or UDim2.new(0,2,0.5,-5.5),
                    BackgroundColor3=Color3.fromRGB(228,228,238),
                    BorderSizePixel=0, ZIndex=17, Parent=pill,
                })
                U.Corner(10, knob)

                local function refresh()
                    U.Tw(pill,  TI.Med, {BackgroundColor3= st and T.Accent or T.SurfaceHiHi})
                    U.Tw(knob,  TI.Med, {
                        Position= st and UDim2.new(1,-13,0.5,-5.5) or UDim2.new(0,2,0.5,-5.5)
                    })
                    pStr.Color = st and T.AccentMid or T.Border
                    stLbl.Text       = st and "ON" or "OFF"
                    stLbl.TextColor3 = st and T.Accent or T.TextDim
                end

                local hit = U.New("TextButton", {
                    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                    Text="", ZIndex=18, Parent=row,
                })
                hit.MouseEnter:Connect(function()
                    U.Tw(row, TI.Fast, {BackgroundTransparency=0.12})
                end)
                hit.MouseLeave:Connect(function()
                    U.Tw(row, TI.Fast, {BackgroundTransparency=0.25})
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

            -- ────────────────────────────────────────────────
            --  SLIDER  (drag knob, live value display)
            -- ────────────────────────────────────────────────
            function sec:CreateSlider(c2)
                c2  = c2 or {}
                local nm  = c2.Name     or "Slider"
                local mn  = c2.Min      or 0
                local mx  = c2.Max      or 100
                local def = c2.Default  or mn
                local suf = c2.Suffix   or ""
                local dec = c2.Decimals or 0
                local cb  = c2.Callback or function() end
                local val = math.clamp(def, mn, mx)

                local wrap = U.New("Frame", {
                    Size=UDim2.new(1,0,0,44),
                    BackgroundColor3=T.SurfaceHi, BackgroundTransparency=0.25,
                    BorderSizePixel=0, ZIndex=15, Parent=body,
                })
                U.Corner(6, wrap)
                U.Stroke(1, T.Border, 0.50, wrap)

                -- Name
                U.New("TextLabel", {
                    Size=UDim2.new(0.58,0,0,19), Position=UDim2.new(0,10,0,4),
                    BackgroundTransparency=1, Text=nm, TextColor3=T.Text,
                    TextSize=11, Font=Enum.Font.GothamMedium,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=16, Parent=wrap,
                })

                -- Value display
                local vLbl = U.New("TextLabel", {
                    Size=UDim2.new(0.42,-10,0,19), Position=UDim2.new(0.58,0,0,4),
                    BackgroundTransparency=1,
                    Text=tostring(val)..suf,
                    TextColor3=T.Accent, TextSize=11, Font=Enum.Font.GothamBold,
                    TextXAlignment=Enum.TextXAlignment.Right, ZIndex=16, Parent=wrap,
                })

                -- Track
                local track = U.New("Frame", {
                    Size=UDim2.new(1,-20,0,4), Position=UDim2.new(0,10,0,31),
                    BackgroundColor3=T.SurfaceHiHi, BorderSizePixel=0, ZIndex=16, Parent=wrap,
                })
                U.Corner(4, track)

                local r0 = (val-mn)/(mx-mn)

                local fill = U.New("Frame", {
                    Size=UDim2.new(r0,0,1,0),
                    BackgroundColor3=T.Accent, BorderSizePixel=0, ZIndex=17, Parent=track,
                })
                U.Corner(4, fill)

                -- Knob
                local knob = U.New("Frame", {
                    Size=UDim2.new(0,12,0,12),
                    Position=UDim2.new(r0,-6,0.5,-6),
                    BackgroundColor3=Color3.fromRGB(228,228,238),
                    BorderSizePixel=0, ZIndex=18, Parent=track,
                })
                U.Corner(10, knob)

                -- Subtle knob glow
                local kGlow = U.New("Frame", {
                    Size=UDim2.new(0,18,0,18), Position=UDim2.new(r0,-9,0.5,-9),
                    BackgroundColor3=T.Accent, BackgroundTransparency=0.72,
                    BorderSizePixel=0, ZIndex=17, Parent=track,
                })
                U.Corner(10, kGlow)

                local sliding = false

                local function upd(mx2)
                    local abs = track.AbsolutePosition
                    local sz  = track.AbsoluteSize
                    local r   = math.clamp((mx2 - abs.X) / sz.X, 0, 1)
                    local raw = mn + (mx-mn)*r
                    local fmt = 10^dec
                    val = math.floor(raw*fmt+0.5)/fmt
                    local rv  = (val-mn)/(mx-mn)
                    U.Tw(fill,  TI.Fast, {Size     = UDim2.new(rv, 0, 1, 0)})
                    U.Tw(knob,  TI.Fast, {Position = UDim2.new(rv,-6,0.5,-6)})
                    U.Tw(kGlow, TI.Fast, {Position = UDim2.new(rv,-9,0.5,-9)})
                    vLbl.Text = tostring(val)..suf
                    pcall(cb, val)
                end

                local hit = U.New("TextButton", {
                    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                    Text="", ZIndex=19, Parent=track,
                })
                hit.MouseButton1Down:Connect(function(x)
                    sliding = true
                    U.Tw(knob, TI.Fast, {Size=UDim2.new(0,14,0,14), Position=UDim2.new((val-mn)/(mx-mn),-7,0.5,-7)})
                    upd(x)
                end)
                hit.MouseButton1Up:Connect(function()
                    sliding = false
                    U.Tw(knob, TI.Fast, {Size=UDim2.new(0,12,0,12)})
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                        upd(i.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                        U.Tw(knob, TI.Fast, {Size=UDim2.new(0,12,0,12)})
                    end
                end)

                local api = {}
                function api:Set(v)
                    val = math.clamp(v, mn, mx)
                    local rv = (val-mn)/(mx-mn)
                    fill.Size     = UDim2.new(rv,0,1,0)
                    knob.Position = UDim2.new(rv,-6,0.5,-6)
                    kGlow.Position= UDim2.new(rv,-9,0.5,-9)
                    vLbl.Text     = tostring(val)..suf
                end
                function api:Get() return val end
                return api
            end

            -- ────────────────────────────────────────────────
            --  DROPDOWN
            -- ────────────────────────────────────────────────
            function sec:CreateDropdown(c2)
                c2   = c2 or {}
                local nm   = c2.Name     or "Dropdown"
                local opts = c2.Options  or {}
                local def  = c2.Default  or (opts[1] or "")
                local cb   = c2.Callback or function() end
                local sel  = def
                local open = false

                local wrap = U.New("Frame", {
                    Size=UDim2.new(1,0,0,30),
                    BackgroundTransparency=1, ZIndex=20,
                    ClipsDescendants=false, Parent=body,
                })

                local row = U.New("Frame", {
                    Size=UDim2.new(1,0,0,30),
                    BackgroundColor3=T.SurfaceHi, BackgroundTransparency=0.25,
                    BorderSizePixel=0, ZIndex=21, Parent=wrap,
                })
                U.Corner(6, row)
                U.Stroke(1, T.Border, 0.50, row)

                U.New("TextLabel", {
                    Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0,10,0,0),
                    BackgroundTransparency=1, Text=nm, TextColor3=T.Text,
                    TextSize=11, Font=Enum.Font.GothamMedium,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=22, Parent=row,
                })
                local selLbl = U.New("TextLabel", {
                    Size=UDim2.new(0.5,-20,1,0), Position=UDim2.new(0.5,0,0,0),
                    BackgroundTransparency=1, Text=sel,
                    TextColor3=T.Accent, TextSize=11, Font=Enum.Font.GothamMedium,
                    TextXAlignment=Enum.TextXAlignment.Right, ZIndex=22, Parent=row,
                })
                local arw = U.New("TextLabel", {
                    Size=UDim2.new(0,14,1,0), Position=UDim2.new(1,-16,0,0),
                    BackgroundTransparency=1, Text="▾",
                    TextColor3=T.TextDim, TextSize=10, Font=Enum.Font.GothamBold,
                    ZIndex=22, Parent=row,
                })

                local iH  = 24
                local pH  = #opts*iH + 8
                local panel = U.New("Frame", {
                    Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,0,1,3),
                    BackgroundColor3=T.Surface, BackgroundTransparency=0.08,
                    BorderSizePixel=0, ClipsDescendants=true,
                    ZIndex=25, Visible=false, Parent=row,
                })
                U.Corner(6, panel)
                U.Stroke(1, T.Border, 0.30, panel)
                U.Pad(4,4,4,4, panel)
                U.List(2, panel)

                for _, opt in ipairs(opts) do
                    local itm = U.New("TextButton", {
                        Size=UDim2.new(1,0,0,iH-2),
                        BackgroundColor3=T.SurfaceHi, BackgroundTransparency=1,
                        Text="", AutoButtonColor=false, BorderSizePixel=0,
                        ZIndex=26, Parent=panel,
                    })
                    U.Corner(5, itm)
                    local il = U.New("TextLabel", {
                        Size=UDim2.new(1,-8,1,0), Position=UDim2.new(0,6,0,0),
                        BackgroundTransparency=1, Text=opt,
                        TextColor3= opt==sel and T.Accent or T.TextSub,
                        TextSize=11, Font=Enum.Font.GothamMedium,
                        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=27, Parent=itm,
                    })
                    itm.MouseEnter:Connect(function()
                        U.Tw(itm, TI.Fast, {BackgroundTransparency=0})
                    end)
                    itm.MouseLeave:Connect(function()
                        U.Tw(itm, TI.Fast, {BackgroundTransparency=1})
                    end)
                    itm.MouseButton1Click:Connect(function()
                        sel = opt; selLbl.Text = opt
                        for _, c in ipairs(panel:GetChildren()) do
                            if c:IsA("TextButton") then
                                local l2 = c:FindFirstChildWhichIsA("TextLabel")
                                if l2 then l2.TextColor3 = l2.Text==opt and T.Accent or T.TextSub end
                            end
                        end
                        open = false
                        U.Tw(panel, TI.Med, {Size=UDim2.new(1,0,0,0)})
                        U.Tw(arw,   TI.Fast, {Rotation=0})
                        task.delay(0.22, function() panel.Visible=false end)
                        wrap.Size = UDim2.new(1,0,0,30)
                        pcall(cb, sel)
                    end)
                end

                local hit = U.New("TextButton", {
                    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                    Text="", ZIndex=23, Parent=row,
                })
                hit.MouseEnter:Connect(function()
                    U.Tw(row, TI.Fast, {BackgroundTransparency=0.12})
                end)
                hit.MouseLeave:Connect(function()
                    U.Tw(row, TI.Fast, {BackgroundTransparency=0.25})
                end)
                hit.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        panel.Visible=true; panel.Size=UDim2.new(1,0,0,0)
                        U.Tw(panel, TI.Med, {Size=UDim2.new(1,0,0,pH)})
                        U.Tw(arw,   TI.Fast, {Rotation=180})
                        wrap.Size = UDim2.new(1,0,0,30+pH+6)
                    else
                        U.Tw(panel, TI.Med, {Size=UDim2.new(1,0,0,0)})
                        U.Tw(arw,   TI.Fast, {Rotation=0})
                        task.delay(0.22, function() panel.Visible=false end)
                        wrap.Size = UDim2.new(1,0,0,30)
                    end
                end)

                local api = {}
                function api:Set(v) sel=v; selLbl.Text=v end
                function api:Get() return sel end
                return api
            end

            -- ────────────────────────────────────────────────
            --  TEXTBOX
            -- ────────────────────────────────────────────────
            function sec:CreateTextbox(c2)
                c2 = c2 or {}
                local nm  = c2.Name        or "Textbox"
                local ph  = c2.Placeholder or "Enter value..."
                local def = c2.Default     or ""
                local cb  = c2.Callback    or function() end

                local wrap = U.New("Frame", {
                    Size=UDim2.new(1,0,0,44),
                    BackgroundColor3=T.SurfaceHi, BackgroundTransparency=0.25,
                    BorderSizePixel=0, ZIndex=15, Parent=body,
                })
                U.Corner(6, wrap)
                U.Stroke(1, T.Border, 0.50, wrap)

                U.New("TextLabel", {
                    Size=UDim2.new(1,-10,0,17), Position=UDim2.new(0,10,0,4),
                    BackgroundTransparency=1, Text=nm, TextColor3=T.Text,
                    TextSize=11, Font=Enum.Font.GothamMedium,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=16, Parent=wrap,
                })
                local ibg = U.New("Frame", {
                    Size=UDim2.new(1,-20,0,17), Position=UDim2.new(0,10,0,23),
                    BackgroundColor3=T.Bg, BackgroundTransparency=0.10,
                    BorderSizePixel=0, ZIndex=16, Parent=wrap,
                })
                U.Corner(5, ibg)
                local iStr = U.Stroke(1, T.Border, 0.40, ibg)

                local box = U.New("TextBox", {
                    Size=UDim2.new(1,-10,1,0), Position=UDim2.new(0,6,0,0),
                    BackgroundTransparency=1, Text=def,
                    PlaceholderText=ph, PlaceholderColor3=T.TextDim,
                    TextColor3=T.Text, TextSize=11, Font=Enum.Font.Gotham,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    ClearTextOnFocus=false, ZIndex=17, Parent=ibg,
                })
                box.Focused:Connect(function()
                    U.Tw(ibg, TI.Fast, {BackgroundColor3=T.SurfaceHi})
                    iStr.Color=T.Accent; iStr.Transparency=0
                end)
                box.FocusLost:Connect(function(enter)
                    U.Tw(ibg, TI.Fast, {BackgroundColor3=T.Bg})
                    iStr.Color=T.Border; iStr.Transparency=0.40
                    if enter then pcall(cb, box.Text) end
                end)

                local api = {}
                function api:Set(v) box.Text=v end
                function api:Get() return box.Text end
                return api
            end

            -- ────────────────────────────────────────────────
            --  KEYBIND
            -- ────────────────────────────────────────────────
            function sec:CreateKeybind(c2)
                c2  = c2 or {}
                local nm  = c2.Name     or "Keybind"
                local def = c2.Default  or Enum.KeyCode.Unknown
                local cb  = c2.Callback or function() end
                local cur = def
                local lst = false

                local row = U.New("Frame", {
                    Size=UDim2.new(1,0,0,30),
                    BackgroundColor3=T.SurfaceHi, BackgroundTransparency=0.25,
                    BorderSizePixel=0, ZIndex=15, Parent=body,
                })
                U.Corner(6, row)
                U.Stroke(1, T.Border, 0.50, row)

                U.New("TextLabel", {
                    Size=UDim2.new(0.6,0,1,0), Position=UDim2.new(0,10,0,0),
                    BackgroundTransparency=1, Text=nm, TextColor3=T.Text,
                    TextSize=11, Font=Enum.Font.GothamMedium,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=16, Parent=row,
                })

                local badge = U.New("Frame", {
                    Size=UDim2.new(0,68,0,17), Position=UDim2.new(1,-74,0.5,-8.5),
                    BackgroundColor3=T.SurfaceHiHi, BorderSizePixel=0, ZIndex=16, Parent=row,
                })
                U.Corner(5, badge)
                local bStr = U.Stroke(1, T.Border, 0.30, badge)

                local kLbl = U.New("TextLabel", {
                    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                    Text= cur==Enum.KeyCode.Unknown and "NONE" or cur.Name,
                    TextColor3=T.Accent, TextSize=9, Font=Enum.Font.GothamBold,
                    ZIndex=17, Parent=badge,
                })

                local hit = U.New("TextButton", {
                    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                    Text="", ZIndex=18, Parent=row,
                })
                hit.MouseEnter:Connect(function() U.Tw(row, TI.Fast, {BackgroundTransparency=0.12}) end)
                hit.MouseLeave:Connect(function() U.Tw(row, TI.Fast, {BackgroundTransparency=0.25}) end)
                hit.MouseButton1Click:Connect(function()
                    lst=true; kLbl.Text="..."; kLbl.TextColor3=T.Warn
                    U.Tw(badge, TI.Fast, {BackgroundColor3=T.AccentLow})
                    bStr.Color=T.Accent; bStr.Transparency=0
                end)
                UserInputService.InputBegan:Connect(function(i, gp)
                    if not gp and lst and i.UserInputType==Enum.UserInputType.Keyboard then
                        lst=false; cur=i.KeyCode
                        kLbl.Text=cur.Name; kLbl.TextColor3=T.Accent
                        U.Tw(badge, TI.Fast, {BackgroundColor3=T.SurfaceHiHi})
                        bStr.Color=T.Border; bStr.Transparency=0.30
                        pcall(cb, cur)
                    elseif not gp and not lst and i.KeyCode==cur then
                        pcall(cb, cur)
                    end
                end)

                local api = {}
                function api:Set(k) cur=k; kLbl.Text=k.Name end
                function api:Get() return cur end
                return api
            end

            -- ────────────────────────────────────────────────
            --  COLOR INDICATOR
            -- ────────────────────────────────────────────────
            function sec:CreateColorIndicator(c2)
                c2 = c2 or {}
                local nm  = c2.Name  or "Color"
                local col = c2.Color or T.Accent

                local row = U.New("Frame", {
                    Size=UDim2.new(1,0,0,30),
                    BackgroundColor3=T.SurfaceHi, BackgroundTransparency=0.25,
                    BorderSizePixel=0, ZIndex=15, Parent=body,
                })
                U.Corner(6, row)
                U.Stroke(1, T.Border, 0.50, row)

                U.New("TextLabel", {
                    Size=UDim2.new(0.6,0,1,0), Position=UDim2.new(0,10,0,0),
                    BackgroundTransparency=1, Text=nm, TextColor3=T.Text,
                    TextSize=11, Font=Enum.Font.GothamMedium,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=16, Parent=row,
                })
                local hex = U.New("TextLabel", {
                    Size=UDim2.new(0,56,1,0), Position=UDim2.new(1,-84,0,0),
                    BackgroundTransparency=1,
                    Text=string.format("#%02X%02X%02X",
                        math.floor(col.R*255), math.floor(col.G*255), math.floor(col.B*255)),
                    TextColor3=T.TextSub, TextSize=10, Font=Enum.Font.GothamMedium,
                    ZIndex=16, Parent=row,
                })
                local sw = U.New("Frame", {
                    Size=UDim2.new(0,18,0,18), Position=UDim2.new(1,-24,0.5,-9),
                    BackgroundColor3=col, BorderSizePixel=0, ZIndex=16, Parent=row,
                })
                U.Corner(5, sw)
                U.Stroke(1, T.Border, 0.30, sw)

                local api = {}
                function api:Set(c)
                    sw.BackgroundColor3=c
                    hex.Text=string.format("#%02X%02X%02X",
                        math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
                end
                function api:Get() return sw.BackgroundColor3 end
                return api
            end

            -- ────────────────────────────────────────────────
            --  THEME PICKER (dot swatches)
            -- ────────────────────────────────────────────────
            function sec:CreateThemePicker()
                local names  = {"Dark","Cyber B&W","KRNL","Soft Dark"}
                local colors = {
                    ["Dark"]      = Color3.fromRGB(80,220,255),
                    ["Cyber B&W"] = Color3.fromRGB(210,210,210),
                    ["KRNL"]      = Color3.fromRGB(136,98,255),
                    ["Soft Dark"] = Color3.fromRGB(98,198,168),
                }

                local row = U.New("Frame", {
                    Size=UDim2.new(1,0,0,30),
                    BackgroundColor3=T.SurfaceHi, BackgroundTransparency=0.25,
                    BorderSizePixel=0, ZIndex=15, Parent=body,
                })
                U.Corner(6, row)
                U.Stroke(1, T.Border, 0.50, row)

                U.New("TextLabel", {
                    Size=UDim2.new(0.42,0,1,0), Position=UDim2.new(0,10,0,0),
                    BackgroundTransparency=1, Text="Theme",
                    TextColor3=T.Text, TextSize=11, Font=Enum.Font.GothamMedium,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=16, Parent=row,
                })

                local dotRow = U.New("Frame", {
                    Size=UDim2.new(0.58,-10,1,0), Position=UDim2.new(0.42,0,0,0),
                    BackgroundTransparency=1, ZIndex=16, Parent=row,
                })
                U.List(7, dotRow, Enum.FillDirection.Horizontal,
                    Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

                for _, tn in ipairs(names) do
                    local dot = U.New("TextButton", {
                        Size=UDim2.new(0,15,0,15),
                        BackgroundColor3=colors[tn], BackgroundTransparency=0.25,
                        Text="", AutoButtonColor=false, BorderSizePixel=0,
                        ZIndex=17, Parent=dotRow,
                    })
                    U.Corner(10, dot)
                    U.Stroke(1, T.Border, 0.40, dot)
                    dot.MouseEnter:Connect(function()
                        U.Tw(dot, TI.Fast, {BackgroundTransparency=0, Size=UDim2.new(0,17,0,17)})
                    end)
                    dot.MouseLeave:Connect(function()
                        U.Tw(dot, TI.Fast, {BackgroundTransparency=0.25, Size=UDim2.new(0,15,0,15)})
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

    -- ── Reveal after loader ───────────────────────────────────
    local function reveal()
        win.Size     = UDim2.new(0, 0, 0, 0)
        win.Position = UDim2.new(0.5, 0, 0.5, 0)
        win.Visible  = true
        shadow.Visible = true
        visible      = true
        U.Tw(win, TI.Bounce, {
            Size               = UDim2.new(0, W, 0, H),
            Position           = UDim2.new(0.5, -W/2, 0.5, -H/2),
            BackgroundTransparency = T.BgAlpha,
        })
        U.Tw(shadow, TI.Slow, {BackgroundTransparency=0.50})
    end

    if useLoader then
        task.spawn(function()
            NexusUI._Loader(NexusUI, gui, loaderTitle, reveal)
        end)
    else
        task.spawn(function() task.wait(0.05); reveal() end)
    end

    return Window
end -- CreateWindow

-- ═══════════════════════════════════════════════════════════
--  EXPORT
-- ═══════════════════════════════════════════════════════════
local Library   = setmetatable({}, NexusUI)
Library.__index = Library

function Library:CreateWindow(cfg)
    return NexusUI.CreateWindow(self, cfg)
end
function Library:Notify(cfg)
    return NexusUI.Notify(self, cfg)
end

return Library
