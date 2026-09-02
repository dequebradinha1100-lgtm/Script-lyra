-- [[ SMILE 7 HUB - VERSÃO DEFINITIVA (REORGANIZADA) ]] --

-- ├── Rayfield / Window
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Falha ao carregar a Rayfield UI. Verifique sua conexão ou executor.")
    return
end

local Window = Rayfield:CreateWindow({
   Name = "Smile 7 Hub",
   LoadingTitle = "Smile 7 Hub",
   LoadingSubtitle = "by anonymus7",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false,
})

-- ├── Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ├── Config
local cfg = {
    -- Reach
    reach = 10,
    sphere = true,
    touch = true,
    reachColor = Color3.fromRGB(0, 255, 255),
    
    -- Bolas
    bolaBrancaAtiva = false,
    textureInputText = "",
    meshInputText = "",
    
    -- Gameplay / Teleport
    autoFollow = false,
    kickOn = false,
    kick = 5,
    
    -- Sistemas de Bola
    magneticEnabled = false,
    magneticStrength = 50,
    
    -- ESP
    esp = true,
    espTrainingOnly = false,
    espPlayers = false, -- TODO
    espLines = false, -- TODO
    
    -- Personagem
    spin = false,
    spinSpeed = 3,
    walkSpeed = 16, -- TODO
    infiniteJump = false, -- TODO
    autoReset = false -- TODO
}

-- ├── Variables / State
local balls = {}
local esps = {}
local dadosOriginais = {}
local magneticWelds = {}
local sp = nil
local targetBall = nil
local char, humanoid, hrp = nil, nil, nil
local spinAngle = 0
local rgbHue = 0
local rgbConnection = nil

local bolaNomes = {
    TPS = true, ESA = true, MRS = true, PRS = true, MPS = true, SSS = true, AIFA = true, RBZ = true,
    Football = true, Ball = true, SoccerBall = true, Hitbox = true, Bola = true, TrainingBall = true
}

-- ├── Character Functions
local function atualizarChar()
    char = LocalPlayer.Character
    if char then
        humanoid = char:FindFirstChildOfClass("Humanoid")
        hrp = char:FindFirstChild("HumanoidRootPart")
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    atualizarChar()
end)
atualizarChar()

-- ├── Ball Detection
local function ObterBolas()
    local lista = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local nomeLower = string.lower(obj.Name)
            if bolaNomes[obj.Name] or string.find(nomeLower, "tcs") or string.find(nomeLower, "ball") or string.find(nomeLower, "bola") then
                table.insert(lista, obj)
            end
        end
    end
    return lista
end

local function AcharBolaMaisProxima()
    if not hrp or not hrp.Parent then return nil end
    local maisProxima, menorDist = nil, math.huge
    for _, v in pairs(ObterBolas()) do
        if v and v.Parent then
            local dist = (v.Position - hrp.Position).Magnitude
            if dist < menorDist then
                menorDist = dist
                maisProxima = v
            end
        end
    end
    return maisProxima
end

-- ├── Reach System
local function AtualizarEsfera()
    if not cfg.sphere then
        if sp and sp.Parent then sp:Destroy() end
        sp = nil
        return
    end
    if not sp or not sp.Parent then
        sp = Instance.new("Part")
        sp.Name = "SmileReachSphere"
        sp.Shape = Enum.PartType.Ball
        sp.Anchored = true
        sp.CanCollide = false
        sp.Transparency = 0.7
        sp.Material = Enum.Material.ForceField
        sp.Color = cfg.reachColor
        sp.Parent = Workspace
    end
    sp.Size = Vector3.new(cfg.reach * 2, cfg.reach * 2, cfg.reach * 2)
    sp.Color = cfg.reachColor
end

-- ├── Ball Customization
local function FormatarID(id)
    if not id or id == "" then return "" end
    local num = string.match(id, "%d+")
    return num and ("rbxassetid://" .. num) or id
end

-- ├── Teleport / Gameplay
-- (Lógica inlineada no Main Loop e UI)

-- ├── Ball System
-- (Lógica inlineada no Main Loop e UI)

-- ├── ESP System
-- (Lógica inlineada no Main Loop)

-- ├── Character System
-- (Lógica inlineada no Main Loop e UI)

-- ├── UI
-- │   ├── Reach
local TabReach = Window:CreateTab("Reach", "crosshair")

TabReach:CreateSlider({
   Name = "Reach (Alcance)",
   Range = {1, 50},
   Increment = 1,
   CurrentValue = cfg.reach,
   Callback = function(v)
      cfg.reach = v
      AtualizarEsfera()
   end,
})

TabReach:CreateToggle({
   Name = "Mostrar Esfera Reach",
   CurrentValue = cfg.sphere,
   Callback = function(v)
      cfg.sphere = v
      AtualizarEsfera()
   end,
})

TabReach:CreateToggle({
   Name = "Bola Reach",
   CurrentValue = cfg.touch,
   Callback = function(v)
      cfg.touch = v
   end,
})

TabReach:CreateColorPicker({
    Name = "Reach Color",
    Color = cfg.reachColor,
    Flag = "ReachColorPicker",
    Callback = function(Value)
        cfg.reachColor = Value
        AtualizarEsfera()
    end
})

-- │   ├── Customizar Bola
local TabCustomizar = Window:CreateTab("Customizar Bola", "palette")

TabCustomizar:CreateToggle({
   Name = "Bola Branca",
   CurrentValue = cfg.bolaBrancaAtiva,
   Callback = function(v)
      cfg.bolaBrancaAtiva = v
   end,
})

TabCustomizar:CreateInput({
   Name = "Texture ID",
   PlaceholderText = "Cole a Texture ID...",
   RemoveTextAfterFocusLost = false,
   Callback = function(text)
      cfg.textureInputText = text
   end,
})

TabCustomizar:CreateButton({
   Name = "Remover Texture",
   Callback = function()
      cfg.textureInputText = ""
      for _, b in pairs(ObterBolas()) do
          pcall(function()
              if b:IsA("MeshPart") then b.TextureID = "" end
              local m = b:FindFirstChildOfClass("SpecialMesh")
              if m then m.TextureId = "" end
              for _, c in pairs(b:GetChildren()) do
                  if c:IsA("Decal") or c:IsA("Texture") then c.Texture = "" end
              end
          end)
      end
      Rayfield:Notify({Title = "Sucesso", Content = "Texture removida!", Duration = 3})
   end,
})

TabCustomizar:CreateInput({
   Name = "Mesh ID",
   PlaceholderText = "Cole a Mesh ID...",
   RemoveTextAfterFocusLost = false,
   Callback = function(text)
      cfg.meshInputText = text
   end,
})

TabCustomizar:CreateButton({
   Name = "Remover Mesh",
   Callback = function()
      cfg.meshInputText = ""
      for _, b in pairs(ObterBolas()) do
          pcall(function()
              if dadosOriginais[b] and dadosOriginais[b].MeshId and b:IsA("MeshPart") then
                  b.MeshId = dadosOriginais[b].MeshId
              end
              local m = b:FindFirstChildOfClass("SpecialMesh")
              if m and dadosOriginais[b] and dadosOriginais[b].SpecialMeshId then
                  m.MeshId = dadosOriginais[b].SpecialMeshId
              end
          end)
      end
      Rayfield:Notify({Title = "Sucesso", Content = "Mesh original restaurada!", Duration = 3})
   end,
})

TabCustomizar:CreateSection("Bolas Prontas")

TabCustomizar:CreateButton({
   Name = "Bola da Champions Laranja",
   Callback = function()
      cfg.textureInputText = "http://www.roblox.com/asset/?id=6631296730"
      cfg.meshInputText = "rbxassetid://4545270159"
      Rayfield:Notify({Title = "Aplicado", Content = "Champions Laranja selecionada!", Duration = 3})
   end,
})

-- │   ├── Teleports e Jogabilidade
local TabGameplay = Window:CreateTab("Teleports e Jogabilidade", "gamepad-2")

TabGameplay:CreateButton({
   Name = "Teleport para Bola",
   Callback = function()
      if hrp then
          local b = AcharBolaMaisProxima()
          if b then hrp.CFrame = b.CFrame * CFrame.new(0, 3, 0) end
      end
   end,
})

TabGameplay:CreateToggle({
   Name = "Auto Seguir Bola",
   CurrentValue = cfg.autoFollow,
   Callback = function(v)
      cfg.autoFollow = v
      targetBall = v and AcharBolaMaisProxima() or nil
   end,
})

TabGameplay:CreateToggle({
   Name = "Power Shoot",
   CurrentValue = cfg.kickOn,
   Callback = function(v)
      cfg.kickOn = v
   end,
})

TabGameplay:CreateSlider({
   Name = "Slide — Força Power Shoot",
   Range = {0, 10},
   Increment = 1,
   CurrentValue = cfg.kick,
   Callback = function(v)
      cfg.kick = v
   end,
})

-- │   ├── Bola
local TabBola = Window:CreateTab("Bola", "aperture")

TabBola:CreateToggle({
   Name = "Magnetic Ball",
   CurrentValue = cfg.magneticEnabled,
   Callback = function(v)
      cfg.magneticEnabled = v
      if not v then
          for b, _ in pairs(magneticWelds) do if b and b.Parent then b.CanCollide = true end end
          magneticWelds = {}
      end
   end,
})

TabBola:CreateSlider({
   Name = "Slide — Força Magnética",
   Range = {10, 200},
   Increment = 5,
   CurrentValue = cfg.magneticStrength,
   Callback = function(v)
      cfg.magneticStrength = v
   end,
})

TabBola:CreateButton({
   Name = "Salvar Posição do Gol",
   Callback = function()
      -- TODO: Implementar lógica de salvar posição do gol futuramente
      Rayfield:Notify({Title = "Sistema", Content = "Em breve!", Duration = 2})
   end,
})

TabBola:CreateButton({
   Name = "Fazer o Gol",
   Callback = function()
      -- TODO: Implementar lógica de Fazer o Gol futuramente
      Rayfield:Notify({Title = "Sistema", Content = "Em breve!", Duration = 2})
   end,
})

-- │   ├── ESP's
local TabESP = Window:CreateTab("ESP's", "eye")

TabESP:CreateToggle({
   Name = "ESP Players",
   CurrentValue = cfg.espPlayers,
   Callback = function(v)
      cfg.espPlayers = v
      -- TODO: Implementar lógica de ESP Players futuramente
   end,
})

TabESP:CreateToggle({
   Name = "ESP Bola de Treino",
   CurrentValue = cfg.espTrainingOnly,
   Callback = function(v)
      cfg.espTrainingOnly = v
   end,
})

TabESP:CreateToggle({
   Name = "ESP Ball",
   CurrentValue = cfg.esp,
   Callback = function(v)
      cfg.esp = v
   end,
})

TabESP:CreateToggle({
   Name = "ESP Linhas",
   CurrentValue = cfg.espLines,
   Callback = function(v)
      cfg.espLines = v
      -- TODO: Implementar lógica de ESP Linhas futuramente
   end,
})

-- │   └── Personagem
local TabPersonagem = Window:CreateTab("Personagem", "user")

TabPersonagem:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = cfg.walkSpeed,
   Callback = function(v)
      cfg.walkSpeed = v
      -- TODO: Implementar lógica de alteração de WalkSpeed no Character System
   end,
})

TabPersonagem:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = cfg.infiniteJump,
   Callback = function(v)
      cfg.infiniteJump = v
      -- TODO: Implementar lógica de Infinite Jump 
   end,
})

TabPersonagem:CreateToggle({
   Name = "Spin Mode",
   CurrentValue = cfg.spin,
   Callback = function(v)
      cfg.spin = v
   end,
})

TabPersonagem:CreateToggle({
   Name = "RGB Player (Arco-Íris)",
   CurrentValue = false,
   Callback = function(v)
      if v then
          rgbConnection = RunService.RenderStepped:Connect(function()
              rgbHue = (rgbHue + 0.5) % 360
              local cor = Color3.fromHSV(rgbHue / 360, 1, 1)
              if LocalPlayer.Character then
                  for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                      if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Color = cor end
                  end
              end
          end)
      else
          if rgbConnection then rgbConnection:Disconnect(); rgbConnection = nil end
      end
   end,
})

TabPersonagem:CreateToggle({
   Name = "Auto Reset",
   CurrentValue = cfg.autoReset,
   Callback = function(v)
      cfg.autoReset = v
      -- TODO: Implementar lógica de Auto Reset 
   end,
})

-- ├── Main Loops
RunService.Heartbeat:Connect(function(delta)
    if not hrp or not hrp.Parent then atualizarChar() end

    balls = ObterBolas()

    -- Auto Seguir
    if cfg.autoFollow and humanoid and hrp then
        if not targetBall or not targetBall.Parent then targetBall = AcharBolaMaisProxima() end
        if targetBall and targetBall.Parent then humanoid:MoveTo(targetBall.Position) end
    end

    -- Reach & Touch Interest
    if cfg.touch and hrp and char then
        for _, pt in pairs(char:GetChildren()) do
            if pt:IsA("BasePart") and pt.Name ~= "HumanoidRootPart" then
                for _, b in pairs(balls) do
                    if b and b.Parent and (b.Position - pt.Position).Magnitude <= cfg.reach then
                        pcall(function() firetouchinterest(b, pt, 0); firetouchinterest(b, pt, 1) end)
                    end
                end
            end
        end
    end

    -- Spin Mode
    if cfg.spin and hrp then
        spinAngle = spinAngle + delta * cfg.spinSpeed * 5
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, spinAngle, 0)
    end

    -- Atualizar Posição da Esfera
    if sp and hrp then sp.Position = hrp.Position end

    -- Customização de Bolas (Textura, Mesh, Bola Branca)
    if #balls > 0 then
        local tTx = FormatarID(cfg.textureInputText)
        local tMs = FormatarID(cfg.meshInputText)

        for _, b in pairs(balls) do
            pcall(function()
                if not dadosOriginais[b] then
                    dadosOriginais[b] = {
                        Color = b.Color,
                        Material = b.Material,
                        TextureID = b:IsA("MeshPart") and b.TextureID or "",
                        MeshId = b:IsA("MeshPart") and b.MeshId or "",
                        SpecialMeshId = b:FindFirstChildOfClass("SpecialMesh") and b:FindFirstChildOfClass("SpecialMesh").MeshId or ""
                    }
                end

                local mObj = b:FindFirstChildOfClass("SpecialMesh")

                -- Aplicar Mesh
                if tMs ~= "" then
                    if b:IsA("MeshPart") then
                        if b.MeshId ~= tMs then b.MeshId = tMs end
                    else
                        if not mObj then mObj = Instance.new("SpecialMesh", b) end
                        if mObj.MeshId ~= tMs then
                            mObj.MeshType = Enum.MeshType.FileMesh
                            mObj.MeshId = tMs
                        end
                    end
                end

                -- Aplicar Texture
                if tTx ~= "" then
                    if b:IsA("MeshPart") then
                        if b.TextureID ~= tTx then b.TextureID = tTx end
                    end
                    if mObj then
                        if mObj.TextureId ~= tTx then mObj.TextureId = tTx end
                    end
                    for _, c in pairs(b:GetChildren()) do
                        if c:IsA("Decal") or c:IsA("Texture") then
                            if c.Texture ~= tTx then c.Texture = tTx end
                        end
                    end
                end

                -- Bola Branca
                if cfg.bolaBrancaAtiva then
                    b.Color = Color3.fromRGB(255, 255, 255)
                    b.Material = Enum.Material.SmoothPlastic
                    for _, child in pairs(b:GetChildren()) do
                        if child:IsA("SurfaceAppearance") then child.Enabled = false end
                    end
                    if tTx == "" then
                        if b:IsA("MeshPart") then b.TextureID = "" end
                        if mObj then mObj.TextureId = "" end
                        for _, c in pairs(b:GetChildren()) do
                            if c:IsA("Decal") or c:IsA("Texture") then c.Transparency = 1 end
                        end
                    end
                else
                    b.Color = dadosOriginais[b].Color
                    b.Material = dadosOriginais[b].Material
                    for _, child in pairs(b:GetChildren()) do
                        if child:IsA("SurfaceAppearance") then child.Enabled = true end
                    end
                end
            end)
        end
    end

    -- ESP Otimizado
    if cfg.esp and hrp then
        for _, b in pairs(balls) do
            local permitir = true
            if cfg.espTrainingOnly and b.Name ~= "TrainingBall" then permitir = false end

            if permitir then
                if b and b.Parent and not esps[b] then
                    pcall(function()
                        local bb = Instance.new("BillboardGui", LocalPlayer:WaitForChild("PlayerGui"))
                        bb.Adornee = b
                        bb.Size = UDim2.new(0, 60, 0, 35)
                        bb.StudsOffset = Vector3.new(0, 3, 0)
                        bb.AlwaysOnTop = true

                        local lbl = Instance.new("TextLabel", bb)
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextColor3 = Color3.fromRGB(0, 255, 255)
                        lbl.TextScaled = true
                        lbl.Font = Enum.Font.GothamBold

                        esps[b] = {gui = bb, text = lbl}
                    end)
                end
                if esps[b] and esps[b].text then
                    pcall(function()
                        esps[b].text.Text = math.floor((b.Position - hrp.Position).Magnitude) .. "m"
                    end)
                end
            else
                if esps[b] then
                    pcall(function() esps[b].gui:Destroy() end)
                    esps[b] = nil
                end
            end
        end
    else
        for _, o in pairs(esps) do pcall(function() o.gui:Destroy() end) end
        esps = {}
    end
end)

-- └── Notifications / Cleanup
AtualizarEsfera()
Rayfield:Notify({Title = "Smile 7 Hub", Content = "Interface atualizada e carregada com sucesso!", Duration = 5})
