-- ═══════════════════════════════════════════════════════════════
--    NATEIRA HUB — UI LIBRARY v1.0
--    Theme  : Cyber Black & White
--    Author : NateiraHub
--    Game   : Fisch (Roblox)
-- ═══════════════════════════════════════════════════════════════

local NateiraHub = {}
NateiraHub.__index = NateiraHub

-- ── Services ──────────────────────────────────────────────────
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local RunService      = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ── Theme ─────────────────────────────────────────────────────
local T = {
    BG          = Color3.fromRGB(10,  10,  10 ),
    Surface     = Color3.fromRGB(17,  17,  17 ),
    SurfaceAlt  = Color3.fromRGB(24,  24,  24 ),
    Border      = Color3.fromRGB(42,  42,  42 ),
    Accent      = Color3.fromRGB(255, 255, 255),
    AccentDim   = Color3.fromRGB(192, 192, 192),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextMuted   = Color3.fromRGB(100, 100, 100),
    ToggleOn    = Color3.fromRGB(255, 255, 255),
    ToggleOff   = Color3.fromRGB(28,  28,  28 ),
    SliderTrack = Color3.fromRGB(34,  34,  34 ),
    Danger      = Color3.fromRGB(255, 80,  80 ),
    Success     = Color3.fromRGB(80,  220, 120),
    Warning     = Color3.fromRGB(255, 200, 60 ),
}

-- ── Helpers ───────────────────────────────────────────────────
local function Tween(obj, props, t, style, dir)
    local ti = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, ti, props):Play()
end

local function New(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local function Corner(p, r)
    return New("UICorner", {CornerRadius = UDim.new(0, r or 6)}, p)
end

local function Stroke(p, color, thick)
    return New("UIStroke", {Color = color or T.Border, Thickness = thick or 1}, p)
end

local function Padding(p, top, bot, left, right)
    return New("UIPadding", {
        PaddingTop    = UDim.new(0, top   or 4),
        PaddingBottom = UDim.new(0, bot   or 4),
        PaddingLeft   = UDim.new(0, left  or 8),
        PaddingRight  = UDim.new(0, right or 8),
    }, p)
end

local function ListLayout(p, dir, pad, halign, valign)
    return New("UIListLayout", {
        FillDirection      = dir    or Enum.FillDirection.Vertical,
        Padding            = UDim.new(0, pad or 0),
        HorizontalAlignment= halign or Enum.HorizontalAlignment.Left,
        VerticalAlignment  = valign or Enum.VerticalAlignment.Top,
        SortOrder          = Enum.SortOrder.LayoutOrder,
    }, p)
end

-- ── Init Library ──────────────────────────────────────────────
function NateiraHub.new()
    local self = setmetatable({}, NateiraHub)

    -- safely parent the gui
    local gui = Instance.new("ScreenGui")
    gui.Name             = "NateiraHub"
    gui.ResetOnSpawn     = false
    gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder     = 999
    gui.IgnoreGuiInset   = true

    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    self.Gui      = gui
    self.Windows  = {}
    return self
end

-- ── Create Window ─────────────────────────────────────────────
function NateiraHub:Window(cfg)
    cfg = cfg or {}
    local Title    = cfg.Title    or "Nateira Hub"
    local Size     = cfg.Size     or UDim2.new(0, 600, 0, 480)
    local Position = cfg.Position or UDim2.new(0.5, -300, 0.5, -240)
    local SubTitle = cfg.SubTitle or "v1.0 | Fisch"

    -- ── Root Frame ──
    local Root = New("Frame", {
        Name             = "Root",
        Size             = Size,
        Position         = Position,
        BackgroundColor3 = T.BG,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, self.Gui)
    Corner(Root, 8)
    Stroke(Root, T.Border, 1)

    -- drop shadow simulation
    local Shadow = New("ImageLabel", {
        Size             = UDim2.new(1, 40, 1, 40),
        Position         = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image            = "rbxassetid://6014260843",
        ImageColor3      = Color3.new(0,0,0),
        ImageTransparency= 0.6,
        ScaleType        = Enum.ScaleType.Slice,
        SliceCenter      = Rect.new(49,49,450,450),
        ZIndex           = 0,
    }, Root)

    -- ── Header ──
    local Header = New("Frame", {
        Name             = "Header",
        Size             = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, Root)

    -- Header bottom line
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        ZIndex           = 4,
    }, Header)

    -- N Logo box
    local LogoBox = New("Frame", {
        Size             = UDim2.new(0, 24, 0, 24),
        Position         = UDim2.new(0, 10, 0.5, -12),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 5,
    }, Header)
    Corner(LogoBox, 5)

    New("TextLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "N",
        TextColor3       = T.BG,
        TextSize         = 15,
        Font             = Enum.Font.GothamBold,
        ZIndex           = 6,
    }, LogoBox)

    -- Title text
    New("TextLabel", {
        Size             = UDim2.new(0, 160, 1, 0),
        Position         = UDim2.new(0, 42, 0, 0),
        BackgroundTransparency = 1,
        Text             = Title,
        TextColor3       = T.TextPrimary,
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 5,
    }, Header)

    New("TextLabel", {
        Size             = UDim2.new(0, 120, 1, 0),
        Position         = UDim2.new(0, 178, 0, 0),
        BackgroundTransparency = 1,
        Text             = SubTitle,
        TextColor3       = T.TextMuted,
        TextSize         = 10,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 5,
    }, Header)

    -- Control buttons helper
    local function CtrlBtn(symbol, offsetX)
        local btn = New("TextButton", {
            Size             = UDim2.new(0, 22, 0, 22),
            Position         = UDim2.new(1, offsetX, 0.5, -11),
            BackgroundColor3 = Color3.fromRGB(36, 36, 36),
            Text             = symbol,
            TextColor3       = T.TextMuted,
            TextSize         = 11,
            Font             = Enum.Font.GothamBold,
            BorderSizePixel  = 0,
            ZIndex           = 6,
        }, Header)
        Corner(btn, 4)
        return btn
    end

    local CloseBtn = CtrlBtn("✕", -8)
    local MinBtn   = CtrlBtn("—", -34)

    -- Close hover
    CloseBtn.MouseEnter:Connect(function()  Tween(CloseBtn, {BackgroundColor3 = T.Danger, TextColor3 = Color3.new(1,1,1)}) end)
    CloseBtn.MouseLeave:Connect(function()  Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(36,36,36), TextColor3 = T.TextMuted}) end)
    MinBtn.MouseEnter:Connect(function()    Tween(MinBtn, {BackgroundColor3 = Color3.fromRGB(60,60,60)}) end)
    MinBtn.MouseLeave:Connect(function()    Tween(MinBtn, {BackgroundColor3 = Color3.fromRGB(36,36,36)}) end)

    -- ── Tab Bar ──
    local TabBar = New("Frame", {
        Name             = "TabBar",
        Size             = UDim2.new(1, 0, 0, 34),
        Position         = UDim2.new(0, 0, 0, 38),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, Root)

    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        ZIndex           = 4,
    }, TabBar)

    ListLayout(TabBar, Enum.FillDirection.Horizontal, 0)

    -- ── Content Area ──
    local ContentArea = New("Frame", {
        Name             = "ContentArea",
        Size             = UDim2.new(1, 0, 1, -74),
        Position         = UDim2.new(0, 0, 0, 74),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex           = 2,
    }, Root)

    -- ── Drag ──
    local dragging, dragStart, startPos = false, nil, nil
    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = i.Position
            startPos  = Root.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            Root.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ── Minimize ──
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Root, {Size = UDim2.new(0, 600, 0, 38)}, 0.22, Enum.EasingStyle.Quart)
        else
            Tween(Root, {Size = Size}, 0.22, Enum.EasingStyle.Quart)
        end
    end)

    -- ── Close ──
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Root, {Size = UDim2.new(0, 600, 0, 0)}, 0.18)
        task.delay(0.2, function() Root:Destroy() end)
    end)

    -- ── Window Object ──
    local win = {
        Root        = Root,
        TabBar      = TabBar,
        ContentArea = ContentArea,
        Gui         = self.Gui,
        Tabs        = {},
        ActiveTab   = nil,
        _tabCount   = 0,
    }

    -- ── Notify ──
    function win:Notify(cfg2)
        cfg2 = cfg2 or {}
        local msg      = cfg2.Message  or "Notification"
        local ntype    = cfg2.Type     or "Info"
        local duration = cfg2.Duration or 3.5

        local col = ({
            Info    = T.AccentDim,
            Success = T.Success,
            Warning = T.Warning,
            Error   = T.Danger,
        })[ntype] or T.AccentDim

        -- Notification holder
        local holder = self.Gui:FindFirstChild("_NotifHolder")
        if not holder then
            holder = New("Frame", {
                Name             = "_NotifHolder",
                Size             = UDim2.new(0, 290, 1, 0),
                Position         = UDim2.new(1, -300, 0, 0),
                BackgroundTransparency = 1,
                ZIndex           = 200,
            }, self.Gui)
            local ll = ListLayout(holder, Enum.FillDirection.Vertical, 6,
                Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
            Padding(holder, 0, 10, 0, 0)
        end

        local card = New("Frame", {
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundColor3 = T.Surface,
            BorderSizePixel  = 0,
            ZIndex           = 201,
            BackgroundTransparency = 1,
        }, holder)
        Corner(card, 6)
        Stroke(card, col, 1)

        New("Frame", {
            Size             = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = col,
            BorderSizePixel  = 0,
            ZIndex           = 202,
        }, card)

        local txt = New("TextLabel", {
            Size             = UDim2.new(1, -14, 0, 0),
            Position         = UDim2.new(0, 10, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text             = msg,
            TextColor3       = T.TextPrimary,
            TextSize         = 11,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
            TextWrapped      = true,
            ZIndex           = 203,
        }, card)
        Padding(txt, 8, 8, 0, 0)

        Tween(card, {BackgroundTransparency = 0}, 0.25)
        task.delay(duration, function()
            Tween(card, {BackgroundTransparency = 1}, 0.25)
            task.delay(0.28, function() card:Destroy() end)
        end)
    end

    -- ── Add Tab ──
    function win:Tab(tabCfg)
        tabCfg = tabCfg or {}
        local name = tabCfg.Name or "Tab"
        self._tabCount = self._tabCount + 1
        local idx = self._tabCount

        -- Tab button
        local tabBtn = New("TextButton", {
            Name             = "TBtn_"..name,
            Size             = UDim2.new(0, 0, 1, 0),
            AutomaticSize    = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text             = name,
            TextColor3       = T.TextMuted,
            TextSize         = 11,
            Font             = Enum.Font.GothamMedium,
            BorderSizePixel  = 0,
            LayoutOrder      = idx,
            ZIndex           = 5,
        }, self.TabBar)
        Padding(tabBtn, 0, 0, 14, 14)

        -- Active underline
        local line = New("Frame", {
            Size             = UDim2.new(1, -20, 0, 2),
            Position         = UDim2.new(0, 10, 1, -2),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ZIndex           = 6,
        }, tabBtn)
        Corner(line, 1)

        -- Scrollable content
        local scroll = New("ScrollingFrame", {
            Name             = "Content_"..name,
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.Border,
            CanvasSize       = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible          = false,
            ZIndex           = 3,
        }, self.ContentArea)

        ListLayout(scroll, Enum.FillDirection.Vertical, 6)
        Padding(scroll, 8, 10, 10, 10)

        local tab = {
            Btn      = tabBtn,
            Line     = line,
            Scroll   = scroll,
            _sec     = 0,
            _win     = self,
        }

        -- Activate
        function tab:Activate()
            for _, t in pairs(self._win.Tabs) do
                t.Scroll.Visible = false
                Tween(t.Btn,  {TextColor3 = T.TextMuted}, 0.15)
                Tween(t.Line, {BackgroundTransparency = 1}, 0.15)
            end
            self.Scroll.Visible = true
            Tween(self.Btn,  {TextColor3 = T.Accent}, 0.15)
            Tween(self.Line, {BackgroundTransparency = 0}, 0.15)
            self._win.ActiveTab = self
        end

        tabBtn.MouseButton1Click:Connect(function() tab:Activate() end)
        tabBtn.MouseEnter:Connect(function()
            if self.ActiveTab ~= tab then
                Tween(tabBtn, {TextColor3 = T.AccentDim}, 0.15)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if self.ActiveTab ~= tab then
                Tween(tabBtn, {TextColor3 = T.TextMuted}, 0.15)
            end
        end)

        if idx == 1 then task.defer(function() tab:Activate() end) end

        -- ── Add Section ──
        function tab:Section(secCfg)
            secCfg = secCfg or {}
            local sname = secCfg.Name or "Section"
            local desc  = secCfg.Desc or nil
            self._sec   = self._sec + 1

            local wrap = New("Frame", {
                Name             = "Sec_"..sname,
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = T.Surface,
                BorderSizePixel  = 0,
                LayoutOrder      = self._sec,
            }, self.Scroll)
            Corner(wrap, 6)
            Stroke(wrap, T.Border, 1)

            -- Header row
            local secHead = New("TextButton", {
                Size             = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 4,
            }, wrap)

            New("TextLabel", {
                Size             = UDim2.new(1, -40, 1, 0),
                Position         = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text             = sname:upper(),
                TextColor3       = T.AccentDim,
                TextSize         = 10,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 5,
            }, secHead)

            local arrow = New("TextLabel", {
                Size             = UDim2.new(0, 20, 1, 0),
                Position         = UDim2.new(1, -26, 0, 0),
                BackgroundTransparency = 1,
                Text             = "▾",
                TextColor3       = T.TextMuted,
                TextSize         = 11,
                ZIndex           = 5,
            }, secHead)

            -- Divider
            local divider = New("Frame", {
                Size             = UDim2.new(1, -24, 0, 1),
                Position         = UDim2.new(0, 12, 0, 32),
                BackgroundColor3 = T.Border,
                BorderSizePixel  = 0,
                ZIndex           = 4,
            }, wrap)

            -- Body
            local body = New("Frame", {
                Name             = "Body",
                Size             = UDim2.new(1, 0, 0, 0),
                Position         = UDim2.new(0, 0, 0, 33),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                ZIndex           = 4,
            }, wrap)
            ListLayout(body, Enum.FillDirection.Vertical, 3)
            Padding(body, 4, 8, 10, 10)

            -- Optional description
            if desc then
                New("TextLabel", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    AutomaticSize    = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text             = desc,
                    TextColor3       = T.TextMuted,
                    TextSize         = 10,
                    Font             = Enum.Font.Gotham,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    TextWrapped      = true,
                    LayoutOrder      = 0,
                    ZIndex           = 5,
                }, body)
            end

            -- Collapse toggle
            local collapsed = false
            secHead.MouseButton1Click:Connect(function()
                collapsed = not collapsed
                body.Visible    = not collapsed
                divider.Visible = not collapsed
                arrow.Text      = collapsed and "▸" or "▾"
            end)

            local sec = { Body = body, _i = 0, _win = self._win }

            ----------------------------------------------------------------
            -- TOGGLE
            ----------------------------------------------------------------
            function sec:Toggle(cfg)
                cfg = cfg or {}
                local lbl  = cfg.Name     or "Toggle"
                local def  = cfg.Default  or false
                local cb   = cfg.Callback or function() end
                local state= def
                self._i    = self._i + 1

                local row = New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    LayoutOrder      = self._i,
                }, self.Body)

                New("TextLabel", {
                    Size             = UDim2.new(1, -54, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = lbl,
                    TextColor3       = T.TextPrimary,
                    TextSize         = 12,
                    Font             = Enum.Font.Gotham,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 5,
                }, row)

                local track = New("Frame", {
                    Size             = UDim2.new(0, 38, 0, 20),
                    Position         = UDim2.new(1, -40, 0.5, -10),
                    BackgroundColor3 = state and T.ToggleOn or T.ToggleOff,
                    BorderSizePixel  = 0,
                    ZIndex           = 5,
                }, row)
                Corner(track, 10)
                Stroke(track, T.Border, 1)

                local thumb = New("Frame", {
                    Size             = UDim2.new(0, 14, 0, 14),
                    Position         = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                    BackgroundColor3 = state and T.BG or T.TextMuted,
                    BorderSizePixel  = 0,
                    ZIndex           = 6,
                }, track)
                Corner(thumb, 7)

                local hitbox = New("TextButton", {
                    Size             = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = "",
                    ZIndex           = 7,
                }, row)

                local obj = { Value = state }

                local function refresh(s)
                    Tween(track, {BackgroundColor3 = s and T.ToggleOn or T.ToggleOff}, 0.18)
                    Tween(thumb, {
                        Position         = s and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
                        BackgroundColor3 = s and T.BG or T.TextMuted
                    }, 0.18)
                end

                hitbox.MouseButton1Click:Connect(function()
                    state     = not state
                    obj.Value = state
                    refresh(state)
                    pcall(cb, state)
                end)

                function obj:Set(v) state = v; self.Value = v; refresh(v) end

                return obj
            end

            ----------------------------------------------------------------
            -- BUTTON
            ----------------------------------------------------------------
            function sec:Button(cfg)
                cfg = cfg or {}
                local lbl = cfg.Name     or "Button"
                local cb  = cfg.Callback or function() end
                self._i   = self._i + 1

                local btn = New("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = T.SurfaceAlt,
                    Text             = lbl,
                    TextColor3       = T.TextPrimary,
                    TextSize         = 11,
                    Font             = Enum.Font.GothamMedium,
                    BorderSizePixel  = 0,
                    LayoutOrder      = self._i,
                    ZIndex           = 5,
                }, self.Body)
                Corner(btn, 4)
                Stroke(btn, T.Border, 1)

                btn.MouseEnter:Connect(function()
                    Tween(btn, {BackgroundColor3 = Color3.fromRGB(38,38,38), TextColor3 = T.Accent}, 0.12)
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, {BackgroundColor3 = T.SurfaceAlt, TextColor3 = T.TextPrimary}, 0.12)
                end)
                btn.MouseButton1Click:Connect(function()
                    Tween(btn, {BackgroundColor3 = T.Border}, 0.05)
                    task.delay(0.08, function() Tween(btn, {BackgroundColor3 = T.SurfaceAlt}, 0.12) end)
                    pcall(cb)
                end)

                return btn
            end

            ----------------------------------------------------------------
            -- SLIDER
            ----------------------------------------------------------------
            function sec:Slider(cfg)
                cfg = cfg or {}
                local lbl  = cfg.Name     or "Slider"
                local min  = cfg.Min      or 0
                local max  = cfg.Max      or 100
                local def  = cfg.Default  or min
                local cb   = cfg.Callback or function() end
                local val  = def
                self._i    = self._i + 1

                local wrap = New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 42),
                    BackgroundTransparency = 1,
                    LayoutOrder      = self._i,
                }, self.Body)

                local topRow = New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                }, wrap)

                New("TextLabel", {
                    Size             = UDim2.new(0.7, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = lbl,
                    TextColor3       = T.TextPrimary,
                    TextSize         = 12,
                    Font             = Enum.Font.Gotham,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 5,
                }, topRow)

                local valLbl = New("TextLabel", {
                    Size             = UDim2.new(0.3, 0, 1, 0),
                    Position         = UDim2.new(0.7, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text             = tostring(val),
                    TextColor3       = T.AccentDim,
                    TextSize         = 11,
                    Font             = Enum.Font.GothamBold,
                    TextXAlignment   = Enum.TextXAlignment.Right,
                    ZIndex           = 5,
                }, topRow)

                local track = New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 6),
                    Position         = UDim2.new(0, 0, 0, 24),
                    BackgroundColor3 = T.SliderTrack,
                    BorderSizePixel  = 0,
                    ZIndex           = 5,
                }, wrap)
                Corner(track, 3)

                local pct  = (val - min) / math.max(max - min, 1)
                local fill = New("Frame", {
                    Size             = UDim2.new(pct, 0, 1, 0),
                    BackgroundColor3 = T.Accent,
                    BorderSizePixel  = 0,
                    ZIndex           = 6,
                }, track)
                Corner(fill, 3)

                local knob = New("Frame", {
                    Size             = UDim2.new(0, 14, 0, 14),
                    Position         = UDim2.new(pct, -7, 0.5, -7),
                    BackgroundColor3 = T.Accent,
                    BorderSizePixel  = 0,
                    ZIndex           = 7,
                }, track)
                Corner(knob, 7)

                -- invisible wider hit area
                local hit = New("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 22),
                    Position         = UDim2.new(0, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text             = "",
                    ZIndex           = 8,
                }, wrap)

                local sliding = false

                local function update(x)
                    local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    val       = math.floor(min + (max - min) * rel + 0.5)
                    valLbl.Text = tostring(val)
                    fill.Size   = UDim2.new(rel, 0, 1, 0)
                    knob.Position = UDim2.new(rel, -7, 0.5, -7)
                    pcall(cb, val)
                end

                hit.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true; update(i.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                        update(i.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                end)

                local obj = { Value = val }
                function obj:Set(v)
                    val = math.clamp(v, min, max)
                    self.Value = val
                    local r = (val - min) / math.max(max - min, 1)
                    valLbl.Text   = tostring(val)
                    fill.Size     = UDim2.new(r, 0, 1, 0)
                    knob.Position = UDim2.new(r, -7, 0.5, -7)
                end
                return obj
            end

            ----------------------------------------------------------------
            -- DROPDOWN
            ----------------------------------------------------------------
            function sec:Dropdown(cfg)
                cfg = cfg or {}
                local lbl     = cfg.Name        or "Dropdown"
                local opts    = cfg.Options      or {}
                local def     = cfg.Default      or (opts[1] or "None")
                local multi   = cfg.Multi        or false
                local cb      = cfg.Callback     or function() end
                local sel     = def
                local selSet  = {}
                self._i       = self._i + 1

                local wrap = New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    LayoutOrder      = self._i,
                    ClipsDescendants = false,
                    ZIndex           = 5,
                }, self.Body)

                New("TextLabel", {
                    Size             = UDim2.new(0.42, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = lbl,
                    TextColor3       = T.TextPrimary,
                    TextSize         = 12,
                    Font             = Enum.Font.Gotham,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 6,
                }, wrap)

                local dBtn = New("TextButton", {
                    Size             = UDim2.new(0.56, 0, 0, 26),
                    Position         = UDim2.new(0.44, 0, 0.5, -13),
                    BackgroundColor3 = T.SurfaceAlt,
                    Text             = multi and "Select..." or tostring(sel),
                    TextColor3       = T.TextPrimary,
                    TextSize         = 11,
                    Font             = Enum.Font.Gotham,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    BorderSizePixel  = 0,
                    ClipsDescendants = true,
                    ZIndex           = 6,
                }, wrap)
                Corner(dBtn, 4)
                Stroke(dBtn, T.Border, 1)
                Padding(dBtn, 0, 0, 8, 22)

                local dArrow = New("TextLabel", {
                    Size             = UDim2.new(0, 20, 1, 0),
                    Position         = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text             = "▾",
                    TextColor3       = T.TextMuted,
                    TextSize         = 11,
                    ZIndex           = 7,
                }, dBtn)

                -- List panel
                local listH  = math.min(#opts, 7) * 26
                local listFr = New("Frame", {
                    Size             = UDim2.new(0.56, 0, 0, listH),
                    Position         = UDim2.new(0.44, 0, 0, 30),
                    BackgroundColor3 = Color3.fromRGB(18,18,18),
                    BorderSizePixel  = 0,
                    Visible          = false,
                    ZIndex           = 50,
                }, wrap)
                Corner(listFr, 4)
                Stroke(listFr, T.Border, 1)

                local listScr = New("ScrollingFrame", {
                    Size             = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = T.Border,
                    CanvasSize       = UDim2.new(0, 0, 0, #opts * 26),
                    ZIndex           = 51,
                }, listFr)
                ListLayout(listScr)

                local isOpen = false

                for i, opt in ipairs(opts) do
                    local ob = New("TextButton", {
                        Size             = UDim2.new(1, 0, 0, 26),
                        BackgroundTransparency = 1,
                        Text             = opt,
                        TextColor3       = T.TextPrimary,
                        TextSize         = 11,
                        Font             = Enum.Font.Gotham,
                        TextXAlignment   = Enum.TextXAlignment.Left,
                        LayoutOrder      = i,
                        ZIndex           = 52,
                    }, listScr)
                    Padding(ob, 0, 0, 10, 4)

                    ob.MouseEnter:Connect(function()
                        ob.BackgroundTransparency = 0
                        Tween(ob, {BackgroundColor3 = Color3.fromRGB(32,32,32)}, 0.1)
                    end)
                    ob.MouseLeave:Connect(function()
                        ob.BackgroundTransparency = 1
                    end)
                    ob.MouseButton1Click:Connect(function()
                        if multi then
                            selSet[opt] = not selSet[opt] or nil
                            ob.TextColor3 = selSet[opt] and T.Accent or T.TextPrimary
                            local n = 0; for _ in pairs(selSet) do n = n + 1 end
                            dBtn.Text = n > 0 and (n.." selected") or "Select..."
                            pcall(cb, selSet)
                        else
                            sel = opt; dBtn.Text = opt
                            listFr.Visible = false; isOpen = false
                            Tween(dArrow, {Rotation = 0}, 0.15)
                            pcall(cb, opt)
                        end
                    end)
                end

                dBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    listFr.Visible = isOpen
                    Tween(dArrow, {Rotation = isOpen and 180 or 0}, 0.15)
                end)

                local obj = { Value = sel, Selected = selSet }
                function obj:Set(v) sel = v; dBtn.Text = v end
                function obj:SelectAll()
                    for _, o in ipairs(opts) do selSet[o] = true end
                    dBtn.Text = #opts .. " selected"
                end
                function obj:DeselectAll() selSet = {}; dBtn.Text = "Select..." end
                function obj:GetSelected()
                    if multi then
                        local t = {}
                        for k in pairs(selSet) do table.insert(t, k) end
                        return t
                    else return sel end
                end
                return obj
            end

            ----------------------------------------------------------------
            -- TEXT INPUT
            ----------------------------------------------------------------
            function sec:Input(cfg)
                cfg = cfg or {}
                local lbl  = cfg.Name        or "Input"
                local ph   = cfg.Placeholder  or ""
                local cb   = cfg.Callback     or function() end
                self._i    = self._i + 1

                local wrap = New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    LayoutOrder      = self._i,
                }, self.Body)

                New("TextLabel", {
                    Size             = UDim2.new(0.35, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = lbl,
                    TextColor3       = T.TextPrimary,
                    TextSize         = 12,
                    Font             = Enum.Font.Gotham,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 5,
                }, wrap)

                local box = New("TextBox", {
                    Size             = UDim2.new(0.63, 0, 0, 26),
                    Position         = UDim2.new(0.37, 0, 0.5, -13),
                    BackgroundColor3 = T.SurfaceAlt,
                    PlaceholderText  = ph,
                    PlaceholderColor3= T.TextMuted,
                    Text             = "",
                    TextColor3       = T.TextPrimary,
                    TextSize         = 11,
                    Font             = Enum.Font.Gotham,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    BorderSizePixel  = 0,
                    ZIndex           = 5,
                }, wrap)
                Corner(box, 4)
                local bStroke = Stroke(box, T.Border, 1)
                Padding(box, 0, 0, 8, 4)

                box.Focused:Connect(function()   bStroke.Color = T.Accent end)
                box.FocusLost:Connect(function(e) bStroke.Color = T.Border; if e then pcall(cb, box.Text) end end)

                local obj = {}
                function obj:Get()    return box.Text end
                function obj:Set(v)   box.Text = v end
                return obj
            end

            ----------------------------------------------------------------
            -- LABEL
            ----------------------------------------------------------------
            function sec:Label(cfg)
                cfg = cfg or {}
                self._i = self._i + 1
                local l = New("TextLabel", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    AutomaticSize    = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text             = cfg.Text or "",
                    TextColor3       = cfg.Color or T.TextMuted,
                    TextSize         = 11,
                    Font             = Enum.Font.Gotham,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    TextWrapped      = true,
                    LayoutOrder      = self._i,
                    ZIndex           = 5,
                }, self.Body)
                return l
            end

            ----------------------------------------------------------------
            -- SEPARATOR
            ----------------------------------------------------------------
            function sec:Separator()
                self._i = self._i + 1
                New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = T.Border,
                    BorderSizePixel  = 0,
                    LayoutOrder      = self._i,
                }, self.Body)
            end

            return sec
        end -- Section

        self.Tabs[name] = tab
        return tab
    end -- Tab

    table.insert(self.Windows, win)
    return win
end -- Window

return NateiraHub
