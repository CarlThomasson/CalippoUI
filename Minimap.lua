local addonName, CUI = ...

CUI.MM = {}
local MM = CUI.MM

function MM.Load()
    MinimapBackdrop:Hide()
    MinimapCompassTexture:Hide()
    MinimapCluster.BorderTop:Hide()
    MinimapCluster.Tracking.Button:SetAlpha(0)
    MinimapCluster.Tracking.Button:SetAlpha(0)
    MinimapCluster.Tracking.Background:Hide()
    GameTimeFrame:SetAlpha(0)
end