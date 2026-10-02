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
-- Visual layer only: existing gameplay logic/variables are preserved.
-- ====================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ObsidianHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local function MakeDraggable(guiObject)
    local dragging, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
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
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Floating button
local FloatButton = Instance.new("TextButton")
FloatButton.Name = "AutoBallFloatBtn"
FloatButton.Parent = ScreenGui
FloatButton.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
FloatButton.Position = UDim2.new(0.84, 0, 0.20, 0)
FloatButton.Size = UDim2.new(0, 118, 0, 38)
FloatButton.Font = Enum.Font.GothamBold
FloatButton.Text = "FOLLOW  •  OFF"
FloatButton.TextColor3 = Color3.fromRGB(235, 235, 240)
FloatButton.TextSize = 12
FloatButton.AutoButtonColor = false

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 9)
FloatCorner.Parent = FloatButton

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(65, 65, 75)
FloatStroke.Thickness = 1
FloatStroke.Parent = FloatButton

MakeDraggable(FloatButton)

FloatButton.MouseButton1Click:Connect(function()
    AutoFollowEnabled = not AutoFollowEnabled
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

-- Main window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
MainFrame.Size = UDim2.new(0, 500, 0, 320)
MainFrame.ClipsDescendants = true
MainFrame.Visible = false

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(42, 42, 50)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

MakeDraggable(MainFrame)

local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
Sidebar.Size = UDim2.new(0, 132, 1, 0)

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

local Title = Instance.new("TextLabel")
Title.Parent = Sidebar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 16, 0, 15)
Title.Size = UDim2.new(1, -28, 0, 28)
Title.Font = Enum.Font.GothamBold
Title.Text = "OBSIDIAN"
Title.TextColor3 = Color3.fromRGB(242, 242, 246)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local Subtitle = Instance.new("TextLabel")
Subtitle.Parent = Sidebar
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0, 16, 0, 39)
Subtitle.Size = UDim2.new(1, -28, 0, 18)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "MTW HUB"
Subtitle.TextColor3 = Color3.fromRGB(115, 115, 125)
Subtitle.TextSize = 9
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

local TabHolder = Instance.new("Frame")
TabHolder.Parent = Sidebar
TabHolder.BackgroundTransparency = 1
TabHolder.Position = UDim2.new(0, 8, 0, 72)
TabHolder.Size = UDim2.new(1, -16, 1, -82)

local TabLayout = Instance.new("UIListLayout")
TabLayout.Parent = TabHolder
TabLayout.Padding = UDim.new(0, 5)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Content = Instance.new("Frame")
Content.Parent = MainFrame
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 132, 0, 0)
Content.Size = UDim2.new(1, -132, 1, 0)

local ContentTitle = Instance.new("TextLabel")
ContentTitle.Parent = Content
ContentTitle.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 18, 0, 15)
Content.Size = UDim2.new(1, -36, 0, 28)
Content.Font = Enum.Font.GothamBold
Content.Text = "Auto Follow"
Content.TextColor3 = Color3.fromRGB(240, 240, 245)
Content.TextSize = 15
Content.TextXAlignment = Enum.TextXAlignment.Left

local ContentLine = Instance.new("Frame")
ContentLine.Parent = Content
ContentLine.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Content.BorderSizePixel = 0
ContentLine.Position = UDim2.new(0, 18, 0, 48)
ContentLine.Size = UDim2.new(1, -36, 0, 1)

local Container = Instance.new("Frame")
Container.Parent = Content
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 18, 0, 58)
Container.Size = UDim2.new(1, -36, 1, -70)

local Tabs = {}
local Pages = {}

local function CreateTabButton(name, order)
    local button = Instance.new("TextButton")
    button.Name = name .. "Tab"
    button.Parent = TabHolder
    button.Size = UDim2.new(1, 0, 0, 34)
    button.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
    button.BackgroundTransparency = 1
    button.Font = Enum.Font.GothamMedium
    button.Text = name
    button.TextColor3 = Color3.fromRGB(145, 145, 155)
    button.TextSize = 11
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.AutoButtonColor = false
    button.LayoutOrder = order

    local pad = Instance.new("UIPadding")
    pad.Parent = button
    pad.PaddingLeft = UDim.new(0, 12)

    local indicator = Instance.new("Frame")
    indicator.Parent = button
    indicator.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
    indicator.BorderSizePixel = 0
    indicator.Position = UDim2.new(0, 0, 0.5, -8)
    indicator.Size = UDim2.new(0, 2, 0, 16)
    indicator.Visible = false

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 2)
    corner.Parent = indicator

    Tabs[name] = {button = button, indicator = indicator}
    return button
end

local TabFollow = CreateTabButton("Auto Follow", 1)
local TabReach = CreateTabButton("Reach", 2)
local TabBall = CreateTabButton("Bola", 3)
local TabGrass = CreateTabButton("Gramado", 4)
local TabAntiLag = CreateTabButton("Anti-Lag", 5)

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Parent = Container
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 80)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout")
    layout.Parent = page
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    Pages[name] = page
    return page
end

local PageFollow = CreatePage("Auto Follow")
local PageReach = CreatePage("Reach")
local PageBall = CreatePage("Bola")
local PageGrass = CreatePage("Gramado")
local PageAntiLag = CreatePage("Anti-Lag")

local function UpdateTabVisuals(activeName)
    for name, data in pairs(Tabs) do
        local active = (name == activeName)
        data.indicator.Visible = active
        data.button.TextColor3 = active
            and Color3.fromRGB(242, 242, 246)
            or Color3.fromRGB(145, 145, 155)
        data.button.BackgroundTransparency = active and 0.85 or 1
    end
end

local function ShowPage(pageName)
    for name, page in pairs(Pages) do
        page.Visible = (name == pageName)
    end
    ContentTitle.Text = pageName
    UpdateTabVisuals(pageName)
end

TabFollow.MouseButton1Click:Connect(function() ShowPage("Auto Follow") end)
TabReach.MouseButton1Click:Connect(function() ShowPage("Reach") end)
TabBall.MouseButton1Click:Connect(function() ShowPage("Bola") end)
TabGrass.MouseButton1Click:Connect(function() ShowPage("Gramado") end)
TabAntiLag.MouseButton1Click:Connect(function() ShowPage("Anti-Lag") end)

local function AddOptionButton(page, text, callback, yOffset)
    local btn = Instance.new("TextButton")
    btn.Parent = page
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    btn.Size = UDim2.new(1, -2, 0, 36)
    btn.Font = Enum.Font.Gotham
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 228)
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.LayoutOrder = math.floor((yOffset or 0) / 32) + 1

    local pad = Instance.new("UIPadding")
    pad.Parent = btn
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(38, 38, 46)
    stroke.Thickness = 1
    stroke.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 31)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    end)

    btn.MouseButton1Click:Connect(function()
        callback(btn, stroke)
    end)

    return btn
end

-- Existing feature controls
AddOptionButton(PageFollow, "Botão Flutuante: VISÍVEL", function(btn)
    FloatButton.Visible = not FloatButton.Visible
    btn.Text = FloatButton.Visible and "Botão Flutuante: VISÍVEL" or "Botão Flutuante: OCULTO"
end, 0)

AddOptionButton(PageFollow, "Distância: Colado (1.5m)", function() FollowDistance = 1.5 end, 68)
AddOptionButton(PageFollow, "Distância: Médio (1.8m)", function() FollowDistance = 1.8 end, 100)
AddOptionButton(PageFollow, "Distância: Longo (2.2m)", function() FollowDistance = 2.2 end, 132)

local ReachToggleBtn = AddOptionButton(PageReach, "Status do Reach: OFF", function(btn, stroke)
    ReachEnabled = not ReachEnabled
    if ReachEnabled then
        btn.Text = "Status do Reach: ON (" .. ReachDistance .. "m)"
        btn.TextColor3 = Color3.fromRGB(105, 235, 145)
        stroke.Color = Color3.fromRGB(105, 235, 145)
    else
        btn.Text = "Status do Reach: OFF"
        btn.TextColor3 = Color3.fromRGB(220, 220, 230)
        stroke.Color = Color3.fromRGB(38, 38, 46)
    end
end, 0)

local function SetReachDist(val)
    ReachDistance = val
    if ReachEnabled then
        ReachToggleBtn.Text = "Status do Reach: ON (" .. val .. "m)"
    end
end

AddOptionButton(PageReach, "Alcance: 2.0 Metros", function() SetReachDist(2.0) end, 32)
AddOptionButton(PageReach, "Alcance: 3.5 Metros", function() SetReachDist(3.5) end, 64)
AddOptionButton(PageReach, "Alcance: 5.0 Metros", function() SetReachDist(5.0) end, 96)
AddOptionButton(PageReach, "Alcance: 7.5 Metros", function() SetReachDist(7.5) end, 128)
AddOptionButton(PageReach, "Alcance: 10.0 Metros", function() SetReachDist(10.0) end, 160)

AddOptionButton(PageBall, "Cor da Bola: Vermelho Neon", function()
    local ball = GetClosestBall()
    if ball then
        ball.Color = Color3.fromRGB(255, 40, 40)
        ball.Material = Enum.Material.Neon
    end
end, 0)

AddOptionButton(PageBall, "Cor da Bola: Azul Cyan", function()
    local ball = GetClosestBall()
    if ball then
        ball.Color = Color3.fromRGB(0, 230, 255)
        ball.Material = Enum.Material.Neon
    end
end, 32)

AddOptionButton(PageBall, "Efeito Fogo: TOGGLE", function(btn)
    local ball = GetClosestBall()
    if ball then
        local fire = ball:FindFirstChildOfClass("Fire")
        if fire then
            fire:Destroy()
            btn.Text = "Efeito Fogo: OFF"
        else
            local newFire = Instance.new("Fire")
            newFire.Size = 6
            newFire.Parent = ball
            btn.Text = "Efeito Fogo: ON"
        end
    end
end, 64)

local ModifiedGrassParts = {}

local function ApplyGrassColor(color)
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            local isCharacter = part:IsDescendantOf(Players)
                or (part.Parent and part.Parent:FindFirstChildOfClass("Humanoid"))
            if not isCharacter then
                local n = part.Name:lower()
                local isLine = n:find("line") or n:find("linha")
                    or n:find("white") or part.Transparency > 0.4

                if not isLine then
                    if ModifiedGrassParts[part] or n:find("grass")
                        or n:find("pitch") or n:find("campo")
                        or n:find("field") or n:find("out")
                        or n:find("wedge") or n:find("stadium")
                        or n:find("floor") or (part.Position.Y < 5 and part.Size.X > 8) then
                        part.Color = color
                        part.Material = Enum.Material.SmoothPlastic
                        ModifiedGrassParts[part] = true
                    end
                end
            end
        end
    end
end

AddOptionButton(PageGrass, "Gramado: Verde Dark", function()
    ApplyGrassColor(Color3.fromRGB(15, 75, 30))
end, 0)

AddOptionButton(PageGrass, "Gramado: Mod Preto Total", function()
    ApplyGrassColor(Color3.fromRGB(18, 18, 22))
end, 32)

AddOptionButton(PageGrass, "Gramado: Roxo Cyber", function()
    ApplyGrassColor(Color3.fromRGB(80, 20, 120))
end, 64)

AddOptionButton(PageGrass, "Gramado: Azul Midnight", function()
    ApplyGrassColor(Color3.fromRGB(15, 35, 85))
end, 96)

AddOptionButton(PageAntiLag, "Remover Sombras do Mapa", function(btn, stroke)
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    btn.Text = "Sombras: DESATIVADAS"
    btn.TextColor3 = Color3.fromRGB(105, 235, 145)
    stroke.Color = Color3.fromRGB(105, 235, 145)
end, 0)

-- Close/open button
local OpenButton = Instance.new("TextButton")
OpenButton.Parent = ScreenGui
OpenButton.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
OpenButton.Position = UDim2.new(0, 14, 0.5, -18)
OpenButton.Size = UDim2.new(0, 34, 0, 34)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Text = "≡"
OpenButton.TextColor3 = Color3.fromRGB(235, 235, 240)
OpenButton.TextSize = 18
OpenButton.AutoButtonColor = false

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 9)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(55, 55, 65)
OpenStroke.Thickness = 1
OpenStroke.Parent = OpenButton

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

ShowPage("Auto Follow")

-- ====================================================================
-- END OBSIDIAN UI
-- ====================================================================
