local addonName, CUI = ...

CUI.CDM = {}
local CDM = CUI.CDM
local Util = CUI.Util

local cooldownViewers = {
    EssentialCooldownViewer,
    UtilityCooldownViewer,
    BuffIconCooldownViewer,
}

---------------------------------------------------------------------------------------------------

function CDM.UpdateAlpha(frame, inCombat)
    if not frame:IsShown() then return end

    if InCombatLockdown() or inCombat then 
        Util.FadeFrame(frame, "IN", CUI.DB.profile.CooldownManager[frame:GetName()].CombatAlpha)
    else
        Util.FadeFrame(frame, "OUT", CUI.DB.profile.CooldownManager[frame:GetName()].Alpha)
    end
end

function CDM.UpdateStyle(viewer)
    local dbEntry = CUI.DB.profile.CooldownManager[viewer:GetName()]

    for _, frame in ipairs({viewer:GetChildren()}) do
        if frame.Icon then
            frame.Icon:SetTexCoord(.08, .92, .08, .92)

            local mask = frame.Icon:GetMaskTexture(1)
            if mask then
                frame.Icon:RemoveMaskTexture(mask)

                local _, _, overlay = frame:GetRegions()
                overlay:Hide()
            end

            if not frame.Borders then
                Util.AddBorder(frame)
            end
        end

        if frame.Applications then
            frame.Applications.Applications:SetFont(dbEntry.Charges.Font, dbEntry.Charges.Size, dbEntry.Charges.Outline)
            frame.Applications.Applications:ClearAllPoints()
            frame.Applications.Applications:SetPoint(dbEntry.Charges.AnchorPoint, frame, dbEntry.Charges.AnchorRelativePoint, dbEntry.Charges.PosX, dbEntry.Charges.PosY)
        end

        if frame.ChargeCount then
            frame.ChargeCount.Current:SetFont(dbEntry.Charges.Font, dbEntry.Charges.Size, dbEntry.Charges.Outline)
            frame.ChargeCount.Current:ClearAllPoints()
            frame.ChargeCount.Current:SetPoint(dbEntry.Charges.AnchorPoint, frame, dbEntry.Charges.AnchorRelativePoint, dbEntry.Charges.PosX, dbEntry.Charges.PosY)
        end

        if frame.Cooldown then
            frame.Cooldown:SetSwipeTexture("", 1, 1, 1, 1)

            local text = frame.Cooldown:GetRegions()
            text:SetFont(dbEntry.Cooldown.Font, dbEntry.Cooldown.Size, dbEntry.Cooldown.Outline)
            text:ClearAllPoints()
            text:SetPoint(dbEntry.Cooldown.AnchorPoint, frame, dbEntry.Cooldown.AnchorRelativePoint, dbEntry.Cooldown.PosX, dbEntry.Cooldown.PosY)
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
end

---------------------------------------------------------------------------------------------------

local function FixWidth(viewer)
    if not InCombatLockdown() then
        C_Timer.After(0.5, function()
            viewer:SetWidth(viewer.iconScale * ((math.min(viewer.frameCount, viewer.iconLimit) * (viewer.frameSize + viewer.iconPadding) - viewer.iconPadding)))
        end)
    end
end

local function UpdatePositions(viewer)
    local iconScale = viewer.iconScale
    local padding = viewer.iconPadding
    local rowSize = viewer.iconLimit

    local viewerName = viewer:GetName()

    local frameSize
    if viewerName == "EssentialCooldownViewer" then
        frameSize = 50 * iconScale
        viewer.frameSize = frameSize
    elseif viewerName == "UtilityCooldownViewer" then
        frameSize = 30 * iconScale
        viewer.frameSize = frameSize
    elseif viewerName == "BuffIconCooldownViewer" then
        frameSize = 40 * iconScale
    end

    local frames = {}
    for _, frame in ipairs({viewer:GetChildren()}) do
        if frame.Cooldown and frame.Icon and frame:IsShown() then
            table.insert(frames, frame)
        end
    end
    viewer.frameCount = #frames

    table.sort(frames, function(a, b)
        local a2 = a.layoutIndex or 1000
        local b2 = b.layoutIndex or 1000
        return a2 < b2 
    end)

    local lastRow
    local lastRowSize
    local lastRowOffest

    if viewerName == "BuffIconCooldownViewer" then
        lastRowOffest = ((frameSize + padding) * (#frames - 1)) / 2 + padding
    else
        lastRow = math.ceil(#frames / rowSize) - 1
        lastRowSize = #frames % rowSize
        if lastRowSize == 0 then lastRowSize = rowSize end
        lastRowOffest = (frameSize + padding) * ((rowSize - lastRowSize) / 2)
    end

    for index, frame in ipairs(frames) do
        index = index - 1
        local row = math.floor(index/rowSize)

        frame:ClearAllPoints()

        if viewerName == "BuffIconCooldownViewer" then
            frame:SetPoint("CENTER", viewer, "CENTER", (index*(frameSize+padding))-lastRowOffest, 0)
        elseif row == lastRow and row ~= 0 and lastRowSize ~= rowSize then
            frame:SetPoint("TOPLEFT", viewer, "TOPLEFT", (index*(frameSize+padding))-(row*rowSize*(frameSize+padding))+lastRowOffest, -(row*(frameSize+padding)))
        else
            frame:SetPoint("TOPLEFT", viewer, "TOPLEFT", (index*(frameSize+padding))-(row*rowSize*(frameSize+padding)), -(row*(frameSize+padding)))
        end

        frame:SetSize(frameSize, frameSize)
    end
end

local function HookScripts(viewer)
    viewer:HookScript("OnShow", function(self)
        CDM.UpdateStyle(self)
    end)

    viewer:HookScript("OnSizeChanged", function(self)
        CDM.UpdateStyle(self)
        UpdatePositions(self)
    end)

    if viewer:GetName() == "BuffIconCooldownViewer" then
        hooksecurefunc(viewer, "OnAcquireItemFrame", function(self, itemFrame)
            itemFrame:SetScript("OnShow", function()
                UpdatePositions(viewer)
            end)

            itemFrame:SetScript("OnHide", function()
                UpdatePositions(viewer)
            end)
        end)
    end
end

---------------------------------------------------------------------------------------------------

function CDM.Load()
    C_CVar.SetCVar("cooldownViewerEnabled", 1)

    for _, viewer in pairs(cooldownViewers) do
        UpdatePositions(viewer)
        CDM.UpdateAlpha(viewer)

        HookScripts(viewer)

        viewer:HookScript("OnShow", function(self)
            if self:GetName() ~= "BuffIconCooldownViewer" then
                FixWidth(self)
            end
            UpdatePositions(self)
            CDM.UpdateAlpha(self)
        end)

        if viewer:GetName() ~= "BuffIconCooldownViewer" then
            viewer:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
        end
        viewer:RegisterEvent("PLAYER_REGEN_ENABLED")
        viewer:RegisterEvent("PLAYER_REGEN_DISABLED")
        viewer:HookScript("OnEvent", function(self, event)
            if event == "PLAYER_REGEN_ENABLED" then
                CDM.UpdateAlpha(self)
            elseif event == "PLAYER_REGEN_DISABLED" then
                CDM.UpdateAlpha(self, true)
            elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
                 FixWidth(self)
            end
        end)

        CDM.UpdateAlpha(viewer)
    end
end