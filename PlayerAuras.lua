local addonName, CUI = ...

CUI.PA = {}
local PA = CUI.PA
local Util = CUI.Util

---------------------------------------------------------------------------------------------------

function PA.UpdateAlpha(frame, inCombat)
    if InCombatLockdown() or inCombat then 
        UIFrameFadeIn(frame, 0.6, frame:GetAlpha(), 1)
    else
        UIFrameFadeOut(frame, 0.6, frame:GetAlpha(), CalippoDB.PlayerAuras.Alpha)
    end
end

---------------------------------------------------------------------------------------------------

local function StyleFrame(frame)
    frame.Icon:SetTexCoord(.08, .92, .08, .92)
    local overlay = CreateFrame("Frame", nil, frame)
    overlay:SetParentKey("Overlay")
    overlay:SetAllPoints(frame.Icon)
    Util.AddBackdrop(overlay, 1, CUI_BACKDROP_DS_2)
    frame.Count:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
    frame.Duration:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
end

local function AddCombatAlpha(frame)
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:HookScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_ENABLED" then
            PA.UpdateAlpha(self)
        elseif event == "PLAYER_REGEN_DISABLED" then
            PA.UpdateAlpha(self, true)
        end
    end)

    PA.UpdateAlpha(frame)
end

---------------------------------------------------------------------------------------------------

function PA.Load()
    BuffFrame.CollapseAndExpandButton:SetAlpha(0)

    AddCombatAlpha(BuffFrame)
    AddCombatAlpha(DebuffFrame)

    for _, frame in pairs({BuffFrame.AuraContainer:GetChildren()}) do
        StyleFrame(frame)
    end

    for _, frame in pairs({DebuffFrame.AuraContainer:GetChildren()}) do
        StyleFrame(frame)
    end
end