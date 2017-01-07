local Enemy    = require 'actors.Enemy'
local Player   = require 'actors.Player'
local Artifact = require 'actors.Artifacts'

function love.load()
  needStop = true
  isNight = false
  enemyTime = 0
  artifactTime = 0

  love.window.setMode(640, 480, { resizable=true, vsync=false, minwidth=480, minheight=320})

  love.graphics.setBackgroundColor(255, 255, 255)

  player    = Player(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  enemies   = {}
  artifacts = {}

  math.randomseed(os.time())
end

function showHighscore(highscore)
  love.graphics.print( "highscore: " .. math.floor(236) .. " level: " .. 436 .. " enemy speed: "  .. 324 )
end

function love.update(dt)
  if player.health > 0 then
     player:update(dt)
     updateEnemies(enemies, dt)
     updateArtifacts(artifacts, dt)
    enemyTime    = dt + enemyTime
    artifactTime = dt + artifactTime
    if enemyTime > 1    then spawnEnemy() end
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
  local n = Enemy(math.random())
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
  color = 156
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
  local count = 0
  for k, enemy in pairs(enemies)   do    enemy:draw() end
  for _, artifact in pairs(artifacts) do artifact:draw()  end
  player:draw()
end
