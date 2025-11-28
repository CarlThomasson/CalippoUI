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
    MinimapCluster.ZoneTextButton:Hide()
    MinimapCluster.MinimapContainer:SetPoint("TOP", MinimapCluster, "TOP", 0, 0)
    MinimapCluster:SetAlpha(0.8)

    TimeManagerClockButton:ClearAllPoints()
    TimeManagerClockButton:SetPoint("TOP", Minimap, "BOTTOM")
    local clockText = TimeManagerClockButton:GetRegions()
    clockText:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
    GameTimeFrame:SetAlpha(0)

    -- for _, frame in pairs({Minimap:GetChildren()}) do
    --     frame:Hide()
    -- end

    Minimap:HookScript("OnEnter", function(self)
        MinimapCluster.Tracking.Button:SetAlpha(1)
        MinimapCluster.Tracking.Button:SetAlpha(1)
        GameTimeFrame:SetAlpha(1)

        -- for _, frame in pairs({self:GetChildren()}) do
        --     frame:Show()
        -- end
    end)

    Minimap:HookScript("OnLeave", function(self)
        MinimapCluster.Tracking.Button:SetAlpha(0)
        MinimapCluster.Tracking.Button:SetAlpha(0)
        GameTimeFrame:SetAlpha(0)

        -- for _, frame in pairs({self:GetChildren()}) do
        --     frame:Hide()
        -- end
    end)
end