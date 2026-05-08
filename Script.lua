-- Argonium v1 │By t.me/AgroniumGG
-- Dollarware UI
local uiLoader = loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/dollarware/main/library.lua'))
local ui = uiLoader({
    rounding = false,
    theme = 'cherry',
    smoothDragging = false
})

ui.autoDisableToggles = true

local window = ui.newWindow({
    text = 'Argonium v1 │By t.me/AgroniumGG',
    resize = true,
    size = Vector2.new(550, 500),
    position = nil
})

-- Сервисы
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TappingRemote = ReplicatedStorage:WaitForChild("TappingRemote")
local TapEvent = TappingRemote:WaitForChild("Tap")
local SuperTapEvent = TappingRemote:WaitForChild("SuperTap")
local RebirthEvent = ReplicatedStorage:WaitForChild("Rebirth")
local AscendEvent = ReplicatedStorage:WaitForChild("Ascend")
local EggHatchingRemote = ReplicatedStorage:WaitForChild("EggHatchingRemote")
local HatchServer = EggHatchingRemote:WaitForChild("HatchServer")
local PotionEvent = ReplicatedStorage:WaitForChild("PotionEvent")
local RainbowPotion1 = PotionEvent:WaitForChild("RainbowPotion1")
local LuckPotion3 = PotionEvent:WaitForChild("LuckPotion3")
local LuckPotion2 = PotionEvent:WaitForChild("LuckPotion2")
local TapPotion = PotionEvent:WaitForChild("TapPotion")
local GemsPotion = PotionEvent:WaitForChild("GemsPotion")
local LuckPotion = PotionEvent:WaitForChild("LuckPotion")

local Workspace = game:GetService("Workspace")
local EggsFolder = Workspace:WaitForChild("Eggs")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Мгновенные ProximityPrompt (оптимизировано)
local function setHoldDuration(obj)
    if obj:IsA("ProximityPrompt") then
        pcall(function() obj.HoldDuration = 0 end)
    end
end

for _, obj in ipairs(game:GetDescendants()) do
    setHoldDuration(obj)
end

game.DescendantAdded:Connect(setHoldDuration)

-- Переменные
local tapConnection
local superTapConnection
local rebirthConnection
local ascendConnection
local antiAFKConnection
local hatchConnection
local potionConnection
local infJumpEnabled = false
local menuVisible = true
local selectedEggs = {}
local selectedPotion = "RainbowPotion1"
local selectedRebirth = 1
local hatchDelay = 0.1
local lastAscendTime = 0
local lastRebirthTime = 0
local lastPotionTime = 0
local lastHatchTime = 0
local ASCEND_COOLDOWN = 1
local REBIRTH_COOLDOWN = 1
local POTION_COOLDOWN = 0.5
local HATCH_COOLDOWN = 0.05

-- Кэширование
local cachedAscendPart = nil
local cachedAscendMain = nil
local lastAscendCacheTime = 0
local ASCEND_CACHE_DURATION = 5

local function getAscendPart()
    local now = tick()
    if cachedAscendMain and (now - lastAscendCacheTime) < ASCEND_CACHE_DURATION then
        return cachedAscendMain
    end
    local ascensions = Workspace:FindFirstChild("Ascensions")
    if ascensions then
        local ascend = ascensions:FindFirstChild("Ascend")
        if ascend then
            local mainPart = ascend:FindFirstChild("Main")
            if mainPart then
                cachedAscendMain = mainPart
                lastAscendCacheTime = now
                return mainPart
            end
        end
    end
    return nil
end

local cachedEggs = {}
local lastEggCacheTime = 0
local EGG_CACHE_DURATION = 10

local function getCachedEggs()
    local now = tick()
    if #cachedEggs > 0 and (now - lastEggCacheTime) < EGG_CACHE_DURATION then
        return cachedEggs
    end
    cachedEggs = {}
    for _, egg in ipairs(EggsFolder:GetChildren()) do
        if egg:IsA("Model") or egg:IsA("Part") or egg:IsA("MeshPart") then
            table.insert(cachedEggs, egg)
        end
    end
    lastEggCacheTime = now
    return cachedEggs
end

-- Таблица rebirth множителей
local rebirthOptions = {
    {name = "x1", value = 1},
    {name = "x10", value = 10},
    {name = "x50", value = 50},
    {name = "x100", value = 100},
    {name = "x250", value = 250},
    {name = "x500", value = 500},
    {name = "x1k", value = 1000},
    {name = "x5k", value = 5000},
    {name = "x10k", value = 10000},
    {name = "x100k", value = 100000},
    {name = "x1m", value = 1000000},
    {name = "x10m", value = 10000000},
    {name = "x100m", value = 100000000},
    {name = "x1b", value = 1000000000},
    {name = "x10b", value = 10000000000},
    {name = "x100b", value = 100000000000},
    {name = "x1t", value = 1000000000000},
    {name = "x10t", value = 10000000000000},
    {name = "x99.9t", value = 99900000000000},
    {name = "x1Qa", value = 1000000000000000},
    {name = "x100Qa", value = 100000000000000000},
    {name = "x10Qi", value = 10000000000000000000},
    {name = "x1Sx", value = 1e21},
    {name = "x10Sx", value = 1e22},
    {name = "x99.9Sx", value = 9.99e22},
    {name = "x1Sp", value = 1e24},
    {name = "x100Sp", value = 1e26},
    {name = "x1Oc", value = 1e27},
    {name = "x5Oc", value = 5e27},
    {name = "x10Oc", value = 1e28},
}

-- Оптимизированная функция нажатия E
local function pressE()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
end

-- Открытие/закрытие меню на RightAlt
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        menuVisible = not menuVisible
        pcall(function() window:SetVisible(menuVisible) end)
    end
end)

-- Оптимизированная функция телепорта
local function teleportToPart(part)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function()
        hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
    end)
end

-- Меню Auto Farm
local menu = window:addMenu({
    text = 'Auto Farm'
})

do
    local section = menu:addSection({
        text = 'Auto Click',
        side = 'left'
    })
    
    do
        section:addLabel({
            text = 'Auto Tap / Super Tap'
        })
        
        local tapToggle = section:addToggle({
            text = 'Auto Tap',
            state = false
        })
        
        tapToggle:bindToEvent('onToggle', function(newState)
            if newState then
                if tapConnection then tapConnection:Disconnect() end
                local lastTap = 0
                tapConnection = RunService.Heartbeat:Connect(function()
                    local now = tick()
                    if now - lastTap >= 0.001 then
                        lastTap = now
                        pcall(function() TapEvent:FireServer() end)
                    end
                end)
            else
                if tapConnection then tapConnection:Disconnect(); tapConnection = nil end
            end
        end)
        
        local superTapToggle = section:addToggle({
            text = 'Auto SuperTap',
            state = false
        })
        
        superTapToggle:bindToEvent('onToggle', function(newState)
            if newState then
                if superTapConnection then superTapConnection:Disconnect() end
                local lastSuperTap = 0
                superTapConnection = RunService.Heartbeat:Connect(function()
                    local now = tick()
                    if now - lastSuperTap >= 0.001 then
                        lastSuperTap = now
                        pcall(function() SuperTapEvent:FireServer() end)
                    end
                end)
            else
                if superTapConnection then superTapConnection:Disconnect(); superTapConnection = nil end
            end
        end)
    end
    
    local section2 = menu:addSection({
        text = 'Rebirth',
        side = 'left'
    })
    
    do
        section2:addLabel({
            text = 'Select Rebirth Multiplier'
        })
        
        for _, option in ipairs(rebirthOptions) do
            section2:addButton({
                text = option.name,
                style = 'small'
            }, function()
                selectedRebirth = option.value
            end)
        end
        
        section2:addLabel({
            text = ' '
        })
        
        section2:addLabel({
            text = 'Auto Rebirth Control'
        })
        
        local rebirthToggle = section2:addToggle({
            text = 'Auto Rebirth',
            state = false
        })
        
        rebirthToggle:bindToEvent('onToggle', function(newState)
            if newState then
                if rebirthConnection then rebirthConnection:Disconnect() end
                rebirthConnection = RunService.Heartbeat:Connect(function()
                    local now = tick()
                    if now - lastRebirthTime >= REBIRTH_COOLDOWN then
                        lastRebirthTime = now
                        pcall(function() RebirthEvent:FireServer(selectedRebirth) end)
                    end
                end)
            else
                if rebirthConnection then rebirthConnection:Disconnect(); rebirthConnection = nil end
            end
        end)
        
        section2:addButton({
            text = 'Rebirth Once',
            style = 'small'
        }, function()
            pcall(function() RebirthEvent:FireServer(selectedRebirth) end)
        end)
    end
    
    local section3 = menu:addSection({
        text = 'Teleport',
        side = 'right'
    })
    
    do
        section3:addLabel({
            text = 'Teleport to Ascend'
        })
        
        section3:addButton({
            text = 'Teleport to Ascend',
            style = 'large'
        }, function()
            local mainPart = getAscendPart()
            if mainPart then
                teleportToPart(mainPart)
            end
        end)
    end
    
    local section4 = menu:addSection({
        text = 'Ascend',
        side = 'right'
    })
    
    do
        section4:addLabel({
            text = 'Auto Ascend'
        })
        
        local ascendToggle = section4:addToggle({
            text = 'Auto Ascend',
            state = false
        })
        
        ascendToggle:bindToEvent('onToggle', function(newState)
            if newState then
                if ascendConnection then ascendConnection:Disconnect() end
                ascendConnection = RunService.Heartbeat:Connect(function()
                    local now = tick()
                    if now - lastAscendTime >= ASCEND_COOLDOWN then
                        lastAscendTime = now
                        pcall(function()
                            local mainPart = getAscendPart()
                            if mainPart then
                                teleportToPart(mainPart)
                                AscendEvent:FireServer()
                                pressE()
                            end
                        end)
                    end
                end)
            else
                if ascendConnection then ascendConnection:Disconnect(); ascendConnection = nil end
            end
        end)
        
        section4:addButton({
            text = 'Ascend Once',
            style = 'small'
        }, function()
            pcall(function()
                local mainPart = getAscendPart()
                if mainPart then
                    teleportToPart(mainPart)
                    AscendEvent:FireServer()
                    pressE()
                end
            end)
        end)
    end
end

-- Меню Eggs
local eggsMenu = window:addMenu({
    text = 'Eggs'
})

do
    local section = eggsMenu:addSection({
        text = 'Egg List',
        side = 'left'
    })
    
    do
        section:addLabel({
            text = 'Select eggs to auto hatch'
        })
        
        local eggList = getCachedEggs()
        table.sort(eggList, function(a, b) return a.Name < b.Name end)
        
        for _, egg in ipairs(eggList) do
            local eggName = egg.Name
            section:addToggle({
                text = eggName,
                state = false
            }):bindToEvent('onToggle', function(newState)
                if newState then
                    selectedEggs[eggName] = true
                else
                    selectedEggs[eggName] = nil
                end
            end)
        end
    end
    
    local section2 = eggsMenu:addSection({
        text = 'Controls',
        side = 'right'
    })
    
    do
        section2:addLabel({
            text = 'Manage selected eggs'
        })
        
        section2:addButton({
            text = 'Select All Eggs',
            style = 'small'
        }, function()
            for _, egg in ipairs(getCachedEggs()) do
                selectedEggs[egg.Name] = true
            end
        end)
        
        section2:addButton({
            text = 'Deselect All Eggs',
            style = 'small'
        }, function()
            selectedEggs = {}
        end)
        
        section2:addLabel({
            text = ' '
        })
        
        section2:addLabel({
            text = 'Hatch Delay'
        })
        
        section2:addSlider({
            text = 'Delay',
            min = 0.01,
            max = 0.5,
            step = 0.01,
            val = 0.1
        }, function(newValue)
            hatchDelay = math.max(0.01, newValue)
        end)
        
        section2:addLabel({
            text = ' '
        })
        
        section2:addLabel({
            text = 'Auto Hatch Control'
        })
        
        local hatchToggle = section2:addToggle({
            text = 'Auto Hatch Selected Eggs',
            state = false
        })
        
        hatchToggle:bindToEvent('onToggle', function(newState)
            if newState then
                if hatchConnection then hatchConnection:Disconnect() end
                local eggList = {}
                local lastUpdate = 0
                
                hatchConnection = RunService.Heartbeat:Connect(function()
                    local now = tick()
                    if now - lastHatchTime >= hatchDelay then
                        lastHatchTime = now
                        
                        if now - lastUpdate > 5 then
                            eggList = {}
                            for name in pairs(selectedEggs) do
                                table.insert(eggList, name)
                            end
                            lastUpdate = now
                        end
                        
                        if #eggList == 0 then
                            for name in pairs(selectedEggs) do
                                table.insert(eggList, name)
                            end
                        end
                        
                        for _, eggName in ipairs(eggList) do
                            local egg = EggsFolder:FindFirstChild(eggName)
                            if egg then
                                pcall(function() HatchServer:InvokeServer(egg) end)
                            end
                        end
                    end
                end)
            else
                if hatchConnection then hatchConnection:Disconnect(); hatchConnection = nil end
            end
        end)
        
        section2:addButton({
            text = 'Hatch Selected Once',
            style = 'small'
        }, function()
            for eggName in pairs(selectedEggs) do
                local egg = EggsFolder:FindFirstChild(eggName)
                if egg then
                    pcall(function() HatchServer:InvokeServer(egg) end)
                end
            end
        end)
    end
end

-- Меню Potions
local potionsMenu = window:addMenu({
    text = 'Potions'
})

do
    local section = potionsMenu:addSection({
        text = 'Select Potion',
        side = 'left'
    })
    
    do
        section:addLabel({
            text = 'Choose a potion to auto buy'
        })
        
        local potionButtons = {
            {text = 'Rainbow Potion', value = "RainbowPotion1"},
            {text = 'x4 Luck Potion', value = "LuckPotion3"},
            {text = 'x3 Luck Potion', value = "LuckPotion2"},
            {text = 'Tap Potion', value = "TapPotion"},
            {text = 'Gems Potion', value = "GemsPotion"},
            {text = 'Luck Potion', value = "LuckPotion"},
        }
        
        for _, btn in ipairs(potionButtons) do
            section:addButton({
                text = btn.text,
                style = 'large'
            }, function()
                selectedPotion = btn.value
            end)
        end
    end
    
    local section2 = potionsMenu:addSection({
        text = 'Auto Buy Potion',
        side = 'right'
    })
    
    do
        section2:addLabel({
            text = 'Auto Buy Selected Potion'
        })
        
        local potionToggle = section2:addToggle({
            text = 'Auto Buy Potion',
            state = false
        })
        
        potionToggle:bindToEvent('onToggle', function(newState)
            if newState then
                if potionConnection then potionConnection:Disconnect() end
                potionConnection = RunService.Heartbeat:Connect(function()
                    local now = tick()
                    if now - lastPotionTime >= POTION_COOLDOWN then
                        lastPotionTime = now
                        pcall(function()
                            if selectedPotion == "RainbowPotion1" then
                                RainbowPotion1:FireServer(465)
                            elseif selectedPotion == "LuckPotion3" then
                                LuckPotion3:FireServer(14498)
                            elseif selectedPotion == "LuckPotion2" then
                                LuckPotion2:FireServer(6702)
                            elseif selectedPotion == "TapPotion" then
                                TapPotion:FireServer(600)
                            elseif selectedPotion == "GemsPotion" then
                                GemsPotion:FireServer(600)
                            elseif selectedPotion == "LuckPotion" then
                                LuckPotion:FireServer(600)
                            end
                        end)
                    end
                end)
            else
                if potionConnection then potionConnection:Disconnect(); potionConnection = nil end
            end
        end)
        
        section2:addButton({
            text = 'Buy Once',
            style = 'large'
        }, function()
            pcall(function()
                if selectedPotion == "RainbowPotion1" then RainbowPotion1:FireServer(465)
                elseif selectedPotion == "LuckPotion3" then LuckPotion3:FireServer(14498)
                elseif selectedPotion == "LuckPotion2" then LuckPotion2:FireServer(6702)
                elseif selectedPotion == "TapPotion" then TapPotion:FireServer(600)
                elseif selectedPotion == "GemsPotion" then GemsPotion:FireServer(600)
                elseif selectedPotion == "LuckPotion" then LuckPotion:FireServer(600)
                end
            end)
        end)
    end
end

-- Меню Misc
local miscMenu = window:addMenu({
    text = 'Misc'
})

do
    local section = miscMenu:addSection({
        text = 'Player',
        side = 'left'
    })
    
    do
        section:addLabel({
            text = 'Anti AFK'
        })
        
        local antiAFKToggle = section:addToggle({
            text = 'Anti AFK',
            state = false
        })
        
        antiAFKToggle:bindToEvent('onToggle', function(newState)
            if newState then
                if antiAFKConnection then antiAFKConnection:Disconnect() end
                local VirtualUser = game:GetService("VirtualUser")
                local lastAFK = 0
                antiAFKConnection = RunService.Heartbeat:Connect(function()
                    local now = tick()
                    if now - lastAFK >= 60 then
                        lastAFK = now
                        pcall(function()
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton2(Vector2.new())
                        end)
                    end
                end)
            else
                if antiAFKConnection then antiAFKConnection:Disconnect(); antiAFKConnection = nil end
            end
        end)
    end
    
    local section2 = miscMenu:addSection({
        text = 'Movement',
        side = 'left'
    })
    
    do
        section2:addLabel({
            text = 'WalkSpeed'
        })
        
        section2:addSlider({
            text = 'WalkSpeed',
            min = 16,
            max = 500,
            step = 1,
            val = 16
        }, function(newValue)
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = newValue
                end
            end
        end)
        
        section2:addLabel({
            text = 'Jump Power'
        })
        
        section2:addSlider({
            text = 'Jump Power',
            min = 50,
            max = 500,
            step = 1,
            val = 50
        }, function(newValue)
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.JumpPower = newValue
                end
            end
        end)
    end
    
    local section3 = miscMenu:addSection({
        text = 'Jump',
        side = 'right'
    })
    
    do
        section3:addLabel({
            text = 'Infinite Jump'
        })
        
        local infJumpToggle = section3:addToggle({
            text = 'Infinite Jump',
            state = false
        })
        
        infJumpToggle:bindToEvent('onToggle', function(newState)
            infJumpEnabled = newState
            if newState then
                local function setupInfJump(char)
                    local humanoid = char:WaitForChild("Humanoid")
                    humanoid.StateChanged:Connect(function(old, new)
                        if infJumpEnabled and new == Enum.HumanoidStateType.Landed then
                                            task.wait(0.05)
                            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
                        end
                    end)
                end
                if LocalPlayer.Character then
                    setupInfJump(LocalPlayer.Character)
                end
                LocalPlayer.CharacterAdded:Connect(function(char)
                    if infJumpEnabled then
                        setupInfJump(char)
                    end
                end)
            end
        end)
    end
end

-- Меню Info
local infoMenu = window:addMenu({
    text = 'Info'
})

do
    local section = infoMenu:addSection({
        text = '--UPDATES--',
        side = 'left'
    })
    
    do
        section:addLabel({text = ' '})
        section:addLabel({text = '[v1.0] Initial Release'})
        section:addLabel({text = '[v1.1] Added Potions'})
        section:addLabel({text = '[v1.2] Added Eggs Auto Hatch'})
        section:addLabel({text = '[v1.3] Added Anti-AFK'})
        section:addLabel({text = '[v1.4] Added TP to Ascend'})
        section:addLabel({text = '[v1.5] Added Egg List'})
        section:addLabel({text = '[v1.6] Added Rebirth Multipliers'})
        section:addLabel({text = '[v1.7] UI Improvements'})
        section:addLabel({text = '[v1.8] Added Hatch Delay'})
        section:addLabel({text = '[v1.9] Added Auto Ascend'})
        section:addLabel({text = '[v2.0] Performance Optimized'})
    end
    
    local section2 = infoMenu:addSection({
        text = '--FIXES--',
        side = 'left'
    })
    
    do
        section2:addLabel({text = ' '})
        section2:addLabel({text = '- Reduced lag significantly'})
        section2:addLabel({text = '- Added cooldowns'})
        section2:addLabel({text = '- Cached game objects'})
        section2:addLabel({text = '- Optimized loops'})
    end
    
    local section3 = infoMenu:addSection({
        text = '--CONTACTS--',
        side = 'right'
    })
    
    do
        section3:addLabel({text = ' '})
        section3:addLabel({text = 'Telegram: t.me/AgroniumGG'})
        section3:addLabel({text = 'Discord: eqstez'})
    end
end

-- Очистка при закрытии
window:bindToEvent('onClose', function()
    if tapConnection then tapConnection:Disconnect() end
    if superTapConnection then superTapConnection:Disconnect() end
    if rebirthConnection then rebirthConnection:Disconnect() end
    if ascendConnection then ascendConnection:Disconnect() end
    if antiAFKConnection then antiAFKConnection:Disconnect() end
    if hatchConnection then hatchConnection:Disconnect() end
    if potionConnection then potionConnection:Disconnect() end
end)
