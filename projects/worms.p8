pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--main

function _init()
 --holds matrix of all soil;
 --a record of top layer;
 --and a counter for collapsing
 soil_class = {
  soil = {},
  top = 1,
  collapse_col = 0}
 
 --populates soil matrix for 
 --full screen
 reset_soil(0, 127)
 
 worm = {
  x = -10,
  y = 50,
  speed = 100}
  
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
  elseif (soil_class.top < 127) then
   --lower topmost layer
   soil_class.top += 1
   
   reset_worm()
   
   state = "soil"
  end
 
 --handles collapsing soil
 elseif (state == "soil") then
  if (soil_class.collapse_col < 128) then 
   --lower a column each draw
   --cycle
   reset_soil(soil_class.collapse_col, soil_class.collapse_col)
   soil_class.collapse_col += 1
  else
   soil_class.collapse_col = 0
   state = "worm"
  end
 end
end

function _draw()
 draw_soil()
 draw_worm()
end
-->8
--worm

function move_worm()
 worm.x += worm.speed/100
end

function eat_soil()
 --mark soil at current worm
 --position as deleted
 if (worm.x >= 0) then
  soil_class.soil[flr(worm.x)][flr(worm.y)] = 0
 end
end

function reset_worm()
 worm.x = -10
 
 --worm offscreen if only one
 --row of dirt remains
 if (soil_class.top <= 126) then
  --ensure in soil
  --and under top layer
  repeat
   worm.y = ceil(rnd(127))
  until worm.y > soil_class.top
 else
  worm.y = -1
 end
 
 worm.speed = ceil(rnd(90))+10
end

function draw_worm()
 pset(worm.x,
  worm.y,
  14)
end
-->8
--soil

--populate each pixel
--with soil or sky
function reset_soil(a, b)
 for x = a, b do
  soil_class.soil[x] = {}
  for y = 0, 127 do
   if (y < soil_class.top) then
    soil_class.soil[x][y] = 12
   else
    soil_class.soil[x][y] = 4
   end
  end
 end
end

function draw_soil()
 --draw dirt pixel by pixel
 --from matrix
 for x in pairs(soil_class.soil) do
  for y in pairs (soil_class.soil) do
   pset(x, y, soil_class.soil[x][y])
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
