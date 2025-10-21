local addonName, CUI = ...

CUI.GF = {}
local GF = CUI.GF
local Util = CUI.Util
local Hide = CUI.Hide
local Const = CUI.Const

---------------------------------------------------------------------------------------------------------------------------------

local function IterateAuras(frame, auras, maxAuras, template)
    local index = 0
    local maxBuffRow = 3
    local maxDebuffRow = 6
    local frameSize = 18
    local pool = frame.pools:GetPool(template)
    pool:ReleaseAll()

    auras:Iterate(function(id, aura)
        if index >= maxAuras then return true end

        local auraFrame = pool:Acquire()
        auraFrame:Show()

        auraFrame.unit = frame.unit

        auraFrame.Icon:SetTexture(aura.icon)
        auraFrame.Icon:SetTexCoord(.08, .92, .08, .92)

        local frameCount = auraFrame.Overlay.Count
        if aura.applications > 1 then
            frameCount:SetText(aura.applications)
            frameCount:Show()
        else
            frameCount:Hide()
        end

        if aura.isHarmful then
			local color
			if aura.dispelName then
				color = DebuffTypeColor[aura.dispelName]
			else
				color = DebuffTypeColor["none"]
			end
            auraFrame.Overlay.Backdrop:ApplyBackdrop(CUI_BACKDROP_W_1)
			auraFrame.Overlay.Backdrop:SetBackdropBorderColor(color.r, color.g, color.b, 1)
		else
            auraFrame.Overlay.Backdrop:ApplyBackdrop(CUI_BACKDROP_B_06)
        end

        CooldownFrame_Set(auraFrame.Cooldown, aura.expirationTime - aura.duration, aura.duration, aura.duration > 0, true)

        auraFrame:ClearAllPoints()
        if aura.isHelpful then
            local level = math.floor(index/maxBuffRow)
            auraFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -(index*frameSize)+(level*maxBuffRow*frameSize), -(level*frameSize))
        else
            local level = math.floor(index/maxDebuffRow)
            auraFrame:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", (index*frameSize)+(level*maxDebuffRow*frameSize), (level*frameSize))
        end
        
        index = index + 1
    end)
end

local function AddAura(frame, aura)
    if not aura then return false end

    if aura.isHelpful then
        if Const.RaidBuffWhitelist[aura.spellId] then
            frame.buffs[aura.auraInstanceID] = aura
            return true
        end
    elseif aura.isHarmful then
        frame.debuffs[aura.auraInstanceID] = aura
        return true
    end

    return false
end

local function AddAllAuras(frame)
    frame.buffs:Clear()
    frame.debuffs:Clear()

	local function HandleAura(aura)
		AddAura(frame, aura)
		return false
	end

	AuraUtil.ForEachAura(frame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful), nil, HandleAura, true)
    AuraUtil.ForEachAura(frame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful), nil, HandleAura, true)
end

local function UpdateAuras(frame, unit, updateInfo)
	local buffsChanged = false
    local debuffsChanged = false

    if updateInfo == nil or updateInfo.isFullUpdate then
        AddAllAuras(frame)
        buffsChanged = true
        debuffsChanged = true
    else
        if updateInfo.addedAuras then
            for _, aura in ipairs(updateInfo.addedAuras) do
                local added = AddAura(frame, aura)
                if added then
                    if aura.isHelpful then
                        buffsChanged = true
                    elseif aura.isHarmful then
                        debuffsChanged = true
                    end
                end
            end
        end

        if updateInfo.updatedAuraInstanceIDs then
            for _, id in ipairs(updateInfo.updatedAuraInstanceIDs) do
				local wasInDebuff = frame.debuffs[id] ~= nil
				local wasInBuff = frame.buffs[id] ~= nil
				if wasInDebuff or wasInBuff then
					local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(frame.unit, id)
					frame.debuffs[id] = nil
					frame.buffs[id] = nil
					local added = AddAura(frame, newAura)
                    if added then
                        if newAura and (newAura.isHelpful or wasInBuff) then
                            buffsChanged = true
                        end
                        if newAura and (newAura.isHarmful or wasInDebuff) then
                            debuffsChanged = true
                        end
                    end
				end 
            end
        end

        if updateInfo.removedAuraInstanceIDs then
            for _, id in ipairs(updateInfo.removedAuraInstanceIDs) do
                if frame.buffs[id] then
                    frame.buffs[id] = nil
                    buffsChanged = true
                elseif frame.debuffs[id] then
                    frame.debuffs[id] = nil
                    debuffsChanged = true
                end
            end
        end
    end

    if not (buffsChanged or debuffsChanged) then return end

    if buffsChanged then
        local numBuffs = math.min(6, frame.buffs:Size());
        if frame.groupType == "party" then
            IterateAuras(frame, frame.buffs, numBuffs, "CUI_PartyFrameBuff")
        else
            IterateAuras(frame, frame.buffs, numBuffs, "CUI_RaidFrameBuff")
        end
    end

    if debuffsChanged then
        local numDebuffs = math.min(6, frame.debuffs:Size());
        if frame.groupType == "party" then
            IterateAuras(frame, frame.debuffs, numDebuffs, "CUI_PartyFrameDebuff")
        else
            IterateAuras(frame, frame.debuffs, numDebuffs, "CUI_RaidFrameDebuff")
        end
    end
end

---------------------------------------------------------------------------------------------------------------------------------

local function HideBlizzard()
    Hide.HideBlizzardParty()
    Hide.HideBlizzardRaid()
    Hide.HideBlizzardRaidManager()
end

local function UpdateHealth(frame)
    frame.HealthBar:SetValue(UnitHealth(frame.unit))
end

local function UpdateMaxHealth(frame)
    frame.HealthBar:SetMinMaxValues(0, UnitHealthMax(frame.unit))
    frame.HealthBar:SetValue(UnitHealth(frame.unit))
end

local function UpdateShield(frame)
    frame.ShieldBar:SetValue(UnitGetTotalAbsorbs(frame.unit))
end

local function UpdateMaxShield(frame)
    frame.ShieldBar:SetMinMaxValues(0, UnitHealthMax(frame.unit))
    frame.ShieldBar:SetValue(UnitGetTotalAbsorbs(frame.unit))
end

local function UpdateAbsorb(frame)
    local absorb = UnitGetTotalHealAbsorbs(frame.unit)
    local health = UnitHealth(frame.unit)

    if absorb > health then
        frame.AbsorbBar:SetValue(health)
    else
        frame.AbsorbBar:SetValue(absorb)
    end
end

local function UpdateMaxAbsorb(frame)
    local absorb = UnitGetTotalHealAbsorbs(frame.unit)
    local health = UnitHealth(frame.unit)

    frame.AbsorbBar:SetMinMaxValues(0, UnitHealthMax(frame.unit))
    if absorb > health then
        frame.AbsorbBar:SetValue(health)
    else
        frame.AbsorbBar:SetValue(absorb)
    end
end

local function UpdateInRange(frame)
    if UnitInRange(frame.unit) then
        frame.HealthBar:SetAlpha(1)
        frame.HealthBar.Background:SetAlpha(1)
    else
        frame.HealthBar:SetAlpha(0.5)
        frame.HealthBar.Background:SetAlpha(0.3)
    end
end

local function UpdateInPhase(frame)
    local phaseReason = UnitPhaseReason(frame.unit)
    if phaseReason then
        frame.Overlay.Phase:Show()
    else
        frame.Overlay.Phase:Hide()
    end
end

local function UpdateIsDead(frame)
    if UnitIsDeadOrGhost(frame.unit) then
        frame.HealthBar.Background:SetColorTexture(0.5, 0, 0, 1)
        frame.dead = true
    elseif frame.dead == true then
        frame.HealthBar.Background:SetColorTexture(1, 1, 1, 1)
        frame.dead = false
    end
end

local function UpdateConnection(frame)
    local isOnline = UnitIsConnected(frame.unit)
    if isOnline then
        frame.Overlay.Connection:Hide()
    else
        frame.Overlay.Connection:Show()
    end
end

local function UpdateReadyCheck(frame)
    local status = GetReadyCheckStatus(frame.unit)
    if status == "ready" then
        frame.Overlay.Readycheck:SetTexture("Interface/AddOns/CalippoUI/Media/readycheck-ready.tga")
        frame.Overlay.Readycheck:Show()
    elseif status == "waiting" then
        frame.Overlay.Readycheck:SetTexture("Interface/AddOns/CalippoUI/Media/readycheck-waiting.tga")           
        frame.Overlay.Readycheck:Show()
    elseif status == "notready" then
        frame.Overlay.Readycheck:SetTexture("Interface/AddOns/CalippoUI/Media/readycheck-notready.tga")
        frame.Overlay.Readycheck:Show()
    else
        frame.Overlay.Readycheck:Hide()
    end
end

local function UpdateRole(frame)
    frame.role = UnitGroupRolesAssigned(frame.unit)

    if frame.role == "TANK" then
        frame.Overlay.Role:SetTexture("Interface/AddOns/CalippoUI/Media/TANK.tga")
        frame.Overlay.Role:Show()
    elseif frame.role == "HEALER" then
        frame.Overlay.Role:SetTexture("Interface/AddOns/CalippoUI/Media/HEALER.tga")
        frame.Overlay.Role:Show()
    else
        frame.Overlay.Role:Hide()
    end
end

local function UpdateRess(frame)
    if UnitHasIncomingResurrection(frame.unit) then
        frame.Overlay.Ress:Show()
    else
        frame.Overlay.Ress:Hide()
    end
end

local function UpdateName(frame)
    local r, g, b = Util.GetUnitColor(frame.unit)
    frame.Overlay.UnitName:SetTextColor(r, g, b, 1)
    frame.Overlay.UnitName:SetText(UnitName(frame.unit))
end

local function UpdateSummon(frame)
    local status = C_IncomingSummon.IncomingSummonStatus(frame.unit)
    if status == Enum.SummonStatus.Pending then
        frame.Overlay.Summon:SetTexture("Interface/AddOns/CalippoUI/Media/Raid-Icon-SummonPending.tga")
        frame.Overlay.Summon:Show()
    elseif status == Enum.SummonStatus.Accepted then
        frame.Overlay.Summon:SetTexture("Interface/AddOns/CalippoUI/Media/Raid-Icon-SummonAccepted.tga")
        frame.Overlay.Summon:Show()
    elseif status == Enum.SummonStatus.Declined then
        frame.Overlay.Summon:SetTexture("Interface/AddOns/CalippoUI/Media/Raid-Icon-SummonDeclined.tga")
        frame.Overlay.Summon:Show()
    else
        frame.Overlay.Summon:Hide()
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

local function UpdateAll(frame)
    UpdateMaxHealth(frame)
    UpdateMaxShield(frame)
    UpdateMaxAbsorb(frame)
    UpdateInRange(frame)
    UpdateInPhase(frame)
    UpdateIsDead(frame)
    UpdateConnection(frame)
    UpdateReadyCheck(frame)
    UpdateRole(frame)
    UpdateName(frame)
    UpdateSummon(frame)
end

local rolePriority = {
    ["TANK"] = 3,
    ["HEALER"] = 2,
    ["DAMAGER"] = 1,
    ["NONE"] = 0,
}

local function RoleComp(a, b)
    local aExists = UnitExists(a.unit)
    local bExists = UnitExists(b.unit)

    if aExists and bExists then
        if rolePriority[a.role] == rolePriority[b.role] then
            return UnitName(a.unit) < UnitName(b.unit)
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

local function SortGroupFrames(groupFrame)
    if InCombatLockdown() then return end
    table.sort(groupFrame.frames, RoleComp)

    if groupFrame.groupType == "party" then
        local height = CalippoDB.partyFrame.sizeY
        for i, frame in ipairs(groupFrame.frames) do
            local spacing = 0
            local positionY = -(i-1)*(height+spacing)

            frame:SetPoint("TOPLEFT", frame:GetParent(), "TOPLEFT", 0, positionY)
        end
    else
        local width = CalippoDB.raidFrame.sizeX
        local height = CalippoDB.raidFrame.sizeY
        for i, frame in ipairs(groupFrame.frames) do
            local spacing = 0
            local level = math.floor((i-1)/5)
            local positionX = (i-1)*(width+spacing)-(level*(width+spacing)*5)
            local positionY = -height*level

            frame:SetPoint("TOPLEFT", frame:GetParent(), "TOPLEFT", positionX, positionY)
        end
    end
end

local lastNumMem = 0
local function UpdateGroupFrames(groupFrame)
    local numMem = GetNumGroupMembers()
    if numMem == 0 then return end

    local groupType = groupFrame.groupType

    if groupType == "raid" and not IsInRaid() then return end
    if groupType == "party" and (not IsInGroup() or IsInRaid()) then return end

    for i=1, numMem do
        local unit = groupType..i
        if groupType == "party" and i == numMem then unit = "player" end

        local frame = groupFrame[unit]

        UpdateAll(frame)

        --UpdateAuras(frame, unit)
    end
    
    if lastNumMem == numMem then return end

    lastNumMem = numMem

    SortGroupFrames(groupFrame)
end

function GF.SetFramePosition(groupType, value, axis)
    local frame = _G["CUI_"..groupType.."Frame"]
    if axis == "X" then
        print("asdasd", value)
        frame:SetPoint("TOPLEFT", frame:GetParent(), "CENTER", value, CalippoDB[groupType.."Frame"].posY)
        CalippoDB[groupType.."Frame"]["pos"..axis] = value
    elseif axis == "Y" then
        frame:SetPoint("TOPLEFT", frame:GetParent(), "CENTER", CalippoDB[groupType.."Frame"].posX, value)
        CalippoDB[groupType.."Frame"]["pos"..axis] = value
    end
end

---------------------------------------------------------------------------------------------------------------------------------

local function SetupGroupFrame(unit, groupType, parent, offsetX, offsetY, sizeX, sizeY)
    local frame = CreateFrame("Button", nil, parent, "CUI_UnitFrameTemplate")
    frame:SetParentKey(unit)
    frame:SetSize(sizeX, sizeY)

    frame:SetAttribute("unit", unit)
    frame:RegisterForClicks("AnyDown")
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")
    frame:SetAttribute("ping-receiver", true)

    frame.unit = unit
    frame.groupType = groupType

    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetParentKey("HealthBar")
    healthBar:SetAllPoints(frame)
    healthBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
    healthBar:SetStatusBarColor(0, 0, 0, 1)

    Util.AddBackdrop(healthBar, 0, CUI_BACKDROP_W_06)
    healthBar.Backdrop:SetBackdropBorderColor(0, 0, 0, 1)

    local healthBarBg = healthBar:CreateTexture(nil, "BACKGROUND")
    healthBarBg:SetParentKey("Background")
    healthBarBg:SetAllPoints(healthBar)
    healthBarBg:SetColorTexture(1, 1, 1, 1)

    local absorbBar = CreateFrame("StatusBar", nil, frame)
    absorbBar:SetParentKey("AbsorbBar")
    absorbBar:SetFrameLevel(healthBar:GetFrameLevel()+1)
    absorbBar:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT")
    absorbBar:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT")
    absorbBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
    absorbBar:SetStatusBarColor(1, 0, 0, 0.8)
    absorbBar:SetReverseFill(false)

    local shieldBar = CreateFrame("StatusBar", nil, frame)
    shieldBar:SetParentKey("ShieldBar")
    shieldBar:SetAllPoints(frame)
    shieldBar:SetFrameLevel(healthBar:GetFrameLevel()+2)
    shieldBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
    shieldBar:SetStatusBarColor(0, 1, 1, 0.5)

    local overlayFrame = CreateFrame("Frame", nil, frame)
    overlayFrame:SetParentKey("Overlay")
    overlayFrame:SetAllPoints(frame)
    overlayFrame:SetFrameLevel(10)

    local unitName = overlayFrame:CreateFontString(nil, "OVERLAY")
    unitName:SetParentKey("UnitName")
    unitName:SetPoint("TOPLEFT", overlayFrame, "TOPLEFT", 3, -3)
    unitName:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 10, "")
    unitName:SetText(UnitName(unit))

    Util.AddBackdrop(overlayFrame, 0, CUI_BACKDROP_W_06)
    overlayFrame.Backdrop:Hide()

    local readyCheck = overlayFrame:CreateTexture(nil, "OVERLAY")
    readyCheck:SetParentKey("Readycheck")
    readyCheck:SetPoint("CENTER")
    readyCheck:SetSize(20, 20)
    readyCheck:Hide()

    local unitPhase = overlayFrame:CreateTexture(nil, "OVERLAY")
    unitPhase:SetParentKey("Phase")
    unitPhase:SetPoint("CENTER")
    unitPhase:SetSize(30, 30)
    unitPhase:SetTexture("Interface/AddOns/CalippoUI/Media/UI-PhasingIcon.blp")
    unitPhase:Hide()

    local unitConnection = overlayFrame:CreateTexture(nil, "OVERLAY")
    unitConnection:SetParentKey("Connection")
    unitConnection:SetPoint("CENTER")
    unitConnection:SetSize(50, 50)
    unitConnection:SetTexture("Interface/AddOns/CalippoUI/Media/Disconnect-Icon.blp")
    unitConnection:Hide()

    local unitRess = overlayFrame:CreateTexture(nil, "OVERLAY")
    unitRess:SetParentKey("Ress")
    unitRess:SetPoint("CENTER")
    unitRess:SetSize(20, 20)
    unitRess:SetTexture("Interface/AddOns/CalippoUI/Media/Raid-Icon-Rez.blp")
    unitRess:Hide()

    local unitSummon = overlayFrame:CreateTexture(nil, "OVERLAY")
    unitSummon:SetParentKey("Summon")
    unitSummon:SetPoint("CENTER")
    unitSummon:SetSize(50, 50)
    unitSummon:Hide()

    local unitDispel = overlayFrame:CreateTexture(nil, "OVERLAY")
    unitDispel:SetParentKey("Dispel")
    unitDispel:SetPoint("BOTTOMRIGHT", overlayFrame, "BOTTOMRIGHT", -3, 3)
    unitDispel:SetSize(15, 15)
    unitDispel:Hide()

    local unitRole = overlayFrame:CreateTexture(nil, "OVERLAY")
    unitRole:SetParentKey("Role")
    unitRole:SetPoint("TOPLEFT", overlayFrame, "TOPLEFT", 4, -15)
    unitRole:SetSize(10, 10)
    unitRole:Hide()

    frame.pools = CreateFramePoolCollection()
    if groupType == "party" then
        frame.pools:CreatePool("Frame", overlayFrame, "CUI_PartyFrameBuff")
        frame.pools:CreatePool("Frame", overlayFrame, "CUI_PartyFrameDebuff")
    else
        frame.pools:CreatePool("Frame", overlayFrame, "CUI_RaidFrameBuff")
        frame.pools:CreatePool("Frame", overlayFrame, "CUI_RaidFrameDebuff")
    end
    frame.buffs = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable)
    frame.debuffs = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable)

    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_AURA" then
            local unit, updateInfo = ...
            UpdateAuras(self, unit, updateInfo)
            UpdateDispel(self)
        elseif event == "UNIT_HEALTH" then
            UpdateHealth(self)
            UpdateIsDead(self)
        elseif event == "UNIT_MAXHEALTH" then
            UpdateMaxHealth(self)
            UpdateMaxShield(self)
            UpdateMaxAbsorb(self)
        elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            UpdateShield(self)
        elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
            UpdateAbsorb(self)
        elseif event == "UNIT_IN_RANGE_UPDATE" then
            UpdateInRange(self)
        elseif event == "UNIT_DISTANCE_CHECK_UPDATE" then
            -- TODO ?
        elseif event == "UNIT_PHASE" then
            UpdateInPhase(self)
        elseif event == "UNIT_CONNECTION" then
            UpdateConnection(self)
        elseif event == "READY_CHECK" then
            UpdateReadyCheck(self)
        elseif event == "READY_CHECK_CONFIRM" then
            UpdateReadyCheck(self)
        elseif event == "READY_CHECK_FINISHED" then
            UpdateReadyCheck(self)
        elseif event == "PLAYER_ROLES_ASSIGNED" then
            UpdateRole(self)
        elseif event == "INCOMING_RESURRECT_CHANGED" then
            UpdateRess(self)
        elseif event == "INCOMING_SUMMON_CHANGED" then
            UpdateSummon(self)
        end
    end)

    frame:HookScript("OnEnter", function(self)
        self.Overlay.Backdrop:Show()
    end)

    frame:HookScript("OnLeave", function(self)
        self.Overlay.Backdrop:Hide()
    end)

    frame:HookScript("OnShow", function(self)
        frame:RegisterUnitEvent("UNIT_AURA", unit)
        frame:RegisterUnitEvent("UNIT_HEALTH", unit)
        frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
        frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit)
        frame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unit)
        frame:RegisterUnitEvent("UNIT_PHASE", unit)
        frame:RegisterUnitEvent("UNIT_CONNECTION", unit)
        frame:RegisterEvent("READY_CHECK")
        frame:RegisterEvent("READY_CHECK_CONFIRM")
        frame:RegisterEvent("READY_CHECK_FINISHED")
        frame:RegisterEvent("INCOMING_RESURRECT_CHANGED")
        frame:RegisterEvent("INCOMING_SUMMON_CHANGED")
        frame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
        self:RegisterUnitEvent("UNIT_IN_RANGE_UPDATE", self.unit)
        --self:RegisterUnitEvent("UNIT_DISTANCE_CHECK_UPDATE", self.unit)
    end)

    frame:HookScript("OnHide", function(self)
        frame:UnregisterEvent("UNIT_AURA", unit)
        frame:UnregisterEvent("UNIT_HEALTH", unit)
        frame:UnregisterEvent("UNIT_MAXHEALTH", unit)
        frame:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit)
        frame:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unit)
        frame:UnregisterEvent("UNIT_PHASE", unit)
        frame:UnregisterEvent("UNIT_CONNECTION", unit)
        frame:UnregisterEvent("READY_CHECK")
        frame:UnregisterEvent("READY_CHECK_CONFIRM")
        frame:UnregisterEvent("READY_CHECK_FINISHED")
        frame:UnregisterEvent("INCOMING_RESURRECT_CHANGED")
        frame:UnregisterEvent("INCOMING_SUMMON_CHANGED")
        frame:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
        self:UnregisterEvent("UNIT_IN_RANGE_UPDATE")
        --self:UnregisterEvent("UNIT_DISTANCE_CHECK_UPDATE")
    end)

    RegisterUnitWatch(frame, false)

    return frame
end

---------------------------------------------------------------------------------------------------------------------------------

function GF.OnLoad()
    HideBlizzard()

    ------------------------------------------------------------------------------

    local partyFrame = CreateFrame("Frame", "CUI_partyFrame", UIParent)
    partyFrame.groupType = "party"
    partyFrame.frames = {}
    partyFrame:SetPoint("TOPLEFT", UIParent, "CENTER", CalippoDB.partyFrame.posX, CalippoDB.partyFrame.posY)
    partyFrame:SetSize(1, 1)
    RegisterAttributeDriver(partyFrame, "state-visibility", "[group:raid]hide;[group:party]show;hide")
    partyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    partyFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    partyFrame:RegisterEvent("GROUP_JOINED")
    partyFrame:RegisterEvent("GROUP_LEFT")
    partyFrame:RegisterEvent("GROUP_FORMED")
    partyFrame:SetScript("OnEvent", function(self, event)
        if event == "GROUP_ROSTER_UPDATE" then
            UpdateGroupFrames(self)
        elseif event == "PLAYER_ROLES_ASSIGNED" then
            if not IsInGroup() or IsInRaid() then return end
            SortGroupFrames(self)
        elseif event == "GROUP_JOINED" or event == "GROUP_LEFT" or event == "GROUP_FORMED" then
            lastNumMem = 0
        end
    end)


    local sizeX, sizeY = 175, 70
    for i=1, 4 do        
        local frame = SetupGroupFrame("party"..i, "party", partyFrame, 0, 0, CalippoDB.partyFrame.sizeX, CalippoDB.partyFrame.sizeY)
        table.insert(partyFrame.frames, frame)
    end

    local playerFrame = SetupGroupFrame("player", "party", partyFrame, 0, 0, CalippoDB.partyFrame.sizeX, CalippoDB.partyFrame.sizeY)
    table.insert(partyFrame.frames, playerFrame)

    UpdateGroupFrames(partyFrame)

    ------------------------------------------------------------------------------

    local raidFrame = CreateFrame("Frame", "CUI_raidFrame", UIParent)
    raidFrame.groupType = "raid"
    raidFrame.frames = {}
    raidFrame:SetPoint("TOPLEFT", UIParent, "CENTER", CalippoDB.raidFrame.posX, CalippoDB.raidFrame.posY)
    raidFrame:SetSize(1, 1)
    RegisterAttributeDriver(raidFrame, "state-visibility", "[group:raid]show;hide")
    raidFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    raidFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    raidFrame:RegisterEvent("GROUP_JOINED")
    raidFrame:RegisterEvent("GROUP_LEFT")
    raidFrame:RegisterEvent("GROUP_FORMED")
    raidFrame:SetScript("OnEvent", function(self, event)
        if event == "GROUP_ROSTER_UPDATE" then
            UpdateGroupFrames(self)
        elseif event == "PLAYER_ROLES_ASSIGNED" then
            if not IsInRaid() then return end
            SortGroupFrames(self)
        elseif event == "GROUP_JOINED" or event == "GROUP_LEFT" or event == "GROUP_FORMED" then
            lastNumMem = 0
        end
    end)

    for i=1, 40 do
        local frame = SetupGroupFrame("raid"..i, "raid", raidFrame, 0, 0, CalippoDB.raidFrame.sizeX, CalippoDB.raidFrame.sizeY)
        table.insert(raidFrame.frames, frame)
    end

    UpdateGroupFrames(raidFrame)
end