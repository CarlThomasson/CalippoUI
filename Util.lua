local addonName, CUI = ...

CUI.Util = {}
local Util = CUI.Util

---------------------------------------------------------------------------------------------------

function Util.AddBorder(frame, offset, backdropInfo)
    if frame.Borders then return end
    frame.Borders = {}
    for i=1, 4 do
        frame.Borders[i] = frame:CreateLine(nil, "OVERLAY", nil, 0)
        local l = frame.Borders[i]
        l:SetThickness(PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1))
        l:SetColorTexture(0, 0, 0, 1)
        if i==1 then
            l:SetStartPoint("TOPLEFT")
            l:SetEndPoint("TOPRIGHT")
        elseif i==2 then
            l:SetStartPoint("TOPRIGHT")
            l:SetEndPoint("BOTTOMRIGHT")
        elseif i==3 then
            l:SetStartPoint("BOTTOMRIGHT")
            l:SetEndPoint("BOTTOMLEFT")
        else
            l:SetStartPoint("BOTTOMLEFT")
            l:SetEndPoint("TOPLEFT")
        end
    end
end

function Util.SetBorderColor(borders, r, g, b, a)
    for _, line in ipairs(borders) do
        line:SetColorTexture(r, g, b, a)
    end
end

function Util.AddStatusBarBackground(frame)
    local r, g, b = frame:GetStatusBarColor()

    local v = 0.2
    r, g, b = r*v, g*v, b*v

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetParentKey("Background")
    bg:SetAllPoints(frame)
    bg:SetTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")
    bg:SetVertexColor(r, g, b, 1)
end

function Util.GetUnitColor(unit)
    local r, g, b = 0, 0, 0

    if UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        if class then
            local color = C_ClassColor.GetClassColor(class)
            r, g, b = color.r, color.g, color.b
        end
    else
        local reaction = UnitReaction(unit, "player")

        if not reaction then return 0, 0, 0 end

        if reaction <= 3 then     -- Hostile
            r, g, b = 0.8, 0, 0
        elseif reaction == 4 then -- Neutral
            r, g, b = 0.8, 0.8, 0
        else                      -- Friendly
            r, g, b = 0, 0.8, 0
        end
    end

    return r, g, b
end

function Util.UnitHealthPercent(unit)
    return string.format("%0.0f", UnitHealthPercent(unit, true, true)).."%"
end

function Util.UnitHealthText(unit)
    local health = UnitHealth(unit)
    local rounded = AbbreviateLargeNumbers(health)
    return rounded
end

function Util.UnitPowerText(unit)
    local power = UnitPower(unit)
    local rounded = AbbreviateLargeNumbers(power)
    return rounded
end

local frameFadeManager = CreateFrame("Frame")

local function UIFrameFadeContains(frame)
	for i, fadeFrame in ipairs(FADEFRAMES) do
		if ( fadeFrame == frame ) then
			return true;
		end
	end

	return false;
end

function Util.FadeFrame(frame, inOut, endAlpha, fadeTime)
    if not fadeTime then fadeTime = 0.8 end
	local fadeInfo = {}
	fadeInfo.mode = inOut -- "IN" or "OUT"
	fadeInfo.timeToFade = fadeTime
	fadeInfo.startAlpha = frame:GetAlpha()
	fadeInfo.endAlpha = endAlpha

    frame.fadeInfo = fadeInfo

	if securecallfunction(UIFrameFadeContains, frame) then
		return
	end
	tinsert(FADEFRAMES, frame)
	frameFadeManager:SetScript("OnUpdate", UIFrameFade_OnUpdate)
end