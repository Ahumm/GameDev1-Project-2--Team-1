sprite = require "sprite"

Shard = {}

function Shard:create(x, y, vx, vy, f_x, f_y, shardSet, polys, x0)
    local shrd = {}
    shrd = sprite.newSprite(shardSet)
    --setmetatable(bldng, {__index = Building})
    shrd.x = x
    shrd.y = y
    shrd.vel_x = vx
    shrd.vel_y = vy
    shrd.f_x = f_x
    shrd.f_y = f_y
    shrd.polys = polys
    shrd.field = "Blarg"
    shrd.x0 = x0
    return shrd
end

