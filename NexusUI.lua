-- ================================================================
--  NEXUS UI LIBRARY - EXAMPLE / DEMO SCRIPT
--  Shows all features and proper usage patterns
-- ================================================================

local Nexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/makarmatvij7-svg/NexusUII/main/NexusUI.lua"))()
-- Or if local: local Nexus = require(path.to.NexusUI)

-- Create the main window
local Window = Nexus.CreateWindow({
    Title = "Nexus | Example Hub",
    Size = UDim2.new(0, 700, 0, 500),
    MinSize = Vector2.new(500, 350),
    MaxSize = Vector2.new(900, 600),
    Draggable = true,
    Resizable = true,
    Centered = true,
})

-- ================================================================
-- TAB 1: Combat
-- ================================================================
local CombatTab = Window:AddTab({ Name = "Combat" })

local AimbotSection = CombatTab:AddSection({ Name = "Aimbot" })

local AimbotToggle = AimbotSection:AddToggle({
    Name = "Enabled",
    Default = false,
    Callback = function(Value)
        print("Aimbot:", Value)
        -- Your aimbot logic here
    end,
})

local SilentAimToggle = AimbotSection:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Callback = function(Value)
        print("Silent Aim:", Value)
    end,
})

local FOVSlider = AimbotSection:AddSlider({
    Name = "FOV",
    Min = 10,
    Max = 500,
    Default = 150,
    Increment = 5,
    ValueType = " px",
    Callback = function(Value)
        print("FOV:", Value)
    end,
})

local SmoothnessSlider = AimbotSection:AddSlider({
    Name = "Smoothness",
    Min = 0,
    Max = 1,
    Default = 0.15,
    Increment = 0.01,
    ValueType = "",
    Callback = function(Value)
        print("Smoothness:", Value)
    end,
})

local AimPartDropdown = AimbotSection:AddDropdown({
    Name = "Target Part",
    Values = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Random"},
    Default = "Head",
    Callback = function(Value)
        print("Aim Part:", Value)
    end,
})

local AimKeybind = AimbotSection:AddKeybind({
    Name = "Aim Key",
    Default = Enum.KeyCode.Q,
    Callback = function(Key, Pressed)
        if Pressed then
            print("Aim key pressed:", Key)
        else
            print("Aim key set to:", Key)
        end
    end,
})

local WeaponSection = CombatTab:AddSection({ Name = "Weapon" })

local NoRecoilToggle = WeaponSection:AddToggle({
    Name = "No Recoil",
    Default = false,
    Callback = function(Value)
        print("No Recoil:", Value)
    end,
})

local NoSpreadToggle = WeaponSection:AddToggle({
    Name = "No Spread",
    Default = false,
    Callback = function(Value)
        print("No Spread:", Value)
    end,
})

local RapidFireToggle = WeaponSection:AddToggle({
    Name = "Rapid Fire",
    Default = false,
    Callback = function(Value)
        print("Rapid Fire:", Value)
    end,
})

local FireRateSlider = WeaponSection:AddSlider({
    Name = "Fire Rate Multiplier",
    Min = 1,
    Max = 10,
    Default = 1,
    Increment = 0.5,
    ValueType = "x",
    Callback = function(Value)
        print("Fire Rate:", Value)
    end,
})

-- ================================================================
-- TAB 2: Visuals
-- ================================================================
local VisualsTab = Window:AddTab({ Name = "Visuals" })

local ESPSection = VisualsTab:AddSection({ Name = "ESP" })

local ESPToggle = ESPSection:AddToggle({
    Name = "Enabled",
    Default = true,
    Callback = function(Value)
        print("ESP:", Value)
    end,
})

local BoxESPToggle = ESPSection:AddToggle({
    Name = "Boxes",
    Default = true,
    Callback = function(Value)
        print("Box ESP:", Value)
    end,
})

local NameESPToggle = ESPSection:AddToggle({
    Name = "Names",
    Default = true,
    Callback = function(Value)
        print("Name ESP:", Value)
    end,
})

local DistanceESPToggle = ESPSection:AddToggle({
    Name = "Distance",
    Default = false,
    Callback = function(Value)
        print("Distance ESP:", Value)
    end,
})

local HealthESPToggle = ESPSection:AddToggle({
    Name = "Health Bar",
    Default = true,
    Callback = function(Value)
        print("Health ESP:", Value)
    end,
})

local ESPColor = ESPSection:AddColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(0, 162, 255),
    Callback = function(Color)
        print("ESP Color:", Color)
    end,
})

local ESPSlider = ESPSection:AddSlider({
    Name = "Max Distance",
    Min = 100,
    Max = 5000,
    Default = 1000,
    Increment = 100,
    ValueType = " studs",
    Callback = function(Value)
        print("ESP Distance:", Value)
    end,
})

local WorldSection = VisualsTab:AddSection({ Name = "World" })

local FullBrightToggle = WorldSection:AddToggle({
    Name = "Full Bright",
    Default = false,
    Callback = function(Value)
        print("Full Bright:", Value)
    end,
})

local NoFogToggle = WorldSection:AddToggle({
    Name = "No Fog",
    Default = false,
    Callback = function(Value)
        print("No Fog:", Value)
    end,
})

local TimeOfDaySlider = WorldSection:AddSlider({
    Name = "Time of Day",
    Min = 0,
    Max = 24,
    Default = 12,
    Increment = 0.5,
    ValueType = ":00",
    Callback = function(Value)
        print("Time:", Value)
    end,
})

-- ================================================================
-- TAB 3: Movement
-- ================================================================
local MovementTab = Window:AddTab({ Name = "Movement" })

local SpeedSection = MovementTab:AddSection({ Name = "Speed" })

local SpeedToggle = SpeedSection:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Callback = function(Value)
        print("Speed Hack:", Value)
    end,
})

local SpeedSlider = SpeedSection:AddSlider({
    Name = "Speed Multiplier",
    Min = 1,
    Max = 10,
    Default = 2,
    Increment = 0.5,
    ValueType = "x",
    Callback = function(Value)
        print("Speed:", Value)
    end,
})

local FlySection = MovementTab:AddSection({ Name = "Flight" })

local FlyToggle = FlySection:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(Value)
        print("Fly:", Value)
    end,
})

local FlySpeedSlider = FlySection:AddSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 5,
    ValueType = "",
    Callback = function(Value)
        print("Fly Speed:", Value)
    end,
})

local FlyKeybind = FlySection:AddKeybind({
    Name = "Fly Key",
    Default = Enum.KeyCode.F,
    Callback = function(Key, Pressed)
        print("Fly key:", Key, "Pressed:", Pressed)
    end,
})

local MiscMoveSection = MovementTab:AddSection({ Name = "Misc" })

local InfiniteJumpToggle = MiscMoveSection:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        print("Infinite Jump:", Value)
    end,
})

local NoClipToggle = MiscMoveSection:AddToggle({
    Name = "No Clip",
    Default = false,
    Callback = function(Value)
        print("No Clip:", Value)
    end,
})

-- ================================================================
-- TAB 4: Misc
-- ================================================================
local MiscTab = Window:AddTab({ Name = "Misc" })

local SettingsSection = MiscTab:AddSection({ Name = "Settings" })

local UsernameTextbox = SettingsSection:AddTextbox({
    Name = "Custom Name",
    Default = "",
    Placeholder = "Enter display name...",
    Callback = function(Text)
        print("Custom name:", Text)
    end,
})

local FPSCapSlider = SettingsSection:AddSlider({
    Name = "FPS Cap",
    Min = 30,
    Max = 360,
    Default = 240,
    Increment = 10,
    ValueType = " FPS",
    Callback = function(Value)
        print("FPS Cap:", Value)
    end,
})

local ThemeDropdown = SettingsSection:AddDropdown({
    Name = "Theme",
    Values = {"Dark", "Midnight", "Crimson", "Forest"},
    Default = "Dark",
    Callback = function(Value)
        print("Theme:", Value)
        -- Apply theme logic here
    end,
})

local ConfigSection = MiscTab:AddSection({ Name = "Configuration" })

ConfigSection:AddLabel({
    Text = "Manage your configuration files below.",
})

ConfigSection:AddDivider()

local SaveConfigBtn = ConfigSection:AddButton({
    Name = "Save Configuration",
    Callback = function()
        Window:Notify({
            Title = "Config Saved",
            Text = "Your settings have been saved successfully.",
            Type = "Success",
            Duration = 3,
        })
    end,
})

local LoadConfigBtn = ConfigSection:AddButton({
    Name = "Load Configuration",
    Callback = function()
        Window:Notify({
            Title = "Config Loaded",
            Text = "Your settings have been loaded successfully.",
            Type = "Info",
            Duration = 3,
        })
    end,
})

local ResetConfigBtn = ConfigSection:AddButton({
    Name = "Reset to Default",
    Callback = function()
        Window:Notify({
            Title = "Reset Complete",
            Text = "All settings restored to defaults.",
            Type = "Warning",
            Duration = 3,
        })
    end,
})

-- ================================================================
-- NOTIFICATION DEMO
-- ================================================================
task.delay(2, function()
    Window:Notify({
        Title = "Nexus UI Loaded",
        Text = "Welcome! Press K to toggle UI visibility. All features are ready.",
        Type = "Success",
        Duration = 5,
    })
end)

-- ================================================================
-- KEYBIND TO TOGGLE UI
-- ================================================================
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        Window:SetVisible(not Window.Visible)
    end
end)

-- ================================================================
-- VALUE GETTERS (for external scripts)
-- ================================================================
--[[
    Access any element's value:
    AimbotToggle:Get()        -- returns boolean
    FOVSlider:Get()           -- returns number
    AimPartDropdown:Get()     -- returns string
    AimKeybind:Get()          -- returns Enum.KeyCode or "None"
    ESPColor:Get()            -- returns Color3

    Set values programmatically:
    AimbotToggle:Set(true)
    FOVSlider:Set(200)
    AimPartDropdown:Set("Torso")
    ESPColor:Set(Color3.fromRGB(255, 0, 0))
--]]

print("Nexus UI Example loaded successfully!")
