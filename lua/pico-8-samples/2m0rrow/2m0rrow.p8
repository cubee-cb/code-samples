pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
--tomorrow's vege-mallet therapy
--(in 20S or less) - by cubee 🐱
-- tomorrow go quick
-- vegemallet chronicle

usetimer=true
--skipcountin=true
allowtimerpickups=true
--pathtest=true
--showhitbox=true
gamemusic=0

poke(0x5f2e,1)
poke(0x5f5c,-1)
poke(0x5f36,0x10) -- oobounds value overrides

menuitem(5,"hitboxes",function()showhitbox=not showhitbox end)

--[[ notes

story:
krikz the robot did something
that really annoyed tomorrow.
she can't get it off her mind,
and thinking about it makes her
even angrier every second.

tomorrow decides that the only
way to blow off some steam is to
go and give krikz a good whack
on the head with a mallet she
made from an oversized jar of
vegemite.

alternatively:
tomorrow has been tasked to
destroy a machine going corrupt.
krikz, the robot.
she must move quickly to find
and destroy it before the
security system finds her.


notes:
rotsprs are at 58,58 and 122,58
add 1-tile sliding?

add difficulties:
- easier - extra timer pickups
- strict - removes timer pickups

timer effects:
- rolling slot-style number changing
- tick tock; faster with less time


issues:


theming:
- overpowered:
   the movement is insane
   the mallet is insane
   asu is insane
   yeah
- people are strange:
   what's more strange than
   turning an oversized jar of
   vegemite into a mallet and
   using it to fling yourself
   across the continent?
- musical fruit:
   i got nothing


hardcore speed-platformer

mechanics:
- wall jump
- hammer whack
- (air) hammer spin + bounce
- down to fall faster

move fast,
die fast,
repeat

enemies die in one hit


firsts:
- 16px platformer character
- dynamic squash and stretch
- amy rose hammer
- non-if-based game states

]]
index={__index=_ENV}
g=_ENV

function _init()

 gamestates={
  title={_updatetitle,_drawtitle},
  game={_updategame,_drawgame},
  over={_updateover,_drawovertime},
  win={_updatewin,_drawwin},
  dead={_updateover,_drawdead},
  notes={_updatenotes,_drawnotes},
 }
 mode="title"
 lastmode=false

 -- init variables
 t=0
 timelimit=20
 timer=timelimit
 
 -- game variables
 mapw=128
 maph=48
 cx,cy=0,0
 cxt,cyt=0,0
 clook=0
 clookt=0
 sandwiches=0
 sandwiches_total=0
 timers=0
 zoom=1
 camzoom=1
 shakex=0
 shakey=0
 starttime=0

 gm_pickups="lenient (timer pickups)"
 gm_normal="normal (20 seconds)"
 gm_unlimited="explore (unlimited time)"
 gamemode=1
 gamemodes={gm_pickups,gm_normal,gm_unlimited}
 modescroll=1

 oi=0
 oi_message="oi"
 tick=false

 fadet=0

 notes={
  "- for 2023's 20 second jam -",
  "- by cubee -",
  "",
  "tomorrow is mad at krikz the",
  "robot. she must find him and",
  "whack him on the head before",
  "the rage consumes her.",
  "",
  "-- tips --",
  "bounce with the mallet to",
  "quickly build up speed.",
  "",
  "hold down to fall faster.",
  "",
  "collect sandwiches to regain",
  "health points.",
  "",
  "look for environment cues to",
  "help position your actions.",
  "",
  "-- trivia --",
  "the term vege-mallet is a",
  "combination of \"vegemite\" and",
  "\"mallet\". vegemite is an",
  "australian spread, which has",
  "a very divisive, salty flavour.",
  "",
  "the mallet's mechanics are an",
  "evolution of amy rose's hammer",
  "from a sonic fangame idea i had",
  "many years ago",
 }

 -- common stats
 grv=0.15

 -- hitbox debug visuals
 hitbox={}

 enemies_visible={}
 objects_visible={}
 pickups_visible={}

 -- start game
 --mode="game"

 fade()
 music(16,1000)

 --mode="win"
end

function _update60()

 gamestates[mode][1]()
end

function _draw()
 pal()
 if mode==lastmode then
	 --pal(9,11,1)
	 pal(11,128+15,1)
	 --pal(13,128+13,1)
	 pal(12,11+128,1)
	 pal(1,1+128,1)

  gamestates[mode][2]()
  firstframe=false

 else
  cls(0)
  t=0
  lastmode=mode
  firstframe=true

 end

 if fadet>0 then
  fadet-=1
  
  camera()
  local i=32-fadet
  --rectfill(0,0+i*i,128,128,0)
  fadevege(i/32,-1)

 end
end

-->8
-- update

function _updategame()

 local unlock_gameplay=countin<60

 hitbox={}
 poke(0x5f5a,1)
 
 if unlock_gameplay then

	 if(btn(4,1))add(enemies,create_enemy(1,cx+64,cy+32))
	
	 -- update timer
	 if usetimer then
 	 -- end the game if the timer expires
		 if timer>timelimit then
		  --mode="over"
		  
		  -- give everyone a friendliness pellet
		  for p in all(players) do
		   p:damage(999,false,true)
		  end
		  
		  usetimer=false
		 end
	
		 timer=time()-starttime
		end
	
	 enemies_visible=get_on_screen(enemies)
	 objects_visible=get_on_screen(objects)
	 pickups_visible=get_on_screen(pickups)

	 local upd=function(i)i:update()end
	 foreach(enemies_visible,upd)
	 foreach(players,upd)
	 foreach(objects_visible,upd)
	 foreach(pickups_visible,upd)
	 foreach(particles,particle_update)

 end

 -- move camera
 if(abs(clook-clookt)>8)clook+=sgn(clookt-clook)/2
 cxt=mid(0,cxt,mapw*8-128)
 cyt=mid(0,cyt,maph*8-128)

 cx+=(cxt-cx)/10
 cx=cxt
 cy+=(cyt-cy)/10

 cx=mid(0,cx,mapw*8-128)
 cy=mid(0,cy,maph*8-128)

 -- run game timers
 if unlock_gameplay then
	 t=max(t+1)
	 shakex=max(shakex-1)
	 shakey=max(shakey-1)
  oi=max(oi-1)

 -- handle the count-in
	else
  starttime=time()

	 if countin==60 then
	  sfx(49)
	 elseif countin%60==0 then
	  sfx(50)
	 end

 end

 countin=max(countin-1)
end

function _updatetitle()

 if(btnp(0))sfx(46)gamemode-=1
 if(btnp(1))sfx(46)gamemode+=1
 gamemode%=#gamemodes

 modescroll+=(gamemode-modescroll)/5

 -- apply timer mode effects
 local gm=gamemodes[gamemode+1]
 if gm==gm_pickups then
  timerallowed=true
  skipcountin=false
  allowtimerpickups=true
  gamemusic=32

 elseif gm==gm_normal then
  timerallowed=true
  skipcountin=false
  allowtimerpickups=false
  gamemusic=0

 elseif gm==gm_unlimited then
  timerallowed=false
  skipcountin=true
  allowtimerpickups=false
  gamemusic=32

 end

 -- start game
 if btnp(4) then
  sfx(45)
  usetimer=timerallowed

  fade()

  start_game()
 elseif btnp(5) then
  sfx(46)
  fade()
  mode="notes"
  notesy=0
 end

end

function _updatewin()
 if(firstframe)sfx(48)

 t=max(t+1)
 if(btnp(4) or btnp(5))sfx(46)fade()run()
end

function _updateover()
 if(firstframe)sfx(47)

 t=max(t+1)
 if(btnp(4) or btnp(5))sfx(46)fade()run()
end

function _updatenotes()

 local s=2
 if(btn(2))notesy-=s
 if(btn(3))notesy+=s

 t=max(t+1)
 if(btnp(4) or btnp(5))sfx(46)fade()mode="title"
end

-->8
-- draw

function _drawgame()
 poke(0x5f5a,0)
 cls()
 pal(0)

 if(btnp(3,1))shakey=20
 if(btnp(2,1))shakey=10

 palt(0,false)
 palt(11,true)

 -- parallax
 camera(mid(0,cx+clook,mapw*8-128)/2%128,(cy)/2%128)

 for ix=0,1 do
  for iy=0,3 do
   map(48,56,ix*128,iy*64,16,8)
  end
 end

 -- level
 local sx=cos(shakex/6)*shakex/4
 local sy=sin(shakey/6)*shakey/4
 camera(mid(0,cx+clook+sx,mapw*8-128),cy+sy)

 map()

 palt(11,false)
 palt(12,true)
 local drw=function(i)i:draw()end
 foreach(enemies_visible,drw)
 foreach(players,drw)
 foreach(objects_visible,drw)
 foreach(pickups_visible,drw)
 foreach(particles,particle_draw)

 -- show hitboxes
 if showhitbox then
		for i in all(hitbox) do
		 local tx,ty,hx,hy,w,h=unpack(i)

		 local m1=true
		 -- these look nicer
		 if m1 then
	 	 rect(hx-w/2,hy-h/2,hx+w/2,hy+h/2,8)
	 	 rect(tx-w/2,ty-h/2,tx+w/2,ty+h/2,7)

   -- these are the actual boxes
		 else
 		 rect(hx-w,hy-h,hx+w,hy+h,8)
 		 pset(tx,ty,7)
		 end
		end
 end

 --[[ camera alignment dot
 circ(64+cxt+clookt,64+cyt,1,8)
 camera()
 pset(64,64,7)
 --]]

 camera()

 -- zoom in
 camzoom+=(zoom-camzoom)/10
 if camzoom>1 or true then
  pal(0)
  palt(0,false)
  local o=flr(128-128*camzoom)
  local w=ceil(128*camzoom)
  poke(0x5f54,0x60)
  sspr(0,0,128,128,o,o,w,w)
  poke(0x5f54,0)
 end

 zoom=1

 -- time limit
 local c1,c2,c3=
 usetimer and 7 or 13,
 usetimer and 13 or 5,
 usetimer and 5 or 1
 bprint("\^w\^t"..(timelimit-timer\1),2,2,c1,c2,c3)
--[[
 for k,i in pairs{players,enemies,objects,pickups,particles} do
  print(#i,1,8+k*8,7)
 end
]]
 foreach(players,player_draw_hud)

 -- count in timer
 if countin>0 then
  palt(12,false)
  palt(15,true)
  countdown=split"go!,1,2,3"
  for k,i in pairs(countdown) do
  end

  local c=countin-30

  local a=c%60/120
  local idx=2+(c-30)\60
  local t=countdown[idx]
  --print(tostr(t).." "..countin,64,64+sin(a)/cos(a),7)
  spr(102+idx*2,64-8,64-8+sin(a)/cos(a),2,2)
 end

 -- yell at player for leaving
 if(oi>0)cprint("oi! we ain't done yet!",64,60)
end

function _drawtitle()
 cls(1)

 -- hammer
 palt(12,true)
 rotspr(64,68,time()/4,127,63,2.5,false,2)


 cprint("❎ notes ❎",64,2)
 
 cprint("\^w\^ttomorrow's",64,16,14,2,12)
 cprint("vege-mallet therapy",64,30,10,4,2)
 cprint("(in 20 seconds or less)",64,39,7)


 cprint("press 🅾️ to start",64,96.5-abs(sin(time()/2)*4))

 -- game mode selection
 cprint("time limit mode",64,112)
 for k,i in pairs(gamemodes) do
  cprint(i,-64+128*(k-modescroll),120)
 end
 
 -- mode arrows
 if(gamemode>0)bprint("⬅️",2,112)
 if(gamemode<#gamemodes-1)bprint("➡️",119,112)

 pal(12,2+128,1)

 --fadevege(time()%1)
end

function _drawnotes()
 cls(1)

 local th=0
 local h=9
 th=#notes*h

 local top=th-64
 notesy=mid(8,notesy,top)
 
 for k,i in pairs(notes) do
  local f=print
  local x=2
  if(i[1]=="-")x=64 f=cprint
  f(i,x,12+k*h-notesy,7,1,1)
 end

 if(notesy>8)bprint("⬆️",119,12)
 if(notesy<top)bprint("⬇️",119,120)

 rectfill(0,0,127,10,0)
 rectfill(0,0,127,9,1)
 cprint("❎ title ❎",64,2)

 pal(1,5+128,1)
end

function _drawwin()

 cls(1)

 local t=time()/2
 
 camera(-64,0)

 for i=0,127 do
  local x1,x2=
   cos(t/4+i/200)*32-32,
   sin(t/3+i/200)*32+32
 
  local a1,a2=
   x1*sin(t/10+i/200),
   x2*cos(t/50+i/100)
  line(a1,i,a2,i,2)
  line(a1,i,(a1+a2)/2,i,14)

  local l=min(a1,a2)
  local r=max(a1,a2)
  --line(l,i,(l+l+l+l+r)/5,i,7)
  --line(r,i,(r+r+r+r+l)/5,i,2)
 end

 camera()

 cprint("\^w\^tyou win",64,16,7)
 cprint("i feel much better now!",64,30,7)

 --cprint("\^w\^t"..(timelimit-timer),64,80,7)
 if(timerallowed)cprint("\^w\^t"..(timer).."\^-w\^-t\|l\-iseconds",64,56,7)

 cprint(sandwiches.."/"..sandwiches_total.." sandwiches",64,102)
 if(allowtimerpickups)cprint("used "..timers.." timers",64,112)

 palt(0,false)
 palt(12,true)
 
 local function sprites(xo,yo)
  spr(44,40+xo,78+yo,2,2)
  spr(46,72+xo,72+yo,2,2)
 end

 for i=0,15 do
  pal(i,1)
 end
 for ix=-1,1 do
  for iy=-1,1 do
   sprites(ix,iy)
  end
 end

 for i=0,15 do
  pal(i,i)
 end
 sprites(0,0)
end

function _drawovertime()

 local time=time()

 cls(1)
 local tm=1-2*min((1-(time-0.5)%1),0.5)
 local x=sin(t/10)*(1-(tm==0 and 1 or tm))*2

 -- tick tock that's the sound of the clock
 if tm==0 then
  tick=true
 else
  if tick then
   sfx(rnd()<.5 and 43 or 42)
   tick=false
  end
 end

 --?tm,1,1,7

 camera(-x,0)

 -- clock bezel
 for y=0,1 do
  for i=-2,2 do
   circfill(64+i,65-y,49,y*2)
   circfill(64,65+i-y,49,y*2)
  end
 end
 circfill(64,64,49,4)

 -- body
 circfill(64,64,48,14)
 
 circ(64,64,2,1)

 -- hour lines
 for i=0,1,1/12 do
  local x,y=cos(i),sin(i)
  line(64+x*47,64+y*47,64+x*44,64+y*44,5)
 end
 
 -- hands
 local hs=(-time)\1/60+0.25
 local hm=(-time/60)\1/60+0.25
 local hh=(-time/60/60)\1/12+0.25
 line(64,64,64+cos(hs)*40,64+sin(hs)*40,8)
 line(64,64,64+cos(hm)*36,64+sin(hm)*36,1)
 line(64,64,64+cos(hh)*24,64+sin(hh)*24,1)

 camera(-x/2,0)

 cprint("\^w\^ttime over",64,48,7)
 cprint("the rage was overpowering...",64,64,7)
 
 camera()

 pal(1,128,1)
 pal(4,4+128,1)
 pal(2,2+128,1)
 pal(8,8+128,1)
 pal(14,6+128,1)
end

function _drawdead()

 cls(2)

 for x=0,1,1/4 do
  for i=0,1,1/4 do
	  local t=time()/5
   circfill(x*128+sin(t/2+i/3)*cos(t/10+i)*32,i*128+sin(t/10+x)*100,8+sin(t/4+x+i)*6,2)
   circ(x*128+sin(t/2+i/3)*cos(t/10+i)*32,i*128+sin(t/10+x)*100,8+sin(t/4+x+i)*6,1)
  end
 end

 camera(-64,-64)

 for a=0,1,1/4 do
	 for i=0,1,1/32 do
	  local t=time()/5
	  local x=cos(a)*64
	  local y=sin(a)*64
	  circfill(x+cos(a+i+t/20)*32,y+sin(a+i/2+t/10)*64,16+cos(t+i)*12,8)
	 end
 end

 camera()

 cprint("\^w\^tyou died",64,48,7)
 cprint("tomorrow is dead now",64,64,7)
end

-->8
-- methods

function nop()end

function fade()
 _set_fps(60)
 for i=0,32 do
  --rectfill(0,0,128,i*i,0)
  fadevege(1-i/32,1)
  flip()
 end

 fadet=32
end

function fadevege(t,d)

 local width1x=5*8
 local fullscale=128/width1x

 m=2+t
 local w=width1x/2*t*fullscale*m
 local s=t*fullscale*m

 palt(0,false) 
 palt(11,true)
 pal(1,0)

 rotspr(64,64,t*(d or 1),116.5-0.0625,60-0.0625,5,false,s)

 -- l+r
 rectfill(-1,-1,64-w,128,0)
 rectfill(128,-1,64+w,128,0)

 -- u+d
 rectfill(-1,-1,128,64-w,0)
 rectfill(-1,128,128,64+w,0)


end

function start_game()
 if(usetimer)music(-1,1000)
 -- create object arrays
 players={}
 enemies={}
 objects={}
 pickups={}
 particles={}

 -- find spawn point
 -- and spawn objects
 sp_x=0
 sp_y=0
 for ix=0,mapw do
  for iy=0,maph do
   local t=mget(ix,iy)
   if t==192 then
    sp_x=ix
    sp_y=iy
    mset(ix,iy,0)

   -- spawn enemies
   elseif fget(t,7) then
    local id=0
    local mappings={
     [64]=1,
     [68]=2,
     [76]=3
    }

    local e=create_enemy(mappings[t] or 0,ix*8+4,iy*8)
    add(enemies,e)

    mset(ix,iy,0)

   -- spawn pickups
   elseif fget(t,6) then
    local mappings={
     [96]=8,
     [100]=10,
     [110]=15,
    }
    
    local place=true
    if(t==100 and not allowtimerpickups)place=false

    if(t==96)sandwiches_total+=1

    local p=create_pickup(mappings[t] or 0,ix*8+4,iy*8)
    if(place)add(pickups,p)

    mset(ix,iy,0)
   end
  end
 end

 -- create players
 cx,cy=sp_x*8-60,sp_y*8-64
 add(players,create_player(sp_x*8+4,sp_y*8,0))
 --add(players,create_player(sp_x*8+4,sp_y*8,1))
 --add(players,create_player(sp_x*8+4,sp_y*8,2))

 -- spawn testing objects
 for i=0,16 do
  --add(enemies,create_enemy(1,i*32,8))
  --add(enemies,create_enemy(2,i*32,8))
 end

 countin=skipcountin and 0 or 240
 mode="game"
 if(usetimer)music(gamemusic,1000,0b1100)
end

function psfx(i,x,y)
 if(pos_on_screen(x,y))sfx(i)
end

function poof(x,y,a,w,h)
 w=w or 8
 h=h or 2
 for i=1,a or 6 do
  local p=create_particle(x+rnd(w)-w/2,y+rnd(h)-h/2,rnd(2)-1,rnd(2)-1)
  add(particles,p)
 end
end

function get_on_screen(obj)
 on_screen={}
 for _ENV in all(obj) do
  if pos_on_screen(x,y) then
   add(on_screen,_ENV)
  end
 end
 return on_screen
end

function pos_on_screen(x,y)
 local r=24
 return x>mid(0,cx+clook,mapw*8-128)-r and x<cx+clook+128+r and
        y>cy-r and y<cy+128+r
end

function aabb(x1,y1,x2,y2,w,h)
 if(showhitbox)add(hitbox,{x1,y1,x2,y2,w,h})

 return not
 (
  x1+w<x2 or x1>=x2+w or
  y1+h<y2 or y1>=y2+h
 )
end

function bprint(t,x,y,c1,c2,c3)
 for i=11,0,-1 do
  if i~=4 then
   print(t,x-1+i%3,y-1+i\3,i>8 and (c3 or 5) or c2 or 13)
  end
 end
 print(t,x,y,c1 or 7)
end

function cprint(t,x,y,c1,c2,c3)
 local o=-32000
 local w=print(t,o,o)-o
 bprint(t,x-w/2,y,c1,c2,c3)
end

-- borrowed - roboz
function rotspr(x,y,rot,mx,my,w,flip,scale)
scale=scale or 1
w*=scale*4
if(flip)rot=-rot
local cs,ss=cos(rot)*.125/scale,sin(rot)*.125/scale
local sx,sy,hx,halfw=mx+cs*-w,my+ss*-w,flip and -w or w,-w
for py=y-w,y+w do
tline(x-hx,py,x+hx,py,sx-ss*halfw,sy+cs*halfw,cs,ss)
halfw+=1
end
end
-- borrowed - freds72
function dist(dx,dy)
local maskx,masky=dx>>31,dy>>31
local a0,b0=(dx+maskx)^^maskx,(dy+masky)^^masky
return a0>b0 and a0*0.9609+b0*0.3984 or b0*0.9609+a0*0.3984
end
-->8
-- common object methods

function bounce(_ENV,x,y,addx,addy)
 if(x~=0)xv=addx and (xv+x) or x
 if(y~=0)yv=addy and (yv+y) or y

 jumping=false
 jumps=maxjumps
 coyote=0
 grounded=false
end

function damage(_ENV,amount,knockback,force)
	if force or not iframes or iframes==0 then
		hp=max(hp-amount or 1)

		_ENV:bounce(knockback or flip and 2 or -2, -1.5)

  if hp==0 then
	 	if(diesfx)psfx(diesfx,x,y)

  else
 		if(damagesfx)psfx(damagesfx,x,y)

  end

  if(iframes)iframes=60

  stunframe=true

	 if(damage_callback)_ENV:damage_callback()
 end
end

function collide_x(_ENV)
 local l,r=false,false

 -- right collisions
 for d=0,xv do
  local e=false

  for cyo=-4,4,4 do
	  local cy=y+cyo
	  local cx=x+8+d
	
	  -- has collided?
	  if fget(mget(cx\8,cy\8),0) then
    x=(x+d)\8*8+3
	   xv=0
	   r=true

	   e=true
	   break
	  end
	  
	 end
	 
	 if(e)break
 end

	-- left collisions
 for d=0,xv,-1 do
  local e=false

  for cyo=-4,4,4 do
	  local cy=y+cyo
	  local cx=x-8+d

	  -- has collided?
	  if fget(mget(cx\8,cy\8),0) then
    x=(x+d)\8*8+5
	   xv=0
	   l=true

	   e=true
	   break
	  end
	  
	 end
	 
	 if(e)break
 end

 return l,r
end

function collide_y(_ENV)
 local u,f,spiked=false,false,false

 -- ground collisions
 grounded=false
 if yv>0 then
	 for d=0,yv do
	  local e=false

	  for cxo=-4,4,4 do
		  local cy=y+8+d
		  local cx=x+cxo
		  local tile=mget(cx\8,cy\8)

	   -- death tiles
	   if fget(tile,2) then
	    _ENV:damage(1)
	   end
	   
		  -- solid tiles
		  if fget(tile,0) then
		   if yv>=2 then
		    landsquash=yv*2
		    poof(x,cy)
		    psfx(59,x,y)
		   end

		   grounded=true
     y=(y+d)\8*8
		   yv=0
		   f=true

		   e=true
		   break
		  end

		 end
		 
		 if(e)break
	 end

	-- roof collisions
	elseif yv<0 then
	 
	 for d=0,yv,-1 do
	  local e=false
	
	  for cxo=-4,4,4 do
		  local cy=y-8+d
		  local cx=x+cxo
		
		  -- has collided?
		  if fget(mget(cx\8,cy\8),0) then
     y=(y+d)\8*8+8
		   yv=0
		   u=true

		   e=true
		   break
		  end
		  
		 end
		 
		 if(e)break
	 end
	 
	end

 return u,f,spiked
end

function collide_point(_ENV,x,y,obj_list,hit_callback,w,h)
 out=false
 out_o=false
 for o in all(obj_list) do
  if o.alive~=false and aabb(x,y,o.x,o.y,w or 6,h or 6) then
   if(hit_callback)hit_callback(o,_ENV)
   out=true
   out_o=o
  end
 end
 return out,out_o
end

function squish_velocity(_ENV)
 local squashx=abs(yv)-abs(0)-landsquash
 local squashy=abs(0)-abs(yv)+landsquash

 return 8-squashx/2,16-squashy
end

function collect_pickup(_ENV,p)
 poof(x,y)

 collect_callback(p)
 del(pickups,_ENV)
end

function move_camera(_ENV,unlockcamera)
 local lookahead=40
 g.clookt=xv==0 and 0 or (sgn(xv)*lookahead)

 g.cxt=x-64
 if(unlockcamera)g.cyt=y-64 unlockcamera=false
end
-->8
-- player methods

function create_player(x,y,id)

 local player=setmetatable({
  update=player_update,
  draw=player_draw,
  damage_callback=function()
   g.shakex=15
  end,

 	-- base vars
 	id=id or 0,t=0,wt=0,hp=3,hpmax=3,
  x=x or 0,y=y or 0,
  xv=0,yv=0,
  alive=true,
  attack=0,
  attacktime=0,
  grounded=true,
  wallslide=0,
  wallslidet=0,
  jumps=0,
  maxjumps=1,
	 jumping=false,
  coyote=0,
  movelock=0,
  landsquash=0,
  jumpbuffer=0,
  hamr=20,
  flip=false,
  damagesfx=56,
  diesfx=51,
  iframes=0,
  hammer_available=true,
  
  -- stats
  ac=0.2,
  fc=0.2,
  dc=0.5,
  mx=3,
  
 },index)

 player:move_camera(true)

 return player

end

function player_update(_ENV)
 local unlockcamera=false

 --[[ spring testing
 if(btnp(0,1))_ENV:bounce(-5,0)
 if(btnp(1,1))_ENV:bounce(5,0)
 if(btnp(2,1))_ENV:bounce(0,-5)
 if(btnp(3,1))_ENV:bounce(0,5)
 --]]
 
 -- check if dead
 if not alive then
  xv*=0.95
  yv+=grv
 
  _ENV:collide_x()
  x+=xv

  -- bounce
  do
   local pyv,u,d=yv,_ENV:collide_y()
   if d and pyv>1 then
    yv=-pyv/2
   end
  end
  y+=yv

  if(grounded and diet)diet-=1

  if(diet<=0)fade()g.mode=timer>timelimit and "over" or "dead"
  return
 end

 -- check if near krikz
 do
  _ENV:collide_point(x,y,enemies_visible,
  function(_ENV,o)
   if type==3 and not o.krikz_time_event then
    shock=true
    
    o.krikz_time_event=true

    o.attack=1
    o.attacktime=32
    g.usetimer=false
    
    o.krikz=_ENV
    music(-1,1000)

   end
  end,32,32)
 end

 -- run the krikz-time event
 if krikz_time_event then

  g.zoom=2
  g.clookt=0
  g.cxt+=(x-32-32*zoom-cxt)/10
  g.cyt=y-64-32

  xv*=0.85
  yv*=0.85

  flip=false

  if krikz_time_event==1 then
   attacktime-=.4

   if attacktime>0 then
    

   end

   if flr(attacktime)==0 then
    _ENV:collide_point(x,y,enemies_visible,
    function(_ENV)_ENV:damage(32000) end,
    120,120)
    
    yv=-1
    xv=1
    
    g.shakey=20
   end

   if(attacktime<=-30)fade()g.mode="win"
  else

   xv=(krikz.x-16-x)/10
   if(y<krikz.y-16)yv=(krikz.y-16-y)/10

	  if btnp(5) then
	   krikz_time_event=1
	   attacktime=10
	  end

  end

  _ENV:collide_x()
  x+=xv
  _ENV:collide_y()
  y+=yv

  return
 end

 -- buffer jump key
 if(btnp(4,id))jumpbuffer=10

 -- adjust physics
 local a,d=ac,dc
 if(not grounded)a,d=ac/2,dc/2

 -- move right
 if btn(1,id) and (movelock==0 or wallslide>0) then
  if(xv<mx)xv+=xv<0 and d or a

  if(grounded)flip=false

 -- move left
 elseif btn(0,id) and (movelock==0 or wallslide<0) then
  if(xv>-mx)xv-=xv>0 and d or a

  if(grounded)flip=true

 -- friction
 elseif movelock==0 then
  if abs(xv)<=a then
   xv=0
  else
   xv-=fc*sgn(xv)*(grounded and 1 or 0.2)
  end

 end

 -- wallsliding
 wallslidet=max(wallslidet-1)
	if movelock==0 and wallslidet==0 then
  wallslide=0
 end

 -- start attacks
 if hammer_available and attack==0 and abs(wallslide)~=1 then
	 if btnp(5,id) then
	  wallslidet=0
	  wallslide=0
	  if grounded then
	   sfx(61)
	   attack=1
	   attacktime=10
	  else
	   sfx(62)
	   attack=2
	   attacktime=1

	   if btn(3,id) then
	    --yv=2
	   end

	  end
	 end

 -- attacking
 else
  -- ground attack
  if attack==1 then
   attacktime-=1

   if attacktime==0 then
    local tx=x+(flip and -16 or 16)

    -- damage enemies
	   local hit=_ENV:collide_point(
	    tx,y,
	    enemies_visible,
	    function(_ENV)_ENV:damage(1,0)end,
	    24,16)

    -- bounce
    --yv-=2
    xv+=flip and -1 or 1
	   sfx(60)

    poof(tx,y+8)

    g.shakey=8
   end

  -- air attack
  elseif attack==2 then
   -- end attack when hitting a wall
   if grounded or wallslide~=0 then
    attacktime=0
   end

   -- bounce!!!
   -- 0 is down
   for i=-.5,.5,0.0625 do
    -- position
    local tx,ty=x+cos(i-.25)*hamr,y+sin(i-.25)*hamr

    -- enemy check
    local hit,e=false,false
    if yv>0 then
     hit,e=_ENV:collide_point(tx,ty,enemies_visible,function(_ENV)_ENV:damage(1,0)end)
    else
     hit,e=_ENV:collide_point(x,y,enemies_visible,function(_ENV)_ENV:damage(1,0)end,16,16)
    end

    if hit then
     g.shakey=e.grounded and 12 or 8

	   -- tile check
    else

	    -- only hit tiles below player
	    local tile=yv>0 and abs(i)<=0.2 and mget(tx/8,ty/8) or 0
	    hit=fget(tile,0)

	    -- bounce hammer off spikes
	    if fget(tile,2) then
	     --hammer_available=false
	     sfx(52)
	     poof(tx,ty)
	     attacktime=0
	     _ENV:bounce(flip and 1 or -1,-2)
	     g.shakey=5
	     hit=false
	
	    end
	    
	    if hit then
      g.shakey=15
	    end

    end

    if hit then
     sfx(60)
     _ENV:bounce(flip and -1 or 1,-3,true,false)

     attacktime=0
     poof(tx,ty)
     unlockcamera=true
     attack=0

     -- turn around
     if(btn(0,id))flip=true
     if(btn(1,id))flip=false

     break
    end


	  end -- radius of effect
  end-- air attack

  -- stop attack
  if(attacktime<=0 and attack~=0)attack=-1

 end

 -- collide with enemies
 do
  local hit,e=_ENV:collide_point(x,y,enemies_visible)
	 if hit and e.dealsdamage then
	  _ENV:damage(1,flip and 1 or -1)
	 end
 end

 -- collect pickups
 do
  _ENV:collide_point(x,y,pickups_visible,collect_pickup,12,12)
 end

 -- reset jumps
 if grounded then
  jumps=maxjumps
  coyote=10
  jumping=false
  if(attack<0)attack=0
 else
  coyote=max(coyote-1)
 end
 if(coyote==0)jumps=min(jumps,maxjumps-1)

 -- handle jumping
 if jumpbuffer>0 then
	 if wallslidet>0 and not grounded then
	  local shortjump=false and btn(0,id) and wallslide==1 or btn(1,id) and wallslide==-1

   poof(x,y+8,3)

	  yv=-2.5
	  xv=sgn(wallslide)*(shortjump and 1 or 2)
	  wallslidet=0
	  movelock=20
		 unlockcamera=true

	  wallslide+=wallslide
		 flip=xv<0
	  jumping=true
	  
	  jumpbuffer=0
   sfx(58)

	 elseif jumps>0 then
	  yv=-3.5
	
	  grounded=false
	  jumps-=1
	  jumping=true
	  coyote=0
	  
   jumpbuffer=0

   poof(x,y+8,3)
   sfx(57)
	 end

 end

 -- variable jumping
 if jumping and not btn(4,id) then
  yv=max(yv,-1)
 end

 -- handle collisions
 do
  local l,r=_ENV:collide_x()

  if not grounded then
   if l then
    wallslide=1
    wallslidet=10
    flip=true
    if(t%4==0)poof(x-6,y,1,2,8)
    movelock=0
   elseif r then
    wallslide=-1
    wallslidet=10
    flip=false
    if(t%4==0)poof(x+6,y,1,2,8)
    movelock=0
   end
  end

 end

 -- update x position
 x+=xv

 -- update y velocity
 -- apply gravity
 if btn(3,id) then
  if(yv<4)yv+=grv*2
 else
  if(yv<3)yv+=grv
 end

 local slidespeed=0.2
 if wallslide~=0 and yv>slidespeed then
  yv+=(slidespeed-yv)/10
  
	 unlockcamera=true
 end

 do
  local u,d=_ENV:collide_y()

  if d then
   stunframe=false
		 unlockcamera=true
  end
 end

 -- update y position
 y+=yv

 -- unlock camera if if nearing edge
 if abs(y-cy)>80 then 
  unlockcamera=true
 end

 -- camera
 _ENV:move_camera(unlockcamera)
 
 -- timers
 t=max(t+1)
 wt=max(wt+xv) -- walk anim t
 movelock=max(movelock-1)
 jumpbuffer=max(jumpbuffer-1)
 landsquash=max(landsquash-1)
 iframes=max(iframes-1)

 -- path test
 if(pathtest)mset(x\8,y\8,62)

 hp=min(hp,hpmax)

 -- die
 if alive and hp<=0 then
  alive=false
  diet=120

  g.shakex=30
  g.usetimer=false
  music(-1,1000)

  --g.mode="dead"
 end

end

function player_draw(_ENV)
 local w,h=_ENV:squish_velocity()

 local playerpals={
  split"1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0",
  split"1,6,13,4,5,6,7,8,9,10,11,12,13,0,15,2",
  split"1,13,13,4,5,6,7,8,9,10,11,12,13,12,15,2",
  split"1,13,3,4,5,6,7,8,9,10,11,12,13,9,15,1",
 }

 -- update animation frame
 local f=0
 if grounded then
  if xv~=0 then
   if abs(xv)>mx+ac then
    f=split"12,4,13,4"[wt%80\20+1]
   else
    f=("3454")[wt%80\20+1]
   end
  else
   f=0
  end

 else
  if abs(wallslide)==1 then
   f=2
  else
   f=yv>0 and 9 or 1
  end
  
 end

 if attack==1 then
  f=attacktime<=4 and 8 or 7
 elseif attack==2 then
  f=6
 end

 if stunframe or not alive then
  f=grounded and 11 or 10
 end

 -- draw hammer
	local hama=0
 if hammer_available then
	 if attack==1 then
	  hama=-0.15+(1-mid(0,attacktime,16)/16)^6/2
	 elseif attack==2 then
	  hama=t/10
	 end
	 hama*=(flip and 1 or -1)
	 hama+=0.25
	
	 -- hammer sprite
	 if attack>0 then
	  rotspr(x+cos(hama)*(hamr-8),y+sin(hama)*(hamr-8),0.25-hama,127,63,2.5,flip)
	 else
	  -- idle
	  local squashv=yv-landsquash/3
	  local yo=split"2,1,1,-1,1,0,0,0,3,0,0,1,1"[f\1] or 0
	  if(not alive)yo-=4
	  local a=0.2-(squashv+yo/6)/32
	  rotspr(
	
	   x-(flip and -4 or 4),
	   y-2-yo-squashv,
	
	   flip and a or -a,
	   127,63,2.5,flip)
	 end
 end

 -- set palette
 pal(playerpals[id+1],0)
 palt(0,false)
 palt(12,true)

 -- player sprite
 if not alive or iframes==0 or t%4<2 then
	 if f==6 then
	  rotspr(x,y,0.1-hama,124,63,2.5,flip)
	 else
	  sspr(f\1%8*16,96+f\8*16,16,16,x-w\1,y-h\1+8,w\.5,h\1,flip)
	 end
 end

 pal(0)
 palt(0,false)
 palt(11,false)
 palt(12,true)

 if krikz_time_event==true then
  cprint("❎!",x,y-16)
  
 end

 --print(hp.." "..tostr(iframes),x,y-16)

end

function player_draw_hud(_ENV)

 pal(0)
 palt(11,false)
 palt(12,true)

 for i=1,hp do
  for x=0,1 do
   spr(48,i*10-9+x,119-id*10)
  end
 end
end

-->8
-- simple objects

function create_particle(x,y,xv,yv)
 return setmetatable({
 	type=0,size=2,l=60,
  x=x,y=y,
  xv=xv,yv=yv,
 },index)
end

function particle_update(_ENV)

 xv*=0.95
 yv*=0.95

 x+=xv
 y+=yv

 l-=1

 if(l<=0)del(particles,_ENV)
end

function particle_draw(_ENV)

 circfill(x,y,size*(l/60),6)

end


function create_pickup(type,x,y)
 local pickup=setmetatable({
  update=pickup_update,
  draw=pickup_draw,
  collect_callback=nop,

 	type=type,
 	t=rnd(-1)\1,
  x=x,y=y,sy=0,
  yv=0,landsquash=0,
  ox=x,oy=y,
 },index)

 -- function to run on pickup collection
 -- p is the object that picked it up
 pickup.collect_callback=({
  [8]=function(p)
   -- sandwich
   g.sandwiches+=1
   p.hp+=1
   sfx(54)
  end,
  [10]=function(p)
   -- timer
   g.timers+=1
   g.timelimit+=3
   sfx(53)
  end,
  [15]=function(p)
   -- entrance
   g.oi=180
   g.oi_message="oi"
   sfx(41)
  end
 })[type]or nop

 return pickup
end

function pickup_update(_ENV)

 sy=sin(t/100)*2
 
 if(t%60==0)yv=5
 yv*=0.75

 t=max(t+1)
end

function pickup_draw(_ENV)
 local w,h=_ENV:squish_velocity()

 local f=type+t%20\10
 if(type~=15)sspr(f\1%8*16,32+f\8*16,16,16,x-w\1,y+sy-h\1+8,w\.5,h\1)

end

-->8
-- enemies

function create_enemy(type,x,y)
 local enemy=setmetatable({
  update=enemy_update,
  update_intent=nop,
  draw=enemy_draw,
  death_callback=nop,
  damage=damage,

 	type=type,hp=1,
 	t=rnd(-1)\1,f=0,diet=0,
  x=x,y=y,
  ox=x,oy=y,
  xv=0,yv=0,
  landsquash=0,
  flip=false,
  alive=true,
  dealsdamage=true,
  invul=false,

  -- detectors
  lwall=false,rwall=false,
  uwall=false,dwall=false,
 },index)

 enemy.update_intent=({
  goomba_update,
  uufo_update,
  krikzz_update
 })[type]or nop

 return enemy
end

function enemy_update(_ENV)

 if alive then
  _ENV:update_intent()
 else
  xv*=0.95
  -- fall
  if(yv<3)yv+=grv

  -- despawn timer
  diet+=1
  if(diet>120)del(enemies,_ENV)
 end

 -- handle collisions
 lwall,rwall=_ENV:collide_x()

 -- update x position
 x+=xv

 uwall,dwall=_ENV:collide_y()

 -- update y position
 y+=yv

 -- timers
 t=max(t+1)
 landsquash=max(landsquash-1)

 -- die
 if alive and hp<=0 then
  alive=false
  poof(x,y,8,16,16)
  sfx(63)
  landsquash=10

  if(death_callback)death_callback()
 end
end

function enemy_draw(_ENV)
 local w,h=_ENV:squish_velocity()

 if(not alive)w*=1.4h*=0.3

 --rect(x-8,y-8,x+7,y+7,8)

 local dy=y
 if(sy)dy+=sy
 if(diet<100 or t%4<2)sspr(f\1%8*16,32+f\8*16,16,16,x-w\1,dy-h\1+8,w\.5,h\1,flip)

 --print(diet,x,y-16,7)

end

-- enemy ais below

function goomba_update(_ENV)
 if(not init)xv=-0.5 init=true

 -- update x velocity
 if(rwall)xv=-0.5
 if(lwall)xv=0.5

 flip=xv<0

 f=0+t%20\10

 -- update y velocity
 -- apply gravity
 if(yv<3)yv+=grv

end

function uufo_update(_ENV)
 -- update x velocity
 --xv=sin(t/200)
 --flip=xv<0
 flip=x>cx+64

 f=2+t%20\10

 -- update y velocity

end

function krikzz_update(_ENV)

 if not init then--[[
  death_callback=function()
   g.usetimer=false
   g.mode="win"
   
   if(pathtest)cstore(0x0000,0x0000,0x3000,"2m0rrow_map_copy.p8")
  end]]

  dealsdamage=false
  hp=32000

  init=true
 end

 xv=0
 yv=0

 flip=true

 if shock then
  f=5
  
  sy=0
 else

  f=6+(cos(t/100)*2>0 and 1 or 0)

  sy=-2.5+sin(t/100)*2

 end

end

__gfx__
00000000bbbbbbbbbbbbbbbbb7bbbbbb00bbbbbbbbbbbb0011111111bbbbbbbbd55555ddbbb82bbb22224421124422204422220000022244b244442bbbbbbbbb
00000000bbbbbbbbbbbbbbbbb7bbb7bb0bbbbbbbbbbbbbb011111111bbb12bbbbd66dd5bbbbbbbbb0222444224444222422222200002222424ffff41bbbbbbbb
00700700bbbbbbbbbbbbbbbbb76bb7bb0bbbbbbbbbbbbbb011111111bbb21bbbbb8e82bbbb2bb2bb002224444444422022222000000022224ff99ff2bbbbbbbb
00077000bbbbbbbbbbbbbbbb776b76bbbbbbbbbbbbbbbbbb11111111bbb12bbbbbb88bbbb2bbbb2b06666d247776220022220000011002224f9ff9f2bbcbbbbb
00077000bbbbbbbbbbbbbbbb766b776bbbbbbbbbbbbbbbbb11111111bbb21bbbb2bbbb2bbbb88bbb06ddd522766d000022200000011000224f9ff9f2bbcb3cbb
00700700bbbbbbbbbbbbbbbb667b767bbbbbbbbbbbbbbbbb11111111bbb12bbbbb2bb2bbbb8e82bb06d77776765dd55000000110000000004ff99ff2cb3bcbbb
000000000bbbbbbbbbbbbbb06d6666dbbbbbbbbbbbbbbbbb11111111bbb21bbbbbbbbbbbbd66dd5b06d7666d7666d5d1000001110000100012ffff213b3b3bcb
0000000000bbbbbbbbbbbb0026288262bbbbbbbbbbbbbbbb11111111bbbbbbbbbbb28bbbd55555dd06d7656d7666d5d10000000000000000b122221b131b3b3c
c22444cc000223c4cc24aa7aa4c9aacc466e7777777777777777e6641444444442244444444444412d57666d6dddd5d1000000000000000000000000bbbbbbbb
3c43cc33002224c4cc229626922999cc4d68eeeeeeeeeeeeeeee86d44422444444442244444442242227666d15555551010001100011001000000000bbbbbbbb
13cc34c20022443ccc2478887429aacc2d6e8888888888888888e6d24444424224444422222244442667656d777776d1000001100011000000000000bbbcbbbb
2231331200222433cc247888742999cc24d666666666666666666d4222442222122442122122244426d7666d76666d51220000100000000200000000bbbcbbbb
22231312002222c2cc2478887429aacc222dd22ddd24442d42ddd42244422122222222222222242226d6dddd76566d11222200000100002200000000bbbcbbbb
0221230000222c34cc229626922999cc02222200022222000222220044422220022222000021244426dd555176666d11222220000102222200000000bbb3bcbb
0000013000222c24cc24aa7aa4c9aacc00000000000000000000000044222200000000000022224426dddd517666d6d1422200110002222400000000bbb3bcbb
0000001000022314ccccccc55ccccccc00000000000000000000000042222000000000000002224426d777767666d551422220110022224400000000bb31b3bb
3c12200000000000ccccccc55ccccccc11111115bbbbbbb51111111b44222000000000000002224406d7666d6dddd5d1ccccccccccccaccccccccccccccc8c8c
23c2200000000000cccccccd5cccccccb1111115bb155115b11111bb2422200000100110002124440d67666d155555d1ccceeeeeeeeccc99ccccccccccc82c28
c3cc220000002200cccccccd5cccccccb5551115b1555115b11111bb4422220000000110002244220076666d16dddd51cceeeffeeeeecc99cccccc9944cccccc
3443220000222222ccccccddd5ccccccb1551115b5555115b55511bb4442120000000000002224440076656d77776d51cceeeeeeeeeeccccccccd6776dddcc28
44c3220021331114ccccccc99cccccccb1555115b1551115b15511bb4442220000000000002222420676666d7666dd51ceeebeeeeebeecccccc9666666d9dc8c
22c22200cc2233cccccccccaacccccccbb111115b5551115b55511bb2242220001100100002222440d6ddddd7656d551ceebfbeee3beeccaccc4ddddd6d4dccc
3c32220043c4cc32ccccccca9cccccccbbbbbbb1b11111b1b11111bb444222000110000000221224065555517666d111ceeff3eee3feeccccccc644946dd6ccc
c3222200443cc343ccccccc55cccccccbbbbbbbb5555551b5555551b44222200000000000002222406d777767666d5d1ceef3f3ef3feffccccccd6666d51cccc
cccccccc111111111111111b1bbbbbb15111111b1bbbbbbb1bbbbbb544222000000000000002224406d7666d7656d551ceeeffffbfeeffccccccc5566511cccc
cceeeecc10111101b11111bb11111111111111bb11511bbb1115151544212000000000000000222406d7666d7666d551cceee2bb2220ffcccccccd66d50ccccc
ceeeeeec11111111b11111bb11111111111111bb115551bb111555152442200000002200002221240556d56d6dddd5d1ccc0200020200cccccccccc00c0ccccc
cefeefec11111111b11111bb11111111111511bb115511bb111555154422220000221222222222240011d66d215555d1cc0020002200cccccccdccc0c0dccccc
ef3ee3fe11111111b11111bb11111111115511bb111111bb111111154442422222222244212222240221dddd42d5dd51cbbb00bbb2cccccccc576c660765cccc
ef3ff3fe11111111b11111bb1111111111511bbb111111bb111111154444442242222444222244440221111142211111cbb00000000ccccccc5660dd0665cccc
eeffffee10111101b11111bb1bbbbbb11bbbbbbb111111bb1bbbbbb14422444444444422422224440022222244222222ccc000cc0000ccccccccc00ccccccccc
ceecccec111111111111111bbbbbbbbbbbbbbbbb1555551bbbbbbbbb1444442244224444444444210022242114442222cc6666ccc7777ccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbccccc499cccccccccccccc4499cccccccccccc4499cccccc
ccccccccccccccccccccccccccccccccccccc89aa98cccccccccc9a77a9cccccbbbbb5555551111bcccc4d6776dcccccccccddd6776dccccccccddd6776dcccc
ccc28882cccccccccccccccccccccccccccc89aaaa98cccccccc9a7777a9ccccbbbb55555511111bcccdd644946ccccccccd9d6666669ccccccd9d6666669ccc
c888888828ccdccccc28882ccccddcccccc6889999886cccccc699aaaa996cccbbb555555111111bccd9d6444469c566cccd4d6666664ccccccd4d6666664ccc
28822228828ccdccc88888828ccc1ccccc666677776666cccc666677776666ccbb5555551111111bccd4d6666664c67cccc6dd649946ccccccc6dd649946cccc
8828ee82882811cc288222282281ccccccd66666550d6dccccd66665550d6dccb55555511111111bcc6ddd6556dcd66ccccc15d6666dcccccccc15d6666dcccc
8288ee8288118ccc882ee8828821cccccc6ddddd50de77cccc6ddd5500ddd6ccb11111113333c31bccc1156556cccc0ccccc1156556ccccccccc1156556ccccc
8288882888828ccc828ee88288128cccccc66665066886aaccc6665066666cccb1555511cc3cc31bcccc11d66dccc66cccccc05d66dcccccccccc05d66dccccc
82888288888288cc82888882888288cccccc2250025d66cccccc2250222e77ccb1111111c3c3331bcccc0cc00cccd6ccccccc0c00cccccccccccc0c0cccccccc
82888888296982ac82888828889282acccc444504450c9ccccc44500444886ccb1555511333cc31bcccc0ccc000cd0cccccc00cc00c06cccccccc0c00c06cccc
2820000299616a7c882000088269aa7acccc9a005500cc9ccccc9507755d66aab111111155511111ccc00ccccc000ccccccc0cccc00d6cccccccc0cc00d6cccc
28051150a97d79aa2801511029616aa9cccc89a00009cccccccc80005000c99cb15555115511111bccc0ccdcccccccccccc00ccccccd6ccccccc00ccccd6cccc
2201d6102a6779992201d650997d799ccccc88aaa998cccccccc89000089ccccb11111115111111bccc0c7656ccccccccc00cccccccc0cccccc00cccccc0cccc
c201dd1022991ddc2205dd10a9671dddcccc8c89a88cccccccccc89898c8ccccb11111111111111bccc006656cccccccc76dcccccccd67cccc76dcccccd67ccc
cc05115022c9911dc20115102a99911ccccc8cc898cccccccccccc9c88c8cccc5555555515555551cccc0cccccccccccc66ccccccccc66cccc66ccccccc66ccc
ccc0000cccccccccccc0000222cccccccccccccc9cccccccccccccccc8cccccc5555555511111111ccccccccccccccccc556ccccccc655cccc556ccccc655ccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ccccccccccccccccccccccccccccccccccccccc76cccccccccccccc76cccccccffffffffffffffffffffcaaaacffffffffffffffffffffffffffffffffffffff
ccc4444cc4444cccccc4444cc4444ccccccccc6ccdcccccccccccc6ccdcccccc9aaaaa9aaaaa9a9fffffa7777affffffffffffffffffffffffffffffffffffff
cc4fffb44bfff4cccc4fffb44bfff4ccccccc7aaaa9cccccccccc7aaaa9ccccca77777a77777a7afffffcaa77affffffffffffffffffffffffffffffffffffff
cc4ffffffffff49ccc4ffffffffff42cccccaaa999aaccccccccaaa999aacccca77aaaa77aa7a7afffffffa77afffffffff8eeeeee8fffffffffffffffffffff
cc4bffffffffb4accc4bffffffffb4accccaa9560599accccccaa9566099accca77affa77aa7a7afffffffa77afffffffffe777777e8ffffffffd66666dfffff
ccc4ffbfffff492cccc4ffbfffff499ccc7a967707699acccc7a967770699acca77affa77aa7a7afffffffa77afffffffff8eeeee77effffffff6777776fffff
ccc4fffffbff40ccccc4fffffbff40ccccaa5777077da9ccccaa5777057da9cc9aa9499aa99a9a9fffffffcaacffffffffffff28777effffffffd666776fffff
ccc4ffffffff42ccccc4ffffffff42cccca967750777a9cccca967750777a9cc9aa99a9aa99a9a9fffffffcaacffffffffff288eee82fffffffff5d66d5fffff
ccc4fffbffff42ccccc4fffbffff42cccca967700777a9cccca988800777a9cc9aa99a9aa99a9a9fffffffcaacfffffffff28eee882fffffffff5ddd66dfffff
ccc4ffffffff40ccccc4ffffffff49cccca95787777da9cccca95777777da9cc9aa99a9aa99a9a9fffffffcaacfffffffff8ee888882ffffffffd66666dfffff
ccc4bffffffb49ccccc4bffffffb49cccc999877777a94cccc999777777a94cc9aa99a9aa99a994fffffffcaacfffffffff8eeeeeee8ffffffff5ddddd5fffff
ccc944444444a9ccccc944444444a9ccccca9ad77da9acccccca9ad77da9accc9aaaaa9aaaaa9a9ffff3cccaaccc3ffffff288888882ffffffffffffffffffff
ccccaa900aa992cccccaa90009aa92cccccc99aaaa9acccccccc99aaaa9acccc499999499999494ffffcaaaaaaaacfffffffffffffffffffffffffffffffffff
ccccc22229992cccccccc22222999cccccccca99994cccccccccca99994cccccfffffffffffffffffff3cccccccc3fffffffffffffffffffffffffffffffffff
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
82a3000000b081818181818181810101018181c082828282828282828282d0818181818181415161a00000000000007292000062004600718181415161818181
9130307181818181818181818181c082e182920000729200000073128383c182920000000000000000000000007292000000000000000000000000000000b082
8292000000b3838312121283838383838383121283838383121212128383838383831212121283c1a2000000000000729200006200000072d183838383838383
838383838383838383838383838383838383930000021100000000006200b082920000000000000000000000000292000000000000000000000000000000b182
82920000000062000042636343000062000000000000000000000000000042636363634300000072a3000000000000b092000062000000739300008000000000
000000000000000000000000000000006200000000029200000000006200b182920000000000000000000000000211f0f1000400f1f10000000000000000b282
8292000000006200000000000000006200000000000000000000000000000000000000000000000292000000000000b192005243004600000000007000000000
000000000000000000000000000000006200000000029200f1f0f1006200b2829200000000000000000000000002d00101018181810181a0000000000000b382
8211f0f10000620000060000f0f1f06200000000000000000000000000000000000000000000000211000000000000b292006200000000000000007000000000
00000000000000000000000000526363430000000072d0818101a0006200b382923030f0f1000000000000000072828282828282828282a10000000000000282
e1d00181818101010181810101818181910000000000000000000000000000000000000000000002a0000000000000b392006284940000000000007000000000
00000000000000000000000000620000000000000073121283c1a100620072e1d081010181910000000000000002828282828282828282a20000000000007282
e1d183831212121283838383831212129300000000000000000000000000000000000000000000b0a10000000000007292006285950000000000009000000000
0052534452530000000000000062000000000000000000000072a200620072d18312128312930000000000000073831212831283831283a3000000000000b082
829243000000000000000000000000000000000000000044000000000000004400000000000000b1a263635300000072d0818181818181818181819130307181
8181415161913030718181818181819100000000000000000073a3006200b0a0000000000000000000000000000000000000000000000000000000000000b182
821100000000000000000000000000000000000000000000000000000000000000000000000000b2a3000062000000b0d18312c182828282828282d08181c082
8282828282d08181c0828282828282920000000000000000000000006200b1a1000000000000000000000000000000000000000000000000000000000000b282
821100000000000000000000000000000000000000000000000000000000000000000000000000b393000062000000b19200000282e1e1e1e1e1e182828282e1
e1e1e1e1e182828282e1e1e1e1e182920000000000000000000000006200b2a2000600000000000000000000000000000000000000000000000000000000b382
1293e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000062000000b29263637282e1e1e1e1e1e1e1e1e1e1e1
e1e1e1e1e1e1e1e1e1e1e1e1e1e182920000000000000000000000006200b3a30000000000000000000000000000000000000000000000000000000000000282
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000062000000b39200000282e1e1e1e1e1e1e1e1e1e1e1
e1e1e1e1e1e1e1e1e1e1e1e1e1e18292000000000000000000849400620072110000000000000000000000000000000000000000000000000000000000000282
e600000084940000000000000000000000000000000000000000000000000000000000000000000000000062000000721163630282e1e1e1e1e1e1e1e1e1e1e1
e1e1e1e1e1e1e1e1e1e1e1e1e1e182920046000000000000008595006200721130303030f000f100f1000000f0f0f1f0f1303030f1f0f000f100f0f1f0f10282
f0f1f0f0859500000c0000f0f1f000f10000000000f1f0f0f13030303030f0f1000000000000f10000f0f162f0f100721100007282e1e1e1e1e1e1e1e1e1e1e1
e1e1e1e1e1e1e1e1e1e1e1e1e1e182d08181818181818181818181818181c0d0010101010101818181818101010101018181018181018101818181010101c0e1
0101018181818181818101010101018101818181810101018101018181010101018181818181810101010101018181c0d00181c082e1e1e1e1e1e1e1e1e1e1e1
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1828282828282828282828282828282e1e1828282828282828282828282828282828282828282828282828282828282e1e1
e1e1828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282e1e1828282e1e1e1e1e1e1e1e1e1e1e1e1
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1
cccccccccccccccccccceeffeeeecccccccceeeeeeeeccccccccceeeeeeeecccccccccccccccccccccccceeeeeeeecccccccccccccccccccccceeffeeeeccccc
ccccceeeeeeeecccccceeeeeeeeeecccccceeeffeeeeeccccccceeeffeeeeeccccccceeeeeeeeccccccceeeffeeeeecccccccebbbbbccccccceeeeeeeeeecccc
cccceeeffeeeeeccccceebeeeeebecccccceeeeeeeeeeccccccceeeeeeeeeecccccceeeffeeeeecccccceeeeeeeeeeccccc0eeeebbbbbccccceebeeeeebecccc
cccceeeeeeeeeecccceeeb3eee3beecccceebeeeeebeeeccccceeebeeeeebeeccccceeeeeeeeeeccccceeebeeeeebeeccc0eeffeebfbbbccceeebbeeebbeeccc
ccceeebeeeeebeeccceebf3eee3feecccceeb3eee3fbeeccccceebf3eee3beecccceeebeeeeebeecccceebf3eee3beeccc0eeeeffffffbccffebf3eee3feeccc
ccceebf3eee3beeccceeff3fef3feecccceef3eee3ffeffcccceeff3eee3feecccceebf3eee3beecccceeff3eee3feecc00eeeeeeefff3fcff0ff3fef3feeccc
ccceeff3eee3feeccceeffffffffeecccceef3fef3ffeffcccceeff3fef3feecccceeff3eee3feecccceeff3fef3feecc000eeeeeeeff3fcff00f3fff3feeccc
ccceeff3fef3feeccceeeffffffeeecccceeeffffffeeffcccceeeffffffeeecccceeff3fef3feecccceeeffffffeeecc000eeeeeeeff3fcce002fffffeeeccc
ccceeeffffffeeecccceee2bb2eeebbcccceee2bb2eeeccccccceee2bb2eeeccccceeeffffffeeeccccceee2bb2eeeccc0000eeeeeeefffccce0222bb22ecccc
cccceee2bb2eeeccccccc2200022bbbccccc02000222c6cccccccc002002bbbccccceee2bb2eeecccccc22020002bbbcc0000eeeeeeefffccccc0020002ccccc
ccccc2020002bbbccccc2020002cccccccbb0000022006ccccccccfff002bbbcccccc2020002ccccccfff0020002bbbcc00000eeeeeeeffcccccc220002ccccc
cccc00020002bbbcccc000bbb0000cccccbbbc0bbb0006ccccccc0fffb000cccccccc0020002bbbcccfffc2bbb00cccccc7000000eeeefccccccc2bbb00ccccc
cccfff2bbb00ccccccfffc0000000cccccccccc0000006cccc7000000000006cccccfffbbb0cbbbcccc60000000007cccc77000ee00eefcccccccc0000066ccc
cccfff0000000cccccfff0000c6666ccccccccc0000cccccccc7000cccc006ccccccfff00000cccccccc6000cc007cccccc77000eeeefcccccccc0000666cccc
cccc0000cc000cccccccc000cccccccccccccccc0000cccccccc77ccccc66ccccccccc000000ccccccccc66ccc77ccccccccc70000eccccccccc000ccccccccc
ccc7777ccc6666cccccc7777cccccccccccccccc7777cccccccccccccccccccccccccc77776cccccccccccccccccccccccccccccccccccccccc7777ccccccccc
cccccccccccccccccccccceeeeeeccccccccccecccccccccccccccccccccccccccccceeeeeeeeeccccccceeeeeeeeecc00002300131313131300000013131300
cccccccccccccccccccceeeffeeeecccccccceeeeeecccccccccccccccccccccccccceeeffeeeeecccccceeeffeeeeec60606060606060606000000000000000
cccccccceeeeeeccccceeeeeeeeeecccccceeefeeeeeeccccccccccccccccccccccceeeeeeeeeeeccccceeeeeeeeeeec33331333131313131300000013131333
cccccceeeffeeeeccceeebeeeeebeeccceeeeeeefeeecccccccccccccccccccccccceeebeeeeebeecccceeebeeeeebee60606060606060606000000000000000
ccccceeeeeeeeeeccceebbbeeebbeecccceebeeeeeeeeccccccccccccccccccccccceebfeeee3beecccceebfeeee3bee00002300131313131300000013131300
ccccceebeeeeeeeecceebf3fee3beeccceeebbeeeeeeecccccccccccccccccccccceeeff3eef3feeccceeeff3eef3fee60606000000060606000100000000000
cccceeebbeeeebeecceeff3fff3feecceeebbfbeeebeeeccccccccccccccccccccceeeff3eff3eeeccceeeff3eff3eee00002300000013131333333313131300
cccceebffbeebbeecceeef3fff3eeebcceee3ffbe3beeeccccccccccccccccccccceeeefffffeeecccc0022fffffeeec60606040005060606000001010000000
cccceeff3ffff3eeccce222bb2eeebbccceee3ff3ffeeecccccccccccccccccccccceee22bbeeecccfff00022bbeeecc00002300000013131300000013131300
cccceeeff3ff3eeeccc220200022cccccc2eeebfffeeebccccceeecccccccccccccccc2220fffbbccfffcc020002bbbc60606000000060606000001010000000
ccccceeeffffeeecccfff220002ccccccc00020002cbbbccceeeeeeeccccccccccccc22000fffbbcccccc2200002bbbc00002300000000000000000000230000
ccccccc22202ccccccfffcbbb000cccccfff22000200ccccefefeeeffeccccccc70000bbb000c6cccc6000bbb0007ccc60606010002060606000000000000000
cccccc200220fffbcccccc0000000ccccfff2bbb00066ccceeebf3ffb00c7cc6c7000000000006cccc60000000007ccc00131313000000000000000000230000
cccc00000000fffbcccccc000c000cccccccc0000c66cccceeeeb3ee20b07006c77000ccc00006cccc66000cc0007ccc6060606060606060600000ccdc002131
cc77700cc000cccccccccc000c6666cccccccc000ccccccceefff00222b07006cc7cccccccc006ccccc6ccccccc07ccc00131313000000000000000000230000
ccc777ccc6666ccccccccc7777cccccccccccc7777cccccccefff00022207006cccccccccccccccccccccccccccccccc6060606060606060600000cddd002232
__label__
7000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
0700000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhdddddddhhhhddddhddddddddddddddddhhhhdddddddhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
0070000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhdd77777ddhhhd77ddd77d777d777dd77dhhhdd77777ddhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
0700000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhd77d7d77dhhhd7d7d7d7dd7dd7ddd7dddhhhd77d7d77dhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
7000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhd777d777dhhhd7d7d7d7dd7dd77dd777dhhhd777d777dhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
0000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhd77d7d77dhhhd7d7d7d7dd7dd7ddddd7dhhhd77d7d77dhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdd77777ddhhhd7d7d77ddd7dd777d77ddhhhdd77777ddhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5ddddddd5hhhdddddddd5ddddddddddd5hhh5ddddddd5hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5555555hhhh55555555h55555555555hhhhh5555555hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhh22222222hh22222222222222hh2222222222222222222222hh22222222222222hh2222hhhh222222hhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhh2eeeeee2hh2eeee22eeeeee2hh2eeee22eeeeee22eeeeee2hh2eeee22ee22ee2hh2ee2hhhh2eeee2hhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhh2eeeeee2222eeee22eeeeee2222eeee22eeeeee22eeeeee2222eeee22ee22ee2222ee2hh222eeee2hhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhh222ee2222ee22ee22eeeeee22ee22ee22ee22ee22ee22ee22ee22ee22ee22ee22ee222hh2ee22222hhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhii2ee2ii2ee22ee22eeeeee22ee22ee22ee22ee22ee22ee22ee22ee22ee22ee22ee2iihh2ee22222hhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhh2ee2hh2ee22ee22ee22ee22ee22ee22eeee2222eeee2222ee22ee22ee22ee22222hhhh2eeeeee2hhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhh2ee2hh2ee22ee22ee22ee22ee22ee22eeee2222eeee2222ee22ee22ee22ee2iiiihhhh2eeeeee2hhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhh2ee2hh2ee22ee22ee22ee22ee22ee22ee22ee22ee22ee22ee22ee22eeeeee2hhhhhhhh22222ee2hhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhh2ee2hh2ee22ee22ee22ee22ee22ee22ee22ee22ee22ee22ee22ee22eeeeee2hhhhhhhh22222ee2hhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhh2ee2hh2eeee2222ee22ee22eeee2222ee22ee22ee22ee22eeee2222eeeeee2hhhhhhhh2eeee222hhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhh2ee2hh2eeee2ii2ee22ee22eeee2ii2ee22ee22ee22ee22eeee2ii2eeeeee2hhhhhhhh2eeee2iihhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhh2222hh222222hh22222222222222hh2222222222222222222222hh22222222hhhhhhhh222222hhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhiiiihhiiiiiihhiiiiiiiiiiiiiihhiiiiiiiiiiiiiiiiiiiiiihhiiiiiiiihhhhhhhhiiiiiihhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhh44444444444444444hhh44444444444h444h444444444hhh44444444444444444444444444444hhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhh4a4a4aaa44aa4aaa4hhh4aaa4aaa4a4h4a4h4aaa4aaa4hhh4aaa4a4a4aaa4aaa4aaa4aaa4a4a4hhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhh4a4a4a444a444a4444444aaa4a4a4a4h4a4h4a4444a44hhh44a44a4a4a444a4a4a4a4a4a4a4a4hhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhh4a4a4aa44a444aa44aaa4a4a4aaa4a4h4a4h4aa424a42hhh24a44aaa4aa44aa44aaa4aaa4aaa4hhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhh4aaa4a444a4a4a4444444a4a4a4a4a444a444a4444a4hhhhh4a44a4a4a444a4a4a4a4a44444a4hhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhh44a44aaa4aaa4aaa42224a4a4a4a4aaa4aaa4aaa44a4hhhhh4a44a4a4aaa4a4a4a4a4a424aaa4hhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhh24444444444444444hhh444444444444444444444444hhhhh4444444444444444444444h44444hhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhh2222222222222222hhh222222222222222222222222hhhhh2222222222222222222222h22222hhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhdddddddddddhhhhdddddddddhhhhdddddddddddddddddddddddhddddhhhhddddddddhhhdddhddddddddddddddddhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhdd7dd777d77ddhhhd777d777dhhhdd77d777dd77dd77d77dd77ddd77dhhhdd77d777dhhhd7dhd777dd77dd77dd7ddhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhd7dddd7dd7d7dhhhddd7d7d7dhhhd7ddd7ddd7ddd7d7d7d7d7d7d7dddhhhd7d7d7d7dhhhd7dhd7ddd7ddd7ddddd7dhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhd7d55d7dd7d7dhhhd777d7d7dhhhd777d77dd7d5d7d7d7d7d7d7d777dhhhd7d7d77ddhhhd7dhd77dd777d777d5d7dhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhd7dddd7dd7d7dhhhd7ddd7d7dhhhddd7d7ddd7ddd7d7d7d7d7d7ddd7dhhhd7d7d7d7dhhhd7ddd7ddddd7ddd7ddd7dhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhdd7dd777d7d7dhhhd777d777dhhhd77dd777dd77d77dd7d7d777d77ddhhhd77dd7d7dhhhd777d777d77dd77ddd7ddhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhh5ddddddddddddhhhdddddddddhhhdddddddddddddddddddddddddddd5hhhdddddddddhhhdddddddddddddddd5ddd5hhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhh555555555555hhh555555555hhh5555555555555555555555555555hhhh555555555hhh5555555555555555h555hhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2244aaaa77aaaa44hh99aaaahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2244aaaa77aaaa44hh99aaaahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh222299662266992222999999hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh222299662266992222999999hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh22447788888877442299aaaahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh22447788888877442299aaaahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh224477888888774422999999hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh224477888888774422999999hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh22447788888877442299aaaahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh22447788888877442299aaaahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh222299662266992222999999hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh222299662266992222999999hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2244aaaa77aaaa44hh99aaaahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2244aaaa77aaaa44hh99aaaahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5555hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5555hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5555hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5555hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdd55hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdd55hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdd55hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdd55hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdddddd55hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdddddd55hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh9999hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh9999hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaaahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaaahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaa99hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaa99hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5555hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5555hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhdddddddddddddddddddddhhhhdddddddhhhhdddddddddhhhhddddddddddddddddddddhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhd777d777d777dd77dd77dhhhdd77777ddhhhd777dd77dhhhdd77d777d777d777d777dhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhd7d7d7d7d7ddd7ddd7dddhhhd77ddd77dhhhdd7dd7d7dhhhd7dddd7dd7d7d7d7dd7ddhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhd777d77dd77dd777d777dhhhd77d7d77dhhh5d7dd7d7dhhhd777dd7dd777d77ddd7d5hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhd7ddd7d7d7ddddd7ddd7dhhhd77ddd77dhhhhd7dd7d7dhhhddd7dd7dd7d7d7d7dd7dhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhd7d5d7d7d777d77dd77ddhhhdd77777ddhhhhd7dd77ddhhhd77ddd7dd7d7d7d7dd7dhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhdddhdddddddddddddddd5hhh5ddddddd5hhhhddddddd5hhhdddd5dddddddddddddddhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhh555h5555555555555555hhhhh5555555hhhhh5555555hhhh5555h555555555555555hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhdddddddhhhhhhhhhhhhhhhhhhhhhhhhdddddddddddddddddhhhdddhdddddddddddddddddhhhdddddddddddddddddhhhhhhhhhhhhhhhhhhhhhhhhhdddddddhh
hdd77777ddhhhhhhhhhhhhhhhhhhhhhhhd777d777d777d777dhhhd7dhd777d777d777d777dhhhd777dd77d77dd777dhhhhhhhhhhhhhhhhhhhhhhhhdd77777ddh
hd777dd77dhhhhhhhhhhhhhhhhhhhhhhhdd7ddd7dd777d7dddhhhd7dhdd7dd777dd7ddd7ddhhhd777d7d7d7d7d7dddhhhhhhhhhhhhhhhhhhhhhhhhd77dd777dh
hd77ddd77dhhhhhhhhhhhhhhhhhhhhhhh5d7d5d7dd7d7d77d5hhhd7dh5d7dd7d7dd7d5d7d5hhhd7d7d7d7d7d7d77d5hhhhhhhhhhhhhhhhhhhhhhhhd77ddd77dh
hd777dd77dhhhhhhhhhhhhhhhhhhhhhhhhd7ddd7dd7d7d7dddhhhd7dddd7dd7d7dd7ddd7dhhhhd7d7d7d7d7d7d7dddhhhhhhhhhhhhhhhhhhhhhhhhd77dd777dh
hdd77777ddhhhhhhhhhhhhhhhhhhhhhhhhd7dd777d7d7d777dhhhd777d777d7d7d777dd7dhhhhd7d7d77dd777d777dhhhhhhhhhhhhhhhhhhhhhhhhdd77777ddh
h5ddddddd5hhhhhhhhhhhhhhhhhhhhhhhhddddddddddddddddhhhddddddddddddddddddddhhhhdddddddddddddddddhhhhhhhhhhhhhhhhhhhhhhhh5ddddddd5h
hh5555555hhhhhhhhhhhhhhhhhhhhhhhhh5555555555555555hhh55555555555555555555hhhh55555555555555555hhhhhhhhhhhhhhhhhhhhhhhhh5555555hh
hhhhhhhhhhhhhhhhhhhhhhhhhddddhddddddddddddddddddhhhhhhddddddddddddhhhhdddddddddddddddddddddddhdddddddhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhd77ddd77d777d777d777d7dhhhhhdd7dd777d777dhhhdd77d777dd77dd77d77dd77ddd77dd7ddhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhd7d7d7d7d7d7d777d7d7d7dhhhhhd7ddddd7d7d7dhhhd7ddd7ddd7ddd7d7d7d7d7d7d7ddddd7dhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhd7d7d7d7d77dd7d7d777d7dhhhhhd7d5d777d7d7dhhhd777d77dd7d5d7d7d7d7d7d7d777d5d7dhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhd7d7d7d7d7d7d7d7d7d7d7dddhhhd7ddd7ddd7d7dhhhddd7d7ddd7ddd7d7d7d7d7d7ddd7ddd7dhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhd7d7d77dd7d7d7d7d7d7d777dhhhdd7dd777d777dhhhd77dd777dd77d77dd7d7d777d77ddd7ddhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhdddddddddddddddddddddddddhhh5ddddddddddddhhhdddddddddddddddddddddddddddd5ddd5hhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhh5555555555555555555555555hhhh555555555555hhh5555555555555555555555555555h555hhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh

__gff__
0001010401010100000001010101010001010000010101010101010101010100010100000000000101010101000000000000000000000001010101010000000080000000800000000000800080000000000000000000000000000000000000004000000040000000000000000000400000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1e1e282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828281e1e
1e1d383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838382121212138382121383838212138383838382138213838383838383838212121381c1e
2829000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000260000000000000000000000000000000000000000000000000b28
2829000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000260000000000000000000000000000000000000000000000001b28
2829000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000260000000000000000000000000000000000000000000000002b28
2829000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000243500000000000000000000000000000000000000000048493b28
2829000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002600000000000000000000000000000000000000006058592728
2829000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002600000000000000000000000000000000000000171818180c1e
2829000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002600000000000000000000000000000000000000373838381c1e
2829000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f001f26000f001f0000001f0000000000000000000000000000002728
2829000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001718181010141516101818181818190000000000000000000000000000002728
282900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044004400000000271d383838382121383838213838390000000000000000000000006400002728
2829000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000440044000000000000000000000000000000000000000000002729000000000000000000000008000000000000000000000000000000002728
2829000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002729000000000000000000000007000000000000000000002536363636362728
280a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000303030303030303030303030303030303030303030303030303030303030303032729000000000000000000000009000000000000000000002600004000002728
281a000000000000000000000000000000000000000000000000002536350000030303004000000040000000000000000025363500000000000000000000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e3739000000000000000000000017181818181818181818181818181818180c1e
282a0000000000000000000000004849000000000000000017181415161818181818181818181818181900000000171814151618190000000000000000000000000000000000001718181818181818181818190000000000000000000000000000000000000000000000000000271d38212138382138382121381c2828281e1e
283a00000000002536363500000058590000030303402536271d38383838383838383838383838381c290000000037383838381c29000000000000000000000000000000000000373838383838381c2828281100000000000000000000000000000000000000000000000000002729002600000000080000260027281e1e1e1e
28290000000000260b1415161818181818181818181818180c290000002600000000000000002536272900000000000000000027290000000000000000000000000000000000000000000000000027281e281100000000000000000000000000000000000000000000000000002711363400000000070000260020281e1e1e1e
280a0000000000242b282828281d383838381c282828282828293500002600000000000000002600272900000000000025363627290000000000000000000000000000000000000000000000000027281e2811000060000000000000000000000000000000000000000000000027110000000000000700002600272828281e1e
281a0000000000003b281e1e1e2936363524271e1e1e1e1e28292600002600002536363635002600272900000000000026000037390000000000000000000000000000000000000000000000000027281e2811000000000000000000000000000000000000000000000000000027290000000000000700002600372121381c1e
282a00000000000027282828280d181818180c2828282828280d18181818181818181818181818180c2900000000000026000000000000000000000000000000000000000000000000000000000027281e2829000000000000000000000000000000000000000000000000000027110000000000000700002600000000252728
283a0000000000000b1d3838383838383838383838383838383838383838383838383838383838381c2900000000000026000000000000000000440044000000000000000000000000000000000027281e28290000000000000000000000000000000000000000000000000000270a0000000000000700002600000000263721
28290000000000001b29000026000000000000000000000000000000002600000000000000000000272948490000000026000000000000000000000000000000000000004849000000000000000027281e28290000001f001f0f0f1f00400f1f0f001f0f1f0f0040001f0f001f271a0000000000000700002436363500260e00
280a0000000000002b29000026000000000000000000000000000000002600000000000000000000272958590000640024363500000000000303000000030300000000005859000000000000000027281e282900001718181010101018181818101010181818101010181018180c2a0000000000000700000000002600260e00
281a0000000000003b29363634000000000000000000000000000000002600000000000000000000270d18181818181818181818181818181818181818181818181818181818181819000000000027281e28110000201d383821212138383821213821383838382121382138211c3a000000000000091f001f0f1f264c260e0f
282a0000000000002729000000000000000000000000000000000000002600000000000000000000373838383838381c1d383838383838383838383838383838383838383838381c29363636363627281e2811000027290000000000000000000000000000000000000000000027110000000000000b18181810101415161010
283a0000000000000b29000000000000000000000000000064000000002435000000000000000000000000000000002729002600000000002600000000000000000000080000003739000000000027281e2829000027110000000000000000000000000000000000000000000020290000000000003b38382121383838381c28
28290000000000001b29000000000000000000000f00000000000040001f26000000000000000000000000000000000b29002600000000002600000000000000000000070000000000000000000027281e28290000200a00000000000000000000000000000000006000000000200a0025363636363400000000000026002728
280a0000000000003b3900000000000000000017190e0e0e0e0e0e0e0e1719000000000000000000000000000000001b29002600000000002600000000000000000000070000000000000000000027281e28290000201a00000000000000000000000000000000000000000000201a0026000000000000000000000024362028
281a0000000000002435000000000000000000270d10181810101010180c29000000000000000000000000000000002b29002600000000002600000000004849000000070000000000000048490027281e28110000202a000000000f253635001f000000000000000000000000272a3634000000000000000000000000002028
282a000000000000253400000000000000001f2728282828282828282828290f1f000025363635001f0000000000003b29002435000000002436354400005859000000090000000000000058590027281e28110000273a00000017181014151619000000000000000000000000273a0000000000000000000000000000002728
__sfx__
451000000421504205042050520504215032050020500205042150020500205002050421500205002050020504215002050020500205042150020500205002050421500205002050020504215002050020500205
010800200e0530000300003000031105300003000030000300003000030e05300003340223402513053000030e0530000300003000031105300003000030000300003000030e0530000311053000003402334023
ab1000000b4010b4010b4010b401000010b4010b4010b40109401094010940109401000010540105401054012161123611246112662128621296212b6312d6312f6313064132641346413565137651396513b651
a11000000b4520b4520b4520b4520b4520b4520b4520b4520b4520b4520b4520b4520545205452054520545207452074520745207452074520745207452074520045200452004520045204452044520445204452
11080020235540050421554005041f554005041d554005041c554005041a5540050418554005041755400504235540050421554005041f554005041d554005041c554005041a5540050418554005041755400504
a11000000b4520b4550b4520b455000000b4550b4550b455094520945509452094550000005455054550545507452074550745207455000000745507455074550045200455004520045500000044550445504455
11080020235540010421554001041f554001041d554001041c554001041a5540010418554001041755400104231540010421154001041f154001041d154001041c154001041a1540010418154001041715400104
a11000000b4520b4550b4550b4500b4550b4500b4550b455094520945509455094550000005450054550545507452074550745207455000000745507455074552f2500b251004520045504455044550000004455
010800200e053000030000300003110530000300003000030e053000030e00000000110533400013000000000e0530000311053000030e0530000311053000030e0530000311053000000e053110530e05311053
410c00000b2540b2520b2520b2520b2420b2420b2420b2420b2320b2320b2320b2320b2220b2220b2220b2220b2120b2120b2120b2120b2120b2120b2120b2120000200002000020000200002000020000200002
910800200e0530000300003000031105300003000030000300003000030e05300003130533400013053000030e0530000300003000031105300003000030000300003000030e0530000311053000003401334013
d51000001023504205042050520510235032050020500205102250020500205002051021500205002050020510235002050020500205102350020500205002051022500205002050020510215002050020500000
110800202355400104215540010400000001041d554001041c554001041a55400104185540010417554001042315400104211540010400000001041d1540010410154001040e154001040c154001040b15400104
c10800003005500005000000000000000000000000500000300550000000000000000000000000000000000000000000000000000000000000000000000000000000000000350550000035055000003505500005
a5101000114550c455134510e45500400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
51040000175501e551135510f5410c5310a5110600000001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
790200000b65017600006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
790200001765017600006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
010800001d65518600000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
a10600002b3502b3402b3302b3202b315000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a10800001c3551f355000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
151000001875500700187551875518755297001875529700107501075510750107550c7500c7500c7500c75500700007000070000700007000070000700007000070000700007000070000700007000070000700
150a00002475500000247552975229742297322972229715000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191002002b75500700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
191002001f75500700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
59040000235502a5512b5511f5211f515060000000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100000
110300002f5502f5502f5402f5302f5202f5102350023500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
150200000c3570e3571035711357183571a3571c3571d357243572635728357293572934029330293202931000600006000060000600006000060000600006000060000600006000060000600006000060000600
010800001a5551f5501f5311f5211f515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000185532b2551a55521755242551f5552f7551d2552b7552425518555005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
51040000235502a5511f5511b54118531165110600000001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
01040000190501e0511e0500000000001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
010800000d6341e033006000060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100600
910800001003300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
790800000c35300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1308000017053235330b6300b6150e6000c6000c60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
13080000170532355311640106300e6200c6100c60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4908000026655110531a6301a61026600266000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00590201
00 00010405
00 00010605
00 00010407
00 00010c07
00 48480e08
04 49494309
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
01 4b42430a
00 4b42430a
00 0b42430a
00 0b42430a
00 0b42434a
02 0b42434a
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 00594201
00 00590201
01 00010405
00 00010605
00 00010407
00 00010c07
00 0b4a050a
00 0b4a0701
00 4b4b0b0e
00 4b420b0a
02 4142430d
00 48484308
04 49494309

