local Enemy    = require 'actors.Enemy'
local Player   = require 'actors.Player'
local Artifact = require 'actors.Artifacts'

function love.load()
  needStop = true
  isNight = false
  enemyTime = 0
  artifactTime = 0
  highscore = 0

  love.window.setMode(640, 480, { resizable=true, vsync=false, minwidth=480, minheight=320})

  love.graphics.setBackgroundColor(255, 255, 255)

  player    = Player(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  enemies   = {}
  artifacts = {}

  math.randomseed(os.time())
end

function showHighscore(highscore)
  love.graphics.print( "highscore: " .. highscore, love.graphics.getWidth() - 100)

end
function love.update(dt)
  needStop = player.health < 0
  if needStop ~= true then
    highscore = highscore + dt
    player:update(dt)
    updateEnemies(enemies, dt)
    updateArtifacts(artifacts, dt)
    enemyTime    = dt + enemyTime
    artifactTime = dt + artifactTime
    if enemyTime > 1   then spawnEnemy() end
    if artifactTime > math.random(5, 20) then createArtifact() end
  end
end

function updateEnemies(enemies, dt)
  if table.getn(enemies) < 1 then spawnEnemy() end
  for k, enemy in pairs(enemies) do
    if enemies[k] ~= nil then
      if enemy.shouldRemove then  enemies[k] = nil end
      enemy:update(dt)
      if hasCollide(enemy, player) and not enemy.isTouched then
        player:injure(1)
        enemy:kill()
      end
    end
  end
end

function updateArtifacts()
  for k, artifact in pairs(artifacts) do
    if hasCollide(artifact, player) then
      artifacts[k]:use(enemies)
      if artifacts[k].shouldRemove then artifacts[k] = nil end
    end
  end
end

function spawnEnemy()
  local side = math.random(1, 4)
  local start = {x = 0, y = 0}

  if side == 1 then
    start = { x = math.random(0, love.graphics.getWidth()), y = 0 }
  elseif side == 2 then
    start = { x = math.random(0, love.graphics.getWidth()), y = love.graphics.getHeight() }
  elseif side == 3 then
    start = { x = 0, y = math.random(0, love.graphics.getHeight()) }
  else
    start = { x = love.graphics.getWidth(), y = math.random(0, love.graphics.getHeight()) }
  end


  local n = Enemy(start.x, start.y)
  n:setTarget(player)
  enemies[#enemies + 1] = n
  enemyTime = 0
end

function createArtifact(x, y, type)
  local n = Artifact(math.random(0, love.graphics.getWidth()), math.random(0, love.graphics.getHeight(), type))
  artifacts[#artifacts + 1] = n
  artifactTime = 0
end

function drawBackground()
  if isNight then love.graphics.setBackgroundColor(33, 33, 33)
  else            love.graphics.setBackgroundColor(255, 255, 225)
  end
end

function drawText()
  if needStop then love.graphics.print("You lose", 10, 250, 0, 2, 2) end
  love.graphics.setColor(0, 0, 0)
  love.graphics.print("Health: " .. player.health)
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

function love.draw()
  drawBackground()
  drawText()
  for k, enemy in pairs(enemies)   do    enemy:draw() end
  for _, artifact in pairs(artifacts) do artifact:draw()  end
  player:draw()
end
