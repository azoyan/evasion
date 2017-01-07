Actor = { x = 0, y = 0, typename = "actor", shouldRemove = false, isTouched = false }
Actor.__index = Actor

setmetatable(Actor, {
  __tostring = function(t) return "actor" end,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_new(...)
    return self
  end,
})

function Actor:_new(x, y, typename)
  self.x = x
  self.y = y
  self.typename = typename
end

return Actor
