local Actor = require "actors.Actor"
local Screen= require 'effects.shack'

local Enemy = {
  width  = 25,
  height = 25,
  speed  = 150,
  target = nil,
  timer = 0,
  rx,
  ry,
  color = {}
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
  self.width  = width ~= nil and width or math.random(25, 100)
  self.height = height ~= nil and height or math.random(25, 100)
  self.speed  = speed
  self.target = target
  self.rx = rx ~=nil and rx or math.random(-self.width, self.width)
  self.ry = ry ~=nil and ry or math.random(-self.height, self.height)
  self.color = color ~=nil and color or { math.random(0, 255), math.random(0, 255), math.random(0, 255)  }
end

function Enemy:kill()
  self.isTouched = true
  plop:play()
  love.system.vibrate(0.02)
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

function Enemy:rotatedRectangle( mode, x, y, w, h, rx, ry, segments, r, ox, oy )
   -- Check to see if you want the rectangle to be rounded or not:
   if not oy and rx then r, ox, oy = rx, ry, segments end
   -- Set defaults for rotation, offset x and y
   r = r or 0
   ox = ox or w / 2
   oy = oy or h / 2
   -- You don't need to indent these; I do for clarity
   love.graphics.push()
      love.graphics.translate( x + ox, y + oy )
      love.graphics.push()
         love.graphics.rotate( -r )
         love.graphics.rectangle( mode, -ox, -oy, w, h, rx, ry, segments )
      love.graphics.pop()
   love.graphics.pop()
end


function Enemy:drawEyes()
  local eye1 = { x = self.x + self.width / 2, y = self.y + self.height / 2 + self.height / 5, radius =  self.width / 6}  -- yeah its weird
  local eye2 = { x = self.x + self.width / 2, y = self.y + self.height / 2 - self.height / 5, radius =  self.height / 6} -- but's looks cool
  love.graphics.setColor(255, 255, 255)
  love.graphics.circle("fill", eye1.x, eye1.y, eye1.radius)
  love.graphics.circle("fill", eye2.x, eye2.y, eye2.radius)

  local diff       = function(player, eye)  return { x = player.x - eye.x, y = player.y - eye.y } end
  local length     = function(diff)         return math.sqrt(diff.x ^ 2 + diff.y ^ 2)             end
  local unitVector = function(diff, length) return { x = diff.x / length, y = diff.y / length }   end

  local diff       = diff(player, eye1)
  local length     = length(diff)
  local unitVector = unitVector(diff, length)

  pupil1 = { x = eye1.x + unitVector.x * eye1.radius / 2, y = eye1.y + unitVector.y * eye1.radius / 2, radius = eye1.radius / 2 }
  pupil2 = { x = eye2.x + unitVector.x * eye2.radius / 2, y = eye2.y + unitVector.y * eye2.radius / 2, radius = eye2.radius / 2 }

  love.graphics.setColor(0, 0, 0)
  love.graphics.circle("fill", pupil1.x, pupil1.y, pupil1.radius)
  love.graphics.circle("fill", pupil2.x, pupil2.y, pupil2.radius)
end

function Enemy:normal()
  love.graphics.setColor(self.color)
  local angle = math.atan2(player.y - self.y , player.x - self.x)
  love.graphics.rectangle ("fill", self.x, self.y, self.width, self.height, self.rx, self.ry)
  self:drawEyes()
end

function Enemy:shake()
  Screen:setShake(32)
  Screen:apply()
end

function Enemy:death()
  self:shake()
  local color = self.color
  local alpha = 5 / self.timer
  color[4] = alpha
  love.graphics.setColor(color)  --love.graphics.setColor(255, 0, 64, 5 / self.timer)
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
