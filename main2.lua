physics = require "physics"

physics.start()

local newGame = 1
local levelSelect = 2

function mainMenu()
    mainMenuGroup = display.newGroup()
    
    local mainMenuBG = display.newImage("mainMenuBG.png")
    mainMenuGroup:insert(mainMenuBG)

    local newGameButton = display.newImage("newGameButton.png", 100, 100)
    newGameButton.id = newGame
    mainMenuGroup:insert(newGameButton)
    
    local levelSelectButton = display.newImage("levelSelectButton.png", 100, 200)
    levelSelectButton.id = levelSelect
    mainMenuGroup:insert(levelSelectButton)
    
    newGameButton:addEventListener("touch", init)
    levelSelectButton:addEventListener("touch", init)
    
end

function levelSelectMenu()
    levelSelectGroup = display.newGroup()
end

function inGameMenu()
    inGameMenuGroup = display.newGroup()
end

function inGame()
    inGameGroup = display.newGroup()
end

function init(event)
    gameMode = event.target.id
    
    if mode == newGame then
        mainMenuGroup:removeSelf()
        timer.performWithDelay(800, inGame, 1)
    elseif mode == levelSelect then
        --local levelSelectAnimation = transition.to(mainMenuGroup, {alpha = 0, xScale = 1, yScale = 1, time = 400})
        levelSelectMenu()
    end
end

mainMenu()