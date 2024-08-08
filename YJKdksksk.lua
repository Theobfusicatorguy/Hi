local guiToClone = workspace["Sector_E"].ApolloCore.CoreModel.Chair.CPU.Scripts.ConsultationScript:WaitForChild("ConsultationGui")

local function onSuspectDetected(player)
    if player and player:FindFirstChild("PlayerGui") then
        -- Clone the GUI
        local clonedGui = guiToClone:Clone()
        
                clonedGui.Parent = player.PlayerGui
        
            end
end

-- Example: Triggering the function when a player joins the game (for testing purposes)
game.Players.PlayerAdded:Connect(function(player)
    -- Here you would add your detection logic, for now we just run it on join
    onSuspectDetected(player)
end)
