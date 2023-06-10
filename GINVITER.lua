-- ##########################################################

-- You can add zones to search here. Just follow syntax "" and , comma
local zones = { "Dalaran", "The Ruby Sanctum" }

-- Loop interval in seconds
local loopInterval = 180 

-- What level to search
local level = 80 

-- Exclude list for people who have already been invited
local excludeList = {}

-- ##########################################################


local searching = false
local lastSearchTime = 0
local timeLeft = 0
local currentZone = 1

local frame = CreateFrame("Frame", "GINVITERFrame", UIParent)
frame:SetSize(145, 110)
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

local statusText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
statusText:SetPoint("TOP", 0, -10)
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
errorText:SetPoint("BOTTOMRIGHT", -10, 10)
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

function GINVITER_Command(args)
    if (args == "stop") then
        GINVITER_StopSearch()
    elseif (args == "start") then
        GINVITER_StartSearch()
    else
        statusText:SetText("GINVITER")
        errorText:SetText("Usage: /GINVITER [start/stop]")
    end
end

function GINVITER_StartSearch()
    if (CanGuildInvite() == false) then
        errorText:SetText("You can't invite at the moment.")
        return
    end
    statusText:SetText("Searching")
    searching = true
    lastSearchTime = time()
    GINVITER_SendSearch()
end

function GINVITER_StopSearch()
    searching = false
    statusText:SetText("Stopped")
end

function GINVITER_OnUpdate(args)
    if (searching == true) then
        timeLeft = lastSearchTime + loopInterval - time()
        if (timeLeft < 0) then
            if (CanGuildInvite() == false) then
                GINVITER_StopSearch()
                errorText:SetText("You can't invite anymore, stopping.")
            else
                GINVITER_SendSearch()
            end
        else
            timeValue:SetText(string.format("%.0f", timeLeft))
            errorText:SetText("")
        end
    end
end

function GINVITER_SendSearch()
    SetWhoToUI(1)
    FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")

    -- Get the next zone to search
    local zone = zones[currentZone]
    currentZone = currentZone + 1
    if (currentZone > #zones) then
        currentZone = 1
    end

    local whoString = "g-\"\" " .. level .. "-" .. level .. " z-\"" .. zone .. "\""
    statusText:SetText("Searching in\n" .. zone)
    lastSearchTime = time()
    SendWho(whoString)
end

function GINVITER_OnEvent(args)
    if (searching == false) then return end
    GINVITER_InviteWhoResults()
end

function GINVITER_InviteWhoResults()
    local numWhos = GetNumWhoResults()
    local invitesSent = 0  -- Counter for guild invites sent per search

    for index = 1, numWhos, 1 do
        local charname, guildname, level, race, class, zone, classFileName = GetWhoInfo(index)

        -- Check if the player is already invited or in the exclude list
        if (guildname == "" and zone ~= "Dalaran Arena" and not excludeList[charname]) then
            GuildInvite(charname)
            excludeList[charname] = true  -- Add the player to the exclude list
            invitesSent = invitesSent + 1

            if invitesSent >= 2 then
                break  -- Limit invites to two per search
            end
        end
    end
end

frame:SetScript("OnUpdate", GINVITER_OnUpdate)
frame:RegisterEvent("WHO_LIST_UPDATE")
frame:SetScript("OnEvent", GINVITER_OnEvent)
SLASH_GINVITER1 = "/GINVITER"
SlashCmdList["GINVITER"] = GINVITER_Command
frame:SetFrameStrata("LOW")
frame:SetClampedToScreen(true)
