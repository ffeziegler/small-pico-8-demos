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
  topsoil = 1,
  collapse_col = 0}
 --populates matter matrix for 
 --full screen
 reset_matter(0, 127)
 
 worm = {
  x = 0,
  y = 0,
  start_y = 0,
  dest_y = 0,
  speed = 0}
 --generate expected values
 reset_worm()
 
 state = "worm"
end

function _update()
 --handles worm position
 if (state == "worm") then
  move_worm()
 
  --respawn a new worm when
  --existing worm off screen
  if (worm.x < 128) then
   eat_soil()
  elseif (matter_class.topsoil < 127) then
   --lower topmost layer
   matter_class.topsoil += 1
   
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
 worm.x += worm.speed
 worm.y += ((worm.dest_y - worm.start_y) 
  / 127)
  * worm.speed
end

function eat_soil()
 --mark soil at current worm
 --position as deleted
 if (worm.x >= 0) then
  matter_class.matter[flr(worm.x)][flr(worm.y)] = 0
 end
end

function reset_worm()
 worm.x = -10
 
 --worm offscreen if only one
 --row of dirt remains
 if (matter_class.topsoil <= 126) then  
  repeat
   worm.start_y = ceil(rnd(127))
   --ensure in soil
   --and under top layer
  until worm.start_y > matter_class.topsoil
  worm.y = worm.start_y
  
  repeat
   worm.dest_y = ceil(rnd(127))
   --ensure not too steep
  until ((worm.dest_y > worm.start_y-50)
  and (worm.dest_y < worm.start_y+50))
  and (worm.dest_y > matter_class.topsoil)
  
 else
  worm.y = -1
 end
 
 worm.speed = (ceil(rnd(70))+30)/100
end

function draw_worm()
 pset(worm.x,
  worm.y,
  14)
end
-->8
--matter

--populate each pixel
--with soil or sky
function reset_matter(a, b)
 for x = a, b do
  matter_class.matter[x] = {}
  for y = 0, 127 do
   if (y < matter_class.topsoil) then
    --sky
    matter_class.matter[x][y] = 12
   else
    --soil
    matter_class.matter[x][y] = 4
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
