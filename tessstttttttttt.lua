-- ===========================================
-- SERVICES
-- ===========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local scriptId = HttpService:GenerateGUID(false)

-- ===========================================
-- ANTI DOUBLE EXECUTION & CLEANUP
-- ===========================================
if not _G.ShieldTeam_Resources then
    _G.ShieldTeam_Resources = {
        Connections = {},
        Threads = {},
        ESPObjects = {}
    }
end

local function cleanupPreviousSession()
    -- Disconnect connections
    for _, conn in ipairs(_G.ShieldTeam_Resources.Connections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    table.clear(_G.ShieldTeam_Resources.Connections)

    -- Close threads
    for _, thread in ipairs(_G.ShieldTeam_Resources.Threads) do
        pcall(function()
            coroutine.close(thread)
        end)
    end
    table.clear(_G.ShieldTeam_Resources.Threads)

    -- Destroy UI
    pcall(function()
        for _, gui in ipairs(CoreGui:GetChildren()) do
            if gui.Name:find("Fluent") or gui.Name:find("Shield") or gui.Name:find("OpenClose") then
                gui:Destroy()
            end
        end
    end)

    -- Clear ESP
    for _, obj in pairs(_G.ShieldTeam_Resources.ESPObjects) do
        pcall(function()
            if obj.Gui then
                obj.Gui:Destroy()
            end
            if obj.Highlight then
                obj.Highlight:Destroy()
            end
        end)
    end
    table.clear(_G.ShieldTeam_Resources.ESPObjects)
end

_G.ShieldTeam_ScriptId = scriptId
cleanupPreviousSession()

local function TrackConnection(conn)
    table.insert(_G.ShieldTeam_Resources.Connections, conn)
    return conn
end

local function TrackTask(func)
    local thread = task.spawn(func)
    table.insert(_G.ShieldTeam_Resources.Threads, thread)
    return thread
end

-- ===========================================
-- GLOBALS & CONSTANTS
-- ===========================================
local fireproximityprompt = fireproximityprompt
    or (syn and syn.fireproximityprompt)
    or function(prompt, holdTime)
        if not prompt or not prompt:IsA("ProximityPrompt") then
            return
        end
        holdTime = holdTime or prompt.HoldDuration or 0
        pcall(function()
            prompt:InputHoldBegin()
        end)
        if holdTime > 0 then
            task.wait(holdTime)
        end
        pcall(function()
            prompt:InputHoldEnd()
        end)
    end

local MutationList = { 
    "Any", "Normal", "Gold", "Rainbow", "Electric", 
    "Bloodit", "Starstruck", "Frozen", "Aurora" 
}

local PetList = {
    { Name = "Frog", Rarity = "Common" },
    { Name = "Bunny", Rarity = "Common" },
    { Name = "Owl", Rarity = "Uncommon" },
    { Name = "Deer", Rarity = "Rare" },
    { Name = "Robin", Rarity = "Legendary" },
    { Name = "Bee", Rarity = "Legendary" },
    { Name = "Monkey", Rarity = "Mythic" },
    { Name = "Golden Dragonfly", Rarity = "Mythic" },
    { Name = "Unicorn", Rarity = "Mythic" },
    { Name = "Bear", Rarity = "Mythic" },
    { Name = "Raccoon", Rarity = "Divine" },
    { Name = "Black Dragon", Rarity = "Divine" },
    { Name = "Ice Serpent", Rarity = "Divine" },
}

local SpeedMap = {
    ["Slow"] = 0.5,
    ["Faster"] = 0.1,
    ["Super Faster"] = 0.01
}

local PLANT_GRID_STEP = 2.5

-- ===========================================
-- CONFIGURATION
-- ===========================================
_G.Config = _G.Config or {
    PlantSeed = {},
    PlantPosition = "Grid",
    AutoPlant = false,
    HarvestSeed = { "All" },
    HarvestSpeed = "Slow",
    AutoHarvest = false,
    HarvestWeightMax = "9999",
    AutoSellMode = "Delay",
    AutoSellDelay = 1,
    AutoSell = false,
    AutoSteal = false,
    ShovelSeed = { "All" },
    ShovelWeightMin = "0",
    ShovelWeightMax = "9999",
    ShovelMutation = "Any",
    AutoShovel = false,
    PetBuyPet = {},
    AutoBuyPet = false,
    PetFinderEnabled = false,
    PetTargetName = {"Any"},
    ServerHop = false,
    ESPMaster = false,
    ESPPet = false,
    ESPFruit = false,
    ShowSellPrice = false,
    ESPStyle = "Both",
    ESPMaxDistance = 5000,
    BuySeeds = {},
    BuyGears = {},
    AutoBuySeed = false,
    AutoBuyGear = false,
    AntiAFK = true,
    AutoRejoin = true,
    DebugMode = false,
    AutoWatering = false,
    WateringCanName = "Any",
    WaterTargetPlants = { "All" },
    AutoSprinkler = false,
    SprinklerName = "Any",
    SprinklerCount = 10,
    SprinklerTargetPlants = { "All" },
    AntiFlashbang = false,
    AutoClaimSeed = false,
    ClaimSeedTypes = { "All" },
    FavoriteFruits = {},
    FavoriteMutations = {},
    FavoriteType = "None",
    AutoFavorite = false,
}

if typeof(_G.Config.HarvestSpeed) == "number" then
    if _G.Config.HarvestSpeed <= 0.05 then
        _G.Config.HarvestSpeed = "Super Faster"
    elseif _G.Config.HarvestSpeed <= 0.1 then
        _G.Config.HarvestSpeed = "Faster"
    else
        _G.Config.HarvestSpeed = "Slow"
    end
end

if type(_G.Config.PetTargetName) == "string" then
    if _G.Config.PetTargetName == "" then
        _G.Config.PetTargetName = { "Any" }
    else
        _G.Config.PetTargetName = { _G.Config.PetTargetName }
    end
end

if _G.Config.PetBuyPet == nil then
    _G.Config.PetBuyPet = {}
elseif type(_G.Config.PetBuyPet) == "string" then
    if _G.Config.PetBuyPet == "" then
        _G.Config.PetBuyPet = {}
    else
        _G.Config.PetBuyPet = { _G.Config.PetBuyPet }
    end
end

-- ===========================================
-- HELPER FUNCTIONS: CORE
-- ===========================================
local function dbg(...)
    if _G.Config.DebugMode then
        print("[ShieldTeam]", ...)
    end
end

local function tableClone(t)
    local copy = {}
    for i, v in ipairs(t) do
        copy[i] = v
    end
    return copy
end

local function getSelectedValue(v)
    if type(v) == "table" then
        return v[1]
    end
    return v
end

local function updateParagraph(paragraph, title, content)
    if not paragraph then
        return
    end
    pcall(function()
        if paragraph.Set then
            paragraph:Set({ Title = title, Content = content })
        else
            if paragraph.SetTitle and title then
                paragraph:SetTitle(title)
            end
            if paragraph.SetDesc and content then
                paragraph:SetDesc(content)
            elseif paragraph.SetContent and content then
                paragraph:SetContent(content)
            end
        end
    end)
end

local function petMatchesSelection(selectedPets, petName)
    if not selectedPets or next(selectedPets) == nil then
        return true
    end
    local isDict = false
    for k, v in pairs(selectedPets) do
        if type(k) == "string" then
            isDict = true
            break
        end
    end
    if isDict then
        if selectedPets["Any"] then
            return true
        end
        for k, v in pairs(selectedPets) do
            if v and string.lower(k) == string.lower(petName) then
                return true
            end
        end
    else
        for _, v in ipairs(selectedPets) do
            if v == "Any" or string.lower(v) == string.lower(petName) then
                return true
            end
        end
    end
    return false
end

local function listContains(list, value)
    if not list then
        return true
    end
    local isDict = false
    local hasItems = false
    for k, v in pairs(list) do
        hasItems = true
        if type(k) == "string" then
            isDict = true
            break
        end
    end
    if not hasItems then
        return true
    end
    if isDict then
        for k, v in pairs(list) do
            if v == true and (string.lower(k) == "all" or string.lower(k) == string.lower(value)) then
                return true
            end
        end
    else
        for _, v in ipairs(list) do
            if v == "All" or string.lower(v) == string.lower(value) then
                return true
            end
        end
    end
    return false
end

local function parseFormattedNumber(text)
    if not text then
        return 0
    end
    text = text:gsub(",", ""):upper()
    local numStr, suffix = string.match(text, "([%d%.]+)%s*([KMB]?)")
    if not numStr then
        return 0
    end
    local num = tonumber(numStr) or 0
    if suffix == "K" then
        num = num * 1000
    elseif suffix == "M" then
        num = num * 1000000
    elseif suffix == "B" then
        num = num * 1000000000
    end
    return math.floor(num)
end

local Networking, PacketRemote
local function refreshNetworking()
    local ok, mod = pcall(function()
        return require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Networking"))
    end)
    if ok then
        Networking = mod
    end
    local ok2, remote = pcall(function()
        return ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Packet"):WaitForChild("RemoteEvent")
    end)
    if ok2 then
        PacketRemote = remote
    end
end
refreshNetworking()

-- ===========================================
-- REMOTE MAPPING & DEBUGGING
-- ===========================================
_G.Remotes = _G.Remotes or {}

local function ScanRemotes()
    _G.Remotes = {}
    local folders = {}
    local descendants = ReplicatedStorage:GetDescendants()
    for i, inst in ipairs(descendants) do
        if i % 100 == 0 then task.wait() end
        if inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") then
            table.insert(_G.Remotes, inst)
            local parentPath = inst.Parent and inst.Parent:GetFullName() or "nil"
            folders[parentPath] = folders[parentPath] or {}
            table.insert(folders[parentPath], inst.Name .. " (" .. inst.ClassName .. ")")
        end
    end
    dbg("[ScanRemotes] Found", #_G.Remotes, "remotes total")
end

local function AutoDetectGameStructure()
    dbg("[AutoDetect] PlaceId:", game.PlaceId)
    local gardens = workspace:FindFirstChild("Gardens")
    if gardens then
        for _, plot in ipairs(gardens:GetChildren()) do
            if plot:GetAttribute("Owner") == player.Name then
                dbg("[AutoDetect] Owned plot:", plot.Name)
                break
            end
        end
    end
end

ScanRemotes()
AutoDetectGameStructure()

-- ===========================================
-- FALLBACK DATA & COST CACHING
-- ===========================================
local FALLBACK_SEEDS = {
    "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple", "Bamboo", "Corn", "Cactus", "Pineapple",
    "Mushroom", "Green Bean", "Banana", "Grape", "Coconut", "Mango", "Dragon Fruit", "Acorn", "Cherry",
    "Sunflower", "Venus Fly Trap", "Pomegranate", "Poison Apple", "Venom Spitter", "Moon Bloom", "Dragon's Breath",
    "Ghost Pepper", "Poison Ivy", "Baby Cactus", "Glow Mushroom", "Romanesco", "Horned Melon", "Hypnobloom"
}

local FALLBACK_GEARS = {
    "Watering Can", "Trowel", "Shovel", "Recall Wrench", "Basic Sprinkler",
    "Advanced Sprinkler", "Godly Sprinkler", "Master Sprinkler",
}

_G.CachedCosts = _G.CachedCosts or {}
local defaultCosts = {
    ["Carrot"] = 1, ["Strawberry"] = 10, ["Blueberry"] = 25, ["Tulip"] = 40, ["Tomato"] = 200, ["Apple"] = 400,
    ["Bamboo"] = 700, ["Corn"] = 2500, ["Cactus"] = 5000, ["Pineapple"] = 10000, ["Mushroom"] = 15000,
    ["Green Bean"] = 20000, ["Banana"] = 30000, ["Grape"] = 50000, ["Coconut"] = 140000, ["Mango"] = 300000,
    ["Dragon Fruit"] = 120000, ["Acorn"] = 700000, ["Cherry"] = 1200000, ["Sunflower"] = 5000000,
    ["Venus Fly Trap"] = 7000000, ["Pomegranate"] = 12000000, ["Poison Apple"] = 25000000, ["Venom Spitter"] = 30000000,
    ["Moon Bloom"] = 65000000, ["Dragon's Breath"] = 90000000, ["Ghost Pepper"] = 2800000, ["Poison Ivy"] = 2800000,
    ["Baby Cactus"] = 1, ["Glow Mushroom"] = 1, ["Romanesco"] = 1, ["Horned Melon"] = 1, ["Hypnobloom"] = 1,
    ["Watering Can"] = 50, ["Trowel"] = 100, ["Shovel"] = 150, ["Recall Wrench"] = 200, ["Basic Sprinkler"] = 300,
    ["Advanced Sprinkler"] = 1000, ["Godly Sprinkler"] = 5000, ["Master Sprinkler"] = 25000
}
for k, v in pairs(defaultCosts) do
    _G.CachedCosts[k] = v
end

pcall(function()
    local SeedData = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("SeedData"))
    if type(SeedData) == "table" then
        for _, info in ipairs(SeedData) do
            if type(info) == "table" and info.SeedName and info.PurchasePrice then
                _G.CachedCosts[info.SeedName] = info.PurchasePrice
            end
        end
    end
end)

pcall(function()
    local GearShopData = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("GearShopData"))
    if type(GearShopData) == "table" and type(GearShopData.Data) == "table" then
        for _, info in ipairs(GearShopData.Data) do
            if type(info) == "table" and info.ItemName and info.Cost then
                _G.CachedCosts[info.ItemName] = info.Cost
            end
        end
    end
end)

local function getSeedList()
    local list = {}
    local ok, items = pcall(function()
        return ReplicatedStorage.StockValues.SeedShop.Items:GetChildren()
    end)
    if ok and items and #items > 0 then
        for _, item in ipairs(items) do
            table.insert(list, item.Name)
        end
    else
        list = tableClone(FALLBACK_SEEDS)
    end
    table.sort(list, function(a, b)
        return string.lower(a) < string.lower(b)
    end)
    return list
end

local function getGearList()
    local list = {}
    local ok, items = pcall(function()
        local sv = ReplicatedStorage:FindFirstChild("StockValues")
        local gs = sv and (sv:FindFirstChild("GearShop") or sv:FindFirstChild("GearsShop"))
        return gs and gs:FindFirstChild("Items"):GetChildren()
    end)
    if ok and items and #items > 0 then
        for _, item in ipairs(items) do
            table.insert(list, item.Name)
        end
    else
        list = tableClone(FALLBACK_GEARS)
    end
    table.sort(list, function(a, b)
        return string.lower(a) < string.lower(b)
    end)
    return list
end

local function getHarvestOptions()
    local opts = { "All" }
    for _, seed in ipairs(getSeedList()) do
        table.insert(opts, seed)
    end
    return opts
end

local function getPetNames()
    local names = {}
    for _, pet in ipairs(PetList) do
        table.insert(names, pet.Name)
    end
    return names
end

-- ===========================================
-- HELPER FUNCTIONS: PLAYER & INVENTORY
-- ===========================================
local function getHRP()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getMoney()
    local ls = player:FindFirstChild("leaderstats")
    local sheckles = ls and ls:FindFirstChild("Sheckles")
    return sheckles and sheckles.Value or 0
end

local function getOwnedPlots()
    local plots = {}
    local gardens = workspace:FindFirstChild("Gardens")
    if not gardens then
        return plots
    end
    for _, plot in ipairs(gardens:GetChildren()) do
        local owner = plot:GetAttribute("Owner")
        local ownerId = plot:GetAttribute("OwnerUserId")
        local isOwner = (owner == player.Name) or (ownerId and tostring(ownerId) == tostring(player.UserId))
        if isOwner then
            table.insert(plots, plot)
        end
    end
    return plots
end

local function findPrompt(inst)
    if not inst then
        return nil
    end
    if inst:IsA("ProximityPrompt") then
        return inst
    end
    for _, desc in ipairs(inst:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            return desc
        end
    end
    return nil
end

local function getPlantName(plant)
    if not plant then
        return ""
    end
    return plant:GetAttribute("SeedName")
        or plant:GetAttribute("FruitName")
        or plant:GetAttribute("CorePartName")
        or plant.Name
        or ""
end

local function getInventoryWateringCans()
    local cans = { "Any" }
    local seen = {}
    local function check(child)
        if child:IsA("Tool") then
            local attr = child:GetAttribute("WateringCan")
            if attr and not seen[attr] then
                seen[attr] = true
                table.insert(cans, attr)
            end
        end
    end
    local char = player.Character
    if char then
        for _, c in ipairs(char:GetChildren()) do
            check(c)
        end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _, c in ipairs(bp:GetChildren()) do
            check(c)
        end
    end
    return cans
end

local function getInventorySprinklers()
    local sprs = { "Any" }
    local seen = {}
    local function check(child)
        if child:IsA("Tool") then
            local attr = child:GetAttribute("Sprinkler")
            if attr and not seen[attr] then
                seen[attr] = true
                table.insert(sprs, attr)
            end
        end
    end
    local char = player.Character
    if char then
        for _, c in ipairs(char:GetChildren()) do
            check(c)
        end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _, c in ipairs(bp:GetChildren()) do
            check(c)
        end
    end
    return sprs
end

local function equipSpecificTool(tool)
    local char = player.Character
    if not char then
        return false
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then
        return false
    end
    if tool.Parent ~= char then
        hum:UnequipTools()
        task.wait(0.05)
        tool.Parent = char
        task.wait(0.15)
    end
    return tool.Parent == char
end

local function isInventoryFull()
    local cur, max = 0, 999
    pcall(function()
        local pg = player:FindFirstChild("PlayerGui")
        if not pg then
            return
        end
        for _, d in ipairs(pg:GetDescendants()) do
            if d:IsA("TextLabel") and string.match(d.Text, "(%d+)%s*/%s*(%d+)") then
                if string.find(string.lower(d.Text), "fruit") or string.find(string.lower(d.Text), "inventory") then
                    local c, m = string.match(d.Text, "(%d+)%s*/%s*(%d+)")
                    cur = tonumber(c) or cur
                    max = tonumber(m) or max
                    break
                end
            end
        end
    end)
    return cur >= max
end

-- ===========================================
-- HELPER FUNCTIONS: SHOP
-- ===========================================
local function getBuyOpcodes()
    local seedOpcode, gearOpcode = 102, 109
    pcall(function()
        if not PacketRemote then
            refreshNetworking()
        end
        if PacketRemote then
            local attrs = PacketRemote:GetAttributes()
            for name, val in pairs(attrs) do
                if type(val) == "number" then
                    local ln = name:lower()
                    if ln:find("seed") and (ln:find("buy") or ln:find("purchase")) and not ln:find("restock") then
                        seedOpcode = val
                    end
                    if (ln:find("gear") or ln:find("tool")) and (ln:find("buy") or ln:find("purchase")) and not ln:find("restock") then
                        gearOpcode = val
                    end
                end
            end
        end
    end)
    return seedOpcode, gearOpcode
end

local function getPetBuyOpcode()
    local petOpcode = 76
    pcall(function()
        if not PacketRemote then
            refreshNetworking()
        end
        if PacketRemote then
            local attrs = PacketRemote:GetAttributes()
            local function isRequestName(name)
                local ln = name:lower()
                return not ln:find("result")
                   and not ln:find("response")
                   and not ln:find("effect")
                   and not ln:find("visual")
            end
            for name, val in pairs(attrs) do
                if type(val) == "number" then
                    local ln = name:lower()
                    if ln:find("pet") and ln:find("wild") and (ln:find("tame") or ln:find("buy")) and isRequestName(name) then
                        return val
                    end
                end
            end
        end
    end)
    return petOpcode
end

local function buyShopItem(itemType, itemName)
    if not PacketRemote then
        refreshNetworking()
    end
    if not PacketRemote then
        return false
    end
    local seedOpcode, gearOpcode = getBuyOpcodes()
    local byteId = itemType == "seed" and seedOpcode or gearOpcode
    local ok = pcall(function()
        local nameLen = #itemName
        local b = buffer.create(3 + nameLen)
        buffer.writeu16(b, 0, byteId)
        buffer.writeu8(b, 2, nameLen)
        buffer.writestring(b, 3, itemName)
        PacketRemote:FireServer(b)
    end)
    if ok then
        _G.CachedCosts[itemName] = _G.CachedCosts[itemName] or 999999
    end
    return ok
end

-- ===========================================
-- HELPER FUNCTIONS: PLANT POSITIONS
-- ===========================================
local function getColumnBounds(column)
    local minX, maxX, minZ, maxZ, avgY, count
    local function consider(part)
        if not part:IsA("BasePart") then
            return
        end
        local pos = part.Position
        minX = minX and math.min(minX, pos.X) or pos.X
        maxX = maxX and math.max(maxX, pos.X) or pos.X
        minZ = minZ and math.min(minZ, pos.Z) or pos.Z
        maxZ = maxZ and math.max(maxZ, pos.Z) or pos.Z
        avgY = (avgY or 0) + pos.Y
        count = (count or 0) + 1
    end
    if column:IsA("BasePart") then
        consider(column)
    end
    for _, p in ipairs(column:GetDescendants()) do
        consider(p)
    end
    if not count then
        return nil
    end
    return minX, maxX, minZ, maxZ, avgY / count
end

local function getPlantPositionsForColumn(column)
    local mode = _G.Config.PlantPosition or "Grid"
    local minX, maxX, minZ, maxZ, avgY = getColumnBounds(column)
    if not minX then
        return {}
    end
    if mode == "Random" then
        local pos = {}
        for _ = 1, 5 do
            table.insert(pos, Vector3.new(
                minX + math.random() * (maxX - minX),
                avgY,
                minZ + math.random() * (maxZ - minZ)
            ))
        end
        return pos
    elseif mode == "Player" then
        local hrp = getHRP()
        if hrp then
            return {
                Vector3.new(
                    math.clamp(hrp.Position.X, minX + 1, maxX - 1),
                    avgY,
                    math.clamp(hrp.Position.Z, minZ + 1, maxZ - 1)
                )
            }
        end
        return {}
    else
        local pos = {}
        local x = minX
        while x <= maxX do
            local z = minZ
            while z <= maxZ do
                table.insert(pos, Vector3.new(x, avgY, z))
                z += PLANT_GRID_STEP
            end
            x += PLANT_GRID_STEP
        end
        return pos
    end
end

-- ===========================================
-- HELPER FUNCTIONS: SHOVEL & PETS
-- ===========================================
local PlantWeightCache = {}
local function getAccurateWeight(obj)
    local w = obj:GetAttribute("Weight") or obj:GetAttribute("Mass")
    if typeof(w) == "number" and w > 0 then
        return w
    end
    
    local plantName = obj:GetAttribute("SeedName")
        or obj:GetAttribute("CorePartName")
        or obj:GetAttribute("FruitName")
        or obj.Name
    local baseWeight = PlantWeightCache[plantName]
    
    if baseWeight == nil then
        baseWeight = false
        pcall(function()
            local pgm = ReplicatedStorage:FindFirstChild("PlantGenerationModules")
            if pgm then
                local fruitMod = pgm:FindFirstChild("Fruits") and pgm.Fruits:FindFirstChild(plantName)
                if fruitMod and fruitMod:IsA("ModuleScript") then
                    local d = require(fruitMod)
                    if d and d.GrowData and d.GrowData.BaseWeight then
                        baseWeight = d.GrowData.BaseWeight
                    end
                end
                if not baseWeight then
                    local plantMod = pgm:FindFirstChild("Plants") and pgm.Plants:FindFirstChild(plantName)
                    if plantMod then
                        local d = require(plantMod)
                        if d and d.GrowData and d.GrowData.BaseWeight then
                            baseWeight = d.GrowData.BaseWeight
                        end
                    end
                end
            end
        end)
        PlantWeightCache[plantName] = baseWeight
    end
    
    if baseWeight then
        local sizeMulti = obj:GetAttribute("SizeMulti") or 1
        return baseWeight * sizeMulti
    end
    
    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
    return part and part.AssemblyMass or 0
end

local function matchesShovelWeight(weight)
    local minW = tonumber(_G.Config.ShovelWeightMin) or 0
    local maxW = tonumber(_G.Config.ShovelWeightMax) or math.huge
    return weight >= minW and weight <= maxW
end

local function matchesShovelMutation(plant, filter)
    if filter == "Any" then
        return true
    end
    local m = plant:GetAttribute("Mutation") or "Normal"
    if filter == "Normal" then
        return m == "Normal" or m == ""
    end
    return string.lower(m) == string.lower(filter)
end

local function getPetDisplayName(pet)
    return pet:GetAttribute("PetName") or pet.Name
end

local function getPetRarity(pet)
    return pet:GetAttribute("Rarity") or ""
end

local function isWildPet(obj)
    if not obj or not obj:IsA("Model") then
        return false
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and obj:IsDescendantOf(p.Character) then
            return false
        end
    end
    return not (obj:GetAttribute("Owner") or obj:GetAttribute("Equipped"))
end

local function scanForPet(selectedPets)
    local descendants = workspace:GetDescendants()
    for i, obj in ipairs(descendants) do
        if i % 100 == 0 then task.wait() end
        if obj:IsA("Model") and isWildPet(obj) then
            local petName = getPetDisplayName(obj)
            if getPetRarity(obj) ~= "" or obj:GetAttribute("PetName") then
                if listContains(selectedPets, petName) then
                    return obj
                end
            end
        end
    end
    return nil
end

-- ===========================================
-- LOGIC: ANTI FLASHBANG
-- ===========================================
local originalFlashbangVFX = nil
local function applyAntiFlashbang()
    pcall(function()
        local FlashbangVFXController = require(player.PlayerScripts:WaitForChild("Controllers"):WaitForChild("FlashbangVFXController"))
        if FlashbangVFXController and not originalFlashbangVFX then
            originalFlashbangVFX = {
                Flash = FlashbangVFXController.Flash,
                DetonationFlash = FlashbangVFXController.DetonationFlash
            }
        end
        if FlashbangVFXController then
            FlashbangVFXController.Flash = function() end
            FlashbangVFXController.DetonationFlash = function() end
        end
    end)
end

TrackTask(function()
    while _G.ShieldTeam_ScriptId == scriptId do
        if _G.Config.AntiFlashbang then
            pcall(function()
                local Lighting = game:GetService("Lighting")
                local cam = workspace.CurrentCamera
                if Lighting.ExposureCompensation > 1 then
                    Lighting.ExposureCompensation = 0
                end
                if cam.FieldOfView > 75 then
                    cam.FieldOfView = 70
                end
                local pg = player:FindFirstChild("PlayerGui")
                if pg then
                    local fg = pg:FindFirstChild("FlashbangGui")
                    if fg then
                        fg:Destroy()
                    end
                end
            end)
            task.wait(0.1)
        else
            task.wait(1)
        end
    end
end)

-- ===========================================
-- UI SETUP & MANAGERS
-- ===========================================
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/KAN-FISCH/tesss/refs/heads/main/tester26"))()
local webook = loadstring(game:HttpGet("https://raw.githubusercontent.com/KAN-FISCH/tesss/refs/heads/main/serverGag"))()

Fluent.Notify = function(_, cfg)
    Fluent:SetNotification({
        Title = cfg.Title or "",
        Content = cfg.Content or cfg.Description or "",
        Delay = cfg.Duration or cfg.Delay or 5,
    })
end

local Window = Fluent:CreateWindow({
    Title = "ShieldTeam || Free || Garden V2",
    ["Tab Width"] = 110,
    SizeUi = UDim2.fromOffset(630, 330)
})

local SaveManager = {}
SaveManager.Folder = "ShieldTeam_GAG2"
SaveManager.File = SaveManager.Folder .. "/config.json"
SaveManager.Elements = {}

function SaveManager:SetFolder(folder)
    self.Folder = folder
    self.File = folder .. "/config.json"
end

function SaveManager:Register(key, element, kind)
    self.Elements[key] = { Element = element, Kind = kind }
end

function SaveManager:Save()
    if not writefile then
        return
    end
    pcall(function()
        if not isfolder(self.Folder) then
            makefolder(self.Folder)
        end
        writefile(self.File, HttpService:JSONEncode(_G.Config))
    end)
end

function SaveManager:Load()
    if not readfile or not isfile(self.File) then
        return
    end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(self.File))
    end)
    if ok and typeof(data) == "table" then
        for k, v in pairs(data) do
            _G.Config[k] = v
        end
    end
end

function SaveManager:Apply()
    for key, info in pairs(self.Elements) do
        local val = _G.Config[key]
        if val ~= nil then
            pcall(function()
                if info.Kind == "Toggle" then
                    info.Element:Set(val, true)
                elseif info.Kind == "Dropdown" then
                    if typeof(val) == "string" and not string.find(key, "Seed", 1, true) then
                        info.Element:Set({ val })
                    else
                        info.Element:Set(val)
                    end
                elseif info.Kind == "Slider" then
                    info.Element:Set(val)
                elseif info.Kind == "Input" then
                    info.Element:Set(tostring(val))
                end
            end)
        end
    end
end

function SaveManager:BuildConfigSection(Tab)
    local Section = Tab:AddSection("Configuration", true, "Left")
    Section:AddButton({
        Title = "Save Config",
        Callback = function()
            SaveManager:Save()
            Fluent:Notify({ Title = "Saved", Content = "Configuration saved.", Duration = 3 })
        end,
    })
    Section:AddButton({
        Title = "Load Config",
        Callback = function()
            SaveManager:Load()
            SaveManager:Apply()
            Fluent:Notify({ Title = "Loaded", Content = "Configuration loaded.", Duration = 3 })
        end,
    })
end

local InterfaceManager = {}
InterfaceManager.Folder = SaveManager.Folder

function InterfaceManager:SetFolder(folder)
    self.Folder = folder
end

function InterfaceManager:BuildInterfaceSection(Tab)
    local Section = Tab:AddSection("Interface", true, "Right")
    Section:AddButton({
        Title = "Unload UI",
        Callback = function()
            Fluent.Unloaded = true
            pcall(function()
                for _, gui in ipairs(CoreGui:GetChildren()) do
                    if gui.Name:find("Speed") or gui.Name:find("Fluent") or gui.Name:find("OpenClose") then
                        gui:Destroy()
                    end
                end
            end)
        end,
    })
    Section:AddParagraph({
        Title = "Config Folder",
        Content = self.Folder,
    })
end

SaveManager:Load()

-- ===========================================
-- PREMIUM KEY UI LOGIC
-- ===========================================
local function formatSecondsToReadable(secs)
    local ok, num = pcall(function() return tonumber(secs) end)
    if not ok or not num or num <= 0 then
        return "Expired"
    end
    num = math.floor(num)
    local years  = math.floor(num / (365 * 86400))
    local months = math.floor((num % (365 * 86400)) / (30 * 86400))
    local days   = math.floor((num % (30 * 86400)) / 86400)
    local hours  = math.floor((num % 86400) / 3600)
    local mins   = math.floor((num % 3600) / 60)
    if years > 0 then
        return years .. " Tahun " .. ((months > 0) and (months .. " Bulan") or "")
    elseif months > 0 then
        return months .. " Bulan " .. days .. " Hari"
    elseif days > 0 then
        return days .. " Hari " .. hours .. " Jam " .. mins .. " Mnt"
    elseif hours > 0 then
        return hours .. " Jam " .. mins .. " Mnt"
    else
        return mins .. " Mnt"
    end
end

local function formatTimestamp(ts)
    local ok, num = pcall(function() return tonumber(ts) end)
    if not ok or not num then
        return tostring(ts)
    end
    if num > 9999999999 then
        num = math.floor(num / 1000)
    end
    local t = os.date("*t", num)
    if not t then
        return tostring(ts)
    end
    return string.format("%02d/%02d/%04d %02d:%02d", t.day, t.month, t.year, t.hour, t.min)
end

local function validateKey(Key)
    local HWID = game:GetService("RbxAnalyticsService"):GetClientId()
    local url = "https://key.shieldteam.asia/api/validate?key=" .. tostring(Key) .. "&hwid=" .. HWID
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        local data = nil
        local jsonSuccess = pcall(function()
            data = HttpService:JSONDecode(response)
        end)
        if jsonSuccess and data then
            if data.status then
                local sisaWaktu = "Active"
                if data.timeLeft and tonumber(data.timeLeft) then
                    sisaWaktu = formatSecondsToReadable(data.timeLeft)
                end
                local waktuExpired = "Active"
                local rawExpiry = data.expiry or data.expired or data.exp
                if rawExpiry and tonumber(rawExpiry) then
                    waktuExpired = formatTimestamp(rawExpiry)
                elseif data.timeLeft and tonumber(data.timeLeft) then
                    waktuExpired = formatTimestamp(os.time() + math.floor(tonumber(data.timeLeft)))
                end
                return data.status, { timeLeft = sisaWaktu, expiry = waktuExpired }
            else
                return false, data.msg or "Key tidak valid."
            end
        end
    end
    return false, "Gagal terhubung ke server validasi."
end

local function saveSavedKey(Key)
    if writefile then
        pcall(function()
            writefile("ShieldKey.txt", tostring(Key))
        end)
    end
end

local function getSavedKey()
    if isfile and isfile("ShieldKey.txt") and readfile then
        local ok, content = pcall(readfile, "ShieldKey.txt")
        if ok then
            return content:gsub("%s+", "")
        end
    end
    return ""
end

local function createPremiumKeyUI(Info, TabMain, TabAuto, TabShop, TabSetting, Speed_Library)
    local genvKey = (getgenv and getgenv().Key) or ""
    local globalKey = tostring(_G.Key or "")
    local savedKey = getSavedKey()
    local userKey = ""
    
    if genvKey ~= "" then
        userKey = genvKey
    elseif globalKey ~= "" and globalKey ~= "nil" then
        userKey = globalKey
    elseif savedKey ~= "" then
        userKey = savedKey
    end
    
    if userKey ~= "" then
        _G.Key = userKey
        getgenv().Key = userKey
    end

    local function Create(Name, Properties, Parent)
        local _instance = Instance.new(Name)
        for i, v in pairs(Properties) do
            _instance[i] = v
        end
        if Parent then
            _instance.Parent = Parent
        end
        return _instance
    end

    local ScrolLayers = Info.ScrolLayers
    local LayersFolder = ScrolLayers.Parent
    local LayersReal = LayersFolder.Parent
    local Layers = LayersReal.Parent
    local PanelsArea = Layers.Parent
    local ContentArea = PanelsArea.Parent
    local ContentHeader = ContentArea:FindFirstChild("ContentHeader")
    local NameTab = ContentHeader:FindFirstChild("NameTab")
    local NameTabSub = ContentHeader:FindFirstChild("NameTabSub")
    local LayersRight = PanelsArea:FindFirstChild("LayersRight")

    local SubTabBar = Create("Frame", {
        Name = "SubTabBar",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false
    }, ContentHeader)

    local subTabList = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 20),
        VerticalAlignment = Enum.VerticalAlignment.Center
    }, SubTabBar)

    Create("UIPadding", { PaddingLeft = UDim.new(0, 15) }, SubTabBar)

    local infoEventBtn = Create("TextButton", {
        Name = "InfoEventBtn",
        Text = "Info Event",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(160, 160, 180),
        Size = UDim2.new(0, 80, 0, 20),
        BackgroundTransparency = 1,
        LayoutOrder = 1
    }, SubTabBar)

    local infoEventUnderline = Create("Frame", {
        Name = "Underline",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Color3.fromRGB(138, 43, 226),
        BorderSizePixel = 0,
        Visible = false
    }, infoEventBtn)

    local premKeyBtn = Create("TextButton", {
        Name = "PremKeyBtn",
        Text = "Premium Key System",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 130, 0, 20),
        BackgroundTransparency = 1,
        LayoutOrder = 2
    }, SubTabBar)

    local premKeyUnderline = Create("Frame", {
        Name = "Underline",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Color3.fromRGB(138, 43, 226),
        BorderSizePixel = 0,
        Visible = true
    }, premKeyBtn)

    local PremiumKeyPage = Create("Frame", {
        Name = "PremiumKeyPage",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = true
    }, PanelsArea)

    local leftCol = Create("Frame", {
        Name = "LeftColumn",
        Size = UDim2.new(0.5, -6, 1, -26),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }, PremiumKeyPage)

    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    }, leftCol)

    local rightCol = Create("Frame", {
        Name = "RightColumn",
        Size = UDim2.new(0.5, -6, 1, -26),
        Position = UDim2.new(0.5, 6, 0, 0),
        BackgroundTransparency = 1
    }, PremiumKeyPage)

    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    }, rightCol)

    local leftTitleFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder = 1
    }, leftCol)

    Create("ImageLabel", {
        Image = "http://www.roblox.com/asset/?id=6023426915",
        ImageColor3 = Color3.fromRGB(138, 43, 226),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 4, 0.5, -10)
    }, leftTitleFrame)

    Create("TextLabel", {
        Text = "Premium Key System",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(0, 30, 0, 2),
        Size = UDim2.new(1, -30, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, leftTitleFrame)

    Create("TextLabel", {
        Text = "Masukkan key premium Anda untuk unlock fitur premium.",
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextColor3 = Color3.fromRGB(140, 140, 150),
        Position = UDim2.new(0, 30, 0, 16),
        Size = UDim2.new(1, -30, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, leftTitleFrame)

    local inputCard = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BorderSizePixel = 0,
        LayoutOrder = 2
    }, leftCol)

    Create("UICorner", { CornerRadius = UDim.new(0, 6) }, inputCard)
    Create("UIStroke", { Color = Color3.fromRGB(45, 45, 55), Thickness = 1, Transparency = 0.4 }, inputCard)

    local textInputBg = Create("Frame", {
        Size = UDim2.new(1, -12, 0, 28),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = Color3.fromRGB(12, 12, 16),
        BorderSizePixel = 0
    }, inputCard)

    Create("UICorner", { CornerRadius = UDim.new(0, 4) }, textInputBg)
    Create("UIStroke", { Color = Color3.fromRGB(35, 35, 45), Thickness = 1, Transparency = 0.5 }, textInputBg)
    Create("ImageLabel", {
        Image = "http://www.roblox.com/asset/?id=6031087405",
        ImageColor3 = Color3.fromRGB(120, 120, 130),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 8, 0.5, -6)
    }, textInputBg)

    local keyTextBox = Create("TextBox", {
        PlaceholderText = "Masukkan Premium Key Anda...",
        Text = userKey,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        PlaceholderColor3 = Color3.fromRGB(90, 90, 100),
        Position = UDim2.new(0, 26, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, textInputBg)

    keyTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        userKey = keyTextBox.Text
    end)

    local validateBtn = Create("TextButton", {
        Text = "Validate Key",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, -12, 0, 28),
        Position = UDim2.new(0, 6, 0, 40),
        BackgroundColor3 = Color3.fromRGB(120, 60, 210),
        BorderSizePixel = 0
    }, inputCard)

    Create("UICorner", { CornerRadius = UDim.new(0, 4) }, validateBtn)
    Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 30, 160))
        }
    }, validateBtn)
    Create("ImageLabel", {
        Image = "http://www.roblox.com/asset/?id=6031068433",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0.5, -46, 0.5, -6)
    }, validateBtn)

    local featuresCard = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 95),
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BorderSizePixel = 0,
        LayoutOrder = 3
    }, leftCol)

    Create("UICorner", { CornerRadius = UDim.new(0, 6) }, featuresCard)
    Create("UIStroke", { Color = Color3.fromRGB(45, 45, 55), Thickness = 1, Transparency = 0.4 }, featuresCard)
    Create("ImageLabel", {
        Image = "http://www.roblox.com/asset/?id=6034825996",
        ImageColor3 = Color3.fromRGB(180, 130, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 8, 0, 6)
    }, featuresCard)
    Create("TextLabel", {
        Text = "Keunggulan Premium",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(180, 130, 255),
        Position = UDim2.new(0, 24, 0, 4),
        Size = UDim2.new(1, -30, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, featuresCard)

    local gridFrame = Create("Frame", {
        Size = UDim2.new(1, -12, 0, 42),
        Position = UDim2.new(0, 6, 0, 24),
        BackgroundTransparency = 1
    }, featuresCard)
    Create("UIGridLayout", {
        CellPadding = UDim2.new(0, 4, 0, 2),
        CellSize = UDim2.new(0.5, -2, 0, 11),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder
    }, gridFrame)

    local function addFeature(text, order)
        local item = Create("Frame", { BackgroundTransparency = 1, LayoutOrder = order }, gridFrame)
        Create("TextLabel", {
            Text = "âœ“",
            Font = Enum.Font.GothamBold,
            TextSize = 9,
            TextColor3 = Color3.fromRGB(160, 100, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 12, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left
        }, item)
        Create("TextLabel", {
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 8,
            TextColor3 = Color3.fromRGB(200, 200, 210),
            Position = UDim2.new(0, 14, 0, 0),
            Size = UDim2.new(1, -14, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1
        }, item)
    end

    addFeature("Akses Semua Fitur", 1)
    addFeature("Fitur Eksklusif", 2)
    addFeature("Auto Farming", 3)
    addFeature("Priority Support", 4)
    addFeature("Unlock Semua Area", 5)
    addFeature("Update Lebih Cepat", 6)

    local banner = Create("Frame", {
        Size = UDim2.new(1, -12, 0, 20),
        Position = UDim2.new(0, 6, 0, 74),
        BackgroundColor3 = Color3.fromRGB(28, 15, 48),
        BorderSizePixel = 0
    }, featuresCard)
    Create("UICorner", { CornerRadius = UDim.new(0, 4) }, banner)
    Create("ImageLabel", {
        Image = "http://www.roblox.com/asset/?id=6031068433",
        ImageColor3 = Color3.fromRGB(180, 130, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0, 6, 0.5, -5)
    }, banner)
    Create("TextLabel", {
        Text = "Jadi bagian dari komunitas premium ShieldTeam!",
        Font = Enum.Font.GothamMedium,
        TextSize = 8,
        TextColor3 = Color3.fromRGB(180, 130, 255),
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, banner)

    local rightTitleFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder = 1
    }, rightCol)
    Create("ImageLabel", {
        Image = "http://www.roblox.com/asset/?id=6031080356",
        ImageColor3 = Color3.fromRGB(138, 43, 226),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 4, 0.5, -10)
    }, rightTitleFrame)
    Create("TextLabel", {
        Text = "Key Information",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(0, 30, 0, 2),
        Size = UDim2.new(1, -30, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, rightTitleFrame)
    Create("TextLabel", {
        Text = "Informasi status key Anda",
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextColor3 = Color3.fromRGB(140, 140, 150),
        Position = UDim2.new(0, 30, 0, 16),
        Size = UDim2.new(1, -30, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, rightTitleFrame)

    local statusCard = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BorderSizePixel = 0,
        LayoutOrder = 2
    }, rightCol)
    Create("UICorner", { CornerRadius = UDim.new(0, 6) }, statusCard)
    Create("UIStroke", { Color = Color3.fromRGB(45, 45, 55), Thickness = 1, Transparency = 0.4 }, statusCard)

    local keyGlowFrame = Create("Frame", {
        Size = UDim2.new(0, 46, 0, 46),
        Position = UDim2.new(0, 8, 0.5, -23),
        BackgroundColor3 = Color3.fromRGB(16, 12, 28),
        BorderSizePixel = 0
    }, statusCard)
    Create("UICorner", { CornerRadius = UDim.new(0, 6) }, keyGlowFrame)
    Create("UIStroke", { Color = Color3.fromRGB(138, 43, 226), Thickness = 1, Transparency = 0.4 }, keyGlowFrame)

    local keyHead = Create("Frame", {
        Size = UDim2.new(0, 22, 0, 22),
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 3),
        BackgroundColor3 = Color3.fromRGB(150, 90, 240),
        BorderSizePixel = 0
    }, keyGlowFrame)
    Create("UICorner", { CornerRadius = UDim.new(1, 0) }, keyHead)
    local keyHole = Create("Frame", {
        Size = UDim2.new(0, 9, 0, 9),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(16, 12, 28),
        BorderSizePixel = 0
    }, keyHead)
    Create("UICorner", { CornerRadius = UDim.new(1, 0) }, keyHole)
    Create("Frame", {
        Size = UDim2.new(0, 5, 0, 17),
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 23),
        BackgroundColor3 = Color3.fromRGB(150, 90, 240),
        BorderSizePixel = 0
    }, keyGlowFrame)
    Create("Frame", {
        Size = UDim2.new(0, 8, 0, 4),
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0.5, 3, 0, 28),
        BackgroundColor3 = Color3.fromRGB(150, 90, 240),
        BorderSizePixel = 0
    }, keyGlowFrame)
    Create("Frame", {
        Size = UDim2.new(0, 5, 0, 4),
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0.5, 3, 0, 34),
        BackgroundColor3 = Color3.fromRGB(150, 90, 240),
        BorderSizePixel = 0
    }, keyGlowFrame)

    Create("TextLabel", {
        Text = "Status",
        Font = Enum.Font.GothamMedium,
        TextColor3 = Color3.fromRGB(140, 140, 150),
        TextSize = 9,
        Size = UDim2.new(0, 70, 0, 14),
        Position = UDim2.new(0, 62, 0, 7),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, statusCard)
    local statusBadge = Create("Frame", {
        Size = UDim2.new(0, 65, 0, 14),
        Position = UDim2.new(0, 132, 0, 7),
        BackgroundColor3 = Color3.fromRGB(80, 20, 20),
        BorderSizePixel = 0
    }, statusCard)
    Create("UICorner", { CornerRadius = UDim.new(0, 3) }, statusBadge)
    local statusBadgeText = Create("TextLabel", {
        Text = "Belum Valid",
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(255, 100, 100),
        TextSize = 8,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    }, statusBadge)

    local function addStatusRow(labelText, yPos)
        Create("TextLabel", {
            Text = labelText,
            Font = Enum.Font.GothamMedium,
            TextColor3 = Color3.fromRGB(140, 140, 150),
            TextSize = 9,
            Size = UDim2.new(0, 70, 0, 14),
            Position = UDim2.new(0, 62, 0, yPos),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1
        }, statusCard)
        return Create("TextLabel", {
            Text = "-",
            Font = Enum.Font.GothamMedium,
            TextColor3 = Color3.fromRGB(210, 210, 220),
            TextSize = 9,
            Size = UDim2.new(1, -140, 0, 14),
            Position = UDim2.new(0, 132, 0, yPos),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1
        }, statusCard)
    end

    local typeVal = addStatusRow("Tipe Key", 24)
    local expVal = addStatusRow("Waktu Expired", 41)
    local leftVal = addStatusRow("Sisa Waktu", 58)

    local getKeyCard = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 76),
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BorderSizePixel = 0,
        LayoutOrder = 3
    }, rightCol)
    Create("UICorner", { CornerRadius = UDim.new(0, 6) }, getKeyCard)
    Create("UIStroke", { Color = Color3.fromRGB(45, 45, 55), Thickness = 1, Transparency = 0.4 }, getKeyCard)
    Create("ImageLabel", {
        Image = "http://www.roblox.com/asset/?id=6034824707",
        ImageColor3 = Color3.fromRGB(160, 100, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 8, 0, 6)
    }, getKeyCard)
    Create("TextLabel", {
        Text = "Butuh Key Premium?",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(230, 230, 240),
        Position = UDim2.new(0, 26, 0, 4),
        Size = UDim2.new(1, -30, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, getKeyCard)
    Create("TextLabel", {
        Text = "Dapatkan key premium untuk membuka semua fitur eksklusif dan pengalaman terbaik!",
        Font = Enum.Font.Gotham,
        TextSize = 8,
        TextColor3 = Color3.fromRGB(150, 150, 160),
        Position = UDim2.new(0, 8, 0, 20),
        Size = UDim2.new(1, -16, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        TextWrapped = true
    }, getKeyCard)

    local getKeyBtn = Create("TextButton", {
        Text = "Dapatkan Premium Key",
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = Color3.fromRGB(180, 130, 255),
        Size = UDim2.new(1, -16, 0, 24),
        Position = UDim2.new(0, 8, 0, 44),
        BackgroundColor3 = Color3.fromRGB(28, 15, 48),
        BorderSizePixel = 0
    }, getKeyCard)

    Create("UICorner", { CornerRadius = UDim.new(0, 4) }, getKeyBtn)
    Create("UIStroke", { Color = Color3.fromRGB(138, 43, 226), Thickness = 1, Transparency = 0.6 }, getKeyBtn)
    Create("ImageLabel", {
        Image = "http://www.roblox.com/asset/?id=6031265886",
        ImageColor3 = Color3.fromRGB(180, 130, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0.5, -64, 0.5, -5)
    }, getKeyBtn)

    getKeyBtn.Activated:Connect(function()
        local link = "https://key.shieldteam.asia/"
        local setClp = setclipboard or toclipboard or (syn and syn.write_clipboard)
        if setClp then
            setClp(link)
            Speed_Library:SetNotification({
                Title = "Key System",
                Content = "Link get key berhasil disalin ke clipboard!",
                Time = 0.5,
                Delay = 3
            })
        else
            Speed_Library:SetNotification({
                Title = "Key System",
                Content = "Link: " .. link,
                Time = 0.5,
                Delay = 5
            })
        end
    end)

    local footer = Create("Frame", {
        Name = "Footer",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, -20),
        BackgroundTransparency = 1
    }, PremiumKeyPage)
    Create("ImageLabel", {
        Image = "http://www.roblox.com/asset/?id=6031075929",
        ImageColor3 = Color3.fromRGB(230, 200, 50),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0, 6, 0.5, -5)
    }, footer)
    Create("TextLabel", {
        Text = "Tips: Dapatkan key premium hanya di server resmi ShieldTeam untuk keamanan akun Anda.",
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(140, 140, 150),
        TextSize = 8,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(0.65, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, footer)
    local footerStatus = Create("TextLabel", {
        Text = 'Status: <font color="#ffffff">Free User</font>',
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(140, 140, 150),
        TextSize = 8,
        Position = UDim2.new(0.7, 0, 0, 0),
        Size = UDim2.new(0.3, -6, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1,
        RichText = true
    }, footer)

    local function updateKeyStatus(isValid, info)
        if isValid then
            statusBadge.BackgroundColor3 = Color3.fromRGB(120, 60, 210)
            statusBadgeText.Text = "Valid"
            statusBadgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
            typeVal.Text = "Premium"
            local expStr = "Active"
            local leftStr = "Active"
            if type(info) == "string" then
                leftStr = info
            elseif type(info) == "table" then
                leftStr = info.timeLeft or "Active"
                expStr = info.expiry or "Active"
            end
            expVal.Text = expStr
            leftVal.Text = leftStr
            footerStatus.Text = 'Status: <font color="#A064FF">Premium User</font>'
        else
            statusBadge.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
            statusBadgeText.Text = "Belum Valid"
            statusBadgeText.TextColor3 = Color3.fromRGB(255, 100, 100)
            typeVal.Text = "-"
            expVal.Text = "-"
            leftVal.Text = "-"
            footerStatus.Text = 'Status: <font color="#ffffff">Free User</font>'
        end
    end

    local function updateWindowTitle()
        _G.IsPremium = true
        local function scanContainer(container)
            if not container then
                return
            end
            pcall(function()
                for _, desc in ipairs(container:GetDescendants()) do
                    if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                        local txt = rawget(desc, "Text") or pcall(function() return desc.Text end) and desc.Text
                        if type(txt) == "string" and txt:find("ShieldTeam") then
                            desc.Text = txt:gsub("|| Free ||", "|| Premium ||")
                        end
                    end
                end
            end)
        end
        pcall(function() scanContainer(player:FindFirstChild("PlayerGui")) end)
        pcall(function() scanContainer(CoreGui) end)
        pcall(function() if gethui then scanContainer(gethui()) end end)
    end

    local activeSubTab = "Premium Key System"
    local function switchSubTabUI(tabName)
        activeSubTab = tabName
        if tabName == "Info Event" then
            infoEventBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            infoEventUnderline.Visible = true
            premKeyBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
            premKeyUnderline.Visible = false
            Layers.Visible = true
            LayersRight.Visible = true
            PremiumKeyPage.Visible = false
        else
            infoEventBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
            infoEventUnderline.Visible = false
            premKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            premKeyUnderline.Visible = true
            Layers.Visible = false
            LayersRight.Visible = false
            PremiumKeyPage.Visible = true
        end
    end

    infoEventBtn.Activated:Connect(function() switchSubTabUI("Info Event") end)
    premKeyBtn.Activated:Connect(function() switchSubTabUI("Premium Key System") end)

    local isChecking = false
    validateBtn.Activated:Connect(function()
        if isChecking then
            return
        end
        isChecking = true
        TrackTask(function()
            Speed_Library:SetNotification({
                Title = "Key System",
                Content = "Sedang memverifikasi key, mohon tunggu...",
                Time = 0.5,
                Delay = 3
            })
            local status, msg = validateKey(userKey)
            isChecking = false
            if status then
                _G.Key = userKey
                getgenv().Key = userKey
                saveSavedKey(userKey)
                _G.Config.Key = userKey
                pcall(function() SaveManager:Save() end)
                TabMain:Unlock()
                TabAuto:Unlock()
                TabShop:Unlock()
                TabSetting:Unlock()
                updateKeyStatus(true, msg)
                updateWindowTitle()
                Speed_Library:SetNotification({
                    Title = "Key System",
                    Content = "âœ… Sukses! Semua fitur premium berhasil dibuka.",
                    Time = 0.5,
                    Delay = 5
                })
            else
                updateKeyStatus(false, nil)
                Speed_Library:SetNotification({
                    Title = "Key System",
                    Content = "âŒ Key Invalid/Expired: " .. tostring(msg or "gagal"),
                    Time = 0.5,
                    Delay = 5
                })
            end
        end)
    end)

    local function checkInfoTabState()
        local isInfoVisible = Info.ScrolLayers.Visible
        if isInfoVisible then
            if NameTab then NameTab.Visible = false end
            if NameTabSub then NameTabSub.Visible = false end
            SubTabBar.Visible = true
            if activeSubTab == "Info Event" then
                Layers.Visible = true
                LayersRight.Visible = true
                PremiumKeyPage.Visible = false
            else
                Layers.Visible = false
                LayersRight.Visible = false
                PremiumKeyPage.Visible = true
            end
        else
            SubTabBar.Visible = false
            if NameTab then NameTab.Visible = true end
            if NameTabSub then NameTabSub.Visible = true end
            Layers.Visible = true
            LayersRight.Visible = true
            PremiumKeyPage.Visible = false
        end
    end

    Info.ScrolLayers:GetPropertyChangedSignal("Visible"):Connect(checkInfoTabState)
    task.spawn(checkInfoTabState)

    local autoKeySource = ""
    if (getgenv and getgenv().Key or "") ~= "" then
        autoKeySource = "getgenv"
    elseif (tostring(_G.Key or "")) ~= "" and (tostring(_G.Key or "")) ~= "nil" then
        autoKeySource = "global"
    elseif userKey ~= "" then
        autoKeySource = "saved"
    end

    if userKey ~= "" then
        TrackTask(function()
            task.wait(0.5)
            pcall(function() keyTextBox.Text = userKey end)
            statusBadgeText.Text = "Checking..."
            statusBadge.BackgroundColor3 = Color3.fromRGB(80, 80, 40)
            statusBadgeText.TextColor3 = Color3.fromRGB(255, 220, 100)
            local sourceLabel = (autoKeySource == "getgenv" and "getgenv().Key") or (autoKeySource == "global" and "_G.Key") or "Saved Key"
            Speed_Library:SetNotification({
                Title = "Key System",
                Content = "Mendeteksi " .. sourceLabel .. "... Memverifikasi otomatis.",
                Time = 0.5,
                Delay = 3
            })
            local status, msg = validateKey(userKey)
            if status then
                _G.Key = userKey
                getgenv().Key = userKey
                saveSavedKey(userKey)
                _G.Config.Key = userKey
                pcall(function() SaveManager:Save() end)
                TabMain:Unlock()
                TabAuto:Unlock()
                TabShop:Unlock()
                TabSetting:Unlock()
                updateKeyStatus(true, msg)
                updateWindowTitle()
                Speed_Library:SetNotification({
                    Title = "Key System",
                    Content = "âœ… Auto-Login sukses via " .. sourceLabel .. "! Semua fitur premium dibuka.",
                    Time = 0.5,
                    Delay = 5
                })
            else
                updateKeyStatus(false, nil)
                Speed_Library:SetNotification({
                    Title = "Key System",
                    Content = "âŒ Auto-Login Gagal: Key invalid/expired.",
                    Time = 0.5,
                    Delay = 4
                })
            end
        end)
    else
        updateKeyStatus(false, nil)
    end
end

-- ===========================================
-- WINDOW & TABS SETUP
-- ===========================================
local MainGroup = Window:CreateGroup({ "Main", "rbxassetid://7733960981" })
local MoreGroup = Window:CreateGroup({ "More", "rbxassetid://7733765398" })

local TabInfo = MainGroup:CreateTab({ "Info", "Information & Key" })
local TabMain = MainGroup:CreateTab({ "Main", "Garden automation", Locked = false })
local TabAuto = MainGroup:CreateTab({ "Automaticly", "World automation", Locked = false })
local TabShop = MainGroup:CreateTab({ "Shop", "Auto buy features", Locked = false })
local TabSetting = MoreGroup:CreateTab({ "Setting", "Config & utilities", Locked = false })

local InfoEventSection = TabInfo:AddSection("Information", true, "Left")
InfoEventSection:AddParagraph({ Title = "Garden Auto Farm V2", Content = "Welcome to ShielDTeam Garden V2 Script." })
InfoEventSection:AddParagraph({ Title = "Developer", Content = "ShielD Team" })

createPremiumKeyUI(TabInfo, TabMain, TabAuto, TabShop, TabSetting, Fluent)

local seedList = getSeedList()
local gearList = getGearList()
local harvestOptions = getHarvestOptions()
local petNames = getPetNames()

-- ===========================================
-- UI: AUTO PLANT SECTION
-- ===========================================
local PlantSection = TabMain:AddSection("Auto Plant", true, "Left")

SaveManager:Register("PlantSeed", PlantSection:AddDropdown({
    Title = "Select Seed to Plant",
    Description = "Pilih bibit yang mau ditanam secara otomatis (Bisa pilih banyak)",
    Options = seedList,
    Multi = true,
    Default = {"Carrot"},
    Callback = function(Value)
        _G.Config.PlantSeed = Value
    end
}), "Dropdown")

SaveManager:Register("PlantPosition", PlantSection:AddDropdown({
    Title = "Plant Mode",
    Description = "Pilih mode posisi tanam",
    Options = { "Grid", "Random", "Player" },
    Default = { _G.Config.PlantPosition or "Grid" },
    Callback = function(v)
        _G.Config.PlantPosition = getSelectedValue(v) or "Grid"
    end,
}), "Dropdown")

SaveManager:Register("AutoPlant", PlantSection:AddToggle({
    Title = "Auto Plant Seed",
    Default = false,
    Callback = function(state)
        _G.Config.AutoPlant = state
    end,
}), "Toggle")

-- ===========================================
-- UI: AUTO HARVEST SECTION
-- ===========================================
local HarvestSection = TabMain:AddSection("Auto Harvest", true, "Right")

SaveManager:Register("HarvestSeed", HarvestSection:AddDropdown({
    Title = "Select Seed to Harvest",
    Multi = true,
    Options = harvestOptions,
    Default = _G.Config.HarvestSeed,
    Callback = function(v)
        _G.Config.HarvestSeed = v
    end,
}), "Dropdown")

SaveManager:Register("HarvestSpeed", HarvestSection:AddDropdown({
    Title = "Harvest Speed",
    Options = { "Slow", "Faster", "Super Faster" },
    Default = { _G.Config.HarvestSpeed or "Slow" },
    Callback = function(v)
        _G.Config.HarvestSpeed = getSelectedValue(v) or "Slow"
    end,
}), "Dropdown")

SaveManager:Register("HarvestWeightMax", HarvestSection:AddInput({
    Title = "Max Weight (Harvest)",
    Description = "Hanya panen buah dengan weight <= maksimal ini",
    Default = tostring(_G.Config.HarvestWeightMax or "9999"),
    Callback = function(v)
        _G.Config.HarvestWeightMax = v
    end,
}), "Input")

SaveManager:Register("AutoHarvest", HarvestSection:AddToggle({
    Title = "Auto Harvest",
    Default = _G.Config.AutoHarvest,
    Callback = function(v)
        _G.Config.AutoHarvest = v
    end,
}), "Toggle")

-- ===========================================
-- UI: AUTO SELL SECTION
-- ===========================================
local SellSection = TabMain:AddSection("Auto Sell", true, "Right")

SaveManager:Register("AutoSellMode", SellSection:AddDropdown({
    Title = "Auto Sell Mode",
    Options = { "Delay", "Inventory Full" },
    Default = { _G.Config.AutoSellMode },
    Callback = function(v)
        _G.Config.AutoSellMode = getSelectedValue(v) or "Delay"
    end,
}), "Dropdown")

SaveManager:Register("AutoSellDelay", SellSection:AddSlider({
    Title = "Auto Sell Delay",
    Min = 0.1,
    Max = 5,
    Default = _G.Config.AutoSellDelay,
    Rounding = 1,
    Callback = function(v)
        _G.Config.AutoSellDelay = v
    end,
}), "Slider")

SaveManager:Register("AutoSell", SellSection:AddToggle({
    Title = "Auto Sell",
    Default = _G.Config.AutoSell,
    Callback = function(v)
        _G.Config.AutoSell = v
    end,
}), "Toggle")

-- ===========================================
-- UI: AUTO CLAIM SEED & STEAL SECTION
-- ===========================================
local CollectSection = TabAuto:AddSection("Auto Claim Seed", true, "Left")

SaveManager:Register("ClaimSeedTypes", CollectSection:AddDropdown({
    Title = "Select Seed to Claim",
    Description = "Pilih tipe seed pack yang ingin di-claim",
    Multi = true,
    Options = { "All", "Common Seed Pack", "Uncommon Seed Pack", "Rare Seed Pack", "Gold Seed", "Rainbow Seed", "Mega Seed" },
    Default = _G.Config.ClaimSeedTypes or { "All" },
    Callback = function(v)
        _G.Config.ClaimSeedTypes = v
    end,
}), "Dropdown")

SaveManager:Register("AutoClaimSeed", CollectSection:AddToggle({
    Title = "Auto Claim Seed",
    Default = _G.Config.AutoClaimSeed,
    Callback = function(v)
        _G.Config.AutoClaimSeed = v
    end,
}), "Toggle")

local StealSection = TabAuto:AddSection("Auto Steal (Night Only)", true, "Left")

SaveManager:Register("AutoSteal", StealSection:AddToggle({
    Title = "Auto Steal",
    Default = _G.Config.AutoSteal,
    Callback = function(v)
        _G.Config.AutoSteal = v
    end,
}), "Toggle")

-- ===========================================
-- UI: AUTO SHOVEL SECTION
-- ===========================================
local ShovelSection = TabAuto:AddSection("Auto Shovel", true, "Right")

SaveManager:Register("ShovelSeed", ShovelSection:AddDropdown({
    Title = "Select Plant to Shovel",
    Multi = true,
    Options = harvestOptions,
    Default = _G.Config.ShovelSeed,
    Callback = function(v)
        _G.Config.ShovelSeed = v
    end,
}), "Dropdown")

SaveManager:Register("ShovelWeightMin", ShovelSection:AddInput({
    Title = "Weight Min",
    Default = tostring(_G.Config.ShovelWeightMin),
    Callback = function(v)
        _G.Config.ShovelWeightMin = v
    end,
}), "Input")

SaveManager:Register("ShovelWeightMax", ShovelSection:AddInput({
    Title = "Weight Max",
    Default = tostring(_G.Config.ShovelWeightMax),
    Callback = function(v)
        _G.Config.ShovelWeightMax = v
    end,
}), "Input")

SaveManager:Register("ShovelMutation", ShovelSection:AddDropdown({
    Title = "Mutation Filter",
    Options = MutationList,
    Default = { _G.Config.ShovelMutation or "Any" },
    Callback = function(v)
        _G.Config.ShovelMutation = getSelectedValue(v) or "Any"
    end,
}), "Dropdown")

SaveManager:Register("AutoShovel", ShovelSection:AddToggle({
    Title = "Auto Shovel",
    Default = _G.Config.AutoShovel,
    Callback = function(v)
        _G.Config.AutoShovel = v
    end,
}), "Toggle")

-- ===========================================
-- UI: AUTO WATERING CAN SECTION
-- ===========================================
local WateringCanSection = TabMain:AddSection("Auto Watering Can", true, "Left")

SaveManager:Register("WateringCanName", WateringCanSection:AddDropdown({
    Title = "Select Watering Can",
    Options = getInventoryWateringCans(),
    Default = { _G.Config.WateringCanName or "Any" },
    Callback = function(v)
        _G.Config.WateringCanName = getSelectedValue(v) or "Any"
    end,
}), "Dropdown")

SaveManager:Register("WaterTargetPlants", WateringCanSection:AddDropdown({
    Title = "Select Plants to Water",
    Multi = true,
    Options = harvestOptions,
    Default = _G.Config.WaterTargetPlants,
    Callback = function(v)
        _G.Config.WaterTargetPlants = v
    end,
}), "Dropdown")

SaveManager:Register("AutoWatering", WateringCanSection:AddToggle({
    Title = "Auto Water Plants",
    Default = _G.Config.AutoWatering,
    Callback = function(v)
        _G.Config.AutoWatering = v
    end,
}), "Toggle")

-- ===========================================
-- UI: AUTO SPRINKLER SECTION
-- ===========================================
local SprinklerSection = TabMain:AddSection("Auto Sprinkler", true, "Right")

SaveManager:Register("SprinklerName", SprinklerSection:AddDropdown({
    Title = "Select Sprinkler",
    Options = getInventorySprinklers(),
    Default = { _G.Config.SprinklerName or "Any" },
    Callback = function(v)
        _G.Config.SprinklerName = getSelectedValue(v) or "Any"
    end,
}), "Dropdown")

SaveManager:Register("SprinklerTargetPlants", SprinklerSection:AddDropdown({
    Title = "Select Plants to Sprinkle",
    Multi = true,
    Options = harvestOptions,
    Default = _G.Config.SprinklerTargetPlants,
    Callback = function(v)
        _G.Config.SprinklerTargetPlants = v
    end,
}), "Dropdown")

SaveManager:Register("SprinklerCount", SprinklerSection:AddSlider({
    Title = "Max Sprinklers to Place",
    Min = 1,
    Max = 50,
    Default = _G.Config.SprinklerCount or 10,
    Rounding = 0,
    Callback = function(v)
        _G.Config.SprinklerCount = v
    end,
}), "Slider")

SaveManager:Register("AutoSprinkler", SprinklerSection:AddToggle({
    Title = "Auto Place Sprinklers",
    Default = _G.Config.AutoSprinkler,
    Callback = function(v)
        _G.Config.AutoSprinkler = v
    end,
}), "Toggle")

-- ===========================================
-- UI: AUTO FAVORITE SECTION
-- ===========================================
local FavoriteSection = TabMain:AddSection("Auto Favorite", true, "Left")

SaveManager:Register("FavoriteFruits", FavoriteSection:AddDropdown({
    Title = "Whitelist Fruits",
    Multi = true,
    Options = harvestOptions,
    Default = _G.Config.FavoriteFruits,
    Callback = function(v) _G.Config.FavoriteFruits = v end,
}), "Dropdown")

SaveManager:Register("FavoriteMutations", FavoriteSection:AddDropdown({
    Title = "Whitelist Mutations",
    Multi = true,
    Options = MutationList,
    Default = _G.Config.FavoriteMutations,
    Callback = function(v) _G.Config.FavoriteMutations = v end,
}), "Dropdown")

SaveManager:Register("FavoriteType", FavoriteSection:AddDropdown({
    Title = "Favorite Type",
    Options = { "None", "Max Value", "Max Size" },
    Default = { _G.Config.FavoriteType or "None" },
    Callback = function(v) _G.Config.FavoriteType = getSelectedValue(v) or "None" end,
}), "Dropdown")

SaveManager:Register("AutoFavorite", FavoriteSection:AddToggle({
    Title = "Auto Favorite",
    Default = _G.Config.AutoFavorite,
    Callback = function(v) _G.Config.AutoFavorite = v end,
}), "Toggle")

-- ===========================================
-- UI: AUTO BUY SHOP & PET SECTION
-- ===========================================
local ShopSection = TabShop:AddSection("Auto Buy Shop", true, "Left")

SaveManager:Register("BuySeeds", ShopSection:AddDropdown({
    Title = "Seeds to Buy",
    Multi = true,
    Options = seedList,
    Default = _G.Config.BuySeeds,
    Callback = function(v)
        _G.Config.BuySeeds = v
    end,
}), "Dropdown")

SaveManager:Register("BuyGears", ShopSection:AddDropdown({
    Title = "Gears to Buy",
    Multi = true,
    Options = gearList,
    Default = _G.Config.BuyGears,
    Callback = function(v)
        _G.Config.BuyGears = v
    end,
}), "Dropdown")

SaveManager:Register("AutoBuySeed", ShopSection:AddToggle({
    Title = "Auto Buy Seed",
    Default = _G.Config.AutoBuySeed,
    Callback = function(v)
        _G.Config.AutoBuySeed = v
    end,
}), "Toggle")

SaveManager:Register("AutoBuyGear", ShopSection:AddToggle({
    Title = "Auto Buy Gears",
    Default = _G.Config.AutoBuyGear,
    Callback = function(v)
        _G.Config.AutoBuyGear = v
    end,
}), "Toggle")

local PetBuySection = TabShop:AddSection("Auto Buy Pet", true, "Right")

SaveManager:Register("PetBuyPet", PetBuySection:AddDropdown({
    Title = "Target Pet",
    Options = petNames,
    Multi = true,
    Default = _G.Config.PetBuyPet or {},
    Callback = function(v)
        _G.Config.PetBuyPet = v
        SaveManager:Save()
    end,
}), "Dropdown")

SaveManager:Register("AutoBuyPet", PetBuySection:AddToggle({
    Title = "Auto Buy Pet",
    Default = _G.Config.AutoBuyPet,
    Callback = function(v)
        _G.Config.AutoBuyPet = v
    end,
}), "Toggle")

PetBuySection:AddParagraph({
    Title = "Status",
    Content = "Status: Waiting for remote...",
})

-- ===========================================
-- UI: PET FINDER & SERVER HOP SECTION
-- ===========================================
local PetFinderSection = TabAuto:AddSection("Pet Finder + Server Hop", true, "Left")

local PetFinderToggle = PetFinderSection:AddToggle({
    Title = "Enable Pet Finder",
    Default = _G.Config.PetFinderEnabled,
    Callback = function(v)
        _G.Config.PetFinderEnabled = v
        SaveManager:Save()
    end,
})
SaveManager:Register("PetFinderEnabled", PetFinderToggle, "Toggle")

local petFinderNames = { "Any" }
for _, name in ipairs(petNames) do
    table.insert(petFinderNames, name)
end

SaveManager:Register("PetTargetName", PetFinderSection:AddDropdown({
    Title = "Specific Pet Name",
    Options = petFinderNames,
    Multi = true,
    Default = _G.Config.PetTargetName or { "Any" },
    Callback = function(v)
        _G.Config.PetTargetName = v
        SaveManager:Save()
    end,
}), "Dropdown")

local PetStatusLabel = PetFinderSection:AddParagraph({
    Title = "Status",
    Content = "Status: Idle",
})

local ServerHopToggle
ServerHopToggle = PetFinderSection:AddToggle({
    Title = "Start Server Hop",
    Default = _G.Config.ServerHop,
    Callback = function(v)
        _G.Config.ServerHop = v
        if v then
            _G.Config.PetFinderEnabled = true
            if PetFinderToggle then
                PetFinderToggle:Set(true, true)
            end
        else
            updateParagraph(PetStatusLabel, "Status", "Status: Idle")
        end
        SaveManager:Save()
    end,
})
SaveManager:Register("ServerHop", ServerHopToggle, "Toggle")

PetFinderSection:AddButton({
    Title = "Stop Server Hop",
    Callback = function()
        _G.Config.ServerHop = false
        if ServerHopToggle then
            ServerHopToggle:Set(false, true)
        end
        updateParagraph(PetStatusLabel, "Status", "Status: Idle")
    end,
})

-- ===========================================
-- UI: ESP SECTION
-- ===========================================
local ESPSection = TabAuto:AddSection("ESP", true, "Right")

local function clearESP()
    for _, obj in pairs(_G.ShieldTeam_Resources.ESPObjects) do
        pcall(function()
            if obj.Gui then
                obj.Gui:Destroy()
            end
            if obj.Highlight then
                obj.Highlight:Destroy()
            end
        end)
    end
    table.clear(_G.ShieldTeam_Resources.ESPObjects)
end

local function createESP(target, text, color)
    if not target or _G.ShieldTeam_Resources.ESPObjects[target] then
        return
    end
    local part = target:IsA("BasePart") and target or target:FindFirstChildWhichIsA("BasePart", true)
    if not part then
        return
    end
    local entry = {}
    if _G.Config.ESPStyle == "Box" or _G.Config.ESPStyle == "Both" then
        local hl = Instance.new("Highlight")
        hl.FillTransparency = 0.7
        hl.OutlineColor = color
        hl.Adornee = target
        hl.Parent = target
        entry.Highlight = hl
    end
    if _G.Config.ESPStyle == "Name" or _G.Config.ESPStyle == "Both" or _G.Config.ShowSellPrice then
        local bb = Instance.new("BillboardGui")
        bb.Name = "ShieldESP"
        bb.Adornee = part
        bb.AlwaysOnTop = true
        bb.Size = UDim2.fromOffset(250, 50)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.Parent = target
        
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.fromScale(1, 1)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextScaled = true
        lbl.TextColor3 = color
        lbl.TextStrokeTransparency = 0.5
        lbl.Text = text
        lbl.Parent = bb
        entry.Gui = bb
    end
    _G.ShieldTeam_Resources.ESPObjects[target] = entry
end

SaveManager:Register("ESPMaster", ESPSection:AddToggle({
    Title = "ESP Master",
    Default = _G.Config.ESPMaster,
    Callback = function(v)
        _G.Config.ESPMaster = v
        if not v then
            clearESP()
        end
    end,
}), "Toggle")

SaveManager:Register("ESPPet", ESPSection:AddToggle({
    Title = "ESP Pet",
    Default = _G.Config.ESPPet,
    Callback = function(v)
        _G.Config.ESPPet = v
    end,
}), "Toggle")

SaveManager:Register("ESPFruit", ESPSection:AddToggle({
    Title = "ESP Fruit",
    Default = _G.Config.ESPFruit,
    Callback = function(v)
        _G.Config.ESPFruit = v
    end,
}), "Toggle")

SaveManager:Register("ShowSellPrice", ESPSection:AddToggle({
    Title = "Show Sell Price",
    Default = _G.Config.ShowSellPrice,
    Callback = function(v)
        _G.Config.ShowSellPrice = v
    end,
}), "Toggle")

SaveManager:Register("ESPStyle", ESPSection:AddDropdown({
    Title = "ESP Style",
    Options = { "Box", "Name", "Both" },
    Default = { _G.Config.ESPStyle },
    Callback = function(v)
        _G.Config.ESPStyle = getSelectedValue(v) or "Both"
        clearESP()
    end,
}), "Dropdown")

SaveManager:Register("ESPMaxDistance", ESPSection:AddSlider({
    Title = "Max Distance",
    Min = 1000,
    Max = 10000,
    Default = _G.Config.ESPMaxDistance,
    Rounding = 0,
    Callback = function(v)
        _G.Config.ESPMaxDistance = v
    end,
}), "Slider")

-- ===========================================
-- UI: SETTINGS & DEBUG SECTION
-- ===========================================
local SettingSection = TabSetting:AddSection("Settings", true, "Left")

SaveManager:Register("AntiAFK", SettingSection:AddToggle({
    Title = "Anti AFK",
    Default = _G.Config.AntiAFK,
    Callback = function(v)
        _G.Config.AntiAFK = v
    end,
}), "Toggle")

SaveManager:Register("AutoRejoin", SettingSection:AddToggle({
    Title = "Auto Rejoin if Kicked",
    Default = _G.Config.AutoRejoin,
    Callback = function(v)
        _G.Config.AutoRejoin = v
    end,
}), "Toggle")

SaveManager:Register("AntiFlashbang", SettingSection:AddToggle({
    Title = "Anti Flashbang",
    Default = _G.Config.AntiFlashbang,
    Callback = function(v)
        _G.Config.AntiFlashbang = v
        if v then
            applyAntiFlashbang()
        end
    end,
}), "Toggle")

SaveManager:Register("DebugMode", SettingSection:AddToggle({
    Title = "Debug Mode",
    Default = _G.Config.DebugMode,
    Callback = function(v)
        _G.Config.DebugMode = v
    end,
}), "Toggle")

local DebugSection = TabSetting:AddSection("Debug Tools", true, "Right")

DebugSection:AddButton({
    Title = "Refresh Remotes",
    Callback = function()
        ScanRemotes()
        refreshNetworking()
        Fluent:Notify({
            Title = "Remotes Refreshed",
            Content = "Found " .. tostring(#_G.Remotes) .. " remotes.",
            Duration = 4,
        })
    end,
})

DebugSection:AddButton({
    Title = "Detect Game Structure",
    Callback = function()
        AutoDetectGameStructure()
    end,
})

SaveManager:BuildConfigSection(TabSetting)
InterfaceManager:BuildInterfaceSection(TabSetting)
SaveManager:Apply()

-- ===========================================
-- TASKS: HARVEST, SELL & CLAIM SEED LOGIC
-- ===========================================
local harvestedSet = {}
local isHarvesting = false
local pendingHarvestDebounce = false

local function isOwnedByLocalPlayer(prompt)
    local part  = prompt.Parent
    local model = part and part:FindFirstAncestorWhichIsA("Model")
    if not model then return false end

    local plotId = player:GetAttribute("PlotId")
    if plotId then
        local gardens = workspace:FindFirstChild("Gardens")
        local plot = gardens and gardens:FindFirstChild("Plot" .. tostring(plotId))
        if plot and model:IsDescendantOf(plot) then
            return true
        end
    end

    for _, plot in ipairs(getOwnedPlots()) do
        if model:IsDescendantOf(plot) then
            return true
        end
    end

    return false
end

local function harvestPlant(prompt)
    if harvestedSet[prompt] then return end
    if not prompt.Enabled or prompt:GetAttribute("Collected") then return end

    local part = prompt.Parent
    if not (part and part:IsA("BasePart")) then return end
    local model = part:FindFirstAncestorWhichIsA("Model")
    if not model or not isOwnedByLocalPlayer(prompt) then return end

    local coreName = model:GetAttribute("CorePartName")
    local seedName = model:GetAttribute("SeedName")
    local fruitName = (type(coreName) == "string" and coreName ~= "" and coreName)
                   or (type(seedName) == "string" and seedName ~= "" and seedName)
                   or model.Name

    if not listContains(_G.Config.HarvestSeed, fruitName) then return end

    local weight = model:GetAttribute("Weight")
    if type(weight) == "number" then
        local maxW = tonumber(_G.Config.HarvestWeightMax) or 9999
        if weight > maxW then return end
    end

    local plantId = model:GetAttribute("PlantId")
    local fruitId = model:GetAttribute("FruitId") or ""
    if not plantId then return end

    harvestedSet[prompt] = true
    pcall(function()
        if not Networking then refreshNetworking() end
        Networking.Garden.CollectFruit:Fire(plantId, fruitId)
    end)
    task.delay(0.5, function()
        harvestedSet[prompt] = nil
    end)
end

local function harvestAll()
    if isHarvesting then return end
    isHarvesting = true
    for _, prompt in ipairs(CollectionService:GetTagged("HarvestPrompt")) do
        if not _G.Config.AutoHarvest or _G.ShieldTeam_ScriptId ~= scriptId then break end
        if prompt:IsDescendantOf(workspace) then
            harvestPlant(prompt)
            task.wait(SpeedMap[_G.Config.HarvestSpeed] or 0.05)
        end
    end
    isHarvesting = false
end

TrackTask(function()
    while _G.ShieldTeam_ScriptId == scriptId do
        if _G.Config.AutoHarvest then
            pcall(harvestAll)
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

local function scheduleHarvest()
    if pendingHarvestDebounce then return end
    pendingHarvestDebounce = true
    task.delay(0.016, function()
        pendingHarvestDebounce = false
        if _G.Config.AutoHarvest and _G.ShieldTeam_ScriptId == scriptId then
            TrackTask(function()
                pcall(harvestAll)
            end)
        end
    end)
end

TrackConnection(CollectionService:GetInstanceAddedSignal("HarvestPrompt"):Connect(function(prompt)
    if not _G.Config.AutoHarvest or _G.ShieldTeam_ScriptId ~= scriptId then return end
    if not prompt:IsDescendantOf(workspace) then return end
    scheduleHarvest()
end))

TrackTask(function()
    local lastSell = 0
    while _G.ShieldTeam_ScriptId == scriptId do
        if _G.Config.AutoSell then
            pcall(function()
                if not Networking then
                    refreshNetworking()
                end
                if _G.Config.AutoSellMode == "Delay" then
                    if tick() - lastSell >= _G.Config.AutoSellDelay then
                        pcall(function()
                            if Networking and Networking.NPCS and Networking.NPCS.SellAll then
                                Networking.NPCS.SellAll:Fire()
                            end
                        end)
                        lastSell = tick()
                    end
                elseif _G.Config.AutoSellMode == "Inventory Full" then
                    if tick() - lastSell >= 2 then
                        if isInventoryFull() then
                            pcall(function()
                                if Networking and Networking.NPCS and Networking.NPCS.SellAll then
                                    Networking.NPCS.SellAll:Fire()
                                end
                            end)
                            lastSell = tick()
                        end
                    end
                end
            end)
            task.wait(0.25)
        else
            task.wait(0.5)
        end
    end
end)

local seedSpawnFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SeedPackSpawnServerLocations")
local isClaimingSeed = false

local function getSeedPackName(part)
    if part:GetAttribute("RainbowSeed") then
        return "Rainbow Seed"
    end
    if part:GetAttribute("GoldSeed") then
        return "Gold Seed"
    end
    if part:GetAttribute("MegaSeed") then
        return "Mega Seed"
    end
    local sp = part:GetAttribute("SeedPack")
    if sp then
        return sp
    end
    return nil
end

local function claimSeedPart(part)
    if isClaimingSeed then
        return
    end
    isClaimingSeed = true
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        isClaimingSeed = false
        return
    end
    local origPos = hrp.CFrame
    local targetPos = part.CFrame * CFrame.new(0, 3, 0)
    hrp.CFrame = targetPos
    task.wait(0.1)
    local prompt = part:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
    local timeout = tick() + 1
    while part.Parent and tick() < timeout do
        task.wait()
    end
    if char and hrp and hrp.Parent then
        hrp.CFrame = origPos
    end
    isClaimingSeed = false
end

TrackTask(function()
    while _G.ShieldTeam_ScriptId == scriptId do
        if _G.Config.AutoClaimSeed and seedSpawnFolder then
            pcall(function()
                if not isClaimingSeed then
                    for _, part in ipairs(seedSpawnFolder:GetChildren()) do
                        if not _G.Config.AutoClaimSeed or _G.ShieldTeam_ScriptId ~= scriptId then
                            break
                        end
                        local name = getSeedPackName(part)
                        if name then
                            local selectedTypes = _G.Config.ClaimSeedTypes or {}
                            local isAllSelected = false
                            local isSpecificSelected = false
                            for _, v in ipairs(selectedTypes) do
                                if v == "All" then
                                    isAllSelected = true
                                end
                                if v == name then
                                    isSpecificSelected = true
                                end
                            end
                            if isAllSelected or isSpecificSelected then
                                TrackTask(function()
                                    claimSeedPart(part)
                                end)
                                break
                            end
                        end
                    end
                end
            end)
            task.wait(0.15)
        else
            task.wait(0.5)
        end
    end
end)

-- ===========================================
-- TASKS: AUTO STEAL LOGIC
-- ===========================================
local StealFlags = nil
pcall(function()
    StealFlags = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Flags"):WaitForChild("StealFlags"))
end)

local function isNightTime()
    local nightObj = ReplicatedStorage:FindFirstChild("Night")
    return nightObj and nightObj.Value == true
end

TrackTask(function()
    while _G.ShieldTeam_ScriptId == scriptId do
        if _G.Config.AutoSteal then
            pcall(function()
                if not isNightTime() then
                    task.wait(1)
                    return
                end
                if not Networking then
                    refreshNetworking()
                end
                local prompts = CollectionService:GetTagged("StealPrompt")
                for _, prompt in ipairs(prompts) do
                    if not _G.Config.AutoSteal or _G.ShieldTeam_ScriptId ~= scriptId then
                        break
                    end
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled and not prompt:GetAttribute("Collected") then
                        local plantModel = prompt.Parent and prompt.Parent:FindFirstAncestorWhichIsA("Model")
                        if not plantModel then
                            continue
                        end
                        local plantName = plantModel:GetAttribute("SeedName") or plantModel:GetAttribute("CorePartName") or plantModel.Name
                        local canSteal = true
                        if StealFlags and StealFlags.IsPlantStealable then
                            canSteal = StealFlags.IsPlantStealable(plantName)
                        end
                        if not canSteal then
                            continue
                        end
                        local targetUserId = tonumber(plantModel:GetAttribute("UserId"))
                        local plantId = plantModel:GetAttribute("PlantId")
                        local fruitId = plantModel:GetAttribute("FruitId") or ""
                        if not (targetUserId and plantId) then
                            continue
                        end
                        local hrp = getHRP()
                        local plantPart = plantModel.PrimaryPart or plantModel:FindFirstChildWhichIsA("BasePart", true)
                        if hrp and plantPart then
                            local dist = (hrp.Position - plantPart.Position).Magnitude
                            if dist > 15 then
                                hrp.CFrame = CFrame.new(plantPart.Position + Vector3.new(0, 0, -4))
                                task.wait(0.2)
                            end
                        end
                        dbg(string.format("[AutoSteal] Stealing %s (Night Active)...", plantName))
                        if Networking and Networking.Steal then
                            pcall(function()
                                Networking.Steal.BeginSteal:Fire(targetUserId, plantId, fruitId)
                                local holdTime = prompt.HoldDuration or 0
                                if holdTime > 0 then
                                    task.wait(holdTime + 0.05)
                                else
                                    task.wait(0.1)
                                end
                                Networking.Steal.CompleteSteal:Fire()
                            end)
                        else
                            local p = findPrompt(plantModel)
                            if p then
                                pcall(function()
                                    fireproximityprompt(p, p.HoldDuration)
                                end)
                            end
                        end
                        task.wait(0.3)
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(0.5)
        end
    end
end)

-- ===========================================
-- TASKS: AUTO WATERING CAN LOGIC
-- ===========================================
TrackTask(function()
    while _G.ShieldTeam_ScriptId == scriptId do
        if _G.Config.AutoWatering then
            pcall(function()
                if not Networking then
                    refreshNetworking()
                end
                local targetCan = _G.Config.WateringCanName or "Any"
                local tool = nil
                local function searchCan(container)
                    if not container then
                        return nil
                    end
                    for _, t in ipairs(container:GetChildren()) do
                        if t:IsA("Tool") and t:GetAttribute("WateringCan") then
                            if targetCan == "Any" or t:GetAttribute("WateringCan") == targetCan then
                                return t
                            end
                        end
                    end
                    return nil
                end
                local char = player.Character
                local bp = player:FindFirstChild("Backpack")
                tool = searchCan(char) or searchCan(bp)
                if tool then
                    if equipSpecificTool(tool) then
                        for _, plot in ipairs(getOwnedPlots()) do
                            local plantsFolder = plot:FindFirstChild("Plants")
                            if plantsFolder then
                                for _, plant in ipairs(plantsFolder:GetChildren()) do
                                    if not _G.Config.AutoWatering or _G.ShieldTeam_ScriptId ~= scriptId then
                                        break
                                    end
                                    if plant:IsA("Model") then
                                        local plantName = plant:GetAttribute("SeedName") or plant:GetAttribute("CorePartName") or plant.Name
                                        if listContains(_G.Config.WaterTargetPlants, plantName) then
                                            local part = plant.PrimaryPart or plant:FindFirstChildWhichIsA("BasePart", true)
                                            if part then
                                                Networking.WateringCan.UseWateringCan:Fire(
                                                    part.Position - Vector3.new(0, 0.3, 0),
                                                    tool:GetAttribute("WateringCan"),
                                                    tool
                                                )
                                                task.wait(0.6)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum:UnequipTools()
                        end
                    end
                end
            end)
            task.wait(2)
        else
            task.wait(0.5)
        end
    end
end)

-- ===========================================
-- TASKS: AUTO FAVORITE LOGIC
-- ===========================================
local FavSellValueData, FavMutationData = nil, nil
pcall(function() FavSellValueData = require(ReplicatedStorage.SharedModules.SellValueData) end)
pcall(function() FavMutationData = require(ReplicatedStorage.SharedModules.MutationData) end)

local function favSelectionSet(raw)
    local set = {}
    if type(raw) == "table" then
        for k, v in pairs(raw) do
            if type(k) == "string" and v == true then set[k] = true
            elseif type(v) == "string" then set[v] = true end
        end
    end
    return set
end

local function favSplitMutStr(raw)
    if type(raw) ~= "string" or raw == "" then return {} end
    local list = {}
    for part in raw:gmatch("[^%+%,]+") do
        local s = part:match("^%s*(.-)%s*$")
        if s ~= "" then table.insert(list, s) end
    end
    return list
end

local function favoritePassesFilter(tool, fruitSet, mutSet)
    local fruitName = tool:GetAttribute("FruitName") or tool:GetAttribute("Fruit")
    if not fruitName then return false end

    local hasFruits, hasMuts = next(fruitSet) ~= nil, next(mutSet) ~= nil
    if not hasFruits and not hasMuts then return false end

    local fruitMatch = hasFruits and fruitSet[fruitName] == true
    local mutMatch = false
    for _, m in ipairs(favSplitMutStr(tool:GetAttribute("Mutation") or "")) do
        if mutSet[m] then mutMatch = true break end
    end

    if hasFruits and not hasMuts then return fruitMatch
    elseif not hasFruits and hasMuts then return mutMatch
    else return fruitMatch or mutMatch end
end

local function favoriteToolValue(tool)
    local name = tool:GetAttribute("FruitName") or tool:GetAttribute("Fruit")
    if not name or not FavSellValueData then return 0 end
    local sizeMulti = tool:GetAttribute("SizeMulti") or tool:GetAttribute("SizeMultiplier") or 1
    local mutation = tool:GetAttribute("Mutation")
    local mult = 1
    if mutation and mutation ~= "" and FavMutationData and FavMutationData.ReturnPriceMultiplier then
        mult = FavMutationData.ReturnPriceMultiplier(mutation) or 1
    end
    return math.floor((FavSellValueData[name] or 0) * (sizeMulti ^ 3) * mult)
end

local function setFruitFavorite(tool, isFav)
    local id = tool:GetAttribute("Id")
    if not id then return end
    tool:SetAttribute("IsFavorite", if isFav then true else nil)
    pcall(function() Networking.Backpack.SetFruitFavorite:Fire(id, isFav) end)
end

local function getFavoriteCandidates()
    local tools = {}
    local char, bp = player.Character, player:FindFirstChild("Backpack")
    if char then
        local equipped = char:FindFirstChildOfClass("Tool")
        if equipped and equipped:GetAttribute("FruitName") then table.insert(tools, equipped) end
    end
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("FruitName") then table.insert(tools, tool) end
        end
    end
    return tools
end

local function runAutoFavoriteScan()
    if not Networking then refreshNetworking() end
    local fruitSet = favSelectionSet(_G.Config.FavoriteFruits)
    local mutSet = favSelectionSet(_G.Config.FavoriteMutations)
    local favType = _G.Config.FavoriteType or "None"
    local tools = getFavoriteCandidates()

    local bestValue, bestTools = 0, {}
    if favType ~= "None" then
        for _, tool in ipairs(tools) do
            local val = favType == "Max Value" and favoriteToolValue(tool) or (tool:GetAttribute("Weight") or 0)
            if val > bestValue then
                bestValue, bestTools = val, { tool }
            elseif val == bestValue and val > 0 then
                table.insert(bestTools, tool)
            end
        end
    end

    for _, tool in ipairs(tools) do
        if not _G.Config.AutoFavorite or _G.ShieldTeam_ScriptId ~= scriptId then break end
        if not (tool and tool.Parent) then continue end

        local shouldFav = favoritePassesFilter(tool, fruitSet, mutSet)
        if favType ~= "None" and bestValue > 0 then
            for _, bTool in ipairs(bestTools) do
                if bTool == tool then shouldFav = true break end
            end
        end

        if shouldFav and tool:GetAttribute("IsFavorite") ~= true then
            setFruitFavorite(tool, true)
            task.wait(0.1)
        end
    end
end

TrackTask(function()
    while _G.ShieldTeam_ScriptId == scriptId do
        if _G.Config.AutoFavorite then
            pcall(runAutoFavoriteScan)
            task.wait(60)
        else
            task.wait(0.5)
        end
    end
end)

TrackConnection(player:WaitForChild("Backpack").ChildAdded:Connect(function(tool)
    if not _G.Config.AutoFavorite or _G.ShieldTeam_ScriptId ~= scriptId then return end
    if not (tool:IsA("Tool") and tool:GetAttribute("FruitName")) then return end
    task.wait(0.05)
    pcall(runAutoFavoriteScan)
end))

-- ===========================================
-- TASKS: AUTO SPRINKLER LOGIC
-- ===========================================
local SPRINKLER_RADIUS = {}
pcall(function()
    local SprinklerData = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("SprinklerData"))
    for _, entry in ipairs(SprinklerData) do
        if type(entry) == "table" and entry.SprinklerName then
            SPRINKLER_RADIUS[entry.SprinklerName] = entry.Radius or 8
        end
    end
end)

TrackTask(function()
    while _G.ShieldTeam_ScriptId == scriptId do
        if _G.Config.AutoSprinkler then
            pcall(function()
                if not Networking then
                    refreshNetworking()
                end
                local targetSpr = _G.Config.SprinklerName or "Any"
                local maxPlace = tonumber(_G.Config.SprinklerCount) or 10
                local bestTool, bestName, bestRadius = nil, nil, 0
                local function checkTool(t)
                    local sName = t:GetAttribute("Sprinkler")
                    if not sName then
                        return
                    end
                    if targetSpr ~= "Any" and sName ~= targetSpr then
                        return
                    end
                    local radius = SPRINKLER_RADIUS[sName] or 8
                    if not bestTool or radius > bestRadius then
                        bestTool, bestName, bestRadius = t, sName, radius
                    end
                end
                local char = player.Character
                local bp = player:FindFirstChild("Backpack")
                if char then
                    for _, t in ipairs(char:GetChildren()) do
                        if t:IsA("Tool") then
                            checkTool(t)
                        end
                    end
                end
                if bp then
                    for _, t in ipairs(bp:GetChildren()) do
                        if t:IsA("Tool") then
                            checkTool(t)
                        end
                    end
                end
                if bestTool then
                    if equipSpecificTool(bestTool) then
                        local plotId = player:GetAttribute("PlotId")
                        if plotId then
                            local plot = workspace:FindFirstChild("Gardens") and workspace.Gardens:FindFirstChild("Plot" .. tostring(plotId))
                            if plot then
                                local plantsFolder = plot:FindFirstChild("Plants")
                                if plantsFolder then
                                    local targets = {}
                                    for _, plant in ipairs(plantsFolder:GetChildren()) do
                                        if plant:IsA("Model") then
                                            local plantName = plant:GetAttribute("SeedName") or plant:GetAttribute("CorePartName") or plant.Name
                                            if listContains(_G.Config.SprinklerTargetPlants, plantName) then
                                                local ppart = plant.PrimaryPart or plant:FindFirstChildWhichIsA("BasePart")
                                                if ppart then
                                                    table.insert(targets, ppart.Position)
                                                end
                                            end
                                        end
                                    end
                                    local placed = 0
                                    local covered = {}
                                    for i, pos in ipairs(targets) do
                                        if not _G.Config.AutoSprinkler or placed >= maxPlace then
                                            break
                                        end
                                        if not covered[i] then
                                            local clusterX, clusterZ, clusterCount = pos.X, pos.Z, 1
                                            local inCluster = { i }
                                            for j = i + 1, #targets do
                                                if not covered[j] then
                                                    local d = (Vector3.new(targets[j].X, 0, targets[j].Z) - Vector3.new(pos.X, 0, pos.Z)).Magnitude
                                                    if d <= bestRadius * 1.5 then
                                                        clusterX = clusterX + targets[j].X
                                                        clusterZ = clusterZ + targets[j].Z
                                                        clusterCount = clusterCount + 1
                                                        table.insert(inCluster, j)
                                                    end
                                                end
                                            end
                                            clusterX = clusterX / clusterCount
                                            clusterZ = clusterZ / clusterCount
                                            local sprPos = Vector3.new(clusterX, pos.Y + 20, clusterZ)
                                            local areaParts = {}
                                            for _, part in ipairs(CollectionService:GetTagged("PlantArea")) do
                                                if part:IsDescendantOf(plot) then
                                                    table.insert(areaParts, part)
                                                end
                                            end
                                            local rcParams = RaycastParams.new()
                                            rcParams.FilterType = Enum.RaycastFilterType.Include
                                            rcParams.FilterDescendantsInstances = areaParts
                                            local hit = workspace:Raycast(sprPos, Vector3.new(0, -40, 0), rcParams)
                                            if hit and hit.Instance then
                                                local tooClose = false
                                                local sprFolder = plot:FindFirstChild("Sprinklers")
                                                if sprFolder then
                                                    for _, model in ipairs(sprFolder:GetChildren()) do
                                                        if model:IsA("Model") and model.PrimaryPart then
                                                            local d = (Vector3.new(model.PrimaryPart.Position.X, 0, model.PrimaryPart.Position.Z) - Vector3.new(hit.Position.X, 0, hit.Position.Z)).Magnitude
                                                            if d < 2 then
                                                                tooClose = true
                                                                break
                                                            end
                                                        end
                                                    end
                                                end
                                                if not tooClose then
                                                    Networking.Place.PlaceSprinkler:Fire(hit.Position, bestName, bestTool, plotId)
                                                    placed = placed + 1
                                                    for _, idx in ipairs(inCluster) do
                                                        covered[idx] = true
                                                    end
                                                    task.wait(0.6)
                                                end
                                            end
                                        end
                                    end
                                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                                    if hum then
                                        hum:UnequipTools()
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(5)
        else
            task.wait(0.5)
        end
    end
end)

-- ===========================================
-- TASKS: AUTO BUY SHOP LOGIC
-- ===========================================
local function getGuiStockAndCost(itemName, itemType)
    -- Fallback to cached costs to prevent nil errors
    return 1, _G.CachedCosts[itemName] or 999999
end

TrackTask(function()
    while _G.ShieldTeam_ScriptId == scriptId do
        if _G.Config.AutoBuySeed or _G.Config.AutoBuyGear then
            pcall(function()
                if _G.Config.AutoBuySeed and #_G.Config.BuySeeds > 0 then
                    for _, seedName in ipairs(_G.Config.BuySeeds) do
                        if _G.ShieldTeam_ScriptId ~= scriptId then
                            break
                        end
                        local stock, cost = getGuiStockAndCost(seedName, "seed")
                        while stock and stock > 0 and getMoney() >= cost and _G.ShieldTeam_ScriptId == scriptId do
                            buyShopItem("seed", seedName)
                            stock = stock - 1
                            task.wait(0.05)
                        end
                    end
                end
                if _G.Config.AutoBuyGear and #_G.Config.BuyGears > 0 then
                    for _, gearName in ipairs(_G.Config.BuyGears) do
                        if _G.ShieldTeam_ScriptId ~= scriptId then
                            break
                        end
                        local stock, cost = getGuiStockAndCost(gearName, "gear")
                        while stock and stock > 0 and getMoney() >= cost and _G.ShieldTeam_ScriptId == scriptId do
                            buyShopItem("gear", gearName)
                            stock = stock - 1
                            task.wait(0.05)
                        end
                    end
                end
            end)
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

-- ===========================================
-- TASKS: AUTO PLANT LOGIC
-- ===========================================
local PLANT_FIRE_INTERVAL = 0.12
local SLOT_RECHECK_DELAY  = 2.5
local EMPTY_RETRY_DELAY   = 1.0
local RAYCAST_DOWN        = 60
local SPACING             = 4

local plantSlotCache = {}
local plantSlotsDirty = true
local plantAreaParams = nil
local lastPlantPlotId = nil

local function isPlantOccupied(pos, Plants)
    if not Plants then return false end
    for _, child in ipairs(Plants:GetChildren()) do
        local pivot = nil
        if child:IsA("Model") then
            pivot = child:GetPivot().Position
        elseif child:IsA("BasePart") then
            pivot = child.Position
        end
        if pivot then
            if math.abs(pivot.X - pos.X) < 2 and math.abs(pivot.Z - pos.Z) < 2 then
                return true
            end
        end
    end
    return false
end

local function getPlantAreaParams(plot)
    local id = tostring(player:GetAttribute("PlotId") or "")
    if id ~= tostring(lastPlantPlotId or "") or not plantAreaParams then
        lastPlantPlotId = id
        local areas = {}
        for _, part in ipairs(CollectionService:GetTagged("PlantArea")) do
            if plot and part:IsDescendantOf(plot) then
                table.insert(areas, part)
            end
        end
        plantAreaParams = RaycastParams.new()
        plantAreaParams.FilterType = Enum.RaycastFilterType.Include
        plantAreaParams.FilterDescendantsInstances = areas
    end
    return plantAreaParams
end

local function resolveGround(pos, params, plot)
    local origin = Vector3.new(pos.X, pos.Y + 20, pos.Z)
    local result = workspace:Raycast(origin, Vector3.new(0, -RAYCAST_DOWN, 0), params)
    if not result then return nil end
    if plot and not result.Instance:IsDescendantOf(plot) then return nil end
    return result.Position
end

local function buildPlantSlots(plot)
    local params = getPlantAreaParams(plot)
    local Plants = plot:FindFirstChild("Plants")
    local areas  = {}
    for _, part in ipairs(CollectionService:GetTagged("PlantArea")) do
        if part:IsDescendantOf(plot) then
            table.insert(areas, part)
        end
    end
    if #areas == 0 then return {} end

    local slots = {}
    local mode = _G.Config.PlantPosition or "Grid"

    if mode == "Player" then
        local hrp = getHRP()
        if hrp then
            local ground = resolveGround(hrp.Position, params, plot)
            if ground and not isPlantOccupied(ground, Plants) then
                table.insert(slots, ground)
            end
        end
    elseif mode == "Random" then
        local seen = {}
        local attempts = 0
        while #slots < 40 and attempts < 120 do
            attempts = attempts + 1
            local area = areas[math.random(1, #areas)]
            local sz = area.Size
            local cf = area.CFrame
            local rx = math.random() * sz.X - sz.X * 0.5
            local rz = math.random() * sz.Z - sz.Z * 0.5
            local world = cf:PointToWorldSpace(Vector3.new(rx, sz.Y * 0.5, rz))
            local ground = resolveGround(world, params, plot)
            if ground then
                local key = math.floor(ground.X + 0.5) .. "_" .. math.floor(ground.Z + 0.5)
                if not seen[key] and not isPlantOccupied(ground, Plants) then
                    seen[key] = true
                    table.insert(slots, ground)
                end
            end
        end
    else -- Grid / Neat
        local minX, minZ = math.huge, math.huge
        local maxX, maxZ = -math.huge, -math.huge
        local topY = 0
        local count = 0
        for _, area in ipairs(areas) do
            local p = area.Position
            local h = area.Size * 0.5
            minX = math.min(minX, p.X - h.X); maxX = math.max(maxX, p.X + h.X)
            minZ = math.min(minZ, p.Z - h.Z); maxZ = math.max(maxZ, p.Z + h.Z)
            topY = topY + p.Y + h.Y; count = count + 1
        end
        topY = topY / math.max(count, 1)
        local x = minX + SPACING * 0.5
        while x <= maxX do
            local z = minZ + SPACING * 0.5
            while z <= maxZ do
                local ground = resolveGround(Vector3.new(x, topY, z), params, plot)
                if ground and not isPlantOccupied(ground, Plants) then
                    table.insert(slots, ground)
                end
                z = z + SPACING
            end
            x = x + SPACING
        end
    end
    return slots
end

local function popPlantSlot()
    local len = #plantSlotCache
    if len == 0 then return nil end
    if (_G.Config.PlantPosition or "Grid") == "Random" then
        local i = math.random(1, len)
        local val = plantSlotCache[i]
        plantSlotCache[i] = plantSlotCache[len]
        plantSlotCache[len] = nil
        return val
    else
        return table.remove(plantSlotCache, 1)
    end
end

TrackTask(function()
    while _G.ShieldTeam_ScriptId == scriptId do
        if _G.Config.AutoPlant then
            pcall(function()
                if not Networking then refreshNetworking() end
                local char = player.Character
                if not char then task.wait(0.5) return end
                
                local plotId = player:GetAttribute("PlotId")
                if not plotId then task.wait(EMPTY_RETRY_DELAY) return end
                local plot = workspace:FindFirstChild("Gardens") and workspace.Gardens:FindFirstChild("Plot" .. tostring(plotId))
                if not plot then task.wait(EMPTY_RETRY_DELAY) return end

                local rawPlant = _G.Config.PlantSeed
                local selectedSeeds = {}
                if type(rawPlant) == "table" then
                    for k, v in pairs(rawPlant) do
                        if type(k) == "number" then selectedSeeds[v] = true
                        else selectedSeeds[k] = v end
                    end
                else
                    selectedSeeds[rawPlant or "Carrot"] = true
                end
                local seedNames = {}
                for name, isSel in pairs(selectedSeeds) do
                    if isSel then table.insert(seedNames, name) end
                end
                if #seedNames == 0 then table.insert(seedNames, "Carrot") end
                table.sort(seedNames)

                local currentSeedTool, currentSeedName = nil, nil
                local function findSeedTool()
                    for _, name in ipairs(seedNames) do
                        if char:FindFirstChild(name) then return char:FindFirstChild(name), name end
                    end
                    local bp = player:FindFirstChild("Backpack")
                    if bp then
                        for _, name in ipairs(seedNames) do
                            if bp:FindFirstChild(name) then return bp:FindFirstChild(name), name end
                        end
                    end
                    return nil, nil
                end

                currentSeedTool, currentSeedName = findSeedTool()
                if not currentSeedTool then task.wait(EMPTY_RETRY_DELAY) return end

                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and currentSeedTool.Parent ~= char then
                    hum:UnequipTools()
                    task.wait(0.05)
                    currentSeedTool.Parent = char
                    task.wait(0.08)
                end
                if currentSeedTool.Parent ~= char then task.wait(0.3) return end

                if plantSlotsDirty or #plantSlotCache == 0 then
                    plantSlotCache = buildPlantSlots(plot)
                    plantSlotsDirty = false
                end
                if #plantSlotCache == 0 then
                    task.wait(SLOT_RECHECK_DELAY)
                    plantSlotsDirty = true
                    return
                end

                while _G.Config.AutoPlant and _G.ShieldTeam_ScriptId == scriptId and #plantSlotCache > 0 do
                    local newTool = findSeedTool()
                    if not newTool then break end
                    if newTool ~= currentSeedTool then
                        currentSeedTool = newTool
                        if hum and currentSeedTool.Parent ~= char then
                            hum:UnequipTools()
                            task.wait(0.05)
                            currentSeedTool.Parent = char
                            task.wait(0.08)
                        end
                    end

                    local pos = popPlantSlot()
                    if not pos then break end

                    pcall(function()
                        local seedId = currentSeedTool:GetAttribute("SeedTool") or currentSeedName
                        Networking.Plant.PlantSeed:Fire(pos, seedId, currentSeedTool)
                    end)
                    task.wait(PLANT_FIRE_INTERVAL)
                end

                if _G.Config.AutoPlant and findSeedTool() then
                    plantSlotsDirty = true
                end
            end)
            task.wait(0.1)
        else
            plantSlotsDirty = true
            table.clear(plantSlotCache)
            task.wait(0.5)
        end
    end
end)

-- ===========================================
-- TASKS: AUTO SHOVEL LOGIC
-- ===========================================
local shovelFiredSet = {}
local SHOVEL_COOLDOWN = 0.5
local isShoveling = false

local function getShovelTool()
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if not char then
        return nil, nil
    end
    local function checkTool(t)
        if t:IsA("Tool") and t:GetAttribute("Shovel") ~= nil then
            return t, t:GetAttribute("Shovel")
        end
        return nil, nil
    end
    for _, t in ipairs(char:GetChildren()) do
        local tool, attr = checkTool(t)
        if tool then
            return tool, attr
        end
    end
    if backpack then
        for _, t in ipairs(backpack:GetChildren()) do
            local tool, attr = checkTool(t)
            if tool then
                return tool, attr
            end
        end
    end
    return nil, nil
end

local function isShovelEquipped()
    local char = player.Character
    if not char then
        return false
    end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool:GetAttribute("Shovel") ~= nil then
            return true
        end
    end
    return false
end

local function equipShovel()
    if isShovelEquipped() then
        return
    end
    local shovelTool = getShovelTool()
    if shovelTool and shovelTool.Parent ~= player.Character then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:EquipTool(shovelTool)
            task.wait(0.2)
        end
    end
end

local function unequipShovel()
    if not isShovelEquipped() then
        return
    end
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:UnequipTools()
    end
end

local function collectShovel(plantId, fruitId, shovelTool, shovelAttr)
    local key = plantId .. "_" .. fruitId
    if shovelFiredSet[key] then
        return
    end
    shovelFiredSet[key] = true
    pcall(function()
        if not Networking then
            refreshNetworking()
        end
        Networking.Shovel.UseShovel:Fire(plantId, fruitId, shovelAttr, shovelTool)
    end)
    task.delay(SHOVEL_COOLDOWN, function()
        shovelFiredSet[key] = nil
    end)
end

local function shovelAll()
    if isShoveling then
        return
    end
    isShoveling = true
    if not Networking then
        refreshNetworking()
    end
    if not Networking then
        isShoveling = false
        return
    end
    local plantsFolder = nil
    local plotId = player:GetAttribute("PlotId")
    if plotId then
        local plot = workspace:FindFirstChild("Gardens") and workspace.Gardens:FindFirstChild("Plot" .. tostring(plotId))
        if plot then
            plantsFolder = plot:FindFirstChild("Plants")
        end
    end
    if not plantsFolder then
        for _, plot in ipairs(getOwnedPlots()) do
            plantsFolder = plot:FindFirstChild("Plants")
            if plantsFolder then
                break
            end
        end
    end
    if not plantsFolder then
        isShoveling = false
        return
    end
    local toShovel = {}
    for _, plant in ipairs(plantsFolder:GetChildren()) do
        if _G.ShieldTeam_ScriptId ~= scriptId then
            break
        end
        if plant:IsA("Model") then
            local name = getPlantName(plant)
            if listContains(_G.Config.ShovelSeed, name) then
                local fruitsFolder = plant:FindFirstChild("Fruits")
                if fruitsFolder then
                    -- Multi-harvest
                    for _, fruit in ipairs(fruitsFolder:GetChildren()) do
                        if fruit:IsA("Model") or fruit:IsA("BasePart") then
                            local weight = getAccurateWeight(fruit)
                            if matchesShovelWeight(weight) and matchesShovelMutation(fruit, _G.Config.ShovelMutation) then
                                table.insert(toShovel, {
                                    plantId = plant.Name,
                                    fruitId = fruit.Name
                                })
                            end
                        end
                    end
                else
                    -- Single-harvest
                    local weight = getAccurateWeight(plant)
                    if matchesShovelWeight(weight) and matchesShovelMutation(plant, _G.Config.ShovelMutation) then
                        table.insert(toShovel, {
                            plantId = plant.Name,
                            fruitId = ""
                        })
                    end
                end
            end
        end
    end
    if #toShovel > 0 then
        equipShovel()
        task.wait(0.1)
        local shovelTool, shovelAttr = getShovelTool()
        if shovelTool then
            if not isShovelEquipped() then
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if hum and shovelTool.Parent ~= player.Character then
                    hum:EquipTool(shovelTool)
                    task.wait(0.2)
                end
            end
            if isShovelEquipped() then
                for _, item in ipairs(toShovel) do
                    if not _G.Config.AutoShovel or _G.ShieldTeam_ScriptId ~= scriptId then
                        break
                    end
                    collectShovel(item.plantId, item.fruitId, shovelTool, shovelAttr)
                    task.wait(0.05)
                end
            end
        end
    else
        unequipShovel()
    end
    isShoveling = false
end

TrackTask(function()
    while _G.ShieldTeam_ScriptId == scriptId do
        if _G.Config.AutoShovel then
            pcall(shovelAll)
            task.wait(2)
        else
            task.wait(0.5)
        end
    end
end)

local pendingShovelDebounce = false
TrackConnection(workspace.DescendantAdded:Connect(function(descendant)
    if not _G.Config.AutoShovel or _G.ShieldTeam_ScriptId ~= scriptId then
        return
    end
    local parent = descendant.Parent
    if parent and (parent.Name == "Fruits" or parent.Name == "Plants") then
        local inOwnedPlot = false
        local plotId = player:GetAttribute("PlotId")
        if plotId then
            local plot = workspace:FindFirstChild("Gardens") and workspace.Gardens:FindFirstChild("Plot" .. tostring(plotId))
            if plot and descendant:IsDescendantOf(plot) then
                inOwnedPlot = true
            end
        end
        if not inOwnedPlot then
            for _, ownedPlot in ipairs(getOwnedPlots()) do
                if descendant:IsDescendantOf(ownedPlot) then
                    inOwnedPlot = true
                    break
                end
            end
        end
        if inOwnedPlot then
            if pendingShovelDebounce then
                return
            end
            pendingShovelDebounce = true
            task.delay(0.3, function()
                pendingShovelDebounce = false
                if _G.Config.AutoShovel then
                    TrackTask(function()
                        pcall(shovelAll)
                    end)
                end
            end)
        end
    end
end))

-- ===========================================
-- TASKS: TELEPORT & AUTO BUY PET LOGIC
-- ===========================================
local function sendServerTeleport(categoryName, val1, position)
    if not PacketRemote then
        return
    end
    local len = #categoryName
    local b = buffer.create(2 + 1 + len + 2 + 12)
    buffer.writeu16(b, 0, 5)
    buffer.writeu8(b, 2, len)
    buffer.writestring(b, 3, categoryName)
    buffer.writeu16(b, 3 + len, val1)
    buffer.writef32(b, 3 + len + 2, position.X)
    buffer.writef32(b, 3 + len + 6, position.Y)
    buffer.writef32(b, 3 + len + 10, position.Z)
    PacketRemote:FireServer(b)
end

local function resolveTeleportTargetCF(target, offset)
    if typeof(target) == "CFrame" then
        return target + offset
    elseif typeof(target) == "Instance" then
        if target:IsA("BasePart") then
            return target.CFrame + offset
        elseif target:IsA("Model") then
            local primary = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
            if primary then
                return primary.CFrame + offset
            end
        end
    end
    return nil
end

local function stepTeleportTowards(hrp, currentTargetCF, maxStep, isLastStep)
    local targetPos = currentTargetCF.Position
    local hrpPos = hrp.Position
    local diff = targetPos - hrpPos
    local dist = diff.Magnitude
    local stepDist = isLastStep and dist or math.min(maxStep, dist)
    local stepPos = hrpPos
    if dist > 0 then
        stepPos = hrpPos + diff.Unit * stepDist
    end
    return CFrame.new(stepPos) * (currentTargetCF - targetPos), stepPos
end

local function fireTeleporterRemote(stepPos)
    pcall(function()
        if not Networking then
            refreshNetworking()
        end
        if Networking and Networking.Place and Networking.Place.UseTeleporter then
            Networking.Place.UseTeleporter:Fire(stepPos)
        end
    end)
end

local function safeTeleport(target, offset)
    local hrp = getHRP()
    if not hrp then
        return
    end
    offset = offset or Vector3.new(0, 0, 0)
    local initialTargetCF = resolveTeleportTargetCF(target, offset)
    if not initialTargetCF then
        return
    end
    local distance = (initialTargetCF.Position - hrp.CFrame.Position).Magnitude
    if distance <= 0 then
        return
    end
    local maxStep = 70
    local numSteps = math.ceil(distance / maxStep)
    for i = 1, numSteps do
        task.wait(0.05)
        local currentTargetCF = resolveTeleportTargetCF(target, offset) or initialTargetCF
        local _, stepPos = stepTeleportTowards(hrp, currentTargetCF, maxStep, i == numSteps)
        hrp.CFrame = stepPos
        fireTeleporterRemote(stepPos)
        if i < numSteps then
            task.wait(0.08)
        end
    end
end

TrackTask(function()
    while _G.ShieldTeam_ScriptId == scriptId do
        if _G.Config.AutoBuyPet then
            pcall(function()
                if not PacketRemote then
                    refreshNetworking()
                end
                local found = scanForPet(_G.Config.PetBuyPet)
                if found then
                    local byteId = getPetBuyOpcode()
                    local targetObj = found
                    local guid = found.Name:match("([%a%d%-]+)$")
                    if guid then
                        local refFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WildPetRef")
                        local refObj = refFolder and refFolder:FindFirstChild("WildPet_" .. guid)
                        if refObj then
                            targetObj = refObj
                        end
                    end
                    local b1 = byteId % 256
                    local b2 = math.floor(byteId / 256) % 256
                    local b = buffer.fromstring(string.char(b1, b2))
                    local args = { b, { targetObj } }
                    local hrp = getHRP()
                    local petPart = found.PrimaryPart or found:FindFirstChildWhichIsA("BasePart", true)
                    if hrp and petPart then
                        local distance = (petPart.Position - hrp.Position).Magnitude
                        local needTeleport = distance >= 15
                        local teleTool = nil
                        if needTeleport then
                            pcall(function()
                                local backpack = player:FindFirstChild("Backpack")
                                local char = player.Character
                                local function checkTool(t)
                                    return t:IsA("Tool") and (t:GetAttribute("Teleporter") or string.find(string.lower(t.Name), "teleport", 1, true))
                                end
                                if char then
                                    for _, c in ipairs(char:GetChildren()) do
                                        if checkTool(c) then
                                            teleTool = c
                                            break
                                        end
                                    end
                                end
                                if not teleTool and backpack then
                                    for _, c in ipairs(backpack:GetChildren()) do
                                        if checkTool(c) then
                                            teleTool = c
                                            break
                                        end
                                    end
                                end
                                if teleTool and teleTool.Parent ~= char then
                                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                                    if hum then
                                        hum:EquipTool(teleTool)
                                        task.wait(0.08)
                                    end
                                end
                            end)
                            local seedPad = workspace:FindFirstChild("Teleports") and workspace.Teleports:FindFirstChild("Seeds")
                            if seedPad and distance > (seedPad.Position - hrp.Position).Magnitude then
                                safeTeleport(seedPad, Vector3.new(0, 3, 0))
                                task.wait(4)
                            end
                            safeTeleport(petPart, Vector3.new(0, 3, 0))
                        end
                        if PacketRemote then
                            PacketRemote:FireServer(unpack(args))
                        end
                        local prompt = findPrompt(found)
                        if prompt then
                            pcall(function()
                                fireproximityprompt(prompt, prompt.HoldDuration or 0)
                            end)
                        end
                        if needTeleport then
                            task.wait(0.4)
                            pcall(function()
                                if teleTool and teleTool.Parent == player.Character then
                                    teleTool.Parent = player:FindFirstChild("Backpack")
                                end
                            end)
                        end
                    else
                        if PacketRemote then
                            PacketRemote:FireServer(unpack(args))
                        end
                    end
                    task.wait(2)
                end
            end)
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

-- ===========================================
-- TASKS: SERVER HOP LOGIC
-- ===========================================
TrackTask(function()
    while _G.ShieldTeam_ScriptId == scriptId do
        if _G.Config.ServerHop then
            local localFound = false
            for scanAttempt = 1, 3 do
                if not _G.Config.ServerHop or _G.ShieldTeam_ScriptId ~= scriptId then
                    break
                end
                pcall(function()
                    updateParagraph(PetStatusLabel, "Status", "Status: Scanning Local (" .. tostring(scanAttempt) .. "/3)")
                    local found = scanForPet(_G.Config.PetTargetName)
                    if found then
                        localFound = true
                        updateParagraph(PetStatusLabel, "Status", "Status: Found - " .. getPetDisplayName(found))
                        Fluent:Notify({
                            Title = "Pet Found!",
                            Content = getPetDisplayName(found) .. " (" .. getPetRarity(found) .. ")",
                            Duration = 8,
                        })
                        SaveManager:Save()
                    end
                end)
                if localFound then
                    break
                end
                task.wait(2.5)
            end
            if not localFound then
                updateParagraph(PetStatusLabel, "Status", "Status: Checking API")
                local targetJobId, targetPlaceId = nil, nil
                local success, response = pcall(function()
                    return game:HttpGet("https://key.shieldteam.asia/api/gag2-servers")
                end)
                if success and response then
                    local decodeSuccess, decoded = pcall(function()
                        return HttpService:JSONDecode(response)
                    end)
                    if decodeSuccess and type(decoded) == "table" then
                        local function matchesTarget(p, selectedPets)
                            if not p or type(p) ~= "table" then
                                return false
                            end
                            return petMatchesSelection(selectedPets, p.name or "")
                        end
                        local validServers = {}
                        for _, s in ipairs(decoded) do
                            local curPlayers, maxPlayers = 0, 8
                            if s.players and type(s.players) == "string" then
                                local cp, mp = s.players:match("^(%d+)%s*/%s*(%d+)")
                                curPlayers = tonumber(cp) or 0
                                maxPlayers = tonumber(mp) or 8
                            end
                            if curPlayers < maxPlayers and s.jobId and s.jobId ~= game.JobId then
                                if s.pet and type(s.pet) == "table" then
                                    local bestExpiry = 0
                                    for _, p in ipairs(s.pet) do
                                        if matchesTarget(p, _G.Config.PetTargetName) then
                                            local expiry = tonumber(p.expiry or s.petTime or 0)
                                            if expiry > os.time() and expiry > bestExpiry then
                                                bestExpiry = expiry
                                            end
                                        end
                                    end
                                    if bestExpiry > 0 then
                                        table.insert(validServers, {
                                            server = s,
                                            expiry = bestExpiry
                                        })
                                    end
                                end
                            end
                        end
                        table.sort(validServers, function(a, b)
                            return a.expiry > b.expiry
                        end)
                        if validServers[1] then
                            targetJobId = validServers[1].server.jobId
                            targetPlaceId = tonumber(validServers[1].server.placeId) or game.PlaceId
                        end
                    end
                end
                if targetJobId then
                    updateParagraph(PetStatusLabel, "Status", "Status: Teleporting...")
                    Fluent:Notify({
                        Title = "Connecting...",
                        Content = "Teleporting to server with target pet!",
                        Duration = 5,
                    })
                    task.wait(1)
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(targetPlaceId or game.PlaceId, targetJobId, player)
                    end)
                    task.wait(10)
                else
                    updateParagraph(PetStatusLabel, "Status", "Status: Waiting for pet (API)")
                    task.wait(5)
                end
            else
                task.wait(0.5)
            end
        else
            task.wait(0.5)
        end
    end
end)

-- ===========================================
-- TASKS: ESP LOGIC
-- ===========================================
local SellValueData, MutationData = nil, nil
pcall(function()
    SellValueData = require(ReplicatedStorage.SharedModules.SellValueData)
end)
pcall(function()
    MutationData = require(ReplicatedStorage.SharedModules.MutationData)
end)

local function isEspPetModel(obj)
    if not obj:IsA("Model") or not isWildPet(obj) then
        return false
    end
    if obj:GetAttribute("Rarity") or obj:GetAttribute("PetName") then
        return true
    end
    return false
end

local function isEspFruitObject(obj)
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then
        return false
    end
    return obj:GetAttribute("FruitId") ~= nil and obj:GetAttribute("PlantId") ~= nil
end

TrackTask(function()
    while _G.ShieldTeam_ScriptId == scriptId do
        if _G.Config.ESPMaster then
            pcall(function()
                local hrp = getHRP()
                local camPos = hrp and hrp.Position or Vector3.zero
                
                if _G.Config.ESPPet then
                    local descendants = workspace:GetDescendants()
                    for i, obj in ipairs(descendants) do
                        if i % 100 == 0 then task.wait() end
                        if isEspPetModel(obj) and not _G.ShieldTeam_Resources.ESPObjects[obj] then
                            local part = obj:FindFirstChildWhichIsA("BasePart", true)
                            if part and (part.Position - camPos).Magnitude <= _G.Config.ESPMaxDistance then
                                local displayName = getPetDisplayName(obj)
                                local rarity = getPetRarity(obj)
                                createESP(obj, "ðŸ¾ " .. displayName .. " " .. rarity, Color3.fromRGB(170, 100, 255))
                            end
                        end
                    end
                end
                
                if _G.Config.ESPFruit then
                    local descendants = workspace:GetDescendants()
                    for i, obj in ipairs(descendants) do
                        if i % 100 == 0 then task.wait() end
                        if isEspFruitObject(obj) and not _G.ShieldTeam_Resources.ESPObjects[obj] then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                            if part and (part.Position - camPos).Magnitude <= _G.Config.ESPMaxDistance then
                                local plantName = obj:GetAttribute("CorePartName") or obj:GetAttribute("SeedName") or "Fruit"
                                local mutation = obj:GetAttribute("Mutation")
                                local sizeMulti = obj:GetAttribute("SizeMulti") or 1
                                local label = "ðŸŽ " .. plantName
                                if mutation and mutation ~= "" then
                                    label = label .. " [" .. mutation .. "]"
                                end
                                if _G.Config.ShowSellPrice and SellValueData and MutationData then
                                    local basePrice = SellValueData[plantName] or 100
                                    local mutMult = (mutation and mutation ~= "") and MutationData.ReturnPriceMultiplier(mutation) or 1
                                    local price = math.floor(basePrice * sizeMulti ^ 3 * mutMult)
                                    label = label .. "\nðŸ’° $" .. tostring(price)
                                end
                                createESP(obj, label, Color3.fromRGB(100, 255, 120))
                            end
                        end
                    end
                end
            end)
            task.wait(1)
        else
            clearESP()
            task.wait(0.5)
        end
    end
end)

-- ===========================================
-- TASKS: ANTI AFK & AUTO REJOIN
-- ===========================================
TrackConnection(player.Idled:Connect(function()
    if _G.Config.AntiAFK and _G.ShieldTeam_ScriptId == scriptId then
        pcall(function()
            VirtualUser:CaptureFocus()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end))

TrackTask(function()
    local promptOverlay = CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
    TrackConnection(promptOverlay.ChildAdded:Connect(function(child)
        if _G.Config.AutoRejoin and _G.ShieldTeam_ScriptId == scriptId then
            task.wait(5)
            pcall(function()
                TeleportService:Teleport(game.PlaceId, player)
            end)
        end
    end))
end)

-- ===========================================
-- INITIALIZATION NOTIFICATION
-- ===========================================
Fluent:Notify({
    Title = "ShieldTeam || Garden V2",
    Content = "Script loaded successfully! Remotes: " .. tostring(#_G.Remotes),
    Duration = 5,
})

print("[ShieldTeam] Script utuh berhasil dimuat.")