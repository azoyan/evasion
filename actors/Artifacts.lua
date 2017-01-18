local Actor = require "actors.Actor"

local Artifact = {
  width  = 10,
  height = 10,
  speed  = 0,
  type = 0,
}

local addHealth = love.graphics.newImage("assets/emergency.png")
local freeze = love.graphics.newImage("assets/freeze.png")
local anchor = love.graphics.newImage("assets/anchor.png")
local bomb = love.graphics.newImage("assets/bomb.png")
local flame = love.graphics.newImage("assets/flame.png")
local pickup = love.audio.newSource("assets/pickup.wav", "static")

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

function Artifact:_new(x, y, type)
  Actor._new(self, x, y, "artifcat")
  self.width,
  self.height = 32, 32
  self.speed  = speed
  self.type = type ~= 0 and math.random(1, 5) or type
end

function Artifact:draw()
  color = {}
  love.graphics.setColor(255, 255, 255)
  if     self.type == 1 then love.graphics.draw(bomb, self.x, self.y)
  elseif self.type == 2 then love.graphics.draw(anchor, self.x, self.y)
  elseif self.type == 3 then love.graphics.draw(freeze, self.x, self.y)
  elseif self.type == 4 then love.graphics.draw(flame, self.x, self.y)
  elseif self.type == 5 then love.graphics.draw(addHealth, self.x, self.y)
  else                       color = {255, 255, 255} end

-- Ещё артефакты:
-- деньги
-- неуязвимость / щит
-- призрак
-- ловушка приманка
-- отпугиватель
-- мина
-- булава
-- взрывная волна

end

function Artifact:use(enemies)
  if self.type == 1 then
    for k, v in pairs(enemies) do  enemies[k]:kill() end
  elseif self.type == 2 then
    for k, v in pairs(enemies) do  enemies[k].speed = 0.5 end
  elseif self.type == 3 then
    for k, v in pairs(enemies) do  enemies[k].speed = enemies[k].speed / 2 end
  elseif self.type == 4 then
    for k, v in pairs(enemies) do  enemies[k].speed = enemies[k].speed * 2 end
  elseif self.type == 5 then   player.health = player.health + 1
  elseif self.type == 6 then   player:injure(1) player.health = player.health + 1 end

  self.shouldRemove = true
  pickup:play()
end

return Artifact
