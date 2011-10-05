sprite = require "sprite"

Building = {}

function Building:create(x, y, btype, status, bldingSet)
    local bldng = {}
    bldng = sprite.newSprite(bldingSet)
    --setmetatable(bldng, {__index = Building})
    bldng.x = x
    bldng.y = y
    bldng.btype = btype
    bldng.status = status
    bldng.takeDamage = function(damage)
                            bldng.health =  bldng.health - damage
                            if bldng.health <= 0 then
                                bldng.health = 0
                            end
                        end
    --bldng.b_sprite = sprite.newSprite(bldingSet)
    --bldng.b_sprite.x = x
    --bldng.b_sprite.y = y
    if btype == 0 then
        bldng.health = 100
        bldng.poly = {-100,-150, 100, -150, 100, 150, -100, 150}
    else
        health = 0
    end
    return bldng
end

