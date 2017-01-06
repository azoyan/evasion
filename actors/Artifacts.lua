local Actor = require "actors.Actor"

local Artifact = {
  width  = 10,
  height = 10,
  speed  = 0,
  types = { freezeEnemies, stopEnemies },
  type = freezeEnemies,
}

debug = "\n"
for k, v in pairs(Actor) do  Artifact[k] = v end
Artifact.__index = Artifact

setmetatable(Artifact, {
  __index = Actor, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_new(...)
    return self
  end,
})

function Artifact:update(dt)

end

function Artifact:_new(x, y, width, height, speed, target)
  Actor._new(self, x, y, "artifcat")
  self.width  = width
  self.height = height
  self.speed  = speed
end

function Artifact:draw()
  love.graphics.setColor(127, 227, 40)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  love.graphics.print("\n" .. debug)
end

function Artifact:use(enemies)
  if (self.type == freezeEnemies) then
    for k, v in pairs(enemies) do
      enemies[k].needSweep = true  -- это работает
      debug = debug .. tostring(enemies[k]) .. "tn: " .. enemies[k].typename .. " v: " .. tostring(v) .. " vtn: " .. v.typename .. "\n"
    end
    self.needSweep = true
  end
end

return Artifact
