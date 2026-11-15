
initSlimeballs = function()
  slimeballs = []
  throw_cooldown = 0
end


throwSlimeball = function()

  if throw_cooldown > 0 then return end

  local ball = object
    x = player.x + player.facing * 18
    y = player.y + 5

    x_velocity = player.facing * 1
    y_velocity = 1.5

    size = 12
    alive = true
  end

  slimeballs.push(ball)
  throw_cooldown = 20

end


updateSlimeballs = function()

  if throw_cooldown > 0 then
    throw_cooldown -= 1
  end

  // Throw with F
  if keyboard.press.F then
    throwSlimeball()
  end

  for ball in slimeballs

    if not ball.alive then continue end

    // Movement
    ball.y_velocity -= 0.12

    ball.x += ball.x_velocity
    ball.y += ball.y_velocity

    // Check collision with walls and ground
    local hw = level.map_width / 2
    local hh = level.map_height / 2

    local tile_x = floor((ball.x + hw) / 16)
    local tile_y = floor((ball.y + hh) / 16)

    if level.map.get(tile_x, tile_y).startsWith("ground") then
      ball.alive = false
    end

    // Check collision with crabs
    for crab in crabs
      if ball.alive and crab.alive and
        abs(ball.x - crab.x) < (ball.size + crab.size) / 2 and
        abs(ball.y - crab.y) < (ball.size + crab.size) / 2 then

        crab.health -= 1

        if crab.health <= 0 then
          crab.alive = false
        end

        ball.alive = false
      end
    end

    // Check collision with gekkos
    for gekko in gekkos
      if ball.alive and gekko.alive and
        abs(ball.x - gekko.x) < (ball.size + gekko.size) / 2 and
        abs(ball.y - gekko.y) < (ball.size + gekko.size) / 2 then

        gekko.health -= 1

        if gekko.health <= 0 then
          gekko.alive = false
        end

        ball.alive = false
      end
    end

    // Check collision with ogres
    for ogre in ogres
      if ball.alive and ogre.alive and
        abs(ball.x - ogre.x) < (ball.size + ogre.size) / 2 and
        abs(ball.y - ogre.y) < (ball.size + ogre.size) / 2 then

        ogre.health -= 1

        if ogre.health <= 0 then
          ogre.alive = false
        end

        ball.alive = false
      end
    end

    // Remove balls that fall off the map
    if ball.y < (-level.map_height / 2 - 50) then
      ball.alive = false
    end

  end
end


drawSlimeballs = function()

  for ball in slimeballs
    if ball.alive then
      screen.drawSprite("slimeball",
        ball.x - camera.x,
        ball.y - camera.y,
        ball.size)
    end
  end

end
