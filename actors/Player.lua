local Actor = require "actors.Actor"

local Player = {
  radius = 100,
  dragging = { active = false, diffX = 0, diffY = 0 }
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
  Actor._new(self, x, y)
  self.radius   = radius
  self.dragging = dragging
end

function Player:move()
  if self.dragging.active then
    self.x = love.mouse.getX() - player.dragging.diffX
    self.y = love.mouse.getY() - player.dragging.diffY
  end
end

function Player:update(dt)
  self:move()
end

function Player:draw()
  love.graphics.setColor(0, 255, 0)
  love.graphics.circle("line", self.x, self.y, self.radius)
end

return Player
