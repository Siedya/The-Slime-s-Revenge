initGekko = function()
  gekko = object
    x = 200
    y = -100
    
    x_velocity = 0
    y_velocity = 0
    facing = 1

    size = 25
    speed = 0.7
        // Chasing behaviour
    chase_range = 150
    chase_speed = 1.2
    chasing = false
    chase_blocked = false
    max_fall_speed = 4
    landed = false
    alive = true
    health = 2
    max_health = 2

    // Patrol boundaries
    patrol_min = 50
    patrol_max = 200
  end

  gekkos = [gekko]
end


updateGekko = function()

  if not gekko.alive then return end

  // Automatic horizontal movement
  //gekko.x_velocity = gekko.facing * gekko.speed
   // Check distance to player
local distance_x = abs(player.x - gekko.x)
local distance_y = abs(player.y - gekko.y)

// Detect player
if distance_x < gekko.chase_range and distance_y < 50 then
  if not gekko.chase_blocked then
    gekko.chasing = true
  end
else
  gekko.chasing = false
  gekko.chase_blocked = false
end

// Choose movement
if gekko.chasing then

  // Face the player
  if player.x < gekko.x then
    gekko.facing = -1
  else
    gekko.facing = 1
  end

  gekko.x_velocity = gekko.facing * gekko.chase_speed

else

  // Normal patrol
  gekko.x_velocity = gekko.facing * gekko.speed

end

  // Gravity
  gekko.y_velocity -= 0.2

  if gekko.y_velocity < -gekko.max_fall_speed then
    gekko.y_velocity = -gekko.max_fall_speed
  end

  local map = level.map
  local hw = level.map_width / 2
  local hh = level.map_height / 2

  // Calculate collision positions
  local old_top = floor((gekko.y + 4 + hh) / 16)
  local old_bottom = floor((gekko.y - 6 + hh) / 16)
  local old_right = floor((gekko.x + 4 + hw) / 16)
  local old_left = floor((gekko.x - 4 + hw) / 16)

  local new_top = floor((gekko.y + gekko.y_velocity + 4 + hh) / 16)
  local new_bottom = floor((gekko.y + gekko.y_velocity - 6 + hh) / 16)
  local new_right = floor((gekko.x + gekko.x_velocity + 4 + hw) / 16)
  local new_left = floor((gekko.x + gekko.x_velocity - 4 + hw) / 16)

  // Falling and landing
  if gekko.y_velocity < 0 and
    (map.get(old_left, new_bottom).startsWith("ground") or
     map.get(old_right, new_bottom).startsWith("ground")) then

    gekko.y = -hh + (new_bottom + 1) * 16 + 6
    gekko.y_velocity = 0
    gekko.landed = true

  // Hitting a ceiling
  elsif gekko.y_velocity > 0 and
    (map.get(old_left, new_top).startsWith("ground") or
     map.get(old_right, new_top).startsWith("ground")) then

    gekko.y_velocity = 0

  else
    gekko.landed = false
  end

  // Hitting a wall on the left
  if gekko.x_velocity < 0 and
    (map.get(new_left, old_bottom).startsWith("ground") or
     map.get(new_left, old_top).startsWith("ground")) then

    gekko.facing = 1
    gekko.x_velocity = 0

  // Hitting a wall on the right
  elsif gekko.x_velocity > 0 and
    (map.get(new_right, old_bottom).startsWith("ground") or
     map.get(new_right, old_top).startsWith("ground")) then

    gekko.facing = -1
    gekko.x_velocity = 0
  end

  // Patrol boundaries
  if gekko.x <= gekko.patrol_min then
    gekko.facing = 1
  elsif gekko.x >= gekko.patrol_max then
    gekko.facing = -1
  end

  // Move gekko
  gekko.x += gekko.x_velocity
  gekko.y += gekko.y_velocity

  // Remove gekko if it falls off the map
  if gekko.y < (-level.map_height / 2 - 100) then
    gekko.alive = false
  end

end


drawGekko = function()

  if not gekko.alive then return end

  // Flip sprite depending on direction
  screen.setDrawScale(gekko.facing, 1)

  // Choose animation
  if abs(gekko.x_velocity) > 0 then
    screen.drawSprite("gekko_run",
      gekko.x - camera.x,
      gekko.y - camera.y,
      gekko.size)
  else
    screen.drawSprite("gekko_idle",
      gekko.x - camera.x,
      gekko.y - camera.y,
      gekko.size)
  end

  // Reset sprite scale
  screen.setDrawScale(1, 1)

  //enemy health
  drawEnemyHealth(gekko)
  
end