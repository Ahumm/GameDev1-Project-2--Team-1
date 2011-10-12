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
    bldng.health = 100
    bldng.x0 = x
    if btype == 1 then
        bldng.value = 500
        bldng.poly = {{-50,-150,50,-150,50,150,-50,150}}
    elseif btype == 2 then
        bldng.value = -500
        bldng.health = 200
        bldng.poly = {{-60,-35,-37,-75,36,-75,59,-35,59,74,-60,74}}
    elseif btype == 3 then
        bldng.value = 1000
        bldng.poly = {{-25,-141,25,-141,25,179,-25,179},{-80,-179,80,-179,80,-141,-80,-141}}
    elseif btype == 4 then
        bldng.value = 100
        bldng.poly = {{-140,-45,131,-45,113,54,-136,54}}
    elseif btype == 5 then
        bldng.value = 50
        bldng.poly = {{-75,55,74,55,74,129,-75,129},{59}}
    elseif btype == 6 then
        bldng.value = 100
        bldng.poly = {{-95,-41,-72,-81,3,-42,3,87,-95,87},{4,37,94,37,94,87,4,87},{11,-86,31,-86,31,35,11,35},{39,-86,57,-86,57,35,39,35},{63,-86,83,-86,83,35,63,35}}
    elseif btype == 7 then
        bldng.value = 50
        bldng.poly = {{-73,-32,71,-32,71,11,-73,11}}
    elseif btype == 8 then
        bldng.value = -1000
        bldng.health = 200
        bldng.poly = {{-50,-130,50,-130,50,130,-50,130}}
    elseif btype == 9 then
        bldng.value = 0
        bldng.poly = {{-100,-150, 100, -150, 100, 150, -100, 150}}
    else
        bldng.value = 0
        bldng.poly = nil
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
                           if bldng.btype == 1 then
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 1, 1), {{-50,122,49,122,49,149,-50,149}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 2, 1), {{-50,-150,49,-150,49,-80,-50,-116}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 3, 1), {{-50,-114,49,-77,49,-51,-50,-40}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 4, 1), {{-50,-40,49,-52,49,15,-50,7}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 5, 1), {{-50,13,49,20,49,73,-50,64}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 6, 1), {{-50,62,49,72,49,121,-50,121}}, bldng.x0))
                           elseif bldng.btype == 2 then
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 1, 1), {{-60,41,34,29,59,47,59,74,-60,74}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 2, 1), {{-60,-35,-36,-75,36,-75,42,-65,-60,1}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 3, 1), {{-31,-17,42,-65,59,-35,59,46}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 4, 1), {{-60,2,-32,-16,32,28,-60,39}}, bldng.x0))
                           elseif bldng.btype == 3 then
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 1, 1), {{-25,96,24,58,24,180,-25,180}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 2, 1), {{-80,-179,80,-179,80,-141,-80,-141},{-24,-142,25,-142,25,-60,-25,-72}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 3, 1), {{-29,-72,20,-59,20,56,-29,94}}, bldng.x0))
                           elseif bldng.btype == 4 then
                               table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 1, 1), {{-136,13,-26,39,-26,54,-136,54}}, bldng.x0))
                               table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 2, 1), {{-18,-45,132,-45,132,-30,-18,-30}}, bldng.x0))
                               table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 3, 1), {{-140,-45,-21,-45,-21,-13,-140,-13}}, bldng.x0))
                               table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 4, 1), {{-117,-12,-7,-12,-7,38,-117,12}}, bldng.x0))
                           elseif bldng.btype == 5 then
                               table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 1, 1), {{-75,103,18,68,73,102,73,129,-75,129}}, bldng.x0))
                               table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 2, 1), {{59}}, bldng.x0))
                               table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 3, 1), {{0,56,74,56,74,102}}, bldng.x0))
                               table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 4, 1), {{-75,56,-2,56,16,68,-75,102}}, bldng.x0))
                           elseif bldng.btype == 6 then
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 1, 1), {{-94,75,94,75,94,87,-94,87}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 2, 1), {{-94,-41,-75,-82,2,-42,-94,-32}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 3, 1), {{11,-86,31,-86,31,35,11,35}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 4, 1), {{39,-86,57,-86,57,35,39,35}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 5, 1), {{63,-86,83,-86,83,35,63,35}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 6, 1), {{-95,-30,3,-39,3,38,-95,6}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 7, 1), {{-95,6,2,38,2,74,-95,74},{3,39,94,39,94,74,3,74}}, bldng.x0))
                           --elseif bldng.btype == 7 then
                           --   table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 1, 1), {{-73,-32,71,-32,71,11,-73,11}}, bldng.x0))
                           elseif bldng.btype == 8 then
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 1, 1), {{50,70,50, 130,-50,130,-50, 107}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 2, 1), {{-50,-80,-50,-130,50,-130,50,-73}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 3, 1), {{-50,78,50,-72,50,-25,-50,0}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 4, 1), {{-50,-3,50,-22,-50,62}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 5, 1), {{-50,-11,50,70,50,78,-50,115}}, bldng.x0))
                           elseif bldng.btype == 9 then
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 1, 1),{{-100,69,-81,100,-100,150},{-81,100,-58,76,-27,86,-100,150},{-27,86,-100,150,14,98,-8,84},{14,98,26,80,47,95,100,150},{47,95,58,80,84,79,100,150},{84,79,100,64, 100, 150},{14,98,100,150,-100,150}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 2, 1),{{-100,-64,-90,-68,-60,-47,-59,75,-81,99,-100,67},{-60,-47,-22,-82,7,-47,-10,-28},{-60,-47,-10,-28,13,-2,-2,14,-59,75},{-2,14,-59,75,-29,86,-8,84},{-8,84,-2,14,26,80,14,97}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 3, 1),{{100,-104,100,65,76,-51,86,-89},{76,-51,86,-89,66,-96},{76,-51,100,65,16,-1,27,-51},{27,-51,13,-68,36,-69,76,-51},{5,-52,27,-51,10,-47},{10,-47,27,-51,16,-1,-8,-28},{16,-1,60,80,49,95,30,82,1,14},{16,-1,100,65,86,78,60,80}}, bldng.x0))
                              table.insert(shards, Shard:create(bldng.x, bldng.y, vx, vy, f_x, f_y, sprite.newSpriteSet(bldng.shardSheet, 4, 1),{{-99,-66,-99,-150,100,-150,-89,-68},{-89,-68,100,-150,-21,-83},{-89,-68,-21,-83,-59,-48},{-21,-83,100,-150,64,-97},{-21,-83,64,-97,36,-69,13,-68},{13,-68,25,-51,4,-53,-21,-83},{36,-69,64,-97,74,-52},{64,-97,100,-150,100,-103,84,-90}}, bldng.x0))
                           end
                           return shards
                       end
                       return nil
                   end
    
    return bldng
end

