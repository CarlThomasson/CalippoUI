local addonName, CUI = ...

CUI.MM = {}
local MM = CUI.MM
local Util = CUI.Util

function MM.Load()
    MinimapBackdrop:Hide()
    MinimapCompassTexture:Hide()

    MinimapCluster.BorderTop:Hide()
    MinimapCluster.Tracking.Button:ClearAllPoints()
    MinimapCluster.Tracking.Button:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
    MinimapCluster.Tracking.Button:SetAlpha(0)
    MinimapCluster.Tracking.Button:SetAlpha(0)
    MinimapCluster.Tracking.Background:Hide()
    MinimapCluster.ZoneTextButton:Hide()
    MinimapCluster.MinimapContainer:SetAllPoints(MinimapCluster)
    MinimapCluster:SetSize(200, 200)
    MinimapCluster:SetAlpha(0.8)

    TimeManagerClockButton:ClearAllPoints()
    TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 5)
    local clockText = TimeManagerClockButton:GetRegions()
    clockText:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
    GameTimeFrame:ClearAllPoints()
    GameTimeFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT")
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
end