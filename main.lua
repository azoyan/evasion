local Enemy    = require 'actors.Enemy'
local Player   = require 'actors.Player'
local Artifact = require 'actors.Artifacts'

function love.load()
  needStop = true
  isNight = false
  enemyTime = 0
  artifactTime = 0

  love.window.setMode(640, 480, { resizable=true, vsync=false, minwidth=480, minheight=320})

  enemies   = {}
  artifacts = {}
  player    = Player()

    -- for i = 1, 1 do
    --   local n = Enemy()
    --   n:setTarget(player)
    --   enemies[n] = n
    -- end

  
end

function showHighscore(highscore)
  --love.graphics.print( "highscore: " .. math.floor(236) .. " level: " .. 436 .. " enemy speed: "  .. 324 )
end

function love.update(dt)
  if player.health > 0 then
     player:update(dt)
     updateEnemies(enemies, dt)
     updateArtifacts(artifacts, dt)
    enemyTime    = dt + enemyTime
    artifactTime = dt + artifactTime
    if (enemyTime > 5)    then spawnEnemy() enemyTime = 0 end
    if (artifactTime > 5) then createArtifact(math.random(0, love.graphics.getWidth()), math.random(0, love.graphics.getHeight())) artifactTime = 0 end
  end
end

function updateEnemies(enemies, dt)
  for k, enemy in pairs(enemies) do
    enemy:update(dt)
    if hasCollide(enemy, player) then player:injure(1) end
    if enemy.needSweep then enemies[k] = nil end
  end
end

function updateArtifacts()
  for k, artifact in pairs(artifacts) do
    if hasCollide(artifact, player) then
      artifacts[k]:use(enemies)
      if artifacts[k].needSweep then artifacts[k] = nil end
    end
  end
end

function spawnEnemy()
  local n = Enemy()
  n:setTarget(player)
  enemies[n] = n
end

function createArtifact(x, y)
  local n = Artifact(x, y)
  artifacts[n] = n
end

function drawBackground()
  color = 44
  love.graphics.setBackgroundColor(color, color, color)
end

function drawText()
  if needStop then love.graphics.print("You lose", 10, 250, 0, 2, 2) end
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
  for _, enemy    in pairs(enemies)   do enemy:draw()     end
  for _, artifact in pairs(artifacts) do artifact:draw()  end
  player:draw()
end
