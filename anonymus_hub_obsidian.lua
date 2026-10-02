-- ====================================================================
-- SERVICES & VARIÁVEIS PRINCIPAIS
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local parentContainer = gethui and gethui() or LocalPlayer:WaitForChild("PlayerGui")
if parentContainer:FindFirstChild("MTWHubGui") then
    parentContainer.MTWHubGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MTWHubGui"
ScreenGui.Parent = parentContainer
ScreenGui.ResetOnSpawn = false

-- ====================================================================
-- TELA DE CARREGAMENTO (LOADING SCREEN)
-- ====================================================================
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Parent = ScreenGui
LoadingFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
LoadingFrame.Position = UDim2.new(0.5, -175, 0.5, -105)
LoadingFrame.Size = UDim2.new(0, 350, 0, 210)
LoadingFrame.ClipsDescendants = true

local LoadingCorner = Instance.new("UICorner")
LoadingCorner.CornerRadius = UDim.new(0, 12)
LoadingCorner.Parent = LoadingFrame

local LoadingStroke = Instance.new("UIStroke")
LoadingStroke.Color = Color3.fromRGB(40, 40, 50)
LoadingStroke.Thickness = 1.5
LoadingStroke.Parent = LoadingFrame

local LoadTitle = Instance.new("TextLabel")
LoadTitle.Parent = LoadingFrame
LoadTitle.BackgroundTransparency = 1
LoadTitle.Position = UDim2.new(0, 0, 0, 15)
LoadTitle.Size = UDim2.new(1, 0, 0, 25)
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.Text = "MTW HUB"
LoadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadTitle.TextSize = 18

local LoadDev = Instance.new("TextLabel")
LoadDev.Parent = LoadingFrame
LoadDev.BackgroundTransparency = 1
LoadDev.Position = UDim2.new(0, 0, 0, 42)
LoadDev.Size = UDim2.new(1, 0, 0, 18)
LoadDev.Font = Enum.Font.GothamMedium
LoadDev.Text = "by @7zhc"
LoadDev.TextColor3 = Color3.fromRGB(120, 120, 140)
LoadDev.TextSize = 12

local LoadWarn = Instance.new("TextLabel")
LoadWarn.Parent = LoadingFrame
LoadWarn.BackgroundTransparency = 1
LoadWarn.Position = UDim2.new(0, 15, 0, 68)
LoadWarn.Size = UDim2.new(1, -30, 0, 85)
LoadWarn.Font = Enum.Font.Gotham
LoadWarn.Text = "Esse script é único e totalmente original!\nAdquira somente com o usuário: 7zhc (Não compre de ninguém).\n\n⚠️ 67 HUB e Dio Brando HUB são cópias que não sabem fazer seu trabalho sozinho."
LoadWarn.TextColor3 = Color3.fromRGB(240, 80, 80)
LoadWarn.TextSize = 10
LoadWarn.TextWrapped = true

local BarBackground = Instance.new("Frame")
BarBackground.Parent = LoadingFrame
BarBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
BarBackground.Position = UDim2.new(0.1, 0, 0.86, 0)
BarBackground.Size = UDim2.new(0.8, 0, 0, 8)

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1, 0)
BarCorner.Parent = BarBackground

local BarFill = Instance.new("Frame")
BarFill.Parent = BarBackground
BarFill.BackgroundColor3 = Color3.fromRGB(60, 220, 100)
BarFill.Size = UDim2.new(0, 0, 1, 0)

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = BarFill

-- Animação de Carregamento
TweenService:Create(BarFill, TweenInfo.new(3.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()

task.delay(3.2, function()
    TweenService:Create(LoadingFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    for _, child in ipairs(LoadingFrame:GetDescendants()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        elseif child:IsA("Frame") then
            TweenService:Create(child, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        end
    end
    task.wait(0.4)
    LoadingFrame:Destroy()
end)

-- ====================================================================
-- CONFIGURAÇÕES DE ESTADO
-- ====================================================================
local AutoFollowEnabled = false
local ReachEnabled = false
local ReachDistance = 3.5
local FollowDistance = 1.8

local TargetCenter = Vector3.new(0, -28.94, 0)
local CenterTolerance = 3.5

local function UpdateCharacter(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end
LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

-- ====================================================================
-- 1. SISTEMA DE DRAG
-- ====================================================================
local function MakeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ====================================================================
-- 2. DETECTOR DA BOLA MAIS PRÓXIMA
-- ====================================================================
local function GetClosestBall()
    if not RootPart then return nil end

    local closestBall = nil
    local shortestDistance = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "TPS" or obj.Name:lower():find("ball") or obj.Name:lower():find("bola")) then
            local size = obj.Size
            local isCorrectSize = (size.X >= 0.8 and size.X <= 5.0)
            local isAtCenter = (obj.Position - TargetCenter).Magnitude <= CenterTolerance

            if isCorrectSize and not isAtCenter then
                local dist = (obj.Position - RootPart.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestBall = obj
                end
            end
        end
    end

    return closestBall
end

-- ====================================================================
-- 3. DETECTOR DE INPUT MANUAL
-- ====================================================================
local function IsManualMoving()
    local keyMovement = UserInputService:IsKeyDown(Enum.KeyCode.W) or 
                        UserInputService:IsKeyDown(Enum.KeyCode.A) or 
                        UserInputService:IsKeyDown(Enum.KeyCode.S) or 
                        UserInputService:IsKeyDown(Enum.KeyCode.D)
    
    if keyMovement then return true end

    if Humanoid then
        local moveVec = Humanoid.MoveDirection
        if moveVec.Magnitude > 0.05 then
            return true
        end
    end

    return false
end

local function IsSkillPlaying()
    if Humanoid then
        local animator = Humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local name = track.Name:lower()
                if name:find("skill") or name:find("dribble") or name:find("fake") or name:find("shoot") or name:find("head") or name:find("rainbow") or name:find("lambreta") then
                    return true
                end
            end
        end
    end
    return false
end

-- ====================================================================
-- 4. INTERCEPTADOR ANTI-BUG
-- ====================================================================
local rawnamecall
rawnamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and self == Humanoid and (method == "MoveTo" or method == "moveTo") then
        local targetPos = args[1]
        if typeof(targetPos) == "Vector3" then
            if (targetPos - TargetCenter).Magnitude <= CenterTolerance or targetPos == Vector3.zero then
                return nil
            end
        end
    end

    return rawnamecall(self, ...)
end)

-- ====================================================================
-- 5. LOOPS PRINCIPAIS
-- ====================================================================
RunService.RenderStepped:Connect(function()
    if not RootPart or not RootPart.Parent or not Humanoid then return end
    local ball = GetClosestBall()

    if AutoFollowEnabled and ball then
        local manualMove = IsManualMoving()
        local doingSkill = IsSkillPlaying()

        if not manualMove and not doingSkill then
            local ballPos = ball.Position
            local myPos = RootPart.Position
            local targetVector = Vector3.new(ballPos.X, myPos.Y, ballPos.Z)
            local distance = (targetVector - myPos).Magnitude

            if distance > FollowDistance then
                local moveDirection = (targetVector - myPos).Unit
                Humanoid:Move(moveDirection, false)
            end
        end
    end

    if ReachEnabled and ball then
        local distance = (ball.Position - RootPart.Position).Magnitude
        local reachStuds = ReachDistance * 5.0

        if distance <= reachStuds then
            firetouchinterest(RootPart, ball, 0)
            firetouchinterest(RootPart, ball, 1)

            for _, part in ipairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    firetouchinterest(part, ball, 0)
                    firetouchinterest(part, ball, 1)
                end
            end

            for _, child in ipairs(ball:GetChildren()) do
                if child:IsA("TouchTransmitter") then
                    firetouchinterest(RootPart, ball, 0)
                    firetouchinterest(RootPart, ball, 1)
                end
            end
        end
    end
end)

-- ====================================================================
-- 6. INTERFACE DESIGN (OBSIDIAN UI)
-- Nome atualizado: Anonymus Hub
-- A janela é criada somente depois do loading inicial.
-- ====================================================================

local Library
local Options
local Toggles
local FloatButton

local libSuccess, libResult = pcall(function()
    return loadstring(
        game:HttpGet(
            "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"
        )
    )()
end)

if libSuccess and libResult then
    Library = libResult
else
    warn("Failed to load Obsidian UI Library")
    return
end

Library.Scheme = {
    BackgroundColor = Color3.fromRGB(15, 15, 15),
    MainColor = Color3.fromRGB(25, 25, 25),
    AccentColor = Color3.fromRGB(125, 85, 255),
    OutlineColor = Color3.fromRGB(40, 40, 40),
    FontColor = Color3.fromRGB(235, 235, 240),
    Font = Font.fromEnum(Enum.Font.Gotham),
}

Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = true
Library.NotifyOnError = true

local Window = Library:CreateWindow({
    Title = "Anonymus Hub",
    Footer = "Steal an Egg",
    Center = true,
    AutoShow = false,
    ShowMobileButtons = true,
    NotifySide = "Right",
})

local Tabs = {
    Main = Window:AddTab("Auto Follow", "home"),
    Reach = Window:AddTab("Reach", "target"),
    Ball = Window:AddTab("Bola", "circle"),
    Grass = Window:AddTab("Gramado", "map"),
    AntiLag = Window:AddTab("Anti-Lag", "zap"),
}

-- ============================================================
-- AUTO FOLLOW
-- ============================================================

local FollowBox = Tabs.Main:AddLeftGroupbox("Auto Follow", "person")

FollowBox:AddToggle("AutoFollowToggle", {
    Text = "Auto Follow",
    Default = AutoFollowEnabled,
    Tooltip = "Ativa ou desativa o Auto Follow.",
    Callback = function(Value)
        AutoFollowEnabled = Value
    end,
})

FollowBox:AddSlider("FollowDistance", {
    Text = "Distância",
    Default = FollowDistance,
    Min = 1.5,
    Max = 2.2,
    Rounding = 1,
    Suffix = "m",
    Callback = function(Value)
        FollowDistance = Value
    end,
})

FollowBox:AddButton({
    Text = "Distância: Colado (1.5m)",
    Func = function()
        FollowDistance = 1.5
        Options.FollowDistance:SetValue(1.5)
    end,
})

FollowBox:AddButton({
    Text = "Distância: Médio (1.8m)",
    Func = function()
        FollowDistance = 1.8
        Options.FollowDistance:SetValue(1.8)
    end,
})

FollowBox:AddButton({
    Text = "Distância: Longo (2.2m)",
    Func = function()
        FollowDistance = 2.2
        Options.FollowDistance:SetValue(2.2)
    end,
})

local FollowInfo = Tabs.Main:AddRightGroupbox("Informações", "info")

FollowInfo:AddLabel(
    "Mexer o analógico/WASD desativa o Auto Follow durante o movimento manual.",
    true
)

FollowInfo:AddToggle("FloatButtonToggle", {
    Text = "Botão flutuante",
    Default = true,
    Callback = function(Value)
        -- A visibilidade do botão flutuante é controlada abaixo,
        -- depois que o objeto for criado.
        if FloatButton then
            FloatButton.Visible = Value
        end
    end,
})

-- ============================================================
-- REACH
-- ============================================================

local ReachBox = Tabs.Reach:AddLeftGroupbox("Reach", "target")

ReachBox:AddToggle("ReachToggle", {
    Text = "Ativar Reach",
    Default = ReachEnabled,
    Callback = function(Value)
        ReachEnabled = Value
    end,
})

ReachBox:AddSlider("ReachDistance", {
    Text = "Alcance",
    Default = ReachDistance,
    Min = 2.0,
    Max = 10.0,
    Rounding = 1,
    Suffix = "m",
    Callback = function(Value)
        ReachDistance = Value
    end,
})

ReachBox:AddButton({
    Text = "Alcance: 2.0 Metros",
    Func = function()
        ReachDistance = 2.0
        Options.ReachDistance:SetValue(2.0)
    end,
})

ReachBox:AddButton({
    Text = "Alcance: 3.5 Metros",
    Func = function()
        ReachDistance = 3.5
        Options.ReachDistance:SetValue(3.5)
    end,
})

ReachBox:AddButton({
    Text = "Alcance: 5.0 Metros",
    Func = function()
        ReachDistance = 5.0
        Options.ReachDistance:SetValue(5.0)
    end,
})

ReachBox:AddButton({
    Text = "Alcance: 7.5 Metros",
    Func = function()
        ReachDistance = 7.5
        Options.ReachDistance:SetValue(7.5)
    end,
})

ReachBox:AddButton({
    Text = "Alcance: 10.0 Metros",
    Func = function()
        ReachDistance = 10.0
        Options.ReachDistance:SetValue(10.0)
    end,
})

-- ============================================================
-- BOLA
-- ============================================================

local BallBox = Tabs.Ball:AddLeftGroupbox("Visual da Bola", "circle")

BallBox:AddButton({
    Text = "Cor: Vermelho Neon",
    Func = function()
        local ball = GetClosestBall()
        if ball then
            ball.Color = Color3.fromRGB(255, 40, 40)
            ball.Material = Enum.Material.Neon
        end
    end,
})

BallBox:AddButton({
    Text = "Cor: Azul Cyan",
    Func = function()
        local ball = GetClosestBall()
        if ball then
            ball.Color = Color3.fromRGB(0, 230, 255)
            ball.Material = Enum.Material.Neon
        end
    end,
})

BallBox:AddToggle("BallFire", {
    Text = "Efeito de Fogo",
    Default = false,
    Callback = function(Value)
        local ball = GetClosestBall()
        if not ball then
            return
        end

        local fire = ball:FindFirstChildOfClass("Fire")

        if Value and not fire then
            local newFire = Instance.new("Fire")
            newFire.Size = 6
            newFire.Parent = ball
        elseif not Value and fire then
            fire:Destroy()
        end
    end,
})

-- ============================================================
-- GRAMADO
-- ============================================================

local ModifiedGrassParts = {}

local function ApplyGrassColor(color)
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            local isCharacter = part:IsDescendantOf(Players)
                or (part.Parent and part.Parent:FindFirstChildOfClass("Humanoid"))

            if not isCharacter then
                local n = part.Name:lower()
                local isLine =
                    n:find("line")
                    or n:find("linha")
                    or n:find("white")
                    or part.Transparency > 0.4

                if not isLine then
                    if ModifiedGrassParts[part]
                        or n:find("grass")
                        or n:find("pitch")
                        or n:find("campo")
                        or n:find("field")
                        or n:find("out")
                        or n:find("wedge")
                        or n:find("stadium")
                        or n:find("floor")
                        or (part.Position.Y < 5 and part.Size.X > 8) then

                        part.Color = color
                        part.Material = Enum.Material.SmoothPlastic
                        ModifiedGrassParts[part] = true
                    end
                end
            end
        end
    end
end

local GrassBox = Tabs.Grass:AddLeftGroupbox("Cores do Gramado", "map")

GrassBox:AddButton({
    Text = "Verde Dark",
    Func = function()
        ApplyGrassColor(Color3.fromRGB(15, 75, 30))
    end,
})

GrassBox:AddButton({
    Text = "Preto Total",
    Func = function()
        ApplyGrassColor(Color3.fromRGB(18, 18, 22))
    end,
})

GrassBox:AddButton({
    Text = "Roxo Cyber",
    Func = function()
        ApplyGrassColor(Color3.fromRGB(80, 20, 120))
    end,
})

GrassBox:AddButton({
    Text = "Azul Midnight",
    Func = function()
        ApplyGrassColor(Color3.fromRGB(15, 35, 85))
    end,
})

-- ============================================================
-- ANTI-LAG
-- ============================================================

local AntiLagBox = Tabs.AntiLag:AddLeftGroupbox("Performance", "zap")

AntiLagBox:AddButton({
    Text = "Remover Sombras do Mapa",
    Func = function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Library:Notify({
            Title = "Anonymus Hub",
            Description = "Sombras e distância de neblina ajustadas.",
            Time = 3,
        })
    end,
})

AntiLagBox:AddLabel(
    "Use esta opção para reduzir alguns efeitos visuais do mapa.",
    true
)

-- ============================================================
-- BOTÃO FLUTUANTE
-- ============================================================

FloatButton = Instance.new("TextButton")
local FloatCorner = Instance.new("UICorner")
local FloatStroke = Instance.new("UIStroke")

FloatButton.Name = "AnonymusHubFloatBtn"
FloatButton.Parent = ScreenGui
FloatButton.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
FloatButton.Position = UDim2.new(0.84, 0, 0.2, 0)
FloatButton.Size = UDim2.new(0, 118, 0, 38)
FloatButton.Font = Enum.Font.GothamBold
FloatButton.Text = "FOLLOW  •  OFF"
FloatButton.TextColor3 = Color3.fromRGB(235, 235, 240)
FloatButton.TextSize = 12
FloatButton.AutoButtonColor = false
FloatButton.Visible = true

FloatCorner.CornerRadius = UDim.new(0, 9)
FloatCorner.Parent = FloatButton

FloatStroke.Color = Color3.fromRGB(65, 65, 75)
FloatStroke.Thickness = 1
FloatStroke.Parent = FloatButton

MakeDraggable(FloatButton)

FloatButton.MouseButton1Click:Connect(function()
    AutoFollowEnabled = not AutoFollowEnabled

    if Toggles.AutoFollowToggle then
        Toggles.AutoFollowToggle:SetValue(AutoFollowEnabled)
    end

    if AutoFollowEnabled then
        FloatButton.Text = "FOLLOW  •  ON"
        FloatButton.TextColor3 = Color3.fromRGB(105, 235, 145)
        FloatStroke.Color = Color3.fromRGB(105, 235, 145)
    else
        FloatButton.Text = "FOLLOW  •  OFF"
        FloatButton.TextColor3 = Color3.fromRGB(235, 235, 240)
        FloatStroke.Color = Color3.fromRGB(65, 65, 75)
    end
end)

-- ============================================================
-- APÓS O PRIMEIRO LOADING / AVISO
-- A interface Obsidian só aparece depois da tela inicial.
-- ============================================================

task.delay(3.7, function()
    FloatButton.Visible = true
    Window:Show()

    Library:Notify({
        Title = "Anonymus Hub",
        Description = "Interface carregada com sucesso.",
        Time = 3,
    })
end)

Library:OnUnload(function()
    if ScreenGui then
        ScreenGui:Destroy()
    end
end)

-- ====================================================================
-- END OBSIDIAN UI
-- ====================================================================
