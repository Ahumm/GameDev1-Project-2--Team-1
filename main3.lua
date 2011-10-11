sprite = require "sprite"
physics = require "physics"
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

GROUND_HEIGHT = 100

--WORLD_WIDTH = 1000
local GRAVITY = 0
temp, GRAVITY = physics.getGravity()
WIDTH_MOD = 200
WORLD_WIDTH = display.contentWidth * 1.3
WORLD_HEIGHT = display.contentHeight * 4

local world = display.newGroup()
local shakable = {}
local penguins = {}
local buildings = {}

local background = display.newRect(world, 0, 0, WORLD_WIDTH, WORLD_HEIGHT)
background:setFillColor(50, 50, 255)

local ground = display.newRect(world, 0, WORLD_HEIGHT - GROUND_HEIGHT, WORLD_WIDTH, GROUND_HEIGHT)
ground:setFillColor(85, 40, 5)

--circle to show transitions, touch & drag
local circle = display.newCircle(world, -100, -100, 10)
circle:setFillColor(255, 101, 23)

local myText = display.newText("", display.contentWidth / 2, 100, native.systemFont, 12)
myText:setTextColor(255, 255, 255)
local debugText = display.newText("", display.contentWidth / 2, 130, native.systemFont, 12)
debugText:setTextColor(255, 255, 255)
 
debugText.text = "LARGE"
debugText.size = 16
myText.text = ""
myText.size = 16

local penguinSheet = sprite.newSpriteSheet("pixelpenguin.png", 360, 288)
local penguinSet = sprite.newSpriteSet(penguinSheet, 1, 2)
sprite.add(penguinSet, "fly", 1, 2, 400)

local buildingSheet = sprite.newSpriteSheet("building1.png", 200, 300)
local buildingSet = sprite.newSpriteSet(buildingSheet, 1, 2)
sprite.add(buildingSet, "anim", 1, 2, 600)

local shardSheet = sprite.newSpriteSheet("building2_shrapnel.png", 200,300)

local bld = Building:create(math.random(200, WORLD_WIDTH - 200), 
                                  WORLD_HEIGHT - GROUND_HEIGHT - 150, 
                                  0, 
                                  1, 
                                  buildingSet,
                                  shardSheet)

world:insert(bld)
table.insert(buildings, bld)
table.insert(shakable, bld)
physics.addBody(bld, {density = 3.0, friction = 0.5, bounce = 0.3, shape = bld.poly})

--[[
local building = display.newImage("building2.png")
building.x = math.random(200, WORLD_WIDTH - 200)
building.y = WORLD_HEIGHT - GROUND_HEIGHT - 151
physics.addBody(building, {density = 3.0, friction = 0.5, bounce = 0.3})
world:insert(building)
table.insert(buildings, building)
table.insert(shakable, building)
]]

for i=1, 3 do
    local penguin = sprite.newSprite(penguinSet)
    world:insert(penguin)
    table.insert(penguins, penguin)
    table.insert(shakable, penguin)
    penguin.x = math.random(200, WORLD_WIDTH - 200)
    penguin.y = WORLD_HEIGHT / 2 
    penguin.xScale = 0.5
    penguin.yScale = 0.5

    penguin:prepare("fly")
    penguin:play()

    penguinpoly = {-30, -70, 30, -70, 70, 0, 40, 60, -40, 60, -70, 0}
    physics.addBody(penguin, {density = 1.0, friction = 10, bounce = 0.4, shape=penguinpoly})
end

--add invisible boudaries so that the penguin doesn't fall offscreen
local top_edge = display.newRect(world, 0,0, WORLD_WIDTH, 10)
physics.addBody(top_edge, "static", {bounce = 0.7})
top_edge.isVisible = false
local left_edge = display.newRect(world, 0,0, 10, WORLD_HEIGHT)
physics.addBody(left_edge, "static", {bounce = 0.7})
left_edge.isVisible = false
local right_edge = display.newRect(world, WORLD_WIDTH - 10,0, 10, WORLD_HEIGHT)
physics.addBody(right_edge, "static", {bounce = 0.7})
right_edge.isVisible = false

physics.addBody(ground, "static", {friction = 10, bounce = 0.4})
buildingJoint = physics.newJoint("weld", ground, bld, bld.x, bld.y + 145)

eq_power = 0
eq = false
post_eq = false
local shake_dir = 1
local shake_dir_start = shake_dir
local shard_list = nil


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
        for i=1, world.numChildren do
            world[i].x = world[i].x + (shake_dir * 7)
        end
        shake_dir = -shake_dir
        timer.performWithDelay(30, shake_world)
    end
end

local function endPostQuake()
    post_eq = false
    --debugText.text = "Normal mode"
    physics.setGravity(0, GRAVITY)
end

local function endQuake()
    eq = false
    for i, penguin in pairs(shakable) do
        penguin:setLinearVelocity(0, 0)
        force = 30000000 * math.min(1, eq_power / MAX_EQ_POWER) + 4500000
        --debugText.text = " " .. eq_power .. " vs. " .. MAX_EQ_POWER .. " : " .. eq_power / MAX_EQ_POWER
        angle = math.atan((math.abs(circle.x - penguin.x))/(math.abs(circle.y - penguin.y)))
        distance = math.sqrt(math.pow(circle.x - penguin.x,2) + math.pow(circle.y - penguin.y,2))
        if circle.x >= penguin.x then
            if circle.y >= penguin.y then
                --Quad 2
                angle = angle + math.pi / 2
            else
                --Quad 3
                angle = angle + math.pi                
            end
        else
            if circle.y >= penguin.y then
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
    if not shake_dir_start == shake_dir then
        world[i].x = world[i].x + (-shake_dir * 7)    
    end
    myText.text = "EARTHQUAKE with eq_power of " .. eq_power .. " just hit!"
    circle.x = -100
    circle.y = -100
    eq_power = 0
    post_eq = true
    timer.performWithDelay(500, endPostQuake)
    --debugText.text = "POST QUAKE MODE"
end

local function circleInBounds()
    if circle.x - 10 >= 0 and circle.x + 10 <= display.contentWidth and
         circle.y - 10 >= 0 and circle.y + 10 <= display.contentHeight then
       return true
    else
        return false
    end
end

local function addShards()
    for i, i_shard in pairs(shard_list) do
        myText.text = "BROKEN! " .. i
        world:insert(i_shard)
        --i_shard.isVisible = false
        table.insert(shakable, i_shard)
        table.insert(penguins, i_shard)
        if #i_shard.polys == 5 then
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
            physics.newJoint("weld", ground, i_shard, i_shard.x, i_shard.y + 145)
        else
            --i_shard:applyLinearImpulse( i_shard.vel_x, i_shard.vel_y, i_shard.f_x, i_shard.f_y)
            a = 0
        end
    end
    shard_list = nil
end

local function damage_building(b, damage, vx, vy, ox, oy)
    if b.dead then 
        return
    end
    b.takeDamage(damage)
    debugText.text = "\n" .. b.health .. "\n(" .. damage .. ")"
    local isDead = b.isDead(vx/6, vy/6, ox, oy)
    if isDead then
        if not b.dead then
            b.dead = true
            for j, thing in pairs(shakable) do
                if thing == b then
                    table.remove(shakable, j)
                    break
                end
            end
            table.remove(buildings, index)
            b:removeSelf()
            --b = nil
            shard_list = isDead
            addShards()
        end
    end
end

local function acc(event)
    if event.isShake == true and eq == false and circleInBounds()  and post_eq == false then
        myText.text = ""
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
    end
    if post_eq then
        physics.setGravity(0, GRAVITY)
        --physics.setGravity(10 * event.yGravity, GRAVITY / 10)
    end
end

local function onKeyEvent(event)
    if event.phase == "down" and event.keyName == "search" then
        local penguin = sprite.newSprite(penguinSet)
        world:insert(penguin)
        table.insert(shakable, penguin)
        table.insert(penguins, penguin)
        penguin.x = math.random(200, WORLD_WIDTH - 200)
        penguin.y = math.random(background.y-(WORLD_HEIGHT/2) + 300, background.y+(WORLD_HEIGHT/2) + 400)
        penguin.xScale = 0.5
        penguin.yScale = 0.5

        penguin:prepare("fly")
        penguin:play()

        penguinpoly = {-30, -70, 30, -70, 70, 0, 40, 60, -40, 60, -70, 0}
        physics.addBody(penguin, {density = 1.0, friction = 10, bounce = 0.4, shape=penguinpoly})
    end
    return true
end

local function groundTouch(event)
    if event.phase == "began" then
        circle.x = event.x
        circle.y = event.y
    end    
    return true
end

local function worldTouch(event)
    
    for i=1, world.numChildren do
        if event.phase == "began" then
            world[i].x0 = event.x - world[i].x
            world[i].y0 = event.y - world[i].y
        end
        if (event.x - background.x0) - (WORLD_WIDTH/2) <= 0 and 
           (event.x - background.x0) + (WORLD_WIDTH/2) >= display.contentWidth then
            world[i].x = event.x - world[i].x0
        end
        if (event.y - background.y0) - (WORLD_HEIGHT/2) <= 0 and 
           (event.y - background.y0) + (WORLD_HEIGHT/2) >= display.contentHeight then
            world[i].y = event.y - world[i].y0
        end
    end 
end

local function onCollide(event)
    if event.phase == "began" then
        local b = nil
        local o = nil
        local index = nil
        for i, b_ in pairs(buildings) do
            if (event.object1 == b_) then
                b = event.object1
                o = event.object2
                index = i
            end
            if (event.object2 == b_) then
                b = event.object2
                o = event.object1
                index = i
            end
        end
        if b then
            if o == ground then
                debugText.text = "Touching the ground!!!!"
            else
                local damage = 0
                local vx = 0
                local vy = 0
                vx, vy = o:getLinearVelocity()
                damage = math.sqrt(math.pow(vx,2) + math.pow(vy,2)) / 12
                
                
                timer.performWithDelay(30, function() return damage_building(b, damage, vx, vy, o.x, o.y) end)
            end
        end
    end
end

world:addEventListener("touch", worldTouch)
ground:addEventListener("touch", groundTouch)
world:addEventListener("touch", worldTouch)
Runtime:addEventListener("collision", onCollide)
Runtime:addEventListener( "accelerometer", acc )
Runtime:addEventListener( "key", onKeyEvent );

for i=1, world.numChildren do
    world[i].x = world[i].x - ((WORLD_WIDTH - display.contentWidth) / 2)
    world[i].y = world[i].y - (WORLD_HEIGHT - display.contentHeight)
    world[i].x0 = world[i].x
    world[i].y0 = world[i].y
end
bld:applyLinearImpulse(-95, -3.5, bld.x, bld.y)

