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
	local modules = {
		{
			["name"] = "ACTIONBAR_TOGGLE",
			["text"] = "Action Bars",
			["dbEntry"] = "ActionBars",
		},
		{
			["name"] = "UNITFRAME_TOGGLE",
			["text"] = "Unit Frames",
			["dbEntry"] = "UnitFrames",
		},
		{
			["name"] = "GROUPFRAME_TOGGLE",
			["text"] = "Group Frames",
			["dbEntry"] = "GroupFrames",
		},
		{
			["name"] = "CDM_TOGGLE",
			["text"] = "Cooldown Manager",
			["dbEntry"] = "CooldownManager",
		},
		{
			["name"] = "CHAT_TOGGLE",
			["text"] = "Chat",
			["dbEntry"] = "Chat",
		},
		{
			["name"] = "PLAYERAURA_TOGGLE",
			["text"] = "Player Auras",
			["dbEntry"] = "PlayerAuras",
		},
		{
			["name"] = "namePLATE_TOGGLE",
			["text"] = "Nameplates",
			["dbEntry"] = "NamePlates",
		},
		{
			["name"] = "MINIMAP_TOGGLE",
			["text"] = "Minimap",
			["dbEntry"] = "Minimap",
		},
		{
			["name"] = "CASTBAR_TOGGLE",
			["text"] = "Cast Bar",
			["dbEntry"] = "CastBar",
		},
		{
			["name"] = "RESOURCE_TOGGLE",
			["text"] = "Resource Bar",
			["dbEntry"] = "ResourceBar",
		},
	}

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Toggle Modules"))

	local initializer = CreateSettingsButtonInitializer("Reload UI", "Reload", function() ReloadUI() end, "Reloads the UI", "Reload")
	layout:AddInitializer(initializer)

	for i, v in ipairs(modules) do
		local setting = Settings.RegisterProxySetting(
			mainCategory,
			v.name,
			Settings.VarType.Boolean,
			v.text,
			CalippoDB[v.dbEntry].Enabled,
			function() return CalippoDB[v.dbEntry].Enabled end,
			function(value) CalippoDB[v.dbEntry].Enabled = value end
		)

		Settings.CreateCheckbox(mainCategory, setting)
	end
end

local function SetupActionBarPage(mainCategory)
	local category, layout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, "Action Bars")

	local actionBars = {
		{
			["name"] = "ACTIONBAR1_ALPHA_SLIDER",
			["text"] = "Action Bar 1",
			["dbEntry"] = "MainActionBar",
		},
		{
			["name"] = "ACTIONBAR2_ALPHA_SLIDER",
			["text"] = "Action Bar 2",
			["dbEntry"] = "MultiBarBottomLeft",
		},
		{
			["name"] = "ACTIONBAR3_ALPHA_SLIDER",
			["text"] = "Action Bar 3",
			["dbEntry"] = "MultiBarBottomRight",
		},
		{
			["name"] = "ACTIONBAR4_ALPHA_SLIDER",
			["text"] = "Action Bar 4",
			["dbEntry"] = "MultiBarRight",
		},
		{
			["name"] = "ACTIONBAR5_ALPHA_SLIDER",
			["text"] = "Action Bar 5",
			["dbEntry"] = "MultiBarLeft",
		},
		{
			["name"] = "ACTIONBAR6_ALPHA_SLIDER",
			["text"] = "Action Bar 6",
			["dbEntry"] = "MultiBar5",
		},
		{
			["name"] = "ACTIONBAR7_ALPHA_SLIDER",
			["text"] = "Action Bar 7",
			["dbEntry"] = "MultiBar6",
		},
		{
			["name"] = "ACTIONBAR8_ALPHA_SLIDER",
			["text"] = "Action Bar 8 (Anchored to player frame)",
			["dbEntry"] = "MultiBar7",
		},
		{
			["name"] = "MICROMENU_ALPHA_SLIDER",
			["text"] = "Micro Menu",
			["dbEntry"] = "MicroMenu",
		},
	}

	for i, v in ipairs(actionBars) do
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(v.text))
		
		local sliderSettings = Settings.RegisterProxySetting(
			category,
			v.name,
			Settings.VarType.Number,
			"Alpha",
			CalippoDB.ActionBars[v.dbEntry].Alpha,
			function() return CalippoDB.ActionBars[v.dbEntry].Alpha end,
			function(value) CalippoDB.ActionBars[v.dbEntry].Alpha = value; AB.UpdateAlphas() end
		)	
		
		local sliderOptions = Settings.CreateSliderOptions(0, 1, 0.01)
		sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return math.ceil(value * 100) end)
		Settings.CreateSlider(category, sliderSettings, sliderOptions)
	end
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
		function() return CalippoDB.UnitFrames.AuraSize end,
		function(v) CalippoDB.UnitFrames.AuraSize = v; UF.UpdateAuras(TargetFrame) end,
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
		function() return CalippoDB.UnitFrames.AuraPadding end,
		function(v) CalippoDB.UnitFrames.AuraPadding = v; UF.UpdateAuras(TargetFrame) end,
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
		function() return CalippoDB.UnitFrames.AuraRowLength end,
		function(v) CalippoDB.UnitFrames.AuraRowLength = v; UF.UpdateAuras(TargetFrame) end,
		0,
		15,
		1,
		nil
	)

	CreateUnitFrameSettings("Focus Frame", category, "FF", FocusFrame)
end

local function SetuoCDMPage(mainCategory)
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
	end

	CreateCDMSettings("Essential Viewer", category, "ECV", EssentialCooldownViewer)
	CreateCDMSettings("Utility Viewer", category, "UCV", UtilityCooldownViewer)
	CreateCDMSettings("Buff Viewer", category, "BCV", BuffIconCooldownViewer)
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

local function SetupResourcePage(mainCategory)
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
		0,
		50,
		1,
		nil
	)	

	CreateSlider(
		category,
		"RB_HEIGHT",
		"Height",
		0,
		function() return CalippoDB.ResourceBar.Height end,
		function(v) CalippoDB.ResourceBar.Height = v; RB.UpdateHeight(CUI_PowerBar) end,
		0,
		50,
		1,
		nil
	)	
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
	SetupActionBarPage(mainCategory)
	SetupUnitFramePage(mainCategory)
	SetuoCDMPage(mainCategory)
	SetupPlayerAuraPage(mainCategory)
	SetupResourcePage(mainCategory)
	SetupMinimapPage(mainCategory)

    Settings.RegisterAddOnCategory(mainCategory)
end