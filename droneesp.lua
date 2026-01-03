-- DRONE ESP - Все дроны в Drone Workspace
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Очистка старых ESP
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "Drone_ESP" then
        v:Destroy()
    end
end

-- Создаём папку для ESP
local DroneESPfolder = Instance.new("Folder")
DroneESPfolder.Name = "Drone_ESP"
DroneESPfolder.Parent = CoreGui

local trackedDrones = {}
local lastUpdate = 0

-- Находим папку с дронами
local function getDroneWorkspace()
    local gameSystems = workspace:FindFirstChild("Game Systems")
    if not gameSystems then return nil end
    
    return gameSystems:FindFirstChild("Drone Workspace")
end

-- Ищем все дроны
local function findAllDrones()
    local droneWorkspace = getDroneWorkspace()
    if not droneWorkspace then return {} end
    
    local drones = {}
    
    for _, droneModel in pairs(droneWorkspace:GetChildren()) do
        if droneModel:IsA("Model") then
            local primaryPart = droneModel.PrimaryPart or droneModel:FindFirstChildWhichIsA("BasePart")
            if primaryPart then
                table.insert(drones, {
                    model = droneModel,
                    name = droneModel.Name,
                    primaryPart = primaryPart
                })
            end
        end
    end
    
    return drones
end

-- Создаём ESP для дрона
local function createDroneESP(droneData)
    if not droneData.model then return nil end
    
    -- Подсветка дрона (ГОЛУБОЙ)
    local highlight = Instance.new("Highlight")
    highlight.Name = "Drone_Highlight"
    highlight.Adornee = droneData.model
    highlight.FillColor = Color3.fromRGB(0, 150, 255)  -- Голубой
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = droneData.model
    
    -- Текст сверху
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Drone_Text"
    billboard.Adornee = droneData.primaryPart
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 5000
    billboard.Parent = DroneESPfolder
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "DRONE"
    textLabel.TextColor3 = Color3.fromRGB(0, 150, 255)  -- Голубой текст
    textLabel.TextStrokeTransparency = 0.3
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 14
    textLabel.Parent = billboard
    
    return {
        highlight = highlight,
        billboard = billboard,
        model = droneData.model,
        name = droneData.name
    }
end

-- Основной цикл (раз в 0.5 секунды)
local function mainESP()
    if tick() - lastUpdate < 0.5 then return end
    lastUpdate = tick()
    
    -- Удаляем уничтоженные дроны
    for model, espData in pairs(trackedDrones) do
        if not model or not model.Parent then
            if espData.highlight then espData.highlight:Destroy() end
            if espData.billboard then espData.billboard:Destroy() end
            trackedDrones[model] = nil
        end
    end
    
    -- Ищем новые дроны
    local foundDrones = findAllDrones()
    
    for _, droneData in pairs(foundDrones) do
        if not trackedDrones[droneData.model] then
            local espData = createDroneESP(droneData)
            if espData then
                trackedDrones[droneData.model] = espData
            end
        end
    end
end

-- Запуск
local connection
local function startESP()
    if connection then
        connection:Disconnect()
    end
    
    connection = RunService.Heartbeat:Connect(function()
        pcall(mainESP)
    end)
end

local function stopESP()
    if connection then
        connection:Disconnect()
    end
    
    for model, espData in pairs(trackedDrones) do
        if espData.highlight then espData.highlight:Destroy() end
        if espData.billboard then espData.billboard:Destroy() end
    end
    
    trackedDrones = {}
    
    if DroneESPfolder then
        DroneESPfolder:Destroy()
    end
end

-- Автостарт
wait(1)
startESP()

-- Управление
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F8 then
        stopESP()
        wait(0.3)
        startESP()
    elseif input.KeyCode == Enum.KeyCode.F9 then
        stopESP()
    end
end)

print("Drone ESP loaded")
print("F8 - restart, F9 - stop")
