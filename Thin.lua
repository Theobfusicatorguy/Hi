local apiKey = "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"
local apiUrl = "https://api.groq.com/openai/v1/chat/completions"
local memory = {}

local player = game.Players.LocalPlayer
local chatDistance = 100

-- Function to send chat to Groq API
local function getApiResponse(message)
    local HttpService = game:GetService("HttpService")
    local response = HttpService:PostAsync(
        apiUrl,
        HttpService:JSONEncode({
            model = "llama3-8b-8192",
            messages = {
                { role = "system", content = "Be a respectful AI" },
                table.unpack(memory),
                { role = "user", content = message }
            }
        }),
        Enum.HttpContentType.ApplicationJson,
        false,
        { ["Authorization"] = "Bearer " .. apiKey }
    )
    local responseData = HttpService:JSONDecode(response)
    local reply = responseData.choices[1].message.content
    table.insert(memory, { role = "assistant", content = reply })
    return reply
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
        warn("Unable to get position for player: " .. player.Nam
            
