physics = require "physics"
sprite = require "sprite"
audio = require "audio"

physics.start()

local newGame = 1
local levelSelect = 2
local soundState = 1
audio.setVolume(0.0)

function mainMenu()
    mainMenuGroup = display.newGroup()
    
    -- Load Background Image
    local mainMenuBG = display.newImage("mainMenuBG.png")
    mainMenuGroup:insert(mainMenuBG)

    -- Add buttons
    local newGameButton = display.newImage("newGameButton.png", (display.contentWidth / 2) - 48, (display.contentHeight / 2) + 60)
    newGameButton.id = newGame
    mainMenuGroup:insert(newGameButton)
    
    local levelSelectButton = display.newImage("levelSelectButton.png", (display.contentWidth / 2) - 48, (display.contentHeight / 2) + 120)
    levelSelectButton.id = levelSelect
    mainMenuGroup:insert(levelSelectButton)
    
    -- Add the sound option
    local soundButtonSheet = sprite.newSpriteSheet("SoundIcon.png", 30, 30)
    local soundButtonSet = sprite.newSpriteSet(soundButtonSheet, 1, 2)
    sprite.add(soundButtonSet, "off", 2, 1, 1000)
    sprite.add(soundButtonSet, "on", 1, 1, 1000)
    soundButton = sprite.newSprite(soundButtonSet)
    mainMenuGroup:insert(soundButton)
    soundButton.x = display.contentWidth - 50
    soundButton.y = 50
    soundButton:prepare("off")
    soundButton:play()
    
    -- Main Menu Background Music
    BGSound = audio.loadSound("song_of_storms.mp3")
    BGChannel = audio.play(BGSound, {loops = -1})
    
    newGameButton:addEventListener("touch", init)
    levelSelectButton:addEventListener("touch", init)
    soundButton:addEventListener("touch", toggleSound)
    
end

function levelSelectMenu()
    levelSelectGroup = display.newGroup()
    
    -- Load Background Image
    local levelSelectBG = display.newImage("levelSelectBG.png")
    levelSelectGroup:insert(levelSelectBG)
    
    
    -- Add level selection buttons
    local levelButtons = {}
    
    for i=1,4 do
        levelButtons[i] = display.newImage(("level" .. i .. "Button.png"), (((i - 1) % 5 ) + 1) * 120, 100 + ((math.floor(i / 5)) * 70))
        levelButtons[i].id = i
        levelSelectGroup:insert(levelButtons[i])
        levelButtons[i]:addEventLisenter("touch", loadLevel)
    end
    
end

function inGameMenu()
    inGameMenuGroup = display.newGroup()
end

function inGame()
    inGameGroup = display.newGroup()
end

function init(event)
    mode = event.target.id
    if mode == newGame then
        mainMenuGroup:removeSelf()
        timer.performWithDelay(800, inGame, 1)
    elseif mode == levelSelect then
        --local levelSelectAnimation = transition.to(mainMenuGroup, {alpha = 0, xScale = 1, yScale = 1, time = 400})
        levelSelectMenu()
    end
end

function toggleSound(event)
    if event.phase == "began" then
        if soundState == 2 then
            soundState = 1
            audio.setVolume(0.0)
            soundButton:prepare("off")
            soundButton:play()
        else
            soundState = 2
            audio.setVolume(1.0)
            soundButton:prepare("on")
            soundButton:play()
        end
    end
end

function loadLevel(event)
end

mainMenu()