Actor = { x = 0, y = 0 }
Actor.__index = Actor

setmetatable(Actor, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_new(...)
    return self
  end,
})

function Actor:_new(x, y)
  self.x = x
  self.y = y
end

return Actor
