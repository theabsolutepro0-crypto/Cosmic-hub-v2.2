--[[
    COSMIC HUB - Super Ring V4
    Delta Mobile Compatible
    Attracts broken house particles and forms a cosmic energy ring
--]]

local player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for character
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Cosmic Hub Variables
local cosmicHub = {
    enabled = true,
    ringActive = true,
    particleAttraction = true,
    ringColor = Color3.fromRGB(100, 50, 255),
    ringSize = 15,
    ringSpeed = 1,
    attractionRadius = 40,
    attractionSpeed = 5,
    powerLevel = 1  -- V1 to V4
}

local ringParts = {}
local attractedParts = {}
local cosmicBeams = {}
local ringParticles = {}

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CosmicHub"
gui.Parent = player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 450)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 0, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 0, 100))
})
gradient.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
title.BackgroundTransparency = 0.5
title.Text = "🌌 COSMIC HUB V4 🌌"
title.TextColor3 = Color3.fromRGB(255, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 15)
titleCorner.Parent = title

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = title

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 55)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 4
scroll.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = scroll

-- Create Toggle Function
local function createToggle(text, setting, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    frame.BackgroundTransparency = 0.3
    frame.Parent = scroll
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(200, 150, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 30)
    btn.Position = UDim2.new(1, -70, 0.5, -15)
    btn.BackgroundColor3 = cosmicHub[setting] and Color3.fromRGB(100, 50, 200) or Color3.fromRGB(60, 60, 80)
    btn.Text = cosmicHub[setting] and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        cosmicHub[setting] = not cosmicHub[setting]
        btn.BackgroundColor3 = cosmicHub[setting] and Color3.fromRGB(100, 50, 200) or Color3.fromRGB(60, 60, 80)
        btn.Text = cosmicHub[setting] and "ON" or "OFF"
        
        if setting == "ringActive" and not cosmicHub.ringActive then
            clearRing()
        end
        if setting == "particleAttraction" and not cosmicHub.particleAttraction then
            clearAttractedParts()
        end
    end)
end

-- Create Slider Function
local function createSlider(text, minVal, maxVal, variable, format)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    frame.BackgroundTransparency = 0.3
    frame.Parent = scroll
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. (format and format(cosmicHub[variable]) or tostring(cosmicHub[variable]))
    label.TextColor3 = Color3.fromRGB(200, 150, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 0, 30)
    input.Position = UDim2.new(0, 10, 0, 32)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    input.Text = tostring(cosmicHub[variable])
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.Parent = frame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input
    
    input.FocusLost:Connect(function()
        local num = tonumber(input.Text)
        if num and num >= minVal and num <= maxVal then
            cosmicHub[variable] = num
            label.Text = text .. ": " .. (format and format(num) or tostring(num))
        else
            input.Text = tostring(cosmicHub[variable])
        end
    end)
end

-- Power Level Buttons
local powerFrame = Instance.new("Frame")
powerFrame.Size = UDim2.new(1, 0, 0, 60)
powerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
powerFrame.BackgroundTransparency = 0.3
powerFrame.Parent = scroll

local powerCorner = Instance.new("UICorner")
powerCorner.CornerRadius = UDim.new(0, 8)
powerCorner.Parent = powerFrame

local powerLabel = Instance.new("TextLabel")
powerLabel.Size = UDim2.new(1, 0, 0, 25)
powerLabel.Position = UDim2.new(0, 10, 0, 5)
powerLabel.BackgroundTransparency = 1
powerLabel.Text = "⚡ POWER LEVEL: V" .. cosmicHub.powerLevel .. " ⚡"
powerLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
powerLabel.TextXAlignment = Enum.TextXAlignment.Left
powerLabel.Font = Enum.Font.GothamBold
powerLabel.TextSize = 13
powerLabel.Parent = powerFrame

local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(1, -20, 0, 30)
buttonFrame.Position = UDim2.new(0, 10, 0, 32)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = powerFrame

local function addPowerBtn(level, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 55, 1, 0)
    btn.Position = UDim2.new(xPos, 0, 0, 0)
    btn.BackgroundColor3 = cosmicHub.powerLevel == level and Color3.fromRGB(150, 50, 200) or Color3.fromRGB(40, 40, 60)
    btn.Text = "V" .. level
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = buttonFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        cosmicHub.powerLevel = level
        powerLabel.Text = "⚡ POWER LEVEL: V" .. cosmicHub.powerLevel .. " ⚡"
        
        -- Update ring based on power level
        updateRingPower()
        
        -- Update button colors
        for _, child in pairs(buttonFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
    end)
end

addPowerBtn(1, 0)
addPowerBtn(2, 0.19)
addPowerBtn(3, 0.38)
addPowerBtn(4, 0.57)
addPowerBtn(5, 0.76)

-- Create toggles
createToggle("🌀 Cosmic Ring", "ringActive", Color3.fromRGB(150, 100, 255))
createToggle("✨ Particle Attraction", "particleAttraction", Color3.fromRGB(100, 200, 255))

-- Create sliders
createSlider("Ring Size", 5, 30, "ringSize")
createSlider("Ring Speed", 0.5, 5, "ringSpeed")
createSlider("Attraction Radius", 20, 80, "attractionRadius")
createSlider("Attraction Speed", 2, 15, "attractionSpeed")

-- Close button
closeBtn.MouseButton1Click:Connect(function()
    clearRing()
    clearAttractedParts()
    clearBeams()
    gui:Destroy()
end)

-- Update ring based on power level
local function updateRingPower()
    if not cosmicHub.ringActive then return end
    
    -- Change ring color based on power level
    if cosmicHub.powerLevel == 1 then
        cosmicHub.ringColor = Color3.fromRGB(100, 50, 200)
    elseif cosmicHub.powerLevel == 2 then
        cosmicHub.ringColor = Color3.fromRGB(150, 50, 255)
    elseif cosmicHub.powerLevel == 3 then
        cosmicHub.ringColor = Color3.fromRGB(200, 50, 255)
    elseif cosmicHub.powerLevel == 4 then
        cosmicHub.ringColor = Color3.fromRGB(255, 100, 200)
    elseif cosmicHub.powerLevel == 5 then
        cosmicHub.ringColor = Color3.fromRGB(255, 150, 100)
    end
    
    -- Update existing ring colors
    for _, part in pairs(ringParts) do
        if part:IsA("BasePart") then
            part.Color = cosmicHub.ringColor
        end
    end
end

-- Create cosmic ring around player
local function createCosmicRing()
    if not cosmicHub.ringActive or not rootPart then return end
    
    clearRing()
    
    local ringRadius = cosmicHub.ringSize
    local numParts = 24 * cosmicHub.powerLevel  -- More parts at higher power
    
    for i = 1, numParts do
        local angle = (i / numParts) * math.pi * 2
        local x = math.cos(angle) * ringRadius
        local z = math.sin(angle) * ringRadius
        
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.8, 0.3, 0.8)
        part.Shape = Enum.PartType.Ball
        part.BrickColor = BrickColor.new("Bright violet")
        part.Color = cosmicHub.ringColor
        part.Material = Enum.Material.Neon
        part.Anchored = true
        part.CanCollide = false
        part.CFrame = CFrame.new(rootPart.Position.X + x, rootPart.Position.Y + 1, rootPart.Position.Z + z)
        part.Parent = Workspace
        
        -- Add glow effect
        local pointLight = Instance.new("PointLight")
        pointLight.Range = 5
        pointLight.Brightness = 1
        pointLight.Color = cosmicHub.ringColor
        pointLight.Parent = part
        
        table.insert(ringParts, part)
        
        -- Add floating particles around ring
        if cosmicHub.powerLevel >= 3 then
            local particleEmitter = Instance.new("ParticleEmitter")
            particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
            particleEmitter.Rate = 50
            particleEmitter.Lifetime = NumberRange.new(0.5, 1)
            particleEmitter.SpreadAngle = Vector2.new(360, 360)
            particleEmitter.VelocityInheritance = 0
            particleEmitter.Speed = NumberRange.new(2, 5)
            particleEmitter.Color = ColorSequence.new(cosmicHub.ringColor)
            particleEmitter.Transparency = NumberSequence.new(0, 1)
            particleEmitter.Parent = part
            table.insert(ringParticles, particleEmitter)
        end
    end
    
    -- Add inner ring for V4 and V5
    if cosmicHub.powerLevel >= 4 then
        local innerRadius = ringRadius * 0.7
        local innerNumParts = 16 * cosmicHub.powerLevel
        
        for i = 1, innerNumParts do
            local angle = (i / innerNumParts) * math.pi * 2
            local x = math.cos(angle) * innerRadius
            local z = math.sin(angle) * innerRadius
            
            local part = Instance.new("Part")
            part.Size = Vector3.new(0.5, 0.2, 0.5)
            part.Shape = Enum.PartType.Ball
            part.Color = cosmicHub.ringColor
            part.Material = Enum.Material.Neon
            part.Anchored = true
            part.CanCollide = false
            part.CFrame = CFrame.new(rootPart.Position.X + x, rootPart.Position.Y + 0.5, rootPart.Position.Z + z)
            part.Parent = Workspace
            
            table.insert(ringParts, part)
        end
    end
    
    -- Add orbiting spheres for V5
    if cosmicHub.powerLevel >= 5 then
        local orbitRadius = ringRadius + 2
        for i = 1, 8 do
            local angle = (i / 8) * math.pi * 2
            local x = math.cos(angle) * orbitRadius
            local z = math.sin(angle) * orbitRadius
            
            local sphere = Instance.new("Part")
            sphere.Size = Vector3.new(1, 1, 1)
            sphere.Shape = Enum.PartType.Ball
            sphere.Color = Color3.fromRGB(255, 200, 100)
            sphere.Material = Enum.Material.Neon
            sphere.Anchored = true
            sphere.CanCollide = false
            sphere.CFrame = CFrame.new(rootPart.Position.X + x, rootPart.Position.Y + 1.5, rootPart.Position.Z + z)
            sphere.Parent = Workspace
            
            local orbitLight = Instance.new("PointLight")
            orbitLight.Range = 8
            orbitLight.Brightness = 1.5
            orbitLight.Color = Color3.fromRGB(255, 150, 50)
            orbitLight.Parent = sphere
            
            table.insert(ringParts, sphere)
        end
    end
end

-- Clear cosmic ring
local function clearRing()
    for _, part in pairs(ringParts) do
        pcall(function() part:Destroy() end)
    end
    ringParts = {}
    ringParticles = {}
end

-- Find and attract broken house particles
local function findBrokenParticles()
    if not cosmicHub.particleAttraction then return {} end
    
    local particles = {}
    
    -- Search for broken parts (common in NDS after disasters)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent and not obj.Parent:IsA("Character") then
            -- Check if it's debris (broken house pieces)
            local isDebris = false
            if obj.Name:lower():find("debris") or 
               obj.Name:lower():find("broken") or
               obj.Name:lower():find("piece") or
               obj.Name:lower():find("part") or
               (obj.Parent and obj.Parent.Name:lower():find("debris")) then
                isDebris = true
            end
            
            -- Also check if it's not anchored and not part of a player
            if (isDebris or (not obj.Anchored and obj:IsA("BasePart") and not obj.Parent:IsA("Model"))) then
                if obj ~= rootPart and obj.Parent ~= character then
                    table.insert(particles, obj)
                end
            end
        end
    end
    
    return particles
end

-- Attract particles to the ring
local function attractParticles()
    if not cosmicHub.particleAttraction or not rootPart then 
        clearAttractedParts()
        return 
    end
    
    local particles = findBrokenParticles()
    local ringCenter = rootPart.Position
    local ringRadius = cosmicHub.ringSize
    
    for _, part in pairs(particles) do
        if part and part.Parent then
            local distance = (part.Position - ringCenter).Magnitude
            
            if distance <= cosmicHub.attractionRadius then
                -- Attract towards the ring orbit
                local direction = (ringCenter - part.Position).Unit
                local targetPos = ringCenter + (part.Position - ringCenter).Unit * ringRadius
                
                -- Move towards target
                local step = cosmicHub.attractionSpeed * 0.1
                local newPos = part.Position + (targetPos - part.Position).Unit * step
                
                -- Apply movement
                if part:IsA("BasePart") and not part.Anchored then
                    part.Velocity = (targetPos - part.Position).Unit * cosmicHub.attractionSpeed * 2
                else
                    part.CFrame = CFrame.new(newPos)
                end
                
                -- Add visual effect
                if not attractedParts[part] then
                    -- Create beam effect
                    local beam = Instance.new("Beam")
                    beam.Attachment0 = Instance.new("Attachment")
                    beam.Attachment1 = Instance.new("Attachment")
                    beam.Attachment0.Parent = part
                    beam.Attachment1.Parent = rootPart
                    beam.Color = ColorSequence.new(cosmicHub.ringColor)
                    beam.Width0 = 0.2
                    beam.Width1 = 0.1
                    beam.Transparency = NumberSequence.new(0.5, 0.8)
                    beam.Parent = part
                    
                    attractedParts[part] = beam
                    table.insert(cosmicBeams, beam)
                end
                
                -- Make particles glow
                local glow = part:FindFirstChild("CosmicGlow")
                if not glow and cosmicHub.powerLevel >= 2 then
                    local newGlow = Instance.new("PointLight")
                    newGlow.Name = "CosmicGlow"
                    newGlow.Range = 3
                    newGlow.Brightness = 1
                    newGlow.Color = cosmicHub.ringColor
                    newGlow.Parent = part
                end
            end
        end
    end
end

-- Clear attracted particles and effects
local function clearAttractedParts()
    for part, beam in pairs(attractedParts) do
        pcall(function() 
            if beam then beam:Destroy() end
            if part and part:FindFirstChild("CosmicGlow") then
                part.CosmicGlow:Destroy()
            end
        end)
    end
    attractedParts = {}
    clearBeams()
end

local function clearBeams()
    for _, beam in pairs(cosmicBeams) do
        pcall(function() beam:Destroy() end)
    end
    cosmicBeams = {}
end

-- Update ring position (follow player)
local function updateRingPosition()
    if not cosmicHub.ringActive or not rootPart then return end
    
    local ringCenter = rootPart.Position
    local ringRadius = cosmicHub.ringSize
    local time = tick() * cosmicHub.ringSpeed
    
    for i, part in pairs(ringParts) do
        if part and part.Parent then
            local angle = (i / #ringParts) * math.pi * 2 + time
            local x = math.cos(angle) * ringRadius
            local z = math.sin(angle) * ringRadius
            
            -- Different heights for inner and outer rings
            local yOffset = 0
            if i > #ringParts * 0.7 then
                yOffset = math.sin(angle * 2) * 0.5
            end
            
            part.CFrame = CFrame.new(ringCenter.X + x, ringCenter.Y + 1 + yOffset, ringCenter.Z + z)
            
            -- Rotate parts for effect
            part.CFrame = part.CFrame * CFrame.Angles(0, time * 2, 0)
        end
    end
end

-- Create cosmic effects (particles around player)
local function createCosmicEffects()
    if not cosmicHub.ringActive then return end
    
    -- Create particle field around player
-- Add inner ring for V4 and V5
    if cosmicHub.powerLevel >= 4 then
        local innerRadius = ringRadius * 0.7
        local innerNumParts = 16 * cosmicHub.powerLevel
        
        for i = 1, innerNumParts do
            local angle = (i / innerNumParts) * math.pi * 2
            local x = math.cos(angle) * innerRadius
            local z = math.sin(angle) * innerRadius
            
            local part = Instance.new("Part")
            part.Size = Vector3.new(0.5, 0.2, 0.5)
            part.Shape = Enum.PartType.Ball
            part.Color = cosmicHub.ringColor
            part.Material = Enum.Material.Neon
            part.Anchored = true
            part.CanCollide = false
            part.CFrame = CFrame.new(rootPart.Position.X + x, rootPart.Position.Y + 0.5, rootPart.Position.Z + z)
            part.Parent = Workspace
            
            table.insert(ringParts, part)
        end
    end
    
    -- Add orbiting spheres for V5
    if cosmicHub.powerLevel >= 5 then
        local orbitRadius = ringRadius + 2
        for i = 1, 8 do
            local angle = (i / 8) * math.pi * 2
            local x = math.cos(angle) * orbitRadius
            local z = math.sin(angle) * orbitRadius
            
            local sphere = Instance.new("Part")
            sphere.Size = Vector3.new(1, 1, 1)
            sphere.Shape = Enum.PartType.Ball
            sphere.Color = Color3.fromRGB(255, 200, 100)
            sphere.Material = Enum.Material.Neon
            sphere.Anchored = true
            sphere.CanCollide = false
            sphere.CFrame = CFrame.new(rootPart.Position.X + x, rootPart.Position.Y + 1.5, rootPart.Position.Z + z)
            sphere.Parent = Workspace
            
            local orbitLight = Instance.new("PointLight")
            orbitLight.Range = 8
            orbitLight.Brightness = 1.5
            orbitLight.Color = Color3.fromRGB(255, 150, 50)
            orbitLight.Parent = sphere
            
            table.insert(ringParts, sphere)
        end
    end
end

-- Clear cosmic ring
local function clearRing()
    for _, part in pairs(ringParts) do
        pcall(function() part:Destroy() end)
    end
    ringParts = {}
    ringParticles = {}
end

-- Find and attract broken house particles
local function findBrokenParticles()
    if not cosmicHub.particleAttraction then return {} end
    
    local particles = {}
    
    -- Search for broken parts (common in NDS after disasters)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent and not obj.Parent:IsA("Character") then
            -- Check if it's debris (broken house pieces)
            local isDebris = false
            if obj.Name:lower():find("debris") or 
               obj.Name:lower():find("broken") or
               obj.Name:lower():find("piece") or
               obj.Name:lower():find("part") or
               (obj.Parent and obj.Parent.Name:lower():find("debris")) then
                isDebris = true
            end
            
            -- Also check if it's not anchored and not part of a player
            if (isDebris or (not obj.Anchored and obj:IsA("BasePart") and not obj.Parent:IsA("Model"))) then
                if obj ~= rootPart and obj.Parent ~= character then
                    table.insert(particles, obj)
                end
            end
        end
    end
    
    return particles
end

-- Attract particles to the ring
local function attractParticles()
    if not cosmicHub.particleAttraction or not rootPart then 
        clearAttractedParts()
        return 
    end
    
    local particles = findBrokenParticles()
    local ringCenter = rootPart.Position
    local ringRadius = cosmicHub.ringSize
    
    for _, part in pairs(particles) do
        if part and part.Parent then
            local distance = (part.Position - ringCenter).Magnitude
            
            if distance <= cosmicHub.attractionRadius then
                -- Attract towards the ring orbit
                local direction = (ringCenter - part.Position).Unit
                local targetPos = ringCenter + (part.Position - ringCenter).Unit * ringRadius
                
                -- Move towards target
                local step = cosmicHub.attractionSpeed * 0.1
                local newPos = part.Position + (targetPos - part.Position).Unit * step
                
                -- Apply movement
                if part:IsA("BasePart") and not part.Anchored then
                    part.Velocity = (targetPos - part.Position).Unit * cosmicHub.attractionSpeed * 2
                else
                    part.CFrame = CFrame.new(newPos)
                end
                
                -- Add visual effect
                if not attractedParts[part] then
                    -- Create beam effect
                    local beam = Instance.new("Beam")
                    beam.Attachment0 = Instance.new("Attachment")
                    beam.Attachment1 = Instance.new("Attachment")
                    beam.Attachment0.Parent = part
                    beam.Attachment1.Parent = rootPart
                    beam.Color = ColorSequence.new(cosmicHub.ringColor)
                    beam.Width0 = 0.2
                    beam.Width1 = 0.1
                    beam.Transparency = NumberSequence.new(0.5, 0.8)
                    beam.Parent = part
                    
                    attractedParts[part] = beam
                    table.insert(cosmicBeams, beam)
                end
                
                -- Make particles glow
                local glow = part:FindFirstChild("CosmicGlow")
                if not glow and cosmicHub.powerLevel >= 2 then
                    local newGlow = Instance.new("PointLight")
                    newGlow.Name = "CosmicGlow"
                    newGlow.Range = 3
                    newGlow.Brightness = 1
                    newGlow.Color = cosmicHub.ringColor
                    newGlow.Parent = part
                end
            end
        end
    end
end

-- Clear attracted particles and effects
local function clearAttractedParts()
    for part, beam in pairs(attractedParts) do
        pcall(function() 
            if beam then beam:Destroy() end
            if part and part:FindFirstChild("CosmicGlow") then
                part.CosmicGlow:Destroy()
            end
        end)
    end
    attractedParts = {}
    clearBeams()
end

local function clearBeams()
    for _, beam in pairs(cosmicBeams) do
        pcall(function() beam:Destroy() end)
    end
    cosmicBeams = {}
end

-- Update ring position (follow player)
local function updateRingPosition()
    if not cosmicHub.ringActive or not rootPart then return end
    
    local ringCenter = rootPart.Position
    local ringRadius = cosmicHub.ringSize
    local time = tick() * cosmicHub.ringSpeed
    
    for i, part in pairs(ringParts) do
        if part and part.Parent then
            local angle = (i / #ringParts) * math.pi * 2 + time
            local x = math.cos(angle) * ringRadius
            local z = math.sin(angle) * ringRadius
            
            -- Different heights for inner and outer rings
            local yOffset = 0
            if i > #ringParts * 0.7 then
                yOffset = math.sin(angle * 2) * 0.5
            end
            
            part.CFrame = CFrame.new(ringCenter.X + x, ringCenter.Y + 1 + yOffset, ringCenter.Z + z)
            
            -- Rotate parts for effect
            part.CFrame = part.CFrame * CFrame.Angles(0, time * 2, 0)
        end
    end
end

-- Create cosmic effects (particles around player)
local function createCosmicEffects()
    if not cosmicHub.ringActive then return end
    
    -- Create particle field around player
    local particleField = character:FindFirstChild("CosmicField")
    if not particleField and cosmicHub.powerLevel >= 3 then
        local emitter = Instance.new("ParticleEmitter")
        emitter.Name = "CosmicField"
        emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        emitter.Rate = 100
        emitter.Lifetime = NumberRange.new(1, 2)
        emitter.SpreadAngle = Vector2.new(360, 360)
        emitter.Speed = NumberRange.new(1, 3)
        emitter.Color = ColorSequence.new(cosmicHub.ringColor)
        emitter.Transparency = NumberSequence.new(0.2, 1)
        emitter.Parent = rootPart
        table.insert(ringParticles, emitter)
    end
end

-- Character respawn handler
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
    wait(1)
    clearRing()
    clearAttractedParts()
    createCosmicRing()
end)

-- Main update loop
RunService.Heartbeat:Connect(function()
    if not cosmicHub.enabled then return end
    
    if cosmicHub.ringActive then
        updateRingPosition()
        createCosmicEffects()
    end
    
    if cosmicHub.particleAttraction then
        attractParticles()
    end
end)

-- Create initial ring
wait(0.5)
createCosmicRing()

-- Spawn particle attraction check loop
spawn(function()
    while true do
        if cosmicHub.particleAttraction then
            attractParticles()
        end
        wait(0.1)
    end
end)

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🌌 COSMIC HUB V4",
    Text = "Super Ring activated! Attract broken particles and harness cosmic power!",
    Duration = 4
})

print("COSMIC HUB V4 - Super Ring Script Loaded")

-- Visual flair for GUI (animated gradient)
spawn(function()
    local hue = 0
    while gui and gui.Parent do
        hue = (hue + 0.01) % 1
        local color = Color3.fromHSV(hue, 1, 0.8)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 0, 100))
        })
        wait(0.05)
    end
end)
