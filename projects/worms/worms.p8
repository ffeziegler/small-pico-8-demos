pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--main--------------------------

function _init()
 init_world()
 init_overworld()
 init_worm()
end

function _update()
 get_input()
 update_worm()
 if (refill.active) update_refill()
end

function _draw()
 draw_world()
 draw_overworld()
 draw_worm()
end

-->8
--worm--------------------------

function init_worm()
 worm = {
  --doubly linked list for
  --drawing worm as contiguous
  --pixels
  head = {
   next_part = nil,
   prev_part = nil,
   x = -1,
   y = -1,
   col = 14},
  start_y = 0,
  dest_y = 0,
  speed = 0}
  
 generate_base_values()
end

function generate_base_values()
 --generate non-list vals
 reset_worm()
 
 --set list length and populate
 --with coordinates that are
 --off-screen
 local current_part = worm.head
 for i = 0, 13 do
  current_part.next_part = {
   next_part = nil,
   prev_part = nil,
   x = -1,
   y = -1,
   col = 14}
  
  --sets different colour
  --for clitellum
  if (i>=3) and (i<=5) then
   current_part.next_part.col = 8
  end
  
  current_part.next_part.prev_part = current_part
  current_part = current_part.next_part
 end
 
 --track the end of the list
 tail = current_part
end

function update_worm()
 move_worm()
 
 --respawn a new worm when
 --existing worm off screen
 if (worm.head.x < 128) then
  eat_soil()
 
 --min world height prevents
 --worms from spawning
 elseif (refill.x > 150) then
  reset_worm()
 end
end

function move_worm()
 update_head()
 update_body() 
end

function update_head()
 worm.head.x += worm.speed
 
 --activate the refilling of
 --the worm's tunnel after
 --a certain amount of distance
 --has been travelled
 if (worm.head.x >= (75*worm.speed))
 then
  refill.active = true
 end
 
 --height relative to
 --horizontal distance
 --travelled
 worm.head.y += (((worm.dest_y - worm.head.y) 
  / (129-worm.head.x))
  * worm.speed)
  + sin(flr(worm.head.x)/5)/2
end

function update_body()
 local current = tail
 
 --work backwards through
 --linked list until nil (index
 --before head)
 while current.prev_part do
  --move all x and y values
  --to the next part
  current.x = current.prev_part.x
  current.y = current.prev_part.y
  current = current.prev_part
 end
end

function eat_soil()
 --mark soil at current worm
 --position as deleted
 if (worm.head.x >= 0)
 and (worm.head.x < 128) then
  world.matter[flr(worm.head.x)][flr(worm.head.y+0.5)] = 0
 end
end

--puts the worm off-screen
--to the left, and gives it
--new behaviour
function reset_worm()
 worm.head.x = -1
 
 get_path()
 
 worm.speed = (ceil(rnd(70))+30)/100

 reset_refill()
end

--plans the starting and
--destination heights for the
--new worm
function get_path()
 repeat
  worm.start_y = ceil(rnd(127))
 --ensures worm in soil
 --and under top layer
 until worm.start_y >= world.grass_tip_height + 10
 worm.head.y = worm.start_y
  
 repeat
  worm.dest_y = ceil(rnd(127))
 --ensures path not too steep
 until ((worm.dest_y > worm.start_y-50)
 and (worm.dest_y < worm.start_y+50))
 and (worm.dest_y >= world.grass_tip_height + 10)
end

function draw_worm()
 local current_part = worm.head
 
 --paint a pixel for each part
 --of the worm, until nil (end
 --of list)
 while current_part do  
  pset(current_part.x,
   --fixes new worms appearing
   --to start 1 layer higher
   --than they are programmed to
   flr(current_part.y + 0.5),
   current_part.col)
   
  current_part = current_part.next_part
 end
end

-->8
--world-------------------------

function init_world()
 --holds matrix of all matter;
 --a record of top layer;
 --and a counter for collapsing
 world = {
  matter = {},
  grass_tip_height = 30}

 --populates matter matrix for 
 --full screen
 reset_matter(0, 127)
end

--creates a table to handle
--the refilling of the worm's
--tunnel
function reset_refill()
 refill = {x = worm.head.x,
  y = worm.head.y,
  origin_speed = {
   x = 0,
   speed = worm.speed,
   next_change = nil},
  origin_dest = {
   x = 0,
   dest = worm.dest_y,
   next_change = nil},
  active = false}

 --tracks active and tail items
 --in the linked lists
 current_refill_speed = refill.origin_speed
 last_refill_speed = refill.origin_speed
 current_refill_dest = refill.origin_dest
 last_refill_dest = refill.origin_dest
end

--advance refill path one pixel
function update_refill()
 move_refill()
 
 --when onscreen
 if (refill.x >= 0)
 and (refill.x < 128) then
  refill_matter()
 end
end

--updates position in worm's
--tunnel to refill
function move_refill()
 check_input_history()

 refill.x += current_refill_speed.speed
 refill.y += (((current_refill_dest.dest - refill.y) 
  / (129-refill.x))
  * current_refill_speed.speed)
  + sin(flr(refill.x)/5)/2
end

--checks history of user input
--and adjusts refill path
--at the appropriate location
--accordingly
function check_input_history()
 check_speed_update(refill.x)
 check_dest_update(refill.x)
end

--update refill speed when
--refill matches the location
--where input was received
function check_speed_update()
 if (current_refill_speed.next_change) then
  if (refill.x >= current_refill_speed.next_change.x) then
   current_refill_speed = current_refill_speed.next_change
  end
 end
end

--update refill destination when
--refill matches the location
--where input was received
function check_dest_update()
 if (current_refill_dest.next_change) then
  if (refill.x >= current_refill_dest.next_change.x) then
   current_refill_dest = current_refill_dest.next_change
  end
 end
end

--fills in a pixel of the
--worm's path
function refill_matter()
 world.matter[flr(refill.x)][flr(refill.y+0.5)] = 4
end

--populate each pixel
--of the world
function reset_matter(a, b)
 for x = a, b do
  world.matter[x] = {}
  for y = 0, 127 do
   if (y < world.grass_tip_height) then
    --sky
    world.matter[x][y] = 12
   else
    if (y < world.grass_tip_height+3) then
     --grass
     world.matter[x][y] = 3
    else
     --soil
     world.matter[x][y] = 4
    end
   end
  end
 end
end

--draws the environment
--pixel-by-pixel
function draw_world()
 for x in pairs(world.matter) do
  for y in pairs (world.matter) do
   pset(x, y, world.matter[x][y])
  end
 end
end
-->8
--controls---------------------

--takes a button press to update
--worm path
function get_input()
 --speed
 if (btn(0)) then
  change_speed(-0.01)
  log_speed_change(worm.speed, worm.head.x)
 elseif (btn(1)) then
  change_speed(0.01)
  log_speed_change(worm.speed, worm.head.x)
 end
 
 --destination
 if (btn(2)) then
  change_destination(-1)
  log_dest_change(worm.dest_y, worm.head.x)
 elseif (btn(3)) then
  change_destination(1)
  log_dest_change(worm.dest_y, worm.head.x)
 end
end

--apply speed change,
--if appropriate
function change_speed(change)
 --ensure speed is reasonable
 if (worm.speed+change >= 0.3)
 and (worm.speed+change < 1) then
  worm.speed += change
 end
end

--record position for refill
--to change speed
function log_speed_change(new_speed, location)
 last_refill_speed.next_change = {
  x = location,
  speed = new_speed,
  next_change = nil}
 
 last_refill_speed = last_refill_speed.next_change
end

--apply destination change,
--if appropriate
function change_destination(change)
 local remaining_dist = 128 - worm.head.x
 local dest_diff = (worm.head.y - (sin(flr(worm.head.x)/5)/2))
   - (worm.dest_y+change)
 
 --ensure underground
 if (worm.dest_y+change >= world.grass_tip_height + 10)
 --ensure on screen
 and (worm.dest_y+change <= 127) then
  --ensure trajectory not too
  --steep
  if (dest_diff/remaining_dist >= -0.39)
  and (dest_diff/remaining_dist <= 0.39) then
   worm.dest_y += change
  end
 end
end

--record position for refill
--to change destination
function log_dest_change(new_dest, location)
 last_refill_dest.next_change = {
  x = location,
  dest = new_dest,
  next_change = nil}
 
 last_refill_dest = last_refill_dest.next_change
end
-->8
--overworld--------------------

function init_overworld()
 init_flowers()
end

function init_flowers()
 flowers = {}
 for i = 0, 15 do
  add(flowers, {
   location = i,
   variant = ceil(rnd(40))})
 end
end

function draw_overworld()
 draw_flowers()
end

function draw_flowers()
 for k, v in pairs(flowers) do
  spr(v.variant,(v.location)*8,22)
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000008980000028200000e2e00000141000006560000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000009a9000008a8000002a2000004a4000005a500008980000028200000e2e00000141000006560000000000000000000000000000000000000000000
000770000008980000028200000e2e000001410000065600009a9000008a8000002a2000004a4000005a50000000000000000000000000000000000000000000
000770000000030300000303000003030000030300000303008980000028200000e2e00000141000006560000000000000000000000000000000000000000000
00700700000000300000003000000030000000300000003000030000000300000003000000030000000300000000000000000000000003000300030000000000
00000000000000300000003000000030000000300000003000330000003300000033000000330000003300000030030003000030000003000030003000030003
00000000000003000000030000000300000003000000030000030000000300000003000000030000000300000003030003000300003003000030003000300303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000008980000028200000e2e00000141000006560000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000009a9000008a8000002a2000004a4000005a5000008980000028200000e2e0000014100000656000000000000000000000000000000000000000000
000000000008980000028200000e2e0000014100000656000009a9000008a8000002a2000004a4000005a5000000000000000000000000000000000000000000
0000000003030000030300000303000003030000030300000008980000028200000e2e0000014100000656000000000000000000000000000000000000000000
00300000003000000030000000300000003000000030000000003000000030000000300000003000000030000000000000000000000000000000000000000000
03000000003000000030000000300000003000000030000000003300000033000000330000003300000033000000000000000000000000000000000000000000
03000030000300000003000000030000000300000003000000003000000030000000300000003000000030000000000000000000000000000000000000000000
