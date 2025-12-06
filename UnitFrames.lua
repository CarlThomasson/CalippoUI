local addonName, CUI = ...

CUI.UF = {}
local UF = CUI.UF
local Util = CUI.Util
local Hide = CUI.Hide

---------------------------------------------------------------------------------------------------

function HideBlizzard()
    PlayerFrameBottomManagedFramesContainer:Hide()

    PlayerFrame.PlayerFrameContent:Hide()
    PlayerFrame.PlayerFrameContainer:Hide()
    Hide.HideUnitFrameChildren(PlayerFrame)

    TargetFrame.TargetFrameContent:Hide()
    TargetFrame.TargetFrameContainer:Hide()
    TargetFrameSpellBar:SetScript("OnShow", function()
        TargetFrameSpellBar:Hide()
    end)
    Hide.HideUnitFrameChildren(TargetFrame)

    FocusFrame.TargetFrameContent:Hide()
    FocusFrame.TargetFrameContainer:Hide()
    Hide.HideUnitFrameChildren(PlayerFrame)

    Hide.HideFrame(PetFrameTexture)
    Hide.HideUnitFrameChildren(PetFrame)
end

---------------------------------------------------------------------------------------------------

function UF.UpdateAlpha(frame, inCombat)
    if InCombatLockdown() or inCombat then 
        Util.FadeFrame(frame, "IN", 1)
    else
        Util.FadeFrame(frame, "OUT", CalippoDB.UnitFrames[frame:GetName()].Alpha)
    end
end

function UF.UpdateSizePos(frame)
    frame.HealthBar:SetPoint("CENTER", frame, "CENTER", CalippoDB.UnitFrames[frame:GetName()].OffsetX, CalippoDB.UnitFrames[frame:GetName()].OffsetY)
    frame.HealthBar:SetSize(CalippoDB.UnitFrames[frame:GetName()].SizeX, CalippoDB.UnitFrames[frame:GetName()].SizeY)
    frame.Overlay.UnitName:SetWidth(frame.Overlay:GetWidth() - 60)
end

function UF.UpdateTexts(frame)
    local fontSizeN = CalippoDB.UnitFrames[frame:GetName()].NameFontSize
    if fontSizeN == 0 then
        frame.Overlay.UnitName:Hide()
    else
        frame.Overlay.UnitName:Show()
        frame.Overlay.UnitName:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", fontSizeN, "")
    end

    local fontSizeH = CalippoDB.UnitFrames[frame:GetName()].HealthFontSize
    if fontSizeH == 0 then
        frame.Overlay.UnitHealth:Hide()    
    else
        frame.Overlay.UnitHealth:Show()
        frame.Overlay.UnitHealth:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", fontSizeH, "")
    end
end

function UF.UpdateAuras(unitFrame)
    local auraFrames = {}
    local maxRow = CalippoDB.UnitFrames[unitFrame:GetName()].AuraRowLength
    local frameSize = CalippoDB.UnitFrames[unitFrame:GetName()].AuraSize
    local padding = CalippoDB.UnitFrames[unitFrame:GetName()].AuraPadding
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
            Util.AddBorder(frame, 1, CUI_BACKDROP_DS_2)
        end
        
        local level = math.floor(index/maxRow)

        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMRIGHT", unitFrame.HealthBar, "TOPRIGHT", -(index*(frameSize+padding))+(level*maxRow*(frameSize+padding)), 2+(level*(frameSize+padding)))

        index = index + 1
    end)

    index = 0

    unitFrame.activeDebuffs:Iterate(function(id, aura)
        local frame = auraFrames[id]
        if not frame then return end
        frame:SetSize(frameSize, frameSize)
        frame:SetPoint("TOPLEFT", TargetFrame.HealthBar, "BOTTOMLEFT")
        frame.Icon:SetTexCoord(.08, .92, .08, .92)
        frame.Count:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")
        frame.Count:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 0)

        if frame.Border then
            frame.Border:Hide()
        end

        if not frame.Borders then
            Util.AddBorder(frame, 1, CUI_BACKDROP_DS_2)
        end

        local level = math.floor(index/maxRow)

        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", unitFrame.PowerBar, "BOTTOMLEFT", (index*(frameSize+padding))-(level*maxRow*(frameSize+padding)), -(level*(frameSize+padding))-2)

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

local function UpdateLeaderAssist(frame)
    local unit = frame.unit
    if UnitIsGroupLeader(unit) then
        frame.Overlay.Leader:SetTexture("Interface/AddOns/CalippoUI/Media/GroupLeader.blp")
        frame.Overlay.Leader:Show()
    elseif UnitIsGroupAssistant(unit) then
        frame.Overlay.Leader:SetTexture("Interface/AddOns/CalippoUI/Media/GroupAssist.blp")
        frame.Overlay.Leader:Show()
    else
        frame.Overlay.Leader:Hide()
    end
end

local function UpdateNameText(frame)
    frame.Overlay.UnitName:SetText(UnitName(frame.unit))
end

local function UpdateAll(frame)
    if frame.PowerBar then UpdatePowerFull(frame) end
    UpdateHealthFull(frame)
    UpdateLeaderAssist(frame)
    UpdateNameText(frame)
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
    Util.AddBorder(castBar, 1, CUI_BACKDROP_DS_3)

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

function SetupUnitFrame(frame)
    local unit = frame.unit

    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetParentKey("HealthBar")
    healthBar:SetPoint("CENTER", frame, "CENTER", CalippoDB.UnitFrames[frame:GetName()].OffsetX, CalippoDB.UnitFrames[frame:GetName()].OffsetY)
    healthBar:SetSize(CalippoDB.UnitFrames[frame:GetName()].SizeX, CalippoDB.UnitFrames[frame:GetName()].SizeY)
    if unit ~= "player" then
        frame:RegisterEvent("PLAYER_TARGET_CHANGED")
        frame:RegisterUnitEvent("UNIT_POWER_UPDATE", unit)
        frame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
        if unit == "focus" then
            frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
        end
        local powerBar = CreateFrame("StatusBar", nil, frame)
        powerBar:SetParentKey("PowerBar")
        powerBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, 5)
        powerBar:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT")
        powerBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
        powerBar:SetFrameLevel(healthBar:GetFrameLevel() + 5)
        Util.AddStatusBarBackground(powerBar)
        Util.AddBorder(powerBar, 1, CUI_BACKDROP_DS_3)
    end
    healthBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
    Util.AddStatusBarBackground(healthBar)
    Util.AddBorder(healthBar, 1, CUI_BACKDROP_DS_3)

    local clickFrame = CreateFrame("Button", nil, healthBar, "SecureUnitButtonTemplate")
    clickFrame:SetAttribute("unit", unit)
    clickFrame:RegisterForClicks("AnyDown")
    clickFrame:SetAttribute("*type1", "target")
    clickFrame:SetAttribute("*type2", "togglemenu")
    clickFrame:SetAllPoints(healthBar)

    local overlayFrame = CreateFrame("Frame", nil, frame)
    overlayFrame:SetParentKey("Overlay")
    overlayFrame:SetAllPoints(healthBar)

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
    
    UF.UpdateTexts(frame)

    frame:RegisterUnitEvent("UNIT_HEALTH", unit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
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
            UpdateLeaderAssist(self)
        end
    end)

    UpdateAll(frame)
end

---------------------------------------------------------------------------------------------------

function UF.Load()
    HideBlizzard()

    SetupUnitFrame(PlayerFrame)
    SetupUnitFrame(TargetFrame)
    SetupUnitFrame(FocusFrame)
    SetupUnitFrame(PetFrame)

    SetupCastBar(FocusFrame, FocusFrameSpellBar)

    hooksecurefunc(TargetFrame, "UpdateAuras", function(self)
        UF.UpdateAuras(self)
    end)

    hooksecurefunc(FocusFrame, "UpdateAuras", function(self)
        UF.UpdateAuras(self)
    end)
end