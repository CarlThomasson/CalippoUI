local addonName, CUI = ...

CUI.GF = {}
local GF = CUI.GF
local Util = CUI.Util
local Hide = CUI.Hide

---------------------------------------------------------------------------------------------------------------------------------

local function HideBlizzard()
    Hide.HideBlizzardParty()
    Hide.HideBlizzardRaid()
    Hide.HideBlizzardRaidManager()
end

---------------------------------------------------------------------------------------------------------------------------------

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

local function UpdateAuras(groupFrame, type)
    local dbEntry = CUI.DB.profile.GroupFrames[groupFrame.name][type]
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

        local auraFrame = groupFrame.pool:Acquire()
        auraFrame:Show()

        auraFrame.unit = groupFrame.unit
        auraFrame.type = type
        auraFrame.auraInstanceID = aura.auraInstanceID

        auraFrame:SetSize(size, size)

        local color = C_UnitAuras.GetAuraDispelTypeColor(groupFrame.unit, aura.auraInstanceID, dispelColorCurve)
        if type == "Debuffs" and color then
            if aura.dispelName then
                auraFrame.Overlay.Backdrop:Hide()
                auraFrame.Overlay.DispelBackdrop:Show()
            else
                auraFrame.Overlay.Backdrop:Show()
                auraFrame.Overlay.DispelBackdrop:Hide()
            end
            auraFrame.Overlay.DispelBackdrop:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
        else
            auraFrame.Overlay.Backdrop:Show()
            auraFrame.Overlay.DispelBackdrop:Hide()
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

        if type == "Defensives" then print("ASDSAD") end

        Util.PositionFromIndex(index, auraFrame, groupFrame.Overlay, anchorPoint, anchorRelativePoint, dirH, dirV, size, size, padding, posX, posY, rowLength)

        index = index + 1
	end

    if type == "Buffs" then
	    AuraUtil.ForEachAura(groupFrame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful, AuraUtil.AuraFilters.Player, AuraUtil.AuraFilters.Raid), nil, HandleAura, true)
    elseif type == "Debuffs" then
        AuraUtil.ForEachAura(groupFrame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful), nil, HandleAura, true)
    elseif type == "Defensives" then
        AuraUtil.ForEachAura(groupFrame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.ExternalDefensive), nil, HandleAura, true)
    end
end

function UpdateAllAuras(groupFrame)
    local dbEntry = CUI.DB.profile.GroupFrames[groupFrame.name]

    groupFrame.pool:ReleaseAll()
    if dbEntry.Buffs.Enabled then
        UpdateAuras(groupFrame, "Buffs")
    end
    if dbEntry.Debuffs.Enabled then
        UpdateAuras(groupFrame, "Debuffs")
    end
    if dbEntry.Defensives.Enabled then
        UpdateAuras(groupFrame, "Defensives")
    end
end

function GF.UpdateAuras(groupFrame)
    for i, frame in ipairs(groupFrame.frames) do
        UpdateAllAuras(frame)
    end
end

---------------------------------------------------------------------------------------------------------------------------------

local function UpdateNameColor(frame)
    local dbEntry = CUI.DB.profile.GroupFrames[frame.name].Name

    if dbEntry.CustomColor then
        local c = dbEntry.Color
        frame.Overlay.UnitName:SetTextColor(c.r, c.g, c.b, c.a)
    else
        frame.Overlay.UnitName:SetTextColor(Util.GetUnitColor(frame.unit, true))
    end
end

local function UpdateHealthColor(frame, dead)
    local dbEntry = CUI.DB.profile.GroupFrames[frame.name]

    if dead then
        frame.HealthBar:SetStatusBarColor(0.3, 0, 0)
    elseif dbEntry.CustomColor then
        local hc = dbEntry.HealthColor
        frame.HealthBar:SetStatusBarColor(hc.r, hc.g, hc.b, hc.a)
        local bc = dbEntry.BackgroundColor
        frame.Background:SetVertexColor(bc.r, bc.g, bc.b, bc.a)
    else
        local r, g, b = Util.GetUnitColor(frame.unit, true)
        local v = 0.2
        local v2 = 0.5
        frame.HealthBar:SetStatusBarColor(r, g, b)
        frame.Background:SetVertexColor(r*v, g*v, b*v)
        frame.HealPrediction:SetStatusBarColor(r*v2, g*v2, b*v2)
    end
end

local function UpdateHealth(frame)
    local health = UnitHealth(frame.unit)
    local missingHealth = UnitHealthMissing(frame.unit)

    frame.HealthBar:SetValue(health)
end

local function UpdateShieldAbsorb(frame)
    local shieldAbsorb = UnitGetTotalAbsorbs(frame.unit)
    frame.ShieldBar:SetValue(shieldAbsorb)
end

local function UpdateHealAbsorb(frame)
    UnitGetDetailedHealPrediction(frame.unit, "player", frame.calc)
    local healAbsorb = frame.calc:GetHealAbsorbs()
    frame.AbsorbBar:SetValue(healAbsorb)
end

local function UpdateInRange(frame)
    frame:SetAlphaFromBoolean(UnitInRange(frame.unit), 1, 0.5)
end

local function UpdateInPhase(frame)
    local phaseReason = UnitPhaseReason(frame.unit)

    if phaseReason then
        frame.phase = true
    else
        frame.phase = false
    end
end

local function UpdateIsDead(frame)
    if UnitIsDeadOrGhost(frame.unit) then
        local min, max = frame.HealthBar:GetMinMaxValues()
        frame.HealthBar:SetValue(max)
        UpdateHealthColor(frame, true)
        frame.dead = true
    elseif frame.dead == true then
        UpdateHealthColor(frame)
        frame.dead = false
    end
end

local function UpdateConnection(frame)
    local isOnline = UnitIsConnected(frame.unit)

    if isOnline then
        frame.disconnected = false
    else
        frame.disconnected = true
    end
end

local function UpdateReadyCheck(frame)
    local status = GetReadyCheckStatus(frame.unit)

    if status == "ready" then
        frame.readyCheck = "ready"
    elseif status == "waiting" then
        frame.readyCheck = "waiting"
    elseif status == "notready" then
        frame.readyCheck = "notready"
    else
        frame.readyCheck = nil
    end
end

local function UpdateRole(frame)
    local dbEntry = CUI.DB.profile.GroupFrames[frame.name].RoleIcon
    frame.role = UnitGroupRolesAssigned(frame.unit)
    if not dbEntry.Enabled then return end

    local roleIcon = frame.Overlay.RoleIcon

    if frame.role == "TANK" then
        roleIcon:SetTexture("Interface/AddOns/CalippoUI/Media/TANK.tga")
        roleIcon:Show()
    elseif frame.role == "HEALER" then
        roleIcon:SetTexture("Interface/AddOns/CalippoUI/Media/HEALER.tga")
        roleIcon:Show()
    else
        roleIcon:Hide()
    end
end

local function UpdateRess(frame)
    if UnitHasIncomingResurrection(frame.unit) then
        frame.ress = true
    else
        frame.ress = false
    end
end

local function UpdateName(frame)
    UpdateNameColor(frame)
    frame.Overlay.UnitName:SetText(UnitName(frame.unit))
end

local function UpdateSummon(frame)
    local status = C_IncomingSummon.IncomingSummonStatus(frame.unit)

    if status == Enum.SummonStatus.Pending then
        frame.summon = "pending"
    elseif status == Enum.SummonStatus.Accepted then
        frame.summon = "accepted"
    elseif status == Enum.SummonStatus.Declined then
        frame.summon = "declined"
    else
        frame.summon = nil
    end
end

local function UpdateDispel(frame)
    local foundDispel = false

    AuraUtil.ForEachAura(frame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful), nil, function(aura)
        local dispelName = aura.dispelName
        if dispelName then
            frame.Overlay.Dispel:SetTexture("Interface/AddOns/CalippoUI/Media/"..dispelName..".tga")
            foundDispel = true
            return true
        end
    end, true)

    if not foundDispel then
        frame.Overlay.Dispel:Hide()
    else
        frame.Overlay.Dispel:Show()
    end
end

local function UpdateHealPrediction(frame)
    UnitGetDetailedHealPrediction(frame.unit, "player", frame.calc)
    local incoming = frame.calc:GetIncomingHeals()
    frame.HealPrediction:SetValue(incoming)
end

local function UpdateMaxHealth(frame)
    local maxHealth = UnitHealthMax(frame.unit)
    local health = UnitHealth(frame.unit)

    frame.HealthBar:SetMinMaxValues(0, maxHealth)
    frame.HealthBar:SetValue(health)

    frame.HealPrediction:SetMinMaxValues(0, maxHealth)
    UpdateHealPrediction(frame)
    frame.AbsorbBar:SetMinMaxValues(0, maxHealth)
    UpdateHealAbsorb(frame)
    frame.ShieldBar:SetMinMaxValues(0, maxHealth)
    UpdateShieldAbsorb(frame)
end

local function UpdateCenterIcon(frame)
    local centerTexture = frame.Overlay.CenterTexture

    if frame.disconnected then
        centerTexture:SetSize(50, 50)
        centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/Disconnect-Icon.blp")
    elseif frame.readyCheck then
        centerTexture:SetSize(20, 20)
        if frame.readyCheck == "ready" then
            centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/readycheck-ready.tga")
        elseif frame.readyCheck == "waiting" then
            centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/readycheck-waiting.tga")
        elseif frame.readyCheck == "notready" then
            centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/readycheck-notready.tga")
        end
    elseif frame.summon then
        centerTexture:SetSize(30, 30)
        if frame.summon == "pending" then
            centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/Raid-Icon-SummonPending.tga")
        elseif frame.summon == "accepted" then
            centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/Raid-Icon-SummonAccepted.tga")
        elseif frame.summon == "declined" then
            centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/Raid-Icon-SummonDeclined.tga")
        end
    elseif frame.ress then
        centerTexture:SetSize(20, 20)
        centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/Raid-Icon-Rez.blp")
    elseif frame.phase then
        centerTexture:SetSize(30, 30)
        centerTexture:SetTexture("Interface/AddOns/CalippoUI/Media/UI-PhasingIcon.blp")
    else
        centerTexture:Hide()
        return
    end

    centerTexture:Show()
end

local function UpdateAll(frame)
    UpdateMaxHealth(frame)
    UpdateInRange(frame)
    UpdateInPhase(frame)
    UpdateIsDead(frame)
    UpdateConnection(frame)
    UpdateReadyCheck(frame)
    UpdateRole(frame)
    UpdateName(frame)
    UpdateSummon(frame)
    UpdateRess(frame)
    UpdateHealPrediction(frame)

    UpdateNameColor(frame)
    UpdateHealthColor(frame)

    UpdateCenterIcon(frame)
end

local function ToggleEvents(frame, unit, state)
    if UnitExists(unit) then
        frame:RegisterUnitEvent("UNIT_AURA", unit)
        frame:RegisterUnitEvent("UNIT_HEALTH", unit)
        frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
        frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit)
        frame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unit)
        frame:RegisterUnitEvent("UNIT_PHASE", unit)
        frame:RegisterUnitEvent("UNIT_CONNECTION", unit)
        frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit)
        frame:RegisterEvent("READY_CHECK")
        frame:RegisterEvent("READY_CHECK_CONFIRM")
        frame:RegisterEvent("READY_CHECK_FINISHED")
        frame:RegisterEvent("INCOMING_RESURRECT_CHANGED")
        frame:RegisterEvent("INCOMING_SUMMON_CHANGED")
        frame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
        frame:RegisterUnitEvent("UNIT_IN_RANGE_UPDATE", unit)
        --self:RegisterUnitEvent("UNIT_DISTANCE_CHECK_UPDATE", unit)
    else
        frame:UnregisterEvent("UNIT_AURA")
        frame:UnregisterEvent("UNIT_HEALTH")
        frame:UnregisterEvent("UNIT_MAXHEALTH")
        frame:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
        frame:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
        frame:UnregisterEvent("UNIT_PHASE")
        frame:UnregisterEvent("UNIT_CONNECTION")
        frame:UnregisterEvent("UNIT_HEAL_PREDICTION")
        frame:UnregisterEvent("READY_CHECK")
        frame:UnregisterEvent("READY_CHECK_CONFIRM")
        frame:UnregisterEvent("READY_CHECK_FINISHED")
        frame:UnregisterEvent("INCOMING_RESURRECT_CHANGED")
        frame:UnregisterEvent("INCOMING_SUMMON_CHANGED")
        frame:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
        frame:UnregisterEvent("UNIT_IN_RANGE_UPDATE")
        --self:UnregisterEvent("UNIT_DISTANCE_CHECK_UPDATE")
    end
end

function GF.ToggleGroupTestFrames(type, state)
    if InCombatLockdown() then return end

    if type == "PartyFrame" then
        for i, frame in ipairs(CUI_PartyFrame.frames) do
            if state then
                ToggleEvents(frame, "player", true)
                frame.unit = "player"
                frame:SetAttribute("unit", "player")
                UpdateAll(frame)
                RegisterAttributeDriver(frame, "state-visibility", "show")
            else
                local unit
                if i == 5 then
                    unit = "player"
                else
                    unit = "party"..i
                end
                ToggleEvents(frame, unit, true)
                frame.unit = unit
                frame:SetAttribute("unit", unit)
                UpdateAll(frame)
                RegisterAttributeDriver(frame, "state-visibility", "[group:raid]hide;[group:party, @"..unit..", exists]show;hide")
            end
        end
        GF.UpdateAuras(CUI_PartyFrame)
        GF.SortGroupFrames(CUI_PartyFrame)
    elseif type == "RaidFrame" then
        for i, frame in ipairs(CUI_RaidFrame.frames) do
            if state then
                ToggleEvents(frame, "player", true)
                frame.unit = "player"
                frame:SetAttribute("unit", "player")
                UpdateAll(frame)
                RegisterAttributeDriver(frame, "state-visibility", "show")
            else
                local unit = "raid"..i
                ToggleEvents(frame, unit, true)
                frame.unit = unit
                frame:SetAttribute("unit", unit)
                UpdateAll(frame)
                RegisterAttributeDriver(frame, "state-visibility", "[group:raid, @"..unit..", exists]show;hide")
            end
        end
        GF.UpdateAuras(CUI_RaidFrame)
        GF.SortGroupFrames(CUI_RaidFrame)
    end
end

---------------------------------------------------------------------------------------------------------------------------------

function GF.UpdateFrame(groupFrame)
    if InCombatLockdown() then return end
    local dbEntry = CUI.DB.profile.GroupFrames[groupFrame.name]

    for _, frame in ipairs(groupFrame.frames) do
        frame:SetSize(dbEntry.Width, dbEntry.Height)

        frame.HealthBar:SetStatusBarTexture(dbEntry.Texture)
        frame.Background:SetTexture(dbEntry.Texture)

        local dbEntryName = dbEntry.Name
        local unitName = frame.Overlay.UnitName
        if dbEntryName.Enabled then
            unitName:Show()
            unitName:ClearAllPoints()
            unitName:SetPoint(dbEntryName.AnchorPoint, frame.Overlay, dbEntryName.AnchorRelativePoint, dbEntryName.PosX, dbEntryName.PosY)
            unitName:SetFont(dbEntryName.Font, dbEntryName.Size, dbEntryName.Outline)
            unitName:SetWidth(dbEntryName.Width)
        else
            unitName:Hide()
        end

        local dbEntryRole = dbEntry.RoleIcon
        local roleIcon = frame.Overlay.RoleIcon
        if dbEntryRole.Enabled then
            UpdateRole(frame)
            roleIcon:ClearAllPoints()
            roleIcon:SetPoint(dbEntryRole.AnchorPoint, frame.Overlay, dbEntryRole.AnchorRelativePoint, dbEntryRole.PosX, dbEntryRole.PosY)
            roleIcon:SetSize(dbEntryRole.Size, dbEntryRole.Size)
        else
            roleIcon:Hide()
        end
    end

    Util.CheckAnchorFrame(groupFrame, dbEntry)

    groupFrame:ClearAllPoints()
    groupFrame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    GF.SortGroupFrames(groupFrame)
end

---------------------------------------------------------------------------------------------------------------------------------

local rolePriority = {
    ["TANK"] = 3,
    ["HEALER"] = 2,
    ["DAMAGER"] = 1,
    ["NONE"] = 0,
}

local classPriority = {
    WARRIOR      = 1,
    PALADIN      = 2,
    HUNTER       = 3,
    ROGUE        = 4,
    PRIEST       = 5,
    DEATHKNIGHT  = 6,
    SHAMAN       = 7,
    MAGE         = 8,
    WARLOCK      = 9,
    MONK         = 10,
    DRUID        = 11,
    DEMONHUNTER  = 12,
    EVOKER       = 13,
}

local function RoleComp(a, b)
    local aExists = UnitExists(a.unit)
    local bExists = UnitExists(b.unit)

    if aExists and bExists then
        if rolePriority[a.role] == rolePriority[b.role] then
            local _, aC = UnitClass(a.unit)
            local _, bC = UnitClass(b.unit)
            if aC and bC then
                return classPriority[aC] > classPriority[bC]
            else
                return UnitName(a.unit) > UnitName(b.unit)
            end
        else
            return rolePriority[a.role] > rolePriority[b.role]
        end
    elseif aExists and not bExists then
        return true
    elseif not aExists and bExists then
        return false
    else
        return a.unit < b.unit
    end
end

-- TODO : Istället för SetPoint använd SetAttribute("Unit", ...)?
function GF.SortGroupFrames(groupFrame)
    if InCombatLockdown() then return end
    local dbEntry = CUI.DB.profile.GroupFrames[groupFrame.name]

    table.sort(groupFrame.frames, RoleComp)

    local aF = dbEntry.AnchorFrame
    local aP = dbEntry.AnchorPoint
    local aRP = dbEntry.AnchorRelativePoint
    local dirH = dbEntry.DirH
    local dirV = dbEntry.DirV
    local width = dbEntry.Width
    local height = dbEntry.Height
    local padding = dbEntry.Padding
    local pX = dbEntry.PosX
    local pY = dbEntry.PosY
    local rL = dbEntry.RowLength
    for i, frame in ipairs(groupFrame.frames) do
        Util.PositionFromIndex(i-1, frame, aF, aP, aRP, dirH, dirV, width, height, padding, pX, pY, rL)
    end
end

local lastNumMem = 0
local function UpdateGroupFrames(groupFrame)
    local numMem = GetNumGroupMembers()
    if numMem == 0 then return end

    local groupType = groupFrame.groupType

    if groupType == "raid" and not IsInRaid() then return end
    if groupType == "party" and (not IsInGroup() or IsInRaid()) then return end

    GF.UpdateFrame(groupFrame)

    for i=1, numMem do
        local unit = groupType..i
        if groupType == "party" and i == numMem then unit = "player" end

        local frame = groupFrame[unit]

        UpdateAll(frame)

        UpdateAllAuras(frame)
    end

    --if lastNumMem == numMem then return end

    lastNumMem = numMem

    GF.SortGroupFrames(groupFrame)
end

---------------------------------------------------------------------------------------------------------------------------------

local function SetupGroupFrame(unit, groupType, frameName, parent)
    local dbEntry = CUI.DB.profile.GroupFrames[frameName]

    local frame = CreateFrame("Button", nil, parent, "CUI_UnitFrameTemplate")
    frame:SetParentKey(unit)
    frame:SetSize(dbEntry.Width, dbEntry.Height)

    frame:SetAttribute("unit", unit)
    frame:RegisterForClicks("AnyDown")
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")
    frame:SetAttribute("ping-receiver", true)

    frame.unit = unit
    frame.groupType = groupType
    frame.name = frameName
    frame.calc = CreateUnitHealPredictionCalculator()
    frame.calc:SetHealAbsorbClampMode(0)
    frame.calc:SetIncomingHealClampMode(1)

    frame.disconnected = nil
    frame.summon = nil
    frame.ress = nil
    frame.readyCheck = nil
    frame.phase = nil

    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetParentKey("HealthBar")
    healthBar:SetAllPoints(frame)
    healthBar:SetStatusBarTexture(dbEntry.Texture)

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetParentKey("Background")
    background:SetTexture(dbEntry.Texture)
    background:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")

    local healPrediction = CreateFrame("StatusBar", nil, frame)
    healPrediction:SetParentKey("HealPrediction")
    healPrediction:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    healPrediction:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    healPrediction:SetFrameLevel(healthBar:GetFrameLevel()+1)
    healPrediction:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")

    local absorbBar = CreateFrame("StatusBar", nil, frame)
    absorbBar:SetParentKey("AbsorbBar")
    absorbBar:SetFrameLevel(healPrediction:GetFrameLevel()+1)
    absorbBar:SetAllPoints(frame)
    absorbBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Striped.tga")
    absorbBar:SetStatusBarColor(1, 0, 0, 1)
    absorbBar:SetReverseFill(false)
    local absorbTexture = absorbBar:GetStatusBarTexture()
    absorbTexture:SetTexture("Interface/AddOns/CalippoUI/Media/Striped.tga", "REPEAT", "REPEAT")
    absorbTexture:SetHorizTile(true)

    local shieldBar = CreateFrame("StatusBar", nil, frame)
    shieldBar:SetParentKey("ShieldBar")
    shieldBar:SetAllPoints(frame)
    shieldBar:SetFrameLevel(absorbBar:GetFrameLevel()+1)
    shieldBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Striped.tga")
    shieldBar:SetStatusBarColor(0, 1, 1, 0.8)
    local shieldTexture = shieldBar:GetStatusBarTexture()
    shieldTexture:SetTexture("Interface/AddOns/CalippoUI/Media/Striped.tga", "REPEAT", "REPEAT")
    shieldTexture:SetHorizTile(true)

    local overlayFrame = CreateFrame("Frame", nil, frame)
    overlayFrame:SetParentKey("Overlay")
    overlayFrame:SetAllPoints(frame)
    overlayFrame:SetFrameLevel(10)
    Util.AddBorder(overlayFrame)

    frame.pool = CreateFramePool("Frame", overlayFrame, "CUI_AuraFrameTemplate")

    local dbEntryUN = dbEntry.Name
    local unitName = overlayFrame:CreateFontString(nil, "OVERLAY")
    unitName:SetParentKey("UnitName")
    unitName:SetPoint(dbEntryUN.AnchorPoint, overlayFrame, dbEntryUN.AnchorRelativePoint, dbEntryUN.PosX, dbEntryUN.PosY)
    unitName:SetFont(dbEntryUN.Font, dbEntryUN.Size, dbEntryUN.Outline)
    unitName:SetJustifyH("LEFT")
    unitName:SetWordWrap(false)
    unitName:SetText(UnitName(unit))

    local centerTexture = overlayFrame:CreateTexture(nil, "OVERLAY")
    centerTexture:SetParentKey("CenterTexture")
    centerTexture:SetPoint("CENTER")
    centerTexture:Hide()

    local unitDispel = overlayFrame:CreateTexture(nil, "OVERLAY")
    unitDispel:SetParentKey("Dispel")
    unitDispel:SetPoint("BOTTOMRIGHT", overlayFrame, "BOTTOMRIGHT", -3, 3)
    unitDispel:SetSize(12, 12)
    unitDispel:Hide()

    local unitRole = overlayFrame:CreateTexture(nil, "OVERLAY")
    unitRole:SetParentKey("RoleIcon")

    frame:SetScript("OnEvent", function(self, event)
        if event == "UNIT_AURA" then
            UpdateAllAuras(self)
            --UpdateDispel(self)
        elseif event == "UNIT_HEALTH" then
            UpdateHealth(self)
            UpdateHealPrediction(self)
            UpdateIsDead(self)
        elseif event == "UNIT_MAXHEALTH" then
            UpdateMaxHealth(self)
        elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            UpdateShieldAbsorb(self)
        elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
            UpdateHealAbsorb(self)
        elseif event == "UNIT_HEAL_PREDICTION" then
            UpdateHealPrediction(self)
        elseif event == "UNIT_IN_RANGE_UPDATE" then
            UpdateInRange(self)
        elseif event == "UNIT_DISTANCE_CHECK_UPDATE" then
            -- TODO ?
        elseif event == "UNIT_PHASE" then
            UpdateInPhase(self)
            UpdateCenterIcon(self)
        elseif event == "UNIT_CONNECTION" then
            UpdateConnection(self)
            UpdateCenterIcon(self)
        elseif event == "READY_CHECK" or event == "READY_CHECK_CONFIRM" or event == "READY_CHECK_FINISHED" then
            UpdateReadyCheck(self)
            UpdateCenterIcon(self)
        elseif event == "PLAYER_ROLES_ASSIGNED" then
            UpdateRole(self)
        elseif event == "INCOMING_RESURRECT_CHANGED" then
            UpdateRess(self)
            UpdateCenterIcon(self)
        elseif event == "INCOMING_SUMMON_CHANGED" then
            UpdateSummon(self)
            UpdateCenterIcon(self)
        end
    end)

    frame:HookScript("OnShow", function(self)
        ToggleEvents(self, self.unit, true)
    end)

    frame:HookScript("OnHide", function(self)
        ToggleEvents(self, self.unit, false)
    end)

    if groupType == "party" then
        RegisterAttributeDriver(frame, "state-visibility", "[group:raid]hide;[group:party, @"..unit..", exists]show;hide")
    else
        RegisterAttributeDriver(frame, "state-visibility", "[group:raid, @"..unit..", exists]show;hide")
    end
    RegisterUnitWatch(frame, true)

    return frame
end

---------------------------------------------------------------------------------------------------------------------------------

function GF.Load()
    HideBlizzard()

    local dbEntryP = CUI.DB.profile.GroupFrames.PartyFrame

    local partyFrame = CreateFrame("Frame", "CUI_PartyFrame", UIParent)
    partyFrame.groupType = "party"
    partyFrame.name = "PartyFrame"
    partyFrame.frames = {}
    partyFrame:SetPoint(dbEntryP.AnchorPoint, dbEntryP.AnchorFrame, dbEntryP.AnchorRelativePoint, dbEntryP.PosX, dbEntryP.PosY)
    partyFrame:SetSize(1, 1)
    partyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    partyFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    partyFrame:RegisterEvent("GROUP_JOINED")
    partyFrame:RegisterEvent("GROUP_LEFT")
    partyFrame:RegisterEvent("GROUP_FORMED")
    partyFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    partyFrame:SetScript("OnEvent", function(self, event)
        if event == "GROUP_ROSTER_UPDATE" then
            UpdateGroupFrames(self)
        elseif event == "PLAYER_ROLES_ASSIGNED" then
            if not IsInGroup() or IsInRaid() then return end
            GF.SortGroupFrames(self)
        elseif event == "GROUP_JOINED" or event == "GROUP_LEFT" or event == "GROUP_FORMED" then
            lastNumMem = 0
        elseif event == "PLAYER_REGEN_DISABLED" then
            if GetNumGroupMembers() ~= lastNumMem then
                UpdateGroupFrames(self)
            end
        end
    end)

    for i=1, 4 do
        local frame = SetupGroupFrame("party"..i, "party", "PartyFrame", partyFrame)
        table.insert(partyFrame.frames, frame)
    end

    local playerFrame = SetupGroupFrame("player", "party", "PartyFrame", partyFrame)
    table.insert(partyFrame.frames, playerFrame)

    UpdateGroupFrames(partyFrame)

    ------------------------------------------------------------------------------
    local dbEntryR = CUI.DB.profile.GroupFrames.RaidFrame

    local raidFrame = CreateFrame("Frame", "CUI_RaidFrame", UIParent)
    raidFrame.groupType = "raid"
    raidFrame.name = "RaidFrame"
    raidFrame.frames = {}
    raidFrame:SetPoint(dbEntryR.AnchorPoint, dbEntryR.AnchorFrame, dbEntryR.AnchorRelativePoint, dbEntryR.PosX, dbEntryR.PosY)
    raidFrame:SetSize(1, 1)
    raidFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    raidFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    raidFrame:RegisterEvent("GROUP_JOINED")
    raidFrame:RegisterEvent("GROUP_LEFT")
    raidFrame:RegisterEvent("GROUP_FORMED")
    raidFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    raidFrame:SetScript("OnEvent", function(self, event)
        if event == "GROUP_ROSTER_UPDATE" then
            UpdateGroupFrames(self)
        elseif event == "PLAYER_ROLES_ASSIGNED" then
            if not IsInRaid() then return end
            GF.SortGroupFrames(self)
        elseif event == "GROUP_JOINED" or event == "GROUP_LEFT" or event == "GROUP_FORMED" then
            lastNumMem = 0
        elseif event == "PLAYER_REGEN_DISABLED" then
            if GetNumGroupMembers() ~= lastNumMem then
                UpdateGroupFrames(self)
            end
        end
    end)

    for i=1, 40 do
        local frame = SetupGroupFrame("raid"..i, "raid", "RaidFrame", raidFrame)
        table.insert(raidFrame.frames, frame)
    end

    UpdateGroupFrames(raidFrame)
end