local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Create ScreenGui
local SG = Instance.new("ScreenGui")
SG.Name = "HaokholalHub"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Floating Ball (HK)
local CHBall = Instance.new("TextButton")
CHBall.Size = UDim2.new(0, 52, 0, 52)
CHBall.Position = UDim2.new(0, 16, 0.5, -26)
CHBall.BackgroundColor3 = Color3.fromRGB(220, 45, 45)
CHBall.BorderSizePixel = 0
CHBall.Text = "HK"
CHBall.TextColor3 = Color3.fromRGB(255, 255, 255)
CHBall.TextSize = 13
CHBall.Font = Enum.Font.GothamBold
CHBall.ZIndex = 20
CHBall.Active = true
CHBall.Parent = SG

local ballScale = Instance.new("UIScale")
ballScale.Scale = 1
ballScale.Parent = CHBall

local ballCorner = Instance.new("UICorner", CHBall)
ballCorner.CornerRadius = UDim.new(0, 26)

local ballStroke = Instance.new("UIStroke", CHBall)
ballStroke.Color = Color3.fromRGB(255, 255, 255)
ballStroke.Thickness = 2

-- On/Off Toggle Button on the Ball
local ballToggle = Instance.new("TextButton")

ballToggle.Size = UDim2.new(0.5, 0, 0.5, 0)
ballToggle.Position = UDim2.new(0.25, 0, 0.25, 0)
ballToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ballToggle.BackgroundTransparency = 0.5
ballToggle.Text = "ON"
ballToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ballToggle.TextSize = 8
ballToggle.Font = Enum.Font.GothamBold
ballToggle.BorderSizePixel = 0
ballToggle.ZIndex = 21
ballToggle.Parent = CHBall

ballToggle.AutoButtonColor = false

ballToggle.MouseButton1Click:Connect(function()
	moved = false
	toggleMainGUI()
end)

local ballToggleCorner = Instance.new("UICorner", ballToggle)
ballToggleCorner.CornerRadius = UDim.new(1, 0)

-- Ball state
local ballActive = true
local pulseConnection = nil

-- Pulse animation (fixed)
local function startPulse()
	if pulseConnection then pulseConnection:Disconnect() end
	pulseConnection = RunService.RenderStepped:Connect(function()
		if ballActive then
			ballScale.Scale = 0.95 + math.sin(tick() * 8) * 0.05
		else
			ballScale.Scale = 1
		end
	end)
end

startPulse()

-- Drag functionality
local dragging = false
local dragStart = nil
local ballStart = nil
local moved = false

-- click toggle (fixed)
CHBall.MouseButton1Click:Connect(function()
	moved = false
	toggleMainGUI()
end)

-- stop dragging
CHBall.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch 
	or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
local delta = input.Position - dragStart
if delta.Magnitude > 5 then
moved = true
end
CHBall.Position = UDim2.new(ballStart.X.Scale, ballStart.X.Offset + delta.X, ballStart.Y.Scale, ballStart.Y.Offset + delta.Y)
end
end)

-- Main GUI Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 540, 0, 480)
Main.Position = UDim2.new(0.5, -270, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = true
Main.Parent = SG

local mainCorner = Instance.new("UICorner", Main)
mainCorner.CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Color3.fromRGB(220, 45, 45)
mainStroke.Thickness = 2

-- GUI visibility
local guiVisible = true

function toggleMainGUI()
if moved then
moved = false
return
end
guiVisible = not guiVisible
Main.Visible = guiVisible
TweenService:Create(CHBall, TweenInfo.new(0.15), {
BackgroundColor3 = guiVisible and Color3.fromRGB(220, 45, 45) or Color3.fromRGB(60, 60, 60)
}):Play()
end

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Header.BorderSizePixel = 0
Header.Parent = Main

local headerCorner = Instance.new("UICorner", Header)
headerCorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Text = "✦ HAOKHOLAL'S HUB  |  Blox Fruits ✦"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.BorderSizePixel = 0
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local closeCorner = Instance.new("UICorner", CloseBtn)
closeCorner.CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function()
SG:Destroy()
end)

-- Sidebar Container
local SidebarContainer = Instance.new("Frame")
SidebarContainer.Size = UDim2.new(0, 130, 1, -44)
SidebarContainer.Position = UDim2.new(0, 0, 0, 44)
SidebarContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
SidebarContainer.BorderSizePixel = 0
SidebarContainer.ClipsDescendants = true
SidebarContainer.Parent = Main

local sidebarCorner = Instance.new("UICorner", SidebarContainer)
sidebarCorner.CornerRadius = UDim.new(0, 0)

-- Scrolling Frame for Tabs
local SidebarScroller = Instance.new("ScrollingFrame")
SidebarScroller.Size = UDim2.new(1, 0, 1, 0)
SidebarScroller.BackgroundTransparency = 1
SidebarScroller.BorderSizePixel = 0
SidebarScroller.ScrollBarThickness = 3
SidebarScroller.ScrollBarImageColor3 = Color3.fromRGB(220, 45, 45)
SidebarScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
SidebarScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
SidebarScroller.Parent = SidebarContainer

local sidebarList = Instance.new("UIListLayout", SidebarScroller)
sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
sidebarList.Padding = UDim.new(0, 4)

local sidebarPadding = Instance.new("UIPadding", SidebarScroller)
sidebarPadding.PaddingLeft = UDim.new(0, 6)
sidebarPadding.PaddingRight = UDim.new(0, 6)
sidebarPadding.PaddingTop = UDim.new(0, 8)
sidebarPadding.PaddingBottom = UDim.new(0, 8)

-- Content Area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -130, 1, -44)
Content.Position = UDim2.new(0, 130, 0, 44)
Content.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Content.BorderSizePixel = 0
Content.Parent = Main

local contentCorner = Instance.new("UICorner", Content)
contentCorner.CornerRadius = UDim.new(0, 0)

-- Tab System
local tabNames = {"✨ Home", "⚔️ Farm", "🌊 Sea Events", "🏃 Race", "🍎 Fruit",
"💎 Raid", "🎯 PVP", "👁️ Visuals", "🔧 Misc"}

local tabButtons = {}
local panels = {}

for i, name in ipairs(tabNames) do
-- Tab Button
local tabBtn = Instance.new("TextButton")
tabBtn.Size = UDim2.new(1, 0, 0, 42)
tabBtn.BackgroundColor3 = i == 1 and Color3.fromRGB(220, 45, 45) or Color3.fromRGB(30, 30, 40)
tabBtn.BorderSizePixel = 0
tabBtn.Text = name
tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tabBtn.TextSize = 12
tabBtn.Font = Enum.Font.GothamSemibold
tabBtn.LayoutOrder = i
tabBtn.Parent = SidebarScroller

local tabCorner = Instance.new("UICorner", tabBtn)  
tabCorner.CornerRadius = UDim.new(0, 8)  
  
-- Active indicator  
local indicator = Instance.new("Frame")  
indicator.Size = UDim2.new(0, 3, 1, -8)  
indicator.Position = UDim2.new(0, 0, 0, 4)  
indicator.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(220, 45, 45)  
indicator.BorderSizePixel = 0  
indicator.Parent = tabBtn  
  
tabButtons[i] = {btn = tabBtn, indicator = indicator}  
  
-- Panel  
local panel = Instance.new("ScrollingFrame")  
panel.Size = UDim2.new(1, 0, 1, 0)  
panel.BackgroundTransparency = 1  
panel.BorderSizePixel = 0  
panel.ScrollBarThickness = 5  
panel.ScrollBarImageColor3 = Color3.fromRGB(220, 45, 45)  
panel.CanvasSize = UDim2.new(0, 0, 0, 0)  
panel.AutomaticCanvasSize = Enum.AutomaticSize.Y  
panel.Visible = i == 1  
panel.Parent = Content  
  
local panelList = Instance.new("UIListLayout", panel)  
panelList.SortOrder = Enum.SortOrder.LayoutOrder  
panelList.Padding = UDim.new(0, 8)  
  
local panelPadding = Instance.new("UIPadding", panel)  
panelPadding.PaddingLeft = UDim.new(0, 12)  
panelPadding.PaddingRight = UDim.new(0, 12)  
panelPadding.PaddingTop = UDim.new(0, 12)  
panelPadding.PaddingBottom = UDim.new(0, 12)  
  
panels[i] = panel  
  
local function switchTab()  
    for j, tab in ipairs(tabButtons) do  
        tab.btn.BackgroundColor3 = j == i and Color3.fromRGB(220, 45, 45) or Color3.fromRGB(30, 30, 40)  
        tab.indicator.BackgroundColor3 = j == i and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(220, 45, 45)  
        panels[j].Visible = j == i  
    end  
end  
  
tabBtn.MouseButton1Click:Connect(switchTab)

end

-- Footer
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 28)
Footer.Position = UDim2.new(0, 0, 1, -28)
Footer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Footer.BorderSizePixel = 0
Footer.Parent = Main

local footerLabel = Instance.new("TextLabel")
footerLabel.Text = "Haokholal's Hub  |  Premium Quality Scripts"
footerLabel.Size = UDim2.new(1, 0, 1, 0)
footerLabel.BackgroundTransparency = 1
footerLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
footerLabel.TextSize = 10
footerLabel.Font = Enum.Font.Gotham
footerLabel.Parent = Footer

-- Helper function to create toggle buttons
local function createToggle(parent, text, order, desc)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
frame.BorderSizePixel = 0
frame.LayoutOrder = order
frame.Parent = parent

local corner = Instance.new("UICorner", frame)  
corner.CornerRadius = UDim.new(0, 8)  
  
local label = Instance.new("TextLabel")  
label.Text = text  
label.Size = UDim2.new(0.7, -10, 0.6, 0)  
label.Position = UDim2.new(0, 12, 0, 5)  
label.BackgroundTransparency = 1  
label.TextColor3 = Color3.fromRGB(255, 255, 255)  
label.TextSize = 14  
label.TextXAlignment = Enum.TextXAlignment.Left  
label.Font = Enum.Font.GothamSemibold  
label.Parent = frame  
  
if desc then  
    local descLabel = Instance.new("TextLabel")  
    descLabel.Text = desc  
    descLabel.Size = UDim2.new(0.7, -10, 0.4, 0)  
    descLabel.Position = UDim2.new(0, 12, 0, 28)  
    descLabel.BackgroundTransparency = 1  
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 170)  
    descLabel.TextSize = 10  
    descLabel.TextXAlignment = Enum.TextXAlignment.Left  
    descLabel.Font = Enum.Font.Gotham  
    descLabel.Parent = frame  
end  
  
local toggle = Instance.new("TextButton")  
toggle.Text = "OFF"  
toggle.Size = UDim2.new(0, 70, 0, 32)  
toggle.Position = UDim2.new(1, -82, 0.5, -16)  
toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)  
toggle.BorderSizePixel = 0  
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)  
toggle.TextSize = 12  
toggle.Font = Enum.Font.GothamBold  
toggle.Parent = frame  
  
local toggleCorner = Instance.new("UICorner", toggle)  
toggleCorner.CornerRadius = UDim.new(0, 16)  
  
local isOn = false  
toggle.MouseButton1Click:Connect(function()  
    isOn = not isOn  
    toggle.Text = isOn and "ON" or "OFF"  
    toggle.BackgroundColor3 = isOn and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(60, 60, 70)  
end)  
  
return frame

end

local function createHeader(parent, title, order)
local header = Instance.new("TextLabel")
header.Text = title
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(220, 45, 45)
header.BackgroundTransparency = 0.2
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.TextSize = 12
header.Font = Enum.Font.GothamBold
header.LayoutOrder = order
header.Parent = parent

local headerCorner = Instance.new("UICorner", header)  
headerCorner.CornerRadius = UDim.new(0, 6)  
return header

end

-- Populate tabs
createHeader(panels[1], "MAIN FEATURES", 1)
createToggle(panels[1], "Auto Farm", 2, "Automatically farm enemies and chests")
createToggle(panels[1], "Auto Raid", 3, "Complete raids automatically")
createToggle(panels[1], "Auto Sea Event", 4, "Auto participate in sea events")
createToggle(panels[1], "Stats Modifier", 5, "Auto distribute stat points")
createToggle(panels[1], "ESP Player", 6, "Show players through walls")
createHeader(panels[1], "UTILITIES", 7)
createToggle(panels[1], "Auto Store", 8, "Auto collect fruits from shop")
createToggle(panels[1], "Auto Chest", 9, "Auto collect nearby chests")

createHeader(panels[2], "FARM SETTINGS", 1)
createToggle(panels[2], "Mastery Farm", 2, "Farm for mastery points")
createToggle(panels[2], "Money Farm", 3, "Farm for Beli")
createToggle(panels[2], "Fragment Farm", 4, "Farm for fragments")
createToggle(panels[2], "Boss Farm", 5, "Automatically farm bosses")

createHeader(panels[3], "SEA EVENTS", 1)
createToggle(panels[3], "Auto Sea Beast", 2, "Auto hunt sea beasts")
createToggle(panels[3], "Auto Ship", 3, "Auto destroy ships")

createHeader(panels[4], "RACE SETTINGS", 1)
createToggle(panels[4], "Auto Race V2", 2, "Auto complete race v2")
createToggle(panels[4], "Auto Race V3", 3, "Auto complete race v3")

createHeader(panels[5], "FRUIT SETTINGS", 1)
createToggle(panels[5], "Auto Store Fruit", 2, "Auto store valuable fruits")
createToggle(panels[5], "Fruit Notifier", 3, "Notify when fruit spawns")

createHeader(panels[6], "RAID SETTINGS", 1)
createToggle(panels[6], "Auto Raid", 2, "Auto complete raids")
createToggle(panels[6], "Auto Awaken", 3, "Auto awaken fruits")

createHeader(panels[7], "PVP SETTINGS", 1)
createToggle(panels[7], "Auto PVP", 2, "Auto fight players")
createToggle(panels[7], "Aimbot", 3, "Auto aim at players")

createHeader(panels[8], "VISUAL SETTINGS", 1)
createToggle(panels[8], "ESP Players", 2, "Show player ESP")
createToggle(panels[8], "ESP Fruits", 3, "Show fruit ESP")

createHeader(panels[9], "MISC SETTINGS", 1)
createToggle(panels[9], "Auto Rejoin", 2, "Auto rejoin on server hop")
createToggle(panels[9], "Auto Click", 3, "Auto click for abilities")

-- Ball On/Off functionality
ballToggle.MouseButton1Click:Connect(function()
ballActive = not ballActive
ballToggle.Text = ballActive and "ON" or "OFF"
if ballActive then
startPulse()
CHBall.BackgroundColor3 = Color3.fromRGB(220, 45, 45)
ballToggle.BackgroundTransparency = 0.5
else
if pulseConnection then pulseConnection:Disconnect() end
pulseConnection = nil
CHBall.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
ballScale.Scale = 1
ballToggle.BackgroundTransparency = 0.7
end
end)

print("Haokholal's Hub GUI Loaded Successfully!")
