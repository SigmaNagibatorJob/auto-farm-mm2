local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/Tuturial_UI_Library/main/UI_Template_1"))()

local Windows = Library.CreateLib("No name Hub", "RJTheme3")

local Tab = Windows:NewTab("main")

local Section = Tab:NewSection("Section Name")


Section:NewButton("auto farm", "ButtonInfo", function()
	local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local maps = {
    "Factory",
    "BioLab",
    "House2",
    "Hospital3",
    "Workplace",
    "MilBase",
    "Bank2",
    "Hotel2",
    "Mansion2",
    "Office3",
    "PoliceStation",
    "ResearchFacility"
}

local speedValue = 2 -- Скорость движения
local autoFarmEnabled = false -- Автофарм по умолчанию отключен
local maxCandies = 40 -- Максимальное количество конфет для сбора за раз

-- Function to teleport to a coin
local function teleportToCoin(coin)
    humanoidRootPart.CFrame = coin.CFrame
    
    if coin:FindFirstChild("TouchInterest") then
        firetouchinterest(humanoidRootPart, coin, 0)
        firetouchinterest(humanoidRootPart, coin, 1)
    end
    
    wait(0.1) -- Wait until the touch is completed
end

-- Function to tween to a coin
local function tweenToCoin(coin)
    local tweenInfo = TweenInfo.new(
        (humanoidRootPart.Position - coin.Position).Magnitude / (24 / speedValue),
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out
    )
    local tweenGoal = {CFrame = coin.CFrame}
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, tweenGoal)
    tween:Play()
    tween.Completed:Wait()

    if coin:FindFirstChild("TouchInterest") then
        firetouchinterest(humanoidRootPart, coin, 0)
        firetouchinterest(humanoidRootPart, coin, 1)
    end
    
    wait(0.1) -- Wait until the touch is completed
end

-- Function to start AutoFarm
function startAutoFarm()
    autoFarmEnabled = true -- Включаем автофарм
    while autoFarmEnabled do
        for _, mapName in ipairs(maps) do
            local map = workspace:FindFirstChild(mapName)
            if map then
                local coinContainer = map:FindFirstChild("CoinContainer")
                if coinContainer then

Section:NewSlider("speed", "SliderInfo", 500, 0, function(s)
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
end)

Section:NewButton("esp", "ButtonInfo", function()
	while wait(0.5) do
    for i, childrik in ipairs(workspace:GetDescendants()) do
        if childrik:FindFirstChild("Humanoid") then
            if not childrik:FindFirstChild("EspBox") then
                if childrik ~= game.Players.LocalPlayer.Character then
                    local esp = Instance.new("BoxHandleAdornment",childrik)
                    esp.Adornee = childrik
                    esp.ZIndex = 0
                    esp.Size = Vector3.new(4, 5, 1)
                    esp.Transparency = 0.65
                    esp.Color3 = Color3.fromRGB(255,48,48)
                    esp.AlwaysOnTop = true
                    esp.Name = "EspBox"
                end
            end
        end
    end
end
end)
