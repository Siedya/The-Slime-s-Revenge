initOgre = function()
  ogre = object
    x = -350
    y = 200
  
    //fix the coords till the ogre is visible again
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
    health = 4
    max_health = 4
    
    // Patrol boundaries
    patrol_min = -450
    patrol_max = -250
    
  end

  ogres = [ogre]
end


updateOgre = function()

  if not ogre.alive then return end

  // Automatic horizontal movement
  //ogre.x_velocity = ogre.facing * ogre.speed
  // Check distance to player
local distance_x = abs(player.x - ogre.x)
local distance_y = abs(player.y - ogre.y)

// Detect player
if distance_x < ogre.chase_range and distance_y < 50 then
  if not ogre.chase_blocked then
    ogre.chasing = true
  end
else
  ogre.chasing = false
  ogre.chase_blocked = false
end

// Choose movement
if ogre.chasing then

  // Face the player
  if player.x < ogre.x then
    ogre.facing = -1
  else
    ogre.facing = 1
  end

  ogre.x_velocity = ogre.facing * ogre.chase_speed

else

  // Normal patrol
  ogre.x_velocity = ogre.facing * ogre.speed

end

  // Gravity only while airborne
if not ogre.landed then
  ogre.y_velocity -= 0.2
end

if ogre.y_velocity < -ogre.max_fall_speed then
  ogre.y_velocity = -ogre.max_fall_speed
end

local map = level.map
local hw = level.map_width / 2
local hh = level.map_height / 2

// Calculate collision positions
// Collision box for 30x30 ogre
local old_top = floor((ogre.y + 12 + hh) / 16)
local old_bottom = floor((ogre.y - 12 + hh) / 16)
local old_right = floor((ogre.x + 12 + hw) / 16)
local old_left = floor((ogre.x - 12 + hw) / 16)

local new_top = floor((ogre.y + ogre.y_velocity + 12 + hh) / 16)
local new_bottom = floor((ogre.y + ogre.y_velocity - 12 + hh) / 16)
local new_right = floor((ogre.x + ogre.x_velocity + 12 + hw) / 16)
local new_left = floor((ogre.x + ogre.x_velocity - 12 + hw) / 16)

 // Falling and landing
if ogre.y_velocity < 0 and
  (map.get(old_left, new_bottom).startsWith("ground") or
   map.get(old_right, new_bottom).startsWith("ground")) then

  ogre.y = -hh + (new_bottom + 1) * 16 + 12
  ogre.y_velocity = 0
  ogre.landed = true

// Hitting a ceiling
elsif ogre.y_velocity > 0 and
  (map.get(old_left, new_top).startsWith("ground") or
   map.get(old_right, new_top).startsWith("ground")) then

  ogre.y_velocity = 0

else
  ogre.landed = false
end

  // Hitting a wall on the left
  if ogre.x_velocity < 0 and
    (map.get(new_left, old_bottom).startsWith("ground") or
     map.get(new_left, old_top).startsWith("ground")) then

    ogre.facing = 1
    ogre.x_velocity = 0

  // Hitting a wall on the right
  elsif ogre.x_velocity > 0 and
    (map.get(new_right, old_bottom).startsWith("ground") or
     map.get(new_right, old_top).startsWith("ground")) then

    ogre.facing = -1
    ogre.x_velocity = 0
  end

  // Patrol boundaries
  if ogre.x <= ogre.patrol_min then
    ogre.facing = 1
  elsif ogre.x >= ogre.patrol_max then
    ogre.facing = -1
  end

  // Move ogre
  ogre.x += ogre.x_velocity
  ogre.y += ogre.y_velocity

  // Remove ogre if it falls off the map
  if ogre.y < (-level.map_height / 2 - 100) then
    ogre.alive = false
  end

end


drawOgre = function()

  if not ogre.alive then return end

  // Flip sprite depending on direction
  screen.setDrawScale(ogre.facing, 1)

  // Choose animation
  if abs(ogre.x_velocity) > 0 then
    screen.drawSprite("ogre_run",
      ogre.x - camera.x,
      ogre.y - camera.y,
      ogre.size)
  else
    screen.drawSprite("ogre_idle",
      ogre.x - camera.x,
      ogre.y - camera.y,
      ogre.size)
  end

  // Reset sprite scale
  screen.setDrawScale(1, 1)

  //enemy health
  drawEnemyHealth(ogre)
end