pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- picodachi
-- by cubee 🐱

-- init

function _init()
 -- 12
 --pal({[0]=0,128,129,1,133,141,5,13,134,6,135,7},1)
 --dark=hexplit"01121d64493d1d1"
 dark=hexplit"01121d62493112e"

 char={
  eye={
   type=1,
   x=0,
   y=0,
   angle=0,
   scale=1
  },
  brow={
   type=1,
   x=0,
   y=0,
   angle=0,
   scale=1
  },
  mouth={
   type=0,
   y=0,
   scale=1
  },
  nose={
   type=0,
   y=0,
   scale=1
  },
  mustache={
   type=0,
   y=0,
   scale=1
  },
  glasses={
   type=0,
   y=0,
   scale=1
  },
  mole={
   type=0,
   x=0,
   y=0,
   scale=1
  },
  beard=0,
  
  hair=4,
  hairflip=false,
  face=1,
  makeup=0,
  
  favcolour=8
 }



 t=0
 dp=0

 cam={
  x=0,y=-8,z=-10,
	 pitch=0,yaw=0
 
 }

	file=file or ""
	
	-- get file
	repeat
	
	if stat(120) then
	 for i=0,serial(0x800,0x8000,0x8000-1) do
	
	  file..=chr(@(0x8000+i))
	 end
	
	end
	
	
	cls()
	?"drop file to load (max 32kb)",1,1,7

	?file,1,8,13
	
	flip()
	until file~=""
	
	-- load file into array
	local currentcolour=5
	for l in all(split(file,"\n")) do

	 local part=split(l," ")
	 local k=deli(part,1)

	 if k=="v" then
	  add(model.verts,{x=tonum(part[1])or 0,y=-(tonum(part[2])or 0),z=-(tonum(part[3])or 0)})

	 elseif k=="vt" then
	  add(model.uvs,{u=128*(tonum(part[1])or 0),v=128*(tonum(part[2])or 0)})

	 elseif k=="vn" then
	  add(model.normals,{x=tonum(part[1])or 0,y=tonum(part[2])or 0,z=tonum(part[3])or 0})

  --materials 0-15 are p8 colours
  --strings use spritesheet
	 elseif k=="usemtl" then
	  currentcolour=part[1]

	 elseif k=="b" then
	  currentbone=part[1]

	 elseif k=="f" then
	  local face={
		  colour=currentcolour-- 1+rnd(15)
		 }

	  for i in all(part) do
	   i=split(i,"/")
	
	   add(face,{vert=i[1],uv=i[2]})
	   face.normal=model.normals[i[3]] or face.normal or {z=0,y=0,z=0}

	  end
	
	  add(model.faces,face)

	 elseif k=="c" then
	  currentcolour=tonum(part[1]) or 14

	 else
	  -- do nothing
	 
	 end
	
	end
	
	
	
	
end--init
	
	
	
	
-->8
-- update

function _update()

 local angle=-cam.yaw

	local cxv,czv=0,0
	local speed=0.5
	if(btn(0,1))cxv,czv=-sin(angle-0.25)*speed,cos(angle-0.25)*speed
	if(btn(1,1))cxv,czv=-sin(angle+0.25)*speed,cos(angle+0.25)*speed
	if(btn(2,1))cxv,czv=-sin(angle)*speed,cos(angle)*speed
	if(btn(3,1))cxv,czv=sin(angle)*speed,-cos(angle)*speed
	cam.x+=cxv
	cam.z+=czv

	if(btn(0))cam.yaw+=.01
	if(btn(1))cam.yaw-=.01
	if(btn(2))cam.pitch-=.01
	if(btn(3))cam.pitch+=.01
	
	if(btn(4))cam.y-=1
	if(btn(5))cam.y+=1

 cam.yaw%=1
 cam.pitch%=1


	t=max(t+1)
end

-->8
-- draw

function _draw()

	cls(13)


 --pal(4,char.hair)
 --pal(8,char.favcolour)
	draw_object(person,1,1,1,
 	0,--(time()/4)%1,
  0--(time()/4)%1,
 	--(time()/4)%1
	)
	pal()

	--draw_object(person,1,1,1,rnd())



 ?cam.yaw,1,1,7
 ?dp

end
-->8
-- model details

-- armature
humanoid={
	bones={
	 body={
	  parent="",
	  x=0,y=0,z=0,
	  pitch=0,yaw=0,roll=0,
	  verts="1-20,30-40"
	 },
	 head={
	  parent="body",
	  x=0,y=0,z=0,
	  pitch=0,yaw=0,roll=0,
	  verts={}
	 },
	 leg_l1={
	  parent="body",
	  x=0,y=0,z=0,
	  pitch=0,yaw=0,roll=0,
	  verts={}
	 },
	 leg_l2={
	  parent="leg_l1",
	  x=0,y=0,z=0,
	  pitch=0,yaw=0,roll=0,
	  verts={}
	 },
	 leg_r1={
	  parent="body",
	  x=0,y=0,z=0,
	  pitch=0,yaw=0,roll=0,
	  verts={}
	 },
	 leg_r2={
	  parent="leg_r1",
	  x=0,y=0,z=0,
	  pitch=0,yaw=0,roll=0,
	  verts={}
	 },
	 arm_l1={
	  parent="body",
	  x=0,y=0,z=0,
	  pitch=0,yaw=0,roll=0,
	  verts={}
	 },
	 arm_l2={
	  parent="leg_l1",
	  x=0,y=0,z=0,
	  pitch=0,yaw=0,roll=0,
	  verts={}
	 },
	 arm_r1={
	  parent="body",
	  x=0,y=0,z=0,
	  pitch=0,yaw=0,roll=0,
	  verts={}
	 },
	 arm_r2={
	  parent="leg_r1",
	  x=0,y=0,z=0,
	  pitch=0,yaw=0,roll=0,
	  verts={}
	 }
	},

 anims={
  idle={
   speed=1,-- seconds btw frames
   frames={
    {
     head="0.2,0.1,-0.1"
    },
    {
     head="-0.2,-0.1,0.1"
    }
   }

  }



 }

}

-- model base
model={
 s=0.75,
	verts={},
	uvs={},
	normals={},
	faces={}
}

-- person
person={
--[[
 models={
  model,
  model
 },]]
 model=model,

 armature=humanoid,
 anim="idle",
 anim_t=0,

 x=0,y=0,z=0,
 pitch=0,yaw=0,roll=0

}

-->8
-- 3d functions


-- draw object
function draw_object(object,ox,oy,oz,yaw,pitch,roll,scale)

 -- get offset
	local ox,oy,oz=
	 (ox or 0)+object.x,
	 (oy or 0)+object.y,
	 (oz or 0)+object.z
	
	-- get rotation
	local yaw,pitch,roll=
	 (yaw or 0)+object.yaw,
	 (pitch or 0)+object.pitch,
	 (roll or 0)+object.roll

 -- get scale
 local s=(model.s or 1)*(scale or 1)

 -- copy model, avoids
 -- unnecessary repeats on loops
 local model=copy(object.model)

 --local model=({unpack(object.model)})

 -- merge object models together
 --local model=merge(unpack(object.models))

	-- reset all verts on status
	for i in all(model.verts) do
	 i.on=false
	end

	-- backface culling
 for face in all(model.faces) do

  local vert=object.model.verts[face[1].vert]

  -- rotate normal
  face.normal=rotatepoint(
   {
    face.normal.x,
    face.normal.y,
    face.normal.z
   }
   ,pitch,-yaw,-roll)

  --turn on faces that face cam
		if dotprod(
		  {
		   -face.normal[1],
		   face.normal[2],
		   face.normal[3]
    },
		  {
		   vert.x-cam.x,
		   vert.y-cam.y,
		   vert.z-cam.z
		  }
		 )>0
		then
		 for i in all(face) do
		  model.verts[i.vert].on=true
		 end
		end

 end


 -- project verts
 for vert in all(model.verts) do
 if vert.on then

  -- scale position
  local point={
   vert.x*s,
   vert.y*s,
   vert.z*s
  }

  -- rotate by model's rotation
  point=rotatepoint(point,pitch,yaw,roll)

  -- translate by cam and offset
  point[1]-=cam.x-ox
  point[2]-=cam.y-oy
  point[3]-=cam.z-oz

  -- rotate by cam's rotation
  point=rotatepoint(point,cam.pitch,cam.yaw,cam.roll)

  -- project to 2d
  local distance=1
  local z=1/(distance-point[3])
  point[1]*=-z
  point[2]*=z
  
  
  --[[ draw
  pset(point[1],point[2])]]

 -- local s=10
  point[1]*=10
  point[2]*=10
--[[
  point[1]+=6
  point[2]-=10
]]
  -- apply
  vert.x,vert.y,vert.z=unpack(point)

  if vert.z<=0 or z>=distance or vert.x>64 or vert.x<-64 or vert.y>64 or vert.y<-64 then
   vert.on=false
  end

 end--on
 end--project

 -- sort faces
 for face in all(model.faces) do
  face.depth=(
   model.verts[face[1].vert].z
  +model.verts[face[2].vert].z
  +model.verts[face[3].vert].z
  )/3
 end

 local sortedfaces=sort(model.faces,function(a,b)return a.depth<b.depth  end)

 -- draw faces
 for face in all(sortedfaces) do

 	local v1=model.verts[face[1].vert]
	 local v2=model.verts[face[2].vert]
	 local v3=model.verts[face[3].vert]

  if v1.on and v2.on and v3.on then
   local f=16
   local lit=face.normal[2]-face.normal[1]/3+face.normal[3]/10

   -- normal face
   if tonum(face.colour) then
    --local colour=face.colour+mid(1,6+(lit)*6,11)
    local colour=lit>0.2 and face.colour or dark[face.colour]

 	 	p01_triangle_335(
 	 	 64+v1.x*f,64-v1.y*f,
 	 	 64+v2.x*f,64-v2.y*f,
 	 	 64+v3.x*f,64-v3.y*f,
 	 	 --v3.z*s
 	 	 --13
 	 	 colour
 	 	)

   -- textured face
   else
 	 	p01_triangle_335(
 	 	 64+v1.x*f,64-v1.y*f,
 	 	 64+v2.x*f,64-v2.y*f,
 	 	 64+v3.x*f,64-v3.y*f,
 	 	 --v3.z*s
 	 	 --13
 	 	 0
 	 	)
   end
 	end


	end--faces
	--]]

 ?yaw,1,1

end

-->8
-- functions

-- 1000 iterations: 55%
function matmul(mat,vec)

 local out={}

 for i=1,#vec do
  local val=0

  for k=1,#vec do
   val+=vec[k]*mat[i][k]
  end

  add(out,val)

 end

 return out

end


function dotprod(v1,v2)
 local out=0
 
 for i=1,#v1 do
  out+=v1[i]*v2[i]
 end

 return out

end


function copy(tbl)
local res={}
for k,v in pairs(tbl) do
 if(type(v)=="table")v=copy(v)
 res[k]=v
end
return res
end


function merge(...)
local res={}
for tbl in all(...) do
 for k,v in pairs(tbl) do
  -- add to existing entry
  if res[k] then
   if type(v)=="table" then
    res[k]=merge(res[k],v)
   else
    add(res[k],v)
   end

  -- make new entry
  else
   if(type(v)=="table")v=copy(v)
   res[k]=v
  end
 end

end

return res
end

--[[
function rotatepoint(point,x,y,z)

 local px,py,pz=unpack(point)

	if z and z~=0 then
		point=matmul(
		 {
			 {cos(z),sin(z),0},
			 {-sin(z),cos(z),0},
			 {0,0,1}
			},
		point)
	end

	if y and y~=0 then
		point=matmul(
		 {
			 {cos(y),0,sin(y)},
			 {0,1,0},
			 {-sin(y),0,cos(y)}
			},
		point)
	end

 if x and x~=0 then
		point=matmul(
		 {
			 {1,0,0},
			 {0,cos(x),sin(x)},
			 {0,-sin(x),cos(x)}
			},
		point)
	end

 return point

end
--]]

---[[
function rotatepoint(point,x,y,z)

 local px,py,pz=unpack(point)

 -- compacted rot functions, via
 -- mboffin's fps controller
	if z and z~=0 then
  py,px=cos(z)*py-sin(z)*px,cos(z)*px+sin(z)*py
 end

	if y and y~=0 then
  px,pz=cos(y)*px-sin(y)*pz,cos(y)*pz+sin(y)*px
 end

 if x and x~=0 then
  pz,py=cos(x)*pz-sin(x)*py,cos(x)*py+sin(x)*pz
 end

 return {px,py,pz}
end
--]]

function hexplit(data)
local tbl={}
for i in all(split(data,1)) do
add(tbl,tonum("0x"..i))
end
return tbl
end



-- sort table by depth
-- my trashy code :)
function sort(table)
 local list,sorted={},{}

 -- copy table
 for i in all(table) do
  add(list,i)
 end

 -- sort
 repeat
  min_y,delete=3200

  -- find highest
  for i in all(list) do
   -- set order
   if(i.depth<min_y)min_y,delete=i.depth,i
  end

  -- move to sorted
  add(sorted,del(list,delete),1)
 until #list==0

 return sorted
end

--https://www.lexaloffle.com/bbs/?tid=2731
-- faster code :)
function sort(tbl)

 -- sort triangles based on depth
 for i = 2,#tbl do
  local tri = tbl[i];
  local k = i - 1;
  local prev_tri = tbl[k];
  while tri.depth > prev_tri.depth do
   tbl[k + 1] = prev_tri;
   tbl[k] = tri;
   if (k == 1) break;
  
   k -= 1;
   prev_tri = tbl[k];
  end
 end

 return tbl

end
-->8
-- trifill

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
-- file

---[[
file=[[
# blender v3.0.0 obj file: 'bod-dress.blend'
# www.blender.org
mtllib bod-dress.mtl
o arm_cube.001
v 0.497217 4.349856 0.188836
v 0.583561 4.860320 0.010362
v 0.497217 4.349856 -0.189289
v 2.558506 4.839448 0.001225
v 1.517040 4.370709 0.220034
v 1.517040 4.810778 0.000000
v 1.517040 4.370709 -0.220034
v 2.558506 4.357383 0.242257
v 2.558506 4.357383 -0.239808
v 0.064267 4.834167 0.000000
v 2.785985 4.491183 -0.047692
v -0.497217 4.349856 0.188836
v -0.583561 4.860320 0.010362
v -0.497217 4.349856 -0.189289
v -2.558506 4.839448 0.001225
v -1.517040 4.370709 0.220034
v -1.517040 4.810778 0.000000
v -1.517040 4.370709 -0.220034
v -2.558506 4.357383 0.242257
v -2.558506 4.357383 -0.239808
v -0.064267 4.834167 0.000000
v -2.785985 4.491183 -0.047692
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 0.000000
vt 0.000000 0.000000
vn 0.0089 0.3629 -0.9318
vn -0.0134 0.4472 0.8943
vn -0.0365 0.4469 0.8938
vn 0.0204 -0.9998 0.0000
vn -0.0128 -0.9999 0.0000
vn -0.0113 0.4472 -0.8944
vn -0.0357 0.3352 0.9415
vn 0.0002 0.3642 -0.9313
vn 0.0278 0.3257 0.9451
vn -0.0361 0.4469 -0.8938
vn -0.0089 0.3629 -0.9318
vn 0.0134 0.4472 0.8943
vn 0.0365 0.4469 0.8938
vn -0.0204 -0.9998 0.0000
vn 0.0128 -0.9999 0.0000
vn 0.0113 0.4472 -0.8944
vn 0.0357 0.3352 0.9415
vn -0.0002 0.3642 -0.9313
vn -0.0278 0.3257 0.9451
vn 0.0361 0.4469 -0.8938
vn 0.6594 0.3362 0.6725
vn 0.5070 -0.8620 0.0000
vn 0.4417 0.4012 -0.8024
vn -0.6594 0.3362 0.6725
vn -0.5070 -0.8620 0.0000
vn -0.4417 0.4012 -0.8024
usemtl 8
s off
f 3/1/1 2/2/1 6/3/1
f 6/3/2 5/4/2 8/5/2
f 5/4/3 6/3/3 1/6/3
f 3/1/4 7/7/4 5/4/4
f 5/4/5 7/7/5 9/8/5
f 7/7/6 6/3/6 9/8/6
f 1/6/7 2/2/7 10/9/7
f 2/2/8 3/1/8 10/9/8
f 8/5/2 4/10/2 6/3/2
f 1/6/9 6/3/9 2/2/9
f 9/8/6 6/3/6 4/10/6
f 6/3/10 7/7/10 3/1/10
f 9/8/5 8/5/5 5/4/5
f 5/4/4 1/6/4 3/1/4
f 14/11/11 17/12/11 13/13/11
f 17/12/12 19/14/12 16/15/12
f 16/15/13 12/16/13 17/12/13
f 14/11/14 16/15/14 18/17/14
f 16/15/15 20/18/15 18/17/15
f 18/17/16 20/18/16 17/12/16
f 12/16/17 21/19/17 13/13/17
f 13/13/18 21/19/18 14/11/18
f 19/14/12 17/12/12 15/20/12
f 12/16/19 13/13/19 17/12/19
f 20/18/16 15/20/16 17/12/16
f 17/12/20 14/11/20 18/17/20
f 20/18/15 16/15/15 19/14/15
f 16/15/14 14/11/14 12/16/14
usemtl 15
f 4/10/21 8/5/21 11/21/21
f 9/8/22 11/21/22 8/5/22
f 4/10/23 11/21/23 9/8/23
f 15/20/24 22/22/24 19/14/24
f 20/18/25 19/14/25 22/22/25
f 15/20/26 20/18/26 22/22/26
o leg_cube.002
v 0.423447 0.000000 0.570589
v 0.423447 0.509840 0.234678
v 0.114300 0.000000 -0.289831
v 0.130414 0.509840 -0.255058
v 0.154838 1.828766 -0.241451
v 0.423447 1.828766 0.207466
v 0.732595 0.000000 -0.289831
v 0.716480 0.509840 -0.255058
v 0.692057 1.828766 -0.241451
v 0.091933 2.987436 -0.019991
v 0.655568 2.987436 0.004946
v -0.423447 0.000000 0.570589
v -0.423447 0.509840 0.234678
v -0.114300 0.000000 -0.289831
v -0.130414 0.509840 -0.255058
v -0.154838 1.828766 -0.241451
v -0.423447 1.828766 0.207466
v -0.732595 0.000000 -0.289831
v -0.716480 0.509840 -0.255058
v -0.692057 1.828766 -0.241451
v -0.091933 2.987436 -0.019991
v -0.655568 2.987436 0.004946
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vn -0.9186 0.2175 0.3300
vn 0.0000 0.0680 -0.9977
vn 0.9186 0.2175 0.3300
vn -0.8493 -0.1432 0.5082
vn 0.8581 0.0106 0.5134
vn 0.0000 0.0103 -0.9999
vn -0.8581 0.0106 0.5134
vn 0.0000 0.2080 -0.9781
vn 0.8552 -0.0819 0.5117
vn 0.0434 0.1898 -0.9809
vn 0.8581 -0.0079 0.5134
vn -0.8581 -0.0079 0.5134
vn -0.0435 0.1805 0.9826
vn 0.8493 -0.1432 0.5082
vn -0.8552 -0.0819 0.5117
vn -0.0434 0.1898 -0.9809
vn 0.0435 0.1805 0.9826
usemtl 5
s off
f 23/23/27 24/24/27 25/25/27
f 25/25/28 30/26/28 29/27/28
f 29/27/29 24/24/29 23/23/29
f 27/28/30 28/29/30 32/30/30
f 24/24/31 30/26/31 28/29/31
f 30/26/32 26/31/32 27/28/32
f 26/31/33 28/29/33 27/28/33
f 31/32/34 27/28/34 33/33/34
f 28/29/31 30/26/31 31/32/31
f 33/33/35 28/29/35 31/32/35
f 28/29/33 26/31/33 24/24/33
f 27/28/32 31/32/32 30/26/32
f 33/33/36 27/28/36 32/30/36
f 30/26/28 25/25/28 26/31/28
f 24/24/37 29/27/37 30/26/37
f 25/25/38 24/24/38 26/31/38
f 32/30/39 28/29/39 33/33/39
f 34/34/29 36/35/29 35/36/29
f 36/35/28 40/37/28 41/38/28
f 40/37/27 34/34/27 35/36/27
f 38/39/40 43/40/40 39/41/40
f 35/36/33 39/41/33 41/38/33
f 41/38/32 38/39/32 37/42/32
f 37/42/31 38/39/31 39/41/31
f 42/43/34 44/44/34 38/39/34
f 39/41/33 42/43/33 41/38/33
f 44/44/41 42/43/41 39/41/41
f 39/41/31 35/36/31 37/42/31
f 38/39/32 41/38/32 42/43/32
f 44/44/42 43/40/42 38/39/42
f 41/38/28 37/42/28 36/35/28
f 35/36/38 41/38/38 40/37/38
f 36/35/37 37/42/37 35/36/37
f 43/40/43 44/44/43 39/41/43
o dress_cube.005
v 0.000000 5.706466 -0.096534
v 0.877703 2.160096 -0.408984
v 0.877703 2.160096 0.406594
v 0.000000 2.160096 -0.852637
v 0.000000 2.140979 0.859204
v 0.569958 4.238743 -0.176726
v 0.000000 4.238743 0.464501
v 0.569958 4.238743 0.207813
v 0.000000 4.238743 -0.461387
v -0.877703 2.160096 -0.408984
v -0.877703 2.160096 0.406594
v -0.569958 4.238743 -0.176726
v -0.569958 4.238743 0.207813
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vn 0.3878 0.3291 0.8610
vn 0.9322 0.3620 0.0000
vn 0.4362 0.2171 -0.8733
vn 0.4449 0.1657 -0.8801
vn 0.9892 0.1465 0.0000
vn 0.4492 0.1652 0.8780
vn 0.4062 0.1464 0.9020
vn 0.4408 0.1639 -0.8825
vn -0.3878 0.3291 0.8610
vn -0.9322 0.3620 0.0000
vn -0.4362 0.2171 -0.8733
vn -0.4449 0.1657 -0.8801
vn -0.9892 0.1465 0.0000
vn -0.4492 0.1652 0.8780
vn -0.4062 0.1464 0.9020
vn -0.4408 0.1639 -0.8825
usemtl 8
s off
f 52/45/44 45/46/44 51/47/44
f 50/48/45 45/46/45 52/45/45
f 53/49/46 45/46/46 50/48/46
f 48/50/47 53/49/47 46/51/47
f 46/51/48 50/48/48 52/45/48
f 47/52/49 51/47/49 49/53/49
f 51/47/50 47/52/50 52/45/50
f 52/45/48 47/52/48 46/51/48
f 46/51/51 53/49/51 50/48/51
f 57/54/52 51/47/52 45/46/52
f 56/55/53 57/54/53 45/46/53
f 53/49/54 56/55/54 45/46/54
f 48/50/55 54/56/55 53/49/55
f 54/56/56 57/54/56 56/55/56
f 55/57/57 49/53/57 51/47/57
f 51/47/58 57/54/58 55/57/58
f 57/54/56 54/56/56 55/57/56
f 54/56/59 56/55/59 53/49/59
o head_cube.004
v 0.000000 5.324478 -1.142157
v 0.691057 5.334680 -0.778538
v 0.563366 5.047732 0.680552
v 1.095591 7.601637 0.822763
v 0.000000 8.039757 1.505876
v 0.000000 4.821830 1.174255
v 1.130281 6.181338 -0.219469
v 1.029332 5.957438 1.114574
v 0.000000 5.969477 1.715642
v -0.691057 5.334680 -0.778538
v -0.563366 5.047732 0.680552
v -1.095591 7.601637 0.822763
v -1.130281 6.181338 -0.219469
v -1.029332 5.957438 1.114574
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vn 0.1104 -0.9770 -0.1825
vn 0.9971 -0.0276 0.0708
vn 0.6585 -0.5711 0.4901
vn 0.8907 -0.4545 -0.0114
vn 0.5031 0.0871 0.8598
vn 0.4635 -0.3780 0.8014
vn 0.5600 0.1228 0.8193
vn 0.8916 -0.4527 -0.0085
vn 0.4362 0.3272 -0.8382
vn -0.1104 -0.9770 -0.1825
vn -0.9971 -0.0276 0.0708
vn -0.6585 -0.5711 0.4901
vn -0.8907 -0.4545 -0.0114
vn -0.5031 0.0871 0.8598
vn 0.0000 -0.9093 -0.4161
vn -0.4635 -0.3780 0.8014
vn -0.5600 0.1228 0.8193
vn -0.8916 -0.4527 -0.0085
vn -0.4362 0.3272 -0.8382
vn 0.0000 -0.9887 -0.1501
usemtl 15
s off
f 59/58/60 60/59/60 58/60/60
f 64/61/61 61/62/61 65/63/61
f 60/59/62 65/63/62 63/64/62
f 59/58/63 64/61/63 60/59/63
f 66/65/64 65/63/64 62/66/64
f 63/64/65 65/63/65 66/65/65
f 62/66/66 65/63/66 61/62/66
f 60/59/67 64/61/67 65/63/67
f 59/58/68 58/60/68 64/61/68
f 67/67/69 58/60/69 68/68/69
f 70/69/70 71/70/70 69/71/70
f 68/68/71 63/64/71 71/70/71
f 67/67/72 68/68/72 70/69/72
f 66/65/73 62/66/73 71/70/73
f 68/68/74 60/59/74 63/64/74
f 63/64/75 66/65/75 71/70/75
f 62/66/76 69/71/76 71/70/76
f 68/68/77 71/70/77 70/69/77
f 67/67/78 70/69/78 58/60/78
f 58/60/79 60/59/79 68/68/79
o face_plane
v -0.000000 5.905313 1.817656
v 1.588231 5.905313 1.337306
v -0.000000 7.273039 1.817656
v 1.614149 7.273039 1.337306
v -0.000000 4.734811 1.632246
v 1.378791 4.734811 1.296148
v -0.000000 8.659628 1.559991
v 1.594721 8.659628 1.061807
v -1.588231 5.905313 1.337306
v -1.614149 7.273039 1.337306
v -1.378791 4.734811 1.296148
v -1.594721 8.659628 1.061807
vt 1.000000 0.710938
vt 0.812500 0.859375
vt 0.812500 0.710938
vt 1.000000 0.562500
vt 1.000000 0.859375
vt 0.812500 1.000000
vt 0.625000 0.710938
vt 0.625000 0.562500
vt 0.625000 0.859375
vt 0.812500 0.562500
vt 1.000000 1.000000
vt 0.625000 1.000000
vn 0.2895 0.0000 0.9572
vn 0.2884 -0.0851 0.9537
vn 0.2808 0.1753 0.9436
vn -0.2895 0.0000 0.9572
vn -0.2884 -0.0851 0.9537
vn -0.2808 0.1753 0.9436
vn 0.2852 -0.0054 0.9584
vn 0.2341 -0.1521 0.9602
vn 0.2927 0.1903 0.9371
vn -0.2852 -0.0054 0.9584
vn -0.2341 -0.1521 0.9602
vn -0.2927 0.1903 0.9371
usemtl texture
s off
f 73/72/80 74/73/80 72/74/80
f 72/74/81 77/75/81 73/72/81
f 75/76/82 78/77/82 74/73/82
f 74/73/83 80/78/83 72/74/83
f 82/79/84 72/74/84 80/78/84
f 78/77/85 81/80/85 74/73/85
f 73/72/86 75/76/86 74/73/86
f 72/74/87 76/81/87 77/75/87
f 75/76/88 79/82/88 78/77/88
f 74/73/89 81/80/89 80/78/89
f 82/79/90 76/81/90 72/74/90
f 78/77/91 83/83/91 81/80/91
o hair_cube
v 0.285425 7.639845 1.705046
v -0.005652 8.692380 1.338658
v -0.005652 4.592942 -1.245672
v -0.005652 8.473918 -1.106280
v 1.435203 6.445199 1.061427
v 1.079412 8.373615 1.093326
v 1.304087 5.252999 -0.495256
v 1.063827 8.047424 -0.903450
v -0.005652 8.759647 0.223547
v 1.350964 8.067595 -0.057235
v 0.669413 7.024149 1.599597
v 0.768539 8.615083 -0.057235
v -0.005652 8.179463 1.672308
v -0.005652 6.808459 -1.715034
v 1.435158 6.846186 -1.032433
v 1.273779 7.332789 1.523408
v 1.665457 7.136611 -0.056537
v 0.931081 6.680159 -1.536203
v -0.005652 7.819096 -0.303343
v -1.311766 6.188410 1.191716
v -1.090717 8.373615 1.093326
v -1.315391 5.252999 -0.495256
v -1.075132 8.047424 -0.903450
v -1.362269 8.067595 -0.057235
v -0.293388 6.776919 1.683761
v -0.779843 8.615083 -0.057235
v -1.446463 6.846186 -1.032433
v -1.285083 7.164207 1.568894
v -1.676761 7.136611 -0.056537
v -0.942386 6.680159 -1.536203
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vt 0.000000 1.000000
vn 0.9001 0.3110 -0.3050
vn 0.6334 0.2735 -0.7239
vn 0.9443 0.2598 0.2019
vn 0.3701 0.4130 0.8321
vn 0.4039 0.8187 -0.4082
vn 0.2305 0.9630 0.1398
vn 0.6846 0.7282 -0.0321
vn 0.6645 0.7069 -0.2423
vn 0.2240 0.3913 -0.8926
vn 0.3102 -0.3939 0.8652
vn 0.1595 -0.0692 0.9848
vn 0.9760 -0.2046 0.0745
vn 0.5947 -0.3665 -0.7156
vn 0.9000 0.3038 -0.3126
vn 0.9384 0.3171 0.1371
vn 0.3301 0.5147 0.7913
vn 0.1058 0.9722 -0.2089
vn 0.2934 0.9543 0.0576
vn 0.3005 0.3274 -0.8958
vn 0.1564 -0.2047 -0.9662
vn 0.2325 0.1834 0.9552
vn 0.9707 0.0548 0.2338
vn 0.7235 -0.2733 -0.6339
vn 0.9719 -0.1430 -0.1868
vn -0.3783 -0.2595 0.8886
vn -0.8021 -0.4396 0.4042
vn -0.9001 0.3110 -0.3050
vn -0.6334 0.2735 -0.7239
vn -0.9447 0.2397 0.2236
vn -0.3779 0.3908 0.8393
vn -0.4039 0.8187 -0.4082
vn -0.2305 0.9630 0.1398
vn -0.6846 0.7282 -0.0321
vn -0.6645 0.7069 -0.2423
vn -0.2240 0.3913 -0.8926
vn -0.2396 -0.3443 0.9078
vn -0.0988 0.0418 0.9942
vn -0.9693 -0.2141 0.1208
vn -0.5947 -0.3665 -0.7156
vn -0.9000 0.3038 -0.3126
vn -0.9384 0.3171 0.1371
vn -0.3301 0.5147 0.7913
vn -0.1058 0.9722 -0.2089
vn -0.2934 0.9543 0.0576
vn -0.3005 0.3274 -0.8958
vn -0.1564 -0.2047 -0.9662
vn -0.0899 0.0119 0.9959
vn -0.9699 -0.0642 0.2348
vn -0.7235 -0.2733 -0.6339
vn -0.9719 -0.1430 -0.1868
vn 0.3783 -0.2595 0.8886
vn 0.8546 -0.4549 0.2504
usemtl 4
s off
f 91/84/92 100/85/92 98/86/92
f 101/87/93 91/84/93 98/86/93
f 100/85/94 89/88/94 99/89/94
f 89/88/95 96/90/95 99/89/95
f 87/91/96 95/92/96 91/84/96
f 92/93/97 89/88/97 95/92/97
f 95/92/98 89/88/98 93/94/98
f 91/84/99 95/92/99 93/94/99
f 97/95/100 91/84/100 101/87/100
f 99/89/101 94/96/101 88/97/101
f 99/89/102 84/98/102 94/96/102
f 100/85/103 88/97/103 90/99/103
f 101/87/104 90/99/104 86/100/104
f 91/84/105 93/94/105 100/85/105
f 100/85/106 93/94/106 89/88/106
f 89/88/107 85/101/107 96/90/107
f 87/91/108 92/93/108 95/92/108
f 92/93/109 85/101/109 89/88/109
f 97/95/110 87/91/110 91/84/110
f 97/95/111 101/87/111 86/100/111
f 99/89/112 96/90/112 84/98/112
f 100/85/113 99/89/113 88/97/113
f 101/87/114 98/86/114 90/99/114
f 98/86/115 100/85/115 90/99/115
f 86/100/116 90/99/116 102/102/116
f 90/99/117 88/97/117 102/102/117
f 106/103/118 110/104/118 112/105/118
f 113/106/119 110/104/119 106/103/119
f 112/105/120 111/107/120 104/108/120
f 104/108/121 111/107/121 96/90/121
f 87/91/122 106/103/122 109/109/122
f 92/93/123 109/109/123 104/108/123
f 109/109/124 107/110/124 104/108/124
f 106/103/125 107/110/125 109/109/125
f 97/95/126 113/106/126 106/103/126
f 111/107/127 103/111/127 108/112/127
f 111/107/128 108/112/128 84/98/128
f 112/105/129 105/113/129 103/111/129
f 113/106/130 86/100/130 105/113/130
f 106/103/131 112/105/131 107/110/131
f 112/105/132 104/108/132 107/110/132
f 104/108/133 96/90/133 85/101/133
f 87/91/134 109/109/134 92/93/134
f 92/93/135 104/108/135 85/101/135
f 97/95/136 106/103/136 87/91/136
f 97/95/137 86/100/137 113/106/137
f 111/107/138 84/98/138 96/90/138
f 112/105/139 103/111/139 111/107/139
f 113/106/140 105/113/140 110/104/140
f 110/104/141 105/113/141 112/105/141
f 86/100/142 102/102/142 105/113/142
f 105/113/143 102/102/143 103/111/143



]]
--]]
-->8
-- custom 20fps mainloop
-- we're going wild world style

_init()
_set_fps(20)
::l::

_update()

_draw()

flip()
goto l
__gfx__
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000eeeeeeeeeee0eeeeeeeeeeeeee444eee0000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00700700ee0000eeeee0feeeeeeeeeeee4eee4ee0000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00077000e0ecce0eee0ffeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00077000eeecce00ee0ffeeeee0000eeeeeeeeee0000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00700700eeeeeeeeeee00eeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeee444444eeeeeeeeeeee444444eeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeee444444eeeeeeeeeeee444444eeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeee44eeeeee44eeeeeeee44eeeeee44eeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeee44eeeeee44eeeeeeee44eeeeee44eeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeee00000000eeeeeeee00000000eeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeee00000000eeeeeeee00000000eeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeee00eeccccee00eeee00eeccccee00eeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeee00eeccccee00eeee00eeccccee00eeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeee0000eecccceeee00eeeeeeccccee0000eeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeee0000eecccceeee00eeeeeeccccee0000eeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeee00ffeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeee00ffeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeee00ffffeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeee00ffffeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeee00ffffeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeee00ffffeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeee0000eeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeee0000eeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeee00eeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddeee000eeeee00eeeeeeeeeeeeeeeeeeee
ee0000eeee0000eeeee000eeeecc0eeee00000eeee0000eeeeeeeeeeeeeeeeeee000eeeeee0000eeeee0000eeed000d0e0cc70eee0ee0eeeeecc70eeee0000ee
e0ecce0ee0ecce0eee0cc70eeecc70eee07cc00ee07cc70eeeecc0eeeeeeeeeeeecc00eee07cc70eee0cc70eed0cce0deecc70eeeecce0eeeecc70eee0ecce0e
eeecceeeeeecce00e07cc700ee7770eee07cc70ee77cc77eeeecceeee0000eeeeecceeeee07cc70ee07cc70ee0ecce00ee7770eeeecce0eee07770eee0ecce0e
eeeeeeeeeeeeeeeee000000eeeeeeeeeee00770eee0000eeeeeeeeeeeeeeeeeeeeeeeeeeee0000eee00000eeeeeeeeeeeeee0eeeeeeeeeeeee000e0eeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeee
e000000eeee000eeee00eeeeeeeeeeeeeeeeeeeeee000eeeee0000e0eee00ee0ee00eeeeee0000eeeeeeeeeeeeeeeeeeeee000eeee0000eeee0cc0eeeee000ee
e0ecce0eee0cce0ee0000e0eee00eeeeee000eeee0cce0e0e07cc70eee0cc00ee0cceeeee0ecceeeee000eeeee00000ee00c770ee0cc770ee07cc700ee000700
eeecceeee0ecce0eeeee00eee0000eeeeeeeeeeeeecce00ee07cc700e07cc700eecceeeeeeecceeeee000eeee07cc77007cc70eee7cc770e0000000ee07cc70e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000eeeeeeeeeeeeeeeeeeeee000000eeeeeeeeeeeeeeeeeeeeeeeeee000000e077eeeeee77700eeeeeeeeeeee00000e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeee00eeeeee00e0eee0000eeeeeeeeeeeeeeeeeeeee000e0ee0000eeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeee00e0eeeeeeeeeeeeeeeee
e00000eeeeeeeeeeee0770eeee0770eee000000eee0000eeeee00eeeee00000ee000000eee0000eeee0770eeeeeeeeeeeeeee000ee0cc0eeeeeeeeeeeee0eeee
e07cc70eeeecceeee07cc700e07cc700e07cc70ee07cc70eee0cc0eee07cc700e07cc70ee07cc70ee07cc70ee000000ee0000770e0c77c00ee000e0eee0eeeee
ee77770eeeecceeee07cc70ee07cc70ee07cc70ee07cc70ee07cc70ee07cc70ee07cc70eee7cc700e07cc70ee07cc70ee07cc70eeecccc0ee00eeeeee0000eee
eeeeeeeeeeeeeeeeeeeeeeeeee0770eeeee77eeee000000ee000000eee0000eeee0000e0eee7770eee0770eeee0770eeee0000eeeee7ceeeeeeee0eeee0eeeee
eeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeee0eee00eeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeee242242ee0eeee0ee00ee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0ee0eeeeeeeeeeeee22eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee0000eeee4444eeee0000ee0ee00ee0e077770ee22ee22eeee22eeee0e00e0eee0ee0eee0eeee0eeee77eeeee2222eeee2e22eee00ee00eeee00eeee006600e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeee4444eeee4444eeee0ee0eee0e00e0ee000000eee0000eeeee44eeee444444eeee00eeeeee00eeeee0770ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e0eeee0eeeeeeeeeeeeeee0eee4444eeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee0000eeeee22eeeee0000eeee2222eeee00000eeee00eeee077770eee00e0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e0eeee0eeee44eeeeeeeeeeeee4444eeeeeeee0ee00ee00eee0000eee0ee0e0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeee444eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e44444eee4eee4ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
010002000a0b0c0d0e0f0a0b0c0d0e0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001a1b1c1d1e1f1a1b1c1d1e1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
030004002a2b2c2d2e2f2a2b2c2d2e2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000003a3b3c3d3e3f3a3b3c3d3e3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000004a4b4c4d4e4f4a4b4c4d4e4f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005a5b5c5d5e5f5a5b5c5d5e5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006a6b6c6d6e6f6a6b6c6d6e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000a0b0c0d0e0f0a0b0c0d0e0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001a1b1c1d1e1f1a1b1c1d1e1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000002a2b2c2d2e2f2a2b2c2d2e2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000003a3b3c3d3e3f3a3b3c3d3e3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000004a4b4c4d4e4f4a4b4c4d4e4f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005a5b5c5d5e5f5a5b5c5d5e5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006a6b6c6d6e6f6a6b6c6d6e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
