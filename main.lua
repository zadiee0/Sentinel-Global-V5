-- [[ SENTINEL GLOBAL V5 - ELITE EDITION ]]
-- Part 1: Core Engine & Universal Identification

if _G.SentinelRunning then 
    _G.SentinelRunning = false 
    task.wait(0.5)
end

_G.SentinelRunning = true
_G.Sentinel = {
    Aimbot = false,
    SilentAim = false,
    Triggerbot = false,
    ESP = true,
    TeamCheck = true, 
    FOV = 150,
    Smoothness = 5,
    MenuVisible = true,
    Objects = {}, 
    Connections = {},
    Cache = {}
}

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- [[ A SENTINELA: FILTRO DE EQUIPA UNIVERSAL ]]
-- Esta função é a base de tudo. Funciona em Arsenal, Rivals, etc.
_G.IsEnemy = function(p)
    if not p or p == LP then return false end
    if not _G.Sentinel.TeamCheck then return true end

    -- 1. Cheque por Equipa Oficial (Roblox Teams)
    if p.Team and LP.Team then
        return p.Team ~= LP.Team
    end

    -- 2. Cheque por TeamColor (Jogos sem sistema de team oficial)
    if p.TeamColor ~= LP.TeamColor then
        return true
    end

    -- 3. Fallback: Se estiverem na mesma equipa, não é inimigo
    return false
end

-- [[ SISTEMA DE RENDERIZAÇÃO DE ELITE ]]
_G.NewDrawing = function(class, props)
    local obj = Drawing.new(class)
    for i, v in pairs(props) do
        obj[i] = v
    end
    table.insert(_G.Sentinel.Objects, obj)
    return obj
end

-- FOV Circle com NumSides alto para ser perfeitamente redondo
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

-- Loop de atualização do FOV
table.insert(_G.Sentinel.Connections, RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = UIS:GetMouseLocation()
        FOVCircle.Radius = _G.Sentinel.FOV
        FOVCircle.Visible = _G.Sentinel.SilentAim
    end
end))

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

-- [[ RENDERIZADOR DE ELITE ]]
local function CreateESP(plr)
    if _G.Sentinel.Cache[plr] then return end
    
    local MainColor = Color3.fromRGB(220, 38, 38) -- Crimson Red
    local AltColor = Color3.fromRGB(245, 158, 11)  -- Amber Orange

    -- Criar linhas do esqueleto antecipadamente para performance
    local lines = {}
    for i = 1, 16 do
        table.insert(lines, _G.NewDrawing("Line", {
            Color = MainColor,
            Thickness = 2,
            Transparency = 1,
            Visible = false
        }))
    end

    -- Barra de vida e fundo
    local hBar = _G.NewDrawing("Line", {Thickness = 3, Visible = false})
    local hBack = _G.NewDrawing("Line", {Thickness = 5, Color = Color3.new(0,0,0), Visible = false, Transparency = 0.7})

    local connection = RunService.RenderStepped:Connect(function()
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        -- CRÍTICO: IsEnemy decide se mostramos ou não. Inimigos SEMPRE mostram se o ESP estiver ON.
        local isEnemy = _G.IsEnemy(plr)
        local shouldRender = _G.Sentinel.ESP and char and hum and root and hum.Health > 0 and isEnemy

        if shouldRender then
            local rootPos, onS = Camera:WorldToViewportPoint(root.Position)
            
            if onS then
                -- 1. Barra de Vida Lateral (Crimson Fade)
                local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.8, 0))
                local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.8, 0))
                local barH = bottom.Y - top.Y
                
                hBack.Visible = true
                hBack.From = Vector2.new(rootPos.X - 35, top.Y)
                hBack.To = Vector2.new(rootPos.X - 35, bottom.Y)
                
                hBar.Visible = true
                hBar.Color = hum.Health > 50 and AltColor or MainColor
                hBar.From = Vector2.new(rootPos.X - 35, bottom.Y)
                hBar.To = Vector2.new(rootPos.X - 35, bottom.Y - (barH * (hum.Health/hum.MaxHealth)))

                -- 2. Esqueleto Crimson (R6 e R15)
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
                        else lines[i].Visible = false end
                    end
                end
            else
                hBar.Visible, hBack.Visible = false, false
                for _, l in pairs(lines) do l.Visible = false end
            end
        else
            -- Limpeza imediata se não deve renderizar
            hBar.Visible, hBack.Visible = false, false
            for _, l in pairs(lines) do l.Visible = false end
        end
    end)
    
    _G.Sentinel.Cache[plr] = connection
    table.insert(_G.Sentinel.Connections, connection)
end

-- Inicialização Universal
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
table.insert(_G.Sentinel.Connections, Players.PlayerAdded:Connect(CreateESP))

print("SENTINEL V5: [2/4] Visual Engine Crimson Carregado.")
-- [[ SENTINEL GLOBAL V5 - COMMUNITY ELITE ]]
-- Parte 3: Menu Horizontal Premium & Efeitos Visuais

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame")
local Header = Instance.new("Frame")
local Glow = Instance.new("ImageLabel") -- Efeito de brilho externo

-- CONFIGURAÇÃO DA JANELA (Design Profissional Largo)
Main.Name = "SentinelHorizon"
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 620, 0, 350) 
Main.Position = UDim2.new(0.5, -310, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Stroke de Borda Dinâmico (Crimson)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 2.5
MainStroke.Color = Color3.fromRGB(220, 30, 0)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Header com Gradiente
Header.Parent = Main
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Header.BorderSizePixel = 0
local HeaderCorner = Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "SENTINEL // GLOBAL V5 - ELITE DOMINATION"
Title.TextColor3 = Color3.fromRGB(255, 60, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- SISTEMA DE BOTÕES LATERAIS (Funcionalidade)
local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 15, 0, 65)
Container.Size = UDim2.new(1, -30, 1, -85)
Container.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", Container)
UIList.FillDirection = Enum.FillDirection.Horizontal
UIList.Wraps = true
UIList.Padding = UDim.new(0, 12)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Função de Botões Premium (Redesenhada)
local function AddToggle(name, varName)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(0, 180, 0, 50)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    Btn.Text = name
    Btn.TextColor3 = _G.Sentinel[varName] and Color3.new(1,1,1) or Color3.fromRGB(130, 130, 130)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    
    local BStroke = Instance.new("UIStroke", Btn)
    BStroke.Thickness = 1.5
    BStroke.Color = _G.Sentinel[varName] and Color3.fromRGB(255, 80, 0) or Color3.fromRGB(45, 45, 50)
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(function()
        _G.Sentinel[varName] = not _G.Sentinel[varName]
        BStroke.Color = _G.Sentinel[varName] and Color3.fromRGB(255, 80, 0) or Color3.fromRGB(45, 45, 50)
        Btn.TextColor3 = _G.Sentinel[varName] and Color3.new(1,1,1) or Color3.fromRGB(130, 130, 130)
    end)
end

-- Sliders Profissionais (Amber Color)
local function AddSlider(name, min, max, default, varName)
    local SFrame = Instance.new("Frame", Container)
    SFrame.Size = UDim2.new(0, 280, 0, 60)
    SFrame.BackgroundTransparency = 1
    
    local Lbl = Instance.new("TextLabel", SFrame)
    Lbl.Size = UDim2.new(1, 0, 0, 20); Lbl.Text = name .. ": " .. default
    Lbl.TextColor3 = Color3.fromRGB(200, 200, 200); Lbl.Font = Enum.Font.GothamMedium; Lbl.TextSize = 12; Lbl.BackgroundTransparency = 1
    
    local Bar = Instance.new("Frame", SFrame)
    Bar.Size = UDim2.new(1, 0, 0, 5); Bar.Position = UDim2.new(0, 0, 0.6, 0); Bar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    
    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = Color3.fromRGB(220, 60, 0); Fill.BorderSizePixel = 0
    
    local Dot = Instance.new("TextButton", Bar)
    Dot.Size = UDim2.new(0, 12, 0, 12); Dot.Position = UDim2.new((default-min)/(max-min), -6, 0.5, -6); Dot.BackgroundColor3 = Color3.new(1,1,1); Dot.Text = ""
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    local isDragging = false
    Dot.MouseButton1Down:Connect(function() isDragging = true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end)
    
    RunService.RenderStepped:Connect(function()
        if isDragging then
            local rel = math.clamp((UIS:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Dot.Position = UDim2.new(rel, -6, 0.5, -6); Fill.Size = UDim2.new(rel, 0, 1, 0)
            local v = math.floor(min + (rel * (max - min)))
            _G.Sentinel[varName] = v; Lbl.Text = name .. ": " .. v
        end
    end)
end

-- Montagem do Menu
AddToggle("CRIMSON COMBAT", "SilentAim")
AddToggle("AUTO-TRIGGER", "Triggerbot")
AddToggle("SKELETON ESP", "ESP")
AddToggle("ANTI-TEAMMATE", "TeamCheck")
AddSlider("FOV RADIUS", 10, 800, 150, "FOV")
AddSlider("SMOOTHNESS", 1, 100, 5, "Smoothness")

-- Controles de Teclado (INSERT / END)
-- [[ NOVO SISTEMA DE MOVIMENTAÇÃO E VISIBILIDADE ]]
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

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- Tecla INSERT (Apenas esconde/mostra, o script continua ligado)
game:GetService("UserInputService").InputBegan:Connect(function(input, chat)
    if chat then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
    end
end)

print("SENTINEL GLOBAL: [3/4] Interface Elite Corrigida (Arrastar Ativo).")
-- [[ SENTINEL GLOBAL - ELITE EXECUTION ]]
-- Parte 4: Motor de Combate e Disparo Autónomo

-- Função de Busca de Alvos (Otimizada para Multi-Game)
local function GetClosestTarget()
    local target = nil
    local maxDist = _G.Sentinel.FOV
    
    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        -- A verificação IsEnemy (Parte 1) é o filtro mestre
        if p ~= game:GetService("Players").LocalPlayer and _G.IsEnemy(p) and p.Character then
            local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("UpperTorso")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local pos, onS = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                
                if onS then
                    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
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

-- [[ LOOP INDEPENDENTE DO TRIGGERBOT ]]
-- Funciona sem precisar de Aimbot ou Silent Aim ativos
task.spawn(function()
    while _G.SentinelRunning do
        task.wait() -- Ciclo ultra-rápido de verificação
        
        if _G.Sentinel.Triggerbot then
            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
            local targetObj = mouse.Target
            
            if targetObj and targetObj.Parent then
                -- Detecta se o que está sob o rato é um Personagem
                local character = targetObj.Parent
                if not character:FindFirstChild("Humanoid") then
                    character = character.Parent
                end
                
                local p = game:GetService("Players"):GetPlayerFromCharacter(character)
                
                -- Só dispara se for Inimigo (Ignora Teammates automaticamente)
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

-- [[ LOOP DE COMBATE PRINCIPAL ]]
local combatLoop = game:GetService("RunService").RenderStepped:Connect(function()
    -- 1. Aimbot / Silent Aim Logic
    if _G.Sentinel.SilentAim and game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestTarget()
        
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("UpperTorso")
            if head then
                local hPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                local mPos = game:GetService("UserInputService"):GetMouseLocation()
                
                -- Smoothness Adaptativa
                local s = (101 - _G.Sentinel.Smoothness) / 5
                
                if mousemoverel then
                    mousemoverel((hPos.X - mPos.X) * (s/10), (hPos.Y - mPos.Y) * (s/10))
                end
            end
        end
    end
end)

table.insert(_G.Sentinel.Connections, combatLoop)

-- Finalização e Estética de Inicialização
print("---------------------------------------")
print("SENTINEL GLOBAL V5: TOTALMENTE ATIVO")
print("ESTADO: Premium Horizon UI Ready")
print("FILTRO: Anti-Teammate Cascata Ativo")
print("---------------------------------------")

-- Efeito Visual de Sucesso
local notify = _G.NewDrawing("Text", {
    Text = "SENTINEL V5: DOMINATION ACTIVE",
    Size = 22,
    Color = Color3.fromRGB(255, 80, 0),
    Outline = true,
    Center = true,
    Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, 120),
    Visible = true
})
task.delay(4, function() notify.Visible = false; notify:Remove() end)
