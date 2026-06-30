-- ================================================================
--  NEXUS UI LIBRARY v1.0
--  Production-ready Roblox UI framework
--  Compatible: Real Executor, Xeno, Solara, Potassium, Volt, Velocity
--  Features: Window system, Tabs, Sections, Toggles, Sliders,
--            Dropdowns, Buttons, Keybinds, ColorPickers, Notifications
-- ================================================================

local Nexus = {}
Nexus.__index = Nexus

-- --- Services ---
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- --- Configuration ---
local Config = {
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontCode = Enum.Font.Code,

    Colors = {
        Background = Color3.fromRGB(18, 18, 22),
        BackgroundSecondary = Color3.fromRGB(25, 25, 30),
        BackgroundTertiary = Color3.fromRGB(32, 32, 38),
        Accent = Color3.fromRGB(0, 162, 255),
        AccentDark = Color3.fromRGB(0, 130, 204),
        Text = Color3.fromRGB(240, 240, 240),
        TextDark = Color3.fromRGB(160, 160, 170),
        TextDisabled = Color3.fromRGB(100, 100, 110),
        Border = Color3.fromRGB(45, 45, 55),
        Success = Color3.fromRGB(80, 200, 120),
        Error = Color3.fromRGB(230, 80, 80),
        Warning = Color3.fromRGB(230, 180, 60),
        ToggleOn = Color3.fromRGB(0, 162, 255),
        ToggleOff = Color3.fromRGB(55, 55, 65),
        SliderFill = Color3.fromRGB(0, 162, 255),
        SliderBackground = Color3.fromRGB(45, 45, 55),
    },

    Sizes = {
        WindowMinWidth = 500,
        WindowMinHeight = 350,
        WindowMaxWidth = 900,
        WindowMaxHeight = 600,
        TitleBarHeight = 38,
        TabHeight = 36,
        SectionPadding = 12,
        ElementHeight = 32,
        ElementSpacing = 8,
        CornerRadius = 6,
        ShadowTransparency = 0.6,
    },

    Animations = {
        TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        FastTween = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        SpringTween = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    }
}

-- --- Utility Functions ---
local Utility = {}

function Utility.Create(className, properties)
    local instance = Instance.new(className)
    if properties then
        for prop, value in pairs(properties) do
            if prop == "Parent" then
                -- Delay parent assignment
            else
                instance[prop] = value
            end
        end
    end
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility.Tween(instance, properties, tweenInfo)
    tweenInfo = tweenInfo or Config.Animations.TweenInfo
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utility.Round(num, decimals)
    decimals = decimals or 0
    local mult = 10 ^ decimals
    return math.floor(num * mult + 0.5) / mult
end

function Utility.Clamp(num, min, max)
    return math.max(min, math.min(max, num))
end

function Utility.FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

function Utility.GetTextBounds(text, font, textSize, maxWidth)
    local params = Instance.new("GetTextBoundsParams")
    params.Text = text
    params.Font = font
    params.Size = textSize
    params.Width = maxWidth or math.huge
    local bounds = TextService:GetTextBoundsAsync(params)
    params:Destroy()
    return bounds
end

function Utility.MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragStart = nil
    local startPos = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

function Utility.MakeResizable(frame, handle, minSize, maxSize)
    minSize = minSize or Vector2.new(Config.Sizes.WindowMinWidth, Config.Sizes.WindowMinHeight)
    maxSize = maxSize or Vector2.new(Config.Sizes.WindowMaxWidth, Config.Sizes.WindowMaxHeight)

    local resizing = false
    local resizeStart = nil
    local startSize = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = frame.AbsoluteSize
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newWidth = Utility.Clamp(startSize.X + delta.X, minSize.X, maxSize.X)
            local newHeight = Utility.Clamp(startSize.Y + delta.Y, minSize.Y, maxSize.Y)
            frame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
end

-- --- Notification System ---
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem
NotificationSystem.ActiveNotifications = {}
NotificationSystem.MaxNotifications = 5

function NotificationSystem.new()
    local self = setmetatable({}, NotificationSystem)

    local parentTarget = nil
    if RunService:IsStudio() then
        parentTarget = LocalPlayer:WaitForChild("PlayerGui")
    elseif typeof(gethui) == "function" then
        parentTarget = gethui()
    elseif syn and syn.protect_gui then
        parentTarget = game:GetService("CoreGui")
    else
        parentTarget = LocalPlayer:WaitForChild("PlayerGui")
    end

    self.Container = Utility.Create("ScreenGui", {
        Name = "NexusNotifications",
        DisplayOrder = 999,
        ResetOnSpawn = false,
        Parent = parentTarget,
    })

    if syn and syn.protect_gui then
        syn.protect_gui(self.Container)
    end

    self.NotificationFrame = Utility.Create("Frame", {
        Name = "Container",
        Size = UDim2.new(0, 320, 1, 0),
        Position = UDim2.new(1, -340, 0, 20),
        BackgroundTransparency = 1,
        Parent = self.Container,
    })

    self.NotificationList = Utility.Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.NotificationFrame,
    })

    return self
end

function NotificationSystem:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local text = options.Text or ""
    local duration = options.Duration or 3
    local notifType = options.Type or "Info"

    if #self.ActiveNotifications >= self.MaxNotifications then
        local oldest = table.remove(self.ActiveNotifications, 1)
        if oldest and oldest.Destroy then
            oldest:Destroy()
        end
    end

    local color = Config.Colors.Accent
    if notifType == "Success" then color = Config.Colors.Success
    elseif notifType == "Warning" then color = Config.Colors.Warning
    elseif notifType == "Error" then color = Config.Colors.Error end

    local notifFrame = Utility.Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(0, 300, 0, 0),
        BackgroundColor3 = Config.Colors.BackgroundSecondary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.NotificationFrame,
    })

    Utility.Create("UICorner", {
        CornerRadius = UDim.new(0, Config.Sizes.CornerRadius),
        Parent = notifFrame,
    })

    Utility.Create("UIStroke", {
        Color = color,
        Thickness = 1.5,
        Transparency = 0.6,
        Parent = notifFrame,
    })

    local accentBar = Utility.Create("Frame", {
        Name = "AccentBar",
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = notifFrame,
    })

    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Config.Colors.Text,
        TextSize = 14,
        Font = Config.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notifFrame,
    })

    local textLabel = Utility.Create("TextLabel", {
        Name = "Text",
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 12, 0, 30),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Config.Colors.TextDark,
        TextSize = 12,
        Font = Config.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = notifFrame,
    })

    local textBounds = Utility.GetTextBounds(text, Config.Font, 12, 276)
    local notifHeight = math.max(70, 42 + textBounds.Y)

    local closeButton = Utility.Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -24, 0, 6),
        BackgroundTransparency = 1,
        Text = "x",
        TextColor3 = Config.Colors.TextDark,
        TextSize = 18,
        Font = Config.FontBold,
        Parent = notifFrame,
    })

    local progressBar = Utility.Create("Frame", {
        Name = "Progress",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = notifFrame,
    })

    notifFrame.Size = UDim2.new(0, 300, 0, 0)
    Utility.Tween(notifFrame, {Size = UDim2.new(0, 300, 0, notifHeight)}, Config.Animations.SpringTween)

    local notifObj = {
        Frame = notifFrame,
        Destroy = function()
            Utility.Tween(notifFrame, {Size = UDim2.new(0, 300, 0, 0)}, Config.Animations.FastTween)
            task.wait(0.15)
            if notifFrame and notifFrame.Parent then
                notifFrame:Destroy()
            end
            for i, n in ipairs(self.ActiveNotifications) do
                if n == notifObj then
                    table.remove(self.ActiveNotifications, i)
                    break
                end
            end
        end
    }

    table.insert(self.ActiveNotifications, notifObj)

    closeButton.MouseButton1Click:Connect(function()
        notifObj:Destroy()
    end)

    Utility.Tween(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, TweenInfo.new(duration, Enum.EasingStyle.Linear))

    task.delay(duration, function()
        if notifFrame and notifFrame.Parent then
            notifObj:Destroy()
        end
    end)

    return notifObj
end

-- --- Window System ---
local Window = {}
Window.__index = Window

function Window.new(options)
    options = options or {}
    local self = setmetatable({}, Window)

    self.Title = options.Title or "Nexus UI"
    self.Size = options.Size or UDim2.new(0, 650, 0, 450)
    self.MinSize = options.MinSize or Vector2.new(Config.Sizes.WindowMinWidth, Config.Sizes.WindowMinHeight)
    self.MaxSize = options.MaxSize or Vector2.new(Config.Sizes.WindowMaxWidth, Config.Sizes.WindowMaxHeight)
    self.Theme = options.Theme or "Dark"
    self.Draggable = options.Draggable ~= false
    self.Resizable = options.Resizable ~= false
    self.Centered = options.Centered ~= false

    self.Tabs = {}
    self.ActiveTab = nil
    self.Visible = true
    self.Minimized = false

    local parentTarget = nil
    if RunService:IsStudio() then
        parentTarget = LocalPlayer:WaitForChild("PlayerGui")
    elseif typeof(gethui) == "function" then
        parentTarget = gethui()
    elseif syn and syn.protect_gui then
        parentTarget = game:GetService("CoreGui")
    else
        parentTarget = LocalPlayer:WaitForChild("PlayerGui")
    end

    self.Gui = Utility.Create("ScreenGui", {
        Name = "NexusUI_" .. HttpService:GenerateGUID(false),
        DisplayOrder = 100,
        ResetOnSpawn = false,
        Parent = parentTarget,
    })

    if syn and syn.protect_gui then
        syn.protect_gui(self.Gui)
    end

    self.Shadow = Utility.Create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = Config.Sizes.ShadowTransparency,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        Parent = self.Gui,
    })

    self.MainFrame = Utility.Create("Frame", {
        Name = "Main",
        Size = self.Size,
        Position = self.Centered and UDim2.new(0.5, -self.Size.X.Offset / 2, 0.5, -self.Size.Y.Offset / 2) or UDim2.new(0, 100, 0, 100),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 0,
        Parent = self.Gui,
    })

    Utility.Create("UICorner", {
        CornerRadius = UDim.new(0, Config.Sizes.CornerRadius),
        Parent = self.MainFrame,
    })

    self.TitleBar = Utility.Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, Config.Sizes.TitleBarHeight),
        BackgroundColor3 = Config.Colors.BackgroundSecondary,
        BorderSizePixel = 0,
        Parent = self.MainFrame,
    })

    Utility.Create("UICorner", {
        CornerRadius = UDim.new(0, Config.Sizes.CornerRadius),
        Parent = self.TitleBar,
    })

    local titleBarFix = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, Config.Sizes.CornerRadius),
        Position = UDim2.new(0, 0, 1, -Config.Sizes.CornerRadius),
        BackgroundColor3 = Config.Colors.BackgroundSecondary,
        BorderSizePixel = 0,
        Parent = self.TitleBar,
    })

    self.TitleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = Config.Colors.Text,
        TextSize = 14,
        Font = Config.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar,
    })

    self.MinimizeBtn = Utility.Create("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "-",
        TextColor3 = Config.Colors.TextDark,
        TextSize = 18,
        Font = Config.FontBold,
        Parent = self.TitleBar,
    })

    self.CloseBtn = Utility.Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "x",
        TextColor3 = Config.Colors.Error,
        TextSize = 18,
        Font = Config.FontBold,
        Parent = self.TitleBar,
    })

    self.TabBar = Utility.Create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, Config.Sizes.TabHeight),
        Position = UDim2.new(0, 0, 0, Config.Sizes.TitleBarHeight),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 0,
        Parent = self.MainFrame,
    })

    self.TabList = Utility.Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.TabBar,
    })

    self.TabPadding = Utility.Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        Parent = self.TabBar,
    })

    self.ContentArea = Utility.Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -(Config.Sizes.TitleBarHeight + Config.Sizes.TabHeight)),
        Position = UDim2.new(0, 0, 0, Config.Sizes.TitleBarHeight + Config.Sizes.TabHeight),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = self.MainFrame,
    })

    if self.Resizable then
        self.ResizeHandle = Utility.Create("TextButton", {
            Name = "ResizeHandle",
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(1, -16, 1, -16),
            BackgroundTransparency = 1,
            Text = "",
            Parent = self.MainFrame,
        })

        local resizeIcon = Utility.Create("ImageLabel", {
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(1, -12, 1, -12),
            BackgroundTransparency = 1,
            Image = "rbxassetid://6764432408",
            ImageColor3 = Config.Colors.TextDark,
            ImageTransparency = 0.5,
            Parent = self.ResizeHandle,
        })

        Utility.MakeResizable(self.MainFrame, self.ResizeHandle, self.MinSize, self.MaxSize)
    end

    if self.Draggable then
        Utility.MakeDraggable(self.MainFrame, self.TitleBar)
    end

    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    self.MinimizeBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)

    self.Notifications = NotificationSystem.new()
    self:SetupMobileToggle()

    return self
end

function Window:SetupMobileToggle()
    local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
    if not isMobile then return end

    self.MobileToggle = Utility.Create("TextButton", {
        Name = "MobileToggle",
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = Config.Colors.Accent,
        Text = "=",
        TextColor3 = Config.Colors.Text,
        TextSize = 24,
        Font = Config.FontBold,
        Parent = self.Gui,
    })

    Utility.Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = self.MobileToggle,
    })

    Utility.Create("UIStroke", {
        Color = Config.Colors.AccentDark,
        Thickness = 2,
        Parent = self.MobileToggle,
    })

    self.MobileToggle.MouseButton1Click:Connect(function()
        self:ToggleVisibility()
    end)
end

function Window:ToggleMinimize()
    self.Minimized = not self.Minimized

    if self.Minimized then
        self.ContentArea.Visible = false
        self.TabBar.Visible = false
        Utility.Tween(self.MainFrame, {
            Size = UDim2.new(0, self.MainFrame.AbsoluteSize.X, 0, Config.Sizes.TitleBarHeight)
        })
    else
        Utility.Tween(self.MainFrame, {Size = self.Size})
        task.delay(0.25, function()
            self.ContentArea.Visible = true
            self.TabBar.Visible = true
        end)
    end
end

function Window:ToggleVisibility()
    self.Visible = not self.Visible
    self.MainFrame.Visible = self.Visible
    self.Shadow.Visible = self.Visible
end

function Window:AddTab(options)
    options = options or {}
    local tab = {
        Name = options.Name or "Tab",
        Icon = options.Icon,
        Sections = {},
        Window = self,
    }

    tab.Button = Utility.Create("TextButton", {
        Name = tab.Name,
        Size = UDim2.new(0, 0, 1, -4),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 0,
        Text = "",
        Parent = self.TabBar,
    })

    Utility.Create("UIPadding", {
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        Parent = tab.Button,
    })

    tab.Label = Utility.Create("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = tab.Name,
        TextColor3 = Config.Colors.TextDark,
        TextSize = 13,
        Font = Config.Font,
        Parent = tab.Button,
    })

    tab.Indicator = Utility.Create("Frame", {
        Name = "Indicator",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Config.Colors.Accent,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Parent = tab.Button,
    })

    tab.Content = Utility.Create("ScrollingFrame", {
        Name = tab.Name .. "Content",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Config.Colors.Accent,
        Visible = false,
        Parent = self.ContentArea,
    })

    tab.ContentList = Utility.Create("UIListLayout", {
        Padding = UDim.new(0, Config.Sizes.ElementSpacing),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tab.Content,
    })

    tab.ContentPadding = Utility.Create("UIPadding", {
        PaddingTop = UDim.new(0, Config.Sizes.SectionPadding),
        PaddingBottom = UDim.new(0, Config.Sizes.SectionPadding),
        PaddingLeft = UDim.new(0, Config.Sizes.SectionPadding),
        PaddingRight = UDim.new(0, Config.Sizes.SectionPadding),
        Parent = tab.Content,
    })

    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)

    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end

    function tab:AddSection(options)
        options = options or {}
        local section = {
            Name = options.Name or "Section",
            Tab = tab,
        }

        section.Frame = Utility.Create("Frame", {
            Name = section.Name,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Config.Colors.BackgroundSecondary,
            BorderSizePixel = 0,
            Parent = tab.Content,
        })

        Utility.Create("UICorner", {
            CornerRadius = UDim.new(0, Config.Sizes.CornerRadius),
            Parent = section.Frame,
        })

        local sectionPadding = Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, Config.Sizes.SectionPadding),
            PaddingBottom = UDim.new(0, Config.Sizes.SectionPadding),
            PaddingLeft = UDim.new(0, Config.Sizes.SectionPadding),
            PaddingRight = UDim.new(0, Config.Sizes.SectionPadding),
            Parent = section.Frame,
        })

        if section.Name ~= "" then
            section.Header = Utility.Create("TextLabel", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = section.Name,
                TextColor3 = Config.Colors.Text,
                TextSize = 13,
                Font = Config.FontBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section.Frame,
            })

            section.Divider = Utility.Create("Frame", {
                Name = "Divider",
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 0, 22),
                BackgroundColor3 = Config.Colors.Border,
                BorderSizePixel = 0,
                Parent = section.Frame,
            })
        end

        section.ElementList = Utility.Create("UIListLayout", {
            Padding = UDim.new(0, Config.Sizes.ElementSpacing),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = section.Frame,
        })

        if section.Name ~= "" then
            section.ElementList.PaddingTop = UDim.new(0, 8)
        end

        -- Toggle
        function section:AddToggle(options)
            options = options or {}
            local toggle = {
                Name = options.Name or "Toggle",
                Default = options.Default or false,
                Callback = options.Callback or function() end,
                Section = section,
                Value = options.Default or false,
            }

            toggle.Frame = Utility.Create("Frame", {
                Name = toggle.Name,
                Size = UDim2.new(1, 0, 0, Config.Sizes.ElementHeight),
                BackgroundTransparency = 1,
                Parent = section.Frame,
            })

            toggle.Label = Utility.Create("TextLabel", {
                Size = UDim2.new(1, -50, 1, 0),
                BackgroundTransparency = 1,
                Text = toggle.Name,
                TextColor3 = Config.Colors.Text,
                TextSize = 12,
                Font = Config.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggle.Frame,
            })

            toggle.Switch = Utility.Create("Frame", {
                Name = "Switch",
                Size = UDim2.new(0, 36, 0, 20),
                Position = UDim2.new(1, -36, 0.5, -10),
                BackgroundColor3 = toggle.Value and Config.Colors.ToggleOn or Config.Colors.ToggleOff,
                BorderSizePixel = 0,
                Parent = toggle.Frame,
            })

            Utility.Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggle.Switch,
            })

            toggle.Knob = Utility.Create("Frame", {
                Name = "Knob",
                Size = UDim2.new(0, 16, 0, 16),
                Position = toggle.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Config.Colors.Text,
                BorderSizePixel = 0,
                Parent = toggle.Switch,
            })

            Utility.Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggle.Knob,
            })

            local function setValue(value)
                toggle.Value = value
                Utility.Tween(toggle.Switch, {BackgroundColor3 = value and Config.Colors.ToggleOn or Config.Colors.ToggleOff})
                Utility.Tween(toggle.Knob, {Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                pcall(toggle.Callback, value)
            end

            toggle.Frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    setValue(not toggle.Value)
                end
            end)

            toggle.Set = setValue
            toggle.Get = function() return toggle.Value end

            return toggle
        end

        -- Slider
        function section:AddSlider(options)
            options = options or {}
            local slider = {
                Name = options.Name or "Slider",
                Min = options.Min or 0,
                Max = options.Max or 100,
                Default = options.Default or options.Min or 0,
                Increment = options.Increment or 1,
                ValueType = options.ValueType or "",
                Callback = options.Callback or function() end,
                Section = section,
                Value = options.Default or options.Min or 0,
                Dragging = false,
            }

            slider.Frame = Utility.Create("Frame", {
                Name = slider.Name,
                Size = UDim2.new(1, 0, 0, 48),
                BackgroundTransparency = 1,
                Parent = section.Frame,
            })

            slider.Label = Utility.Create("TextLabel", {
                Size = UDim2.new(0.6, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = slider.Name,
                TextColor3 = Config.Colors.Text,
                TextSize = 12,
                Font = Config.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = slider.Frame,
            })

            slider.ValueLabel = Utility.Create("TextLabel", {
                Size = UDim2.new(0.4, 0, 0, 18),
                Position = UDim2.new(0.6, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(slider.Default) .. slider.ValueType,
                TextColor3 = Config.Colors.TextDark,
                TextSize = 12,
                Font = Config.FontCode,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = slider.Frame,
            })

            slider.Track = Utility.Create("Frame", {
                Name = "Track",
                Size = UDim2.new(1, 0, 0, 6),
                Position = UDim2.new(0, 0, 0, 30),
                BackgroundColor3 = Config.Colors.SliderBackground,
                BorderSizePixel = 0,
                Parent = slider.Frame,
            })

            Utility.Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = slider.Track,
            })

            slider.Fill = Utility.Create("Frame", {
                Name = "Fill",
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Config.Colors.SliderFill,
                BorderSizePixel = 0,
                Parent = slider.Track,
            })

            Utility.Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = slider.Fill,
            })

            slider.Knob = Utility.Create("Frame", {
                Name = "Knob",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, -7, 0.5, -7),
                BackgroundColor3 = Config.Colors.Text,
                BorderSizePixel = 0,
                Parent = slider.Fill,
            })

            Utility.Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = slider.Knob,
            })

            local function updateValue(input)
                local trackPos = slider.Track.AbsolutePosition.X
                local trackSize = slider.Track.AbsoluteSize.X
                local relativeX = math.clamp((input.Position.X - trackPos) / trackSize, 0, 1)
                local rawValue = slider.Min + (slider.Max - slider.Min) * relativeX
                local steppedValue = math.floor((rawValue - slider.Min) / slider.Increment + 0.5) * slider.Increment + slider.Min
                steppedValue = math.clamp(steppedValue, slider.Min, slider.Max)

                if steppedValue ~= slider.Value then
                    slider.Value = steppedValue
                    local fillScale = (steppedValue - slider.Min) / (slider.Max - slider.Min)
                    slider.Fill.Size = UDim2.new(fillScale, 0, 1, 0)
                    slider.ValueLabel.Text = string.format("%s%s", Utility.Round(steppedValue,
                        slider.Increment < 1 and 2 or 0), slider.ValueType)
                    pcall(slider.Callback, steppedValue)
                end
            end

            slider.Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    slider.Dragging = true
                    updateValue(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if slider.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateValue(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    slider.Dragging = false
                end
            end)

            local initialScale = (slider.Default - slider.Min) / (slider.Max - slider.Min)
            slider.Fill.Size = UDim2.new(initialScale, 0, 1, 0)
            slider.Value = slider.Default

            slider.Set = function(value)
                value = math.clamp(value, slider.Min, slider.Max)
                value = math.floor((value - slider.Min) / slider.Increment + 0.5) * slider.Increment + slider.Min
                slider.Value = value
                local fillScale = (value - slider.Min) / (slider.Max - slider.Min)
                slider.Fill.Size = UDim2.new(fillScale, 0, 1, 0)
                slider.ValueLabel.Text = string.format("%s%s", Utility.Round(value,
                    slider.Increment < 1 and 2 or 0), slider.ValueType)
                pcall(slider.Callback, value)
            end

            slider.Get = function() return slider.Value end

            return slider
        end

        -- Button
        function section:AddButton(options)
            options = options or {}
            local button = {
                Name = options.Name or "Button",
                Callback = options.Callback or function() end,
                Section = section,
            }

            button.Frame = Utility.Create("TextButton", {
                Name = button.Name,
                Size = UDim2.new(1, 0, 0, Config.Sizes.ElementHeight),
                BackgroundColor3 = Config.Colors.BackgroundTertiary,
                BorderSizePixel = 0,
                Text = button.Name,
                TextColor3 = Config.Colors.Text,
                TextSize = 12,
                Font = Config.Font,
                Parent = section.Frame,
            })

            Utility.Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = button.Frame,
            })

            button.Frame.MouseEnter:Connect(function()
                Utility.Tween(button.Frame, {BackgroundColor3 = Config.Colors.Accent})
            end)

            button.Frame.MouseLeave:Connect(function()
                Utility.Tween(button.Frame, {BackgroundColor3 = Config.Colors.BackgroundTertiary})
            end)

            button.Frame.MouseButton1Click:Connect(function()
                Utility.Tween(button.Frame, {BackgroundColor3 = Config.Colors.AccentDark}, Config.Animations.FastTween)
                task.delay(0.1, function()
                    Utility.Tween(button.Frame, {BackgroundColor3 = Config.Colors.Accent})
                end)
                pcall(button.Callback)
            end)

            return button
        end

        -- Dropdown
        function section:AddDropdown(options)
            options = options or {}
            local dropdown = {
                Name = options.Name or "Dropdown",
                Values = options.Values or {},
                Default = options.Default,
                Multi = options.Multi or false,
                Callback = options.Callback or function() end,
                Section = section,
                Open = false,
                Selected = options.Multi and {} or (options.Default or nil),
            }

            dropdown.Frame = Utility.Create("Frame", {
                Name = dropdown.Name,
                Size = UDim2.new(1, 0, 0, Config.Sizes.ElementHeight),
                BackgroundTransparency = 1,
                Parent = section.Frame,
                ClipsDescendants = false,
            })

            dropdown.Label = Utility.Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = dropdown.Name,
                TextColor3 = Config.Colors.Text,
                TextSize = 12,
                Font = Config.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdown.Frame,
            })

            dropdown.Button = Utility.Create("TextButton", {
                Name = "Button",
                Size = UDim2.new(1, 0, 0, 28),
                Position = UDim2.new(0, 0, 0, 20),
                BackgroundColor3 = Config.Colors.BackgroundTertiary,
                BorderSizePixel = 0,
                Text = "",
                Parent = dropdown.Frame,
            })

            Utility.Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = dropdown.Button,
            })

            dropdown.Display = Utility.Create("TextLabel", {
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = dropdown.Multi and "Select..." or (dropdown.Default or "Select..."),
                TextColor3 = Config.Colors.TextDark,
                TextSize = 12,
                Font = Config.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = dropdown.Button,
            })

            dropdown.Arrow = Utility.Create("ImageLabel", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(1, -20, 0.5, -6),
                BackgroundTransparency = 1,
                Image = "rbxassetid://6764433195",
                ImageColor3 = Config.Colors.TextDark,
                Parent = dropdown.Button,
            })

            dropdown.List = Utility.Create("Frame", {
                Name = "List",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 4),
                BackgroundColor3 = Config.Colors.BackgroundTertiary,
                BorderSizePixel = 0,
                Visible = false,
                ZIndex = 10,
                Parent = dropdown.Button,
            })

            Utility.Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = dropdown.List,
            })

            dropdown.ListLayout = Utility.Create("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = dropdown.List,
            })

            dropdown.ListPadding = Utility.Create("UIPadding", {
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4),
                Parent = dropdown.List,
            })

            local function refreshList()
                for _, child in ipairs(dropdown.List:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end

                for _, value in ipairs(dropdown.Values) do
                    local itemBtn = Utility.Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26),
                        BackgroundTransparency = 1,
                        Text = value,
                        TextColor3 = Config.Colors.Text,
                        TextSize = 12,
                        Font = Config.Font,
                        Parent = dropdown.List,
                    })

                    local isSelected = dropdown.Multi and table.find(dropdown.Selected, value) or dropdown.Selected == value

                    if isSelected then
                        itemBtn.TextColor3 = Config.Colors.Accent
                    end

                    itemBtn.MouseEnter:Connect(function()
                        if not (dropdown.Multi and table.find(dropdown.Selected, value) or dropdown.Selected == value) then
                            Utility.Tween(itemBtn, {BackgroundTransparency = 0.9})
                        end
                    end)

                    itemBtn.MouseLeave:Connect(function()
                        Utility.Tween(itemBtn, {BackgroundTransparency = 1})
                    end)

                    itemBtn.MouseButton1Click:Connect(function()
                        if dropdown.Multi then
                            local idx = table.find(dropdown.Selected, value)
                            if idx then
                                table.remove(dropdown.Selected, idx)
                                itemBtn.TextColor3 = Config.Colors.Text
                            else
                                table.insert(dropdown.Selected, value)
                                itemBtn.TextColor3 = Config.Colors.Accent
                            end
                            dropdown.Display.Text = #dropdown.Selected > 0 and table.concat(dropdown.Selected, ", ") or "Select..."
                            pcall(dropdown.Callback, dropdown.Selected)
                        else
                            dropdown.Selected = value
                            dropdown.Display.Text = value
                            dropdown.Display.TextColor3 = Config.Colors.Text
                            dropdown.Open = false
                            dropdown.List.Visible = false
                            pcall(dropdown.Callback, value)
                        end
                    end)
                end

                local listHeight = math.min(#dropdown.Values * 28 + 8, 200)
                dropdown.List.Size = UDim2.new(1, 0, 0, listHeight)
            end

            dropdown.Button.MouseButton1Click:Connect(function()
                dropdown.Open = not dropdown.Open
                dropdown.List.Visible = dropdown.Open
                if dropdown.Open then
                    refreshList()
                    Utility.Tween(dropdown.Arrow, {Rotation = 180})
                else
                    Utility.Tween(dropdown.Arrow, {Rotation = 0})
                end
            end)

            dropdown.Set = function(value)
                if dropdown.Multi then
                    dropdown.Selected = type(value) == "table" and value or {value}
                    dropdown.Display.Text = #dropdown.Selected > 0 and table.concat(dropdown.Selected, ", ") or "Select..."
                else
                    dropdown.Selected = value
                    dropdown.Display.Text = value or "Select..."
                end
                pcall(dropdown.Callback, dropdown.Selected)
            end

            dropdown.Get = function() return dropdown.Selected end
            dropdown.Refresh = function(values)
                dropdown.Values = values
                refreshList()
            end

            refreshList()
            return dropdown
        end

        -- Keybind
        function section:AddKeybind(options)
            options = options or {}
            local keybind = {
                Name = options.Name or "Keybind",
                Default = options.Default or "None",
                Callback = options.Callback or function() end,
                Section = section,
                Value = options.Default or "None",
                Listening = false,
            }

            keybind.Frame = Utility.Create("Frame", {
                Name = keybind.Name,
                Size = UDim2.new(1, 0, 0, Config.Sizes.ElementHeight),
                BackgroundTransparency = 1,
                Parent = section.Frame,
            })

            keybind.Label = Utility.Create("TextLabel", {
                Size = UDim2.new(1, -90, 1, 0),
                BackgroundTransparency = 1,
                Text = keybind.Name,
                TextColor3 = Config.Colors.Text,
                TextSize = 12,
                Font = Config.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = keybind.Frame,
            })

            keybind.Button = Utility.Create("TextButton", {
                Size = UDim2.new(0, 80, 0, 24),
                Position = UDim2.new(1, -80, 0.5, -12),
                BackgroundColor3 = Config.Colors.BackgroundTertiary,
                BorderSizePixel = 0,
                Text = keybind.Default == "None" and "None" or tostring(keybind.Default):gsub("Enum.KeyCode.", ""),
                TextColor3 = Config.Colors.TextDark,
                TextSize = 11,
                Font = Config.FontCode,
                Parent = keybind.Frame,
            })

            Utility.Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = keybind.Button,
            })

            keybind.Button.MouseButton1Click:Connect(function()
                keybind.Listening = true
                keybind.Button.Text = "..."
                keybind.Button.TextColor3 = Config.Colors.Accent
            end)

            UserInputService.InputBegan:Connect(function(input)
                if keybind.Listening then
                    if input.KeyCode == Enum.KeyCode.Escape then
                        keybind.Value = "None"
                        keybind.Button.Text = "None"
                    elseif input.KeyCode ~= Enum.KeyCode.Unknown then
                        keybind.Value = input.KeyCode
                        keybind.Button.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                    end
                    keybind.Listening = false
                    keybind.Button.TextColor3 = Config.Colors.TextDark
                    pcall(keybind.Callback, keybind.Value)
                elseif keybind.Value ~= "None" and input.KeyCode == keybind.Value then
                    pcall(keybind.Callback, keybind.Value, true)
                end
            end)

            keybind.Set = function(value)
                keybind.Value = value
                keybind.Button.Text = value == "None" and "None" or tostring(value):gsub("Enum.KeyCode.", "")
                pcall(keybind.Callback, value)
            end

            keybind.Get = function() return keybind.Value end

            return keybind
        end

        -- Textbox
        function section:AddTextbox(options)
            options = options or {}
            local textbox = {
                Name = options.Name or "Textbox",
                Default = options.Default or "",
                Placeholder = options.Placeholder or "Enter text...",
                Numeric = options.Numeric or false,
                Callback = options.Callback or function() end,
                Section = section,
                Value = options.Default or "",
            }

            textbox.Frame = Utility.Create("Frame", {
                Name = textbox.Name,
                Size = UDim2.new(1, 0, 0, Config.Sizes.ElementHeight + 4),
                BackgroundTransparency = 1,
                Parent = section.Frame,
            })

            textbox.Label = Utility.Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = textbox.Name,
                TextColor3 = Config.Colors.Text,
                TextSize = 12,
                Font = Config.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = textbox.Frame,
            })

            textbox.Input = Utility.Create("TextBox", {
                Size = UDim2.new(1, 0, 0, 26),
                Position = UDim2.new(0, 0, 0, 20),
                BackgroundColor3 = Config.Colors.BackgroundTertiary,
                BorderSizePixel = 0,
                Text = textbox.Default,
                PlaceholderText = textbox.Placeholder,
                TextColor3 = Config.Colors.Text,
                PlaceholderColor3 = Config.Colors.TextDisabled,
                TextSize = 12,
                Font = Config.Font,
                ClearTextOnFocus = false,
                Parent = textbox.Frame,
            })

            Utility.Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = textbox.Input,
            })

            Utility.Create("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = textbox.Input,
            })

            textbox.Input.FocusLost:Connect(function()
                local text = textbox.Input.Text
                if textbox.Numeric then
                    text = tonumber(text) or textbox.Value
                    textbox.Input.Text = tostring(text)
                end
                textbox.Value = text
                pcall(textbox.Callback, text)
            end)

            textbox.Set = function(value)
                textbox.Value = value
                textbox.Input.Text = tostring(value)
                pcall(textbox.Callback, value)
            end

            textbox.Get = function() return textbox.Value end

            return textbox
        end

        -- ColorPicker (simplified)
        function section:AddColorPicker(options)
            options = options or {}
            local picker = {
                Name = options.Name or "Color Picker",
                Default = options.Default or Color3.fromRGB(0, 162, 255),
                Callback = options.Callback or function() end,
                Section = section,
                Value = options.Default or Color3.fromRGB(0, 162, 255),
                Open = false,
            }

            picker.Frame = Utility.Create("Frame", {
                Name = picker.Name,
                Size = UDim2.new(1, 0, 0, Config.Sizes.ElementHeight),
                BackgroundTransparency = 1,
                Parent = section.Frame,
            })

            picker.Label = Utility.Create("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0),
                BackgroundTransparency = 1,
                Text = picker.Name,
                TextColor3 = Config.Colors.Text,
                TextSize = 12,
                Font = Config.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = picker.Frame,
            })

            picker.Display = Utility.Create("TextButton", {
                Size = UDim2.new(0, 30, 0, 22),
                Position = UDim2.new(1, -30, 0.5, -11),
                BackgroundColor3 = picker.Default,
                BorderSizePixel = 0,
                Text = "",
                Parent = picker.Frame,
            })

            Utility.Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = picker.Display,
            })

            Utility.Create("UIStroke", {
                Color = Config.Colors.Border,
                Thickness = 1,
                Parent = picker.Display,
            })

            picker.Display.MouseButton1Click:Connect(function()
                -- Simplified: just cycles through preset colors
                local presets = {
                    Color3.fromRGB(0, 162, 255),
                    Color3.fromRGB(255, 80, 80),
                    Color3.fromRGB(80, 200, 120),
                    Color3.fromRGB(230, 180, 60),
                    Color3.fromRGB(138, 43, 226),
                    Color3.fromRGB(255, 255, 255),
                }
                local currentIdx = 1
                for i, color in ipairs(presets) do
                    if color == picker.Value then
                        currentIdx = i
                        break
                    end
                end
                local nextColor = presets[(currentIdx % #presets) + 1]
                picker.Value = nextColor
                picker.Display.BackgroundColor3 = nextColor
                pcall(picker.Callback, nextColor)
            end)

            picker.Set = function(color)
                picker.Value = color
                picker.Display.BackgroundColor3 = color
                pcall(picker.Callback, color)
            end

            picker.Get = function() return picker.Value end

            return picker
        end

        -- Label
        function section:AddLabel(options)
            options = options or {}
            local label = {
                Text = options.Text or "Label",
                Section = section,
            }

            label.Frame = Utility.Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text = label.Text,
                TextColor3 = options.Color or Config.Colors.TextDark,
                TextSize = 12,
                Font = options.Bold and Config.FontBold or Config.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = section.Frame,
            })

            label.Set = function(text)
                label.Text = text
                label.Frame.Text = text
            end

            return label
        end

        -- Divider
        function section:AddDivider()
            local divider = Utility.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Config.Colors.Border,
                BorderSizePixel = 0,
                Parent = section.Frame,
            })
            return divider
        end

        table.insert(tab.Sections, section)
        return section
    end

    return tab
end

function Window:SelectTab(tab)
    if self.ActiveTab == tab then return end

    if self.ActiveTab then
        self.ActiveTab.Content.Visible = false
        self.ActiveTab.Label.TextColor3 = Config.Colors.TextDark
        Utility.Tween(self.ActiveTab.Indicator, {BackgroundTransparency = 1})
    end

    self.ActiveTab = tab
    tab.Content.Visible = true
    tab.Label.TextColor3 = Config.Colors.Text
    Utility.Tween(tab.Indicator, {BackgroundTransparency = 0})
end

function Window:Notify(options)
    return self.Notifications:Notify(options)
end

function Window:SetVisible(visible)
    self.Visible = visible
    self.MainFrame.Visible = visible
    self.Shadow.Visible = visible
end

function Window:Destroy()
    if self.Gui then
        self.Gui:Destroy()
    end
    if self.Notifications and self.Notifications.Container then
        self.Notifications.Container:Destroy()
    end
end

-- --- Library Entry Point ---
function Nexus.CreateWindow(options)
    return Window.new(options)
end

function Nexus.Notify(options)
    local notifSystem = NotificationSystem.new()
    return notifSystem:Notify(options)
end

function Nexus.SetConfig(key, value)
    if Config[key] then
        if type(Config[key]) == "table" and type(value) == "table" then
            for k, v in pairs(value) do
                Config[key][k] = v
            end
        else
            Config[key] = value
        end
    end
end

function Nexus.GetConfig()
    local clone = {}
    for k, v in pairs(Config) do
        if type(v) == "table" then
            clone[k] = {}
            for k2, v2 in pairs(v) do
                clone[k][k2] = v2
            end
        else
            clone[k] = v
        end
    end
    return clone
end

function Nexus.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

Nexus.Themes = {
    Dark = "Dark",
    Midnight = "Midnight",
    Crimson = "Crimson",
    Forest = "Forest",
}

return Nexus
