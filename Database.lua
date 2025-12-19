local addonName, CUI = ...

CUI.Database = {}
local Database = CUI.Database

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

                Padding = 0,

                Keybind = {
                    Enabled = true,
                    Size = 10,
                },
                Cooldown = {
                    Enabled = true,
                    Size = 16,
                },
                Charges = {
                    Enabled = true,
                    Size = 16,
                },
                Macro = {
                    Enabled = true,
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

            PlayerFrame = {
                Alpha = 1,
                CombatAlpha = 1,

                Width = 200,
                Height = 50,

                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = -200,
                PosY = 0,

                Name = {
                    Enabled = true,
                    Size = 16,
                    Width = 100,

                    AnchorPoint = "LEFT",
                    AnchorRelativePoint = "LEFT",
                    PosX = 0,
                    PosY = 0,
                },
                HealthText = {
                    Enabled = true,
                    Size = 16,

                    AnchorPoint = "RIGHT",
                    AnchorRelativePoint = "RIGHT",
                    PosX = 0,
                    PosY = 0,
                },

                LeaderIcon = {
                    Enabled = true,
                    Size = 16,

                    AnchorPoint = "TOPLEFT",
                    AnchorRelativePoint = "TOPLEFT",
                    PosX = 0,
                    PosY = 0,   
                },

                PowerBar = {
                    Enabled = true,
                    Height = 5,
                },
            },
            TargetFrame = {
                Alpha = 1,
                CombatAlpha = 1,

                Width = 200,
                Height = 50,

                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 200,
                PosY = 0,

                Name = {
                    Enabled = true,
                    Size = 16,
                    Width = 100,

                    AnchorPoint = "LEFT",
                    AnchorRelativePoint = "LEFT",
                    PosX = 5,
                    PosY = 0,

                },
                HealthText = {
                    Enabled = true,
                    Size = 16,

                    AnchorPoint = "RIGHT",
                    AnchorRelativePoint = "RIGHT",
                    PosX = -5,
                    PosY = 0,
                },

                LeaderIcon = {
                    Enabled = true,
                    Size = 16,

                    AnchorPoint = "TOPLEFT",
                    AnchorRelativePoint = "TOPLEFT",
                    PosX = 0,
                    PosY = 0,   
                },

                Buffs = {
                    Enabled = true,

                    RowLength = 6,
                    Size = 20,
                    DirH = "LEFT",
                    DirV = "UP",
                    Padding = 2,

                    AnchorFrame = "UIParent",
                    AnchorPoint = "CENTER",
                    AnchorRelativePoint = "CENTER",
                    PosX = 0,
                    PosY = 0,
                },
                Debuffs = {
                    Enabled = true,

                    RowLength = 6,
                    Size = 20,
                    DirH = "LEFT",
                    DirV = "UP",
                    Padding = 2,

                    AnchorFrame = "UIParent",
                    AnchorPoint = "CENTER",
                    AnchorRelativePoint = "CENTER",
                    PosX = 0,
                    PosY = 0,
                },

                PowerBar = {
                    Enabled = true,
                    Height = 5,
                },
            },
            FocusFrame = {
                Alpha = 1,
                CombatAlpha = 1,

                Width = 150,
                Height = 40,

                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 200,
                PosY = -100,

                Name = {
                    Enabled = true,
                    Size = 12,
                    Width = 100,

                    AnchorPoint = "LEFT",
                    AnchorRelativePoint = "LEFT",
                    PosX = 5,
                    PosY = 0,
                },
                HealthText = {
                    Enabled = true,
                    Size = 12,

                    AnchorPoint = "RIGHT",
                    AnchorRelativePoint = "RIGHT",
                    PosX = -5,
                    PosY = 0,
                },

                LeaderIcon = {
                    Enabled = true,
                    Size = 16,

                    AnchorPoint = "TOPLEFT",
                    AnchorRelativePoint = "TOPLEFT",
                    PosX = 0,
                    PosY = 0,   
                },

                Buffs = {
                    Enabled = true,

                    RowLength = 6,
                    Size = 20,
                    DirH = "LEFT",
                    DirV = "UP",
                    Padding = 2,

                    AnchorFrame = "UIParent",
                    AnchorPoint = "CENTER",
                    AnchorRelativePoint = "CENTER",
                    PosX = 0,
                    PosY = 0,
                },
                Debuffs = {
                    Enabled = true,

                    RowLength = 6,
                    Size = 20,
                    DirH = "LEFT",
                    DirV = "UP",
                    Padding = 2,

                    AnchorFrame = "UIParent",
                    AnchorPoint = "CENTER",
                    AnchorRelativePoint = "CENTER",
                    PosX = 0,
                    PosY = 0,
                },

                PowerBar = {
                    Enabled = true,
                    Height = 5,
                },
            },
            PetFrame = {
                Alpha = 1,
                CombatAlpha = 1,

                Width = 200,
                Height = 25,

                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,

                Name = {
                    Enabled = true,
                    Size = 12,
                    Width = 100,

                    AnchorPoint = "LEFT",
                    AnchorRelativePoint = "LEFT",
                    PosX = 5,
                    PosY = 0,
                },
                HealthText = {
                    Enabled = true,
                    Size = 12,

                    AnchorPoint = "RIGHT",
                    AnchorRelativePoint = "RIGHT",
                    PosX = -5,
                    PosY = 0,
                },

                PowerBar = {
                    Enabled = true,
                    Height = 5,
                },
            },
            BossFrame = {
                Alpha = 1,
                CombatAlpha = 1,

                Width = 200,
                Height = 25,

                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,

                Name = {
                    Enabled = true,
                    Size = 16,
                    Width = 100,

                    AnchorPoint = "LEFT",
                    AnchorRelativePoint = "LEFT",
                    PosX = 0,
                    PosY = 0,
                },
                HealthText = {
                    Enabled = true,
                    Size = 16,

                    AnchorPoint = "RIGHT",
                    AnchorRelativePoint = "RIGHT",
                    PosX = 0,
                    PosY = 0,
                },

                PowerBar = {
                    Enabled = true,
                    Height = 5,
                },
            },
        },
        GroupFrames = {
            Enabled = true,
        },
        PlayerCastBar = {
            Enabled = true,

            Alpha = 1,
            CombatAlpha = 1,

            Width = 200,
            Height = 20,

            Color = {
                ["r"] = 0, 
                ["g"] = 0.8, 
                ["b"] = 0, 
                ["a"] = 1
            },
            
            MatchWidth = false,

            AnchorFrame = "UIParent",
            AnchorPoint = "CENTER",
            AnchorRelativePoint = "CENTER",
            PosX = 0,
            PosY = 0,
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
        },
        Nameplates = {
            Enabled = true,
        },
        ResourceBar = {
            Enabled = true,

            Alpha = 1,
            CombatAlpha = 1,

            Width = 200,
            Height = 12,

            Text = {
                Enabled = true,
                Size = 10,

                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,
            },

            MatchWidth = true,

            AnchorFrame = "EssentialCooldownViewer",
            AnchorPoint = "CENTER",
            AnchorRelativePoint = "CENTER",
            PosX = 0,
            PosY = 0,

            PersonalResourceBar = {
                AnchorFrame = "CUI_PowerBar",
                AnchorPoint = "BOTTOM",
                AnchorRelativePoint = "TOP",
                PosX = 0,
                PosY = 2,
            }
        },
        CooldownManager = {
            Enabled = true,

            EssentialCooldownViewer = {
                Alpha = 1,
                CombatAlpha = 1,

                Cooldown = {
                    Size = 16,
                },
                Charges = {
                    Size = 16,
                },
            },
            UtilityCooldownViewer = {
                Alpha = 1,
                CombatAlpha = 1,

                Cooldown = {
                    Size = 12,
                },
                Charges = {
                    Size = 12,
                },
            },
            BuffIconCooldownViewer = {
                Alpha = 1,
                CombatAlpha = 1,

                Cooldown = {
                    Size = 12,
                },
                Charges = {
                    Size = 12,
                },
            },
        },
    }
}

function Database.Load()
    CUI.DB = LibStub("AceDB-3.0"):New("CalippoDB", defaults, "Default")
end
    
