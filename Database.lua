local addonName, CUI = ...

CUI.DB = {}
CUI.Const = {}
local DB = CUI.DB
local Const = CUI.Const

function DB.OnLoad()
    if not CalippoDB then
        CalippoDB = {}
    end

    if not CalippoDB.BarAlpha then
        CalippoDB.BarAlpha = 0
    end

    if not CalippoDB.playerFrame then
        CalippoDB.playerFrame = {}
        CalippoDB.playerFrame.posX = -258
        CalippoDB.playerFrame.posY = -156
        CalippoDB.playerFrame.sizeX = 195
        CalippoDB.playerFrame.sizeY = 50
    end

    if not CalippoDB.targetFrame then
        CalippoDB.targetFrame = {}
        CalippoDB.targetFrame.posX = 258
        CalippoDB.targetFrame.posY = -156
        CalippoDB.targetFrame.sizeX = 195
        CalippoDB.targetFrame.sizeY = 50
        
    end

    if not CalippoDB.partyFrame then
        CalippoDB.partyFrame = {}
        CalippoDB.partyFrame.posX = -380
        CalippoDB.partyFrame.posY = 220
        CalippoDB.partyFrame.sizeX = 175
        CalippoDB.partyFrame.sizeY = 70
    end

    if not CalippoDB.raidFrame then
        CalippoDB.raidFrame = {}
        CalippoDB.raidFrame.posX = -700
        CalippoDB.raidFrame.posY = 220
        CalippoDB.raidFrame.sizeX = 100
        CalippoDB.raidFrame.sizeY = 60
    end

    if not CalippoDB.AutoWhisper then
        CalippoDB.AutoWhisper = false
    end

    if not CalippoDB.IsEnabled then
        CalippoDB.IsEnabled = {}
        CalippoDB.IsEnabled.Chat = true
        CalippoDB.IsEnabled.UnitFrame = true
        CalippoDB.IsEnabled.GroupFrame = true
        CalippoDB.IsEnabled.Bars = true
    end

    Const.cUnit = {
        ["player"] = "Player",
        ["target"] = "Target",
        ["party"] = "Party",
        ["raid"] = "Raid",
    }

    Const.BuffWhitelist = {
        -- Paladin
        [53563] = "Beacon of Light",
        [156910] = "Beacon of Faith",
        [200025] = "Beacon of Virtue",

        -- Shaman
        [61295] = "Riptide",
        [974] = "Earth Shield (Player)",
        [383648] = "Earth Shield (Other)",

        -- Monk
        [119611] = "Renewing Mist",
    }

    Const.DebuffBlacklist = {
        [57723] = "Exhaustion",
        [57724] = "Sated",
        [80354] = "Temporal Displacement",
        [264689] = "Fatigued",
        [390435] = "Exhaustion",
        [206151] = "Challenger's Burden",
    }

    CUI_BACKDROP_DS_3 = {
        edgeFile = "Interface/AddOns/CalippoUI/Media/DropShadowBorder.blp", 
        edgeSize = 3, 
        bgFile = nil
    }

    CUI_BACKDROP_W_2 = {
        edgeFile = "Interface/AddOns/CalippoUI/Media/white.blp", 
        edgeSize = 2, 
        bgFile = nil
    }

    CUI_BACKDROP_W_1 = {
        edgeFile = "Interface/AddOns/CalippoUI/Media/white.blp", 
        edgeSize = 1, 
        bgFile = nil
    }

    CUI_BACKDROP_W_06 = {
        edgeFile = "Interface/AddOns/CalippoUI/Media/white.blp", 
        edgeSize = 0.6, 
        bgFile = nil
    }

    CUI_BACKDROP_B_1 = {
        edgeFile = "Interface/AddOns/CalippoUI/Media/black.blp", 
        edgeSize = 1, 
        bgFile = nil
    }

    CUI_BACKDROP_B_06 = {
        edgeFile = "Interface/AddOns/CalippoUI/Media/black.blp", 
        edgeSize = 0.6, 
        bgFile = nil
    }
end