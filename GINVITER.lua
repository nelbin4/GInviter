-- Search mode "zone" or "class"
local SearchMode = "class"

-- Add or remove zones to search here
local SearchZone = { "Dalaran", "The Ruby Sanctum" }

-- Add or remove classes to search here
local SearchClass = { "Warrior", "Paladin", "Hunter", "Rogue", "Priest", "Death Knight", "Shaman", "Mage", "Warlock", "Druid" }

-- Loop interval in seconds
local loopInterval = 90

-- What level to search
local level = 80

-- Maximum number of invites before excluding a player
local maxInvites = 2

-- Add your desired zones to be excluded
local excludedZones = { "Dalaran Arena", "Nagrand Arena", "Blade's Edge Arena", "Ruins of Lordaeron" }

local initialSearchZone = { unpack(SearchZone) }
local initialSearchClass = { unpack(SearchClass) }
local searching = false
local searchStarted = false
local lastSearchTime = 0
local timeLeft = 0
local currentZone = 1
local currentClass = 1
local excludeList = {}

-- UI frame
local frame = CreateFrame("Frame", "GINVITERFrame", UIParent)
frame:SetSize(145, 135)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})

local titleBar = CreateFrame("Frame", nil, frame)
titleBar:SetSize(frame:GetWidth(), 25)
titleBar:SetPoint("TOP", 0, 0)
titleBar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
titleBar:SetBackdropColor(0.5, 0, 0.1, 1)

local titleText = titleBar:CreateFontString(nil, "ARTWORK", "GameFontNormal")
titleText:SetPoint("CENTER", titleBar, "CENTER")
titleText:SetText("GInviter")
titleText:SetTextColor(1, 1, 1)

local minimizeButton = CreateFrame("Button", nil, frame)
minimizeButton:SetSize(25, 25)
minimizeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
minimizeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
minimizeButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
minimizeButton:SetScript("OnClick", function() frame:Hide() end)

local statusText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
statusText:SetPoint("TOP", titleBar, "BOTTOM", 0, -10)
statusText:SetJustifyH("CENTER")
statusText:SetText("Stopped")

local timeText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
timeText:SetPoint("TOP", statusText, "BOTTOM", 0, -10)
timeText:SetJustifyH("CENTER")
timeText:SetText("Time left:")

local timeValue = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
timeValue:SetPoint("TOP", timeText, "BOTTOM", 0, -5)
timeValue:SetJustifyH("CENTER")
timeValue:SetText("-")

local errorText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
errorText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
errorText:SetJustifyH("RIGHT")
errorText:SetText("")

local startButton = CreateFrame("Button", "GINVITERStartButton", frame, "UIPanelButtonTemplate")
startButton:SetSize(60, 20)
startButton:SetPoint("BOTTOMLEFT", 10, 10)
startButton:SetText("Start")
if searchStarted then
    startButton:Disable()
else
    startButton:Enable()
end
startButton:SetScript("OnClick", function() GINVITER_StartSearch() end)

local stopButton = CreateFrame("Button", "GINVITERStopButton", frame, "UIPanelButtonTemplate")
stopButton:SetSize(60, 20)
stopButton:SetPoint("BOTTOMLEFT", startButton, "BOTTOMRIGHT", 5, 0)
stopButton:SetText("Stop")
if not searchStarted then
    stopButton:Disable()
else
    stopButton:Enable()
end
stopButton:SetScript("OnClick", function() GINVITER_StopSearch() end)

-- Add to exclusion list
local function GINVITER_AddToExcludeList(playerName)
    excludeList[playerName] = (excludeList[playerName] or 0) + 1
end

-- Excluded list
local function GINVITER_IsExcluded(playerName)
    return excludeList[playerName] and excludeList[playerName] >= maxInvites
end

-- Slash Cmds
local function GINVITER_Command(args)
    if (args == "show") then
        frame:Show()
    elseif (args == "hide") then
        frame:Hide()
    else
        print("Usage: /ginviter [show/hide]")
    end
end

-- Function to start the search
function GINVITER_StartSearch()
    if CanGuildInvite() then
        searching = true
        lastSearchTime = time()
        GINVITER_SendSearch()
        timeLeft = 0
        currentZone = 1
        currentClass = 1
        startButton:Disable()
        stopButton:Enable()
		print("|cffffff00GInviter:|r Starting..")
    else
        GINVITER_StopSearch()
        print("|cffffff00GInviter:|r We are not in a guild. Join a guild to use GInviter.")
    end
end

-- Function to stop the search
function GINVITER_StopSearch()
    searching = false
    statusText:SetText("Stopped")
    timeValue:SetText("-")
    startButton:Enable()
    stopButton:Disable()
    timeLeft = 0
    currentZone = 1
    currentClass = 1
    SearchZone = table.clone(initialSearchZone)
    SearchClass = table.clone(initialSearchClass)
	print("|cffffff00GInviter:|r Stopped.")
end

-- Function to restart the search
function GINVITER_RestartSearch()
    if CanGuildInvite() then
        searching = true
        lastSearchTime = time()
        GINVITER_SendSearch()
        timeLeft = 0
        currentZone = 1
        currentClass = 1
        startButton:Disable()
        stopButton:Enable()
        print("|cffffff00GInviter:|r Restarting..")
    else
        GINVITER_StopSearch()
        print("|cffffff00GInviter:|r We are not in a guild. Join a guild to use GInviter.")
    end
end

-- Function to check guild member count
function GINVITER_CheckGuildMemberCount()
    GuildRoster()
    local numMembers = GetNumGuildMembers(true)

    if numMembers >= 1000 then
        GINVITER_StopSearch()
        print("|cffffff00GInviter:|r Guild Full.")
        return true
    end

    return false
end

-- Table clone
function table.clone(...)
    local clones = {...}
    local result = {}
    
    for i, clone in ipairs(clones) do
        for key, value in pairs(clone) do
            if type(value) == "table" then
                result[key] = table.clone(value)
            else
                result[key] = value
            end
        end
    end
    
    return result
end

-- Function to send the search query
function GINVITER_SendSearch()
    if GINVITER_CheckGuildMemberCount() then
        return
    end
	
    SetWhoToUI(1)
    FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")

    local whoString = ""
    if SearchMode == "zone" then
        if #SearchZone == 0 then
            if #SearchClass == 0 then
                GINVITER_RestartSearch()
                return
            end
            SearchZone = table.clone(initialSearchZone)
        end
        local zoneIndex = math.random(1, #SearchZone)
        local zone = table.remove(SearchZone, zoneIndex)
        whoString = "g-\"\" " .. level .. " z-\"" .. zone .. "\""
        statusText:SetText("Searching in\n" .. zone)
    elseif SearchMode == "class" then
        if #SearchClass == 0 then
            if #SearchZone == 0 then
                GINVITER_RestartSearch()
                return
            end
            SearchClass = table.clone(initialSearchClass)
        end
        local classIndex = math.random(1, #SearchClass)
        local class = table.remove(SearchClass, classIndex)
        whoString = "g-\"\" " .. level .. " c-\"" .. class .. "\""
        statusText:SetText("Searching for\n" .. class)
    end

    lastSearchTime = time()
    SendWho(whoString)
end

-- Function to handle the update
local function GINVITER_OnUpdate(args)
    if searching then
        local timeLeft = lastSearchTime + loopInterval - time()
        if timeLeft < 0 then
            if CanGuildInvite() then
                GINVITER_SendSearch()
            else
                GINVITER_StopSearch()
                print("|cffffff00GInviter:|r We don't have /ginvite privileges. Ask the Guild Master or an Officer.")
            end
        else
            timeValue:SetText(string.format("%.0f", timeLeft))
            errorText:SetText("")
        end
    else
        if #SearchZone == 0 or #SearchClass == 0 then

            if #SearchZone == 0 then
                SearchZone = table.clone(initialSearchZone)
            end

            if #SearchClass == 0 then
                SearchClass = table.clone(initialSearchClass)
            end

            if not searching then
                GINVITER_RestartSearch()
            end
        end
    end
end

function GINVITER_OnEvent(args)
    if (searching == false) then return end
    GINVITER_InviteWhoResults()
	GINVITER_CheckGuildMemberCount()
end

function GINVITER_OnLoad()
	local initialSearchZone = table.clone(SearchZone)
	local initialSearchClass = table.clone(SearchClass)
end

function GINVITER_InviteWhoResults()
    local numWhos = GetNumWhoResults()

    for index = 1, numWhos, 1 do
        local charname, guildname, level, race, class, zone, classFileName = GetWhoInfo(index)
        
        if (guildname == "" and not GINVITER_IsExcluded(charname) and not IsZoneExcluded(zone)) then
            GINVITER_AddToExcludeList(charname)
            GuildInvite(charname)
        end
    end
end

function IsZoneExcluded(zone)
    for _, excludedZone in ipairs(excludedZones) do
        if zone == excludedZone then
            return true
        end
    end
    return false
end

frame:SetScript("OnUpdate", GINVITER_OnUpdate)
frame:SetScript("OnEvent", GINVITER_OnEvent)
frame:SetScript("OnLoad", GINVITER_OnLoad)
frame:RegisterEvent("WHO_LIST_UPDATE")
frame:SetFrameStrata("LOW")
frame:SetClampedToScreen(true)
SLASH_GINVITER1 = "/GINVITER"
SlashCmdList["GINVITER"] = GINVITER_Command

print("|cffffff00GInviter:|r Use /GINVITER. Modify file ginviter.lua inside addon folder. Check |cffffff00github.com/nelbin4/ginviter|r for updates.")
