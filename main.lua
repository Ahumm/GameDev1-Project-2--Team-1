physics = require "physics"
sprite = require "sprite"
audio = require "audio"
require "Shard"
require "Building"



--start the physical simulation
physics.start()
physics.setDrawMode("hybrid")
--background color
local isSimulator = "simulator" == system.getInfo("environment")

-- Accelerator is not supported on Simulator
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
WORLD_HEIGHT = display.contentHeight * 3
MAP_UNIT = 10


local newGame = 1
local levelSelect = 2
local soundState = 1
audio.setVolume(0.0)
local selectedLevel = 1
local completedLevels = 9

function mainMenu()
    mainMenuGroup = display.newGroup()
    
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

function inGame()
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
    
    local top_edge = display.newRect(inGameGroup, 0,display.contentHeight - WORLD_HEIGHT, WORLD_WIDTH, 10)
    top_edge.x = display.contentCenterX
    physics.addBody(top_edge, "static", {bounce = 0.7})
    top_edge.isVisible = false
    local left_edge = display.newRect(inGameGroup, 0,0, 10, WORLD_HEIGHT)
    left_edge.x = left_edge.x - ((WORLD_WIDTH / 2) - (display.contentWidth / 2))
    physics.addBody(left_edge, "static", {bounce = 0.7})
    left_edge.isVisible = false
    local right_edge = display.newRect(inGameGroup, WORLD_WIDTH - 10,0, 10, WORLD_HEIGHT)
    right_edge.x = right_edge.x - ((WORLD_WIDTH / 2) - (display.contentWidth / 2))
    physics.addBody(right_edge, "static", {bounce = 0.7})
    right_edge.isVisible = false
    local ground = display.newRect(inGameGroup, 0, display.contentHeight - GROUND_HEIGHT, WORLD_WIDTH, GROUND_HEIGHT)
    ground.x = display.contentCenterX
    physics.addBody(ground, "static", {friction = 2, bounce = 0.4})
    ground.isVisible = false
    
    -- Load level from file
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
        
        -- 1
        local bldSheet = sprite.newSpriteSheet("Office1.png", 100, 300)
        local bldSet = sprite.newSpriteSet(bldSheet, 1, 1)

        local shrdSheet = sprite.newSpriteSheet("OfficeShards.png", 100,300)

        buildingSets[1] = bldSet
        shardSheets[1] = shrdSheet
        -- 2
        local bldSheet = sprite.newSpriteSheet("SmallHouse.png", 120, 150)
        local bldSet = sprite.newSpriteSet(bldSheet, 1, 1)

        local shrdSheet = sprite.newSpriteSheet("SmallHouseRemains.png", 120,150)

        buildingSets[2] = bldSet
        shardSheets[2] = shrdSheet
        -- 3
        local bldSheet = sprite.newSpriteSheet("EnemyHQ.png", 160, 360)
        local bldSet = sprite.newSpriteSet(bldSheet, 1, 1)

        local shrdSheet = sprite.newSpriteSheet("EnemyHQFragments.png", 160,360)

        buildingSets[3] = bldSet
        shardSheets[3] = shrdSheet
        -- 4
        local bldSheet = sprite.newSpriteSheet("GasStation.png", 280,110)
        local bldSet = sprite.newSpriteSet(bldSheet, 1, 1)

        local shrdSheet = sprite.newSpriteSheet("GasStationRemains.png", 280,110)

        buildingSets[4] = bldSet
        shardSheets[4] = shrdSheet
        -- 5
        local bldSheet = sprite.newSpriteSheet("DonutShop.png", 150,260)
        local bldSet = sprite.newSpriteSet(bldSheet, 1, 1)

        local shrdSheet = sprite.newSpriteSheet("DonutShopShards.png", 150,260)

        buildingSets[5] = bldSet
        shardSheets[5] = shrdSheet
        -- 6
        local bldSheet = sprite.newSpriteSheet("Factory.png", 190, 175)
        local bldSet = sprite.newSpriteSet(bldSheet, 1, 1)

        local shrdSheet = sprite.newSpriteSheet("FactoryShards.png", 190, 175)

        buildingSets[6] = bldSet
        shardSheets[6] = shrdSheet
        -- 7
        local bldSheet = sprite.newSpriteSheet("FuelTank.png", 150, 70)
        local bldSet = sprite.newSpriteSet(bldSheet, 1, 1)

        local shrdSheet = sprite.newSpriteSheet("FuelTankShards.png", 150,70)

        buildingSets[7] = bldSet
        shardSheets[7] = shrdSheet
        -- 8
        local bldSheet = sprite.newSpriteSheet("ApartmentBuilding.png", 100, 260)
        local bldSet = sprite.newSpriteSet(bldSheet, 1, 1)

        local shrdSheet = sprite.newSpriteSheet("ApartmentShards.png", 100,260)

        buildingSets[8] = bldSet
        shardSheets[8] = shrdSheet
        -- 9
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
                if letter == "1" then
                    lencheck = 10
                elseif letter == "2" then
                    lencheck = 12
                elseif letter == "3" then
                    lencheck = 16
                elseif letter == "4" then
                    lencheck = 28
                elseif letter == "5" then
                    lencheck = 15
                elseif letter == "6" then
                    lencheck = 19
                elseif letter == "7" then
                    lencheck = 15
                elseif letter == "8" then
                    lencheck = 10
                elseif letter == "9" then
                    lencheck = 20
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
                    if #bld.poly == 1 then
                        physics.addBody(bld, {density = 3.0, friction = 0.5, bounce = 0.3, shape = bld.poly[1]})
                    elseif #bld.poly == 2 then
                        if #bld.poly[2] == 1 then
                            physics.addBody(bld, {density = 3.0, friction = 0.5, bounce = 0.3, shape = bld.poly[1]},
                                                 {density = 3.0, friction = 0.5, bounce = 0.3, radius = bld.poly[2][1]})
                        else
                            physics.addBody(bld, {density = 3.0, friction = 0.5, bounce = 0.3, shape = bld.poly[1]},
                                                 {density = 3.0, friction = 0.5, bounce = 0.3, shape = bld.poly[2]})
                        end
                    elseif #bld.poly == 5 then
                        physics.addBody(bld, 
                                    {density = 3.0, friction = 0.5, bounce = 0.3, shape = bld.poly[1]},
                                    {density = 3.0, friction = 0.5, bounce = 0.3, shape = bld.poly[2]},
                                    {density = 3.0, friction = 0.5, bounce = 0.3, shape = bld.poly[3]},
                                    {density = 3.0, friction = 0.5, bounce = 0.3, shape = bld.poly[4]},
                                    {density = 3.0, friction = 0.5, bounce = 0.3, shape = bld.poly[5]})
                    end
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
    
    local function worldTouch(event)
        if event.phase == "began" then
            if event.y > display.contentHeight - GROUND_HEIGHT + 10 and not post_eq and not eq then
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
            if not post_eq and not eq then
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
                inGameGroup[i].x = inGameGroup[i].x + (shake_dir * 7)
            end
            shake_dir = -shake_dir
            timer.performWithDelay(30, shake_world)
        end
    end
    
    local function endPostQuake()
        post_eq = false
        physics.setGravity(0, GRAVITY)
    end

    local function endQuake()
        eq = false
        for i, penguin in pairs(shakable) do
            penguin:setLinearVelocity(0, 0)
            force = 30000000 * math.min(1, eq_power / MAX_EQ_POWER) + 4500000
            angle = math.atan((math.abs(epicenter.x - penguin.x))/(math.abs(epicenter.y - penguin.y)))
            distance = math.sqrt(math.pow(epicenter.x - penguin.x,2) + math.pow(epicenter.y - penguin.y,2))
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
            
            x = math.cos(angle) * (force/math.pow(distance,2))
            y = math.sin(angle) * -(force/math.pow(distance,2))
            penguin:applyLinearImpulse(x, y, penguin.x, penguin.y)
        end
        epicenter.x = -100
        epicenter.y = -100
        epicenter.isVisible = false
        eq_power = 0
        post_eq = true
        timer.performWithDelay(500, endPostQuake)
    end
    
    local function addShards()
        for i, i_shard in pairs(shard_list) do
            inGameGroup:insert(i_shard)
            table.insert(shakable, i_shard)
            table.insert(shrapnel, i_shard)
            if #i_shard.polys == 1 then
                if #i_shard.polys[1] == 1 then
                    physics.addBody(i_shard, 
                                    {density=3.0,friction=0.4, bounce=0.4, radius = i_shard.polys[1][1]})
                else
                    physics.addBody(i_shard, 
                                    {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[1]})
                end
            elseif #i_shard.polys == 2 then
                physics.addBody(i_shard, 
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[1]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[2]})
            elseif #i_shard.polys == 3 then
                physics.addBody(i_shard, 
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[1]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[2]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[3]})
            elseif #i_shard.polys == 4 then
                physics.addBody(i_shard, 
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[1]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[2]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[3]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[4]})
            elseif #i_shard.polys == 5 then
                physics.addBody(i_shard, 
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[1]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[2]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[3]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[4]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[5]})
            elseif #i_shard.polys == 6 then
                physics.addBody(i_shard, 
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[1]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[2]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[3]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[4]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[5]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[6]})
            elseif #i_shard.polys == 7 then
                physics.addBody(i_shard, 
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[1]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[2]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[3]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[4]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[5]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[6]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[7]})
            elseif #i_shard.polys == 8 then
                physics.addBody(i_shard, 
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[1]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[2]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[3]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[4]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[5]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[6]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[7]},
                                {density=3.0,friction=0.4, bounce=0.4, shape = i_shard.polys[8]})
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
            b:removeSelf()
            --b = nil
            shard_list = isDead
            addShards()
        end
    end
    
    local function acc(event)
        if event.isShake == true and eq == false and epicenter.isVisible and post_eq == false then
            timer.performWithDelay(2000, endQuake)
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
            
            for i, bld in pairs(buildings) do
                local damage = 12000 * math.min(1, math.abs(event.zInstant) / MAX_EQ_POWER) + 1
                local distance = math.pow(math.sqrt(math.pow(epicenter.x - bld.x,2) + math.pow(epicenter.y -bld.y,2)) / 30, 2)
                damage_building(bld, damage / distance, 0, 0, 0, 0)
            end
        end
    end
    
    local function onCollide(self, event)
        if event.phase == "began" then
            if self then
                if event.other == ground then
                    print("Wooops")
                else
                    local damage = 0
                    local vx = 0
                    local vy = 0
                    vx, vy = event.other:getLinearVelocity()
                    damage = math.sqrt(math.pow(vx,2) + math.pow(vy,2)) / 12
                    
                    
                    timer.performWithDelay(30, function() return damage_building(self, damage, vx, vy, event.other.x, event.other.y) end)
                end
            end
        end
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

function returnToMain(event)
    if event.phase == "began" then
        selectedLevel = 1
        mainMenu()
    end
end

function onKeyEvent(event)
    if event.phase == "down" and event.keyName == "back" then
        inGameGroup:removeSelf()
        selectedLevel = 1
        mainMenu()
    end
end

Runtime:addEventListener("key", onKeyEvent)

mainMenu()