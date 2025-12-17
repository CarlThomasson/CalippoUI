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

            MainActionBar = {
                Alpha = 1,
                CombatAlpha = 1,

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

                ShouldAnchor = false,
                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,
                
            },
            MultiBarBottomLeft = {
                Alpha = 1,
                CombatAlpha = 1,

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

                ShouldAnchor = false,
                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,
            },
            MultiBarBottomRight = {
                Alpha = 1,
                CombatAlpha = 1,

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

                ShouldAnchor = false,
                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,
            },
            MultiBarLeft = {
                Alpha = 1,
                CombatAlpha = 1,

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

                ShouldAnchor = false,
                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,
            },
            MultiBarRight = {
                Alpha = 1,
                CombatAlpha = 1,

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

                ShouldAnchor = false,
                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,
            },
            MultiBar5 = {
                Alpha = 1,
                CombatAlpha = 1,

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

                ShouldAnchor = false,
                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,
            },
            MultiBar6 = {
                Alpha = 1,
                CombatAlpha = 1,

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

                ShouldAnchor = false,
                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,
            },
            MultiBar7 = {
                Alpha = 1,
                CombatAlpha = 1,

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

                ShouldAnchor = false,
                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,
            },
            PetActionBar = {
                Alpha = 1,
                CombatAlpha = 1,

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

                ShouldAnchor = false,
                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,
            },
            MicroMenu = {
                Alpha = 1,
                CombatAlpha = 1,

                ShouldAnchor = false,
                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,
            },
        },
        UnitFrames = {
            Enabled = true,

            PlayerFrame = {
                Alpha = 1,
                CombatAlpha = 1,

                Width = 200,
                Height = 50,

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

                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = -200,
                PosY = 0,
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
            },
            PetFrame = {
                Alpha = 1,
                CombatAlpha = 1,

                Width = 200,
                Height = 25,

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

                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,
            },
            BossFrame = {
                Alpha = 1,
                CombatAlpha = 1,

                Width = 200,
                Height = 25,

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

                AnchorFrame = "UIParent",
                AnchorPoint = "CENTER",
                AnchorRelativePoint = "CENTER",
                PosX = 0,
                PosY = 0,
            },
        },
        GroupFrames = {
            Enabled = true,
        },
        PlayerCastBar = {
            Enabled = true,

            Width = 200,
            Height = 20,

            Color = {0, 1, 0, 1},

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
            Height = 25,

            Text = {
                Size = 16,
            },

            MatchWidth = true,

            AnchorFrame = "EssentialCooldownViewer",
            AnchorPoint = "CENTER",
            AnchorRelativePoint = "CENTER",
            PosX = 0,
            PosY = 0,
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
        }
    }
}

function Database.Load()
    CUI.DB = LibStub("AceDB-3.0"):New("CalippoDB", defaults, "Default")
end
    
