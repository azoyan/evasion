local Enemy  = require 'actors.Enemy'
local Player = require 'actors.Player'

function love.load()
  needStop = true
  isNight = false
  time = 0

  love.window.setMode(720, 480, {resizable=true, vsync=false, minwidth=480, minheight=720})

  enemies = {}
  player = Player()

  for i = 1, 1 do
    local n = Enemy()
    n:setTarget(player)
    enemies[n] = n
  end
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

  if isTouch and inCircle then
    player.dragging.active = true
    player.dragging.diffX = x - player.x
    player.dragging.diffY = y - player.y
  end
end

function love.mousereleased(x, y, button, isTouch)
  if isTouch then player.dragging.active = false end
end

function showHighscore(highscore)
  love.graphics.print( "highscore: " .. math.floor(236) .. " level: " .. 436 .. " enemy speed: "  .. 324 )
end

function love.update(dt)
  if (needStop == false) then
    player:update(dt)
    for _, enemy in pairs(enemies) do
      enemy:update(dt)
      if hasCollide(enemy, player) then needStop = true end
    end
      time = dt + time;
      if (time > 10) then
        local n = Enemy()
        n:setTarget(player)
        enemies[n] = n
        time = 0
      end

  end
end

function drawBackground()
  color = 0
  love.graphics.setBackgroundColor(color, color, color)
end

function drawText()
  if needStop then love.graphics.print("You lose", 10, 250, 0, 2, 2) end
end

function love.draw()
  drawBackground()
  for _, enemy in pairs(enemies) do enemy:draw() end
  player:draw()
  drawText()
  showHighscore(highscore)
end

function hasCollide(rect, target)
  local circleDistance_x = math.abs(target.x - rect.x - rect.width  / 2);
  local circleDistance_y = math.abs(target.y - rect.y - rect.height / 2);

  if (circleDistance_x > (rect.width  / 2 + target.radius)) then return false end
  if (circleDistance_y > (rect.height / 2 + target.radius)) then return false end

  if (circleDistance_x <= (rect.width / 2)) then return true end
  if (circleDistance_y <= (rect.height/ 2)) then return true end

  cornerDistance_sq = (circleDistance_x - rect.width / 2) ^ 2 + (circleDistance_y - rect.height / 2) ^ 2;
  return (cornerDistance_sq <= (target.radius ^ 2));
end
