
if not game:IsLoaded() then game.Loaded:Wait() end

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Safe Module Requires & Network Map
local EggCmds, Ragdoll, Network, NM, PlotCmds, GEP, GCP, RGSR, SPP, GuardsD, AreasD, SlotId
local Save, Constants, Bases, Treadmills, Trails
local PlotsNet, TreadmillsNet, TrailsNet
pcall(function() EggCmds = require(ReplicatedStorage.Library.Client.EggCmds) end)
pcall(function() Ragdoll = require(ReplicatedStorage.Library.Modules.Ragdoll) end)
pcall(function() Network = require(ReplicatedStorage.Library.Client.Network) end)
pcall(function() NM = (Network and Network.NET_MAP) or (Constants and Constants.NETWORK_MAP) end)
pcall(function() PlotCmds = require(ReplicatedStorage.Library.Client.PlotCmds) end)
pcall(function() GEP = require(ReplicatedStorage.Library.Modules.GuardAreas.GuardEscapePrediction) end)
pcall(function() GCP = require(ReplicatedStorage.Library.Modules.GuardAreas.GuardChasePolicy) end)
pcall(function() RGSR = require(ReplicatedStorage.Library.Functions.ResolveGuardSpeedRequirement) end)
pcall(function() SPP = require(ReplicatedStorage.Library.Client.SpeedPowerProjection) end)
pcall(function() GuardsD = require(ReplicatedStorage.Directory.Guards) end)
pcall(function() AreasD = require(ReplicatedStorage.Directory.Areas) end)
pcall(function() SlotId = require(ReplicatedStorage.Library.Util.AreaEggSlotIdentity) end)

pcall(function() Save = require(ReplicatedStorage.Library.Client.Save) end)
pcall(function() Constants = require(ReplicatedStorage.Library.Globals.Constants) end)
pcall(function() Bases = require(ReplicatedStorage.Directory.Bases) end)
pcall(function() Treadmills = require(ReplicatedStorage.Directory.Treadmills) end)
pcall(function() Trails = require(ReplicatedStorage.Directory.Trails) end)

pcall(function() PlotsNet = Constants and Constants.NETWORK_MAP and Constants.NETWORK_MAP.Plots end)
pcall(function() TreadmillsNet = Constants and Constants.NETWORK_MAP and Constants.NETWORK_MAP.Treadmills end)
pcall(function() TrailsNet = Constants and Constants.NETWORK_MAP and Constants.NETWORK_MAP.Trails end)

-- Initial Ragdoll Module Override
if Ragdoll then
    pcall(function()
        Ragdoll.Ragdoll = function() end
        Ragdoll.IsRagdolled = function() return false end
        Ragdoll.NpcRagdoll = function() end
    end)
end

ProximityPromptService.PromptShown:Connect(function(prompt)
    prompt.HoldDuration = 0
end)

-- Obsidian UI Setup
local Library
local libSuccess, libResult = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
end)
if libSuccess and libResult then
    Library = libResult
else
    warn("Failed to load UI Library")
    return
end

local Window = Library:CreateWindow({
    Title = "Anonymus Hub",
    Footer = "Steal an Egg",
    Center = true,
    AutoShow = true,
    ShowMobileButtons = true
})

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = game:GetService("HttpService"):GenerateGUID(false)
ScreenGui.ResetOnSpawn = false
local guiSuccess = pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not guiSuccess or not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 110, 0, 40)
ToggleButton.Position = UDim2.new(0.02, 0, 0.1, 0)
ToggleButton.Text = "Anonymus Hub"
ToggleButton.TextSize = 12
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.AutoButtonColor = false
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(40, 40, 40)
ToggleStroke.Thickness = 1.5
ToggleStroke.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Library:Toggle()
end)

-- Mobile Draggable Circles (Touch Fixed & Improved Visuals)
local mobileButtons = {}
local function makeFloatingCircle(name, startPos, callback, isToggle)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 48, 0, 48)
    btn.Position = startPos
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.RichText = true
    btn.Text = "<b>" .. name .. "</b>" .. (isToggle and '\n<font color="#ff4444" size="8">[OFF]</font>' or "")
    btn.Active = true
    btn.Parent = ScreenGui
    btn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2.5
    stroke.Color = Color3.fromRGB(100, 100, 120)
    stroke.Transparency = 0.2
    stroke.Parent = btn
    
    local dragging = false
    local dragStart, startPosVec
    local state = false
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosVec = btn.Position
            TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 44, 0, 44)}):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(
                startPosVec.X.Scale, startPosVec.X.Offset + delta.X,
                startPosVec.Y.Scale, startPosVec.Y.Offset + delta.Y
            )
        end
    end)
    
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 48, 0, 48)}):Play()
            if not dragging then return end
            dragging = false
            local delta = (input.Position - dragStart).Magnitude
            if delta < 10 then -- Tap detected
                if isToggle then
                    state = not state
                    stroke.Color = state and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(100, 100, 120)
                    btn.Text = "<b>" .. name .. "</b>\n" .. (state and '<font color="#44ff44" size="8">[ON]</font>' or '<font color="#ff4444" size="8">[OFF]</font>')
                    callback(state)
                else
                    stroke.Color = Color3.fromRGB(200, 200, 255)
                    task.delay(0.2, function() pcall(function() stroke.Color = Color3.fromRGB(100, 100, 120) end) end)
                    callback()
                end
            end
        end
    end)
    table.insert(mobileButtons, btn)
    return btn
end

local MainTab = Window:AddTab({ Name = "Main" })
local AutomationTab = Window:AddTab({ Name = "Automation" })
local UpgradesTab = Window:AddTab({ Name = "Upgrades" })
local MiscTab = Window:AddTab({ Name = "Misc" })

-- State Variables
local antiRagdollEnabled = false
local tpWalkEnabled = false
local tpWalkSpeedValue = 500
local eggEspEnabled = false
local espFilterTargets = { ["All"] = true }
local espRenderDistance = 1000
local autoFarmEnabled = false
local autoFarmTargets = {}
local autoFarmSpeedValue = 650
local autoFarmOriginalPos = nil
local autoHatchEnabled = false
local autoEquipBestEnabled = false
local autoClaimEnabled = false
local fullbrightEnabled = false
local flyEnabled = false
local flySpeedValue = 500
local maxZoomEnabled = false
local timeFreezeEnabled = false
local antiLagEnabled = false
local antiAfkEnabled = false
local fov120Enabled = false
local activeTween = nil
local idledConnection = nil

local autoPenEnabled = true
local autoTreadmillEnabled = true
local autoRunEnabled = true
local autoBuyTrailsEnabled = true
local antiTrapEnabled = true

local cachedEggs = {}
local droppedEggMemory = {}
local lastHeldEgg = nil

local function isCarryingEgg(char)
    if not char then return false end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("Tool") then
            local lName = string.lower(obj.Name)
            if lName:find("egg") or lName:find("swan") or lName:find("pet") or obj:FindFirstChild("SmartPromptPart") or obj:FindFirstChildWhichIsA("ProximityPrompt") then
                return true
            end
        end
    end
    return false
end

-- Character Egg Holding Tracker (ensures dropped eggs remember real name & size)
task.spawn(function()
    while true do
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, obj in ipairs(char:GetChildren()) do
                    if obj:IsA("Model") or obj:IsA("Tool") then
                        local lName = string.lower(obj.Name)
                        if lName:find("egg") or lName:find("swan") or lName:find("pet") or obj:FindFirstChild("SmartPromptPart") or obj:FindFirstChildWhichIsA("ProximityPrompt") then
                            local size = obj:IsA("Model") and obj:GetExtentsSize() or Vector3.new(2.5, 3.5, 2.5)
                            for _, p in ipairs(obj:GetDescendants()) do
                                if p:IsA("BasePart") and p.Size.Magnitude > size.Magnitude then
                                    size = p.Size
                                end
                            end
                            local petName = obj.Name
                            if petName == "Model" or petName == "Tool" or petName == "Egg" or petName == "SmartPromptPart" then
                                local root = char:FindFirstChild("HumanoidRootPart")
                                if root then
                                    local zName = "Forest"
                                    local wx = root.Position.X
                                    if wx >= 647 and wx < 792 then zName = "Lake"
                                    elseif wx >= 792 and wx < 1004 then zName = "Desert"
                                    elseif wx >= 1004 and wx < 1240 then zName = "Jungle"
                                    elseif wx >= 1240 and wx < 1565 then zName = "Snow"
                                    elseif wx >= 1565 and wx < 1950 then zName = "Volcano"
                                    elseif wx >= 1950 and wx < 2380 then zName = "Abyss Ocean"
                                    elseif wx >= 2380 and wx < 2885 then zName = "Prehistoric"
                                    elseif wx >= 2885 and wx < 3527 then zName = "Cosmic"
                                    elseif wx >= 3527 and wx < 4400 then zName = "Cherry Blossom"
                                    elseif wx >= 4400 then zName = "Titan Temple"
                                    end
                                    petName = zName .. " Egg"
                                end
                            end
                            lastHeldEgg = {
                                name = petName,
                                size = size,
                                area = "Carried",
                                time = os.clock()
                            }
                        end
                    end
                end
            end
        end)
        task.wait(0.4)
    end
end)

local utility = {
    RunService = game:GetService("RunService"),
    Players = game:GetService("Players")
}

utility.collectgarbage = function()
    local s, r = pcall(function()
        return getgc(true)
    end)
    if s and r then
        return r    
    end
    return warn("failed to get garbage: "..tostring(r))
end

utility.safehook = function(f, c)
    local s, r = pcall(function()
        return hookfunction(f, newcclosure(c))
    end)
    if s and r then
        return r    
    end
    return warn("failed to function hook: "..tostring(r))
end

function utility:initbypass()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then return end

    if not getgc or not hookfunction or not islclosure then
        if Library and Library.Notify then
            Library:Notify({ Title = "Bypass v2", Content = "Unsupported Executor: Missing getgc/hookfunction/islclosure", Duration = 5 })
        end
        return warn("UNSUPPORTED EXECUTOR: MISSING REQUIRED FUNCTIONS")
    end

    local hooked = false
    -- Hook ContentCatalog checks to let them execute fully while sanitizing failure flags
    for _, f in next, self.collectgarbage() do
        if typeof(f) == 'function' and islclosure(f) then
            local success, source = pcall(debug.info, f, "s")
            if success and source and source:find("ContentCatalog") then
                local oldFunc
                oldFunc = self.safehook(f, function(...)
                    local results = {oldFunc(...)}
                    for i, v in ipairs(results) do
                        if v == false or (typeof(v) == "string" and (v:lower():match("flag") or v:lower():match("detect"))) then
                            results[i] = true
                        end
                    end
                    return unpack(results)
                end)
                hooked = true
            end
        end
    end
    
    if Library and Library.Notify then
        Library:Notify({ Title = "Bypass v2", Content = hooked and "Successfully hooked ContentCatalog flags." or "Failed to find hooks.", Duration = 3 })
    end
end

-- Anti-Cheat Bypass
local function bypassAntiCheatFunc()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local clone = humanoid:Clone()
            clone.Parent = character
            humanoid:Destroy()
            task.wait(0.1)
            if character:FindFirstChild("HumanoidRootPart") then
                workspace.CurrentCamera.CameraSubject = character:FindFirstChildOfClass("Humanoid") or character.HumanoidRootPart
            end
        end
    end
end

local function goToMainStandFunc()
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not rootPart then return end
    if activeTween then activeTween:Cancel() end
    
    local targetCFrame = CFrame.new(544.577637, 92.0762939, -364.869049, -1, 0, 0, 0, 1, 0, 0, 0, -1)
    local dist = (rootPart.Position - targetCFrame.Position).Magnitude
    local travelTime = math.max(dist / 350, 0.1)
    
    activeTween = TweenService:Create(rootPart, TweenInfo.new(travelTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = targetCFrame})
    activeTween.Completed:Connect(function() 
        if hum then 
            pcall(function() 
                hum:ChangeState(Enum.HumanoidStateType.Landed) 
                hum.PlatformStand = false 
            end) 
        end
    end)
    activeTween:Play()
end

-- Create Mobile Circles
makeFloatingCircle("Fly", UDim2.new(0.02, 0, 0.33, 0), function(v) flyEnabled = v end, true)
makeFloatingCircle("TP Walk", UDim2.new(0.02, 0, 0.46, 0), function(v) tpWalkEnabled = v end, true)
makeFloatingCircle("Ragdoll", UDim2.new(0.02, 0, 0.59, 0), function(v) antiRagdollEnabled = v end, true)
makeFloatingCircle("ESP", UDim2.new(0.02, 0, 0.72, 0), function(v) eggEspEnabled = v end, true)


-- Main Tab
local MainGroup = MainTab:AddLeftGroupbox("Main Features")
local selectedBypass = "Bypass v1"
MainGroup:AddDropdown("BypassDropdown", {
    Text = "Select Bypass Version",
    Default = 1,
    Values = {"Bypass v1", "Bypass v2"},
    Callback = function(v) selectedBypass = v end
})
MainGroup:AddButton({ Text = "Execute Bypass", Func = function()
    if selectedBypass == "Bypass v1" then
        bypassAntiCheatFunc()
    elseif selectedBypass == "Bypass v2" then
        utility:initbypass()
    end
end })

MainGroup:AddButton({ Text = "Respawn Character", Func = function()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.Health = 0 end
    end
end })

local MoveGroup = MainTab:AddLeftGroupbox("Teleports")
MoveGroup:AddButton({ Text = "Go To Main Stand", Func = goToMainStandFunc })
MoveGroup:AddButton({ Text = "Stop Movement", Func = function()
    if activeTween then
        activeTween:Cancel()
        activeTween = nil
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end })

local TPGroup = MainTab:AddRightGroupbox("Movement Modifiers")
TPGroup:AddToggle("AntiRagdoll", { Text = "Anti-Ragdoll", Default = false, Callback = function(v) antiRagdollEnabled = v end })
TPGroup:AddToggle("TPWalk", { Text = "TP Walk", Default = false, Callback = function(v) tpWalkEnabled = v end })
TPGroup:AddSlider("TPSpeed", { Text = "TP Walk Speed", Default = 500, Min = 1, Max = 1000, Rounding = 0, Callback = function(v) tpWalkSpeedValue = v end })


-- Automation Tab
local AutoGroup = AutomationTab:AddLeftGroupbox("Egg ESP")
AutoGroup:AddToggle("EggESP", { Text = "Egg ESP", Default = false, Callback = function(v) eggEspEnabled = v end })
AutoGroup:AddDropdown("EspFilter", { Text = "ESP Filter", Default = 1, Multi = true, Values = {"All", "Forest", "Lake", "Desert", "Jungle", "Snow", "Volcano", "Abyss Ocean", "Prehistoric", "Cosmic", "Cherry Blossom", "Titan Temple", "Dropped"}, Callback = function(v) espFilterTargets = type(v) == "table" and v or { [v] = true } end })
AutoGroup:AddSlider("EspDistance", { Text = "ESP Render Distance", Default = 1000, Min = 100, Max = 5000, Rounding = 0, Callback = function(v) espRenderDistance = v end })

local FarmGroup = AutomationTab:AddLeftGroupbox("Auto Farm")
FarmGroup:AddToggle("AutoFarmToggle", { Text = "Auto Farm", Default = false, Callback = function(v) 
    autoFarmEnabled = v 
    if v then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            autoFarmOriginalPos = char.HumanoidRootPart.Position
        end
    end
end })
FarmGroup:AddDropdown("AutoFarmAreas", { Text = "Farm Areas", Default = 1, Multi = true, Values = {"Forest", "Lake", "Desert", "Jungle", "Snow", "Volcano", "Abyss Ocean", "Prehistoric", "Cosmic", "Cherry Blossom", "Titan Temple"}, Callback = function(v) autoFarmTargets = type(v) == "table" and v or { [v] = true } end })
FarmGroup:AddSlider("AutoFarmSpeed", { Text = "Auto Farm Speed", Default = 650, Min = 1, Max = 650, Rounding = 0, Callback = function(v) autoFarmSpeedValue = v end })

local RewardsGroup = AutomationTab:AddRightGroupbox("Auto Rewards")
RewardsGroup:AddToggle("AutoHatch", { Text = "Auto Hatch", Default = false, Callback = function(v) autoHatchEnabled = v end })
RewardsGroup:AddToggle("AutoEquip", { Text = "Auto Equip Best", Default = false, Callback = function(v) autoEquipBestEnabled = v end })
RewardsGroup:AddToggle("AutoClaim", { Text = "Auto Claim", Default = false, Callback = function(v) autoClaimEnabled = v end })
RewardsGroup:AddButton({ Text = "Sell Inventory Now", Func = function()
    task.spawn(function()
        pcall(function()
            local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
            if net then
                if net:FindFirstChild("RE/PetSatchel/SellEveryPet") then
                    net["RE/PetSatchel/SellEveryPet"]:FireServer()
                end
                if net:FindFirstChild("RF/Haul/OfferFullSatchelSale") then
                    net["RF/Haul/OfferFullSatchelSale"]:InvokeServer()
                end
            end
            Library:Notify({ Title = "Pets", Content = "Sold every pet in inventory." })
        end)
    end)
end })

-- Upgrades Tab
local UpgradesGroup = UpgradesTab:AddLeftGroupbox("Auto Upgrades")
UpgradesGroup:AddToggle("AutoPen", { Text = "Auto Upgrade Pen", Default = true, Callback = function(v) autoPenEnabled = v end })
UpgradesGroup:AddToggle("AutoTreadmill", { Text = "Auto Upgrade Treadmill", Default = true, Callback = function(v) autoTreadmillEnabled = v end })
UpgradesGroup:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = true, Callback = function(v) autoBuyTrailsEnabled = v end })

local RunGroup = UpgradesTab:AddRightGroupbox("Movement")
RunGroup:AddToggle("AutoRun", { Text = "Auto Run Treadmill", Default = true, Callback = function(v) autoRunEnabled = v end })


-- Misc Tab
local VisualsGroup = MiscTab:AddLeftGroupbox("Visuals & Render")
VisualsGroup:AddToggle("Fullbright", { Text = "Fullbright", Default = false, Callback = function(v) 
    fullbrightEnabled = v 
    Lighting.Brightness = fullbrightEnabled and 3 or 1
    Lighting.ClockTime = fullbrightEnabled and 14 or 14
    Lighting.GlobalShadows = not fullbrightEnabled
end })
VisualsGroup:AddToggle("MaxZoom", { Text = "Max Zoom Distance", Default = false, Callback = function(v) 
    maxZoomEnabled = v 
    LocalPlayer.CameraMaxZoomDistance = maxZoomEnabled and 9999 or 400
end })
VisualsGroup:AddToggle("TimeFreeze", { Text = "Time Freeze (Noon)", Default = false, Callback = function(v) timeFreezeEnabled = v end })
VisualsGroup:AddToggle("AntiLag", { Text = "Anti-Lag", Default = false, Callback = function(v) 
    antiLagEnabled = v 
    pcall(function()
        if antiLagEnabled then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 999999
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                elseif obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                end
            end
        else
            Lighting.GlobalShadows = true
            Lighting.FogEnd = 100000
        end
    end)
end })
VisualsGroup:AddToggle("FOV120", { Text = "120 FOV", Default = false, Callback = function(v) 
    fov120Enabled = v 
    if not fov120Enabled then
        local cam = Workspace.CurrentCamera
        if cam then cam.FieldOfView = 70 end
    end
end })

local UtilsGroup = MiscTab:AddRightGroupbox("Utilities")
UtilsGroup:AddToggle("ShowMobileToggles", { Text = "Show Mobile Toggles", Default = true, Callback = function(v) 
    for _, btn in ipairs(mobileButtons) do
        if btn then btn.Visible = v end
    end
end })
UtilsGroup:AddToggle("AntiTrap", { Text = "Anti-Trap", Default = true, Callback = function(v) antiTrapEnabled = v end })
UtilsGroup:AddToggle("NormalFly", { Text = "Normal Fly", Default = false, Callback = function(v) flyEnabled = v end })
UtilsGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 500, Min = 1, Max = 1000, Rounding = 0, Callback = function(v) flySpeedValue = v end })
UtilsGroup:AddToggle("AntiAFK", { Text = "Anti-AFK", Default = false, Callback = function(v) 
    antiAfkEnabled = v 
    if antiAfkEnabled then
        if getconnections then
            for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
                conn:Disable()
            end
        else
            if not idledConnection then
                idledConnection = LocalPlayer.Idled:Connect(function()
                    pcall(function()
                        local vu = game:GetService("VirtualUser")
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.new())
                    end)
                end)
            end
        end
    else
        if getconnections then
            for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
                conn:Enable()
            end
        end
        if idledConnection then
            idledConnection:Disconnect()
            idledConnection = nil
        end
    end
end })

UtilsGroup:AddButton({ Text = "Unload Script", Func = function()
    -- Disable all automated states
    eggEspEnabled = false
    autoHatchEnabled = false
    autoEquipBestEnabled = false
    autoClaimEnabled = false
    autoRunEnabled = false
    antiTrapEnabled = false
    autoBuyTrailsEnabled = false
    autoPenEnabled = false
    autoTreadmillEnabled = false
    flyEnabled = false
    tpWalkEnabled = false
    antiRagdollEnabled = false
    
    if activeTween then pcall(function() activeTween:Cancel() activeTween = nil end) end
    if ScreenGui then pcall(function() ScreenGui:Destroy() end) end
    if Library then pcall(function() Library:Unload() end) end
end })

-- ============= VISUAL PETS & VOID FUNCTIONS =============
-- Core Logic Below
local EXIT_DIR = Vector3.new(-1,0,0)
local AREA = {}
pcall(function()
    EXIT_DIR = -Workspace.__OBJECTS.Areas.SeparationLine.CFrame.LookVector
end)
local folder = Workspace:FindFirstChild("__OBJECTS")
folder = folder and folder:FindFirstChild("Areas")
folder = folder and folder:FindFirstChild("GuardAreas")
if folder and GuardsD and AreasD and GCP then
    for _, a in ipairs(folder:GetChildren()) do
        pcall(function()
            local d = GuardsD.Directory[AreasD.Directory[a.Name].GuardId]
            local rec = {
                cf = a.Bounds.CFrame,
                size = a.Bounds.Size,
                guardPos = a.Guard:GetPivot().Position,
                speed = d.WalkSpeed,
                radius = d.FlatRadius,
                hit = GCP.ResolveHitDistance(d.HitDistance),
                reqSP = nil,
            }
            if GEP and RGSR then
                pcall(function()
                    local exitPos = a.ClosestExitPoint.Position
                    rec.reqSP = RGSR({
                        BaseGuardWalkSpeed = rec.speed,
                        ExitDirection = EXIT_DIR,
                        ExitDistance = GEP.ResolveExitDistance(rec.cf, rec.size, exitPos, EXIT_DIR),
                        FlatRadius = rec.radius,
                        GuardStartPosition = rec.guardPos,
                        HitDistance = rec.hit,
                        PlayerStartPosition = exitPos,
                    })
                end)
            end
            AREA[a.Name] = rec
        end)
    end
end

-- ------------------------------------------------------------------------------
-- AREA ZONES & LOOT INFO (Egg ESP v4)
-- ------------------------------------------------------------------------------
local MAX_DISTANCE = 200
local AREA_ZONES = {
    { minX = 553,  maxX = 647,  name = "Forest"          },
    { minX = 647,  maxX = 792,  name = "Lake"            },
    { minX = 792,  maxX = 1004, name = "Desert"          },
    { minX = 1004, maxX = 1240, name = "Jungle"          },
    { minX = 1240, maxX = 1565, name = "Snow"            },
    { minX = 1565, maxX = 1950, name = "Volcano"         },
    { minX = 1950, maxX = 2380, name = "Abyss Ocean"     },
    { minX = 2380, maxX = 2885, name = "Prehistoric"     },
    { minX = 2885, maxX = 3527, name = "Cosmic"          },
    { minX = 3527, maxX = 4200, name = "Cherry Blossom"  },
    { minX = 4200, maxX = 999999, name = "Titan Temple"    },
}

local LOOT_INFO = {
    ["Forest"]         = { rarity = "Common",    rarityColor = Color3.fromRGB(180, 180, 180), areaColor = Color3.fromRGB(80, 200, 80) },
    ["Lake"]           = { rarity = "Uncommon",  rarityColor = Color3.fromRGB(0, 255, 0),     areaColor = Color3.fromRGB(80, 160, 255) },
    ["Desert"]         = { rarity = "Rare",      rarityColor = Color3.fromRGB(25, 144, 255),  areaColor = Color3.fromRGB(240, 190, 60) },
    ["Jungle"]         = { rarity = "Epic",      rarityColor = Color3.fromRGB(196, 2, 255),   areaColor = Color3.fromRGB(50, 180, 50) },
    ["Snow"]           = { rarity = "Legendary", rarityColor = Color3.fromRGB(255, 133, 34),  areaColor = Color3.fromRGB(180, 230, 255) },
    ["Volcano"]        = { rarity = "Mythic",    rarityColor = Color3.fromRGB(255, 43, 100),  areaColor = Color3.fromRGB(255, 90, 30) },
    ["Abyss Ocean"]    = { rarity = "Cosmic",    rarityColor = Color3.fromRGB(65, 0, 170),    areaColor = Color3.fromRGB(30, 80, 200) },
    ["Prehistoric"]    = { rarity = "Secret",    rarityColor = Color3.fromRGB(46, 46, 46),    areaColor = Color3.fromRGB(180, 130, 60) },
    ["Cosmic"]         = { rarity = "Eternal",   rarityColor = Color3.fromRGB(255, 30, 240),  areaColor = Color3.fromRGB(160, 80, 255) },
    ["Cherry Blossom"] = { rarity = "Divine",    rarityColor = Color3.fromRGB(251, 255, 0),  areaColor = Color3.fromRGB(255, 160, 200) },
    ["Titan Temple"]   = { rarity = "Titan",     rarityColor = Color3.fromRGB(255, 215, 0),  areaColor = Color3.fromRGB(255, 170, 0) },
}

local function getAreaName(worldX)
    for _, zone in ipairs(AREA_ZONES) do
        if worldX >= zone.minX and worldX < zone.maxX then
            return zone.name
        end
    end
    return "Forest"
end

local function getLootInfo(areaName)
    return LOOT_INFO[areaName] or LOOT_INFO["Forest"]
end

task.spawn(function()
    while true do
        local eggs = {}
        
        -- NEW METHOD: AreaEggSlotsClient (Fixes Auto Farm)
        local container = Workspace:FindFirstChild("AreaEggSlotsClient")
        if container then
            for _, slot in ipairs(container:GetChildren()) do
                if slot:IsA("Model") then
                    local hitbox = slot:FindFirstChild("Hitbox") or slot:FindFirstChildWhichIsA("BasePart")
                    if hitbox then
                        local uid = slot.Name
                        local areaName = getAreaName(hitbox.Position.X)
                        if slot.Name:find("FirstAreaEgg") then
                            local slotArea = slot.Name:match("_([A-Za-z ]+):Slot")
                            if slotArea then areaName = slotArea end
                        end
                        
                        local petName = areaName .. " Egg"
                        for _, child in ipairs(slot:GetChildren()) do
                            if child:IsA("Model") then
                                local lowerName = string.lower(child.Name)
                                if lowerName ~= "hitbox" and lowerName ~= "nest" and lowerName ~= "egg" then
                                    petName = child.Name
                                    if not string.find(lowerName, string.lower(areaName)) then
                                        break
                                    end
                                end
                            end
                        end
                        
                        eggs[#eggs+1] = {
                            uid = uid, cf = hitbox.CFrame, pos = hitbox.Position, size = hitbox.Size,
                            area = areaName, cat = petName, nest = slot, isPhysical = false
                        }
                    end
                end
            end
        end
        
        -- FALLBACK FOR ANY LINGERING RECORDS
        pcall(function()
            local snap = EggCmds and EggCmds.GetAreaEggSnapshot and EggCmds.GetAreaEggSnapshot()
            if snap and snap.Records then
                for _, r in ipairs(snap.Records) do
                    if r.State ~= "Equipped" and r.State ~= "Hatched" and r.State ~= "Claimed" and r.State ~= "Incubating" then
                        local ePos = r.CFrame and r.CFrame.Position or (r.BoundsCFrame and r.BoundsCFrame.Position)
                        if ePos then
                            local isDupe = false
                            for _, e in ipairs(eggs) do
                                if (e.pos - ePos).Magnitude < 3 then isDupe = true break end
                            end
                            if not isDupe then
                                eggs[#eggs+1] = {
                                    uid = r.Uid, cf = r.CFrame or r.BoundsCFrame, pos = ePos, size = r.Size or r.BoundsSize,
                                    area = r.AreaId, cat = r.AssetCategory, nest = r.NestId, isPhysical = false
                                }
                            end
                        end
                    end
                end
            end
        end)
        
        pcall(function()
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                    local action = string.lower(prompt.ActionText)
                    local objTxt = string.lower(prompt.ObjectText)
                    local parentName = string.lower(prompt.Parent and prompt.Parent.Name or "")
                    
                    if action:find("grab") or action:find("steal") or action:find("take") or action:find("pick") or action:find("collect") or objTxt:find("egg") or parentName:find("egg") or parentName:find("drop") then
                        local part = prompt.Parent
                        if part and part:IsA("BasePart") then
                            local isDupe = false
                            for _, e in ipairs(eggs) do
                                if (e.pos - part.Position).Magnitude < 3 then
                                    isDupe = true
                                    break
                                end
                            end
                            
                            if not isDupe then
                                local promptId = tostring(prompt:GetDebugId())
                                
                                local function isValidPetName(n)
                                    if not n then return false end
                                    local ln = string.lower(n)
                                    if ln == "egg" or ln == "part" or ln == "meshpart" or ln == "smartpromptpart" or ln == "model" or ln == "workspace" or ln == "hitbox" then return false end
                                    -- Ignore UUIDs (long hex strings with dashes)
                                    if #n > 20 and n:match("%-") and n:match("%w") then return false end
                                    return true
                                end
                                
                                -- 2. RESOLVE REAL NAME (Prevent resetting to "SmartPromptPart" or generic "Egg")
                                local petName = nil
                                
                                -- A: Memory cache from previous detection
                                if droppedEggMemory[promptId] then
                                    petName = droppedEggMemory[promptId].name
                                end
                                
                                -- B: If I just dropped it recently, grab it from lastHeldEgg
                                if not petName or not isValidPetName(petName) then
                                    if lastHeldEgg and (os.clock() - lastHeldEgg.time) < 1.0 then
                                        local dist = (lastHeldEgg.size.Magnitude - part.Size.Magnitude)
                                        if math.abs(dist) < 5 then
                                            petName = lastHeldEgg.name
                                        end
                                    end
                                end
                                
                                -- C: Hierarchy / Billboard fallback
                                if not petName or not isValidPetName(petName) then
                                    if prompt.ObjectText and isValidPetName(prompt.ObjectText) then
                                        petName = prompt.ObjectText
                                    elseif part.Parent and part.Parent:IsA("Model") and isValidPetName(part.Parent.Name) then
                                        petName = part.Parent.Name
                                    elseif isValidPetName(part.Name) then
                                        petName = part.Name
                                    else
                                        local bb = part:FindFirstChildOfClass("BillboardGui") or (part.Parent and part.Parent:FindFirstChildOfClass("BillboardGui"))
                                        if bb then
                                            local tl = bb:FindFirstChildOfClass("TextLabel")
                                            if tl and tl.Text ~= "" and isValidPetName(tl.Text) then petName = tl.Text end
                                        end
                                        if not petName or not isValidPetName(petName) then
                                            if part.Parent and part.Parent.Parent and isValidPetName(part.Parent.Parent.Name) then
                                                petName = part.Parent.Parent.Name
                                            end
                                        end
                                    end
                                end
                                
                                if not petName or not isValidPetName(petName) then petName = "Egg" end
                                
                                -- Save to memory so it doesn't get lost
                                droppedEggMemory[promptId] = { name = petName, size = part.Size }
                                
                                eggs[#eggs+1] = {
                                    uid = "Phys_" .. promptId,
                                    cf = part.CFrame,
                                    pos = part.Position,
                                    size = part.Size,
                                    area = "Dropped",
                                    cat = petName,
                                    nest = nil,
                                    part = part,
                                    isPhysical = true,
                                    prompt = prompt
                                }
                            end
                        end
                    end
                end
            end
        end)
        
        cachedEggs = eggs
        task.wait(0.35)
    end
end)

local curSP = 0
task.spawn(function()
    while true do
        if SPP then
            pcall(function() curSP = SPP.GetSpeedPower() or curSP end)
        end
        task.wait(1)
    end
end)

local function areaUnlocked(areaId)
    local A = AREA[areaId]
    if not A or not A.reqSP then return true end
    return curSP >= A.reqSP
end

local function shortNum(n)
    if not n then return "?" end
    local a = math.abs(n)
    if a >= 1e12 then return string.format("%.1fT", n/1e12) end
    if a >= 1e9  then return string.format("%.1fB", n/1e9)  end
    if a >= 1e6  then return string.format("%.1fM", n/1e6)  end
    if a >= 1e3  then return string.format("%.1fK", n/1e3)  end
    return string.format("%d", n)
end

-- ------------------------------------------------------------------------------
-- DRAWING POOL & HIGHLIGHT MANAGER
-- ------------------------------------------------------------------------------
local drawingSupported = (typeof(Drawing) ~= "nil" and type(Drawing.new) == "function")
local eggDrawings = {}
local eggHighlights = {}

local function createTextLabel()
    if not drawingSupported then return nil end
    local text = Drawing.new("Text")
    text.Font = Drawing.Fonts.UI
    text.Outline = true
    text.Center = true
    text.Visible = false
    return text
end

local function getOrCreate(uid)
    if eggDrawings[uid] then return eggDrawings[uid] end

    local set = {}
    set.name   = createTextLabel()
    set.dist   = createTextLabel()
    set.rarity = createTextLabel()

    eggDrawings[uid] = set
    return set
end

local function getOrCreateHighlight(uid, adornee, color)
    if eggHighlights[uid] then
        eggHighlights[uid].Adornee = adornee
        eggHighlights[uid].OutlineColor = color
        eggHighlights[uid].FillColor = color
        eggHighlights[uid].Enabled = true
        return eggHighlights[uid]
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "EggESPOutline"
    highlight.Adornee = adornee
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.85
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = color
    highlight.FillColor = color
    highlight.Parent = adornee

    eggHighlights[uid] = highlight
    return highlight
end

local function hideSet(uid)
    local set = eggDrawings[uid]
    if set then
        if set.name then set.name.Visible   = false end
        if set.dist then set.dist.Visible   = false end
        if set.rarity then set.rarity.Visible = false end
    end

    if eggHighlights[uid] then
        eggHighlights[uid].Enabled = false
    end
end

local normalFlyGyro, normalFlyVel = nil, nil

task.spawn(function()
    while task.wait(0.2) do
        if antiRagdollEnabled then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                    local st = hum:GetState()
                    if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.Ragdoll then
                        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                    end
                    if not flyEnabled then
                        hum.PlatformStand = false
                    end
                end
                
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("BodyPosition") or v:IsA("LinearVelocity") or v:IsA("VectorForce") or v:IsA("BodyThrust") then
                        if v.Name ~= "CustomFlyVel" and v.Name ~= "CustomFlyGyro" and v.Name ~= "CustomAntiGrav" then
                            pcall(function() v:Destroy() end)
                        end
                    elseif v:IsA("Constraint") and v:GetAttribute("RagdollConstraint") then
                        pcall(function() v:Destroy() end)
                    elseif v:IsA("Attachment") and v:GetAttribute("RagdollAttachment") then
                        pcall(function() v:Destroy() end)
                    elseif v:IsA("Motor6D") and not v.Enabled then
                        v.Enabled = true
                    end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        
        if timeFreezeEnabled then
            Lighting.ClockTime = 12
        end

        if fov120Enabled then
            local cam = Workspace.CurrentCamera
            if cam then cam.FieldOfView = 120 end
        end

        if tpWalkEnabled and hum and rootPart then
            if hum.MoveDirection.Magnitude > 0 then
                local velocityVector = hum.MoveDirection * math.clamp(tpWalkSpeedValue, 1, 1000)
                rootPart.AssemblyLinearVelocity = Vector3.new(velocityVector.X, rootPart.AssemblyLinearVelocity.Y, velocityVector.Z)
            else
                rootPart.AssemblyLinearVelocity = Vector3.new(0, rootPart.AssemblyLinearVelocity.Y, 0)
            end
        end

        if flyEnabled and rootPart then
            if not normalFlyGyro or not normalFlyGyro.Parent then
                normalFlyGyro = Instance.new("BodyGyro")
                normalFlyGyro.Name = "CustomFlyGyro"
                normalFlyGyro.P = 9e4
                normalFlyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
                normalFlyGyro.Parent = rootPart
            end
            if not normalFlyVel or not normalFlyVel.Parent then
                normalFlyVel = Instance.new("BodyVelocity")
                normalFlyVel.Name = "CustomFlyVel"
                normalFlyVel.Velocity = Vector3.zero
                normalFlyVel.MaxForce = Vector3.new(9e4, 9e4, 9e4)
                normalFlyVel.Parent = rootPart
            end
            
            local cam = Workspace.CurrentCamera
            local moveDir = Vector3.zero
            local isTyping = UserInputService:GetFocusedTextBox() ~= nil
            
            if not isTyping then
                pcall(function()
                    local pm = require(LocalPlayer.PlayerScripts.PlayerModule)
                    local moveVector = pm:GetControls():GetMoveVector()
                    if moveVector.Magnitude > 0 then
                        moveDir = (cam.CFrame.RightVector * moveVector.X) - (cam.CFrame.LookVector * moveVector.Z)
                    end
                end)
                
                if moveDir == Vector3.zero then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                end
            end
            
            normalFlyGyro.CFrame = cam.CFrame
            normalFlyVel.Velocity = moveDir * math.clamp(flySpeedValue, 1, 1000)
            if hum then hum.PlatformStand = true end
        else
            if normalFlyGyro then normalFlyGyro:Destroy(); normalFlyGyro = nil end
            if normalFlyVel then normalFlyVel:Destroy(); normalFlyVel = nil end
            if not flyEnabled and hum and hum.PlatformStand and not antiRagdollEnabled then
                hum.PlatformStand = false
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Landed) end)
            end
        end
    end

    if eggEspEnabled then
        local cam = Workspace.CurrentCamera
        if cam then
            local camPos = cam.CFrame.Position
            local seen = {}

            for _, eggData in ipairs(cachedEggs) do
                if not espFilterTargets["All"] and not espFilterTargets[eggData.area] then
                    continue
                end
                
                local worldPos = eggData.pos
                local dist = (camPos - worldPos).Magnitude

                if dist > espRenderDistance then
                    continue
                end

                local screenPos, onScreen = cam:WorldToViewportPoint(worldPos)
                if not onScreen then continue end
                
                local uid = eggData.uid
                seen[uid] = true

                local adornee = eggData.nest or eggData.part
                
                local areaColor, rarityColor, rarityText
                local predictedPet = eggData.cat
                local sz = eggData.size or Vector3.zero
                local szMag = math.max(sz.X, sz.Y, sz.Z)
                local sizeStr = "Size: " .. string.format("%.1f", szMag)

                if not eggData.isPhysical then
                    local loot = getLootInfo(eggData.area)
                    areaColor = loot and loot.areaColor or Color3.fromRGB(255, 220, 60)
                    rarityColor = loot and loot.rarityColor or Color3.fromRGB(200, 200, 200)
                    rarityText = loot and loot.rarity or "Unknown"
                else
                    areaColor = Color3.fromRGB(255, 100, 100)
                    rarityColor = Color3.fromRGB(255, 255, 255)
                    rarityText = "Dropped"
                end
                
                local set = getOrCreate(uid)
                if adornee then getOrCreateHighlight(uid, adornee, areaColor) end

                if set.name then
                    local scale = math.clamp(1 - (dist / espRenderDistance), 0.5, 1)
                    local titleSize = math.floor(28 * scale)
                    local detailSize = math.floor(20 * scale)
                    local spacing = math.floor(24 * scale)

                    local centerX = screenPos.X
                    local topY = screenPos.Y - (40 * scale)

                    set.rarity.Text = "[" .. rarityText .. "]"
                    set.rarity.Size = detailSize
                    set.rarity.Color = rarityColor
                    set.rarity.Position = Vector2.new(centerX, topY - spacing)
                    set.rarity.Visible = true

                    set.name.Text = predictedPet
                    set.name.Size = titleSize
                    set.name.Color = areaColor
                    set.name.Position = Vector2.new(centerX, topY)
                    set.name.Visible = true

                    set.dist.Text = string.format("%.0f studs | %s", dist, sizeStr)
                    set.dist.Size = detailSize
                    set.dist.Color = Color3.fromRGB(220, 220, 220)
                    set.dist.Position = Vector2.new(centerX, topY + spacing)
                    set.dist.Visible = true
                end
            end
            
            for uid, _ in pairs(eggDrawings) do
                if not seen[uid] then 
                    hideSet(uid) 
                end
            end
        end
    else
        for uid, _ in pairs(eggDrawings) do
            hideSet(uid) 
        end
    end
end)

-- Reliable Auto Rewards Loop
task.spawn(function()
    local lastHatch, lastEquip, lastClaim = 0, 0, 0
    while task.wait(1) do
        local now = os.clock()
        local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
        
        if autoHatchEnabled and (now - lastHatch) >= 2 then
            lastHatch = now
            
            -- Fallback 1: Direct UI Button Clicking (Bypasses all remote protections)
            pcall(function()
                if getconnections then
                    for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                        if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
                            local text = gui:IsA("TextButton") and gui.Text or ""
                            if text == "" then
                                local tl = gui:FindFirstChildOfClass("TextLabel")
                                if tl then text = tl.Text end
                            end
                            if text == "Open" or text == "Grow All" then
                                for _, conn in pairs(getconnections(gui.MouseButton1Click)) do
                                    conn:Fire()
                                end
                            end
                        end
                    end
                end
            end)

            -- Method 2: Modern Packages.Networking (Removed Growth Checks)
            pcall(function()
                if net and net:FindFirstChild("RF/EggWorld/AskLiveSnapshot") then
                    local snap = net["RF/EggWorld/AskLiveSnapshot"]:InvokeServer()
                    if type(snap) == "table" then
                        for _, plot in pairs(snap) do
                            if plot.OwnerUserId == LocalPlayer.UserId then
                                for uid, egg in pairs(plot.Records or {}) do
                                    if egg.Placement then
                                        task.spawn(function()
                                            if net:FindFirstChild("RF/EggWorld/AskHatch") then
                                                local ok = net["RF/EggWorld/AskHatch"]:InvokeServer(uid)
                                                if ok and net:FindFirstChild("RF/EggWorld/AskFinishHatch") then
                                                    task.wait(0.2)
                                                    net["RF/EggWorld/AskFinishHatch"]:InvokeServer(uid)
                                                end
                                            end
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)

            -- Method 3: Legacy EggCmds (Removed IsLocalEggReady checks)
            pcall(function()
                if EggCmds and EggCmds.GetOwnerRuntimeRecords then
                    local ok, recs = pcall(function() return EggCmds.GetOwnerRuntimeRecords(LocalPlayer.UserId) end)
                    if ok and type(recs) == "table" then
                        for uid, rec in pairs(recs) do
                            if rec.Placement ~= nil then
                                task.spawn(function()
                                    pcall(function()
                                        local st = EggCmds.RequestHatchEgg(uid)
                                        if st then
                                            task.wait(0.2)
                                            EggCmds.RequestCompleteHatchEgg(uid)
                                        end
                                    end)
                                end)
                            end
                        end
                    end
                end
            end)
        end
        
        if autoEquipBestEnabled and (now - lastEquip) >= 3 then
            lastEquip = now
            pcall(function()
                if net and net:FindFirstChild("RF/Haul/WearBest") then
                    net["RF/Haul/WearBest"]:InvokeServer()
                end
                if Network and NM and NM.Backpack and NM.Backpack.EQUIP_BEST then
                    Network.Invoke(NM.Backpack.EQUIP_BEST)
                elseif Network and Network.Invoke then
                    Network.Invoke("EQUIP_BEST")
                    Network.Invoke("WEAR_BEST")
                end
            end)
        end
        
        if autoClaimEnabled and (now - lastClaim) >= 5 then
            lastClaim = now
            
            pcall(function()
                if net then
                    if net:FindFirstChild("RF/AwayEarnings/AskCollect") then
                        pcall(function() net["RF/AwayEarnings/AskCollect"]:InvokeServer() end)
                    end
                    if net:FindFirstChild("RF/Codex/AskRedeemAll") then
                        pcall(function() net["RF/Codex/AskRedeemAll"]:InvokeServer() end)
                    end
                end
                
                local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    for _, prompt in ipairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            local txt = string.lower(prompt.ActionText .. " " .. prompt.ObjectText)
                            if string.find(txt, "claim") or string.find(txt, "collect") or string.find(txt, "coin") or string.find(txt, "cash") then
                                local part = prompt.Parent
                                if part and part:IsA("BasePart") and (part.Position - rootPart.Position).Magnitude < 40 then
                                    pcall(function() 
                                        prompt.HoldDuration = 0
                                        if fireproximityprompt then fireproximityprompt(prompt) end
                                    end)
                                    task.wait(0.06)
                                end
                            end
                        end
                    end
                end
                
                if Network and NM then
                    if NM.Index and NM.Index.REQUEST_CLAIM_ALL then Network.Invoke(NM.Index.REQUEST_CLAIM_ALL) end
                    if NM.FreeGifts and NM.FreeGifts.REQUEST_CLAIM then Network.Invoke(NM.FreeGifts.REQUEST_CLAIM) end
                    if NM.OfflineAssets and NM.OfflineAssets.REQUEST_REDEEM then Network.Invoke(NM.OfflineAssets.REQUEST_REDEEM) end
                    if NM.GroupReward and NM.GroupReward.CLAIM_REWARD then Network.Invoke(NM.GroupReward.CLAIM_REWARD) end
                elseif Network and Network.Invoke then
                    Network.Invoke("REQUEST_CLAIM_ALL")
                    Network.Invoke("REQUEST_CLAIM")
                    Network.Invoke("REQUEST_REDEEM")
                    Network.Invoke("CLAIM_REWARD")
                end
            end)
        end
    end
end)

-- ============= ANTI-TRAP & AUTO-RUN =============
local function setupAntiTrap()
    local function checkAndDestroy(obj)
        pcall(function()
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local name = string.lower(obj.Name)
                if string.find(name, "trap") or string.find(name, "spike") or string.find(name, "snare") then
                    obj:Destroy()
                end
            end
        end)
    end

    -- 1. Sweep existing traps instantly
    for _, obj in ipairs(Workspace:GetDescendants()) do
        checkAndDestroy(obj)
    end

    -- 2. Destroy new traps the millisecond they spawn
    Workspace.DescendantAdded:Connect(function(obj)
        if antiTrapEnabled then
            checkAndDestroy(obj)
        end
    end)

    task.spawn(function()
        while task.wait(0.1) do
            if antiTrapEnabled then
                pcall(function()
                    local char = LocalPlayer.Character
                    if char and char:GetAttribute("IsTrapped") then
                        char:SetAttribute("IsTrapped", nil)
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum.PlatformStand = false end
                    end
                end)
            end
        end
    end)
end
setupAntiTrap()

task.spawn(function()
    while true do
        if autoRunEnabled then
            pcall(function()
                if TreadmillsNet and TreadmillsNet.REQUEST_SET_SLOW_TOGGLE_ENABLED then
                    Network.Invoke(TreadmillsNet.REQUEST_SET_SLOW_TOGGLE_ENABLED, false)
                elseif Network and Network.Invoke then
                    Network.Invoke("REQUEST_SET_SLOW_TOGGLE_ENABLED", false)
                end
            end)
        end
        task.wait(10)
    end
end)

-- ============= UPGRADE LOOP =============
local lastPenUpgrade = 0
local lastTreadmillUpgrade = 0
local lastTrailBuy = 0

local function tryUpgradePen(data)
    local nextLevel = data.BaseUpgradeLevel + 1
    local nextConfig = Bases and Bases.BASES and Bases.BASES[nextLevel]
    if nextConfig == nil then return end
    if data.Money >= nextConfig.Cost then
        pcall(function()
            if PlotsNet and PlotsNet.REQUEST_BASE_UPGRADE then
                Network.Fire(PlotsNet.REQUEST_BASE_UPGRADE)
            elseif Network and Network.Fire then
                Network.Fire("REQUEST_BASE_UPGRADE")
            end
        end)
    end
end

local function tryUpgradeTreadmill(data)
    local nextLevel = data.TreadmillUpgradeLevel + 1
    local nextConfig = Treadmills and Treadmills.GetByUpgradeLevel and Treadmills.GetByUpgradeLevel(nextLevel)
    if nextConfig == nil then return end
    if data.Money >= nextConfig.Price then
        pcall(function()
            if TreadmillsNet and TreadmillsNet.REQUEST_UPGRADE then
                Network.Invoke(TreadmillsNet.REQUEST_UPGRADE, nextConfig._id)
            elseif Network and Network.Invoke then
                Network.Invoke("REQUEST_UPGRADE", nextConfig._id)
            end
        end)
    end
end

local function tryBuyTrails(data)
    if not Trails or not Trails.Directory then return end
    local affordable = {}
    for name, cfg in pairs(Trails.Directory) do
        if cfg.DisplayInShop and not data.TrailInventory[name] then
            if data.Money >= cfg.Price then
                table.insert(affordable, {name = name, price = cfg.Price})
            end
        end
    end
    table.sort(affordable, function(a, b) return a.price < b.price end)

    if #affordable > 0 then
        local target = affordable[#affordable]
        pcall(function()
            if TrailsNet and TrailsNet.REQUEST_PURCHASE then
                Network.Invoke(TrailsNet.REQUEST_PURCHASE, target.name)
            elseif Network and Network.Invoke then
                Network.Invoke("REQUEST_PURCHASE", target.name)
            end
        end)
    end
end

task.spawn(function()
    while true do
        if autoPenEnabled or autoTreadmillEnabled or autoBuyTrailsEnabled then
            local ok, data = pcall(function() return Save and Save.Get and Save.Get() end)
            if ok and data then
                local now = os.clock()

                if autoPenEnabled and (now - lastPenUpgrade > 1.5) then
                    tryUpgradePen(data)
                    lastPenUpgrade = now
                end

                if autoTreadmillEnabled and (now - lastTreadmillUpgrade > 1.5) then
                    tryUpgradeTreadmill(data)
                    lastTreadmillUpgrade = now
                end

                if autoBuyTrailsEnabled and (now - lastTrailBuy > 3) then
                    tryBuyTrails(data)
                    lastTrailBuy = now
                end
            end
        end
        task.wait(1.5)
    end
end)

-- ============= AUTO FARM (EGG STEALER) =============
task.spawn(function()
    while true do
        task.wait(0.1)
        if autoFarmEnabled then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not root or not hum then return end

                -- 1. Find Target Egg
                local targetEgg = nil
                for _, egg in ipairs(cachedEggs) do
                    if autoFarmTargets[egg.area] and not egg.isPhysical then
                        targetEgg = egg
                        break
                    end
                end

                if not targetEgg then 
                    task.wait(1) 
                    return 
                end

                -- 2. Go to Egg
                local dist = (root.Position - targetEgg.pos).Magnitude
                local timeToTravel = math.max(dist / autoFarmSpeedValue, 0.1)
                
                local tween = TweenService:Create(root, TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear), {CFrame = targetEgg.cf})
                tween:Play()
                
                local tweenStart = os.clock()
                while os.clock() - tweenStart < timeToTravel + 0.5 do
                    if not autoFarmEnabled then tween:Cancel() return end
                    if (root.Position - targetEgg.pos).Magnitude < 5 then
                        tween:Cancel()
                        break
                    end
                    task.wait(0.1)
                end

                if not autoFarmEnabled then return end

                -- 3. Grab the egg
                root.CFrame = targetEgg.cf
                task.wait(0.1)

                local function getClosestPrompt(pos, range, filters)
                    local closest = nil
                    local minDist = range
                    for _, prompt in ipairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            local p = prompt.Parent
                            if p and p:IsA("BasePart") then
                                local d = (p.Position - pos).Magnitude
                                if d < minDist then
                                    local txt = string.lower(prompt.ActionText .. " " .. prompt.ObjectText)
                                    local ok = false
                                    for _, f in ipairs(filters) do
                                        if txt:find(f) then ok = true break end
                                    end
                                    if ok then
                                        closest = prompt
                                        minDist = d
                                    end
                                end
                            end
                        end
                    end
                    return closest
                end

                local initialPrompt = getClosestPrompt(root.Position, 20, {"steal", "grab", "take", "egg"})
                if initialPrompt and fireproximityprompt then
                    fireproximityprompt(initialPrompt)
                    task.wait(0.1)
                    fireproximityprompt(initialPrompt)
                elseif targetEgg.nest then
                    local p = targetEgg.nest:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if p and fireproximityprompt then fireproximityprompt(p) end
                end

                -- 4. WAIT exactly 4.0 seconds for the guard to tackle us and to get up
                task.wait(4.0)

                if not autoFarmEnabled then return end

                -- Force get up from ragdoll just in case
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)

                -- 5. Find dropped egg and grab it again
                local droppedEgg = nil
                local minDist = math.huge -- Removed distance limit (was 250) in case sent far
                for _, egg in ipairs(cachedEggs) do
                    if egg.isPhysical then
                        local d = (egg.pos - root.Position).Magnitude
                        if d < minDist then
                            droppedEgg = egg
                            minDist = d
                        end
                    end
                end
                
                if droppedEgg and droppedEgg.prompt and droppedEgg.part then
                    -- Fly (tween) to the dropped egg instead of teleporting
                    local flyDist = (root.Position - droppedEgg.part.Position).Magnitude
                    local flyTime = math.max(flyDist / autoFarmSpeedValue, 0.1)
                    local flyTween = TweenService:Create(root, TweenInfo.new(flyTime, Enum.EasingStyle.Linear), {CFrame = droppedEgg.part.CFrame})
                    flyTween:Play()
                    
                    local flyStart = os.clock()
                    while os.clock() - flyStart < flyTime + 2.0 do -- Added extra timeout leeway
                        if not autoFarmEnabled then flyTween:Cancel() return end
                        -- Double check distance from the actual part's current position
                        if (root.Position - droppedEgg.part.Position).Magnitude < 7 then
                            flyTween:Cancel()
                            break
                        end
                        task.wait(0.1)
                    end
                    
                    task.wait(1.5) -- Give 1.5 seconds wait before grabbing the egg
                    
                    -- Fire prompt
                    if fireproximityprompt then 
                        fireproximityprompt(droppedEgg.prompt)
                    end
                end
                
                if not autoFarmEnabled then return end

                -- 6. Go back to original position
                if autoFarmOriginalPos then
                    local backDist = (root.Position - autoFarmOriginalPos).Magnitude
                    local backTime = math.max(backDist / autoFarmSpeedValue, 0.1)
                    local backTween = TweenService:Create(root, TweenInfo.new(backTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(autoFarmOriginalPos)})
                    backTween:Play()
                    
                    local backStart = os.clock()
                    while os.clock() - backStart < backTime + 0.5 do
                        if not autoFarmEnabled then backTween:Cancel() return end
                        if (root.Position - autoFarmOriginalPos).Magnitude < 5 then
                            backTween:Cancel()
                            break
                        end
                        task.wait(0.1)
                    end
                end
                
                -- Wait a moment to drop off the egg at base before looping again
                task.wait(0.5)
            end)
        end
    end
end)

Library:Notify({ Title = "Anonymus Hub", Content = "Script fully restored with touch circles!", Duration = 5 })