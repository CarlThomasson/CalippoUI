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

local function UpdateAuraFrame(frame, addBorder, index, frameSize, padding, anchorPoint, growDirection)
    -- local xPos
    -- if growDirection == "LEFT" then
    --     xPos = -((index - 1) * (frameSize + padding))
    -- elseif growDirection == "RIGHT" then
    --     xPos = ((index - 1) * (frameSize + padding))
    -- end
    
    -- frame:ClearAllPoints()
    -- frame:SetPoint(anchorPoint, frame:GetParent().healthBar, anchorPoint, xPos, 0)
    -- frame:SetSize(frameSize, frameSize)

    if frame.count then
        frame.count:ClearAllPoints()
        frame.count:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
        frame.count:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 11, "")
    end

    if addBorder then
        if frame.border then
            frame.border:Hide()
        end
        frame.icon:SetTexCoord(.08, .92, .08, .92)
        if not frame.Borders then
            Util.AddBorder(frame, 1, CUI_BACKDROP_DS_2)
        end
    end
end

local function UpdateAllAuraFrames(member)
    for k=1, 6 do 
        UpdateAuraFrame(_G["CompactPartyFrameMember"..member.."Buff"..k], true, k, 18, 2, "TOPRIGHT", "LEFT")
    end

    for k=1, 3 do 
        UpdateAuraFrame(_G["CompactPartyFrameMember"..member.."Debuff"..k], true, k, 18, 2, "BOTTOMLEFT", "RIGHT")
    end

    -- for k=1, 3 do 
    --     UpdateAuraFrame(_G["CompactPartyFrameMember"..member.."DispelDebuff"..k], false, k, 18, 2, "BOTTOMRIGHT", "LEFT")
    -- end
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

        -- frame:RegisterUnitEvent("UNIT_AURA", frame.unit)
        -- frame:HookScript("OnEvent", function(self, event)
        --     if event == "UNIT_AURA" then
        --         UpdateAllAuraFrames(i)
        --     end
        -- end)

        -- EditModeManagerFrame:HookScript("OnHide", function(self)
        --     UpdateAllAuraFrames(i)
        -- end)

        UpdateAllAuraFrames(i)
    end

    -- Raid...
end

---------------------------------------------------------------------------------------------------

function GF.Load()
    HideBlizzard()

    SetupFrames()

    local frame = CreateFrame("Frame", "CUI_GroupFrameUpdater", UIParent)
    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    frame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    frame:SetScript("OnEvent", function(self, event)
        if event == "GROUP_ROSTER_UPDATE" or 
            event == "PLAYER_ROLES_ASSIGNED" then
            UpdateFrames()
        end
    end)

    UpdateFrames()
end