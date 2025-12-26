local addonName, CUI = ...

CUI.RB = {}
local RB = CUI.RB
local Hide = CUI.Hide
local Util = CUI.Util

---------------------------------------------------------------------------------------------------

function RB.UpdateAlpha(frame, inCombat)
    if InCombatLockdown() or inCombat then 
        Util.FadeFrame(frame, "IN", 1)
        Util.FadeFrame(PersonalResourceDisplayFrame, "IN", 1)
    else
        local dbEntry = CUI.DB.profile.ResourceBar

        Util.FadeFrame(frame, "OUT", dbEntry.Alpha)
        Util.FadeFrame(PersonalResourceDisplayFrame, "OUT", dbEntry.Alpha)
    end
end

function RB.UpdateFrame(frame)
    local dbEntry = CUI.DB.profile.ResourceBar

    frame:SetSize(dbEntry.Width, dbEntry.Height)
    frame:SetStatusBarTexture(dbEntry.Texture)

    Util.CheckAnchorFrame(frame, dbEntry)

    frame:ClearAllPoints()
    if dbEntry.MatchWidth then
        frame:SetPoint("BOTTOMLEFT", dbEntry.AnchorFrame, "TOPLEFT", 0, dbEntry.PosY)
        frame:SetPoint("BOTTOMRIGHT", dbEntry.AnchorFrame, "TOPRIGHT", 0, dbEntry.PosY)
    else
        frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    end
end

function RB.UpdatePersonalBar(frame)
    local dbEntry = CUI.DB.profile.ResourceBar.PersonalResourceBar

    Util.CheckAnchorFrame(frame, dbEntry)

    frame:ClearAllPoints()
    frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
end

---------------------------------------------------------------------------------------------------

local function UpdatePower(frame)
    local value = UnitPower("player")

    frame:SetValue(value)
    if frame.powerType == "MANA" and CUI.DB.profile.ResourceBar.Text.ShowManaPercent then
        frame.Text:SetText(Util.UnitPowerPercent("player", frame.powerType))
    else
        frame.Text:SetText(Util.UnitPowerText("player"))
    end
end

local function UpdateMaxPower(frame)
    local _, powerType = UnitPowerType("player")
    frame.powerType = powerType

    frame:SetMinMaxValues(0, UnitPowerMax("player"))
    UpdatePower(frame)
end

local function UpdatePowerColor(frame)
    local r, g, b = Util.GetUnitPowerColor("player")
    frame:SetStatusBarColor(r, g, b)

    local v = 0.2
    frame.Background:SetVertexColor(r*v, g*v, b*v)
end

---------------------------------------------------------------------------------------------------

function RB.UpdateText(frame)
    local dbEntry = CUI.DB.profile.ResourceBar.Text

    if dbEntry.Enabled then
        frame.Text:Show()
        frame.Text:SetFont(dbEntry.Font, dbEntry.Size, dbEntry.Outline)
        frame.Text:ClearAllPoints()
        frame.Text:SetPoint(dbEntry.AnchorPoint, frame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)

        UpdatePower(frame)
    else
        frame.Text:Hide()
    end
end

---------------------------------------------------------------------------------------------------

local powerBar = CreateFrame("Statusbar", "CUI_PowerBar", UIParent)

local function SetupPowerBar()
    powerBar:SetStatusBarTexture(CUI.DB.profile.ResourceBar.Texture)

    local _, powerType = UnitPowerType("player")
    powerBar.powerType = powerType

    Util.AddStatusBarBackground(powerBar)
    Util.AddBorder(powerBar)

    RB.UpdateFrame(powerBar)

    local text = powerBar:CreateFontString(nil, "OVERLAY")
    text:SetParentKey("Text")

    RB.UpdateText(powerBar)

    C_Timer.After(0.5, function()
        UpdateMaxPower(powerBar)
        UpdatePowerColor(powerBar)
    end)

    powerBar:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    powerBar:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    powerBar:RegisterEvent("PLAYER_REGEN_ENABLED")
    powerBar:RegisterEvent("PLAYER_REGEN_DISABLED")
    powerBar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    powerBar:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_POWER_UPDATE" then
            UpdatePower(self)
        elseif event == "UNIT_MAXPOWER" then
            UpdateMaxPower(self)
        elseif event == "PLAYER_REGEN_ENABLED" then
            RB.UpdateAlpha(self)
            RB.UpdateAlpha(PersonalResourceDisplayFrame)
        elseif event == "PLAYER_REGEN_DISABLED" then
            RB.UpdateAlpha(self, true)
            RB.UpdateAlpha(PersonalResourceDisplayFrame, true)
        elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
            C_Timer.After(0.5, function() UpdatePowerColor(self) end)
        end
    end)

    RB.UpdateAlpha(powerBar)
    RB.UpdateAlpha(PersonalResourceDisplayFrame)
end

local function SetupPersonalResourceBar()
    if CUI.DB.profile.ResourceBar.PersonalResourceBar.Enabled then
        SetCVar("nameplateShowSelf", 1)
        SetCVar("nameplateHideHealthAndPower", 1)
        SetCVar("NameplatePersonalShowAlways", 1)
    else
        SetCVar("nameplateShowSelf", 0)
        return
    end

    PersonalResourceDisplayFrame:SetSize(10, 10)

    Hide.HideFrame(PersonalResourceDisplayFrame.PowerBar)
    Hide.HideFrame(PersonalResourceDisplayFrame.HealthBarsContainer)
    Hide.HideFrame(PersonalResourceDisplayFrame.AlternatePowerBar)

    RB.UpdatePersonalBar(PersonalResourceDisplayFrame)

    EditModeManagerFrame:HookScript("OnHide", function(self)
        RB.UpdatePersonalBar(PersonalResourceDisplayFrame)
    end)

    PersonalResourceDisplayFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    PersonalResourceDisplayFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    PersonalResourceDisplayFrame:HookScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_WORLD" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
            C_Timer.After(0.5, function() RB.UpdatePersonalBar(self) end)
        end
    end)

    if not prdClassFrame then return end

    local _, class = UnitClass("player")
    prdClassFrame:ClearAllPoints()
    if class == "PALADIN" then
        prdClassFrame:SetPoint("BOTTOM", PersonalResourceDisplayFrame, "BOTTOM", 0, -7)
    else
        prdClassFrame:SetPoint("BOTTOM", PersonalResourceDisplayFrame, "BOTTOM", 0, 1)
    end
end

local powerTypes = {
    PALADIN = {value = 9, name = "HOLY_POWER", type = "MultiBar"},

    Brewmaster = {value = nil, name = "STAGGER", color = {r = 0, g = 1, b = 0.6}, type = "SingleBar"},
    Windwalker = {value = 12, name = "CHI", color = {r = 0, g = 1, b = 0.6}, type = "MultiBar"},

    ROGUE = {value = 4, name = "COMBO_POINTS", color = {r = 0.8, g = 0, b = 0}, type = "MultiBar"},

    Feral = {value = 4, name = "COMBO_POINTS", color = {r = 0.8, g = 0, b = 0}, type = "MultiBar"},

    Arcane = {value = 16, name = "ARCANE_CHARGES", color = {r = 0.25, g = 0.78, b = 0.92}, type = "MultiBar"},

    EVOKER = {value = 19, name = "ESSENCE", color = {r = 0.2, g = 0.58, b = 0.5}, type = "MultiBar"},

    DEATHKNIGHT = {value = 5, name = "RUNES", color = {r = 0.77, g = 0.12, b = 0.23}, type = "MultiBar"},
}

local function SortRunes(a, b)
    local startA, _, runeReadyA = GetRuneCooldown(a)
    local startB, _, runeReadyB = GetRuneCooldown(b)

    if runeReadyA and runeReadyB then
        return a < b
    end

    if runeReadyA then return true end
    if runeReadyB then return false end

    if startA and not startB then return true end
    if startB and not startA then return false end

    return startA < startB
end

local runeOrder = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
}

local function UpdateSecondaryPowerValue(frame)
    if frame.PowerType == "MultiBar" then
        if frame.PowerName == "RUNES" then
            table.sort(runeOrder, SortRunes)
            for i, powerFrame in ipairs(frame.frames) do
                if i > frame.PowerMax then return end

                local start, duration, runeReady = GetRuneCooldown(runeOrder[i])
                if runeReady then
                    powerFrame:SetMinMaxValues(0, 1)
                    powerFrame:SetValue(1)
                else
                    powerFrame.duration:SetTimeFromStart(start, duration)
                    powerFrame:SetTimerDuration(powerFrame.duration)
                end
            end
        elseif frame.PowerName == "ESSENCE" then
            local power = UnitPower("player", frame.PowerValue, true)
            print(power)
        else
            local power = UnitPower("player", frame.PowerValue)

            for i, powerFrame in ipairs(frame.frames) do
                if i > frame.PowerMax then return end
                if i <= power then
                    powerFrame:SetValue(1)
                else
                    powerFrame:SetValue(0)
                end
            end
        end
    elseif frame.PowerType == "SingleBar" then
        if frame.PowerName == "STAGGER" then
            local powerFrame = frame.frames[1]
            local stagger = UnitStagger("player")
            powerFrame:SetMinMaxValues(0, UnitHealthMax("player"))
            powerFrame:SetValue(stagger)
        end
    end
end

local function UpdateSecondaryPowerFrame(frame)
    local currentSpec = GetSpecialization()
    local currentSpecName
    if currentSpec then
         _, currentSpecName = GetSpecializationInfo(currentSpec)
    end

    local _, class = UnitClass("player")
    local powerType = powerTypes[class]
    if not powerType then
        powerType = powerTypes[currentSpecName]
        if not powerType then
            for _, powerFrame in ipairs(frame.frames) do
                powerFrame:Hide()
            end
            return
        else
            frame.PowerValue = powerType.value
            frame.PowerName = powerType.name
            frame.PowerType = powerType.type
            frame.PowerMax = UnitPowerMax("player" , powerType.value)
        end
    else
        frame.PowerValue = powerType.value
        frame.PowerName = powerType.name
        frame.PowerType = powerType.type
        frame.PowerMax = UnitPowerMax("player" , powerType.value)
     end

    local dbEntry = CUI.DB.profile.ResourceBar.SecondaryResourceBar
    local height = dbEntry.Height

    local width
    if dbEntry.MatchWidth then
        width = _G[dbEntry.AnchorFrame]:GetWidth()
    else
        width = dbEntry.Width
    end

    local color = powerType.color

    if frame.PowerType == "MultiBar" then
        local padding = dbEntry.Padding
        local frameWidth = (width/frame.PowerMax) - padding + (padding/frame.PowerMax)
        for i, powerFrame in ipairs(frame.frames) do
            if i > frame.PowerMax then
                powerFrame:Hide()
            else
                powerFrame:Show()
                powerFrame:SetSize(frameWidth, height)
                powerFrame:SetStatusBarColor(color.r, color.g, color.b)
                powerFrame.Background:SetVertexColor(color.r*0.2, color.g*0.2, color.b*0.2)
                powerFrame:SetMinMaxValues(0, 1)
                Util.PositionFromIndex(i-1, powerFrame, frame, "TOPLEFT", "TOPLEFT", "RIGHT", "DOWN", frameWidth, height, padding, 0, 0, 123)
            end
        end

        if frame.PowerName == "RUNES" then
            frame:RegisterEvent("RUNE_POWER_UPDATE")
        end
    elseif frame.PowerType == "SingleBar" then
        if frame.PowerName == "STAGGER" then color = color.green end

        for i, powerFrame in ipairs(frame.frames) do
            if i == 1 then
                powerFrame:Show()
                powerFrame:SetSize(width, height)
                powerFrame:SetPoint("TOPLEFT")
                powerFrame:SetStatusBarColor(color.r, color.g, color.b)
                powerFrame.Background:SetVertexColor(color.r*0.2, color.g*0.2, color.b*0.2)
                powerFrame:SetMinMaxValues(0, 1)
                powerFrame:SetValue(1)
            else
                powerFrame:Hide()
            end
        end
    end

    UpdateSecondaryPowerValue(frame)
end

function RB.UpdateSecondaryPowerBar(frame)
    local dbEntry = CUI.DB.profile.ResourceBar.SecondaryResourceBar
    Util.CheckAnchorFrame(secondaryPowerContainer, dbEntry)

    frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)

    if dbEntry.MatchWidth then
        frame:SetSize(_G[dbEntry.AnchorFrame]:GetWidth(), dbEntry.Height)
    else
        frame:SetSize(dbEntry.Width, dbEntry.Height)
    end

    UpdateSecondaryPowerFrame(frame)
end

local function SetupSecondaryPowerBar()
    local dbEntry = CUI.DB.profile.ResourceBar.SecondaryResourceBar
    Util.CheckAnchorFrame(secondaryPowerContainer, dbEntry)

    local secondaryPowerContainer = CreateFrame("Frame", "CUI_SecondaryPowerBar", UIParent)
    secondaryPowerContainer.frames = {}

    for i=1, 7 do
        local frame = CreateFrame("StatusBar", nil, secondaryPowerContainer)
        frame:SetStatusBarTexture(dbEntry.Texture)
        frame:SetMinMaxValues(0, 1)
        Util.AddStatusBarBackground(frame)
        frame.Background:SetTexture(dbEntry.Texture)
        Util.AddBorder(frame)
        frame:Hide()
        frame.duration = C_DurationUtil.CreateDuration()
        frame.Index = i
        table.insert(secondaryPowerContainer.frames, frame)
    end

    secondaryPowerContainer:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    secondaryPowerContainer:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    secondaryPowerContainer:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    secondaryPowerContainer:SetScript("OnEvent", function(self, event)
        if event == "UNIT_POWER_UPDATE" or event == "RUNE_POWER_UPDATE" then
            UpdateSecondaryPowerValue(self)
        elseif event == "UNIT_MAXPOWER" then
            UpdateSecondaryPowerFrame(self)
        elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
            C_Timer.After(0.5, function() UpdateSecondaryPowerFrame(self) end)
        end
    end)

    if dbEntry.MatchWidth then
        _G[dbEntry.AnchorFrame]:HookScript("OnSizeChanged", function(self, width)
            CUI_SecondaryPowerBar:SetWidth(width)
            UpdateSecondaryPowerFrame(CUI_SecondaryPowerBar)
        end)
    end

    RB.UpdateSecondaryPowerBar(secondaryPowerContainer)
end

---------------------------------------------------------------------------------------------------

function RB.Load()
    SetupPowerBar()
    SetupPersonalResourceBar()
    SetupSecondaryPowerBar()
end