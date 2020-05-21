pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--main

drip_col=16
bg_col=0
drips={}
start = time()

function _init()
 cls(bg_col)

 --populate drips
 for x = 0, 127 do
  add(drips, {
   x_pos = 0,
   y_pos = 0,
   col = 0,
   spd = 0})
 end
	
 gen_drips()
end

--initialise/reset drip values
function gen_drips(new_col)
 for x = 1, 128 do
  drips[x] = {
   x_pos = x-1,
   y_pos = -2,
   --uses a specific
   --colour, if given
   col = new_col or flr(rnd(14)) + 1,
   spd = rnd(1)+0.3}
 end
end

function _update()
 update_bg_col()
 update_drip_col()
 foreach(drips,travel)
 if (drip_col > 15) then
  foreach(drips,update_col)
 end
end

--move drip
function travel(drip)
 drip.y_pos += drip.spd/2
end

--changes drip colour in special
--colour modes
function update_col(drip)
 if (flr(rnd(50))+1 == 1) then
  drip.col = flr(rnd(14)) + 1
 end
end

function _draw()
 foreach(drips,draw_drip)
 
 --displays controls a few
 --seconds after all drips
 --have reached the bottom
 if (time() - start) > 30 then
  print("press ⬆️⬇️ to change drips",
   5,
   110,
   bg_col)
  print("press ⬅️➡️ to change bg",
   5,
   118,
   bg_col)
 end
end

--paints a pixel at the current
--location of the drip
function draw_drip(drip)
 pset(drip.x_pos,
 drip.y_pos,
 drip.col)
end
-->8
--button presses

--changes drip colour on
--vertical key press
function update_drip_col()
 --up pressed
 if (btnp(2)) then
  --below max cap
  if (drip_col < 16) then
   drip_col += 1
   start = time()
  	
   --if in rainbow mode,
   --randomise first colour
   if (drip_col > 15) then
    for v in all(drips) do
     v.col = flr(rnd(14)) + 1
    end
   else
    for v in all(drips) do
     v.col = drip_col
    end
   end
  end
  reset_screen()

 --down pressed
 elseif (btnp(3)) then
  --above min cap
  if (drip_col > 0) then
   drip_col -= 1
   start = time()
   for v in all(drips) do
    v.col = drip_col
   end
  end
  reset_screen()
 end
end

--reacts to horizontal key
--input to update background
--colour
function update_bg_col()
 --left pressed
 if (btnp(0)) then
  if (bg_col > 0) then
   change_col(-1)
  end

 --right pressed
 elseif (btnp(1)) then
  if (bg_col < 15) then
   change_col(1)
  end
 end
end

--applies change to background
--colour
function change_col(col)
 original = bg_col
 bg_col += col
 update_bg(original, bg_col)
 foreach(drips,restore_drips)
end

--preserves drips by painting
--remaining background
function update_bg(old, new)
 for x = 0, 127 do
  for y = 0, 127 do
   --ignore instances of old
   --background colour above
   --drip
   if (pget(x, y) == old)
   and (drips[x + 1].y_pos < y)
   then
    pset(x, y, new)
   end
  end
 end
end

--ensures drips retain their
--colour when bg changes
function restore_drips(drip)
 if (drip_col < 16) then
  for y = 0, drip.y_pos+3 do
   pset(drip.x_pos, y, drip_col)
  end
 end
end

--reset drips and clear trails
function reset_screen()
  if (drip_col > 15) then
   gen_drips()
  else
   gen_drips(drip_col)
  end
  cls(bg_col)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
