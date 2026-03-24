local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local LocalPlayer=Players.LocalPlayer
local flying=false
local flySpeed=50
local flyConn
local mi={f=false,b=false,l=false,r=false,u=false,d=false}
local function getFlyDir()
	local cam=workspace.CurrentCamera
	local d=Vector3.zero
	if mi.f then d+=cam.CFrame.LookVector end
	if mi.b then d-=cam.CFrame.LookVector end
	if mi.l then d-=cam.CFrame.RightVector end
	if mi.r then d+=cam.CFrame.RightVector end
	if mi.u then d+=Vector3.new(0,1,0) end
	if mi.d then d-=Vector3.new(0,1,0) end
	return d
end
local function startFly()
	local char=LocalPlayer.Character if not char then return end
	local hrp=char:FindFirstChild("HumanoidRootPart")
	local hum=char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end
	hum.PlatformStand=true
	for _,n in ipairs({"FV","FG"})do
		local o=hrp:FindFirstChild(n) if o then o:Destroy() end
	end
	local att=hrp:FindFirstChild("RootAttachment")or Instance.new("Attachment",hrp)
	local bv=Instance.new("LinearVelocity")
	bv.Name="FV" bv.Attachment0=att
	bv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
	bv.MaxForce=1e6 bv.RelativeTo=Enum.ActuatorRelativeTo.World
	bv.VectorVelocity=Vector3.zero bv.Parent=hrp
	local ba=Instance.new("AlignOrientation")
	ba.Name="FG" ba.Mode=Enum.OrientationAlignmentMode.OneAttachment
	ba.Attachment0=att ba.MaxTorque=1e6 ba.Responsiveness=50
	ba.CFrame=workspace.CurrentCamera.CFrame ba.Parent=hrp
	flyConn=RunService.Heartbeat:Connect(function(dt)
		if not flying then return end
		local dir=getFlyDir()
		local t=dir.Magnitude>0 and dir.Unit*flySpeed or Vector3.zero
		local v=hrp:FindFirstChild("FV")
		local g=hrp:FindFirstChild("FG")
		if v then v.VectorVelocity=v.VectorVelocity:Lerp(t,math.min(1,dt*12)) end
		if g then g.CFrame=workspace.CurrentCamera.CFrame end
	end)
end
local function stopFly()
	flying=false
	if flyConn then flyConn:Disconnect() flyConn=nil end
	local char=LocalPlayer.Character if not char then return end
	local hrp=char:FindFirstChild("HumanoidRootPart")
	local hum=char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand=false end
	if hrp then
		local v=hrp:FindFirstChild("FV") if v then v:Destroy() end
		local g=hrp:FindFirstChild("FG") if g then g:Destroy() end
	end
end
local godMode=false local godConn
local noclip=false local noclipConn
local infiniteJump=false
local function toggleGod(s)
	godMode=s
	local char=LocalPlayer.Character if not char then return end
	local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return end
	if s then
		hum.MaxHealth=1e6 hum.Health=1e6
		godConn=RunService.Heartbeat:Connect(function()
			if hum and hum.Health<hum.MaxHealth then hum.Health=hum.MaxHealth end
		end)
	else
		hum.MaxHealth=100 hum.Health=100
		if godConn then godConn:Disconnect() godConn=nil end
	end
end
local function toggleNoclip(s)
	noclip=s
	if s then
		noclipConn=RunService.Stepped:Connect(function()
			local char=LocalPlayer.Character if not char then return end
			for _,p in ipairs(char:GetDescendants())do
				if p:IsA("BasePart")then p.CanCollide=false end
			end
		end)
	else
		if noclipConn then noclipConn:Disconnect() noclipConn=nil end
		local char=LocalPlayer.Character if not char then return end
		for _,p in ipairs(char:GetDescendants())do
			if p:IsA("BasePart")then p.CanCollide=true end
		end
	end
end
local function setSpeed(v)
	local char=LocalPlayer.Character if not char then return end
	local hum=char:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed=v end
end
local function setJump(v)
	local char=LocalPlayer.Character if not char then return end
	local hum=char:FindFirstChildOfClass("Humanoid") if hum then hum.JumpPower=v end
end
UserInputService.JumpRequest:Connect(function()
	if not infiniteJump then return end
	local char=LocalPlayer.Character if not char then return end
	local hum=char:FindFirstChildOfClass("Humanoid")
	if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	if flying then startFly() end
	if godMode then toggleGod(true) end
	if noclip then toggleNoclip(true) end
end)
local SG=Instance.new("ScreenGui")
SG.Name="CosmicHub" SG.ResetOnSpawn=false
SG.IgnoreGuiInset=true
SG.Parent=LocalPlayer:WaitForChild("PlayerGui")

-- FLOATING BUTTON (draggable + tap to toggle GUI)
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

-- drag logic
local td=false local tds=nil local tsp=nil local tdMoved=false
TB.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
		td=true tdMoved=false tds=i.Position tsp=TB.Position
	end
end)
TB.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
		td=false
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if td and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then
		local delta=i.Position-tds
		if delta.Magnitude>6 then tdMoved=true end
		TB.Position=UDim2.new(tsp.X.Scale,tsp.X.Offset+delta.X,tsp.Y.Scale,tsp.Y.Offset+delta.Y)
	end
end)

local Main=Instance.new("Frame")
Main.Size=UDim2.new(0,500,0,380)
Main.Position=UDim2.new(0.5,-250,0.5,-190)
Main.BackgroundColor3=Color3.fromRGB(8,8,8)
Main.BorderSizePixel=0 Main.Active=true
Main.Draggable=true Main.Visible=true Main.Parent=SG
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,6)
local ms=Instance.new("UIStroke",Main)
ms.Color=Color3.fromRGB(220,45,45) ms.Thickness=2

-- TOGGLE GUI ON/OFF — only fires if not dragged
local vis=true
TB.MouseButton1Click:Connect(function()
	if tdMoved then tdMoved=false return end
	vis=not vis
	Main.Visible=vis
	TweenService:Create(TB,TweenInfo.new(0.15),{
		BackgroundColor3=vis and Color3.fromRGB(220,45,45) or Color3.fromRGB(60,60,60)
	}):Play()
	TB.Text=vis and "CH" or "CH"
end)
TB.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.Touch then
		if tdMoved then tdMoved=false return end
		vis=not vis
		Main.Visible=vis
		TweenService:Create(TB,TweenInfo.new(0.15),{
			BackgroundColor3=vis and Color3.fromRGB(220,45,45) or Color3.fromRGB(60,60,60)
		}):Play()
	end
end)

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
CB.MouseButton1Click:Connect(function()
	stopFly() toggleGod(false) toggleNoclip(false) SG:Destroy()
end)
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
-- TOGGLE: whole row is clickable
local function makeToggle(parent,label,order,callback)
	local Row=Instance.new("TextButton")
	Row.Size=UDim2.new(1,0,0,44)
	Row.BackgroundColor3=Color3.fromRGB(160,30,30)
	Row.BorderSizePixel=0 Row.Text=""
	Row.LayoutOrder=order Row.Parent=parent
	Instance.new("UICorner",Row).CornerRadius=UDim.new(0,6)
	local Lbl=Instance.new("TextLabel")
	Lbl.Text=label Lbl.Size=UDim2.new(1,-60,1,0)
	Lbl.Position=UDim2.new(0,10,0,0)
	Lbl.BackgroundTransparency=1
	Lbl.TextColor3=Color3.fromRGB(255,255,255)
	Lbl.TextSize=12 Lbl.Font=Enum.Font.GothamBold
	Lbl.TextXAlignment=Enum.TextXAlignment.Left
	Lbl.ZIndex=2 Lbl.Parent=Row
	local Tog=Instance.new("Frame")
	Tog.Size=UDim2.new(0,44,0,24)
	Tog.Position=UDim2.new(1,-52,0.5,-12)
	Tog.BackgroundColor3=Color3.fromRGB(100,20,20)
	Tog.BorderSizePixel=0 Tog.ZIndex=2 Tog.Parent=Row
	Instance.new("UICorner",Tog).CornerRadius=UDim.new(1,0)
	local Knob=Instance.new("Frame")
	Knob.Size=UDim2.new(0,18,0,18)
	Knob.Position=UDim2.new(0,3,0.5,-9)
	Knob.BackgroundColor3=Color3.fromRGB(255,255,255)
	Knob.BorderSizePixel=0 Knob.ZIndex=3 Knob.Parent=Tog
	Instance.new("UICorner",Knob).CornerRadius=UDim.new(1,0)
	local on=false
	local function flip()
		on=not on
		TweenService:Create(Tog,TweenInfo.new(0.15),{
			BackgroundColor3=on and Color3.fromRGB(255,255,255)or Color3.fromRGB(100,20,20)
		}):Play()
		TweenService:Create(Knob,TweenInfo.new(0.15),{
			BackgroundColor3=on and Color3.fromRGB(220,45,45)or Color3.fromRGB(255,255,255),
			Position=on and UDim2.new(0,23,0.5,-9)or UDim2.new(0,3,0.5,-9)
		}):Play()
		callback(on)
	end
	Row.MouseButton1Click:Connect(flip)
	Row.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.Touch then flip() end
	end)
end
local function makeSlider(parent,label,order,mn,mx,def,callback)
	local C=Instance.new("Frame")
	C.Size=UDim2.new(1,0,0,58)
	C.BackgroundColor3=Color3.fromRGB(160,30,30)
	C.BorderSizePixel=0 C.LayoutOrder=order C.Parent=parent
	Instance.new("UICorner",C).CornerRadius=UDim.new(0,6)
	local Lbl=Instance.new("TextLabel")
	Lbl.Text=label Lbl.Size=UDim2.new(0.65,0,0,22)
	Lbl.Position=UDim2.new(0,10,0,6)
	Lbl.BackgroundTransparency=1
	Lbl.TextColor3=Color3.fromRGB(255,255,255)
	Lbl.TextSize=12 Lbl.Font=Enum.Font.GothamBold
	Lbl.TextXAlignment=Enum.TextXAlignment.Left Lbl.Parent=C
	local VL=Instance.new("TextLabel")
	VL.Text=tostring(def) VL.Size=UDim2.new(0.35,0,0,22)
	VL.Position=UDim2.new(0.65,-10,0,6)
	VL.BackgroundTransparency=1
	VL.TextColor3=Color3.fromRGB(255,220,220)
	VL.TextSize=12 VL.Font=Enum.Font.GothamBold
	VL.TextXAlignment=Enum.TextXAlignment.Right Lbl.Parent=C
	local Track=Instance.new("Frame")
	Track.Size=UDim2.new(1,-20,0,6)
	Track.Position=UDim2.new(0,10,0,38)
	Track.BackgroundColor3=Color3.fromRGB(100,20,20)
	Track.BorderSizePixel=0 Track.Parent=C
	Instance.new("UICorner",Track).CornerRadius=UDim.new(1,0)
	local ir=(def-mn)/(mx-mn)
	local Fill=Instance.new("Frame")
	Fill.Size=UDim2.new(ir,0,1,0)
	Fill.BackgroundColor3=Color3.fromRGB(255,255,255)
	Fill.BorderSizePixel=0 Fill.Parent=Track
	Instance.new("UICorner",Fill).CornerRadius=UDim.new(1,0)
	local SK=Instance.new("TextButton")
	SK.Size=UDim2.new(0,20,0,20)
	SK.Position=UDim2.new(ir,-10,0.5,-10)
	SK.BackgroundColor3=Color3.fromRGB(255,255,255)
	SK.BorderSizePixel=0 SK.Text="" SK.ZIndex=5 SK.Parent=Track
	Instance.new("UICorner",SK).CornerRadius=UDim.new(1,0)
	local drag=false
	local function upd(x)
		local rel=math.clamp((x-Track.AbsolutePosition.X)/Track.AbsoluteSize.X,0,1)
		local val=math.floor(mn+rel*(mx-mn))
		VL.Text=tostring(val)
		Fill.Size=UDim2.new(rel,0,1,0)
		SK.Position=UDim2.new(rel,-10,0.5,-10)
		callback(val)
	end
	SK.MouseButton1Down:Connect(function()drag=true end)
	Track.MouseButton1Down:Connect(function()drag=true upd(UserInputService:GetMouseLocation().X)end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
	UserInputService.InputChanged:Connect(function(i)
		if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X)end end)
	SK.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch then drag=true end end)
	SK.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
	Track.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.Touch then drag=true upd(i.Position.X)end end)
	Track.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
	UserInputService.InputChanged:Connect(function(i)
		if drag and i.UserInputType==Enum.UserInputType.Touch then upd(i.Position.X)end end)
end
local function makeLabel(parent,txt,order)
	local L=Instance.new("TextLabel")
	L.Size=UDim2.new(1,0,0,24)
	L.BackgroundTransparency=1
	L.Text=txt L.LayoutOrder=order
	L.TextColor3=Color3.fromRGB(255,220,220)
	L.TextSize=11 L.Font=Enum.Font.GothamBold
	L.TextXAlignment=Enum.TextXAlignment.Left L.Parent=parent
end
local H=panels[1]
makeLabel(H,"Welcome to Cosmic Hub!",1)
makeToggle(H,"Fly",2,function(on)flying=on if on then startFly()else stopFly()end end)
makeToggle(H,"God Mode",3,function(on)toggleGod(on)end)
makeToggle(H,"Noclip",4,function(on)toggleNoclip(on)end)
makeToggle(H,"Infinite Jump",5,function(on)infiniteJump=on end)
makeSlider(H,"Walk Speed",6,16,150,16,function(v)setSpeed(v)end)
makeSlider(H,"Fly Speed",7,10,200,50,function(v)flySpeed=v end)
local F=panels[2]
makeLabel(F,"Auto Farm Settings",1)
makeToggle(F,"Auto Farm",2,function(on)end)
makeToggle(F,"Auto Quest",3,function(on)end)
makeToggle(F,"Auto Chest",4,function(on)end)
makeSlider(F,"Farm Speed",5,16,150,16,function(v)setSpeed(v)end)
local SE=panels[3]
makeLabel(SE,"Sea Events",1)
makeToggle(SE,"Auto Sea Beast",2,function(on)end)
makeToggle(SE,"Auto Rumble",3,function(on)end)
makeToggle(SE,"Ship Noclip",4,function(on)toggleNoclip(on)end)
local R=panels[4]
makeLabel(R,"Race Features",1)
makeToggle(R,"Auto Race",2,function(on)end)
makeToggle(R,"Infinite Jump",3,function(on)infiniteJump=on end)
makeSlider(R,"Run Speed",4,16,300,16,function(v)setSpeed(v)end)
local FR=panels[5]
makeLabel(FR,"Fruit Features",1)
makeToggle(FR,"Fruit Notifier",2,function(on)end)
makeToggle(FR,"Auto Eat Fruit",3,function(on)end)
makeToggle(FR,"Fruit Sniper",4,function(on)end)
local RA=panels[6]
makeLabel(RA,"Raid Features",1)
makeToggle(RA,"Auto Raid",2,function(on)end)
makeToggle(RA,"God Mode",3,function(on)toggleGod(on)end)
makeToggle(RA,"Fly",4,function(on)flying=on if on then startFly()else stopFly()end end)
local PV=panels[7]
makeLabel(PV,"PVP Features",1)
makeToggle(PV,"God Mode",2,function(on)toggleGod(on)end)
makeToggle(PV,"Noclip",3,function(on)toggleNoclip(on)end)
makeSlider(PV,"Walk Speed",4,16,150,16,function(v)setSpeed(v)end)
makeSlider(PV,"Jump Power",5,50,300,50,function(v)setJump(v)end)
local VI=panels[8]
makeLabel(VI,"Visual Features",1)
makeToggle(VI,"Full Bright",2,function(on)
	game:GetService("Lighting").Brightness=on and 10 or 2 end)
makeToggle(VI,"No Fog",3,function(on)
	game:GetService("Lighting").FogEnd=on and 1e6 or 100000 end)
local MI=panels[9]
makeLabel(MI,"Misc Features",1)
makeToggle(MI,"Infinite Jump",2,function(on)infiniteJump=on end)
makeSlider(MI,"Walk Speed",3,16,150,16,function(v)setSpeed(v)end)
makeSlider(MI,"Jump Power",4,50,300,50,function(v)setJump(v)end)
makeToggle(MI,"Fly",5,function(on)flying=on if on then startFly()else stopFly()end end)
-- MOBILE FLY DPAD
local DPad=Instance.new("Frame")
DPad.Size=UDim2.new(0,160,0,160)
DPad.Position=UDim2.new(0,16,1,-190)
DPad.BackgroundTransparency=1 DPad.Visible=false
DPad.ZIndex=9 DPad.Parent=SG
local VP=Instance.new("Frame")
VP.Size=UDim2.new(0,60,0,120)
VP.Position=UDim2.new(1,-80,1,-190)
VP.BackgroundTransparency=1 VP.Visible=false
VP.ZIndex=9 VP.Parent=SG
local function flyBtn(parent,txt,x,y,w,h,key)
	local b=Instance.new("TextButton")
	b.Size=UDim2.new(0,w,0,h) b.Position=UDim2.new(0,x,0,y)
	b.BackgroundColor3=Color3.fromRGB(180,35,35)
	b.BackgroundTransparency=0.2
	b.BorderSizePixel=0 b.Text=txt
	b.TextColor3=Color3.fromRGB(255,255,255)
	b.TextSize=20 b.Font=Enum.Font.GothamBold
	b.ZIndex=10 b.Parent=parent
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,10)
	b.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.Touch then mi[key]=true end end)
	b.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.Touch then mi[key]=false end end)
end
flyBtn(DPad,"▲",56,0,50,50,"f")
flyBtn(DPad,"▼",56,110,50,50,"b")
flyBtn(DPad,"◀",0,55,50,50,"l")
flyBtn(DPad,"▶",110,55,50,50,"r")
flyBtn(VP,"↑",0,0,60,55,"u")
flyBtn(VP,"↓",0,65,60,55,"d")
RunService.Heartbeat:Connect(function()
	DPad.Visible=flying VP.Visible=flying end)
