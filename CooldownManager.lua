local addonName, CUI = ...

CUI.CDM = {}
local CDM = CUI.CDM
local Util = CUI.Util

---------------------------------------------------------------------------------------------------

function CDM.UpdateAlpha(frame, inCombat)
    if not frame:IsShown() then return end

    if InCombatLockdown() or inCombat then 
        UIFrameFadeIn(frame, 0.6, frame:GetAlpha(), 1)
    else
        UIFrameFadeOut(frame, 0.6, frame:GetAlpha(), CalippoDB.CooldownManager[frame:GetName()].Alpha)
    end
end

---------------------------------------------------------------------------------------------------

local function UpdateStyle(viewer)
    for _, frame in ipairs({viewer:GetChildren()}) do
        if frame.Icon then
            local mask = frame.Icon:GetMaskTexture(1)
            if mask then
                frame.Icon:RemoveMaskTexture(mask)
                frame.Icon:SetTexCoord(.08, .92, .08, .92)

                local _, _, overlay = frame:GetRegions()
                overlay:Hide()

                Util.AddBackdrop(frame, 1, CUI_BACKDROP_DS_3)
            end
        end

        if frame.Applications then
            frame.Applications.Applications:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 13, "OUTLINE")
            frame.Applications.Applications:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        end

        if frame.ChargeCount then
            local fontSize
            if viewer:GetName() == "EssentialCooldownViewer" then
                fontSize = 18
            elseif viewer:GetName() == "UtilityCooldownViewer" then
                fontSize = 12
            end

            frame.ChargeCount.Current:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", fontSize, "OUTLINE")
            frame.ChargeCount.Current:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        end

        if frame.Cooldown then
            frame.Cooldown:SetSwipeTexture("", 0, 0, 0, 1)
            --frame.Cooldown:SetEdgeTexture()
            
            local fontSize
            if viewer:GetName() == "EssentialCooldownViewer" then
                fontSize = 18
            elseif viewer:GetName() == "UtilityCooldownViewer" then
                fontSize = 12
            elseif viewer:GetName() == "BuffIconCooldownViewer" then
                fontSize = 13
            end

            local text = frame.Cooldown:GetRegions()
            text:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", fontSize, "OUTLINE")
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

local function UpdatePositions(viewer)
    local iconScale = viewer.iconScale
    local padding = viewer.iconPadding
    local rowSize = viewer.iconLimit

    local frameSize
    if viewer:GetName() == "EssentialCooldownViewer" then
        frameSize = 50 * viewer.iconScale 
    elseif viewer:GetName() == "UtilityCooldownViewer" then
        frameSize = 30 * viewer.iconScale 
    elseif viewer:GetName() == "BuffIconCooldownViewer" then
        frameSize = 40 * viewer.iconScale 
    end

    local frames = {}
    for _, frame in ipairs({viewer:GetChildren()}) do
        if frame.Cooldown and frame.Icon and frame:IsShown() then
            table.insert(frames, frame)
        end
    end

    table.sort(frames, function(a, b)
        local a2 = a.layoutIndex or 1000
        local b2 = b.layoutIndex or 1000
        return a2 < b2 
    end)

    local lastRow
    local lastRowSize
    local lastRowOffest

    if viewer:GetName() == "BuffIconCooldownViewer" then
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

        if viewer:GetName() == "BuffIconCooldownViewer" then
            frame:SetPoint("CENTER", viewer, "CENTER", (index*(frameSize+padding))-lastRowOffest, 0)
        elseif row == lastRow and row ~= 0 and lastRowSize ~= rowSize then
            frame:SetPoint("TOPLEFT", viewer, "TOPLEFT", (index*(frameSize+padding))-(row*rowSize*(frameSize+padding))+lastRowOffest, -(row*(frameSize+padding)))
        else
            frame:SetPoint("TOPLEFT", viewer, "TOPLEFT", (index*(frameSize+padding))-(row*rowSize*(frameSize+padding)), -(row*(frameSize+padding)))
        end
        
        frame:SetSize(frameSize, frameSize)
    end
end

local cooldownViewers = {
    EssentialCooldownViewer,
    UtilityCooldownViewer,
    BuffIconCooldownViewer,
}

local function HookScripts(viewer)
    viewer:HookScript("OnShow", function(self)
        UpdateStyle(self)
    end)

    viewer:HookScript("OnSizeChanged", function(self)
        UpdateStyle(self)
        UpdatePositions(self)
    end)

    if viewer:GetName() == "BuffIconCooldownViewer" then
        hooksecurefunc(viewer, "OnAcquireItemFrame", function(self, itemFrame)
            itemFrame:SetScript("OnShow", function(self)
                UpdatePositions(viewer)
            end)

            itemFrame:SetScript("OnHide", function(self)
                UpdatePositions(viewer)
            end)
        end)
    end
end

---------------------------------------------------------------------------------------------------

function CDM.Load()
    for _, viewer in pairs(cooldownViewers) do
        HookScripts(viewer)

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

        CDM.UpdateAlpha(viewer)
    end
end