local addonName, CUI = ...

CUI.UF = {}
local UF = CUI.UF
local Util = CUI.Util
local Hide = CUI.Hide

---------------------------------------------------------------------------------------------------

function HideBlizzard()
    Hide.HideFrame(PlayerFrame)
    Hide.HideFrame(TargetFrame)
    Hide.HideFrame(FocusFrame)
    Hide.HideFrame(PetFrame)

    Hide.HideFrame(Boss1TargetFrame)
    Hide.HideFrame(Boss2TargetFrame)
    Hide.HideFrame(Boss3TargetFrame)
    Hide.HideFrame(Boss4TargetFrame)
    Hide.HideFrame(Boss5TargetFrame)
end

---------------------------------------------------------------------------------------------------

function UF.ToggleBossTest(active)
    for i=1, 5 do
        local frame = _G["CUI_BossFrame"..i]

        local unit
        if active then
            unit = "player"
            frame:SetAttribute("unit", unit)
            frame.unit = unit
            frame.CastBar.unit = unit
        else
            unit = "boss"..i
            frame:SetAttribute("unit", unit)
            frame.unit = unit
            frame.CastBar.unit = unit
        end

        frame:RegisterUnitEvent("UNIT_AURA", unit)
        frame:RegisterUnitEvent("UNIT_HEALTH", unit)
        frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
        frame:RegisterUnitEvent("UNIT_POWER_UPDATE", unit)
        frame:RegisterUnitEvent("UNIT_MAXPOWER", unit)

        local castBar = frame.CastBar
        if CUI.DB.profile.UnitFrames.BossFrame.CastBar.Enabled then
            castBar:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
            castBar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
            castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
            castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
            castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
        else
            castBar:UnregisterAllEvents()
        end
    end
end

local function UpdateBossFrameAlpha()
    for i=1, 5 do
        UF.UpdateAlpha(_G["CUI_BossFrame"..i])
    end
end

function UF.UpdateAlpha(frame, inCombat)
    if frame == "BossFrame" then UpdateBossFrameAlpha() return end

    if InCombatLockdown() or inCombat then
        Util.FadeFrame(frame, "IN", CUI.DB.profile.UnitFrames[frame.name].CombatAlpha)
    else
        Util.FadeFrame(frame, "OUT", CUI.DB.profile.UnitFrames[frame.name].Alpha)
    end
end

local function UpdateBossFrames()
    for i=1, 5 do
        UF.UpdateFrame(_G["CUI_BossFrame"..i], i)
    end
end

function UF.UpdateFrame(frame, i)
    if frame == "BossFrame" then UpdateBossFrames() return end

    local dbEntry = CUI.DB.profile.UnitFrames[frame.name]

    Util.CheckAnchorFrame(frame, dbEntry)

    frame:ClearAllPoints()
    if frame.name == "BossFrame" then
        if i == 1 then
            frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
        else
            frame:SetPoint("TOPLEFT", "CUI_BossFrame"..(i-1), "BOTTOMLEFT", 0, -dbEntry.Padding)
        end
    else
        frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    end
    frame:SetSize(dbEntry.Width, dbEntry.Height)

    frame.HealthBar:SetStatusBarTexture(dbEntry.HealthBar.Texture)

    if dbEntry.PowerBar.Enabled then
        frame.PowerBar:Show()
        frame.PowerBar:SetHeight(dbEntry.PowerBar.Height)
        frame.PowerBar:SetStatusBarTexture(dbEntry.PowerBar.Texture)
        frame.HealthBar:SetPoint("BOTTOMRIGHT", frame.PowerBar, "TOPRIGHT")
    else
        frame.PowerBar:Hide()
        frame.HealthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    end
end

local function UpdateBossFrameTexts()
    for i=1, 5 do
        UF.UpdateTexts(_G["CUI_BossFrame"..i])
    end
end

function UF.UpdateTexts(frame)
    if frame == "BossFrame" then UpdateBossFrameTexts() return end

    local dbEntry = CUI.DB.profile.UnitFrames[frame.name]
    frame.Overlay.UnitName:SetWidth(dbEntry.Name.Width)

    if dbEntry.Name.Enabled then
        frame.Overlay.UnitName:Show()
        frame.Overlay.UnitName:SetFont(dbEntry.Name.Font, dbEntry.Name.Size, dbEntry.Name.Outline)
        frame.Overlay.UnitName:ClearAllPoints()
        frame.Overlay.UnitName:SetPoint(dbEntry.Name.AnchorPoint, frame.Overlay, dbEntry.Name.AnchorRelativePoint,
            dbEntry.Name.PosX, dbEntry.Name.PosY)
    else
        frame.Overlay.UnitName:Hide()
    end

    if dbEntry.HealthText.Enabled then
        frame.Overlay.UnitHealth:Show()
        frame.Overlay.UnitHealth:SetFont(dbEntry.HealthText.Font, dbEntry.HealthText.Size, dbEntry.HealthText.Outline)
        frame.Overlay.UnitHealth:ClearAllPoints()
        frame.Overlay.UnitHealth:SetPoint(dbEntry.HealthText.AnchorPoint, frame.Overlay, dbEntry.HealthText.AnchorRelativePoint,
            dbEntry.HealthText.PosX, dbEntry.HealthText.PosY)
    else
        frame.Overlay.UnitHealth:Hide()
    end
end

function UF.UpdateLeaderAssist(frame)
    if not CUI.DB.profile.UnitFrames[frame.name].LeaderIcon then return end

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

local function UpdateBossFrameCastBarFrame()
    for i=1, 5 do
        UF.UpdateCastBarFrame(_G["CUI_BossFrame"..i])
    end
end

function UF.UpdateCastBarFrame(unitFrame)
    if unitFrame == "BossFrame" then UpdateBossFrameCastBarFrame() return end

    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame.name].CastBar
    local castBar = unitFrame.CastBar

    if unitFrame.name == "BossFrame" then dbEntry.AnchorFrame = unitFrame:GetName() end

    castBar:SetSize(dbEntry.Width, dbEntry.Height)
    castBar:SetStatusBarTexture(dbEntry.Texture)
    castBar:SetStatusBarColor(dbEntry.Color.r, dbEntry.Color.g, dbEntry.Color.b, dbEntry.Color.a)

    Util.CheckAnchorFrame(unitFrame, dbEntry)

    castBar:ClearAllPoints()
    if dbEntry.MatchWidth then
        castBar:SetPoint("TOPLEFT", dbEntry.AnchorFrame, "BOTTOMLEFT", 0, dbEntry.PosY)
        castBar:SetPoint("TOPRIGHT", dbEntry.AnchorFrame, "BOTTOMRIGHT", 0, dbEntry.PosY)
    else
        castBar:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    end

    if dbEntry.Enabled then
        local unit = unitFrame.unit
        castBar:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
        castBar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
        castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
        castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
        castBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
        castBar:RegisterEvent("PLAYER_FOCUS_CHANGED")
        castBar:RegisterEvent("PLAYER_TARGET_CHANGED")
    else
        castBar:Hide()
        castBar:UnregisterAllEvents()
    end
end

local function UpdateBossFrameCastBarTexts()
    for i=1, 5 do
        UF.UpdateCastBarTexts(_G["CUI_BossFrame"..i])
    end
end

function UF.UpdateCastBarTexts(unitFrame)
    if unitFrame == "BossFrame" then UpdateBossFrameCastBarTexts() return end

    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame.name].CastBar
    local name = unitFrame.CastBar.Name
    local time = unitFrame.CastBar.Time

    name:SetFont(dbEntry.Name.Font, dbEntry.Name.Size, dbEntry.Name.Outline)
    name:SetPoint(dbEntry.Name.AnchorPoint, unitFrame.CastBar, dbEntry.Name.AnchorRelativePoint, dbEntry.Name.PosX, dbEntry.Name.PosY)
    name:SetWidth(dbEntry.Name.Width)

    time:SetFont(dbEntry.Time.Font, dbEntry.Time.Size, dbEntry.Time.Outline)
    time:SetPoint(dbEntry.Time.AnchorPoint, unitFrame.CastBar, dbEntry.Time.AnchorRelativePoint, dbEntry.Time.PosX, dbEntry.Time.PosY)
end

---------------------------------------------------------------------------------------------------

local DEBUFF_DISPLAY_COLOR_INFO = {
    [0] = CreateColor(0, 0, 0, 0),
    [1] = DEBUFF_TYPE_MAGIC_COLOR,
    [2] = DEBUFF_TYPE_CURSE_COLOR,
    [3] = DEBUFF_TYPE_DISEASE_COLOR,
    [4] = DEBUFF_TYPE_POISON_COLOR,
    [9] = DEBUFF_TYPE_BLEED_COLOR, -- enrage
    [11] = DEBUFF_TYPE_BLEED_COLOR,
}
local dispelColorCurve = C_CurveUtil.CreateColorCurve()

dispelColorCurve:SetType(Enum.LuaCurveType.Step)
for i, c in pairs(DEBUFF_DISPLAY_COLOR_INFO) do
    dispelColorCurve:AddPoint(i, c)
end

local function UpdateAuras(unitFrame, type)
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame.name][type]
    local anchorPoint = dbEntry.AnchorPoint
    local anchorRelativePoint = dbEntry.AnchorRelativePoint
    local dirH = dbEntry.DirH
    local dirV = dbEntry.DirV
    local size = dbEntry.Size
    local padding = dbEntry.Padding
    local posX = dbEntry.PosX
    local posY = dbEntry.PosY
    local rowLength = dbEntry.RowLength
    local maxShown = dbEntry.MaxShown

    local stacksEnabled = dbEntry.Stacks.Enabled
    local stacksAP = dbEntry.Stacks.AnchorPoint
    local stacksARP = dbEntry.Stacks.AnchorRelativePoint
    local stacksPX = dbEntry.Stacks.PosX
    local stacksPY = dbEntry.Stacks.PosY
    local stacksFont = dbEntry.Stacks.Font
    local stacksOutline = dbEntry.Stacks.Outline
    local stacksSize = dbEntry.Stacks.Size

    local index = 0
	local function HandleAura(aura)
        if index >= maxShown then return end

        local auraFrame = unitFrame.pool:Acquire()
        auraFrame:Show()

        auraFrame.unit = unitFrame.unit
        auraFrame.index = index + 1

        auraFrame:SetSize(size, size)

        local color = C_UnitAuras.GetAuraDispelTypeColor(unitFrame.unit, aura.auraInstanceID, dispelColorCurve)
        if color then
            if aura.dispelName then
                auraFrame.Overlay.Backdrop:Hide()
                auraFrame.Overlay.DispelBackdrop:Show()
            else
                auraFrame.Overlay.Backdrop:Show()
                auraFrame.Overlay.DispelBackdrop:Hide()
            end
            auraFrame.Overlay.DispelBackdrop:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
        end

        auraFrame.Icon:SetTexture(aura.icon)
        -- TODO : Flytta till Frames.XML vvvvvvvvvvvv
        auraFrame.Icon:SetTexCoord(.08, .92, .08, .92)

        local stacksFrame = auraFrame.Overlay.Count
        if stacksEnabled then
            stacksFrame:Show()
            stacksFrame:ClearAllPoints()
            stacksFrame:SetPoint(stacksAP, auraFrame.Overlay, stacksARP, stacksPX, stacksPY)
            stacksFrame:SetFont(stacksFont, stacksSize, stacksOutline)
            stacksFrame:SetText(C_StringUtil.TruncateWhenZero(aura.applications))
        else
            stacksFrame:Hide()
        end

        auraFrame.Cooldown:SetCooldownFromExpirationTime(aura.expirationTime, aura.duration)

        Util.PositionFromIndex(index, auraFrame, unitFrame, anchorPoint, anchorRelativePoint, dirH, dirV, size, padding, posX, posY, rowLength)

        index = index + 1
	end

    if type == "Buffs" then
	    AuraUtil.ForEachAura(unitFrame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful), nil, HandleAura, true)
    elseif type == "Debuffs" then
        AuraUtil.ForEachAura(unitFrame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful, AuraUtil.AuraFilters.Player), nil, HandleAura, true)
    end
end

local function UpdateBossFrameAuras()
    for i=1, 5 do
        UF.UpdateAuras(_G["CUI_BossFrame"..i])
    end
end

function UF.UpdateAuras(unitFrame)
    if unitFrame == "BossFrame" then UpdateBossFrameAuras() return end
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame.name]

    unitFrame.pool:ReleaseAll()
    if dbEntry.Buffs.Enabled then
        UpdateAuras(unitFrame, "Buffs")
    end
    if dbEntry.Debuffs.Enabled then
        UpdateAuras(unitFrame, "Debuffs")
    end
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

local function GetCastOrChannelDuration(unit)
    local castingDuration = UnitCastingDuration(unit)
    if castingDuration then return false, castingDuration, UnitCastingInfo(unit) end

    local channelDuration = UnitChannelDuration(unit)
    if channelDuration then return true, channelDuration, UnitChannelInfo(unit) end

    return nil
end

local function UpdateCastBar(castBar, unitFrame)
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame.name].CastBar
    local isChannel, duration, name, _, icon = GetCastOrChannelDuration(castBar.unit)

    if not duration then
        castBar.isCasting = false
        castBar:Hide()
        return
    end

    if isChannel then
        local c = dbEntry.Color
        castBar.Background:SetVertexColor(c.r, c.g, c.b, c.a, 1)

        local v = 0.2
        castBar:SetStatusBarColor(c.r*v, c.g*v, c.b*v)
        castBar:SetReverseFill(true)
    else
        local c = dbEntry.Color
        castBar:SetStatusBarColor(c.r, c.g, c.b, c.a)

        local v = 0.2
        castBar.Background:SetVertexColor(c.r*v, c.g*v, c.b*v, 1)
        castBar:SetReverseFill(false)
    end

    castBar.Name:SetText(name)

    castBar:SetTimerDuration(duration, 0)

    castBar:SetScript("OnUpdate", function(self)
        local castTime = duration:GetRemainingDuration()
        self.Time:SetText(string.format("%.1f", castTime))
    end)

    castBar.isCasting = true
    castBar:Show()
end

function SetupCastBar(unitFrame)
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame.name].CastBar
    local unit = unitFrame.unit

    local castBar = CreateFrame("Statusbar", nil, unitFrame)
    castBar:SetParentKey("CastBar")
    castBar:Hide()

    UF.UpdateCastBarFrame(unitFrame)

    Util.AddStatusBarBackground(castBar)
    Util.AddBorder(castBar)

    castBar.duration = C_DurationUtil.CreateDuration()
    castBar.isCasting = false
    castBar.unit = unit

    local castBarName = castBar:CreateFontString(nil, "OVERLAY")
    castBarName:SetParentKey("Name")
    castBarName:SetJustifyH("LEFT")
    castBarName:SetWordWrap(false)

    local castBarTime = castBar:CreateFontString(nil, "OVERLAY")
    castBarTime:SetParentKey("Time")

    UF.UpdateCastBarTexts(unitFrame)

    castBar:SetScript("OnEvent", function(self, event)            
        if event == "UNIT_SPELLCAST_START" or
            event == "UNIT_SPELLCAST_CHANNEL_START" or
            event == "UNIT_SPELLCAST_STOP" or
            event == "UNIT_SPELLCAST_CHANNEL_STOP" or
            event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
            UpdateCastBar(self, unitFrame)
        elseif event == "PLAYER_FOCUS_CHANGED" or event == "PLAYER_TARGET_CHANGED" then
            UpdateCastBar(self, unitFrame)
        end
    end)
end

-------------------------------------------------------------------------------------------------

function SetupUnitFrame(frameName, unit, number)
    local dbEntry = CUI.DB.profile.UnitFrames[frameName]

    local frame
    if frameName == "BossFrame" then
        frame = CreateFrame("Button", "CUI_"..frameName..number, UIParent, "CUI_UnitFrameTemplate")
        dbEntry.CastBar.AnchorFrame = "CUI_"..frameName..number
    else
        frame = CreateFrame("Button", "CUI_"..frameName, UIParent, "CUI_UnitFrameTemplate")
    end
    frame:SetSize(dbEntry.Width, dbEntry.Height)

    Util.CheckAnchorFrame(frame, dbEntry)
    if frameName == "BossFrame" then
        if number == 1 then
            frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
        else
            frame:SetPoint("TOPLEFT", "CUI_BossFrame"..(number-1), "BOTTOMLEFT", 0, -dbEntry.Padding)
        end
    else
        frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    end

    -- if frameName == "BossFrame" then
    --     frame.unit = "player"
    --     frame:SetAttribute("unit", "player")
    -- else

    -- end
    
    frame:SetAttribute("unit", unit)
    frame:RegisterForClicks("AnyDown")
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")
    frame:SetAttribute("ping-receiver", true)

    frame.unit = unit
    frame.name = frameName
    frame.pool = CreateFramePool("Frame", frame, "CUI_AuraFrameTemplate")

    if unit == "target" then
        frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    elseif unit == "focus" then
        frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    elseif unit == "pet" or frameName == "BossFrame" then
        frame:HookScript("OnShow", function(self)
            UpdateAll(self)
        end)
    end

    local powerBar = CreateFrame("StatusBar", nil, frame)
    powerBar:SetParentKey("PowerBar")
    powerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
    powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    powerBar:SetHeight(dbEntry.PowerBar.Height)
    powerBar:SetStatusBarTexture(dbEntry.PowerBar.Texture)
    Util.AddStatusBarBackground(powerBar)
    Util.AddBorder(powerBar)

    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetParentKey("HealthBar")
    healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT")
    healthBar:SetPoint("BOTTOMRIGHT", powerBar, "TOPRIGHT")
    healthBar:SetStatusBarTexture(dbEntry.HealthBar.Texture)
    Util.AddStatusBarBackground(healthBar)
    Util.AddBorder(healthBar)

    local overlayFrame = CreateFrame("Frame", nil, frame)
    overlayFrame:SetParentKey("Overlay")
    overlayFrame:SetAllPoints(frame)

    local unitName = overlayFrame:CreateFontString(nil, "OVERLAY")
    unitName:SetParentKey("UnitName")
    unitName:SetPoint(dbEntry.Name.AnchorPoint, frame.Overlay, dbEntry.Name.AnchorRelativePoint, dbEntry.Name.PosX, dbEntry.Name.PosY)
    unitName:SetFont(dbEntry.Name.Font, dbEntry.Name.Size, dbEntry.Name.Outline)
    unitName:SetWidth(dbEntry.Name.Width)
    unitName:SetJustifyH("LEFT")
    unitName:SetWordWrap(false)
    unitName:SetText(UnitName(unit))

    local unitHealth = overlayFrame:CreateFontString(nil, "OVERLAY")
    unitHealth:SetParentKey("UnitHealth")
    unitHealth:SetPoint(dbEntry.HealthText.AnchorPoint, frame.Overlay, dbEntry.HealthText.AnchorRelativePoint, dbEntry.HealthText.PosX, dbEntry.HealthText.PosY)
    unitHealth:SetFont(dbEntry.HealthText.Font, dbEntry.HealthText.Size, dbEntry.HealthText.Outline)
    unitHealth:SetText(Util.UnitHealthText(unit))

    if dbEntry.LeaderIcon then
        local leaderFrame = overlayFrame:CreateTexture(nil, "OVERLAY")
        leaderFrame:SetParentKey("Leader")
        leaderFrame:SetPoint(dbEntry.LeaderIcon.AnchorPoint, overlayFrame, dbEntry.LeaderIcon.AnchorRelativePoint, dbEntry.LeaderIcon.PosX, dbEntry.LeaderIcon.PosY)
        leaderFrame:SetSize(15, 15)
        leaderFrame:Hide()
    end

    frame:RegisterUnitEvent("UNIT_AURA", unit)
    frame:RegisterUnitEvent("UNIT_HEALTH", unit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    frame:RegisterUnitEvent("UNIT_POWER_UPDATE", unit)
    frame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PARTY_LEADER_CHANGED")
    frame:RegisterEvent("GROUP_FORMED")
    frame:RegisterEvent("GROUP_LEFT")
    frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    frame:HookScript("OnEvent", function(self, event, ...)
        if event == "UNIT_AURA" then
            UF.UpdateAuras(self)
        elseif event == "UNIT_HEALTH" then
            UpdateHealth(self)
        elseif event == "UNIT_MAXHEALTH" then
            UpdateMaxHealth(self)
        elseif event == "UNIT_POWER_UPDATE" then
            UpdatePower(self)
        elseif event == "UNIT_MAXPOWER" then
            UpdateMaxPower(self)
        elseif event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
            if not UnitExists(self.unit) then return end
            UpdateAll(self)
            if EditModeManagerFrame:IsShown() then return end
             UF.UpdateAuras(self)
        elseif event == "PLAYER_REGEN_ENABLED" then
            UF.UpdateAlpha(self)
        elseif event == "PLAYER_REGEN_DISABLED" then
            UF.UpdateAlpha(self, true)
        elseif event == "PARTY_LEADER_CHANGED" or event == "GROUP_FORMED" or event == "GROUP_LEFT" then
            UF.UpdateLeaderAssist(self)
        elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
            C_Timer.After(0.5, function() UpdatePowerFull(self) end)
        end
    end)

    SetupCastBar(frame)

    UpdateAll(frame)
    UF.UpdateAuras(frame)
    RegisterUnitWatch(frame, false)
end

---------------------------------------------------------------------------------------------------

function UF.Load()
    HideBlizzard()

    SetupUnitFrame("PlayerFrame", "player")
    SetupUnitFrame("TargetFrame", "target")
    SetupUnitFrame("FocusFrame", "focus")
    SetupUnitFrame("PetFrame", "pet")

    SetupUnitFrame("BossFrame", "boss1", 1)
    SetupUnitFrame("BossFrame", "boss2", 2)
    SetupUnitFrame("BossFrame", "boss3", 3)
    SetupUnitFrame("BossFrame", "boss4", 4)
    SetupUnitFrame("BossFrame", "boss5", 5)
end
