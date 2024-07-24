
-- orginal: https://raw.githubusercontent.com/Guerric9018/chatbothub/main/ChatbotHub.lua



local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/Guerric9018/OrionLibFixed/main/OrionLib.lua')))()

_G.CHATBOTHUB_BLACKLISTED = {
	--["Name"] = true,
}

_G.CHATBOTHUB_DISPLAYTOFULLNAME = {
	--["Display name"] = "Full name"
}

_G.CHATBOTHUB_BLACKLISTEDCONTENT = {
	--"Full name (Display name))"
}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local alreadyRan = true

local GUI = Instance.new("ScreenGui")
GUI.Parent = game.CoreGui
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if _G.CHATBOTHUB_RAN == nil then
    alreadyRan = false
	_G.CHATBOTHUB_TTA = false
	_G.CHATBOTHUB_AI_MODEL = "Llama-8B ( default | 5 points )"
	_G.CHATBOTHUB_ON = false
	_G.CHATBOTHUB_CREDITS = math.huge -- Set credits to infinite
	_G.CHATBOTHUB_LOGIN = false
	_G.CHATBOTHUB_PREMIUM = true -- Enable premium features by default
	_G.CHATBOTHUB_CUSTOMPROMPT = false
	_G.CHATBOTHUB_CUSTOMPROMPTTEXT = "Just be a normal AI."
    _G.CHATBOTHUB_WHITELIST = false
	_G.CHATBOTHUB_BOTFORMAT = true
	_G.CHATBOTHUB_TTA_RUNNING = true
	_G.CHATBOTHUB_CHAT_BYPASS = false
	_G.CHATBOTHUB_KEY = "default"
	_G.CHATBOTHUB_LOADED = false
	_G.CHATBOTHUB_DELAYED_CHAT = false
	_G.CHATBOTHUB_REMINDING_STATE = false
end

local msg = function() return end


local success, textChannels = pcall(function()
	return game:GetService("TextChatService").TextChannels
end)

if success then
	print("New chat system detected")
	msg = function(txt) game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(txt) end
else
	print("Old chat system detected")
	msg = function(txt) game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(txt, "All") end
end


local AIs = {
	"Furry",
	"Roast",
	"Waifu",
	"Nerd",
	"Christian",
	"Robot",
    "Brainrot",
	"Normal"
}

local AiModels = {
	"Llama-8B ( default | 5 points )",
	"Llama2-7B ( if default one fails | 5 points )",
	"Llama-70B ( 50 points )"
}

local AiCost = {
	["Llama-8B ( default | 5 points )"] = 5,
	["Llama2-7B ( if default one fails | 5 points )"] = 5,
	["Llama-70B ( 50 points )"] = 50
}

if _G.CHATBOTHUB_RAN == nil then
	_G.CHATBOTHUB_MaxDistance = 20
	_G.CHATBOTHUB_Character = "Normal"
end

_G.CHATBOTHUB_RAN = true

local updateCredits = function() return end
local updatePremium = function() return end


local correspondances = {
	["h"] = "ẖ",
	["i"] = "ї",
	["a"] = "ɑ",
	["u"] = "ṷ",
	["c"] = "с",
	["g"] = "ɡ",
	["n"] = "ṅ",
	["e"] = "e",
	["t"] = "ṭ",
	["l"] = "ḻ",
	["o"] = "ο",
	["d"] = "d",
	["s"] = "ṣ",
	["k"] = "k",
	["w"] = "ẇ"
} 


local function translate(m)
	m = string.lower(m)
	for i, j in pairs(correspondances) do
		m = m:gsub(i, j)
	end
	return(m)
end


local findPlayerName = function(name)
	for i,player in pairs(game.Players:GetChildren()) do
		local prefix_length = #name
		local name_prefix = player.Name:sub(1, prefix_length)
		if(name_prefix == name) then
			return player.Name, player.DisplayName
		end
	end
	for i,player in pairs(game.Players:GetChildren()) do
		local prefix_length = #name
		local name_prefix = player.DisplayName:sub(1, prefix_length)
		if(name_prefix == name) then
			return player.Name, player.DisplayName
		end
	end
	return nil, nil
end

local findPlayer = function(name)
	for i,player in pairs(game.Players:GetChildren()) do
		local prefix_length = #name
		local name_prefix = player.Name:sub(1, prefix_length)
		if(string.lower(name_prefix) == name) then
			return player
		end
	end
	for i,player in pairs(game.Players:GetChildren()) do
		local prefix_length = #name
		local name_prefix = player.DisplayName:sub(1, prefix_length)
		if(string.lower(name_prefix) == name) then
			return player
		end
	end
	return nil, nil
end


local function stopAction()
	print(stopping)
	_G.CHATBOTHUB_TTA_RUNNING = false
	wait(1)
	_G.CHATBOTHUB_TTA_RUNNING = true
end

local function jump()
	LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
end

local function spin()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = LocalPlayer.Character.HumanoidRootPart
        
        while _G.CHATBOTHUB_TTA_RUNNING do
            humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(15), 0)
            wait(0.1)
        end
	end
end

local function follow(player)
	local TargetPlayer = findPlayer(player)
	print("following " .. TargetPlayer.DisplayName)
	_G.CHATBOTHUB_TARGET_PLAYER = TargetPlayer
	while _G.CHATBOTHUB_TTA_RUNNING  and TargetPlayer == _G.CHATBOTHUB_TARGET_PLAYER do
		LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):MoveTo(TargetPlayer.Character.HumanoidRootPart.Position)
		wait(0.05)
	end
end

local function checkCommand(input)
	input = string.lower(input)
    if input == "stop" then 
		stopAction()
		return
	end
	if input == "jump" then 
		jump()
		return
	end
	if input == "spin" then 
		spin()
		return
	end
	if input == "null" then
		return
	end

    local followPattern = "^follow%s+(.+)"
    local match = string.match(input, followPattern)

    if match then
        follow(match)
    end
end

local function remindAIState(state)
	if not _G.CHATBOTHUB_REMINDING_STATE and state then
		_G.CHATBOTHUB_REMINDING_STATE = true
		while _G.CHATBOTHUB_REMINDING_STATE do
			msg("Hello, I am an AI! Please chat with me!")
			wait(10)
		end
	end
	if not state then
		_G.CHATBOTHUB_REMINDING_STATE = false
	end
end

local requestsList = {}

local function addRequestToList(message)
    table.insert(requestsList, message)
    if #requestsList > 5 then
        table.remove(requestsList, 1)
    end
end

local function delayedChat(state)
	if not _G.CHATBOTHUB_DELAYED_CHAT and state then
		_G.CHATBOTHUB_DELAYED_CHAT = true
		while _G.CHATBOTHUB_DELAYED_CHAT do
			if #requestsList > 0 then
				local firstMessage = requestsList[1]
				table.remove(requestsList, 1)
				msg(firstMessage)
			end
			wait(2)
		end
	end
	if not state then
		_G.CHATBOTHUB_DELAYED_CHAT = false
	end
end

local Window = OrionLib:MakeWindow({
	Name = "ChatBot Hub",
	HidePremium = false,
	SaveConfig = false,
	IntroText = "ChatBot Hub",
	IntroEnabled = true,
	IntroIcon = "rbxassetid://13188306657"})


local MainTab = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://6034798461",
})

local CharacterTab = Window:MakeTab{
	Name = "AI",
	Icon = "rbxassetid://13680871118"
}

local PremiumTab = Window:MakeTab{
	Name = "Premium",
	Icon = "rbxassetid://11835491319",
}

local ChatTab = Window:MakeTab{
	Name = "Chat",
	Icon = "rbxassetid://14376097365"
}

local MoreTab = Window:MakeTab{
	Name = "More",
	Icon = "rbxassetid://5107175347",
}

local HelpTab = Window:MakeTab{
	Name = "Help",
	Icon = "rbxassetid://15668939723"
}

local resetToggle = function() return end
local doCallback = true

local RunningToggle = MainTab:AddToggle{
	Name = "Running",
	Default = _G.CHATBOTHUB_ON,
	Callback = function(state)
		_G.CHATBOTHUB_ON = state
	end
}

resetToggle = function()
	doCallback = false
	RunningToggle:Set(false)
	wait(0.3)
	doCallback = true
end

local CreditLabel = MainTab:AddLabel("Points balance: ".. _G.CHATBOTHUB_CREDITS)

updateCredits = function()
	CreditLabel:Set(_G.CHATBOTHUB_CREDITS)
end

local addPlayer = function() return end
local removePlayer = function() return end

local BlacklistTextbox = MainTab:AddTextbox({
	Name = "Blacklist player",
	Default = "",
	TextDisappear = true,
	Callback = function(player)
		addPlayer(player)
	end	  
})

local BlacklistedDropdown = MainTab:AddDropdown({
	Name = "Blacklisted players",
	Description = "Select player to whitelist...",
	Default = "",
	Options = _G.CHATBOTHUB_BLACKLISTED,
	Callback = function(FullName) removePlayer(FullName) end
})

addPlayer = function(player)
	local FullName, Name = findPlayerName(player)
	if FullName==nil then return end
	_G.CHATBOTHUB_BLACKLISTED[FullName] = true
	_G.CHATBOTHUB_DISPLAYTOFULLNAME[FullName.." ("..Name..")"] = FullName
	table.insert(_G.CHATBOTHUB_BLACKLISTEDCONTENT, FullName.." ("..Name..")")
	BlacklistedDropdown:Refresh(_G.CHATBOTHUB_BLACKLISTEDCONTENT,true)
end

removePlayer = function(player)
	local FullName = _G.CHATBOTHUB_DISPLAYTOFULLNAME[player]
	if FullName==nil then return end
	_G.CHATBOTHUB_BLACKLISTED[FullName] = false
	for i, v in ipairs(_G.CHATBOTHUB_BLACKLISTEDCONTENT) do
		if v == player then 
			table.remove(_G.CHATBOTHUB_BLACKLISTEDCONTENT, i)
		end
	end
	BlacklistedDropdown:Refresh(_G.CHATBOTHUB_BLACKLISTEDCONTENT,true)
	BlacklistedDropdown:Set("")
end

MainTab:AddButton{
	Name = "Reset blacklist",
	Callback = function() 
		table.clear(_G.CHATBOTHUB_BLACKLISTED)
		table.clear(_G.CHATBOTHUB_DISPLAYTOFULLNAME)
		table.clear(_G.CHATBOTHUB_BLACKLISTEDCONTENT)
		BlacklistedDropdown:Refresh(_G.CHATBOTHUB_BLACKLISTEDCONTENT,true)
	end
}

MainTab:AddToggle{
	Name = "Whitelist mode",
    Default = _G.CHATBOTHUB_WHITELIST,
	Callback = function(state) 
        if state == false then
		    BlacklistedDropdown:Title("Blacklisted players")
            BlacklistTextbox:Title("Blacklist player")
            _G.CHATBOTHUB_WHITELIST = state
        else
            BlacklistedDropdown:Title("Whitelisted players")
            BlacklistTextbox:Title("Whitelist player")
            _G.CHATBOTHUB_WHITELIST = state
        end
	end
}

MainTab:AddTextbox({
	Name = "Listening range",
	Default = "20",
	TextDisappear = false,
	Callback = function(value)
		_G.CHATBOTHUB_MaxDistance = tonumber(value)
	end	  
})

MainTab:AddToggle{
	Name = "Anti spam",
    Default = _G.CHATBOTHUB_DELAYED_CHAT,
	Callback = function(state) 
        delayedChat(state)
	end
}

MainTab:AddButton{
	Name = "Reset AI memory",
	Callback = function() 
		game:HttpGet("https://guerric.pythonanywhere.com/erase-memory?uid=" .. tostring(LocalPlayer.UserId))
		OrionLib:MakeNotification{
			Name = "Success",
			Content  = "AI's memory erased!",
			Image = "rbxassetid://7115671043",
			Time = 3
		}
	end
}

MainTab:AddToggle{
	Name = "Chatbot message formatting ([Chatbot] ...)",
    Default = _G.CHATBOTHUB_BOTFORMAT,
	Callback = function(state) 
        _G.CHATBOTHUB_BOTFORMAT = state
	end
}

MainTab:AddToggle{
	Name = "Chat bypass",
    Default = _G.CHATBOTHUB_CHAT_BYPASS,
	Callback = function(state) 
        _G.CHATBOTHUB_CHAT_BYPASS = state
	end
}

MainTab:AddToggle{
	Name = "Auto remind you're a chatbot",
    Default = _G.CHATBOTHUB_REMINDING_STATE,
	Callback = function(state) 
        remindAIState(state)
	end
}


local resetTogglePrem = function() return end

local CharDropdown = CharacterTab:AddDropdown{
	Name = "Select the character of your AI",
	Default = _G.CHATBOTHUB_Character,
	Description = "List is subject to change in future updates! Give ideas in the Discord server!",
	Options = AIs,
	Callback = function(SelectedCharacter) 
		_G.CHATBOTHUB_Character = SelectedCharacter 
		resetTogglePrem()
	end
}

local AiDropDown = CharacterTab:AddDropdown{
	Name = "Select the AI model",
	Default = _G.CHATBOTHUB_AI_MODEL,
	Description = "Some AIs are smarter but cost more points!",
	Options = AiModels,
	Callback = function(SelectedModel) 
		_G.CHATBOTHUB_AI_MODEL = SelectedModel
	end
}


local PremiumLabel = PremiumTab:AddLabel("Premium activated!") -- Update premium status

updatePremium = function()
	local PremiumText = "Premium activated!"
	PremiumLabel:Set(PremiumText)
end

updatePremium()

local doCallbackPrem = true

local resetToggleTTA = function() return end
local doCallbackTTA = true

local TTAToggle = PremiumTab:AddToggle{
	Name = "Text to action mode ( 1.5x points )",
	Default = _G.CHATBOTHUB_TTA,
	Callback = function(state)
		_G.CHATBOTHUB_TTA = state
	end
}

resetToggleTTA = function()
	doCallbackTTA = false
	TTAToggle:Set(false)
	wait(0.3)
	doCallbackTTA = true
end

local CustomToggle = PremiumTab:AddToggle{
	Name = "Enable custom prompt",
	Default = _G.CHATBOTHUB_CUSTOMPROMPT,
	Callback = function(state)
		_G.CHATBOTHUB_CUSTOMPROMPT = state
	end
}

resetTogglePrem = function()
	doCallbackPrem = false
	CustomToggle:Set(false)
	wait(0.3)
	doCallbackPrem = true
end

local updateCustomPrompt = function() return end

PremiumTab:AddTextbox({
	Name = "Enter custom prompt here: ",
	Default = "",
	TextDisappear = true,
	Callback = function(prompt)
		_G.CHATBOTHUB_CUSTOMPROMPTTEXT = prompt
		updateCustomPrompt()
	end	  
})

local CustomPrompt = PremiumTab:AddParagraph("Custom Prompt", _G.CHATBOTHUB_CUSTOMPROMPTTEXT)

updateCustomPrompt = function()
	CustomPrompt:Set(_G.CHATBOTHUB_CUSTOMPROMPTTEXT)
end

local updateChat = function(message) return end

ChatTab:AddButton{
	Name = "Clear chat",
	Callback = function() 
		updateChat("")
	end
}

local ChatText = ""

local ChatLabel = ChatTab:AddParagraph("AI's answer","")

local CopyButton = ChatTab:AddButton{
	Name = "Copy the answer",
	Description = "Click to copy the full answer",
	Callback = function() 
		OrionLib:MakeNotification{
			Name = "ChatBot response",
			Content = "ChatBot response copied to clipboard",
			Time = 3,
			Image = "rbxassetid://10337369764"
		}
		setclipboard(ChatText) 
	end
}

updateChat = function(message)
	ChatText = message
	ChatLabel:Set(message)
end

ChatTab:AddTextbox{
	Name = "Message",
	Default = "",
	TextDisappear = true,
	Callback = function(message) 
		message = HttpService:UrlEncode(message)
		local userDisplayURI = HttpService:UrlEncode(LocalPlayer.DisplayName)
		local Character = HttpService:UrlEncode(_G.CHATBOTHUB_Character)
		local model = HttpService:UrlEncode(_G.CHATBOTHUB_AI_MODEL)
		local custom = "no"
		local shownText = ""

		if _G.CHATBOTHUB_PREMIUM and _G.CHATBOTHUB_CUSTOMPROMPT then
			Character = HttpService:UrlEncode(_G.CHATBOTHUB_CUSTOMPROMPTTEXT)
			custom = "yes"
		end
		local response = game:HttpGet("https://guerric.pythonanywhere.com/chat?msg="..message.."&user="..userDisplayURI.."&key=" .. _G.CHATBOTHUB_KEY .. "&ai=" .. Character .. "&uid=" .. LocalPlayer.UserId .. "&custom=" .. custom .. "&model=" .. model .. "&long=yes&tta=no")

		OrionLib:MakeNotification{
		 Name = tostring(AiCost[_G.CHATBOTHUB_AI_MODEL]) .. " points used",
		 Content = tostring(_G.CHATBOTHUB_CREDITS) .. " points left",
		 Time = 1
		 }
		 CreditLabel:Set(_G.CHATBOTHUB_CREDITS)
		
		updateChat(response)
	end
}

MoreTab:AddButton{
	Name = "Official Discord server",
	Description = "Click to copy the link",
	Callback = function() 
		OrionLib:MakeNotification{
			Name = "Discord",
			Content = "Discord link copied to clipboard",
			Time = 3,
			Image = "rbxassetid://10337369764"
		}
		setclipboard("https://discord.gg/MJagjEv9VX") 
	end
}

MoreTab:AddButton{
	Name = "Chat bypass by Guerric",
	Description = "Click to execute the script",
	Callback = function() 
		OrionLib:MakeNotification{
			Name = "Chat bypass by Guerric",
			Content = "Chat bypass script launched",
			Time = 3,
			Image = "rbxassetid://7115671043"
		}
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Guerric9018/chat_bypass/main/main.lua"))()
	end
}

HelpTab:AddParagraph("Help",
	"<b>\nIf you encounter issues. Please check the following:</b>\n\n" ..
		"<font color=\"rgb(255, 0, 0)\"><b>• Have you set 'Running' on in the main tab?</b></font>\n" ..
		"<b>If nothing works please ask your question in the Discord server.</b>")

OrionLib:Init()

local function main(message, userDisplay, uid)
	message = HttpService:UrlEncode(message)
    userDisplayURI = HttpService:UrlEncode(userDisplay)
    local Character = HttpService:UrlEncode(_G.CHATBOTHUB_Character)
	local model = HttpService:UrlEncode(_G.CHATBOTHUB_AI_MODEL)
	local custom = "no"
	if _G.CHATBOTHUB_PREMIUM and _G.CHATBOTHUB_CUSTOMPROMPT then
		Character = HttpService:UrlEncode(_G.CHATBOTHUB_CUSTOMPROMPTTEXT)
		custom = "yes"
	end
    local response = game:HttpGet("https://guerric.pythonanywhere.com/chat?msg="..message.."&user="..userDisplayURI.."&key=" .. _G.CHATBOTHUB_KEY .. "&ai=" .. Character .. "&uid=" .. uid .. "&custom=" .. custom .. "&model=" .. model .. "&long=no&tta=no")
    local data = response
    
	if _G.CHATBOTHUB_CHAT_BYPASS then data = translate(data) end
			
	if _G.CHATBOTHUB_TTA then
		ttaResponse = game:HttpGet("https://guerric.pythonanywhere.com/chat?msg="..message.."&user="..userDisplayURI.."&key=" .. _G.CHATBOTHUB_KEY .. "&ai=" .. Character .. "&uid=" .. uid .. "&custom=" .. custom .. "&model=" .. _G.CHATBOTHUB_AI_MODEL .. "&long=no&tta=yes")
		print(ttaResponse)
		checkCommand(ttaResponse)
	end

    local responseText = data:gsub("i love you", "ily"):gsub("wtf", "wt$"):gsub("zex", "zesty"):gsub("\n", " "):gsub("I love you", "ily"):gsub("I don't know what you're saying. Please teach me.", "I do not understand, try saying it without emojis and/or special characters.")
    if responseText == "" then return end
   wait()
   local offset = 0
   if _G.CHATBOTHUB_BOTFORMAT then
	offset = 12 + #userDisplay
   end
   local chunkSize = 195 - offset
   local numChunks = math.ceil(#responseText / chunkSize)

   local mult = 1

   if _G.CHATBOTHUB_TTA then
		mult = 1.5
   end

   for i = 1, numChunks do
        local startIndex = (i - 1) * chunkSize + 1
        local endIndex = math.min(i * chunkSize, #responseText)
		local intro = ""
        local chunk = string.sub(responseText, startIndex, endIndex)
		if _G.CHATBOTHUB_BOTFORMAT then
        	local intro = "[ChatBot]: "
		end
        local chunkProgress = " "..i.."/"..numChunks
        if numChunks == 1 then 
            chunkProgress = ""
        end
        if _G.CHATBOTHUB_BOTFORMAT and i == 1 then 
            intro = "[ChatBot]: "..userDisplay.. ", "
        end

		addRequestToList(intro .. chunk .. chunkProgress)

		if not _G.CHATBOTHUB_DELAYED_CHAT then
        	msg(intro .. chunk .. chunkProgress)
		end

        wait(0.1)
    end

end

local Players = game:GetService("Players")

if not alreadyRan then
	Players.PlayerChatted:Connect(function(type, plr, message)
		if _G.CHATBOTHUB_CUSTOMPROMPT and (not _G.CHATBOTHUB_PREMIUM) then resetTogglePrem() end
		if (_G.CHATBOTHUB_BLACKLISTED[plr.Name] and not _G.CHATBOTHUB_WHITELIST) or (_G.CHATBOTHUB_WHITELIST and not _G.CHATBOTHUB_BLACKLISTED[plr.Name]) then return end
		if _G.CHATBOTHUB_ON and ((Players.LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude <= _G.CHATBOTHUB_MaxDistance) then
			if plr.Name ~= LocalPlayer.Name and string.sub(message, 1, 1) ~= "#" then
				main(message, plr.DisplayName, LocalPlayer.UserId)
			end
		end
	end)
end

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 70, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 1, -160)
ToggleButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Text = "Toggle ChatbotHub"
ToggleButton.Parent = GUI
ToggleButton.TextWrapped = true
ToggleButton.Font = Enum.Font.Code
local ToggleButtonCornerFrame = Instance.new("UICorner")
ToggleButtonCornerFrame.CornerRadius = UDim.new(0.2, 0)
ToggleButtonCornerFrame.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    OrionLib:Switch()
end)

_G.CHATBOTHUB_LOADED = true

loadstring(game:HttpGet("https://raw.githubusercontent.com/AnthonyIsntHere/anthonysrepository/main/scripts/AntiChatLogger.lua", true))()
