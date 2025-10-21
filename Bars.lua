local addonName, CUI = ...

CUI.Bars = {}
local Bars = CUI.Bars
local Hide = CUI.Hide

local microMenuButtons = {
    CharacterMicroButton,
    ProfessionMicroButton,
    PlayerSpellsMicroButton,
    AchievementMicroButton,
    QuestLogMicroButton,
    GuildMicroButton,
    LFDMicroButton,
    CollectionsMicroButton,
    EJMicroButton,
    StoreMicroButton,
    MainMenuMicroButton,
}

local actionBars = {
    MainMenuBar,
    MultiBarBottomLeft,
    MultiBarBottomRight,
    MultiBarLeft,
    MultiBarRight,
    MultiBar5,
    MultiBar6,
    MultiBar7,
}

local actionButtons = {
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarLeftButton",
    "MultiBarRightButton",
    "MultiBar5Button",
    "MultiBar6Button",
    "MultiBar7Button",
}

function Bars.SetAlphas(alpha)
    MicroMenu:SetAlpha(alpha)

    for _, bar in pairs(actionBars) do
        bar:SetAlpha(alpha)
    end
end 

local function AddSingleHook(frame, target)
    frame:HookScript("OnEnter", function() target:SetAlpha(1) end)
    frame:HookScript("OnLeave", function() target:SetAlpha(CalippoDB.BarAlpha) end)
end 

local function AddActionBarHooks(name, target)
    for i=1, 12 do
        local frame = _G[name..i]
        frame:HookScript("OnEnter", function() target:SetAlpha(1) end)
        frame:HookScript("OnLeave", function() target:SetAlpha(CalippoDB.BarAlpha) end)
    end
end

local function AddMicroMenuHooks()
    for _, button in pairs(microMenuButtons) do
        button:HookScript("OnEnter", function() MicroMenu:SetAlpha(1) end)
        button:HookScript("OnLeave", function() MicroMenu:SetAlpha(CalippoDB.BarAlpha) end)
    end
end

local function HideBlizzard()
    Hide.HideFrame(BagsBar)
    Hide.HideFrame(StanceBar)
    Hide.HideFrame(TalkingHeadFrame)
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

function Bars.OnLoad()
    HideBlizzard()

    Bars.SetAlphas(CalippoDB.BarAlpha)
    
    AddHookSecure()

    AddMicroMenuHooks()

    for _, bar in pairs(actionBars) do
        AddSingleHook(bar, bar)
    end

    for i, button in ipairs(actionButtons) do
        AddActionBarHooks(button, actionBars[i])
    end
end