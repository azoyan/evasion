local Actor = require "actors.Actor"

local DEFAULT_HEALTH = 3

local DEFAULT_INVULNERABLE_TIME = 3
local INVULNERABLE_TIME = DEFAULT_INVULNERABLE_TIME

local Player = {}

local blinkTimer = 0

for k, v in pairs(Actor) do Player[k] = v end
Player.__index = Player

setmetatable(Player, {
  __index = Actor,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_new(...)
    return self
  end,
})

function Player:setRadius(radius)
  player.radius = radius
end

function Player:_new(x, y, radius, dragging)
  Actor._new(self, x, y, "player")
  self.radius    = radius
  self.minRadius = radius
  self.maxRadius = radius * 2
  self.dragging  = dragging or { active = false, diffX = 0, diffY = 0 }
  self.health    = DEFAULT_HEALTH
  self.isInvulnerable = false
  self.speedX    = 0
  self.speedY    = 0
  self.maxSpeed = biggestSide() / 2  
end

function love.mousepressed(x, y, button, isTouch)
  if needStop then
    needStop = false;
    player.x = x
    player.y = y
    player.health = 3
  end
  local DeltaX = player.x - x
  local DeltaY = player.y - y
  local inCircle = (DeltaX ^ 2 + DeltaY ^ 2) < player.radius ^ 2
  if button == 1 and inCircle then
    player.dragging.active = true
    player.dragging.diffX = x - player.x
    player.dragging.diffY = y - player.y
  end
end

function love.mousereleased(x, y, button, isTouch)
  if button == 1 then 
    player.dragging.active = false 
  end
end

function Player:injure(damage)
  if not player.isInvulnerable then
    self.health = self.health - 1
    self.isInvulnerable = true
  end
end

function Player:move(dt)
  local x = self.x
  local y = self.y
  if joystick then joystick.update(dt)
    player.speedx = player.maxSpeed * joystick.getX()
    player.speedy = player.maxSpeed * joystick.getY()
    player.x = player.x + player.speedx * dt
    player.y = player.y + player.speedy * dt
    -- if player.x > love.graphics.getWidth() or player.x < 0 then player.x = math.abs(player.x % love.graphics.getWidth()) end
    -- if player.y > love.graphics.getHeight() or player.y < 0 then player.y = math.abs(player.y % love.graphics.getHeight()) end
  end
  if self.dragging.active then
    self.x = love.mouse.getX() - self.dragging.diffX
    self.y = love.mouse.getY() - self.dragging.diffY
  end
  local offset = dt * math.sqrt((x - self.x) ^ 2 + (y - self.y) ^ 2)  
  self:resize(offset, dt)
end

function Player:resize(offset, dt)  
  if self.dragging.active then
    if (offset > dt and self.radius < self.maxRadius) then 
      self.radius = self.radius + offset
    elseif 
      self.radius > self.minRadius then self.radius = self.radius - dt * 20
    else                                     
      self.radius = self.minRadius end
  else 
    self.radius = self.radius > self.minRadius and self.radius - dt * 20 or self.minRadius 
  end
end

function Player:update(dt)
  self:move(dt)  
  if self.isInvulnerable then
    if INVULNERABLE_TIME < 0 then 
      self.isInvulnerable = false
    else                          
      INVULNERABLE_TIME = INVULNERABLE_TIME - dt
      blinkTimer = blinkTimer + dt
    end
  else 
    INVULNERABLE_TIME = DEFAULT_INVULNERABLE_TIME
  end
end

function Player:draw()
  local color = self.isInvulnerable and { 127, 127, 127 } or {  255 / self.health, 255 / 3 * self.health, 0, 128 }
  if     blinkTimer < 0.5                    then color = {127, 127, 127}
  elseif blinkTimer > 0.5 and blinkTimer < 1 then color = {0 ,0 ,0, 50}
  else                                            blinkTimer = 0
  end
  love.graphics.setColor(color) 
  love.graphics.circle("fill", self.x, self.y, self.radius)  
end

return Player
