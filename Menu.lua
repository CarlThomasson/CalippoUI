local addonName, CUI = ...

CUI.Menu = {}
local Menu = CUI.Menu

-- https://www.wowinterface.com/forums/showthread.php?t=60190

local function CreateSliderOptions(min, max, step, label, showMinMax, suffix)
    local options = Settings.CreateSliderOptions(min, max, step)

    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return value..(suffix or "") end)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Top, function(value) return label end) 

    if showMinMax then
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Max, function(value) return min end)
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Min, function(value) return max end)
    end

    return options
end

local function BarAlphaSlider(frame)
    local options = CreateSliderOptions(0, 100, 1, "Bar Alpha", false, "%")

    frame:Init((CalippoDB.BarAlpha * 100), options.minValue, options.maxValue, options.steps, options.formatters)

    frame:RegisterCallback("OnValueChanged", function(self, value)
        local normValue = value / 100
        CalippoDB.BarAlpha = normValue
        CUI.Bars.SetAlphas(normValue)
    end, frame)
end

local function UnitFramePositionSlider(frame, unit, axis)
    local options = CreateSliderOptions(-1000, 1000, 1, CUI.Const.cUnit[unit].." "..axis, false)

    local value = CalippoDB[unit.."Frame"]["pos"..axis]

    frame:Init(value, options.minValue, options.maxValue, options.steps, options.formatters)

    frame:RegisterCallback("OnValueChanged", function(self, value)
        CUI.UF.SetFramePosition(_G["CUI_"..unit.."Frame"], unit, value, axis)
    end, frame)
end

local function GroupFramePositionSlider(frame, groupType, axis)
    local options = CreateSliderOptions(-1000, 1000, 1, CUI.Const.cUnit[groupType].." "..axis, false)

    local value = CalippoDB[unit.."Frame"]["pos"..axis]

    frame:Init(value, options.minValue, options.maxValue, options.steps, options.formatters)

    frame:RegisterCallback("OnValueChanged", function(self, value)
        CUI.GF.SetFramePosition(groupType, value, axis)
    end, frame)
end

local function HideAllOptions(mainFrame)
    mainFrame.GeneralOptions:Hide()
    mainFrame.UnitFrameOptions:Hide()
    mainFrame.GroupFrameOptions:Hide()
end

local function LoadTopButtons(mainFrame)
    mainFrame.GeneralButton:SetScript("OnClick", function(self)
        HideAllOptions(mainFrame)
        mainFrame.GeneralOptions:Show()
    end)

    mainFrame.UnitFrameButton:SetScript("OnClick", function(self)
        HideAllOptions(mainFrame)
        mainFrame.UnitFrameOptions:Show()
    end)

    mainFrame.GroupFrameButton:SetScript("OnClick", function(self)
        HideAllOptions(mainFrame)
        mainFrame.GroupFrameOptions:Show()
    end)
end

local function LoadGeneralOptions(mainFrame)
    local frame = mainFrame.GeneralOptions

    BarAlphaSlider(frame.BarAlphaSlider)
end

local function LoadUnitFrameOptions(mainFrame)
    local frame = mainFrame.UnitFrameOptions

    UnitFramePositionSlider(frame.PlayerFramePosXSlider, "player", "X")
    UnitFramePositionSlider(frame.PlayerFramePosYSlider, "player", "Y")

    UnitFramePositionSlider(frame.TargetFramePosXSlider, "target", "X")
    UnitFramePositionSlider(frame.TargetFramePosYSlider, "target", "Y")
end

local function LoadGroupFrameOptions(mainFrame)
    local frame = mainFrame.GroupFrameOptions

    UnitFramePositionSlider(frame.PartyFramePosXSlider, "party", "X")
    UnitFramePositionSlider(frame.PartyFramePosYSlider, "party", "Y")

    UnitFramePositionSlider(frame.RaidFramePosXSlider, "raid", "X")
    UnitFramePositionSlider(frame.RaidFramePosYSlider, "raid", "Y")
end

function Menu.Load()
    local frame = CreateFrame("Frame", "CUI_OptionsFrame", UIParent, "CUI_OptionsTemplate")

    LoadTopButtons(frame)

    LoadGeneralOptions(frame)
    LoadUnitFrameOptions(frame)
    LoadGroupFrameOptions(frame)

    frame.GeneralOptions:Show()
    --frame:Show()
end