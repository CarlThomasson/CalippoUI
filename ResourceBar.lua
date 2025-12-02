local addonName, CUI = ...

CUI.RB = {}
local RB = CUI.RB
local Util = CUI.Util

---------------------------------------------------------------------------------------------------

function RB.UpdateAlpha(frame, inCombat)
    if InCombatLockdown() or inCombat then 
        UIFrameFadeIn(frame, 0.6, frame:GetAlpha(), 1)
    else
        UIFrameFadeOut(frame, 0.6, frame:GetAlpha(), CalippoDB.ResourceBar.Alpha)
    end
end

function RB.UpdateHeight(frame)
    frame:SetHeight(CalippoDB.ResourceBar.Height)
end

function RB.UpdateFontSize(frame)
    frame.Text:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", CalippoDB.ResourceBar.FontSize, "")
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

function RB.Load()
    local powerBar = CreateFrame("Statusbar", "CUI_PowerBar", UIParent)
    powerBar:SetHeight(CalippoDB.ResourceBar.Height)
    powerBar:SetPoint("BOTTOMLEFT", EssentialCooldownViewer, "TOPLEFT", 0, 2)
    powerBar:SetPoint("BOTTOMRIGHT", EssentialCooldownViewer, "TOPRIGHT", 0, 2)
    powerBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")

    UpdatePowerColor(powerBar)
    Util.AddStatusBarBackground(powerBar)
    Util.AddBackdrop(powerBar, 1, CUI_BACKDROP_DS_3)

    local text = powerBar:CreateFontString(nil, "OVERLAY")
    text:SetParentKey("Text")
    text:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", CalippoDB.ResourceBar.FontSize, "")
    text:SetPoint("CENTER", powerBar, "CENTER")

    UpdateMaxPower(powerBar)

    RB.UpdateAlpha(powerBar)

    powerBar:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    powerBar:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    powerBar:RegisterEvent("PLAYER_REGEN_ENABLED")
    powerBar:RegisterEvent("PLAYER_REGEN_DISABLED")
    powerBar:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_POWER_UPDATE" then
            UpdatePower(self)
        elseif event == "UNIT_MAXPOWER" then
            UpdateMaxPower(self)
        elseif event == "PLAYER_REGEN_ENABLED" then
            RB.UpdateAlpha(self)
        elseif event == "PLAYER_REGEN_DISABLED" then
            RB.UpdateAlpha(self, true)
        end
    end)
end