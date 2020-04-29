pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--main

function _init()
 --holds matrix of all matter;
 --a record of top layer;
 --and a counter for collapsing
 matter_class = {
  matter = {},
  grass_tips = 30,
  collapse_col = 0}
 --populates matter matrix for 
 --full screen
 reset_matter(0, 127)
 
 worm = {
 	--doubly linked list for
 	--drawing worm as contiguous
 	--pixels
  head = {
   next_part = nil,
   prev_part = nil,
   x = -1,
   y = -1},
  start_y = 0,
  dest_y = 0,
  speed = 0}
  
 --generate expected values
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
   y = -1}
  current_part.next_part.prev_part = current_part
  current_part = current_part.next_part
 end
 --track the end of the list
 tail = current_part

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
  elseif (matter_class.grass_tips < 118) then
   --lower topmost layer
   matter_class.grass_tips += 1
   
   reset_worm()
   
   state = "soil"
  end
 
 --handles collapsing soil
 elseif (state == "soil") then
  if (matter_class.collapse_col < 128) then 
   --lower a column each draw
   --cycle
   reset_matter(matter_class.collapse_col, matter_class.collapse_col)
   matter_class.collapse_col += 1
  else
   matter_class.collapse_col = 0
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
  matter_class.matter[flr(worm.head.x)][flr(worm.head.y+0.5)] = 0
 end
end

function reset_worm()
 worm.head.x = -1
 
 --only spawns worm if space
 --in soil for it
 if (matter_class.grass_tips <= 117) then  
  repeat
   worm.start_y = ceil(rnd(127))
   --ensures worm in soil
   --and under top layer
  until worm.start_y >= matter_class.grass_tips + 10
  worm.head.y = worm.start_y
  
  repeat
   worm.dest_y = ceil(rnd(127))
   --ensures path not too steep
  until ((worm.dest_y > worm.start_y-50)
  and (worm.dest_y < worm.start_y+50))
  and (worm.dest_y >= matter_class.grass_tips + 10)
  
 else
  --worm offscreen if only grass
  --and one row of dirt remains
  worm.head.y = -100
 end
 
 worm.speed = (ceil(rnd(70))+30)/100
end

function draw_worm()
 local current_part = worm.head
 
 --used for aesthetics
 local counter = 0
 local colour = 0
 
 --paint a pixel for each part
 --of the worm, until nil (end
 --of linked list)
 while current_part do
  --different colour for 
  --clitellum
  if (counter < 4)
  or (counter > 6) then
   colour = 14
  else
   colour = 8
  end
  
  pset(current_part.x,
   --fixes new worms appearing
   --to start 1 layer higher
   --than they are programmed to
   flr(current_part.y + 0.5),
   colour)
   
  --move to next section
  current_part = current_part.next_part
  counter += 1
 end
end
-->8
--matter

--populate each pixel
--with soil or sky
function reset_matter(a, b)
 for x = a, b do
  matter_class.matter[x] = {}
  for y = 0, 127 do
   if (y < matter_class.grass_tips) then
    --sky
    matter_class.matter[x][y] = 12
   else
    if (y < matter_class.grass_tips+3) then
     --grass
     matter_class.matter[x][y] = 3
    else
     --soil
     matter_class.matter[x][y] = 4
    end
   end
  end
 end
end

function draw_matter()
 --draw matter pixel by pixel
 --from matrix
 for x in pairs(matter_class.matter) do
  for y in pairs (matter_class.matter) do
   pset(x, y, matter_class.matter[x][y])
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
