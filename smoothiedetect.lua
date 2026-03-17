local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local function debugBuffs()
    print("=== Поиск баффов ===")
    local stats = Player:FindFirstChild("PlayerStats")
    if stats then
        print("✅ PlayerStats найден")
        local buffs = stats:FindFirstChild("Buffs")
        if buffs then
            print("✅ Buffs найден, детей:", #buffs:GetChildren())
            for i, buff in pairs(buffs:GetChildren()) do
                print("  Бафф " .. i .. ": " .. buff.Name)
                for _, prop in pairs(buff:GetChildren()) do
                    print("    - " .. prop.Name .. " = " .. tostring(prop.Value))
                end
            end
        else
            print("❌ Buffs не найден")
        end
    else
        print("❌ PlayerStats не найден")
    end
end

debugBuffs()
