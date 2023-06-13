-- ##########################################################

-- Search mode "zone" or "class"
local searchMode = "class"

-- You can add zones to search here. Just follow syntax "" and , comma
local zones = { "Dalaran", "The Ruby Sanctum" }

-- You can add classes to search here. Just follow syntax "" and , comma
local classes = { "Warrior", "Paladin", "Hunter", "Rogue", "Priest", "Death Knight", "Shaman", "Mage", "Warlock", "Druid" }

-- Loop interval in seconds
local loopInterval = 180 

-- What level to search
local level = 80 

-- Maximum number of invites before excluding a player
local maxInvites = 2

-- ##########################################################

local searching = false
local lastSearchTime = 0
local timeLeft = 0
local currentZone = 1
local currentClass = 1

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

-- Create the title bar frame
local titleBar = CreateFrame("Frame", nil, frame)
titleBar:SetSize(frame:GetWidth(), 25)
titleBar:SetPoint("TOP", 0, 0)
titleBar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
titleBar:SetBackdropColor(0.5, 0, 0.1, 1) -- Maroon background color

-- Create the title text
local titleText = titleBar:CreateFontString(nil, "ARTWORK", "GameFontNormal")
titleText:SetPoint("CENTER", titleBar, "CENTER")
titleText:SetText("GInviter") -- Set the title text
titleText:SetTextColor(1, 1, 1) -- White text color

-- Create the close/minimize button
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
startButton:SetScript("OnClick", function() GINVITER_StartSearch() end)

local stopButton = CreateFrame("Button", "GINVITERStopButton", frame, "UIPanelButtonTemplate")
stopButton:SetSize(60, 20)
stopButton:SetPoint("BOTTOMLEFT", startButton, "BOTTOMRIGHT", 5, 0)
stopButton:SetText("Stop")
stopButton:SetScript("OnClick", function() GINVITER_StopSearch() end)

local excludeList = {}

local function GINVITER_AddToExcludeList(playerName)
    excludeList[playerName] = (excludeList[playerName] or 0) + 1
end

local function GINVITER_IsExcluded(playerName)
    return excludeList[playerName] and excludeList[playerName] >= maxInvites
end

local function GINVITER_Command(args)
    if (args == "show") then
        frame:Show()
    elseif (args == "hide") then
        frame:Hide()
    else
        ChatFrame1:AddMessage("Usage: /GINVITER [show/hide]")
    end
end

function GINVITER_OnLoad()
end

function GINVITER_StartSearch()
    if CanGuildInvite() then
	    statusText:SetText("Searching")
		searching = true
		lastSearchTime = time()
		GINVITER_SendSearch()
	else
		GINVITER_StopSearch()
        print("We don't have /ginvite privileges. Ask Guild Master or Officer.")
    end
end

function GINVITER_StopSearch()
    searching = false
    statusText:SetText("Stopped")
end

function GINVITER_OnUpdate(args)
    if searching then
        local timeLeft = lastSearchTime + loopInterval - time()
        if timeLeft < 0 then
            if CanGuildInvite() then
                GINVITER_SendSearch()
            else
                GINVITER_StopSearch()
                print("We don't have /ginvite privileges. Ask the Guild Master or an Officer.")
            end
        else
            timeValue:SetText(string.format("%.0f", timeLeft))
            errorText:SetText("")
        end
    end
end


-- Function to send the search query
function GINVITER_SendSearch()
    SetWhoToUI(1)
    FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")

    local whoString = ""
    if (searchMode == "zone") then
        if #zones == 0 then
            print("All zones have been searched.")
            return
        end

        local zoneIndex = math.random(1, #zones) -- Randomly select a zone index
        local zone = zones[zoneIndex]
        table.remove(zones, zoneIndex) -- Remove the selected zone from the list
        whoString = "g-\"\" " .. level .. " z-\"" .. zone .. "\""
        statusText:SetText("Searching in\n" .. zone)
    elseif (searchMode == "class") then
        if #classes == 0 then
            print("All classes have been searched.")
            return
        end

        local classIndex = math.random(1, #classes) -- Randomly select a class index
        local class = classes[classIndex]
        table.remove(classes, classIndex) -- Remove the selected class from the list
        whoString = "g-\"\" " .. level .. " c-\"" .. class .. "\""
        statusText:SetText("Searching for\n" .. class)
    end

    lastSearchTime = time()
    SendWho(whoString)
end

function GINVITER_OnEvent(args)
    if (searching == false) then return end
    GINVITER_InviteWhoResults()
end

function GINVITER_InviteWhoResults()
    local numWhos = GetNumWhoResults()
    for index = 1, numWhos, 1 do
        local charname, guildname, level, race, class, zone, classFileName = GetWhoInfo(index)
        if (guildname == "" and zone ~= "Dalaran Arena" and not GINVITER_IsExcluded(charname)) then
            GINVITER_AddToExcludeList(charname)
            GuildInvite(charname)
        end
    end
end

frame:SetScript("OnUpdate", GINVITER_OnUpdate)
frame:RegisterEvent("WHO_LIST_UPDATE")
frame:SetScript("OnEvent", GINVITER_OnEvent)
frame:SetScript("OnLoad", GINVITER_OnLoad)
SLASH_GINVITER1 = "/GINVITER"
SlashCmdList["GINVITER"] = GINVITER_Command
frame:SetFrameStrata("LOW")
frame:SetClampedToScreen(true)

print("|cff00ff00GInviter loaded.|r Use /GINVITER. Modify file ginviter.lua inside addon folder. Check github.com/nelbin4/ginviter for updates.")
