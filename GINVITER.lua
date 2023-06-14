-- GInviter.lua
-- Author: nelbin4
-- Version: 1.X
-- This addon is for World of Warcraft client patch 3.3.5a (Wrath of the Lich King)
-- Description: GInviter is an addon that facilitates automatic guild member recruitment in World of Warcraft.
-- It searches for potential recruits based on specified criteria, such as zone or class, and sends guild invitations accordingly.
-- This file contains the main functionality of the GInviter addon, including search, exclusion lists, UI elements, and event handling.
-- For more information and updates, visit github.com/nelbin4/ginviter.
--
-- ###########################################################
-- ## Variables
-- ###########################################################
--
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

-- ###########################################################

local initialSearchZone = { unpack(SearchZone) }
local initialSearchClass = { unpack(SearchClass) }
local searching = false
local searchStarted = false
local lastSearchTime = 0
local timeLeft = 0
local currentZone = 1
local currentClass = 1
local excludeList = {}

-- Create the main frame
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

-- Create the title bar
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

-- Create the title text
local titleText = titleBar:CreateFontString(nil, "ARTWORK", "GameFontNormal")
titleText:SetPoint("CENTER", titleBar, "CENTER")
titleText:SetText("GInviter")
titleText:SetTextColor(1, 1, 1)

-- Create the minimize button
local minimizeButton = CreateFrame("Button", nil, frame)
minimizeButton:SetSize(25, 25)
minimizeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
minimizeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
minimizeButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
minimizeButton:SetScript("OnClick", function() frame:Hide() end)

-- Create the status text
local statusText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
statusText:SetPoint("TOP", titleBar, "BOTTOM", 0, -10)
statusText:SetJustifyH("CENTER")
statusText:SetText("Stopped")

-- Create the time text
local timeText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
timeText:SetPoint("TOP", statusText, "BOTTOM", 0, -10)
timeText:SetJustifyH("CENTER")
timeText:SetText("Time left:")

-- Create the time value
local timeValue = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
timeValue:SetPoint("TOP", timeText, "BOTTOM", 0, -5)
timeValue:SetJustifyH("CENTER")
timeValue:SetText("-")

-- Create the error text
local errorText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
errorText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
errorText:SetJustifyH("RIGHT")
errorText:SetText("")

-- Create the start button
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

-- Create the stop button
local stopButton = CreateFrame("Button", "GINVITERStopButton", frame, "UIPanelButtonTemplate")
stopButton:SetSize(60, 20)
stopButton:SetPoint("BOTTOMLEFT", startButton, "BOTTOMRIGHT", 5, 0)
stopButton:SetText("Stop")
if not searchStarted then
    stopButton:Disable()
else
    stopButton:Enable()
end
stopButton:SetScript("OnClick", function() GINVITER_StopSearch(); GINVITER_StopSearch() end)

-- Function to add a player to the exclude list
local function GINVITER_AddToExcludeList(playerName)
    excludeList[playerName] = (excludeList[playerName] or 0) + 1
end

-- Function to check if a player is excluded from invites
local function GINVITER_IsExcluded(playerName)
    return excludeList[playerName] and excludeList[playerName] >= maxInvites
end

-- Function to handle the GINVITER command
local function GINVITER_Command(args)
    if (args == "show") then
        frame:Show() -- Show the frame
    elseif (args == "hide") then
        frame:Hide() -- Hide the frame
    else
        ChatFrame1:AddMessage("Usage: /GINVITER [show/hide]") -- Display usage instructions in the chat
    end
end

-- Function to start the search
function GINVITER_StartSearch()
    if CanGuildInvite() then
        local initialSearchZone = table.clone(SearchZone) -- Create a clone of the SearchZone table
        local initialSearchClass = table.clone(SearchClass) -- Create a clone of the SearchClass table
        statusText:SetText("Searching") -- Set the status text to indicate searching
        searching = true -- Set searching flag to true
        lastSearchTime = time() -- Set the last search time to the current time
        GINVITER_SendSearch() -- Initiate the search
        timeLeft = 0 -- Reset the time left
        currentZone = 1 -- Reset the current zone index
        currentClass = 1 -- Reset the current class index
        startButton:Disable()  -- Disable the Start button
        stopButton:Enable()  -- Enable the Stop button
    else
        GINVITER_StopSearch() -- Stop the search if not in a guild
        print("We are not in a guild. Join a guild to use GInviter.") -- Display a message indicating not in a guild
    end
end

-- Function to stop the search
function GINVITER_StopSearch()
    searching = false
    statusText:SetText("Stopped")
    startButton:Enable()  -- Enable the Start button
    stopButton:Disable()  -- Disable the Stop button
end

-- Function to restart the search
function GINVITER_RestartSearch()
    if CanGuildInvite() then
        excludeList = {} -- Clear the exclude list
		searching = true -- Set searching flag to true
        lastSearchTime = time() -- Reset the last search time
        GINVITER_SendSearch() -- Initiate a new search
        timeLeft = 0 -- Reset the time left
        currentZone = 1 -- Reset the current zone index
        currentClass = 1 -- Reset the current class index
		print("GInviter: Restarting..") -- Display a message indicating restart
    else
        GINVITER_StopSearch() -- Stop the search if not in a guild
        print("We are not in a guild. Join a guild to use GInviter.") -- Display a message indicating not in a guild
    end
end

-- Table cloning function for restart purposes
function table.clone(...)
    -- Collect the tables to be cloned
    local clones = {...}
    -- Create a new table to store the cloned result
    local result = {}
    
    -- Iterate over each table to be cloned
    for i, clone in ipairs(clones) do
        -- Iterate over the key-value pairs of each table
        for key, value in pairs(clone) do
            -- If the value is a table, recursively clone it
            if type(value) == "table" then
                result[key] = table.clone(value) -- Recursively clone nested tables
            else
                result[key] = value -- Copy non-table values directly
            end
        end
    end
    
    -- Return the cloned result table
    return result
end

-- Function to send the search query
function GINVITER_SendSearch()
    SetWhoToUI(1)
    FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")

    local whoString = ""
    if (SearchMode == "zone") then
        -- Randomly select a zone from the remaining list
        local zoneIndex = math.random(1, #SearchZone)
        local zone = SearchZone[zoneIndex]
        table.remove(SearchZone, zoneIndex) -- Remove the selected zone from the list
        -- Construct the search query string for zone search mode
        whoString = "g-\"\" " .. level .. " z-\"" .. zone .. "\""
        statusText:SetText("Searching in\n" .. zone)
    elseif (SearchMode == "class") then
        -- Randomly select a class from the remaining list
        local classIndex = math.random(1, #SearchClass)
        local class = SearchClass[classIndex]
        table.remove(SearchClass, classIndex) -- Remove the selected class from the list
        -- Construct the search query string for class search mode
        whoString = "g-\"\" " .. level .. " c-\"" .. class .. "\""
        statusText:SetText("Searching for\n" .. class)
    end
	-- Send who string
    lastSearchTime = time()
    SendWho(whoString)
end

-- Function to handle the update
local function GINVITER_OnUpdate(args)
    if searching then
        -- Check if the guild is full. Stop when reached 1001 members
        local numGuildMembers, _, _ = GetNumGuildMembers()
        if numGuildMembers >= 1001 then
            GINVITER_StopSearch()
            statusText:SetText("Guild Full")
            return
        end

        local timeLeft = lastSearchTime + loopInterval - time()
        if timeLeft < 0 then
            -- Check if the player has guild invite privileges
            if CanGuildInvite() then
                GINVITER_SendSearch() -- Send the search query
            else
                GINVITER_StopSearch()
                print("We don't have /ginvite privileges. Ask the Guild Master or an Officer.")
            end
        else
            timeValue:SetText(string.format("%.0f", timeLeft)) -- Update remaining time display
			errorText:SetText("") -- Clear error message
        end
    end

    -- Check if the search has completed for both modes and restart the search
    if not searching and (#SearchZone == 0 or #SearchClass == 0) then
        if #SearchZone == 0 then
            SearchZone = table.clone(initialSearchZone) -- Reset SearchZone to initial values
        end
        if #SearchClass == 0 then
            SearchClass = table.clone(initialSearchClass) -- Reset SearchClass to initial values
        end

        GINVITER_RestartSearch() -- Restart the search
    end
end

-- Function to handle the event
function GINVITER_OnEvent(args)
    -- If not currently searching, return and do nothing
    if searching == false then
        return
    end
    GINVITER_InviteWhoResults() -- Process the WHO_LIST_UPDATE event and invite eligible players
end

function GINVITER_OnLoad()
end

function GINVITER_InviteWhoResults()
    -- Get the number of results from the /who command
    local numWhos = GetNumWhoResults()

    -- Loop through each result
    for index = 1, numWhos, 1 do
        -- Get information about the character
        local charname, guildname, level, race, class, zone, classFileName = GetWhoInfo(index)
        
        -- Check if the character is not in a guild and is not excluded and the zone is not excluded
        if (guildname == "" and not GINVITER_IsExcluded(charname) and not IsZoneExcluded(zone)) then
            -- Add the character to the exclude list to avoid inviting them again
            GINVITER_AddToExcludeList(charname)
            -- Send a guild invite to the character
            GuildInvite(charname)
        end
    end
end

function IsZoneExcluded(zone)
    -- Loop through each excluded zone in the excludedZones table
    for _, excludedZone in ipairs(excludedZones) do
        -- Check if the current zone matches an excluded zone
        if zone == excludedZone then
            -- If a match is found, return true
            return true
        end
    end
    -- If no match is found, return false
    return false
end


frame:SetScript("OnUpdate", GINVITER_OnUpdate) -- Set the update script to execute GINVITER_OnUpdate function
frame:SetScript("OnEvent", GINVITER_OnEvent) -- Set the event script to execute GINVITER_OnEvent function
frame:SetScript("OnLoad", GINVITER_OnLoad) -- Set the load script to execute GINVITER_OnLoad function
frame:RegisterEvent("WHO_LIST_UPDATE") -- Register the "WHO_LIST_UPDATE" event to be tracked by the frame
frame:SetFrameStrata("LOW") -- Set the frame's strata to "LOW" to make it appear behind other frames
frame:SetClampedToScreen(true) -- Clamp the frame's position within the screen boundaries
SLASH_GINVITER1 = "/GINVITER" -- Define the slash command "/GINVITER"
SlashCmdList["GINVITER"] = GINVITER_Command -- Associate the slash command with the GINVITER_Command function

print("|cff00ff00GInviter loaded.|r Use /GINVITER. Modify file ginviter.lua inside addon folder. Check github.com/nelbin4/ginviter for updates.")
-- Print a message to the chat frame indicating that GInviter has been loaded and provide instructions for usage and updates.
