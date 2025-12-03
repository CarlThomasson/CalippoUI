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
}

---------------------------------------------------------------------------------------------------

function AB.UpdateAlpha(frame, inCombat)
    if InCombatLockdown() or inCombat then 
        frame:SetAlpha(CalippoDB.ActionBars[frame:GetName()].CombatAlpha)
    else
        frame:SetAlpha(CalippoDB.ActionBars[frame:GetName()].Alpha)
    end
end

---------------------------------------------------------------------------------------------------

local function AddActionBarHooks(actionBar, button)
    for i=1, 12 do
        local frame = _G[button..i]
        frame:HookScript("OnEnter", function() actionBar:SetAlpha(1) end)
        frame:HookScript("OnLeave", function() AB.UpdateAlpha(actionBar) end)
    end
end

local function AddMicroMenuHooks()
    for _, button in pairs(microMenuButtons) do
        button:HookScript("OnEnter", function() MicroMenu:SetAlpha(1) end)
        button:HookScript("OnLeave", function() MicroMenu:SetAlpha(CalippoDB.ActionBars.MicroMenu.Alpha) end)
    end
end

local function AddHookSecure()
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

local function StyleButtons()
    for bar, button in pairs(actionBars) do
        for i=1, 12 do
            local frame = _G[button..i]

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

            frame.NormalTexture:Hide()
            frame.NormalTexture:HookScript("OnShow", function(self)
                self:Hide()
            end)

            frame.icon:SetTexCoord(.08, .92, .08, .92)
            Util.AddBackdrop(frame, 1, CUI_BACKDROP_DS_2)
        end     
    end
end

---------------------------------------------------------------------------------------------------

function AB.Load()
    HideBlizzard()
    
    AddHookSecure()

    AddMicroMenuHooks()

    for bar, button in pairs(actionBars) do
        AddActionBarHooks(bar, button)

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

    StyleButtons()

    if not InCombatLockdown() and PlayerFrame.HealthBar then
        MultiBar7:ClearAllPoints()
        MultiBar7:SetPoint("TOPLEFT", PlayerFrame.HealthBar, "BOTTOMLEFT", 0, -2)
    end
    EditModeManagerFrame:HookScript("OnHide", function(self)
        if InCombatLockdown() or not PlayerFrame.HealthBar then return end
        MultiBar7:ClearAllPoints()
        MultiBar7:SetPoint("TOPLEFT", PlayerFrame.HealthBar, "BOTTOMLEFT", 0, -2)
    end)
end