pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--main

function _init()
 init_matter()
 init_worm()

 --start the scene by moving
 --the worm rather than
 --collapsing the soil
 state = "worm"
end

function _update()
 --handles worm position
 if (state == "worm") then
  move_worm()
 
  --respawn a new worm when
  --existing worm off screen
  if (worm.head.x < 200) then
   eat_soil()
  
  --controls matter cap of
  --when worms stop spawning
  elseif (world.grass_tips < 118) then
   --lower topmost layer
   world.grass_tips += 1
   
   reset_worm()
   
   state = "soil"
  end
 
 --handles collapsing soil
 elseif (state == "soil") then
  if (world.collapse_col < 128) then 
   --lower a column each draw
   --cycle
   reset_matter(world.collapse_col, world.collapse_col)
   world.collapse_col += 1
  else
   world.collapse_col = 0
   state = "worm"
  end
 end
end

function _draw()
 draw_matter()
 draw_worm()
end
-->8
--worm

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

function move_worm()
 update_head()
 update_body() 
end

function update_head()
 worm.head.x += worm.speed
 
 --height relative to
 --horizontal distance
 --travelled
 worm.head.y += (((worm.dest_y - worm.start_y) 
  / 127)
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

function reset_worm()
 worm.head.x = -1
 
 --only spawns worm if space
 --in soil for it
 if (world.grass_tips <= 117) then  
  get_path()
 else
  --worm offscreen if only grass
  --and one row of dirt remains
  worm.head.y = -100
 end
 
 worm.speed = (ceil(rnd(70))+30)/100
end

function get_path()
 repeat
  worm.start_y = ceil(rnd(127))
 --ensures worm in soil
 --and under top layer
 until worm.start_y >= world.grass_tips + 10
 worm.head.y = worm.start_y
  
 repeat
  worm.dest_y = ceil(rnd(127))
 --ensures path not too steep
 until ((worm.dest_y > worm.start_y-50)
 and (worm.dest_y < worm.start_y+50))
 and (worm.dest_y >= world.grass_tips + 10)
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
--matter

function init_matter()
 --holds matrix of all matter;
 --a record of top layer;
 --and a counter for collapsing
 world = {
  matter = {},
  grass_tips = 30,
  collapse_col = 0}
 --populates matter matrix for 
 --full screen
 reset_matter(0, 127)
end

--populate each pixel
--with soil or sky
function reset_matter(a, b)
 for x = a, b do
  world.matter[x] = {}
  for y = 0, 127 do
   if (y < world.grass_tips) then
    --sky
    world.matter[x][y] = 12
   else
    if (y < world.grass_tips+3) then
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

function draw_matter()
 --draw matter pixel by pixel
 --from matrix
 for x in pairs(world.matter) do
  for y in pairs (world.matter) do
   pset(x, y, world.matter[x][y])
  end
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
