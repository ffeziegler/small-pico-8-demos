pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--main

drips={}

function _init()
 cls(0)

 for i = 0, 127 do
  add(drips, {x_pos = 0,
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
 for i = 1, 128 do
  drips[i] = {x_pos = i - 1,
												  y_pos = -2,
												  viscosity = rnd(10)+1,
												  y_max = 0,
												  speed = 0,
												  prev_y = -3}
 end
 
 foreach(drips,calc_y_max)
end

--max amount a drip can drop
function calc_y_max(drip)
 --high viscosity == low y_max
 drip.y_max = 50 / (drip.viscosity/1.5) + 10
end

function _update()
 foreach(drips,slide)
end

--move drip down
function slide(drip)
 if (drip.y_pos < drip.y_max) then
    --retain last y_pos for
    --drawing lines
    drip.prev_y = drip.y_pos
				
				--descent slows the
				--lower the drip
				--+
				--high viscosity means
				--smaller increments
				drip.y_pos += ((drip.y_max - drip.y_pos) / drip.viscosity)/3
	end
end

function _draw()
 foreach(drips,draw_drip)
end

function draw_drip(drip)
 --using a line as may travel
 --multiple pixels per frame
 line(drip.x_pos,
      drip.prev_y,
      drip.x_pos,
      drip.y_pos,
      3)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
