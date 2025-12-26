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
    local dbEntry = CUI.DB.profile.CooldownManager[frame:GetName()]

    if InCombatLockdown() or inCombat then
        Util.FadeFrame(frame, "IN", dbEntry.CombatAlpha)
    else
        Util.FadeFrame(frame, "OUT", dbEntry.Alpha)
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

        if frame.DebuffBorder then
            frame.DebuffBorder:ClearAllPoints()
            frame.DebuffBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -6, 6)
            frame.DebuffBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 6, -6)
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

local function UpdatePositions(viewer)
    local padding = viewer.childXPadding
    local rowSize = viewer.iconLimit

    local viewerName = viewer:GetName()

    local frameSize
    if viewerName == "EssentialCooldownViewer" then
        frameSize = 50
        viewer.frameSize = 50
    elseif viewerName == "UtilityCooldownViewer" then
        frameSize = 30
        viewer.frameSize = 30
    elseif viewerName == "BuffIconCooldownViewer" then
        frameSize = 40
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
    local starts
    local ends

    if viewerName == "BuffIconCooldownViewer" then
        lastRowOffest = ((frameSize + padding) * (#frames - 1)) / 2 + padding
        starts = 1
        ends = #frames
    else
        lastRow = math.ceil(#frames / rowSize) - 1
        lastRowSize = #frames % rowSize

        if lastRowSize == 0 or lastRowSize == #frames then return end

        starts = (rowSize*lastRow) + 1
        ends = #frames
        lastRowOffest = (frameSize + padding) * ((rowSize - lastRowSize) / 2)
    end

    for index=starts, ends do
        local frame = frames[index]
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
    end
end

local function HookScripts(viewer)
    viewer:HookScript("OnSizeChanged", function(self)
        CDM.UpdateStyle(self)
        UpdatePositions(self)
    end)

    viewer:HookScript("OnShow", function(self)
        UpdatePositions(self)
        CDM.UpdateAlpha(self)
    end)

    viewer:RegisterEvent("PLAYER_REGEN_ENABLED")
    viewer:RegisterEvent("PLAYER_REGEN_DISABLED")
    viewer:HookScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_ENABLED" then
            CDM.UpdateAlpha(self)
        elseif event == "PLAYER_REGEN_DISABLED" then
            CDM.UpdateAlpha(self, true)
        end
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
    end
end