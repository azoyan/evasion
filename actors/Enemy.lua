local Actor = require "actors.Actor"
local Screen= require 'effects.shack'

local Enemy = {
  width  = 50,
  height = 50,
  speed  = 150,
  target = nil,
  timer = 0,
}
Screen:setDimensions(love.graphics.getDimensions())



local DEATH_ANIMATION_TIME = 0.3

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
  Actor._new(self, x, y, "enemy", false, false)
  self.width  = width
  self.height = height
  self.speed  = speed
  self.target = target
end

function Enemy:kill()
  self.isTouched = true
end

function Enemy:toRemove()
  self.shouldRemove = true
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
  if not self.isTouched then self:normal()
  else                       self:death() end
end

function Enemy:normal()
  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

end

function Enemy:shake()
  Screen:setShake(32)
  Screen:apply()
end

function Enemy:death()
  self:shake()
  love.graphics.setColor(255, 0, 64, 5 / self.timer)
  love.graphics.circle("fill", self.x, self.y, self.width * 10 * self.timer)
end

function Enemy:update(dt)
  if not self.isTouched then self:follow(self.target, dt)
  else
    self.timer = self.timer + dt
    if (self.timer > DEATH_ANIMATION_TIME) then self.shouldRemove = true end
  end
end

function Enemy:addSpeed(addiction)
  self.speed = self.speed + addiction
end

function Enemy:setTarget(target)
  self.target = target
end

return Enemy
