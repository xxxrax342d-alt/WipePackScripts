-- Super Smoothie Tracker
-- Отслеживает наличие и оставшееся время баффа

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer

-- ==============================================
-- ПЕРЕМЕННЫЕ
-- ==============================================
local smoothieActive = false
local smoothieEndTime = 0
local smoothieStartTime = 0
local smoothieDuration = 1200 -- 20 минут в секундах

-- ==============================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА
-- ==============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SuperSmoothieTracker"
screenGui.Parent = game:GetService("CoreGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 80)
mainFrame.Position = UDim2.new(0, 10, 0, 150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 25)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 180, 100)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🥤 Super Smoothie"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -25, 0.5, -10)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = not screenGui.Enabled
end)

-- Статус
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.5, -5, 0, 20)
statusLabel.Position = UDim2.new(0, 8, 0, 35)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Статус:"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

local statusValue = Instance.new("TextLabel")
statusValue.Size = UDim2.new(0.5, -5, 0, 20)
statusValue.Position = UDim2.new(0.5, 0, 0, 35)
statusValue.BackgroundTransparency = 1
statusValue.Text = "⏳ Поиск..."
statusValue.TextColor3 = Color3.fromRGB(255, 255, 100)
statusValue.Font = Enum.Font.GothamBold
statusValue.TextSize = 12
statusValue.TextXAlignment = Enum.TextXAlignment.Left
statusValue.Parent = mainFrame

-- Время
local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(0.5, -5, 0, 20)
timeLabel.Position = UDim2.new(0, 8, 0, 55)
timeLabel.BackgroundTransparency = 1
timeLabel.Text = "Осталось:"
timeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
timeLabel.Font = Enum.Font.Gotham
timeLabel.TextSize = 12
timeLabel.TextXAlignment = Enum.TextXAlignment.Left
timeLabel.Parent = mainFrame

local timeValue = Instance.new("TextLabel")
timeValue.Size = UDim2.new(0.5, -5, 0, 20)
timeValue.Position = UDim2.new(0.5, 0, 0, 55)
timeValue.BackgroundTransparency = 1
timeValue.Text = "--:--"
timeValue.TextColor3 = Color3.fromRGB(100, 255, 100)
timeValue.Font = Enum.Font.GothamBold
timeValue.TextSize = 12
timeValue.TextXAlignment = Enum.TextXAlignment.Left
timeValue.Parent = mainFrame

-- ==============================================
-- ФУНКЦИИ ДЛЯ РАБОТЫ С БАФФОМ
-- ==============================================

-- Получение времени окончания баффа из PlayerStats
local function getBuffEndTime()
    local stats = Player:FindFirstChild("PlayerStats")
    if not stats then return nil end
    
    local buffs = stats:FindFirstChild("Buffs")
    if not buffs then return nil end
    
    for _, buff in pairs(buffs:GetChildren()) do
        if buff.Name:find("SuperSmoothie") or buff.Name:find("Smoothie") then
            local endTime = buff:FindFirstChild("EndTime")
            if endTime then
                return endTime.Value
            end
        end
    end
    return nil
end

-- Проверка через визуальный объект в Particles
local function findSuperSmoothieObject()
    local particles = Workspace:FindFirstChild("Particles")
    if not particles then return nil end
    
    for _, obj in pairs(particles:GetChildren()) do
        if obj.Name:find("Super") and obj.Name:find("Smoothie") then
            return obj
        end
    end
    return nil
end

-- Проверка активности через иконку
local function isSmoothieIconActive()
    local smoothieObj = findSuperSmoothieObject()
    if not smoothieObj then return false end
    
    local icon = smoothieObj:FindFirstChild("Icon")
    if icon and icon:IsA("ImageLabel") then
        return icon.ImageTransparency == 0
    end
    
    local billboard = smoothieObj:FindFirstChild("BillboardGui")
    if billboard then
        return billboard.Enabled
    end
    
    return false
end

-- Форматирование времени
local function formatTime(seconds)
    if seconds <= 0 then return "00:00" end
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", mins, secs)
end

-- ==============================================
-- ОСНОВНОЙ ЦИКЛ ОТСЛЕЖИВАНИЯ
-- ==============================================
local function updateSmoothieStatus()
    local currentTime = tick()
    local endTime = getBuffEndTime()
    local remaining = 0
    
    if endTime then
        remaining = endTime - currentTime
    end
    
    -- Проверка активности через время
    if remaining > 0 then
        smoothieActive = true
        smoothieEndTime = endTime
        statusValue.Text = "✅ АКТИВЕН"
        statusValue.TextColor3 = Color3.fromRGB(100, 255, 100)
        timeValue.Text = formatTime(remaining)
        
        -- Изменение цвета в зависимости от оставшегося времени
        if remaining < 300 then -- меньше 5 минут
            timeValue.TextColor3 = Color3.fromRGB(255, 100, 100)
        elseif remaining < 600 then -- меньше 10 минут
            timeValue.TextColor3 = Color3.fromRGB(255, 200, 100)
        else
            timeValue.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
        
        -- Меняем цвет заголовка при активном баффе
        titleBar.BackgroundColor3 = Color3.fromRGB(255, 180, 100)
    else
        -- Проверка через визуальный объект как резервный метод
        local iconActive = isSmoothieIconActive()
        
        if iconActive then
            smoothieActive = true
            statusValue.Text = "✅ АКТИВЕН"
            statusValue.TextColor3 = Color3.fromRGB(100, 255, 100)
            timeValue.Text = "??:??"
            timeValue.TextColor3 = Color3.fromRGB(200, 200, 200)
            titleBar.BackgroundColor3 = Color3.fromRGB(255, 180, 100)
        else
            smoothieActive = false
            statusValue.Text = "❌ НЕ АКТИВЕН"
            statusValue.TextColor3 = Color3.fromRGB(200, 200, 200)
            timeValue.Text = "--:--"
            timeValue.TextColor3 = Color3.fromRGB(150, 150, 150)
            titleBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end
end

-- Запуск цикла обновления
spawn(function()
    while true do
        updateSmoothieStatus()
        task.wait(1) -- Обновление каждую секунду
    end
end)

-- ==============================================
-- ДОПОЛНИТЕЛЬНО: Отслеживание появления объекта
-- ==============================================
local function onSmoothieAdded(obj)
    if obj.Name:find("Super") and obj.Name:find("Smoothie") then
        print("🥤 Super Smoothie появился!")
        updateSmoothieStatus()
    end
end

local function onSmoothieRemoved(obj)
    if obj.Name:find("Super") and obj.Name:find("Smoothie") then
        print("🥤 Super Smoothie исчез!")
        updateSmoothieStatus()
    end
end

-- Отслеживание добавления/удаления объектов в Particles
local particles = Workspace:FindFirstChild("Particles")
if particles then
    particles.ChildAdded:Connect(onSmoothieAdded)
    particles.ChildRemoved:Connect(onSmoothieRemoved)
end

-- Отслеживание изменений в PlayerStats
local stats = Player:FindFirstChild("PlayerStats")
if stats then
    local buffs = stats:FindFirstChild("Buffs")
    if buffs then
        buffs.ChildAdded:Connect(function()
            task.wait(0.5)
            updateSmoothieStatus()
        end)
        buffs.ChildRemoved:Connect(function()
            task.wait(0.5)
            updateSmoothieStatus()
        end)
    end
end

-- ==============================================
-- ИНФОРМАЦИЯ О ЗАПУСКЕ
-- ==============================================
print("========================================")
print("🥤 Super Smoothie Tracker запущен")
print("========================================")
print("📊 Отслеживание:")
print("   - Статус баффа (активен/не активен)")
print("   - Оставшееся время (до 20 минут)")
print("   - Визуальная индикация")
print("========================================")
print("🖱️ Окно можно перетаскивать")
print("❌ Нажмите ✕ чтобы скрыть/показать")
print("========================================")
