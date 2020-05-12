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
 update_overworld()
 update_worm()
 if (refill.active) update_refill()
end

function _draw()
 draw_world()
 draw_overworld()
 draw_worm()
end

-->8
--wiggler----------------------
--parent to worm and refill

function move_horizontal(object, increment)
 object.x += increment
end

function move_vertical(object, dest, speed)
 object.y += (((dest - object.y) 
  / (129-object.x))
  * speed)
  + sin(flr(object.x)/5)/2
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
  --mark soil at current worm
  --position as deleted
  change_pixel(worm.head, 0)
 
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
 move_horizontal(worm.head, worm.speed)
 
 --activate the refilling of
 --the worm's tunnel after
 --a certain amount of distance
 --has been travelled
 if (worm.head.x >= (75*worm.speed))
 then
  refill.active = true
 end
 
 move_vertical(worm.head, worm.dest_y, worm.speed)
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
--refill-----------------------

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
 
 --fills in a pixel of the
 --worm's path
 change_pixel(refill, 4)
end

--updates position in worm's
--tunnel to refill
function move_refill()
 check_input_history()

 move_horizontal(refill, current_refill_speed.speed)
 move_vertical(refill, current_refill_dest.dest, current_refill_speed.speed)
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

function change_pixel(object, colour)
 --when onscreen
 if (object.x >= 0)
 and (object.x < 128) then
  world.matter[flr(object.x)][flr(object.y+0.5)] = colour
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
--overworld--------------------

function init_overworld()
 init_clouds()
 init_flowers()
end

function init_clouds()
 clouds = {}
 local quantity = ceil(rnd(10)) + 4
 for i = 0, quantity do
  add(clouds, make_cloud())
 end
end

--returns a new cloud "object"
function make_cloud()
 local cloud = {
  width = rnd(10)+10,
  height = rnd(5)+5,
  y = rnd(10)-3,
  x = rnd(250),
  colour = ceil(rnd(2)) + 5}
 return cloud
end

function init_flowers()
 flowers = {}
 for i = 0, 15 do
  add(flowers, {
   location = i,
   variant = ceil(rnd(40))})
 end
end

function update_overworld()
 update_clouds()
end

--handles cloud movement
function update_clouds()
 for k, v in pairs(clouds) do
  if (v.x < 128) then
   --move if onscreen
   v.x += 0.2
  else
   --respawn if offscreen
   del(clouds, v)
   add(clouds, make_cloud())
   clouds[#clouds].x -= 300
  end
 end
end

function draw_overworld()
 clear_sky()
 draw_clouds()
 draw_flowers()
end

--clears sky to prevent clouds
--from smearing
function clear_sky()
 rectfill(0,0,127,29,12)
end

function draw_clouds()
 for k, v in pairs(clouds) do
  rectfill(v.x,v.y,v.x+v.width,v.y+v.height,v.colour)
 end
end

function draw_flowers()
 for k, v in pairs(flowers) do
  spr(v.variant,(v.location)*8,22)
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
__label__
cccccccccccccccccccccccccccccccccccccccccccccc666666666666ccccccccccccccccccccccccccccccccccccc7777777777777777ccccccccccc777777
cccccccccccccccccccccccccccccccccccccccccccccc66666677777777777777ccccccccccccccccccccccccccccc7777777777777777ccccccccccc777777
cccccccccccccccccccccccccccccccccccccccccccccc66666677777777777777ccccccccccccccccccccccccccccc7777777777777777ccccccccccc777777
cccccccccccccccccccccccccccccccccccccccccccccc6666667777777777777777777777ccccccccccccccccccccc7777777777777777ccccccccccc777777
cccccccccccccccccccccccccccccccccccccccccccccc6666667777777777777777777777ccccccccccccccccccccc7777777777777777ccccccccccc777777
cccccccccccccccccccccccccccccccccccccccccccccc6666667777777777777777777777ccccccccccccccccccccc7777777777777777ccccccccccc777777
cccccccccccccccccccccccccccccccccccccccc7777777777777777777777777777777777777777777cccccccccccc777777777777777777777cccccc777777
cccccccccccccccccccccccccccccccccccccccc7777777777777777777777777777777777777777777cccccccccccccccccccc7777777777777cccccc777777
cccccccccccccccccccccccccccccccccccccccc7777777777777777777777777777777777777777777cccccccccccccccccccc7777777777777cccccccccccc
cccccccccccccccccccccccccccccccccccccccc7777777777777777777777777777777777777777777cccccccccccccccccccc7777777777777cccccccccccc
cccccccccccccccccccccccccccccccccccccccc7777777777777777777777777777777777777777777cccccccccccccccccccc7777777777777cccccccccccc
cccccccccccccccccccccccccccccccccccccccc7777777777777777777777777777777777777777777cccccccccccccccccccc7777777777777cccccccccccc
cccccccccccccccccccccccccccccccccccccccc7777777777777777666666666cccc77777777777777cccccccccccccccccccc7777777777777cccccccccccc
cccccccccccccccccccccccccccccccccccccccc7777777777777777666666666cccccccccccccccccccccccccccccccccccccc7777777777777cccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc666666666666666666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc666666666666666666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccce2eccccccccccccce2eccccccccccccccccccccc141ccccccccccccccccccccccccccccc898cccccccccccccccccccccccccccccccccccccccccc
cc141cccccc2a2ccccc898ccccc2a2cccc282cccccccccccccc4a4cccccccccccccccccccce2ecccccc9a9ccccc656ccccc141ccccccccccccccccccccc141cc
cc4a4cccccce2eccccc9a9ccccce2ecccc8a8cccccccccccccc141cccccccccccccccccccc2a2cccccc898ccccc5a5ccccc4a4ccccccccccccccccccccc4a4cc
cc141cccccccc3c3ccc898ccccccc3c3cc282cccccccccccc3c3cccccccccccccccccccccce2ecccc3c3ccccccc656ccccc141ccccccccccccccccccccc141cc
ccc3cccccccccc3ccccc3ccccccccc3cccc3cccccccccccccc3cccccccccc3ccccccccccccc3cccccc3ccccccccc3ccccccc3ccccccccccccccccccccccc3ccc
cc33cccccccccc3ccccc33cccccccc3ccc33cccccccccccccc3cccccccccc3cccc3cc3cccc33cccccc3ccccccccc33cccccc33cccccccccccc3cc3cccccc33cc
ccc3ccccccccc3cccccc3cccccccc3ccccc3ccccccccccccccc3cccccc3cc3ccccc3c3ccccc3ccccccc3cccccccc3ccccccc3cccccccccccccc3c3cccccc3ccc
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444884444444444444444444444444444444444444444444444444
4444444444444444444444444444444444444444444444444444444444444444444444444444e44ee44444444444444444444444444444444444444444444444
444444444444444444444444444444444444444444444444444444444444444444444444eeee4444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444044444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444440000044444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444404404444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444004404444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444440440044444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444400440444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444440444000004444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444004400004044444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444440400404400444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444004440044444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444

