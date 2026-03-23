local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- === STATE ===
local flying = false
local flySpeed = 50
local flyConn
local godConn
local noclipConn
local infiniteJump = false
local godMode = false
local noclip = false
local mobileInput = {forward=false,back=false,left=false,right=false,up=false,down=false}

-- === SUPERMAN FLY ===
local function getFlyDir()
	local cam = workspace.CurrentCamera
	local d = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) or mobileInput.forward then d += cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) or mobileInput.back then d -= cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) or mobileInput.left then d -= cam.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) or mobileInput.right then d += cam.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) or mobileInput.up then d += Vector3.new(0,1,0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.Q) or mobileInput.down then d -= Vector3.new(0,1,0) end
	return d
end

local function startFly()
	local char = LocalPlayer.Character if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end
	hum.PlatformStand = true
	for _,n in ipairs({"FlyVel","FlyGyro"}) do
		local o = hrp:FindFirstChild(n) if o then o:Destroy() end
	end
	-- Superman pose: tilt character forward
	local att = hrp:FindFirstChild("RootAttachment") or Instance.new("Attachment", hrp)
	local bv = Instance.new("LinearVelocity")
	bv.Name = "FlyVel" bv.Attachment0 = att
	bv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	bv.MaxForce = 1e6
	bv.RelativeTo = Enum.ActuatorRelativeTo.World
	bv.VectorVelocity = Vector3.zero bv.Parent = hrp
	local ba = Instance.new("AlignOrientation")
	ba.Name = "FlyGyro"
	ba.Mode = Enum.OrientationAlignmentMode.OneAttachment
	ba.Attachment0 = att ba.MaxTorque = 1e6
	ba.Responsiveness = 50 ba.Parent = hrp
	flyConn = RunService.Heartbeat:Connect(function(dt)
		if not flying then return end
		local dir = getFlyDir()
		local target = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
		local v = hrp:FindFirstChild("FlyVel")
		local g = hrp:FindFirstChild("FlyGyro")
		if v then v.VectorVelocity = v.VectorVelocity:Lerp(target, math.min(1, dt * 10)) end
		-- Superman tilt: rotate toward movement direction
		if g then
			local cam = workspace.CurrentCamera
			if dir.Magnitude > 0 then
				local flatDir = Vector3.new(dir.X, 0, dir.Z)
				if flatDir.Magnitude > 0.1 then
					local tiltCF = CFrame.new(Vector3.zero, flatDir) * CFrame.Angles(-math.rad(40), 0, 0)
					g.CFrame = g.CFrame:Lerp(CFrame.new(hrp.Position) * tiltCF, dt * 8)
				else
					g.CFrame = g.CFrame:Lerp(cam.CFrame, dt * 8)
				end
			else
				g.CFrame = g.CFrame:Lerp(cam.CFrame, dt * 6)
			end
		end
	end)
end

local function stopFly()
	flying = false
	if flyConn then flyConn:Disconnect() flyConn = nil end
	local char = LocalPlayer.Character if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end
	if hrp then
		local v = hrp:FindFirstChild("FlyVel") if v then v:Destroy() end
		local g = hrp:FindFirstChild("FlyGyro") if g then g:Destroy() end
	end
end

-- === GOD MODE ===
local function toggleGod(state)
	godMode = state
	local char = LocalPlayer.Character if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid") if not hum then return end
	if state then
		hum.MaxHealth = 1e6 hum.Health = 1e6
		godConn = RunService.Heartbeat:Connect(function()
			if hum and hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
		end)
	else
		hum.MaxHealth = 100 hum.Health = 100
		if godConn then godConn:Disconnect() godConn = nil end
	end
end

-- === NOCLIP ===
local function toggleNoclip(state)
	noclip = state
	if state then
		noclipConn = RunService.Stepped:Connect(function()
			local char = LocalPlayer.Character if not char then return end
			for _,p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end)
	else
		if noclipConn then noclipConn:Disconnect() noclipConn = nil end
		local char = LocalPlayer.Character if not char then return end
		for _,p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = true end
		end
	end
end

-- === SPEED / JUMP ===
local function setSpeed(v)
	local char = LocalPlayer.Character if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed = v end
end
local function setJump(v)
	local char = LocalPlayer.Character if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid") if hum then hum.JumpPower = v end
end

-- === INFINITE JUMP ===
UserInputService.JumpRequest:Connect(function()
	if not infiniteJump then return end
	local char = LocalPlayer.Character if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- === RESPAWN HANDLER ===
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	if flying then startFly() end
	if godMode then toggleGod(true) end
	if noclip then toggleNoclip(true) end
end)
-- === ORION GUI ===
local Window = OrionLib:MakeWindow({
	Name = "Cosmic Hub | NDS",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "CosmicHub"
})

-- TAB 1: FLY
local FlyTab = Window:MakeTab({
	Name = "Fly",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

FlyTab:AddToggle({
	Name = "Enable Fly",
	Default = false,
	Callback = function(v)
		flying = v
		if v then startFly() else stopFly() end
	end
})

FlyTab:AddSlider({
	Name = "Fly Speed",
	Min = 10,
	Max = 300,
	Default = 50,
	Color = Color3.fromRGB(229,57,53),
	Increment = 1,
	ValueName = "speed",
	Callback = function(v)
		flySpeed = v
	end
})

FlyTab:AddParagraph("Controls (keyboard)", "W/A/S/D = direction  |  Space = up  |  Q = down")
FlyTab:AddParagraph("Controls (mobile)", "D-Pad appears on screen when fly is ON")

-- TAB 2: MOVEMENT
local MoveTab = Window:MakeTab({
	Name = "Movement",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

MoveTab:AddToggle({
	Name = "Infinite Jump",
	Default = false,
	Callback = function(v)
		infiniteJump = v
	end
})

MoveTab:AddSlider({
	Name = "Walk Speed",
	Min = 16,
	Max = 200,
	Default = 16,
	Color = Color3.fromRGB(229,57,53),
	Increment = 1,
	ValueName = "speed",
	Callback = function(v)
		setSpeed(v)
	end
})

MoveTab:AddSlider({
	Name = "Jump Power",
	Min = 50,
	Max = 500,
	Default = 50,
	Color = Color3.fromRGB(229,57,53),
	Increment = 1,
	ValueName = "power",
	Callback = function(v)
		setJump(v)
	end
})

-- TAB 3: SURVIVAL
local SurvTab = Window:MakeTab({
	Name = "Survival",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

SurvTab:AddToggle({
	Name = "God Mode",
	Default = false,
	Callback = function(v)
		toggleGod(v)
	end
})

SurvTab:AddToggle({
	Name = "Noclip (pass debris)",
	Default = false,
	Callback = function(v)
		toggleNoclip(v)
	end
})

SurvTab:AddToggle({
	Name = "Infinite Jump",
	Default = false,
	Callback = function(v)
		infiniteJump = v
	end
})

SurvTab:AddButton({
	Name = "Rejoin Server",
	Callback = function()
		local TS = game:GetService("TeleportService")
		TS:Teleport(game.PlaceId, LocalPlayer)
	end
})

SurvTab:AddButton({
	Name = "Reset Character",
	Callback = function()
		LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0
	end
})

-- TAB 4: VISUAL
local VisTab = Window:MakeTab({
	Name = "Visual",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

VisTab:AddToggle({
	Name = "Fullbright",
	Default = false,
	Callback = function(v)
		game:GetService("Lighting").Brightness = v and 10 or 1
		game:GetService("Lighting").ClockTime = v and 14 or 14
		game:GetService("Lighting").FogEnd = v and 1e6 or 100000
	end
})

VisTab:AddToggle({
	Name = "Nametag ESP",
	Default = false,
	Callback = function(v)
		for _,plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					if v then
						local bb = Instance.new("BillboardGui")
						bb.Name = "ESP_Tag" bb.Size = UDim2.new(0,100,0,30)
						bb.AlwaysOnTop = true bb.Parent = hrp
						local lbl = Instance.new("TextLabel")
						lbl.Size = UDim2.new(1,0,1,0)
						lbl.BackgroundTransparency = 1
						lbl.Text = plr.Name
						lbl.TextColor3 = Color3.fromRGB(229,57,53)
						lbl.Font = Enum.Font.GothamBold
						lbl.TextSize = 14 lbl.Parent = bb
					else
						local t = hrp:FindFirstChild("ESP_Tag")
						if t then t:Destroy() end
					end
				end
			end
		end
	end
})

-- TAB 5: MISC
local MiscTab = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

MiscTab:AddButton({
	Name = "Copy Server ID",
	Callback = function()
		setclipboard(tostring(game.JobId))
		OrionLib:MakeNotification({
			Name = "Copied!",
			Content = "Server ID copied to clipboard",
			Time = 3
		})
	end
})

MiscTab:AddButton({
	Name = "Rejoin",
	Callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
	end
})

MiscTab:AddParagraph("Cosmic Hub", "Made for Natural Disaster Survival\nAll features mobile friendly")

OrionLib:Init()
-- === MOBILE D-PAD (shows when fly is on) ===
local SG = Instance.new("ScreenGui")
SG.Name = "CosmicDPad"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function makeDBtn(parent,txt,x,y,w,h,key)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0,w,0,h)
	b.Position = UDim2.new(0,x,0,y)
	b.BackgroundColor3 = Color3.fromRGB(30,30,50)
	b.BorderSizePixel = 0
	b.Text = txt
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.TextSize = 18
	b.Font = Enum.Font.GothamBold
	b.ZIndex = 15
	b.Parent = parent
	Instance.new("UICorner",b).CornerRadius = UDim.new(0,10)
	local st = Instance.new("UIStroke",b)
	st.Color = Color3.fromRGB(229,57,53)
	st.Thickness = 1.5
	b.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or
		   i.UserInputType == Enum.UserInputType.MouseButton1 then
			mobileInput[key] = true
			TweenService:Create(b, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.fromRGB(229,57,53)
			}):Play()
		end
	end)
	b.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or
		   i.UserInputType == Enum.UserInputType.MouseButton1 then
			mobileInput[key] = false
			TweenService:Create(b, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.fromRGB(30,30,50)
			}):Play()
		end
	end)
end

-- Main D-Pad (left side)
local DPad = Instance.new("Frame")
DPad.Size = UDim2.new(0,150,0,150)
DPad.Position = UDim2.new(0,10,1,-170)
DPad.BackgroundTransparency = 1
DPad.Visible = false
DPad.ZIndex = 14
DPad.Parent = SG

makeDBtn(DPad,"▲",50,0,50,46,"forward")
makeDBtn(DPad,"▼",50,104,50,46,"back")
makeDBtn(DPad,"◀",0,50,46,50,"left")
makeDBtn(DPad,"▶",104,50,46,50,"right")

-- Center dot
local Ctr = Instance.new("Frame")
Ctr.Size = UDim2.new(0,44,0,44)
Ctr.Position = UDim2.new(0,53,0,53)
Ctr.BackgroundColor3 = Color3.fromRGB(20,20,35)
Ctr.BorderSizePixel = 0
Ctr.ZIndex = 15
Ctr.Parent = DPad
Instance.new("UICorner",Ctr).CornerRadius = UDim.new(1,0)
local CtrLbl = Instance.new("TextLabel")
CtrLbl.Size = UDim2.new(1,0,1,0)
CtrLbl.BackgroundTransparency = 1
CtrLbl.Text = "✦"
CtrLbl.TextColor3 = Color3.fromRGB(229,57,53)
CtrLbl.TextSize = 16
CtrLbl.Font = Enum.Font.GothamBold
CtrLbl.Parent = Ctr

-- Up/Down pad (right side)
local VP = Instance.new("Frame")
VP.Size = UDim2.new(0,90,0,104)
VP.Position = UDim2.new(1,-110,1,-120)
VP.BackgroundTransparency = 1
VP.Visible = false
VP.ZIndex = 14
VP.Parent = SG

makeDBtn(VP,"↑ UP",0,0,90,46,"up")
makeDBtn(VP,"↓ DN",0,58,90,46,"down")

-- Show/hide dpad with fly state
RunService.Heartbeat:Connect(function()
	DPad.Visible = flying
	VP.Visible = flying
end)

-- Notification on load
OrionLib:MakeNotification({
	Name = "Cosmic Hub Loaded!",
	Content = "NDS script ready. Enable Fly tab for mobile dpad.",
	Time = 5
})
