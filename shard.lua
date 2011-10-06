sprite = require "sprite"

Shard = {}

function Shard:create(x, y, shardSet, polys)
    local shrd = {}
    shrd = sprite.newSprite(shardSet)
    --setmetatable(bldng, {__index = Building})
    shrd.x = x
    shrd.y = y
    shrd.polys = polys
    return shrd
end

