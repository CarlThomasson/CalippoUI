local addonName, CUI = ...

CUI.DB = {}
CUI.Const = {}
local DB = CUI.DB
local Const = CUI.Const

function DB.Load()
    if not CalippoDB then
        CalippoDB = {}
    end

    if not CalippoDB.ActionBars then
        CalippoDB.ActionBars = {}
        CalippoDB.ActionBars.Enabled = true

        CalippoDB.ActionBars.MainActionBar = {}
        CalippoDB.ActionBars.MainActionBar.Alpha = 1
        CalippoDB.ActionBars.MainActionBar.CombatAlpha = 1

        CalippoDB.ActionBars.MultiBarBottomLeft = {}
        CalippoDB.ActionBars.MultiBarBottomLeft.Alpha = 1
        CalippoDB.ActionBars.MultiBarBottomLeft.CombatAlpha = 1

        CalippoDB.ActionBars.MultiBarBottomRight = {}
        CalippoDB.ActionBars.MultiBarBottomRight.Alpha = 1
        CalippoDB.ActionBars.MultiBarBottomRight.CombatAlpha = 1

        CalippoDB.ActionBars.MultiBarRight = {}
        CalippoDB.ActionBars.MultiBarRight.Alpha = 1
        CalippoDB.ActionBars.MultiBarRight.CombatAlpha = 1

        CalippoDB.ActionBars.MultiBarLeft = {}
        CalippoDB.ActionBars.MultiBarLeft.Alpha = 1
        CalippoDB.ActionBars.MultiBarLeft.CombatAlpha = 1

        CalippoDB.ActionBars.MultiBar5 = {}
        CalippoDB.ActionBars.MultiBar5.Alpha = 1
        CalippoDB.ActionBars.MultiBar5.CombatAlpha = 1

        CalippoDB.ActionBars.MultiBar6 = {}
        CalippoDB.ActionBars.MultiBar6.Alpha = 1
        CalippoDB.ActionBars.MultiBar6.CombatAlpha = 1

        CalippoDB.ActionBars.MultiBar7 = {}
        CalippoDB.ActionBars.MultiBar7.Alpha = 1
        CalippoDB.ActionBars.MultiBar7.CombatAlpha = 1

        CalippoDB.ActionBars.MicroMenu = {}
        CalippoDB.ActionBars.MicroMenu.Alpha = 1
        CalippoDB.ActionBars.MicroMenu.CombatAlpha = 1
    end

    if not CalippoDB.UnitFrames then
        CalippoDB.UnitFrames = {}
        CalippoDB.UnitFrames.Enabled = true

        CalippoDB.UnitFrames.AuraSize = 20
        CalippoDB.UnitFrames.AuraPadding = 2
        CalippoDB.UnitFrames.AuraRowLength = 8

        CalippoDB.UnitFrames.PlayerFrame = {}
        CalippoDB.UnitFrames.PlayerFrame.Alpha = 1
        CalippoDB.UnitFrames.PlayerFrame.OffsetX = 0
        CalippoDB.UnitFrames.PlayerFrame.OffsetY = 0
        CalippoDB.UnitFrames.PlayerFrame.SizeX = 200
        CalippoDB.UnitFrames.PlayerFrame.SizeY = 50

        CalippoDB.UnitFrames.TargetFrame = {}
        CalippoDB.UnitFrames.TargetFrame.Alpha = 1
        CalippoDB.UnitFrames.TargetFrame.OffsetX = 0
        CalippoDB.UnitFrames.TargetFrame.OffsetY = 0
        CalippoDB.UnitFrames.TargetFrame.SizeX = 200
        CalippoDB.UnitFrames.TargetFrame.SizeY = 50

        CalippoDB.UnitFrames.FocusFrame = {}
        CalippoDB.UnitFrames.FocusFrame.Alpha = 1
        CalippoDB.UnitFrames.FocusFrame.OffsetX = 0
        CalippoDB.UnitFrames.FocusFrame.OffsetY = 0
        CalippoDB.UnitFrames.FocusFrame.SizeX = 150
        CalippoDB.UnitFrames.FocusFrame.SizeY = 40
    end

    if not CalippoDB.GroupFrames then
        CalippoDB.GroupFrames = {}
        CalippoDB.GroupFrames.Enabled = true
    end

    if not CalippoDB.CooldownManager then
        CalippoDB.CooldownManager = {}
        CalippoDB.CooldownManager.Enabled = true

        CalippoDB.CooldownManager.EssentialCooldownViewer = {}
        CalippoDB.CooldownManager.EssentialCooldownViewer.Alpha = 1

        CalippoDB.CooldownManager.UtilityCooldownViewer = {}
        CalippoDB.CooldownManager.UtilityCooldownViewer.Alpha = 1

        CalippoDB.CooldownManager.BuffIconCooldownViewer = {}
        CalippoDB.CooldownManager.BuffIconCooldownViewer.Alpha = 1
    end

    if not CalippoDB.Chat then
        CalippoDB.Chat = {}
        CalippoDB.Chat.Enabled = true
    end

    if not CalippoDB.PlayerAuras then
        CalippoDB.PlayerAuras = {}
        CalippoDB.PlayerAuras.Enabled = true

        CalippoDB.PlayerAuras.Alpha = 1
    end

    if not CalippoDB.NamePlates then
        CalippoDB.NamePlates = {}
        CalippoDB.NamePlates.Enabled = true
    end  
    
    if not CalippoDB.Minimap then
        CalippoDB.Minimap = {}
        CalippoDB.Minimap.Enabled = true

        CalippoDB.Minimap.Alpha = 1
    end  

    if not CalippoDB.CastBar then
        CalippoDB.CastBar = {}
        CalippoDB.CastBar.Enabled = true
    end  

    if not CalippoDB.ResourceBar then
        CalippoDB.ResourceBar = {}
        CalippoDB.ResourceBar.Enabled = true

        CalippoDB.ResourceBar.Alpha = 1
        CalippoDB.ResourceBar.Height = 20
        CalippoDB.ResourceBar.FontSize = 12
    end  

    if not CalippoDB.AutoWhisper then
        CalippoDB.AutoWhisper = {}
        CalippoDB.AutoWhisper.Enabled = false
    end

    CUI_BACKDROP_DS_3 = {
        edgeFile = "Interface/AddOns/CalippoUI/Media/DropShadowBorder.blp", 
        edgeSize = 3, 
        bgFile = nil
    }

    CUI_BACKDROP_DS_2 = {
        edgeFile = "Interface/AddOns/CalippoUI/Media/DropShadowBorder.blp", 
        edgeSize = 2, 
        bgFile = nil
    }

    CUI_BACKDROP_DS_1 = {
        edgeFile = "Interface/AddOns/CalippoUI/Media/DropShadowBorder.blp", 
        edgeSize = 1, 
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