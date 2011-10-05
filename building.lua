sprite = require "sprite"

Building = {}
Building.__index = sprite

function Building.create(x, y, btype, status, bldingSet)
    local bldng = {}
    setmetatable(bldng, Building)
    bldng.x = x
    bldng.y = y
    bldng.type = type
    bldng.status = status
    bldng.b_sprite = sprite.newSprite(bldingSet)
    if type == 0 then
        bldng.health = 100
        bldng.poly = {-100,-150, 100, -150, 100, 150, -100, 150}
    else
        health = 0
    end
    return bldng
end

function Building:TakeDamage(damage)
    self.health =  self.health - damage
    if self.health <= 0 then
        self.health = 0
    end
end

