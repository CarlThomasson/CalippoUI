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

local actionBars = {
    [MainActionBar] = "ActionButton",
    [MultiBarBottomLeft] = "MultiBarBottomLeftButton",
    [MultiBarBottomRight] = "MultiBarBottomRightButton",
    [MultiBarLeft] = "MultiBarLeftButton",
    [MultiBarRight] = "MultiBarRightButton",
    [MultiBar5] = "MultiBar5Button",
    [MultiBar6] = "MultiBar6Button",
    [MultiBar7] = "MultiBar7Button",
    [MultiBar7] = "MultiBar7Button",
    [PetActionBar] = "PetActionButton",
}

---------------------------------------------------------------------------------------------------

function AB.UpdateAlpha(frame, inCombat)
    if InCombatLockdown() or inCombat then 
        Util.FadeFrame(frame, "IN", CalippoDB.ActionBars[frame:GetName()].CombatAlpha)
    else
        Util.FadeFrame(frame, "OUT", CalippoDB.ActionBars[frame:GetName()].Alpha)
    end
end

---------------------------------------------------------------------------------------------------

local function PositionMB7()
    if not InCombatLockdown() and PlayerFrame.Container.HealthBar then
        MultiBar7:ClearAllPoints()
        MultiBar7:SetPoint("TOPLEFT", PlayerFrame.Container.HealthBar, "BOTTOMLEFT", 0, -2)
    end
    MultiBar7:RegisterEvent("PLAYER_ENTERING_WORLD")
    MultiBar7:HookScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            MultiBar7:ClearAllPoints()
            MultiBar7:SetPoint("TOPLEFT", PlayerFrame.Container.HealthBar, "BOTTOMLEFT", 0, -2)
        end
    end)
    EditModeManagerFrame:HookScript("OnHide", function(self)
        if InCombatLockdown() or not PlayerFrame.Container.HealthBar then return end
        MultiBar7:ClearAllPoints()
        MultiBar7:SetPoint("TOPLEFT", PlayerFrame.Container.HealthBar, "BOTTOMLEFT", 0, -2)
    end)
end

local function AddHooks()
    for bar, button in pairs(actionBars) do
        for i=1, 12 do
            local frame = _G[button..i]
            if not frame then break end

            frame:HookScript("OnEnter", function() Util.FadeFrame(bar, "IN", 1, 0.3) end)
            frame:HookScript("OnLeave", function() AB.UpdateAlpha(bar) end)
        end

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

    FramerateFrame:ClearAllPoints()
    FramerateFrame:SetPoint("TOP", Minimap, "BOTTOM", 0, -5)
    hooksecurefunc(FramerateFrame, "UpdatePosition", function(self) 
        self:ClearAllPoints()
        self:SetPoint("TOP", Minimap, "BOTTOM", 0, -5)
    end)

    QueueStatusButton:ClearAllPoints()
    QueueStatusButton:SetPoint("CENTER", Minimap, "BOTTOMLEFT")
    hooksecurefunc(QueueStatusButton, "UpdatePosition", function(self) 
        self:ClearAllPoints()
        self:SetPoint("CENTER", Minimap, "BOTTOMLEFT")
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
    for bar, button in pairs(actionBars) do
        for i=1, 12 do
            local frame = _G[button..i]
            if not frame then break end

            frame.TextOverlayContainer.HotKey:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 10, "OUTLINE")
            frame.TextOverlayContainer.HotKey:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)

            frame.Name:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 10, "OUTLINE")
            frame.Name:SetPoint("BOTTOM", frame, "BOTTOM", 0, 2)

            frame.Count:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 16, "OUTLINE")
            frame.Count:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)

            frame.cooldown:SetAllPoints(frame)
            frame.cooldown:GetRegions():SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 16, "OUTLINE")

            frame.Border:Hide()
            frame.SlotArt:Hide()
            frame.SlotBackground:Hide()
            frame.IconMask:Hide()

            local background = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
            background:SetParentKey("Background")
            background:SetAllPoints(frame)
            background:SetColorTexture(0, 0, 0, 0.5)

            frame.NormalTexture:Hide()
            frame.NormalTexture:HookScript("OnShow", function(self)
                self:Hide()
            end)

            frame.icon:SetTexCoord(.08, .92, .08, .92)
            Util.AddBorder(frame, 1, CUI_BACKDROP_DS_2)
        end     
    end
end

---------------------------------------------------------------------------------------------------

function AB.Load()
    HideBlizzard()

    AddHooks()
    StyleButtons()

    StyleXPBar()

    PositionMB7()
end