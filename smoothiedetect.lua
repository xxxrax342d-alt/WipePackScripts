local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local function checkBuffViaRemote()
    local remote = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("AbilityEvent")
    if remote then
        local success, result = pcall(function()
            return remote:InvokeServer("GetBuffs")
        end)
        if success then
            print("Баффы:", result)
        end
    end
end
