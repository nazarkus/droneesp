local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "Drone_ESP" then
        v:Destroy()
    end
end

local DroneESPfolder = Instance.new("Folder")
DroneESPfolder.Name = "Drone_ESP"
DroneESPfolder.Parent = CoreGui

local trackedDrones = {}
local lastUpdate = 0

local function getDroneWorkspace()
    local gameSystems = workspace:FindFirstChild("Game Systems")
    if not gameSystems then return nil end
    return gameSystems:FindFirstChild("Drone Workspace")
end

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

local function createDroneESP(droneData)
    if not droneData.model then return nil end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "Drone_Highlight"
    highlight.Adornee = droneData.model
    highlight.FillColor = Color3.fromRGB(0, 150, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = droneData.model
    
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
    textLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
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

local function mainESP()
    if tick() - lastUpdate < 0.5 then return end
    lastUpdate = tick()
    
    for model, espData in pairs(trackedDrones) do
        if not model or not model.Parent then
            if espData.highlight then espData.highlight:Destroy() end
            if espData.billboard then espData.billboard:Destroy() end
            trackedDrones[model] = nil
        end
    end
    
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

local connection
local function startESP()
    if connection then
        connection:Disconnect()
    end
    
    connection = RunService.Heartbeat:Connect(function()
        pcall(mainESP)
    end)
end

wait(1)
startESP()

print("drone esp loaded")
