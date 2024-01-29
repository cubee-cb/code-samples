-- Drone Fight
-- By Cubee

---------------------------------------------------------------------------------------------------
--     ______   ______    _____   __    ___ _______     _______ ___ ________ __    ___ _________ --
--    / ___  \ / ___  \ / ___  | /  \  /  // _____/    / _____//  // ______// /   /  //__   ___/ --
--   / /  /  // /__/  // /  /  // /\ \/  // __/       / __/   /  // /  ___ / /___/  /   /  /     --
--  / /__/  // ___  -'/ /__/  // /  \   // /____     / /     /  // /__/  // ____   /   /  /      --
-- /______-'/_/   \__\\_____-'/_/   /__//______/    /_/     /__//_______//_/   /__/   /__/       --
--                                                                         Gotta destroy 'em all --
---------------------------------------------------------------------------------------------------

-- Seed for early calculations
love.math.setRandomSeed(love.timer.getTime())

-- Defaults
savename="_df_score.dfight"

-- Check for existing save files and create them if they aren't there
for i=1,10 do
  if not love.filesystem.exists(i..savename) then
    -- Create save file if missing
    sfile=love.filesystem.newFile(i..savename, "w")
    if sfile then
      -- Set scores to 0
      sfile:write("0")
      sfile:close()
    end
    new=true
  end
end

if not love.filesystem.exists("cash.dfight") then
  -- Create save file if missing
  sfile=love.filesystem.newFile("cash.dfight", "w")
  if sfile then
    -- Set money to 0
    sfile:write("0")
    sfile:close()
    money=0
  end
end

if not love.filesystem.exists("frame.dfight") then
  -- Create save file if missing
  sfile=love.filesystem.newFile("frame.dfight", "w")
  if sfile then
    -- Set frame to 1
    sfile:write("1")
    sfile:close()
    plr_frame=1
  end
end

if not love.filesystem.exists("class.dfight") then
  -- Create save file if missing
  sfile=love.filesystem.newFile("class.dfight", "w")
  if sfile then
    -- Set class to Drone
    sfile:write("Drone")
    sfile:close()
    plr_class="Drone"
  end
end

-- Load save files
save={}
for i=1,10 do
  save[i]=love.filesystem.read(i..savename)
  save[i]=tonumber(save[i])
end
top=save[1]
top2=0
top_name="None"
plr_class=love.filesystem.read("class.dfight")
plr_frame=love.filesystem.read("frame.dfight")
plr_frame=tonumber(plr_frame)
money=love.filesystem.read("cash.dfight")
money=tonumber(money)

-- Window Variables
aw,ah=love.window.getDesktopDimensions()
--aw=256
--ah=640
if aw>ah then
  sw=512
  sh=(ah/aw)*sw
  portrait=false
else
  sh=512
  sw=(aw/ah)*sh
  portrait=true
end
full=true

-- Debug variables
showfps=false

-- Game Variables
t=0
td=0
px=0
py=0
mx=0
my=0
md=false
md_time=0
jx=0
jy=0
rumble1=0
rumble2=0
rumble=0
cntrl_names={"Xbox One","Dualshock 4","Arcade Stick"}
cntrl_id=1
cntrl_idn=1
cntrl_type=cntrl_names[cntrl_idn]
rv=0
bmx=2.5
tmx=5
acc=1
fc=0.01
fpsc=255
pxof=0
back_x=0
back_y=0
back_x2=0
back_y2=0
back_x3=0
back_y3=0
mode="splash"
return_to="title"
crown_sprite=1
fade=0
planet="Felino Pianeta"
english_planet="Feline Planet"
collect="Minerals"
risk=0
risk_x=0
risk_y=0
risk_amount=0
num_drone=9
num_laser=9
chars=" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]~<>" -- Font letter order
bot={}
laser={}
human=1 -- Human player index (0 for all bots)
if human<=0 then
  hb=1
else
  hb=human
end
amount=100 -- amount of drones
mhp=10
penalty=300
max=20*amount
maxpart=20*amount
gamepad_time=0
classes={"Drone","Bomber","Leopard","Eliminator"}
colours={"Striped","The Evil","Flaming","Void","Frozen","Lollipop","Sunset","Rainforest","Pink"}
colour_desc={"The classic Drone pattern.","The classic Enemy pattern.","It looks like fire.","Purple is a void colour, right?","It'll be alright, they said. Ice won't melt in space, they said.","Sugar is nice.","Gradients are cool.","Summon the parrots!","Emoji drone: [*]"}
-- MAKE THE DROOONNNEEESSSS
function make_drones(amount)
  bot={}
  for i=0,amount do
    bot[i]={0,0,0,0,0,love.math.random(1,num_drone),mhp,nil,classes[love.math.random(1,4)],0,0,nil}-- x pos, y pos, x vel, y vel, rotation, frame, hitpoints, target, class, score, penalty, target type
  end
  bot[hb]={0,0,0,0,0,plr_frame,mhp,nil,plr_class,0,0,nil}
end

make_drones(amount)

-- Camera variables
cx=0
cy=0
cxv=0
cyv=0
cxt=0
cyt=0

smoke={
  x={},
  y={},
  l={}, -- Lifetime
  type={},
  xv={},
  yv={},
  size={}
}

rock={
  x={},
  y={},
  a={}, -- Angle
  rv={}, -- Rotation velocity
  xv={},
  yv={},
  type={}
}

mineral={
  x={},
  y={},
  a={}, -- Angle
  rv={}, -- Rotation velocity
  xv={},
  yv={}
}



-----------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--  Functions  --------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------






function scalewin(scalemode)
  -- Get scale factor
  function scale()
    scw=aw/sw
    sch=ah/sh
    if sch<scw then
      sc=sch
    else
      sc=scw
    end

    wo=(aw/sc)/2-(sw/2)
    ho=(ah/sc)/2-(sh/2)
  end

  if scalemode=="integer" then
    scale()
    if sc>=1 then
      if sw>aw/math.ceil(sc) then
        sw=aw/math.floor(sc)
        sh=ah/math.floor(sc)
      else
        sw=aw/math.ceil(sc)
        sh=ah/math.ceil(sc)
      end
    end
  end
  scale()
end

scalewin("integer")

-- Make particle
function make_smoke(x,y,type,size)
  if size==nil then
    size=love.math.random(3,8)
  end
  smoke.x[#smoke.x+1]=x
  smoke.y[#smoke.y+1]=y
  smoke.l[#smoke.l+1]=love.math.random(10,60)
  smoke.type[#smoke.type+1]=type
  smoke.xv[#smoke.xv+1]=love.math.random(-20,20)/10
  smoke.yv[#smoke.yv+1]=love.math.random(-20,20)/10
  smoke.size[#smoke.size+1]=size
end

-- Delete particle
function del_smoke(i)
  table.remove(smoke.x,i)
  table.remove(smoke.y,i)
  table.remove(smoke.l,i)
  table.remove(smoke.type,i)
  table.remove(smoke.xv,i)
  table.remove(smoke.yv,i)
  table.remove(smoke.size,i)
end

-- Make asteroid
function make_rock(x,y,type)
  if type==nil then
    type=math.random(3,8)
  end
  rxv=love.math.random(-15,15)/5
  ryv=love.math.random(-15,15)/5
  if rxv==0 then
    rxv=1
  end
  if ryv==0 then
    ryv=1
  end
  rock.x[#rock.x+1]=x
  rock.y[#rock.y+1]=y
  rock.a[#rock.a+1]=love.math.random(1,360)
  rock.rv[#rock.rv+1]=love.math.random(-20,20)/15
  rock.xv[#rock.xv+1]=rxv
  rock.yv[#rock.yv+1]=ryv
  rock.type[#rock.type+1]=type
end

-- Delete asteroid
function del_rock(i)
  table.remove(rock.x,i)
  table.remove(rock.y,i)
  table.remove(rock.a,i)
  table.remove(rock.rv,i)
  table.remove(rock.xv,i)
  table.remove(rock.yv,i)
  table.remove(rock.type,i)
end

-- Make minerals
function make_mineral(x,y)
  rxv=love.math.random(-15,15)/5
  ryv=love.math.random(-15,15)/5
  if rxv==0 then
    rxv=1
  end
  if ryv==0 then
    ryv=1
  end
  mineral.x[#mineral.x+1]=x
  mineral.y[#mineral.y+1]=y
  mineral.a[#mineral.a+1]=love.math.random(1,360)
  mineral.rv[#mineral.rv+1]=love.math.random(-20,20)/15
  mineral.xv[#mineral.xv+1]=rxv
  mineral.yv[#mineral.yv+1]=ryv
end

-- Delete asteroid
function del_mineral(i)
  table.remove(mineral.x,i)
  table.remove(mineral.y,i)
  table.remove(mineral.a,i)
  table.remove(mineral.rv,i)
  table.remove(mineral.xv,i)
  table.remove(mineral.yv,i)
end

-- Key press check
function btn(s)
  if love.keyboard.isDown(s) then
    return true
  else
    return false
  end
end

-- Key press check 2
function btnp(s)
  bd=love.keyboard.isDown(s)
  if bd and not bdp then
    r=true
  else
    r=false
  end
  bdp=bd
  return r
end

-- Check for mouse press
function mousep()
  local r
  if md and not mdp then
    r=true
    if mode~="game" or pause then
      sfx(sfx_click)
    end
  else
    r=false
  end
  if md then
    mdp=true
  else
    mdp=false
  end
  return r
end

-- Get width and/or height
function w(i)
  return i:getWidth()
end

function h(i)
  return i:getHeight()
end

-- Drawing Sprites
function spr(image,x,y,rot)
  if image~=nil then
    if rot==nil then
      rot=0
      xo=0
      yo=0
    else
      xo=w(image)/2
      yo=h(image)/2
    end
    love.graphics.draw(image,x+wo,y+ho,rot,1,1,xo,yo)
  else
    love.graphics.print("Missing Sprite",x+wo,y+ho)
    print("Missing Sprite")
  end
end

-- Text_Print("To Print Text",1,1,font1,"left")
function t_print(text,x,y,fo,align)
  love.graphics.setFont(fo)
  love.graphics.printf(text,x+wo,y+ho,sw,align)
end

function sfx(sound)
  if sound~=nil then
    ac=love.audio.getSourceCount()
    if ac>0 then
      love.audio.stop(sound)
    end
    love.audio.play(sound)
  end
end

function sign(n)
  if n>0 then
    return 1
  elseif n<0 then
    return -1
  else
    return 0
  end
end

function love.keypressed(k)
  if k=="escape" then
    if mode=="game" then
      pause= not pause
    else
      love.event.quit()
    end
  end
end

function set_positions()
  for i=1,#bot do
    bx=love.math.random(0-(sw*(amount/20)),sw+(sw*(amount/20)))
    by=love.math.random(0-(sh*(amount/20)),sh+(sh*(amount/20)))
    bot[i][1]=bx
    bot[i][2]=by
  end
end




-----------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--  Loading Things  ---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------




function love.load()
  love.graphics.setDefaultFilter("linear","linear",1)
  red=love.graphics.newImage("spr/red.png")
  love.graphics.setDefaultFilter("linear","nearest",1)

  -- Logos
  shock=love.graphics.newImage("logos/shshock.png")
  cubg=love.graphics.newImage("logos/cubg.png")
  cs=love.audio.newSource("logos/cubg.wav","static")
  ss=love.audio.newSource("logos/shshock.wav","static")

  -- Fonts
  font1 = love.graphics.newImageFont("spr/font1.png",chars)
  font2 = love.graphics.newImageFont("spr/font2.png",chars)
  love.graphics.setFont(font1)

  -- Drone sprites
  num_drone=9
  Drones={}
  for i=1,num_drone do
    Drones[i]=love.graphics.newImage("spr/drone-"..i..".png")
  end
  Bombers={}
  for i=1,num_drone do
    Bombers[i]=love.graphics.newImage("spr/bomber-"..i..".png")
  end
  Leopards={}
  for i=1,num_drone do
    Leopards[i]=love.graphics.newImage("spr/leopard-"..i..".png")
  end
  Eliminators={}
  for i=1,num_drone do
    Eliminators[i]=love.graphics.newImage("spr/eliminator-"..i..".png")
  end

  -- Laser sprites
  num_laser=9
  laserd={}
  for i=1,num_laser do
    laserd[i]=love.graphics.newImage("spr/laserd-"..i..".png")
  end
  laserb={}
  for i=1,num_laser do
    laserb[i]=love.graphics.newImage("spr/laserb-"..i..".png")
  end
  lasere={}
  for i=1,num_laser do
    lasere[i]=love.graphics.newImage("spr/lasere-"..i..".png")
  end
  laserl={}
  for i=1,num_laser do
    laserl[i]=love.graphics.newImage("spr/laserl-"..i..".png")
  end

  -- Object sprites
  back={}
  for i=1,4 do
    back[i]=love.graphics.newImage("spr/stars-"..i..".png")
  end
  cntrl={love.graphics.newImage("spr/xb-one-1.png"),love.graphics.newImage("spr/ps4-1.png")}
  rocks={}
  for i=1,3 do
    rocks[i]=love.graphics.newImage("spr/asteroid-"..i..".png")
  end
  valuable=love.graphics.newImage("spr/rock.png")

  -- Menu sprites
  love.graphics.setDefaultFilter("linear","linear",1)
  title=love.graphics.newImage("spr/title.png")

  love.graphics.setDefaultFilter("linear","nearest",1)
  button={love.graphics.newImage("spr/button-play.png"),love.graphics.newImage("spr/button-score.png"),love.graphics.newImage("spr/button-options.png"),love.graphics.newImage("spr/button-exit.png"),love.graphics.newImage("spr/button-back.png")}
  arrow={}
  for i=1,4 do
    arrow[i]=love.graphics.newImage("spr/arrow-"..i..".png")
  end
  cursor=love.graphics.newImage("spr/cursor.png")
  crown={}
  for i=1,3 do
    crown[i]=love.graphics.newImage("spr/crown-"..i..".png")
  end

  -- Music
  mus_title=love.audio.newSource("mus/title.wav","stream")
  mus_title:setLooping(true)
  mus_game=love.audio.newSource("mus/retro-beat.wav","stream")
  mus_game:setLooping(true)

  -- Sounds
  sfx_laserd=love.audio.newSource("snd/laserd.wav","static")
  sfx_laserb=love.audio.newSource("snd/laserb.wav","static")
  sfx_lasere=love.audio.newSource("snd/lasere.wav","static")
  sfx_laserl=love.audio.newSource("snd/laserl.wav","static")
  sfx_click=sfx_lasere
  sfx_explode=love.audio.newSource("snd/explosion.wav","static")
  sfx_warn={love.audio.newSource("snd/warning-0.wav","static"),love.audio.newSource("snd/warning-1.wav","static")}
  sfx_block=love.audio.newSource("snd/shield.wav","static")
  sfx_hpup=love.audio.newSource("snd/hp-up.wav","static")
  sfx_powerdown=love.audio.newSource("snd/powerdown.wav","static")

  -- Window
  icon=love.image.newImageData("spr/icon.png")
  love.window.setMode(aw,ah)
  love.window.setIcon(icon)
  love.window.setTitle("Drone Fight")
  if full then
    love.window.setFullscreen(true,"desktop")
  else
    love.window.setFullscreen(false,"desktop")
  end

  -- Assign sprites and positions for Drones
  set_positions()

  -- Create asteroids
  for i=1,math.random(amount*80,amount*100) do
    make_rock(love.math.random(0-(sw*(i/100)),sw+(sw*(i/100))),love.math.random(0-(sh*(i/20)),sh+(sh*(i/20))),love.math.random(1,3))
  end

  --[[
  barframes={}
  bar=love.graphics.newImage("spr/lifebar.png")
  life=love.graphics.newImage("spr/lifebar2.png")
  for i=1,w(life) do
    barframes[i]=love.graphics.newQuad(0,0,i,h(life),life:getDimensions())
  end
  ]]

  -- Add the gamepad
  --gamepads=love.joystick.getJoysticks()
  --gamepad=gamepads[cntrl_id]

  
  screen=love.graphics.newCanvas(sw,sh)
end




-----------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--  Main Code  --------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------




function love.update(dt)
  scalewin("integer")
  -- Give time to stabilise FPS, then get FPS
  if t>120 then
    fps=love.timer.getFPS()
  else
    fps=60
  end

  -- Check for gamepad every 60 frames until there is one
  if not gamepad and t%60==0 and not mobile then
    gamepad_time=0
    gamepad=false
    gamepads=love.joystick.getJoysticks()
    if #gamepads~=0 then
      gamepad_time=120
      reason="Connected"
      --gamepad=gamepads[cntrl_id]
    end
  end

  if gamepad_time>0 then
    gamepad_time=gamepad_time-1
  end

  if love.mouse.getX()/sc-wo~=pmx or love.mouse.getY()/sc-ho~=pmy or love.mouse.isDown(1) then
    joy_mouse=false
    mobile=false
  end

    -- Get mouse or touch positions
  touch=love.touch.getTouches()
  if #touch~=0 and not joy_mouse then
    mx,my=love.touch.getPosition(touch[1])
    if #touch>1 then
      md=true
    else
      md=false
    end
  elseif not joy_mouse then
    mx=love.mouse.getX()/sc-wo
    my=love.mouse.getY()/sc-ho
    md=love.mouse.isDown(1)
  end

  touch=love.touch.getTouches() -- Touch takes priority over mouse
  if #touch~=0 and touch[1]~=nil then
    mx,my=love.touch.getPosition(touch[1])
    mx=mx/sc-wo
    my=my/sc-ho
    md=true
  end

  -- Gamepad indexes
  if btnp("0") then
    cntrl_id=0
  elseif btnp("1") then
    cntrl_id=1
  elseif btnp("2") then
    cntrl_id=2
  elseif btnp("3") then
    cntrl_id=3
  elseif btnp("4") then
    cntrl_id=4
  elseif btnp("5") then
    cntrl_id=5
  elseif btnp("6") then
    cntrl_id=6
  elseif btnp("7") then
    cntrl_id=7
  elseif btnp("8") then
    cntrl_id=8
  elseif btnp("9") then
    cntrl_id=9
  end

  if cntrl_id<0 then
    cntrl_id=0
  end
  if cntrl_id>#gamepads then
    cntrl_id=#gamepads
  end
  --gamepad=gamepads[cntrl_id]

  -- Gamepad takes priority over all
  if gamepad and human~=0 then
    tjx,tjy,lt,trx,try,rt=gamepad:getAxes()
    if tjx~=nil and tjy~=nil then

      if cntrl_idn<1 then
        cntrl_idn=1
      end
      if cntrl_idn>#cntrl_names then
        cntrl_idn=#cntrl_names
      end
      cntrl_type=cntrl_names[cntrl_idn]

      if cntrl_id~=0 then

        if rumble1>0 or rumble2>0 then -- Rumble
          rumble1=rumble1-100*dt
          rumble2=rumble2-100*dt
          gamepad:setVibration(rumble1/10,rumble2/10)
        else
          rumble1=0
          rumble2=0
          gamepad:setVibration(0,0)
        end
        jr=0.12 -- Gamepad deadzone
        tlx,tly,lt,trx,try,rt=gamepad:getAxes()
        if trx==nil then
          trx=0
        end
        if try==nil then
          try=0
        end
        if tlx<-jr or tlx>jr or tly<-jr or tly>jr then -- Left analog has priority
          jx=tlx
          jy=tly
          analog_move=true
          joy_mouse=true
        elseif trx<-jr or trx>jr or try<-jr or try>jr then -- Right analog
          jx=trx
          jy=try
          analog_move=true
          joy_mouse=true
        else
          if mode~="game" then
            jx=0
            jy=0
          end
          analog_move=false
        end
        -- Set mouse position based on analog
        if mode=="game" and joy_mouse and not pause then
          mx=(sw/2)+(jx*50)
          my=(sh/2)+(jy*50)
        else
          mx=mx+jx*4
          my=my+jy*4
          if mx<0 then
            mx=0
          elseif mx>sw then
            mx=sw
          end
          if my<0 then
            my=0
          elseif my>sh then
            my=sh
          end
        end
        -- Set buttons
        btnp_acc=btn_acc
        btnp_fire=btn_fire
        btnp_start=btn_start
        btnp_showfps=btn_showfps
        if cntrl_type==cntrl_names[1] then -- Xbox one bindings
          btn_acc=gamepad:isDown(1,2)
          btn_fire=gamepad:isDown(3,4,5,6,9)
          btn_showfps=gamepad:isDown(7) -- Select
          btn_start=gamepad:isDown(8) -- Start
        elseif cntrl_type==cntrl_names[2] then -- PS4 bindings
          btn_acc=gamepad:isDown(2,3)
          btn_fire=gamepad:isDown(1,4,5,6,11)
          btn_start=gamepad:isDown(10)--?
        else                                  -- Generic controller bindings
          btn_acc=gamepad:isDown(1,2,3,4)
          btn_fire=gamepad:isDown(5,6,9)
          btn_start=gamepad:isDown(8)
        end

        if not btn_fire and (lt~=nil and rt~=nil) then
          if rt>0.3 or lt>0.3 then
            btn_fire=true
          end
        end
      end
    else
      gamepad_time=120
      reason="Disconnected"
      joy_mouse=false
      gamepad=nil
    end
  else
    rumble1=0
    rumble2=0
    btn_acc=false
    btn_fire=false
    btnp_fire=false
  end

  if btn_showfps and not btnp_showfps then
    showfps = not showfps
  end

  if md or btn_fire then
    md_time=md_time+1
  else
    md_time=0
  end

  if mode=="splash" then
    if math.floor(t)==30 then
      sfx(cs)
    end
    if math.floor(t)==60 then
      sfx(sfx_laserl)
    end
    if math.floor(t)==90 then
      sfx(ss)
    end
    if math.floor(t)==120 then
      sfx(sfx_laserb)
    end
    if t>300 or mousep() or btn_start then
      current_mus=mus_title
      sfx(current_mus)
      mode="title"
    end

  elseif mode=="title" then
    if (mousep() or (btn_fire and not btnp_fire) or (btn_acc and not btnp_acc)) and mx>64 and mx<64+w(button[1]) then
      if my<sh/2-h(button[1])-24 and my>sh/2-h(button[1])*2-24 then
        love.audio.stop(current_mus)
        current_mus=mus_game
        sfx(current_mus)
        make_drones(amount)
        set_positions()
        pause=false
        mode="game"
      elseif my<sh/2-8 and my>sh/2-h(button[1])-8 then
        mode="score"
        return_to="title"
      elseif my>sh/2+8 and my<sh/2+h(button[1])+8 then
        mode="menu"
      elseif my>sh/2+h(button[1])+24 and my<sh/2+h(button[1])*2+24 then
        love.audio.stop(current_mus)
        love.event.quit()
      end
    end

  elseif mode=="score" then
    if mousep() or (btn_fire and not btnp_fire) or (btn_acc and not btnp_acc) then
      mode=return_to
    end

  elseif mode=="menu" then
    if mousep() or (btn_fire and not btnp_fire) or (btn_acc and not btnp_acc) then
      plr_frame=bot[hb][6]
      plr_class=bot[hb][9]
      plr_save=tostring(plr_frame)
      love.filesystem.write("frame.dfight",plr_save)
      love.filesystem.write("class.dfight",plr_class)
      if mx<w(button[5]) and my>sh-h(button[5]) then
        mode="title"
      end
      if mx<sw/2+16 and mx>sw/2-16 and my>sh/2-48 and my<sh/2-32 then
        if bot[hb][9]=="Bomber" then
          bot[hb][9]="Drone"
        elseif bot[hb][9]=="Drone" then
          bot[hb][9]="Leopard"
        elseif bot[hb][9]=="Leopard" then
          bot[hb][9]="Eliminator"
        elseif bot[hb][9]=="Eliminator" then
          bot[hb][9]="Bomber"
        end
      end
      if mx<sw/2+16 and mx>sw/2-16 and my>sh/2+32 and my<sh/2+48 then
        if bot[hb][9]=="Bomber" then
          bot[hb][9]="Eliminator"
        elseif bot[hb][9]=="Eliminator" then
          bot[hb][9]="Leopard"
        elseif bot[hb][9]=="Leopard" then
          bot[hb][9]="Drone"
        elseif bot[hb][9]=="Drone" then
          bot[hb][9]="Bomber"
        end
      end
      if mx<sw/2-32 and mx>sw/2-48 and my>sh/2-16 and my<sh/2+16 then
        bot[hb][6]=bot[hb][6]-1
      end
      if mx>sw/2+32 and mx<sw/2+48 and my>sh/2-16 and my<sh/2+16 then
        bot[hb][6]=bot[hb][6]+1
      end
      if bot[hb][6]<1 then
        bot[hb][6]=num_drone
      end
      if bot[hb][6]>num_drone then
        bot[hb][6]=1
      end
    end

  elseif mode=="game" then
    if pause then
      if mousep() or (btn_fire and not btnp_fire) or (btn_acc and not btnp_acc) then
        if mx>sw/2-w(button[1])/2 and mx<sw/2+w(button[1])/2 then
          if my<sh/2-48 and my>sh/2-80 then
            pause=false
          elseif my<sh/2+16 and my>sh/2-16 then
            mode="score"
            return_to="game"
          elseif my<sh/2+80 and my>sh/2+48 then
            mode="title"
            love.audio.stop(current_mus)
            current_mus=mus_title
            sfx(current_mus)
            plr_money=tostring(money)
            love.filesystem.write("cash.dfight",plr_money)
          end
        end
      end
    else

      -- Set Camera
      cxt=bot[1][1]-sw/2
      cyt=bot[1][2]-sh/2
      mx=mx+cx
      my=my+cy

      -- Control for particles
      for i=1,#smoke.x do
        if smoke.x[i]~=nil then
          smoke.xv[i]=smoke.xv[i]+love.math.random(-0.1,0.1)*100*dt
          smoke.yv[i]=smoke.yv[i]-love.math.random(-0.1,0.1)*100*dt
          smoke.l[i]=smoke.l[i]-1
          smoke.x[i]=smoke.x[i]+smoke.xv[i]*100*dt
          smoke.y[i]=smoke.y[i]+smoke.yv[i]*100*dt
          if smoke.l[i]<=0 then
            del_smoke(i)
          end
        end
        if #smoke.x>maxpart then
          del_smoke(1)
        end
      end

      -- Control for minerals
      for i=1,#mineral.x do
        if mineral.x~=nil and mineral.y~=nil and mineral.xv~=nil and mineral.yv~=nil and mineral.a~=nil and mineral.rv~=nil then
          if mineral.x[i]-cx<sw+16 and mineral.x[i]-cx>-16 and mineral.y[i]-cy<sw+16 and mineral.y[i]-cy>-16 then
            if love.math.random(0,10)==1 then
              make_smoke(mineral.x[i],mineral.y[i],2)
            end
            if mineral.xv[i]<0 then
              mineral.xv[i]=mineral.xv[i]+fc*100*dt
            elseif rock.xv[i]>0 then
              mineral.xv[i]=mineral.xv[i]-fc*100*dt
            end
            if mineral.yv[i]<0 then
              mineral.yv[i]=mineral.xv[i]+fc*100*dt
            elseif mineral.yv[i]>0 then
              mineral.yv[i]=mineral.yv[i]-fc*100*dt
            end
            mineral.x[i]=mineral.x[i]+mineral.xv[i]*100*dt
            mineral.y[i]=mineral.y[i]+mineral.yv[i]*100*dt
            mineral.rv[i]=(mineral.xv[i]+mineral.yv[i])/50
            rmx=1
            if mineral.rv[i]>rmx then
              mineral.rv[i]=rmx
            elseif mineral.rv[i]<-rmx then
              mineral.rv[i]=-rmx
            end
            mineral.a[i]=mineral.a[i]+mineral.rv[i]*100*dt
            rng=10

            for i2=1,#rock.x do
              if rock.x[i2]~=nil and rock.x[i2]~=i then -- Bounce off of asteroids
                if mineral.x[i]<rock.x[i2]+rng and mineral.x[i]>rock.x[i2]-rng and mineral.y[i]<rock.y[i2]+rng and mineral.y[i]>rock.y[i2]-rng then
                  mineral.xv[i]=-mineral.xv[i]
                  mineral.yv[i]=-mineral.yv[i]
                  rock.xv[i2]=-rock.xv[i2]
                  rock.yv[i2]=-rock.yv[i2]
                end
              end
            end

            for il=1,#laser do -- Destroy lasers
              if laser[il]~=nil then
                lx=laser[il][1]
                ly=laser[il][2]
                lxv=laser[il][3]
                lyv=laser[il][4]
                own=laser[il][7]
                if mineral.x[i]<lx+rng and mineral.x[i]>lx-rng and mineral.y[i]<ly+rng and mineral.y[i]>ly-rng then
                  for amount=0,math.random(4,6) do
                    make_smoke(mineral.x[i],mineral.y[i],0)
                  end
                  table.remove(laser,il)
                end
              end
            end

            mineral_speed=0.15
            mineral_max=1.5
            for ib=1,#bot do
              if bot[ib]~=nil then
                if bot[ib][11]==0 then
                  bx=bot[ib][1]
                  by=bot[ib][2]
                  if mineral.x[i]<bx+rng*10 and mineral.x[i]>bx-rng*10 and mineral.y[i]<by+rng*10 and mineral.y[i]>by-rng*10 then
                    angle=-math.atan2((mineral.x[i]-bx),(mineral.y[i]-by))
                    mineral_vx=-math.sin(-angle)*2.5
                    mineral_vy=-math.cos(-angle)*2.5
                    if (mineral_vx<0 and mineral.x[i]<bx) or (mineral_vx>0 and mineral.x[i]>bx) then
                      mineral_vx=mineral_vx*3
                    end
                    if (mineral_vy<0 and mineral.y[i]<by) or (mineral_vy>0 and mineral.y[i]>by) then
                      mineral_vy=mineral_vy*3
                    end
                    mineral.x[i]=mineral.x[i]+mineral_vx*100*dt
                    mineral.y[i]=mineral.y[i]+mineral_vy*100*dt

                  end
                end
              end
            end
          end
        end
      end

      -- Control for asteroids
      for i=1,#rock.x do
        if rock.x~=nil then
          if rock.x[i]-cx<sw+16 and rock.x[i]-cx>-16 and rock.y[i]-cy<sw+16 and rock.y[i]-cy>-16 then
            if rock.xv[i]<0 then
              rock.xv[i]=rock.xv[i]+fc*100*dt
            elseif rock.xv[i]>0 then
              rock.xv[i]=rock.xv[i]-fc*100*dt
            end
            if rock.yv[i]<0 then
              rock.yv[i]=rock.xv[i]+fc*100*dt
            elseif rock.yv[i]>0 then
              rock.yv[i]=rock.yv[i]-fc*100*dt
            end
            rock.x[i]=rock.x[i]+rock.xv[i]*100*dt
            rock.y[i]=rock.y[i]+rock.yv[i]*100*dt
            rock.rv[i]=(rock.xv[i]+rock.yv[i])/50
            rmx=0.5
            if rock.rv[i]>rmx then
              rock.rv[i]=rmx
            elseif rock.rv[i]<-rmx then
              rock.rv[i]=-rmx
            end
            rock.a[i]=rock.a[i]+rock.rv[i]*100*dt
            rng=rock.type[i]*6

            for i2=1,#rock.x do
              if rock.x[i2]~=nil and rock.x[i2]~=i then -- Bounce off other asteroids
                if rock.x[i]<rock.x[i2]+rng and rock.x[i]>rock.x[i2]-rng and rock.y[i]<rock.y[i2]+rng and rock.y[i]>rock.y[i2]-rng then
                  rock.xv[i]=-rock.xv[i]
                  rock.yv[i]=-rock.yv[i]
                  rock.xv[i2]=-rock.xv[i2]
                  rock.yv[i2]=-rock.yv[i2]
                end
              end
            end

            for il=1,#laser do
              if laser[il]~=nil then
                lx=laser[il][1]
                ly=laser[il][2]
                lxv=laser[il][3]
                lyv=laser[il][4]
                own=laser[il][7]
                if rock.x[i]<lx+rng and rock.x[i]>lx-rng and rock.y[i]<ly+rng and rock.y[i]>ly-rng then
                  for amount=0,math.random(4,6) do
                    make_smoke(rock.x[i],rock.y[i],0)
                  end
                  rock.xv[i]=lxv/2
                  rock.yv[i]=lyv/2
                  table.remove(laser,il)
                  make_mineral(rock.x[i],rock.y[i])
                  rock.y[i]=rock.y[i]+rng
                  if rock.type[i]==3 then
                    rock.type[i]=2
                  elseif rock.type[i]==2 then
                    rock.type[i]=1
                  else
                    make_rock(love.math.random(0-(sw*(amount/10)),sw+(sw*(amount/10))),love.math.random(0-(sh*(amount/20)),sh+(sh*(amount/20))),love.math.random(1,3))
                    del_rock(i)
                  end
                end
              end
            end

            for ib=1,#bot do
              if bot[ib]~=nil then
                bx=bot[ib][1]
                by=bot[ib][2]
                bxv=bot[ib][3]
                byv=bot[ib][4]
                if rock.x[i]<bx+rng and rock.x[i]>bx-rng and rock.y[i]<by+rng and rock.y[i]>by-rng then
                  rock.xv[i]=bxv/1.2
                  rock.yv[i]=byv/1.2
                  bxv=-bxv/1.2
                  byv=-byv/1.2
                  bx=bx+bxv*100*dt
                  by=by+byv*100*dt
                  rock.x[i]=rock.x[i]+rock.xv[i]*100*dt
                  rock.y[i]=rock.y[i]+rock.yv[i]*100*dt
                  for i2=0,love.math.random(8,12) do
                    make_smoke(bx,by,2,love.math.random(1,2)) -- Pretty sparkles
                  end
                end
                bot[ib][1]=bx
                bot[ib][2]=by
                bot[ib][3]=bxv
                bot[ib][4]=byv
              end
            end
          end
        end
      end

      -- Control for all the Drones (Including player; everyone must be equal)
      for i=1,#bot do -- 1,3 = x,xv | 2,4 = y,yv | 5,6 = r,f
        if bot[i]~=nil then
          bxv=bot[i][3]
          byv=bot[i][4]
          bx=bot[i][1]
          by=bot[i][2]
          r=bot[i][5]
          f=bot[i][6]
          bhp=bot[i][7]
          target=bot[i][8]
          class=bot[i][9]
          score=bot[i][10]
          dtime=bot[i][11]
          target_type=bot[i][12]

          if dtime==0 then

            -- Get a new target if there is no target or target is self
            if target==nil or target==i or target_type==nil then
              if love.math.random(1,2)==1 and top~=0 then
                target=top2
                target_type="bot"
              elseif love.math.random(1,2)==1 then
                target=love.math.random(1,#bot)
                target_type="bot"
              else
                newt=love.math.random(1,#mineral.x)
                if mineral.x[newt]~=nil then
                  target=newt
                  target_type="rock"
                else
                  target=love.math.random(1,#bot)
                  target_type="bot"
                end
              end
            end

            -- Find a new target if the current one is defeated
            if target~=nil and target>0 and target<#bot and target_type=="bot" then
              if bot[target][11]<=60 and bot[target][11]>0 then
                target=love.math.random(1,#bot)
              end
            end

            -- Find a specific asteroid
            if target_type=="rock" then
              if target>#mineral.x then
                target=#mineral.x
              end
              if target<1 then
                target=1
              end
            end

            -- Set target to go towards
            if i==human then
              tx=mx
              ty=my
            else
              if target_type=="bot" then
                if bot[target]~=nil then
                  tx=bot[target][1]
                  ty=bot[target][2]
                else
                  tx=0
                  ty=0
                end
              else
                tx=mineral.x[target]
                ty=mineral.y[target]
              end
            end

            -- Rotation
            r=-math.atan2(bx-tx,by-ty)

            -- Accelerate towards target
            if ((i==human and (btn("space") or btn_acc or analog_move)) or (i~=human and love.math.random(0,2)<2)) then
              if class=="Bomber" then -- Slow but strong
                acc=0.8
                bmx=2.2
              elseif class=="Leopard" then -- Speedy Leopard, good for chasing
                acc=1.5
                bmx=4.5
              elseif class=="Eliminator" then -- RAPID FIRE PEWPEWPEW
                acc=1
                bmx=2.8
              else
                acc=1
                bmx=3.2
              end

              vx=-acc*math.sin(-r)/10
              vy=-acc*math.cos(-r)/10

              -- Horizontal
              if vx<0 and bxv>-bmx then
                bxv=bxv+vx*100*dt
              elseif vx>0 and bxv<bmx then
                bxv=bxv+vx*100*dt
              end
              -- Vertical
              if vy<0 and byv>-bmx then
                byv=byv+vy*100*dt
              elseif vy>0 and byv<bmx then
                byv=byv+vy*100*dt
              end
            else
              -- Friction
              if bxv>0 then
                bxv=bxv-fc*100*dt
              end
              if bxv<0 then
                bxv=bxv+fc*100*dt
              end
              if byv>0 then
                byv=byv-fc*100*dt
              end
              if byv<0 then
                byv=byv+fc*100*dt
              end
              -- Stop when barely moving
              if math.abs(bxv)<fc*100*dt then
                bxv=0
              end
              if math.abs(byv)<fc*100*dt then
                byv=0
              end
            end

            -- Bounce against other Drones
            for i2=1,#bot do
              if bot[i2]~=nil and bot[i2]~=bot[i] and bot[i2][11]==0 then
                blx=bot[i2][1]
                bly=bot[i2][2]
                bhp2=bot[i2][7]
                brng=7
                if bx<blx+brng and bx>blx-brng and by<bly+brng and by>bly-brng then
                  if i==human then
                    rumble1=20 -- Controller rumble
                    rumble=20
                  end
                  for i=0,love.math.random(8,12) do
                    make_smoke(bx,by,2,love.math.random(1,2)) -- Pretty sparkles
                  end
                  bhp=bhp-math.abs(bxv+byv)/10
                  if i==human or (i==1 and human==0) and bhp>0 then -- Play warning sound on low hp
                    if bhp<mhp/5 and bhp>0 then
                      sfx(sfx_warn[2])
                    elseif bhp<mhp/2 and bhp>0 then
                      sfx(sfx_warn[1])
                    end
                  end
                  bhp2=bhp2-math.abs(bxv+byv)/10
                  bxv=-bxv*1.2
                  byv=-byv*1.2
                  target=i2 -- Gain aggression
                  last_dmg=i2
                end
                bot[i2][7]=bhp2
              end
            end

            -- True speed limit
            if bxv>tmx then bxv=tmx end
            if bxv<-tmx then bxv=-tmx end
            if byv>tmx then byv=tmx end
            if byv<-tmx then byv=-tmx end

            -- Update Position
            bx=bx+bxv*100*dt
            by=by+byv*100*dt

            -- Shoot Lasers Randomly (or when player clicks)
            lsp=2 -- Lumpy space prince
            if (i==human and (mousep() or (btn_fire and not btnp_fire))) or (i==human and md_time%16/8==0 and (md or btn_fire)) or (i==human and class=="Eliminator" and (md or btn_fire) and md_time%6/3==0) or (i~=human and love.math.random(0,50)==0) or (i~=human and class=="Eliminator" and love.math.random(0,10)==0) then
              laser[#laser+1]={bx,by,((-2*math.sin(-r))*lsp)+bxv/2,((-2*math.cos(-r))*lsp)+byv/2,r,0,i,bot[i][6]}-- x pos, y pos, x vel, y vel, rotation, life, owner, colour
              if bot[i][1]-cx>-32-wo and bot[i][1]-cx<sw+32+wo and bot[i][2]-cy>-32-ho and bot[i][2]-cy<sh+32+ho then
                if bot[hb][11]==0 then
                  if class=="Bomber" then
                    sfx(sfx_laserb)
                  elseif class=="Eliminator" then
                    sfx(sfx_lasere)
                  elseif class=="Leopard" then
                    sfx(sfx_laserl)
                  else
                    sfx(sfx_laserd)
                  end
                end
                if i==human then
                  rumble2=25 -- Controller rumble
                end
              end
            end

            -- Collect minerals
            for i2=1,#mineral.x do
              if mineral.x[i2]~=nil then
                if mineral.x[i2]<bx+rng and mineral.x[i2]>bx-rng and mineral.y[i2]<by+rng and mineral.y[i2]>by-rng then
                  score=score+1
                  for a=0,math.random(4,6) do
                    make_smoke(mineral.x[i2],mineral.y[i2],2)
                  end
                  if i==hb then
                    sfx(sfx_hpup)
                  end
                  del_mineral(i2)
                end
              end
            end

            -- Emit smoke when damaged
            if bhp<=mhp/3 then
              if t%10/5==1 then
                make_smoke(bx,by)
              end
            elseif bhp<=mhp/2 then
              if t%20/10==1 then
                make_smoke(bx,by)
              end
            end
          end

          -- Explode when out of health
          if bhp<=0 then
            bhp=0
            if dtime==0 then
              if bot[i][1]-cx>-32-wo and bot[i][1]-cx<sw+32+wo and bot[i][2]-cy>-32-ho and bot[i][2]<sh+32+ho then
                if i==human then
                  rumble1=60 -- Controller rumble
                  rumble2=60
                  rumble=60 -- Screen shake
                end
                if bot[hb][11]==0 then
                  sfx(sfx_explode)
                end
              end
              for i=0,math.random(2,5) do -- Boom!
                make_smoke(bx,by,0)
                make_smoke(bx,by,1)
              end
              for i=1,math.floor(score/3) do -- Lose about a third of your minerals
                make_mineral(bx,by)
              end
              score=math.ceil(score/3)*2

              newt=love.math.random(1,#bot-1)
              if bot[newt][7]<bot[target][7] then
                target=newt
                target_type="bot"
              end
              dtime=penalty
              if i==human then
                love.audio.stop(current_mus)
                sfx(sfx_powerdown)
              end
            end
            dtime=dtime-60*dt
            if dtime<=0 then
              dtime=0
              bx=love.math.random(0-(sw*(amount/20)),sw+(sw*(amount/20))) -- Go somewhere
              by=love.math.random(0-(sh*(amount/20)),sh+(sh*(amount/20)))
              bhp=mhp
              if i==human then
                current_mus=mus_game
                sfx(current_mus)
              end
            end
          end

          bot[i][3]=bxv -- x velocity
          bot[i][4]=byv -- y velocity
          bot[i][1]=bx -- change x
          bot[i][2]=by -- change y
          bot[i][5]=r -- rotation
          bot[i][6]=f -- frame
          bot[i][7]=bhp -- hitpoints
          bot[i][8]=target -- target
          bot[i][9]=class -- class
          bot[i][10]=score -- score
          bot[i][11]=dtime -- death penalty
          bot[i][12]=target_type
        end
      end

      -- Control for lasers
      if #laser>0 then
        for i=1,#laser do
          if laser[i]~=nil then
            lxv=laser[i][3]
            lyv=laser[i][4]
            lx=laser[i][1]
            ly=laser[i][2]
            r=laser[i][5]
            l=laser[i][6]
            own=laser[i][7]
            col=laser[i][8]

            lx=lx+lxv*100*dt
            ly=ly+lyv*100*dt

            r=-math.atan2(lx-(lx+lxv),ly-(ly+lyv))

            l=l+1

            laser[i][3]=lxv -- x velocity
            laser[i][4]=lyv -- y velocity
            laser[i][1]=lx -- change x
            laser[i][2]=ly -- change y
            laser[i][5]=r -- rotation
            laser[i][6]=l -- life
            laser[i][7]=own -- owner
            laser[i][8]=col -- colour

            if l>255 then table.remove(laser,i) end
            for i2=1,#bot do
              if bot[i2]~=nil and i2~=own and bot[i2][11]==0 then
                bx=bot[i2][1]
                by=bot[i2][2]
                bxv=bot[i2][3]
                byv=bot[i2][4]
                bhp=bot[i2][7]
                target=bot[i2][8]
                lrng=6
                if lx>bx-lrng and lx<bx+lrng and ly>by-lrng and ly<by+lrng then
                  if i2==human or (i2==1 and human==0) and bhp>0 then
                    if bot[hb][11]==0 then
                      sfx(sfx_block)
                    end
                    rumble1=25 -- Controller rumble
                    rumble=25
                  end
                  table.remove(laser,i)
                  if bot[own][9]=="Leopard" then
                    bhp=bhp-0.6
                  elseif bot[own][9]=="Bomber" then
                    bhp=bhp-1.4
                  elseif bot[own][9]=="Eliminator" then
                    bhp=bhp-0.4
                  else
                    bhp=bhp-1
                  end
                  for i=0,love.math.random(2,4) do
                    make_smoke(bx,by,0)
                  end
                  if i2==human or (i2==1 and human==0) and bhp>0 then -- Play warning sound on low hp
                    if bhp<mhp/5 and bhp>0 then
                      sfx(sfx_warn[2])
                    elseif bhp<mhp/2 and bhp>0 then
                      sfx(sfx_warn[1])
                    end
                  end
                  bxv=lxv/1.2
                  byv=lyv/1.2
                  target=own -- Gain aggression
                  target_type="bot"
                  if bhp<=0 then
                    bot[own][10]=bot[own][10]+1
                  end
                end
                bot[i2][1]=bx
                bot[i2][2]=by
                bot[i2][3]=bxv
                bot[i2][4]=byv
                bot[i2][7]=bhp
                bot[i2][8]=target
                bot[i2][12]=target_type
              end
            end
          end
        end
      end

      -- Update camera position
      cx=(bot[hb][1]-sw/2)
      cy=(bot[hb][2]-sh/2)

      -- Screen shake
      if rumble>0 then
        rumble=rumble-1
        strength=20
        pxof=love.math.random(-strength,strength)/10
      else
        rumble=0
        pxof=0
      end

      -- Crown animations
      crown_sprite=crown_sprite+10*dt
      if crown_sprite>#crown+1 then
        crown_sprite=1
      end
    end

    -- FPS adjustments for speeeeeeeeeeeddddd
    fpsc=(fps/60)*(255)

    if t>120 then -- Give time to stabilise FPS
      if fps>65 then
        maxpart=maxpart+0.1
        if max<amount*25 then
          max=max+1
        end
      elseif fps<60 then
        if maxpart>0 then -- Maximum Particles
          maxpart=maxpart-math.ceil(60-fps)
        else
          maxpart=0
        end
        if max>amount then -- Maximum Lasers
          max=max-math.ceil(60-fps)
        else
          max=amount
        end
      end
    end
  else
    print("Mode is not set, going to title screen")
    mode="title"
  end

  t=t+60*dt

  pmx=love.mouse.getX()/sc-ho
  pmy=love.mouse.getY()/sc-ho
end




-----------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--  Le Artist  --------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------




function love.draw()
  love.graphics.setCanvas(screen) -- internal screen
  love.graphics.clear()
  love.graphics.setColor(255,255,255)
  love.graphics.setBlendMode("alpha")

  if not pause then
    love.graphics.translate(pxof*love.math.random(-1,1),pxof*love.math.random(-1,1))
  end
  love.graphics.setColor(255,255,255)

  if mode=="splash" then
    back_x=0
    back_y=0
    back_x2=0
    back_y2=0
    back_x3=0
    back_y3=0

  elseif mode=="title" or mode=="menu" or mode=="score" then
    back_x=0
    back_y=back_y+0.1
    back_x2=0
    back_y2=back_y2+0.3
    back_x3=0
    back_y3=back_y3+0.5

  elseif mode=="game" then
    back_x=cx/2.2
    back_y=cy/2.2
    back_x2=cx/1.8
    back_y2=cy/1.8
    back_x3=cx/1.8
    back_y3=cy/1.4
  end

  -- Draw background
  if fps>=50 then -- Complex math to scroll layered background at any resolution (in theory)
    for ix=(-wo/w(back[2])),math.floor(sw/w(back[2]))+(wo/w(back[2]))+math.ceil(sc) do
      for iy=(-ho/h(back[2])),math.floor(sh/h(back[2]))+(ho/h(back[2]))+math.ceil(sc) do
        spr(back[2],ix*w(back[2])-back_x%w(back[2]),iy*h(back[2])-back_y%w(back[2]))
      end
    end
    for ix=(-wo/w(back[3])),math.floor(sw/w(back[3]))+(wo/w(back[3]))+math.ceil(sc) do
      for iy=(-ho/h(back[3])),math.floor(sh/h(back[3]))+(ho/h(back[3]))+math.ceil(sc) do
        spr(back[3],ix*w(back[3])-back_x2%w(back[3]),iy*h(back[3])-back_y2%w(back[3]))
      end
    end
    for ix=(-wo/w(back[4])),math.floor(sw/w(back[4]))+(wo/w(back[4]))+math.ceil(sc) do
      for iy=(-ho/h(back[4])),math.floor(sh/h(back[4]))+(ho/h(back[4]))+math.ceil(sc) do
        spr(back[4],ix*w(back[4])-back_x3%w(back[4]),iy*h(back[4])-back_y3%w(back[4]))
      end
    end
   else -- Standard background
    for ix=(-wo/w(back[1])),math.floor(sw/w(back[1]))+(wo/w(back[1]))+math.ceil(sc) do
      for iy=(-ho/h(back[1])),math.floor(sh/h(back[1]))+(ho/h(back[1]))+math.ceil(sc) do
        spr(back[1],ix*w(back[1])-back_x%w(back[1]),iy*h(back[1])-back_y%w(back[1]))
      end
    end
  end

  title_rotate=math.rad(math.sin(t/128)*5)
  title_scale=0.5+math.sin(t/156)/20 -- Draw title logo

  if mode=="splash" then
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill",0,0,sw,sh)
    love.graphics.setColor(255,255,255)
    if portrait then
      if t>30 then
        love.graphics.draw(shock,sw/2+wo,sh/2-128+ho,-math.rad(math.sin(t/70)*3),(t-30)/100,(t-30)/100,w(shock)/2,h(shock)/2)
      end
      if t>90 then
        love.graphics.draw(cubg,sw/2+wo,sh/2+128+ho,math.rad(math.sin(t/70)*3),(t-90)/80,(t-90)/80,w(cubg)/2,h(cubg)/2)
      end
    else
      if t>30 then
        love.graphics.draw(shock,sw/2-128+wo,sh/2+ho,-math.rad(math.sin(t/70)*3),(t-30)/100,(t-30)/100,w(shock)/2,h(shock)/2)
      end
      if t>90 then
        love.graphics.draw(cubg,sw/2+128+wo,sh/2+ho,math.rad(math.sin(t/70)*3),(t-90)/80,(t-90)/80,w(cubg)/2,h(cubg)/2)
      end
    end
    if t>60 then
      t_print("And",0,sh/2+3,font2,"center")
    end
    if t>120 then
      t_print("Present:",0,sh-48,font2,"center")
    end
    if t>240 then
      fade=fade+10
      love.graphics.setColor(0,0,0,fade)
      love.graphics.rectangle("fill",0,0,sw,sh)
    end

  elseif mode=="title" then
    if portrait then
      for i=1,4 do -- Draw menu buttons
        spr(button[i],sw/2-w(button[i])/2,sh/2-((h(button[i])+32)*2)+i*h(button[i])+i*16-8)
      end
      love.graphics.draw(title,(sw/2),64+ho,title_rotate,title_scale/2,title_scale/2,w(title)/2,h(title)/2)
    else
      for i=1,4 do -- Draw menu buttons
        spr(button[i],(sw/10),sh/2-((h(button[i])+32)*2)+i*h(button[i])+i*16-8)
      end
      love.graphics.draw(title,(sw/2)+(sw/5)+wo,sh/2+ho+math.tan(t/100)*5,title_rotate,title_scale,title_scale,w(title)/2,h(title)/2)
    end

    if fade>0 then
      if fade>255 then
        fade=255
      end
      fade=fade-5
      love.graphics.setColor(0,0,0,fade)
      love.graphics.rectangle("fill",0,0,sw,sh)
    else
      fade=0
    end

  elseif mode=="score" then
    love.graphics.draw(title,sw/2+wo+math.tan(t/100)*5,h(title)/2-16,title_rotate,title_scale,title_scale,w(title)/2,h(title)/2)
    if portrait then
      for i=1,10 do
        love.graphics.setColor(i*30,255-i*30,50)
        t_print(i..": "..save[i].." "..collect,0,math.floor(96+i*32),font2,"center")
      end
    else
      for i=1,5 do
        love.graphics.setColor(i*30,255-i*30,50)
        t_print(i..": "..save[i].." "..collect,-sw/4,math.floor(sh/4+i*32),font2,"center")
      end
      for i=6,10 do
        love.graphics.setColor(i*30,255-i*30,50)
        t_print(i..": "..save[i].." "..collect,sw/4,math.floor(sh/4+(i-5)*32),font2,"center")
      end
    end
    love.graphics.setColor(0,255,50)
    if mobile then
      t_print("Touch to go back",0,sh-32,font2,"center")
    elseif gamepad then
      t_print("Press a button to go back",0,sh-32,font2,"center")
    else
      t_print("Click to go back",0,sh-32,font2,"center")
    end

  elseif mode=="menu" then
    love.graphics.draw(title,sw/2+wo+math.tan(t/100)*5,h(title)/2-16,title_rotate,title_scale,title_scale,w(title)/2,h(title)/2)

    -- Descriptions and sprites for drones
    if bot[hb][9]=="Drone" then
      spt=Drones[bot[hb][6]]
      t_print("The Drone is your standard all-rounder with medium speed and firepower.",0,sh-sh/9,font1,"center")
    elseif bot[hb][9]=="Bomber" then
      spt=Bombers[bot[hb][6]]
      t_print("The Bomber is slow, but its lasers deal a large amount of damage.",0,sh-sh/9,font1,"center")
    elseif bot[hb][9]=="Eliminator" then
      spt=Eliminators[bot[hb][6]]
      t_print("The Eliminator is slow and its lasers do low damage, but it has a rapid fire rate.",0,sh-sh/9,font1,"center")
    elseif bot[hb][9]=="Leopard" then
      spt=Leopards[bot[hb][6]]
      t_print("The Leopard is a quick drone and it can even outrun some lasers, however its own firepower is pretty low.",0,sh-sh/9,font1,"center")
    else
      spt=laserd[1]
      t_print("Missing Drone",0,sh-sh/9,font2,"center")
    end

    t_print(colours[bot[hb][6]].." "..bot[hb][9].."\n"..colour_desc[bot[hb][6]],0,sh-sh/5,font2,"center")

    love.graphics.draw(spt,sw/2,sh/2,math.rad(t),2,2,8,8)

    spr(arrow[1],sw/2-16,sh/2-48)
    spr(arrow[2],sw/2+32,sh/2-16)
    spr(arrow[3],sw/2-48,sh/2-16)
    spr(arrow[4],sw/2-16,sh/2+32)

    if gamepad then
      controller=gamepad:getName()
    else
      controller="None"
    end
    spr(cntrl[cntrl_idn],8,64)
    t_print("Controller: "..controller.."\nLayout: "..cntrl_type,1,48,font1,"left")

    spr(button[5],0,sh-h(button[4]))

  elseif mode=="game" then
    back_x=bot[hb][1]
    back_y=bot[hb][2]

    clip=32

    -- Draw lasers
    for i=1,#laser do
      if (laser[i][1]-cx<sw+clip and laser[i][1]-cx>-clip and laser[i][2]-cy<sh+clip and laser[i][2]-cy>-clip) then -- Only draw if on screen
        s=laser[i][8]
        love.graphics.setColor(255,255,255,255-laser[i][6])

        own=laser[i][7]
        if bot[own][9]=="Drone" then
          spt=laserd[s]
        elseif bot[own][9]=="Bomber" then
          spt=laserb[s]
        elseif bot[own][9]=="Eliminator" then
          spt=lasere[s]
        elseif bot[own][9]=="Leopard" then
          spt=laserl[s]
        else
          spt=Drones[1]
        end

        spr(spt,laser[i][1]-cx,laser[i][2]-cy,laser[i][5])
      end
    end

    -- Draw Drones
    love.graphics.setColor(255,255,255)
    for i=1,#bot do
      if bot[i][8]==hb then -- Draw all target circles if fps is at least 60, or only the ones currently chasing the player
        circ_x=bot[i][1]-cx
        circ_y=bot[i][2]-cy
        circ_draw=false
        if bot[i][8]==1 then
          circ_rng=64
          circ_a=255
          circ_r=200
          circ_g=20
        else
          circ_rng=8
          circ_a=90
          circ_r=50
          circ_g=120
        end
        if circ_x>sw-circ_rng then
          circ_draw=true
          circ_x=sw-circ_rng
        elseif circ_x<circ_rng then
          circ_draw=true
          circ_x=circ_rng
        end
        if circ_y>sh-circ_rng then
          circ_draw=true
          circ_y=sh-circ_rng
        elseif circ_y<circ_rng then
          circ_draw=true
          circ_y=circ_rng
        end
        if circ_draw then
          love.graphics.setColor(circ_r+math.sin(t/10)*50,circ_g,20,circ_a)
          love.graphics.circle("line",circ_x+wo,circ_y+ho,math.sin(t/10)*5,16)
          if circ_a==255 then
            love.graphics.circle("line",circ_x+wo,circ_y+ho,math.sin(t/10)*2,12)
          end
        end
      end

      if bot[i][10]==top and top2~=0 then -- Draw crowns to show where top players are
        love.graphics.setColor(255,255,255)
        crown_x=bot[i][1]-cx
        crown_y=bot[i][2]-12-cy
        crown_range=40
        if crown_x<crown_range then
          crown_x=crown_range
        elseif crown_x>sw-crown_range then
          crown_x=sw-crown_range
        end
        if crown_y<crown_range then
          crown_y=crown_range
        elseif crown_y>sh-crown_range then
          crown_y=sh-crown_range
        end
        spr(crown[math.floor(crown_sprite)],crown_x-4,crown_y-4)
      end

      if (bot[i][1]-cx<sw+clip and bot[i][1]-cx>-clip and bot[i][2]-cy<sh+clip and bot[i][2]-cy>-clip) then -- Only draw if on screen
        p=(bot[i][7]/100)*(255*mhp)
        love.graphics.setColor(255,p,p)

        if bot[i][11]==0 then
          if bot[i][9]=="Drone" then
            spt=Drones[bot[i][6]]
          elseif bot[i][9]=="Bomber" then
            spt=Bombers[bot[i][6]]
          elseif bot[i][9]=="Eliminator" then
            spt=Eliminators[bot[i][6]]
          elseif bot[i][9]=="Leopard" then
            spt=Leopards[bot[i][6]]
          else
            spt=laserd[1]
          end

          spr(spt,bot[i][1]-cx,bot[i][2]-cy,bot[i][5])

          -- Lifebar
          if math.ceil(bot[i][7])<mhp then
            bar_width=mhp
          else
            bar_width=math.ceil(bot[i][7])
          end
          bar_high=9
          love.graphics.setColor(50,50,50)
          love.graphics.rectangle("fill",bot[i][1]-cx-(bar_width/2)+wo-1,bot[i][2]+bar_high-cy+ho-1,bar_width+2,4)
          love.graphics.setColor(30,30,30)
          love.graphics.rectangle("fill",bot[i][1]-cx-(bar_width/2)+wo,bot[i][2]+bar_high-cy+ho,bar_width,2)
          love.graphics.setColor(255-p,p,0)
          love.graphics.rectangle("fill",bot[i][1]-cx-(bar_width/2)+wo,bot[i][2]+bar_high-cy+ho,bot[i][7],2)
        end
      end
      if i==hb and bot[i][7]<=0 then -- Respawn circle
        love.graphics.setColor(bot[i][11]*2,255-(bot[i][11]*2),0)
        love.graphics.circle("line",sw/2+wo,sh/2+ho,bot[i][11])
        t_print(math.ceil(bot[i][11]/60),0,sh/2-3,font1,"center")
      end
    end

    -- Draw minerals
    love.graphics.setColor(255,255,255)
    for i=1,#mineral.x do
      if mineral.x~=nil then
        if mineral.x[i]-cx<sw+clip and mineral.x[i]-cx>-clip and mineral.y[i]-cy<sh+clip and mineral.y[i]-cy>-clip then
          spr(valuable,mineral.x[i]-cx,mineral.y[i]-cy,mineral.a[i])
        end
      end
    end

    -- Draw asteroids
    love.graphics.setColor(255,255,255)
    for i=1,#rock.x do
      if rock.x~=nil then
        if rock.x[i]-cx<sw+clip and rock.x[i]-cx>-clip and rock.y[i]-cy<sh+clip and rock.y[i]-cy>-clip then
          spr(rocks[rock.type[i]],rock.x[i]-cx,rock.y[i]-cy,rock.a[i])
        end
      end
    end

    -- Draw particles
    love.graphics.setColor(255,255,255)
    for i=1,#smoke.x do
      if smoke.x~=nil then
        c=100
        if smoke.type[i]==1 then
          love.graphics.setColor(c,c-smoke.l[i]*4,0,smoke.l[i]*3)
        elseif smoke.type[i]==2 then
          love.graphics.setColor(c,c,0,smoke.l[i]*3)
        else
          love.graphics.setColor(c,c,c,smoke.l[i]*3)
        end
        love.graphics.circle("fill",smoke.x[i]-cx+wo,smoke.y[i]-cy+ho,smoke.size[i])
      end
    end
--[[ removed
    -- Average position of drones
    risk=0
    for i=1,#bot do
      risk=risk+1
      if bot[i]~=nil then
        risk_x=risk_x+bot[i][1]
        risk_y=risk_y+bot[i][2]
      end
    end
    for i=1,#mineral.x do
      risk=risk+1
      if mineral.x[i]~=nil then
        risk_x=risk_x+mineral.x[i]
        risk_y=risk_y+mineral.x[i]
      end
    end

    risk_x=risk_x/risk-cx
    risk_y=risk_y/risk-cy
    risk_range=22
    if risk_x<risk_range then
      risk_x=risk_range
    elseif risk_x>sw-risk_range then
      risk_x=sw-risk_range
    end
    if risk_y<risk_range then
      risk_y=risk_range
    elseif risk_y>sh-risk_range then
      risk_y=sh-risk_range
    end

    love.graphics.setColor(255,255,0,128)
    love.graphics.circle("line",risk_x+wo,risk_y+ho,math.sin(t/50)*7,16)
    love.graphics.circle("line",risk_x+wo,risk_y+ho,math.sin(t/50)*3,12)
    ]]

    -- Red circle of damage
    if bot[hb][11]==0 then
      p=(bot[hb][7]/100)*(255*mhp)
      love.graphics.setColor(100,0,0,(255-p))
      red_scalew=sw/128
      red_scaleh=sh/128
      love.graphics.draw(red,0,0,0,red_scalew,red_scaleh)
      --love.graphics.rectangle("fill",0-wo-16,0-ho-16,sw+(wo*4)+32,sh+(ho*4)+32)
    end

    -- Draw top player score
    love.graphics.setColor(100,255,100)
    top=0
    top2=0
    for i=1,#bot do
      if bot[i][10]>top then
        top=bot[i][10]
        top2=i
        if i==hb then
          save[1]=top
          top_name="(You) Bot "
        else
          top_name="Bot "
        end
      end
    end
    t_print(collect..":"..bot[hb][10].."\n\nTop Player: "..top_name..top2.."\nTheir "..collect..": "..top,12,12,font1,"left")

    --p=(bot[hb][7]/100)*(255*mhp)

    if pause then
      love.graphics.setColor(255,255,255)
      spr(button[5],sw/2,sh/2-64,0) -- back
      spr(button[2],sw/2,sh/2,0) -- score
      spr(button[4],sw/2,sh/2+64,0) -- title screen
    end
  end

  if showfps then
    if gamepad then
      controller=gamepad:getName()
      spr(cntrl[cntrl_idn],sw-64,0)
    else
      controller="None"
    end
    love.graphics.setColor(255-fpsc,fpsc,0)
    t_print("FPS: "..fps.."\nDrones: "..amount.."\nLasers: "..#laser.."/"..max.."\nParticles: "..#smoke.x.."/"..maxpart.."\nRumble: "..rumble1.." | "..rumble2.."\nController: "..controller.."\nLayout: "..cntrl_type,1,48,font1,"left")
    love.graphics.setColor(255,255,255)
    love.graphics.circle("fill",mx,my,3)
  end

  if gamepad and (mode~="game" or pause) then
    love.graphics.setColor(255,255,255)
    spr(cursor,mx,my,t/30)
  end

  
  love.graphics.setColor(255,255,255)
  if gamepad_time>0 then
    love.graphics.setColor(255,255,255,gamepad_time*6)
    t_print("Controller "..reason,0,4,font1,"center")
  end

  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill",sw,0,sw,sh*2)
  love.graphics.rectangle("fill",0,sh,sw*2,sh)

  love.graphics.setCanvas() -- draw to the screen

  love.graphics.scale(sc,sc)
  love.graphics.setColor(255,255,255)
  love.graphics.setBlendMode("alpha", "premultiplied")
  love.graphics.draw(screen)

  if btnp("tab") then
    local screenshot = love.graphics.newScreenshot();
    screenshot:encode("png","df-"..mode.."-"..os.time()..".png");
  end
end
