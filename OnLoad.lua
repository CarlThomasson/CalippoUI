local addonName, CUI = ...

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, isLogin, isReload)
    if isLogin or isReload then
        -- Database
        CUI.DB.Load()

        -- Chat
        if CalippoDB.Chat.Enabled then
            CUI.Chat.Load()
        end

        -- UnitFrames
        if CalippoDB.UnitFrames.Enabled then
            CUI.UF.Load()
        end

        -- GroupFrames
        if CalippoDB.GroupFrames.Enabled then
            CUI.GF.Load()
        end

        -- ActionBars
        if CalippoDB.ActionBars.Enabled then
            CUI.AB.Load()
        end

        -- CooldownManager
        if CalippoDB.CooldownManager.Enabled then
            CUI.CDM.Load()
        end

        -- Resources
        if CalippoDB.ResourceBar.Enabled then
            CUI.RB.Load()
        end

        -- CastBar
        if CalippoDB.CastBar.Enabled then
            CUI.CB.Load()
        end

        -- Minimap
        if CalippoDB.Minimap.Enabled then
            CUI.MM.Load()
        end

        -- PlayerAuras
        if CalippoDB.PlayerAuras.Enabled then
            CUI.PA.Load()
        end

        -- NamePlates
        if CalippoDB.NamePlates.Enabled then
            CUI.NP.Load()
        end

        -- Config
        CUI.Conf.Load()
    end
end)

-- SLASH_CALIPPOUI1 = "/cui"
-- function SlashCmdList.CALIPPOUI(msg, editbox)
--     if CUI_OptionsFrame:IsShown() then
--         CUI_OptionsFrame:Hide()
--     else
--         CUI_OptionsFrame:Show()
--     end
-- end