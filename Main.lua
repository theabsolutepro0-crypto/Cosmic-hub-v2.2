local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local LocalPlayer=Players.LocalPlayer
local SG=Instance.new("ScreenGui")
SG.Name="CosmicHub" SG.ResetOnSpawn=false
SG.IgnoreGuiInset=true
SG.Parent=LocalPlayer:WaitForChild("PlayerGui")
local TB=Instance.new("TextButton")
TB.Size=UDim2.new(0,52,0,52)
TB.Position=UDim2.new(0,16,0.5,-26)
TB.BackgroundColor3=Color3.fromRGB(220,45,45)
TB.BorderSizePixel=0 TB.Text="CH"
TB.TextColor3=Color3.fromRGB(255,255,255)
TB.TextSize=13 TB.Font=Enum.Font.GothamBold
TB.ZIndex=20 TB.Active=true TB.Parent=SG
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,26)
local tStroke=Instance.new("UIStroke",TB)
tStroke.Color=Color3.fromRGB(255,255,255) tStroke.Thickness=2
local td=false local tds=nil local tsp=nil local tdMoved=false
TB.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
		td=true tdMoved=false tds=i.Position tsp=TB.Position end end)
TB.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
		td=false end end)
UserInputService.InputChanged:Connect(function(i)
	if td and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then
		local delta=i.Position-tds
		if delta.Magnitude>6 then tdMoved=true end
		TB.Position=UDim2.new(tsp.X.Scale,tsp.X.Offset+delta.X,tsp.Y.Scale,tsp.Y.Offset+delta.Y)
	end end)
local Main=Instance.new("Frame")
Main.Size=UDim2.new(0,500,0,380)
Main.Position=UDim2.new(0.5,-250,0.5,-190)
Main.BackgroundColor3=Color3.fromRGB(8,8,8)
Main.BorderSizePixel=0 Main.Active=true
Main.Draggable=true Main.Visible=true Main.Parent=SG
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,6)
local ms=Instance.new("UIStroke",Main)
ms.Color=Color3.fromRGB(220,45,45) ms.Thickness=2
local vis=true
local function toggleVis()
	if tdMoved then tdMoved=false return end
	vis=not vis Main.Visible=vis
	TweenService:Create(TB,TweenInfo.new(0.15),{
		BackgroundColor3=vis and Color3.fromRGB(220,45,45)or Color3.fromRGB(60,60,60)
	}):Play()
end
TB.MouseButton1Click:Connect(toggleVis)
TB.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.Touch then toggleVis() end end)
local Hdr=Instance.new("Frame")
Hdr.Size=UDim2.new(1,0,0,38)
Hdr.BackgroundColor3=Color3.fromRGB(10,10,10)
Hdr.BorderSizePixel=0 Hdr.Parent=Main
Instance.new("UICorner",Hdr).CornerRadius=UDim.new(0,6)
local Ttl=Instance.new("TextLabel")
Ttl.Text="COSMIC HUB  |  Blox Fruits"
Ttl.Size=UDim2.new(1,-50,1,0)
Ttl.Position=UDim2.new(0,14,0,0)
Ttl.BackgroundTransparency=1
Ttl.TextColor3=Color3.fromRGB(255,255,255)
Ttl.TextSize=13 Ttl.Font=Enum.Font.GothamBold
Ttl.TextXAlignment=Enum.TextXAlignment.Left Ttl.Parent=Hdr
local CB=Instance.new("TextButton")
CB.Text="X" CB.Size=UDim2.new(0,30,0,28)
CB.Position=UDim2.new(1,-36,0.5,-14)
CB.BackgroundColor3=Color3.fromRGB(180,30,30)
CB.BorderSizePixel=0
CB.TextColor3=Color3.fromRGB(255,255,255)
CB.TextSize=13 CB.Font=Enum.Font.GothamBold CB.Parent=Hdr
Instance.new("UICorner",CB).CornerRadius=UDim.new(0,5)
CB.MouseButton1Click:Connect(function() SG:Destroy() end)
local Sidebar=Instance.new("Frame")
Sidebar.Size=UDim2.new(0,120,1,-38)
Sidebar.Position=UDim2.new(0,0,0,38)
Sidebar.BackgroundColor3=Color3.fromRGB(180,35,35)
Sidebar.BorderSizePixel=0 Sidebar.Parent=Main
Instance.new("UIListLayout",Sidebar).SortOrder=Enum.SortOrder.LayoutOrder
local Content=Instance.new("Frame")
Content.Size=UDim2.new(1,-120,1,-38)
Content.Position=UDim2.new(0,120,0,38)
Content.BackgroundColor3=Color3.fromRGB(200,45,45)
Content.BorderSizePixel=0 Content.Parent=Main
local tabNames={"Home","Farm","Sea Events","Race","Fruit","Raid","PVP","Visuals","Misc"}
local tabBtns={} local panels={}
for i,name in ipairs(tabNames)do
	local TB2=Instance.new("TextButton")
	TB2.Size=UDim2.new(1,0,0,38)
	TB2.BackgroundColor3=i==1 and Color3.fromRGB(140,25,25)or Color3.fromRGB(180,35,35)
	TB2.BorderSizePixel=0
	TB2.Text=name
	TB2.TextColor3=Color3.fromRGB(255,255,255)
	TB2.TextSize=11 TB2.Font=Enum.Font.GothamBold
	TB2.LayoutOrder=i TB2.Parent=Sidebar
	local bar=Instance.new("Frame")
	bar.Size=UDim2.new(0,4,1,0)
	bar.BackgroundColor3=i==1 and Color3.fromRGB(255,255,255)or Color3.fromRGB(180,35,35)
	bar.BorderSizePixel=0 bar.Parent=TB2
	tabBtns[i]={btn=TB2,bar=bar}
	local P=Instance.new("ScrollingFrame")
	P.Size=UDim2.new(1,0,1,0)
	P.BackgroundTransparency=1 P.BorderSizePixel=0
	P.ScrollBarThickness=3
	P.ScrollBarImageColor3=Color3.fromRGB(255,255,255)
	P.CanvasSize=UDim2.new(0,0,0,0)
	P.AutomaticCanvasSize=Enum.AutomaticSize.Y
	P.Visible=i==1 P.Parent=Content
	local ul=Instance.new("UIListLayout",P)
	ul.SortOrder=Enum.SortOrder.LayoutOrder
	ul.Padding=UDim.new(0,6)
	local up=Instance.new("UIPadding",P)
	up.PaddingLeft=UDim.new(0,10)
	up.PaddingRight=UDim.new(0,10)
	up.PaddingTop=UDim.new(0,10)
	panels[i]=P
	local function switchTab()
		for j,t in ipairs(tabBtns)do
			t.btn.BackgroundColor3=j==i and Color3.fromRGB(140,25,25)or Color3.fromRGB(180,35,35)
			t.bar.BackgroundColor3=j==i and Color3.fromRGB(255,255,255)or Color3.fromRGB(180,35,35)
			panels[j].Visible=j==i
		end
	end
	TB2.MouseButton1Click:Connect(switchTab)
	TB2.InputEnded:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.Touch then switchTab() end
	end)
end
local Ft=Instance.new("Frame")
Ft.Size=UDim2.new(1,0,0,20)
Ft.Position=UDim2.new(0,0,1,-20)
Ft.BackgroundColor3=Color3.fromRGB(10,10,10)
Ft.BorderSizePixel=0 Ft.Parent=Main
local FL=Instance.new("TextLabel")
FL.Text="Cosmic Hub  |  Blox Fruits"
FL.Size=UDim2.new(1,0,1,0)
FL.BackgroundTransparency=1
FL.TextColor3=Color3.fromRGB(120,120,120)
FL.TextSize=10 FL.Font=Enum.Font.Gotham
FL.Parent=Ft
