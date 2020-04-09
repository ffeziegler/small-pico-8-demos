pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--main

drips={}
spacing=1

function _init()
 cls(0)

 add(drips, {
  x_pos = 0,
  y_pos = 0,
  viscosity = rnd(10)+1.49,
  y_max = 0,
  speed = 0,
  prev_y = 0})

 for i = 0, 126 do
  add(drips, {
   x_pos = 0,
   y_pos = 0,
   viscosity = 0,
   y_max = 0,
   speed = 0,
   prev_y = 0})
 end
 
 gen_drips()
end

--establishes base values for
--each drip
function gen_drips()
 for i = 2, 128 do
  drips[i] = {x_pos = i - 1,
   y_pos = -2,
   viscosity = 0,
   y_max = 0,
   speed = 0,
   prev_y = -3}

  --make viscosity relative to neighbours
  while drips[i].viscosity <= 1
  or drips[i].viscosity >= 10
  do
   drips[i].viscosity = drips[i-1].viscosity + ((rnd(300)-150)/100)
  end
 end

 foreach(drips,calc_y_max)
end

--max amount a drip can drop
function calc_y_max(drip)
 --high viscosity == low y_max
 drip.y_max = (drip.viscosity+1)*4 + 20
end

function _update()
 foreach(drips,slide)
end

--move drip down
function slide(drip)
 --retain last y_pos for
 --drawing lines
 drip.prev_y = drip.y_pos

 --descent slows the
 --lower the drip
 --+
 --high viscosity means
 --smaller increments	
 drip.y_pos += ((drip.y_max - drip.y_pos) * (drip.viscosity)/10)/20

 if (drip.y_pos > drip.y_max) then
  drip.y_pos = drip.y_max
 end
end

function _draw()
 foreach(drips,draw_drip)

 print("press ctrl+r to reset",
  0,
  123,
  7)
end

function draw_drip(drip)
 line(drip.x_pos,
  -1,
  drip.x_pos,
  drip.y_pos-(20-drip.viscosity),
  3)
 line(drip.x_pos,
  drip.prev_y,
  drip.x_pos,
  drip.y_pos,
  11)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000a00001550013500135001950012500195001250013500135001450014500115001150011500115001150012500125001250012500125001250013500145001650018500195001b5001d5001f5001a50019500
