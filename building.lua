sprite = require "sprite"
require "Shard"

Building = {}

function Building:create(x, y, btype, status, bldingSet, shardSheet)
    local bldng = {}
    bldng = sprite.newSprite(bldingSet)
    --setmetatable(bldng, {__index = Building})
    bldng.x = x
    bldng.y = y - bldng.height / 2
    bldng.dead = false
    bldng.btype = btype
    bldng.status = status
    bldng.shardSheet = shardSheet
    if btype == 9 then
        bldng.health = 100
        bldng.poly = {-100,-150, 100, -150, 100, 150, -100, 150}
    else
        health = 0
    end
    
    -- Cause damage to buildings
    bldng.takeDamage = function(damage)
                           bldng.health =  bldng.health - damage
                           if bldng.health <= 0 then
                               bldng.health = 0
                               bldng.dead = true
                           end
                        end
    
    -- Check for building death, return shard table if dead, else nil
    bldng.isDead = function(vx,vy,f_x,f_y)
                       if bldng.health == 0 then
                           local shards = {}
                           if bldng.btype == 9 then
                               table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 1, 1),{{-100,69,-81,100,-100,150},{-81,100,-58,76,-27,86,-100,150},{-27,86,-100,150,14,98,-8,84},{14,98,26,80,47,95,100,150},{47,95,58,80,84,79,100,150},{84,79,100,64, 100, 150},{14,98,100,150,-100,150}}))
                               table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 2, 1),{{-100,-64,-90,-68,-60,-47,-59,75,-81,99,-100,67},{-60,-47,-22,-82,7,-47,-10,-28},{-60,-47,-10,-28,13,-2,-2,14,-59,75},{-2,14,-59,75,-29,86,-8,84},{-8,84,-2,14,26,80,14,97}}))
                               table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 3, 1),{{100,-104,100,65,76,-51,86,-89},{76,-51,86,-89,66,-96},{76,-51,100,65,16,-1,27,-51},{27,-51,13,-68,36,-69,76,-51},{5,-52,27,-51,10,-47},{10,-47,27,-51,16,-1,-8,-28},{16,-1,60,80,49,95,30,82,1,14},{16,-1,100,65,86,78,60,80}}))
                               table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 4, 1),{{-99,-66,-99,-150,100,-150,-89,-68},{-89,-68,100,-150,-21,-83},{-89,-68,-21,-83,-59,-48},{-21,-83,100,-150,64,-97},{-21,-83,64,-97,36,-69,13,-68},{13,-68,25,-51,4,-53,-21,-83},{36,-69,64,-97,74,-52},{64,-97,100,-150,100,-103,84,-90}}))
                           end
                           return shards
                       end
                       return nil
                   end
    
    return bldng
end

