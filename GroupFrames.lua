local addonName, CUI = ...

CUI.GF = {}
local GF = CUI.GF
local Util = CUI.Util
local Hide = CUI.Hide

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
        -- Raid
    end
end

local function SetupFrames()
    for i=1, 5 do
        local frame = _G["CompactPartyFrameMember"..i]

        local unitName = frame.healthBar:CreateFontString(nil, "OVERLAY")
        unitName:SetParentKey("UnitName")
        unitName:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 3, -3)
        unitName:SetFont("Interface\\AddOns\\CalippoUI\\Fonts\\FiraSans-Medium.ttf", 12, "")

        local unitRole = frame.healthBar:CreateTexture(nil, "OVERLAY")
        unitRole:SetParentKey("Role")
        unitRole:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 4, -15)
        unitRole:SetSize(10, 10)

        for k=1, 6 do 
            local buffFrame = _G["CompactPartyFrameMember"..i.."Buff"..k]
            local frameSize = 18
            local padding = 2
            buffFrame:HookScript("OnUpdate", function(self)
                buffFrame:ClearAllPoints()
                buffFrame:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", -((k - 1) * (frameSize + padding)), 0)
                buffFrame:SetSize(frameSize, frameSize)
            end)
            buffFrame.icon:SetTexCoord(.08, .92, .08, .92)
            Util.AddBackdrop(buffFrame, 1, CUI_BACKDROP_DS_2)
        end

        for k=1, 3 do 
            local debuffFrame = _G["CompactPartyFrameMember"..i.."Debuff"..k]
            local frameSize = 18
            local padding = 2
            debuffFrame:HookScript("OnUpdate", function(self)
                debuffFrame:ClearAllPoints()
                debuffFrame:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", ((k - 1) * (frameSize + padding)), 0)
                debuffFrame:SetSize(frameSize, frameSize)
            end)
            debuffFrame.icon:SetTexCoord(.08, .92, .08, .92)
            Util.AddBackdrop(debuffFrame, 1, CUI_BACKDROP_DS_2)
        end

        for k=1, 3 do 
            local dispelDebuffFrame = _G["CompactPartyFrameMember"..i.."DispelDebuff"..k]
            local frameSize = 18
            local padding = 2
            dispelDebuffFrame:HookScript("OnUpdate", function(self)
                dispelDebuffFrame:ClearAllPoints()
                dispelDebuffFrame:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -((k - 1) * (frameSize + padding)), 0)
                dispelDebuffFrame:SetSize(frameSize, frameSize)
            end)
            dispelDebuffFrame.icon:SetTexCoord(.08, .92, .08, .92)
            Util.AddBackdrop(dispelDebuffFrame, 1, CUI_BACKDROP_DS_2)
        end
    end
end

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