-- [[ SENTINEL GLOBAL V5 - ELITE EDITION ]]
-- Part 1: Core Engine & Universal Identification

if _G.SentinelRunning then 
    _G.SentinelRunning = false 
    task.wait(0.5)
end

_G.SentinelRunning = true
_G.Sentinel = {
    -- TODAS AS FUNÇÕES COMEÇAM FALSE
    Aimbot = false,
    SilentAim = false,
    Triggerbot = false,
    ESP = false,
    TeamCheck = false,
    FOV = 150,
    Smoothness = 5,
    ShowFOV = false,
    MenuVisible = true,
    Objects = {}, 
    Connections = {},
    Cache = {},
    -- Movimento
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    -- Visual
    ESPColor = Color3.fromRGB(220, 38, 38),
    ESPWeapon = false,
    -- Sistema
    AntiAFK = false,
    -- UI State
    CurrentTab = "COMBAT",
    ColorPickerOpen = false
}

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

-- [[ A SENTINELA: FILTRO DE EQUIPA UNIVERSAL ]]
_G.IsEnemy = function(p)
    if not p or p == LP then return false end
    if not _G.Sentinel.TeamCheck then return true end
    if p.Team and LP.Team then return p.Team ~= LP.Team end
    if p.TeamColor ~= LP.TeamColor then return true end
    return false
end

-- [[ SISTEMA DE RENDERIZAÇÃO DE ELITE ]]
_G.NewDrawing = function(class, props)
    local obj = Drawing.new(class)
    for i, v in pairs(props) do obj[i] = v end
    table.insert(_G.Sentinel.Objects, obj)
    return obj
end

-- FOV Circle
local FOVCircle = _G.NewDrawing("Circle", {
    Thickness = 2,
    Color = Color3.fromRGB(255, 40, 0),
    Filled = false,
    Transparency = 0.8,
    Visible = false,
    Radius = _G.Sentinel.FOV,
    NumSides = 100
})
_G.Sentinel.FOVObject = FOVCircle

-- [[ SISTEMA DE MOVIMENTO - FLY E NOCLIP ]]
local function UpdateMovement()
    local char = LP.Character
    if not char then return end
    
    if _G.Sentinel.Noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    if _G.Sentinel.Fly then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local bv = root:FindFirstChild("FlyVelocity")
            local bg = root:FindFirstChild("FlyGyro")
            
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.zero
                bv.MaxForce = Vector3.new(100000, 100000, 100000)
                bv.Parent = root
                bv.Name = "FlyVelocity"
            end
            
            if not bg then
                bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(100000, 100000, 100000)
                bg.CFrame = root.CFrame
                bg.Parent = root
                bg.Name = "FlyGyro"
            end
            
            bg.CFrame = Camera.CFrame
            
            local move = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
            
            bv.Velocity = move * _G.Sentinel.FlySpeed
        end
    else
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            for _, v in pairs({root:FindFirstChild("FlyVelocity"), root:FindFirstChild("FlyGyro")}) do
                if v then v:Destroy() end
            end
        end
    end
end

-- [[ SISTEMA ANTI-AFK ]]
local function UpdateAntiAFK()
    if _G.Sentinel.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end

-- Função para desligar TODAS as funções
_G.DisableAll = function()
    for k, v in pairs(_G.Sentinel) do
        if type(v) == "boolean" and k ~= "MenuVisible" and k ~= "ColorPickerOpen" then
            _G.Sentinel[k] = false
        end
    end
end

_G.UIButtons = {}

-- Loop de atualização
table.insert(_G.Sentinel.Connections, RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = UIS:GetMouseLocation()
        FOVCircle.Radius = _G.Sentinel.FOV
        FOVCircle.Visible = _G.Sentinel.ShowFOV or _G.Sentinel.SilentAim
    end
    UpdateMovement()
end))

-- Loop Anti-AFK
task.spawn(function()
    while _G.SentinelRunning do
        if _G.Sentinel.AntiAFK then UpdateAntiAFK() end
        task.wait(300)
    end
end)

-- Reset ao respawnar
LP.CharacterAdded:Connect(function()
    if _G.Sentinel.Fly then
        _G.Sentinel.Fly = false
        task.wait(0.1)
        _G.Sentinel.Fly = true
    end
end)

print("SENTINEL V5: [1/4] Motor de Identificação Carregado.")

-- [[ SENTINEL GLOBAL V5 - ELITE EDITION ]]
-- Parte 2: Crimson Skeleton Engine & Advanced Visuals

local SkeletonRig = {
    R15 = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
    },
    R6 = {
        {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
        {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
    }
}

local function CreateESP(plr)
    if _G.Sentinel.Cache[plr] then return end
    
    local AltColor = Color3.fromRGB(245, 158, 11)

    local lines = {}
    for i = 1, 16 do
        table.insert(lines, _G.NewDrawing("Line", {
            Color = _G.Sentinel.ESPColor,
            Thickness = 2,
            Transparency = 1,
            Visible = false
        }))
    end

    local hBar = _G.NewDrawing("Line", {Thickness = 3, Visible = false})
    local hBack = _G.NewDrawing("Line", {Thickness = 5, Color = Color3.new(0,0,0), Visible = false, Transparency = 0.7})
    local nameText = _G.NewDrawing("Text", {Size = 13, Center = true, Outline = true, Visible = false})
    local weaponText = _G.NewDrawing("Text", {Size = 12, Center = true, Outline = true, Visible = false})
    local distanceText = _G.NewDrawing("Text", {Size = 12, Center = true, Outline = true, Visible = false})

    local connection = RunService.RenderStepped:Connect(function()
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        local isEnemy = _G.IsEnemy(plr)
        local shouldRender = _G.Sentinel.ESP and char and hum and root and hum.Health > 0 and isEnemy

        if shouldRender then
            local rootPos, onS = Camera:WorldToViewportPoint(root.Position)
            
            if onS then
                local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.8, 0))
                local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.8, 0))
                local barH = bottom.Y - top.Y
                
                hBack.Visible = true
                hBack.From = Vector2.new(rootPos.X - 35, top.Y)
                hBack.To = Vector2.new(rootPos.X - 35, bottom.Y)
                
                hBar.Visible = true
                hBar.Color = hum.Health > 50 and AltColor or _G.Sentinel.ESPColor
                hBar.From = Vector2.new(rootPos.X - 35, bottom.Y)
                hBar.To = Vector2.new(rootPos.X - 35, bottom.Y - (barH * (hum.Health/hum.MaxHealth)))

                nameText.Text = plr.Name
                nameText.Position = Vector2.new(rootPos.X, top.Y - 25)
                nameText.Color = _G.Sentinel.ESPColor
                nameText.Visible = true

                local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
                distanceText.Text = dist .. " studs"
                distanceText.Position = Vector2.new(rootPos.X, bottom.Y + 5)
                distanceText.Color = _G.Sentinel.ESPColor
                distanceText.Visible = true

                if _G.Sentinel.ESPWeapon then
                    local tool = char:FindFirstChildOfClass("Tool")
                    local weaponName = tool and tool.Name or "Fists"
                    weaponText.Text = weaponName
                    weaponText.Position = Vector2.new(rootPos.X, bottom.Y + 20)
                    weaponText.Color = AltColor
                    weaponText.Visible = true
                else
                    weaponText.Visible = false
                end

                local rig = char:FindFirstChild("UpperTorso") and SkeletonRig.R15 or SkeletonRig.R6
                for i, bone in pairs(rig) do
                    local p1, p2 = char:FindFirstChild(bone[1]), char:FindFirstChild(bone[2])
                    if p1 and p2 and lines[i] then
                        local pos1, v1 = Camera:WorldToViewportPoint(p1.Position)
                        local pos2, v2 = Camera:WorldToViewportPoint(p2.Position)
                        if v1 and v2 then
                            lines[i].Visible = true
                            lines[i].From = Vector2.new(pos1.X, pos1.Y)
                            lines[i].To = Vector2.new(pos2.X, pos2.Y)
                            lines[i].Color = _G.Sentinel.ESPColor
                        else lines[i].Visible = false end
                    end
                end
            else
                hBar.Visible, hBack.Visible = false, false
                nameText.Visible, weaponText.Visible, distanceText.Visible = false, false, false
                for _, l in pairs(lines) do l.Visible = false end
            end
        else
            hBar.Visible, hBack.Visible = false, false
            nameText.Visible, weaponText.Visible, distanceText.Visible = false, false, false
            for _, l in pairs(lines) do l.Visible = false end
        end
    end)
    
    _G.Sentinel.Cache[plr] = {Connection = connection, Lines = lines}
    table.insert(_G.Sentinel.Connections, connection)
end

_G.UpdateESPColor = function(newColor)
    _G.Sentinel.ESPColor = newColor
    for plr, cache in pairs(_G.Sentinel.Cache) do
        if cache.Lines then
            for _, line in ipairs(cache.Lines) do
                line.Color = newColor
            end
        end
    end
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
table.insert(_G.Sentinel.Connections, Players.PlayerAdded:Connect(CreateESP))

print("SENTINEL V5: [2/4] Visual Engine Crimson Carregado.")

-- [[ SENTINEL GLOBAL V5 - COMMUNITY ELITE ]]
-- Parte 3: Menu Premium Glassmorphism

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "SentinelUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Blur = Instance.new("BlurEffect", game:GetService("Lighting"))
Blur.Size = 0
Blur.Name = "SentinelBlur"

local Main = Instance.new("Frame")
Main.Name = "SentinelHorizon"
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 620, 0, 380)
Main.Position = UDim2.new(0.5, -310, -0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
Main.BackgroundTransparency = 0.15
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(220, 40, 40)
MainStroke.Transparency = 0.3
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local HeaderGradient = Instance.new("UIGradient", Header)
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 40, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 10, 10))
})
HeaderGradient.Rotation = 90

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "SENTINEL // GLOBAL V5"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local Version = Instance.new("TextLabel", Header)
Version.Size = UDim2.new(0, 60, 1, 0)
Version.Position = UDim2.new(1, -70, 0, 0)
Version.Text = "ELITE"
Version.TextColor3 = Color3.fromRGB(255, 200, 0)
Version.Font = Enum.Font.GothamBold
Version.TextSize = 11
Version.BackgroundTransparency = 1

-- [[ SISTEMA DE TABS ]]
local TabContainer = Instance.new("Frame", Main)
TabContainer.Size = UDim2.new(1, 0, 0, 42)
TabContainer.Position = UDim2.new(0, 0, 0, 55)
TabContainer.BackgroundTransparency = 1

local TabList = Instance.new("UIListLayout", TabContainer)
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.Padding = UDim.new(0, 4)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabList.VerticalAlignment = Enum.VerticalAlignment.Center

local TabIndicator = Instance.new("Frame", TabContainer)
TabIndicator.Size = UDim2.new(0, 135, 0, 3)
TabIndicator.Position = UDim2.new(0, 0, 1, -3)
TabIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 0)
TabIndicator.BorderSizePixel = 0
Instance.new("UICorner", TabIndicator).CornerRadius = UDim.new(0, 2)

local TabButtons = {}
local TabPages = {}

local function CreateTab(name, icon, order)
    local TabButton = Instance.new("TextButton", TabContainer)
    TabButton.Size = UDim2.new(0, 135, 1, 0)
    TabButton.Text = icon .. "  " .. name
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TabButton.BackgroundTransparency = 0.3
    TabButton.TextColor3 = Color3.fromRGB(160, 160, 160)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 12
    TabButton.LayoutOrder = order
    TabButton.AutoButtonColor = false
    
    local TabStroke = Instance.new("UIStroke", TabButton)
    TabStroke.Thickness = 1
    TabStroke.Color = Color3.fromRGB(60, 60, 70)
    TabStroke.Transparency = 0.5
    
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)
    
    TabButton.MouseEnter:Connect(function()
        TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    
    TabButton.MouseLeave:Connect(function()
        if TabPages[order] and not TabPages[order].Visible then
            TabButton.BackgroundTransparency = 0.3
        end
    end)
    
    local TabPage = Instance.new("Frame", Main)
    TabPage.Size = UDim2.new(1, -30, 1, -110)
    TabPage.Position = UDim2.new(0, 15, 0, 100)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    
    local PageList = Instance.new("UIListLayout", TabPage)
    PageList.FillDirection = Enum.FillDirection.Horizontal
    PageList.Wraps = true
    PageList.Padding = UDim.new(0, 12)
    PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageList.VerticalAlignment = Enum.VerticalAlignment.Center
    
    TabButton.MouseButton1Click:Connect(function()
        for _, page in pairs(TabPages) do page.Visible = false end
        for i, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            btn.BackgroundTransparency = 0.3
            btn.TextColor3 = Color3.fromRGB(160, 160, 160)
            btn.UIStroke.Color = Color3.fromRGB(60, 60, 70)
        end
        TabPage.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
        TabButton.BackgroundTransparency = 0.1
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.UIStroke.Color = Color3.fromRGB(255, 100, 0)
        _G.Sentinel.CurrentTab = name
        
        local pos = TabButton.AbsolutePosition.X - TabContainer.AbsolutePosition.X
        TweenService:Create(TabIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {Position = UDim2.new(0, pos, 1, -3)}):Play()
    end)
    
    table.insert(TabButtons, TabButton)
    table.insert(TabPages, TabPage)
    
    return TabPage
end

local CombatTab = CreateTab("COMBAT", "🎯", 1)
local VisualTab = CreateTab("VISUAL", "👁️", 2)
local MovementTab = CreateTab("MOVEMENT", "✈️", 3)
local SystemTab = CreateTab("SYSTEM", "⚙️", 4)

TabPages[1].Visible = true
TabButtons[1].BackgroundColor3 = Color3.fromRGB(220, 38, 38)
TabButtons[1].BackgroundTransparency = 0.1
TabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
TabButtons[1].UIStroke.Color = Color3.fromRGB(255, 100, 0)

-- [[ COMPONENTES DE UI ]]
local function AddToggle(tab, name, varName)
    local Btn = Instance.new("TextButton", tab)
    Btn.Size = UDim2.new(0, 175, 0, 48)
    Btn.BackgroundColor3 = _G.Sentinel[varName] and Color3.fromRGB(200, 35, 35) or Color3.fromRGB(28, 28, 34)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Thickness = 1.5
    BtnStroke.Color = _G.Sentinel[varName] and Color3.fromRGB(255, 120, 0) or Color3.fromRGB(50, 50, 60)
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    local Icon = Instance.new("TextLabel", Btn)
    Icon.Size = UDim2.new(0, 30, 1, 0)
    Icon.Text = name:sub(1, 2)
    Icon.TextColor3 = Color3.new(1,1,1)
    Icon.BackgroundTransparency = 1
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 14
    
    local Label = Instance.new("TextLabel", Btn)
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 35, 0, 0)
    Label.Text = name:sub(4)
    Label.TextColor3 = _G.Sentinel[varName] and Color3.new(1,1,1) or Color3.fromRGB(140, 140, 140)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {
            BackgroundColor3 = _G.Sentinel[varName] and Color3.fromRGB(220, 45, 45) or Color3.fromRGB(40, 40, 50)
        }):Play()
    end)
    
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {
            BackgroundColor3 = _G.Sentinel[varName] and Color3.fromRGB(200, 35, 35) or Color3.fromRGB(28, 28, 34)
        }):Play()
    end)
    
    local function UpdateButton()
        local state = _G.Sentinel[varName]
        Btn.BackgroundColor3 = state and Color3.fromRGB(200, 35, 35) or Color3.fromRGB(28, 28, 34)
        BtnStroke.Color = state and Color3.fromRGB(255, 120, 0) or Color3.fromRGB(50, 50, 60)
        Label.TextColor3 = state and Color3.new(1,1,1) or Color3.fromRGB(140, 140, 140)
    end
    
    Btn.MouseButton1Click:Connect(function()
        _G.Sentinel[varName] = not _G.Sentinel[varName]
        UpdateButton()
    end)
    
    local btnData = {Update = UpdateButton}
    table.insert(_G.UIButtons, btnData)
end

local function AddSlider(tab, name, min, max, default, varName)
    local SFrame = Instance.new("Frame", tab)
    SFrame.Size = UDim2.new(0, 270, 0, 60)
    SFrame.BackgroundTransparency = 1
    
    local Lbl = Instance.new("TextLabel", SFrame)
    Lbl.Size = UDim2.new(1, 0, 0, 20)
    Lbl.Text = name .. ": " .. default
    Lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 12
    Lbl.BackgroundTransparency = 1
    
    local Bar = Instance.new("Frame", SFrame)
    Bar.Size = UDim2.new(1, 0, 0, 6)
    Bar.Position = UDim2.new(0, 0, 0.5, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 3)
    
    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(220, 60, 0)
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)
    
    local Dot = Instance.new("TextButton", Bar)
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new((default-min)/(max-min), -7, 0.5, -7)
    Dot.BackgroundColor3 = Color3.new(1,1,1)
    Dot.Text = ""
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", Dot).Thickness = 2
    
    local isDragging = false
    Dot.MouseButton1Down:Connect(function() isDragging = true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end)
    
    RunService.RenderStepped:Connect(function()
        if isDragging then
            local rel = math.clamp((UIS:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Dot.Position = UDim2.new(rel, -7, 0.5, -7)
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            local v = math.floor(min + (rel * (max - min)))
            _G.Sentinel[varName] = v
            Lbl.Text = name .. ": " .. v
        end
    end)
end

local function AddColorButton(tab)
    local Btn = Instance.new("TextButton", tab)
    Btn.Size = UDim2.new(0, 175, 0, 48)
    Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Thickness = 1.5
    BtnStroke.Color = Color3.fromRGB(255, 120, 0)
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    local Icon = Instance.new("TextLabel", Btn)
    Icon.Size = UDim2.new(0, 30, 1, 0)
    Icon.Text = "🎨"
    Icon.TextColor3 = Color3.new(1,1,1)
    Icon.BackgroundTransparency = 1
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 16
    
    local Label = Instance.new("TextLabel", Btn)
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 35, 0, 0)
    Label.Text = "ESP COLOR"
    Label.TextColor3 = Color3.new(1,1,1)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ColorPreview = Instance.new("Frame", Btn)
    ColorPreview.Size = UDim2.new(0, 20, 0, 20)
    ColorPreview.Position = UDim2.new(1, -30, 0.5, -10)
    ColorPreview.BackgroundColor3 = _G.Sentinel.ESPColor
    Instance.new("UICorner", ColorPreview).CornerRadius = UDim.new(0, 4)
    
    local ColorPickerFrame = Instance.new("Frame", Main)
    ColorPickerFrame.Size = UDim2.new(0, 260, 0, 120)
    ColorPickerFrame.Position = UDim2.new(0.5, -130, 0.5, -60)
    ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    ColorPickerFrame.BackgroundTransparency = 0.1
    ColorPickerFrame.BorderSizePixel = 0
    ColorPickerFrame.Visible = false
    ColorPickerFrame.ZIndex = 10
    Instance.new("UICorner", ColorPickerFrame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", ColorPickerFrame).Color = Color3.fromRGB(255, 80, 0)
    
    local ColorGrid = Instance.new("UIGridLayout", ColorPickerFrame)
    ColorGrid.CellSize = UDim2.new(0, 50, 0, 40)
    ColorGrid.CellPadding = UDim2.new(0, 8, 0, 8)
    ColorGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ColorGrid.VerticalAlignment = Enum.VerticalAlignment.Center
    
    local colors = {
        {Name = "Crimson", Color = Color3.fromRGB(220, 38, 38)},
        {Name = "Amber", Color = Color3.fromRGB(245, 158, 11)},
        {Name = "Emerald", Color = Color3.fromRGB(16, 185, 129)},
        {Name = "Azure", Color = Color3.fromRGB(59, 130, 246)},
        {Name = "Violet", Color = Color3.fromRGB(139, 92, 246)},
        {Name = "Pink", Color = Color3.fromRGB(236, 72, 153)},
        {Name = "White", Color = Color3.fromRGB(255, 255, 255)},
        {Name = "Yellow", Color = Color3.fromRGB(234, 179, 8)}
    }
    
    for _, colorData in pairs(colors) do
        local ColorBtn = Instance.new("TextButton", ColorPickerFrame)
        ColorBtn.Size = UDim2.new(1, 0, 1, 0)
        ColorBtn.BackgroundColor3 = colorData.Color
        ColorBtn.Text = ""
        ColorBtn.ZIndex = 11
        Instance.new("UICorner", ColorBtn).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", ColorBtn).Color = Color3.new(1,1,1)
        
        ColorBtn.MouseButton1Click:Connect(function()
            _G.Sentinel.ESPColor = colorData.Color
            ColorPreview.BackgroundColor3 = colorData.Color
            for plr, cache in pairs(_G.Sentinel.Cache) do
                if cache.Lines then
                    for _, line in ipairs(cache.Lines) do
                        line.Color = colorData.Color
                    end
                end
            end
            ColorPickerFrame.Visible = false
            Blur.Size = 0
        end)
    end
    
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
    end)
    
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 28, 34)}):Play()
    end)
    
    Btn.MouseButton1Click:Connect(function()
        ColorPickerFrame.Visible = not ColorPickerFrame.Visible
        Blur.Size = ColorPickerFrame.Visible and 15 or 0
    end)
end

local function AddButton(tab, name, icon, callback)
    local Btn = Instance.new("TextButton", tab)
    Btn.Size = UDim2.new(0, 175, 0, 48)
    Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Thickness = 1.5
    BtnStroke.Color = Color3.fromRGB(255, 120, 0)
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    local IconLabel = Instance.new("TextLabel", Btn)
    IconLabel.Size = UDim2.new(0, 30, 1, 0)
    IconLabel.Text = icon
    IconLabel.TextColor3 = Color3.new(1,1,1)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextSize = 16
    
    local Label = Instance.new("TextLabel", Btn)
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 35, 0, 0)
    Label.Text = name
    Label.TextColor3 = Color3.new(1,1,1)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
    end)
    
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 28, 34)}):Play()
    end)
    
    Btn.MouseButton1Click:Connect(callback)
end

-- [[ PREENCHER TABS ]]
AddToggle(CombatTab, "🎯 SILENT AIM", "SilentAim")
AddToggle(CombatTab, "🔫 AUTO TRIGGER", "Triggerbot")
AddToggle(CombatTab, "👀 SHOW FOV", "ShowFOV")
AddSlider(CombatTab, "FOV RADIUS", 10, 800, 150, "FOV")
AddSlider(CombatTab, "SMOOTHNESS", 1, 100, 5, "Smoothness")

AddToggle(VisualTab, "👁️ SKELETON ESP", "ESP")
AddToggle(VisualTab, "🔫 SHOW WEAPON", "ESPWeapon")
AddToggle(VisualTab, "🛡️ ANTI-TEAMMATE", "TeamCheck")
AddColorButton(VisualTab)

AddToggle(MovementTab, "✈️ FLY MODE", "Fly")
AddSlider(MovementTab, "FLY SPEED", 20, 200, 50, "FlySpeed")
AddToggle(MovementTab, "🚀 NOCLIP", "Noclip")

AddToggle(SystemTab, "⏰ ANTI-AFK", "AntiAFK")
AddButton(SystemTab, "⚡ DISABLE ALL", "⚡", function()
    _G.DisableAll()
    for _, btn in ipairs(_G.UIButtons) do
        if btn.Update then btn:Update() end
    end
end)

-- [[ ANIMAÇÃO DE ENTRADA ]]
local enterTween = TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
    {Position = UDim2.new(0.5, -310, 0.5, -190)})
enterTween:Play()

-- [[ SISTEMA DE ARRASTAR ]]
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- Tecla INSERT
UIS.InputBegan:Connect(function(input, chat)
    if chat then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
    end
end)

print("SENTINEL GLOBAL: [3/4] Interface Elite Premium Carregada.")

-- [[ SENTINEL GLOBAL - ELITE EXECUTION ]]
-- Parte 4: Motor de Combate e Disparo Autónomo

local function GetClosestTarget()
    local target = nil
    local maxDist = _G.Sentinel.FOV
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and _G.IsEnemy(p) and p.Character then
            local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("UpperTorso")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local pos, onS = Camera:WorldToViewportPoint(head.Position)
                
                if onS then
                    local mousePos = UIS:GetMouseLocation()
                    local magnitude = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    
                    if magnitude < maxDist then
                        maxDist = magnitude
                        target = p
                    end
                end
            end
        end
    end
    return target
end

task.spawn(function()
    while _G.SentinelRunning do
        task.wait()
        
        if _G.Sentinel.Triggerbot then
            local mouse = LP:GetMouse()
            local targetObj = mouse.Target
            
            if targetObj and targetObj.Parent then
                local character = targetObj.Parent
                if not character:FindFirstChild("Humanoid") then
                    character = character.Parent
                end
                
                local p = Players:GetPlayerFromCharacter(character)
                
                if p and _G.IsEnemy(p) then
                    if mouse1click then 
                        mouse1click() 
                    elseif mouse1press then
                        mouse1press()
                        task.wait(0.01)
                        mouse1release()
                    end
                end
            end
        end
    end
end)

local combatLoop = RunService.RenderStepped:Connect(function()
    if _G.Sentinel.SilentAim and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestTarget()
        
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("UpperTorso")
            if head then
                local hPos = Camera:WorldToViewportPoint(head.Position)
                local mPos = UIS:GetMouseLocation()
                
                local s = (101 - _G.Sentinel.Smoothness) / 5
                
                if mousemoverel then
                    mousemoverel((hPos.X - mPos.X) * (s/10), (hPos.Y - mPos.Y) * (s/10))
                end
            end
        end
    end
end)

table.insert(_G.Sentinel.Connections, combatLoop)

-- Finalização
print("---------------------------------------")
print("SENTINEL GLOBAL V5: TOTALMENTE ATIVO")
print("---------------------------------------")
