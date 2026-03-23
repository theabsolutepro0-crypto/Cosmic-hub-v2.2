local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local LP=Players.LocalPlayer
local flying=false
local flySpeed=50
local flyConn=nil
local godConn=nil
local godMode=false
local noclip=false
local noclipConn=nil
local infJump=false
local mob={f=false,b=false,l=false,r=false,u=false,d=false}
local function getFlyDir()
local cam=workspace.CurrentCamera
local d=Vector3.zero
if UIS:IsKeyDown(Enum.KeyCode.W)or mob.f then d+=cam.CFrame.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.S)or mob.b then d-=cam.CFrame.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.A)or mob.l then d-=cam.CFrame.RightVector end
if UIS:IsKeyDown(Enum.KeyCode.D)or mob.r then d+=cam.CFrame.RightVector end
if UIS:IsKeyDown(Enum.KeyCode.Space)or mob.u then d+=Vector3.new(0,1,0) end
if UIS:IsKeyDown(Enum.KeyCode.Q)or mob.d then d-=Vector3.new(0,1,0) end
return d
end
local function startFly()
local char=LP.Character if not char then return end
local hrp=char:FindFirstChild("HumanoidRootPart")
local hum=char:FindFirstChildOfClass("Humanoid")
if not hrp or not hum then return end
hum.PlatformStand=true
for _,n in ipairs({"FV","FG"})do local o=hrp:FindFirstChild(n)if o then o:Destroy()end end
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
flyConn=RS.Heartbeat:Connect(function(dt)
if not flying then return end
local dir=getFlyDir()
local t=dir.Magnitude>0 and dir.Unit*flySpeed or Vector3.zero
bv.VectorVelocity=bv.VectorVelocity:Lerp(t,math.min(1,dt*12))
ba.CFrame=workspace.CurrentCamera.CFrame
end)
end
local function stopFly()
flying=false
if flyConn then flyConn:Disconnect() flyConn=nil end
local char=LP.Character if not char then return end
local hrp=char:FindFirstChild("HumanoidRootPart")
local hum=char:FindFirstChildOfClass("Humanoid")
if hum then hum.PlatformStand=false end
if hrp then
local v=hrp:FindFirstChild("FV")if v then v:Destroy()end
local g=hrp:FindFirstChild("FG")if g then g:Destroy()end
end
end
local function toggleGod(state)
godMode=state
local char=LP.Character if not char then return end
local hum=char:FindFirstChildOfClass("Humanoid")if not hum then return end
if state then hum.MaxHealth=1e6 hum.Health=1e6
godConn=RS.Heartbeat:Connect(function()
if hum and hum.Health<hum.MaxHealth then hum.Health=hum.MaxHealth end end)
else hum.MaxHealth=100 hum.Health=100
if godConn then godConn:Disconnect() godConn=nil end end
end
local function toggleNoclip(state)
noclip=state
if state then noclipConn=RS.Stepped:Connect(function()
local char=LP.Character if not char then return end
for _,p in ipairs(char:GetDescendants())do
if p:IsA("BasePart")then p.CanCollide=false end end end)
else if noclipConn then noclipConn:Disconnect() noclipConn=nil end
local char=LP.Character if not char then return end
for _,p in ipairs(char:GetDescendants())do
if p:IsA("BasePart")then p.CanCollide=true end end end
end
UIS.JumpRequest:Connect(function()
if not infJump then return end
local char=LP.Character if not char then return end
local hum=char:FindFirstChildOfClass("Humanoid")
if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping)end end)
LP.CharacterAdded:Connect(function()
task.wait(0.5)
if flying then startFly()end
if godMode then toggleGod(true)end
if noclip then toggleNoclip(true)end end)
local SG=Instance.new("ScreenGui")
SG.Name="CosmicHub" SG.ResetOnSpawn=false
SG.IgnoreGuiInset=true SG.Parent=LP:WaitForChild("PlayerGui")
local Main=Instance.new("Frame")
Main.Size=UDim2.new(0,500,0,460)
Main.Position=UDim2.new(0.5,-250,0.5,-230)
Main.BackgroundColor3=Color3.fromRGB(26,26,46)
Main.BorderSizePixel=0 Main.Active=true
Main.Draggable=true Main.Visible=true Main.Parent=SG
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,8)
local st=Instance.new("UIStroke",Main)
st.Color=Color3.fromRGB(229,57,53) st.Thickness=1.5
local Hdr=Instance.new("Frame")
Hdr.Size=UDim2.new(1,0,0,44)
Hdr.BackgroundColor3=Color3.fromRGB(229,57,53)
Hdr.BorderSizePixel=0 Hdr.Parent=Main
Instance.new("UICorner",Hdr).CornerRadius=UDim.new(0,8)
local Ttl=Instance.new("TextLabel")
Ttl.Text="COSMIC HUB  v2.2"
Ttl.Size=UDim2.new(1,-50,1,0)
Ttl.Position=UDim2.new(0,14,0,0)
Ttl.BackgroundTransparency=1
Ttl.TextColor3=Color3.fromRGB(255,255,255)
Ttl.TextSize=15 Ttl.Font=Enum.Font.GothamBold
Ttl.TextXAlignment=Enum.TextXAlignment.Left Ttl.Parent=Hdr
local CB=Instance.new("TextButton")
CB.Text="X" CB.Size=UDim2.new(0,36,0,36)
CB.Position=UDim2.new(1,-40,0,4)
CB.BackgroundTransparency=1
CB.TextColor3=Color3.fromRGB(255,255,255)
CB.TextSize=16 CB.Font=Enum.Font.GothamBold CB.Parent=Hdr
CB.MouseButton1Click:Connect(function()
stopFly() toggleGod(false) toggleNoclip(false) SG:Destroy() end)
local SB=Instance.new("ScrollingFrame")
SB.Size=UDim2.new(0,120,1,-116)
SB.Position=UDim2.new(0,0,0,78)
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
B.Text=item B.Size=UDim2.new(1,0,0,40)
B.BackgroundTransparency=i==1 and 0.85 or 1
B.BackgroundColor3=Color3.fromRGB(26,26,46)
B.TextColor3=i==1 and Color3.fromRGB(229,57,53)or Color3.fromRGB(170,170,170)
B.TextSize=12 B.Font=Enum.Font.Gotham
B.TextXAlignment=Enum.TextXAlignment.Left
B.LayoutOrder=i B.Parent=SB
Instance.new("UIPadding",B).PaddingLeft=UDim.new(0,12)
sbBtns[i]=B end
local scrollMap={[1]=0,[2]=48,[3]=96,[4]=144,[5]=220,[6]=284,[7]=348}
local function setSide(idx)
for i,b in ipairs(sbBtns)do
b.BackgroundTransparency=i==idx and 0.85 or 1
b.TextColor3=i==idx and Color3.fromRGB(229,57,53)or Color3.fromRGB(170,170,170)end
for j,p in ipairs(panels)do
p.Visible=j==3
tbBtns[j].TextColor3=j==3 and Color3.fromRGB(229,57,53)or Color3.fromRGB(150,150,150)end
if scrollMap[idx]then
TweenService:Create(panels[3],TweenInfo.new(0.3),
{CanvasPosition=Vector2.new(0,scrollMap[idx])}):Play()end end
for i,b in ipairs(sbBtns)do
b.MouseButton1Click:Connect(function()setSide(i)end)
b.InputEnded:Connect(function(inp)
if inp.UserInputType==Enum.UserInputType.Touch then setSide(i)end end)end
local Ft=Instance.new("Frame")
Ft.Size=UDim2.new(1,0,0,26) Ft.Position=UDim2.new(0,0,1,-26)
Ft.BackgroundColor3=Color3.fromRGB(18,18,42) Ft.BorderSizePixel=0 Ft.Parent=Main
local FL=Instance.new("TextLabel")
FL.Text="Cosmic Hub v2.2  |  loadstring ready"
FL.Size=UDim2.new(1,0,1,0) FL.BackgroundTransparency=1
FL.TextColor3=Color3.fromRGB(80,80,100) FL.TextSize=11
FL.Font=Enum.Font.Gotham FL.Parent=Ft
local function mkToggle(parent,label,order,cb)
local Row=Instance.new("Frame")
Row.Size=UDim2.new(1,0,0,50) Row.BackgroundTransparency=1
Row.LayoutOrder=order Row.Parent=parent
local Pad=Instance.new("UIPadding",Row)
Pad.PaddingLeft=UDim.new(0,12) Pad.PaddingRight=UDim.new(0,12)
local Lbl=Instance.new("TextLabel")
Lbl.Text=label Lbl.Size=UDim2.new(1,-60,1,0)
Lbl.BackgroundTransparency=1 Lbl.TextColor3=Color3.fromRGB(200,200,200)
Lbl.TextSize=13 Lbl.Font=Enum.Font.Gotham
Lbl.TextXAlignment=Enum.TextXAlignment.Left Lbl.Parent=Row
local Tog=Instance.new("TextButton")
Tog.Size=UDim2.new(0,46,0,26) Tog.Position=UDim2.new(1,-46,0.5,-13)
Tog.BackgroundColor3=Color3.fromRGB(42,42,74)
Tog.BorderSizePixel=0 Tog.Text="" Tog.Parent=Row
Instance.new("UICorner",Tog).CornerRadius=UDim.new(1,0)
local Knob=Instance.new("Frame")
Knob.Size=UDim2.new(0,20,0,20) Knob.Position=UDim2.new(0,3,0.5,-10)
Knob.BackgroundColor3=Color3.fromRGB(255,255,255)
Knob.BorderSizePixel=0 Knob.Parent=Tog
Instance.new("UICorner",Knob).CornerRadius=UDim.new(1,0)
local Div=Instance.new("Frame")
Div.Size=UDim2.new(1,0,0,1) Div.Position=UDim2.new(0,0,1,-1)
Div.BackgroundColor3=Color3.fromRGB(42,42,74) Div.BorderSizePixel=0 Div.Parent=Row
local on=false
local function flip()
on=not on
TweenService:Create(Tog,TweenInfo.new(0.15),{BackgroundColor3=on and Color3.fromRGB(229,57,53)or Color3.fromRGB(42,42,74)}):Play()
TweenService:Create(Knob,TweenInfo.new(0.15),{Position=on and UDim2.new(0,23,0.5,-10)or UDim2.new(0,3,0.5,-10)}):Play()
cb(on)end
Tog.MouseButton1Click:Connect(flip)
Tog.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.Touch then flip()end end)
return Row end
local function mkSlider(parent,label,order,mn,mx,def,cb)
local C=Instance.new("Frame")
C.Size=UDim2.new(1,0,0,64) C.BackgroundTransparency=1
C.LayoutOrder=order C.Parent=parent
local Pad=Instance.new("UIPadding",C)
Pad.PaddingLeft=UDim.new(0,12) Pad.PaddingRight=UDim.new(0,12)
local LR=Instance.new("Frame")
LR.Size=UDim2.new(1,0,0,26) LR.BackgroundTransparency=1 LR.Parent=C
local Lbl=Instance.new("TextLabel")
Lbl.Text=label Lbl.Size=UDim2.new(0.7,0,1,0)
Lbl.BackgroundTransparency=1 Lbl.TextColor3=Color3.fromRGB(200,200,200)
Lbl.TextSize=13 Lbl.Font=Enum.Font.Gotham
Lbl.TextXAlignment=Enum.TextXAlignment.Left Lbl.Parent=LR
local VL=Instance.new("TextLabel")
VL.Text=tostring(def) VL.Size=UDim2.new(0.3,0,1,0)
VL.Position=UDim2.new(0.7,0,0,0) VL.BackgroundTransparency=1
VL.TextColor3=Color3.fromRGB(229,57,53) VL.TextSize=13
VL.Font=Enum.Font.GothamBold
VL.TextXAlignment=Enum.TextXAlignment.Right VL.Parent=LR
local Track=Instance.new("Frame")
Track.Size=UDim2.new(1,0,0,10) Track.Position=UDim2.new(0,0,0,32)
Track.BackgroundColor3=Color3.fromRGB(42,42,74)
Track.BorderSizePixel=0 Track.Parent=C
Instance.new("UICorner",Track).CornerRadius=UDim.new(1,0)
local ir=(def-mn)/(mx-mn)
local Fill=Instance.new("Frame")
Fill.Size=UDim2.new(ir,0,1,0)
Fill.BackgroundColor3=Color3.fromRGB(229,57,53)
Fill.BorderSizePixel=0 Fill.Parent=Track
Instance.new("UICorner",Fill).CornerRadius=UDim.new(1,0)
local SK=Instance.new("TextButton")
SK.Size=UDim2.new(0,24,0,24) SK.Position=UDim2.new(ir,-12,0.5,-12)
SK.BackgroundColor3=Color3.fromRGB(255,255,255)
SK.BorderSizePixel=0 SK.Text="" SK.ZIndex=5 SK.Parent=Track
Instance.new("UICorner",SK).CornerRadius=UDim.new(1,0)
local Div=Instance.new("Frame")
Div.Size=UDim2.new(1,0,0,1) Div.Position=UDim2.new(0,0,1,0)
Div.BackgroundColor3=Color3.fromRGB(42,42,74) Div.BorderSizePixel=0 Div.Parent=C
local drag=false
local function upd(x)
local rel=math.clamp((x-Track.AbsolutePosition.X)/Track.AbsoluteSize.X,0,1)
local val=math.floor(mn+rel*(mx-mn))
VL.Text=tostring(val) Fill.Size=UDim2.new(rel,0,1,0)
SK.Position=UDim2.new(rel,-12,0.5,-12) cb(val)end
SK.MouseButton1Down:Connect(function()drag=true end)
Track.MouseButton1Down:Connect(function()drag=true upd(UIS:GetMouseLocation().X)end)
UIS.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
UIS.InputChanged:Connect(function(i)
if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X)end end)
SK.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch then drag=true end end)
SK.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
Track.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.Touch then drag=true upd(i.Position.X)end end)
Track.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
UIS.InputChanged:Connect(function(i)
if drag and i.UserInputType==Enum.UserInputType.Touch then upd(i.Position.X)end end)
return C end
local NP=panels[3]
local function secHdr(txt,ord)
local F=Instance.new("Frame")
F.Size=UDim2.new(1,0,0,30) F.BackgroundTransparency=1
F.LayoutOrder=ord F.Parent=NP
local L=Instance.new("TextLabel")
L.Text=txt L.Size=UDim2.new(1,-12,1,0)
L.Position=UDim2.new(0,12,0,0) L.BackgroundTransparency=1
L.TextColor3=Color3.fromRGB(229,57,53) L.TextSize=11
L.Font=Enum.Font.GothamBold
L.TextXAlignment=Enum.TextXAlignment.Left L.Parent=F end
secHdr("NATURAL DISASTER SURVIVAL",1)
mkToggle(NP,"Fly",2,function(on)flying=on if on then startFly()else stopFly()end end)
mkToggle(NP,"God Mode",3,function(on)toggleGod(on)end)
mkToggle(NP,"Noclip",4,function(on)toggleNoclip(on)end)
mkToggle(NP,"Infinite Jump",5,function(on)infJump=on end)
secHdr("SPEED & POWER",6)
mkSlider(NP,"Walk Speed",7,16,150,16,function(v)
local char=LP.Character if not char then return end
local hum=char:FindFirstChildOfClass("Humanoid")if hum then hum.WalkSpeed=v end end)
mkSlider(NP,"Jump Power",8,50,300,50,function(v)
local char=LP.Character if not char then return end
local hum=char:FindFirstChildOfClass("Humanoid")if hum then hum.JumpPower=v end end)
mkSlider(NP,"Fly Speed",9,10,200,50,function(v)flySpeed=v end)
local DPad=Instance.new("Frame")
DPad.Size=UDim2.new(0,150,0,150)
DPad.Position=UDim2.new(0,20,1,-190)
DPad.BackgroundTransparency=1 DPad.Visible=false
DPad.ZIndex=10 DPad.Parent=SG
local VP=Instance.new("Frame")
VP.Size=UDim2.new(0,80,0,86)
VP.Position=UDim2.new(1,-110,1,-190)
VP.BackgroundTransparency=1 VP.Visible=false
VP.ZIndex=10 VP.Parent=SG
local function mkDBtn(par,txt,x,y,w,h,key)
local b=Instance.new("TextButton")
b.Size=UDim2.new(0,w,0,h) b.Position=UDim2.new(0,x,0,y)
b.BackgroundColor3=Color3.fromRGB(40,40,70) b.BorderSizePixel=0
b.Text=txt b.TextColor3=Color3.fromRGB(255,255,255)
b.TextSize=18 b.Font=Enum.Font.GothamBold b.ZIndex=11 b.Parent=par
Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",b).Color=Color3.fromRGB(229,57,53)
b.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.Touch or
i.UserInputType==Enum.UserInputType.MouseButton1 then mob[key]=true end end)
b.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.Touch or
i.UserInputType==Enum.UserInputType.MouseButton1 then mob[key]=false end end)end
mkDBtn(DPad,"▲",51,0,48,48,"f")
mkDBtn(DPad,"▼",51,102,48,48,"b")
mkDBtn(DPad,"◀",0,51,48,48,"l")
mkDBtn(DPad,"▶",102,51,48,48,"r")
local cc=Instance.new("Frame")
cc.Size=UDim2.new(0,42,0,42) cc.Position=UDim2.new(0,54,0,54)
cc.BackgroundColor3=Color3.fromRGB(30,30,55) cc.BorderSizePixel=0
cc.ZIndex=11 cc.Parent=DPad
Instance.new("UICorner",cc).CornerRadius=UDim.new(1,0)
mkDBtn(VP,"↑",0,0,80,38,"u")
mkDBtn(VP,"↓",0,48,80,38,"d")
RS.Heartbeat:Connect(function()
DPad.Visible=flying VP.Visible=flying end)
local TB=Instance.new("TextButton")
TB.Size=UDim2.new(0,60,0,60)
TB.Position=UDim2.new(0,16,0.5,-30)
TB.BackgroundColor3=Color3.fromRGB(229,57,53)
TB.BorderSizePixel=0 TB.Text="RZ"
TB.TextColor3=Color3.fromRGB(255,255,255)
TB.TextSize=15 TB.Font=Enum.Font.GothamBold
TB.ZIndex=20 TB.Active=true TB.Parent=SG
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,30)
local ts=Instance.new("UIStroke",TB)
ts.Color=Color3.fromRGB(255,255,255) ts.Thickness=2
local td,tds,tsp,moved=false,nil,nil,false
TB.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.Touch or
i.UserInputType==Enum.UserInputType.MouseButton1 then
td=true moved=false tds=i.Position tsp=TB.Position end end)
TB.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.Touch or
i.UserInputType==Enum.UserInputType.MouseButton1 then
td=false
if not moved then
local vis=not Main.Visible Main.Visible=vis
TB.BackgroundColor3=vis and Color3.fromRGB(229,57,53)or Color3.fromRGB(60,60,90)
end end end)
UIS.InputChanged:Connect(function(i)
if td and(i.UserInputType==Enum.UserInputType.MouseMovement or
i.UserInputType==Enum.UserInputType.Touch)then
local d=i.Position-tds
if math.abs(d.X)>6 or math.abs(d.Y)>6 then moved=true end
TB.Position=UDim2.new(tsp.X.Scale,tsp.X.Offset+d.X,
tsp.Y.Scale,tsp.Y.Offset+d.Y)end end)










