Building = {}
Building.__index = Building

function Building.create(x, y, btype, status)
    x = x or 0
    y = y or 0
    btype = btype or 0
    status = status or 0
    local bldng = {}
    setmetatable(bldng, Building)
    bldng.x = x
    bldng.y = y
    bldng.type = type
    bldng.status = status
    if type == 0 then
        bldng.health = 100
    else
        health = 0
    end
    return bldng
end

function Building:TakeDamage(damage)
    self.health -= damage
    if self.health <= 0 then
        self.health == 0
    end
end

