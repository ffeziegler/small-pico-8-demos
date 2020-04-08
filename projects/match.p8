pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
flame_particles = {}
smoke_particles = {}
particle_types = {flame_particles,
 smoke_particles}

function _init()
 foreach(particle_types,
  add_new_prtcls)
end

function add_new_prtcls(prtcls)
  for i = 0, 8 do
  
   add(prtcls, {
    x = 60+i,
    y = 87 - (rnd(2)-1),
    col = 10,
    age = 0,
    kill_y = 65 + ((i-4) ^ 2)/1.5})
  
 end
end

function _update()
 add_new_prtcls()
 foreach(flame_particles,update_particles)
end

function update_particles(prtcl)
 prtcl.y -= rnd(1)/3
 if (prtcl.y <= prtcl.kill_y) then
  del(flame_particles, prtcl)
 end
 
 if (prtcl.y <= prtcl.kill_y + 5) then
  prtcl.col = 8
 elseif (prtcl.y <= prtcl.kill_y + 10) then
  prtcl.col = 9
 end
end

function _draw()
 cls(0)
 draw_light()
 draw_flames()
 draw_stick()
end

function draw_light()
 circfill(64,75,
  (1800/flame_particles[1].y),5)
 circfill(64,75,
  (1500/flame_particles[1].y)+rnd(1),6)
end

function draw_stick()
 rectfill(62,85,66, 128, 15)
 rectfill(62,81,66, 85, 8)
end

function draw_flames()
 for prtcl in
 all(flame_particles)
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
