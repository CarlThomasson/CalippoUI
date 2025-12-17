local addonName, CUI = ...

CUI.CB = {}
local CB = CUI.CB
local Util = CUI.Util
local Hide = CUI.Hide

---------------------------------------------------------------------------------------------------

local function HideBlizzard()
    --PlayerCastingBarFrame:UnregisterAllEvents()

    for _, frame in pairs({PlayerCastingBarFrame:GetRegions()}) do
        Hide.HideFrame(frame)
    end

    for _, frame in pairs({PlayerCastingBarFrame:GetChildren()}) do
        Hide.HideFrame(frame)
    end
end

---------------------------------------------------------------------------------------------------

local function GetCastOrChannelInfo(unit)
    local nameCast, _, _, startTimeMSCast, endTimeMSCast = UnitCastingInfo("player")
    local nameChannel, _, _, startTimeMSChannel, endTimeMSChannel = UnitChannelInfo("player")

    if startTimeMSCast then
        return nameCast, false, startTimeMSCast, endTimeMSCast
    elseif startTimeMSChannel then
        return nameChannel, true, startTimeMSChannel, endTimeMSChannel
    else
        return nil, nil
    end
end

local function UpdateCastBar(castBar)
    local name, isChannel, startTime, endTime = GetCastOrChannelInfo("player")

    if not startTime then 
        castBar:Hide() 
        return
    end
    
    if isChannel then
        local r, g, b = 0, 0.8, 0
        castBar.Background:SetVertexColor(r, g, b, a, 1)
        
        local v = 0.2
        castBar:SetStatusBarColor(r*v, g*v, b*v)
        castBar:SetReverseFill(true)
    else
        local r, g, b = 0, 0.8, 0
        castBar:SetStatusBarColor(r, g, b, a)

        local v = 0.2
        castBar.Background:SetVertexColor(r*v, g*v, b*v, 1)
        castBar:SetReverseFill(false)
    end

    castBar:SetTimerDuration(castBar.duration)
    castBar.duration:SetTimeSpan(startTime/1000, endTime/1000)
    
    castBar.startTime = startTime
    castBar.endTime = endTime
    castBar:Show()
end

local function SetupCastBar()
    local castBar = CreateFrame("Statusbar", "CUI_CastBar", UIParent)
    castBar:SetAllPoints(PlayerCastingBarFrame)
    castBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
    castBar:SetStatusBarColor(0, 0.8, 0, 0.5)
    Util.AddStatusBarBackground(castBar)
    Util.AddBorder(castBar)

    castBar.duration = C_DurationUtil.CreateDuration()

    castBar:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", "player")
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "player")
    castBar:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_SPELLCAST_START"  or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
            UpdateCastBar(self)
        elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
            self:SetMinMaxValues(self.startTime, self.endTime)
            self:SetValue(GetTime()*1000)
        end
    end)
end

---------------------------------------------------------------------------------------------------

function CB.Load()
    HideBlizzard()
    -- Hide.HideFrame(PlayerCastingBarFrame)
    SetupCastBar()
end