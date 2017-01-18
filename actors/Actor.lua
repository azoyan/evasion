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

function biggestSide() 
  return love.graphics.getHeight() < love.graphics.getWidth() and love.graphics.getWidth() or love.graphics.getHeight() 
end
function smallestSide() 
  return love.graphics.getHeight() > love.graphics.getWidth() and love.graphics.getWidth() or love.graphics.getHeight() 
end

function randomColor()
  return { math.random(0, 255), math.random(0, 255), math.random(0, 255)  }
end
return Actor
