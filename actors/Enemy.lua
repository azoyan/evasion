local Actor = require "actors.Actor"
local Screen= require 'effects.shack'

local Enemy = {
  width  = 0,
  height = 0,
  speed  = 150,
  target = nil,
  timer = 0,
  rx = 0,
  ry = 0,
  color = {},
  sleepTime = 0,
  shouldSleep = false,
  age = 0,
  fatefulTime = 0,
}

Screen:setDimensions(love.graphics.getDimensions())

local monster = love.graphics.newImage("assets/monster.png")
local plop    = love.audio.newSource("assets/Explosion.wav", "static")

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

function Enemy:_new(x, y, width, height, speed, target, rx, ry, color)
  Actor._new(self, x, y, "enemy", false, false)
  self.width  = width  or math.random(25, 50)
  self.height = height or math.random(25, 50)
  self.speed  = speed
  self.target = target
  self.rx = rx or math.random(-self.width / 2, self.width)
  self.ry = ry or math.random(-self.height / 2, self.height)
  self.color = color or { math.random(0, 255), math.random(0, 255), math.random(0, 255)  }
  self.eyes = math.random(1, 3)
  self.sleepTime = math.random(1, 15)
  self.fatefulTime = math.random(10, 20)
end


function Enemy:kill()     self.isTouched    = true end
function Enemy:toRemove() self.shouldRemove = true end

function Enemy:follow(target, dt)
  local nearestX = math.max(self.x, math.min(target.x, self.x + self.width))
  local nearestY = math.max(self.y, math.min(target.y, self.y + self.height))
  if target.x > nearestX then self.x = self.x + self.speed * dt end
  if target.x < nearestX then self.x = self.x - self.speed * dt end
  if target.y > nearestY then self.y = self.y + self.speed * dt end
  if target.y < nearestY then self.y = self.y - self.speed * dt end
end

function Enemy:draw()
  if not self.isTouched then self:drawNormal()
  else                       self:drawDeath() end
end

function Enemy:drawEye(x, y, radius, color)
  local apple = {x = x, y = y, radius = radius }

  local pupilColor = color or { 0, 0, 0 }
  local appleColor = { 255, 255, 255 }
  local diff       = { x = player.x - apple.x, y = player.y - apple.y }
  local length     = math.sqrt(diff.x ^ 2 + diff.y ^ 2)
  local unitVector = { x = diff.x / length, y = diff.y / length }
  pupil = { x = apple.x + unitVector.x * apple.radius / 2, y = apple.y + unitVector.y * apple.radius / 2, radius = apple.radius / 2 }

  if self.shouldSleep then pupilColor, appleColor = self.color, self.color end

  love.graphics.setColor(appleColor)
  love.graphics.circle("fill", apple.x, apple.y, apple.radius)
  love.graphics.setColor(pupilColor)
  love.graphics.circle("fill", pupil.x, pupil.y, pupil.radius)
end

function Enemy:drawEyes()
  local k = 1
  local radius = self.width < self.height and self.width or self.height
  local x = self.x + self.width / 2
  local y = self.y + self.height / 2

  if self.eyes == 1 then
    k = 3
    radius = radius / k
    self:drawEye(x, y, radius)
  elseif self.eyes == 2 then
    k = 6
    radius = radius / k
    self:drawEye(x, y + self.height / 5, radius )
    self:drawEye(x, y - self.height / 5, radius )
  else
    k = 8
    radius = radius / k
    self:drawEye(x, y + self.height / 5, radius)
    self:drawEye(x, y - self.height / 5, radius)
    self:drawEye(x - self.width / 5, y,  radius)
  end
end

function Enemy:drawNormal()
  love.graphics.setColor(self.color)
  local angle = math.atan2(player.y - self.y , player.x - self.x)
  love.graphics.rectangle ("fill", self.x, self.y, self.width, self.height, self.rx, self.ry)
  self:drawEyes()
end

function Enemy:shake()
  Screen:setShake(32)
  Screen:apply()
end

function Enemy:drawDeath()
  local color = self.color
  local alpha = 5 / self.timer
  color[4] = alpha
  love.graphics.setColor(color)  --love.graphics.setColor(255, 0, 64, 5 / self.timer)
  love.graphics.circle("fill", self.x, self.y, self.width * 10 * self.timer)
end

function Enemy:update(dt)
  self.age = self.age + dt
  if self.age < self.sleepTime and self.age > self.sleepTime - 0.2 then
    self.shouldSleep = true
  end

  if self.age > self.sleepTime then
    self.sleepTime = self.sleepTime + math.random(1, 15)
    self.shouldSleep = false
  end
  if self.age > self.fatefulTime then self:kill() end




  if not self.isTouched then self:follow(self.target, dt)
  else
    self.timer = self.timer + dt
    if (self.timer > DEATH_ANIMATION_TIME) then
      plop:play()
      self:toRemove() end
  end
end

function Enemy:addSpeed(addiction)
  self.speed = self.speed + addiction
end

function Enemy:setTarget(target)
  self.target = target
end

return Enemy
