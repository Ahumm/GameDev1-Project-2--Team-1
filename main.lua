physics = require "physics"
sprite = require "sprite"
audio = require "audio"
require "Shard"
require "Building"



--start the physical simulation
physics.start()
--physics.setDrawMode("hybrid")
--background color
local isSimulator = "simulator" == system.getInfo("environment")

-- Accelerator is not supported on Simulator
--
if isSimulator then
    MAX_EQ_POWER = 70
else
    MAX_EQ_POWER = 130
end

GROUND_HEIGHT = 90

--WORLD_WIDTH = 1000
local GRAVITY = 0
temp, GRAVITY = physics.getGravity()
WIDTH_MOD = 200
WORLD_WIDTH = 2000
WORLD_HEIGHT = display.contentHeight
MAP_UNIT = 20


local newGame = 1
local levelSelect = 2
local soundState = 1
audio.setVolume(0.0)
local selectedLevel = 1

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
    
    local levelsPerRow = 2
    
    for i=1,4 do
        levelButtons[i] = display.newImage(("level" .. i .. "Button.png"), (((i - 1) % levelsPerRow ) + 1) * 120, 100 + ((math.floor(i / (levelsPerRow + 1))) * 70))
        levelButtons[i].id = i
        levelSelectGroup:insert(levelButtons[i])
        levelButtons[i]:addEventListener("touch", startLevel)
    end
    
end

function inGameMenu()
    inGameMenuGroup = display.newGroup()
    mainMenu()
end

function inGame()
    inGameGroup = display.newGroup()
    
    local shakable = {}
    local shrapnel = {}
    local buildings = {}
    
    local background = display.newImage("DayBkgrd.png", 0, display.contentHeight - 500)
    background.x = display.contentCenterX
    inGameGroup:insert(background)
    
    
    -- Load level from file
    function loadLevel()
        local path = system.pathForFile("level" .. selectedLevel .. ".txt", system.ResourceDirectory)
        
        local fh, reason = io.open(path, "r")
        
        if fh then
            contents = fh:read("*a")
        else
            print("reason open failed " .. reason)
            return
        end
        
        buildingSets = {}
        shardSheets = {}
        
        local bldSheet = sprite.newSpriteSheet("building1.png", 200, 300)
        local bldSet = sprite.newSpriteSet(bldSheet, 1, 2)

        local shrdSheet = sprite.newSpriteSheet("building2_shrapnel.png", 200,300)

        buildingSets[1] = bldSet
        shardSheets[1] = shrdSheet
        
        local i = 1
        while i <= (WORLD_WIDTH / MAP_UNIT) do
            local letter = string.sub(contents, i, i)
            if letter ~= "g" then
                local lencheck = 1
                if letter == "1" then
                    lencheck = 10
                end
                local j = i
                while string.sub(contents, j, j) == letter do
                    j = j + 1
                end
                if j - i == lencheck then
                    local fucklua = tonumber(letter)
                    local bld = Building:create((i + (lencheck / 2)) * MAP_UNIT - ((WORLD_WIDTH / 2) - (display.contentWidth / 2)),
                                                WORLD_HEIGHT - GROUND_HEIGHT,
                                                fucklua,
                                                1,
                                                buildingSets[fucklua],
                                                shardSheets[fucklua])
                    table.insert(buildings, bld)
                    table.insert(shakable, bld)
                    inGameGroup:insert(bld)       
                    i = j - 1
                end
            end
            i = i + 1
        end
        
        io.close(fh)
    end
    
    function worldTouch(event)
        for i=1, inGameGroup.numChildren do
            if event.phase == "began" then
                inGameGroup[i].x0 = event.x - inGameGroup[i].x
                inGameGroup[i].y0 = event.y - inGameGroup[i].y
            end
            if (event.x - background.x0) - (WORLD_WIDTH/2) <= 0 and 
               (event.x - background.x0) + (WORLD_WIDTH/2) >= display.contentWidth then
                inGameGroup[i].x = event.x - inGameGroup[i].x0
            end
        end 
    end
    
    inGameGroup:addEventListener("touch", worldTouch)
    
    loadLevel()
end

function init(event)
    mode = event.target.id
    if event.phase == "ended" then
        if mode == newGame then
            mainMenuGroup:removeSelf()
            selectedLevel = 1
            inGame()
        elseif mode == levelSelect then
            --local levelSelectAnimation = transition.to(mainMenuGroup, {alpha = 0, xScale = 1, yScale = 1, time = 400})
            mainMenuGroup:removeSelf()
            levelSelectMenu()
        end
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

function startLevel(event)
    if event.phase == "ended" then
        selectedLevel = event.target.id
        levelSelectGroup:removeSelf()
        inGame()
    end
end

function returnToMain(event)
    if event.phase == "began" then
        selectedLevel = 1
        mainMenu()
    end
end

mainMenu()