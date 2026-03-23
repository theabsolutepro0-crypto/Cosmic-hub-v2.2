local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local LocalPlayer=Players.LocalPlayer
local flying=false
local flySpeed=50
local flyConnection
local mobileInput={forward=false,back=false,left=false,right=false,up=false,down=false}
local function getFlyDir()
	local cam=workspace.CurrentCamera
	local d=Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W)or mobileInput.forward then d+=cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S)or mobileInput.back then d-=cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A)or mobileInput.left then d-=cam.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D)or mobileInput.right then d+=cam.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space)or mobileInput.up then d+=Vector3.new(0,1,0)end
	if UserInputService:IsKeyDown(Enum.KeyCode.Q)or mobileInput.down then d-=Vector3.new(0,1,0)end
	return d
end
local function startFly()
	local char=LocalPlayer.Character if not char then return end
	local hrp=char:FindFirstChild("HumanoidRootPart")
	local hum=char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end
	hum.PlatformStand=true
	for _,n in ipairs({"FlyVel","FlyGyro"})do
		local o=hrp:FindFirstChild(n)if o then o:Destroy()end
	end
	local att=hrp:FindFirstChild("RootAttachment")or Instance.new("Attachment",hrp)
	local bv=Instance.new("LinearVelocity")
	bv.Name="FlyVel" bv.Attachment0=att
	bv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
	bv.MaxForce=1e6 bv.RelativeTo=Enum.ActuatorRelativeTo.World
	bv.VectorVelocity=Vector3.zero bv.Parent=hrp
	local ba=Instance.new("AlignOrientation")
	ba.Name="FlyGyro" ba.Mode=Enum.OrientationAlignmentMode.OneAttachment
	ba.Attachment0=att ba.MaxTorque=1e6 ba.Responsiveness=50
	ba.CFrame=workspace.CurrentCamera.CFrame ba.Parent=hrp
	flyConnection=RunService.Heartbeat:Connect(function(dt)
		if not flying then return end
		local dir=getFlyDir()
		local t=dir.Magnitude>0 and dir.Unit*flySpeed or Vector3.zero
		local v=hrp:FindFirstChild("FlyVel")
		local g=hrp:FindFirstChild("FlyGyro")
		if v then v.VectorVelocity=v.VectorVelocity:Lerp(t,math.min(1,dt*12))end
		if g then g.CFrame=workspace.CurrentCamera.CFrame end
	end)
end
local function stopFly()
	flying=false
	if flyConnection then flyConnection:Disconnect()flyConnection=nil end
	local char=LocalPlayer.Character if not char then return end
	local hrp=char:FindFirstChild("HumanoidRootPart")
	local hum=char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand=false end
	if hrp then
		local v=hrp:FindFirstChild("FlyVel")if v then v:Destroy()end
		local g=hrp:FindFirstChild("FlyGyro")if g then g:Destroy()end
	end
end
local godMode=false local godConn
local noclip=false local noclipConn
local infiniteJump=false
local function toggleGod(state)
	godMode=state
	local char=LocalPlayer.Character if not char then return end
	local hum=char:FindFirstChildOfClass("Humanoid")if not hum then return end
	if state then
		hum.MaxHealth=1e6 hum.Health=1e6
		godConn=RunService.Heartbeat:Connect(function()
			if hum and hum.Health<hum.MaxHealth then hum.Health=hum.MaxHealth end
		end)
	else
		hum.MaxHealth=100 hum.Health=100
		if godConn then godConn:Disconnect()godConn=nil end
	end
end
local function toggleNoclip(state)
	noclip=state
	if state then
		noclipConn=RunService.Stepped:Connect(function()
			local char=LocalPlayer.Character if not char then return end
			for _,p in ipairs(char:GetDescendants())do
				if p:IsA("BasePart")then p.CanCollide=false end
			end
		end)
	else
		if noclipConn then noclipConn:Disconnect()noclipConn=nil end
		local char=LocalPlayer.Character if not char then return end
		for _,p in ipairs(char:GetDescendants())do
			if p:IsA("BasePart")then p.CanCollide=true end
		end
	end
end
local function setSpeed(v)
	local char=LocalPlayer.Character if not char then return end
	local hum=char:FindFirstChildOfClass("Humanoid")if hum then hum.WalkSpeed=v end
end
local function setJump(v)
	local char=LocalPlayer.Character if not char then return end
	local hum=char:FindFirstChildOfClass("Humanoid")if hum then hum.JumpPower=v end
end
UserInputService.JumpRequest:Connect(function()
	if not infiniteJump then return end
	local char=LocalPlayer.Character if not char then return end
	local hum=char:FindFirstChildOfClass("Humanoid")
	if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping)end
end)
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	if flying then startFly()end
	if godMode then toggleGod(true)end
	if noclip then toggleNoclip(true)end
end)
local SG=Instance.new("ScreenGui")
SG.Name="CosmicHub" SG.ResetOnSpawn=false
SG.IgnoreGuiInset=true
SG.Parent=LocalPlayer:WaitForChild("PlayerGui")
local TB=Instance.new("TextButton")
TB.Size=UDim2.new(0,54,0,54)
TB.Position=UDim2.new(0,20,0.5,-27)
TB.BackgroundColor3=Color3.fromRGB(229,57,53)
TB.BorderSizePixel=0 TB.Text="RZ"
TB.TextColor3=Color3.fromRGB(255,255,255)
TB.TextSize=14 TB.Font=Enum.Font.GothamBold
TB.ZIndex=10 TB.Active=true TB.Parent=SG
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,27)
local td,tds,tsp=false,nil,nil
TB.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
		td=true tds=i.Position tsp=TB.Position end end)
TB.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then td=false end end)
UserInputService.InputChanged:Connect(function(i)
	if td and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then
		local d=i.Position-tds
		TB.Position=UDim2.new(tsp.X.Scale,tsp.X.Offset+d.X,tsp.Y.Scale,tsp.Y.Offset+d.Y)end end)
local Main=Instance.new("Frame")
Main.Size=UDim2.new(0,460,0,420)
Main.Position=UDim2.new(0.5,-230,0.5,-210)
Main.BackgroundColor3=Color3.fromRGB(26,26,46)
Main.BorderSizePixel=0 Main.Active=true
Main.Draggable=true Main.Visible=true Main.Parent=SG
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,8)
local mStroke=Instance.new("UIStroke",Main)
mStroke.Color=Color3.fromRGB(229,57,53)mStroke.Thickness=1.5
local vis=true
TB.MouseButton1Click:Connect(function()
	if td then return end
	vis=not vis Main.Visible=vis
	TB.BackgroundColor3=vis and Color3.fromRGB(229,57,53)or Color3.fromRGB(60,60,90)end)
local Hdr=Instance.new("Frame")
Hdr.Size=UDim2.new(1,0,0,36)
Hdr.BackgroundColor3=Color3.fromRGB(229,57,53)
Hdr.BorderSizePixel=0 Hdr.Parent=Main
Instance.new("UICorner",Hdr).CornerRadius=UDim.new(0,8)
local Ttl=Instance.new("TextLabel")
Ttl.Text="COSMIC HUB  v2.2" Ttl.Size=UDim2.new(1,-40,1,0)
Ttl.Position=UDim2.new(0,12,0,0) Ttl.BackgroundTransparency=1
Ttl.TextColor3=Color3.fromRGB(255,255,255)
Ttl.TextSize=14 Ttl.Font=Enum.Font.GothamBold
Ttl.TextXAlignment=Enum.TextXAlignment.Left Ttl.Parent=Hdr
local CB=Instance.new("TextButton")
CB.Text="X" CB.Size=UDim2.new(0,30,0,30)
CB.Position=UDim2.new(1,-35,0,3) CB.BackgroundTransparency=1
CB.TextColor3=Color3.fromRGB(255,255,255)
CB.TextSize=14 CB.Font=Enum.Font.Gotham CB.Parent=Hdr
CB.MouseButton1Click:Connect(function()
	stopFly()toggleGod(false)toggleNoclip(false)SG:Destroy()end)
local TabBar=Instance.new("Frame")
TabBar.Size=UDim2.new(1,0,0,30) TabBar.Position=UDim2.new(0,0,0,36)
TabBar.BackgroundColor3=Color3.fromRGB(18,18,42)
TabBar.BorderSizePixel=0 TabBar.Parent=Main
local tbl=Instance.new("UIListLayout",TabBar)
tbl.FillDirection=Enum.FillDirection.Horizontal
tbl.SortOrder=Enum.SortOrder.LayoutOrder
local panels={} local tbBtns={}
local tabNames={"Combat","Movement","NDS","Misc"}
for i,n in ipairs(tabNames)do
	local T=Instance.new("TextButton")
	T.Text=n T.Size=UDim2.new(0,115,1,0)
	T.BackgroundTransparency=1
	T.TextColor3=i==3 and Color3.fromRGB(229,57,53)or Color3.fromRGB(150,150,150)
	T.TextSize=11 T.Font=Enum.Font.Gotham T.LayoutOrder=i T.Parent=TabBar
	tbBtns[i]=T
	local P=Instance.new("ScrollingFrame")
	P.Size=UDim2.new(1,-110,1,-108) P.Position=UDim2.new(0,110,0,66)
	P.BackgroundTransparency=1 P.BorderSizePixel=0
	P.ScrollBarThickness=3
	P.ScrollBarImageColor3=Color3.fromRGB(229,57,53)
	P.CanvasSize=UDim2.new(0,0,0,0)
	P.AutomaticCanvasSize=Enum.AutomaticSize.Y
	P.Visible=i==3 P.Parent=Main
	Instance.new("UIListLayout",P).SortOrder=Enum.SortOrder.LayoutOrder
	panels[i]=P
	T.MouseButton1Click:Connect(function()
		for j,p in ipairs(panels)do
			p.Visible=j==i
			tbBtns[j].TextColor3=j==i and Color3.fromRGB(229,57,53)or Color3.fromRGB(150,150,150)
		end
	end)
end
local SB=Instance.new("ScrollingFrame")
SB.Size=UDim2.new(0,110,1,-108) SB.Position=UDim2.new(0,0,0,66)
SB.BackgroundColor3=Color3.fromRGB(18,18,42)
SB.BorderSizePixel=0 SB.ScrollBarThickness=2
SB.ScrollBarImageColor3=Color3.fromRGB(229,57,53)
SB.CanvasSize=UDim2.new(0,0,0,0)
SB.AutomaticCanvasSize=Enum.AutomaticSize.Y SB.Parent=Main
Instance.new("UIListLayout",SB).SortOrder=Enum.SortOrder.LayoutOrder
local sbItems={"Fly","God Mode","Noclip","Inf Jump","Walk Spd","Jump Pwr","Fly Spd"}
local sbBtns={}
for i,item in ipairs(sbItems)do
	local B=Instance.new("TextButton")
	B.Text=item B.Size=UDim2.new(1,0,0,36)
	B.BackgroundTransparency=i==1 and 0.85 or 1
	B.BackgroundColor3=Color3.fromRGB(26,26,46)
	B.TextColor3=i==1 and Color3.fromRGB(229,57,53)or Color3.fromRGB(170,170,170)
	B.TextSize=11 B.Font=Enum.Font.Gotham
	B.TextXAlignment=Enum.TextXAlignment.Left
	B.LayoutOrder=i B.Parent=SB
	Instance.new("UIPadding",B).PaddingLeft=UDim.new(0,12)
	sbBtns[i]=B
end
local scrollMap={[1]=0,[2]=44,[3]=88,[4]=132,[5]=204,[6]=260,[7]=316}
local function setSide(idx)
	for i,b in ipairs(sbBtns)do
		b.BackgroundTransparency=i==idx and 0.85 or 1
		b.TextColor3=i==idx and Color3.fromRGB(229,57,53)or Color3.fromRGB(170,170,170)
	end
	for j,p in ipairs(panels)do
		p.Visible=j==3
		tbBtns[j].TextColor3=j==3 and Color3.fromRGB(229,57,53)or Color3.fromRGB(150,150,150)
	end
	if scrollMap[idx]then
		TweenService:Create(panels[3],TweenInfo.new(0.3),{CanvasPosition=Vector2.new(0,scrollMap[idx])}):Play()
	end
end
for i,b in ipairs(sbBtns)do
	b.MouseButton1Click:Connect(function()setSide(i)end)
	b.InputEnded:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.Touch then setSide(i)end end)
end
local function makeToggle(parent,label,order,callback)
	local Row=Instance.new("Frame")
	Row.Size=UDim2.new(1,0,0,44) Row.BackgroundTransparency=1
	Row.LayoutOrder=order Row.Parent=parent
	local Pad=Instance.new("UIPadding",Row)
	Pad.PaddingLeft=UDim.new(0,10) Pad.PaddingRight=UDim.new(0,10)
	local Lbl=Instance.new("TextLabel")
	Lbl.Text=label Lbl.Size=UDim2.new(1,-50,1,0)
	Lbl.BackgroundTransparency=1 Lbl.TextColor3=Color3.fromRGB(200,200,200)
	Lbl.TextSize=12 Lbl.Font=Enum.Font.Gotham
	Lbl.TextXAlignment=Enum.TextXAlignment.Left Lbl.Parent=Row
	local Tog=Instance.new("TextButton")
	Tog.Size=UDim2.new(0,40,0,22) Tog.Position=UDim2.new(1,-40,0.5,-11)
	Tog.BackgroundColor3=Color3.fromRGB(42,42,74)
	Tog.BorderSizePixel=0 Tog.Text="" Tog.Parent=Row
	Instance.new("UICorner",Tog).CornerRadius=UDim.new(1,0)
	local Knob=Instance.new("Frame")
	Knob.Size=UDim2.new(0,16,0,16) Knob.Position=UDim2.new(0,3,0.5,-8)
	Knob.BackgroundColor3=Color3.fromRGB(255,255,255)
	Knob.BorderSizePixel=0 Knob.Parent=Tog
	Instance.new("UICorner",Knob).CornerRadius=UDim.new(1,0)
	local Div=Instance.new("Frame")
	Div.Size=UDim2.new(1,0,0,1) Div.Position=UDim2.new(0,0,1,-1)
	Div.BackgroundColor3=Color3.fromRGB(42,42,74)
	Div.BorderSizePixel=0 Div.Parent=Row
	local on=false
	local function flip()
		on=not on
		TweenService:Create(Tog,TweenInfo.new(0.15),{BackgroundColor3=on and Color3.fromRGB(229,57,53)or Color3.fromRGB(42,42,74)}):Play()
		TweenService:Create(Knob,TweenInfo.new(0.15),{Position=on and UDim2.new(0,21,0.5,-8)or UDim2.new(0,3,0.5,-8)}):Play()
		callback(on)
	end
	Tog.MouseButton1Click:Connect(flip)
	Tog.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch then flip()end end)
end
local function makeSlider(parent,label,order,mn,mx,def,callback)
	local C=Instance.new("Frame")
	C.Size=UDim2.new(1,0,0,56) C.BackgroundTransparency=1
	C.LayoutOrder=order C.Parent=parent
	local Pad=Instance.new("UIPadding",C)
	Pad.PaddingLeft=UDim.new(0,10) Pad.PaddingRight=UDim.new(0,10)
	local LR=Instance.new("Frame")
	LR.Size=UDim2.new(1,0,0,24) LR.BackgroundTransparency=1 LR.Parent=C
	local Lbl=Instance.new("TextLabel")
	Lbl.Text=label Lbl.Size=UDim2.new(0.7,0,1,0)
	Lbl.BackgroundTransparency=1 Lbl.TextColor3=Color3.fromRGB(200,200,200)
	Lbl.TextSize=12 Lbl.Font=Enum.Font.Gotham
	Lbl.TextXAlignment=Enum.TextXAlignment.Left Lbl.Parent=LR
	local VL=Instance.new("TextLabel")
	VL.Text=tostring(def) VL.Size=UDim2.new(0.3,0,1,0)
	VL.Position=UDim2.new(0.7,0,0,0) VL.BackgroundTransparency=1
	VL.TextColor3=Color3.fromRGB(229,57,53) VL.TextSize=12
	VL.Font=Enum.Font.GothamBold
	VL.TextXAlignment=Enum.TextXAlignment.Right VL.Parent=LR
	local Track=Instance.new("Frame")
	Track.Size=UDim2.new(1,0,0,8) Track.Position=UDim2.new(0,0,0,30)
	Track.BackgroundColor3=Color3.fromRGB(42,42,74)
	Track.BorderSizePixel=0 Track.Parent=C
	Instance.new("UICorner",Track).CornerRadius=UDim.new(1,0)
	local ir=(def-mn)/(mx-mn)
	local Fill=Instance.new("Frame")
	Fill.Size=UDim2.new(ir,0,1,0) Fill.BackgroundColor3=Color3.fromRGB(229,57,53)
	Fill.BorderSizePixel=0 Fill.Parent=Track
	Instance.new("UICorner",Fill).CornerRadius=UDim.new(1,0)
	local SK=Instance.new("TextButton")
	SK.Size=UDim2.new(0,20,0,20) SK.Position=UDim2.new(ir,-10,0.5,-10)
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
local NP=panels[3]
local function secHdr(txt,ord)
	local F=Instance.new("Frame")
	F.Size=UDim2.new(1,0,0,28) F.BackgroundTransparency=1
	F.LayoutOrder=ord F.Parent=NP
	local L=Instance.new("TextLabel")
	L.Text=txt L.Size=UDim2.new(1,-10,1,0)
	L.Position=UDim2.new(0,10,0,0) L.BackgroundTransparency=1
	L.TextColor3=Color3.fromRGB(229,57,53) L.TextSize=10
	L.Font=Enum.Font.GothamBold
	L.TextXAlignment=Enum.TextXAlignment.Left L.Parent=F
end
secHdr("NATURAL DISASTER SURVIVAL",1)
makeToggle(NP,"Fly",2,function(on)flying=on if on then startFly()else stopFly()end end)
makeToggle(NP,"God Mode",3,function(on)toggleGod(on)end)
makeToggle(NP,"Noclip",4,function(on)toggleNoclip(on)end)
makeToggle(NP,"Infinite Jump",5,function(on)infiniteJump=on end)
secHdr("SPEED & POWER",6)
makeSlider(NP,"Walk Speed",7,16,150,16,function(v)setSpeed(v)end)
makeSlider(NP,"Jump Power",8,50,300,50,function(v)setJump(v)end)
makeSlider(NP,"Fly Speed",9,10,200,50,function(v)flySpeed=v end)
local function makeDBtn(parent,txt,x,y,w,h,key)
	local b=Instance.new("TextButton")
	b.Size=UDim2.new(0,w,0,h) b.Position=UDim2.new(0,x,0,y)
	b.BackgroundColor3=Color3.fromRGB(40,40,70) b.BorderSizePixel=0
	b.Text=txt b.TextColor3=Color3.fromRGB(255,255,255)
	b.TextSize=16 b.Font=Enum.Font.GothamBold b.ZIndex=11 b.Parent=parent
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
	local s=Instance.new("UIStroke",b)s.Color=Color3.fromRGB(229,57,53)s.Thickness=1
	b.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then mobileInput[key]=true end end)
	b.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then mobileInput[key]=false end end)
end
local DPad=Instance.new("Frame")
DPad.Size=UDim2.new(0,140,0,140) DPad.Position=UDim2.new(0,20,1,-180)
DPad.BackgroundTransparency=1 DPad.Visible=false DPad.ZIndex=10 DPad.Parent=SG
makeDBtn(DPad,"▲",46,0,48,44,"forward")
makeDBtn(DPad,"▼",46,96,48,44,"back")
makeDBtn(DPad,"◀",0,46,44,48,"left")
makeDBtn(DPad,"▶",96,46,44,48,"right")
local VP=Instance.new("Frame")
VP.Size=UDim2.new(0,80,0,80) VP.Position=UDim2.new(1,-100,1,-100)
VP.BackgroundTransparency=1 VP.Visible=false VP.ZIndex=10 VP.Parent=SG
makeDBtn(VP,"↑",0,0,80,36,"up")
makeDBtn(VP,"↓",0,44,80,36,"down")
RunService.Heartbeat:Connect(function()DPad.Visible=flying VP.Visible=flying end)
local Ft=Instance.new("Frame")
Ft.Size=UDim2.new(1,0,0,24) Ft.Position=UDim2.new(0,0,1,-24)
Ft.BackgroundColor3=Color3.fromRGB(18,18,42) Ft.BorderSizePixel=0 Ft.Parent=Main
local FL=Instance.new("TextLabel")
FL.Text="Cosmic Hub v2.2  |  loadstring ready"
FL.Size=UDim2.new(1,0,1,0) FL.BackgroundTransparency=1
FL.TextColor3=Color3.fromRGB(80,80,100) FL.TextSize=10
FL.Font=Enum.Font.Gotham FL.Parent=Ft
