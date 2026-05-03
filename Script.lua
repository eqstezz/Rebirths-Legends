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
    size = Vector2.new(550, 400),
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
local selectedPotion = "RainbowPotion1"

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
            text = 'Auto Rebirth'
        })
        
        local rebirthToggle = section2:addToggle({
            text = 'Auto Rebirth',
            state = false
        })
        
        rebirthToggle:bindToEvent('onToggle', function(newState)
            if newState then
                rebirthConnection = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        RebirthEvent:FireServer(1e28)
                    end)
                end)
            else
                if rebirthConnection then
                    rebirthConnection:Disconnect()
                    rebirthConnection = nil
                end
            end
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
        text = 'Add Egg',
        side = 'left'
    })
    
    do
        section:addLabel({
            text = 'Enter egg name and click Add'
        })
        
        local eggTextbox = section:addTextbox({
            text = 'Egg Name'
        })
        
        local addedEggsLabel = section:addLabel({
            text = 'Selected Eggs: 0'
        })
        
        section:addButton({
            text = 'Add Egg',
            style = 'large'
        }, function()
            local eggName = eggTextbox:getText()
            if eggName and eggName ~= '' then
                local egg = EggsFolder:FindFirstChild(eggName)
                if egg then
                    if not selectedEggs[eggName] then
                        selectedEggs[eggName] = true
                        ui.notify({
                            title = 'Egg Added',
                            message = 'Added: ' .. eggName,
                            duration = 2
                        })
                    else
                        ui.notify({
                            title = 'Error',
                            message = 'Egg already added!',
                            duration = 2
                        })
                    end
                else
                    ui.notify({
                        title = 'Error',
                        message = 'Egg not found!',
                        duration = 2
                    })
                end
            end
            local count = 0
            for _ in pairs(selectedEggs) do count = count + 1 end
            addedEggsLabel:setText('Selected Eggs: ' .. tostring(count))
        end):setTooltip('Add an egg to the hatching list')
    end
    
    local section2 = eggsMenu:addSection({
        text = 'Preset Eggs',
        side = 'left'
    })
    
    do
        section2:addLabel({
            text = 'Quick Add Eggs'
        })
        
        section2:addButton({
            text = 'Add All Eggs',
            style = 'small'
        }, function()
            for _, egg in ipairs(EggsFolder:GetChildren()) do
                selectedEggs[egg.Name] = true
            end
            local count = 0
            for _ in pairs(selectedEggs) do count = count + 1 end
            addedEggsLabel:setText('Selected Eggs: ' .. tostring(count))
            ui.notify({
                title = 'Eggs',
                message = 'All eggs added!',
                duration = 2
            })
        end):setTooltip('Add all available eggs')
        
        section2:addButton({
            text = 'Add Alien Egg',
            style = 'small'
        }, function()
            local eggName = "Alien Egg"
            if EggsFolder:FindFirstChild(eggName) then
                selectedEggs[eggName] = true
                local count = 0
                for _ in pairs(selectedEggs) do count = count + 1 end
                addedEggsLabel:setText('Selected Eggs: ' .. tostring(count))
                ui.notify({
                    title = 'Egg Added',
                    message = 'Alien Egg added!',
                    duration = 2
                })
            end
        end)
        
        section2:addButton({
            text = 'Add Angelic Egg',
            style = 'small'
        }, function()
            local eggName = "Angelic Egg"
            if EggsFolder:FindFirstChild(eggName) then
                selectedEggs[eggName] = true
                local count = 0
                for _ in pairs(selectedEggs) do count = count + 1 end
                addedEggsLabel:setText('Selected Eggs: ' .. tostring(count))
            end
        end)
    end
    
    local section3 = eggsMenu:addSection({
        text = 'Auto Hatch',
        side = 'right'
    })
    
    do
        section3:addLabel({
            text = 'Start/Stop Hatching'
        })
        
        section3:addButton({
            text = 'Clear Egg List',
            style = 'small'
        }, function()
            selectedEggs = {}
            local count = 0
            for _ in pairs(selectedEggs) do count = count + 1 end
            addedEggsLabel:setText('Selected Eggs: ' .. tostring(count))
            ui.notify({
                title = 'Eggs',
                message = 'Egg list cleared!',
                duration = 2
            })
        end):setTooltip('Clear all selected eggs')
        
        local hatchToggle = section3:addToggle({
            text = 'Auto Hatch',
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
    end
    
    local section4 = eggsMenu:addSection({
        text = 'Individual Egg Control',
        side = 'right'
    })
    
    do
        section4:addLabel({
            text = 'Auto Hatch Single Egg'
        })
        
        local personalEggTextbox = section4:addTextbox({
            text = 'Single Egg Name'
        })
        
        local singleHatchToggle = section4:addToggle({
            text = 'Auto Hatch (Single)',
            state = false
        })
        
        local singleHatchConnection
        
        singleHatchToggle:bindToEvent('onToggle', function(newState)
            if newState then
                local singleEggName = personalEggTextbox:getText()
                singleHatchConnection = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local egg = EggsFolder:FindFirstChild(singleEggName)
                        if egg then
                            HatchServer:InvokeServer(egg)
                        end
                    end)
                end)
            else
                if singleHatchConnection then
                    singleHatchConnection:Disconnect()
                    singleHatchConnection = nil
                end
            end
        end)
        
        section4:addButton({
            text = 'Hatch Once',
            style = 'small'
        }, function()
            local singleEggName = personalEggTextbox:getText()
            pcall(function()
                local egg = EggsFolder:FindFirstChild(singleEggName)
                if egg then
                    HatchServer:InvokeServer(egg)
                    ui.notify({
                        title = 'Hatch',
                        message = 'Hatched: ' .. singleEggName,
                        duration = 2
                    })
                end
            end)
        end):setTooltip('Hatch the specified egg once')
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
