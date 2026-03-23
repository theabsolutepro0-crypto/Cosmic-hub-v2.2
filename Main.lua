-- REDZ HUB v2.0 | FULL FIX — Mobile + Sliders + Sidebar + Toggle Button
-- LocalScript inside StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- =====================================================
-- FLY SYSTEM (mobile + keyboard)
-- =====================================================
local flying = false
local flySpeed = 50
local flyConnection

-- Mobile virtual input state
local mobileInput = {
    forward = false, back = false,
    left = false, right = false,
    up = false, down = false
}

local function getFlyDirection()
    local camera = workspace.CurrentCamera
    local dir = Vector3.zero
    -- Keyboard
    if UserInputService:IsKeyDown(Enum.KeyCode.W) or mobileInput.forward then dir += camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) or mobileInput.back    then dir -= camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) or mobileInput.left    then dir -= camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) or mobileInput.right   then dir += camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or mobileInput.up  then dir += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q) or mobileInput.down then
        dir -= Vector3.new(0,1,0)
    end
    return dir
end

local function startFly()
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    humanoid.PlatformStand = true
    for _, n in ipairs({"FlyVelocity","FlyGyro"}) do
        local old = hrp:FindFirstChild(n)
        if old then old:Destroy() end
    end
    local att = hrp:FindFirstChild("RootAttachment") or Instance.new("Attachment", hrp)
    local bv = Instance.new("LinearVelocity")
    bv.Name = "FlyVelocity"
    bv.Attachment0 = att
    bv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    bv.MaxForce = 1e6
    bv.RelativeTo = Enum.ActuatorRelativeTo.World
    bv.VectorVelocity = Vector3.zero
    bv.Parent = hrp
    local ba = Instance.new("AlignOrientation")
    ba.Name = "FlyGyro"
    ba.Mode = Enum.OrientationAlignmentMode.OneAttachment
    ba.Attachment0 = att
    ba.MaxTorque = 1e6
    ba.Responsiveness = 50
    ba.CFrame = workspace.CurrentCamera.CFrame
    ba.Parent = hrp
    flyConnection = RunService.Heartbeat:Connect(function(dt)
        if not flying then return end
        local dir = getFlyDirection()
        local target = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
        bv.VectorVelocity = bv.VectorVelocity:Lerp(target, math.min(1, dt * 12))
        ba.CFrame = workspace.CurrentCamera.CFrame
    end)
end

local function stopFly()
    flying = false
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = false end
    if hrp then
        local bv = hrp:FindFirstChild("FlyVelocity")
        local ba = hrp:FindFirstChild("FlyGyro")
        if bv then bv:Destroy() end
        if ba then ba:Destroy() end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if flying then startFly() end
end)

-- =====================================================
-- NDS FEATURES
-- =====================================================
local godMode = false
local godConnection
local infiniteJump = false
local noclip = false
local noclipConnection

local function toggleGodMode(state)
    godMode = state
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if godMode then
        humanoid.MaxHealth = 1e6
        humanoid.Health = 1e6
        godConnection = RunService.Heartbeat:Connect(function()
            if humanoid and humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    else
        humanoid.MaxHealth = 100
        humanoid.Health = 100
        if godConnection then godConnection:Disconnect() godConnection = nil end
    end
end

UserInputService.JumpRequest:Connect(function()
    if not infiniteJump then return end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

local function setWalkSpeed(val)
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = val end
end

local function setJumpPower(val)
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.JumpPower = val end
end

local function toggleNoclip(state)
    noclip = state
    if noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            local character = LocalPlayer.Character
            if not character then return end
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if godMode then toggleGodMode(true) end
    if noclip then toggleNoclip(true) end
end)

-- =====================================================
-- GUI SETUP
-- =====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RedzHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- =====================================================
-- FLOATING TOGGLE BUTTON (draggable, always visible)
-- =====================================================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 54, 0, 54)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -27)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(229, 57, 53)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "RZ"
ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.ZIndex = 10
ToggleBtn.Active = true
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 27)
local tStroke = Instance.new("UIStroke", ToggleBtn)
tStroke.Color = Color3.fromRGB(255,255,255)
tStroke.Thickness = 1.5

-- Make toggle button draggable
local togDragging, togDragStart, togStartPos = false, nil, nil
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        togDragging = true
        togDragStart = input.Position
        togStartPos = ToggleBtn.Position
    end
end)
ToggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        togDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if togDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - togDragStart
        ToggleBtn.Position = UDim2.new(
            togStartPos.X.Scale, togStartPos.X.Offset + delta.X,
            togStartPos.Y.Scale, togStartPos.Y.Offset + delta.Y
        )
    end
end)

-- =====================================================
-- MAIN FRAME
-- =====================================================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 460, 0, 420)
Main.Position = UDim2.new(0.5, -230, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(26, 26, 46)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(229, 57, 53)
stroke.Thickness = 1.5

-- Toggle show/hide
local hubVisible = true
ToggleBtn.MouseButton1Click:Connect(function()
    if togDragging then return end
    hubVisible = not hubVisible
    Main.Visible = hubVisible
    ToggleBtn.Text = hubVisible and "RZ" or "RZ"
    ToggleBtn.BackgroundColor3 = hubVisible and Color3.fromRGB(229,57,53) or Color3.fromRGB(60,60,90)
end)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundColor3 = Color3.fromRGB(229, 57, 53)
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Text = "REDZ HUB  v2.0"
Title.Size = UDim2.new(1,-40,1,0)
Title.Position = UDim2.new(0,12,0,0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0,30,0,30)
CloseBtn.Position = UDim2.new(1,-35,0,3)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.Parent = Header
CloseBtn.MouseButton1Click:Connect(function()
    stopFly()
    toggleGodMode(false)
    toggleNoclip(false)
    ScreenGui:Destroy()
end)

-- =====================================================
-- TABS
-- =====================================================
local tabNames = {"Combat", "Movement", "NDS", "Misc"}
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,30)
TabBar.Position = UDim2.new(0,0,0,36)
TabBar.BackgroundColor3 = Color3.fromRGB(18,18,42)
TabBar.BorderSizePixel = 0
TabBar.Parent = Main
local tabLayout = Instance.new("UIListLayout", TabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local panels = {}
local tabBtns = {}

local function makePanel(visible)
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1,-110,1,-108)
    p.Position = UDim2.new(0,110,0,66)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = Color3.fromRGB(229,57,53)
    p.CanvasSize = UDim2.new(0,0,0,0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Visible = visible
    p.Parent = Main
    local layout = Instance.new("UIListLayout", p)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,0)
    return p
end

for i, name in ipairs(tabNames) do
    local Tab = Instance.new("TextButton")
    Tab.Text = name
    Tab.Size = UDim2.new(0,115,1,0)
    Tab.BackgroundTransparency = 1
    Tab.TextColor3 = i == 3 and Color3.fromRGB(229,57,53) or Color3.fromRGB(150,150,150)
    Tab.TextSize = 11
    Tab.Font = Enum.Font.Gotham
    Tab.LayoutOrder = i
    Tab.Parent = TabBar
    tabBtns[i] = Tab
    panels[i] = makePanel(i == 3)
    Tab.MouseButton1Click:Connect(function()
        for j, p in ipairs(panels) do
            p.Visible = j == i
            tabBtns[j].TextColor3 = j == i and Color3.fromRGB(229,57,53) or Color3.fromRGB(150,150,150)
        end
    end)
end

-- =====================================================
-- SIDEBAR (scrollable, functional)
-- =====================================================
local sidebarItems = {"Fly", "God Mode", "Noclip", "Inf Jump", "Walk Spd", "Jump Pwr", "Fly Spd"}

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0,110,1,-108)
Sidebar.Position = UDim2.new(0,0,0,66)
Sidebar.BackgroundColor3 = Color3.fromRGB(18,18,42)
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 2
Sidebar.ScrollBarImageColor3 = Color3.fromRGB(229,57,53)
Sidebar.CanvasSize = UDim2.new(0,0,0,0)
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.Parent = Main
local sideLayout = Instance.new("UIListLayout", Sidebar)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder

local sideButtons = {}
for i, item in ipairs(sidebarItems) do
    local Btn = Instance.new("TextButton")
    Btn.Text = item
    Btn.Size = UDim2.new(1,0,0,36)
    Btn.BackgroundTransparency = i == 1 and 0.85 or 1
    Btn.BackgroundColor3 = Color3.fromRGB(26,26,46)
    Btn.TextColor3 = i == 1 and Color3.fromRGB(229,57,53) or Color3.fromRGB(170,170,170)
    Btn.TextSize = 11
    Btn.Font = Enum.Font.Gotham
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.LayoutOrder = i
    Btn.Parent = Sidebar
    local Pad = Instance.new("UIPadding", Btn)
    Pad.PaddingLeft = UDim.new(0,12)
    sideButtons[i] = Btn
end

-- Sidebar highlight helper
local function setSideActive(idx)
    for i, b in ipairs(sideButtons) do
        b.BackgroundTransparency = i == idx and 0.85 or 1
        b.TextColor3 = i == idx and Color3.fromRGB(229,57,53) or Color3.fromRGB(170,170,170)
    end
end

-- =====================================================
-- HELPERS: Toggle + Slider (with mobile/touch support)
-- =====================================================
local function makeToggle(parent, label, order, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1,0,0,44)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.Parent = parent

    local Pad = Instance.new("UIPadding", Row)
    Pad.PaddingLeft = UDim.new(0,10)
    Pad.PaddingRight = UDim.new(0,10)

    local Lbl = Instance.new("TextLabel")
    Lbl.Text = label
    Lbl.Size = UDim2.new(1,-50,1,0)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = Color3.fromRGB(200,200,200)
    Lbl.TextSize = 12
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row

    local Tog = Instance.new("TextButton")
    Tog.Size = UDim2.new(0,40,0,22)
    Tog.Position = UDim2.new(1,-40,0.5,-11)
    Tog.BackgroundColor3 = Color3.fromRGB(42,42,74)
    Tog.BorderSizePixel = 0
    Tog.Text = ""
    Tog.Parent = Row
    Instance.new("UICorner", Tog).CornerRadius = UDim.new(1,0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0,16,0,16)
    Knob.Position = UDim2.new(0,3,0.5,-8)
    Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Tog
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

    local Div = Instance.new("Frame")
    Div.Size = UDim2.new(1,0,0,1)
    Div.Position = UDim2.new(0,0,1,-1)
    Div.BackgroundColor3 = Color3.fromRGB(42,42,74)
    Div.BorderSizePixel = 0
    Div.Parent = Row

    local on = false
    local function flip()
        on = not on
        TweenService:Create(Tog, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Color3.fromRGB(229,57,53) or Color3.fromRGB(42,42,74)
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.15), {
            Position = on and UDim2.new(0,21,0.5,-8) or UDim2.new(0,3,0.5,-8)
        }):Play()
        callback(on)
    end
    Tog.MouseButton1Click:Connect(flip)
    -- Touch support
    Tog.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then flip() end
    end)
    return Row
end

local function makeSlider(parent, label, order, minVal, maxVal, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1,0,0,56)
    Container.BackgroundTransparency = 1
    Container.LayoutOrder = order
    Container.Parent = parent

    local Pad = Instance.new("UIPadding", Container)
    Pad.PaddingLeft = UDim.new(0,10)
    Pad.PaddingRight = UDim.new(0,10)

    local LblRow = Instance.new("Frame")
    LblRow.Size = UDim2.new(1,0,0,24)
    LblRow.BackgroundTransparency = 1
    LblRow.Parent = Container

    local Lbl = Instance.new("TextLabel")
    Lbl.Text = label
    Lbl.Size = UDim2.new(0.7,0,1,0)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = Color3.fromRGB(200,200,200)
    Lbl.TextSize = 12
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = LblRow

    local ValLbl = Instance.new("TextLabel")
    ValLbl.Text = tostring(default)
    ValLbl.Size = UDim2.new(0.3,0,1,0)
    ValLbl.Position = UDim2.new(0.7,0,0,0)
    ValLbl.BackgroundTransparency = 1
    ValLbl.TextColor3 = Color3.fromRGB(229,57,53)
    ValLbl.TextSize = 12
    ValLbl.Font = Enum.Font.GothamBold
    ValLbl.TextXAlignment = Enum.TextXAlignment.Right
    ValLbl.Parent = LblRow

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1,0,0,8)
    Track.Position = UDim2.new(0,0,0,30)
    Track.BackgroundColor3 = Color3.fromRGB(42,42,74)
    Track.BorderSizePixel = 0
    Track.Parent = Container
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1,0)

    local initRel = (default - minVal) / (maxVal - minVal)
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(initRel,0,1,0)
    Fill.BackgroundColor3 = Color3.fromRGB(229,57,53)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)

    local SKnob = Instance.new("TextButton")
    SKnob.Size = UDim2.new(0,20,0,20)
    SKnob.Position = UDim2.new(initRel,-10,0.5,-10)
    SKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    SKnob.BorderSizePixel = 0
    SKnob.Text = ""
    SKnob.ZIndex = 5
    SKnob.Parent = Track
    Instance.new("UICorner", SKnob).CornerRadius = UDim.new(1,0)

    local Div = Instance.new("Frame")
    Div.Size = UDim2.new(1,0,0,1)
    Div.Position = UDim2.new(0,0,1,0)
    Div.BackgroundColor3 = Color3.fromRGB(42,42,74)
    Div.BorderSizePixel = 0
    Div.Parent = Container

    local function updateSlider(xPos)
        local rel = math.clamp((xPos - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + rel * (maxVal - minVal))
        ValLbl.Text = tostring(val)
        Fill.Size = UDim2.new(rel,0,1,0)
        SKnob.Position = UDim2.new(rel,-10,0.5,-10)
        callback(val)
    end

    local dragging = false
    -- Mouse support
    SKnob.MouseButton1Down:Connect(function() dragging = true end)
    Track.MouseButton1Down:Connect(function()
        dragging = true
        updateSlider(UserInputService:GetMouseLocation().X)
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(i.Position.X)
        end
    end)
    -- Touch support
    SKnob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    SKnob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    SKnob.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    Track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(i.Position.X)
        end
    end)
    Track.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.Touch then
            updateSlider(i.Position.X)
        end
    end)

    return Container
end

-- =====================================================
-- BUILD NDS PANEL (panel 3 = index 3)
-- =====================================================
local ndsPanel = panels[3]

local function sectionHeader(text, order)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1,0,0,28)
    F.BackgroundTransparency = 1
    F.LayoutOrder = order
    F.Parent = ndsPanel
    local L = Instance.new("TextLabel")
    L.Text = text
    L.Size = UDim2.new(1,-10,1,0)
    L.Position = UDim2.new(0,10,0,0)
    L.BackgroundTransparency = 1
    L.TextColor3 = Color3.fromRGB(229,57,53)
    L.TextSize = 10
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = F
end

sectionHeader("NATURAL DISASTER SURVIVAL", 1)

local flyToggleRow = makeToggle(ndsPanel, "Fly", 2, function(on)
    flying = on
    if on then startFly() else stopFly() end
end)

makeToggle(ndsPanel, "God Mode", 3, function(on)
    toggleGodMode(on)
end)

makeToggle(ndsPanel, "Noclip (pass through debris)", 4, function(on)
    toggleNoclip(on)
end)

makeToggle(ndsPanel, "Infinite Jump", 5, function(on)
    infiniteJump = on
end)

sectionHeader("SPEED & POWER", 6)

makeSlider(ndsPanel, "Walk Speed", 7, 16, 150, 16, function(val)
    setWalkSpeed(val)
end)

makeSlider(ndsPanel, "Jump Power", 8, 50, 300, 50, function(val)
    setJumpPower(val)
end)

makeSlider(ndsPanel, "Fly Speed", 9, 10, 200, 50, function(val)
    flySpeed = val
end)

-- =====================================================
-- SIDEBAR â†’ SCROLL TO SECTION
-- =====================================================
-- Map sidebar index to NDS panel scroll position
local sideScrollMap = {
    [1] = 0,    -- Fly
    [2] = 44,   -- God Mode
    [3] = 88,   -- Noclip
    [4] = 132,  -- Inf Jump
    [5] = 204,  -- Walk Speed
    [6] = 260,  -- Jump Power
    [7] = 316,  -- Fly Speed
}

for i, btn in ipairs(sideButtons) do
    btn.MouseButton1Click:Connect(function()
        setSideActive(i)
        -- Switch to NDS tab
        for j, p in ipairs(panels) do
            p.Visible = j == 3
            tabBtns[j].TextColor3 = j == 3 and Color3.fromRGB(229,57,53) or Color3.fromRGB(150,150,150)
        end
        -- Scroll to section
        if sideScrollMap[i] then
            TweenService:Create(ndsPanel, TweenInfo.new(0.3), {
                CanvasPosition = Vector2.new(0, sideScrollMap[i])
            }):Play()
        end
    end)
    -- Touch support for sidebar
    btn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            setSideActive(i)
            for j, p in ipairs(panels) do
                p.Visible = j == 3
                tabBtns[j].TextColor3 = j == 3 and Color3.fromRGB(229,57,53) or Color3.fromRGB(150,150,150)
            end
            if sideScrollMap[i] then
                TweenService:Create(ndsPanel, TweenInfo.new(0.3), {
                    CanvasPosition = Vector2.new(0, sideScrollMap[i])
                }):Play()
            end
        end
    end)
end

-- =====================================================
-- MOBILE FLY D-PAD (only shows when fly is ON)
-- =====================================================
local DPad = Instance.new("Frame")
DPad.Size = UDim2.new(0, 140, 0, 140)
DPad.Position = UDim2.new(0, 20, 1, -180)
DPad.BackgroundTransparency = 1
DPad.Visible = false
DPad.ZIndex = 10
DPad.Parent = ScreenGui

local VertPad = Instance.new("Frame")
VertPad.Size = UDim2.new(0, 80, 0, 80)
VertPad.Position = UDim2.new(1, 10, 1, -100)
VertPad.BackgroundTransparency = 1
VertPad.Visible = false
VertPad.ZIndex = 10
VertPad.Parent = ScreenGui

local function makeDBtn(parent, text, x, y, w, h, onHold)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,w,0,h)
    btn.Position = UDim2.new(0,x,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,70)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 11
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    local stroke2 = Instance.new("UIStroke", btn)
    stroke2.Color = Color3.fromRGB(229,57,53)
    stroke2.Thickness = 1
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            onHold(true)
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            onHold(false)
        end
    end)
    return btn
end

-- D-Pad directional buttons
makeDBtn(DPad, "â–²", 46, 0,  48, 44, function(s) mobileInput.forward = s end)
makeDBtn(DPad, "â–¼", 46, 96, 48, 44, function(s) mobileInput.back    = s end)
makeDBtn(DPad, "â—€", 0,  46, 44, 48, function(s) mobileInput.left    = s end)
makeDBtn(DPad, "â–¶", 96, 46, 44, 48, function(s) mobileInput.right   = s end)

-- Center circle
local Center = Instance.new("Frame")
Center.Size = UDim2.new(0,40,0,40)
Center.Position = UDim2.new(0,50,0,50)
Center.BackgroundColor3 = Color3.fromRGB(30,30,55)
Center.BorderSizePixel = 0
Center.ZIndex = 11
Center.Parent = DPad
Instance.new("UICorner", Center).CornerRadius = UDim.new(1,0)

-- Up/Down vertical buttons
makeDBtn(VertPad, "â†‘", 0,  0,  80, 36, function(s) mobileInput.up   = s end)
makeDBtn(VertPad, "â†“", 0,  44, 80, 36, function(s) mobileInput.down = s end)

-- Show/hide dpad with fly toggle
local origFlyCallback = function(on)
    flying = on
    DPad.Visible = on
    VertPad.Visible = on
    if on then startFly() else stopFly() end
end
-- Patch the fly toggle row's button callback
for _, v in ipairs(flyToggleRow:GetDescendants()) do
    if v:IsA("TextButton") then
        -- Override the connection by disconnecting and reconnecting isn't possible cleanly,
        -- so we use a BindableEvent workaround â€” instead we set mobileInput visibility via RunService
        break
    end
end

-- Simpler: watch flying state each frame to sync dpad visibility
RunService.Heartbeat:Connect(function()
    DPad.Visible = flying
    VertPad.Visible = flying
end)

-- =====================================================
-- FOOTER
-- =====================================================
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1,0,0,24)
Footer.Position = UDim2.new(0,0,1,-24)
Footer.BackgroundColor3 = Color3.fromRGB(18,18,42)
Footer.BorderSizePixel = 0
Footer.Parent = Main

local FooterText = Instance.new("TextLabel")
FooterText.Text = "redzHub.lua  â€”  tap RZ button to hide/show"
FooterText.Size = UDim2.new(1,0,1,0)
FooterText.BackgroundTransparency = 1
FooterText.TextColor3 = Color3.fromRGB(80,80,100)
FooterText.TextSize = 10
FooterText.Font = Enum.Font.Gotham
FooterText.Parent = Footer
