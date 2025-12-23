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

function RB.UpdateText(frame)
    local dbEntry = CUI.DB.profile.ResourceBar.Text

    if dbEntry.Enabled then
        frame.Text:Show()
        frame.Text:SetFont(dbEntry.Font, dbEntry.Size, dbEntry.Outline)
        frame.Text:ClearAllPoints()
        frame.Text:SetPoint(dbEntry.AnchorPoint, frame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)

        if frame.powerType == "MANA" and dbEntry.ShowManaPercent then
            frame.Text:SetText(Util.UnitPowerPercent("player", frame.powerType))
        else
            frame.Text:SetText(Util.UnitPowerText("player"))
        end
    else
        frame.Text:Hide()
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
    local value = UnitPower("player")

    frame:SetMinMaxValues(0, UnitPowerMax("player"))
    frame:SetValue(value)

    local _, powerType = UnitPowerType("player")
    frame.powerType = powerType

    if frame.powerType == "MANA" and CUI.DB.profile.ResourceBar.Text.ShowManaPercent then
        frame.Text:SetText(Util.UnitPowerPercent("player", frame.powerType))
    else
        frame.Text:SetText(Util.UnitPowerText("player"))
    end
end

local function UpdatePowerColor(frame)
    local r, g, b = Util.GetUnitPowerColor("player")
    frame:SetStatusBarColor(r, g, b)

    local v = 0.2
    frame.Background:SetVertexColor(r*v, g*v, b*v)
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
    PersonalResourceDisplayFrame:SetSize(10, 10)

    SetCVar("nameplateShowSelf", 1)
    SetCVar("nameplateHideHealthAndPower", 1)
    SetCVar("NameplatePersonalShowAlways", 1)

    Hide.HideFrame(PersonalResourceDisplayFrame.PowerBar)
    Hide.HideFrame(PersonalResourceDisplayFrame.HealthBarsContainer)

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

---------------------------------------------------------------------------------------------------

function RB.Load()
    SetupPowerBar()
    SetupPersonalResourceBar()
end