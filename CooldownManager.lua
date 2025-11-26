local addonName, CUI = ...

CUI.CDM = {}
local CDM = CUI.CDM
local Util = CUI.Util

local function UpdateIcon(frame, type)
        if frame.Icon then
            local mask = frame.Icon:GetMaskTexture(1)
            frame.Icon:RemoveMaskTexture(mask)
            frame.Icon:SetTexCoord(.08, .92, .08, .92)

            local _, _, overlay = frame:GetRegions()
            overlay:Hide()

            Util.AddBackdrop(frame, 1, CUI_BACKDROP_DS_3)
        end

        if frame.Applications then
            frame.Applications.Applications:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 18, "OUTLINE")
        end

        if frame.ChargeCount then
            frame.ChargeCount.Current:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 18, "OUTLINE")
        end

        if frame.Cooldown then
            frame.Cooldown:SetSwipeTexture("", 0, 0, 0, 1)
            --frame.Cooldown:SetEdgeTexture()

            local text = frame.Cooldown:GetRegions()
            text:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 18, "OUTLINE")
        end

        if frame.OutOfRange then
            frame.OutOfRange:SetScript("OnShow", function(self)
                self:Hide()
            end)
        end

        if frame.CooldownFlash then
            frame.CooldownFlash:SetScript("OnShow", function(self)
                self:Hide()
            end)
        end
end

local function PositionIcons()
    for index, child in ipairs({EssentialCooldownViewer:GetChildren()}) do 
        UpdateIcon(child, "Essential")
    end

    for index, child in ipairs({UtilityCooldownViewer:GetChildren()}) do 
        UpdateIcon(child, "Utility")
    end

    for index, child in ipairs({BuffIconCooldownViewer:GetChildren()}) do 
        UpdateIcon(child, "BuffIcon")
    end
end

function CDM.Load()
    PositionIcons()
end