local addonName, CUI = ...

CUI.UF = {}
local UF = CUI.UF
local Util = CUI.Util
local Hide = CUI.Hide

---------------------------------------------------------------------------------------------------

function HideBlizzard()
    -- TODO : Unregister events på blizzard frames

    Hide.HideFrame(PlayerFrame)
    Hide.HideFrame(TargetFrame)
    Hide.HideFrame(FocusFrame)
    Hide.HideFrame(PetFrame)
end

---------------------------------------------------------------------------------------------------

function UF.UpdateAlpha(frame, inCombat)
    if InCombatLockdown() or inCombat then 
        Util.FadeFrame(frame, "IN", CUI.DB.profile.UnitFrames[frame.name].CombatAlpha)
    else
        Util.FadeFrame(frame, "OUT", CUI.DB.profile.UnitFrames[frame.name].Alpha)
    end
end

function UF.UpdateSizePos(frame)
    local dbEntry = CUI.DB.profile.UnitFrames[frame.name]

    frame:ClearAllPoints()
    frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    frame:SetSize(dbEntry.Width, dbEntry.Height)

    if dbEntry.PowerBar.Enabled then
        frame.PowerBar:Show()
        frame.PowerBar:SetHeight(dbEntry.PowerBar.Height)
        frame.HealthBar:SetPoint("BOTTOMRIGHT", frame.PowerBar, "TOPRIGHT")
    else
        frame.PowerBar:Hide()
        frame.HealthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    end
end

function UF.UpdateTexts(frame)
    local dbEntry = CUI.DB.profile.UnitFrames[frame.name]

    frame.Overlay.UnitName:SetWidth(dbEntry.Name.Width)

    if dbEntry.Name.Enabled then
        frame.Overlay.UnitName:Show()
        frame.Overlay.UnitName:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", dbEntry.Name.Size, "")
        frame.Overlay.UnitName:ClearAllPoints()
        frame.Overlay.UnitName:SetPoint(dbEntry.Name.AnchorPoint, frame.Overlay, dbEntry.Name.AnchorRelativePoint, 
            dbEntry.Name.PosX, dbEntry.Name.PosY)
    else
        frame.Overlay.UnitName:Hide()
    end

    if dbEntry.HealthText.Enabled then
        frame.Overlay.UnitHealth:Show()
        frame.Overlay.UnitHealth:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", dbEntry.HealthText.Size, "")
        frame.Overlay.UnitHealth:ClearAllPoints()
        frame.Overlay.UnitHealth:SetPoint(dbEntry.HealthText.AnchorPoint, frame.Overlay, dbEntry.HealthText.AnchorRelativePoint, 
            dbEntry.HealthText.PosX, dbEntry.HealthText.PosY)
    else
        frame.Overlay.UnitHealth:Hide()    
    end
end

function UF.UpdateLeaderAssist(frame)
    if frame.name == "PetFrame" or frame.name == "BossFrame" then return end

    local unit = frame.unit
    local dbEntry = CUI.DB.profile.UnitFrames[frame.name].LeaderIcon
    local leaderFrame = frame.Overlay.Leader


    leaderFrame:ClearAllPoints()
    leaderFrame:SetPoint(dbEntry.AnchorPoint, frame.Overlay, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)

    if UnitIsGroupLeader(unit) then
        leaderFrame:SetTexture("Interface/AddOns/CalippoUI/Media/GroupLeader.blp")
        leaderFrame:Show()
    elseif UnitIsGroupAssistant(unit) then
        leaderFrame:SetTexture("Interface/AddOns/CalippoUI/Media/GroupAssist.blp")
        leaderFrame:Show()
    else
        leaderFrame:Hide()
    end
end

function UF.UpdateAuras(unitFrame)
    if true then
        return -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    end
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame.name]

    local auraFrames = {}
    local rowLength = dbEntry.Buffs.RowLength
    local frameSize = dbEntry.Buffs.Size
    local padding = dbEntry.Buffs.Padding
    local index = 0

    for frame in unitFrame.auraPools:EnumerateActive() do
        auraFrames[frame.auraInstanceID] = frame
    end

    unitFrame.activeBuffs:Iterate(function(id, aura)
        local frame = auraFrames[id]
        if not frame then return end
        frame:ClearAllPoints()
        frame:SetSize(frameSize, frameSize)
        frame.Icon:SetTexCoord(.08, .92, .08, .92)
        frame.Count:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
        frame.Count:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 0)

        if not frame.Borders then
            Util.AddBorder(frame)
        end

        Util.PositionFromIndex(index, frame, unitFrame, "BOTTOMRIGHT", "TOPRIGHT", "LEFT", "UP", frameSize, padding, 0, 2, rowLength)
        
        index = index + 1
    end)

    rowLength = dbEntry.Debuffs.RowLength
    frameSize = dbEntry.Debuffs.Size
    padding = dbEntry.Debuffs.Padding
    index = 0

    unitFrame.activeDebuffs:Iterate(function(id, aura)
        local frame = auraFrames[id]
        if not frame then return end
        frame:SetSize(frameSize, frameSize)
        frame.Icon:SetTexCoord(.08, .92, .08, .92)
        frame.Count:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
        frame.Count:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 0)

        if frame.Border then
            frame.Border:Hide()
        end

        if not frame.Borders then
            Util.AddBorder(frame)
        end

        Util.PositionFromIndex(index, frame, unitFrame, "TOPLEFT", "BOTTOMLEFT", "RIGHT", "DOWN", frameSize, padding, 0, -2, rowLength)

        index = index + 1
    end)
end

---------------------------------------------------------------------------------------------------

local function UpdateHealth(frame)
    local unit = frame.unit

    frame.Overlay.UnitHealth:SetText(Util.UnitHealthText(unit))
    frame.HealthBar:SetValue(UnitHealth(unit))
end

local function UpdateMaxHealth(frame)
    local unit = frame.unit

    frame.Overlay.UnitHealth:SetText(Util.UnitHealthText(unit))
    frame.HealthBar:SetMinMaxValues(0, UnitHealthMax(unit))
    frame.HealthBar:SetValue(UnitHealth(unit))
end

local function UpdateHealthFull(frame)
    if not frame.HealthBar then return end

    local unit = frame.unit

    UpdateMaxHealth(frame)

    frame.Overlay.UnitHealth:SetText(Util.UnitHealthText(unit))

    local r, g, b = Util.GetUnitColor(unit)
    frame.HealthBar:SetStatusBarColor(r, g, b)

    local v = 0.2
    frame.HealthBar.Background:SetColorTexture(r*v, g*v, b*v, 1)
end

local function UpdatePower(frame)
    frame.PowerBar:SetValue(UnitPower(frame.unit))
end 

local function UpdateMaxPower(frame)
    local unit = frame.unit

    frame.PowerBar:SetMinMaxValues(0, UnitPowerMax(unit))
    frame.PowerBar:SetValue(UnitPower(unit))
end

local function UpdatePowerFull(frame)
    if not frame.PowerBar then return end

    local unit = frame.unit

    UpdateMaxPower(frame)

    local _, powerType = UnitPowerType(unit)
    if powerType == "MANA" or powerType == nil then powerType = "MAELSTROM" end

    local color = PowerBarColor[powerType]
    if color == nil then
        color = PowerBarColor["MAELSTROM"]
    end
    frame.PowerBar:SetStatusBarColor(color.r, color.g, color.b, 1)

    local v = 0.2
    frame.PowerBar.Background:SetColorTexture(color.r*v, color.g*v, color.b*v, 1)
end

local function UpdateNameText(frame)
    frame.Overlay.UnitName:SetText(UnitName(frame.unit))
end

local function UpdateAll(frame)
    UpdateHealthFull(frame)
    UpdatePowerFull(frame)
    UpdateNameText(frame)
    UF.UpdateLeaderAssist(frame)
    UF.UpdateAlpha(frame)
end

-------------------------------------------------------------------------------------------------

local function GetCastBarColor(castBar)
    local color = {}

    if castBar.barType == "uninterruptable" then
        color.r = 0.9
        color.g = 0.9
        color.b = 0.9
        color.a = 1
        return color
    else
        color.r = 0.9
        color.g = 0.9
        color.b = 0
        color.a = 1
        return color
    end
end

local function GetCastOrChannelInfo(unit)
    local nameCast, _, _, startTimeMSCast, endTimeMSCast = UnitCastingInfo(unit)
    local nameChannel, _, _, startTimeMSChannel, endTimeMSChannel = UnitChannelInfo(unit)

    if startTimeMSCast then
        return nameCast, false, startTimeMSCast, endTimeMSCast
    elseif startTimeMSChannel then
        return nameChannel, true, startTimeMSChannel, endTimeMSChannel
    else
        return nil, nil
    end
end

local function UpdateCastBar(castBar, blizzardCastBar)
    local name, isChannel, startTime, endTime = GetCastOrChannelInfo(castBar.unit)

    if not startTime then 
        castBar.isCasting = false
        castBar:Hide() 
        return
    end
    
    if isChannel then
        local castBarColor = GetCastBarColor(blizzardCastBar)
        castBar.Background:SetVertexColor(castBarColor.r, castBarColor.g, castBarColor.b, castBarColor.a, 1)
        
        local v = 0.2
        castBar:SetStatusBarColor(castBarColor.r*v, castBarColor.g*v, castBarColor.b*v)
        castBar:SetReverseFill(true)
    else
        local castBarColor = GetCastBarColor(blizzardCastBar)
        castBar:SetStatusBarColor(castBarColor.r, castBarColor.g, castBarColor.b, castBarColor.a)

        local v = 0.2
        castBar.Background:SetVertexColor(castBarColor.r*v, castBarColor.g*v, castBarColor.b*v, 1)
        castBar:SetReverseFill(false)
    end

    castBar.Text:SetText(name)

    local currentTime = GetTime()
    castBar:SetMinMaxValues(startTime, endTime)
    castBar:SetValue(currentTime)
    
    castBar.isCasting = true
    castBar:Show()
end

function SetupCastBar(unitFrame, blizzardCastBar)
    local unit = unitFrame.unit

    blizzardCastBar:Hide()
    blizzardCastBar:HookScript("OnShow", function(self)
        self:Hide()
    end)

    local castBar = CreateFrame("Statusbar", nil, unitFrame)
    castBar:SetParentKey("CUI_CastBar")
    castBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
    castBar:SetStatusBarColor(0.8, 0.8, 0, 1)
    castBar:SetPoint("BOTTOMLEFT", unitFrame.HealthBar, "TOPLEFT", 0, 2)
    castBar:SetPoint("BOTTOMRIGHT", unitFrame.HealthBar, "TOPRIGHT", 0, 2)
    castBar:SetHeight(13)

    Util.AddStatusBarBackground(castBar)
    Util.AddBorder(castBar)

    castBar.isCasting = false
    castBar.unit = unit

    local castBarText = castBar:CreateFontString(nil, "OVERLAY")
    castBarText:SetParentKey("Text")
    castBarText:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 8, "")
    castBarText:SetPoint("LEFT", castBar, "LEFT", 3, 0)

    UpdateCastBar(castBar, blizzardCastBar)

    castBar:SetScript("OnUpdate", function(self)
        if not self.isCasting then return end
        self:SetValue(GetTime() * 1000)
    end)

    castBar:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
    castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
    castBar:RegisterEvent("PLAYER_FOCUS_CHANGED")
    castBar:HookScript("OnEvent", function(self, event)            
        if event == "UNIT_SPELLCAST_START" or 
                event == "UNIT_SPELLCAST_CHANNEL_START" or
                event == "UNIT_SPELLCAST_STOP" or
                event == "UNIT_SPELLCAST_CHANNEL_STOP" or
                event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
            UpdateCastBar(self, blizzardCastBar)
        elseif event == "PLAYER_FOCUS_CHANGED" then
            UpdateCastBar(self, blizzardCastBar)
        end
    end)
end

-------------------------------------------------------------------------------------------------

function SetupUnitFrame(frameName, unit)
    local dbEntry = CUI.DB.profile.UnitFrames[frameName]

    local frame = CreateFrame("Button", "CUI_"..frameName, UIParent, "CUI_UnitFrameTemplate")
    frame:SetSize(dbEntry.Width, dbEntry.Height)

    frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)

    frame:SetAttribute("unit", unit)
    frame:RegisterForClicks("AnyDown")
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")

    frame.unit = unit
    frame.name = frameName

    if unit == "target" then
        frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    elseif unit == "focus" then
        frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    elseif unit == "pet" then
        frame:HookScript("OnShow", function(self)
            UpdateAll(self)
        end)
    end

    local powerBar = CreateFrame("StatusBar", nil, frame)
    powerBar:SetParentKey("PowerBar")
    powerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
    powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    powerBar:SetHeight(dbEntry.PowerBar.Height)
    powerBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
    Util.AddStatusBarBackground(powerBar)
    Util.AddBorder(powerBar)

    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetParentKey("HealthBar")
    healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT")
    healthBar:SetPoint("BOTTOMRIGHT", powerBar, "TOPRIGHT")
    healthBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
    Util.AddStatusBarBackground(healthBar)
    Util.AddBorder(healthBar)

    local overlayFrame = CreateFrame("Frame", nil, frame)
    overlayFrame:SetParentKey("Overlay")
    overlayFrame:SetAllPoints(frame)

    local unitName = overlayFrame:CreateFontString(nil, "OVERLAY")
    unitName:SetParentKey("UnitName")
    unitName:SetPoint("LEFT", overlayFrame, "LEFT", 5, 0)
    unitName:SetWidth(overlayFrame:GetWidth() - 60)
    unitName:SetJustifyH("LEFT")
    unitName:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 12, "")
    unitName:SetText(UnitName(unit))
    unitName:SetWordWrap(false)
    
    local unitHealth = overlayFrame:CreateFontString(nil, "OVERLAY")
    unitHealth:SetParentKey("UnitHealth")
    unitHealth:SetPoint("RIGHT", overlayFrame, "RIGHT", -5, 0)
    unitHealth:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 12, "")
    unitHealth:SetText(Util.UnitHealthText(unit))
    
    local leaderFrame = overlayFrame:CreateTexture(nil, "OVERLAY")
    leaderFrame:SetParentKey("Leader")
    leaderFrame:SetPoint("TOPLEFT", overlayFrame, "TOPLEFT", 3, -3)
    leaderFrame:SetSize(15, 15)
    leaderFrame:Hide()
    
    frame:RegisterUnitEvent("UNIT_HEALTH", unit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    frame:RegisterUnitEvent("UNIT_POWER_UPDATE", unit)
    frame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PARTY_LEADER_CHANGED")
    frame:RegisterEvent("GROUP_FORMED")
    frame:RegisterEvent("GROUP_LEFT")
    frame:HookScript("OnEvent", function(self, event, ...)
        if event == "UNIT_HEALTH" then
            UpdateHealth(self)
        elseif event == "UNIT_MAXHEALTH" then
            UpdateMaxHealth(self)
        elseif event == "UNIT_POWER_UPDATE" then
            if self.unit == "player" then return end
            UpdatePower(self)
        elseif event == "UNIT_MAXPOWER" then
            if self.unit == "player" then return end
            UpdateMaxPower(self)
        elseif event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
            if not UnitExists(self.unit) then return end
            UpdateAll(frame)
        elseif event == "PLAYER_REGEN_ENABLED" then
            UF.UpdateAlpha(self)
        elseif event == "PLAYER_REGEN_DISABLED" then
            UF.UpdateAlpha(self, true)
        elseif event == "PARTY_LEADER_CHANGED" or event == "GROUP_FORMED" or event == "GROUP_LEFT" then
            UF.UpdateLeaderAssist(self)
        end
    end)

    UpdateAll(frame)
    UF.UpdateTexts(frame)
    UF.UpdateSizePos(frame)
    RegisterUnitWatch(frame, false)
end

---------------------------------------------------------------------------------------------------

function UF.Load()
    HideBlizzard()

    SetupUnitFrame("PlayerFrame", "player")
    SetupUnitFrame("TargetFrame", "target")
    SetupUnitFrame("FocusFrame", "focus")
    SetupUnitFrame("PetFrame", "pet")

    SetupUnitFrame("BossFrame", "boss1")

    --SetupCastBar(FocusFrame, FocusFrameSpellBar)

    hooksecurefunc(TargetFrame, "UpdateAuras", function(self)
        UF.UpdateAuras(self)
    end)

    hooksecurefunc(FocusFrame, "UpdateAuras", function(self)
        UF.UpdateAuras(self)
    end)
end