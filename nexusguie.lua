--[[
    ██╗   ██╗ ██████╗ ██████╗  █████╗ ██╗  ██╗██╗   ██╗██████╗ 
    ██║   ██║██╔═══██╗██╔══██╗██╔══██╗██║  ██║██║   ██║██╔══██╗
    ██║   ██║██║   ██║██████╔╝███████║███████║██║   ██║██████╔╝
    ╚██╗ ██╔╝██║   ██║██╔══██╗██╔══██║██╔══██║██║   ██║██╔══██╗
     ╚████╔╝ ╚██████╔╝██║  ██║██║  ██║██║  ██║╚██████╔╝██████╔╝
      ╚═══╝   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 

    VoraHub UI Library - Monochrome Cyber-Stealth Edition
    Visual design inspired by VoraHub premium hub layout.
    Core config/callback system preserved from original WisHub.
    
    Rewritten by: Claude (Sonnet 4.6) for Nynzz
    
    ACCENT COLOR CONFIG — toggle here:
    AccentColor options:
      Monochrome White  → Color3.fromRGB(255, 255, 255)
      Neon Blue         → Color3.fromRGB(0, 140, 255)
      Cyber Green       → Color3.fromRGB(0, 255, 140)
      Pure White (VH)   → Color3.fromRGB(220, 220, 220)  ← default VoraHub style
--]]

-- ╔══════════════════════════════════════════╗
-- ║           ACCENT COLOR CONFIG            ║
-- ╚══════════════════════════════════════════╝
local AccentColor = Color3.fromRGB(220, 220, 220)  -- Change this to switch theme

-- ╔══════════════════════════════════════════╗
-- ║           SERVICES & GLOBALS            ║
-- ╚══════════════════════════════════════════╝
local HttpService      = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()

-- ╔══════════════════════════════════════════╗
-- ║           CONFIG / SAVE SYSTEM          ║
-- ╚══════════════════════════════════════════╝
if not isfolder("VoraHub") then makefolder("VoraHub") end
if not isfolder("VoraHub/Config") then makefolder("VoraHub/Config") end

local gameName   = tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
gameName         = gameName:gsub("[^%w_ ]", ""):gsub("%s+", "_")
local ConfigFile = "VoraHub/Config/" .. gameName .. ".json"

ConfigData       = {}
Elements         = {}
CURRENT_VERSION  = nil

function SaveConfig()
    if writefile then
        ConfigData._version = CURRENT_VERSION
        writefile(ConfigFile, HttpService:JSONEncode(ConfigData))
    end
end

function LoadConfigFromFile()
    if not CURRENT_VERSION then return end
    if isfile and isfile(ConfigFile) then
        local ok, result = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if ok and type(result) == "table" then
            ConfigData = (result._version == CURRENT_VERSION) and result or { _version = CURRENT_VERSION }
        else
            ConfigData = { _version = CURRENT_VERSION }
        end
    else
        ConfigData = { _version = CURRENT_VERSION }
    end
end

function LoadConfigElements()
    for key, element in pairs(Elements) do
        if ConfigData[key] ~= nil and element.Set then
            element:Set(ConfigData[key], true)
        end
    end
end

-- ╔══════════════════════════════════════════╗
-- ║           ICON REGISTRY                 ║
-- ╚══════════════════════════════════════════╝
local Icons = {
    player    = "rbxassetid://12120698352",
    web       = "rbxassetid://137601480983962",
    bag       = "rbxassetid://8601111810",
    shop      = "rbxassetid://4985385964",
    cart      = "rbxassetid://128874923961846",
    plug      = "rbxassetid://137601480983962",
    settings  = "rbxassetid://70386228443175",
    loop      = "rbxassetid://122032243989747",
    gps       = "rbxassetid://17824309485",
    compas    = "rbxassetid://125300760963399",
    gamepad   = "rbxassetid://84173963561612",
    boss      = "rbxassetid://13132186360",
    scroll    = "rbxassetid://114127804740858",
    menu      = "rbxassetid://6340513838",
    crosshair = "rbxassetid://12614416478",
    user      = "rbxassetid://108483430622128",
    stat      = "rbxassetid://12094445329",
    eyes      = "rbxassetid://14321059114",
    sword     = "rbxassetid://82472368671405",
    discord   = "rbxassetid://94434236999817",
    star      = "rbxassetid://107005941750079",
    skeleton  = "rbxassetid://17313330026",
    payment   = "rbxassetid://18747025078",
    scan      = "rbxassetid://109869955247116",
    alert     = "rbxassetid://73186275216515",
    question  = "rbxassetid://17510196486",
    idea      = "rbxassetid://16833255748",
    strom     = "rbxassetid://13321880293",
    water     = "rbxassetid://100076212630732",
    dcs       = "rbxassetid://15310731934",
    start     = "rbxassetid://108886429866687",
    next      = "rbxassetid://12662718374",
    rod       = "rbxassetid://103247953194129",
    fish      = "rbxassetid://97167558235554",
    arrow     = "rbxassetid://16851841101",
    close_x   = "rbxassetid://9886659671",
    minimize  = "rbxassetid://9886659276",
}

-- ╔══════════════════════════════════════════╗
-- ║           DESIGN TOKENS                 ║
-- ╚══════════════════════════════════════════╝
local Theme = {
    -- Backgrounds
    BgMain       = Color3.fromRGB(13, 13, 13),      -- Main window
    BgSidebar    = Color3.fromRGB(18, 18, 18),      -- Sidebar nav
    BgCard       = Color3.fromRGB(22, 22, 22),      -- Section cards
    BgElement    = Color3.fromRGB(30, 30, 30),      -- Toggle/button bg
    BgInput      = Color3.fromRGB(26, 26, 26),      -- Input fields
    BgTopbar     = Color3.fromRGB(16, 16, 16),      -- Top bar

    -- Text
    TextPrimary  = Color3.fromRGB(255, 255, 255),   -- Headers / labels
    TextSecond   = Color3.fromRGB(160, 160, 160),   -- Descriptions
    TextMuted    = Color3.fromRGB(90, 90, 90),      -- Placeholder

    -- Accent (driven by AccentColor global)
    Accent       = AccentColor,
    AccentDim    = Color3.fromRGB(60, 60, 60),      -- Inactive toggle track

    -- Borders
    Border       = Color3.fromRGB(38, 38, 38),      -- Subtle card border
    BorderActive = AccentColor,                      -- Active state border

    -- Category header highlight
    CatBg        = Color3.fromRGB(28, 28, 28),

    -- Sidebar pill active
    PillActive   = Color3.fromRGB(38, 38, 38),

    -- Top bar separator
    Separator    = Color3.fromRGB(35, 35, 35),

    -- Toggle ON color
    ToggleOn     = AccentColor,
    ToggleOff    = Color3.fromRGB(45, 45, 45),
}

-- ╔══════════════════════════════════════════╗
-- ║           UTILITY FUNCTIONS             ║
-- ╚══════════════════════════════════════════╝
local function isMobile()
    return UserInputService.TouchEnabled
        and not UserInputService.KeyboardEnabled
        and not UserInputService.MouseEnabled
end

local function New(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

local function Corner(radius, parent)
    return New("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

local function Stroke(color, thickness, parent, trans)
    return New("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = trans or 0,
        Parent = parent
    })
end

local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj, TweenInfo.new(
        t or 0.25,
        style or Enum.EasingStyle.Quad,
        dir or Enum.EasingDirection.Out
    ), props):Play()
end

local function MakeDraggable(handle, window)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = inp.Position
            startPos = window.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            dragInput = inp
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp == dragInput and dragging then
            local delta = inp.Position - dragStart
            Tween(window, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }, 0.15)
        end
    end)
end

-- ╔══════════════════════════════════════════╗
-- ║           NOTIFICATION SYSTEM           ║
-- ╚══════════════════════════════════════════╝
local VoraHub = {}

function VoraHub:Notify(cfg)
    cfg = cfg or {}
    cfg.Title    = cfg.Title    or "VoraHub"
    cfg.Content  = cfg.Content  or "Notification"
    cfg.Color    = cfg.Color    or Theme.Accent
    cfg.Duration = cfg.Duration or 4

    local fn = {}
    spawn(function()
        if not CoreGui:FindFirstChild("VHNotifyGui") then
            New("ScreenGui", {
                Name = "VHNotifyGui", ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                ResetOnSpawn = false, Parent = CoreGui
            })
        end
        local Gui = CoreGui.VHNotifyGui
        if not Gui:FindFirstChild("Container") then
            New("Frame", {
                Name = "Container",
                AnchorPoint = Vector2.new(1, 1),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -16, 1, -16),
                Size = UDim2.new(0, 300, 1, 0),
                Parent = Gui
            })
            New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 8),
                Parent = Gui.Container
            })
        end

        local Container = Gui.Container

        -- Notification card
        local Card = New("Frame", {
            Name = "Notify",
            BackgroundColor3 = Theme.BgCard,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 72),
            Position = UDim2.new(1, 10, 0, 0),
            Parent = Container
        })
        Corner(8, Card)
        Stroke(Theme.Border, 1, Card)

        -- Accent left strip
        New("Frame", {
            BackgroundColor3 = cfg.Color,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 1, -16),
            Position = UDim2.new(0, 0, 0, 8),
            Parent = Card
        })
        Corner(2, Card:FindFirstChildOfClass("Frame"))

        -- Title
        New("TextLabel", {
            Font = Enum.Font.GothamBold,
            Text = cfg.Title,
            TextColor3 = Theme.TextPrimary,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 12),
            Size = UDim2.new(1, -50, 0, 14),
            Parent = Card
        })

        -- Content
        New("TextLabel", {
            Font = Enum.Font.Gotham,
            Text = cfg.Content,
            TextColor3 = Theme.TextSecond,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 30),
            Size = UDim2.new(1, -20, 0, 32),
            Parent = Card
        })

        -- Close button
        local CloseBtn = New("TextButton", {
            Text = "✕",
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextColor3 = Theme.TextMuted,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -8, 0, 8),
            Size = UDim2.new(0, 20, 0, 20),
            Parent = Card
        })

        local closed = false
        local function CloseNotif()
            if closed then return end
            closed = true
            Tween(Card, { Position = UDim2.new(1, 10, 0, 0) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.wait(0.35)
            Card:Destroy()
        end
        fn.Close = CloseNotif

        -- Animate in
        Tween(Card, { Position = UDim2.new(0, 0, 0, 0) }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        CloseBtn.Activated:Connect(CloseNotif)

        task.wait(cfg.Duration)
        CloseNotif()
    end)
    return fn
end

function than(msg, delay, color, title)
    return VoraHub:Notify({
        Title   = title or "VoraHub",
        Content = msg or "Notification",
        Color   = color or Theme.Accent,
        Duration= delay or 4
    })
end

-- ╔══════════════════════════════════════════╗
-- ║              MAIN WINDOW                ║
-- ╚══════════════════════════════════════════╝
function VoraHub:Window(cfg)
    cfg           = cfg or {}
    cfg.Title     = cfg.Title   or "VoraHub"
    cfg.SubTitle  = cfg.SubTitle or ""
    cfg.Version   = cfg.Version or 1
    cfg.Image     = cfg.Image   or nil  -- for toggle button

    CURRENT_VERSION = cfg.Version
    LoadConfigFromFile()

    local W = {}

    -- Screen GUI
    local ScreenGui = New("ScreenGui", {
        Name = "VoraHubUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        Parent = CoreGui
    })

    -- ── Main Window Frame ──────────────────────────────────────────────
    local WinSize = isMobile() and UDim2.new(0, 520, 0, 320) or UDim2.new(0, 720, 0, 460)
    local Window = New("Frame", {
        Name = "Window",
        BackgroundColor3 = Theme.BgMain,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = WinSize,
        Parent = ScreenGui
    })
    Corner(10, Window)
    Stroke(Theme.Border, 1, Window)

    -- Drop shadow
    local Shadow = New("ImageLabel", {
        Name = "Shadow",
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 60, 1, 60),
        ZIndex = 0,
        Parent = Window
    })

    -- ── TOP BAR ────────────────────────────────────────────────────────
    local TopBar = New("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Theme.BgTopbar,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = Window
    })
    Corner(10, TopBar)

    -- Fix bottom corners of topbar
    New("Frame", {
        BackgroundColor3 = Theme.BgTopbar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
        Parent = TopBar
    })

    -- Top bar separator line
    New("Frame", {
        BackgroundColor3 = Theme.Separator,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 2,
        Parent = TopBar
    })

    -- App Name
    local AppTitle = New("TextLabel", {
        Font = Enum.Font.GothamBold,
        Text = cfg.Title,
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(0, 140, 1, 0),
        ZIndex = 2,
        Parent = TopBar
    })

    -- Player Avatar Holder (round)
    local AvatarHolder = New("Frame", {
        BackgroundColor3 = Theme.BgElement,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 14 + 8, 0.5, 0),
        Size = UDim2.new(0, 26, 0, 26),
        ZIndex = 2,
        Parent = TopBar
    })
    Corner(13, AvatarHolder)
    Stroke(Theme.Border, 1, AvatarHolder)

    -- Load avatar async
    spawn(function()
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size48x48
            )
        end)
        if ok then
            New("ImageLabel", {
                Image = img,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 3,
                Parent = AvatarHolder
            })
            Corner(13, AvatarHolder:FindFirstChildOfClass("ImageLabel"))
        end
    end)

    -- Reposition title to be left of avatar
    AppTitle.Size = UDim2.new(0, 100, 1, 0)

    -- Avatar sits right after title
    AvatarHolder.Position = UDim2.new(0, AppTitle.Position.X.Offset + AppTitle.Size.X.Offset + 8, 0.5, 0)

    -- Player name label next to avatar
    New("TextLabel", {
        Font = Enum.Font.Gotham,
        Text = LocalPlayer.DisplayName,
        TextColor3 = Theme.TextSecond,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, AppTitle.Position.X.Offset + AppTitle.Size.X.Offset + 40, 0, 0),
        Size = UDim2.new(0, 120, 1, 0),
        ZIndex = 2,
        Parent = TopBar
    })

    -- Search Bar (right side)
    local SearchBg = New("Frame", {
        Name = "SearchBg",
        BackgroundColor3 = Theme.BgInput,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -80, 0.5, 0),
        Size = UDim2.new(0, 180, 0, 26),
        ZIndex = 2,
        Parent = TopBar
    })
    Corner(6, SearchBg)
    Stroke(Theme.Border, 1, SearchBg)

    New("TextLabel", {
        Font = Enum.Font.Gotham,
        Text = "🔍",
        TextSize = 11,
        TextColor3 = Theme.TextMuted,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 0),
        Size = UDim2.new(0, 18, 1, 0),
        ZIndex = 3,
        Parent = SearchBg
    })

    local SearchBox = New("TextBox", {
        Font = Enum.Font.Gotham,
        PlaceholderText = "Search tabs/groups...",
        PlaceholderColor3 = Theme.TextMuted,
        Text = "",
        TextColor3 = Theme.TextPrimary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Position = UDim2.new(0, 26, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
        ZIndex = 3,
        Parent = SearchBg
    })

    -- Window control buttons (right of topbar)
    local function MakeWinBtn(offsetX, icon, color)
        local Btn = New("TextButton", {
            Text = icon,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = color or Theme.TextSecond,
            BackgroundColor3 = Theme.BgElement,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -offsetX, 0.5, 0),
            Size = UDim2.new(0, 22, 0, 22),
            ZIndex = 3,
            Parent = TopBar
        })
        Corner(5, Btn)
        Btn.MouseEnter:Connect(function()
            Tween(Btn, { BackgroundColor3 = Theme.BgCard }, 0.15)
        end)
        Btn.MouseLeave:Connect(function()
            Tween(Btn, { BackgroundColor3 = Theme.BgElement }, 0.15)
        end)
        return Btn
    end

    local CloseBtn = MakeWinBtn(10, "✕", Color3.fromRGB(255, 80, 80))
    local MinBtn   = MakeWinBtn(38, "—", Theme.TextSecond)

    -- Min/Close logic
    MinBtn.Activated:Connect(function()
        Window.Visible = false
    end)

    CloseBtn.Activated:Connect(function()
        -- Clean close dialog
        local Overlay = New("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 100,
            Parent = Window
        })

        local Dialog = New("Frame", {
            BackgroundColor3 = Theme.BgCard,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 280, 0, 130),
            ZIndex = 101,
            Parent = Overlay
        })
        Corner(10, Dialog)
        Stroke(Theme.Border, 1, Dialog)

        New("TextLabel", {
            Font = Enum.Font.GothamBold,
            Text = "Close VoraHub?",
            TextColor3 = Theme.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Center,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 18),
            Size = UDim2.new(1, 0, 0, 18),
            ZIndex = 102,
            Parent = Dialog
        })

        New("TextLabel", {
            Font = Enum.Font.Gotham,
            Text = "You won't be able to reopen this.",
            TextColor3 = Theme.TextSecond,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Center,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 42),
            Size = UDim2.new(1, 0, 0, 14),
            ZIndex = 102,
            Parent = Dialog
        })

        local function MakeDialogBtn(label, xPos, bgColor, callback)
            local B = New("TextButton", {
                Font = Enum.Font.GothamBold,
                Text = label,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                BackgroundColor3 = bgColor,
                BorderSizePixel = 0,
                Position = xPos,
                Size = UDim2.new(0, 110, 0, 32),
                ZIndex = 102,
                Parent = Dialog
            })
            Corner(7, B)
            B.Activated:Connect(callback)
            return B
        end

        MakeDialogBtn("Close", UDim2.new(0, 20, 1, -46), Color3.fromRGB(60, 25, 25), function()
            ScreenGui:Destroy()
            if CoreGui:FindFirstChild("VHToggleBtn") then CoreGui.VHToggleBtn:Destroy() end
        end)
        MakeDialogBtn("Cancel", UDim2.new(0, 148, 1, -46), Theme.BgElement, function()
            Overlay:Destroy()
        end)
    end)

    -- Make topbar draggable
    MakeDraggable(TopBar, Window)

    -- ── BODY LAYOUT ────────────────────────────────────────────────────
    local BodyFrame = New("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(1, 0, 1, -42),
        Parent = Window
    })

    -- ── SIDEBAR ────────────────────────────────────────────────────────
    local SidebarWidth = 150
    local Sidebar = New("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Theme.BgSidebar,
        BorderSizePixel = 0,
        Size = UDim2.new(0, SidebarWidth, 1, 0),
        Parent = BodyFrame
    })
    -- Bottom-left corner only
    local SidebarCornerFix = New("Frame", {
        BackgroundColor3 = Theme.BgSidebar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 10),
        Parent = Sidebar
    })

    -- Right border of sidebar
    New("Frame", {
        BackgroundColor3 = Theme.Separator,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Parent = Sidebar
    })

    -- Sidebar scroll
    local SideScroll = New("ScrollingFrame", {
        Name = "SideScroll",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Parent = Sidebar
    })

    local SideList = New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = SideScroll
    })

    SideList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SideScroll.CanvasSize = UDim2.new(0, 0, 0, SideList.AbsoluteContentSize.Y + 8)
    end)

    New("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = SideScroll
    })

    -- ── CONTENT AREA ───────────────────────────────────────────────────
    local ContentArea = New("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, SidebarWidth + 1, 0, 0),
        Size = UDim2.new(1, -(SidebarWidth + 1), 1, 0),
        ClipsDescendants = true,
        Parent = BodyFrame
    })

    -- Content holder (UIPageLayout)
    local PagesFolder = New("Folder", {
        Name = "Pages",
        Parent = ContentArea
    })

    local PageLayout = New("UIPageLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        TweenTime = 0.3,
        EasingStyle = Enum.EasingStyle.Quad,
        EasingDirection = Enum.EasingDirection.InOut,
        FillDirection = Enum.FillDirection.Vertical,
        Parent = PagesFolder
    })

    -- ── TOGGLE BUTTON (minimized state) ────────────────────────────────
    function W:ToggleUI()
        if not cfg.Image then return end
        local TGui = New("ScreenGui", {
            Name = "VHToggleBtn",
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false,
            Parent = CoreGui
        })
        local TBtn = New("ImageLabel", {
            Image = "rbxassetid://" .. tostring(cfg.Image),
            BackgroundColor3 = Theme.BgCard,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 20, 0.5, -25),
            Size = UDim2.new(0, 50, 0, 50),
            Parent = TGui
        })
        Corner(10, TBtn)
        Stroke(Theme.Border, 1, TBtn)

        local TBtnClick = New("TextButton", {
            Text = "",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = TBtn
        })
        TBtnClick.Activated:Connect(function()
            Window.Visible = not Window.Visible
        end)

        local drag, ds, sp = false, nil, nil
        TBtnClick.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                drag = true; ds = inp.Position; sp = TBtn.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then drag = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if drag and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local d = inp.Position - ds
                TBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
            end
        end)
    end
    W:ToggleUI()

    function W:DestroyGui()
        ScreenGui:Destroy()
    end

    -- ── SEARCH FILTER ──────────────────────────────────────────────────
    -- (wires to category filtering, impl below after categories built)

    -- ── CATEGORY / TAB SYSTEM ──────────────────────────────────────────
    local CategoryCount = 0
    local AllSubTabs = {}         -- {tabFrame, pageName, searchName}
    local ActivePage = nil
    local FirstTab = true

    local function ActivateSubTab(tabBtn, pillBg, pageFrame, displayName, allTabBtns)
        -- Deactivate all
        for _, t in pairs(allTabBtns) do
            if t.Pill then Tween(t.Pill, { BackgroundTransparency = 1 }, 0.15) end
            if t.Label then Tween(t.Label, { TextColor3 = Theme.TextSecond }, 0.15) end
        end
        -- Activate selected
        Tween(pillBg, { BackgroundTransparency = 0 }, 0.15)
        Tween(tabBtn,  { TextColor3 = Theme.TextPrimary }, 0.15)

        -- Jump page
        PageLayout:JumpTo(pageFrame)
        ActivePage = pageFrame
    end

    -- Shared tab registry for search
    local AllTabRegistry = {}

    -- AddCategory: creates collapsible sidebar header + nested sub-tabs
    function W:AddCategory(catCfg)
        catCfg = catCfg or {}
        catCfg.Name = catCfg.Name or "Category"
        catCfg.Icon = catCfg.Icon or ""

        local catOrder = CategoryCount
        CategoryCount  = CategoryCount + 1

        -- Category header row
        local CatHeader = New("Frame", {
            Name = "Cat_" .. catCfg.Name,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = catOrder,
            Size = UDim2.new(1, 0, 0, 28),
            Parent = SideScroll
        })

        -- Category icon
        if catCfg.Icon ~= "" then
            local img = Icons[catCfg.Icon] or catCfg.Icon
            New("ImageLabel", {
                Image = img,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Parent = CatHeader
            })
        end

        -- Category label
        local iconOff = (catCfg.Icon ~= "") and 20 or 4
        local CatLabel = New("TextLabel", {
            Font = Enum.Font.GothamBold,
            Text = string.upper(catCfg.Name),
            TextColor3 = Theme.TextMuted,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            LetterSpacing = 1,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, iconOff, 0, 0),
            Size = UDim2.new(1, -(iconOff + 20), 1, 0),
            Parent = CatHeader
        })

        -- Arrow indicator
        local ArrowLabel = New("TextLabel", {
            Font = Enum.Font.GothamBold,
            Text = "▾",
            TextColor3 = Theme.TextMuted,
            TextSize = 10,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
            BackgroundTransparency = 1,
            Parent = CatHeader
        })

        -- Category click button (collapse/expand)
        local CatBtn = New("TextButton", {
            Text = "",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = CatHeader
        })

        -- Sub-tab container
        local SubContainer = New("Frame", {
            Name = "Subs_" .. catCfg.Name,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = catOrder,
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true,
            Parent = SideScroll
        })

        local SubList = New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
            Parent = SubContainer
        })

        local subExpanded = true
        local subTotalHeight = 0

        -- Collapse / Expand logic
        local function RefreshSubHeight()
            subTotalHeight = 0
            for _, c in SubContainer:GetChildren() do
                if c:IsA("Frame") then
                    subTotalHeight = subTotalHeight + c.Size.Y.Offset + 2
                end
            end
            if subExpanded then
                Tween(SubContainer, { Size = UDim2.new(1, 0, 0, subTotalHeight) }, 0.25)
                ArrowLabel.Text = "▾"
            end
        end

        SubList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RefreshSubHeight)

        CatBtn.Activated:Connect(function()
            subExpanded = not subExpanded
            if subExpanded then
                Tween(SubContainer, { Size = UDim2.new(1, 0, 0, subTotalHeight) }, 0.25)
                ArrowLabel.Text = "▾"
            else
                Tween(SubContainer, { Size = UDim2.new(1, 0, 0, 0) }, 0.25)
                ArrowLabel.Text = "▸"
            end
        end)

        -- Sub-tab function
        local Cat = {}
        local SubOrder = 0
        -- A shared list of all sub-tab pill references for this category (for deactivation)
        -- We use the global AllTabRegistry for cross-category deactivation

        function Cat:AddTab(tabCfg)
            tabCfg      = tabCfg or {}
            tabCfg.Name = tabCfg.Name or "Tab"
            tabCfg.Icon = tabCfg.Icon or ""

            local tabOrder = SubOrder
            SubOrder = SubOrder + 1

            -- Create content page
            local PageFrame = New("ScrollingFrame", {
                Name = "Page_" .. catCfg.Name .. "_" .. tabCfg.Name,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                LayoutOrder = CategoryCount * 100 + tabOrder,
                Size = UDim2.new(1, 0, 1, 0),
                Parent = PagesFolder
            })

            New("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                Parent = PageFrame
            })

            -- Two-column layout using two nested frames
            local ColLeft = New("Frame", {
                Name = "ColLeft",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0.5, -6, 1, 0),
                Parent = PageFrame
            })
            New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                Parent = ColLeft
            })

            local ColRight = New("Frame", {
                Name = "ColRight",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, 6, 0, 0),
                Size = UDim2.new(0.5, -6, 1, 0),
                Parent = PageFrame
            })
            New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                Parent = ColRight
            })

            -- Auto canvas resize
            local function UpdateCanvas()
                local lh = ColLeft:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y
                local rh = ColRight:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y
                PageFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(lh, rh) + 24)
            end
            ColLeft:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
            ColRight:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

            -- ── SIDEBAR PILL BUTTON ──────────────────────────────────────
            local SubTabRow = New("Frame", {
                Name = "SubTab_" .. tabCfg.Name,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                LayoutOrder = tabOrder,
                Size = UDim2.new(1, 0, 0, 28),
                Parent = SubContainer
            })

            -- Pill background (hidden when inactive)
            local Pill = New("Frame", {
                Name = "Pill",
                BackgroundColor3 = Theme.PillActive,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 1,
                Parent = SubTabRow
            })
            Corner(6, Pill)

            -- Left accent strip (shown when active)
            local ActiveStrip = New("Frame", {
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 2, 0, 14),
                Position = UDim2.new(0, 0, 0.5, -7),
                ZIndex = 2,
                Parent = SubTabRow
            })
            Corner(2, ActiveStrip)

            -- Icon
            local tabIconOffset = 10
            if tabCfg.Icon ~= "" then
                local img = Icons[tabCfg.Icon] or tabCfg.Icon
                New("ImageLabel", {
                    Image = img,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 8, 0.5, -8),
                    Size = UDim2.new(0, 14, 0, 14),
                    ZIndex = 2,
                    Parent = SubTabRow
                })
                tabIconOffset = 26
            end

            -- Label
            local TabLabel = New("TextLabel", {
                Font = Enum.Font.Gotham,
                Text = tabCfg.Name,
                TextColor3 = Theme.TextSecond,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, tabIconOffset, 0, 0),
                Size = UDim2.new(1, -tabIconOffset, 1, 0),
                ZIndex = 2,
                Parent = SubTabRow
            })

            -- Click button
            local SubBtn = New("TextButton", {
                Text = "",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 3,
                Parent = SubTabRow
            })

            -- Register into global list
            local entry = { Pill = Pill, Label = TabLabel, Strip = ActiveStrip, Page = PageFrame }
            table.insert(AllTabRegistry, entry)

            -- Activate first tab automatically
            if FirstTab then
                FirstTab = false
                Pill.BackgroundTransparency = 0
                TabLabel.TextColor3 = Theme.TextPrimary
                ActiveStrip.BackgroundTransparency = 0
                TabLabel.Font = Enum.Font.GothamBold
                PageLayout:JumpTo(PageFrame)
                ActivePage = PageFrame
            end

            SubBtn.Activated:Connect(function()
                -- Deactivate all tabs globally
                for _, t in pairs(AllTabRegistry) do
                    Tween(t.Pill,  { BackgroundTransparency = 1 }, 0.15)
                    Tween(t.Label, { TextColor3 = Theme.TextSecond }, 0.15)
                    Tween(t.Strip, { BackgroundTransparency = 1 }, 0.15)
                    t.Label.Font = Enum.Font.Gotham
                end
                -- Activate this tab
                Tween(Pill,       { BackgroundTransparency = 0 }, 0.15)
                Tween(TabLabel,   { TextColor3 = Theme.TextPrimary }, 0.15)
                Tween(ActiveStrip,{ BackgroundTransparency = 0 }, 0.15)
                TabLabel.Font = Enum.Font.GothamBold
                PageLayout:JumpTo(PageFrame)
                ActivePage = PageFrame
            end)

            -- Search integration
            table.insert(AllSubTabs, {
                btn  = SubBtn,
                row  = SubTabRow,
                name = string.lower(tabCfg.Name)
            })

            -- ── TAB API ─────────────────────────────────────────────────
            local Tab = {}

            -- AddSection: creates a card groupbox in left or right column
            function Tab:AddSection(secCfg)
                secCfg        = secCfg or {}
                secCfg.Name   = secCfg.Name  or "Section"
                secCfg.Side   = secCfg.Side  or "Left"

                local targetCol = (secCfg.Side == "Right") and ColRight or ColLeft

                -- Card frame
                local Card = New("Frame", {
                    Name = "Section_" .. secCfg.Name,
                    BackgroundColor3 = Theme.BgCard,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 36),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = targetCol
                })
                Corner(8, Card)
                Stroke(Theme.Border, 1, Card)

                -- Section header row
                local HeaderRow = New("Frame", {
                    Name = "Header",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = Card
                })

                New("TextLabel", {
                    Font = Enum.Font.GothamBold,
                    Text = secCfg.Name,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    Parent = HeaderRow
                })

                -- Header separator
                New("Frame", {
                    BackgroundColor3 = Theme.Separator,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 12, 1, 0),
                    Size = UDim2.new(1, -24, 0, 1),
                    Parent = HeaderRow
                })

                -- Element container
                local ElemContainer = New("Frame", {
                    Name = "Elements",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 33),
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = Card
                })

                New("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 1),
                    Parent = ElemContainer
                })

                New("UIPadding", {
                    PaddingLeft   = UDim.new(0, 8),
                    PaddingRight  = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 8),
                    Parent = ElemContainer
                })

                -- Section API
                local Sec = {}
                local ElemOrder = 0

                -- ── TOGGLE ──────────────────────────────────────────────
                function Sec:AddToggle(tCfg)
                    tCfg          = tCfg or {}
                    tCfg.Title    = tCfg.Title   or "Toggle"
                    tCfg.Default  = tCfg.Default  or false
                    tCfg.Desc     = tCfg.Desc     or ""
                    tCfg.Callback = tCfg.Callback or function() end

                    local configKey = "Toggle_" .. tCfg.Title
                    if ConfigData[configKey] ~= nil then
                        tCfg.Default = ConfigData[configKey]
                    end

                    local TF = { Value = tCfg.Default }

                    -- Row
                    local Row = New("Frame", {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = ElemOrder,
                        Size = UDim2.new(1, 0, 0, tCfg.Desc ~= "" and 44 or 32),
                        Parent = ElemContainer
                    })

                    -- Title
                    New("TextLabel", {
                        Font = Enum.Font.Gotham,
                        Text = tCfg.Title,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, tCfg.Desc ~= "" and 6 or 0),
                        Size = UDim2.new(1, -50, 0, 14),
                        Parent = Row
                    })

                    -- Desc
                    if tCfg.Desc ~= "" then
                        New("TextLabel", {
                            Font = Enum.Font.Gotham,
                            Text = tCfg.Desc,
                            TextColor3 = Theme.TextSecond,
                            TextSize = 10,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 0, 0, 22),
                            Size = UDim2.new(1, -50, 0, 12),
                            Parent = Row
                        })
                    end

                    -- Pill track
                    local Track = New("Frame", {
                        Name = "Track",
                        BackgroundColor3 = Theme.ToggleOff,
                        BorderSizePixel = 0,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, 0, 0.5, 0),
                        Size = UDim2.new(0, 34, 0, 18),
                        Parent = Row
                    })
                    Corner(9, Track)

                    -- Thumb circle
                    local Thumb = New("Frame", {
                        Name = "Thumb",
                        BackgroundColor3 = Color3.fromRGB(180, 180, 180),
                        BorderSizePixel = 0,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 2, 0.5, 0),
                        Size = UDim2.new(0, 14, 0, 14),
                        Parent = Track
                    })
                    Corner(7, Thumb)

                    -- Click button
                    local TBtn = New("TextButton", {
                        Text = "",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Parent = Row
                    })

                    function TF:Set(val, silent)
                        TF.Value = val
                        if val then
                            Tween(Track, { BackgroundColor3 = Theme.ToggleOn }, 0.2)
                            Tween(Thumb, {
                                Position = UDim2.new(0, 18, 0.5, 0),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                            }, 0.2)
                        else
                            Tween(Track, { BackgroundColor3 = Theme.ToggleOff }, 0.2)
                            Tween(Thumb, {
                                Position = UDim2.new(0, 2, 0.5, 0),
                                BackgroundColor3 = Color3.fromRGB(180, 180, 180)
                            }, 0.2)
                        end
                        ConfigData[configKey] = val
                        SaveConfig()
                        if not silent then
                            local ok, err = pcall(tCfg.Callback, val)
                            if not ok then warn("Toggle callback error:", err) end
                        end
                    end

                    TBtn.Activated:Connect(function() TF:Set(not TF.Value) end)
                    TF:Set(TF.Value, true)
                    ElemOrder = ElemOrder + 1
                    Elements[configKey] = TF
                    UpdateCanvas()
                    return TF
                end

                -- ── SLIDER ──────────────────────────────────────────────
                function Sec:AddSlider(sCfg)
                    sCfg           = sCfg or {}
                    sCfg.Title     = sCfg.Title     or "Slider"
                    sCfg.Min       = sCfg.Min       or 0
                    sCfg.Max       = sCfg.Max       or 100
                    sCfg.Default   = sCfg.Default   or 50
                    sCfg.Increment = sCfg.Increment or 1
                    sCfg.Desc      = sCfg.Desc      or ""
                    sCfg.Callback  = sCfg.Callback  or function() end

                    local configKey = "Slider_" .. sCfg.Title
                    if ConfigData[configKey] ~= nil then
                        sCfg.Default = ConfigData[configKey]
                    end

                    local SF = { Value = sCfg.Default }

                    local Row = New("Frame", {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = ElemOrder,
                        Size = UDim2.new(1, 0, 0, 48),
                        Parent = ElemContainer
                    })

                    -- Title row
                    New("TextLabel", {
                        Font = Enum.Font.Gotham,
                        Text = sCfg.Title,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 4),
                        Size = UDim2.new(1, -40, 0, 14),
                        Parent = Row
                    })

                    -- Value display
                    local ValLabel = New("TextLabel", {
                        Font = Enum.Font.GothamBold,
                        Text = tostring(sCfg.Default),
                        TextColor3 = Theme.Accent,
                        TextSize = 11,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, 0, 0, 4),
                        Size = UDim2.new(0, 36, 0, 14),
                        BackgroundTransparency = 1,
                        Parent = Row
                    })

                    -- Track bar
                    local TrackBg = New("Frame", {
                        BackgroundColor3 = Theme.BgElement,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, 28),
                        Size = UDim2.new(1, 0, 0, 3),
                        Parent = Row
                    })
                    Corner(2, TrackBg)

                    local TrackFill = New("Frame", {
                        BackgroundColor3 = Theme.Accent,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 0, 1, 0),
                        Parent = TrackBg
                    })
                    Corner(2, TrackFill)

                    -- Thumb
                    local Thumb = New("Frame", {
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.new(0, 11, 0, 11),
                        ZIndex = 2,
                        Parent = TrackBg
                    })
                    Corner(6, Thumb)
                    Stroke(Theme.Border, 2, Thumb)

                    local function Round(n, f)
                        return math.floor(n / f + 0.5) * f
                    end

                    function SF:Set(val, silent)
                        val = math.clamp(Round(val, sCfg.Increment), sCfg.Min, sCfg.Max)
                        SF.Value = val
                        ValLabel.Text = tostring(val)
                        local pct = (val - sCfg.Min) / (sCfg.Max - sCfg.Min)
                        Tween(TrackFill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.2)
                        Tween(Thumb, { Position = UDim2.new(pct, 0, 0.5, 0) }, 0.2)
                        ConfigData[configKey] = val
                        SaveConfig()
                        if not silent then
                            local ok, err = pcall(sCfg.Callback, val)
                            if not ok then warn("Slider callback error:", err) end
                        end
                    end

                    local dragging = false
                    TrackBg.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            local pct = math.clamp((inp.Position.X - TrackBg.AbsolutePosition.X) / TrackBg.AbsoluteSize.X, 0, 1)
                            SF:Set(sCfg.Min + (sCfg.Max - sCfg.Min) * pct)
                            Tween(Thumb, { Size = UDim2.new(0, 14, 0, 14) }, 0.1)
                        end
                    end)
                    TrackBg.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                            Tween(Thumb, { Size = UDim2.new(0, 11, 0, 11) }, 0.1)
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(inp)
                        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                            local pct = math.clamp((inp.Position.X - TrackBg.AbsolutePosition.X) / TrackBg.AbsoluteSize.X, 0, 1)
                            SF:Set(sCfg.Min + (sCfg.Max - sCfg.Min) * pct)
                        end
                    end)

                    SF:Set(sCfg.Default, true)
                    ElemOrder = ElemOrder + 1
                    Elements[configKey] = SF
                    UpdateCanvas()
                    return SF
                end

                -- ── BUTTON ──────────────────────────────────────────────
                function Sec:AddButton(bCfg)
                    bCfg           = bCfg or {}
                    bCfg.Title     = bCfg.Title     or "Button"
                    bCfg.SubTitle  = bCfg.SubTitle  or nil
                    bCfg.Callback  = bCfg.Callback  or function() end
                    bCfg.SubCallback = bCfg.SubCallback or function() end

                    local Row = New("Frame", {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = ElemOrder,
                        Size = UDim2.new(1, 0, 0, 30),
                        Parent = ElemContainer
                    })

                    local function MakeBtn(label, pos, size, callback)
                        local B = New("TextButton", {
                            Font = Enum.Font.GothamBold,
                            Text = label,
                            TextColor3 = Theme.TextSecond,
                            TextSize = 12,
                            BackgroundColor3 = Theme.BgElement,
                            BorderSizePixel = 0,
                            Position = pos,
                            Size = size,
                            Parent = Row
                        })
                        Corner(6, B)
                        Stroke(Theme.Border, 1, B)
                        B.MouseEnter:Connect(function()
                            Tween(B, { BackgroundColor3 = Theme.PillActive, TextColor3 = Theme.TextPrimary }, 0.15)
                        end)
                        B.MouseLeave:Connect(function()
                            Tween(B, { BackgroundColor3 = Theme.BgElement, TextColor3 = Theme.TextSecond }, 0.15)
                        end)
                        B.Activated:Connect(callback)
                        return B
                    end

                    if bCfg.SubTitle then
                        MakeBtn(bCfg.Title,    UDim2.new(0, 0, 0, 0), UDim2.new(0.5, -3, 1, 0), bCfg.Callback)
                        MakeBtn(bCfg.SubTitle, UDim2.new(0.5, 3, 0, 0), UDim2.new(0.5, -3, 1, 0), bCfg.SubCallback)
                    else
                        MakeBtn(bCfg.Title, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 1, 0), bCfg.Callback)
                    end

                    ElemOrder = ElemOrder + 1
                    UpdateCanvas()
                end

                -- ── DROPDOWN ────────────────────────────────────────────
                function Sec:AddDropdown(dCfg)
                    dCfg          = dCfg or {}
                    dCfg.Title    = dCfg.Title    or "Dropdown"
                    dCfg.Options  = dCfg.Options  or {}
                    dCfg.Default  = dCfg.Default  or (dCfg.Options[1] or "")
                    dCfg.Callback = dCfg.Callback or function() end

                    local configKey = "Dropdown_" .. dCfg.Title
                    if ConfigData[configKey] ~= nil then
                        dCfg.Default = ConfigData[configKey]
                    end

                    local DF = { Value = dCfg.Default }

                    local Row = New("Frame", {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = ElemOrder,
                        Size = UDim2.new(1, 0, 0, 56),
                        ClipsDescendants = false,
                        Parent = ElemContainer
                    })

                    -- Label
                    New("TextLabel", {
                        Font = Enum.Font.Gotham,
                        Text = dCfg.Title,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 4),
                        Size = UDim2.new(1, 0, 0, 14),
                        Parent = Row
                    })

                    -- Dropdown button
                    local DropBtn = New("TextButton", {
                        Font = Enum.Font.Gotham,
                        Text = dCfg.Default,
                        TextColor3 = Theme.TextSecond,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundColor3 = Theme.BgInput,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, 22),
                        Size = UDim2.new(1, 0, 0, 26),
                        ClipsDescendants = false,
                        Parent = Row
                    })
                    Corner(6, DropBtn)
                    Stroke(Theme.Border, 1, DropBtn)

                    New("UIPadding", {
                        PaddingLeft = UDim.new(0, 8),
                        Parent = DropBtn
                    })

                    -- Arrow
                    local Arrow = New("TextLabel", {
                        Font = Enum.Font.GothamBold,
                        Text = "▾",
                        TextColor3 = Theme.TextMuted,
                        TextSize = 10,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -8, 0.5, 0),
                        Size = UDim2.new(0, 14, 1, 0),
                        BackgroundTransparency = 1,
                        Parent = DropBtn
                    })

                    -- Dropdown list (renders above/below, uses ZIndex)
                    local DropList = New("Frame", {
                        Name = "DropList",
                        BackgroundColor3 = Theme.BgCard,
                        BorderSizePixel = 0,
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.new(0, 0, 1, 2),
                        Size = UDim2.new(1, 0, 0, 0),
                        ZIndex = 50,
                        ClipsDescendants = true,
                        Visible = false,
                        Parent = DropBtn
                    })
                    Corner(6, DropList)
                    Stroke(Theme.Border, 1, DropList)

                    local DListLayout = New("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 0),
                        Parent = DropList
                    })

                    local targetListH = math.min(#dCfg.Options * 26, 130)

                    -- Populate options
                    local function BuildOptions()
                        for _, c in DropList:GetChildren() do
                            if c:IsA("TextButton") then c:Destroy() end
                        end
                        for i, opt in ipairs(dCfg.Options) do
                            local Opt = New("TextButton", {
                                Font = Enum.Font.Gotham,
                                Text = opt,
                                TextColor3 = (opt == DF.Value) and Theme.TextPrimary or Theme.TextSecond,
                                TextSize = 11,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                BackgroundColor3 = (opt == DF.Value) and Theme.PillActive or Color3.fromRGB(0,0,0),
                                BackgroundTransparency = (opt == DF.Value) and 0 or 1,
                                BorderSizePixel = 0,
                                LayoutOrder = i,
                                Size = UDim2.new(1, 0, 0, 26),
                                ZIndex = 51,
                                Parent = DropList
                            })
                            New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = Opt })
                            Opt.Activated:Connect(function()
                                DF.Value = opt
                                DropBtn.Text = opt
                                ConfigData[configKey] = opt
                                SaveConfig()
                                local ok, err = pcall(dCfg.Callback, opt)
                                if not ok then warn("Dropdown callback error:", err) end
                                -- close
                                Tween(DropList, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
                                task.wait(0.2)
                                DropList.Visible = false
                                BuildOptions()
                            end)
                        end
                    end
                    BuildOptions()

                    local isOpen = false
                    DropBtn.Activated:Connect(function()
                        isOpen = not isOpen
                        if isOpen then
                            DropList.Visible = true
                            DropList.Size = UDim2.new(1, 0, 0, 0)
                            Tween(DropList, { Size = UDim2.new(1, 0, 0, targetListH) }, 0.2)
                            Tween(Arrow, { Rotation = 180 }, 0.2)
                        else
                            Tween(DropList, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
                            Tween(Arrow, { Rotation = 0 }, 0.2)
                            task.wait(0.2)
                            DropList.Visible = false
                        end
                    end)

                    function DF:Set(val, silent)
                        DF.Value = val
                        DropBtn.Text = val
                        ConfigData[configKey] = val
                        SaveConfig()
                        BuildOptions()
                        if not silent then
                            local ok, err = pcall(dCfg.Callback, val)
                            if not ok then warn("Dropdown callback error:", err) end
                        end
                    end

                    ElemOrder = ElemOrder + 1
                    Elements[configKey] = DF
                    UpdateCanvas()
                    return DF
                end

                -- ── INPUT BOX ───────────────────────────────────────────
                function Sec:AddInput(iCfg)
                    iCfg           = iCfg or {}
                    iCfg.Title     = iCfg.Title       or "Input"
                    iCfg.Default   = iCfg.Default      or ""
                    iCfg.Placeholder = iCfg.Placeholder or "Enter value..."
                    iCfg.Callback  = iCfg.Callback     or function() end

                    local configKey = "Input_" .. iCfg.Title
                    if ConfigData[configKey] ~= nil then
                        iCfg.Default = ConfigData[configKey]
                    end

                    local IF = { Value = iCfg.Default }

                    local Row = New("Frame", {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = ElemOrder,
                        Size = UDim2.new(1, 0, 0, 52),
                        Parent = ElemContainer
                    })

                    New("TextLabel", {
                        Font = Enum.Font.Gotham,
                        Text = iCfg.Title,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 4),
                        Size = UDim2.new(1, 0, 0, 14),
                        Parent = Row
                    })

                    local InputBg = New("Frame", {
                        BackgroundColor3 = Theme.BgInput,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, 22),
                        Size = UDim2.new(1, 0, 0, 26),
                        Parent = Row
                    })
                    Corner(6, InputBg)
                    local InpStroke = Stroke(Theme.Border, 1, InputBg)

                    local TBox = New("TextBox", {
                        Font = Enum.Font.Gotham,
                        PlaceholderText = iCfg.Placeholder,
                        PlaceholderColor3 = Theme.TextMuted,
                        Text = iCfg.Default,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ClearTextOnFocus = false,
                        Position = UDim2.new(0, 8, 0, 0),
                        Size = UDim2.new(1, -16, 1, 0),
                        Parent = InputBg
                    })

                    TBox.Focused:Connect(function()
                        Tween(InpStroke, { Color = Theme.Accent, Transparency = 0 }, 0.15)
                    end)
                    TBox.FocusLost:Connect(function(enter)
                        Tween(InpStroke, { Color = Theme.Border, Transparency = 0 }, 0.15)
                        IF.Value = TBox.Text
                        ConfigData[configKey] = TBox.Text
                        SaveConfig()
                        local ok, err = pcall(iCfg.Callback, TBox.Text, enter)
                        if not ok then warn("Input callback error:", err) end
                    end)

                    function IF:Set(val)
                        IF.Value = val
                        TBox.Text = val
                    end

                    ElemOrder = ElemOrder + 1
                    Elements[configKey] = IF
                    UpdateCanvas()
                    return IF
                end

                -- ── PARAGRAPH ───────────────────────────────────────────
                function Sec:AddParagraph(pCfg)
                    pCfg         = pCfg or {}
                    pCfg.Title   = pCfg.Title   or "Info"
                    pCfg.Content = pCfg.Content or ""

                    local PF = {}

                    local Row = New("Frame", {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = ElemOrder,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Parent = ElemContainer
                    })

                    New("TextLabel", {
                        Font = Enum.Font.GothamBold,
                        Text = pCfg.Title,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 0, 16),
                        Parent = Row
                    })

                    local ContentLbl = New("TextLabel", {
                        Font = Enum.Font.Gotham,
                        Text = pCfg.Content,
                        TextColor3 = Theme.TextSecond,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true,
                        RichText = true,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 18),
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Parent = Row
                    })

                    function PF:SetContent(text)
                        ContentLbl.Text = text or ""
                    end

                    ElemOrder = ElemOrder + 1
                    UpdateCanvas()
                    return PF
                end

                -- ── PANEL (button + optional input) ─────────────────────
                function Sec:AddPanel(pCfg)
                    pCfg             = pCfg or {}
                    pCfg.Title       = pCfg.Title       or "Panel"
                    pCfg.Content     = pCfg.Content     or ""
                    pCfg.ButtonText  = pCfg.ButtonText  or pCfg.Button or "Confirm"
                    pCfg.Callback    = pCfg.Callback    or pCfg.ButtonCallback or function() end
                    pCfg.SubButtonText = pCfg.SubButtonText or pCfg.SubButton or nil
                    pCfg.SubCallback = pCfg.SubCallback or pCfg.SubButtonCallback or function() end
                    pCfg.Placeholder = pCfg.Placeholder or nil
                    pCfg.Default     = pCfg.Default     or ""

                    local configKey = "Panel_" .. pCfg.Title
                    if ConfigData[configKey] ~= nil then pCfg.Default = ConfigData[configKey] end

                    local PanF = { Value = pCfg.Default }

                    local totalH = 16 + (pCfg.Content ~= "" and 18 or 0) + (pCfg.Placeholder and 34 or 0) + 34

                    local Row = New("Frame", {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = ElemOrder,
                        Size = UDim2.new(1, 0, 0, totalH),
                        Parent = ElemContainer
                    })

                    local curY = 0

                    New("TextLabel", {
                        Font = Enum.Font.GothamBold,
                        Text = pCfg.Title,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, curY),
                        Size = UDim2.new(1, 0, 0, 14),
                        Parent = Row
                    })
                    curY = curY + 16

                    if pCfg.Content ~= "" then
                        New("TextLabel", {
                            Font = Enum.Font.Gotham,
                            Text = pCfg.Content,
                            TextColor3 = Theme.TextSecond,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextWrapped = true,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 0, 0, curY),
                            Size = UDim2.new(1, 0, 0, 14),
                            Parent = Row
                        })
                        curY = curY + 18
                    end

                    local InputBox
                    if pCfg.Placeholder then
                        local IBg = New("Frame", {
                            BackgroundColor3 = Theme.BgInput,
                            BorderSizePixel = 0,
                            Position = UDim2.new(0, 0, 0, curY),
                            Size = UDim2.new(1, 0, 0, 26),
                            Parent = Row
                        })
                        Corner(6, IBg)
                        Stroke(Theme.Border, 1, IBg)
                        InputBox = New("TextBox", {
                            Font = Enum.Font.Gotham,
                            PlaceholderText = pCfg.Placeholder,
                            PlaceholderColor3 = Theme.TextMuted,
                            Text = pCfg.Default,
                            TextColor3 = Theme.TextPrimary,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BackgroundTransparency = 1,
                            ClearTextOnFocus = false,
                            Position = UDim2.new(0, 8, 0, 0),
                            Size = UDim2.new(1, -16, 1, 0),
                            Parent = IBg
                        })
                        InputBox.FocusLost:Connect(function()
                            PanF.Value = InputBox.Text
                            ConfigData[configKey] = InputBox.Text
                            SaveConfig()
                        end)
                        curY = curY + 32
                    end

                    local function MakePBtn(label, xPos, size, callback)
                        local B = New("TextButton", {
                            Font = Enum.Font.GothamBold,
                            Text = label,
                            TextColor3 = Theme.TextSecond,
                            TextSize = 11,
                            BackgroundColor3 = Theme.BgElement,
                            BorderSizePixel = 0,
                            Position = xPos,
                            Size = size,
                            Parent = Row
                        })
                        Corner(6, B)
                        Stroke(Theme.Border, 1, B)
                        B.Activated:Connect(function()
                            callback(InputBox and InputBox.Text or "")
                        end)
                    end

                    if pCfg.SubButtonText then
                        MakePBtn(pCfg.ButtonText,  UDim2.new(0, 0, 0, curY), UDim2.new(0.5, -3, 0, 28), pCfg.Callback)
                        MakePBtn(pCfg.SubButtonText, UDim2.new(0.5, 3, 0, curY), UDim2.new(0.5, -3, 0, 28), pCfg.SubCallback)
                    else
                        MakePBtn(pCfg.ButtonText, UDim2.new(0, 0, 0, curY), UDim2.new(1, 0, 0, 28), pCfg.Callback)
                    end

                    function PanF:GetInput()
                        return InputBox and InputBox.Text or ""
                    end

                    ElemOrder = ElemOrder + 1
                    UpdateCanvas()
                    return PanF
                end

                UpdateCanvas()
                return Sec
            end -- AddSection

            return Tab
        end -- AddTab

        return Cat
    end -- AddCategory

    -- ── Search bar wire (filter sidebar sub-tab rows) ──────────────────
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for _, t in pairs(AllSubTabs) do
            if query == "" then
                t.row.Visible = true
            else
                t.row.Visible = string.find(t.name, query, 1, true) ~= nil
            end
        end
    end)

    return W
end

return VoraHub

