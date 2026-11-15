init = function()
  initMenu()
  initPlayer()
  initCamera()
  initGekko()
  initCrab()
  initOgre()
  initGameTimer()
  initSlimeballs()
  
  myMusic = audio.playMusic("fragilebeing", 1, 1)
  
  enemies_cleared = false

  level_complete = false

  level = object
    spawn = object
      x = 0
      y = 0
    end
  end

  setLevel(1)
  respawnPlayer()

  mode = 1
  game_started = false
  paused = true
  overlay_alpha_target = 0.75

  game_over_timer = 0
end


update = function()

  // Update overlay fades
  overlay_alpha = moveToward(overlay_alpha, overlay_alpha_target, 0.05)

  if mode == 3 then

    // Game Over countdown
    game_over_timer -= 1

    if game_over_timer <= 0 then
      resetGame()
    end

  elsif (keyboard.press.ESCAPE or gamepad.press.MENU) and (not paused) then
    pauseGame()

  elsif paused then
    updateMenu()

  elsif mode == 1 then

    updatePlayer()

    if player.damage_cooldown > 0 then
      player.damage_cooldown -= 1
    end

    updateCamera()
    updateGekko()
    updateCrab()
    updateOgre()
    updateSlimeballs()

    checkEnemyDamage()
    
    // Check if all enemies are defeated
if not enemies_cleared and allEnemiesDefeated() then
  enemies_cleared = true
end
    // Check if Meowy has died
    if player.health <= 0 then
      mode = 3
      game_over_timer = 120
      paused = false
      return
    end

    updateGameTimer()

    // Check for level completion
    if level_complete then
      setLevel(level.number + 1)
      respawnPlayer()
    end
  end
end


drawEnemyHealth = function(enemy)

  local heart_size = 8
  local spacing = 9

  // Center the hearts above the enemy
  local total_width = 3 * spacing
  local start_x = enemy.x - total_width / 2 + spacing / 2
  local heart_y = enemy.y + enemy.size / 2 + 10

  for i = 0 to enemy.max_health - 1

    if i < enemy.health then
      screen.drawSprite("heart_full",
        start_x + i * spacing - camera.x,
        heart_y - camera.y,
        heart_size, heart_size)
    else
      screen.drawSprite("heart_empty",
        start_x + i * spacing - camera.x,
        heart_y - camera.y,
        heart_size, heart_size)
    end

  end
end


drawHealth = function()

  for i = 0 to 2
    if i < player.health then
      screen.drawSprite("heart_full",
        -screen.width / 2 + 20 + i * 20,
        screen.height / 2 - 20,
        16, 16)
    else
      screen.drawSprite("heart_empty",
        -screen.width / 2 + 20 + i * 20,
        screen.height / 2 - 20,
        16, 16)
    end
  end
end


draw = function()

  screen.clear()

  if mode == 1 then

    // Draw background
    screen.drawMap("sky" + level.number, -camera.x / 3, -camera.y / 3, 640, 384)

    // Draw level
    screen.drawMap(level.map_name, -camera.x, -camera.y, level.map_width, level.map_height)

    // Draw characters
    drawPlayer()
    drawGekko()
    drawCrab()
    drawOgre()
    drawSlimeballs()
    // Draw health
    drawHealth()

  elsif mode == 2 then

    // Draw victory screen
    screen.drawMap("end_sky", 0, 0, 400, 200)
    screen.drawMap("end_foreground", 0, -20, 400, 200)
    screen.drawSprite("cat_sit", 140, -20, 40, 40)
    drawEndingMessage()

  elsif mode == 3 then

    // Draw Game Over screen
    screen.clear("#111")

    screen.drawText("GAME OVER", 0, 25, 35, "#FF4444")
    screen.drawText("The Slime's revenge has failed...", 0, -15, 15, "#FFFFFF")
    screen.drawText("Returning to menu...", 0, -45, 12, "#AAAAAA")
  end

  drawGameTimer()

  // Draw overlay
  screen.fillRect(0, 0, screen.width, screen.height, "rgba(0, 0, 0," + overlay_alpha + ")")
  
  // Draw ending pop-up
  drawSlimeEnding()
  // Draw menu
  if paused then
    drawMenu()
  end
end


// Apply damage and knockback to Meowy
applyPlayerHit = function()

  player.health -= 1
  player.damage_cooldown = 60

  // Show hit sprite
  player.hit_timer = 12

  // Knock Meowy backwards and upwards
  player.x_velocity = -player.facing * player.knockback_strength
  player.y_velocity = 3

  player.landed = false
  player.climbing = false
end


// Collision with enemies
checkEnemyDamage = function()

  // Check collision with crabs
  for crab in crabs
    if crab.alive and
      abs(player.x - crab.x) < (player.size + crab.size) / 2 and
      abs(player.y - crab.y) < (player.size + crab.size) / 2 then

      if player.damage_cooldown <= 0 then
        applyPlayerHit()
      end
    end
  end

  // Check collision with gekkos
  for gekko in gekkos
    if gekko.alive and
      abs(player.x - gekko.x) < (player.size + gekko.size) / 2 and
      abs(player.y - gekko.y) < (player.size + gekko.size) / 2 then

      if player.damage_cooldown <= 0 then
        applyPlayerHit()
      end
    end
  end
  
  // Check collision with crabs
  for ogre in ogres
    if ogre.alive and
      abs(player.x - ogre.x) < (player.size + ogre.size) / 2 and
      abs(player.y - ogre.y) < (player.size + ogre.size) / 2 then

      if player.damage_cooldown <= 0 then
        applyPlayerHit()
      end
    end
  end
end


// Reset the entire game
resetGame = function()

  // Reset player
  initPlayer()
  
  
  
  // Reset enemies
  initGekko()
  initCrab()
  initOgre()
  
  // Reset slimeballs
  initSlimeballs()

  // Reset timer
  initGameTimer()
  
  // Reset enemies cleared
  enemies_cleared = false
  
  // Reset level
  level_complete = false
  mode = 1
  setLevel(1)
  respawnPlayer()

  // Return to start menu
  game_started = false
  paused = true

  // Reset overlay
  overlay_alpha_target = 0.75

  // Reset Game Over timer
  game_over_timer = 0
end


// HELPER FUNCTIONS

setLevel = function(num)

  overlay_alpha = 2.5
  overlay_alpha_target = 0

  if num == level_spawns.length then
    mode = 2
    adjustHighScore()

  else
    level.number = num
    level.map_name = "level" + num
    level.map = maps[level.map_name]
    level.map_width = level.map.width * level.map.block_width
    level.map_height = level.map.height * level.map.block_height

    level.spawn.x = level_spawns[num][0]
    level.spawn.y = level_spawns[num][1]

    player.facing = level_spawns[num][2]
  end
end


level_spawns = [
  0,
  [-470, -202, 1],
  [415, -202, -1],
  [-474, -10, 1],
  [-15, 6, -1]
]


allEnemiesDefeated = function()

  for gekko in gekkos
    if gekko.alive then
      return false
    end
  end

  for crab in crabs
    if crab.alive then
      return false
    end
  end

  for ogre in ogres
    if ogre.alive then
      return false
    end
  end

  return true
end

drawSlimeEnding = function()

  if not enemies_cleared then return end

  // Dark background
  screen.fillRect(0, 0,
    screen.width, screen.height,
    "rgba(0, 0, 0, 0.8)")

  // Ending drawing
  screen.drawSprite("slime_ending",
    0, 45, 100, 100)

  // Ending message
  screen.drawText(
    "You completed the slime's revenge!",
    0, -30, 17, "#FFFFFF")

  screen.drawText(
    "Now his family can rest in peace...",
    0, -55, 13, "#FFFFFF")

end

drawEndingMessage = function()

  local message = [
    "Congratulations... you have guided Meowy",
    "back to the land of the living.",
    "Meowy is a little wiser for the adventure :-)"
  ]

  // Draw shadow
  local i = 0

  for line in message
    screen.drawText(line, -21, 29 - i, 15, "#333")
    i += 20
  end

  // Draw text
  i = 0

  for line in message
    screen.drawText(line, -20, 30 - i, 15, "#FFF")
    i += 20
  end
end