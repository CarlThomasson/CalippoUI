local addonName, CUI = ...

CUI.Menu = {}
local Menu = CUI.Menu

local topButtons = {
    {
        ["ButtonText"] = "ActionBars",
        ["ButtonName"] = "ActionBarOptionsButton",
        ["OptionsFrameName"] = "ActionBarOptions",
        ["SetupFunc"] = SetupActioBarOptions,
    },
}

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

local function SetupSlider(frame, func, startValue, min, max, step, label, showMinMax, suffix)
    local options = CreateSliderOptions(min, max, step, label, showMinMax, suffix)

    frame:Init(startValue, options.minValue, options.maxValue, options.steps, options.formatters)

    frame:RegisterCallback("OnValueChanged", func, frame)
end

local function HideAllOptions(mainFrame)
    for _, frame in pairs({mainFrame.OptionsContainer:GetChildren()}) do
        frame:Hide()
    end
end

local function SetupMenus(mainFrame)
    for i, v in ipairs(topButtons) do
        local button = CreateFrame("Button", nil, mainFrame, "CUI_ButtonTemplate")
        button:SetParentKey(v.ButtonName)
        button:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 2, -2)
        button:SetText(v.ButtonText)

        local optionsFrame = CreateFrame("Frame", nil, mainFrame.OptionsContainer)
        optionsFrame:SetParentKey(v.OptionsFrameName)
        optionsFrame:SetAllPoints(mainFrame.OptionsContainer)

        button:SetScript("OnClick", function(self)
            HideAllOptions(mainFrame)
            optionsFrame:Show()
        end)
    end
end

-- local actionBarOptions = {
--     {
--         ["Name"] = "ActionBar 1 Alpha",
--         ["Type"] = "Slider",
--         ["Min"] = ,
--         ["Max"] = ,
--         ["Step"] = ,
--         ["StartValue"] = ,
--         ["DBValue"] = ,
--     }
-- }

local function SetupActioBarOptions(optionsFrame)
    
end

function Menu.Load()
    local frame = CreateFrame("Frame", "CUI_OptionsFrame", UIParent, "CUI_OptionsTemplate")

    --SetupMenus(frame)

    --frame:Show()
end