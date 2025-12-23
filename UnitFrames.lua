local addonName, CUI = ...

CUI.UF = {}
local UF = CUI.UF
local Util = CUI.Util
local Hide = CUI.Hide

---------------------------------------------------------------------------------------------------

function HideBlizzard()
    Hide.UnregisterChildren(PlayerFrame)
    Hide.HideFrame(PlayerFrame)

    Hide.UnregisterChildren(TargetFrame)
    Hide.HideFrame(TargetFrame)

    Hide.UnregisterChildren(FocusFrame)
    Hide.HideFrame(FocusFrame)

    Hide.UnregisterChildren(PetFrame)
    Hide.HideFrame(PetFrame)

    Hide.UnregisterChildren(Boss1TargetFrame)
    Hide.HideFrame(Boss1TargetFrame, true)

    Hide.UnregisterChildren(Boss2TargetFrame)
    Hide.HideFrame(Boss2TargetFrame, true)

    Hide.UnregisterChildren(Boss3TargetFrame)
    Hide.HideFrame(Boss3TargetFrame, true)

    Hide.UnregisterChildren(Boss4TargetFrame)
    Hide.HideFrame(Boss4TargetFrame, true)

    Hide.UnregisterChildren(Boss5TargetFrame)
    Hide.HideFrame(Boss5TargetFrame, true)

    Hide.UnregisterChildren(BossTargetFrameContainer)
    Hide.HideFrame(BossTargetFrameContainer)
end

---------------------------------------------------------------------------------------------------

local function UpdateBossFrameAlpha()
    for i=1, 5 do
        UF.UpdateAlpha(_G["CUI_BossFrame"..i])
    end
end

local function UpdateBossFrames()
    for i=1, 5 do
        UF.UpdateFrame(_G["CUI_BossFrame"..i])
    end
end

local function UpdateBossFrameTexts()
    for i=1, 5 do
        UF.UpdateTexts(_G["CUI_BossFrame"..i])
    end
end

local function UpdateBossFrameCastBarFrame()
    for i=1, 5 do
        UF.UpdateCastBarFrame(_G["CUI_BossFrame"..i])
    end
end

local function UpdateBossFrameCastBarTexts()
    for i=1, 5 do
        UF.UpdateCastBarTexts(_G["CUI_BossFrame"..i])
    end
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

        UF.UpdateAuras(frame)

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

function UF.UpdateAlpha(frame, inCombat)
    if frame == "BossFrame" then UpdateBossFrameAlpha() return end

    if InCombatLockdown() or inCombat then
        Util.FadeFrame(frame, "IN", CUI.DB.profile.UnitFrames[frame.name].CombatAlpha)
    else
        Util.FadeFrame(frame, "OUT", CUI.DB.profile.UnitFrames[frame.name].Alpha)
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

function UF.UpdateCastBarFrame(unitFrame)
    if unitFrame == "BossFrame" then UpdateBossFrameCastBarFrame() return end

    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame.name].CastBar
    local castBar = unitFrame.CastBar

    if unitFrame.name == "BossFrame" then dbEntry.AnchorFrame = unitFrame:GetName() end

    castBar:SetSize(dbEntry.Width, dbEntry.Height)

    castBar.Bar:SetStatusBarTexture(dbEntry.Texture)
    castBar.Bar:SetStatusBarColor(dbEntry.Color.r, dbEntry.Color.g, dbEntry.Color.b, dbEntry.Color.a)

    castBar.Bar.Background:SetTexture(dbEntry.Texture)
    castBar.Bar.Background:SetVertexColor(dbEntry.Color.r*0.2, dbEntry.Color.g*0.2, dbEntry.Color.b*0.2, dbEntry.Color.a)

    if dbEntry.ShowIcon then
        castBar.IconContainer:Show()
        castBar.IconContainer:SetWidth(dbEntry.Height)
        castBar.Bar:SetPoint("TOPLEFT", castBar.IconContainer, "TOPRIGHT")
    else
        castBar.IconContainer:Hide()
        castBar.Bar:SetPoint("TOPLEFT", castBar, "TOPLEFT")
    end

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

function UF.UpdateCastBarTexts(unitFrame)
    if unitFrame == "BossFrame" then UpdateBossFrameCastBarTexts() return end

    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame.name].CastBar
    local name = unitFrame.CastBar.Bar.Name
    local time = unitFrame.CastBar.Bar.Time

    name:SetFont(dbEntry.Name.Font, dbEntry.Name.Size, dbEntry.Name.Outline)
    name:SetPoint(dbEntry.Name.AnchorPoint, unitFrame.CastBar.Bar, dbEntry.Name.AnchorRelativePoint, dbEntry.Name.PosX, dbEntry.Name.PosY)
    name:SetWidth(dbEntry.Name.Width)

    time:SetFont(dbEntry.Time.Font, dbEntry.Time.Size, dbEntry.Time.Outline)
    time:SetPoint(dbEntry.Time.AnchorPoint, unitFrame.CastBar.Bar, dbEntry.Time.AnchorRelativePoint, dbEntry.Time.PosX, dbEntry.Time.PosY)
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
        auraFrame.type = type
        auraFrame.showTooltip = true
        auraFrame.auraInstanceID = aura.auraInstanceID

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

        Util.PositionFromIndex(index, auraFrame, unitFrame, anchorPoint, anchorRelativePoint, dirH, dirV, size, size, padding, posX, posY, rowLength)

        index = index + 1
	end

    if type == "Buffs" then
	    AuraUtil.ForEachAura(unitFrame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful), nil, HandleAura, true)
    elseif type == "Debuffs" then
        if UnitIsEnemy("player", unitFrame.unit) then
            AuraUtil.ForEachAura(unitFrame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful, AuraUtil.AuraFilters.Player), nil, HandleAura, true)
        else
            AuraUtil.ForEachAura(unitFrame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful), nil, HandleAura, true)
        end
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

local function UpdateHealthColor(frame)
    local r, g, b = Util.GetUnitColor(frame.unit)
    frame.HealthBar:SetStatusBarColor(r, g, b)

    local v = 0.2
    frame.HealthBar.Background:SetVertexColor(r*v, g*v, b*v, 1)
end

local function UpdatePowerColor(frame)
    local r, g, b = Util.GetUnitPowerColor(frame.unit)
    frame.PowerBar:SetStatusBarColor(r, g, b)

    local v = 0.2
    frame.PowerBar.Background:SetVertexColor(r*v, g*v, b*v)
end

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

    UpdateMaxHealth(frame)
    UpdateHealthColor(frame)

    frame.Overlay.UnitHealth:SetText(Util.UnitHealthText(frame.unit))
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
    UpdateMaxPower(frame)
    UpdatePowerColor(frame)
end

local function UpdateNameText(frame)
    frame.Overlay.UnitName:SetText(UnitName(frame.unit))
end

local function UpdateLeaderAssist(frame)
    if not frame.Overlay.LeaderIcon then return end

    local dbEntry = CUI.DB.profile.UnitFrames[frame.name].LeaderIcon
    if not dbEntry.Enabled then frame.Overlay.LeaderIcon:Hide() return end

    local leaderFrame = frame.Overlay.LeaderIcon
    local unit = frame.unit

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

local function UpdateAll(frame)
    UpdateHealthFull(frame)
    UpdatePowerFull(frame)
    UpdateNameText(frame)
    UpdateLeaderAssist(frame)
    UF.UpdateAlpha(frame)
end

-------------------------------------------------------------------------------------------------

function UF.UpdateFrame(frame)
    if frame == "BossFrame" then UpdateBossFrames() return end

    local dbEntry = CUI.DB.profile.UnitFrames[frame.name]

    Util.CheckAnchorFrame(frame, dbEntry)

    frame:ClearAllPoints()
    if frame.name == "BossFrame" then
        if frame.number == 1 then
            frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
        else
            frame:SetPoint("TOPLEFT", "CUI_BossFrame"..(frame.number-1), "BOTTOMLEFT", 0, -dbEntry.Padding)
        end
    else
        frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    end
    frame:SetSize(dbEntry.Width, dbEntry.Height)

    frame.HealthBar:SetStatusBarTexture(dbEntry.HealthBar.Texture)
    frame.HealthBar.Background:SetTexture(dbEntry.HealthBar.Texture)

    if dbEntry.PowerBar.Enabled then
        frame.PowerBar:Show()
        frame.PowerBar:SetHeight(dbEntry.PowerBar.Height)
        frame.PowerBar:SetStatusBarTexture(dbEntry.PowerBar.Texture)
        frame.HealthBar:SetPoint("BOTTOMRIGHT", frame.PowerBar, "TOPRIGHT")
    else
        frame.PowerBar:Hide()
        frame.HealthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    end

    local leaderIcon = frame.Overlay.LeaderIcon
    if leaderIcon then
        local dbEntryLead = dbEntry.LeaderIcon
        if dbEntryLead.Enabled then
            UpdateLeaderAssist(frame)
            leaderIcon:ClearAllPoints()
            leaderIcon:SetPoint(dbEntryLead.AnchorPoint, frame.Overlay, dbEntryLead.AnchorRelativePoint, dbEntryLead.PosX, dbEntryLead.PosY)
            leaderIcon:SetSize(dbEntryLead.Size, dbEntryLead.Size)
        else
            leaderIcon:Hide()
        end
    end
end

-------------------------------------------------------------------------------------------------

local function GetCastOrChannelDuration(unit)
    local castingDuration = UnitCastingDuration(unit)
    if castingDuration then return false, castingDuration, UnitCastingInfo(unit) end

    local channelDuration = UnitChannelDuration(unit)
    if channelDuration then return true, channelDuration, UnitChannelInfo(unit) end

    return nil
end

local function UpdateCastBar(castBarContainer)
    local isChannel, duration, name, _, icon = GetCastOrChannelDuration(castBarContainer.unit)
    local castBar = castBarContainer.Bar

    if not duration then
        castBarContainer.isCasting = false
        castBarContainer:Hide()
        return
    end

    castBarContainer.IconContainer.Icon:SetTexture(icon)
    castBar.Name:SetText(name)

    local direction
    if isChannel then
        direction = 1
    else
        direction = 0
    end

    castBar:SetTimerDuration(duration, 0, direction)

    castBar:SetScript("OnUpdate", function(self)
        local castTime = duration:GetRemainingDuration()
        self.Time:SetText(string.format("%.1f", castTime))
    end)

    castBarContainer.isCasting = true
    castBarContainer:Show()
end

function SetupCastBar(unitFrame)
    local unit = unitFrame.unit

    local castBarContainer = CreateFrame("Frame", nil, unitFrame)
    castBarContainer:SetParentKey("CastBar")
    castBarContainer:Hide()

    castBarContainer.isCasting = false
    castBarContainer.unit = unit

    local iconContainer = CreateFrame("Frame", nil, castBarContainer)
    iconContainer:SetParentKey("IconContainer")
    iconContainer:SetPoint("TOPLEFT", castBarContainer, "TOPLEFT")
    iconContainer:SetPoint("BOTTOMLEFT", castBarContainer, "BOTTOMLEFT")
    Util.AddBorder(iconContainer)

    local icon = iconContainer:CreateTexture(nil, "ARTWORK")
    icon:SetParentKey("Icon")
    icon:SetAllPoints(iconContainer)
    icon:SetTexCoord(.08, .92, .08, .92)

    local castBar = CreateFrame("Statusbar", nil, castBarContainer)
    castBar:SetParentKey("Bar")
    castBar:SetPoint("BOTTOMRIGHT", castBarContainer, "BOTTOMRIGHT")

    Util.AddStatusBarBackground(castBar)
    Util.AddBorder(castBar)
    UF.UpdateCastBarFrame(unitFrame)

    local castBarName = castBar:CreateFontString(nil, "OVERLAY")
    castBarName:SetParentKey("Name")
    castBarName:SetJustifyH("LEFT")
    castBarName:SetWordWrap(false)

    local castBarTime = castBar:CreateFontString(nil, "OVERLAY")
    castBarTime:SetParentKey("Time")

    UF.UpdateCastBarTexts(unitFrame)

    castBarContainer:SetScript("OnEvent", function(self, event)            
        if event == "UNIT_SPELLCAST_START" or
            event == "UNIT_SPELLCAST_CHANNEL_START" or
            event == "UNIT_SPELLCAST_STOP" or
            event == "UNIT_SPELLCAST_CHANNEL_STOP" or
            event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
            UpdateCastBar(self)
        elseif event == "PLAYER_FOCUS_CHANGED" or event == "PLAYER_TARGET_CHANGED" then
            UpdateCastBar(self)
        end
    end)
end

-------------------------------------------------------------------------------------------------

CreateFrame("Button", "CUI_PlayerFrame", UIParent, "CUI_UnitFrameTemplate")
CreateFrame("Button", "CUI_TargetFrame", UIParent, "CUI_UnitFrameTemplate")
CreateFrame("Button", "CUI_FocusFrame", UIParent, "CUI_UnitFrameTemplate")
CreateFrame("Button", "CUI_PetFrame", UIParent, "CUI_UnitFrameTemplate")
CreateFrame("Button", "CUI_BossFrame1", UIParent, "CUI_UnitFrameTemplate")
CreateFrame("Button", "CUI_BossFrame2", UIParent, "CUI_UnitFrameTemplate")
CreateFrame("Button", "CUI_BossFrame3", UIParent, "CUI_UnitFrameTemplate")
CreateFrame("Button", "CUI_BossFrame4", UIParent, "CUI_UnitFrameTemplate")
CreateFrame("Button", "CUI_BossFrame5", UIParent, "CUI_UnitFrameTemplate")

function SetupUnitFrame(frameName, unit, number)
    local dbEntry = CUI.DB.profile.UnitFrames[frameName]

    local frame
    if frameName == "BossFrame" then
        frame = _G["CUI_"..frameName..number]
        dbEntry.CastBar.AnchorFrame = "CUI_"..frameName..number
    else
        frame = _G["CUI_"..frameName]
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

    frame:SetAttribute("unit", unit)
    frame:RegisterForClicks("AnyDown")
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")
    frame:SetAttribute("ping-receiver", true)

    frame.unit = unit
    frame.name = frameName
    frame.number = number
    frame.pool = CreateFramePool("Frame", frame, "CUI_AuraFrameTemplate")

    if unit == "target" then
        frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    elseif unit == "focus" then
        frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    elseif unit == "pet" or frameName == "BossFrame" then
        frame:HookScript("OnShow", function(self)
            if EditModeManagerFrame:IsShown() then return end
            UpdateAll(self)
        end)
    end

    local powerBar = CreateFrame("StatusBar", nil, frame)
    powerBar:SetParentKey("PowerBar")
    powerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
    powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    Util.AddStatusBarBackground(powerBar)
    Util.AddBorder(powerBar)

    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetParentKey("HealthBar")
    healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT")
    healthBar:SetPoint("BOTTOMRIGHT", powerBar, "TOPRIGHT")
    Util.AddStatusBarBackground(healthBar)
    Util.AddBorder(healthBar)

    local overlayFrame = CreateFrame("Frame", nil, frame)
    overlayFrame:SetParentKey("Overlay")
    overlayFrame:SetFrameLevel(frame:GetFrameLevel()+10)
    overlayFrame:SetAllPoints(frame)

    local unitName = overlayFrame:CreateFontString(nil, "OVERLAY")
    unitName:SetParentKey("UnitName")
    unitName:SetFont(dbEntry.Name.Font, dbEntry.Name.Size, dbEntry.Name.Outline)
    unitName:SetJustifyH("LEFT")
    unitName:SetWordWrap(false)

    local unitHealth = overlayFrame:CreateFontString(nil, "OVERLAY")
    unitHealth:SetParentKey("UnitHealth")
    unitHealth:SetFont(dbEntry.HealthText.Font, dbEntry.HealthText.Size, dbEntry.HealthText.Outline)

    if dbEntry.LeaderIcon then
        local leaderFrame = overlayFrame:CreateTexture(nil, "OVERLAY")
        leaderFrame:SetParentKey("LeaderIcon")
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
            UpdateLeaderAssist(self)
        elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
            C_Timer.After(0.5, function() UpdatePowerFull(self) end)
        end
    end)

    SetupCastBar(frame)

    UF.UpdateAuras(frame)
    UF.UpdateFrame(frame)
    UF.UpdateTexts(frame)
    UpdateAll(frame)

    C_Timer.After(0.5, function()
        UpdatePowerColor(frame)
    end)

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
