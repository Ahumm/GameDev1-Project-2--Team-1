physics = require "physics"
sprite = require "sprite"
audio = require "audio"
require "Shard"
require "Building"



physics.start()
--physics.setDrawMode("hybrid")

if "simulator" == system.getInfo("environment") then
    MAX_EQ_POWER = 70
else
    MAX_EQ_POWER = 110
end

GROUND_HEIGHT = 90

--WORLD_WIDTH = 1000
local GRAVITY = 0
temp, GRAVITY = physics.getGravity()
WIDTH_MOD = 200
WORLD_WIDTH = 2000
WORLD_HEIGHT = display.contentHeight * 3
MAP_UNIT = 20


local newGame = 1
local levelSelect = 2
local soundState = 1
local gameState = 0 -- 0 = main menu; 1 = level select; 2 = in game
audio.setVolume(0.0)
local selectedLevel = 1
local completedLevels = 0

function mainMenu()
    mainMenuGroup = display.newGroup()
    gameState = 0
    
    -- Load Background Image
    local mainMenuBG = display.newImage("mainMenuBG.png")
    mainMenuGroup:insert(mainMenuBG)

    -- Add buttons
    local newGameButton = display.newImage("newGameButton.png", display.contentCenterX - 48, display.contentCenterY + 60)
    newGameButton.id = newGame
    mainMenuGroup:insert(newGameButton)
    
    local levelSelectButton = display.newImage("levelSelectButton.png", display.contentCenterX - 48, display.contentCenterY + 120)
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
    gameState = 1
    levelSelectGroup = display.newGroup()
    
    -- Load Background Image
    local levelSelectBG = display.newImage("levelSelectBG.png")
    levelSelectGroup:insert(levelSelectBG)
    
    
    -- Add level selection buttons
    local levelButtons = {}
    local grayOuts = {}
    
    local levelsPerRow = 2
    
    for i=1,4 do
        levelButtons[i] = display.newImage(("level" .. i .. "Button.png"), (((i - 1) % levelsPerRow ) + 1) * 120, 100 + ((math.floor(i / (levelsPerRow + 1))) * 70))
        grayOuts[i] = display.newImage(("leveloverlay.png"), (((i - 1) % levelsPerRow ) + 1) * 120, 100 + ((math.floor(i / (levelsPerRow + 1))) * 70))
        levelButtons[i].id = i
        grayOuts[i].id = i
        if selectedLevel >= i then
            grayOuts[i].alpha = 0
        else
            grayOuts[i].alpha = 0.8
        end
        levelSelectGroup:insert(levelButtons[i])
        levelSelectGroup:insert(levelButtons[i])
        levelButtons[i]:addEventListener("touch", startLevel)
    end
    
end

function inGame()
    gameState = 2
    inGameGroup = display.newGroup()
    
    local shakable = {}
    local shrapnel = {}
    local buildings = {}
    
    local eq = false
    local post_eq = false
    local eq_power = 0
    local shard_list = nil
    local shake_dir = 1
    
    local background = display.newImage("DayBkgrd.png", 0, display.contentHeight - 500)
    background.x = display.contentCenterX
    inGameGroup:insert(background)
    
    local epicenterSheet = sprite.newSpriteSheet("crosshair.png", 16, 16)
    local epicenterSet = sprite.newSpriteSet(epicenterSheet, 1, 1)
    local epicenter = sprite.newSprite(epicenterSet)
    epicenter.isVisible = false
    inGameGroup:insert(epicenter)
    
    local top_edge = display.newRect(inGameGroup, 0, display.contentHeight - WORLD_HEIGHT, WORLD_WIDTH, 10)
    top_edge.x = display.contentCenterX
    physics.addBody(top_edge, "static", {bounce = 0.7})
    top_edge.isVisible = false
    
    local left_edge = display.newRect(inGameGroup, 0,display.contentHeight - WORLD_HEIGHT, 10, WORLD_HEIGHT)
    left_edge.x = left_edge.x - ((WORLD_WIDTH / 2) - (display.contentWidth / 2))
    physics.addBody(left_edge, "static", {bounce = 0.7})
    left_edge.isVisible = false
    
    local right_edge = display.newRect(inGameGroup, WORLD_WIDTH - 10,display.contentHeight - WORLD_HEIGHT, 10, WORLD_HEIGHT)
    right_edge.x = right_edge.x - ((WORLD_WIDTH / 2) - (display.contentWidth / 2))
    physics.addBody(right_edge, "static", {bounce = 0.7})
    right_edge.isVisible = false

    local ground = display.newRect(inGameGroup, 0, display.contentHeight - GROUND_HEIGHT, WORLD_WIDTH, GROUND_HEIGHT)
    ground.x = display.contentCenterX
    physics.addBody(ground, "static", {friction = 2, bounce = 0.3})
    ground.isVisible = false
    local font = nil
    for i, font_ in pairs(native.getFontNames()) do
        if string.sub(font_, 1, 3) == "Qua" then
           print(font_)
           font = font_
        end
    end
    local scoreText = display.newText(inGameGroup, "Karma Points: ", 6, 6, font, 22)
    scoreText:setTextColor(255, 255, 255)
    scoreText.x_init = scoreText.x - scoreText.width/2
    scoreText.updateText = function(text)
                               scoreText.text = text
                               scoreText.x = scoreText.x_init + scoreText.width/2
                            end
    scoreText.moves = false
    
    local gauge_border = display.newRect(inGameGroup, 3, 3, display.contentWidth - 6, 30)
    gauge_border.strokeWidth = 6
    gauge_border:setFillColor(40, 40, 230)
    gauge_border:setStrokeColor(180, 180, 180)
    gauge_border.isVisible = false
    gauge_border.moves = false

    local gauge = display.newRect(inGameGroup, 6, 6, 0, 24)
    gauge:setFillColor(230, 40, 40)
    gauge.isVisible = false
    gauge.moves = false
    
    local function worldTouch(event)
        if event.phase == "began" then
            if event.y > display.contentHeight - GROUND_HEIGHT + 10 and not post_eq and not eq then
                scoreText.updateText("Karma Points: " .. "(".. event.x ..", ".. event.y ..")")
                epicenter.x = event.x
                epicenter.y = event.y
                epicenter.isVisible = true
            end
        end
        for i=1, inGameGroup.numChildren do
            if event.phase == "began" then
                inGameGroup[i].x0 = event.x - inGameGroup[i].x
                inGameGroup[i].y0 = event.y - inGameGroup[i].y
            end
            if not post_eq and not eq and inGameGroup[i].moves == nil then
                if (event.x - background.x0) - (WORLD_WIDTH/2) > 10 then
                    inGameGroup[i].x = background.x0 + (WORLD_WIDTH/2) - inGameGroup[i].x0 - 10
                elseif (event.x - background.x0) + (WORLD_WIDTH/2) < display.contentWidth - 10 then
                    inGameGroup[i].x = background.x0 - (WORLD_WIDTH/2) + display.contentWidth - inGameGroup[i].x0 + 10
                else
                    inGameGroup[i].x = event.x - inGameGroup[i].x0
                end
            end
        end
    end
    
    function shake()
        if eq then
            for i,penguin in pairs(shakable) do
                vx, vy = penguin:getLinearVelocity()
                penguin:applyLinearImpulse(-1.032 * vx, -3.5, penguin.x, penguin.y)
            end
            timer.performWithDelay(40, shake)
        end
    end

    function shake_world()
        if eq then
            for i=1, inGameGroup.numChildren do
                if inGameGroup[i].moves == nil then
                    inGameGroup[i].x = inGameGroup[i].x + (shake_dir * 7)
                end
            end
            shake_dir = -shake_dir
            timer.performWithDelay(30, shake_world)
        end
    end
    
    local function endPostQuake()
        post_eq = false
        physics.setGravity(0, GRAVITY)
    end
    
    local function addShards()
        for i, i_shard in pairs(shard_list) do
            inGameGroup:insert(i_shard)
            table.insert(shakable, i_shard)
            table.insert(shrapnel, i_shard)
            if #i_shard.polys == 1 then
                physics.addBody(i_shard, 
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[1]})
            elseif #i_shard.polys == 2 then
                physics.addBody(i_shard, 
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[1]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[2]})
            elseif #i_shard.polys == 3 then
                physics.addBody(i_shard, 
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[1]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[2]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[3]})
            elseif #i_shard.polys == 4 then
                physics.addBody(i_shard, 
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[1]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[2]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[3]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[4]})
            elseif #i_shard.polys == 5 then
                physics.addBody(i_shard, 
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[1]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[2]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[3]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[4]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[5]})
            elseif #i_shard.polys == 6 then
                physics.addBody(i_shard, 
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[1]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[2]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[3]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[4]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[5]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[6]})
            elseif #i_shard.polys == 7 then
                physics.addBody(i_shard, 
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[1]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[2]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[3]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[4]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[5]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[6]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[7]})
            elseif #i_shard.polys == 8 then
                physics.addBody(i_shard, 
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[1]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[2]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[3]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[4]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[5]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[6]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[7]},
                                {density=3.0,friction=0.4, bounce=0.2, shape = i_shard.polys[8]})
            end
            if i == 1 then
                physics.newJoint("weld", ground, i_shard, i_shard.x, i_shard.y + i_shard.height / 2)
            else
                i_shard:applyLinearImpulse( i_shard.vel_x, i_shard.vel_y, i_shard.f_x, i_shard.f_y)
                i_shard.isBullet = true
            end
        end
        shard_list = nil
    end
    
    local function damage_building(b, damage, vx, vy, ox, oy)
        if b then
            b.takeDamage(damage)
            local isDead = b.isDead(vx/6, vy/6, ox, oy)
            if isDead then
                b.dead = true
                for j, thing in pairs(shakable) do
                    if thing == b then
                        table.remove(shakable, j)
                        break
                    end
                end
                for j, thing in pairs(buildings) do
                    if thing == b then
                        table.remove(buildings, j)
                        break
                    end
                end
                if b.x then
                    b:removeSelf()
                    b = nil
                    shard_list = isDead
                    addShards()
                else
                    print("lol")
                    for d, shrd in pairs(isDead) do
                        shrd:removeSelf()
                    end
                end
            end
        end
    end
    
    local function endQuake()
        eq = false
        for i, bld in pairs(buildings) do
            force = 55000 * math.min(1, eq_power / MAX_EQ_POWER) + 10000
            angle = math.atan((math.abs(epicenter.x - bld.x))/(math.abs(epicenter.y - bld.y)))
            distance = math.sqrt(math.pow(epicenter.x - bld.x,2) + math.pow(epicenter.y - bld.y,2)) / 30
            
            x = math.cos(angle) * (force/math.pow(distance,1.5))
            y = math.sin(angle) * -(force/math.pow(distance,1.5))
            damage = force / math.pow(distance, 2) / 10
            print(damage)
            damage_building(bld, damage, x, y, epicenter.x, epicenter.y)
        end
        for i, penguin in pairs(shakable) do
            penguin:setLinearVelocity(0, 0)
            force = 55000 * math.min(1, eq_power / MAX_EQ_POWER) + 10000
            angle = math.atan((math.abs(epicenter.x - penguin.x))/(math.abs(epicenter.y - penguin.y)))
            distance = math.sqrt(math.pow(epicenter.x - penguin.x,2) + math.pow(epicenter.y - penguin.y,2)) / 30
            if epicenter.x >= penguin.x then
                if epicenter.y >= penguin.y then
                    --Quad 2
                    angle = angle + math.pi / 2
                else
                    --Quad 3
                    angle = angle + math.pi                
                end
            else
                if epicenter.y >= penguin.y then
                    --Quad 1
                    angle = angle + 0
                else
                    --Quad 4
                    angle = angle + 3 * math.pi / 2
                end        
            end
            
            x = math.cos(angle) * (force/math.pow(distance,1.5))
            y = math.sin(angle) * -(force/math.pow(distance,1.5))
            
            penguin:applyLinearImpulse(x, y, penguin.x, penguin.y)
        end
        epicenter.x = -100
        epicenter.y = -100
        epicenter.isVisible = false
        eq_power = 0
        gauge.width = 0
        gauge.isVisible = false
        gauge_border.isVisible = false
        post_eq = true
        timer.performWithDelay(500, endPostQuake)
    end
    
    local function acc(event)
        if event.isShake == true and eq == false and epicenter.isVisible and post_eq == false then
            timer.performWithDelay(2000, endQuake)
            gauge_border.isVisible = true
            gauge.isVisible = true
            eq = true
            shake_world()
            shake_dir_start = shake_dir
            for i,penguin in pairs(shakable) do
                if math.random(1,2) == 1 then
                    penguin:applyLinearImpulse(-95, -3.5, penguin.x, penguin.y)
                else
                    penguin:applyLinearImpulse(95, -3.5, penguin.x, penguin.y)
                end
            end
            shake(i)
        end
        if eq then
            eq_power = eq_power + math.abs(event.zInstant)
            gauge.width = (display.contentWidth - 12) * math.min(1, eq_power / MAX_EQ_POWER)
            gauge.x = 6 + gauge.width / 2
            
            for i, bld in pairs(buildings) do
                local damage = 12000 * math.min(1, math.abs(event.zInstant) / MAX_EQ_POWER) + 1
                local distance = math.pow(math.sqrt(math.pow(epicenter.x - bld.x,2) + math.pow(epicenter.y -bld.y,2)) / 30, 2)
                damage_building(bld, damage / distance, 0, 0, 0, 0)
            end
        end
    end
    
    local function onCollide(self, event)
        print("OnCollide!")
        if event.phase == "began" then
            if event.other == ground then
                print("Wooops")
            else
                local damage = 0
                local vx = 0
                local vy = 0
                vx, vy = event.other:getLinearVelocity()
                damage = math.sqrt(math.pow(vx,2) + math.pow(vy,2)) / 3
                print(" damage: " .. damage)
                
                timer.performWithDelay(30, function() return damage_building(self, damage, vx, vy, event.other.x, event.other.y) end)
            end
        end
    end
    
    local function loadLevel()
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

        buildingSets[9] = bldSet
        shardSheets[9] = shrdSheet
        
        local i = 1
        while i <= (WORLD_WIDTH / MAP_UNIT) do
            local letter = string.sub(contents, i, i)
            if letter ~= "g" then
                local lencheck = 1
                if letter == "9" then
                    lencheck = 10
                end
                local j = i
                while string.sub(contents, j, j) == letter do
                    j = j + 1
                end
                if j - i == lencheck then
                    local fucklua = tonumber(letter)
                    local bld = Building:create((i + (lencheck / 2)) * MAP_UNIT - ((WORLD_WIDTH / 2) - (display.contentWidth / 2)),
                                                display.contentHeight - GROUND_HEIGHT,
                                                fucklua,
                                                1,
                                                buildingSets[fucklua],
                                                shardSheets[fucklua])
                    table.insert(buildings, bld)
                    table.insert(shakable, bld)
                    inGameGroup:insert(bld) 
                    physics.addBody(bld, {density = 3.0, friction = 0.5, bounce = 0.1, shape = bld.poly})
                    buildingJoint = physics.newJoint("weld", ground, bld, bld.x, bld.y + bld.height / 2)
                    
                    bld.collision = onCollide
                    bld:addEventListener("collision", bld)
                    i = j - 1
                end
            end
            i = i + 1
        end
        
        io.close(fh)
    end
    
    inGameGroup:addEventListener("touch", worldTouch)
    Runtime:addEventListener( "accelerometer", acc )
    
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
        if selectedLevel <= completedLevels + 1 then
            levelSelectGroup:removeSelf()
            inGame()
        end
    end
end

function returnToMainFromLevelSelect()
    selectedLevel = 1
    mainMenu()
end

function onKeyEvent(event)
    if event.phase == "down" and event.keyName == "back" then
        if gameState == 0 then
            os.exit()
        elseif gameState == 1 then  
            levelSelectGroup:removeSelf()
            selectedLevel = 1
            mainMenu()
        elseif gameState == 2 then
            inGameGroup:removeSelf()
            selectedLevel = 1
            levelSelectMenu()
        else
            print("error")
        end
    end
end

Runtime:addEventListener("key", onKeyEvent)

mainMenu()