initCrab = function()
  crab = object
    x = -25
    y = 4
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

  crabs = [crab]
end


updateCrab = function()

  if not crab.alive then return end

  // Automatic horizontal movement
  //crab.x_velocity = crab.facing * crab.speed
  // Check distance to player
local distance_x = abs(player.x - crab.x)
local distance_y = abs(player.y - crab.y)

// Detect player
if distance_x < crab.chase_range and distance_y < 50 then
  if not crab.chase_blocked then
    crab.chasing = true
  end
else
  crab.chasing = false
  crab.chase_blocked = false
end

// Choose movement
if crab.chasing then

  // Face the player
  if player.x < crab.x then
    crab.facing = -1
  else
    crab.facing = 1
  end

  crab.x_velocity = crab.facing * crab.chase_speed

else

  // Normal patrol
  crab.x_velocity = crab.facing * crab.speed

end

  // Gravity
  crab.y_velocity -= 0.2

  if crab.y_velocity < -crab.max_fall_speed then
    crab.y_velocity = -crab.max_fall_speed
  end

  local map = level.map
  local hw = level.map_width / 2
  local hh = level.map_height / 2

  // Calculate collision positions
  local old_top = floor((crab.y + 4 + hh) / 16)
  local old_bottom = floor((crab.y - 6 + hh) / 16)
  local old_right = floor((crab.x + 4 + hw) / 16)
  local old_left = floor((crab.x - 4 + hw) / 16)

  local new_top = floor((crab.y + crab.y_velocity + 4 + hh) / 16)
  local new_bottom = floor((crab.y + crab.y_velocity - 6 + hh) / 16)
  local new_right = floor((crab.x + crab.x_velocity + 4 + hw) / 16)
  local new_left = floor((crab.x + crab.x_velocity - 4 + hw) / 16)

  // Falling and landing
  if crab.y_velocity < 0 and
    (map.get(old_left, new_bottom).startsWith("ground") or
     map.get(old_right, new_bottom).startsWith("ground")) then

    crab.y = -hh + (new_bottom + 1) * 16 + 6
    crab.y_velocity = 0
    crab.landed = true

  // Hitting a ceiling
  elsif crab.y_velocity > 0 and
    (map.get(old_left, new_top).startsWith("ground") or
     map.get(old_right, new_top).startsWith("ground")) then

    crab.y_velocity = 0

  else
    crab.landed = false
  end

  // Hitting a wall on the left
  if crab.x_velocity < 0 and
    (map.get(new_left, old_bottom).startsWith("ground") or
     map.get(new_left, old_top).startsWith("ground")) then

    crab.facing = 1
    crab.x_velocity = 0

  // Hitting a wall on the right
  elsif crab.x_velocity > 0 and
    (map.get(new_right, old_bottom).startsWith("ground") or
     map.get(new_right, old_top).startsWith("ground")) then

    crab.facing = -1
    crab.x_velocity = 0
  end

  // Patrol boundaries
  if crab.x <= crab.patrol_min then
    crab.facing = 1
  elsif crab.x >= crab.patrol_max then
    crab.facing = -1
  end

  // Move crab
  crab.x += crab.x_velocity
  crab.y += crab.y_velocity

  // Remove crab if it falls off the map
  if crab.y < (-level.map_height / 2 - 100) then
    crab.alive = false
  end

end


drawCrab = function()

  if not crab.alive then return end

  // Flip sprite depending on direction
  screen.setDrawScale(crab.facing, 1)

  // Choose animation
  if abs(crab.x_velocity) > 0 then
    screen.drawSprite("crab_run",
      crab.x - camera.x,
      crab.y - camera.y,
      crab.size)
  else
    screen.drawSprite("crab_idle",
      crab.x - camera.x,
      crab.y - camera.y,
      crab.size)
  end

  // Reset sprite scale
  screen.setDrawScale(1, 1)

  // enemy health
  drawEnemyHealth(crab)

end