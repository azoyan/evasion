local Enemy    = require 'actors.Enemy'
local Player   = require 'actors.Player'
local Artifact = require 'actors.Artifacts'
local orientation = require "orientation/orientation"

function love.load()
  needStop = false
  isNight = false
  enemyTime = 10
  artifactTime = 0
  highscore = 0
  enemySpawnTime = 11

  love.window.setMode(1024, 768, { resizable=true, vsync=false, minwidth=480, minheight=320})

  love.graphics.setBackgroundColor(255, 255, 255)

  width, height = love.graphics.getWidth(), love.graphics.getHeight()

  math.randomseed(os.time())
  player    = Player(width / 2, height / 2)
  enemies   = {}
  artifacts = {}

  for _ = 1, 1 do spawnEnemy() end
  player.health = -1


  min_dt = 1/60
  next_time = love.timer.getTime()
  love.resize()

  width = love.graphics.getWidth()
  height = love.graphics.getHeight()
  orientation.screen();
  backgroundColor = { 123, 123, 123 }
end

function love.update(dt)
  width, height = love.graphics.getWidth(), love.graphics.getHeight()
  orientation.update(dt)
  next_time = next_time + min_dt
  needStop = player.health < 0
  --if needStop ~= true then

    highscore = highscore + dt
    player:update(dt)
    updateEnemies(enemies, dt)
    updateArtifacts(artifacts, dt)
    enemyTime    = dt + enemyTime
    artifactTime = dt + artifactTime
    if enemyTime > enemySpawnTime   then spawnEnemy() end
    if artifactTime > math.random(5, 20) then createArtifact() end
  --end
end

function updateEnemies(enemies, dt)
  if table.getn(enemies) < 1 then spawnEnemy() end
  for k, enemy in pairs(enemies) do
    if enemies[k] ~= nil then
      if enemy.shouldRemove then  enemies[k] = nil end
      enemy:update(dt)
      if hasCollide(enemy, player, dt) and not enemy.isTouched then
        player:injure(1)
        enemy:kill()
      end
    end
  end
end

function updateArtifacts(artifacts, dt)
  for k, artifact in pairs(artifacts) do
    if hasCollide(artifact, player, dt) then
      artifacts[k]:use(enemies)
      if artifacts[k].shouldRemove then artifacts[k] = nil end
    end
  end
end

function spawnEnemy()
  local side = math.random(1, 4)
  local start = { x = 0, y = 0 }

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
  if not isNight then love.graphics.setBackgroundColor(backgroundColor)
  else                love.graphics.setBackgroundColor(125, 155, 155)
  end
end

function drawText()
  if needStop then love.graphics.print("You lose", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 0, 2, 2) end
  love.graphics.setColor(0, 0, 0)
  love.graphics.print("Health: " .. player.health .. " FPS: " .. love.timer.getFPS())
  showHighscore(highscore)
end

function showHighscore(highscore) 
  love.graphics.print( "highscore: " .. highscore, love.graphics.getWidth() - 100) 
end

function hasCollide(rect, target, dt)
  local circleDistance_x = math.abs(target.x - rect.x - rect.width  / 2);
  local circleDistance_y = math.abs(target.y - rect.y - rect.height / 2);

  if circleDistance_x > rect.width  / 2 + target.radius then return false end
  if circleDistance_y > rect.height / 2 + target.radius then return false end

  if circleDistance_x <= rect.width  / 2                then return true end
  if circleDistance_y <= rect.height / 2                then return true end

  cornerDistance_sq = (circleDistance_x - rect.width / 2) ^ 2 + (circleDistance_y - rect.height / 2) ^ 2;
  return cornerDistance_sq <= target.radius ^ 2;
end


function love.resize(w, h)
  if w ~= nil and h ~= nil then
    print(("Window resized to width: %d and height: %d."):format(w, h))
    backgroundColor = { math.random(0, 255), math.random(0, 255), math.random(0, 255) }
  end
end

function love.draw()
  local cur_time = love.timer.getTime()
  if next_time <= cur_time then
    next_time = cur_time
    return
  end
  love.timer.sleep(next_time - cur_time)

  love.graphics.push()
  -- Take into account this rotation is pretty basic, use a camera system or something more complex to actually rotate
  love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  love.graphics.rotate(orientation.get()) -- Returns the current orientation
  if orientation.name == "portrait" then 
    love.graphics.translate(-love.graphics.getWidth() / 2, -love.graphics.getHeight() / 2)
  else 
    love.graphics.translate(-love.graphics.getWidth() / 2, -love.graphics.getHeight() / 2)
  end
  drawBackground()
  drawText()
  love.graphics.pop()


  for k, enemy    in pairs(enemies)   do enemy:draw()    end
  for k, artifact in pairs(artifacts) do artifact:draw() end
  player:draw()
end
