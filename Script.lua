-- Made by pogreshim
-- Dollarware UI
local uiLoader = loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/dollarware/main/library.lua'))
local ui = uiLoader({
    rounding = false,
    theme = 'cherry',
    smoothDragging = false
})

ui.autoDisableToggles = true

local window = ui.newWindow({
    text = 'LX49 Release // made by ForgottenHuman',
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
local EggHatchingRemote = ReplicatedStorage:WaitForChild("EggHatchingRemote")
local HatchServer = EggHatchingRemote:WaitForChild("HatchServer")
local PotionEvent = ReplicatedStorage:WaitForChild("PotionEvent")
local RainbowPotion1 = PotionEvent:WaitForChild("RainbowPotion1")
local LuckPotion3 = PotionEvent:WaitForChild("LuckPotion3")
local LuckPotion2 = PotionEvent:WaitForChild("LuckPotion2")

local Workspace = game:GetService("Workspace")
local EggsFolder = Workspace:WaitForChild("Eggs")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Мгновенные ProximityPrompt
for _, prompt in ipairs(game:GetDescendants()) do
    if prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
    end
end

game.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") then
        obj.HoldDuration = 0
    end
end)

-- Переменные
local tapConnection
local superTapConnection
local rebirthConnection
local antiAFKConnection
local hatchConnection
local potionConnection
local infJumpEnabled = false
local menuVisible = true
local selectedEggs = {}
local eggToggles = {}
local selectedPotion = "RainbowPotion1"
local selectedRebirth = 1

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

-- Открытие/закрытие меню на RightAlt
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        menuVisible = not menuVisible
        window:SetVisible(menuVisible)
    end
end)

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
                tapConnection = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        TapEvent:FireServer()
                    end)
                end)
            else
                if tapConnection then
                    tapConnection:Disconnect()
                    tapConnection = nil
                end
            end
        end)
        
        local superTapToggle = section:addToggle({
            text = 'Auto SuperTap',
            state = false
        })
        
        superTapToggle:bindToEvent('onToggle', function(newState)
            if newState then
                superTapConnection = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        SuperTapEvent:FireServer()
                    end)
                end)
            else
                if superTapConnection then
                    superTapConnection:Disconnect()
                    superTapConnection = nil
                end
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
            local rebirthButton = section2:addButton({
                text = option.name,
                style = 'small'
            }, function()
                selectedRebirth = option.value
                ui.notify({
                    title = 'Rebirth',
                    message = 'Selected: ' .. option.name,
                    duration = 2
                })
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
                rebirthConnection = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        RebirthEvent:FireServer(selectedRebirth)
                    end)
                end)
            else
                if rebirthConnection then
                    rebirthConnection:Disconnect()
                    rebirthConnection = nil
                end
            end
        end)
        
        section2:addButton({
            text = 'Rebirth Once',
            style = 'small'
        }, function()
            pcall(function()
                RebirthEvent:FireServer(selectedRebirth)
            end)
            ui.notify({
                title = 'Rebirth',
                message = 'Rebirthed once!',
                duration = 2
            })
        end):setTooltip('Rebirth one time with selected multiplier')
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
            pcall(function()
                local char = LocalPlayer.Character
                if not char then
                    LocalPlayer.CharacterAdded:Wait()
                    char = LocalPlayer.Character
                end
                
                local hrp = char:WaitForChild("HumanoidRootPart", 5)
                if not hrp then return end
                
                local ascensions = Workspace:WaitForChild("Ascensions", 5)
                if not ascensions then return end
                
                local ascend = ascensions:WaitForChild("Ascend", 5)
                if not ascend then return end
                
                local mainPart = ascend:WaitForChild("Main", 5)
                if not mainPart then return end
                
                local targetCFrame = mainPart.CFrame + Vector3.new(0, 3, 0)
                
                local distance = (hrp.Position - targetCFrame.Position).Magnitude
                local speed = math.max(distance / 0.5, 100)
                
                local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
                tween:Play()
                tween.Completed:Wait()
            end)
            ui.notify({
                title = 'Teleport',
                message = 'Teleported to Ascend!',
                duration = 2
            })
        end):setTooltip('Teleports you to workspace.Ascensions.Ascend.Main')
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
        
        local eggList = EggsFolder:GetChildren()
        table.sort(eggList, function(a, b) return a.Name < b.Name end)
        
        for _, egg in ipairs(eggList) do
            local eggName = egg.Name
            local eggToggle = section:addToggle({
                text = eggName,
                state = false
            })
            
            eggToggle:bindToEvent('onToggle', function(newState)
                if newState then
                    selectedEggs[eggName] = true
                else
                    selectedEggs[eggName] = nil
                end
            end)
            
            table.insert(eggToggles, eggToggle)
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
            for _, egg in ipairs(EggsFolder:GetChildren()) do
                selectedEggs[egg.Name] = true
            end
            ui.notify({
                title = 'Eggs',
                message = 'All eggs selected!',
                duration = 2
            })
        end):setTooltip('Select all available eggs')
        
        section2:addButton({
            text = 'Deselect All Eggs',
            style = 'small'
        }, function()
            selectedEggs = {}
            ui.notify({
                title = 'Eggs',
                message = 'All eggs deselected!',
                duration = 2
            })
        end):setTooltip('Deselect all eggs')
        
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
                hatchConnection = RunService.Heartbeat:Connect(function()
                    for eggName, _ in pairs(selectedEggs) do
                        pcall(function()
                            local egg = EggsFolder:FindFirstChild(eggName)
                            if egg then
                                HatchServer:InvokeServer(egg)
                            end
                        end)
                    end
                end)
            else
                if hatchConnection then
                    hatchConnection:Disconnect()
                    hatchConnection = nil
                end
            end
        end)
        
        section2:addButton({
            text = 'Hatch Selected Once',
            style = 'small'
        }, function()
            for eggName, _ in pairs(selectedEggs) do
                pcall(function()
                    local egg = EggsFolder:FindFirstChild(eggName)
                    if egg then
                        HatchServer:InvokeServer(egg)
                    end
                end)
            end
            ui.notify({
                title = 'Hatch',
                message = 'Hatched all selected eggs once!',
                duration = 2
            })
        end):setTooltip('Hatch all selected eggs one time')
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
        
        section:addButton({
            text = 'Rainbow Potion',
            style = 'large'
        }, function()
            selectedPotion = "RainbowPotion1"
            ui.notify({
                title = 'Potion Selected',
                message = 'Rainbow Potion selected!',
                duration = 2
            })
        end):setTooltip('Select Rainbow Potion (465)')
        
        section:addButton({
            text = 'x4 Luck Potion',
            style = 'large'
        }, function()
            selectedPotion = "LuckPotion3"
            ui.notify({
                title = 'Potion Selected',
                message = 'x4 Luck Potion selected!',
                duration = 2
            })
        end):setTooltip('Select x4 Luck Potion (14498)')
        
        section:addButton({
            text = 'x3 Luck Potion',
            style = 'large'
        }, function()
            selectedPotion = "LuckPotion2"
            ui.notify({
                title = 'Potion Selected',
                message = 'x3 Luck Potion selected!',
                duration = 2
            })
        end):setTooltip('Select x3 Luck Potion (6702)')
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
                potionConnection = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        if selectedPotion == "RainbowPotion1" then
                            RainbowPotion1:FireServer(465)
                        elseif selectedPotion == "LuckPotion3" then
                            LuckPotion3:FireServer(14498)
                        elseif selectedPotion == "LuckPotion2" then
                            LuckPotion2:FireServer(6702)
                        end
                    end)
                end)
            else
                if potionConnection then
                    potionConnection:Disconnect()
                    potionConnection = nil
                end
            end
        end)
        
        section2:addButton({
            text = 'Buy Once',
            style = 'large'
        }, function()
            pcall(function()
                if selectedPotion == "RainbowPotion1" then
                    RainbowPotion1:FireServer(465)
                    ui.notify({
                        title = 'Potion',
                        message = 'Bought Rainbow Potion!',
                        duration = 2
                    })
                elseif selectedPotion == "LuckPotion3" then
                    LuckPotion3:FireServer(14498)
                    ui.notify({
                        title = 'Potion',
                        message = 'Bought x4 Luck Potion!',
                        duration = 2
                    })
                elseif selectedPotion == "LuckPotion2" then
                    LuckPotion2:FireServer(6702)
                    ui.notify({
                        title = 'Potion',
                        message = 'Bought x3 Luck Potion!',
                        duration = 2
                    })
                end
            end)
        end):setTooltip('Buy the selected potion once')
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
                local VirtualUser = game:GetService("VirtualUser")
                antiAFKConnection = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end)
                end)
            else
                if antiAFKConnection then
                    antiAFKConnection:Disconnect()
                    antiAFKConnection = nil
                end
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
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = newValue
                    end
                end
            end)
        end):setTooltip('Set your walkspeed (16 - 500)')
        
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
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.JumpPower = newValue
                    end
                end
            end)
        end):setTooltip('Set your jump power (50 - 500)')
    end
    
    local section3 = miscMenu:addSection({
        text = 'Jump',
        side = 'right'
    })
    
    do
        section3:addLabel({
            text = 'Infinite Jump'
        })
        
        local function enableInfJump(char)
            local humanoid = char:WaitForChild("Humanoid")
            
            task.spawn(function()
                while infJumpEnabled do
                    pcall(function()
                        if humanoid and humanoid.Parent then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end)
                    task.wait()
                end
            end)
        end
        
        local infJumpToggle = section3:addToggle({
            text = 'Infinite Jump',
            state = false
        })
        
        infJumpToggle:bindToEvent('onToggle', function(newState)
            infJumpEnabled = newState
            if newState then
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        enableInfJump(char)
                    end
                end)
            end
        end)
        
        LocalPlayer.CharacterAdded:Connect(function(char)
            if infJumpEnabled then
                enableInfJump(char)
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
        section:addLabel({
            text = ' '
        })
        
        section:addLabel({
            text = 'add new undetect'
        })
        
        section:addLabel({
            text = 'add potions'
        })
        
        section:addLabel({
            text = 'add 46 eggs hatch'
        })
        
        section:addLabel({
            text = 'add Anti-Afk'
        })
        
        section:addLabel({
            text = 'add Tp to Ascend'
        })
    end
    
    local section2 = infoMenu:addSection({
        text = '--CONTACTS--',
        side = 'right'
    })
    
    do
        section2:addLabel({
            text = ' '
        })
        
        section2:addLabel({
            text = 'My Telegram: @Kyoex'
        })
        
        section2:addLabel({
            text = 'My Discord: eqstez'
        })
    end
end

-- Очистка при закрытии
window:bindToEvent('onClose', function()
    if tapConnection then tapConnection:Disconnect() end
    if superTapConnection then superTapConnection:Disconnect() end
    if rebirthConnection then rebirthConnection:Disconnect() end
    if antiAFKConnection then antiAFKConnection:Disconnect() end
    if hatchConnection then hatchConnection:Disconnect() end
    if potionConnection then potionConnection:Disconnect() end
end)
