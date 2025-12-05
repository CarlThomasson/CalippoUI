local addonName, CUI = ...

CUI.Conf = {}
local Conf = CUI.Conf
local AB = CUI.AB
local UF = CUI.UF
local CDM = CUI.CDM
local PA = CUI.PA
local RB = CUI.RB
local MM = CUI.MM

---------------------------------------------------------------------------------------------------

local function CreateSlider(category, name, text, default, getter, setter, min, max, step, display)
	local sliderSettings = Settings.RegisterProxySetting(
		category,
		name,
		Settings.VarType.Number,
		text,
		default,
		getter,
		setter
	)	
	
	local sliderOptions = Settings.CreateSliderOptions(min, max, step)
	if not display then display = function(v) return v end end
	sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, display)
	Settings.CreateSlider(category, sliderSettings, sliderOptions)
end

---------------------------------------------------------------------------------------------------

local function SetupMainPage(mainCategory, layout)
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Toggle Modules"))
	
	local function CreateToggleSettings(category, shortName, text, dbEntry)
		local toggleSettings = Settings.RegisterProxySetting(
			category,
			shortName.."_TOGGLE",
			Settings.VarType.Boolean,
			text,
			CalippoDB[dbEntry].Enabled,
			function() return CalippoDB[dbEntry].Enabled end,
			function(value) CalippoDB[dbEntry].Enabled = value end
		)

		Settings.CreateCheckbox(category, toggleSettings)
	end

	local initializer = CreateSettingsButtonInitializer("Reload UI to apply changes", "Reload", function() ReloadUI() end, "", "")
	layout:AddInitializer(initializer)

	CreateToggleSettings(mainCategory, "AB", "Action Bars", "ActionBars")
	CreateToggleSettings(mainCategory, "UF", "Unit Frames", "UnitFrames")
	CreateToggleSettings(mainCategory, "GF", "Group Frames", "GroupFrames")
	CreateToggleSettings(mainCategory, "CDM", "Cooldown Manager", "CooldownManager")
	CreateToggleSettings(mainCategory, "NP", "Nameplates", "NamePlates")
	CreateToggleSettings(mainCategory, "CB", "Cast Bar", "CastBar")
	CreateToggleSettings(mainCategory, "RB", "Resource Bar", "ResourceBar")
	CreateToggleSettings(mainCategory, "PA", "Player Auras", "PlayerAuras")
	CreateToggleSettings(mainCategory, "MM", "Minimap", "Minimap")
	CreateToggleSettings(mainCategory, "CH", "Chat", "Chat")
end

local function SetupActionBarPage(mainCategory)
	local category, layout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, "Action Bars")

	local function CreateActionBarSettings(title, category, shortName, frame) 
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(title))
		
		CreateSlider(
			category,
			shortName.."_ALPHA",
			"Alpha (Out of combat)",
			0,
			function() return CalippoDB.ActionBars[frame:GetName()].Alpha end,
			function(v) CalippoDB.ActionBars[frame:GetName()].Alpha = v; AB.UpdateAlpha(frame) end,
			0,
			1,
			0.01,
			function(v) return math.floor(v * 100) end
		)

		CreateSlider(
			category,
			shortName.."_COMBATALPHA",
			"Alpha (In combat)",
			0,
			function() return CalippoDB.ActionBars[frame:GetName()].CombatAlpha end,
			function(v) CalippoDB.ActionBars[frame:GetName()].CombatAlpha = v; AB.UpdateAlpha(frame) end,
			0,
			1,
			0.01,
			function(v) return math.floor(v * 100) end
		)	
	end

	CreateActionBarSettings("Action Bar 1", category, "AB1", MainActionBar)
	CreateActionBarSettings("Action Bar 2", category, "AB2", MultiBarBottomLeft)
	CreateActionBarSettings("Action Bar 3", category, "AB3", MultiBarBottomRight)
	CreateActionBarSettings("Action Bar 4", category, "AB4", MultiBarRight)
	CreateActionBarSettings("Action Bar 5", category, "AB5", MultiBarLeft)
	CreateActionBarSettings("Action Bar 6", category, "AB6", MultiBar5)
	CreateActionBarSettings("Action Bar 7", category, "AB7", MultiBar6)
	CreateActionBarSettings("Action Bar 8 (Anchored to Player Frame)", category, "AB8", MultiBar7)
	CreateActionBarSettings("Pet Bar", category, "PETB", PetActionBar)
	CreateActionBarSettings("Micro Menu", category, "MICRO", MicroMenu)
end

local function SetupUnitFramePage(mainCategory)
	local category, layout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, "Unit Frames")

	local function CreateUnitFrameSettings(title, category, shortName, frame)
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(title))

		CreateSlider(
			category,
			shortName.."_SIZEX",
			"Width",
			0,
			function() return CalippoDB.UnitFrames[frame:GetName()].SizeX end,
			function(v) CalippoDB.UnitFrames[frame:GetName()].SizeX = v; UF.UpdateSizePos(frame) end,
			0,
			300,
			1,
			nil
		)

		CreateSlider(
			category,
			shortName.."_SIZEY",
			"Height",
			0,
			function() return CalippoDB.UnitFrames[frame:GetName()].SizeY end,
			function(v) CalippoDB.UnitFrames[frame:GetName()].SizeY = v; UF.UpdateSizePos(frame) end,
			0,
			300,
			1,
			nil
		)

		CreateSlider(
			category,
			shortName.."_OFFSETX",
			"Offset X",
			0,
			function() return CalippoDB.UnitFrames[frame:GetName()].OffsetX end,
			function(v) CalippoDB.UnitFrames[frame:GetName()].OffsetX = v; UF.UpdateSizePos(frame) end,
			-100,
			100,
			1,
			nil
		)

		CreateSlider(
			category,
			shortName.."_OFFSETY",
			"Offset Y",
			0,
			function() return CalippoDB.UnitFrames[frame:GetName()].OffsetY end,
			function(v) CalippoDB.UnitFrames[frame:GetName()].OffsetY = v; UF.UpdateSizePos(frame) end,
			-100,
			100,
			1,
			nil
		)

		CreateSlider(
			category,
			shortName.."_NAMEFONTSIZE",
			"Name font size",
			0,
			function() return CalippoDB.UnitFrames[frame:GetName()].NameFontSize end,
			function(v) CalippoDB.UnitFrames[frame:GetName()].NameFontSize = v; UF.UpdateTexts(frame) end,
			0,
			100,
			1,
			nil
		)

		CreateSlider(
			category,
			shortName.."_HEALTHFONTSIZE",
			"Health font size",
			0,
			function() return CalippoDB.UnitFrames[frame:GetName()].HealthFontSize end,
			function(v) CalippoDB.UnitFrames[frame:GetName()].HealthFontSize = v; UF.UpdateTexts(frame) end,
			0,
			100,
			1,
			nil
		)

		CreateSlider(
			category,
			shortName.."_ALPHA",
			"Alpha (Out of combat)",
			0,
			function() return CalippoDB.UnitFrames[frame:GetName()].Alpha end,
			function(v) CalippoDB.UnitFrames[frame:GetName()].Alpha = v; UF.UpdateAlpha(frame) end,
			0,
			1,
			0.01,
			function(v) return math.floor(v * 100) end
		)
	end

	CreateUnitFrameSettings("Player Frame", category, "PF", PlayerFrame)

	CreateUnitFrameSettings("Target Frame", category, "TF", TargetFrame)
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Target Frame Auras"))

	CreateSlider(
		category,
		"TF_AURASIZE",
		"Aura Size",
		0,
		function() return CalippoDB.UnitFrames.TargetFrame.AuraSize end,
		function(v) CalippoDB.UnitFrames.TargetFrame.AuraSize = v; UF.UpdateAuras(TargetFrame) end,
		0,
		50,
		1,
		nil
	)

	CreateSlider(
		category,
		"TF_AURAPADDING",
		"Aura Padding",
		0,
		function() return CalippoDB.UnitFrames.TargetFrame.AuraPadding end,
		function(v) CalippoDB.UnitFrames.TargetFrame.AuraPadding = v; UF.UpdateAuras(TargetFrame) end,
		0,
		10,
		1,
		nil
	)

	CreateSlider(
		category,
		"TF_AURAROW",
		"Aura Row Length",
		0,
		function() return CalippoDB.UnitFrames.TargetFrame.AuraRowLength end,
		function(v) CalippoDB.UnitFrames.TargetFrame.AuraRowLength = v; UF.UpdateAuras(TargetFrame) end,
		0,
		15,
		1,
		nil
	)

	CreateUnitFrameSettings("Focus Frame", category, "FF", FocusFrame)
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Focus Frame Auras"))

	CreateSlider(
		category,
		"FF_AURASIZE",
		"Aura Size",
		0,
		function() return CalippoDB.UnitFrames.FocusFrame.AuraSize end,
		function(v) CalippoDB.UnitFrames.FocusFrame.AuraSize = v; UF.UpdateAuras(FocusFrame) end,
		0,
		50,
		1,
		nil
	)

	CreateSlider(
		category,
		"FF_AURAPADDING",
		"Aura Padding",
		0,
		function() return CalippoDB.UnitFrames.FocusFrame.AuraPadding end,
		function(v) CalippoDB.UnitFrames.FocusFrame.AuraPadding = v; UF.UpdateAuras(FocusFrame) end,
		0,
		10,
		1,
		nil
	)

	CreateSlider(
		category,
		"FF_AURAROW",
		"Aura Row Length",
		0,
		function() return CalippoDB.UnitFrames.FocusFrame.AuraRowLength end,
		function(v) CalippoDB.UnitFrames.FocusFrame.AuraRowLength = v; UF.UpdateAuras(FocusFrame) end,
		0,
		15,
		1,
		nil
	)

	CreateUnitFrameSettings("Pet Frame", category, "PETF", PetFrame)
end

local function SetupCDMPage(mainCategory)
	local category, layout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, "Cooldown Manager")

	local function CreateCDMSettings(title, category, shortName, frame)
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(title))
		CreateSlider(
			category,
			shortName.."_ALPHA",
			"Alpha (Out of combat)",
			0,
			function() return CalippoDB.CooldownManager[frame:GetName()].Alpha end,
			function(v) CalippoDB.CooldownManager[frame:GetName()].Alpha = v; CDM.UpdateAlpha(frame) end,
			0,
			1,
			0.01,
			function(v) return math.floor(v * 100) end
		)

		CreateSlider(
			category,
			shortName.."_CDFONTSIZE",
			"Cooldown Font Size",
			0,
			function() return CalippoDB.CooldownManager[frame:GetName()].CooldownFontSize end,
			function(v) CalippoDB.CooldownManager[frame:GetName()].CooldownFontSize = v; CDM.UpdateStyle(frame) end,
			1,
			50,
			1,
			nil
		)

		CreateSlider(
			category,
			shortName.."_COUNTFONTSIZE",
			"Count Font Size",
			0,
			function() return CalippoDB.CooldownManager[frame:GetName()].CountFontSize end,
			function(v) CalippoDB.CooldownManager[frame:GetName()].CountFontSize = v; CDM.UpdateStyle(frame) end,
			1,
			50,
			1,
			nil
		)
	end

	CreateCDMSettings("Buff Viewer", category, "BCV", BuffIconCooldownViewer)
	CreateCDMSettings("Essential Viewer", category, "ECV", EssentialCooldownViewer)
	CreateCDMSettings("Utility Viewer", category, "UCV", UtilityCooldownViewer)
end

local function SetupPlayerAuraPage(mainCategory)
	local category, layout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, "Player Auras")

	CreateSlider(
		category,
		"PA_ALPHA",
		"Alpha (Out of combat)",
		0,
		function() return CalippoDB.PlayerAuras.Alpha end,
		function(v) CalippoDB.PlayerAuras.Alpha = v; PA.UpdateAlpha(BuffFrame); PA.UpdateAlpha(DebuffFrame) end,
		0,
		1,
		0.01,
		function(v) return math.floor(v * 100) end
	)
end

local function SetupResourceBarPage(mainCategory)
	local category, layout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, "Resource Bar")

	CreateSlider(
		category,
		"RB_ALPHA",
		"Alpha (Out of combat)",
		0,
		function() return CalippoDB.ResourceBar.Alpha end,
		function(v) CalippoDB.ResourceBar.Alpha = v; RB.UpdateAlpha(CUI_PowerBar) end,
		0,
		1,
		0.01,
		function(v) return math.floor(v * 100) end
	)

	CreateSlider(
		category,
		"RB_FONTSIZE",
		"Font Size",
		0,
		function() return CalippoDB.ResourceBar.FontSize end,
		function(v) CalippoDB.ResourceBar.FontSize = v; RB.UpdateFontSize(CUI_PowerBar) end,
		1,
		100,
		1,
		nil
	)	

	CreateSlider(
		category,
		"RB_HEIGHT",
		"Height",
		0,
		function() return CalippoDB.ResourceBar.Height end,
		function(v) CalippoDB.ResourceBar.Height = v; RB.UpdateSize(CUI_PowerBar) end,
		0,
		100,
		1,
		nil
	)	

	CreateSlider(
		category,
		"RB_WIDTH",
		"Width",
		0,
		function() return CalippoDB.ResourceBar.Width end,
		function(v) CalippoDB.ResourceBar.Width = v; RB.UpdateSize(CUI_PowerBar) end,
		0,
		500,
		1,
		nil
	)

	CreateSlider(
		category,
		"RB_OFFSETX",
		"Offset X",
		0,
		function() return CalippoDB.ResourceBar.OffsetX end,
		function(v) CalippoDB.ResourceBar.OffsetX = v; RB.UpdatePosition(CUI_PowerBar) end,
		-500,
		500,
		1,
		nil
	)	

	CreateSlider(
		category,
		"RB_OFFSETY",
		"Offset Y",
		0,
		function() return CalippoDB.ResourceBar.OffsetY end,
		function(v) CalippoDB.ResourceBar.OffsetY = v; RB.UpdatePosition(CUI_PowerBar) end,
		-500,
		500,
		1,
		nil
	)	

	local toggleSettings = Settings.RegisterProxySetting(
		category,
		"RB_TOGGLEANCHOR",
		Settings.VarType.Boolean,
		"Anchor to CDM",
		CalippoDB.ResourceBar.AnchorToCDM,
		function() return CalippoDB.ResourceBar.AnchorToCDM end,
		function(value) CalippoDB.ResourceBar.AnchorToCDM = value; RB.UpdatePosition(CUI_PowerBar); RB.UpdateSize(CUI_PowerBar) end
	)

	Settings.CreateCheckbox(category, toggleSettings)
end

local function SetupMinimapPage(mainCategory)
	local category, layout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, "Minimap")

	CreateSlider(
		category,
		"MM_ALPHA",
		"Alpha (Out of combat)",
		0,
		function() return CalippoDB.Minimap.Alpha end,
		function(v) CalippoDB.Minimap.Alpha = v; MM.UpdateAlpha(MinimapCluster) end,
		0,
		1,
		0.01,
		function(v) return math.floor(v * 100) end
	)	
end

---------------------------------------------------------------------------------------------------

function Conf.Load()	
    local mainCategory, layout = Settings.RegisterVerticalLayoutCategory("CalippoUI")

	SettingsPanel:RegisterForDrag("LeftButton")
	SettingsPanel:HookScript("OnDragStart", function(self)
		self:StartMoving()
	end)
	SettingsPanel:HookScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)

	SetupMainPage(mainCategory, layout)

	if CalippoDB.ActionBars.Enabled then
		SetupActionBarPage(mainCategory)
	end

	if CalippoDB.UnitFrames.Enabled then
		SetupUnitFramePage(mainCategory)
	end

	if CalippoDB.CooldownManager.Enabled then
		SetupCDMPage(mainCategory)
	end

	if CalippoDB.ResourceBar.Enabled then
		SetupResourceBarPage(mainCategory)
	end

	if CalippoDB.PlayerAuras.Enabled then
		SetupPlayerAuraPage(mainCategory)
	end

	if CalippoDB.Minimap.Enabled then
		SetupMinimapPage(mainCategory)
	end

    Settings.RegisterAddOnCategory(mainCategory)
end