print("Distance Tracker with Elevation GUI loaded")

-- USER VARIABLES - ADJUST THESE
local DROP = 3.78
local VELOCITY = 1108

local players = game:GetService("Players")
local localplayer = players.LocalPlayer

local elevationDisplays = {}

local trackedPlayers = {}
local playerOrder = {} 

local function calculateDistance(pos1, pos2)
    if not pos1 or not pos2 then
        return nil
    end
    
    local dx = pos2.X - pos1.X
    local dy = pos2.Y - pos1.Y
    local dz = pos2.Z - pos1.Z
    
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function calculateElevation(distance)
    if not distance or distance == 0 then
        return nil
    end
    
    local elevation = (DROP / (2 * VELOCITY)) * distance
    return elevation
end

local function getPlayerPosition(player)
    if player and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            return hrp.Position
        end
    end
    return nil
end

local function createPlayerDisplay(player)
    local nameText = Drawing.new("Text")
    nameText.Text = player.Name
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Outline = true
    nameText.Visible = true
    
    local elevationText = Drawing.new("Text")
    elevationText.Text = "Elevation: 0.00"
    elevationText.Color = Color3.fromRGB(255, 127, 0)
    elevationText.Outline = true
    elevationText.Visible = true
    
    elevationDisplays[player] = {
        nameText = nameText,
        elevationText = elevationText
    }
end

local function removePlayerDisplay(player)
    if elevationDisplays[player] then
        elevationDisplays[player].nameText:Remove()
        elevationDisplays[player].elevationText:Remove()
        elevationDisplays[player] = nil
    end
    
    for i, p in ipairs(playerOrder) do
        if p == player then
            table.remove(playerOrder, i)
            break
        end
    end
end

local function updateGUIPositions()
    local startX = 20
    local startY = 100
    local lineHeight = 30
    local index = 0
    
    for _, player in ipairs(playerOrder) do
        if elevationDisplays[player] then
            local display = elevationDisplays[player]
            display.nameText.Position = Vector2.new(startX, startY + (index * lineHeight))
            display.elevationText.Position = Vector2.new(startX + 10, startY + (index * lineHeight) + 15)
            index = index + 1
        end
    end
end

while true do
    local currentPlayers = {}
    for _, player in pairs(players:GetChildren()) do
        if player.ClassName == "Player" and player ~= localplayer and player.Name ~= localplayer.Name then
            currentPlayers[player] = true
            if not trackedPlayers[player] then
                createPlayerDisplay(player)
                trackedPlayers[player] = true
                table.insert(playerOrder, player)
            end
        end
    end
    for player, _ in pairs(trackedPlayers) do
        if not currentPlayers[player] then
            removePlayerDisplay(player)
            trackedPlayers[player] = nil
        end
    end
    
    if localplayer and localplayer.Character then
        local localPos = getPlayerPosition(localplayer)
        
        if localPos and playerOrder then
            for _, player in ipairs(playerOrder) do
                local display = elevationDisplays[player]
                if display and player and player ~= localplayer and player.Name ~= localplayer.Name then
                    local playerPos = getPlayerPosition(player)
                    
                    if playerPos then
                        local distance = calculateDistance(localPos, playerPos)
                        
                        if distance then
                            local elevation = calculateElevation(distance)
                            
                            if elevation then
                                local roundedElev = math.floor(elevation * 100 + 0.5) / 100
                                display.elevationText.Text = string.format("Elevation: %.2f", roundedElev)
                                display.nameText.Visible = true
                                display.elevationText.Visible = true
                            end
                        else
                            display.nameText.Visible = false
                            display.elevationText.Visible = false
                        end
                    else
                        display.nameText.Visible = false
                        display.elevationText.Visible = false
                    end
                end
            end
            
            updateGUIPositions()
        end
    end
    
    wait(0.1)
end
