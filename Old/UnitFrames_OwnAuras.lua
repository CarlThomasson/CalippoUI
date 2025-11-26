local addonName, CUI = ...

CUI.UF = {}
local UF = CUI.UF
local Util = CUI.Util
local Hide = CUI.Hide

---------------------------------------------------------------------------------------------------------------------------------

local function GetIndexTable(frame, auras)
    local indexTable = {}
    local i = 1

    while true do
        local a = C_UnitAuras.GetBuffDataByIndex(frame.unit, i)
        if not a then break end
        indexTable[a.auraInstanceID] = i
        i = i + 1
    end

    i = 1
    while true do
        local a = C_UnitAuras.GetDebuffDataByIndex(frame.unit, i)
        if not a then break end
        indexTable[a.auraInstanceID] = i
        i = i + 1
    end
    
    return indexTable
end

local function IterateAuras(frame, auras, isBuff, maxAuras, template)
    local maxRow = 9
    local frameSize = 21
    local indexTable = GetIndexTable(frame, auras)
    local pool = frame.pools:GetPool(template)
    pool:ReleaseAll()

    for index, aura in ipairs(auras) do
        if index > maxAuras then return end

        local auraFrame = pool:Acquire()
        auraFrame:Show()

        auraFrame.unit = frame.unit
        auraFrame.index = indexTable[aura.auraInstanceID]

        auraFrame.Icon:SetTexture(aura.icon)
        auraFrame.Icon:SetTexCoord(.08, .92, .08, .92)

        local frameCount = auraFrame.Overlay.Count
        if aura.applications > 1 then
            frameCount:SetText(aura.applications)
            frameCount:Show()
        else
            frameCount:Hide()
        end

        if not isBuff then
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

        index = index - 1

        local level = math.floor(index/maxRow)

        auraFrame:ClearAllPoints()
        if isBuff then
            auraFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", (index*frameSize)-(level*maxRow*frameSize), -(level*frameSize)-2)
        else
            auraFrame:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -(index*frameSize)+(level*maxRow*frameSize), 2+(level*frameSize))
        end
    end
end

local function UpdateAuras(frame, unit, updateInfo)
    local buffs = {}
    local debuffs = {}

	local function HandleBuff(aura)
        table.insert(buffs, aura)
	end

    local function HandleDebuff(aura)
        table.insert(debuffs, aura)
	end

	AuraUtil.ForEachAura(frame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful), nil, HandleBuff, true)
    AuraUtil.ForEachAura(frame.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful), nil, HandleDebuff, true)

    local numBuffs = math.min(18, #buffs)
    IterateAuras(frame, buffs, true, numBuffs, "CUI_UnitFrameBuff")

    local numDebuffs = math.min(18, #debuffs)
    IterateAuras(frame, debuffs, false, numDebuffs, "CUI_UnitFrameDebuff")  
end

---------------------------------------------------------------------------------------------------------------------------------

local function HideBlizzard()
    Hide.HideFrame(PlayerFrame)
    Hide.HideFrame(TargetFrame)
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
    if frame.showAuras then UpdateAuras(frame, frame.unit, nil) end
    if frame.showPower then UpdatePowerFull(frame) end
    UpdateHealthFull(frame)
    UpdateLeaderAssist(frame)
    UpdateNameText(frame)
end

function UF.SetFramePosition(frame, unit, value, axis)
    if axis == "X" then
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", frame:GetParent(), "CENTER", value, CalippoDB[unit.."Frame"].posY)
        CalippoDB[unit.."Frame"]["pos"..axis] = value
    elseif axis == "Y" then
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", frame:GetParent(), "CENTER", CalippoDB[unit.."Frame"].posX, value)
        CalippoDB[unit.."Frame"]["pos"..axis] = value
    end
end

---------------------------------------------------------------------------------------------------------------------------------

local function SetupUnitFrame(unit, posX, posY, sizeX, sizeY, showAuras, showPower, powerHeight)
    local frame = CreateFrame("Button", "CUI_"..unit.."Frame", UIParent, "CUI_UnitFrameTemplate")
    frame:SetPoint("CENTER", UIParent, "CENTER", posX, posY)
    frame:SetSize(sizeX, sizeY)

    frame:SetAttribute("unit", unit)
    frame:RegisterForClicks("AnyDown")
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")
    frame:SetAttribute("ping-receiver", true)

    frame.unit = unit
    frame.showAuras = showAuras
    frame.showPower = showPower

    frame:SetAlpha(0.5)

    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetParentKey("HealthBar")
    healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT")
    healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, powerHeight or 0)
    healthBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
    Util.AddStatusBarBackground(healthBar)
    Util.AddBackdrop(healthBar, 1, CUI_BACKDROP_DS_3)

    if showPower then
        frame:RegisterUnitEvent("UNIT_POWER_UPDATE", unit)
        frame:RegisterUnitEvent("UNIT_MAXPOWER", unit)

        local powerBar = CreateFrame("StatusBar", nil, frame)
        powerBar:SetParentKey("PowerBar")
        powerBar:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, powerHeight)
        powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
        powerBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")

        if unit == "player" then
            local _, powerType = UnitPowerType("player")
            if powerType == nil or powerType == "MANA" then powerType = "MAELSTROM" end
            local color = PowerBarColor[powerType]
            powerBar:SetStatusBarColor(color.r, color.g, color.b, 1)
        end

        Util.AddStatusBarBackground(powerBar)
        Util.AddBackdrop(powerBar, 1, CUI_BACKDROP_DS_3)
    end

    local overlayFrame = CreateFrame("Frame", nil, frame)
    overlayFrame:SetParentKey("Overlay")
    overlayFrame:SetAllPoints(frame)
    overlayFrame:SetFrameLevel(10)

    local unitName = overlayFrame:CreateFontString(nil, "OVERLAY")
    unitName:SetParentKey("UnitName")
    unitName:SetPoint("LEFT", overlayFrame, "LEFT", 5, 0)
    unitName:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 12, "")
    unitName:SetText(UnitName(unit))
    
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

    if showAuras then
        frame:RegisterUnitEvent("UNIT_AURA", unit)
        frame.pools = CreateFramePoolCollection()
        frame.pools:CreatePool("Frame", frame, "CUI_UnitFrameBuff")
        frame.pools:CreatePool("Frame", frame, "CUI_UnitFrameDebuff")
        UpdateAuras(frame, unit, nil)
    end

    frame:RegisterUnitEvent("UNIT_HEALTH", unit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PARTY_LEADER_CHANGED")
    frame:RegisterEvent("GROUP_FORMED")
    frame:RegisterEvent("GROUP_LEFT")
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_AURA" then
            local unit, updateInfo = ...
            UpdateAuras(self, unit, updateInfo)
        elseif event == "UNIT_HEALTH" then
            UpdateHealth(self)
        elseif event == "UNIT_MAXHEALTH" then
            UpdateMaxHealth(self)
        elseif event == "UNIT_POWER_UPDATE" then
            UpdatePower(self)
        elseif event == "UNIT_MAXPOWER" then
            UpdateMaxPower(self)
        elseif event == "PLAYER_TARGET_CHANGED" then
            if not UnitExists(self.unit) then return end
            UpdateAll(frame)
        elseif event == "PLAYER_REGEN_ENABLED" then
            UIFrameFadeOut(self, 0.6, 1, 0.5)
        elseif event == "PLAYER_REGEN_DISABLED" then
            UIFrameFadeIn(self, 0.5, 0.5, 1)
        elseif event == "PARTY_LEADER_CHANGED" or event == "GROUP_FORMED" or event == "GROUP_LEFT" then
            UpdateLeaderAssist(self)
        end
    end)

    UpdateAll(frame)

    RegisterUnitWatch(frame, false)
end

---------------------------------------------------------------------------------------------------------------------------------

function UF.OnLoad()
    --HideBlizzard()

    SetupUnitFrame("player", CalippoDB.playerFrame.posX, CalippoDB.playerFrame.posY, CalippoDB.playerFrame.sizeX, CalippoDB.playerFrame.sizeY, false, false)
    SetupUnitFrame("target", CalippoDB.targetFrame.posX, CalippoDB.targetFrame.posY, CalippoDB.targetFrame.sizeX, CalippoDB.targetFrame.sizeY, true, true, 5)
end