local addonName, CUI = ...

CUI.Database = {}
local Database = CUI.Database

CUI_BACKDROP_DS = {
    edgeFile = "Interface/AddOns/CalippoUI/Media/DropShadowBorder.blp",
    edgeSize = PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1) * 3,
    bgFile = nil
}

CUI_BACKDROP_WHITE = {
    edgeFile = "Interface/AddOns/CalippoUI/Media/white.tga",
    edgeSize = PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1),
    bgFile = nil
}

CUI.SharedMedia = LibStub("LibSharedMedia-3.0")
CUI.SharedMedia:Register("font", "Fira Sans Medium", "Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf")
CUI.SharedMedia:Register("statusbar", "Cell", "Interface/AddOns/CalippoUI/Media/Statusbar.tga")

local defaultFont = "Interface/AddOns/CalippoUI/Fonts/FiraSans-Medium.ttf"
local defaultTexture = "Interface/AddOns/CalippoUI/Media/Statusbar.tga"

local defaults = {
    global = {
        Config = {
            Width = 800,
            Height = 600,

            AnchorPoint = "CENTER",
            AnchorRelativePoint = "CENTER",
            PosX = 0,
            PosY = 0,
        },
    },
    profile = {
        ActionBars = {
            Enabled = true,

            ["**"] = {
                Alpha = 1,
                CombatAlpha = 1,

                ShouldAnchor = false,
                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,

                Padding = 2,

                Keybind = {
                    Enabled = true,
                    Font = defaultFont,
                    Outline = "",
                    Size = 10,
                },
                Cooldown = {
                    Enabled = true,
                    Font = defaultFont,
                    Outline = "",
                    Size = 16,
                },
                Charges = {
                    Enabled = true,
                    Font = defaultFont,
                    Outline = "",
                    Size = 16,
                },
                Macro = {
                    Enabled = true,
                    Font = defaultFont,
                    Outline = "",
                    Size = 10,
                },
            },

            MainActionBar = {

            },
            MultiBarBottomLeft = {

            },
            MultiBarBottomRight = {

            },
            MultiBarLeft = {

            },
            MultiBarRight = {

            },
            MultiBar5 = {

            },
            MultiBar6 = {

            },
            MultiBar7 = {

            },
            PetActionBar = {

            },
            MicroMenu = {

            },
        },
        UnitFrames = {
            Enabled = true,

            ["**"] = {
                Alpha = 1,
                CombatAlpha = 1,

                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",

                Name = {
                    Enabled = true,
                    Font = defaultFont,
                    Outline = "",
                    Size = 16,
                    Width = 130,

                    AnchorPoint = "LEFT",
                    AnchorRelativePoint = "LEFT",
                    PosX = 5,
                    PosY = 2,
                },
                HealthText = {
                    Enabled = true,
                    Font = defaultFont,
                    Outline = "",
                    Size = 16,

                    AnchorPoint = "RIGHT",
                    AnchorRelativePoint = "RIGHT",
                    PosX = -5,
                    PosY = 2,
                },

                Buffs = {
                    Enabled = true,

                    RowLength = 8,
                    Size = 20,
                    DirH = "LEFT",
                    DirV = "UP",
                    Padding = 2,

                    AnchorPoint = "BOTTOMRIGHT",
                    AnchorRelativePoint = "TOPRIGHT",
                    PosX = 0,
                    PosY = 2,
                },
                Debuffs = {
                    Enabled = true,

                    RowLength = 8,
                    Size = 20,
                    DirH = "RIGHT",
                    DirV = "DOWN",
                    Padding = 2,

                    AnchorPoint = "TOPLEFT",
                    AnchorRelativePoint = "BOTTOMLEFT",
                    PosX = 0,
                    PosY = -2,
                },

                HealthBar = {
                    Texture = defaultTexture,
                    TextureBane = defaultTextureName
                },
                PowerBar = {
                    Enabled = true,
                    Height = 5,

                    Texture = defaultTexture,
                },

                CastBar = {
                    Enabled = true,

                    MatchWidth = true,
                    Width = 200,
                    Height = 20,

                    AnchorPoint = "TOPLEFT",
                    AnchorRelativePoint = "BOTTOMLEFT",
                    PosX = 0,
                    PosY = -2,

                    Texture = defaultTexture,

                    Name = {
                        Enabled = true,
                        
                        Font = defaultFont,
                        Outline = "",
                        Size = 12,

                        AnchorPoint = "LEFT",
                        AnchorRelativePoint = "LEFT",
                        PosX = 5,
                        PosY = 0,
                    },
                    Time = {
                        Enabled = true,
                        
                        Font = defaultFont,
                        Outline = "",
                        Size = 12,

                        AnchorPoint = "RIGHT",
                        AnchorRelativePoint = "RIGHT",
                        PosX = -5,
                        PosY = 0,
                    },

                    Color = {
                        ["r"] = 0,
                        ["g"] = 0.8,
                        ["b"] = 0,
                        ["a"] = 1
                    },
                },
            },

            PlayerFrame = {
                Width = 200,
                Height = 50,

                PosX = -300,
                PosY = -200,

                LeaderIcon = {
                    Enabled = true,
                    Size = 16,

                    AnchorPoint = "TOPLEFT",
                    AnchorRelativePoint = "TOPLEFT",
                    PosX = 2,
                    PosY = -1,
                },

                CastBar = {
                    AnchorFrame = "CUI_PlayerFrame"
                },
            },
            TargetFrame = {
                Width = 200,
                Height = 50,

                PosX = 300,
                PosY = -200,

                LeaderIcon = {
                    Enabled = true,
                    Size = 16,

                    AnchorPoint = "TOPLEFT",
                    AnchorRelativePoint = "TOPLEFT",
                    PosX = 2,
                    PosY = -1,
                },

                CastBar = {
                    AnchorFrame = "CUI_TargetFrame"
                },
            },
            FocusFrame = {
                Width = 125,
                Height = 40,

                AnchorFrame = "CUI_TargetFrame",
                AnchorPoint = "TOPLEFT",
                AnchorRelativePoint = "TOPRIGHT",
                PosX = 50,
                PosY = 0,

                Name = {
                    Size = 12,
                    Width = 80,
                },
                HealthText = {
                    Size = 12,
                },

                Buffs = {
                    RowLength = 7,
                    Size = 16,
                },
                Debuffs = {
                    RowLength = 7,
                    Size = 16,
                },

                CastBar = {
                    AnchorFrame = "CUI_FocusFrame"
                },
            },
            PetFrame = {
                Width = 75,
                Height = 20,

                AnchorFrame = "CUI_PlayerFrame",
                AnchorPoint = "BOTTOMLEFT",
                AnchorRelativePoint = "TOPLEFT",
                PosX = 0,
                PosY = 0,

                Name = {
                    Enabled = false,
                    Size = 12,
                    Width = 40,
                },
                HealthText = {
                    Enabled = false,
                    Size = 12,
                },

                PowerBar = {
                    Enabled = false,
                    Height = 5,
                },

                CastBar = {
                    AnchorFrame = "CUI_PetFrame"
                },
            },
            BossFrame = {
                Width = 200,
                Height = 25,

                PosX = 0,
                PosY = 0,
            },
        },
        GroupFrames = {
            Enabled = true,
        },
        PlayerCastBar = {
            Enabled = true,

            Alpha = 1,
            CombatAlpha = 1,

            MatchWidth = false,
            Width = 200,
            Height = 10,

            Color = {
                ["r"] = 0,
                ["g"] = 0.8,
                ["b"] = 0,
                ["a"] = 1
            },

            Texture = defaultTexture,

            AnchorFrame = "UIParent",
            AnchorPoint = "CENTER",
            AnchorRelativePoint = "CENTER",
            PosX = 0,
            PosY = -300,
        },
        PlayerAuras = {
            Enabled = true,

            Alpha = 1,
            CombatAlpha = 1,
        },
        Minimap = {
            Enabled = true,

            Alpha = 1,
            CombatAlpha = 1,
        },
        Chat = {
            Enabled = true,

            Font = defaultFont,
            Outline = "",
        },
        Nameplates = {
            Enabled = true,
        },
        ResourceBar = {
            Enabled = true,

            Alpha = 1,
            CombatAlpha = 1,

            MatchWidth = true,
            Width = 200,
            Height = 15,

            AnchorFrame = "EssentialCooldownViewer",
            AnchorPoint = "CENTER",
            AnchorRelativePoint = "CENTER",
            PosX = 0,
            PosY = 2,

            Text = {
                Enabled = true,
                Font = defaultFont,
                Outline = "",
                Size = 14,

                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,
            },

            Texture = defaultTexture,

            PersonalResourceBar = {
                AnchorFrame = "CUI_PowerBar",
                AnchorPoint = "BOTTOM",
                AnchorRelativePoint = "TOP",
                PosX = 0,
                PosY = 3,
            }
        },
        CooldownManager = {
            Enabled = true,

            ["**"] = {
                Alpha = 1,
                CombatAlpha = 1,
            },

            EssentialCooldownViewer = {
                Cooldown = {
                    Size = 16,
                },
                Charges = {
                    Size = 16,
                },
            },
            UtilityCooldownViewer = {
                Cooldown = {
                    Size = 12,
                },
                Charges = {
                    Size = 12,
                },
            },
            BuffIconCooldownViewer = {
                Cooldown = {
                    Size = 12,
                },
                Charges = {
                    Size = 12,
                },
            },
        },
        AutoWhisper = {
            Enabled = false,
        }
    }
}

function Database.Load()
    CUI.DB = LibStub("AceDB-3.0"):New("CalippoDB", defaults, "Default")
end