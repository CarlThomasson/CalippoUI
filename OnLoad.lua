local addonName, CUI = ...

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, isLogin, isReload)
    if isLogin or isReload then
        CUI.DB.OnLoad()

        if CalippoDB.IsEnabled.Chat then
            CUI.Chat.OnLoad()
        end

        if CalippoDB.IsEnabled.UnitFrame then
            CUI.UF.OnLoad()
        end

        if CalippoDB.IsEnabled.GroupFrame then
            CUI.GF.OnLoad()
        end

        if CalippoDB.IsEnabled.Bars then
            CUI.Bars.OnLoad()
        end

        CUI.Menu.OnLoad()
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