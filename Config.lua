local addonName, CUI = ...

CUI.Conf = {}
local Conf = CUI.Conf
local AB = CUI.AB
local UF = CUI.UF
local CDM = CUI.CDM
local PA = CUI.PA
local RB = CUI.RB
local MM = CUI.MM
local CB = CUI.CB

local AceGUI = LibStub("AceGUI-3.0")

---------------------------------------------------------------------------------------------------------------------------------------

local anchorPoints = {
    ["TOPLEFT"] = "Top Left",
    ["TOPRIGHT"] = "Top Right",
    ["BOTTOMLEFT"] = "Bottom Left",
    ["BOTTOMRIGHT"] = "Bottom Right",
    ["TOP"] = "Top",
    ["BOTTOM"] = "Bottom",
    ["LEFT"] = "Left",
    ["RIGHT"] = "Right",
    ["CENTER"] = "Center",
}

local directionsHorizontal = {
    ["LEFT"] = "Left",
    ["RIGHT"] = "Right",
}

local directionsVertical = {
    ["UP"] = "Up",
    ["DOWN"] = "Down",
}

local outlines = {
    [""] = "None",
    ["OUTLINE"] = "Outline",
    ["THICKOUTLINE"] = "Thick",
    ["MONOCHROME"] = "Monochrome",
}

---------------------------------------------------------------------------------------------------------------------------------------

local function ReverseHashTable(table)
    local newTable = {}
    for k, v in pairs(table) do
        newTable[v] = k
    end
    return newTable
end

local fonts = ReverseHashTable(CUI.SharedMedia:HashTable("font"))
local textures = ReverseHashTable(CUI.SharedMedia:HashTable("statusbar"))

local function CreateInlineGroup(container, title)
    local inlineGroup = AceGUI:Create("InlineGroup")
    inlineGroup:SetTitle(title)
    inlineGroup:SetLayout("Flow")
    inlineGroup:SetRelativeWidth(1)
    container:AddChild(inlineGroup)
    return inlineGroup
end

local function CreateSlider(container, label, min, max, step, value, func, width)
    local slider = AceGUI:Create("Slider")
    slider:SetLabel(label)
    slider:SetSliderValues(min, max, step)
    slider:SetValue(value)
    slider:SetCallback("OnValueChanged", func)
    if width then slider:SetRelativeWidth(width) end
    container:AddChild(slider)
    return slider
end

local function CreateCheckBox(container, label, value, func, width)
    local checkBox = AceGUI:Create("CheckBox")
    checkBox:SetLabel(label)
    checkBox:SetValue(value)
    checkBox:SetCallback("OnValueChanged", func)
    if width then checkBox:SetRelativeWidth(width) end
    container:AddChild(checkBox)
    return checkBox
end

local function CreateEditBox(container, label, value, func, width)
    local editBox = AceGUI:Create("EditBox")
    editBox:SetLabel(label)
    editBox:SetText(value)
    editBox:SetCallback("OnEnterPressed", func)
    if width then editBox:SetRelativeWidth(width) end
    container:AddChild(editBox)
end

local function CreateDropDown(container, label, value, list, func, width)
    local dropDown = AceGUI:Create("Dropdown")
    dropDown:SetLabel(label)
    dropDown:SetList(list)
    dropDown:SetValue(value)
    dropDown:SetCallback("OnValueChanged", func)
    if width then dropDown:SetRelativeWidth(width) end
    container:AddChild(dropDown)
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreateAnchorGroup(container, dbEntry, func, frame)
    local anchorGroup = CreateInlineGroup(container, "Anchor")

    CreateEditBox(anchorGroup, "Anchor Frame", dbEntry.AnchorFrame,
        function(self, event, value)
            local frameExists = _G[value]
            if frameExists then
                dbEntry.AnchorFrame = value
                func(frame)
            else
                print("Frame does not exist!")
                self:SetText(dbEntry.AnchorFrame)
            end
        end, 0.33)

    CreateDropDown(anchorGroup, "Anchor Point", dbEntry.AnchorPoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorPoint = value
            func(frame)
        end, 0.33)
        
    CreateDropDown(anchorGroup, "Relative Anchor Point", dbEntry.AnchorRelativePoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorRelativePoint = value
            func(frame)
        end, 0.33)
        
    CreateSlider(anchorGroup, "Position X", -1000, 1000, 0.1, dbEntry.PosX,
        function(self, event, value)
            dbEntry.PosX = value
            func(frame)
        end, 0.5)

    CreateSlider(anchorGroup, "Position Y", -1000, 1000, 0.1, dbEntry.PosY,
        function(self, event, value)
            dbEntry.PosY = value
            func(frame)
        end, 0.5)

    return anchorGroup
end

local function CreateAlphaGroup(container, dbEntry, func, frame)
    local alphaGroup = CreateInlineGroup(container, "Alpha") 

    CreateSlider(alphaGroup, "Alpha (Out of combat)", 0, 100, 1, dbEntry.Alpha*100, 
        function(self, event, value)
            dbEntry.Alpha = value/100
            func(frame)
        end, 0.5)

    CreateSlider(alphaGroup, "Alpha (In Combat)", 0, 100, 1, dbEntry.CombatAlpha*100, 
        function(self, event, value)
            dbEntry.CombatAlpha = value/100
            func(frame)
        end, 0.5)

    return alphaGroup
end

local function CreateSizeGroup(container, dbEntry, func, frame)
    local sizeGroup = CreateInlineGroup(container, "Size")

    CreateSlider(sizeGroup, "Width", 1, 500, 1, dbEntry.Width,
        function(self, event, value)
            dbEntry.Width = value
            func(frame)
        end, 0.5)

    CreateSlider(sizeGroup, "Height", 1, 500, 1, dbEntry.Height,
        function(self, event, value)
            dbEntry.Height = value
            func(frame)
        end, 0.5)

    return sizeGroup
end

local function CreateColorGroup(container, dbEntry, func, frame)
    local colorGroup = CreateInlineGroup(container, "Color")

    local colorPicker = AceGUI:Create("ColorPicker")
    colorPicker:SetHasAlpha(true)
    colorPicker:SetColor(dbEntry.Color.r, dbEntry.Color.g, dbEntry.Color.b, dbEntry.Color.a)
    colorPicker:SetCallback("OnValueChanged",
        function(self, event, r, g, b, a)
            dbEntry.Color.r = r
            dbEntry.Color.g = g
            dbEntry.Color.b = b
            dbEntry.Color.a = a

            func(frame)
        end)
    colorGroup:AddChild(colorPicker)

    return colorGroup
end

local function CreateTextGroup(container, dbEntry, func, frame, text)
    local textGroup = CreateInlineGroup(container, text)

    CreateCheckBox(textGroup, "Toggle "..text, dbEntry.Enabled,
        function(self, event, value)
            dbEntry.Enabled = value
            func(frame)
        end, 0.5)

    CreateSlider(textGroup, text.." Font Size", 1, 50, 1, dbEntry.Size, 
        function(self, event, value)
            dbEntry.Size = value
            func(frame)
        end, 0.5)

    CreateDropDown(textGroup, "Anchor Point", dbEntry.AnchorPoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorPoint = value
            func(frame)
        end, 0.5)

    CreateDropDown(textGroup, "Relative Anchor Point", dbEntry.AnchorRelativePoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorRelativePoint = value
            func(frame)
        end, 0.5)

    CreateSlider(textGroup, "Position X", -100, 100, 1, dbEntry.PosX,
        function(self, event, value)
            dbEntry.PosX = value
            func(frame)
        end, 0.5)

    CreateSlider(textGroup, "Position Y", -100, 100, 1, dbEntry.PosY,
        function(self, event, value)
            dbEntry.PosY = value
            func(frame)
        end, 0.5)

    CreateDropDown(textGroup, "Font", dbEntry.Font, fonts,
        function(self, event, value)
            dbEntry.Font = value
            dbEntry.FontName = fonts[value]
            func(frame)
        end, 0.5)

    CreateDropDown(textGroup, "Outline", dbEntry.Outline, outlines,
        function(self, event, value)
            dbEntry.Outline = value
            func(frame)
        end, 0.5)

    return textGroup
end

local function CreateTextureGroup(container, dbEntry, func, frame)
    local textureGroup = CreateInlineGroup(container, "Texture")

    CreateDropDown(textureGroup, "", dbEntry.Texture, textures,
        function(self, event, value)
            dbEntry.Texture = value
            func(frame)
        end, 1)

    return textureGroup
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreateGeneralSettings(container)
    local dbEntry = CUI.DB.profile

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local modulesGroup = CreateInlineGroup(scrollFrame, "Toggle Modules (Reload to apply changes)")

    CreateCheckBox(modulesGroup, "Action Bars", dbEntry.ActionBars.Enabled,
        function(self, event, value)
            dbEntry.ActionBars.Enabled = value
        end, 0.33)

    CreateCheckBox(modulesGroup, "Unit Frames", dbEntry.UnitFrames.Enabled,
        function(self, event, value)
            dbEntry.UnitFrames.Enabled = value
        end, 0.33)

    CreateCheckBox(modulesGroup, "Cooldown Manager", dbEntry.CooldownManager.Enabled,
        function(self, event, value)
            dbEntry.CooldownManager.Enabled = value
        end, 0.33)

    CreateCheckBox(modulesGroup, "Resource Bar", dbEntry.ResourceBar.Enabled,
        function(self, event, value)
            dbEntry.ResourceBar.Enabled = value
        end, 0.33)

    CreateCheckBox(modulesGroup, "Player Cast Bar", dbEntry.PlayerCastBar.Enabled,
        function(self, event, value)
            dbEntry.PlayerCastBar.Enabled = value
        end, 0.33)

    CreateCheckBox(modulesGroup, "Nameplates", dbEntry.Nameplates.Enabled,
        function(self, event, value)
            dbEntry.Nameplates.Enabled = value
        end, 0.33)

    CreateCheckBox(modulesGroup, "Group Frames", dbEntry.GroupFrames.Enabled,
        function(self, event, value)
            dbEntry.GroupFrames.Enabled = value
        end, 0.33)

    CreateCheckBox(modulesGroup, "Minimap", dbEntry.Minimap.Enabled,
        function(self, event, value)
            dbEntry.Minimap.Enabled = value
        end, 0.33)

    CreateCheckBox(modulesGroup, "PlayerAuras", dbEntry.PlayerAuras.Enabled,
        function(self, event, value)
            dbEntry.PlayerAuras.Enabled = value
        end, 0.33)

    local reloadButton = AceGUI:Create("Button")
    reloadButton:SetText("Reload")
    reloadButton:SetCallback("OnClick", function() ReloadUI() end)
    reloadButton:SetRelativeWidth(1)
    modulesGroup:AddChild(reloadButton)
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreateActionBarPage(container, actionBar)
    local dbEntry = CUI.DB.profile.ActionBars[actionBar]
    local frame = _G[actionBar]

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    if actionBar ~= "MicroMenu" then
        local textGroup = CreateInlineGroup(scrollFrame, "Text")

        CreateCheckBox(textGroup, "Toggle Keybind Text", dbEntry.Keybind.Enabled,
            function(self, event, value)
                dbEntry.Keybind.Enabled = value
                AB.UpdateBar(frame)
            end, 0.25)

        CreateCheckBox(textGroup, "Toggle Cooldown Text", dbEntry.Cooldown.Enabled,
            function(self, event, value)
                dbEntry.Cooldown.Enabled = value
                AB.UpdateBar(frame)
            end, 0.25)

        CreateCheckBox(textGroup, "Toggle Charges Text", dbEntry.Charges.Enabled,
            function(self, event, value)
                dbEntry.Charges.Enabled = value
                AB.UpdateBar(frame)
            end, 0.25)

        CreateCheckBox(textGroup, "Toggle Macro Text", dbEntry.Macro.Enabled,
            function(self, event, value)
                dbEntry.Macro.Enabled = value
                AB.UpdateBar(frame)
            end, 0.25)

        CreateSlider(textGroup, "Bind Font Size", 1, 50, 1, dbEntry.Keybind.Size,
            function(self, event, value)
                dbEntry.Keybind.Size = value
                AB.UpdateBar(frame)
            end, 0.25)

        CreateSlider(textGroup, "Cooldown Font Size", 1, 50, 1, dbEntry.Cooldown.Size,
            function(self, event, value)
                dbEntry.Cooldown.Size = value
                AB.UpdateBar(frame)
            end, 0.25)

        CreateSlider(textGroup, "Charge Font Size", 1, 50, 1, dbEntry.Charges.Size,
            function(self, event, value)
                dbEntry.Charges.Size = value
                AB.UpdateBar(frame)
            end, 0.25)

        CreateSlider(textGroup, "Macro Font Size", 1, 50, 1, dbEntry.Macro.Size,
            function(self, event, value)
                dbEntry.Macro.Size = value
                AB.UpdateBar(frame)
            end, 0.25)

        local paddingGroup = CreateInlineGroup(scrollFrame, "Padding")

        CreateSlider(paddingGroup, "Padding (Overrides padding from edit mode)", 0, 15, 1, dbEntry.Padding,
            function(self, event, value)
                dbEntry.Padding = value
                AB.UpdateBar(frame)
            end, 1)
    end

    CreateAlphaGroup(scrollFrame, dbEntry, AB.UpdateAlpha, frame)

    local anchorGroup = CreateInlineGroup(scrollFrame, "Anchor")

    CreateCheckBox(anchorGroup, "Toggle Anchoring (Overrides edit mode placement)", dbEntry.ShouldAnchor,
        function(self, event, value)
            dbEntry.ShouldAnchor = value
            AB.UpdateBarAnchor(frame)
        end, 0.5)

    CreateEditBox(anchorGroup, "Anchor Frame", dbEntry.AnchorFrame,
        function(self, event, value)
            local frameExists = _G[value]
            if frameExists then
                dbEntry.AnchorFrame = value
                AB.UpdateBarAnchor(frame)
            else
                print("Frame does not exist!")
                self:SetText(dbEntry.AnchorFrame)
            end
        end, 0.5)

    CreateDropDown(anchorGroup, "Anchor Point", dbEntry.AnchorPoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorPoint = value
            AB.UpdateBarAnchor(frame)
        end, 0.5)

    CreateDropDown(anchorGroup, "Relative Anchor Point", dbEntry.AnchorRelativePoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorRelativePoint = value
            AB.UpdateBarAnchor(frame)
        end, 0.5)

    CreateSlider(anchorGroup, "Position X", -1000, 1000, 0.1, dbEntry.PosX,
        function(self, event, value)
            dbEntry.PosX = value
            AB.UpdateBarAnchor(frame)
        end, 0.5)

    CreateSlider(anchorGroup, "Position Y", -1000, 1000, 0.1, dbEntry.PosY,
        function(self, event, value)
            dbEntry.PosY = value
            AB.UpdateBarAnchor(frame)
        end, 0.5)

    scrollFrame:DoLayout()
end

local function CreateActionBarSettings(container)
    local function SelectGroup(container, event, actionBar)
        container:ReleaseChildren()
        CreateActionBarPage(container, actionBar)
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="Action Bar 1", value="MainActionBar"}, 
                    {text="Action Bar 2", value="MultiBarBottomLeft"},
                    {text="Action Bar 3", value="MultiBarBottomRight"},
                    {text="Action Bar 4", value="MultiBarRight"},
                    {text="Action Bar 5", value="MultiBarLeft"},
                    {text="Action Bar 6", value="MultiBar5"},
                    {text="Action Bar 7", value="MultiBar6"},
                    {text="Action Bar 8", value="MultiBar7"},
                    {text="Pet Action Bar", value="PetActionBar"},
                    {text="Micro Menu", value="MicroMenu"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("MainActionBar")

    container:AddChild(tabGroup)
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreateUnitFrameFramePage(container, unitFrame)
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame]
    local frame = _G["CUI_"..unitFrame]

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    CreateSizeGroup(scrollFrame, dbEntry, UF.UpdateFrame, frame)

    CreateAlphaGroup(scrollFrame, dbEntry, UF.UpdateAlpha, frame)

    CreateTextureGroup(scrollFrame, dbEntry.HealthBar, UF.UpdateFrame, frame)

    CreateAnchorGroup(scrollFrame, dbEntry, UF.UpdateFrame, frame)

    local powerBarGroup = CreateInlineGroup(scrollFrame, "Power Bar")

    CreateCheckBox(powerBarGroup, "Enable", dbEntry.PowerBar.Enabled,
        function(self, event, value)
            dbEntry.PowerBar.Enabled = value
            UF.UpdateFrame(frame)
        end, 0.5)

    CreateSlider(powerBarGroup, "Height", 1, 50, 1, dbEntry.PowerBar.Height,
        function(self, event, value)
            dbEntry.PowerBar.Height = value
            UF.UpdateFrame(frame)
        end, 0.5)

    CreateTextureGroup(powerBarGroup, dbEntry.PowerBar, UF.UpdateFrame, frame)

    scrollFrame:DoLayout()
end

local function CreateUnitFramAuraSettings(container, unitFrame, type)
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame][type]
    local frame = _G["CUI_"..unitFrame]

    local group = CreateInlineGroup(container, type)

    CreateCheckBox(group, "Toggle "..type, dbEntry.Enabled,
        function(self, event, value)
            dbEntry.Enabled = value
            UF.SetupAuras(frame)
        end, 1)

    CreateSlider(group, "Size", 1, 50, 1, dbEntry.Size,
        function(self, event, value)
            dbEntry.Size = value
            UF.SetupAuras(frame)
        end, 0.33)

    CreateSlider(group, "Padding", 0, 20, 1, dbEntry.Padding,
        function(self, event, value)
            dbEntry.Padding = value
            UF.SetupAuras(frame)
        end, 0.33)

    CreateSlider(group, "Row length", 1, 20, 1, dbEntry.RowLength,
        function(self, event, value)
            dbEntry.RowLength = value
            UF.SetupAuras(frame)
        end, 0.33)

    CreateDropDown(group, "Horizontal Growth Direction", dbEntry.DirH, directionsHorizontal,
        function(self, event, value)
            dbEntry.DirH = value
            UF.SetupAuras(frame)
        end, 0.5)
        
    CreateDropDown(group, "Vertical Growth Direction", dbEntry.DirV, directionsVertical,
        function(self, event, value)
            dbEntry.DirV = value
            UF.SetupAuras(frame)
        end, 0.5)

    CreateDropDown(group, "Anchor Point", dbEntry.AnchorPoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorPoint = value
            UF.SetupAuras(frame)
        end, 0.5)

    CreateDropDown(group, "Relative Anchor Point", dbEntry.AnchorRelativePoint, anchorPoints,
        function(self, event, value)
            dbEntry.AnchorRelativePoint = value
            UF.SetupAuras(frame)
        end, 0.5)

    CreateSlider(group, "Position X", -500, 500, 0.1, dbEntry.PosX,
        function(self, event, value)
            dbEntry.PosX = value
            UF.SetupAuras(frame)
        end, 0.5)

    CreateSlider(group, "Position Y", -500, 500, 0.1, dbEntry.PosY,
        function(self, event, value)
            dbEntry.PosY = value
            UF.SetupAuras(frame)
        end, 0.5)

    group:DoLayout()
end

local function CreateUnitFrameAuraPage(container, unitFrame)
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    CreateUnitFramAuraSettings(scrollFrame, unitFrame, "Buffs")

    CreateUnitFramAuraSettings(scrollFrame, unitFrame, "Debuffs")

    scrollFrame:DoLayout()
end

local function CreateUnitFrameTextPage(container, unitFrame)
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame]
    local frame = _G["CUI_"..unitFrame]

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local nameGroup = CreateTextGroup(scrollFrame, dbEntry.Name, UF.UpdateTexts, frame, "Name")

    CreateSlider(nameGroup, "Width", 1, 500, 1, dbEntry.Name.Width,
        function(self, event, value)
            dbEntry.Name.Width = value
            UF.UpdateTexts(frame)
        end, 1)

    CreateTextGroup(scrollFrame, dbEntry.HealthText, UF.UpdateTexts, frame, "Health")

    scrollFrame:DoLayout()
end

local function CreateUnitFrameCastBarPage(container, unitFrame)
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame].CastBar
    local frame = _G["CUI_"..unitFrame]

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local toggleGroup = CreateInlineGroup(scrollFrame, "Toggle")

    CreateCheckBox(toggleGroup, "Toggle Cast Bar", dbEntry.Enabled,
        function(self, event, value)
            dbEntry.Enabled = value
            UF.UpdateCastBarFrame(frame)
        end, 1)

    local sizeGroup = CreateSizeGroup(scrollFrame, dbEntry, UF.UpdateCastBarFrame, frame)

    CreateCheckBox(sizeGroup, "Match width to anchored frame (also forces anchor to bottom of frame)", dbEntry.MatchWidth,
        function(self, event, value)
            dbEntry.MatchWidth = value
            UF.UpdateCastBarFrame(frame)
        end, 1)

    CreateColorGroup(scrollFrame, dbEntry, UF.UpdateCastBarFrame, frame)

    CreateTextureGroup(scrollFrame, dbEntry, UF.UpdateCastBarFrame, frame)

    CreateAnchorGroup(scrollFrame, dbEntry, UF.UpdateCastBarFrame, frame)

    CreateTextGroup(scrollFrame, dbEntry.Name, UF.UpdateCastBarTexts, frame, "Spell Name")

    CreateTextGroup(scrollFrame, dbEntry.Time, UF.UpdateCastBarTexts, frame, "Spell Time")

    scrollFrame:DoLayout()
end

local function CreateUnitFrameMiscPage(container, unitFrame)
    local dbEntry = CUI.DB.profile.UnitFrames[unitFrame]
    local frame = _G["CUI_"..unitFrame]

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    if dbEntry.LeaderIcon then
        local leaderGroup = CreateInlineGroup(scrollFrame, "Leader / Assist Icon")

        CreateDropDown(leaderGroup, "Anchor Point", dbEntry.LeaderIcon.AnchorPoint, anchorPoints,
            function(self, event, value)
                dbEntry.LeaderIcon.AnchorPoint = value
                UF.UpdateLeaderAssist(frame)
            end, 0.5)

        CreateDropDown(leaderGroup, "Relative Anchor Point", dbEntry.LeaderIcon.AnchorRelativePoint, anchorPoints,
            function(self, event, value)
                dbEntry.LeaderIcon.AnchorRelativePoint = value
                UF.UpdateLeaderAssist(frame)
            end, 0.5)

        CreateSlider(leaderGroup, "Position X", -500, 500, 0.1, dbEntry.LeaderIcon.PosX,
            function(self, event, value)
                dbEntry.LeaderIcon.PosX = value
                UF.UpdateLeaderAssist(frame)
            end, 0.5)

        CreateSlider(leaderGroup, "Position Y", -500, 500, 0.1, dbEntry.LeaderIcon.PosY,
            function(self, event, value)
                dbEntry.LeaderIcon.PosY = value
                UF.UpdateLeaderAssist(frame)
            end, 0.5)
    end

    scrollFrame:DoLayout()
end

local function CreateUnitFrameTabs(container, unitFrame)
    local function SelectGroup(container, event, tab)
        container:ReleaseChildren()
        if tab == "Frame" then
            CreateUnitFrameFramePage(container, unitFrame)
        elseif tab == "Aura" then
            CreateUnitFrameAuraPage(container, unitFrame)
        elseif tab == "Text" then
            CreateUnitFrameTextPage(container, unitFrame)
        elseif tab == "CastBar" then
            CreateUnitFrameCastBarPage(container, unitFrame)
        elseif tab == "Misc" then
            CreateUnitFrameMiscPage(container, unitFrame)
        end
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="Frame", value="Frame"}, 
                    {text="Auras", value="Aura"},
                    {text="Texts", value="Text"},
                    {text="Cast Bar", value="CastBar"},
                    {text="Misc", value="Misc"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("Frame")

    container:AddChild(tabGroup)
    container:DoLayout()
end

local function CreateUnitFrameSettings(container)
    local function SelectGroup(container, event, unitFrame)
        container:ReleaseChildren()
        CreateUnitFrameTabs(container, unitFrame)
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="Player Frame", value="PlayerFrame"}, 
                    {text="Target Frame", value="TargetFrame"},
                    {text="Focus Frame", value="FocusFrame"},
                    {text="Pet Frame", value="PetFrame"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("PlayerFrame")

    container:AddChild(tabGroup)
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreateCDMPage(container, viewer)
    local dbEntry = CUI.DB.profile.CooldownManager[viewer]
    local frame = _G[viewer]

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    ----------------------------------------------------------------------------------------------------
    local textGroup = CreateInlineGroup(scrollFrame, "Text")

    CreateSlider(textGroup, "Cooldown Font Size", 1, 50, 1, dbEntry.Cooldown.Size, 
        function(self, event, value)
            dbEntry.Cooldown.Size = value
            CDM.UpdateStyle(frame)
        end, 0.5)

    CreateSlider(textGroup, "Charges Font Size", 1, 50, 1, dbEntry.Charges.Size, 
        function(self, event, value)
            dbEntry.Charges.Size = value
            CDM.UpdateStyle(frame)
        end, 0.5)

    ----------------------------------------------------------------------------------------------------

    CreateAlphaGroup(scrollFrame, dbEntry, CDM.UpdateAlpha, frame)

    scrollFrame:DoLayout()
end

local function CreateCDMSettings(container)
    local function SelectGroup(container, event, viewer)
        container:ReleaseChildren()
        CreateCDMPage(container, viewer)
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="Essential", value="EssentialCooldownViewer"}, 
                    {text="Utility", value="UtilityCooldownViewer"},
                    {text="Buff", value="BuffIconCooldownViewer"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("EssentialCooldownViewer")

    container:AddChild(tabGroup)
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreatePrimaryResourceBarPage(container)
    local dbEntry = CUI.DB.profile.ResourceBar
    local frame = CUI_PowerBar

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local sizeGroup = CreateSizeGroup(scrollFrame, dbEntry, RB.UpdateFrame, frame)

    CreateCheckBox(sizeGroup, "Match width to anchored frame (also forces anchor to top of frame)", dbEntry.MatchWidth,
        function(self, event, value)
            dbEntry.MatchWidth = value
            RB.UpdateFrame(frame)
        end, 1)

    CreateAlphaGroup(scrollFrame, dbEntry, RB.UpdateAlpha, frame)

    CreateTextureGroup(scrollFrame, dbEntry, RB.UpdateFrame, frame)

    CreateAnchorGroup(scrollFrame, dbEntry, RB.UpdateFrame, frame)

    CreateTextGroup(scrollFrame, dbEntry.Text, RB.UpdateText, frame, "Text")

    scrollFrame:DoLayout()
end

local function CreateSecondaryResourceBarPage(container)
    local dbEntry = CUI.DB.profile.ResourceBar.PersonalResourceBar
    local frame = PersonalResourceDisplayFrame

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    CreateAnchorGroup(scrollFrame, dbEntry, RB.UpdatePersonalBar, frame)

    scrollFrame:DoLayout()
end

local function CreateResourceBarSettings(container)
    local function SelectGroup(container, event, resource)
        container:ReleaseChildren()
        if resource == "Primary" then
            CreatePrimaryResourceBarPage(container)
        elseif resource == "Secondary" then
            CreateSecondaryResourceBarPage(container)
        end
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({{text="Primary", value="Primary"},
                    {text="Secondary", value="Secondary"},})
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("Primary")

    container:AddChild(tabGroup)
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreateMinimapSettings(container)
    local dbEntry = CUI.DB.profile.Minimap

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    CreateAlphaGroup(scrollFrame, dbEntry, MM.UpdateAlpha, MinimapCluster)

    scrollFrame:DoLayout()
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreatePlayerAuraSettings(container)
    local dbEntry = CUI.DB.profile.PlayerAuras

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local alphaGroup = CreateInlineGroup(scrollFrame, "Alpha") 

    CreateSlider(alphaGroup, "Alpha (Out of combat)", 0, 100, 1, dbEntry.Alpha*100, 
        function(self, event, value)
            dbEntry.Alpha = value/100
            PA.UpdateAlpha(BuffFrame)
            PA.UpdateAlpha(DebuffFrame)
        end, 0.5)

    CreateSlider(alphaGroup, "Alpha (In Combat)", 0, 100, 1, dbEntry.CombatAlpha*100, 
        function(self, event, value)
            dbEntry.CombatAlpha = value/100
            PA.UpdateAlpha(BuffFrame)
            PA.UpdateAlpha(DebuffFrame)
        end, 0.5)

    scrollFrame:DoLayout()
end

---------------------------------------------------------------------------------------------------------------------------------------

local function CreatePlayerCastBarSettings(container)
    local dbEntry = CUI.DB.profile.PlayerCastBar
    local frame = CUI_CastBar

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    container:AddChild(scrollFrame)

    local sizeGroup = CreateSizeGroup(scrollFrame, dbEntry, CB.UpdateFrame, frame)

    CreateCheckBox(sizeGroup, "Match width to anchored frame (also forces anchor to top of frame)", dbEntry.MatchWidth,
        function(self, event, value)
            dbEntry.MatchWidth = value
            CB.UpdateFrame(frame)
        end, 1)

    CreateColorGroup(scrollFrame, dbEntry, CB.UpdateFrame, frame)

    CreateTextureGroup(scrollFrame, dbEntry, CB.UpdateFrame, frame)

    CreateAnchorGroup(scrollFrame, dbEntry, CB.UpdateFrame, frame)

    scrollFrame:DoLayout()
end

---------------------------------------------------------------------------------------------------------------------------------------

local function SetupMainTabs(frame)
    local function SelectGroup(container, event, group)
        container:ReleaseChildren()
        if group == "General" then
            CreateGeneralSettings(container)
        elseif group == "ActionBars" then
            CreateActionBarSettings(container)
        elseif group == "UnitFrames" then
            CreateUnitFrameSettings(container)
        elseif group == "CooldownManager" then
            CreateCDMSettings(container)
        elseif group == "ResourceBar" then
            CreateResourceBarSettings(container)
        elseif group == "Minimap" then
            CreateMinimapSettings(container)
        elseif group == "PlayerAuras" then
            CreatePlayerAuraSettings(container)
        elseif group == "PlayerCastBar" then
            CreatePlayerCastBarSettings(container)
        elseif group == "" then

        elseif group == "" then
            
        end
    end

    local activeModules = {{text="General", value="General"}}
    local dbEntry = CUI.DB.profile

    if dbEntry.ActionBars.Enabled then
        table.insert(activeModules, {text="Action Bars", value="ActionBars"})
    end
    if dbEntry.UnitFrames.Enabled then
        table.insert(activeModules, {text="Unit Frames", value="UnitFrames"})
    end
    if dbEntry.CooldownManager.Enabled then
        table.insert(activeModules, {text="Cooldown Manager", value="CooldownManager"})
    end
    if dbEntry.ResourceBar.Enabled then
        table.insert(activeModules, {text="Resource Bar", value="ResourceBar"})
    end
    if dbEntry.PlayerCastBar.Enabled then
        table.insert(activeModules, {text="Player Cast Bar", value="PlayerCastBar"})
    end
    if dbEntry.Nameplates.Enabled then
        table.insert(activeModules, {text="Nameplates", value="Nameplates"})
    end
    if dbEntry.GroupFrames.Enabled then
        table.insert(activeModules, {text="Group Frames", value="GroupFrames"})
    end
    if dbEntry.Minimap.Enabled then
        table.insert(activeModules, {text="Minimap", value="Minimap"})
    end
    if dbEntry.PlayerAuras.Enabled then
        table.insert(activeModules, {text="Player Auras", value="PlayerAuras"})
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs(activeModules)
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("General")

    frame:AddChild(tabGroup)
end

---------------------------------------------------------------------------------------------------------------------------------------

function Conf.Load()
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("CalippoUI")
    frame:SetStatusText("CalippoUI, bästa UIn i Midnight!")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Fill")

    local dbEntry = CUI.DB.global.Config
    frame:SetWidth(dbEntry.Width)
    frame:SetHeight(dbEntry.Height)
    frame:SetPoint(dbEntry.AnchorPoint, UIParent, dbEntry.AnchorRelativePoint, dbEntry.PosX, dbEntry.PosY)

    function frame:OnWidthSet(width)
        CUI.DB.global.Config.Width = width
    end

    function frame:OnHeightSet(height)
        CUI.DB.global.Config.Height = height
    end

    frame:SetCallback("OnClose",
        function(self)
            local point, _, relativePoint, X, Y = self:GetPoint()
            dbEntry.AnchorPoint = point
            dbEntry.AnchorRelativePoint = relativePoint
            dbEntry.PosX = X
            dbEntry.PosY = Y
        end)

    SetupMainTabs(frame)
end