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
        frame.Text:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", dbEntry.Size, "")
        frame.Text:ClearAllPoints()
        frame.Text:SetPoint(dbEntry.AnchorPoint, frame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
    else
        frame.Text:Hide()
    end
end

function RB.UpdateFrame(frame)
    local dbEntry = CUI.DB.profile.ResourceBar

    frame:SetSize(dbEntry.Width, dbEntry.Height)

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

    frame:ClearAllPoints()
    frame:SetPoint(dbEntry.AnchorPoint, dbEntry.AnchorFrame, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)
end

---------------------------------------------------------------------------------------------------

local function UpdatePower(frame)
    local value = UnitPower("player")

    frame:SetValue(value)
    frame.Text:SetText(Util.UnitPowerText("player"))
end 

local function UpdateMaxPower(frame)
    local value = UnitPower("player")

    frame:SetMinMaxValues(0, UnitPowerMax("player"))
    frame:SetValue(value)
    frame.Text:SetText(Util.UnitPowerText("player"))
end

local function UpdatePowerColor(frame)
    local _, powerType = UnitPowerType("player")
    if powerType == "MANA" or powerType == nil then powerType = "MAELSTROM" end

    local color = PowerBarColor[powerType]
    if color == nil then
        color = PowerBarColor["MAELSTROM"]
    end
    frame:SetStatusBarColor(color.r, color.g, color.b, 1)
end

---------------------------------------------------------------------------------------------------

local powerBar = CreateFrame("Statusbar", "CUI_PowerBar", UIParent)
local function SetupPowerBar()
    powerBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")

    RB.UpdateFrame(powerBar) 
    UpdatePowerColor(powerBar)
    Util.AddStatusBarBackground(powerBar)
    Util.AddBorder(powerBar)

    local text = powerBar:CreateFontString(nil, "OVERLAY")
    text:SetParentKey("Text")
    text:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", CUI.DB.profile.ResourceBar.Text.Size, "")
    text:SetPoint("CENTER", powerBar, "CENTER")

    UpdateMaxPower(powerBar)

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
    if not prdClassFrame then return end
    SetCVar("nameplateShowSelf", 1)
    SetCVar("nameplateHideHealthAndPower", 1)
    SetCVar("NameplatePersonalShowAlways", 1)

    Hide.HideFrame(PersonalResourceDisplayFrame.PowerBar)
    Hide.HideFrame(PersonalResourceDisplayFrame.HealthBarsContainer)
    
    RB.UpdatePersonalBar(PersonalResourceDisplayFrame)

    EditModeManagerFrame:HookScript("OnHide", function(self)
        RB.UpdatePersonalBar(PersonalResourceDisplayFrame)
    end)

    PersonalResourceDisplayFrame:SetSize(8, 8)
    
    prdClassFrame:ClearAllPoints()
    local _, class = UnitClass("player")
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

    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function()
        RB.UpdatePersonalBar(PersonalResourceDisplayFrame)
    end)
end