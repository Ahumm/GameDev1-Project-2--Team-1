sprite = require "sprite"

Building = {}

function Building:create(x, y, btype, status, bldingSet)
    local bldng = {}
    setmetatable(bldng, {__index = sprite})
    bldng.x = x
    bldng.y = y
    bldng.btype = btype
    bldng.status = status
    bldng.b_sprite = sprite.newSprite(bldingSet)
    bldng.b_sprite.x = x
    bldng.b_sprite.y = y
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

