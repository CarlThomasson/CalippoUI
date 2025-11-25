local addonName, CUI = ...

CUI.Util = {}
local Util = CUI.Util

function Util.AddBackdrop(frame, offset, backdropInfo)
    local bd = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    bd:SetParentKey("Backdrop")
    bd:SetPoint("TOPLEFT", frame, "TOPLEFT", -offset, offset)
    bd:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", offset, -offset)
    bd:SetBackdrop(backdropInfo)
end

function Util.AddStatusBarBackground(frame)
    local r, g, b = frame:GetStatusBarColor()

    local v = 0.2
    r, g, b = r*v, g*v, b*v

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetParentKey("Background")
    bg:SetAllPoints(frame)
    bg:SetColorTexture(r, g, b, 1)
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
    return UnitHealthPercent(unit)
end

function Util.UnitHealthText(unit)
    local health = UnitHealth(unit)
    local rounded = AbbreviateLargeNumbers(health)
    return rounded
end