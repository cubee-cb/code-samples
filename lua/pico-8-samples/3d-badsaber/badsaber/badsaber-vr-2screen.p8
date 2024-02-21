pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
-- bad saber - pico-8 edition
-- by cubee 🐱, not dani

-- got an oculus milk?

poke(0x5f36,1+8)
--poke(0x5f2e,1)
--reload(0x3100,0x3100,4658,"beatem-music.p8")

--- settings

-- reduce model details to
-- improve performance
perfmode=true

-- particles from slicing blocks
-- 0 disable, 1 low, 2 full
-- /!\ perfmode when on 2
particlemode=2

-- enable pcm samples of the
-- beat saber sound effects
-- /!\ perfmode + 30fps when on
--enpcm=true

--- gameplay options

-- automatically use the correct
-- saber
autocolour=false

--[[🐱 credits

simple fps controller by mboffin
https://www.lexaloffle.com/bbs/?pid=88033
- base 3d engine, used for camera

p01's trifill function
...
- for triangles, obviously



for whatever reason z=0 makes
bad performance

]]

--reload(0x3100,0x3100,4658,"beatem-music.p8")

function _init()
 if(enpcm or particlemode==2)perfmode=true

	--activate mouselook which will
	--lock the mouse to the center
	--of the screen.
	-- also enable buttons
	poke(0x5f2d, 0x7)

	cam_init()
	scene_init()

 offsets=split"2048,3418,4790,6161,7529,8892,10262,10919,11576"
 location=0x800

 for o=1,#offsets-1 do
  local pos=offsets[o]
  local len=offsets[o+1]-offsets[o]
  local str=""
  for i=1,len do
   str..=chr(@(pos+i-1))
  end
  
  defy_load(str)
 end

end

function _update60()

 dt=_update60 and 0.5 or 1

	cam_update()
	scene_update()

	defy_play()
end
if(enpcm)_update=_update60 _update60=nil

function _draw()
	cls()
	scene_draw()

	pal(split"133,5,7,129,1,140,12,130,2,136,8,137,9,139,11",1)

 return true
end

-->8
--camera

function cam_init()
	cam={}
	
	--position
	cam.x=0
	cam.y=1
	cam.z=-1
	
	--rotation (left/right)
	cam.rot=0
	cam.rotspd=4000
	
	--pitch (up/down)
	cam.pitch=0
	cam.pitchspd=4000
	cam.pitch_max=0.21
	cam.pitch_min=-0.24
	
	-- roll
	cam.roll=0
	
	--movement
	cam.dx=0
	cam.dz=0
	cam.dy=0
	cam.g=0.025 --gravity
	cam.jmp=0.8
	cam.accel=0.05
	cam.drg=0.8 --friction
	cam.max_spd=0.45
end

function cam_update()
	--gradually slow down
	cam.dx*=cam.drg
	cam.dz*=cam.drg
	
	--add gravity (for jumping)
	cam.dy-=cam.g
	
	--movement prep - we use cos()
	--and sin() to move in the
	--right direction based on the
	--camera's angle (cam.rot). we
	--also add +0.25 to the angle
	--because technically angle 0
	--is pointing to the player's
	--right, so we adjust to think
	--with a rotation of 0 being
	--pointing in front, looking
	--down the z-axis.
	if (btn(⬆️,1)) cam.dx+=cos(cam.rot+0.25)*cam.accel
	if (btn(⬆️,1)) cam.dz-=sin(cam.rot+0.25)*cam.accel

	if (btn(⬇️,1)) cam.dx-=cos(cam.rot+0.25)*cam.accel
	if (btn(⬇️,1)) cam.dz+=sin(cam.rot+0.25)*cam.accel

	if (btn(⬅️,1)) cam.dx+=cos(cam.rot+0.5)*cam.accel
	if (btn(⬅️,1)) cam.dz-=sin(cam.rot+0.5)*cam.accel

	if (btn(➡️,1)) cam.dx-=cos(cam.rot+0.5)*cam.accel
	if (btn(➡️,1)) cam.dz+=sin(cam.rot+0.5)*cam.accel
	
	--don't let them move too fast!
	cam.dx=mid(-cam.max_spd,cam.dx,cam.max_spd)
	cam.dy=mid(-cam.max_spd,cam.dy,cam.max_spd)

	--mouselook
	if (stat(38)!=0) then
		--divide by ☉rotspd because
		--mouse movement gives very
		--big numbers, but camera
		--rotation is between 0..1
		cam.rot-=stat(38)/cam.rotspd
	end
	if (stat(39)!=0) then
		--same as rotation, but divide
		--by ☉pitchspd
		cam.pitch=cam.pitch-stat(39)/cam.pitchspd
	end

	if(cam.rot>1)cam.rot-=1
	if(cam.rot<-1)cam.rot+=1
	if(cam.pitch>1)cam.pitch-=1
	if(cam.pitch<-1)cam.pitch+=1
	
	--jump
	--if (stat(31)==" ") cam.dy=cam.jmp
	
	--actually move
	cam.x+=cam.dx
	cam.z+=cam.dz
	cam.y=max(1,cam.y+cam.dy)
	
	
	-- ignore all the above, we got
	-- vr now

end
-->8
--3d

clipplane=0

--world space to camera space
function w➡️c(p,o)

 -- offset
 o=o or {x=0,y=0,z=0}

 cx1,cx2,cx3,
 cy1,cy2,cy3,
 cz1,cz2,cz3=
 p.x1,p.x2,p.x3,
 p.y1,p.y2,p.y3,
 p.z1,p.z2,p.z3

 -- rotate
	cy1,cx1=rot(cy1,cx1,p.roll)
	cx1,cz1=rot(cx1,cz1,p.rot)
	cz1,cy1=rot(cz1,cy1,p.pitch)

 -- offsets
	p.cx1=cx1-cam.x+o.x
	p.cy1=cy1-cam.y+o.y
	p.cz1=cz1-cam.z+o.z

 -- rotate by camera
 p.cy1,p.cx1=rot(p.cy1,p.cx1,cam.roll)
	p.cx1,p.cz1=rot(p.cx1,p.cz1,cam.rot)
	p.cz1,p.cy1=rot(p.cz1,p.cy1,cam.pitch)

 if cx2 then
  -- rotate
 	cy2,cx2=rot(cy2,cx2,p.roll)
 	cx2,cz2=rot(cx2,cz2,p.rot)
 	cz2,cy2=rot(cz2,cy2,p.pitch)

  -- offsets
 	p.cx2=cx2-cam.x+o.x
 	p.cy2=cy2-cam.y+o.y
 	p.cz2=cz2-cam.z+o.z

  -- rotate by camera
 	p.cy2,p.cx2=rot(p.cy2,p.cx2,cam.roll)
 	p.cx2,p.cz2=rot(p.cx2,p.cz2,cam.rot)
 	p.cz2,p.cy2=rot(p.cz2,p.cy2,cam.pitch)
 end

 if cx3 then
  -- rotate
		cy3,cx3=rot(cy3,cx3,p.roll)
		cx3,cz3=rot(cx3,cz3,p.rot)
		cz3,cy3=rot(cz3,cy3,p.pitch)

  -- offsets
		p.cx3=cx3-cam.x+o.x
		p.cy3=cy3-cam.y+o.y
		p.cz3=cz3-cam.z+o.z

  -- rotate by camera
		p.cy3,p.cx3=rot(p.cy3,p.cx3,cam.roll)
		p.cx3,p.cz3=rot(p.cx3,p.cz3,cam.rot)
		p.cz3,p.cy3=rot(p.cz3,p.cy3,cam.pitch)
	end

	--disable any dots behind the
	--camera's view
	p.on=p.cz1>=clipplane
	if(p.cz2)p.on=p.cz1>=clipplane and p.cz2>=clipplane
	if(p.cz3)p.on=p.cz1>=clipplane and p.cz2>=clipplane and p.cz3>=clipplane
	
end

--camera space to screen space
function c➡️s(p)

 --projection from 3d world
 --coords to 2d screen coords
 p.sx1=64+p.cx1*128/p.cz1
 p.sy1=64-p.cy1*128/p.cz1
 if p.x2 then
 	p.sx2=64+p.cx2*128/p.cz2
 	p.sy2=64-p.cy2*128/p.cz2
 end
 if p.x3 then
 	p.sx3=64+p.cx3*128/p.cz3
 	p.sy3=64-p.cy3*128/p.cz3
 end

end

--rotation around x/y
function rot(x,y,a)
	if a==0 then
	 return x,y
	else
	 rx=cos(a)*x-sin(a)*y
	 ry=cos(a)*y+sin(a)*x
 	return rx,ry
	end
end

--z-sort the points so that
--points farther away from the
--camera are drawn first
function sort(t)
--🐱 we don't need sorting

-- definitely
-- it'll be fine

--[[
	for pass=1,3 do
		for i=1,#t-1 do
			if (t[i].cz<t[i+1].cz) then
				--swap
				t[i],t[i+1]=t[i+1],t[i]
			end
		end
		for i=#t-1,1,-1 do
			if (t[i].cz<t[i+1].cz) then
				t[i],t[i+1]=t[i+1],t[i]
			end
		end
	end
--]]
end
-->8
--scene


function start_song()
	t=0
	rumble=0

	-- camera
	cx=-64
	cy=-64
	cs=0
	
	-- ring rotation
	ra=0
	rav=0
	raa=0

	-- ring scale
	rs=1
	rst=1
	rr=32

	-- segments
	s={}

	-- add lasers
	for i=1,perfmode and 8 or 12 do
	 add(s,{sc=8,rm=1,lc=12,la=0,lav=0,laa=0,lat=0,lfr=0,lam=0})
	end
	-- rm: ring modifier


 box={}
 combo=0
 music(0)
end

function scene_init()
 menuitem(1,"toggle cardboard",function() cbvr=not cbvr cam.z=cbvr and -0.2 or -1 cam.x=0 end)

 pi_init()

	box_scale=0.25

	--points!
	ps={}
	box={}
	saber={}
	part={}

 for i=0,1 do
  saber_add(0.5-i,0.5,2,0.05,6+i*4)
 end

	--tri_add(-16,0,-16,16,0,-16,-16,4,-16,8)
	
	--[[floor grid
	for x=-16,16,2 do for z=-16,16,2 do
		point_add(x,0,z,3)
	end end]]

 local f=-1

	-- platform plane
 if not perfmode then
		local fs=2
		local fw=3
		local w,d=2,2
		for i=1,w do
		 i-=w/2
		 for iz=1,d do
		  iz-=d/2
	  	tri_add(-fw/w*i,f,fs/d*iz,-fw/w*i,f,-fs/d*iz,fw/w*i,f,fs/d*iz,4)
	  	tri_add(fw/w*i,f,-fs/d*iz,-fw/w*i,f,-fs/d*iz,fw/w*i,f,fs/d*iz,4)
	  end
		end
	end
	--tri_add(-fw,f,fs,-fw,f,-fs,fw,f,fs,4)
	--tri_add(fw,f,-fs,-fw,f,-fs,fw,f,fs,4)

 -- runway plane
 local w=1.5
 local l=32
	tri_add(-w,f,l,w,f,l,-w,f,4,5)
	tri_add(w,f,4,w,f,l,-w,f,4,5)

 -- runway front
 if perfmode then
  tri_add(-w,f,4,w,f,4,0,f-0.5,4,4)
 else
  tri_add(-w,f,4,w,f,4,w,f-0.5,4,4)
  tri_add(-w,f,4,-w,f-0.5,4,w,f-0.5,4,4)
 end

 -- runway legs
 if perfmode then
 	--tri_add(-w,f,4,w-1.45,f,4,-w+0.2,f-10,4,4)
 	--tri_add(w,f,4,-w+1.45,f,4,w-0.5,f-10,4,4)
 else
 	tri_add(-w,f-0.5,4,-w+0.5,f-0.5,4,-w,f-10,4,4)
 	tri_add(w,f-0.5,4,w-0.5,f-0.5,4,w,f-10,4,4)
 end

	
	start_song()

end

function point_add(x,y,z,c)
	add(ps,{
	x=x, --world space x/y/z
	y=y,
	z=z,
	c=c, --color
	cx=0, --camera space x/y/z
	cy=0,
	cz=0,
	sx=0, --screen space x/y
	sy=0
	})
end

function tri_make(x1,y1,z1,x2,y2,z2,x3,y3,z3,c,force)
 return {
 fc=force,
	x1=x1, --world space x/y/z
	y1=y1,
	z1=z1,
	x2=x2, --world space x/y/z
	y2=y2,
	z2=z2,
	x3=x3, --world space x/y/z
	y3=y3,
	z3=z3,
	c=c, --color
	cx1=0, --camera space x/y/z
	cy1=0,
	cz1=0,
	cx2=0, --camera space x/y/z
	cy2=0,
	cz2=0,
	cx3=0, --camera space x/y/z
	cy3=0,
	cz3=0,
	sx1=0, --screen space x/y
	sy1=0,
	sx2=0, --screen space x/y
	sy2=0,
	sx3=0, --screen space x/y
	sy3=0
	}
end

function tri_add(x1,y1,z1,x2,y2,z2,x3,y3,z3,c)
	add(ps,tri_make(x1,y1,z1,x2,y2,z2,x3,y3,z3,c))
end

function cube_add(x,y,z,s,d,c)
 d=d or 1

 local b={
  t=0,
  x=x,
  y=y,
  z=z,
  s=s,
  c=c,
  d=d,
  rot=0,
  roll=0,
  pitch=0,
  rolldir=d>4 and 1 or 0,
  bomb=d==9,

  -- random brrrrrrrrrrr
  model={
		 -- top
	 	tri_make(s,s,s,s,s,-s,-s,s,-s,c-1),
	 	tri_make(-s,s,-s,s,s,s,-s,s,s,c-1),
	
	  -- right
  	tri_make(s,s,s,s,s,-s,s,-s,s,c-1),
  	tri_make(s,s,-s,s,-s,-s,s,-s,s,c-1),

   -- left
  	tri_make(-s,s,s,-s,s,-s,-s,-s,s,c-1),
  	tri_make(-s,s,-s,-s,-s,-s,-s,-s,s,c-1),

	  -- bottom
	 	tri_make(s,-s,s,s,-s,-s,-s,-s,-s,c-1),
	 	tri_make(-s,-s,-s,s,-s,s,-s,-s,s,c-1),
	
   -- front
	 	tri_make(-s,s,-s,-s,-s,-s,s,-s,-s,c),
	 	tri_make(-s,s,-s,s,s,-s,s,-s,-s,c),

   -- don't add back for peformance
	 	--tri_make(-s,s,s,-s,-s,s,s,-s,s,c),
	 	--tri_make(-s,s,s,s,s,s,s,-s,s,c)

  }
 }

 -- note direction arrow
 -- 1-8 rotation, 0 directionless
 if d==0 then
  if perfmode then
   local a=s*0.4
   add(b.model,tri_make(-a,a,-s*1.1,a,a,-s*1.1,0,-a,-s*1.1,3,true))
   --add(b.model,tri_make(a,a,-s*1.1,-a,a,-s*1.1,a,-a,-s*1.1,3,true))
  else
   local a=s*0.3
   add(b.model,tri_make(-a,-a,-s*1.1,-a,a,-s*1.1,a,-a,-s*1.1,3,true))
   add(b.model,tri_make(a,a,-s*1.1,-a,a,-s*1.1,a,-a,-s*1.1,3,true))
  end
 else
  add(b.model,tri_make(-s*0.8,s*0.8,-s*1.1,s*0.8,s*0.8,-s*1.1,0,s*0.2,-s*1.1,3,true))
 end

 add(box,b)
end

function part_add(x,y,z,s,roll,c,type)
 d=d or 1
 local xv=cos(roll)/15
 local rd=-sgn(xv)*(rnd(2)+1)

 local p={
  t=0,
  x=x,
  y=y,
  z=z,
  xv=xv,
  yv=sin(roll)/15,
  zv=-0.2,
  s=s,
  c=c,
  rot=0,
  roll=roll,
  pitch=0,
  rolldir=rd,
  type=particlemode==1 and 1 or type,

  -- random brrrrrrrrrrr
  model={
		 -- top
	 	tri_make(s,s,s,s,s,-s,0,s,-s,c-1),
	 	tri_make(0,s,-s,s,s,s,0,s,s,c-1),
	
	  -- right
  	tri_make(s,s,s,s,s,-s,s,-s,s,c-1),
  	tri_make(s,s,-s,s,-s,-s,s,-s,s,c-1),

	  -- bottom
	 	tri_make(s,-s,s,s,-s,-s,0,-s,-s,c-1),
	 	tri_make(0,-s,-s,s,-s,s,0,-s,s,c-1),

	  -- left
  	tri_make(0,s,s,0,s,-s,0,-s,s,3),
  	tri_make(0,s,-s,0,-s,-s,0,-s,s,3),

   -- front
	 	tri_make(0,s,-s,0,-s,-s,s,-s,-s,c),
	 	tri_make(0,s,-s,s,s,-s,s,-s,-s,c),

  }
 }

 add(part,p)
end

function saber_add(x,y,z,s,c)
 d=d or 1

 local r=s*40 -- saber length
 local h=r/4 -- handle length
 r+=h

 local sab={
  t=0,
  x=x,
  y=y,
  z=z,
  s=s,
  c=c,
  r=r,
  p={x=0,y=0,z=2},
  sr=0,
  sp=0,
  sa=false,
  rot=0,
  roll=0,
  pitch=0,

  model={
	  -- bottom
	 	tri_make(s,0,r,s,0,h,-s,0,h,3),
	 	tri_make(-s,0,h,s,0,r,-s,0,r,3),

		 -- side
	 	tri_make(0,s,r,0,s,h,0,-s,r,3),
	 	tri_make(0,s,h,0,-s,h,0,-s,r,3),

	  -- handle bottom
	 	tri_make(s,0,h,s,0,0,-s,0,0,c),
	 	tri_make(-s,0,0,s,0,h,-s,0,h,c),

		 -- handle side
	 	tri_make(0,s,h,0,s,0,0,-s,h,c),
	 	tri_make(0,s,0,0,-s,0,0,-s,h,c),

   -- base
   tri_make(0,-s,0,-s,0,0,0,s,0,3),
   tri_make(0,-s,0,s,0,0,0,s,0,3),
  }
 }

 if not perfmode then
  -- midpoint
  add(sab.model,tri_make(0,-s,h,-s,0,h,0,s,h,c))
  add(sab.model,tri_make(0,-s,h,s,0,h,0,s,h,c))

 end

 add(saber,sab)
end


function scene_update()

poke(0x5f80,128)
poke(0x5f80+1,128)
poke(0x5f80+2,128)
poke(0x5f80+3,0)
poke(0x5f80+4,0)
poke(0x5f80+5,0)

---[[ placeholder lightshow

st=stat(50)

for k,i in pairs(s) do
 ki=k*(1/#s)
 local sign=(k/2==k\2 and -1 or 1)
 altbeat=(st\4%2==1 and -1 or 1)
 altbeat2=(st\2%2==0 and -1 or 1)
 altbeat8=(st\8%2==0 and -1 or 1)


 i.lav=sin(st/32)/100*sign

 --i.lc=8+(st\4+k)%8
 i.lc=sign==altbeat and 11 or 7
 i.sc=sign==altbeat and 7 or 11

 if(st\4%4==0)i.lc=3
 if(st\4%4==2)i.sc=3

 i.rm=sign==altbeat and 0.8 or 1.2

 if(sign==altbeat8 and t%2==0 and st%8>=4)i.lc=0
 if(sign==altbeat2)i.sc=0
--[[
 i.lfr=10
 i.lam=st\4%2*2
]]
end

rav=sin((st/16-1)/10)/100

rst=st%4==0 and 1 or (st%16<8 and 0.5 or 0.8)

--]]

-- move lasers
for k,i in pairs(s) do
 k*=1/#s

 i.lav+=i.laa
 i.la+=i.lav

end

-- move ring
rav+=raa
ra+=rav

rs+=(rst-rs)/4

----

 -- spawn boxes
 if stat(57) and stat(50)%2==0 then
  if makebox then
   --for i=0,rnd(5)-3 do
   for i=0,0 do
    local x=rnd(4)\1/2
    local y=rnd(3)\1/2
    cube_add(x-0.75,0.5+y,21.1,box_scale,rnd(10)\1,rnd(2)<1 and 6 or 10)
   end
  end


  makebox=false
 else
  makebox=true
 end

	for k,s in pairs(saber) do

  -- get saber motion

  s.lp=s.p

  -- get point
  local p={x=0,y=0,z=2}
  -- rotate point to be in line
  -- with saber
 	p.x,p.z=rot(p.x,p.z,s.rot)
		p.z,p.y=rot(p.z,p.y,s.pitch)

  -- get angle
  s.a=-atan2(p.x-s.lp.x,p.y-s.lp.y)
  s.p=p

  local ss=2
 	cam.rotspd=4000
 	cam.pitchspd=4000
  if pi_is_inited() then
   srt=-(pi_axis(4-k*2)+1)/10000/80
   spt=pi_axis(5-k*2)/10000/80+0.02
   s.sa=pi_trigger(2-k)>25
   ss=6

  elseif cbvr then
   srt=cam.rot
   spt=cam.pitch
   s.sa=btn(3+k)
  else
   srt=cam.rot*2
   spt=cam.pitch*2
   s.sa=btn(3+k)

  	cam.rotspd=8000
  	cam.pitchspd=8000
  end
  s.sr+=(srt-s.sr)/ss
  s.sp+=(spt-s.sp)/ss

  if autocolour and box[1] then
   s.sa=s.c==box[1].c
  end

  if false then
   --s.rot=-s.sr*2
   s.rot+=(-cam.rot-s.rot-s.sr)/(2/dt)

   s.pitch=-s.sp*2

   --s.x=0.3-(k-1)*0.6-s.sr*10
   s.y=0.5+s.sp*10
   --s.z=1

   s.x=cos(-0.25-cam.rot)*2
   s.z=sin(-0.25-cam.rot)*2-(cbvr and 1 or 0)

   local mag=0.25-(k-1)*0.5

   if btn(4) and btn(5) then
    --s.x+=cos(-s.a-0.25)*mag
    --s.y+=sin(-s.a-0.25)*mag

    s.x+=mag
   end
  else
  --[[
   s.rot=0
   s.pitch=0.1

   s.x=0.3-(k-1)*0.6
   s.y=0.15
   s.z=0]]
   
   local hand=s.c==7 and hand_left or hand_right
   
   s.x=hand.x
   s.y=hand.y
   s.z=hand.z
   s.rot=hand.yaw
   s.pitch=hand.pitch
   s.roll=hand.roll
  end
--[[
  s.x+=cam.x
  s.y+=cam.y-1
  s.z+=cam.z
]]
--[[
  s.rot=sin(s.t/120)
  s.pitch=sin(s.t/120)]]

	 s.t+=1*dt

	end


	for b in all(box) do

  local _del=false

 	b.z-=0.5*dt

 	b.yo=easeoutback(min(b.t/20,1),-4,4,1)

  b.rot=0
  b.pitch=-max(b.yo/8)

  --b.roll=0
  if(b.d>0)b.roll+=(b.d/8-b.rolldir-b.roll)/(4/dt)

	 b.t+=2*dt

  -- the dreaded collisions
  if b.z<3 and b.z>1.5 then
	  local hb=box_scale*1.2
	  local zhb=0.3
	  local collide=false
	  local col=0
	  local ang=0
	
	  for s in all(saber) do
	
	   for i=0,2,box_scale do
		
		   if not collide then
	
			   -- get point
			   local p={
			   	x=0,
			   	y=0,
			   	z=i
			   }
			   -- rotate point to be in line
			   -- with saber
				 	--p.y,p.x=rot(p.y,p.x,s.roll)
				 	p.x,p.z=rot(p.x,p.z,s.rot)
			 		p.z,p.y=rot(p.z,p.y,s.pitch)

			   -- move point to saber
			   p.x+=s.x
			   p.y+=s.y
			   p.z+=s.z

			   -- check collision
			   if p.x>=b.x-hb and p.x<=b.x+hb and
			      p.y>=b.y-hb and p.y<=b.y+hb and
			      p.z>=b.z-zhb and p.z<=b.z+hb
			   then
			    collide=true
			    col=s.c
			    ang=(s.a+0.25)%1
			   end

		   end
	
		  end

   end

   -- do stuff when hit
   if collide then
	   _del=true

    -- spawn particles
    if particlemode>0 then
     if b.bomb then
      for i=0,1,0.25 do
       part_add(b.x,b.y,b.z,box_scale/3,i+0.125,1,1)
      end
     else
      for i=0,1 do
       part_add(b.x,b.y,b.z,box_scale,b.roll+i/2,b.c,2)
      end
     end
    end

	   rumble=10

    local ra=(b.d/8)%1
    local rn=0.25

	   -- check colours and direction match
    if not b.bomb and col==b.c and
    (
    -- meh
    b.d==0 or
    (ang>ra+1-rn and ang<ra+1+rn) or
    (ang>ra-rn and ang<ra+rn) or
    (ang>ra-1-rn and ang<ra-1+rn)
    ) 
     then

	    -- correct cut
	    if enpcm then
		    playpcm((col==7 and 1 or 4)+rnd(3)\1)
     else
      sfx(9)
	    end
	    combo+=1
	
	   else
	    -- bad cut
	    if enpcm then
	     playpcm(7+rnd(2)\1)
	    else
	     sfx(8)
	    end
	    combo=0

	   end
   end


  end

 	-- die
 	if b.z<0 or _del then
 	 -- reset combo on miss
 	 if not _del and not b.bomb then
 	  combo=0
 	  if enpcm then
  	  playpcm(7+rnd(2)\1)combo=0
	   else
 	   sfx(8)
	   end
 	 end
 	 del(box,b)
 	end
	end

 if particlemode>0 then
		for b in all(part) do

	  b.yv+=0.01
	  b.y-=b.yv

	  b.x+=b.xv
	  b.z+=b.zv

		 -- update model
   if particlemode==2 then

	   b.rot=0
	   b.pitch=0

	   b.roll+=b.rolldir*dt/100

		 end
	
	 	-- die
	 	if b.y<-4 then
	 	 del(part,b)
	 	end
		end
		
	end

	t=max(t+2)

--[[ rumble no workie?
	rumble=max(rumble-1)
	if rumble>0 then
	 pi_rumble(0,255)
	else
	 pi_rumble(0,0)
	end
]]
end

function scene_draw()

 local eye_off=stat(3)==0 and -1 or 1
 update_vr(eye_off*0.06)

 local z=30

	for k,i in pairs(s) do
	 k*=1/#s
	
	 local x,y=
	  cos(ra+k)/6*rr*rs*i.rm,
	  1+sin(ra+k)/6*rr*rs*i.rm
	
	 if i.lc>0 then
   local ang=i.la+k
	  line3d(x,y,z,x+cos(ang)*20,y+sin(ang)*20,10,i.lc)

	 end
	
	 if(i.sc>0)circ3d(x,y,z,64,i.sc)
	
	end

 for i=perfmode and 1 or 0,7,perfmode and 2 or 1 do

	 circ3d(0,1,i*4,500*rs,4+i)

 end

 -- floor
	foreach(ps,w➡️c)
	foreach(ps,c➡️s)
	foreach(ps,point_draw)

 -- hud
 c=tostr(combo)
 for i=1,#c do
  spr3d(-2.5-0.25+0.5*i-0.25*#c,1.1,7,8+tonum(sub(c,i,_))*8,0,8,16,7)
 end

 spr3d(-2.5,1.7,7,88,0,32,8,7)

 -- notes, drawn back to front
	for i=#box,1,-1 do
	 local b=box[i]

	 -- update model
	 if not _del and not b.bomb then
		 for p in all(b.model) do
		  p.rot=b.rot
		  p.pitch=b.pitch
		  p.roll=b.roll
		  local o={x=b.x,y=b.y,z=b.z}
		  --local o=b
		  if b.yo<0 then
		   o.z-=b.yo*2
		  else
		   o.y-=b.yo/2
		  end
		  w➡️c(p,o) -- b provides box position
		  c➡️s(p)
		 end
	 end


	 if b.bomb then
			circ3d(b.x,b.y,b.z,180*box_scale,1,true)
  else
	  foreach(b.model,point_draw)
	 end
	end

 -- particles
 if particlemode>0 then
		for p in all(part) do
		 if p.type==2 then
		 
			 for p in all(b.model) do
			  p.rot=b.rot
			  p.pitch=b.pitch
			  p.roll=b.roll
			  w➡️c(p,b)
			  c➡️s(p)
			 end
		 
		  foreach(p.model,point_draw)
		 else
		  circ3d(p.x,p.y,p.z,180*p.s,p.c,true)
		 end
		end
	end

 -- sabers
	for s in all(saber) do
	
	 -- update model
	 for p in all(s.model) do

   if not perfmode or s.sa then
	   p.rot=s.rot
	   p.pitch=s.pitch
	   p.roll=s.roll

	   local o={x=s.x,y=s.y,z=s.z}

	   w➡️c(p,o)
 	  c➡️s(p)
   else

    p.on=false

	  end
	 end

	
	 foreach(s.model,point_draw)
	end


 ?hand_left.x,1,1,3
 ?hand_right.x
 ?peek(0x5f80+6)
 ?peek(0x5f80+14)
 ?stat(3)
 ?eye_off
end

function point_draw(p)
	--only draw dots that are in
	--front of the camera
	if p.on then
	 p01_triangle_335(p.sx1,p.sy1,p.sx2,p.sy2,p.sx3,p.sy3,p.c)
	end
end

-->8
-- p01 trifill

function p01_trapeze_h(l,r,lt,rt,y0,y1)
 lt,rt=(lt-l)/(y1-y0),(rt-r)/(y1-y0)
 if(y0<0)l,r,y0=l-y0*lt,r-y0*rt,0
 y1=min(y1,128)
 for y0=y0,y1 do
  rectfill(l,y0,r,y0)
  l+=lt
  r+=rt
 end
end
function p01_trapeze_w(t,b,tt,bt,x0,x1)
 tt,bt=(tt-t)/(x1-x0),(bt-b)/(x1-x0)
 if(x0<0)t,b,x0=t-x0*tt,b-x0*bt,0
 x1=min(x1,128)
 for x0=x0,x1 do
  rectfill(x0,t,x0,b)
  t+=tt
  b+=bt
 end
end
function p01_triangle_335(x0,y0,x1,y1,x2,y2,col)
 color(col)
 if(y1<y0)x0,x1,y0,y1=x1,x0,y1,y0
 if(y2<y0)x0,x2,y0,y2=x2,x0,y2,y0
 if(y2<y1)x1,x2,y1,y2=x2,x1,y2,y1
 if max(x2,max(x1,x0))-min(x2,min(x1,x0)) > y2-y0 then
  col=x0+(x2-x0)/(y2-y0)*(y1-y0)
  p01_trapeze_h(x0,x0,x1,col,y0,y1)
  p01_trapeze_h(x1,col,x2,x2,y1,y2)
 else
  if(x1<x0)x0,x1,y0,y1=x1,x0,y1,y0
  if(x2<x0)x0,x2,y0,y2=x2,x0,y2,y0
  if(x2<x1)x1,x2,y1,y2=x2,x1,y2,y1
  col=y0+(y2-y0)/(x2-x0)*(x1-x0)
  p01_trapeze_w(y0,y0,y1,col,x0,x1)
  p01_trapeze_w(y1,col,y2,y2,x1,x2)
 end
end

-->8
-- easing functions

function easeoutback(t,b,c,d)
 local s=2
 t=t/d-1
 return c*(t*t*((s+1)*t+s)+1)+b
end

function easeoutquad(t,b,c,d)
 return -c*(t/d)*(t-2)+b
end

-->8
-- other functions

function playpcm(id)
 for i in all(clips) do
  i.done=true
 end
 defy_cue(id)
end

function circ3d(x,y,z,r,c,fill)
 local p={
	x1=x, --world space x/y/z
	y1=y,
	z1=z,
	c=c, --color
	cx1=0, --camera space x/y/z
	cy1=0,
	cz1=0,
	sx1=0, --screen space x/y
	sy1=0
	}
 w➡️c(p)
 c➡️s(p)

 local f=fill and circfill or circ
 if(p.on)f(p.sx1,p.sy1,r/p.cz1,c)

end

function spr3d(x,y,z,spx,spy,w,h,s)
 local p={
	x1=x, --world space x/y/z
	y1=y,
	z1=z,
	c=c, --color
	cx1=0, --camera space x/y/z
	cy1=0,
	cz1=0,
	sx1=0, --screen space x/y
	sy1=0
	}
 w➡️c(p)
 c➡️s(p)

 local w2,h2=(w*s)/p.cz1,(h*s)/p.cz1
 if(p.on)sspr(spx,spy,w,h,p.sx1-w2/2,p.sy1-h2/2,w2,h2)

end

function line3d(x1,y1,z1,x2,y2,z2,c)
 local p={
	x1=x1, --world space x/y/z
	y1=y1,
	z1=z1,
	x2=x2, --world space x/y/z
	y2=y2,
	z2=z2,
	c=c, --color
	cx1=0, --camera space x/y/z
	cy1=0,
	cz1=0,
	cx2=0, --camera space x/y/z
	cy2=0,
	cz2=0,
	sx1=0, --screen space x/y
	sy1=0,
	sx2=0, --screen space x/y
	sy2=0
	}
 w➡️c(p)
 c➡️s(p)

 if(p.on)line(p.sx1,p.sy1,p.sx2,p.sy2,c)

end

-->8
-- pinput client v0.1.2
-- @vyr@demon.social

-- common

pi_gpio = 0x5f80

pi_magic = {
 0x46c7.2002,
 0x6e44.ab77,
 0xd67f.dcbe,
 0x4d98.77d2,
}

pi_num_players = 8
pi_gamepad_stride = 16

-- write pinput magic to gpio
function pi_init()
 for i = 1, #pi_magic do
  poke4(
   pi_gpio + 4 * (i - 1),
   pi_magic[i]
  )
 end
end

-- if magic is cleared,
-- pinput is ready
function pi_is_inited()
 return peek4(pi_gpio) ~= pi_magic[1]
end

-- buttons

pi_buttons_offset = 2
pi_num_buttons = 16

pi_⬆️ = 0
pi_⬇️ = 1
pi_⬅️ = 2
pi_➡️ = 3

pi_start = 4
pi_back = 5

pi_ls = 6
pi_rs = 7

pi_lb = 8
pi_rb = 9

pi_guide = 10
pi_misc = 11

pi_a = 12
pi_🅾️ = pi_a
pi_b = 13
pi_❎ = pi_b
pi_x = 14
pi_y = 15

-- read a button
function pi_btn(b, pl)
 pl = pl or 0
 if pl < 0 or pl >= pi_num_players
 or b < 0 or b >= pi_num_buttons then
  assert(false, 'pi_btn: parameter out of range')
 end
 
 local buttons = peek2(pi_gpio
  + pl * pi_gamepad_stride
  + pi_buttons_offset)
 return 1 & (buttons >> b) == 1
end

-- triggers

pi_trigger_offset = 4
pi_trigger_stride = 1

pi_lt = 0
pi_rt = 1

pi_num_triggers = 2

-- read a trigger
function pi_trigger(t, pl)
 pl = pl or 0
 if pl < 0 or pl >= pi_num_players
 or t < 0 or t >= pi_num_triggers then
  assert(false, 'pi_trigger: parameter out of range')
 end
 
 return peek(pi_gpio
  + pl * pi_gamepad_stride
  + pi_trigger_offset
  + t * pi_trigger_stride)
end

-- sticks

pi_axis_offset = 6
pi_axis_stride = 2
pi_num_axes = 4

pi_lx = 0
pi_ly = 1

pi_rx = 2
pi_ry = 3

function pi_axis(a, pl)
 pl = pl or 0
 if pl < 0 or pl >= pi_num_players
 or a < 0 or a >= pi_num_axes then
  assert(false, 'pi_axis: parameter out of range')
 end
 
 return peek2(pi_gpio
  + pl * pi_gamepad_stride
  + pi_axis_offset
  + a * pi_axis_stride)
end

-- rumble

pi_rumble_offset = 14
pi_rumble_stride = 1
pi_num_rumbles = 2

pi_lo = 0
pi_hi = 1

-- note: this writes rumble,
-- instead of reading it
function pi_rumble(r, v, pl)
 pl = pl or 0
 if pl < 0 or pl >= pi_num_players
 or r < 0 or r >= pi_num_rumbles
 or v < 0x00 or v > 0xff
 or v % 1 ~= 0 then
  --assert(false, 'pi_rumble: parameter out of range')
 end

 poke(pi_gpio
  + pl * pi_gamepad_stride
  + pi_rumble_offset
  + r * pi_rumble_stride,
  v
 )
end

-- flags

pi_flags_offset = 0
pi_num_flags = 6

pi_connected = 0
pi_has_battery = 1
pi_charging = 2
pi_has_guide_button = 3
pi_has_misc_button = 4
pi_has_rumble = 5

-- read a flag
function pi_flag(f, pl)
 pl = pl or 0
 if pl < 0 or pl >= pi_num_players
 or f < 0 or f >= pi_num_flags then
  assert(false, 'pi_flag: parameter out of range')
 end

 local buttons = peek2(pi_gpio
  + pl * pi_gamepad_stride
  + pi_flags_offset)
 return 1 & (buttons >> f) == 1
end

-- battery level

pi_battery_offset = 1

-- read battery level
-- (0 for wired)
function pi_battery(pl)
 pl = pl or 0
 if pl < 0 or pl >= pi_num_players then
  assert(false, 'pi_battery: parameter out of range')
 end

 return peek(pi_gpio
  + pl * pi_gamepad_stride
  + pi_battery_offset)
end

-->8
-- vr.p8
-- aaaaaaaaaaaaaaaa by cubee 🐱

hmd={x=0,y=0,z=0,yaw=0,pitch=0,roll=0}
hand_left={x=0,y=0,z=0,yaw=0,pitch=0,roll=0,trigger=0,grip=0}
hand_right={x=0,y=0,z=0,yaw=0,pitch=0,roll=0,trigger=0,grip=0}

function get_vals(addr,array)
 local idx=0
 for i in all(array) do
  i=peek(addr+idx)
  
  -- move all but y to 0 origin
  if(k~="y")i-=128
  i/=100

  idx+=1
 end

 return array
end

function update_vr(eye_off)
eye_off=eye_off or 0
--[[
hmd=get_vals(0x5f80,hmd)
hand_left=get_vals(0x5f80+6,hand_left)
hand_right=get_vals(0x5f80+14,hand_right)
]]

function fix(addr)
 return (@(addr)-128)/100
end

function fixrot(addr)
 return (@(addr)-128)/255
end

local a=0x5f80

hmd={
 x=fix(a)+eye_off,
 y=@(a+1)/100,
 z=fix(a+2),
 yaw=fixrot(a+4),
 pitch=fixrot(a+3),
 roll=fixrot(a+5)
}

hand_left={
 x=fix(a+6),
 y=@(a+7)/100,
 z=fix(a+8),
 yaw=fixrot(a+10),
 pitch=fixrot(a+9),
 roll=fixrot(a+11),
 trigger=@(a+12)/100,
 grip=@(a+13)/100
}

hand_left={
 x=fix(a+14),
 y=@(a+15)/100,
 z=fix(a+16),
 yaw=fixrot(a+18),
 pitch=fixrot(a+17),
 roll=fixrot(a+19),
 trigger=@(a+20)/100,
 grip=@(a+21)/100
}

cam.x=hmd.x	
cam.y=hmd.y
cam.z=hmd.z

cam.rot=hmd.yaw
cam.pitch=hmd.pitch
cam.roll=hmd.roll
end

-->8
--defy audio string library by bikibird
local buffer=0x8000
local clips={}
local cued
local step, new_sample, ad_index,c,direction 
local index_table = {[0]=-1,-1,-1,-1,2,4,6,8,-1,-1,-1,-1,2,4,6,8} 
local step_table ={7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66, 73, 80, 88, 97, 107, 118,130, 143, 157, 173, 190, 209, 230, 253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767}
local adpcm=function(sample,bits)
if bits >1 then  
local delta=0
local temp_step =step
local sign = sample &(1<<(bits-1))
local magnitude =(sample & (sign-1))<<(4-bits)
sign <<=(4-bits)
local mask = 4
for i=1,3 do
if (magnitude & mask >0) then
delta+=temp_step
end
mask >>>= 1
temp_step >>>= 1   
end
if sign> 0 then
if new_sample < -32768+delta then 
new_sample = -32768
else    
new_sample-=delta
end
else
if new_sample >32767-delta then
new_sample =32767
else
new_sample +=delta
end
end 
ad_index += index_table[sign+magnitude]
else
if sample==1 then
if new_sample < -32768+step then 
new_sample = -32768
else    
new_sample-=step
end
else
if new_sample >32767-step then
new_sample =32767
else
new_sample +=step
end
end 
if sample==direction then
ad_index+=1
else
ad_index-=1
direction =sample
end 
end 
if ad_index < 1 then 
ad_index = 1
elseif (ad_index > #step_table) then
ad_index = #step_table
end 
step = step_table[ad_index]
return new_sample\256+128
end 
defy_load=function(clip)
add(clips,{clip=clip,start=1,endpoint=#clip, index=1, loop=false, done=false}) 
end
local cued=false
defy_cue=function(clip_number,start,endpoint,looping)
clips[clip_number].start=start or clips[clip_number].start
clips[clip_number].index=clips[clip_number].start
clips[clip_number].endpoint=endpoint or #clips[clip_number].clip
clips[clip_number].loop=looping or false
clips[clip_number].done=false
step, new_sample, ad_index,delta,direction=7,0,0,0,0
cued=clip_number
end 
defy_play=function()
if cued and not clips[cued].done then
while stat(108)<1536 do
for i=0,128 do
c=ord(clips[cued].clip,clips[cued].index)
poke(buffer+i*4, adpcm((c>>>6)&0x03,2), adpcm((c>>>4)&0x03,2), adpcm((c>>>2)&0x03,2), adpcm(c&0x03,2))
clips[cued].index+=1
if (clips[cued].index>clips[cued].endpoint) then
if (clips[cued].loop) then
clips[cued].index=clips[cued].start
else
serial(0x808,buffer,i+1)
clips[cued].done=true
return 
end
end
end
serial(0x808,buffer,512)
end
end
end
function eject()
clips[cued].done=true
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333000333003300033033330003330000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333303333303330333033333033333000000000
00000000003333000033300000333300003333000000330003333330003333300333333000333300003333003303303303303332333033033033033000000000
00000000033333300033300003333330033333300003330003333330033333300333333003333330033333303300003303303333333033331033033000000000
00000000033003300003300003300330033003300003300003300000033000000000033003300330033003303300003303303323233033331033033000000000
00000000033003300003300003300330033003300033300003300000033000000000033003300330033003303303303303303303033033033033033000000000
00000000033003300003300000003320000003300033033003333300033000000000330003300330033003303333303333303300033033333033333000000000
00000000033003300003300000003300000033200333033003333330033333000000330002333320033333300333000333003300033033330003330000000000
00000000033003300003300000033000000033200330033000000330033333300003300002333320003333300000000000000000000000000000000000000000
00000000033003300003300000033000000003300333333300000330033003300003300003300330000003300000000000000000000000000000000000000000
00000000033003300003300000330000033003300333333303300330033003300033000003300330033003300000000000000000000000000000000000000000
00000000033003300003300002330000033003300000033003300330033003300033000003300330033003300000000000000000000000000000000000000000
00000000033333300003300003333330033333300000033003333330033333300330000003333330033333300000000000000000000000000000000000000000
00000000003333000003300003333330003333000000033000333300003333000330000000333300003333000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007777f7007777f757df57dfffd52813e6b52aa3ab29ea1d680c66ae2eb80eb7a9a847dab10c906b8026f2e0ea1a1caafa48861708014b60890cb2ac316ea0bc
501a00aa501a00aaefbb60968a070400e2efafaeeac0b65a0017a12682e0e83b8ffa2c12c68118280491022827b87c13a63afa3000926c68c1f2ab1ca6ba1ca9
084a82a7084a82a7ae7ce6608daabf2afea20c8108108717914160c862f290aa6cfef2caca8a018d7008408147a11206071648192eeeabeebbba2aca88211b00
16aa0f8116aa0f81320161abeb2fae8cea10484181488219c6423b22eea1adabd8da001c3b828850ea8238670746504061a6caf320cfbafa08f2298856864868
0bb8ba040bb8ba04caa68e368b388a5610abaabfe89b9e2c001226075180a97c8ae20981b6ea837a0ba0afb3ee8b4001041072461011c609aba2ae0e0b26d236
ad36a86cad36a86cc6a0f82ebf78cac6b0690e86178601a1ababba016bb8cbeaeab90abbab8bc861090441860421c6066b90ac8abefe932ee28112ca86110009
872121ac872121acec3fcb07a121481a8ad6c026191c608aa2f82bbe8a0fa7beca0bb811400781e63aea021a161600b5484cc200ba7e8edbe220e12d0c401a10
1fe6608c1fe6608ca04d8b86e1b0284ccea7200142c2206fc87101a1a00d1ba21acbb600e2a17b1caba60cc631600b92c016882627812c3adafa202fa8afb20d
27c206e527c206e5b11900662aeb7818aaaefec23a1aabe72a9a911000581217c226081a1e8f03d7a230718a8e928e0266395c8bb6aa8e501ba6b2b0b128a90f
0c0a22100c0a221097b6b13a6b8adae2e6291ea0891fc3a78c3a600c0207e6316a1a9aaab66c2a601edbe090b0000bba5e9be0bab1794b8380812611ae3211aa
1adfb2a91adfb2a96baa1e8be6a9be2698ae2310c136619c6b02d8baa06c0c06e0e12a13e0601eca3604008a9f820680b17911dae2e6c831409caba282c67168
b00162e8b00162e8680aa71c0be6a80f07914c63aa0c20a6cd0b031160a7ca8867084cbaa6a9ba638bca23108ab6666c8a018ac7394cabe236400ea10141a63b
afda1040afda104018932a18ba0c0ecbbab6362148400141c2b6f6a60f82aa2c7912b28610508b8b1c1833704c98c2a0600181ad0b6b82e2f909084a1f2aa8f1
8bf637108bf6371043aaa608cbfa8140462a92d383f6280e4eaae20a0eb5671a6fa298ad3a2aceb066aab66a0786a9cb030afa272b6a98928e2da2a91fb61698
2cb780202cb78020621a2931eaa3b6b0f29a8bc6814c6600387086e1e8a96bcaa01386400bab6c7c602d0ca2230d20363d60212ae6a231b92d2092db10a1e6a8
00a1abe100a1abe1cac6a6e10071080a920036a64c6c970c22160c060b13922bf3e6e100684e6c2ada20c1b0b910a2c816e5b1006d881b8bd2e2e0a67c680b82
b9484e1eb9484e1e8a08c62021690d43ca87b6c660b90a0ca2b2e6b7b821180e1853e0e630666c1c0a8a838804b5206c1a4fda0b00e6b829682edbc286e2f100
82b6a10a82b6a10a6d8e8f92a6c0b6b90028b8b0b93d680a0e930ba7b8b138011a4c13928b10100886c0e6e1ea484c0e0f08a6b2cc9600b7c2a6097a6e4e1a82
081638b1081638b10821ac1f9a0b1b0a20fcfb810180ab1b400426e1c6400086aa3cab520ca78b4e8100ac4c113b2f6caa2e3f88118760eaa8a12130a20b0c46
6681cbf26681cbf2021006323cfa3aa137807e4860a00c81007a881343421000aa0c8704abeb0a3638fab0a6eaa60402b600c82128bc288104b5a6e2aaaa86a2
0a8a00040a8a000400a0eaa2ba0080a80b00100200a2aa0a8a820800401a2a0b080000002aaaaaaa08a0aaaaaaaaaaaa0e080000000008000000000000000000
000020aa000020aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa8adddddddddd7f4677ff6d078bb7a12368a3ea408d4648aafbc2a0cb214e7011aa50
116032aa116032aafb8e002b38815626278e29bb114313aabbb80a360a66aafa2fd8220c8246677ab1111a8aaaaff2bbcba121a9b211a2b99ef2b2e20a605090
56a2268d56a2268de7ba0f80308ff6eaa1885110a92ce6aeaa109156a2fe08ca9b1e01080abba0229f100736e23fa2aaae615189a2feab0b2867524296a2c086
afee8ab2afee8ab28a4e885641114100a62f22abeefa2eba602841c6aab0d668ca4622beaaee26470110110ceabe880afa3bfbaeb8da8a012650917082074740
faabbbaafaabbbaa2ae1bba6be8d3a3110b6a60816a14c0811a012660f7822bdcae62fadaa08e600cb00ca8717000482b9104701a8cfab3e8ef60010a1805866
8e2c2fc88e2c2fc81861500a78abefca8aa0270dfa0150629018b1a1ba8f04462a2d2e8bf2cb2babc21aa611045a07804910600bfaac0ce6ab0fe08011044686
8a87b0f38a87b0f3a88d2c01ebbef280ebbaf0e2a958911101071100a00cf2bbb8a1ba0ae2e30fea2b0f988e1ba101108106160766aab08c804704e271abafab
ce60a8abce60a8ab09810751ab2e0126005702b0ab7cfaaa1b1a10a72baaabb80fa3bc4bb68b40a6410628cac7a082cfc2600196301108a9291f86a750e2a3bd
b3e0ebabb3e0ebab2aae1847078107a1410042a61e3140b128bfabeeabeeabbbca60480104585040118120aaea2618f6086befbea2eaa01eeb8ec2fa185aca46
16b882ac16b882accbbbe2abfe0102400410114040a1fc0a460012b29ceeeeba0aa6ac0aa3ac964102cb570701686eababaca82903b3a1babf08abb04e1217ea
ba28f222ba28f222224196eace06b6814019c186eaa287002900e6fafefabeea0cacba8ba168aa5656110216800781b220bb4086a6af8cbaff00a7eefaabeaae
6121500761215007876011a60040a73aaeafebab0caafacaa21028369e1c3a40a10210470256b2ba8186a710874601c6226733babebbb00bbaaafe0818560186
400121b6400121b6b8ca2fe228af10400687914682f33b20bb3acba68e8a166017a170aa00b2418027271086c611c200a1f3ed22baaca28903f9faeeeaae0011
494880b6494880b660bcb08be3acca2ce8610a964616ba04000fbbeaababceaaba796010611056a083410040e1060dea2bceeaeefeaaeabeba4c406640875040
8cfcaebe8cfcaebee2abe22af23ba0a70e16b650a807400640caa081be023207eebdfe222bca8c9a0251688a47d011409600207a40261cbbeaeeefb808a0a6a8
1a17c0811a17c08160a2661b0b20c2d0126d08bafab1beebbaaa2e8b008036171786412760eac828abafae21bac17040aacb9cbafaaa6cabb011ca0077a62812
080066fa080066fa2beeeec2a8e2f8928cdbc641006a6010c05218a6ba282cfbf2c2e80b109ca0e6a753a10e07408a920046e2abbabf0ceaebcb2baaae1f0141
104860a2104860a2cae62e08bafbbeebbacaeaab01683c6a66610856100b0ca6ae088a09511eaab200cf6cbc72b82ec1804c81101c16beb100a8c0264bc9b1aa
1640811216408112aae0ec00ecbfbeabeaeacb1080d2a0b6504246015116a01008a12afaefb2fefacaa0ba006610a2c64058aa90a7934222416acb4616e2e22a
b510a2a2b510a2a2962701c104f0eeeeabbeabaaca024827171640561008a1c21ba6eb80bbeeabbfbaaaaa9a18616098011641004100bcabe2bbaa2d2a0cb6c2
162abbab162abbabafaebea2abca600a105001161060aaeaababbaea8babaeaa08081640100140108200aabbaabeeabecaaaea0a00011640160116000420baea
abaaaaaaabaaaaaaaa004010000100010000aaaaaa2caaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa77777777d7
435db6a6435db6a6a3be2c9a500b261e9232698f281ca2374cb2183aa74c2160aaceb6a3cba8ba0851424004278aebbcba3a2a19ac7a2bfa7011110a161a8bfa
0051a1aa0051a1aace04adc104a250c3178ce6caeae80313a19a01a11ab10be603400798cac2b8bb22895341aa19b6b22bab0b02a6a62ab53850aa1c6f2b8602
d60146cad60146ca0e66bbcb0aa0f60c11661000b64250c3bb224c1862c9aaf2ea7ea24c04901116a60ba0fbeafa3afaaa6c110c16581011ba02b107bbeaaaba
40aaabee40aaabee1667e2a2aaaab8ce490c278e16a2cf01e6abbe2011e1ea0b20a26150c6561128a6e8ea2ccf2fac9c0ba190168241a8b0e59a000ffaa026af
a6408631a64086312ff2aeea0faa0c16010741508a08611aaba2afff0beaea0eb600076aa8015186408204a78fa37eaafabb08b2abdca22058d2418927014686
eeababbfeeababbf3aba22414016164004a1002bb3c3b0aa4c1220708be12c400150cbaa8c20025156a6aabdea862fe3810bcaeac24b9810171111100060fbea
604c5018604c50181030041abce2baabea606c409a0427188aa6167a00cff2bbaa8b50089229e6b28e96caaa3eae9feaa680515641188026ceb2ea8ee620eebf
304a5a8f304a5a8f8607175010101018288afbfabaafebaecb2002baa9605c18471181610a90abbbabfabbea8bba8a810407041140610802e8bfebd200875018
eaa28eaaeaa28eaa7c2ac25151400441a18aabfe0e229aa03050b0ebafbfa2ab0240a80796572a48560b86ca220a2bae427607b2bebe0feac2e0260050961916
926b2ba2926b2ba230ba8ec0afffe2ea0f280a874d5011104811000029a3b3a7a3befaeaab0eea2aafc0d1a61841071640a1b60010aefef2eaae0eca02271650
2b7087002b7087007002068b3afa6c3cc862465ba12a70aebe0b0610410106b6b2bcaefea16a002640400cba68bee61c89114020ae3ef206b632100b2b17e2a9
82499acc82499acc212b3baa3a0727669a83e83d0a28e3ccaf38295211500121800c98fbbeab8a99aeca9040b5220f50aaca974b6c0086620e912bbaaa3e2ce0
b6108240b6108240100617041618aaa9ae8fbffafaeaba2c8ba6b85011461681018182b6b2ebafbeeaa20a8ba11061416060cab2c180d6ca982c0a43a60709a0
c8bbe2b0c8bbe2b0081c8ad2e05c0248a701560111caa2baefbe3a8001c860daea4c184891b826a7aa9e2eab8ba1f8127600614917a2eae6acbe2aae8b007912
4649082646490826b0afbece06faa12a4ad60089218d02b30a071c039037fa2ea06251180c8a18981740027da9fa320740bc66baab2a2ccec0e263a846484741
b20c28afb20c28afc3b05cc6a1ea37a2abea2c822846565681404060c08a2bfebbeaea2c4ca0b848c6460981e66b0b002a07761b8680da0c76180efa638ba0a2
0787602007876020ed6b2fb6280b680218bba81c9b2b5bca626203a60b0132161300a748a8b36dec2bb83b6cc0a6ac6260406681602c2e83c880eb36966c1818
72caeaed72caeaedb21ca2fa292e8c62109637408a16ba6cabe90c8821970bc1a1aec226910b2a036a1b3a0fb233989281168802d6761080a73870c10a12b0bc
411a8ab1411a8ab1a92c4eabcacb40885a2ebe4e04d2aa27aa17982286d6b2f2ae98baa810c3e2e3d843002a1bf27618060096c6266c8b9adae20090389ea2ae
87c2872087c287201f618ebab1a14ec0010101a680c6211f32a2e2f60828aea80d8b87b50b62802a2712102a080a002188a61c9a0fa2c020c881b12a1050aa68
0bb2208a0bb2208a820021a8a1ba48a022000060088001aaa0aa0b2aba00280b2020aa08080000008182aa08000000000000000000000000000000000000aa0a
208a2a00208a2a00008220000000000000000000000077ff5d777fff37d17cdf6708ae78eab26bf686c60886c316ee81c604a1b380aead608da1eb92600b1abe
fa1a1040fa1a1040aa2f02e5cd8620bcacab0a211d260910a1cb60034681602befee2eca11a950068be6ab48ab5080e2feca1bd2402610aa0fab2e0407a14c82
62c8982f62c8982f2e025100babbc24a211627bababebab111162102e2fbbe2e0b1200b501014682d5c00208823ae8a9efafbe40010486a3eecaa84d0b171640
baba23bcbaba23bc8cea381bb6611b260a8616aabcaeb0dcc640a2072a6b23b8b8c686600d8067aaadecbec040b60a264a310ac60840324beea1861cb60a2611
2faeabea2faeabeaba085086485101568008ebaeec162a48fb1080fe0881b28e07262856febaacafaa4847162640a6ce021608eb1bbae8be0828ff8b0a04668a
47ba00a147ba00a1aebeaabecd4008218b962c04dcca1622a7ba0ce2fafcea8a1b994046401640800229a01fc670baebb3ecaeaebab600501016160486b22a0c
b2aa4c0eb2aa4c0e86278f7000b3aa63585adaa298210bb7abefba500112e80b4041406600804ceabbbeae2b2b8a127e8ba158818722fabbdc884c20b0a16857
ebb0eabbebb0eabbadeaabbaea2a1e1841860a61f600a6236066070a1bbbc83a161616a8bfeeababba00baa16001d6018716014090a1bbab3ba22fbca2eecd02
00860bea00860beabbab8c222ce01118bac804d62a509611aa1f3b80502817a8fe82eeaaaeea2ae61c594001460600f8eab3b6b822a3caa7d2a040ad07078106
bb080111bb080111c1a2afbf00040416a67881118a16a8202effcc12ea60ba6b8e8ec896aba090580d4086a73e40268862b18230a6a0c9fbc986968a3ae3fa2c
d660aa04d660aa048610170307628c8bba28e62117962b90ab2c2cb0afcba6f6e0faca221150421046101140ca1108e2bbabba8bafbba2ee8a4032d02f3aa307
66600160666001602692c1e6acacfbbbacaeaeae021700074601500140a608b2bebeaceaca58200e4181aad89168aeaf2e3ba3ae3c23038b9842668746111111
be2feebabe2feebacaeabeca0019ba81104616010616680a22c3babeabaeee1c10aaeeabe8ac0ca6f340161101401882661c024727ea82beea0ec130aaebc8ca
0446460404464604000bb0eeeeeaeb402017009118914060eacefbaaaeab32c991b8aaa1a94d118104160472aafbafeeeacaa8a64641410840b0eabab6a2e8b2
8901c02c8901c02ccaffe28b8a5141878646810200b3bccba2cfeeaaee2e504a991810a6ba004248461c822ce8bbfb2fab887a40041817581890604c000268eb
eba388d6eba388d610074018183812189a8b6c867a82e6aecbe6ca038bae2cfb10182066571a0826a07e20f8a64fc2880aee4f13a0e2a28843b920c696ade186
4cb6232c4cb6232c88fa32c2b0a11b8c1ba01bd62616400450cbc6a0babebaca081888eb60e50062b566214b2807a6a8ece82e2d2cb0086072f9800c411c5060
8cbe00478cbe00479232404306625c0b1028298d3eaa2eb3babea3bc6c80501b011140406089508c069bbe2cabe0fa0aaa9fba5ccaa1101e0181821000cda3b7
671d2249671d2249508bca863eaac26b8f03d20b80e6aa9ebe6dbaa6164288a72096ae3b40b2e1b8c6bab21ceaa8e2a66feaa61a0c01d09b00404186b1382071
888ae7ea888ae7ea80cadb8daa788146a2abba3ceaae0e5c022d1c01a62639062eaa8bb63a614e0a091bc7a10abd687c0c02a2bbace17c8a0a07105040044640
abbb0f68abbb0f68afae8ffaaa0c104046501010210004a23700270c1e8bc2900c8b268286a690e10802ba0082aaaba0a2ab8acaaaeaa818a000074010100004
ababbeeaababbeeabaeaaaaaaaaa004010000100000400000000000002aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0c0877777777f75f57ff5f41e2e07cd848c0b1a1
eabe60baeabe60ba521b8250c21183abaf0c048789aaeacf04ca6a2e18414c8b178c4881c0a6e80e8b8708d1baebafaaaa0b66171182784c92c086ab28bffa08
2cbb8bb62cbb8bb60c281a4261a1016ea70a81b6ad2ef982abb000efb6bb612a400462abadae0a016111b6faaabae2c666aa83e64000a102473dfcc02c088250
efabaaddefabaadda89621a638616a8248ebffbbaaeabe8004165640500000abca28bfb8afcea11e1aa18aa13d42b81ab0abbe02185d5008670a2bbb0b03b2ca
0004691a0004691a1611a041170411a600b2bfeebcaa1c2aeb0c2b6eca41e8040148a7661b20402b8151ab8ea8bb0ef8cb6baa00e029fabb30a7a11101212601
abcaabbaabcaabba1c10602242078616fa21eea2eeba0217018600eefbbaab60692eb2181896080666ba00fb41078272caeaf0ebabfa28d2a6024611a6e610aa
6af9ba0f6af9ba0f00a121a7082718d250a02b4804fe6c2ae28afbbbbc2aeb0eb9ba2a56014617110a04b80eb62cae2a8b8836f0eba3eacf22a2eb4019046111
a92f2051a92f2051182058bbabbbabab2dbaaf8aaa3e4aa6a11ab65b5800015110a2afa2feaba8a21658ab0ba6b88ff2fa98a1bf5080500160baeaaa0cf6a0ca
207b50cb207b50cb07610aa6bc62fa60eabbeabefaabcaab0a474602172158608aa6ab040a614cebefabbbbbeaeaee00504001121616180126aaaa1d8ab50b82
0883f6ab0883f6abb0b20ec62641414046044004ac22eef2faaabf4c8010012240165002bacf1100a626abe7bb2b0a212a0af0bbb846d1ea114640108acabc0b
6c2acf8a6c2acf8ae22cde8051b2d86610abaeaeb8ca8849a7b2fa81004c86522621f2a04104424831babefebbbaaa2faaee2040aa1947478601040766baaafa
__label__
00007700000100000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000017000000000
00000070001000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000001000000000
00000007001000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000071000000000
00000000710000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000700100000000
00000000017000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000700100000000
00000000100700000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000007000010000000
00000000100077000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000070000010000000
00000001000000700000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000070000001000000
00000001000000070000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000700000001000000
00000010000000007700000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000007000000000100000
00000010000000000070000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000007000000000100000
00000010000000000007000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000070000000000100000
00000100000000000000770000000000000000000000000000000000000000000000700000000000000000000000000000000000000000700000000000010000
00000100000000000000007000000000000000000000000000000000000000000000700000000000000000000000000000000000000000700000000000010000
00000100000000000000000770000000000000000000000000000000000000000007000000000000000000000000000000000000000007000000000000010000
00001000000000000000000007000000000000000000000000000000000000000007000000000000000000000000000000000000000070000000000000001000
00001000000000000000000000700000000000000000000000000000000000000007000000000000000000000000000000000000000070000000000000001000
00001000000000000000000000077000000000000000000000000000000000000007000000000000000000000000000000000000000700000000000000001000
00001000000000000000000000000700000000000000000000000000000000000007000000000000000000000000000000000000007000000000000000001000
00010000000000000000000000000070000000000000000000000000000000000070000000000000000000000000000000000000007000000000000000000100
00010000000000000000000000000007700000000000000000000000000000000070000000000000000000000000000000000000070000000000000000000100
00010000000000000000000000000000070000000000000000000000000000000070000000000000000000000000000000000000700000000000000000000100
00010000000000000000000000000000007000000000000000000000000000000070000000000000000000000000000000000000700000000000000000000100
00010000000000000000000000000000000770000000000000000000000000000700000000000000000000000000000000000007000000000000000000000100
00010000000000000000000000000000000007000000000000000000000000000700000000000000000000000000000000000070000000000000000000000100
00100000000000000000000000000000000000770000000000000000000000000700000000000000000000000000000000000070000000000000000000000010
00100000000000000000000000000000000000007000000000000000000000000700000000000000000000000000000000000700000000000000000000000010
00100000000000000000000000000000000000000700000000000000000000000700000000000000000000000000000000007000000000000000000000000010
00177700077700770007707777000777000000000077000000000000000000007000000000000000000000000000000000007000000000000000000000000010
00777770777770777077707777707777700000000000700000000000000000007000000000000000000000000000000000070000000000000000000000000010
00770770770770777577707707707707700000000000070000000000000000007000000000000000000000000000000000700000000000000000000000000010
00770000770770777777707777l07707700000000000007700000000000000007000000000000000000000000000000000700000000000000000000000000010
00770000770770775757707777l07707700000000000000070000000000000070000000000000000000000000000000007000000000000000000000000000010
0077077077077077070770ssssssssssssssssssssss0000070000000000ccccccccc00000000000000000000000000070000000000000000000000000000010
0077777077777077000770ssssssssssssssssssssss1000007700000ccc000700000ccc00000000000000000000000070000000000000000000000000000010
0017770007770077000770ssssssssssssssssssssss10000000700cc000000700000000cc000000000000000000000700000000000000000000000000000010
0010000000000000000000ssssssssssssssssssssss110000000cc0000000070000000000cc0000000000000000007000000000000000000000000000000010
0010000000000000777700ssssssssssssssssssssss11100000c00700000070000000000000c000000000000000007000000000000000000000000000000010
0010000000000007777770ssssssssssssssssssssss1110000c0000700000700000000000000c00000000000000070000000000000000000000000000000010
0010000000000007700770ssssssssssssssssssssss111000c000000770007000000000000000c0000000000000700000000000000000000000000000000010
0001000000000007700770ssssssssssssssssssssss11100c00000000070070000000000000000c000000000000700000000000000000000000000000000100
0001000000000007700770ssssssssssssssssssssss1110c0000000000077000000000000000000c00000000007000000000000000000000000000000000100
0001000000000007700770ssssssssssssssssssssss111c000000000000077000000000000000000c0000000070000000000000000000000000000000000100
0001000000000007700770ssssssssssssssssssssss111c000000000000070700000000000000000c0000000070000000000000000000000000000000000100
0001000000000007700770ssssssssssssssssssssss11100000000000000700708880000000000000c000000700000000000000000000000000000000000100
0001000000000007700770ssssssssss7sssssssssss11100000000000000222222208000000000000c000007000000000000000000000000000000000000100
0000100000000007700770sssssssss7777sssssssss111000000000000220000807220000000000000c00007000000000000000000000000000000000001000
0000100000000007777770ssssssss777777ssssssss111000000000022070000800082200000000000c00070000000000000000000000000000000000001000
0000100000000000777700ssssss777777777sssssss111000000000200070000088800020000000000c00700000000000000000000000000000000000001000
7000100000000000000000sssss777777777777sssss1110000000020000700000000000020000000000c0700000000000000000000000000000000000001000
0777710000000000000000ssss77777777777777ssss1110000000200007000000000000002000000000c7000000000000000000000000000000000000010000
0000017770000000000000ss777777777777777777ss111000000020000700888lll0000002000000000c0000000000000000000000000000000000000010000
0000010007777000000000ssssssssssssssssssssss11100000020000078800lllll000000200000000c0000000000000000000000000000000000000010000
0000001000000777700000ssssssssssssssssssssss1110000002000008000lllllll00000200000007c0000000000000000000000000000000000000100000
000000100000000007770000111111111111111111111110088820000080000lllllll87770020000070c0000000000000000000000000000000000000100000
000000100000000000007777000011111111111111111110800020000800000lllllll08007727700070c0000000000000000000000000000000000000100000
00000001000000000000000077770000000000000000c0008070200008000000lllll008000020077777c0000000000000000000000000000000000001000000
00000001000000000000000000007777000000000000c00087002000800000000lll0000800020007000c7777000000000000000000000000000000001000000
000000001000000000000000000000007777000000000c0008882000800000000000000080002000700c00000777770000000000000000000000000010000000
000000001000000000000000000000000000777000000c0070002000800000000000000080002007000c00000000007777700000000000000000000010000000
000000000100000000000000000000000000000777700c0700002000800000000000000080002880000c00000000000000077777000000000000000100000000
0000000001000000000000000000000000000000000777c00000020080000000000000008002007800c000000000000000000000777770000000000100000000
0000000000100000000000000000000000000000000000c77770020008000000000000080002070800c000000000000000000000000007777700001000000000
00000000001000000000000000000000000000000000070c000777200800000000000008002800080c0000000000000000000000000000000077771000000000
00000000000100000000000000000000000000000000700c000000277080000000000080002088800c0000000000000000000000000000000000010777770000
000000000000100000000000000000000000000000070000c0000002000800000000080002000000c00000000000000000000000000000000000100000007777
0000000000001000000000000000000000000000000700000c00000020008800000880002000000c000000000000000000000000000000000000100000000000
00000000000001000000000000000000000000000070000000c000000220008888807022000000c0000000000000000000000000000000000001000000000000
000000000000001000000000000000000000000007000000000c0000001111111111111000000c00000000000000000000000000000000000010000000000000
0000000000000010000000000000000000000000070000000000c00011111111111111110000c000000000000000000000000000000000000010000000000000
00000000000000010000000000000000000000007000000000000cc1111111111111111111cc0000000000000000000000000000000000000100000000000000
00000000000000001000000000000000000000070000000000000111111111111111111111100000000000000000000000000000000000001000000000000000
00000000000000000100000000000000000000700000000000001111111111111111111111111000000000000000000000000000000000010000000000000000
00000000000000000100000000000000000000700000000000111111111111111111111111111100000000000000000000000000000000010000000000000000
00000000000000000010000000000000000007000000000001111111111111111111111111111111000000000000000000000000000000100000000000000000
00000000000000000001000000000000000070000000000111111111111111111111111111111111100000000000000000000000000001000000000000000000
00000000000000000000100000000000000070000000001111111111111111117111111111111111111000000000000000000000000010000000000000000000
00000000000000000000010000000000000700000000111111111111111111117111111111111111111100000000000000000000000100000000000000000000
00000000000000000000001000000000007000000001111111111111111111777711111111111111111111000000000000000000001000000000000000000000
00000000000000000000000110000000070000000111111111111111111111777711111111111111111111100000000000000000110000000000000000000000
00000000000000000000000001000000070000001111111111111111111111777711111111111111111111111000000000000001000000000000000000000000
00000000000000000000000000100000700000111111111111111111111111777711111111111111111111111100000000000010000000000000000000000000
00000000000000000000000000011007000001111111111111111111111111777711111111111111111111111111000000001100000000000000000000000000
00000000000000000000000000000170000111111111111111111111111111777711111111111111111111111111100000010000000000000000000000000000
00000000000000000000000000000011001111111111111111111111111111777711111111111111111111111111111001100000000000000000000000000000
00000000000000000000000000000700111111111111111111111111111111777711111111111111111111111111111110000000000000000000000000000000
00000000000000000000000000007001111111111111111111111111111111777711111111111111111111111111111111000000000000000000000000000000
0000000000000000000000000000711111111111111111111111111111111177s711111111111111111111111111111111100000000000000000000000000000
0000000000000000000000000007111111111111111111111111111111111177s771111111111111111111111111111111111000000000000000000000000000
0000000000000000000000000011111111111111111111111111111111111ssssss1111111111111111111111111111111111100000000000000000000000000
0000000000000000000000000111111111111111111111111111111111111ssssss1111111111111111111111111111111111111000000000000000000000000
0000000000000000000000011111111111111111111111111111111111111ssssss1111111111111111111111111111111111111100000000000000000000000
0000000000000000000000111111111111111111111111111111111111111sss7ss1111111111111111111111111111111111111111000000000000000000000
0000000000000000000011111111111111111111111111111111111111111ss777s1111111111111111111111111111111111111111100000000000000000000
0000000000000000000111111111111111111111111111111111111111111s777771111111111111111111111111111111111111111111000000000000000000
00000000000000000111111111111111111111111111111111111111111117777777111111111111111111111111111111111111111111100000000000000000
0000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh77777777hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000
0000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh777777hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000
0000000000000000000070hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh7777hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000
0000000000000000000700000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh77hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000000
0000000000000000007000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh770000000000000000000000000
0000000000000000070000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000007000000000000000000000000
0000000000000000070000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000770000000000000000000000
0000000000000000700000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000007000000000000000000000
0000000000000007000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000770000000000000000000
0000000000000007000000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000007000000000000000000
0000000000000070000000000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000000000770000000000000000
0000000000000700000000000000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000000000000007000000000000000
0000000000007000000000000000000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000000000000000000770000000000000
0000000000007000000000000000000000000000000000000000000hhhhhhhhhhhhhhhhhhh000000000000000000000000000000000000000007700000000000
0000000000070000000000000000000000000000000000000000000000hhhhhhhhhhhhh000000000000000000000000000000000000000000000070000000000
0000000000700000000000000000000000000000000000000000000000700hhhhhhh000000000000000000000000000000000000000000000000007700000000
0000000000700000000000000000000000000000000000000000000007000000h000000000000000000000000000000000000000000000000000000070000000
00000000070000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000007700000
00000000700000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000070000
00000007000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000007700
00000007000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000070
00000070000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000007
00000700000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000
00007000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000
00007000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000
00070000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000
00700000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000
00700000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000
07000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000

__map__
baacbee8843be3faebbabbea80b6050410741404111280010c28fcaebf2b2abaeaeeab046018ea7001a9a29c8075ae0102ba87407010701106022c9d0aeebfafabeabaeabbe02815611a0600052d05aa009ae3bb7acaa0bac401681620750a8feec0caeceb12b20811189c66c4aa82ab851b1a90827a03050b00071fe2c8acb2
8b046c07affabb2a80051465010105210a00c437a2eeaff00230a385a8127116aad2083c2ec2aecafb2abab480107490716a8e8140010798342bacbb2f23afc00aebacb108710170616801018c6a2b32fabacbae8ba80becc2860878780560152818013306a27ac1aacdbae0eeec8c03223a6805040119131461124000b9c180
b06ecbbafee2b0029aa2b204147ac074620261aa948c680acb2f1835a00af2c6fcbecab0b80b01821ad41470111481aba2b1babc2b04aba2a8c0702e3b62e3ec21bb12c1020194d8a48c7262128461a21d82faebfaaeab8ae2cb6a2f5b04402885005ba86140aac036ef8aebabc8006b629bdb8864b015012a0840616eeaaabf
b82bbeaf2caaeabc610509009415006101aaeb1bb8a001abfbafabb22bac84212af91185a0116a08b8dabab40a2404782a8bc6bf28a38db0f8a76bb106882a763b86e2b08318ad26a0ea3114c1a41811068a6a13b2a033fefaeeabaaeeac620b629ac1690464057862806006a8e3feabeeebeb00a0801118021301616a825e0c
6908846dae84666b8ba8bbaf6aaec6aa0b00147484068823ffbbabaeeb22826c2104947860714040600b2c7abbab0bbbbabbbacaa20866050102701411010400b2faaeeeaea080001acaa82119040168aeebbbabb2ae8eaab00101190411040128abaeaeaaebaebabaaaa028041004104040680008abaeaebaeebabaab880004
10611061101010002aebaeeaeebabaaaaaaaaa0040040040010000000000aaaaabaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa87777757fdd75f5deefbd7204c62ef1b87a8ba6bc1b86ad0a88087ac63c02ed8eb52e1821228784a3eaecaac6a96a1a21025ec2eb06a46f041aca0b30eb2d8a8b240974
14806a3cafb0ba00a62a946931106e1213a89fcaf2eaeae2940510711ac001afaaf300072810848aebb2398b71680164abbaeb036a22e4eab028329a1e1f0065106ae21e6bc49a862aaf66abbbce0ab2e80414628b87b3407acaa2691814688a27bb2fb3ac4000817186baabfbbaaafaeac064646126811411000000370ffbba
baeaafa1aaf061006ab47440b04010102ec82eb6eea0400e8520bbfab26181beea8c23816464a1781002a8f86efbafaec09a40841406856ca0bab81c0bcaf0062f68849118118122eebfa2f220af8aea8471251864184010406babaf2febacbbbaaae0051a04216114118014a2beafab2a00aaba17efbc82aae8801561742104
40040022fffecb2b0bbab02a61617111104004aacbafb2eababc06a0283b01cb0461681bac019a2aa97206baf8ec051b07a1806ac8a3ee2faba011716101002bfbafabbbac826840711104046a00bbeafac2aa08ab0ad5810c6e841620406ee2fbba2ae26c2e8166a3ba119eaaaca22e11711011407101a2c42eebbebac2b82e
efb8baa80ae430666e85146510640401aaaebbaefab2bbabac8bac22acaaa04079156170104061c02bbaeabbaeca002611850410007028780afeffbbab81a1827062b880c82092aadd8c7240117071042d40bbabebee0a2a98a4614002caeefa07220208f522951a2c40706480962a0abfbb0063afbeeebebae2c0a404646498
1411010005028b6b2b22bbbeabefaeebeeaeacaa0589407110111010400106a3a2b7bb2bebbbae8ab00ea0c1c009916510646804a0041eaff0bcaecaaeaa85047070640102aba833caeb32a2efae2eec2e3ac074407401043a8cbb82601164a040b2befbace1b06400046a2e2eb82eb6ec19c588102eae2bb602b060130b6210
e9899ba2e500896b1ac0030b3bba378436009388fd3a0863c0cba871046518614004ac088bfbbbaae9cab2a89a61372eaa0c82c79b6c4066826b6186aa20126eaafbfa2f07c6ea02820ad6859406181aa9c80f8faeeebaf8ba2f1201a81571106104010004b73bbbaeebab8a0a800411646460009ab1c08482c89c326b04a568
10aa852e0edaefb3b0baaeaf02c6ec720a14046464101a82aa3ffb2a388108c07ac2ec688d61802676b0ac1b2bab80a8f266712969171208c4b8aebabb0ac0092b6b1c01010469680620bfacbae00cf1022271d009812d8207aaa31c0701873afa30a261118c0aac1a94161b0d7880ab37121eb66abbaa2c0baaebb368046865
05040006b2b2ec082fa2c2fc70a9aca73acaeacab2882561761180700061cc1abafb2acae82c06c0b1678019a012eb6a008f67006b0491ca8a04798f08b30ba8c6c486aaae71118626b8e36f26b82b0862081bb8ac1b9b2b78c7062284ab0102b5831005a85ca2bd08f2b0bb3c60c6b8b620406669880abe6bac80c3a6301868
7898d701203630c0ade2f862aaf92e38a2601495306a046a2e32adec0891371b01c1ae2281289b1ab20e6b1a3ea3a33c12918768020486718087a83071ca0210bcbecab04011621881b9ac6e1bab8bc068885e2eaf6402daa42807119226c6daabeeaa802da093c2c3c893400aab1af62d906a0696c42c6b8a9b92e000983f10
0aabe6ba9b8782c2c1bb110e1ea1b1ae40c1010104a6c6a82f8632a3a6fc1a2ba8ad0386c5bc00609e02021068000a6a21b004ad029f0280a2ac8881ba00407aa86ba0aeaeab8ae22c1a88006ac180ac400000060001a8a0020028aa8aabaaaaaeaaaa2aaaaa8a80a00000000000000000000040a0a000208aaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa7d77f577f5dfdd6f5dbd2887d786c006a2d7c48086e0a6eaaf6ea8b0a1e1a2a4e5ac6c210a5b9b0212e5e1e002821b9b9ba9bc682c6ac0a0d2d2c6c0212c6a8aaa2e6c6c6b96c6ab6e6e086c68a8a3d31b1aa8aac6c7d78087828001b1b1e4e086c06c6c6c0006d29b
8202a128a5f4b1aabd6e086e0280c4a2ab6e6e6f6282d6e00316e1b92e1b92e12c0084b06a0b93c4aa02a82e5f1a8396f17a00a0a1b12e90f16e6b80086a1ea4b93c6aaa80a4bd0e00b1a0e5b0a17f5b86e006e12c6aaa2f6b12aa2b84f5b0006e5b2c6aa1e0a4ba6f012c6aa1baaa386b8316e5bc012c62c42a82e10e96be62
aa0ab06f13131282c5f90aa86f96ea80a8c4ac10b12c042b14bc68aaa2c394f5ae806f5ba0a0b121b93c6a2e62a06e80206f5ba00e5ba82c62c4e796e0a8b1b86ad2ab1b021b84a0aa1afc40316e1392c012ea12e4e1ae02016f1a2a7e62c6aaa2e217800e6e6b5b800c017e16e86e1aba1ba80085f122a8385ba2c68b0a5f6b
12ac06b12ae1b12ae5b8aaae13a5ba02c0021b92e52f12aa7c10b131a0b06b978083128b005b8a80a53e013d6e1ae4b0008a1f121a803d6ea0b68b96c02c6c6a0a1bab86e4a80a0f97c4c4aac05b085e8b28786820e5f1a2c6aa8b831286b86ea5b8b1aa838486ee1aac086f6a096eaa8fa86e5f40286e1ba0a1229bc4af16ae
02ac5ba1b0809312e1b06e086e6ab16eaa3c5e00602c6bc42a86c693c0a92a0b5baac1286e0f72b812e6e286b1b86ab86e0aa00417a0aea00100053b97e6c6c06ae1b9aae01ba1386cb5b0a086c6ab1e0a1b92d2a0c4b0a4f121b1a8ae0b6a0a6af97a086e6e6e8081ab21b86e1b80c5f1028683d6e002d08b6a6e6e6e282aa4
ea17c6c6c4e1a2e4b06b01b86ab06e001aa1bd2a3902e4ab12c210e1e012c6c68b9b6e6b0004b1a07f75fd775fd7dfdd13c5a3c5b084e4b86a3c5b84a0a1ae0e1bc1be1ba00aa392c5b928786aa4b92c00102d6e5eaa8b0780b5f12ab12c6b1b86ac008012e1ae6b1b800a9392c4a0e180e92a786c6c6b6e5b82c4b06b06a0c4
b1386b81b8786c6c1b001a8b1386a2e4b084aae4b800286abd6e085f6a9ba08a6f96e4b86c00b12ab12e5ba86f12e12e12e10aa02a13c5b86ba13a12e012e86b0020e16fd4b81ae1ac0a806b84b16be17a0a8b86a0b16b05bc5e80aaac408a86e10e885ee13a086f95fa5bc4a8aa0bd6e86e0001b96eaa2a2e6c00122e138b12
d285b86eaac4be72f0402840ed1ba01bc40aa92f1003d4ac0012e1a82e94f86a2f94ba285bc1aaab2203c52e14ba843e102b001284c4a805bc6b0e14be5b82c4b16e82aa028b16f16e802ac47c6b1282e10a2a0bd0e1b85b84ba10aeaa0aafa876f5ae84baa0293e6e73a0286a0f96e086fa73b12a80a0bc613b1282d0a2e5be
16ea62c4a0e813e10b8873c41ac1b0280e04ac639286e1ba012c62af14be16e1b80a021b84aba5f06a2a0abf72c682d0a0b13c212c6c7280b0e92e90bd6f128284e005bc6aa2b86b000a5f1287b10b06c0253a1ba02c6b1016c2c6b0a12e90e02c72e420e1bc6a386a1b8a1b84e010b138016c0a1aba1baad4f0682c6b1203a1
bb112e0016f01ac42ba12c6a80040f86c6e0e168b96e0312bb14ba029384e1b1b008042c7af06b001284ba1ba1e80015f000a1b8b870a2a5bf62e012c102c16b84b0287c686e001a08aa82abcb85f97c6a93e5ba0a80f52c0212aa6f1b92f16c1aaaab82aba4b4f1086a080f042e5ea1ae1b86e12e12b801bc72e0212c2ab12a
35bc5baa86e80284ea009bd5f90a2ba6e8013c5b80012e62a02ec5b801283c5f129bc480b1aaf16e0004b85bc42aa00ac12e102f7aaf12aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
312800001705500005100550000510055000051005500005110550000510055000051005500005100550000511055000051005500005100550000510055000051105500005100550000510055000051005500005
312800001005500000100000000010000000001000000000100550000010000000001000000000100000000010055000001000000000100550000510000000001005500005100550000510055000051005500005
19011820050503805032050280502c0501f05023050180502005019050200501c05025050230502e0502b050330502e050310502a0502c050270502b050270502a05026050290502405028050230502705024050
cd040800135301255011540105300e5300d5200c51001500015000150001500015000150001500015000150001500015000150001500015000150001500015000150001500015000150001500015000150001500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d04000007a5007a5013a5013a5013a5013a4013a3013a3013a2013a2013a1013a1013a1013a1013a1001a0001a0001a0001a0001a0001a0001a0001a0001a0001a0001a0001a0001a0001a0001a0001a0001a00
ad0808002f65405652050520504205042050320502205012050020500205002050020500205002050020500205002050020500205002000020000200002000020000200002000020000200002000020000200002
__music__
00 01424344
03 00424344

