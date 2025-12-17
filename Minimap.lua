local addonName, CUI = ...

CUI.MM = {}
local MM = CUI.MM
local Util = CUI.Util

---------------------------------------------------------------------------------------------------

function MM.UpdateAlpha(frame, inCombat)
    if InCombatLockdown() or inCombat then 
        Util.FadeFrame(frame, "IN", CUI.DB.profile.Minimap.CombatAlpha)
    else
        Util.FadeFrame(frame, "OUT", CUI.DB.profile.Minimap.Alpha)
    end
end

---------------------------------------------------------------------------------------------------

local function SetupMinimap()
    MinimapBackdrop:Hide()
    MinimapCompassTexture:Hide()

    MinimapCluster.MinimapContainer:SetAllPoints(MinimapCluster)

    MinimapCluster.BorderTop:Hide()

    MinimapCluster.Tracking.Button:ClearAllPoints()
    MinimapCluster.Tracking.Button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 30, 0)
    MinimapCluster.Tracking.Button:SetAlpha(0)
    MinimapCluster.Tracking.Button:SetAlpha(0)
    MinimapCluster.Tracking.Background:Hide()

    MinimapCluster.ZoneTextButton:Hide()
    MinimapCluster.MinimapContainer:SetAllPoints(MinimapCluster)

    MinimapCluster.InstanceDifficulty:ClearAllPoints()
    MinimapCluster.InstanceDifficulty:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 1, 1)

    MinimapCluster.IndicatorFrame:ClearAllPoints()
    MinimapCluster.IndicatorFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 2, -2)

    TimeManagerClockButton:ClearAllPoints()
    TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 5)

    local clockText = TimeManagerClockButton:GetRegions()
    clockText:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")

    GameTimeFrame:ClearAllPoints()
    GameTimeFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -30, 0)
    GameTimeFrame:SetAlpha(0)

    Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")
    Util.AddBorder(Minimap)

    Minimap:ClearAllPoints()
    Minimap:SetPoint("TOPRIGHT", MinimapCluster.MinimapContainer, "TOPRIGHT")

    MinimapCluster:RegisterEvent("PLAYER_REGEN_ENABLED")
    MinimapCluster:RegisterEvent("PLAYER_REGEN_DISABLED")
    MinimapCluster:HookScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_ENABLED" then
            MM.UpdateAlpha(self)
        elseif event == "PLAYER_REGEN_DISABLED" then
            MM.UpdateAlpha(self, true)
        end
    end)
    MM.UpdateAlpha(MinimapCluster)

    Minimap:HookScript("OnEnter", function(self)
        MinimapCluster.Tracking.Button:SetAlpha(1)
        GameTimeFrame:SetAlpha(1)
    end)

    Minimap:HookScript("OnLeave", function(self)
        MinimapCluster.Tracking.Button:SetAlpha(0)
        GameTimeFrame:SetAlpha(0)
    end)
end

---------------------------------------------------------------------------------------------------

function MM.Load()
    SetupMinimap()

    EditModeManagerFrame:HookScript("OnHide", function(self)
        SetupMinimap()
    end)
end