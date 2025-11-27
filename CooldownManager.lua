local addonName, CUI = ...

CUI.CDM = {}
local CDM = CUI.CDM
local Util = CUI.Util

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
            frame.Applications.Applications:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 18, "OUTLINE")
        end

        if frame.ChargeCount then
            if viewer:GetName() == "EssentialCooldownViewer" then
                frame.ChargeCount.Current:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 18, "OUTLINE")
            elseif viewer:GetName() == "UtilityCooldownViewer" then
                frame.ChargeCount.Current:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 12, "OUTLINE")
            elseif viewer:GetName() == "BuffIconCooldownViewer" then
                frame.ChargeCount.Current:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 16, "OUTLINE")
            end
        end

        if frame.Cooldown then
            frame.Cooldown:SetSwipeTexture("", 0, 0, 0, 1)
            --frame.Cooldown:SetEdgeTexture()

            local text = frame.Cooldown:GetRegions()

            if viewer:GetName() == "EssentialCooldownViewer" then
                text:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 18, "OUTLINE")
            elseif viewer:GetName() == "UtilityCooldownViewer" then
                text:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 12, "OUTLINE")
            elseif viewer:GetName() == "BuffIconCooldownViewer" then
                text:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 16, "OUTLINE")
            end
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
    local rowLength = viewer.iconLimit

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

    local index = 0
    local lastRow
    local lastRowSize
    local lastRowOffest

    if viewer:GetName() == "BuffIconCooldownViewer" then
        lastRowOffest = ((frameSize + padding) * (#frames - 1)) / 2 + padding
    else
        lastRow = math.ceil(#frames / rowLength)
        lastRowSize = #frames % rowLength
        lastRowOffest = (frameSize + padding) * ((rowLength - lastRowSize) / 2)
    end

    for _, frame in ipairs(frames) do
        local row = math.floor(index/rowLength)

        frame:ClearAllPoints()

        if viewer:GetName() == "BuffIconCooldownViewer" then
            frame:SetPoint("CENTER", viewer, "CENTER", (index*(frameSize+padding))-lastRowOffest, 0)
        elseif row == (lastRow - 1) then
            frame:SetPoint("TOPLEFT", viewer, "TOPLEFT", (index*(frameSize+padding))-(row*rowLength*(frameSize+padding))+lastRowOffest, -(row*(frameSize+padding)))
        else
            frame:SetPoint("TOPLEFT", viewer, "TOPLEFT", (index*(frameSize+padding))-(row*rowLength*(frameSize+padding)), -(row*(frameSize+padding)))
        end
        
        frame:SetSize(frameSize, frameSize)

        index = index + 1
    end
end

local cooldownViewers = {
    EssentialCooldownViewer,
    UtilityCooldownViewer,
    BuffIconCooldownViewer,
}

local function HookScripts(frame)
    frame.CUI_LastUpdate = GetTime() - 123
    local updateInterval = 1

    if frame:GetName() == "BuffIconCooldownViewer" then
        updateInterval = 0.05
    end

    frame:HookScript("OnShow", function(self)
        UpdateStyle(self)
    end)

    frame:HookScript("OnSizeChanged", function(self)
        UpdateStyle(self)
        UpdatePositions(self)
    end)

    frame:HookScript("OnUpdate", function(self)
        local time = GetTime()
        if self.CUI_LastUpdate + updateInterval < time then
            self.CUI_LastUpdate = time
            UpdatePositions(self)
        end
    end)
end

function CDM.Load()
    for _, viewer in pairs(cooldownViewers) do
        HookScripts(viewer)
    end
end