local addonName, CUI = ...

CUI.GF = {}
local GF = CUI.GF
local Util = CUI.Util
local Hide = CUI.Hide

---------------------------------------------------------------------------------------------------

local function HideBlizzard()
    Hide.HideBlizzardRaidManager()
    Hide.HideFrame(CompactPartyFrameTitle)
    
    for i=1, 5 do
        local frame = _G["CompactPartyFrameMember"..i]
        Hide.HideFrame(frame.name)
        Hide.HideFrame(frame.roleIcon)
        -- Hide.HideFrame(frame.background)
        -- Hide.HideFrame(frame.healthBar)
        -- Hide.HideFrame(frame.MyHealAbsorb)
    end
end

---------------------------------------------------------------------------------------------------

local function UpdateFrames()
    local numMem = GetNumGroupMembers()
    if numMem == 0 then return end

    if IsInGroup() and not IsInRaid() then
        for i=1, numMem do
            local frame = _G["CompactPartyFrameMember"..i]

            frame.healthBar.UnitName:SetText(UnitName(frame.unit))
            
            local role = UnitGroupRolesAssigned(frame.unit)
            if role == "TANK" then
                frame.healthBar.Role:SetTexture("Interface/AddOns/CalippoUI/Media/TANK.tga")
                frame.healthBar.Role:Show()
            elseif role == "HEALER" then
                frame.healthBar.Role:SetTexture("Interface/AddOns/CalippoUI/Media/HEALER.tga")
                frame.healthBar.Role:Show()
            else
                frame.healthBar.Role:Hide()
            end
        end
    else
        -- Raid...
    end
end

local function SetupAuraFrame(parentFrame, frame, script, addBorder, index, frameSize, padding, anchorPoint, growDirection)
    frame:HookScript(script, function(self)
        self:ClearAllPoints()
        local xPos
        if growDirection == "LEFT" then
            xPos = -((index - 1) * (frameSize + padding))
        elseif growDirection == "RIGHT" then
            xPos = ((index - 1) * (frameSize + padding))
        end

        self:SetPoint(anchorPoint, parentFrame.healthBar, anchorPoint, xPos, 0)
        self:SetSize(frameSize, frameSize)
    end)

    frame:ClearAllPoints()
    local xPos
    if growDirection == "LEFT" then
        xPos = -((index - 1) * (frameSize + padding))
    elseif growDirection == "RIGHT" then
        xPos = ((index - 1) * (frameSize + padding))
    end

    frame:SetPoint(anchorPoint, parentFrame.healthBar, anchorPoint, xPos, 0)
    frame:SetSize(frameSize, frameSize)

    if addBorder then
        frame.icon:SetTexCoord(.08, .92, .08, .92)
        Util.AddBackdrop(frame, 1, CUI_BACKDROP_DS_2)
    end
end

local function SetupFrames()
    for i=1, 5 do
        local frame = _G["CompactPartyFrameMember"..i]

        frame.healthBar:SetStatusBarTexture("Interface/AddOns/CalippoUI/Media/Statusbar.tga")

        local unitName = frame.healthBar:CreateFontString(nil, "OVERLAY")
        unitName:SetParentKey("UnitName")
        unitName:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 3, -3)
        unitName:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 11, "")

        local unitRole = frame.healthBar:CreateTexture(nil, "OVERLAY")
        unitRole:SetParentKey("Role")
        unitRole:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 4, -15)
        unitRole:SetSize(10, 10)

        for k=1, 6 do 
            SetupAuraFrame(frame, _G["CompactPartyFrameMember"..i.."Buff"..k], "OnShow", true, k, 18, 2, "TOPRIGHT", "LEFT")
        end

        for k=1, 3 do 
            -- TODO : Försök att inte använda OnUpdate
            SetupAuraFrame(frame, _G["CompactPartyFrameMember"..i.."Debuff"..k], "OnUpdate", true, k, 18, 2, "BOTTOMLEFT", "RIGHT")
        end

        for k=1, 3 do 
            SetupAuraFrame(frame, _G["CompactPartyFrameMember"..i.."DispelDebuff"..k], "OnShow", false, k, 18, 2, "BOTTOMRIGHT", "LEFT")
        end
    end

    -- Raid...
end

---------------------------------------------------------------------------------------------------

function GF.Load()
    HideBlizzard()

    local frame = CreateFrame("Frame", "CUI_GroupFrameUpdater", UIParent)
    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    frame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    frame:RegisterEvent("GROUP_JOINED")
    frame:RegisterEvent("GROUP_LEFT")
    frame:RegisterEvent("GROUP_FORMED")
    frame:SetScript("OnEvent", function(self, event)
        if event == "GROUP_ROSTER_UPDATE" or 
            event == "PLAYER_ROLES_ASSIGNED" or 
            event == "GROUP_JOINED" or 
            event == "GROUP_LEFT" or 
            event == "GROUP_FORMED" then
            UpdateFrames()
        end
    end)

    SetupFrames()
    UpdateFrames()
end