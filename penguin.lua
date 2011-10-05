sprite = require "sprite"
physics = require "physics"

--start the physical simulation
physics.start()
physics.setDrawMode("hybrid")

--background color
local background = display.newRect(0, 0, display.contentWidth, display.contentHeight)
background:setFillColor(0, 0, 200)

--circle to show transitions, touch & drag
local circle = display.newCircle(display.contentWidth / 2, display.contentHeight / 2, 100)
circle:setFillColor(255, 0, 0)

--functions that show simple transitions - circle regularly fade in and out

function fadeIn()
    transition.to(circle, {time=1500, delay = 1000, alpha = 1.0, onComplete=fadeOut})
end

function fadeOut()
    transition.to(circle, {time=1500, delay = 1000, alpha = 0.2, onComplete=fadeIn})
end

fadeOut()

--this will start to break down with multiple moving physics objects
--consider using a TouchJoint if the physics engine is enabled
local function circleTouch(event)
    --save point on which circle was touched - otherwise it hops instantly to be centered on finger
    if event.phase == "began" then
        circle.x0 = event.x - circle.x
        circle.y0 = event.y - circle.y
    end
    
    circle.x = event.x - circle.x0
    circle.y = event.y - circle.y0
    
    return true
end

--spritesheet and sprite set for the penguin
--filename, width and height of an individual frame
local penguinSheet = sprite.newSpriteSheet("pixelpenguin.png", 360, 288)
--sprite set defines which frames are associated with each character
--can be subdivided into different animation sequences for playback
--specify spritesheet, startFrame, numFrames
local penguinSet = sprite.newSpriteSet(penguinSheet, 1, 2)
--adds animation sequence to the set
--specify sprite set, name, start frame, frame count, time between frames, [loop?]
sprite.add(penguinSet, "fly", 1, 2, 400)

--the penguin object
local penguin = sprite.newSprite(penguinSet)
penguin.x = display.contentWidth / 2
penguin.y = display.contentHeight / 2
penguin.xScale = 0.5
penguin.yScale = 0.5

--penguin animation
--Stops and currently playing animation sequence, optionally sets the new
--current sequence, and moves to the first frame of that sequence
penguin:prepare("fly")
penguin:play()

--make penguin wobble up and down
local function penguinFly(event)
    penguin.y = display.contentHeight /2 + 300*math.sin(event.time / 3000)
end

--[[Corona automatically translates between the screen units and the
internal metric units of the physical simulation
Default ration is 30 pixels == 1 meter. Change with physics.setScale()

To remain consistent with the rest of the SDK, all angular values
are expressed in degrees, +y is down, shape definitions must
declare their points in clockwise order]]
--set up collision polygon
penguinpoly = {-30, -70, 30, -70, 70, 0, 40, 60, -40, 60, -70, 0}
--initialize for the physics engine
physics.addBody(penguin, {density = 1.0, friction = 10, bounce = 0.4, shape=penguinpoly})

--add invisible boudaries so that the penguin doesn't fall offscreen
local edge1 = display.newRect(0,0, display.contentWidth, 10)
physics.addBody(edge1, "static", {bounce = 0.7})
edge1.isVisible = false
local edge2 = display.newRect(0,0, 10, display.contentHeight)
physics.addBody(edge2, "static", {bounce = 0.7})
edge2.isVisible = false
local edge3 = display.newRect(display.contentWidth - 10,0, 10, display.contentHeight)
physics.addBody(edge3, "static", {bounce = 0.7})
edge3.isVisible = false
local edge4 = display.newRect(0,display.contentHeight-10, display.contentWidth, 10)
physics.addBody(edge4, "static", {bounce = 0.7})
edge4.isVisible = false

--change color of circle everytime the penguin bounces off something
local function onCollide(event)
    if ((event.object1 == penguin) or (event.object2 == penguin)) then
        circle:setFillColor(math.random(0, 255), math.random(0, 255), math.random(0, 255))
    end
end

--apply random impulse to penguin when device is shaken
local function onShake(event)
    penguin:applyLinearImpulse(math.random(-500, 500), math.random(-500, 500),
    penguin.x + math.random(-20, 20), penguin.y + math.random(-20, 20))
end

--add event listeners for other functions
circle:addEventListener("touch", circleTouch)
--Runtime:addEventListener("enterFrame", penguinFly)
Runtime:addEventListener("collision", onCollide)
Runtime:addEventListener("accelerometer", onShake)



