local addonName, CUI = ...

CUI.UF = {}
local UF = CUI.UF
local Util = CUI.Util
local Hide = CUI.Hide

---------------------------------------------------------------------------------------------------

function HideBlizzard()
    PlayerFrame.PlayerFrameContent:Hide()
    PlayerFrame.PlayerFrameContainer:Hide()

    TargetFrame.TargetFrameContent:Hide()
    TargetFrame.TargetFrameContainer:Hide()
    TargetFrameSpellBar:SetScript("OnShow", function()
        TargetFrameSpellBar:Hide()
    end)

    FocusFrame.TargetFrameContent:Hide()
    FocusFrame.TargetFrameContainer:Hide()

    Hide.HideFrame(PaladinPowerBarFrame)
    Hide.HideFrame(RuneFrame)
end

---------------------------------------------------------------------------------------------------

function UF.UpdateSizePos(frame)
    frame.HealthBar:SetPoint("CENTER", frame, "CENTER", CalippoDB.UnitFrames[frame:GetName()].OffsetX, CalippoDB.UnitFrames[frame:GetName()].OffsetY)
    frame.HealthBar:SetSize(CalippoDB.UnitFrames[frame:GetName()].SizeX, CalippoDB.UnitFrames[frame:GetName()].SizeY)
    frame.Overlay.UnitName:SetWidth(frame.Overlay:GetWidth() - 60)
end

function UF.UpdateAlpha(frame, inCombat)
    if InCombatLockdown() or inCombat then 
        frame:SetAlpha(1)
    else
        UIFrameFadeOut(frame, 0.6, frame:GetAlpha(), CalippoDB.UnitFrames[frame:GetName()].Alpha)
    end
end

function UF.UpdateAuras(unitFrame)
    local auraFrames = {}
    local maxRow = CalippoDB.UnitFrames.AuraRowLength
    local frameSize = CalippoDB.UnitFrames.AuraSize
    local padding = CalippoDB.UnitFrames.AuraPadding
    local index = 0

    for frame in unitFrame.auraPools:EnumerateActive() do
        auraFrames[frame.auraInstanceID] = frame
    end        

    unitFrame.activeBuffs:Iterate(function(id, aura)
        local frame = auraFrames[id]
        frame:ClearAllPoints()
        frame:SetSize(frameSize, frameSize)
        frame.Icon:SetTexCoord(.08, .92, .08, .92)
        frame.Count:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")

        if not frame.Backdrop then
            Util.AddBackdrop(frame, 1, CUI_BACKDROP_DS_2)
        end
        
        local level = math.floor(index/maxRow)

        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMRIGHT", TargetFrame.HealthBar, "TOPRIGHT", -(index*(frameSize+padding))+(level*maxRow*(frameSize+padding)), 2+(level*(frameSize+padding)))

        index = index + 1
    end)

    index = 0

    unitFrame.activeDebuffs:Iterate(function(id, aura)
        local frame = auraFrames[id]
        frame:SetSize(frameSize, frameSize)
        frame:SetPoint("TOPLEFT", TargetFrame.HealthBar, "BOTTOMLEFT")
        frame.Icon:SetTexCoord(.08, .92, .08, .92)
        frame.Count:SetFont("Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf", 12, "")

        if not frame.Backdrop then
            Util.AddBackdrop(frame, 1, CUI_BACKDROP_DS_2)
        end

        local level = math.floor(index/maxRow)

        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", TargetFrame.PowerBar, "BOTTOMLEFT", (index*(frameSize+padding))-(level*maxRow*(frameSize+padding)), -(level*(frameSize+padding))-2)

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

---------------------------------------------------------------------------------------------------

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
        powerBar:SetFrameLevel(healthBar:GetFrameLevel() + 1)
        Util.AddStatusBarBackground(powerBar)
        Util.AddBackdrop(powerBar, 1, CUI_BACKDROP_DS_3)
    end
    healthBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
    Util.AddStatusBarBackground(healthBar)
    Util.AddBackdrop(healthBar, 1, CUI_BACKDROP_DS_3)

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

    frame:HookScript("OnShow", function(self)
        if not UnitExists(self.unit) then
            self:Hide()
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

    hooksecurefunc(TargetFrame, "UpdateAuras", function(self)
        UF.UpdateAuras(self)
    end)
end