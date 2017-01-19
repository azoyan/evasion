local Actor  = require "actors.Actor"
local Screen = require 'effects.shack'

local Enemy = {}

Screen:setDimensions(love.graphics.getDimensions())

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
  self.width  = width  or math.random(biggestSide() / 2, biggestSide() * 2) / 30
  self.height = height or math.random(biggestSide() / 2, biggestSide() * 2) / 30
  self.speed  = speed or 150
  self.target = target
  self.rx = rx or 0
  self.ry = ry or 0
  self.color = color or randomColor()
  self.eyes = math.random(1, 3)
  self.sleepTime = math.random(3, 10)
  self.shouldSleep = false
  self.age = 0
  self.lifeTime = math.random(10, 20)
  self.deathAnimationTime = 0 
  self.secondColor = randomColor()
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

function Enemy:drawEyes(x, y)
  local k = 2 * self.eyes
  local radius = (self.width < self.height and self.width or self.height) / 2 / k
  local x = x + self.width / 2
  local y = y + self.height / 2

  if self.eyes == 1 then
    self:drawEye(x, y, radius)
  elseif self.eyes == 2 then
    if self.height < self.width then
      self:drawEye(x + self.width / 5, y, radius)
      self:drawEye(x - self.width / 5, y, radius)
    else
      self:drawEye(x, y + self.height / 5, radius)
      self:drawEye(x, y - self.height / 5, radius)
    end

  else
    self:drawEye(x, y + self.height / 5, radius)
    self:drawEye(x, y - self.height / 5, radius)
    self:drawEye(x - self.width / 5, y,  radius)
  end
end

function Enemy:drawNormal()
  love.graphics.setColor(self.color)
  --love.graphics.rectangle ("fill", self.x, self.y, self.width, self.height, self.rx, self.ry)
  local centerX = (self.x + self.width) / 2
  local centerY = (self.y + self.height) / 2
  local angle = math.atan2(player.y - self.y , player.x - self.x)
  local a = { 0, 0,                            self.secondColor[1], self.secondColor[2], self.secondColor[3] }
  local b = { 0 + self.width, 0,               self.secondColor[1], self.secondColor[2], self.secondColor[3] }
  local c = { 0 + self.width, 0 + self.height, self.secondColor[1], self.secondColor[2], self.secondColor[3] }
  local d = { 0, 0 + self.height,              self.secondColor[1], self.secondColor[2], self.secondColor[3] }


  local vertices = { a, b, c, d }

  local mesh = love.graphics.newMesh(vertices, "fan", "dynamic")
  love.graphics.draw(mesh, self.x , self.y , 0)
  self:drawEyes(self.x, self.y)
end

function Enemy:shake()
  Screen:setShake(32)
  Screen:apply()
end

function Enemy:drawDeath()
  local color = self.color
  local alpha = 5 / self.deathAnimationTime
  color[4] = alpha
  love.graphics.setColor(color)  --love.graphics.setColor(255, 0, 64, 5 / self.deathAnimationTime)
  love.graphics.circle("fill", self.x, self.y, self.width * 10 * self.deathAnimationTime)
end

function love.resize()

end

function Enemy:update(dt)
  self.age = self.age + dt
  if self.age < self.sleepTime and self.age > self.sleepTime - 0.1 then
    self.shouldSleep = true
  end

  if self.age > self.sleepTime then
    self.sleepTime = self.sleepTime + math.random(1, 6)
    self.shouldSleep = false
  end
  if self.age > self.lifeTime then self:kill() end
  if not self.isTouched then self:follow(self.target, dt)
  else
    self.deathAnimationTime = self.deathAnimationTime + dt
    if (self.deathAnimationTime > DEATH_ANIMATION_TIME) then
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
