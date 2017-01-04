local Actor = require "actors.Actor"

local Enemy = {
  width  = 50,
  height = 50,
  speed  = 150,
  target = nil
}

for k, v in pairs(Actor) do  Enemy[k] = v end
Enemy.__index = Enemy

setmetatable(Enemy, {
  __index = Actor, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_new(...)
    return self
  end,
})

function Enemy:_new(x, y, width, height, speed, target)
  Actor._new(self, x, y)
  self.width  = width
  self.height = height
  self.speed  = speed
  self.target = target
end

function Enemy:follow(target, dt)
  local nearestX = math.max(self.x, math.min(target.x, self.x + self.width))
  local nearestY = math.max(self.y, math.min(target.y, self.y + self.height))
  if target.x > nearestX then self.x = self.x + self.speed * dt end
  if target.x < nearestX then self.x = self.x - self.speed * dt end
  if target.y > nearestY then self.y = self.y + self.speed * dt end
  if target.y < nearestY then self.y = self.y - self.speed * dt end
end

function Enemy:draw()
  love.graphics.setColor(255, 0, 64)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Enemy:update(dt)
  self:follow(self.target, dt)
end

function Enemy:addSpeed(addiction)
  self.speed = self.speed + addiction
end

function Enemy:setTarget(target)
  self.target = target
end

return Enemy
