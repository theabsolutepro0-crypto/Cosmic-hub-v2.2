-- 🔥 NATURAL DISASTER SURVIVAL (NDS) ULTIMATE 2026 SCRIPT
-- EVERY POSSIBLE FEATURE + YOUR EXACT MOBILE FLY WITH JOYSTICK
-- God Mode, Noclip, Inf Jump, No Fall, Speed, Gravity, ESP, Fling, TP to Highest Point, TP to Winners Island, Server Hop + more
-- Tap "NDS HUB" to open full menu | Separate "FLY" button for joystick

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==================== YOUR EXACT FLY SCRIPT (unchanged) ====================
local flying = false
local flySpeed = 70

local bv, bg
local joystickActive = false
local joystickCenter = Vector2.new()
local joystickTouchId = nil
local moveInput = Vector2.new(0, 0)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NDS_UltimateHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Toggle button (small circle, draggable)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 65, 0, 65)
toggleBtn.Position = UDim2.new(0.07, 0, 0.8, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Text = "FLY"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 18
toggleBtn.BorderSizePixel = 0
toggleBtn.BackgroundTransparency = 0.4
toggleBtn.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1,0)
corner.Parent = toggleBtn

-- Joystick (hidden until flying)
local joystickFrame = Instance.new("Frame")
joystickFrame.Size = UDim2.new(0, 140, 0, 140)
joystickFrame.Position = UDim2.new(0.15, 0, 0.65, 0)
joystickFrame.BackgroundTransparency = 1
joystickFrame.Visible = false
joystickFrame.Parent = screenGui

local outerRing = Instance.new("Frame")
outerRing.Size = UDim2.new(1,0,1,0)
outerRing.BackgroundColor3 = Color3.fromRGB(80,80,80)
outerRing.BackgroundTransparency = 0.7
outerRing.BorderSizePixel = 0
outerRing.Parent = joystickFrame
local outerCorner = Instance.new("UICorner")
outerCorner.CornerRadius = UDim.new(1,0)
outerCorner.Parent = outerRing

local innerStick = Instance.new("Frame")
innerStick.Size = UDim2.new(0, 50, 0, 50)
innerStick.Position = UDim2.new(0.5, -25, 0.5, -25)
innerStick.BackgroundColor3 = Color3.fromRGB(200,200,200)
innerStick.BackgroundTransparency = 0.3
innerStick.BorderSizePixel = 0
innerStick.Parent = joystickFrame
local stickCorner = Instance.new("UICorner")
stickCorner.CornerRadius = UDim.new(1,0)
stickCorner.Parent = innerStick

-- Drag toggle button
local dragging, dragStart, startPosToggle
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosToggle = toggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        toggleBtn.Position = UDim2.new(startPosToggle.X.Scale, startPosToggle.X.Offset + delta.X, startPosToggle.Y.Scale, startPosToggle.Y.Offset + delta.Y)
    end
end)

-- Joystick logic (touch drag)
joystickFrame.InputBegan:Connect(function(input)
    if flying and input.UserInputType == Enum.UserInputType.Touch and not joystickTouchId then
        joystickTouchId = input
        joystickCenter = Vector2.new(input.Position.X, input.Position.Y)
        joystickActive = true
    end
end)

joystickFrame.InputChanged:Connect(function(input)
    if joystickActive and input == joystickTouchId then
        local pos = Vector2.new(input.Position.X, input.Position.Y)
        local delta = pos - joystickCenter
        local mag = math.min(delta.Magnitude, 60)
        local dir = delta.Unit * mag
        
        moveInput = delta / 60
        innerStick.Position = UDim2.new(0.5, dir.X - 25, 0.5, dir.Y - 25)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == joystickTouchId then
        joystickTouchId = nil
        joystickActive = false
        moveInput = Vector2.new(0,0)
        innerStick.Position = UDim2.new(0.5, -25, 0.5, -25)
    end
end)

local function getHRP()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function startFlying()
    local hrp = getHRP()
    if not hrp then return end
    
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6,1e6,1e6)
    bv.Velocity = Vector3.new()
    bv.Parent = hrp
    
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(4e5,4e5,4e5)
    bg.P = 12000
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    
    flying = true
    toggleBtn.Text = "STOP"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    joystickFrame.Visible = true
end

local function stopFlying()
    flying = false
    toggleBtn.Text = "FLY"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    joystickFrame.Visible = false
    moveInput = Vector2.new(0,0)
    
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

toggleBtn.MouseButton1Click:Connect(function()
    if flying then stopFlying() else startFlying() end
end)

-- Fly movement (your exact code)
RunService.RenderStepped:Connect(function()
    if not flying then return end
    
    local hrp = getHRP()
    if not hrp then stopFlying() return end
    
    local cam = workspace.CurrentCamera
    
    local horiz = Vector3.new(moveInput.X, 0, -moveInput.Y)
    
    local vert = 0
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService.TouchEnabled and UserInputService:GetFocusedTextBox() == nil then
        vert = vert + (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        vert = vert - 1
    end
    
    local direction = horiz + Vector3.new(0, vert, 0)
    local moveDir = Vector3.new()
    if direction.Magnitude > 0 then
        moveDir = direction.Unit
    end
    
    local finalVel = 
        cam.CFrame.RightVector * moveDir.X +
        Vector3.yAxis * moveDir.Y +
        cam.CFrame.LookVector * moveDir.Z
    
    bv.Velocity = finalVel * flySpeed
    
    bg.CFrame = cam.CFrame
end)

-- ==================== NDS HUB MENU (ALL FEATURES) ====================
local hubBtn = Instance.new("TextButton")
hubBtn.Size = UDim2.new(0, 75, 0, 75)
hubBtn.Position = UDim2.new(0.85, 0, 0.1, 0)
hubBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
hubBtn.Text = "NDS\nHUB"
hubBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
hubBtn.Font = Enum.Font.SourceSansBold
hubBtn.TextSize = 20
hubBtn.Parent = screenGui
Instance.new("UICorner", hubBtn).CornerRadius = UDim.new(1,0)

local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 340, 0, 520)
menuFrame.Position = UDim2.new(0.5, -170, 0.5, -260)
menuFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
menuFrame.Visible = false
menuFrame.Parent = screenGui
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,45)
title.BackgroundTransparency = 1
title.Text = "NATURAL DISASTER SURVIVAL - ULTIMATE HUB"
title.TextColor3 = Color3.fromRGB(0,255,120)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24
title.Parent = menuFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-20,1,-60)
scroll.Position = UDim2.new(0,10,0,50)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 8
scroll.CanvasSize = UDim2.new(0,0,0,1200)
scroll.Parent = menuFrame
Instance.new("UIListLayout", scroll).Padding = UDim.new(0,10)

-- Helper functions
local function createToggle(name, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,50)
    f.BackgroundColor3 = Color3.fromRGB(35,35,35)
    f.Parent = scroll
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "   " .. name
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 18
    lbl.Parent = f
    
    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(0,85,0,35)
    tog.Position = UDim2.new(0.82,0,0.5,-17)
    tog.BackgroundColor3 = default and Color3.fromRGB(0,200,70) or Color3.fromRGB(90,90,90)
    tog.Text = default and "ON" or "OFF"
    tog.TextColor3 = Color3.new(1,1,1)
    tog.Font = Enum.Font.SourceSansBold
    tog.Parent = f
    Instance.new("UICorner", tog).CornerRadius = UDim.new(0,8)
    
    local state = default
    tog.MouseButton1Click:Connect(function()
        state = not state
        tog.BackgroundColor3 = state and Color3.fromRGB(0,200,70) or Color3.fromRGB(90,90,90)
        tog.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

local function createSlider(name, minv, maxv, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,65)
    f.BackgroundColor3 = Color3.fromRGB(35,35,35)
    f.Parent = scroll
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,20)
    lbl.BackgroundTransparency = 1
    lbl.Text = name .. ": " .. default
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Parent = f
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0.85,0,0,12)
    bar.Position = UDim2.new(0.075,0,0.55,0)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-minv)/(maxv-minv),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    
    local dragging = false
    bar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local perc = math.clamp((inp.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(minv + (maxv-minv)*perc)
            fill.Size = UDim2.new(perc,0,1,0)
            lbl.Text = name .. ": " .. val
            callback(val)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)
end

local function createButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,45)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Parent = scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    btn.MouseButton1Click:Connect(callback)
end

-- ==================== ALL FEATURES ====================

-- Movement Toggles
createToggle("God Mode (Invincible)", true, function(s)
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.MaxHealth = s and 9e9 or 100; hum.Health = hum.MaxHealth end
end)

createToggle("Noclip", false, function(s)
    if s then
        local conn = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _,part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
        player.CharacterAdded:Connect(function() if conn then conn:Disconnect() end end) -- cleanup
    else
        -- reset collision on disable (simple)
        local char = player.Character
        if char then for _,part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end end
    end
end)

createToggle("Infinite Jump", false, function(s)
    if s then
        UserInputService.JumpRequest:Connect(function()
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

createToggle("No Fall Damage", true, function(s)
    RunService.Heartbeat:Connect(function()
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum and s and hum:GetState() == Enum.HumanoidStateType.Freefall then
            hum:ChangeState(Enum.HumanoidStateType.Landed)
        end
    end)
end)

createToggle("Fullbright (No Fog)", true, function(s)
    if s then
        Lighting.FogEnd = 99999
        Lighting.Brightness = 2
    else
        Lighting.FogEnd = 100
        Lighting.Brightness = 1
    end
end)

-- Sliders
createSlider("WalkSpeed", 16, 200, 50, function(v)
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end)

createSlider("JumpPower", 50, 300, 50, function(v)
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = v end
end)

createSlider("Fly Speed", 30, 150, 70, function(v)
    flySpeed = v
end)

createSlider("Gravity", 0, 196.2, 196.2, function(v)
    workspace.Gravity = v
end)

-- Teleports & Trolls
createButton("Teleport to Highest Point (Safe Island)", Color3.fromRGB(0, 120, 255), function()
    local highestY = -math.huge
    local bestPos = nil
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Position.Y > highestY and part.CanCollide then
            highestY = part.Position.Y
            bestPos = part.Position
        end
    end
    local hrp = getHRP()
    if hrp and bestPos then
        hrp.CFrame = CFrame.new(bestPos + Vector3.new(0, 15, 0))
    end
end)

createButton("Teleport to Winners Island / End Area", Color3.fromRGB(255, 180, 0), function()
    -- Dynamic winners island (works on all maps)
    local highestY = -math.huge
    local bestPos = nil
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name:find("Island") or part.Name:find("Winners") or part.Name:find("End")) and part.Position.Y > highestY then
            highestY = part.Position.Y
            bestPos = part.Position
        end
    end
    local hrp = getHRP()
    if hrp and bestPos then
        hrp.CFrame = CFrame.new(bestPos + Vector3.new(0, 20, 0))
    else
        -- fallback
        hrp.CFrame = CFrame.new(0, 500, 0)
    end
end)

createButton("Teleport to Random Player", Color3.fromRGB(100, 0, 255), function()
    local pls = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p \~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(pls, p.Character.HumanoidRootPart.Position)
        end
    end
    if #pls > 0 then
        local hrp = getHRP()
        if hrp then hrp.CFrame = CFrame.new(pls[math.random(1,#pls)] + Vector3.new(0,5,0)) end
    end
end)

createButton("Fling All Players", Color3.fromRGB(255, 0, 0), function()
    spawn(function()
        for i = 1, 20 do
            for _, p in pairs(Players:GetPlayers()) do
                if p \~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Velocity = Vector3.new(math.random(-200,200), 150, math.random(-200,200))
                end
            end
            task.wait(0.15)
        end
    end)
end)

createButton("Server Hop (New Server)", Color3.fromRGB(200, 50, 50), function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
end)

-- ESP (simple name tags)
createToggle("Player ESP", false, function(s)
    if s then
        for _, p in pairs(Players:GetPlayers()) do
            if p \~= player and p.Character then
                local bb = Instance.new("BillboardGui")
                bb.Adornee = p.Character:FindFirstChild("Head")
                bb.Size = UDim2.new(0,200,0,50)
                bb.StudsOffset = Vector3.new(0,3,0)
                bb.AlwaysOnTop = true
                bb.Parent = p.Character.Head
                
                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(1,0,1,0)
                txt.BackgroundTransparency = 1
                txt.Text = p.Name
                txt.TextColor3 = Color3.new(1,0,0)
                txt.TextSize = 18
                txt.Font = Enum.Font.SourceSansBold
                txt.Parent = bb
            end
        end
    end
end)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,35,0,35)
closeBtn.Position = UDim2.new(1,-40,0,5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,0,0)
closeBtn.TextSize = 28
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = menuFrame
closeBtn.MouseButton1Click:Connect(function() menuFrame.Visible = false end)

-- Open menu
hubBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
end)

-- ==================== AUTO RE-APPLY ON RESPAWN ====================
player.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = 50 -- default from slider
    hum.JumpPower = 50
    if flying then
        stopFlying()
        task.wait(0.3)
        startFlying()
    end
end)

print("✅ NDS ULTIMATE SCRIPT LOADED!")
print("• Tap NDS HUB (top right) for menu")
print("• Tap FLY button for mobile joystick (Space = up, Ctrl = down)")
print("• God Mode + Noclip + Fly + TP to Winners Island = survive 100%")
