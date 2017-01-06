local Actor = require "actors.Actor"

local MIN_RADIUS     = love.graphics.getWidth() / 20 + love.graphics.getHeight() / 20
local NORMAL_RADIUS  = MIN_RADIUS * 2
local MAX_RADIUS     = NORMAL_RADIUS * 2
local DEFAULT_HEALTH = 3

local DEFAULT_INVULNERABLE_TIME = 3
local INVULNERABLE_TIME = DEFAULT_INVULNERABLE_TIME

local Player = {
  radius = NORMAL_RADIUS,
  dragging = { active = false, diffX = 0, diffY = 0 },
  health = DEFAULT_HEALTH,
  isInvulnerable = false,
}

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

function Player:_new(x, y, radius, dragging)
  Actor._new(self, x, y, "player")
  self.radius   = radius
  self.dragging = dragging
end

function love.mousepressed(x, y, button, isTouch)
  if needStop then
    needStop = false;
    player.x = x
    player.y = y
  end

  DeltaX = player.x - x
  DeltaY = player.y - y
  local inCircle = (DeltaX ^ 2 + DeltaY ^ 2) < player.radius ^ 2

  if isTouch or button == 1 and inCircle then
    player.dragging.active = true
    player.dragging.diffX = x - player.x
    player.dragging.diffY = y - player.y
  end
end

function love.mousereleased(x, y, button, isTouch)
  if isTouch or button ~=1 then player.dragging.active = false end
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
  if self.dragging.active then
    self.x = love.mouse.getX() - self.dragging.diffX
    self.y = love.mouse.getY() - self.dragging.diffY
  end
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
    if INVULNERABLE_TIME  < 0 then self.isInvulnerable = false
    else                           INVULNERABLE_TIME = INVULNERABLE_TIME - dt
    end
  else INVULNERABLE_TIME = DEFAULT_INVULNERABLE_TIME
  end
end

function Player:draw()
  local color = self.isInvulnerable and { 127, 127, 127 } or {  255 / self.health, 255 / 3 * self.health, 0, 128 }
  love.graphics.rotate(91)
  love.graphics.setColor(color)
  love.graphics.circle("fill", self.x, self.y, self.radius)
  love.graphics.setColor(0, 255, 125)
  _, m, r, c = love.getVersion()
  love.graphics.print("player x: " .. self.x .. " y: " .. self.y .. " radius: " .. self.radius .. " version: " .. m .. " health: " .. self.health)
end

return Player
