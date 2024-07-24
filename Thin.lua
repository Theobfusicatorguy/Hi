local HttpService = game:GetService("HttpService")
local proxyUrl = "https://c5a5a248032c7bdf7244065d5e5895f2.serveo.net"  -- Local proxy URL
local memory = {}

local player = game.Players.LocalPlayer
local chatDistance = 100

-- Function to send chat to Proxy API
local function getApiResponse(message)
    local success, response = pcall(function()
        return HttpService:PostAsync(
            proxyUrl,
            HttpService:JSONEncode({ message = message, memory = memory }),
            Enum.HttpContentType.ApplicationJson
        )
    end)
    if success then
        local responseData = HttpService:JSONDecode(response)
        local reply = responseData.choices[1].message.content
        table.insert(memory, { role = "assistant", content = reply })
        return reply
    else
        warn("Failed to get API response: " .. tostring(response))
        return "Error: Unable to get response."
    end
end

-- Function to get a player's position
local function getPlayerPosition(player)
    if player.Character and player.Character.PrimaryPart then
        return player.Character.PrimaryPart.Position
    else
        for _, part in ipairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then
                return part.Position
            end
        end
    end
    return nil
end

-- Function to listen for chat messages
local function onPlayerChatted(player, message)
    local playerPosition = getPlayerPosition(player)
    local localPlayerPosition = getPlayerPosition(game.Players.LocalPlayer)
    if playerPosition and localPlayerPosition then
        local distance = (playerPosition - localPlayerPosition).Magnitude
        if distance <= chatDistance then
            table.insert(memory, { role = "user", content = message })
            local response = getApiResponse(message)
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(response, "All")
        end
    else
        warn("Unable to get position for player: " .. player.Name)
    end
end

-- Connect chat listener to all players
for _, otherPlayer in pairs(game.Players:GetPlayers()) do
    if otherPlayer ~= player then
        otherPlayer.Chatted:Connect(function(message)
            onPlayerChatted(otherPlayer, message)
        end)
    end
end

-- Connect chat listener to new players joining
game.Players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.Chatted:Connect(function(message)
        onPlayerChatted(newPlayer, message)
    end)
end)
