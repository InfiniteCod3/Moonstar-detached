--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                         LUNARITY UI MODULE                                ║
    ║                    Shared ImGUI-Style GUI Framework                       ║
    ╠═══════════════════════════════════════════════════════════════════════════╣
    ║  This module provides a consistent, modern UI framework for all          ║
    ║  Lunarity scripts. It includes theme colors, helper functions for        ║
    ║  creating UI elements, and window management.                            ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LunarityUI = {}

-- Color Scheme (Purple/Violet ImGUI Style)
LunarityUI.Theme = {
    -- Primary colors
    Background = Color3.fromRGB(15, 15, 20),
    BackgroundLight = Color3.fromRGB(25, 25, 35),
    BackgroundDark = Color3.fromRGB(10, 10, 15),
    Border = Color3.fromRGB(80, 60, 140),
    Accent = Color3.fromRGB(130, 90, 200),
    AccentHover = Color3.fromRGB(150, 110, 220),
    AccentDark = Color3.fromRGB(100, 70, 160),
    Text = Color3.fromRGB(220, 220, 230),
    TextDim = Color3.fromRGB(140, 140, 160),
    Success = Color3.fromRGB(90, 200, 120),
    Error = Color3.fromRGB(200, 90, 90),
    Warning = Color3.fromRGB(200, 160, 90),
    Separator = Color3.fromRGB(50, 45, 70),
    
    -- Backward-compatible aliases (for existing scripts)
    BackgroundGradientStart = Color3.fromRGB(25, 25, 35),
    BackgroundGradientEnd = Color3.fromRGB(10, 10, 15),
    Panel = Color3.fromRGB(20, 20, 28),
    PanelStroke = Color3.fromRGB(80, 60, 140),
    PanelHover = Color3.fromRGB(30, 30, 40),
    NeutralButton = Color3.fromRGB(25, 25, 35),
    NeutralButtonHover = Color3.fromRGB(35, 35, 45),
    NeutralDark = Color3.fromRGB(15, 15, 22),
    AccentLight = Color3.fromRGB(160, 120, 230),
    TextPrimary = Color3.fromRGB(220, 220, 230),
    TextSecondary = Color3.fromRGB(180, 180, 195),
    TextMuted = Color3.fromRGB(140, 140, 160),
    Danger = Color3.fromRGB(200, 90, 90),
    DangerDark = Color3.fromRGB(150, 60, 60),
    DangerHover = Color3.fromRGB(220, 110, 110),
}

-- Gradient sequences for UI elements
LunarityUI.AccentGradientSequence = ColorSequence.new{
    ColorSequenceKeypoint.new(0, LunarityUI.Theme.AccentLight),
    ColorSequenceKeypoint.new(0.5, LunarityUI.Theme.Accent),
    ColorSequenceKeypoint.new(1, LunarityUI.Theme.AccentDark)
}

LunarityUI.BackgroundGradientSequence = ColorSequence.new{
    ColorSequenceKeypoint.new(0, LunarityUI.Theme.BackgroundGradientStart),
    ColorSequenceKeypoint.new(1, LunarityUI.Theme.BackgroundGradientEnd)
}

LunarityUI.DangerGradientSequence = ColorSequence.new{
    ColorSequenceKeypoint.new(0, LunarityUI.Theme.Danger),
    ColorSequenceKeypoint.new(1, LunarityUI.Theme.DangerDark)
}

-- Local reference for internal use
local Theme = LunarityUI.Theme

-- Connection tracking for cleanup
local function createConnectionTracker()
    local connections = {}
    return {
        add = function(conn)
            if conn then
                table.insert(connections, conn)
            end
        end,
        disconnectAll = function()
            for _, conn in ipairs(connections) do
                pcall(function()
                    if conn and conn.Disconnect then
                        conn:Disconnect()
                    end
                end)
            end
            connections = {}
        end
    }
end

--[[
    Creates a new Lunarity-styled window
    
    @param options table {
        Name: string,           -- GUI name (used for duplicate detection)
        Title: string,          -- Window title
        Subtitle: string?,      -- Optional subtitle
        Size: UDim2?,          -- Window size (default: 340x480)
        Position: UDim2?,      -- Window position (default: centered)
        Minimizable: boolean?, -- Show minimize button (default: true)
        Closable: boolean?,    -- Show close button (default: true)
        OnClose: function?,    -- Callback when window is closed
    }
    
    @return table { 
        ScreenGui, MainFrame, Content, 
        addConnection, destroy, 
        createSection, createButton, createToggle, createNumberBox, createStatusBar
    }
]]
function LunarityUI.CreateWindow(options)
    options = options or {}
    local name = options.Name or "LunarityUI"
    local title = options.Title or "Lunarity"
    local subtitle = options.Subtitle or ""
    local size = options.Size or UDim2.new(0, 340, 0, 480)
    local position = options.Position or UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    local minimizable = options.Minimizable ~= false
    local closable = options.Closable ~= false
    local onClose = options.OnClose
    
    local connectionTracker = createConnectionTracker()
    
    -- Cleanup existing UI
    local existingGui = CoreGui:FindFirstChild(name)
    if existingGui then
        existingGui:Destroy()
    end
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = name
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = size
    MainFrame.Position = position
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = MainFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Theme.Border
    UIStroke.Thickness = 1
    UIStroke.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 28)
    TitleBar.BackgroundColor3 = Theme.BackgroundDark
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 4)
    TitleCorner.Parent = TitleBar
    
    -- Fix bottom corners of title bar
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 8)
    TitleFix.Position = UDim2.new(0, 0, 1, -8)
    TitleFix.BackgroundColor3 = Theme.BackgroundDark
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = TitleBar
    
    -- Title Label
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Theme.Accent
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Subtitle Label
    if subtitle ~= "" then
        local Subtitle = Instance.new("TextLabel")
        Subtitle.Size = UDim2.new(0, 100, 1, 0)
        Subtitle.Position = UDim2.new(0, 70, 0, 0)
        Subtitle.BackgroundTransparency = 1
        Subtitle.Text = "| " .. subtitle
        Subtitle.TextColor3 = Theme.TextDim
        Subtitle.TextSize = 12
        Subtitle.Font = Enum.Font.Gotham
        Subtitle.TextXAlignment = Enum.TextXAlignment.Left
        Subtitle.Parent = TitleBar
    end
    
    -- Close Button
    local CloseBtn
    if closable then
        CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0, 28, 0, 28)
        CloseBtn.Position = UDim2.new(1, -28, 0, 0)
        CloseBtn.BackgroundTransparency = 1
        CloseBtn.Text = "×"
        CloseBtn.TextColor3 = Theme.TextDim
        CloseBtn.TextSize = 14
        CloseBtn.Font = Enum.Font.Gotham
        CloseBtn.Parent = TitleBar
        
        CloseBtn.MouseEnter:Connect(function()
            CloseBtn.TextColor3 = Theme.Error
        end)
        CloseBtn.MouseLeave:Connect(function()
            CloseBtn.TextColor3 = Theme.TextDim
        end)
        CloseBtn.MouseButton1Click:Connect(function()
            if onClose then
                onClose()
            end
            ScreenGui:Destroy()
        end)
    end
    
    -- Minimize Button
    local minimized = false
    local originalSize = size
    local MinBtn
    if minimizable then
        MinBtn = Instance.new("TextButton")
        MinBtn.Size = UDim2.new(0, 28, 0, 28)
        MinBtn.Position = closable and UDim2.new(1, -56, 0, 0) or UDim2.new(1, -28, 0, 0)
        MinBtn.BackgroundTransparency = 1
        MinBtn.Text = "-"
        MinBtn.TextColor3 = Theme.TextDim
        MinBtn.TextSize = 16
        MinBtn.Font = Enum.Font.Gotham
        MinBtn.Parent = TitleBar
        
        MinBtn.MouseEnter:Connect(function()
            MinBtn.TextColor3 = Theme.Accent
        end)
        MinBtn.MouseLeave:Connect(function()
            MinBtn.TextColor3 = Theme.TextDim
        end)
        MinBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            if minimized then
                MainFrame.Size = UDim2.new(0, size.X.Offset, 0, 28)
            else
                MainFrame.Size = originalSize
            end
        end)
    end
    
    -- Content Area (ScrollingFrame)
    local Content = Instance.new("ScrollingFrame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -16, 1, -36)
    Content.Position = UDim2.new(0, 8, 0, 32)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 2
    Content.ScrollBarImageColor3 = Theme.Accent
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.Parent = MainFrame
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 4)
    ContentLayout.Parent = Content
    
    -- Auto-update canvas size
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Dragging functionality
    local dragging, dragStart, startPos
    
    connectionTracker.add(TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end))
    
    connectionTracker.add(TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))
    
    connectionTracker.add(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))
    
    -- Layout order counter
    local layoutOrder = 0
    local function nextLayoutOrder()
        layoutOrder = layoutOrder + 1
        return layoutOrder
    end
    
    -- Helper: Create Section Header
    local function createSection(sectionTitle)
        local Section = Instance.new("Frame")
        Section.Name = sectionTitle
        Section.Size = UDim2.new(1, 0, 0, 22)
        Section.BackgroundTransparency = 1
        Section.LayoutOrder = nextLayoutOrder()
        Section.Parent = Content
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = string.upper(sectionTitle)
        Label.TextColor3 = Theme.TextDim
        Label.TextSize = 10
        Label.Font = Enum.Font.GothamBold
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Section
        
        local Line = Instance.new("Frame")
        Line.Size = UDim2.new(1, 0, 0, 1)
        Line.Position = UDim2.new(0, 0, 1, -1)
        Line.BackgroundColor3 = Theme.Separator
        Line.BorderSizePixel = 0
        Line.Parent = Section
        
        return Section
    end
    
    -- Helper: Create Button
    local function createButton(text, callback, accent)
        local btnColor = accent and Theme.Accent or Theme.BackgroundLight
        local btnHover = accent and Theme.AccentHover or Theme.Separator
        
        local Button = Instance.new("TextButton")
        Button.Name = text
        Button.Size = UDim2.new(1, 0, 0, 26)
        Button.BackgroundColor3 = btnColor
        Button.BorderSizePixel = 0
        Button.Text = text
        Button.TextColor3 = Theme.Text
        Button.TextSize = 12
        Button.Font = Enum.Font.Gotham
        Button.LayoutOrder = nextLayoutOrder()
        Button.AutoButtonColor = false
        Button.Parent = Content
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 3)
        Corner.Parent = Button
        
        Button.MouseButton1Click:Connect(callback)
        
        Button.MouseEnter:Connect(function()
            Button.BackgroundColor3 = btnHover
        end)
        Button.MouseLeave:Connect(function()
            Button.BackgroundColor3 = btnColor
        end)
        
        return Button
    end
    
    -- Helper: Create Toggle
    local function createToggle(text, initial, onChanged)
        local state = initial
        
        local Holder = Instance.new("Frame")
        Holder.Name = text .. "_Toggle"
        Holder.Size = UDim2.new(1, 0, 0, 26)
        Holder.BackgroundTransparency = 1
        Holder.LayoutOrder = nextLayoutOrder()
        Holder.Parent = Content
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -50, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Holder
        
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Name = "Toggle"
        ToggleBtn.Size = UDim2.new(0, 42, 0, 20)
        ToggleBtn.Position = UDim2.new(1, -44, 0.5, -10)
        ToggleBtn.AutoButtonColor = false
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Parent = Holder
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 3)
        ToggleCorner.Parent = ToggleBtn
        
        local function updateVisual()
            if state then
                ToggleBtn.Text = "ON"
                ToggleBtn.BackgroundColor3 = Theme.Success
                ToggleBtn.TextColor3 = Theme.BackgroundDark
            else
                ToggleBtn.Text = "OFF"
                ToggleBtn.BackgroundColor3 = Theme.BackgroundLight
                ToggleBtn.TextColor3 = Theme.TextDim
            end
        end
        
        updateVisual()
        
        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            updateVisual()
            if onChanged then
                onChanged(state)
            end
        end)
        
        -- Return control functions
        return {
            holder = Holder,
            getState = function() return state end,
            setState = function(newState)
                state = newState
                updateVisual()
            end
        }
    end
    
    -- Helper: Create Number Input
    local function createNumberBox(text, initial, minValue, maxValue, onChanged)
        local value = initial
        
        local Holder = Instance.new("Frame")
        Holder.Name = text .. "_Number"
        Holder.Size = UDim2.new(1, 0, 0, 26)
        Holder.BackgroundTransparency = 1
        Holder.LayoutOrder = nextLayoutOrder()
        Holder.Parent = Content
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -70, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Holder
        
        local Box = Instance.new("TextBox")
        Box.Name = "Input"
        Box.Size = UDim2.new(0, 60, 0, 20)
        Box.Position = UDim2.new(1, -62, 0.5, -10)
        Box.BackgroundColor3 = Theme.BackgroundLight
        Box.BorderSizePixel = 0
        Box.Font = Enum.Font.Gotham
        Box.Text = tostring(initial)
        Box.TextSize = 11
        Box.TextColor3 = Theme.Text
        Box.ClearTextOnFocus = false
        Box.Parent = Holder
        
        local BoxCorner = Instance.new("UICorner")
        BoxCorner.CornerRadius = UDim.new(0, 3)
        BoxCorner.Parent = Box
        
        Box.FocusLost:Connect(function(enterPressed)
            local n = tonumber(Box.Text)
            if not n then
                Box.Text = tostring(value)
                return
            end
            n = math.clamp(n, minValue, maxValue)
            value = n
            Box.Text = tostring(n)
            if onChanged then
                onChanged(n)
            end
        end)
        
        return {
            holder = Holder,
            getValue = function() return value end,
            setValue = function(newValue)
                value = math.clamp(newValue, minValue, maxValue)
                Box.Text = tostring(value)
            end
        }
    end
    
    -- Helper: Create Status Bar
    local function createStatusBar(text, initialColor)
        local StatusFrame = Instance.new("Frame")
        StatusFrame.Name = "Status"
        StatusFrame.Size = UDim2.new(1, 0, 0, 28)
        StatusFrame.BackgroundColor3 = Theme.BackgroundLight
        StatusFrame.BorderSizePixel = 0
        StatusFrame.LayoutOrder = nextLayoutOrder()
        StatusFrame.Parent = Content
        
        local StatusCorner = Instance.new("UICorner")
        StatusCorner.CornerRadius = UDim.new(0, 3)
        StatusCorner.Parent = StatusFrame
        
        local StatusIndicator = Instance.new("Frame")
        StatusIndicator.Name = "Indicator"
        StatusIndicator.Size = UDim2.new(0, 8, 0, 8)
        StatusIndicator.Position = UDim2.new(0, 10, 0.5, -4)
        StatusIndicator.BackgroundColor3 = initialColor or Theme.Error
        StatusIndicator.Parent = StatusFrame
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(1, 0)
        IndicatorCorner.Parent = StatusIndicator
        
        local StatusText = Instance.new("TextLabel")
        StatusText.Name = "StatusText"
        StatusText.Size = UDim2.new(1, -30, 1, 0)
        StatusText.Position = UDim2.new(0, 26, 0, 0)
        StatusText.BackgroundTransparency = 1
        StatusText.Text = text
        StatusText.TextColor3 = Theme.TextDim
        StatusText.TextSize = 11
        StatusText.Font = Enum.Font.Gotham
        StatusText.TextXAlignment = Enum.TextXAlignment.Left
        StatusText.Parent = StatusFrame
        
        return {
            frame = StatusFrame,
            setText = function(newText)
                StatusText.Text = newText
            end,
            setColor = function(color)
                StatusIndicator.BackgroundColor3 = color
            end,
            setTextColor = function(color)
                StatusText.TextColor3 = color
            end
        }
    end
    
    -- Helper: Create Dropdown/List
    local function createDropdownList(title, height)
        height = height or 140
        
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = title .. "_Dropdown"
        DropdownFrame.Size = UDim2.new(1, 0, 0, height)
        DropdownFrame.BackgroundColor3 = Theme.BackgroundLight
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.LayoutOrder = nextLayoutOrder()
        DropdownFrame.Parent = Content
        
        local DropdownCorner = Instance.new("UICorner")
        DropdownCorner.CornerRadius = UDim.new(0, 3)
        DropdownCorner.Parent = DropdownFrame
        
        local List = Instance.new("ScrollingFrame")
        List.Name = "List"
        List.Size = UDim2.new(1, -8, 1, -8)
        List.Position = UDim2.new(0, 4, 0, 4)
        List.BackgroundTransparency = 1
        List.ScrollBarThickness = 2
        List.ScrollBarImageColor3 = Theme.Accent
        List.Parent = DropdownFrame
        
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.SortOrder = Enum.SortOrder.Name
        ListLayout.Padding = UDim.new(0, 2)
        ListLayout.Parent = List
        
        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            List.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
        end)
        
        local function addItem(itemText, onClick, isSpecial, specialColor)
            local textColor = isSpecial and (specialColor or Theme.Accent) or Theme.Text
            local bgColor = isSpecial and Color3.fromRGB(40, 30, 60) or Theme.BackgroundDark
            
            local ItemBtn = Instance.new("TextButton")
            ItemBtn.Name = itemText
            ItemBtn.Size = UDim2.new(1, -4, 0, 22)
            ItemBtn.BackgroundColor3 = bgColor
            ItemBtn.BorderSizePixel = 0
            ItemBtn.Text = itemText
            ItemBtn.TextColor3 = textColor
            ItemBtn.TextSize = 10
            ItemBtn.Font = Enum.Font.Gotham
            ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
            ItemBtn.AutoButtonColor = false
            ItemBtn.Parent = List
            
            local ItemCorner = Instance.new("UICorner")
            ItemCorner.CornerRadius = UDim.new(0, 2)
            ItemCorner.Parent = ItemBtn
            
            local Padding = Instance.new("UIPadding")
            Padding.PaddingLeft = UDim.new(0, 6)
            Padding.Parent = ItemBtn
            
            ItemBtn.MouseEnter:Connect(function()
                ItemBtn.BackgroundColor3 = Theme.Separator
            end)
            ItemBtn.MouseLeave:Connect(function()
                ItemBtn.BackgroundColor3 = bgColor
            end)
            
            if onClick then
                ItemBtn.MouseButton1Click:Connect(onClick)
            end
            
            return ItemBtn
        end
        
        local function clearItems()
            for _, child in ipairs(List:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
        end
        
        return {
            frame = DropdownFrame,
            list = List,
            addItem = addItem,
            clearItems = clearItems
        }
    end
    
    -- Helper: Create Info Label
    local function createInfoLabel(text)
        local InfoLabel = Instance.new("TextLabel")
        InfoLabel.Size = UDim2.new(1, 0, 0, 40)
        InfoLabel.BackgroundColor3 = Theme.BackgroundLight
        InfoLabel.BorderSizePixel = 0
        InfoLabel.Text = text
        InfoLabel.TextColor3 = Theme.TextDim
        InfoLabel.TextSize = 10
        InfoLabel.Font = Enum.Font.Gotham
        InfoLabel.TextWrapped = true
        InfoLabel.LayoutOrder = nextLayoutOrder()
        InfoLabel.Parent = Content
        
        local InfoCorner = Instance.new("UICorner")
        InfoCorner.CornerRadius = UDim.new(0, 3)
        InfoCorner.Parent = InfoLabel
        
        return InfoLabel
    end
    
    -- Helper: Create Text Box (for text input like API keys)
    local function createTextBox(placeholder, onSubmit)
        local TextBox = Instance.new("TextBox")
        TextBox.Size = UDim2.new(1, 0, 0, 32)
        TextBox.BackgroundColor3 = Theme.BackgroundLight
        TextBox.BorderSizePixel = 0
        TextBox.Text = ""
        TextBox.PlaceholderText = placeholder or "Enter text..."
        TextBox.TextColor3 = Theme.Text
        TextBox.PlaceholderColor3 = Theme.TextDim
        TextBox.Font = Enum.Font.Gotham
        TextBox.TextSize = 13
        TextBox.ClearTextOnFocus = false
        TextBox.LayoutOrder = nextLayoutOrder()
        TextBox.Parent = Content
        
        local TextBoxCorner = Instance.new("UICorner")
        TextBoxCorner.CornerRadius = UDim.new(0, 4)
        TextBoxCorner.Parent = TextBox
        
        local TextBoxStroke = Instance.new("UIStroke")
        TextBoxStroke.Color = Theme.Border
        TextBoxStroke.Transparency = 0.5
        TextBoxStroke.Parent = TextBox
        
        local TextBoxPadding = Instance.new("UIPadding")
        TextBoxPadding.PaddingLeft = UDim.new(0, 10)
        TextBoxPadding.PaddingRight = UDim.new(0, 10)
        TextBoxPadding.Parent = TextBox
        
        TextBox.Focused:Connect(function()
            TextBoxStroke.Color = Theme.Accent
            TextBoxStroke.Transparency = 0
        end)
        
        TextBox.FocusLost:Connect(function(enterPressed)
            TextBoxStroke.Color = Theme.Border
            TextBoxStroke.Transparency = 0.5
            if enterPressed and onSubmit then
                onSubmit(TextBox.Text)
            end
        end)
        
        return {
            textBox = TextBox,
            getText = function() return TextBox.Text end,
            setText = function(text) TextBox.Text = text end,
        }
    end
    
    -- Helper: Create Slider
    local function createSlider(text, minVal, maxVal, initial, decimals, onChanged)
        local value = initial
        
        local Holder = Instance.new("Frame")
        Holder.Name = text .. "_Slider"
        Holder.Size = UDim2.new(1, 0, 0, 36)
        Holder.BackgroundTransparency = 1
        Holder.LayoutOrder = nextLayoutOrder()
        Holder.Parent = Content
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -50, 0, 16)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Holder
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0, 40, 0, 16)
        ValueLabel.Position = UDim2.new(1, -42, 0, 0)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(initial)
        ValueLabel.TextColor3 = Theme.Accent
        ValueLabel.TextSize = 11
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = Holder
        
        local SliderBg = Instance.new("Frame")
        SliderBg.Size = UDim2.new(1, 0, 0, 6)
        SliderBg.Position = UDim2.new(0, 0, 0, 22)
        SliderBg.BackgroundColor3 = Theme.BackgroundDark
        SliderBg.BorderSizePixel = 0
        SliderBg.Parent = Holder
        
        local SliderBgCorner = Instance.new("UICorner")
        SliderBgCorner.CornerRadius = UDim.new(0, 3)
        SliderBgCorner.Parent = SliderBg
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new((initial - minVal) / (maxVal - minVal), 0, 1, 0)
        SliderFill.BackgroundColor3 = Theme.Accent
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderBg
        
        local SliderFillCorner = Instance.new("UICorner")
        SliderFillCorner.CornerRadius = UDim.new(0, 3)
        SliderFillCorner.Parent = SliderFill
        
        local draggingSlider = false
        
        local function updateSlider(input)
            local relativeX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            local newValue = minVal + relativeX * (maxVal - minVal)
            
            if decimals then
                newValue = math.floor(newValue * (10 ^ decimals) + 0.5) / (10 ^ decimals)
            else
                newValue = math.floor(newValue + 0.5)
            end
            
            value = newValue
            SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            ValueLabel.Text = tostring(value)
            if onChanged then
                onChanged(value)
            end
        end
        
        SliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = true
                updateSlider(input)
            end
        end)
        
        SliderBg.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)
        
        connectionTracker.add(UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end))
        
        return {
            holder = Holder,
            getValue = function() return value end,
            setValue = function(newValue)
                value = math.clamp(newValue, minVal, maxVal)
                local relativeX = (value - minVal) / (maxVal - minVal)
                SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                ValueLabel.Text = tostring(value)
            end
        }
    end
    
    -- Helper: Create Cycling Dropdown (click to cycle through options)
    local function createDropdown(text, options, initialIndex, onChanged)
        local currentIndex = initialIndex
        
        local Holder = Instance.new("Frame")
        Holder.Name = text .. "_Dropdown"
        Holder.Size = UDim2.new(1, 0, 0, 26)
        Holder.BackgroundTransparency = 1
        Holder.LayoutOrder = nextLayoutOrder()
        Holder.Parent = Content
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -90, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Holder
        
        local Button = Instance.new("TextButton")
        Button.Name = "Select"
        Button.Size = UDim2.new(0, 80, 0, 20)
        Button.Position = UDim2.new(1, -82, 0.5, -10)
        Button.BackgroundColor3 = Theme.BackgroundLight
        Button.BorderSizePixel = 0
        Button.Text = options[initialIndex]
        Button.TextColor3 = Theme.Text
        Button.TextSize = 10
        Button.Font = Enum.Font.Gotham
        Button.AutoButtonColor = false
        Button.Parent = Holder
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 3)
        ButtonCorner.Parent = Button
        
        Button.MouseButton1Click:Connect(function()
            currentIndex = currentIndex % #options + 1
            Button.Text = options[currentIndex]
            if onChanged then
                onChanged(currentIndex, options[currentIndex])
            end
        end)
        
        Button.MouseEnter:Connect(function()
            Button.BackgroundColor3 = Theme.Separator
        end)
        Button.MouseLeave:Connect(function()
            Button.BackgroundColor3 = Theme.BackgroundLight
        end)
        
        return {
            holder = Holder,
            getIndex = function() return currentIndex end,
            setIndex = function(newIndex)
                currentIndex = newIndex
                Button.Text = options[newIndex]
            end
        }
    end
    
    -- Helper: Create Large Toggle (full-width toggle button)
    local function createLargeToggle(text, initial, onChanged)
        local state = initial
        
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Name = text .. "_LargeToggle"
        ToggleBtn.Size = UDim2.new(1, 0, 0, 36)
        ToggleBtn.BackgroundColor3 = state and Theme.Accent or Theme.BackgroundLight
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
        ToggleBtn.TextColor3 = state and Theme.Text or Theme.TextDim
        ToggleBtn.TextSize = 14
        ToggleBtn.Font = Enum.Font.GothamBold
        ToggleBtn.AutoButtonColor = false
        ToggleBtn.LayoutOrder = nextLayoutOrder()
        ToggleBtn.Parent = Content
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 4)
        ToggleCorner.Parent = ToggleBtn
        
        local ToggleStroke = Instance.new("UIStroke")
        ToggleStroke.Color = Theme.Border
        ToggleStroke.Thickness = 1
        ToggleStroke.Transparency = 0.5
        ToggleStroke.Parent = ToggleBtn
        
        local function updateVisual()
            ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
            ToggleBtn.BackgroundColor3 = state and Theme.Accent or Theme.BackgroundLight
            ToggleBtn.TextColor3 = state and Theme.Text or Theme.TextDim
        end
        
        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            updateVisual()
            if onChanged then
                onChanged(state)
            end
        end)
        
        ToggleBtn.MouseEnter:Connect(function()
            ToggleBtn.BackgroundColor3 = state and Theme.AccentHover or Theme.Separator
        end)
        ToggleBtn.MouseLeave:Connect(function()
            ToggleBtn.BackgroundColor3 = state and Theme.Accent or Theme.BackgroundLight
        end)
        
        return {
            button = ToggleBtn,
            getState = function() return state end,
            setState = function(newState)
                state = newState
                updateVisual()
            end,
            updateText = function(newText)
                text = newText
                updateVisual()
            end
        }
    end
    
    -- Helper: Create Player List (scrolling list for player selection)
    local function createPlayerList(title, height, onPlayerClick, onPlayerRightClick)
        local ListFrame = Instance.new("Frame")
        ListFrame.Name = title .. "_PlayerList" 
        ListFrame.Size = UDim2.new(1, 0, 0, height + 24)
        ListFrame.BackgroundTransparency = 1
        ListFrame.LayoutOrder = nextLayoutOrder()
        ListFrame.Parent = Content
        
        local ListLabel = Instance.new("TextLabel")
        ListLabel.Size = UDim2.new(1, 0, 0, 20)
        ListLabel.BackgroundTransparency = 1
        ListLabel.Text = title
        ListLabel.TextColor3 = Theme.TextDim
        ListLabel.TextSize = 11
        ListLabel.Font = Enum.Font.GothamSemibold
        ListLabel.TextXAlignment = Enum.TextXAlignment.Left
        ListLabel.Parent = ListFrame
        
        local List = Instance.new("ScrollingFrame")
        List.Size = UDim2.new(1, 0, 0, height)
        List.Position = UDim2.new(0, 0, 0, 24)
        List.BackgroundColor3 = Theme.BackgroundLight
        List.BorderSizePixel = 0
        List.ScrollBarThickness = 4
        List.ScrollBarImageColor3 = Theme.Accent
        List.CanvasSize = UDim2.new(0, 0, 0, 0)
        List.AutomaticCanvasSize = Enum.AutomaticSize.Y
        List.Parent = ListFrame
        
        local ListCorner = Instance.new("UICorner")
        ListCorner.CornerRadius = UDim.new(0, 4)
        ListCorner.Parent = List
        
        local ListStroke = Instance.new("UIStroke")
        ListStroke.Color = Theme.Border
        ListStroke.Thickness = 1
        ListStroke.Transparency = 0.5
        ListStroke.Parent = List
        
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Padding = UDim.new(0, 4)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Parent = List
        
        local ListPadding = Instance.new("UIPadding")
        ListPadding.PaddingTop = UDim.new(0, 4)
        ListPadding.PaddingLeft = UDim.new(0, 4)
        ListPadding.PaddingRight = UDim.new(0, 4)
        ListPadding.PaddingBottom = UDim.new(0, 4)
        ListPadding.Parent = List
        
        local playerButtons = {}
        local selectedPlayer = nil
        local markedPlayer = nil  -- For right-click marking (e.g., spoof target)
        
        local function clearPlayers()
            for _, btn in ipairs(playerButtons) do
                btn:Destroy()
            end
            playerButtons = {}
        end
        
        local function addPlayer(player, isSelected, isMarked)
            local PlayerBtn = Instance.new("TextButton")
            PlayerBtn.Size = UDim2.new(1, -8, 0, 32)
            PlayerBtn.BackgroundColor3 = isSelected and Theme.Success or (isMarked and Theme.AccentDark or Theme.BackgroundDark)
            PlayerBtn.BorderSizePixel = 0
            PlayerBtn.AutoButtonColor = false
            PlayerBtn.Parent = List
            
            local displayText = player.Name
            if isSelected and isMarked then
                displayText = displayText .. " [TARGET+MARK]"
            elseif isSelected then
                displayText = displayText .. " [TARGET]"
            elseif isMarked then
                displayText = displayText .. " [MARK]"
            end
            PlayerBtn.Text = displayText
            PlayerBtn.TextColor3 = Theme.Text
            PlayerBtn.TextSize = 12
            PlayerBtn.Font = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = PlayerBtn
            
            PlayerBtn.MouseEnter:Connect(function()
                if not isSelected and not isMarked then
                    PlayerBtn.BackgroundColor3 = Theme.Separator
                end
            end)
            PlayerBtn.MouseLeave:Connect(function()
                if not isSelected and not isMarked then
                    PlayerBtn.BackgroundColor3 = Theme.BackgroundDark
                end
            end)
            
            PlayerBtn.MouseButton1Click:Connect(function()
                if onPlayerClick then
                    onPlayerClick(player)
                end
            end)
            
            PlayerBtn.MouseButton2Click:Connect(function()
                if onPlayerRightClick then
                    onPlayerRightClick(player)
                end
            end)
            
            table.insert(playerButtons, PlayerBtn)
            return PlayerBtn
        end
        
        local function refresh(getSelectedFn, getMarkedFn)
            clearPlayers()
            local LocalPlayer = game:GetService("Players").LocalPlayer
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer then
                    local isSelected = getSelectedFn and getSelectedFn(player) or false
                    local isMarked = getMarkedFn and getMarkedFn(player) or false
                    addPlayer(player, isSelected, isMarked)
                end
            end
        end
        
        return {
            frame = ListFrame,
            list = List,
            addPlayer = addPlayer,
            clearPlayers = clearPlayers,
            refresh = refresh
        }
    end
    
    -- Helper: Create Keybind Button (click to capture a keybind)
    local function createKeybindButton(text, initialKey, onKeybindChanged)
        local currentKey = initialKey
        local isListening = false
        
        local Holder = Instance.new("Frame")
        Holder.Name = text .. "_Keybind"
        Holder.Size = UDim2.new(1, 0, 0, 28)
        Holder.BackgroundTransparency = 1
        Holder.LayoutOrder = nextLayoutOrder()
        Holder.Parent = Content
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -70, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Holder
        
        local KeyBtn = Instance.new("TextButton")
        KeyBtn.Size = UDim2.new(0, 60, 0, 22)
        KeyBtn.Position = UDim2.new(1, -62, 0.5, -11)
        KeyBtn.BackgroundColor3 = Theme.BackgroundLight
        KeyBtn.BorderSizePixel = 0
        KeyBtn.Text = currentKey.Name
        KeyBtn.TextColor3 = Theme.Text
        KeyBtn.TextSize = 10
        KeyBtn.Font = Enum.Font.GothamBold
        KeyBtn.AutoButtonColor = false
        KeyBtn.Parent = Holder
        
        local KeyBtnCorner = Instance.new("UICorner")
        KeyBtnCorner.CornerRadius = UDim.new(0, 3)
        KeyBtnCorner.Parent = KeyBtn
        
        local KeyBtnStroke = Instance.new("UIStroke")
        KeyBtnStroke.Color = Theme.Border
        KeyBtnStroke.Thickness = 1
        KeyBtnStroke.Transparency = 0.5
        KeyBtnStroke.Parent = KeyBtn
        
        KeyBtn.MouseButton1Click:Connect(function()
            isListening = true
            KeyBtn.Text = "..."
            KeyBtn.BackgroundColor3 = Theme.Accent
        end)
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not isListening then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                isListening = false
                currentKey = input.KeyCode
                KeyBtn.Text = currentKey.Name
                KeyBtn.BackgroundColor3 = Theme.BackgroundLight
                if onKeybindChanged then
                    onKeybindChanged(currentKey)
                end
            end
        end)
        connectionTracker.add(connection)
        
        return {
            holder = Holder,
            getKey = function() return currentKey end,
            setKey = function(key)
                currentKey = key
                KeyBtn.Text = key.Name
            end
        }
    end
    
    -- Helper: Create Keybind Row (compact keybind display with status)
    local function createKeybindRow(keyCode, labelText, initialStatus)
        local Holder = Instance.new("Frame")
        Holder.Name = labelText .. "_KeybindRow"
        Holder.Size = UDim2.new(1, 0, 0, 28)
        Holder.BackgroundTransparency = 1
        Holder.LayoutOrder = nextLayoutOrder()
        Holder.Parent = Content
        
        local KeyLabel = Instance.new("TextLabel")
        KeyLabel.Size = UDim2.new(0, 50, 1, 0)
        KeyLabel.BackgroundColor3 = Theme.BackgroundDark
        KeyLabel.BorderSizePixel = 0
        KeyLabel.Text = typeof(keyCode) == "EnumItem" and keyCode.Name or tostring(keyCode)
        KeyLabel.TextColor3 = Theme.Text
        KeyLabel.TextSize = 11
        KeyLabel.Font = Enum.Font.GothamBold
        KeyLabel.Parent = Holder
        
        local KeyCorner = Instance.new("UICorner")
        KeyCorner.CornerRadius = UDim.new(0, 3)
        KeyCorner.Parent = KeyLabel
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(1, -110, 1, 0)
        NameLabel.Position = UDim2.new(0, 56, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = labelText
        NameLabel.TextColor3 = Theme.TextDim
        NameLabel.TextSize = 11
        NameLabel.Font = Enum.Font.Gotham
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = Holder
        
        local StatusFrame = Instance.new("Frame")
        StatusFrame.Size = UDim2.new(0, 40, 0, 20)
        StatusFrame.Position = UDim2.new(1, -42, 0.5, -10)
        StatusFrame.BackgroundColor3 = initialStatus and Theme.Accent or Theme.BackgroundLight
        StatusFrame.BorderSizePixel = 0
        StatusFrame.Parent = Holder
        
        local StatusCorner = Instance.new("UICorner")
        StatusCorner.CornerRadius = UDim.new(0, 3)
        StatusCorner.Parent = StatusFrame
        
        local StatusText = Instance.new("TextLabel")
        StatusText.Size = UDim2.new(1, 0, 1, 0)
        StatusText.BackgroundTransparency = 1
        StatusText.Text = initialStatus and "ON" or "OFF"
        StatusText.TextColor3 = initialStatus and Theme.Text or Theme.TextDim
        StatusText.TextSize = 9
        StatusText.Font = Enum.Font.GothamBold
        StatusText.Parent = StatusFrame
        
        return {
            holder = Holder,
            setStatus = function(isOn)
                StatusFrame.BackgroundColor3 = isOn and Theme.Accent or Theme.BackgroundLight
                StatusText.Text = isOn and "ON" or "OFF"
                StatusText.TextColor3 = isOn and Theme.Text or Theme.TextDim
            end,
            setKey = function(key)
                KeyLabel.Text = typeof(key) == "EnumItem" and key.Name or tostring(key)
            end
        }
    end
    
    -- Helper: Create Progress Bar
    local function createProgressBar(initialProgress)
        local progress = initialProgress or 0
        
        local BarHolder = Instance.new("Frame")
        BarHolder.Name = "ProgressBar"
        BarHolder.Size = UDim2.new(1, 0, 0, 8)
        BarHolder.BackgroundColor3 = Theme.BackgroundDark
        BarHolder.BorderSizePixel = 0
        BarHolder.LayoutOrder = nextLayoutOrder()
        BarHolder.Parent = Content
        
        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(0, 3)
        BarCorner.Parent = BarHolder
        
        local BarFill = Instance.new("Frame")
        BarFill.Size = UDim2.new(progress, 0, 1, 0)
        BarFill.BackgroundColor3 = Theme.Accent
        BarFill.BorderSizePixel = 0
        BarFill.Parent = BarHolder
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 3)
        FillCorner.Parent = BarFill
        
        local FillGradient = Instance.new("UIGradient")
        FillGradient.Color = LunarityUI.AccentGradientSequence
        FillGradient.Parent = BarFill
        
        return {
            holder = BarHolder,
            fill = BarFill,
            setProgress = function(newProgress)
                progress = math.clamp(newProgress, 0, 1)
                BarFill.Size = UDim2.new(progress, 0, 1, 0)
            end,
            getProgress = function() return progress end
        }
    end
    
    -- Helper: Create Action Button with Icon Label
    local function createActionButton(text, iconText, onClick)
        local Holder = Instance.new("Frame")
        Holder.Name = text .. "_Action"
        Holder.Size = UDim2.new(1, 0, 0, 38)
        Holder.BackgroundColor3 = Theme.AccentDark
        Holder.BorderSizePixel = 0
        Holder.LayoutOrder = nextLayoutOrder()
        Holder.Parent = Content
        
        local HolderCorner = Instance.new("UICorner")
        HolderCorner.CornerRadius = UDim.new(0, 4)
        HolderCorner.Parent = Holder
        
        local HolderGradient = Instance.new("UIGradient")
        HolderGradient.Color = LunarityUI.AccentGradientSequence
        HolderGradient.Rotation = 90
        HolderGradient.Parent = Holder
        
        local ActionBtn = Instance.new("TextButton")
        ActionBtn.Size = UDim2.new(1, 0, 1, 0)
        ActionBtn.BackgroundTransparency = 1
        ActionBtn.Text = (iconText or "") .. " " .. text
        ActionBtn.TextColor3 = Theme.Text
        ActionBtn.TextSize = 14
        ActionBtn.Font = Enum.Font.GothamBold
        ActionBtn.AutoButtonColor = false
        ActionBtn.Parent = Holder
        
        ActionBtn.MouseButton1Click:Connect(function()
            if onClick then onClick() end
        end)
        
        ActionBtn.MouseEnter:Connect(function()
            Holder.BackgroundColor3 = Theme.AccentHover
        end)
        ActionBtn.MouseLeave:Connect(function()
            Holder.BackgroundColor3 = Theme.AccentDark
        end)
        
        return {
            holder = Holder,
            button = ActionBtn,
            setText = function(newText)
                ActionBtn.Text = (iconText or "") .. " " .. newText
            end
        }
    end
    
    -- Helper: Create Label with Value (e.g., "Target: None")
    local function createLabelValue(label, initialValue, valueColor)
        local Holder = Instance.new("Frame")
        Holder.Name = label .. "_LabelValue"
        Holder.Size = UDim2.new(1, 0, 0, 28)
        Holder.BackgroundColor3 = Theme.BackgroundLight
        Holder.BorderSizePixel = 0
        Holder.LayoutOrder = nextLayoutOrder()
        Holder.Parent = Content
        
        local HolderCorner = Instance.new("UICorner")
        HolderCorner.CornerRadius = UDim.new(0, 4)
        HolderCorner.Parent = Holder
        
        local LabelText = Instance.new("TextLabel")
        LabelText.Size = UDim2.new(1, -10, 1, 0)
        LabelText.Position = UDim2.new(0, 10, 0, 0)
        LabelText.BackgroundTransparency = 1
        LabelText.Text = label .. ": " .. tostring(initialValue)
        LabelText.TextColor3 = valueColor or Theme.TextDim
        LabelText.TextSize = 12
        LabelText.Font = Enum.Font.Gotham
        LabelText.TextXAlignment = Enum.TextXAlignment.Left
        LabelText.Parent = Holder
        
        return {
            holder = Holder,
            setValue = function(value, color)
                LabelText.Text = label .. ": " .. tostring(value)
                if color then
                    LabelText.TextColor3 = color
                end
            end,
            setColor = function(color)
                LabelText.TextColor3 = color
            end
        }
    end
    
    -- Helper: Create Separator Line
    local function createSeparator()
        local Sep = Instance.new("Frame")
        Sep.Size = UDim2.new(1, 0, 0, 1)
        Sep.BackgroundColor3 = Theme.Separator
        Sep.BorderSizePixel = 0
        Sep.LayoutOrder = nextLayoutOrder()
        Sep.Parent = Content
        return Sep
    end
    
    -- Return window object with all helper functions
    return {
        -- UI Elements
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        Content = Content,
        TitleBar = TitleBar,
        
        -- Connection management
        addConnection = connectionTracker.add,
        
        -- Cleanup
        destroy = function()
            connectionTracker.disconnectAll()
            ScreenGui:Destroy()
        end,
        
        -- UI Helpers
        createSection = createSection,
        createButton = createButton,
        createToggle = createToggle,
        createNumberBox = createNumberBox,
        createStatusBar = createStatusBar,
        createDropdownList = createDropdownList,
        createInfoLabel = createInfoLabel,
        createTextBox = createTextBox,
        createSlider = createSlider,
        createDropdown = createDropdown,
        createLargeToggle = createLargeToggle,
        createPlayerList = createPlayerList,
        createKeybindButton = createKeybindButton,
        createKeybindRow = createKeybindRow,
        createProgressBar = createProgressBar,
        createActionButton = createActionButton,
        createLabelValue = createLabelValue,
        createSeparator = createSeparator,
        
        -- Utility
        nextLayoutOrder = nextLayoutOrder,
    }
end

--[[
    Creates a floating panel (for displays like keybind overlay)
    
    @param options table {
        Name: string,
        Title: string?,
        Size: UDim2,
        Position: UDim2,
        Visible: boolean?,
        Draggable: boolean?
    }
]]
function LunarityUI.CreatePanel(options)
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")
    
    -- Cleanup existing
    local existing = CoreGui:FindFirstChild(options.Name)
    if existing then
        existing:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = options.Name
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    
    local Panel = Instance.new("Frame")
    Panel.Name = "Panel"
    Panel.Size = options.Size or UDim2.new(0, 200, 0, 100)
    Panel.Position = options.Position or UDim2.new(1, -210, 0, 10)
    Panel.BackgroundColor3 = Theme.Background
    Panel.BackgroundTransparency = 0.1
    Panel.BorderSizePixel = 0
    Panel.Visible = options.Visible ~= false
    Panel.Active = true
    Panel.Parent = ScreenGui
    
    local PanelGradient = Instance.new("UIGradient")
    PanelGradient.Color = LunarityUI.BackgroundGradientSequence
    PanelGradient.Rotation = 135
    PanelGradient.Parent = Panel
    
    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, 6)
    PanelCorner.Parent = Panel
    
    local PanelStroke = Instance.new("UIStroke")
    PanelStroke.Color = Theme.Border
    PanelStroke.Thickness = 1
    PanelStroke.Transparency = 0.3
    PanelStroke.Parent = Panel
    
    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 0, 0)
    AccentLine.BackgroundColor3 = Theme.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = Panel
    
    local AccentGradient = Instance.new("UIGradient")
    AccentGradient.Color = LunarityUI.AccentGradientSequence
    AccentGradient.Parent = AccentLine
    
    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 6)
    AccentCorner.Parent = AccentLine
    
    -- Content area with padding
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -16, 1, -12)
    Content.Position = UDim2.new(0, 8, 0, 8)
    Content.BackgroundTransparency = 1
    Content.Parent = Panel
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 4)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = Content
    
    -- Dragging support
    if options.Draggable ~= false then
        local dragging = false
        local dragInput, dragStart, startPos
        
        Panel.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Panel.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        Panel.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                Panel.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end
    
    local layoutOrder = 0
    local function nextLayoutOrder()
        layoutOrder = layoutOrder + 1
        return layoutOrder
    end
    
    -- Helper: Add keybind row to panel
    local function addKeybindRow(keyCode, labelText, initialStatus)
        local Holder = Instance.new("Frame")
        Holder.Size = UDim2.new(1, 0, 0, 28)
        Holder.BackgroundTransparency = 1
        Holder.LayoutOrder = nextLayoutOrder()
        Holder.Parent = Content
        
        local KeyLabel = Instance.new("TextLabel")
        KeyLabel.Size = UDim2.new(0, 50, 1, 0)
        KeyLabel.BackgroundColor3 = Theme.BackgroundDark
        KeyLabel.BorderSizePixel = 0
        KeyLabel.Text = typeof(keyCode) == "EnumItem" and keyCode.Name or tostring(keyCode)
        KeyLabel.TextColor3 = Theme.Text
        KeyLabel.TextSize = 11
        KeyLabel.Font = Enum.Font.GothamBold
        KeyLabel.Parent = Holder
        
        local KeyCorner = Instance.new("UICorner")
        KeyCorner.CornerRadius = UDim.new(0, 3)
        KeyCorner.Parent = KeyLabel
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(1, -110, 1, 0)
        NameLabel.Position = UDim2.new(0, 56, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = labelText
        NameLabel.TextColor3 = Theme.TextDim
        NameLabel.TextSize = 11
        NameLabel.Font = Enum.Font.Gotham
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = Holder
        
        local StatusFrame = Instance.new("Frame")
        StatusFrame.Size = UDim2.new(0, 40, 0, 20)
        StatusFrame.Position = UDim2.new(1, -42, 0.5, -10)
        StatusFrame.BackgroundColor3 = initialStatus and Theme.Accent or Theme.BackgroundLight
        StatusFrame.BorderSizePixel = 0
        StatusFrame.Parent = Holder
        
        local StatusCorner = Instance.new("UICorner")
        StatusCorner.CornerRadius = UDim.new(0, 3)
        StatusCorner.Parent = StatusFrame
        
        local StatusText = Instance.new("TextLabel")
        StatusText.Size = UDim2.new(1, 0, 1, 0)
        StatusText.BackgroundTransparency = 1
        StatusText.Text = initialStatus and "ON" or "OFF"
        StatusText.TextColor3 = initialStatus and Theme.Text or Theme.TextDim
        StatusText.TextSize = 9
        StatusText.Font = Enum.Font.GothamBold
        StatusText.Parent = StatusFrame
        
        return {
            holder = Holder,
            setStatus = function(isOn)
                StatusFrame.BackgroundColor3 = isOn and Theme.Accent or Theme.BackgroundLight
                StatusText.Text = isOn and "ON" or "OFF"
                StatusText.TextColor3 = isOn and Theme.Text or Theme.TextDim
            end,
            setKey = function(key)
                KeyLabel.Text = typeof(key) == "EnumItem" and key.Name or tostring(key)
            end
        }
    end
    
    return {
        ScreenGui = ScreenGui,
        Panel = Panel, 
        Content = Content,
        addKeybindRow = addKeybindRow,
        show = function() ScreenGui.Enabled = true end,
        hide = function() ScreenGui.Enabled = false end,
        toggle = function() ScreenGui.Enabled = not ScreenGui.Enabled end,
        destroy = function() ScreenGui:Destroy() end
    }
end

--[[
    Creates an animated loading screen
    
    @param options table {
        Name: string,
        Title: string,
        OnComplete: function?
    }
]]
function LunarityUI.CreateLoadingScreen(options)
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = options.Name or "LunarityLoading"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    
    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Size = UDim2.new(0, 300, 0, 140)
    LoadingFrame.Position = UDim2.new(0.5, -150, 0.5, -70)
    LoadingFrame.BackgroundColor3 = Theme.Background
    LoadingFrame.BorderSizePixel = 0
    LoadingFrame.Parent = ScreenGui
    
    local FrameGradient = Instance.new("UIGradient")
    FrameGradient.Color = LunarityUI.BackgroundGradientSequence
    FrameGradient.Rotation = 45
    FrameGradient.Parent = LoadingFrame
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 8)
    FrameCorner.Parent = LoadingFrame
    
    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Color = Theme.Border
    FrameStroke.Thickness = 1
    FrameStroke.Transparency = 0.3
    FrameStroke.Parent = LoadingFrame
    
    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 3)
    AccentLine.BackgroundColor3 = Theme.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = LoadingFrame
    
    local AccentGradient = Instance.new("UIGradient")
    AccentGradient.Color = LunarityUI.AccentGradientSequence
    AccentGradient.Parent = AccentLine
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 40)
    Title.Position = UDim2.new(0, 20, 0, 20)
    Title.BackgroundTransparency = 1
    Title.Text = options.Title or "Lunarity"
    Title.TextColor3 = Theme.Text
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Center
    Title.Parent = LoadingFrame
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, -40, 0, 20)
    StatusText.Position = UDim2.new(0, 20, 0, 60)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Initializing..."
    StatusText.TextColor3 = Theme.TextDim
    StatusText.TextSize = 12
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextXAlignment = Enum.TextXAlignment.Center
    StatusText.Parent = LoadingFrame
    
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Size = UDim2.new(1, -40, 0, 6)
    ProgressBg.Position = UDim2.new(0, 20, 0, 95)
    ProgressBg.BackgroundColor3 = Theme.BackgroundDark
    ProgressBg.BorderSizePixel = 0
    ProgressBg.Parent = LoadingFrame
    
    local ProgressBgCorner = Instance.new("UICorner")
    ProgressBgCorner.CornerRadius = UDim.new(0, 3)
    ProgressBgCorner.Parent = ProgressBg
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = Theme.Accent
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = ProgressBg
    
    local ProgressGradient = Instance.new("UIGradient")
    ProgressGradient.Color = LunarityUI.AccentGradientSequence
    ProgressGradient.Parent = ProgressBar
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 3)
    ProgressCorner.Parent = ProgressBar
    
    local function animateProgress(stages, onComplete)
        task.spawn(function()
            for _, stage in ipairs(stages) do
                StatusText.Text = stage.text
                TweenService:Create(ProgressBar, TweenInfo.new(stage.time or 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(stage.progress, 0, 1, 0)
                }):Play()
                task.wait(stage.time or 1)
            end
            
            task.wait(0.3)
            
            -- Fade out
            local fadeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(LoadingFrame, fadeInfo, {BackgroundTransparency = 1}):Play()
            TweenService:Create(Title, fadeInfo, {TextTransparency = 1}):Play()
            TweenService:Create(StatusText, fadeInfo, {TextTransparency = 1}):Play()
            TweenService:Create(ProgressBg, fadeInfo, {BackgroundTransparency = 1}):Play()
            TweenService:Create(ProgressBar, fadeInfo, {BackgroundTransparency = 1}):Play()
            TweenService:Create(AccentLine, fadeInfo, {BackgroundTransparency = 1}):Play()
            
            task.wait(0.5)
            ScreenGui:Destroy()
            
            if onComplete then onComplete() end
        end)
    end
    
    return {
        ScreenGui = ScreenGui,
        LoadingFrame = LoadingFrame,
        setStatus = function(text) StatusText.Text = text end,
        setProgress = function(progress)
            ProgressBar.Size = UDim2.new(math.clamp(progress, 0, 1), 0, 1, 0)
        end,
        animate = animateProgress,
        destroy = function() ScreenGui:Destroy() end
    }
end

-- Expose Theme for external use
LunarityUI.Colors = Theme

return LunarityUI
