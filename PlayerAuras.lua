local addonName, CUI = ...

CUI.PA = {}
local PA = CUI.PA
local Util = CUI.Util

local function StyleFrame(frame)
    frame.Icon:SetTexCoord(.08, .92, .08, .92)
    local overlay = CreateFrame("Frame", nil, frame)
    overlay:SetParentKey("Overlay")
    overlay:SetAllPoints(frame.Icon)
    Util.AddBackdrop(overlay, 1, CUI_BACKDROP_DS_2)
    frame.Count:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
    frame.Duration:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")

    if InCombatLockdown() then 
        frame.Icon:SetAlpha(1) 
    else
        frame.Icon:SetAlpha(0.5)
    end

    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:HookScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_ENABLED" then
            self.Icon:SetAlpha(0.5)
        elseif event == "PLAYER_REGEN_DISABLED" then
            self.Icon:SetAlpha(1)
        end
    end)
end

function PA.Load()
    BuffFrame.CollapseAndExpandButton:SetAlpha(0)

    for _, frame in pairs({BuffFrame.AuraContainer:GetChildren()}) do
        StyleFrame(frame)
    end

    for _, frame in pairs({DebuffFrame.AuraContainer:GetChildren()}) do
        StyleFrame(frame)
    end
end