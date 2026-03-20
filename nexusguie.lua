-- ═══════════════════════════════════════════════════════════════════════
--   NATEIRA HUB  ·  UI Library  v3.0
--   Layout  : Vora Hub inspired  (sidebar + content)
--   Theme   : Minimal Cyber Black & White
--   Author  : nynzzkeren
-- ═══════════════════════════════════════════════════════════════════════

local NateiraHub   = {}
NateiraHub.__index = NateiraHub

-- ── Services ─────────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LP               = Players.LocalPlayer

-- ── Palette ──────────────────────────────────────────────────────────
local C = {
    -- Window
    WinBG       = Color3.fromRGB( 13,  13,  15),   -- main window bg
    Header      = Color3.fromRGB( 17,  17,  20),   -- header bg
    Sidebar     = Color3.fromRGB( 15,  15,  18),   -- sidebar bg
    Content     = Color3.fromRGB( 11,  11,  13),   -- content area bg
    -- Surfaces
    Card        = Color3.fromRGB( 20,  20,  24),   -- card / section bg
    CardHov     = Color3.fromRGB( 26,  26,  30),   -- card hover
    Input       = Color3.fromRGB( 18,  18,  22),   -- input field
    -- Borders
    Border      = Color3.fromRGB( 38,  38,  44),   -- subtle border
    BorderAct   = Color3.fromRGB( 80,  80,  90),   -- active border
    -- Accent
    Accent      = Color3.fromRGB(255, 255, 255),   -- white accent
    AccentDim   = Color3.fromRGB(160, 160, 170),   -- muted white
    SideAct     = Color3.fromRGB(255, 255, 255),   -- sidebar active bar
    -- Text
    TxtPri      = Color3.fromRGB(230, 230, 235),
    TxtSec      = Color3.fromRGB(120, 120, 130),
    TxtMut      = Color3.fromRGB( 70,  70,  80),
    -- State
    TglOn       = Color3.fromRGB(255, 255, 255),
    TglOff      = Color3.fromRGB( 35,  35,  40),
    TglThumb    = Color3.fromRGB( 10,  10,  12),
    Danger      = Color3.fromRGB(210,  60,  60),
    Success     = Color3.fromRGB( 60, 200, 100),
    Warn        = Color3.fromRGB(210, 170,  40),
    Info        = Color3.fromRGB(100, 160, 230),
}

-- ── Tween helper ─────────────────────────────────────────────────────
local function Tw(obj, props, dur, style, dir)
    TweenService:Create(obj, TweenInfo.new(
        dur   or 0.16,
        style or Enum.EasingStyle.Quad,
        dir   or Enum.EasingDirection.Out
    ), props):Play()
end

-- ── Instance factory ─────────────────────────────────────────────────
local function Make(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do
        o[k] = v
    end
    if parent then o.Parent = parent end
    return o
end

local function Rnd(p, r)
    Make("UICorner", {CornerRadius = UDim.new(0, r or 8)}, p)
    return p
end

local function Bdr(p, col, thick)
    return Make("UIStroke", {
        Color           = col   or C.Border,
        Thickness       = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, p)
end

local function Pad(p, t, b, l, r)
    Make("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
    }, p)
    return p
end

local function VList(p, gap)
    Make("UIListLayout", {
        FillDirection       = Enum.FillDirection.Vertical,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment   = Enum.VerticalAlignment.Top,
        Padding             = UDim.new(0, gap or 0),
    }, p)
    return p
end

-- ── Library init ─────────────────────────────────────────────────────
function NateiraHub.new()
    local self = setmetatable({}, NateiraHub)

    local gui = Make("ScreenGui", {
        Name           = "NateiraHub_v3",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 999,
        IgnoreGuiInset = true,
    })

    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = LP:WaitForChild("PlayerGui")
    end

    self.Gui = gui
    return self
end

-- ── Window ────────────────────────────────────────────────────────────
function NateiraHub:Window(cfg)
    cfg = cfg or {}
    local Title    = cfg.Title    or "Nateira Hub"
    local SubTitle = cfg.SubTitle or "v3.0"
    local W        = cfg.Width    or 680
    local H        = cfg.Height   or 470
    local SW       = 185  -- sidebar width (fixed, matching reference)

    -- ─── Root window ────────────────────────────────────────────────
    local Root = Make("Frame", {
        Name             = "Root",
        Size             = UDim2.new(0, W, 0, H),
        Position         = UDim2.new(0.5, -W/2, 0.5, -H/2),
        BackgroundColor3 = C.WinBG,
        BorderSizePixel  = 0,
        ClipsDescendants = false,
        ZIndex           = 10,
    }, self.Gui)
    Rnd(Root, 12)
    Bdr(Root, C.Border, 1)

    -- Inner clip (clips header + sidebar + content to rounded corners)
    local Clip = Make("Frame", {
        Name             = "Clip",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex           = 10,
    }, Root)
    Rnd(Clip, 12)

    -- ─── Header ─────────────────────────────────────────────────────
    local Header = Make("Frame", {
        Name             = "Header",
        Size             = UDim2.new(1, 0, 0, 48),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = C.Header,
        BorderSizePixel  = 0,
        ZIndex           = 14,
    }, Clip)

    -- Header bottom divider
    Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = C.Border,
        BorderSizePixel  = 0,
        ZIndex           = 15,
    }, Header)

    -- ── Logo box ── (white square with N, matching the V box in photo)
    local LogoBg = Make("Frame", {
        Size             = UDim2.new(0, 32, 0, 32),
        Position         = UDim2.new(0, 14, 0.5, -16),
        BackgroundColor3 = C.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 16,
    }, Header)
    Rnd(LogoBg, 7)
    Make("TextLabel", {
        Size               = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text               = "N",
        TextColor3         = C.WinBG,
        TextSize           = 18,
        Font               = Enum.Font.GothamBold,
        ZIndex             = 17,
    }, LogoBg)

    -- Title
    Make("TextLabel", {
        Size             = UDim2.new(0, 160, 0, 22),
        Position         = UDim2.new(0, 54, 0.5, -11),
        BackgroundTransparency = 1,
        Text             = Title,
        TextColor3       = C.TxtPri,
        TextSize         = 15,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 15,
    }, Header)

    -- Header right-side control buttons
    local function HBtn(icon, offsetX, hoverCol)
        local b = Make("TextButton", {
            Size             = UDim2.new(0, 28, 0, 28),
            Position         = UDim2.new(1, offsetX, 0.5, -14),
            BackgroundColor3 = C.Card,
            BackgroundTransparency = 1,
            Text             = icon,
            TextColor3       = C.TxtSec,
            TextSize         = 13,
            Font             = Enum.Font.GothamBold,
            BorderSizePixel  = 0,
            ZIndex           = 15,
        }, Header)
        Rnd(b, 6)
        b.MouseEnter:Connect(function()
            b.BackgroundTransparency = 0
            Tw(b, {BackgroundColor3 = hoverCol or C.CardHov, TextColor3 = C.Accent}, 0.12)
        end)
        b.MouseLeave:Connect(function()
            Tw(b, {BackgroundColor3 = C.CardHov, TextColor3 = C.TxtSec}, 0.12)
            task.delay(0.13, function() b.BackgroundTransparency = 1 end)
        end)
        return b
    end

    local CloseBtn = HBtn("✕", -10, C.Danger)
    local MaxBtn   = HBtn("⬜", -42, C.CardHov)
    local MinBtn   = HBtn("—", -74, C.CardHov)

    -- ─── Sidebar ─────────────────────────────────────────────────────
    local Sidebar = Make("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, SW, 1, -48),
        Position         = UDim2.new(0, 0, 0, 48),
        BackgroundColor3 = C.Sidebar,
        BorderSizePixel  = 0,
        ZIndex           = 12,
    }, Clip)

    -- Sidebar right border
    Make("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = C.Border,
        BorderSizePixel  = 0,
        ZIndex           = 13,
    }, Sidebar)

    local SideScroll = Make("ScrollingFrame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize       = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex           = 13,
    }, Sidebar)
    VList(SideScroll, 2)
    Pad(SideScroll, 10, 10, 0, 0)

    -- ─── Content area ────────────────────────────────────────────────
    local ContentBG = Make("Frame", {
        Name             = "ContentBG",
        Size             = UDim2.new(1, -SW, 1, -48),
        Position         = UDim2.new(0, SW, 0, 48),
        BackgroundColor3 = C.Content,
        BorderSizePixel  = 0,
        ZIndex           = 11,
    }, Clip)

    -- Content pages holder
    local Pages = Make("Frame", {
        Name             = "Pages",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex           = 12,
    }, ContentBG)

    -- ─── DRAG (fixed with AbsolutePosition) ──────────────────────────
    local dragging       = false
    local dragMStart     = Vector2.new()
    local dragRStart     = Vector2.new()

    Header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging   = true
            dragMStart = Vector2.new(inp.Position.X, inp.Position.Y)
            dragRStart = Vector2.new(Root.AbsolutePosition.X, Root.AbsolutePosition.Y)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = Vector2.new(inp.Position.X, inp.Position.Y) - dragMStart
            Root.Position = UDim2.new(0, dragRStart.X + d.X, 0, dragRStart.Y + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ─── Minimize bar ────────────────────────────────────────────────
    local MinBar = Make("Frame", {
        Name             = "MinBar",
        Size             = UDim2.new(0, 220, 0, 40),
        Position         = UDim2.new(0.5, -110, 0.5, -20),
        BackgroundColor3 = C.Header,
        BorderSizePixel  = 0,
        Visible          = false,
        ZIndex           = 60,
    }, self.Gui)
    Rnd(MinBar, 10)
    Bdr(MinBar, C.Border, 1)

    local MbLogo = Make("Frame", {
        Size=UDim2.new(0,26,0,26), Position=UDim2.new(0,8,0.5,-13),
        BackgroundColor3=C.Accent, BorderSizePixel=0, ZIndex=61,
    }, MinBar)
    Rnd(MbLogo, 6)
    Make("TextLabel", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="N", TextColor3=C.WinBG, TextSize=14, Font=Enum.Font.GothamBold, ZIndex=62,
    }, MbLogo)

    Make("TextLabel", {
        Size=UDim2.new(0,120,1,0), Position=UDim2.new(0,42,0,0),
        BackgroundTransparency=1, Text=Title,
        TextColor3=C.TxtPri, TextSize=12, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=61,
    }, MinBar)

    local ExpandBtn = Make("TextButton", {
        Size=UDim2.new(0,24,0,24), Position=UDim2.new(1,-30,0.5,-12),
        BackgroundColor3=C.Card, BackgroundTransparency=1,
        Text="□", TextColor3=C.TxtSec, TextSize=12,
        Font=Enum.Font.GothamBold, BorderSizePixel=0, ZIndex=62,
    }, MinBar)
    Rnd(ExpandBtn, 5)
    ExpandBtn.MouseEnter:Connect(function() Tw(ExpandBtn,{BackgroundTransparency=0,BackgroundColor3=C.CardHov,TextColor3=C.Accent},0.12) end)
    ExpandBtn.MouseLeave:Connect(function() Tw(ExpandBtn,{BackgroundTransparency=1,TextColor3=C.TxtSec},0.12) end)

    -- MinBar drag
    local mbD,mbS,mbP=false,Vector2.new(),Vector2.new()
    MinBar.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            mbD=true; mbS=Vector2.new(inp.Position.X,inp.Position.Y)
            mbP=Vector2.new(MinBar.AbsolutePosition.X,MinBar.AbsolutePosition.Y)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if mbD and inp.UserInputType==Enum.UserInputType.MouseMovement then
            local d=Vector2.new(inp.Position.X,inp.Position.Y)-mbS
            MinBar.Position=UDim2.new(0,mbP.X+d.X,0,mbP.Y+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then mbD=false end
    end)

    -- Minimize
    MinBtn.MouseButton1Click:Connect(function()
        MinBar.Position = UDim2.new(0, Root.AbsolutePosition.X, 0, Root.AbsolutePosition.Y + H - 20)
        Tw(Root, {Size=UDim2.new(0,W,0,0)}, 0.2, Enum.EasingStyle.Quart)
        task.delay(0.18, function() Root.Visible=false; MinBar.Visible=true end)
    end)
    ExpandBtn.MouseButton1Click:Connect(function()
        Root.Position=UDim2.new(0,MinBar.AbsolutePosition.X,0,MinBar.AbsolutePosition.Y)
        Root.Size=UDim2.new(0,W,0,0); Root.Visible=true; MinBar.Visible=false
        Tw(Root, {Size=UDim2.new(0,W,0,H)}, 0.22, Enum.EasingStyle.Quart)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tw(Root,{Size=UDim2.new(0,W,0,0)},0.16)
        task.delay(0.18,function() Root:Destroy();MinBar:Destroy() end)
    end)

    -- ─── Notification system ─────────────────────────────────────────
    local function GetNotifHolder(gui)
        local h = gui:FindFirstChild("_NH_Notifs")
        if not h then
            h = Make("Frame", {
                Name="__NH_Notifs", Size=UDim2.new(0,290,1,-20),
                Position=UDim2.new(1,-300,0,10), BackgroundTransparency=1, ZIndex=300,
            }, gui)
            Make("UIListLayout",{
                FillDirection=Enum.FillDirection.Vertical,
                VerticalAlignment=Enum.VerticalAlignment.Bottom,
                SortOrder=Enum.SortOrder.LayoutOrder,
                Padding=UDim.new(0,6),
            }, h)
        end
        return h
    end

    -- ─── Window object ───────────────────────────────────────────────
    local win = {
        Root=Root, Pages=Pages, SideScroll=SideScroll,
        Gui=self.Gui, Tabs={}, ActiveTab=nil, _ti=0,
    }

    function win:Notify(cfg2)
        cfg2=cfg2 or {}
        local msg=cfg2.Message or ""; local dur=cfg2.Duration or 3.5
        local col=({Info=C.Info,Success=C.Success,Warning=C.Warn,Error=C.Danger})[cfg2.Type or "Info"] or C.Info
        local h=GetNotifHolder(self.Gui)
        local card=Make("Frame",{
            Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundColor3=C.Card, BorderSizePixel=0,
            BackgroundTransparency=0, ZIndex=301,
        },h)
        Rnd(card,8); Bdr(card,col,1)
        -- left accent bar
        Make("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=col,BorderSizePixel=0,ZIndex=302},card)
        local tl=Make("TextLabel",{
            Size=UDim2.new(1,-16,0,0), Position=UDim2.new(0,12,0,0),
            AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1,
            Text=msg, TextColor3=C.TxtPri, TextSize=11, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, ZIndex=303,
        },card)
        Pad(tl,8,8,0,0)
        -- type label top-right
        Make("TextLabel",{
            Size=UDim2.new(0,60,0,14), Position=UDim2.new(1,-64,0,4),
            BackgroundTransparency=1, Text=(cfg2.Type or "Info"):upper(),
            TextColor3=col, TextSize=8, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Right, ZIndex=304,
        },card)
        Tw(card,{BackgroundTransparency=0},0.2)
        task.delay(dur,function()
            Tw(card,{BackgroundTransparency=1},0.2)
            task.delay(0.22,function() card:Destroy() end)
        end)
    end

    -- ─── Tab ─────────────────────────────────────────────────────────
    function win:Tab(tcfg)
        tcfg=tcfg or {}
        local name = tcfg.Name or "Tab"
        local icon = tcfg.Icon or "◈"
        self._ti   = self._ti + 1
        local idx  = self._ti

        -- ── Sidebar button ──────────────────────────────────────────
        local sbRow = Make("Frame", {
            Name             = "Tab_"..name,
            Size             = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = C.CardHov,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            LayoutOrder      = idx,
            ZIndex           = 14,
        }, self.SideScroll)
        Rnd(sbRow, 8)

        -- Active left indicator bar (like the blue bar in the photo)
        local actBar = Make("Frame", {
            Size             = UDim2.new(0, 3, 0, 22),
            Position         = UDim2.new(0, 0, 0.5, -11),
            BackgroundColor3 = C.SideAct,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ZIndex           = 16,
        }, sbRow)
        Rnd(actBar, 2)

        -- Icon frame (like the small icon box in reference)
        local iconLbl = Make("TextLabel", {
            Size             = UDim2.new(0, 20, 0, 20),
            Position         = UDim2.new(0, 16, 0.5, -10),
            BackgroundTransparency = 1,
            Text             = icon,
            TextColor3       = C.TxtMut,
            TextSize         = 14,
            Font             = Enum.Font.GothamMedium,
            ZIndex           = 15,
        }, sbRow)

        -- Tab name
        local nameLbl = Make("TextLabel", {
            Size             = UDim2.new(1, -46, 1, 0),
            Position         = UDim2.new(0, 44, 0, 0),
            BackgroundTransparency = 1,
            Text             = name,
            TextColor3       = C.TxtSec,
            TextSize         = 12,
            Font             = Enum.Font.GothamMedium,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 15,
        }, sbRow)

        -- Hit button (covers whole row)
        local hitBtn = Make("TextButton", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=16,
        }, sbRow)

        -- ── Content page ────────────────────────────────────────────
        local page = Make("ScrollingFrame", {
            Name             = "Page_"..name,
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = C.BorderAct,
            CanvasSize       = UDim2.new(0,0,0,0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible          = false,
            ZIndex           = 13,
        }, self.Pages)
        VList(page, 8)
        Pad(page, 18, 18, 18, 18)

        local tab = {Row=sbRow, ActBar=actBar, IconLbl=iconLbl, NameLbl=nameLbl, Page=page, _si=0, _win=self}

        local function setActive(state)
            if state then
                tab.Page.Visible = true
                Tw(actBar, {BackgroundTransparency=0}, 0.15)
                Tw(iconLbl, {TextColor3=C.Accent}, 0.15)
                Tw(nameLbl, {TextColor3=C.TxtPri}, 0.15)
                Tw(sbRow, {BackgroundTransparency=0, BackgroundColor3=Color3.fromRGB(22,22,28)}, 0.15)
            else
                tab.Page.Visible = false
                Tw(actBar, {BackgroundTransparency=1}, 0.15)
                Tw(iconLbl, {TextColor3=C.TxtMut}, 0.15)
                Tw(nameLbl, {TextColor3=C.TxtSec}, 0.15)
                Tw(sbRow, {BackgroundTransparency=1}, 0.15)
            end
        end

        function tab:Activate()
            for _, t in pairs(self._win.Tabs) do
                if t ~= self then setActive_for(t, false) end
            end
            self._win.ActiveTab = self
            setActive(true)
        end

        -- helper so we can call setActive on other tabs
        function setActive_for(t, state)
            if state then
                t.Page.Visible = true
                Tw(t.ActBar,  {BackgroundTransparency=0}, 0.15)
                Tw(t.IconLbl, {TextColor3=C.Accent}, 0.15)
                Tw(t.NameLbl, {TextColor3=C.TxtPri}, 0.15)
                Tw(t.Row,     {BackgroundTransparency=0, BackgroundColor3=Color3.fromRGB(22,22,28)}, 0.15)
            else
                t.Page.Visible = false
                Tw(t.ActBar,  {BackgroundTransparency=1}, 0.15)
                Tw(t.IconLbl, {TextColor3=C.TxtMut}, 0.15)
                Tw(t.NameLbl, {TextColor3=C.TxtSec}, 0.15)
                Tw(t.Row,     {BackgroundTransparency=1}, 0.15)
            end
        end

        hitBtn.MouseButton1Click:Connect(function() tab:Activate() end)
        hitBtn.MouseEnter:Connect(function()
            if self._win.ActiveTab ~= tab then
                Tw(sbRow, {BackgroundTransparency=0, BackgroundColor3=Color3.fromRGB(19,19,24)}, 0.12)
                Tw(nameLbl, {TextColor3=C.AccentDim}, 0.12)
            end
        end)
        hitBtn.MouseLeave:Connect(function()
            if self._win.ActiveTab ~= tab then
                Tw(sbRow, {BackgroundTransparency=1}, 0.12)
                Tw(nameLbl, {TextColor3=C.TxtSec}, 0.12)
            end
        end)

        if idx == 1 then task.defer(function() tab:Activate() end) end

        -- ── Section (matches Vora Hub style: title + full-width line) ─
        function tab:Section(scfg)
            scfg    = scfg or {}
            local sname = scfg.Name or "Section"
            self._si    = self._si + 1

            -- Section wrapper
            local wrap = Make("Frame", {
                Name          = "Sec_"..sname,
                Size          = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder   = self._si,
                ZIndex        = 13,
            }, self.Page)
            VList(wrap, 0)

            -- ── Section header (label + horizontal line, like in photo) ──
            local secHeader = Make("Frame", {
                Size             = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                LayoutOrder      = 1,
                ZIndex           = 14,
            }, wrap)

            -- Section title text
            local secTitle = Make("TextLabel", {
                Size             = UDim2.new(0, 0, 1, 0),
                AutomaticSize    = Enum.AutomaticSize.X,
                Position         = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Text             = sname,
                TextColor3       = C.TxtPri,
                TextSize         = 12,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 15,
            }, secHeader)

            -- Horizontal divider line (starts after title text, like Vora Hub)
            local divLine = Make("Frame", {
                Size             = UDim2.new(1, -10, 0, 1),
                Position         = UDim2.new(0, 10, 0.5, 0),
                BackgroundColor3 = C.Border,
                BorderSizePixel  = 0,
                ZIndex           = 14,
            }, secHeader)

            -- Update divider position after title auto-sizes
            task.defer(function()
                local tw = secTitle.AbsoluteSize.X + 10
                divLine.Size     = UDim2.new(1, -tw, 0, 1)
                divLine.Position = UDim2.new(0, tw, 0.5, 0)
            end)

            -- Section body (cards live here)
            local body = Make("Frame", {
                Name          = "Body",
                Size          = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder   = 2,
                ZIndex        = 13,
            }, wrap)
            VList(body, 6)
            Pad(body, 4, 4, 0, 0)

            local sec = {Body=body, _i=0, _win=self._win}

            -- ════════════════════════════════════════════════════════
            --  TOGGLE  (card style like reference)
            -- ════════════════════════════════════════════════════════
            function sec:Toggle(c)
                c=c or {}; self._i=self._i+1
                local s=c.Default or false

                local card = Make("Frame",{
                    Size=UDim2.new(1,0,0,46), BackgroundColor3=C.Card,
                    BorderSizePixel=0, LayoutOrder=self._i, ZIndex=14,
                }, self.Body)
                Rnd(card,8); Bdr(card,C.Border,1)
                Pad(card,0,0,14,14)

                Make("TextLabel",{
                    Size=UDim2.new(1,-58,0,20), Position=UDim2.new(0,0,0.5,-14),
                    BackgroundTransparency=1, Text=c.Name or "Toggle",
                    TextColor3=C.TxtPri, TextSize=12, Font=Enum.Font.GothamMedium,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=15,
                }, card)

                if c.Desc then
                    Make("TextLabel",{
                        Size=UDim2.new(1,-58,0,14), Position=UDim2.new(0,0,0.5,2),
                        BackgroundTransparency=1, Text=c.Desc,
                        TextColor3=C.TxtSec, TextSize=10, Font=Enum.Font.Gotham,
                        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=15,
                    }, card)
                end

                -- Toggle switch
                local track=Make("Frame",{
                    Size=UDim2.new(0,42,0,24), Position=UDim2.new(1,-42,0.5,-12),
                    BackgroundColor3=s and C.TglOn or C.TglOff,
                    BorderSizePixel=0, ZIndex=15,
                }, card)
                Rnd(track,12); Bdr(track,C.Border,1)

                local thumb=Make("Frame",{
                    Size=UDim2.new(0,18,0,18),
                    Position=s and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
                    BackgroundColor3=s and C.TglThumb or C.AccentDim,
                    BorderSizePixel=0, ZIndex=16,
                },track)
                Rnd(thumb,9)

                local hit=Make("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=17},card)

                local obj={Value=s}
                local function refresh(v)
                    Tw(track,{BackgroundColor3=v and C.TglOn or C.TglOff},0.18)
                    Tw(thumb,{
                        Position=v and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
                        BackgroundColor3=v and C.TglThumb or C.AccentDim
                    },0.18)
                end
                hit.MouseButton1Click:Connect(function()
                    s=not s; obj.Value=s; refresh(s); pcall(c.Callback or function()end,s)
                end)
                -- Card hover
                hit.MouseEnter:Connect(function() Tw(card,{BackgroundColor3=C.CardHov},0.12) end)
                hit.MouseLeave:Connect(function() Tw(card,{BackgroundColor3=C.Card},0.12) end)
                function obj:Set(v) s=v;self.Value=v;refresh(v) end
                return obj
            end

            -- ════════════════════════════════════════════════════════
            --  BUTTON  (full card button)
            -- ════════════════════════════════════════════════════════
            function sec:Button(c)
                c=c or {}; self._i=self._i+1
                local btn=Make("TextButton",{
                    Size=UDim2.new(1,0,0,42), BackgroundColor3=C.Card,
                    Text="", BorderSizePixel=0, LayoutOrder=self._i, ZIndex=14,
                },self.Body)
                Rnd(btn,8); Bdr(btn,C.Border,1)

                Make("TextLabel",{
                    Size=UDim2.new(1,-40,1,0), Position=UDim2.new(0,14,0,0),
                    BackgroundTransparency=1, Text=c.Name or "Button",
                    TextColor3=C.TxtPri, TextSize=12, Font=Enum.Font.GothamMedium,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=15,
                },btn)

                -- Arrow icon on right
                Make("TextLabel",{
                    Size=UDim2.new(0,24,1,0), Position=UDim2.new(1,-28,0,0),
                    BackgroundTransparency=1, Text="›",
                    TextColor3=C.TxtMut, TextSize=18, Font=Enum.Font.GothamBold, ZIndex=15,
                },btn)

                btn.MouseEnter:Connect(function() Tw(btn,{BackgroundColor3=C.CardHov},0.12) end)
                btn.MouseLeave:Connect(function() Tw(btn,{BackgroundColor3=C.Card},0.12) end)
                btn.MouseButton1Click:Connect(function()
                    Tw(btn,{BackgroundColor3=C.BorderAct},0.06)
                    task.delay(0.1,function() Tw(btn,{BackgroundColor3=C.Card},0.12) end)
                    pcall(c.Callback or function()end)
                end)
                return btn
            end

            -- ════════════════════════════════════════════════════════
            --  INFO CARD  (like Discord/Update card in the photo)
            -- ════════════════════════════════════════════════════════
            function sec:InfoCard(c)
                c=c or {}; self._i=self._i+1
                local card=Make("Frame",{
                    Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
                    BackgroundColor3=C.Card, BorderSizePixel=0, LayoutOrder=self._i, ZIndex=14,
                },self.Body)
                Rnd(card,8); Bdr(card,C.Border,1)
                Pad(card,12,12,14,14)
                VList(card,4)

                Make("TextLabel",{
                    Size=UDim2.new(1,0,0,16), BackgroundTransparency=1,
                    Text=c.Title or "Title", TextColor3=C.TxtPri,
                    TextSize=12, Font=Enum.Font.GothamBold,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=15, LayoutOrder=1,
                },card)

                if c.Desc then
                    Make("TextLabel",{
                        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
                        BackgroundTransparency=1, Text=c.Desc,
                        TextColor3=C.TxtSec, TextSize=10, Font=Enum.Font.Gotham,
                        TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true,
                        ZIndex=15, LayoutOrder=2,
                    },card)
                end

                if c.Clickable then
                    Make("TextLabel",{
                        Size=UDim2.new(1,0,0,12), BackgroundTransparency=1,
                        Text=c.SubText or "click to copy link",
                        TextColor3=C.TxtMut, TextSize=9, Font=Enum.Font.Gotham,
                        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=15, LayoutOrder=2,
                    },card)
                    local hit=Make("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=16},card)
                    -- Action icon
                    Make("TextLabel",{
                        Size=UDim2.new(0,22,0,22), Position=UDim2.new(1,-28,0.5,-11),
                        BackgroundTransparency=1, Text="✓",
                        TextColor3=C.TxtMut, TextSize=13, ZIndex=16,
                    },card)
                    hit.MouseEnter:Connect(function() Tw(card,{BackgroundColor3=C.CardHov},0.12) end)
                    hit.MouseLeave:Connect(function() Tw(card,{BackgroundColor3=C.Card},0.12) end)
                    hit.MouseButton1Click:Connect(function() pcall(c.Callback or function()end) end)
                end

                return card
            end

            -- ════════════════════════════════════════════════════════
            --  SLIDER
            -- ════════════════════════════════════════════════════════
            function sec:Slider(c)
                c=c or {}; self._i=self._i+1
                local min=c.Min or 0; local max=c.Max or 100; local val=c.Default or min

                local card=Make("Frame",{
                    Size=UDim2.new(1,0,0,58), BackgroundColor3=C.Card,
                    BorderSizePixel=0, LayoutOrder=self._i, ZIndex=14,
                },self.Body)
                Rnd(card,8); Bdr(card,C.Border,1); Pad(card,0,0,14,14)

                -- Label + value
                local topRow=Make("Frame",{Size=UDim2.new(1,-28,0,20),Position=UDim2.new(0,0,0,11),BackgroundTransparency=1,ZIndex=15},card)
                Make("TextLabel",{
                    Size=UDim2.new(0.7,0,1,0), BackgroundTransparency=1,
                    Text=c.Name or "Slider", TextColor3=C.TxtPri, TextSize=12,
                    Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=15,
                },topRow)
                local vLbl=Make("TextLabel",{
                    Size=UDim2.new(0.3,0,1,0), Position=UDim2.new(0.7,0,0,0),
                    BackgroundTransparency=1, Text=tostring(val),
                    TextColor3=C.AccentDim, TextSize=11, Font=Enum.Font.GothamBold,
                    TextXAlignment=Enum.TextXAlignment.Right, ZIndex=15,
                },topRow)

                -- Track
                local trk=Make("Frame",{
                    Size=UDim2.new(1,-28,0,4), Position=UDim2.new(0,0,0,38),
                    BackgroundColor3=Color3.fromRGB(35,35,42), BorderSizePixel=0, ZIndex=15,
                },card)
                Rnd(trk,2)
                local pct=(val-min)/math.max(max-min,1)
                local fill=Make("Frame",{Size=UDim2.new(pct,0,1,0),BackgroundColor3=C.Accent,BorderSizePixel=0,ZIndex=16},trk)
                Rnd(fill,2)
                local knob=Make("Frame",{
                    Size=UDim2.new(0,14,0,14), Position=UDim2.new(pct,-7,0.5,-7),
                    BackgroundColor3=C.Accent, BorderSizePixel=0, ZIndex=17,
                },trk)
                Rnd(knob,7); Bdr(knob,C.Border,1)

                -- Hit area
                local hit=Make("TextButton",{
                    Size=UDim2.new(1,0,0,24), Position=UDim2.new(0,0,0,30),
                    BackgroundTransparency=1, Text="", ZIndex=18,
                },card)

                local sliding=false
                local function upd(x)
                    local r=math.clamp((x-trk.AbsolutePosition.X)/math.max(trk.AbsoluteSize.X,1),0,1)
                    val=math.floor(min+(max-min)*r+0.5); vLbl.Text=tostring(val)
                    fill.Size=UDim2.new(r,0,1,0); knob.Position=UDim2.new(r,-7,0.5,-7)
                    pcall(c.Callback or function()end,val)
                end
                hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true;upd(i.Position.X) end end)
                UserInputService.InputChanged:Connect(function(i) if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
                hit.MouseEnter:Connect(function() Tw(card,{BackgroundColor3=C.CardHov},0.12) end)
                hit.MouseLeave:Connect(function() Tw(card,{BackgroundColor3=C.Card},0.12) end)

                local obj={Value=val}
                function obj:Set(v)
                    val=math.clamp(v,min,max);self.Value=val
                    local r=(val-min)/math.max(max-min,1);vLbl.Text=tostring(val)
                    fill.Size=UDim2.new(r,0,1,0);knob.Position=UDim2.new(r,-7,0.5,-7)
                end
                return obj
            end

            -- ════════════════════════════════════════════════════════
            --  DROPDOWN
            -- ════════════════════════════════════════════════════════
            function sec:Dropdown(c)
                c=c or {}; self._i=self._i+1
                local opts=c.Options or {}; local multi=c.Multi or false
                local sel=c.Default or (opts[1] or "Select"); local selSet={}
                local cb=c.Callback or function()end

                local card=Make("Frame",{
                    Size=UDim2.new(1,0,0,46), BackgroundColor3=C.Card,
                    BorderSizePixel=0, LayoutOrder=self._i, ClipsDescendants=false, ZIndex=14,
                },self.Body)
                Rnd(card,8); Bdr(card,C.Border,1); Pad(card,0,0,14,14)

                Make("TextLabel",{
                    Size=UDim2.new(0.4,0,1,0), BackgroundTransparency=1,
                    Text=c.Name or "Dropdown", TextColor3=C.TxtPri,
                    TextSize=12, Font=Enum.Font.GothamMedium,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=15,
                },card)

                local dBtn=Make("TextButton",{
                    Size=UDim2.new(0.58,0,0,30), Position=UDim2.new(0.42,0,0.5,-15),
                    BackgroundColor3=C.Input, Text=multi and "Select..." or tostring(sel),
                    TextColor3=C.TxtPri, TextSize=11, Font=Enum.Font.Gotham,
                    TextXAlignment=Enum.TextXAlignment.Left, BorderSizePixel=0,
                    ClipsDescendants=true, ZIndex=15,
                },card)
                Rnd(dBtn,6); Bdr(dBtn,C.Border,1); Pad(dBtn,0,0,10,24)

                local dArr=Make("TextLabel",{
                    Size=UDim2.new(0,20,1,0), Position=UDim2.new(1,-22,0,0),
                    BackgroundTransparency=1, Text="▾", TextColor3=C.TxtMut, TextSize=10, ZIndex=16,
                },dBtn)

                local lH=math.min(#opts,6)*34
                local lFr=Make("Frame",{
                    Size=UDim2.new(0.58,0,0,lH), Position=UDim2.new(0.42,0,0,50),
                    BackgroundColor3=Color3.fromRGB(16,16,20), BorderSizePixel=0, Visible=false, ZIndex=80,
                },card)
                Rnd(lFr,8); Bdr(lFr,C.Border,1)

                local lScr=Make("ScrollingFrame",{
                    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                    ScrollBarThickness=2, ScrollBarImageColor3=C.BorderAct,
                    CanvasSize=UDim2.new(0,0,0,#opts*34), ZIndex=81,
                },lFr)
                VList(lScr); Pad(lScr,4,4,0,0)

                local isOpen=false
                for i,opt in ipairs(opts) do
                    local ob=Make("TextButton",{
                        Size=UDim2.new(1,0,0,34), BackgroundTransparency=1,
                        Text="", BorderSizePixel=0, LayoutOrder=i, ZIndex=82,
                    },lScr)
                    Pad(ob,0,0,10,10)
                    Make("TextLabel",{
                        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                        Text=opt, TextColor3=selSet[opt] and C.Accent or C.TxtPri,
                        TextSize=11, Font=Enum.Font.Gotham,
                        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=83,
                    },ob)
                    ob.MouseEnter:Connect(function() Tw(ob,{BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(28,28,34)},0.1) end)
                    ob.MouseLeave:Connect(function() ob.BackgroundTransparency=1 end)
                    ob.MouseButton1Click:Connect(function()
                        local tl=ob:FindFirstChildOfClass("TextLabel")
                        if multi then
                            selSet[opt]=not selSet[opt] or nil
                            if tl then tl.TextColor3=selSet[opt] and C.Accent or C.TxtPri end
                            local n=0; for _ in pairs(selSet) do n=n+1 end
                            dBtn.Text=n>0 and (n.." selected") or "Select..."
                            pcall(cb,selSet)
                        else
                            sel=opt; dBtn.Text=opt; lFr.Visible=false; isOpen=false
                            Tw(dArr,{Rotation=0},0.15); pcall(cb,opt)
                        end
                    end)
                end

                dBtn.MouseButton1Click:Connect(function()
                    isOpen=not isOpen; lFr.Visible=isOpen
                    Tw(dArr,{Rotation=isOpen and 180 or 0},0.15)
                end)
                card.MouseEnter:Connect(function() if not isOpen then Tw(card,{BackgroundColor3=C.CardHov},0.12) end end)
                card.MouseLeave:Connect(function() Tw(card,{BackgroundColor3=C.Card},0.12) end)

                local obj={Value=sel,Selected=selSet}
                function obj:Set(v) sel=v;dBtn.Text=v end
                function obj:SelectAll() for _,o in ipairs(opts) do selSet[o]=true end;dBtn.Text=#opts.." selected" end
                function obj:DeselectAll() selSet={};dBtn.Text="Select..." end
                function obj:GetSelected()
                    if multi then local t={};for k in pairs(selSet) do table.insert(t,k) end;return t
                    else return sel end
                end
                return obj
            end

            -- ════════════════════════════════════════════════════════
            --  INPUT
            -- ════════════════════════════════════════════════════════
            function sec:Input(c)
                c=c or {}; self._i=self._i+1
                local card=Make("Frame",{
                    Size=UDim2.new(1,0,0,46), BackgroundColor3=C.Card,
                    BorderSizePixel=0, LayoutOrder=self._i, ZIndex=14,
                },self.Body)
                Rnd(card,8); Bdr(card,C.Border,1); Pad(card,0,0,14,14)

                Make("TextLabel",{
                    Size=UDim2.new(0.34,0,1,0), BackgroundTransparency=1,
                    Text=c.Name or "Input", TextColor3=C.TxtPri,
                    TextSize=12, Font=Enum.Font.GothamMedium,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=15,
                },card)

                local box=Make("TextBox",{
                    Size=UDim2.new(0.64,0,0,30), Position=UDim2.new(0.36,0,0.5,-15),
                    BackgroundColor3=C.Input, PlaceholderText=c.Placeholder or "",
                    PlaceholderColor3=C.TxtMut, Text="",
                    TextColor3=C.TxtPri, TextSize=11, Font=Enum.Font.Gotham,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    ClearTextOnFocus=false, BorderSizePixel=0, ZIndex=15,
                },card)
                Rnd(box,6); local bS=Bdr(box,C.Border,1); Pad(box,0,0,10,4)
                box.Focused:Connect(function() Tw(bS,{Color=C.AccentDim},0.15) end)
                box.FocusLost:Connect(function(e)
                    Tw(bS,{Color=C.Border},0.15)
                    if e then pcall(c.Callback or function()end,box.Text) end
                end)
                card.MouseEnter:Connect(function() Tw(card,{BackgroundColor3=C.CardHov},0.12) end)
                card.MouseLeave:Connect(function() Tw(card,{BackgroundColor3=C.Card},0.12) end)

                local obj={}
                function obj:Get() return box.Text end
                function obj:Set(v) box.Text=v end
                return obj
            end

            -- ════════════════════════════════════════════════════════
            --  LABEL  (plain text)
            -- ════════════════════════════════════════════════════════
            function sec:Label(c)
                c=c or {}; self._i=self._i+1
                return Make("TextLabel",{
                    Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
                    BackgroundTransparency=1, Text=c.Text or "",
                    TextColor3=c.Color or C.TxtSec, TextSize=11, Font=Enum.Font.Gotham,
                    TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true,
                    LayoutOrder=self._i, ZIndex=14,
                },self.Body)
            end

            -- ════════════════════════════════════════════════════════
            --  SEPARATOR
            -- ════════════════════════════════════════════════════════
            function sec:Separator()
                self._i=self._i+1
                Make("Frame",{
                    Size=UDim2.new(1,0,0,1), BackgroundColor3=C.Border,
                    BorderSizePixel=0, LayoutOrder=self._i, ZIndex=14,
                },self.Body)
            end

            return sec
        end -- :Section()

        self.Tabs[name] = tab
        return tab
    end -- :Tab()

    return win
end -- :Window()

return NateiraHub
