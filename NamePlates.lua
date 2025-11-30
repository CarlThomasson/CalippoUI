local addonName, CUI = ...

CUI.NP = {}
local NP = CUI.NP
local Util = CUI.Util
local Hide = CUI.Hide

function NP.Load()
    local frame = CreateFrame("Frame", "CUI_NamePlateTracker", UIParent)
    frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    frame:SetScript("OnEvent", function(self, event, unitToken)
        if event == "NAME_PLATE_UNIT_ADDED" then
            local namePlate = C_NamePlate.GetNamePlateForUnit(unitToken)
            local unitFrame = namePlate.UnitFrame

            unitFrame.name:Hide()
            unitFrame.name:HookScript("OnShow", function(self)
                self:Hide()
            end)

            unitFrame.myHealPrediction:Hide()
            unitFrame.myHealPrediction:HookScript("OnShow", function(self)
                self:Hide()
            end)

            if not unitFrame.CUI_Name then
                local name = unitFrame:CreateFontString(nil, "OVERLAY")
                name:SetParentKey("CUI_Name")
                name:SetPoint("LEFT", unitFrame.healthBar, "LEFT", 3, 0)
                name:SetPoint("RIGHT", unitFrame.healthBar, "RIGHT", -30, 0)
                name:SetJustifyH("LEFT")
                name:SetWordWrap(false)
                name:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 10, "")
            end
            unitFrame.CUI_Name:SetText(UnitName(unitToken))

            if not unitFrame.CUI_HealthText then
                local health = unitFrame:CreateFontString(nil, "OVERLAY")
                health:SetParentKey("CUI_HealthText")
                health:SetPoint("RIGHT", unitFrame.healthBar, "RIGHT", -3, 0)
                health:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 10, "")
            end
            unitFrame.CUI_HealthText:SetText(Util.UnitHealthPercent(unitToken))

            unitFrame.healthBar.bgTexture:Hide()
            unitFrame.healthBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")

            if not unitFrame.healthBar.Backdrop then
                Util.AddBackdrop(unitFrame.healthBar, 1, CUI_BACKDROP_DS_3)
                unitFrame.healthBar.Backdrop:SetFrameStrata("LOW")
            end

            unitFrame.healthBar.deselectedOverlay:Hide()

            unitFrame.healthBar.selectedBorder:ClearAllPoints()
            unitFrame.healthBar.selectedBorder:SetPoint("TOPLEFT", unitFrame.healthBar, "TOPLEFT", -2, 2)
            unitFrame.healthBar.selectedBorder:SetPoint("BOTTOMRIGHT", unitFrame.healthBar, "BOTTOMRIGHT", 2, -2)

            if not unitFrame.CUI_Background then
                local background = unitFrame:CreateTexture(nil, "BACKGROUND")
                background:SetParentKey("CUI_Background")
                background:SetAllPoints(unitFrame.healthBar)
                background:SetColorTexture(0, 0, 0, 1)
            end

            unitFrame.AurasFrame.DebuffListFrame:ClearAllPoints()
            unitFrame.AurasFrame.DebuffListFrame:SetPoint("BOTTOMLEFT", unitFrame.HealthBarsContainer, "TOPLEFT", 0, 2)

            unitFrame:RegisterUnitEvent("UNIT_HEALTH", unitToken)
            unitFrame:RegisterUnitEvent("UNIT_AURA", unitToken)
            unitFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
            unitFrame:HookScript("OnEvent", function(self, event, unit)
                if event == "UNIT_AURA" then
                    for index, frame in ipairs({self.AurasFrame.DebuffListFrame:GetChildren()}) do
                        frame.CountFrame.Count:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 12, "OUTLINE")
                        frame.Cooldown:GetRegions():SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 12, "OUTLINE")

                        local _, mask = frame:GetRegions()
                        if mask then 
                            frame.Icon:RemoveMaskTexture(mask)
                        end
                
                        if not frame.Backdrop then
                            frame.Icon:SetTexCoord(.08, .92, .08, .92)
                            Util.AddBackdrop(frame, 1, CUI_BACKDROP_DS_2)
                        end
                    end
                elseif event == "UNIT_HEALTH" then
                    unitFrame.CUI_HealthText:SetText(Util.UnitHealthPercent(unit))
                elseif event == "PLAYER_TARGET_CHANGED" then
                    self.healthBar.deselectedOverlay:Hide()
                end
            end)
        elseif event == "NAME_PLATE_UNIT_REMOVED" then

        end
    end)
end