local beltSwitched = false

require(ReplicatedStorage.Events).ClientListen("PlayerAbilityEvent", function(data)
    for tag, info in pairs(data) do
        if tag == "Combo Coconuts" or tag == "ComboCoconuts" then
            if info.Action == "Update" then
                local value = info.Values and info.Values[1] or 0
                
                -- Если значение >= 30 и мы ещё не переключали пояса в этом цикле
                if value >= 30 and not beltSwitched then
                    beltSwitched = true
                    
                    -- Надеваем Petal Belt
                    local args1 = {
                        "Equip",
                        {
                            Category = "Accessory",
                            Type = "Petal Belt"
                        }
                    }
                    game:GetService("ReplicatedStorage").Events.ItemPackageEvent:InvokeServer(table.unpack(args1))
                    print("✅ Petal Belt надет (комбо: " .. value .. ")")
                    
                    -- Ждём 1 секунду
                    task.wait(1)
                    
                    -- Надеваем Coconut Belt
                    local args2 = {
                        "Equip",
                        {
                            Category = "Accessory",
                            Type = "Coconut Belt"
                        }
                    }
                    game:GetService("ReplicatedStorage").Events.ItemPackageEvent:InvokeServer(table.unpack(args2))
                    print("✅ Coconut Belt надет (комбо: " .. value .. ")")
                end
                
                -- Если значение упало ниже 30 (после сброса комбо), сбрасываем флаг
                if value < 30 then
                    beltSwitched = false
                end
            end
        end
    end
end)
