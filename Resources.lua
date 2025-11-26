local addonName, CUI = ...

CUI.RES = {}
local RES = CUI.RES
local Util = CUI.Util

local function UpdatePower(frame)
    local value = UnitPower("player")

    frame:SetValue(value)
    frame.Text:SetText(value)
end 

local function UpdateMaxPower(frame)
    local value = UnitPower("player")

    frame:SetMinMaxValues(0, UnitPowerMax("player"))
    frame:SetValue(value)
    frame.Text:SetText(value)
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

-- local function Warrior()

-- end

function RES.Load()
    -- local _, class = UnitClass("player")

    -- if class == "WARRIOR" then
    --     Warrior()
    -- end

    local powerBar = CreateFrame("Statusbar", "CUI_PoweBar", UIParent)
    powerBar:SetHeight(18)
    powerBar:SetPoint("BOTTOMLEFT", EssentialCooldownViewer, "TOPLEFT", 0, 2)
    powerBar:SetPoint("BOTTOMRIGHT", EssentialCooldownViewer, "TOPRIGHT", 0, 2)
    powerBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")

    UpdatePowerColor(powerBar)
    Util.AddStatusBarBackground(powerBar)
    Util.AddBackdrop(powerBar, 1, CUI_BACKDROP_DS_3)

    local text = powerBar:CreateFontString(nil, "OVERLAY")
    text:SetParentKey("Text")
    text:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 16, "")
    text:SetPoint("CENTER", powerBar, "CENTER")

    UpdateMaxPower(powerBar)

    powerBar:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    powerBar:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    powerBar:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_POWER_UPDATE" then
            UpdatePower(self)
        elseif event == "UNIT_MAXPOWER" then
            UpdateMaxPower(self)
        end
    end)
end