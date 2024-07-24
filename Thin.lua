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

-- Function to listen for chat messages
local function onPlayerChatted(player, message)
    if player:DistanceFromCharacter(game.Players.LocalPlayer.Character.Position) <= chatDistance then
        table.insert(memory, { role = "user", content = message })
        local response = getApiResponse(message)
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(response, "All")
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
