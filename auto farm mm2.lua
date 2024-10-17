local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/Tuturial_UI_Library/main/UI_Template_1"))()

local Windows = Library.CreateLib("No name Hub", "RJTheme3")

local Tab = Windows:NewTab("main")

local Section = Tab:NewSection("Section Name")


Section:NewButton("auto farm", "ButtonInfo", function()
	local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local userInterface = player:WaitForChild("PlayerGui")

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

print("[DEBUG] Loaded player, character, and maps.")

-- Create a ScreenGui and Slider to adjust the speed
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = userInterface
screenGui.Name = "AutoFarmGui"

local sliderFrame = Instance.new("Frame", screenGui)
sliderFrame.Size = UDim2.new(0, 200, 0, 50)
sliderFrame.Position = UDim2.new(0.5, -100, 0, 10)

local slider = Instance.new("TextButton", sliderFrame)
slider.Size = UDim2.new(1, 0, 1, 0)
slider.Text = "Speed: 2"

local speedValue = 2 -- Default speed
local autoFarmEnabled = false
local noclipEnabled = false
local mapFirstCoinCollected = {} -- Track if first coin has been collected for each map

-- Create configuration in workspace
local configFolder = workspace:FindFirstChild("AutoFarmConfig")
if not configFolder then
    configFolder = Instance.new("Folder")
    configFolder.Name = "AutoFarmConfig"
    configFolder.Parent = workspace
end

local speedConfig = Instance.new("IntValue", configFolder)
speedConfig.Name = "SpeedValue"
speedConfig.Value = speedValue

local autoFarmConfig = Instance.new("BoolValue", configFolder)
autoFarmConfig.Name = "AutoFarmEnabled"
autoFarmConfig.Value = autoFarmEnabled

slider.MouseButton1Click:Connect(function()
    speedValue = speedValue + 1
    if speedValue > 10 then
        speedValue = 1
    end
    slider.Text = "Speed: " .. tostring(speedValue)
    speedConfig.Value = speedValue
    print("[DEBUG] Speed adjusted to: " .. tostring(speedValue))
end)

-- Create Start/Stop Button for AutoFarm
local buttonFrame = Instance.new("Frame", screenGui)
buttonFrame.Size = UDim2.new(0, 200, 0, 50)
buttonFrame.Position = UDim2.new(0.5, -100, 0, 70)

local startStopButton = Instance.new("TextButton", buttonFrame)
startStopButton.Size = UDim2.new(1, 0, 1, 0)
startStopButton.Text = "Start AutoFarm"

startStopButton.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    autoFarmConfig.Value = autoFarmEnabled
    if autoFarmEnabled then
        startStopButton.Text = "Stop AutoFarm"
        noclipEnabled = true
        print("[DEBUG] AutoFarm started.")
        startAutoFarm()
    else
        startStopButton.Text = "Start AutoFarm"
        noclipEnabled = false
        print("[DEBUG] AutoFarm stopped.")
    end
end)

-- Function to enable/disable noclip
local function noclip()
    while noclipEnabled do
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
        wait(0.1)
    end
end

-- Start noclip coroutine when autofarm is enabled
coroutine.wrap(noclip)()

-- Function to teleport to a coin
local function teleportToCoin(coin)
    print("[DEBUG] Teleporting to coin: " .. coin:GetFullName())
    humanoidRootPart.CFrame = coin.CFrame
    
    -- Fire a proximity prompt or touch event if required (simulating collection)
    if coin:FindFirstChild("TouchInterest") then
        print("[DEBUG] Firing touch interest for coin: " .. coin:GetFullName())
        firetouchinterest(humanoidRootPart, coin, 0)
        firetouchinterest(humanoidRootPart, coin, 1)
    end
    
    -- Wait until the touch is completed before moving to the next coin
    wait(0.1)
    
    -- Reset player position to prevent floating
    humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
end

-- Function to tween to a coin
local function tweenToCoin(coin)
    print("[DEBUG] Tweening to coin: " .. coin:GetFullName())
    local tweenInfo = TweenInfo.new(
        (humanoidRootPart.Position - coin.Position).Magnitude / (24 / speedValue), -- Adjusted for a faster speed
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out
    )
    local tweenGoal = {CFrame = coin.CFrame}
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, tweenGoal)
    tween:Play()
    tween.Completed:Wait()

    -- Fire a proximity prompt or touch event if required (simulating collection)
    if coin:FindFirstChild("TouchInterest") then
        print("[DEBUG] Firing touch interest for coin: " .. coin:GetFullName())
        firetouchinterest(humanoidRootPart, coin, 0)
        firetouchinterest(humanoidRootPart, coin, 1)
    end
    
    -- Wait until the touch is completed before moving to the next coin
    wait(0.1)
    
    -- Reset player position to prevent floating
    humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
end

-- Function to start AutoFarm
function startAutoFarm()
    coroutine.wrap(function()
        while autoFarmEnabled do
            for _, mapName in ipairs(maps) do
                local map = workspace:FindFirstChild(mapName)
                if map then
                    print("[DEBUG] Found map: " .. mapName)
                    local coinContainer = map:FindFirstChild("CoinContainer")
                    if coinContainer then
                        print("[DEBUG] Found coin container in map: " .. mapName)
                        local coins = {}
                        for _, coin in ipairs(coinContainer:GetChildren()) do
                            if not coin:IsDescendantOf(workspace) then
                                print("[DEBUG] Skipping already collected coin: " .. coin:GetFullName())
                            elseif not coin:FindFirstChild("CoinVisual") then
                                print("[DEBUG] Skipping invalid coin: " .. coin:GetFullName())
                            else
                                table.insert(coins, coin)
                            end
                        end
                        table.sort(coins, function(a, b)
                            if a:IsA("BasePart") and b:IsA("BasePart") then
                                return (humanoidRootPart.Position - a.Position).Magnitude < (humanoidRootPart.Position - b.Position).Magnitude
                            end
                            return false
                        end)
                        if #coins > 0 then
                            local firstCoin = coins[1]
                            if not mapFirstCoinCollected[mapName] then
                                if firstCoin:FindFirstChild("CoinVisual") then
                                    teleportToCoin(firstCoin.CoinVisual)
                                    mapFirstCoinCollected[mapName] = true
                                end
                            else
                                teleportToCoin(firstCoin.CoinVisual) -- Ensure we teleport first after respawn
                                for _, coin in ipairs(coins) do
                                    if not autoFarmEnabled then
                                        print("[DEBUG] AutoFarm stopped, exiting loop.")
                                        return
                                    end
                                    if coin:FindFirstChild("CoinVisual") then
                                        tweenToCoin(coin.CoinVisual)
                                    end
                                end
                            end
                        end
                    else
                        print("[DEBUG] No coin container found in map: " .. mapName)
                    end
                else
                    print("[DEBUG] Map not found: " .. mapName)
                end
            end
            wait(1) -- Wait a moment before checking for coins again
        end
    end)()
end

-- Keep GUI and functionality after respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    print("[DEBUG] Character respawned, GUI remains visible.")
    if autoFarmEnabled then
        print("[DEBUG] Resuming AutoFarm after respawn.")
        startAutoFarm()
    end
end)

-- Add Auto Rejoin Button if player gets kicked
player.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.Failed then
        local rejoinButton = Instance.new("TextButton", screenGui)
        rejoinButton.Size = UDim2.new(0, 200, 0, 50)
        rejoinButton.Position = UDim2.new(0.5, -100, 0, 130)
        rejoinButton.Text = "Rejoin Game"
        rejoinButton.MouseButton1Click:Connect(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, player)
        end)
    end
end)
end)

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
