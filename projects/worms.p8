pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--main--------------------------

function _init()
 init_world()
 init_worm()
 
 state = "worm"
end

function _update()
 if (state == "worm") then
  update_worm()
 elseif (state == "collapse ground") then
  update_matter()
 end
end

function _draw()
 draw_world()
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
 if (worm.head.x < 200) then
  eat_soil()
 
 --min world height prevents
 --worms from spawning
 elseif (world.grass_tip_height < 118) then
  world.grass_tip_height += 1
   
  reset_worm()
   
  state = "collapse ground"
 end
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
 
 --Moves worm offscreen when
 --ground limited
 if (world.grass_tip_height <= 117) then  
  get_path()
 else
  worm.head.y = -100
 end
 
 worm.speed = (ceil(rnd(70))+30)/100
end

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
  grass_tip_height = 30,
  col_tracker = 0}

 --populates matter matrix for 
 --full screen
 reset_matter(0, 127)
end

function update_matter()
 if (world.col_tracker < 128) then 
  --lower a column each draw
  --cycle
  reset_matter(world.col_tracker, world.col_tracker)
  world.col_tracker += 1
 else
  world.col_tracker = 0
  state = "worm"
 end
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

function draw_world()
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
