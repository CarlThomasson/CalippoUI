local addonName, CUI = ...

CUI.CB = {}
local CB = CUI.CB
local Util = CUI.Util

local function HideFrame(frame)
    frame:Hide()
    frame:SetScript("OnShow", function(self)
        self:Hide()
    end)
end

local function HideBlizzard()
    for _, frame in pairs({PlayerCastingBarFrame:GetRegions()}) do
        HideFrame(frame)
    end
end

local function SetupCastBar()
    local castBarFrame = CreateFrame("Statusbar", "CUI_CastBar", PlayerCastingBarFrame)
    castBarFrame:SetAllPoints(PlayerCastingBarFrame)
    castBarFrame:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
    castBarFrame:SetStatusBarColor(0, 0.8, 0, 1)
    Util.AddStatusBarBackground(castBarFrame)
    Util.AddBackdrop(castBarFrame, 1, CUI_BACKDROP_DS_3)

    castBarFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
    castBarFrame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
    castBarFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
    castBarFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
    castBarFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
    castBarFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
    castBarFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "player")
    castBarFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "player")
    castBarFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", "player")
    castBarFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "player")
    castBarFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_SPELLCAST_START" then
            local name, text, texture, startTimeMS, endTimeMS = UnitCastingInfo("player")
            self.startTime = (startTimeMS / 1000)
            self.endTime = (endTimeMS / 1000)
            self.duration = (self.endTime - self.startTime)
            self:SetMinMaxValues(0, self.duration)
        elseif event == "UNIT_SPELLCAST_STOP" then
            self.startTime = nil
        end
    end)

    castBarFrame:SetScript("OnUpdate", function(self)
        if self.startTime then
            self:SetValue(GetTime() - self.startTime)
        end
    end)
end

function CB.Load()
    HideBlizzard()
    SetupCastBar()
end