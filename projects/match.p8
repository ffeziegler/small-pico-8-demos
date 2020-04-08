pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--main

--holds flames and smoke
particles = {}

function _init()
 --initialise base layer of
 --flame
 add_new_prtcls()
end

function add_new_prtcls()
 for i = 0, 8 do
  
  add(particles, {
   x = 60+i,
   y = 87 - (rnd(2)-1),
   col = 10,
   kill_y = 65 + ((i-4) ^ 2)/1.5})
  
 end
end

function _update()
 --generate new base layer
 add_new_prtcls()
 
 --update all particles
 foreach(particles,update_height)
 foreach(particles,check_life)
 foreach(particles,update_colour)
end

--increase particle height
function update_height(prtcl)
 prtcl.y -= rnd(1)/3
end

--delete particle at height cap
function check_life(prtcl) 
 if (prtcl.y <= prtcl.kill_y) then
  
  --occasionally generate
  --smoke particles
  if (ceil(rnd(30)) == 30) then
   add(particles, {
    x = prtcl.x,
    y = prtcl.y,
    col = 13,
    kill_y = 35+rnd(15)})
  end
  
  del(particles, prtcl)
  
 end
end

--update particle colour
--if not smoke
function update_colour(prtcl)
 --red at flame tip
 if (prtcl.y <= prtcl.kill_y + 5)
 and (prtcl.col != 13) then
  prtcl.col = 8
  
 --orange at flame mid
 elseif (prtcl.y <= prtcl.kill_y + 10)
 and (prtcl.col != 13) then
  prtcl.col = 9
 end
end

function _draw()
 cls(0) --wipe frame to black
 draw_light()
 draw_particles()
 draw_stick()
end

function draw_light()
 --darker light
 circfill(64,75,
  --grow with the flame
  (1800/particles[1].y/1.4),
  5)
  
 --lighter light
 circfill(64,75,
  --grow with the flame
  --+ flicker
  (1500/particles[1].y/1.4)+rnd(1),
  6)
end

function draw_stick()
 --body
 rectfill(62,85,66, 128, 15)
 
 --red tip
 rectfill(62,81,66, 85, 8)
end

function draw_particles()
 for prtcl in
 all(particles)
 do
  pset(prtcl.x,
  prtcl.y,
  prtcl.col)
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
