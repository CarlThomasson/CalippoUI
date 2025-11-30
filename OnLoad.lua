local addonName, CUI = ...

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, isLogin, isReload)
    if isLogin or isReload then
        CUI.DB.Load()

        -- Chat
        if CalippoDB.IsEnabled.Chat then
            CUI.Chat.Load()
        end

        -- UnitFrames
        if CalippoDB.IsEnabled.UnitFrame then
            CUI.UF.Load()
        end

        -- GroupFrames
        if CalippoDB.IsEnabled.GroupFrame then
            CUI.GF.Load()
        end

        -- ActionBars
        if CalippoDB.IsEnabled.Bars then
            CUI.Bars.Load()
        end

        -- CooldownManager
        CUI.CDM.Load()

        -- Resources
        CUI.RES.Load()

        -- CastBar
        CUI.CB.Load()

        -- Minimap
        CUI.MM.Load()

        -- PlayerAuras
        CUI.PA.Load()

        -- NamePlates
        CUI.NP.Load()

        -- Menu
        CUI.Menu.Load()
    end
end)

SLASH_CALIPPOUI1 = "/cui"
function SlashCmdList.CALIPPOUI(msg, editbox)
    if CUI_OptionsFrame:IsShown() then
        CUI_OptionsFrame:Hide()
    else
        CUI_OptionsFrame:Show()
    end
end