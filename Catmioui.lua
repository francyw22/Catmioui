-- Modified Arqel Key System for Catmio


repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(obj) return obj end
local gethui = gethui or function() return cloneref(game:GetService("CoreGui")) end

-- services
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local Lighting = cloneref(game:GetService("Lighting"))
local Players = cloneref(game:GetService("Players"))

local hui = gethui()

if getgenv().ArqelLoaded and hui:FindFirstChild("ArqelKeySystem") then return getgenv().Arqel end
if getgenv().ArqelLoaded and hui:FindFirstChild("ArqelKeylessSystem") then return getgenv().Arqel end
getgenv().ArqelLoaded = false
getgenv().ArqelClosed = false

local Arqel = {}

-- appearance
Arqel.Appearance = {
    Title = "catmio | Key system",
    Subtitle = "Enter your key to continue",
    Icon = "rbxassetid://95721401302279", -- Keep default icon or replace if user provides one
    IconSize = UDim2.new(0, 30, 0, 30)
}

-- links
Arqel.Links = {
    GetKey = "https://discord.gg/JzUgsbUFNp", -- Redirect Get Premium to Discord
    Discord = "https://discord.gg/JzUgsbUFNp"
}

-- storage
Arqel.Storage = {
    FileName = "catmio_Key", -- Changed from Arqel_Key
    Remember = true,
    AutoLoad = true
}

-- options
Arqel.Options = {
    Keyless = nil,
    KeylessUI = false,
    Blur = true,
    Draggable = true
}

-- theme
Arqel.Theme = {
    Accent = Color3.fromRGB(255, 165, 0), -- Naranja
    AccentHover = Color3.fromRGB(200, 100, 0), -- Naranja oscuro
    Background = Color3.fromRGB(15, 15, 15), -- Negro
    Header = Color3.fromRGB(40, 40, 44), -- Gris (de Catmio)
    Input = Color3.fromRGB(25, 25, 25), -- Negro
    Text = Color3.fromRGB(255, 255, 255), -- Blanco
    TextDim = Color3.fromRGB(120, 120, 120), -- Gris
    Success = Color3.fromRGB(50, 205, 110), -- Verde (mantener)
    Error = Color3.fromRGB(128, 0, 0), -- Rojo vino
    Warning = Color3.fromRGB(255, 180, 50), -- Naranja (mantener)
    StatusIdle = Color3.fromRGB(128, 0, 0), -- Rojo vino
    Discord = Color3.fromRGB(88, 101, 242), -- Azul (mantener)
    DiscordHover = Color3.fromRGB(114, 137, 218), -- Azul (mantener)
    Divider = Color3.fromRGB(45, 45, 70), -- Gris oscuro (mantener)
    Pending = Color3.fromRGB(60, 60, 60) -- Gris (mantener)
}

-- callbacks
Arqel.Callbacks = {
    OnVerify = nil,
    OnSuccess = nil,
    OnFail = nil,
    OnClose = nil
}

Arqel.Changelog = {}

-- shop
Arqel.Shop = {
    Enabled = true, -- Enable shop for 'Get Premium'
    Icon = "", -- Default icon
    Title = "Get Premium Access",
    Subtitle = "Instant delivery â€¢ 24/7 support",
    ButtonText = "Get Premium",
    Link = "https://discord.gg/JzUgsbUFNp" -- Redirect to Discord
}

-- internal
local Internal = {
    Junkie = nil,
    BlurEffect = nil,
    NotificationList = {},
    ValidateFunction = nil,
    IsJunkieMode = false,
    IconsLoaded = false
}

local IconBaseURL = "https://raw.githubusercontent.com/Cobruhehe/expert-octo-doodle/main/Icons/"
local IconFiles = {
    key = "lucide--key.png",
    shield = "lucide--shield-minus.png",
    check = "prime--check-square.png",
    copy = "flowbite--clipboard-outline.png",
    discord = "qlementine-icons--discord-16.png",
    alert = "mdi--alert-octagon-outline.png",
    lock = "lucide--user-lock.png",
    loading = "nonicons--loading-16.png",
    close = "material-symbols--dangerous-outline.png",
    changelog = "ant-design--sync-outlined.png",
    logo = "rrjlGmac.png",
    user = "U.png",
    clock = "Clock.png",
    cart = "Cart.png"
}

local FallbackIcons = {
    key = "rbxassetid://96510194465420",
    shield = "rbxassetid://89965059528921",
    check = "rbxassetid://76078495178149",
    copy = "rbxassetid://125851897718493",
    discord = "rbxassetid://83278450537116",
    alert = "rbxassetid://140438367956051",
    lock = "rbxassetid://114355063515473",
    loading = "rbxassetid://116535712789945",
    close = "rbxassetid://6022668916",
    changelog = "rbxassetid://138133190015277",
    logo = "rbxassetid://95721401302279",
    user = "rbxassetid://77400125196692",
    clock = "rbxassetid://87505349362628",
    cart = "rbxassetid://114754518183872"
}

local CachedIcons = {}
local FolderName = "Arqel"
local IconsFolder = "Icons"
local DefaultLogoAsset = "rbxassetid://95721401302279"

local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function getScale()
    local viewport = Workspace.CurrentCamera.ViewportSize
    return math.clamp(math.min(viewport.X, viewport.Y) / 900, 0.65, 1.3)
end

local function hasFileSystem()
    local ok1 = pcall(function() return type(writefile) == "function" end)
    local ok2 = pcall(function() return type(readfile) == "function" end)
    local ok3 = pcall(function() return type(isfile) == "function" end)
    local ok4 = pcall(function() return type(makefolder) == "function" end)
    local ok5 = pcall(function() return type(isfolder) == "function" end)
    return ok1 and ok2 and ok3 and ok4 and ok5
end

local fileSystemSupported = hasFileSystem()

local function getFileName()
    return FolderName .. "/" .. Arqel.Storage.FileName .. ".txt"
end

local function saveKey(key)
    if not fileSystemSupported or not Arqel.Storage.Remember then return false end
    return pcall(function() writefile(getFileName(), key) end)
end

local function loadKey()
    if not fileSystemSupported then return nil end
    local ok, content = pcall(function()
        if isfile(getFileName()) then return readfile(getFileName()) end
        return nil
    end)
    if ok and content and content ~= "" then return content end
    return nil
end

local function clearKey()
    if not fileSystemSupported then return false end
    return pcall(function() delfile(getFileName()) end)
end

local function ensureFolders()
    if not fileSystemSupported then return false end
    pcall(function()
        if not isfolder(FolderName) then makefolder(FolderName) end
        if not isfolder(FolderName .. "/" .. IconsFolder) then makefolder(FolderName .. "/" .. IconsFolder) end
    end)
    return true
end

local function getIconPath(iconName)
    return FolderName .. "/" .. IconsFolder .. "/" .. IconFiles[iconName]
end

local function isIconCached(iconName)
    if not fileSystemSupported then return false end
    local success, result = pcall(function() return isfile(getIconPath(iconName)) end)
    return success and result
end

local function downloadIcon(iconName)
    if not fileSystemSupported then
        CachedIcons[iconName] = FallbackIcons[iconName]
        return false
    end
    local path = getIconPath(iconName)
    if isIconCached(iconName) then
        local success = pcall(function() CachedIcons[iconName] = getcustomasset(path) end)
        if success then return true end
    end
    local success = pcall(function()
        local response = game:HttpGet(IconBaseURL .. IconFiles[iconName])
        if #response < 100 then error("Invalid") end
        writefile(path, response)
        CachedIcons[iconName] = getcustomasset(path)
    end)
    if not success then CachedIcons[iconName] = FallbackIcons[iconName] end
    return success
end

local function getIcon(iconName)
    return CachedIcons[iconName] or FallbackIcons[iconName]
end

local function getLogoIcon()
    if Arqel.Appearance.Icon == DefaultLogoAsset then return getIcon("logo") end
    return Arqel.Appearance.Icon
end

local function shouldDownloadLogo()
    return Arqel.Appearance.Icon == DefaultLogoAsset
end

local function getShopIcon()
    if Arqel.Shop.Icon == "" then return getLogoIcon() end
    return Arqel.Shop.Icon
end

local function isShopEnabled()
    return Arqel.Shop.Enabled
end

local function allIconsCached()
    if not fileSystemSupported then return false end
    local iconNames = {"key", "shield", "check", "copy", "discord", "alert", "lock", "loading", "close", "changelog", "user", "clock", "cart"}
    if shouldDownloadLogo() then table.insert(iconNames, "logo") end
    for _, name in ipairs(iconNames) do
        if not isIconCached(name) then return false end
    end
    return true
end

local function loadAllIconsFromCache()
    ensureFolders()
    local iconNames = {"key", "shield", "check", "copy", "discord", "alert", "lock", "loading", "close", "changelog", "user", "clock", "cart"}
    if shouldDownloadLogo() then table.insert(iconNames, "logo") end
    for _, name in ipairs(iconNames) do downloadIcon(name) end
    Internal.IconsLoaded = true
end

local function getExecutorName()
    local success, name = pcall(identifyexecutor)
    if success and name then return tostring(name) end
    return "Unknown"
end

local function getDeviceType()
    local touch = UserInputService.TouchEnabled
    local keyboard = UserInputService.KeyboardEnabled
    local gamepad = UserInputService.GamepadEnabled
    if gamepad and not keyboard and not touch then return "Console"
    elseif touch and not keyboard then return "Mobile"
    elseif keyboard and touch then return "PC & Touch"
    elseif keyboard then return "PC"
    else return "Unknown" end
end

local function getHWID()
    local hwid = nil
    pcall(function() if gethwid then hwid = gethwid() end end)
    if not hwid then pcall(function() if getgenv().HWID then hwid = getgenv().HWID end end) end
    if not hwid then pcall(function() if game.RobloxHWID then hwid = tostring(game.RobloxHWID) end end) end
    if not hwid then
        local player = cloneref(Players.LocalPlayer)
        hwid = HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 32)
        if player then
            hwid = HttpService:MD5(player.Name .. player.UserId .. hwid)
        end
    end
    return hwid
end

-- Catmio Key System Integration
local VALID_KEY = "catmio"
local KEY_FILE = "catmio_key.json"
local KEY_TIME = 7200 -- 2 horas

local function saveCatmioKey(key)
    local data = {
        key = key,
        time = os.time()
    }
    writefile(KEY_FILE, HttpService:JSONEncode(data))
end

local function isCatmioKeyValid()
    if not isfile(KEY_FILE) then
        return false
    end

    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(KEY_FILE))
    end)

    if not success or not data then
        return false
    end

    if data.key ~= VALID_KEY then
        return false
    end

    if os.time() - data.time > KEY_TIME then
        return false
    end

    return true
end

-- Placeholder for game script loading from Catmio
local function loadGameScript()
    -- This function would contain the logic to load game-specific scripts
    -- based on game.PlaceId or game.GameId, similar to the original Catmio script.
    -- For this integration, we'll just print a message.
    print("Game script loading logic would go here.")
    -- Example from Catmio:
    -- local scripts = {
    --     [106772177198260] = "https://raw.githubusercontent.com/francy2w/Hub/refs/heads/main/Reelabrainrot.lua",
    --     -- ... other game scripts
    -- }
    -- local placeId = game.PlaceId
    -- local scriptUrl = scripts[placeId]
    -- if scriptUrl then
    --     local success, result = pcall(function() return game:HttpGet(scriptUrl) end)
    --     if success and result then
    --         local func = loadstring and loadstring(result)
    --         if func then pcall(func) end
    --     end
    -- end
end

-- Arqel's key verification callback
Arqel.Callbacks.OnVerify = function(key)
    if key == VALID_KEY then
        saveCatmioKey(key)
        return true, "Key verified successfully!"
    else
        return false, "Invalid Key."
    end
end

-- Arqel's success callback
Arqel.Callbacks.OnSuccess = function()
    loadGameScript()
end

-- Auto-load key if valid
if isCatmioKeyValid() then
    getgenv().ArqelClosed = true -- Close Arqel UI if key is valid
    loadGameScript()
end

return Arqel
