local addonName, CUI = ...

CUI.MM = {}
local MM = CUI.MM
local Util = CUI.Util

---------------------------------------------------------------------------------------------------

function MM.UpdateAlpha(frame, inCombat)
    if InCombatLockdown() or inCombat then 
        UIFrameFadeIn(frame, 0.6, frame:GetAlpha(), 1)
    else
        UIFrameFadeOut(frame, 0.6, frame:GetAlpha(), CalippoDB.Minimap.Alpha)
    end
end

---------------------------------------------------------------------------------------------------

function MM.Load()
    MinimapBackdrop:Hide()
    MinimapCompassTexture:Hide()

    MinimapCluster.BorderTop:Hide()
    MinimapCluster.Tracking.Button:ClearAllPoints()
    MinimapCluster.Tracking.Button:SetPoint("TOPLEFT", MinimapCluster, "TOPLEFT")
    MinimapCluster.Tracking.Button:SetAlpha(0)
    MinimapCluster.Tracking.Button:SetAlpha(0)
    MinimapCluster.Tracking.Background:Hide()
    MinimapCluster.ZoneTextButton:Hide()
    MinimapCluster.MinimapContainer:SetAllPoints(MinimapCluster)
    MinimapCluster.InstanceDifficulty:ClearAllPoints()
    MinimapCluster.InstanceDifficulty:SetPoint("TOPRIGHT", MinimapCluster, "TOPRIGHT")
    MinimapCluster:SetSize(200, 200)

    MinimapCluster:HookScript("OnShow", function(self)
        MinimapCluster:SetSize(200, 200)
    end)

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

    TimeManagerClockButton:ClearAllPoints()
    TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 5)
    local clockText = TimeManagerClockButton:GetRegions()
    clockText:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
    GameTimeFrame:ClearAllPoints()
    GameTimeFrame:SetPoint("TOPRIGHT", MinimapCluster, "TOPRIGHT", -30, 0)
    GameTimeFrame:SetAlpha(0)

    Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')
    Util.AddBackdrop(Minimap, 1, CUI_BACKDROP_DS_3)

    Minimap:HookScript("OnEnter", function(self)
        MinimapCluster.Tracking.Button:SetAlpha(1)
        GameTimeFrame:SetAlpha(1)
    end)

    Minimap:HookScript("OnLeave", function(self)
        MinimapCluster.Tracking.Button:SetAlpha(0)
        GameTimeFrame:SetAlpha(0)
    end)

    local cuiButton = CreateFrame("Button", "CUI_OptionsButton", Minimap)
    cuiButton:SetSize(30, 30)
    cuiButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT")
    
    
    cuiButton:SetScript("OnClick", function(self)
        CUI_OptionsFrame:Show()
    end)

end