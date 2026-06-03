--// ============================================================================
--//  VoraHub UI Library — Monochrome Cyber-Stealth Edition
--//  Refactored: Hierarchical Categories → Sub-Tabs → Left/Right Card Grid
--// ============================================================================

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")
local viewport = workspace.CurrentCamera.ViewportSize

--// ========================== THEME CONFIGURATION =============================
--//  Ganti AccentColor ke Color3.fromRGB(0, 170, 255) untuk Neon Blue
local Theme = {
	AccentColor     = Color3.fromRGB(0, 170, 255),   -- Neon Blue (sesuai gambar)
	-- AccentColor  = Color3.fromRGB(255,255,255),   -- Uncomment untuk White-Gray

	MainBG          = Color3.fromRGB(10, 10, 12),    -- Ultra dark charcoal
	SidebarBG       = Color3.fromRGB(14, 14, 16),    -- Sidebar sedikit lebih terang dari MainBG
	CardBG          = Color3.fromRGB(22, 22, 26),    -- Card/Groupbox background
	HeaderText      = Color3.fromRGB(255, 255, 255),
	SecondaryText   = Color3.fromRGB(160, 160, 170),
	Border          = Color3.fromRGB(40, 40, 48),
	SearchBG        = Color3.fromRGB(30, 30, 34),
	ToggleOff       = Color3.fromRGB(55, 55, 62),
	ToggleOn        = Color3.fromRGB(0, 170, 255),
	ToggleCircle    = Color3.fromRGB(255, 255, 255),
	SliderTrack     = Color3.fromRGB(45, 45, 52),
	PillHighlight   = Color3.fromRGB(0, 140, 255),   -- Active tab pill blue
	HoverBright     = Color3.fromRGB(35, 35, 42),
	Font            = Enum.Font.Gotham,
	FontBold        = Enum.Font.GothamBold,
}

--// ========================== CONFIG PERSISTENCE ==============================
if not isfolder("VoraHub") then makefolder("VoraHub") end
if not isfolder("VoraHub/Config") then makefolder("VoraHub/Config") end

local gameName = tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
gameName = gameName:gsub("[^%w_ ]", "")
gameName = gameName:gsub("%s+", "_")

local ConfigFile = "VoraHub/Config/" .. gameName .. ".json"
local ConfigData = {}
local Elements = {}
local CURRENT_VERSION = nil

local function SaveConfig()
	if writefile then
		ConfigData._version = CURRENT_VERSION
		pcall(function()
			writefile(ConfigFile, HttpService:JSONEncode(ConfigData))
		end)
	end
end

local function LoadConfigFromFile()
	if not CURRENT_VERSION then return end
	if isfile and isfile(ConfigFile) then
		local success, result = pcall(function()
			return HttpService:JSONDecode(readfile(ConfigFile))
		end)
		if success and type(result) == "table" then
			if result._version == CURRENT_VERSION then
				ConfigData = result
			else
				ConfigData = { _version = CURRENT_VERSION }
			end
		else
			ConfigData = { _version = CURRENT_VERSION }
		end
	else
		ConfigData = { _version = CURRENT_VERSION }
	end
end

local function LoadConfigElements()
	for key, element in pairs(Elements) do
		if ConfigData[key] ~= nil and element.Set then
			element:Set(ConfigData[key], true)
		end
	end
end

--// ========================== UTILITY FUNCTIONS ==============================
local function isMobileDevice()
	return UserInputService.TouchEnabled
		and not UserInputService.KeyboardEnabled
		and not UserInputService.MouseEnabled
end
local isMobile = isMobileDevice()

local function safeSize(pxWidth, pxHeight)
	local scaleX = pxWidth / viewport.X
	local scaleY = pxHeight / viewport.Y
	if isMobile then
		if scaleX > 0.5 then scaleX = 0.5 end
		if scaleY > 0.3 then scaleY = 0.3 end
	end
	return UDim2.new(scaleX, 0, scaleY, 0)
end

local function MakeDraggable(topbarobject, object)
	local Dragging, DragInput, DragStart, StartPosition
	local function UpdatePos(input)
		local Delta = input.Position - DragStart
		local pos = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
		TweenService:Create(object, TweenInfo.new(0.2), { Position = pos }):Play()
	end
	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = object.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)
	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			UpdatePos(input)
		end
	end)
end

local function MakeResizable(object)
	local Dragging, DragInput, DragStart, StartSize
	local minSizeX, minSizeY = 500, 320
	local defSizeX, defSizeY = isMobile and 470 or 860, isMobile and 270 or 520
	object.Size = UDim2.new(0, defSizeX, 0, defSizeY)

	local handle = Instance.new("Frame")
	handle.Name = "ResizeHandle"
	handle.AnchorPoint = Vector2.new(1, 1)
	handle.BackgroundTransparency = 1
	handle.Size = UDim2.new(0, 40, 0, 40)
	handle.Position = UDim2.new(1, 20, 1, 20)
	handle.Parent = object

	local function UpdateSize(input)
		local Delta = input.Position - DragStart
		local newWidth = math.max(StartSize.X.Offset + Delta.X, minSizeX)
		local newHeight = math.max(StartSize.Y.Offset + Delta.Y, minSizeY)
		TweenService:Create(object, TweenInfo.new(0.2), { Size = UDim2.new(0, newWidth, 0, newHeight) }):Play()
	end
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartSize = object.Size
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			UpdateSize(input)
		end
	end)
end

--// ========================== NOTIFICATION SYSTEM =============================
local VoraHub = {}

function VoraHub:MakeNotify(NotifyConfig)
	NotifyConfig = NotifyConfig or {}
	NotifyConfig.Title = NotifyConfig.Title or "VoraHub"
	NotifyConfig.Description = NotifyConfig.Description or "Notification"
	NotifyConfig.Content = NotifyConfig.Content or "Content"
	NotifyConfig.Color = NotifyConfig.Color or Theme.AccentColor
	NotifyConfig.Time = NotifyConfig.Time or 0.5
	NotifyConfig.Delay = NotifyConfig.Delay or 5

	local NotifyFunction = {}
	task.spawn(function()
		if not CoreGui:FindFirstChild("VoraNotifyGui") then
			local NotifyGui = Instance.new("ScreenGui")
			NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			NotifyGui.Name = "VoraNotifyGui"
			NotifyGui.Parent = CoreGui
		end
		if not CoreGui.VoraNotifyGui:FindFirstChild("NotifyLayout") then
			local NotifyLayout = Instance.new("Frame")
			NotifyLayout.AnchorPoint = Vector2.new(1, 1)
			NotifyLayout.BackgroundTransparency = 1
			NotifyLayout.BorderSizePixel = 0
			NotifyLayout.Position = UDim2.new(1, -30, 1, -30)
			NotifyLayout.Size = UDim2.new(0, 320, 1, 0)
			NotifyLayout.Name = "NotifyLayout"
			NotifyLayout.Parent = CoreGui.VoraNotifyGui
			local Count = 0
			CoreGui.VoraNotifyGui.NotifyLayout.ChildRemoved:Connect(function()
				Count = 0
				for i, v in CoreGui.VoraNotifyGui.NotifyLayout:GetChildren() do
					TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{ Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * Count)) }):Play()
					Count = Count + 1
				end
			end)
		end

		local NotifyPosHeigh = 0
		for i, v in CoreGui.VoraNotifyGui.NotifyLayout:GetChildren() do
			NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
		end

		local NotifyFrame = Instance.new("Frame")
		NotifyFrame.BackgroundTransparency = 1
		NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
		NotifyFrame.Name = "NotifyFrame"
		NotifyFrame.Parent = CoreGui.VoraNotifyGui.NotifyLayout
		NotifyFrame.AnchorPoint = Vector2.new(0, 1)
		NotifyFrame.Position = UDim2.new(0, 0, 1, -(NotifyPosHeigh))

		local NotifyFrameReal = Instance.new("Frame")
		NotifyFrameReal.BackgroundColor3 = Theme.CardBG
		NotifyFrameReal.BorderSizePixel = 0
		NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
		NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
		NotifyFrameReal.Name = "NotifyFrameReal"
		NotifyFrameReal.Parent = NotifyFrame
		Instance.new("UICorner", NotifyFrameReal).CornerRadius = UDim.new(0, 8)

		local Top = Instance.new("Frame")
		Top.BackgroundTransparency = 1
		Top.Size = UDim2.new(1, 0, 0, 36)
		Top.Name = "Top"
		Top.Parent = NotifyFrameReal

		local TitleLabel = Instance.new("TextLabel")
		TitleLabel.Font = Theme.FontBold
		TitleLabel.Text = NotifyConfig.Title
		TitleLabel.TextColor3 = Theme.HeaderText
		TitleLabel.TextSize = 14
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.Size = UDim2.new(1, 0, 1, 0)
		TitleLabel.Position = UDim2.new(0, 10, 0, 0)
		TitleLabel.Parent = Top

		local DescLabel = Instance.new("TextLabel")
		DescLabel.Font = Theme.FontBold
		DescLabel.Text = NotifyConfig.Description
		DescLabel.TextColor3 = NotifyConfig.Color
		DescLabel.TextSize = 14
		DescLabel.TextXAlignment = Enum.TextXAlignment.Left
		DescLabel.BackgroundTransparency = 1
		DescLabel.Size = UDim2.new(1, 0, 1, 0)
		DescLabel.Position = UDim2.new(0, TitleLabel.TextBounds.X + 15, 0, 0)
		DescLabel.Parent = Top

		local Close = Instance.new("TextButton")
		Close.Text = ""
		Close.AnchorPoint = Vector2.new(1, 0.5)
		Close.BackgroundTransparency = 1
		Close.Position = UDim2.new(1, -5, 0.5, 0)
		Close.Size = UDim2.new(0, 25, 0, 25)
		Close.Parent = Top

		local CloseImg = Instance.new("ImageLabel")
		CloseImg.Image = "rbxassetid://9886659671"
		CloseImg.AnchorPoint = Vector2.new(0.5, 0.5)
		CloseImg.BackgroundTransparency = 1
		CloseImg.Position = UDim2.new(0.5, 0, 0.5, 0)
		CloseImg.Size = UDim2.new(1, -8, 1, -8)
		CloseImg.ImageColor3 = Theme.SecondaryText
		CloseImg.Parent = Close

		local ContentLabel = Instance.new("TextLabel")
		ContentLabel.Font = Theme.FontBold
		ContentLabel.TextColor3 = Theme.SecondaryText
		ContentLabel.TextSize = 13
		ContentLabel.Text = NotifyConfig.Content
		ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
		ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
		ContentLabel.BackgroundTransparency = 1
		ContentLabel.Position = UDim2.new(0, 10, 0, 27)
		ContentLabel.Size = UDim2.new(1, -20, 0, 13)
		ContentLabel.TextWrapped = true
		ContentLabel.Parent = NotifyFrameReal

		ContentLabel.Size = UDim2.new(1, -20, 0, 13 + (13 * (ContentLabel.TextBounds.X // ContentLabel.AbsoluteSize.X)))
		if ContentLabel.AbsoluteSize.Y < 27 then
			NotifyFrame.Size = UDim2.new(1, 0, 0, 65)
		else
			NotifyFrame.Size = UDim2.new(1, 0, 0, ContentLabel.AbsoluteSize.Y + 40)
		end

		local waitbruh = false
		function NotifyFunction:Close()
			if waitbruh then return false end
			waitbruh = true
			TweenService:Create(NotifyFrameReal, TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
				{ Position = UDim2.new(0, 400, 0, 0) }):Play()
			task.wait(tonumber(NotifyConfig.Time) / 1.2)
			NotifyFrame:Destroy()
		end

		Close.Activated:Connect(function()
			NotifyFunction:Close()
		end)

		TweenService:Create(NotifyFrameReal, TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
			{ Position = UDim2.new(0, 0, 0, 0) }):Play()
		task.wait(tonumber(NotifyConfig.Delay))
		NotifyFunction:Close()
	end)
	return NotifyFunction
end

function VoraHub:Notify(msg, delayTime, color, title, desc)
	return self:MakeNotify({
		Title = title or "VoraHub",
		Description = desc or "Notification",
		Content = msg or "Content",
		Color = color or Theme.AccentColor,
		Delay = delayTime or 4
	})
end

--// ========================== MAIN WINDOW =====================================
function VoraHub:Window(GuiConfig)
	GuiConfig = GuiConfig or {}
	GuiConfig.Title = GuiConfig.Title or "VoraHub"
	GuiConfig.Footer = GuiConfig.Footer or ""
	GuiConfig.Color = GuiConfig.Color or Theme.AccentColor
	GuiConfig.Version = GuiConfig.Version or 1
	GuiConfig.Image = GuiConfig.Image or "107005941750079"

	CURRENT_VERSION = GuiConfig.Version
	LoadConfigFromFile()

	if GuiConfig.Color then
		Theme.AccentColor = GuiConfig.Color
		Theme.ToggleOn = GuiConfig.Color
		Theme.PillHighlight = GuiConfig.Color
	end

	local GuiFunc = {}
	local AllCategories = {}
	local ActiveTab = nil
	local TabCount = 0

	--// Root GUI
	local NatUI = Instance.new("ScreenGui")
	NatUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	NatUI.Name = "VoraHubUI"
	NatUI.ResetOnSpawn = false
	NatUI.Parent = CoreGui

	local MainHolder = Instance.new("Frame")
	MainHolder.Name = "MainHolder"
	MainHolder.AnchorPoint = Vector2.new(0.5, 0.5)
	MainHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainHolder.Size = safeSize(isMobile and 470 or 860, isMobile and 270 or 520)
	MainHolder.BackgroundTransparency = 1
	MainHolder.BorderSizePixel = 0
	MainHolder.Parent = NatUI

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.BackgroundColor3 = Theme.MainBG
	Main.BorderSizePixel = 0
	Main.Size = UDim2.new(1, 0, 1, 0)
	Main.Parent = MainHolder
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

	--// Top Bar
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.BackgroundColor3 = Theme.MainBG
	TopBar.BorderSizePixel = 0
	TopBar.Size = UDim2.new(1, 0, 0, 48)
	TopBar.Parent = Main
	Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

	local TopBarDeco = Instance.new("Frame")
	TopBarDeco.Name = "TopBarDeco"
	TopBarDeco.BackgroundColor3 = Theme.Border
	TopBarDeco.BorderSizePixel = 0
	TopBarDeco.Position = UDim2.new(0, 0, 1, -1)
	TopBarDeco.Size = UDim2.new(1, 0, 0, 1)
	TopBarDeco.Parent = TopBar

	-- App Name (Left)
	local AppName = Instance.new("TextLabel")
	AppName.Name = "AppName"
	AppName.Font = Theme.FontBold
	AppName.Text = GuiConfig.Title
	AppName.TextColor3 = Theme.HeaderText
	AppName.TextSize = 15
	AppName.TextXAlignment = Enum.TextXAlignment.Left
	AppName.BackgroundTransparency = 1
	AppName.Position = UDim2.new(0, 14, 0, 0)
	AppName.Size = UDim2.new(0, 200, 1, 0)
	AppName.Parent = TopBar

	-- Player Avatar (beside title)
	local AvatarHolder = Instance.new("Frame")
	AvatarHolder.Name = "AvatarHolder"
	AvatarHolder.BackgroundColor3 = Theme.CardBG
	AvatarHolder.BorderSizePixel = 0
	AvatarHolder.Position = UDim2.new(0, AppName.TextBounds.X + 22, 0.5, -13)
	AvatarHolder.Size = UDim2.new(0, 26, 0, 26)
	AvatarHolder.Parent = TopBar
	Instance.new("UICorner", AvatarHolder).CornerRadius = UDim.new(1, 0)

	local AvatarImg = Instance.new("ImageLabel")
	AvatarImg.Name = "AvatarImg"
	AvatarImg.BackgroundTransparency = 1
	AvatarImg.Size = UDim2.new(1, 0, 1, 0)
	AvatarImg.Parent = AvatarHolder
	local success, thumb = pcall(function()
		return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	end)
	if success then AvatarImg.Image = thumb end

	-- Current Tab Title (Center)
	local CurrentTabTitle = Instance.new("TextLabel")
	CurrentTabTitle.Name = "CurrentTabTitle"
	CurrentTabTitle.Font = Theme.FontBold
	CurrentTabTitle.Text = ""
	CurrentTabTitle.TextColor3 = Theme.HeaderText
	CurrentTabTitle.TextSize = 14
	CurrentTabTitle.TextXAlignment = Enum.TextXAlignment.Left
	CurrentTabTitle.BackgroundTransparency = 1
	CurrentTabTitle.Position = UDim2.new(0, 220, 0, 0)
	CurrentTabTitle.Size = UDim2.new(0, 200, 1, 0)
	CurrentTabTitle.Parent = TopBar

	-- Search Bar (Right)
	local SearchFrame = Instance.new("Frame")
	SearchFrame.Name = "SearchFrame"
	SearchFrame.AnchorPoint = Vector2.new(1, 0.5)
	SearchFrame.BackgroundColor3 = Theme.SearchBG
	SearchFrame.BorderSizePixel = 0
	SearchFrame.Position = UDim2.new(1, -50, 0.5, 0)
	SearchFrame.Size = UDim2.new(0, 200, 0, 30)
	SearchFrame.Parent = TopBar
	Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 6)

	local SearchIcon = Instance.new("ImageLabel")
	SearchIcon.Name = "SearchIcon"
	SearchIcon.Image = "rbxassetid://122032243989747"
	SearchIcon.BackgroundTransparency = 1
	SearchIcon.Position = UDim2.new(0, 8, 0.5, -8)
	SearchIcon.Size = UDim2.new(0, 16, 0, 16)
	SearchIcon.ImageColor3 = Theme.SecondaryText
	SearchIcon.Parent = SearchFrame

	local SearchBox = Instance.new("TextBox")
	SearchBox.Name = "SearchBox"
	SearchBox.Font = Theme.Font
	SearchBox.PlaceholderText = "Search tabs/groups..."
	SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	SearchBox.Text = ""
	SearchBox.TextColor3 = Theme.HeaderText
	SearchBox.TextSize = 12
	SearchBox.TextXAlignment = Enum.TextXAlignment.Left
	SearchBox.BackgroundTransparency = 1
	SearchBox.Position = UDim2.new(0, 30, 0, 0)
	SearchBox.Size = UDim2.new(1, -40, 1, 0)
	SearchBox.ClearTextOnFocus = false
	SearchBox.Parent = SearchFrame

	-- Window Controls
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Name = "CloseBtn"
	CloseBtn.Text = ""
	CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Position = UDim2.new(1, -10, 0.5, 0)
	CloseBtn.Size = UDim2.new(0, 25, 0, 25)
	CloseBtn.Parent = TopBar

	local CloseImg = Instance.new("ImageLabel")
	CloseImg.Image = "rbxassetid://9886659671"
	CloseImg.AnchorPoint = Vector2.new(0.5, 0.5)
	CloseImg.BackgroundTransparency = 1
	CloseImg.Position = UDim2.new(0.5, 0, 0.5, 0)
	CloseImg.Size = UDim2.new(1, -8, 1, -8)
	CloseImg.ImageColor3 = Theme.SecondaryText
	CloseImg.Parent = CloseBtn

	local MinBtn = Instance.new("TextButton")
	MinBtn.Name = "MinBtn"
	MinBtn.Text = ""
	MinBtn.AnchorPoint = Vector2.new(1, 0.5)
	MinBtn.BackgroundTransparency = 1
	MinBtn.Position = UDim2.new(1, -40, 0.5, 0)
	MinBtn.Size = UDim2.new(0, 25, 0, 25)
	MinBtn.Parent = TopBar

	local MinImg = Instance.new("ImageLabel")
	MinImg.Image = "rbxassetid://9886659276"
	MinImg.AnchorPoint = Vector2.new(0.5, 0.5)
	MinImg.BackgroundTransparency = 1
	MinImg.Position = UDim2.new(0.5, 0, 0.5, 0)
	MinImg.Size = UDim2.new(1, -9, 1, -9)
	MinImg.ImageColor3 = Theme.SecondaryText
	MinImg.Parent = MinBtn

	--// Sidebar
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.BackgroundColor3 = Theme.SidebarBG
	Sidebar.BorderSizePixel = 0
	Sidebar.Position = UDim2.new(0, 0, 0, 48)
	Sidebar.Size = UDim2.new(0, 210, 1, -48)
	Sidebar.Parent = Main
	Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 0)

	local SidebarDeco = Instance.new("Frame")
	SidebarDeco.Name = "SidebarDeco"
	SidebarDeco.BackgroundColor3 = Theme.Border
	SidebarDeco.BorderSizePixel = 0
	SidebarDeco.Position = UDim2.new(1, 0, 0, 0)
	SidebarDeco.Size = UDim2.new(0, 1, 1, 0)
	SidebarDeco.Parent = Sidebar

	local SidebarScroll = Instance.new("ScrollingFrame")
	SidebarScroll.Name = "SidebarScroll"
	SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	SidebarScroll.ScrollBarImageTransparency = 1
	SidebarScroll.ScrollBarThickness = 0
	SidebarScroll.Active = true
	SidebarScroll.BackgroundTransparency = 1
	SidebarScroll.BorderSizePixel = 0
	SidebarScroll.Size = UDim2.new(1, 0, 1, 0)
	SidebarScroll.Parent = Sidebar
	SidebarScroll.ClipsDescendants = true

	local SidebarList = Instance.new("UIListLayout")
	SidebarList.Name = "SidebarList"
	SidebarList.Padding = UDim.new(0, 6)
	SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarList.Parent = SidebarScroll

	SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, SidebarList.AbsoluteContentSize.Y + 20)
	end)

	--// Content Area
	local ContentArea = Instance.new("Frame")
	ContentArea.Name = "ContentArea"
	ContentArea.BackgroundTransparency = 1
	ContentArea.BorderSizePixel = 0
	ContentArea.Position = UDim2.new(0, 210, 0, 48)
	ContentArea.Size = UDim2.new(1, -210, 1, -48)
	ContentArea.Parent = Main

	local ContentScroll = Instance.new("ScrollingFrame")
	ContentScroll.Name = "ContentScroll"
	ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	ContentScroll.ScrollBarImageTransparency = 0.9
	ContentScroll.ScrollBarThickness = 3
	ContentScroll.ScrollBarImageColor3 = Theme.Border
	ContentScroll.Active = true
	ContentScroll.BackgroundTransparency = 1
	ContentScroll.BorderSizePixel = 0
	ContentScroll.Size = UDim2.new(1, 0, 1, 0)
	ContentScroll.Parent = ContentArea
	ContentScroll.ClipsDescendants = true

	local ContentPageLayout = Instance.new("UIPageLayout")
	ContentPageLayout.Name = "ContentPageLayout"
	ContentPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ContentPageLayout.Parent = ContentScroll
	ContentPageLayout.TweenTime = 0.3
	ContentPageLayout.EasingDirection = Enum.EasingDirection.InOut
	ContentPageLayout.EasingStyle = Enum.EasingStyle.Quad
	ContentPageLayout.FillDirection = Enum.FillDirection.Vertical

	--// Dropdown Overlay (ZIndex 100, renders above everything)
	local DropdownOverlay = Instance.new("Frame")
	DropdownOverlay.Name = "DropdownOverlay"
	DropdownOverlay.BackgroundTransparency = 1
	DropdownOverlay.BorderSizePixel = 0
	DropdownOverlay.Size = UDim2.new(1, 0, 1, 0)
	DropdownOverlay.ZIndex = 100
	DropdownOverlay.Visible = false
	DropdownOverlay.Parent = ContentArea

	local ActiveDropdownFrame = nil

	local function CloseActiveDropdown()
		DropdownOverlay.Visible = false
		ActiveDropdownFrame = nil
		for _, child in ipairs(DropdownOverlay:GetChildren()) do
			child:Destroy()
		end
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and DropdownOverlay.Visible then
			local list = DropdownOverlay:FindFirstChildOfClass("Frame")
			if list then
				local pos = input.Position
				local absPos = list.AbsolutePosition
				local absSize = list.AbsoluteSize
				local insideList = pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y
				if not insideList then
					if ActiveDropdownFrame then
						local sAbs = ActiveDropdownFrame.AbsolutePosition
						local sSize = ActiveDropdownFrame.AbsoluteSize
						local insideSelect = pos.X >= sAbs.X and pos.X <= sAbs.X + sSize.X and pos.Y >= sAbs.Y and pos.Y <= sAbs.Y + sSize.Y
						if not insideSelect then
							CloseActiveDropdown()
						end
					else
						CloseActiveDropdown()
					end
				end
			end
		end
	end)

	--// Search Logic
	local function UpdateSearch()
		local query = string.lower(SearchBox.Text)
		for _, catData in ipairs(AllCategories) do
			local catMatch = string.find(string.lower(catData.Name), query, 1, true)
			local anyTabMatch = false
			for _, tabData in ipairs(catData.Tabs) do
				local tabMatch = string.find(string.lower(tabData.Name), query, 1, true)
				if query == "" or catMatch or tabMatch then
					tabData.Button.Visible = true
					anyTabMatch = true
				else
					tabData.Button.Visible = false
				end
			end
			if query == "" or catMatch or anyTabMatch then
				catData.Header.Visible = true
				if anyTabMatch and not catData.Expanded then
					catData.Expanded = true
					catData.Content.Visible = true
					TweenService:Create(catData.Arrow, TweenInfo.new(0.2), { Rotation = 90 }):Play()
				end
			else
				catData.Header.Visible = false
				catData.Content.Visible = false
			end
		end
		task.wait()
		SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, SidebarList.AbsoluteContentSize.Y + 20)
	end
	SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdateSearch)

	--// GUI Control Methods
	function GuiFunc:DestroyGui()
		if CoreGui:FindFirstChild("VoraHubUI") then
			NatUI:Destroy()
		end
	end

	MinBtn.Activated:Connect(function()
		MainHolder.Visible = false
	end)

	CloseBtn.Activated:Connect(function()
		local Overlay = Instance.new("Frame")
		Overlay.Name = "Overlay"
		Overlay.Size = UDim2.new(1, 0, 1, 0)
		Overlay.BackgroundColor3 = Color3.new(0, 0, 0)
		Overlay.BackgroundTransparency = 0.4
		Overlay.ZIndex = 200
		Overlay.Parent = MainHolder

		local Dialog = Instance.new("Frame")
		Dialog.Name = "Dialog"
		Dialog.BackgroundColor3 = Theme.CardBG
		Dialog.BorderSizePixel = 0
		Dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
		Dialog.Size = UDim2.new(0, 300, 0, 150)
		Dialog.ZIndex = 201
		Dialog.Parent = Overlay
		Instance.new("UICorner", Dialog).CornerRadius = UDim.new(0, 10)

		local DialogStroke = Instance.new("UIStroke")
		DialogStroke.Color = Theme.Border
		DialogStroke.Thickness = 1
		DialogStroke.Parent = Dialog

		local DTitle = Instance.new("TextLabel")
		DTitle.Name = "DTitle"
		DTitle.Font = Theme.FontBold
		DTitle.Text = "Close VoraHub?"
		DTitle.TextColor3 = Theme.HeaderText
		DTitle.TextSize = 18
		DTitle.BackgroundTransparency = 1
		DTitle.Size = UDim2.new(1, 0, 0, 40)
		DTitle.Position = UDim2.new(0, 0, 0, 4)
		DTitle.ZIndex = 202
		DTitle.Parent = Dialog

		local DMsg = Instance.new("TextLabel")
		DMsg.Name = "DMsg"
		DMsg.Font = Theme.Font
		DMsg.Text = "Do you want to close this window?\nYou will not be able to open it again."
		DMsg.TextColor3 = Theme.SecondaryText
		DMsg.TextSize = 13
		DMsg.TextWrapped = true
		DMsg.BackgroundTransparency = 1
		DMsg.Size = UDim2.new(1, -20, 0, 50)
		DMsg.Position = UDim2.new(0, 10, 0, 38)
		DMsg.ZIndex = 202
		DMsg.Parent = Dialog

		local Yes = Instance.new("TextButton")
		Yes.Name = "Yes"
		Yes.Size = UDim2.new(0.45, -10, 0, 32)
		Yes.Position = UDim2.new(0.05, 0, 1, -50)
		Yes.BackgroundColor3 = Theme.CardBG
		Yes.Text = "Yes"
		Yes.Font = Theme.FontBold
		Yes.TextSize = 14
		Yes.TextColor3 = Theme.HeaderText
		Yes.ZIndex = 202
		Yes.Parent = Dialog
		Instance.new("UICorner", Yes).CornerRadius = UDim.new(0, 6)
		local YesStroke = Instance.new("UIStroke")
		YesStroke.Color = Theme.Border
		YesStroke.Thickness = 1
		YesStroke.Parent = Yes

		local Cancel = Instance.new("TextButton")
		Cancel.Name = "Cancel"
		Cancel.Size = UDim2.new(0.45, -10, 0, 32)
		Cancel.Position = UDim2.new(0.5, 10, 1, -50)
		Cancel.BackgroundColor3 = Theme.AccentColor
		Cancel.Text = "Cancel"
		Cancel.Font = Theme.FontBold
		Cancel.TextSize = 14
		Cancel.TextColor3 = Theme.MainBG
		Cancel.ZIndex = 202
		Cancel.Parent = Dialog
		Instance.new("UICorner", Cancel).CornerRadius = UDim.new(0, 6)

		Yes.MouseButton1Click:Connect(function()
			NatUI:Destroy()
			if CoreGui:FindFirstChild("VoraHubToggle") then
				CoreGui.VoraHubToggle:Destroy()
			end
		end)

		Cancel.MouseButton1Click:Connect(function()
			Overlay:Destroy()
		end)
	end)

	function GuiFunc:ToggleUI()
		if CoreGui:FindFirstChild("VoraHubToggle") then
			CoreGui.VoraHubToggle:Destroy()
		end
		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Name = "VoraHubToggle"
		ScreenGui.Parent = CoreGui
		ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

		local MainButton = Instance.new("ImageLabel")
		MainButton.Name = "MainButton"
		MainButton.Parent = ScreenGui
		MainButton.Size = UDim2.new(0, 50, 0, 50)
		MainButton.Position = UDim2.new(0, 20, 0, 100)
		MainButton.BackgroundTransparency = 1
		MainButton.Image = "rbxassetid://" .. GuiConfig.Image
		MainButton.ScaleType = Enum.ScaleType.Fit
		Instance.new("UICorner", MainButton).CornerRadius = UDim.new(0, 10)

		local Button = Instance.new("TextButton")
		Button.Name = "Button"
		Button.Parent = MainButton
		Button.Size = UDim2.new(1, 0, 1, 0)
		Button.BackgroundTransparency = 1
		Button.Text = ""

		Button.MouseButton1Click:Connect(function()
			MainHolder.Visible = not MainHolder.Visible
		end)

		local dragging = false
		local dragStart, startPos
		local function update(input)
			local delta = input.Position - dragStart
			MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
		Button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = MainButton.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				update(input)
			end
		end)
	end

	GuiFunc:ToggleUI()
	MakeDraggable(TopBar, MainHolder)
	MakeResizable(MainHolder)

	--// ===================== CATEGORY & TAB SYSTEM ==========================
	function GuiFunc:AddCategory(CatConfig)
		CatConfig = CatConfig or {}
		CatConfig.Name = CatConfig.Name or "Category"
		CatConfig.Icon = CatConfig.Icon or ""
		CatConfig.LayoutOrder = CatConfig.LayoutOrder or (#AllCategories + 1)

		local CatFunc = {}
		local catData = {
			Name = CatConfig.Name,
			Tabs = {},
			Expanded = true
		}

		-- Category Header
		local Header = Instance.new("Frame")
		Header.Name = "CategoryHeader_" .. CatConfig.Name
		Header.BackgroundTransparency = 1
		Header.Size = UDim2.new(1, -16, 0, 32)
		Header.LayoutOrder = CatConfig.LayoutOrder * 100
		Header.Parent = SidebarScroll

		local HeaderBtn = Instance.new("TextButton")
		HeaderBtn.Name = "HeaderBtn"
		HeaderBtn.Text = ""
		HeaderBtn.BackgroundTransparency = 1
		HeaderBtn.Size = UDim2.new(1, 0, 1, 0)
		HeaderBtn.Parent = Header

		local CatIcon = Instance.new("ImageLabel")
		CatIcon.Name = "CatIcon"
		CatIcon.BackgroundTransparency = 1
		CatIcon.Position = UDim2.new(0, 10, 0.5, -7)
		CatIcon.Size = UDim2.new(0, 14, 0, 14)
		CatIcon.ImageColor3 = Theme.SecondaryText
		CatIcon.Parent = Header
		if CatConfig.Icon ~= "" then
			CatIcon.Image = CatConfig.Icon
		end

		local CatTitle = Instance.new("TextLabel")
		CatTitle.Name = "CatTitle"
		CatTitle.Font = Theme.FontBold
		CatTitle.Text = CatConfig.Name
		CatTitle.TextColor3 = Theme.HeaderText
		CatTitle.TextSize = 12
		CatTitle.TextXAlignment = Enum.TextXAlignment.Left
		CatTitle.BackgroundTransparency = 1
		CatTitle.Position = UDim2.new(0, CatConfig.Icon ~= "" and 32 or 12, 0, 0)
		CatTitle.Size = UDim2.new(1, -60, 1, 0)
		CatTitle.Parent = Header

		local Arrow = Instance.new("ImageLabel")
		Arrow.Name = "Arrow"
		Arrow.Image = "rbxassetid://16851841101"
		Arrow.BackgroundTransparency = 1
		Arrow.Position = UDim2.new(1, -22, 0.5, -6)
		Arrow.Size = UDim2.new(0, 12, 0, 12)
		Arrow.ImageColor3 = Theme.SecondaryText
		Arrow.Rotation = 90
		Arrow.Parent = Header

		-- Category Content (holds sub-tabs)
		local Content = Instance.new("Frame")
		Content.Name = "CategoryContent_" .. CatConfig.Name
		Content.BackgroundTransparency = 1
		Content.BorderSizePixel = 0
		Content.Size = UDim2.new(1, -16, 0, 0)
		Content.AutomaticSize = Enum.AutomaticSize.Y
		Content.LayoutOrder = CatConfig.LayoutOrder * 100 + 1
		Content.Parent = SidebarScroll
		Content.ClipsDescendants = true

		local ContentList = Instance.new("UIListLayout")
		ContentList.Name = "ContentList"
		ContentList.Padding = UDim.new(0, 2)
		ContentList.SortOrder = Enum.SortOrder.LayoutOrder
		ContentList.Parent = Content

		catData.Header = Header
		catData.Content = Content
		catData.Arrow = Arrow
		table.insert(AllCategories, catData)

		HeaderBtn.Activated:Connect(function()
			catData.Expanded = not catData.Expanded
			if catData.Expanded then
				TweenService:Create(Arrow, TweenInfo.new(0.2), { Rotation = 90 }):Play()
				Content.Visible = true
			else
				TweenService:Create(Arrow, TweenInfo.new(0.2), { Rotation = 0 }):Play()
				Content.Visible = false
			end
			task.delay(0.05, function()
				SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, SidebarList.AbsoluteContentSize.Y + 20)
			end)
		end)

		function CatFunc:AddTab(TabConfig)
			TabConfig = TabConfig or {}
			TabConfig.Name = TabConfig.Name or "Tab"
			TabConfig.Icon = TabConfig.Icon or ""

			local TabFunc = {}
			local SectionCount = 0

			-- Sidebar Tab Button
			local TabBtn = Instance.new("TextButton")
			TabBtn.Name = "Tab_" .. TabConfig.Name
			TabBtn.Text = ""
			TabBtn.BackgroundTransparency = 1
			TabBtn.Size = UDim2.new(1, -12, 0, 30)
			TabBtn.LayoutOrder = TabCount
			TabBtn.Parent = Content

			-- Pill Highlight (rounded capsule background — PERSIS kayak gambar)
			local Pill = Instance.new("Frame")
			Pill.Name = "Pill"
			Pill.BackgroundColor3 = Theme.PillHighlight
			Pill.BorderSizePixel = 0
			Pill.Size = UDim2.new(1, 0, 1, 0)
			Pill.ZIndex = 1
			Pill.Visible = false
			Pill.Parent = TabBtn
			Instance.new("UICorner", Pill).CornerRadius = UDim.new(0, 6)

			local TabIcon = Instance.new("ImageLabel")
			TabIcon.Name = "TabIcon"
			TabIcon.BackgroundTransparency = 1
			TabIcon.Position = UDim2.new(0, 10, 0.5, -6)
			TabIcon.Size = UDim2.new(0, 12, 0, 12)
			TabIcon.ImageColor3 = Theme.SecondaryText
			TabIcon.ZIndex = 2
			TabIcon.Parent = TabBtn
			if TabConfig.Icon ~= "" then
				TabIcon.Image = TabConfig.Icon
			end

			local TabLabel = Instance.new("TextLabel")
			TabLabel.Name = "TabLabel"
			TabLabel.Font = Theme.Font
			TabLabel.Text = TabConfig.Name
			TabLabel.TextColor3 = Theme.SecondaryText
			TabLabel.TextSize = 12
			TabLabel.TextXAlignment = Enum.TextXAlignment.Left
			TabLabel.BackgroundTransparency = 1
			TabLabel.Position = UDim2.new(0, TabConfig.Icon ~= "" and 30 or 12, 0, 0)
			TabLabel.Size = UDim2.new(1, -40, 1, 0)
			TabLabel.ZIndex = 2
			TabLabel.Parent = TabBtn

			-- Content Page (Two-Column Layout)
			local TabPage = Instance.new("ScrollingFrame")
			TabPage.Name = "Page_" .. TabConfig.Name
			TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
			TabPage.ScrollBarImageTransparency = 0.9
			TabPage.ScrollBarThickness = 3
			TabPage.ScrollBarImageColor3 = Theme.Border
			TabPage.Active = true
			TabPage.BackgroundTransparency = 1
			TabPage.BorderSizePixel = 0
			TabPage.Size = UDim2.new(1, 0, 1, 0)
			TabPage.LayoutOrder = TabCount
			TabPage.Parent = ContentScroll
			TabPage.ClipsDescendants = true

			local PageContainer = Instance.new("Frame")
			PageContainer.Name = "PageContainer"
			PageContainer.BackgroundTransparency = 1
			PageContainer.BorderSizePixel = 0
			PageContainer.Size = UDim2.new(1, -20, 0, 0)
			PageContainer.AutomaticSize = Enum.AutomaticSize.Y
			PageContainer.Position = UDim2.new(0, 10, 0, 10)
			PageContainer.Parent = TabPage

			local LeftColumn = Instance.new("Frame")
			LeftColumn.Name = "LeftColumn"
			LeftColumn.BackgroundTransparency = 1
			LeftColumn.BorderSizePixel = 0
			LeftColumn.Size = UDim2.new(0.5, -6, 0, 0)
			LeftColumn.AutomaticSize = Enum.AutomaticSize.Y
			LeftColumn.Parent = PageContainer

			local RightColumn = Instance.new("Frame")
			RightColumn.Name = "RightColumn"
			RightColumn.BackgroundTransparency = 1
			RightColumn.BorderSizePixel = 0
			RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
			RightColumn.Size = UDim2.new(0.5, -6, 0, 0)
			RightColumn.AutomaticSize = Enum.AutomaticSize.Y
			RightColumn.Parent = PageContainer

			local LeftList = Instance.new("UIListLayout")
			LeftList.Name = "LeftList"
			LeftList.Padding = UDim.new(0, 10)
			LeftList.SortOrder = Enum.SortOrder.LayoutOrder
			LeftList.Parent = LeftColumn

			local RightList = Instance.new("UIListLayout")
			RightList.Name = "RightList"
			RightList.Padding = UDim.new(0, 10)
			RightList.SortOrder = Enum.SortOrder.LayoutOrder
			RightList.Parent = RightColumn

			PageContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				TabPage.CanvasSize = UDim2.new(0, 0, 0, PageContainer.AbsoluteSize.Y + 20)
			end)

			local tabData = {
				Name = TabConfig.Name,
				Button = TabBtn,
				Pill = Pill,
				Label = TabLabel,
				Icon = TabIcon,
				Page = TabPage
			}
			table.insert(catData.Tabs, tabData)

			local function ActivateTab()
				if ActiveTab == tabData then return end
				if ActiveTab then
					ActiveTab.Pill.Visible = false
					TweenService:Create(ActiveTab.Label, TweenInfo.new(0.2), { TextColor3 = Theme.SecondaryText }):Play()
					if ActiveTab.Icon.Image ~= "" then
						TweenService:Create(ActiveTab.Icon, TweenInfo.new(0.2), { ImageColor3 = Theme.SecondaryText }):Play()
					end
				end
				ActiveTab = tabData
				Pill.Visible = true
				TweenService:Create(TabLabel, TweenInfo.new(0.2), { TextColor3 = Theme.HeaderText }):Play()
				if TabIcon.Image ~= "" then
					TweenService:Create(TabIcon, TweenInfo.new(0.2), { ImageColor3 = Theme.HeaderText }):Play()
				end
				CurrentTabTitle.Text = TabConfig.Name
				ContentPageLayout:JumpToIndex(TabCount)
			end

			TabBtn.Activated:Connect(ActivateTab)

			if not ActiveTab then
				task.delay(0.1, function()
					Pill.Visible = true
					TabLabel.TextColor3 = Theme.HeaderText
					if TabIcon.Image ~= "" then
						TabIcon.ImageColor3 = Theme.HeaderText
					end
					ActiveTab = tabData
					CurrentTabTitle.Text = TabConfig.Name
				end)
			end

			TabCount = TabCount + 1

			--// ===================== SECTION SYSTEM =============================
			function TabFunc:AddSection(SectionConfig)
				SectionConfig = SectionConfig or {}
				SectionConfig.Name = SectionConfig.Name or "Section"
				SectionConfig.Side = SectionConfig.Side or "Left"

				local SectionFunc = {}
				local ItemCount = 0
				local TargetColumn = SectionConfig.Side == "Right" and RightColumn or LeftColumn

				-- Card / Groupbox (Kotak Gede)
				local Card = Instance.new("Frame")
				Card.Name = "Section_" .. SectionConfig.Name
				Card.BackgroundColor3 = Theme.CardBG
				Card.BorderSizePixel = 0
				Card.Size = UDim2.new(1, 0, 0, 0)
				Card.AutomaticSize = Enum.AutomaticSize.Y
				Card.LayoutOrder = SectionCount
				Card.Parent = TargetColumn
				Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

				local CardStroke = Instance.new("UIStroke")
				CardStroke.Name = "CardStroke"
				CardStroke.Color = Theme.Border
				CardStroke.Thickness = 1
				CardStroke.Transparency = 0.85
				CardStroke.Parent = Card

				local CardPadding = Instance.new("UIPadding")
				CardPadding.PaddingLeft = UDim.new(0, 14)
				CardPadding.PaddingRight = UDim.new(0, 14)
				CardPadding.PaddingTop = UDim.new(0, 12)
				CardPadding.PaddingBottom = UDim.new(0, 12)
				CardPadding.Parent = Card

				local CardList = Instance.new("UIListLayout")
				CardList.Name = "CardList"
				CardList.Padding = UDim.new(0, 8)
				CardList.SortOrder = Enum.SortOrder.LayoutOrder
				CardList.Parent = Card

				local SectionTitle = Instance.new("TextLabel")
				SectionTitle.Name = "SectionTitle"
				SectionTitle.Font = Theme.FontBold
				SectionTitle.Text = SectionConfig.Name
				SectionTitle.TextColor3 = Theme.HeaderText
				SectionTitle.TextSize = 13
				SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
				SectionTitle.BackgroundTransparency = 1
				SectionTitle.Size = UDim2.new(1, 0, 0, 16)
				SectionTitle.Parent = Card

				local ContentFrame = Instance.new("Frame")
				ContentFrame.Name = "ContentFrame"
				ContentFrame.BackgroundTransparency = 1
				ContentFrame.BorderSizePixel = 0
				ContentFrame.Size = UDim2.new(1, 0, 0, 0)
				ContentFrame.AutomaticSize = Enum.AutomaticSize.Y
				ContentFrame.Parent = Card

				local ContentListLayout = Instance.new("UIListLayout")
				ContentListLayout.Name = "ContentListLayout"
				ContentListLayout.Padding = UDim.new(0, 6)
				ContentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				ContentListLayout.Parent = ContentFrame

				SectionCount = SectionCount + 1

				--// ===================== ELEMENTS =============================
				function SectionFunc:AddParagraph(ParagraphConfig)
					ParagraphConfig = ParagraphConfig or {}
					ParagraphConfig.Title = ParagraphConfig.Title or "Title"
					ParagraphConfig.Content = ParagraphConfig.Content or "Content"

					local ParagraphFunc = {}
					local Paragraph = Instance.new("Frame")
					Paragraph.Name = "Paragraph"
					Paragraph.BackgroundTransparency = 1
					Paragraph.LayoutOrder = ItemCount
					Paragraph.Size = UDim2.new(1, 0, 0, 40)
					Paragraph.Parent = ContentFrame

					local iconOffset = 0
					if ParagraphConfig.Icon then
						local IconImg = Instance.new("ImageLabel")
						IconImg.Name = "IconImg"
						IconImg.Size = UDim2.new(0, 18, 0, 18)
						IconImg.Position = UDim2.new(0, 0, 0, 0)
						IconImg.BackgroundTransparency = 1
						IconImg.ImageColor3 = Theme.SecondaryText
						IconImg.Image = ParagraphConfig.Icon
						IconImg.Parent = Paragraph
						iconOffset = 24
					end

					local ParagraphTitle = Instance.new("TextLabel")
					ParagraphTitle.Name = "ParagraphTitle"
					ParagraphTitle.Font = Theme.FontBold
					ParagraphTitle.Text = ParagraphConfig.Title
					ParagraphTitle.TextColor3 = Theme.HeaderText
					ParagraphTitle.TextSize = 12
					ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
					ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
					ParagraphTitle.BackgroundTransparency = 1
					ParagraphTitle.Position = UDim2.new(0, iconOffset, 0, 0)
					ParagraphTitle.Size = UDim2.new(1, -iconOffset, 0, 14)
					ParagraphTitle.Parent = Paragraph

					local ParagraphContent = Instance.new("TextLabel")
					ParagraphContent.Name = "ParagraphContent"
					ParagraphContent.Font = Theme.Font
					ParagraphContent.Text = ParagraphConfig.Content
					ParagraphContent.TextColor3 = Theme.SecondaryText
					ParagraphContent.TextSize = 11
					ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
					ParagraphContent.TextYAlignment = Enum.TextYAlignment.Top
					ParagraphContent.BackgroundTransparency = 1
					ParagraphContent.Position = UDim2.new(0, iconOffset, 0, 16)
					ParagraphContent.Size = UDim2.new(1, -iconOffset, 0, 13)
					ParagraphContent.TextWrapped = true
					ParagraphContent.RichText = true
					ParagraphContent.Parent = Paragraph

					local function UpdateSize()
						ParagraphContent.Size = UDim2.new(1, -iconOffset, 0, ParagraphContent.TextBounds.Y)
						Paragraph.Size = UDim2.new(1, 0, 0, math.max(36, 16 + ParagraphContent.TextBounds.Y + 4))
					end
					ParagraphContent:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)
					UpdateSize()

					function ParagraphFunc:SetContent(content)
						ParagraphContent.Text = content or "Content"
						UpdateSize()
					end

					ItemCount = ItemCount + 1
					return ParagraphFunc
				end

				function SectionFunc:AddButton(ButtonConfig)
					ButtonConfig = ButtonConfig or {}
					ButtonConfig.Title = ButtonConfig.Title or "Confirm"
					ButtonConfig.Callback = ButtonConfig.Callback or function() end
					ButtonConfig.SubTitle = ButtonConfig.SubTitle or nil
					ButtonConfig.SubCallback = ButtonConfig.SubCallback or function() end

					local Button = Instance.new("Frame")
					Button.Name = "Button"
					Button.BackgroundTransparency = 1
					Button.Size = UDim2.new(1, 0, 0, 34)
					Button.LayoutOrder = ItemCount
					Button.Parent = ContentFrame

					local MainButton = Instance.new("TextButton")
					MainButton.Name = "MainButton"
					MainButton.Font = Theme.FontBold
					MainButton.Text = ButtonConfig.Title
					MainButton.TextSize = 12
					MainButton.TextColor3 = Theme.HeaderText
					MainButton.BackgroundColor3 = Theme.CardBG
					MainButton.BackgroundTransparency = 0.5
					MainButton.AutoButtonColor = false
					MainButton.Size = ButtonConfig.SubTitle and UDim2.new(0.5, -4, 1, 0) or UDim2.new(1, 0, 1, 0)
					MainButton.Position = UDim2.new(0, 0, 0, 0)
					MainButton.Parent = Button
					Instance.new("UICorner", MainButton).CornerRadius = UDim.new(0, 6)
					local MainStroke = Instance.new("UIStroke")
					MainStroke.Color = Theme.Border
					MainStroke.Thickness = 1
					MainStroke.Parent = MainButton

					MainButton.MouseEnter:Connect(function()
						TweenService:Create(MainButton, TweenInfo.new(0.15), { BackgroundColor3 = Theme.HoverBright }):Play()
					end)
					MainButton.MouseLeave:Connect(function()
						TweenService:Create(MainButton, TweenInfo.new(0.15), { BackgroundColor3 = Theme.CardBG }):Play()
					end)
					MainButton.MouseButton1Click:Connect(ButtonConfig.Callback)

					if ButtonConfig.SubTitle then
						local SubButton = Instance.new("TextButton")
						SubButton.Name = "SubButton"
						SubButton.Font = Theme.FontBold
						SubButton.Text = ButtonConfig.SubTitle
						SubButton.TextSize = 12
						SubButton.TextColor3 = Theme.HeaderText
						SubButton.BackgroundColor3 = Theme.CardBG
						SubButton.BackgroundTransparency = 0.5
						SubButton.AutoButtonColor = false
						SubButton.Size = UDim2.new(0.5, -4, 1, 0)
						SubButton.Position = UDim2.new(0.5, 4, 0, 0)
						SubButton.Parent = Button
						Instance.new("UICorner", SubButton).CornerRadius = UDim.new(0, 6)
						local SubStroke = Instance.new("UIStroke")
						SubStroke.Color = Theme.Border
						SubStroke.Thickness = 1
						SubStroke.Parent = SubButton

						SubButton.MouseEnter:Connect(function()
							TweenService:Create(SubButton, TweenInfo.new(0.15), { BackgroundColor3 = Theme.HoverBright }):Play()
						end)
						SubButton.MouseLeave:Connect(function()
							TweenService:Create(SubButton, TweenInfo.new(0.15), { BackgroundColor3 = Theme.CardBG }):Play()
						end)
						SubButton.MouseButton1Click:Connect(ButtonConfig.SubCallback)
					end

					ItemCount = ItemCount + 1
				end

				function SectionFunc:AddToggle(ToggleConfig)
					ToggleConfig = ToggleConfig or {}
					ToggleConfig.Title = ToggleConfig.Title or "Toggle"
					ToggleConfig.Content = ToggleConfig.Content or ""
					ToggleConfig.Default = ToggleConfig.Default or false
					ToggleConfig.Callback = ToggleConfig.Callback or function() end

					local configKey = "Toggle_" .. ToggleConfig.Title
					if ConfigData[configKey] ~= nil then
						ToggleConfig.Default = ConfigData[configKey]
					end

					local ToggleFunc = { Value = ToggleConfig.Default }

					local Toggle = Instance.new("Frame")
					Toggle.Name = "Toggle"
					Toggle.BackgroundTransparency = 1
					Toggle.LayoutOrder = ItemCount
					Toggle.Size = UDim2.new(1, 0, 0, 36)
					Toggle.Parent = ContentFrame

					local ToggleTitle = Instance.new("TextLabel")
					ToggleTitle.Name = "ToggleTitle"
					ToggleTitle.Font = Theme.FontBold
					ToggleTitle.Text = ToggleConfig.Title
					ToggleTitle.TextColor3 = Theme.HeaderText
					ToggleTitle.TextSize = 12
					ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
					ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
					ToggleTitle.BackgroundTransparency = 1
					ToggleTitle.Size = UDim2.new(1, -70, 0, 14)
					ToggleTitle.Parent = Toggle

					local ToggleContent = Instance.new("TextLabel")
					ToggleContent.Name = "ToggleContent"
					ToggleContent.Font = Theme.Font
					ToggleContent.Text = ToggleConfig.Content
					ToggleContent.TextColor3 = Theme.SecondaryText
					ToggleContent.TextSize = 11
					ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
					ToggleContent.TextYAlignment = Enum.TextYAlignment.Top
					ToggleContent.BackgroundTransparency = 1
					ToggleContent.Position = UDim2.new(0, 0, 0, 16)
					ToggleContent.Size = UDim2.new(1, -70, 0, 12)
					ToggleContent.TextWrapped = true
					ToggleContent.Parent = Toggle

					local function UpdateToggleSize()
						ToggleContent.Size = UDim2.new(1, -70, 0, ToggleContent.TextBounds.Y)
						Toggle.Size = UDim2.new(1, 0, 0, math.max(32, 16 + ToggleContent.TextBounds.Y + 4))
					end
					ToggleContent:GetPropertyChangedSignal("TextBounds"):Connect(UpdateToggleSize)
					UpdateToggleSize()

					-- Pill Switch (Persis gambar)
					local SwitchFrame = Instance.new("Frame")
					SwitchFrame.Name = "SwitchFrame"
					SwitchFrame.AnchorPoint = Vector2.new(1, 0.5)
					SwitchFrame.BackgroundColor3 = Theme.ToggleOff
					SwitchFrame.BorderSizePixel = 0
					SwitchFrame.Position = UDim2.new(1, 0, 0.5, 0)
					SwitchFrame.Size = UDim2.new(0, 36, 0, 18)
					SwitchFrame.Parent = Toggle
					Instance.new("UICorner", SwitchFrame).CornerRadius = UDim.new(1, 0)

					local SwitchCircle = Instance.new("Frame")
					SwitchCircle.Name = "SwitchCircle"
					SwitchCircle.BackgroundColor3 = Theme.ToggleCircle
					SwitchCircle.BorderSizePixel = 0
					SwitchCircle.Position = UDim2.new(0, 2, 0.5, -7)
					SwitchCircle.Size = UDim2.new(0, 14, 0, 14)
					SwitchCircle.Parent = SwitchFrame
					Instance.new("UICorner", SwitchCircle).CornerRadius = UDim.new(1, 0)

					local SwitchBtn = Instance.new("TextButton")
					SwitchBtn.Name = "SwitchBtn"
					SwitchBtn.Text = ""
					SwitchBtn.BackgroundTransparency = 1
					SwitchBtn.Size = UDim2.new(1, 0, 1, 0)
					SwitchBtn.Parent = Toggle

					function ToggleFunc:Set(Value, skipCallback)
						ToggleFunc.Value = Value
						ConfigData[configKey] = Value
						SaveConfig()
						if not skipCallback and typeof(ToggleConfig.Callback) == "function" then
							local ok, err = pcall(function()
								ToggleConfig.Callback(Value)
							end)
							if not ok then warn("Toggle Callback error:", err) end
						end
						if Value then
							TweenService:Create(SwitchFrame, TweenInfo.new(0.2), { BackgroundColor3 = Theme.ToggleOn }):Play()
							TweenService:Create(SwitchCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 20, 0.5, -7) }):Play()
							TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = Theme.HeaderText }):Play()
						else
							TweenService:Create(SwitchFrame, TweenInfo.new(0.2), { BackgroundColor3 = Theme.ToggleOff }):Play()
							TweenService:Create(SwitchCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 2, 0.5, -7) }):Play()
							TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = Theme.SecondaryText }):Play()
						end
					end

					SwitchBtn.Activated:Connect(function()
						ToggleFunc:Set(not ToggleFunc.Value)
					end)

					ToggleFunc:Set(ToggleFunc.Value, true)
					Elements[configKey] = ToggleFunc
					ItemCount = ItemCount + 1
					return ToggleFunc
				end

				function SectionFunc:AddSlider(SliderConfig)
					SliderConfig = SliderConfig or {}
					SliderConfig.Title = SliderConfig.Title or "Slider"
					SliderConfig.Content = SliderConfig.Content or ""
					SliderConfig.Increment = SliderConfig.Increment or 1
					SliderConfig.Min = SliderConfig.Min or 0
					SliderConfig.Max = SliderConfig.Max or 100
					SliderConfig.Default = SliderConfig.Default or 50
					SliderConfig.Callback = SliderConfig.Callback or function() end

					local configKey = "Slider_" .. SliderConfig.Title
					if ConfigData[configKey] ~= nil then
						SliderConfig.Default = ConfigData[configKey]
					end

					local SliderFunc = { Value = SliderConfig.Default }

					local Slider = Instance.new("Frame")
					Slider.Name = "Slider"
					Slider.BackgroundTransparency = 1
					Slider.LayoutOrder = ItemCount
					Slider.Size = UDim2.new(1, 0, 0, 50)
					Slider.Parent = ContentFrame

					local SliderTitle = Instance.new("TextLabel")
					SliderTitle.Name = "SliderTitle"
					SliderTitle.Font = Theme.FontBold
					SliderTitle.Text = SliderConfig.Title
					SliderTitle.TextColor3 = Theme.HeaderText
					SliderTitle.TextSize = 12
					SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
					SliderTitle.BackgroundTransparency = 1
					SliderTitle.Size = UDim2.new(1, -60, 0, 14)
					SliderTitle.Parent = Slider

					local ValueBox = Instance.new("TextBox")
					ValueBox.Name = "ValueBox"
					ValueBox.Font = Theme.FontBold
					ValueBox.Text = tostring(SliderConfig.Default)
					ValueBox.TextColor3 = Theme.HeaderText
					ValueBox.TextSize = 11
					ValueBox.BackgroundColor3 = Theme.SearchBG
					ValueBox.BackgroundTransparency = 0.3
					ValueBox.BorderSizePixel = 0
					ValueBox.Position = UDim2.new(1, -50, 0, 0)
					ValueBox.Size = UDim2.new(0, 50, 0, 20)
					ValueBox.Parent = Slider
					Instance.new("UICorner", ValueBox).CornerRadius = UDim.new(0, 4)
					local ValueStroke = Instance.new("UIStroke")
					ValueStroke.Color = Theme.Border
					ValueStroke.Thickness = 1
					ValueStroke.Parent = ValueBox

					-- Track (Ultra-thin)
					local Track = Instance.new("Frame")
					Track.Name = "Track"
					Track.BackgroundColor3 = Theme.SliderTrack
					Track.BorderSizePixel = 0
					Track.Position = UDim2.new(0, 0, 0, 32)
					Track.Size = UDim2.new(1, 0, 0, 3)
					Track.Parent = Slider
					Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

					local Fill = Instance.new("Frame")
					Fill.Name = "Fill"
					Fill.BackgroundColor3 = Theme.AccentColor
					Fill.BorderSizePixel = 0
					Fill.Size = UDim2.new(0.5, 0, 1, 0)
					Fill.Parent = Track
					Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

					local Thumb = Instance.new("Frame")
					Thumb.Name = "Thumb"
					Thumb.BackgroundColor3 = Theme.ToggleCircle
					Thumb.BorderSizePixel = 0
					Thumb.Position = UDim2.new(0.5, -6, 0.5, -6)
					Thumb.Size = UDim2.new(0, 12, 0, 12)
					Thumb.Parent = Track
					Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)

					local ThumbStroke = Instance.new("UIStroke")
					ThumbStroke.Name = "ThumbStroke"
					ThumbStroke.Color = Theme.AccentColor
					ThumbStroke.Thickness = 1.5
					ThumbStroke.Parent = Thumb

					local Dragging = false

					local function Round(Number, Factor)
						local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
						if Result < 0 then Result = Result + Factor end
						return Result
					end

					function SliderFunc:Set(Value, skipCallback)
						Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
						SliderFunc.Value = Value
						ValueBox.Text = tostring(Value)
						local scale = (Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
						TweenService:Create(Fill, TweenInfo.new(0.15), { Size = UDim2.new(scale, 0, 1, 0) }):Play()
						TweenService:Create(Thumb, TweenInfo.new(0.15), { Position = UDim2.new(scale, -6, 0.5, -6) }):Play()

						if not skipCallback then
							SliderConfig.Callback(Value)
						end
						ConfigData[configKey] = Value
						SaveConfig()
					end

					Track.InputBegan:Connect(function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
							Dragging = true
							TweenService:Create(Thumb, TweenInfo.new(0.1), { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(Thumb.Position.X.Scale, -7, 0.5, -7) }):Play()
							local scale = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
							SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * scale))
						end
					end)

					Track.InputEnded:Connect(function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
							Dragging = false
							SliderConfig.Callback(SliderFunc.Value)
							TweenService:Create(Thumb, TweenInfo.new(0.1), { Size = UDim2.new(0, 12, 0, 12) }):Play()
						end
					end)

					UserInputService.InputChanged:Connect(function(Input)
						if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
							local scale = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
							SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * scale))
						end
					end)

					ValueBox.FocusLost:Connect(function()
						local num = tonumber(ValueBox.Text:gsub("[^%d.]", ""))
						if num then
							SliderFunc:Set(num)
						else
							SliderFunc:Set(SliderFunc.Value)
						end
					end)

					SliderFunc:Set(SliderConfig.Default, true)
					Elements[configKey] = SliderFunc
					ItemCount = ItemCount + 1
					return SliderFunc
				end

				function SectionFunc:AddInput(InputConfig)
					InputConfig = InputConfig or {}
					InputConfig.Title = InputConfig.Title or "Input"
					InputConfig.Content = InputConfig.Content or ""
					InputConfig.Placeholder = InputConfig.Placeholder or "Enter text..."
					InputConfig.Default = InputConfig.Default or ""
					InputConfig.Callback = InputConfig.Callback or function() end

					local configKey = "Input_" .. InputConfig.Title
					if ConfigData[configKey] ~= nil then
						InputConfig.Default = ConfigData[configKey]
					end

					local InputFunc = { Value = InputConfig.Default }

					local Input = Instance.new("Frame")
					Input.Name = "Input"
					Input.BackgroundTransparency = 1
					Input.LayoutOrder = ItemCount
					Input.Size = UDim2.new(1, 0, 0, 56)
					Input.Parent = ContentFrame

					local InputTitle = Instance.new("TextLabel")
					InputTitle.Name = "InputTitle"
					InputTitle.Font = Theme.FontBold
					InputTitle.Text = InputConfig.Title
					InputTitle.TextColor3 = Theme.HeaderText
					InputTitle.TextSize = 12
					InputTitle.TextXAlignment = Enum.TextXAlignment.Left
					InputTitle.BackgroundTransparency = 1
					InputTitle.Size = UDim2.new(1, 0, 0, 14)
					InputTitle.Parent = Input

					local InputContent = Instance.new("TextLabel")
					InputContent.Name = "InputContent"
					InputContent.Font = Theme.Font
					InputContent.Text = InputConfig.Content
					InputContent.TextColor3 = Theme.SecondaryText
					InputContent.TextSize = 11
					InputContent.TextXAlignment = Enum.TextXAlignment.Left
					InputContent.BackgroundTransparency = 1
					InputContent.Position = UDim2.new(0, 0, 0, 16)
					InputContent.Size = UDim2.new(1, 0, 0, 12)
					InputContent.TextWrapped = true
					InputContent.Parent = Input

					local function UpdateInputSize()
						InputContent.Size = UDim2.new(1, 0, 0, InputContent.TextBounds.Y)
						Input.Size = UDim2.new(1, 0, 0, math.max(56, 28 + InputContent.TextBounds.Y + 30))
					end
					InputContent:GetPropertyChangedSignal("TextBounds"):Connect(UpdateInputSize)
					UpdateInputSize()

					local InputFrame = Instance.new("Frame")
					InputFrame.Name = "InputFrame"
					InputFrame.BackgroundColor3 = Theme.SearchBG
					InputFrame.BorderSizePixel = 0
					InputFrame.Position = UDim2.new(0, 0, 1, -28)
					InputFrame.Size = UDim2.new(1, 0, 0, 28)
					InputFrame.Parent = Input
					Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 6)
					local InputStroke = Instance.new("UIStroke")
					InputStroke.Color = Theme.Border
					InputStroke.Thickness = 1
					InputStroke.Parent = InputFrame

					local InputBox = Instance.new("TextBox")
					InputBox.Name = "InputBox"
					InputBox.Font = Theme.Font
					InputBox.PlaceholderText = InputConfig.Placeholder
					InputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
					InputBox.Text = InputConfig.Default
					InputBox.TextColor3 = Theme.HeaderText
					InputBox.TextSize = 12
					InputBox.TextXAlignment = Enum.TextXAlignment.Left
					InputBox.BackgroundTransparency = 1
					InputBox.Size = UDim2.new(1, -16, 1, -8)
					InputBox.Position = UDim2.new(0, 8, 0, 4)
					InputBox.ClearTextOnFocus = false
					InputBox.Parent = InputFrame

					function InputFunc:Set(Value, skipCallback)
						InputBox.Text = Value
						InputFunc.Value = Value
						ConfigData[configKey] = Value
						SaveConfig()
						if not skipCallback then
							InputConfig.Callback(Value)
						end
					end

					InputBox.FocusLost:Connect(function()
						InputFunc:Set(InputBox.Text)
					end)

					InputFunc:Set(InputFunc.Value, true)
					Elements[configKey] = InputFunc
					ItemCount = ItemCount + 1
					return InputFunc
				end

				function SectionFunc:AddDropdown(DropdownConfig)
					DropdownConfig = DropdownConfig or {}
					DropdownConfig.Title = DropdownConfig.Title or "Dropdown"
					DropdownConfig.Content = DropdownConfig.Content or ""
					DropdownConfig.Multi = DropdownConfig.Multi or false
					DropdownConfig.Options = DropdownConfig.Options or {}
					DropdownConfig.Default = DropdownConfig.Default or (DropdownConfig.Multi and {} or nil)
					DropdownConfig.Callback = DropdownConfig.Callback or function() end

					local configKey = "Dropdown_" .. DropdownConfig.Title
					if ConfigData[configKey] ~= nil then
						DropdownConfig.Default = ConfigData[configKey]
					end

					local DropdownFunc = { Value = DropdownConfig.Default, Options = DropdownConfig.Options }

					local Dropdown = Instance.new("Frame")
					Dropdown.Name = "Dropdown"
					Dropdown.BackgroundTransparency = 1
					Dropdown.LayoutOrder = ItemCount
					Dropdown.Size = UDim2.new(1, 0, 0, 56)
					Dropdown.Parent = ContentFrame

					local DropdownTitle = Instance.new("TextLabel")
					DropdownTitle.Name = "DropdownTitle"
					DropdownTitle.Font = Theme.FontBold
					DropdownTitle.Text = DropdownConfig.Title
					DropdownTitle.TextColor3 = Theme.HeaderText
					DropdownTitle.TextSize = 12
					DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
					DropdownTitle.BackgroundTransparency = 1
					DropdownTitle.Size = UDim2.new(1, 0, 0, 14)
					DropdownTitle.Parent = Dropdown

					local DropdownContent = Instance.new("TextLabel")
					DropdownContent.Name = "DropdownContent"
					DropdownContent.Font = Theme.Font
					DropdownContent.Text = DropdownConfig.Content
					DropdownContent.TextColor3 = Theme.SecondaryText
					DropdownContent.TextSize = 11
					DropdownContent.TextXAlignment = Enum.TextXAlignment.Left
					DropdownContent.BackgroundTransparency = 1
					DropdownContent.Position = UDim2.new(0, 0, 0, 16)
					DropdownContent.Size = UDim2.new(1, 0, 0, 12)
					DropdownContent.TextWrapped = true
					DropdownContent.Parent = Dropdown

					local function UpdateDropdownSize()
						DropdownContent.Size = UDim2.new(1, 0, 0, DropdownContent.TextBounds.Y)
						Dropdown.Size = UDim2.new(1, 0, 0, math.max(56, 28 + DropdownContent.TextBounds.Y + 30))
					end
					DropdownContent:GetPropertyChangedSignal("TextBounds"):Connect(UpdateDropdownSize)
					UpdateDropdownSize()

					local SelectFrame = Instance.new("TextButton")
					SelectFrame.Name = "SelectFrame"
					SelectFrame.Text = ""
					SelectFrame.BackgroundColor3 = Theme.SearchBG
					SelectFrame.BorderSizePixel = 0
					SelectFrame.Position = UDim2.new(0, 0, 1, -28)
					SelectFrame.Size = UDim2.new(1, 0, 0, 28)
					SelectFrame.AutoButtonColor = false
					SelectFrame.Parent = Dropdown
					Instance.new("UICorner", SelectFrame).CornerRadius = UDim.new(0, 6)
					local SelectStroke = Instance.new("UIStroke")
					SelectStroke.Color = Theme.Border
					SelectStroke.Thickness = 1
					SelectStroke.Parent = SelectFrame

					local SelectedText = Instance.new("TextLabel")
					SelectedText.Name = "SelectedText"
					SelectedText.Font = Theme.Font
					SelectedText.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
					SelectedText.TextColor3 = Theme.SecondaryText
					SelectedText.TextSize = 12
					SelectedText.TextXAlignment = Enum.TextXAlignment.Left
					SelectedText.BackgroundTransparency = 1
					SelectedText.Position = UDim2.new(0, 10, 0, 0)
					SelectedText.Size = UDim2.new(1, -30, 1, 0)
					SelectedText.Parent = SelectFrame

					local ArrowIcon = Instance.new("ImageLabel")
					ArrowIcon.Name = "ArrowIcon"
					ArrowIcon.Image = "rbxassetid://16851841101"
					ArrowIcon.Rotation = -90
					ArrowIcon.BackgroundTransparency = 1
					ArrowIcon.Position = UDim2.new(1, -22, 0.5, -6)
					ArrowIcon.Size = UDim2.new(0, 12, 0, 12)
					ArrowIcon.ImageColor3 = Theme.SecondaryText
					ArrowIcon.Parent = SelectFrame

					local function OpenDropdown()
						CloseActiveDropdown()
						ActiveDropdownFrame = SelectFrame

						local List = Instance.new("Frame")
						List.Name = "DropdownList"
						List.BackgroundColor3 = Theme.CardBG
						List.BorderSizePixel = 0
						List.Parent = DropdownOverlay
						List.ZIndex = 101
						Instance.new("UICorner", List).CornerRadius = UDim.new(0, 6)

						local ListStroke = Instance.new("UIStroke")
						ListStroke.Color = Theme.Border
						ListStroke.Thickness = 1
						ListStroke.Parent = List

						local btnAbs = SelectFrame.AbsolutePosition
						local overlayAbs = DropdownOverlay.AbsolutePosition
						List.Position = UDim2.new(0, btnAbs.X - overlayAbs.X, 0, btnAbs.Y - overlayAbs.Y + SelectFrame.AbsoluteSize.Y + 2)
						List.Size = UDim2.new(0, SelectFrame.AbsoluteSize.X, 0, 0)

						local ListScroll = Instance.new("ScrollingFrame")
						ListScroll.Name = "ListScroll"
						ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
						ListScroll.ScrollBarImageTransparency = 1
						ListScroll.ScrollBarThickness = 0
						ListScroll.Active = true
						ListScroll.BackgroundTransparency = 1
						ListScroll.BorderSizePixel = 0
						ListScroll.Size = UDim2.new(1, -8, 1, -8)
						ListScroll.Position = UDim2.new(0, 4, 0, 4)
						ListScroll.ZIndex = 102
						ListScroll.Parent = List

						local ListLayout = Instance.new("UIListLayout")
						ListLayout.Name = "ListLayout"
						ListLayout.Padding = UDim.new(0, 2)
						ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
						ListLayout.Parent = ListScroll

						ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
							local h = math.min(ListLayout.AbsoluteContentSize.Y + 8, 200)
							List.Size = UDim2.new(0, SelectFrame.AbsoluteSize.X, 0, h)
							ListScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 4)
						end)

						for _, option in ipairs(DropdownFunc.Options) do
							local label, value
							if typeof(option) == "table" and option.Label and option.Value ~= nil then
								label = tostring(option.Label)
								value = option.Value
							else
								label = tostring(option)
								value = option
							end

							local Option = Instance.new("Frame")
							Option.Name = "Option"
							Option.BackgroundTransparency = 1
							Option.Size = UDim2.new(1, 0, 0, 26)
							Option.Parent = ListScroll
							Option.ZIndex = 102

							local OptionBtn = Instance.new("TextButton")
							OptionBtn.Name = "OptionBtn"
							OptionBtn.Text = ""
							OptionBtn.BackgroundTransparency = 1
							OptionBtn.Size = UDim2.new(1, 0, 1, 0)
							OptionBtn.ZIndex = 103
							OptionBtn.Parent = Option

							local OptionText = Instance.new("TextLabel")
							OptionText.Name = "OptionText"
							OptionText.Font = Theme.Font
							OptionText.Text = label
							OptionText.TextColor3 = Theme.SecondaryText
							OptionText.TextSize = 12
							OptionText.TextXAlignment = Enum.TextXAlignment.Left
							OptionText.BackgroundTransparency = 1
							OptionText.Position = UDim2.new(0, 8, 0, 0)
							OptionText.Size = UDim2.new(1, -16, 1, 0)
							OptionText.ZIndex = 103
							OptionText.Parent = Option

							local Check = Instance.new("Frame")
							Check.Name = "Check"
							Check.BackgroundColor3 = Theme.AccentColor
							Check.BorderSizePixel = 0
							Check.Size = UDim2.new(0, 0, 0, 0)
							Check.Position = UDim2.new(0, 4, 0.5, 0)
							Check.ZIndex = 102
							Check.Parent = Option
							Instance.new("UICorner", Check).CornerRadius = UDim.new(0, 2)

							Option:SetAttribute("RealValue", value)

							OptionBtn.MouseEnter:Connect(function()
								TweenService:Create(Option, TweenInfo.new(0.1), { BackgroundTransparency = 0.9, BackgroundColor3 = Theme.HoverBright }):Play()
							end)
							OptionBtn.MouseLeave:Connect(function()
								TweenService:Create(Option, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
							end)

							OptionBtn.Activated:Connect(function()
								if DropdownConfig.Multi then
									if not table.find(DropdownFunc.Value, value) then
										table.insert(DropdownFunc.Value, value)
									else
										for i, v in pairs(DropdownFunc.Value) do
											if v == value then
												table.remove(DropdownFunc.Value, i)
												break
											end
										end
									end
								else
									DropdownFunc.Value = value
								end
								DropdownFunc:Set(DropdownFunc.Value)
							end)
						end

						DropdownOverlay.Visible = true
					end

					SelectFrame.Activated:Connect(function()
						if DropdownOverlay.Visible and ActiveDropdownFrame == SelectFrame then
							CloseActiveDropdown()
						else
							OpenDropdown()
						end
					end)

					function DropdownFunc:Clear()
						for _, child in ipairs(DropdownOverlay:GetChildren()) do
							if child.Name == "DropdownList" then
								for _, opt in ipairs(child:FindFirstChildOfClass("ScrollingFrame"):GetChildren()) do
									if opt.Name == "Option" then opt:Destroy() end
								end
							end
						end
						DropdownFunc.Value = DropdownConfig.Multi and {} or nil
						DropdownFunc.Options = {}
						SelectedText.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
					end

					function DropdownFunc:Set(Value)
						task.spawn(function()
							if DropdownConfig.Multi then
								DropdownFunc.Value = type(Value) == "table" and Value or {}
							else
								DropdownFunc.Value = (type(Value) == "table" and Value[1]) or Value
							end

							ConfigData[configKey] = DropdownFunc.Value
							SaveConfig()

							local texts = {}
							for _, Drop in ipairs(DropdownOverlay:GetChildren()) do
								if Drop.Name == "DropdownList" then
									local scroll = Drop:FindFirstChildOfClass("ScrollingFrame")
									if scroll then
										for _, Option in ipairs(scroll:GetChildren()) do
											if Option.Name == "Option" and Option:FindFirstChild("OptionText") then
												local v = Option:GetAttribute("RealValue")
												local selected = DropdownConfig.Multi and table.find(DropdownFunc.Value, v) or DropdownFunc.Value == v

												local Check = Option:FindFirstChild("Check")
												if selected then
													if Check then
														TweenService:Create(Check, TweenInfo.new(0.15), { Size = UDim2.new(0, 3, 0, 12), Position = UDim2.new(0, 2, 0.5, -6) }):Play()
													end
													TweenService:Create(Option.OptionText, TweenInfo.new(0.15), { TextColor3 = Theme.HeaderText }):Play()
													table.insert(texts, Option.OptionText.Text)
												else
													if Check then
														TweenService:Create(Check, TweenInfo.new(0.1), { Size = UDim2.new(0, 0, 0, 0) }):Play()
													end
													TweenService:Create(Option.OptionText, TweenInfo.new(0.1), { TextColor3 = Theme.SecondaryText }):Play()
												end
											end
										end
									end
								end
							end

							SelectedText.Text = (#texts == 0) and (DropdownConfig.Multi and "Select Options" or "Select Option") or table.concat(texts, ", ")

							if DropdownConfig.Callback then
								if DropdownConfig.Multi then
									DropdownConfig.Callback(DropdownFunc.Value)
								else
									local str = (DropdownFunc.Value ~= nil) and tostring(DropdownFunc.Value) or ""
									DropdownConfig.Callback(str)
								end
							end
						end)
					end

					function DropdownFunc:SetValues(newList, selecting)
						newList = newList or {}
						selecting = selecting or (DropdownConfig.Multi and {} or nil)
						DropdownFunc:Clear()
						task.spawn(function()
							for i, v in ipairs(newList) do
								DropdownFunc:AddOption(v)
								if i % 20 == 0 then task.wait() end
							end
							DropdownFunc:Set(selecting)
						end)
						DropdownFunc.Options = newList
					end

					function DropdownFunc:AddOption(option)
						if not table.find(DropdownFunc.Options, option) then
							table.insert(DropdownFunc.Options, option)
						end
					end

					function DropdownFunc:SetValue(val)
						self:Set(val)
					end

					function DropdownFunc:GetValue()
						return self.Value
					end

					DropdownFunc:SetValues(DropdownFunc.Options, DropdownFunc.Value)
					Elements[configKey] = DropdownFunc
					ItemCount = ItemCount + 1
					return DropdownFunc
				end

				function SectionFunc:AddDivider()
					local Divider = Instance.new("Frame")
					Divider.Name = "Divider"
					Divider.BackgroundColor3 = Theme.Border
					Divider.BorderSizePixel = 0
					Divider.Size = UDim2.new(1, 0, 0, 1)
					Divider.LayoutOrder = ItemCount
					Divider.Parent = ContentFrame
					ItemCount = ItemCount + 1
					return Divider
				end

				return SectionFunc
			end

			return TabFunc
		end

		return CatFunc
	end

	--// Load saved config after all elements created
	task.delay(0.5, function()
		LoadConfigElements()
	end)

	return GuiFunc
end

return VoraHub
