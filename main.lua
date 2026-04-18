-- [[ SENTINEL GLOBAL V6 - ULTIMATE EDITION ]]
-- Engine: Luau Optimized | Arquitetura: Senior-Level Game Hacking

if _G.SentinelRunning then 
    _G.SentinelRunning = false 
    task.wait(0.5)
end

_G.SentinelRunning = true

-- Config Save System
local ConfigFile = "SentinelV6_Config.json"
local function SaveConfig()
    local config = {
        ESPColor = {_G.Sentinel.ESPColor.R, _G.Sentinel.ESPColor.G, _G.Sentinel.ESPColor.B},
        FOV = _G.Sentinel.FOV,
        Smoothness = _G.Sentinel.Smoothness,
        FlySpeed = _G.Sentinel.FlySpeed
    }
    local json = game:GetService("HttpService"):JSONEncode(config)
    writefile(ConfigFile, json)
end

local function LoadConfig()
    pcall(function()
        local json = readfile(ConfigFile)
        local config = game:GetService("HttpService"):JSONDecode(json)
        if config.ESPColor then
            _G.Sentinel.ESPColor = Color3.new(config.ESPColor[1], config.ESPColor[2], config.ESPColor[3])
        end
        if config.FOV then _G.Sentinel.FOV = config.FOV end
        if config.Smoothness then _G.Sentinel.Smoothness = config.Smoothness end
        if config.FlySpeed then _G.Sentinel.FlySpeed = config.FlySpeed end
    end)
end

_G.Sentinel = {
    Aimbot = false,
    SilentAim = false,
    Triggerbot = false,
    ESP = false,
    TeamCheck = true,
    VisCheck = true,
    Prediction = true,
    FOV = 150,
    Smoothness = 5,
    ShowFOV = false,
    MenuVisible = true,
    Objects = {}, 
    Connections = {},
    Cache = {},
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    ESPColor = Color3.fromRGB(220, 38, 38),
    ESPWeapon = false,
    AntiAFK = false,
    CurrentTab = "COMBAT",
    ColorPickerOpen = false
}

LoadConfig()

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- [[ UNIVERSAL ENEMY FILTER - SENIOR LEVEL ]]
_G.IsEnemy = function(targetPlayer)
    if not targetPlayer or targetPlayer == LP then return false end
    if not _G.Sentinel.TeamCheck then return true end
    
    local success, result = pcall(function()
        local targetChar = targetPlayer.Character
        local localChar = LP.Character
        
        if targetChar and localChar then
            if targetChar:GetAttribute("Team") and localChar:GetAttribute("Team") then
                return targetChar:GetAttribute("Team") ~= localChar:GetAttribute("Team")
            end
        end
        
        if targetPlayer.Team and LP.Team then
            return targetPlayer.Team ~= LP.Team
        end
        
        if targetPlayer.TeamColor and LP.TeamColor then
            return targetPlayer.TeamColor ~= LP.TeamColor
        end
        
        if targetPlayer:GetAttribute("Faction") and LP:GetAttribute("Faction") then
            return targetPlayer:GetAttribute("Faction") ~= LP:GetAttribute("Faction")
        end
        
        return true
    end)
    
    return success and result or true
end

-- [[ VISIBILITY CHECK - RAYCAST SYSTEM ]]
_G.IsVisible = function(targetPart)
    if not _G.Sentinel.VisCheck then return true end
    if not LP.Character or not LP.Character:FindFirstChild("Head") then return false end
    
    local success, visible = pcall(function()
        local origin = Camera.CFrame.Position
        local direction = (targetPart.Position - origin).Unit * 1000
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {LP.Character}
        raycastParams.IgnoreWater = true
        
        local result = workspace:Raycast(origin, direction, raycastParams)
        
        if result then
            local hit = result.Instance
            local hitPlayer = Players:GetPlayerFromCharacter(hit.Parent)
            return hitPlayer ~= nil
        end
        return true
    end)
    
    return success and visible or false
end

-- [[ PREDICTION ENGINE ]]
_G.GetPredictedPosition = function(targetPart, multiplier)
    if not _G.Sentinel.Prediction then return targetPart.Position end
    multiplier = multiplier or 0.12
    
    local success, predicted = pcall(function()
        local root = targetPart.Parent and targetPart.Parent:FindFirstChild("HumanoidRootPart")
        if root then
            return targetPart.Position + (root.Velocity * multiplier)
        end
        return targetPart.Position
    end)
    
    return success and predicted or targetPart.Position
end

-- [[ RENDERIZAÇÃO DE ELITE ]]
_G.NewDrawing = function(class, props)
    local success, obj = pcall(function()
        local drawing = Drawing.new(class)
        for i, v in pairs(props) do drawing[i] = v end
        return drawing
    end)
    if success then
        table.insert(_G.Sentinel.Objects, obj)
        return obj
    end
    return nil
end

local FOVCircle = _G.NewDrawing("Circle", {
    Thickness = 2,
    Color = Color3.fromRGB(255, 40, 0),
    Filled = false,
    Transparency = 0.8,
    Visible = false,
    Radius = _G.Sentinel.FOV,
    NumSides = 40
})

-- [[ MOVEMENT SYSTEM - OPTIMIZED ]]
local function UpdateMovement()
    local char = LP.Character
    if not char then return end
    
    pcall(function()
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
    end)
end

-- [[ ANTI-AFK ]]
local function UpdateAntiAFK()
    pcall(function()
        if _G.Sentinel.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

_G.DisableAll = function()
    for k, v in pairs(_G.Sentinel) do
        if type(v) == "boolean" and k ~= "MenuVisible" and k ~= "ColorPickerOpen" then
            _G.Sentinel[k] = false
        end
    end
end

_G.UIButtons = {}

table.insert(_G.Sentinel.Connections, RunService.RenderStepped:Connect(function()
    pcall(function()
        if FOVCircle then
            FOVCircle.Position = UIS:GetMouseLocation()
            FOVCircle.Radius = _G.Sentinel.FOV
            FOVCircle.Visible = _G.Sentinel.ShowFOV or _G.Sentinel.SilentAim
        end
        UpdateMovement()
    end)
end))

task.spawn(function()
    while _G.SentinelRunning do
        if _G.Sentinel.AntiAFK then UpdateAntiAFK() end
        task.wait(300)
    end
end)

LP.CharacterAdded:Connect(function()
    if _G.Sentinel.Fly then
        _G.Sentinel.Fly = false
        task.wait(0.1)
        _G.Sentinel.Fly = true
    end
end)

print("SENTINEL V6: [1/4] Core Engine Carregado.")

-- [[ SKELETON RIG - OPTIMIZED ]]
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

-- [[ ESP SYSTEM - CACHE OPTIMIZED ]]
local function CreateESP(plr)
    if _G.Sentinel.Cache[plr] then return end
    
    local AltColor = Color3.fromRGB(245, 158, 11)
    local lines = {}
    
    for i = 1, 16 do
        lines[i] = _G.NewDrawing("Line", {
            Color = _G.Sentinel.ESPColor,
            Thickness = 2,
            Transparency = 1,
            Visible = false
        })
    end

    local hBar = _G.NewDrawing("Line", {Thickness = 3, Visible = false})
    local hBack = _G.NewDrawing("Line", {Thickness = 5, Color = Color3.new(0,0,0), Visible = false, Transparency = 0.7})
    local nameText = _G.NewDrawing("Text", {Size = 13, Center = true, Outline = true, Visible = false})
    local weaponText = _G.NewDrawing("Text", {Size = 12, Center = true, Outline = true, Visible = false})
    local distanceText = _G.NewDrawing("Text", {Size = 12, Center = true, Outline = true, Visible = false})

    local connection = RunService.RenderStepped:Connect(function()
        pcall(function()
            local char = plr.Character
            if not char then return end
            
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            
            if not hum or not root or hum.Health <= 0 then
                hBar.Visible, hBack.Visible = false, false
                nameText.Visible, weaponText.Visible, distanceText.Visible = false, false, false
                for _, l in pairs(lines) do if l then l.Visible = false end end
                return
            end
            
            if not _G.Sentinel.ESP or not _G.IsEnemy(plr) then
                hBar.Visible, hBack.Visible = false, false
                nameText.Visible, weaponText.Visible, distanceText.Visible = false, false, false
                for _, l in pairs(lines) do if l then l.Visible = false end end
                return
            end
            
            local rootPos, onS = Camera:WorldToViewportPoint(root.Position)
            if not onS then
                hBar.Visible, hBack.Visible = false, false
                nameText.Visible, weaponText.Visible, distanceText.Visible = false, false, false
                for _, l in pairs(lines) do if l then l.Visible = false end end
                return
            end
            
            local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.8, 0))
            local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.8, 0))
            local barH = bottom.Y - top.Y
            
            hBack.Visible = true
            hBack.From = Vector2.new(rootPos.X - 35, top.Y)
            hBack.To = Vector2.new(rootPos.X - 35, bottom.Y)
            
            hBar.Visible = true
            hBar.Color = hum.Health > 50 and AltColor or _G.Sentinel.ESPColor
            hBar.From = Vector2.new(rootPos.X - 35, bottom.Y)
            hBar.To = Vector2.new(rootPos.X - 35, bottom.Y - (barH * (hum.Health / hum.MaxHealth)))

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
                weaponText.Text = tool and tool.Name or "Fists"
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
                    else
                        lines[i].Visible = false
                    end
                end
            end
        end)
    end)
    
    _G.Sentinel.Cache[plr] = {Connection = connection, Lines = lines}
    table.insert(_G.Sentinel.Connections, connection)
end

_G.UpdateESPColor = function(newColor)
    _G.Sentinel.ESPColor = newColor
    for plr, cache in pairs(_G.Sentinel.Cache) do
        pcall(function()
            if cache.Lines then
                for _, line in ipairs(cache.Lines) do
                    if line then line.Color = newColor end
                end
            end
        end)
    end
    SaveConfig()
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LP then CreateESP(p) end end

Players.PlayerAdded:Connect(function(p)
    if p ~= LP then CreateESP(p) end
end)

Players.PlayerRemoving:Connect(function(plr)
    pcall(function()
        if _G.Sentinel.Cache[plr] then
            local cache = _G.Sentinel.Cache[plr]
            if cache.Connection then cache.Connection:Disconnect() end
            if cache.Lines then
                for _, line in ipairs(cache.Lines) do
                    if line then line:Remove() end
                end
            end
            _G.Sentinel.Cache[plr] = nil
        end
    end)
end)

print("SENTINEL V6: [2/4] Visual Engine Optimized Carregado.")

-- [[ UI - CLEAN ELITE ]]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "SentinelUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame")
Main.Name = "SentinelHorizon"
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 600, 0, 370)
Main.Position = UDim2.new(0.5, -300, 0.5, -185)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
Main.BackgroundTransparency = 0.1
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(220, 40, 40)
MainStroke.Transparency = 0.2

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local HeaderGradient = Instance.new("UIGradient", Header)
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 40, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 10, 10))
})
HeaderGradient.Rotation = 90

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "SENTINEL // GLOBAL V6"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local Version = Instance.new("TextLabel", Header)
Version.Size = UDim2.new(0, 60, 1, 0)
Version.Position = UDim2.new(1, -70, 0, 0)
Version.Text = "ULTIMATE"
Version.TextColor3 = Color3.fromRGB(255, 200, 0)
Version.Font = Enum.Font.GothamBold
Version.TextSize = 10
Version.BackgroundTransparency = 1

local TabContainer = Instance.new("Frame", Main)
TabContainer.Size = UDim2.new(1, 0, 0, 38)
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.BackgroundTransparency = 1

local TabList = Instance.new("UIListLayout", TabContainer)
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.Padding = UDim.new(0, 4)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Left

local TabIndicator = Instance.new("Frame", TabContainer)
TabIndicator.Size = UDim2.new(0, 115, 0, 2)
TabIndicator.Position = UDim2.new(0, 0, 1, -2)
TabIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 0)
TabIndicator.BorderSizePixel = 0

local TabButtons = {}
local TabPages = {}

local TooltipFrame = Instance.new("Frame", ScreenGui)
TooltipFrame.Size = UDim2.new(0, 0, 0, 0)
TooltipFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
TooltipFrame.BackgroundTransparency = 0.1
TooltipFrame.BorderSizePixel = 0
TooltipFrame.Visible = false
TooltipFrame.ZIndex = 100
Instance.new("UICorner", TooltipFrame).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", TooltipFrame).Color = Color3.fromRGB(255, 100, 0)

local TooltipLabel = Instance.new("TextLabel", TooltipFrame)
TooltipLabel.Size = UDim2.new(1, -16, 1, -8)
TooltipLabel.Position = UDim2.new(0, 8, 0, 4)
TooltipLabel.TextColor3 = Color3.new(1,1,1)
TooltipLabel.BackgroundTransparency = 1
TooltipLabel.Font = Enum.Font.GothamMedium
TooltipLabel.TextSize = 11

local function ShowTooltip(guiObject, text)
    TooltipFrame.Size = UDim2.new(0, 200, 0, 35)
    TooltipLabel.Text = text
    local mousePos = UIS:GetMouseLocation()
    TooltipFrame.Position = UDim2.new(0, mousePos.X + 15, 0, mousePos.Y + 10)
    TooltipFrame.Visible = true
    TooltipFrame.ZIndex = 100
end

local function HideTooltip()
    TooltipFrame.Visible = false
end

local function CreateTab(name, icon, order, tooltip)
    local TabButton = Instance.new("TextButton", TabContainer)
    TabButton.Size = UDim2.new(0, 115, 1, 0)
    TabButton.Text = icon .. "  " .. name
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TabButton.BackgroundTransparency = 0.2
    TabButton.TextColor3 = Color3.fromRGB(160, 160, 160)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 11
    TabButton.LayoutOrder = order
    TabButton.AutoButtonColor = false
    
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
    
    TabButton.MouseEnter:Connect(function()
        ShowTooltip(TabButton, tooltip)
        TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    
    TabButton.MouseLeave:Connect(function()
        HideTooltip()
        if TabPages[order] and not TabPages[order].Visible then
            TabButton.BackgroundTransparency = 0.2
        end
    end)
    
    local TabPage = Instance.new("Frame", Main)
    TabPage.Size = UDim2.new(1, -24, 1, -105)
    TabPage.Position = UDim2.new(0, 12, 0, 95)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    
    local PageList = Instance.new("UIListLayout", TabPage)
    PageList.FillDirection = Enum.FillDirection.Horizontal
    PageList.Wraps = true
    PageList.Padding = UDim.new(0, 10)
    PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageList.VerticalAlignment = Enum.VerticalAlignment.Center
    
    TabButton.MouseButton1Click:Connect(function()
        for _, page in pairs(TabPages) do page.Visible = false end
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            btn.BackgroundTransparency = 0.2
            btn.TextColor3 = Color3.fromRGB(160, 160, 160)
        end
        TabPage.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
        TabButton.BackgroundTransparency = 0.1
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        _G.Sentinel.CurrentTab = name
        
        local pos = TabButton.AbsolutePosition.X - TabContainer.AbsolutePosition.X
        TweenService:Create(TabIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {Position = UDim2.new(0, pos, 1, -2)}):Play()
    end)
    
    table.insert(TabButtons, TabButton)
    table.insert(TabPages, TabPage)
    
    return TabPage
end

local CombatTab = CreateTab("COMBAT", "🎯", 1, "Configurações de mira e combate")
local VisualTab = CreateTab("VISUAL", "👁️", 2, "Configurações de ESP e visuais")
local MovementTab = CreateTab("MOVEMENT", "✈️", 3, "Fly, Noclip e velocidade")
local SystemTab = CreateTab("SYSTEM", "⚙️", 4, "Configurações do sistema")

TabPages[1].Visible = true
TabButtons[1].BackgroundColor3 = Color3.fromRGB(220, 38, 38)
TabButtons[1].BackgroundTransparency = 0.1
TabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)

local Tooltips = {
    SilentAim = "Mira automaticamente no inimigo mais próximo",
    Triggerbot = "Dispara automaticamente ao mirar num inimigo",
    VisCheck = "Só mira em inimigos visíveis (não atravessa paredes)",
    Prediction = "Compensa o movimento do alvo",
    ShowFOV = "Mostra o círculo do FOV no ecrã",
    FOV = "Raio do campo de visão para o Aimbot",
    Smoothness = "Suavidade do movimento da mira",
    ESP = "Mostra esqueleto e informações dos inimigos",
    ESPWeapon = "Mostra a arma que o inimigo está a usar",
    TeamCheck = "Ignora aliados no ESP e Aimbot",
    Fly = "Permite voar pelo mapa (WASD + Espaço/Control)",
    FlySpeed = "Velocidade do modo Fly",
    Noclip = "Atravessa paredes e objetos",
    AntiAFK = "Impede ser desconectado por inatividade",
    SaveConfig = "Guarda as configurações atuais",
    DisableAll = "Desliga todas as funções ativas"
}

local function AddToggle(tab, name, varName)
    local Btn = Instance.new("TextButton", tab)
    Btn.Size = UDim2.new(0, 155, 0, 42)
    Btn.BackgroundColor3 = _G.Sentinel[varName] and Color3.fromRGB(200, 35, 35) or Color3.fromRGB(28, 28, 34)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Thickness = 1.5
    BtnStroke.Color = _G.Sentinel[varName] and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(50, 50, 60)
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local Icon = Instance.new("TextLabel", Btn)
    Icon.Size = UDim2.new(0, 26, 1, 0)
    Icon.Text = name:sub(1, 2)
    Icon.TextColor3 = Color3.new(1,1,1)
    Icon.BackgroundTransparency = 1
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 12
    
    local Label = Instance.new("TextLabel", Btn)
    Label.Size = UDim2.new(1, -32, 1, 0)
    Label.Position = UDim2.new(0, 28, 0, 0)
    Label.Text = name:sub(4)
    Label.TextColor3 = _G.Sentinel[varName] and Color3.new(1,1,1) or Color3.fromRGB(140, 140, 140)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    Btn.MouseEnter:Connect(function()
        ShowTooltip(Btn, Tooltips[varName] or "")
        TweenService:Create(Btn, TweenInfo.new(0.2), {
            BackgroundColor3 = _G.Sentinel[varName] and Color3.fromRGB(220, 45, 45) or Color3.fromRGB(38, 38, 46)
        }):Play()
    end)
    
    Btn.MouseLeave:Connect(function()
        HideTooltip()
        TweenService:Create(Btn, TweenInfo.new(0.2), {
            BackgroundColor3 = _G.Sentinel[varName] and Color3.fromRGB(200, 35, 35) or Color3.fromRGB(28, 28, 34)
        }):Play()
    end)
    
    local function UpdateButton()
        local state = _G.Sentinel[varName]
        Btn.BackgroundColor3 = state and Color3.fromRGB(200, 35, 35) or Color3.fromRGB(28, 28, 34)
        BtnStroke.Color = state and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(50, 50, 60)
        Label.TextColor3 = state and Color3.new(1,1,1) or Color3.fromRGB(140, 140, 140)
    end
    
    Btn.MouseButton1Click:Connect(function()
        _G.Sentinel[varName] = not _G.Sentinel[varName]
        UpdateButton()
    end)
    
    table.insert(_G.UIButtons, {Update = UpdateButton})
end

local function AddSlider(tab, name, min, max, default, varName)
    local SFrame = Instance.new("Frame", tab)
    SFrame.Size = UDim2.new(0, 240, 0, 52)
    SFrame.BackgroundTransparency = 1
    
    local Lbl = Instance.new("TextLabel", SFrame)
    Lbl.Size = UDim2.new(1, 0, 0, 18)
    Lbl.Text = name .. ": " .. default
    Lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 11
    Lbl.BackgroundTransparency = 1
    
    local Bar = Instance.new("Frame", SFrame)
    Bar.Size = UDim2.new(1, 0, 0, 5)
    Bar.Position = UDim2.new(0, 0, 0.5, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 2)
    
    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(220, 60, 0)
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 2)
    
    local Dot = Instance.new("TextButton", Bar)
    Dot.Size = UDim2.new(0, 12, 0, 12)
    Dot.Position = UDim2.new((default-min)/(max-min), -6, 0.5, -6)
    Dot.BackgroundColor3 = Color3.new(1,1,1)
    Dot.Text = ""
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", Dot).Thickness = 1.5
    
    SFrame.MouseEnter:Connect(function() ShowTooltip(SFrame, Tooltips[varName] or "") end)
    SFrame.MouseLeave:Connect(HideTooltip)
    
    local isDragging = false
    Dot.MouseButton1Down:Connect(function() isDragging = true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end)
    
    RunService.RenderStepped:Connect(function()
        if isDragging then
            local rel = math.clamp((UIS:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Dot.Position = UDim2.new(rel, -6, 0.5, -6)
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            local v = math.floor(min + (rel * (max - min)))
            _G.Sentinel[varName] = v
            Lbl.Text = name .. ": " .. v
        end
    end)
end

local function AddColorButton(tab)
    local Btn = Instance.new("TextButton", tab)
    Btn.Size = UDim2.new(0, 155, 0, 42)
    Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Thickness = 1.5
    BtnStroke.Color = Color3.fromRGB(255, 100, 0)
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local Icon = Instance.new("TextLabel", Btn)
    Icon.Size = UDim2.new(0, 26, 1, 0)
    Icon.Text = "🎨"
    Icon.TextColor3 = Color3.new(1,1,1)
    Icon.BackgroundTransparency = 1
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 13
    
    local Label = Instance.new("TextLabel", Btn)
    Label.Size = UDim2.new(1, -32, 1, 0)
    Label.Position = UDim2.new(0, 28, 0, 0)
    Label.Text = "ESP COLOR"
    Label.TextColor3 = Color3.new(1,1,1)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ColorPreview = Instance.new("Frame", Btn)
    ColorPreview.Size = UDim2.new(0, 16, 0, 16)
    ColorPreview.Position = UDim2.new(1, -24, 0.5, -8)
    ColorPreview.BackgroundColor3 = _G.Sentinel.ESPColor
    Instance.new("UICorner", ColorPreview).CornerRadius = UDim.new(0, 3)
    
    local ColorPickerFrame = Instance.new("Frame", Main)
    ColorPickerFrame.Size = UDim2.new(0, 230, 0, 105)
    ColorPickerFrame.Position = UDim2.new(0.5, -115, 0.5, -52)
    ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    ColorPickerFrame.BackgroundTransparency = 0.1
    ColorPickerFrame.BorderSizePixel = 0
    ColorPickerFrame.Visible = false
    ColorPickerFrame.ZIndex = 10
    Instance.new("UICorner", ColorPickerFrame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", ColorPickerFrame).Color = Color3.fromRGB(255, 80, 0)
    
    local ColorGrid = Instance.new("UIGridLayout", ColorPickerFrame)
    ColorGrid.CellSize = UDim2.new(0, 42, 0, 32)
    ColorGrid.CellPadding = UDim2.new(0, 5, 0, 5)
    ColorGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ColorGrid.VerticalAlignment = Enum.VerticalAlignment.Center
    
    local colors = {
        Color3.fromRGB(220, 38, 38),
        Color3.fromRGB(245, 158, 11),
        Color3.fromRGB(16, 185, 129),
        Color3.fromRGB(59, 130, 246),
        Color3.fromRGB(139, 92, 246),
        Color3.fromRGB(236, 72, 153),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(234, 179, 8)
    }
    
    for _, color in pairs(colors) do
        local ColorBtn = Instance.new("TextButton", ColorPickerFrame)
        ColorBtn.Size = UDim2.new(1, 0, 1, 0)
        ColorBtn.BackgroundColor3 = color
        ColorBtn.Text = ""
        ColorBtn.ZIndex = 11
        Instance.new("UICorner", ColorBtn).CornerRadius = UDim.new(0, 4)
        
        ColorBtn.MouseButton1Click:Connect(function()
            _G.UpdateESPColor(color)
            ColorPreview.BackgroundColor3 = color
            ColorPickerFrame.Visible = false
        end)
    end
    
    Btn.MouseEnter:Connect(function()
        ShowTooltip(Btn, "Selecionar cor do ESP")
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(38, 38, 46)}):Play()
    end)
    
    Btn.MouseLeave:Connect(function()
        HideTooltip()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 28, 34)}):Play()
    end)
    
    Btn.MouseButton1Click:Connect(function()
        ColorPickerFrame.Visible = not ColorPickerFrame.Visible
    end)
end

local function AddButton(tab, name, icon, callback, tooltip)
    local Btn = Instance.new("TextButton", tab)
    Btn.Size = UDim2.new(0, 155, 0, 42)
    Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Thickness = 1.5
    BtnStroke.Color = Color3.fromRGB(255, 100, 0)
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local IconLabel = Instance.new("TextLabel", Btn)
    IconLabel.Size = UDim2.new(0, 26, 1, 0)
    IconLabel.Text = icon
    IconLabel.TextColor3 = Color3.new(1,1,1)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextSize = 13
    
    local Label = Instance.new("TextLabel", Btn)
    Label.Size = UDim2.new(1, -32, 1, 0)
    Label.Position = UDim2.new(0, 28, 0, 0)
    Label.Text = name
    Label.TextColor3 = Color3.new(1,1,1)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    Btn.MouseEnter:Connect(function()
        ShowTooltip(Btn, tooltip or "")
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(38, 38, 46)}):Play()
    end)
    
    Btn.MouseLeave:Connect(function()
        HideTooltip()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 28, 34)}):Play()
    end)
    
    Btn.MouseButton1Click:Connect(callback)
end

-- [[ PREENCHER TABS ]]
AddToggle(CombatTab, "🎯 SILENT AIM", "SilentAim")
AddToggle(CombatTab, "🔫 AUTO TRIGGER", "Triggerbot")
AddToggle(CombatTab, "👁️ VIS CHECK", "VisCheck")
AddToggle(CombatTab, "🎯 PREDICTION", "Prediction")
AddToggle(CombatTab, "👀 SHOW FOV", "ShowFOV")
AddSlider(CombatTab, "FOV RADIUS", 10, 800, _G.Sentinel.FOV, "FOV")
AddSlider(CombatTab, "SMOOTHNESS", 1, 100, _G.Sentinel.Smoothness, "Smoothness")

AddToggle(VisualTab, "👁️ SKELETON ESP", "ESP")
AddToggle(VisualTab, "🔫 SHOW WEAPON", "ESPWeapon")
AddToggle(VisualTab, "🛡️ ANTI-TEAMMATE", "TeamCheck")
AddColorButton(VisualTab)

AddToggle(MovementTab, "✈️ FLY MODE", "Fly")
AddSlider(MovementTab, "FLY SPEED", 20, 200, _G.Sentinel.FlySpeed, "FlySpeed")
AddToggle(MovementTab, "🚀 NOCLIP", "Noclip")

AddToggle(SystemTab, "⏰ ANTI-AFK", "AntiAFK")
AddButton(SystemTab, "💾 SAVE CONFIG", "💾", SaveConfig, "Guarda as configurações atuais")
AddButton(SystemTab, "⚡ DISABLE ALL", "⚡", function()
    _G.DisableAll()
    for _, btn in ipairs(_G.UIButtons) do
        if btn.Update then btn:Update() end
    end
end, "Desliga todas as funções ativas")

Main.Position = UDim2.new(0.5, -300, -0.5, 0)
local enterTween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
    {Position = UDim2.new(0.5, -300, 0.5, -185)})
enterTween:Play()

local dragging, dragInput, dragStart, startPos

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
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputBegan:Connect(function(input, chat)
    if chat then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
    end
end)

print("SENTINEL V6: [3/4] Interface Elite Carregada.")

-- [[ COMBAT ENGINE - VISCHECK + PREDICTION ]]
local function GetClosestTarget()
    local target = nil
    local maxDist = _G.Sentinel.FOV
    
    for _, p in pairs(Players:GetPlayers()) do
        pcall(function()
            if p ~= LP and _G.IsEnemy(p) and p.Character then
                local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("UpperTorso")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                
                if head and hum and hum.Health > 0 then
                    if _G.Sentinel.VisCheck and not _G.IsVisible(head) then return end
                    
                    local predictedPos = _G.GetPredictedPosition(head, 0.12)
                    local pos, onS = Camera:WorldToViewportPoint(predictedPos)
                    
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
        end)
    end
    return target
end

task.spawn(function()
    while _G.SentinelRunning do
        task.wait()
        
        pcall(function()
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
                        if _G.Sentinel.VisCheck then
                            local head = p.Character and (p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("UpperTorso"))
                            if head and not _G.IsVisible(head) then return end
                        end
                        
                        if mouse1click then 
                            mouse1click() 
                        elseif mouse1press then
                            mouse1press()
                            task.wait(0.01)
                            mouse1release()
                        else
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down()
                            task.wait(0.01)
                            VirtualUser:Button1Up()
                        end
                    end
                end
            end
        end)
    end
end)

local combatLoop = RunService.RenderStepped:Connect(function()
    pcall(function()
        if _G.Sentinel.SilentAim and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = GetClosestTarget()
            
            if target and target.Character then
                local head = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("UpperTorso")
                if head then
                    local predictedPos = _G.GetPredictedPosition(head, 0.12)
                    local hPos = Camera:WorldToViewportPoint(predictedPos)
                    local mPos = UIS:GetMouseLocation()
                    
                    local s = (101 - _G.Sentinel.Smoothness) / 5
                    
                    if mousemoverel then
                        mousemoverel((hPos.X - mPos.X) * (s/10), (hPos.Y - mPos.Y) * (s/10))
                    else
                        local lookVector = (predictedPos - Camera.CFrame.Position).Unit
                        local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector)
                        if _G.Sentinel.Smoothness > 1 then
                            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 1 / _G.Sentinel.Smoothness)
                        else
                            Camera.CFrame = newCFrame
                        end
                    end
                end
            end
        end
    end)
end)

table.insert(_G.Sentinel.Connections, combatLoop)

print("---------------------------------------")
print("SENTINEL V6: ULTIMATE EDITION ATIVA")
print("VISCHECK: " .. tostring(_G.Sentinel.VisCheck))
print("PREDICTION: " .. tostring(_G.Sentinel.Prediction))
print("CONFIG SAVE: Ativo")
print("---------------------------------------")
