local addonName, CUI = ...

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, isLogin, isReload)
    if isLogin or isReload then
        CUI.DB.Load()

        if CalippoDB.IsEnabled.Chat then
            CUI.Chat.Load()
        end

        if CalippoDB.IsEnabled.UnitFrame then
            CUI.UF.Load()
        end

        if CalippoDB.IsEnabled.GroupFrame then
            CUI.GF.Load()
        end

        if CalippoDB.IsEnabled.Bars then
            CUI.Bars.Load()
        end

        CUI.CDM.Load()

        CUI.RES.Load()

        CUI.CB.Load()

        CUI.MM.Load()

        CUI.PA.Load()

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