local addonName, CUI = ...

CUI.AB = {}
local AB = CUI.AB
local Hide = CUI.Hide
local Util = CUI.Util

---------------------------------------------------------------------------------------------------

local function HideBlizzard()
    Hide.HideFrame(BagsBar)
    Hide.HideFrame(StanceBar)
    Hide.HideFrame(TalkingHeadFrame)
end

---------------------------------------------------------------------------------------------------

local microMenuButtons = {
    CharacterMicroButton,
    ProfessionMicroButton,
    PlayerSpellsMicroButton,
    AchievementMicroButton,
    QuestLogMicroButton,
    HousingMicroButton,
    GuildMicroButton,
    LFDMicroButton,
    CollectionsMicroButton,
    EJMicroButton,
    StoreMicroButton,
    MainMenuMicroButton,
}

AB.ActionBars = {
    [MainActionBar] = "ActionButton",
    [MultiBarBottomLeft] = "MultiBarBottomLeftButton",
    [MultiBarBottomRight] = "MultiBarBottomRightButton",
    [MultiBarRight] = "MultiBarRightButton",
    [MultiBarLeft] = "MultiBarLeftButton",
    [MultiBar5] = "MultiBar5Button",
    [MultiBar6] = "MultiBar6Button",
    [MultiBar7] = "MultiBar7Button",
    [PetActionBar] = "PetActionButton",
}

---------------------------------------------------------------------------------------------------

function AB.UpdateAlpha(frame, inCombat)
    if InCombatLockdown() or inCombat then 
        Util.FadeFrame(frame, "IN", CUI.DB.profile.ActionBars[frame:GetName()].CombatAlpha, 0.2)
    else
        Util.FadeFrame(frame, "OUT", CUI.DB.profile.ActionBars[frame:GetName()].Alpha, 0.2)
    end
end

function AB.UpdateBar(bar)
    local button = AB.ActionBars[bar]
    local dbEntry = CUI.DB.profile.ActionBars[bar:GetName()]

    local scale = _G[bar:GetName().."ButtonContainer1"]:GetScale()
    local width = _G[bar:GetName().."ButtonContainer1"]:GetWidth()
    local padding = dbEntry.Padding
    if bar.isHorizontal then
        bar:SetWidth(scale * ((math.ceil(bar.numButtonsShowable / bar.numRows) * (width + padding)) - padding))
        bar:SetHeight(scale * ((width + padding) * bar.numRows - padding))
    else
        bar:SetHeight(scale * ((math.ceil(bar.numButtonsShowable / bar.numRows) * (width + padding)) - padding))
        bar:SetWidth(scale * ((width + padding) * bar.numRows - padding))
    end

    for i=1, 12 do
        local frame = _G[button..i]
        if not frame then break end

        local container = _G[bar:GetName().."ButtonContainer"..i]

        if bar.isHorizontal then
            Util.PositionFromIndex(i-1, container, bar, "TOPLEFT", "TOPLEFT", "RIGHT", "DOWN", container:GetWidth(), dbEntry.Padding, 0, 0, math.ceil(bar.numButtonsShowable / bar.numRows))
        else
            Util.PositionFromIndex(i-1, container, bar, "TOPLEFT", "TOPLEFT", "RIGHT", "DOWN", container:GetWidth(), dbEntry.Padding, 0, 0, bar.numRows)
        end

        if dbEntry.Keybind.Enabled then
            frame.TextOverlayContainer.HotKey:SetAlpha(1)
            frame.TextOverlayContainer.HotKey:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", dbEntry.Keybind.Size, "OUTLINE")
            frame.TextOverlayContainer.HotKey:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
        else
            frame.TextOverlayContainer.HotKey:SetAlpha(0)
        end

        if dbEntry.Macro.Enabled then
            frame.Name:SetAlpha(1)
            frame.Name:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", dbEntry.Macro.Size, "OUTLINE")
            frame.Name:SetPoint("BOTTOM", frame, "BOTTOM", 0, 1)
        else
            frame.Name:SetAlpha(0)
        end

        if dbEntry.Charges.Enabled then
            frame.Count:SetAlpha(1)
            frame.Count:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", dbEntry.Charges.Size, "OUTLINE")
            frame.Count:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
        else
            frame.Count:SetAlpha(0)
        end

        if dbEntry.Cooldown.Enabled then
            frame.cooldown:GetRegions():SetAlpha(1)
            frame.cooldown:GetRegions():SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", dbEntry.Cooldown.Size, "OUTLINE")
        else
            frame.cooldown:GetRegions():SetAlpha(0)
        end
        frame.cooldown:SetAllPoints(frame)

        frame.Border:Hide()
        frame.SlotArt:Hide()
        frame.IconMask:Hide()

        frame.SlotBackground:Hide()
        frame.SlotBackground:HookScript("OnShow", function(self)
            self:Hide()
        end)

        if frame.Arrow then
            frame.Arrow:SetDrawLayer("HIGHLIGHT")
        end

        if not frame.Background then
            local background = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
            background:SetParentKey("Background")
            background:SetAllPoints(frame)
            background:SetColorTexture(0, 0, 0, 0.5)
        end

        frame.NormalTexture:Hide()
        frame.NormalTexture:HookScript("OnShow", function(self)
            self:Hide()
        end)

        frame.icon:SetTexCoord(.08, .92, .08, .92)
        if not frame.Borders then
            Util.AddBorder(frame)
        end
    end   
end

function AB.UpdateBarAnchor(bar)
    local dbEntry = CUI.DB.profile.ActionBars[bar:GetName()]

    if dbEntry.ShouldAnchor then
        if not _G[dbEntry.AnchorFrame] then
            dbEntry.AnchorFrame = "UIParent"
        end

        if not InCombatLockdown() then
            bar:ClearAllPoints()
            bar:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
        end

        bar:RegisterEvent("PLAYER_ENTERING_WORLD")
        bar:HookScript("OnEvent", function(self, event)
            if event == "PLAYER_ENTERING_WORLD" then
                self:ClearAllPoints()
                self:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
            end
        end)
    else
        bar:HookScript("OnEvent", function() end)
    end
end

---------------------------------------------------------------------------------------------------

local function AddHooks()
    for bar, button in pairs(AB.ActionBars) do
        for i=1, 12 do
            local frame = _G[button..i]
            if not frame then break end

            frame:HookScript("OnEnter", function() Util.FadeFrame(bar, "IN", 1, 0.3) end)
            frame:HookScript("OnLeave", function() AB.UpdateAlpha(bar) end)
        end

        bar:HookScript("OnEnter", function() Util.FadeFrame(bar, "IN", 1, 0.3) end)
        bar:HookScript("OnLeave", function() AB.UpdateAlpha(bar) end)

        bar:RegisterEvent("PLAYER_REGEN_ENABLED")
        bar:RegisterEvent("PLAYER_REGEN_DISABLED")
        bar:HookScript("OnEvent", function(self, event)
            if event == "PLAYER_REGEN_ENABLED" then
                AB.UpdateAlpha(self)
            elseif event == "PLAYER_REGEN_DISABLED" then
                AB.UpdateAlpha(self, true)
            end
        end)

        AB.UpdateAlpha(bar)
    end

    for _, button in pairs(microMenuButtons) do
        button:HookScript("OnEnter", function() Util.FadeFrame(MicroMenu, "IN", 1, 0.3) end)
        button:HookScript("OnLeave", function() AB.UpdateAlpha(MicroMenu) end)
    end
    AB.UpdateAlpha(MicroMenu)

    EditModeManagerFrame:HookScript("OnHide", function(self)
        if InCombatLockdown() then return end
        for bar, _ in pairs(AB.ActionBars) do
            local dbEntry = CUI.DB.profile.ActionBars[bar:GetName()]

            AB.UpdateBar(bar)

            if dbEntry.ShouldAnchor then
                local anchorFrame = dbEntry.AnchorFrame
                local anchorPoint = dbEntry.AnchorPoint
                local anchorRelativePoint = dbEntry.AnchorRelativePoint
                local posX = dbEntry.PosX
                local posY = dbEntry.PosY

                bar:ClearAllPoints()
                bar:SetPoint(anchorPoint, anchorFrame, anchorRelativePoint, posX, posY)
            end
        end
    end)
end

local function StyleXPBar()
    MainStatusTrackingBarContainer.BarFrameTexture:Hide()
    Util.AddBorder(MainStatusTrackingBarContainer)
    for _, frame in pairs({MainStatusTrackingBarContainer:GetChildren()}) do
        if frame.StatusBar then
            frame.StatusBar:SetAllPoints(MainStatusTrackingBarContainer)

            local r, g, b = 0.6, 0.2, 0.9
            local v = 0.2

            frame.StatusBar.BarTexture:SetTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
            frame.StatusBar.BarTexture:SetVertexColor(r, g, b)

            frame.StatusBar.Background:SetTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
            frame.StatusBar.Background:SetVertexColor(r*v, g*v, b*v)
        end

        if frame.OverlayFrame then
            frame.OverlayFrame:SetAllPoints(MainStatusTrackingBarContainer)
            frame.OverlayFrame.Text:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 10, "")
        end
    end
end

local function StyleButtons()
    for bar, button in pairs(AB.ActionBars) do
        AB.UpdateBar(bar)
        AB.UpdateBarAnchor(bar)
    end
end

---------------------------------------------------------------------------------------------------

function AB.Load()
    HideBlizzard()

    AddHooks()
    StyleButtons()

    StyleXPBar()
end