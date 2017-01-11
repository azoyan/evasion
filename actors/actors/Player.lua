local Actor = require "actors.Actor"
require "andralog.andralog"

local DEFAULT_HEALTH = 3

local DEFAULT_INVULNERABLE_TIME = 3
local INVULNERABLE_TIME = DEFAULT_INVULNERABLE_TIME

local Player = {
  radius = 0,
  dragging = { active = false, diffX = 0, diffY = 0 },
  health = DEFAULT_HEALTH,
  isInvulnerable = false,
}

local joystickRadius = smallestSide() / 20

joystick = newAnalog(x, y, joystickRadius, joystickRadius * 0.75, 0)

for k, v in pairs(Actor) do Player[k] = v end
Player.__index = Player

local NORMAL_RADIUS = 0
local MAX_RADIUS = 0

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

function love.resize()
  MIN_RADIUS = biggestSide() / 60
  NORMAL_RADIUS = MIN_RADIUS * 2
  MAX_RADIUS = NORMAL_RADIUS * 2
  Player:setRadius(MIN_RADIUS)
end

function Player:_new(x, y, radius, dragging)
  Actor._new(self, x, y, "player")
  self.radius   = radius
  self.dragging = dragging
  self.speedX = 0
  self.speedY = 0
  self.maxSpeed = biggestSide() / 2
end

-- function love.mousepressed(x, y, button, isTouch)
--   if needStop == true then
--     needStop = false;
--     player.x = x
--     player.y = y
--     player.health = 3
--   end

--   DeltaX = player.x - x
--   DeltaY = player.y - y
--   local inCircle = (DeltaX ^ 2 + DeltaY ^ 2) < player.radius ^ 2

--   if isTouch and inCircle then
--     player.dragging.active = true
--     player.dragging.diffX = x - player.x
--     player.dragging.diffY = y - player.y
--   end
-- end

--function love.mousereleased(x, y, button, isTouch)
--   if isTouch then player.dragging.active = false end
--end

function Player:injure(damage)
  if not player.isInvulnerable then
    self.health = self.health - 1
    self.isInvulnerable = true
  end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  joystick.isVisible = true
  joystick.cx, joystick.cy = x, y
  joystick.touchPressed(id, x, y, dx, dy, pressure)
end

function love.touchreleased(id, x, y, dx, dy, pressure)	joystick.touchReleased(id, x, y, dx, dy, pressure)
   joystick.isVisible = false
 end

function love.touchmoved(id, x, y, dx, dy, pressure)
  joystick.touchMoved(id, x, y, dx, dy, pressure)
end
function love.mousepressed(x, y, button)
	love.touchpressed(1, x, y, 0, 0, 1)
	mousepressed = true
end

function love.mousereleased(x, y, button)
	love.touchreleased(1, x, y, 0, 0, 1)
	mousepressed = false
end

function Player:move(dt)
  local x = self.x
  local y = self.y
  if joystick then joystick.update(dt)
    player.speedx = player.maxSpeed * joystick.getX()
    player.speedy = player.maxSpeed * joystick.getY()
    player.x = player.x + player.speedx * dt
    player.y = player.y + player.speedy * dt
    if player.x > love.graphics.getWidth() or player.x < 0 then player.x = math.abs(player.x % love.graphics.getWidth()) end
    if player.y > love.graphics.getHeight() or player.y < 0 then player.y = math.abs(player.y % love.graphics.getHeight()) end
  end
  -- if self.dragging.active then
  --   self.x = love.mouse.getX() - self.dragging.diffX
  --   self.y = love.mouse.getY() - self.dragging.diffY
  -- end
  local offset = dt * math.sqrt((x - self.x) ^ 2 + (y - self.y) ^ 2)
  self:resize(offset, dt)
end

function Player:resize(offset, dt)
  if self.dragging.active then
    if (offset > dt and self.radius < MAX_RADIUS) then self.radius = self.radius + offset
    elseif self.radius > NORMAL_RADIUS then self.radius = self.radius - dt * 20
    else                                    self.radius = NORMAL_RADIUS end
  else self.radius = self.radius > NORMAL_RADIUS and self.radius - dt * 20 or NORMAL_RADIUS end
end

function Player:update(dt)
  self:move(dt)
  if self.isInvulnerable then
    if INVULNERABLE_TIME < 0 then self.isInvulnerable = false
    else                          INVULNERABLE_TIME = INVULNERABLE_TIME - dt
    end
  else INVULNERABLE_TIME = DEFAULT_INVULNERABLE_TIME
  end
end

function Player:draw()
  local color = self.isInvulnerable and { 127, 127, 127 } or {  255 / self.health, 255 / 3 * self.health, 0, 128 }
  love.graphics.setColor(color)
  love.graphics.circle("fill", self.x, self.y, self.radius)
  love.graphics.setColor(0, 255, 125)
  _, m, r, c = love.getVersion()
end

return Player
