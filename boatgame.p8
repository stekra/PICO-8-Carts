pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- boat game
-- by @sutekura

-- todo:
--  😐 two players
----… detect gate pass
--  ⧗ time/score
--  ✽ wind behavior
       -- change at wind-sock
--  ˇ seagulls
--  ◆ rocks
--  ➡️ off-screen indicator
--  ∧ water wave effects
--  ❎ sfx (speed,gate,..)
--  ♪ music and/or ambience

function _init()
	b={} -- boat
	b.x=40
	b.y=100
	b.vx=0
	b.vy=0
	b.ang=0.25
	b.spd=0.002
	b.goals=0
	
	s={} -- sail
	s.x=b.x
	s.y=b.y
	s.ang=.35
	
	wang=0.5 -- wind angle
	
	v=0 -- vertical progress
	
	vel=0

	gates={}
	add(gates, new_gate(32))
	add(gates, new_gate(-42))
	add(gates, new_gate(-106))
end

function _update60()
 b.ang=b.ang%1
 s.ang=s.ang%1
 
 wf=abs(sin(s.ang-wang))
 
 b.vx-=cos(b.ang)*b.spd*wf
 b.vy+=sin(b.ang)*b.spd*wf
 
 falloff=0.99
 b.vx*=falloff
 b.vy*=falloff
 
 b.x+=b.vx
 b.y+=b.vy

 vel+=b.spd*wf
 vel*=0.995
 
 b.x-=cos(b.ang)*vel/2
 b.y+=sin(b.ang)*vel/2
 
 -- turn ctrl
 t=0.005
 spd=sqrt(b.vx*b.vx+b.vy*b.vy)
 spd=(spd*2.5+0.2)
 if (btn(⬅️)) b.ang-=t*spd
 if (btn(➡️)) b.ang+=t*spd
 
 -- sail ctrl
 if (btn(🅾️)) then
  s.ang=arot(s.ang,b.ang,0.0027)
 else
  s.ang=arot(s.ang,wang,0.003)
	end
	 
 -- sail root position
 s.x=b.x-cos(b.ang)*2+7.5
 s.y=b.y+sin(b.ang)*2+7.5

 -- turn wind
 wang=(wang+0.0001)%1

 -- scroll map
 if (b.y+v<74) v+=0.3 -- top
 if (b.y+v<50) v+=0.6 -- fast
 if (b.y+v>90) v-=0.2 -- back
 
 update_array(gates)
 
 st=stat(1)
 fps=stat(7)
end

function _draw()
	local start = stat(1)
	cls(3)
	print(st,0,50,0)
	print(fps,0,60,0)
	
	draw_debug()
	
	draw_sail_refl(s.x,s.y+v,s.ang)

 if (v<80) draw_start(80)
 draw_array(gates)
 
 draw_boat(b.x,b.y+v,b.ang)
 draw_sail(s.x,s.y+v,s.ang) 
 
-- draw_sock(108,16)
 rspr(64,16,108,8,wang,2)
 print(wang,105,26,12)
 
	printh("this took "..((stat(1)-start)*100).."% of a frame")
end

-->8
-- borrowed functions 웃

-- sprite rotation ✽
-- by @fsouchu

-- rotate a sprite
-- col 15 is transparent
-- sx,sy - sprite sheet coords
-- x,y - screen coords
-- a - angle
-- w - width in tiles
function rspr(sx,sy,x,y,a,w)
 local ca,sa=cos(a),sin(a)
 local srcx,srcy
 local ddx0,ddy0=ca,sa
 local mask=shl(0xfff8,(w-1))
 w*=4
 ca*=w-0.5
 sa*=w-0.5
 local dx0,dy0=sa-ca+w,-ca-sa+w
 w=2*w-1
 for ix=0,w do
  srcx,srcy=dx0,dy0
  for iy=0,w do
   if band(bor(srcx,srcy),mask)==0 then
    local c=sget(sx+srcx,sy+srcy)
 -- set transparent color here
    if (c!=0) pset(x+ix,y+iy,c)
   end
   srcx-=ddy0
   srcy+=ddx0
  end
  dx0+=ddx0
  dy0+=ddy0
 end
end

--pelogen_tri_176 ⧗
--by @shiftalow
function tri(v1,v2,v3,col)
 color(col)
 if(v1[2]>v2[2]) v1,v2=v2,v1
	if(v1[2]>v3[2]) v1,v3=v3,v1
	if(v2[2]>v3[2]) v3,v2=v2,v3
	local l,c,r,t,m,b=v1[1],v2[1],v3[1],flr(v1[2]),flr(v2[2]),v3[2]
	local i,j,k,r=(c-l)/(m-t),(r-l)/(b-t),(r-c)/(b-m),l
	while t~=b do
		if(t<0)t,l,r=0,l-i*t,v1 and r-j*t or r
		for t=t,min(m-1,127) do
			rectfill(l,t,r,t)
			r+=j
			l+=i
		end
		l,t,m,i,v1=c,m,b,k
	end
end
-->8
-- object functions ★

function draw_boat(x,y,a)
 for i=0,1 do
  local sx=16*(i%8)
  local sy=16*flr(i/8)
  rspr(sx,sy,x,y-i,a,2)
 end
end

function draw_sail(x,y,a)
 local ax=cos(a)
 local ay=sin(a)
 local p1={x,y-2}
 local p2={x,y-11}
 local p3={x+ax*8,y-2-ay*8}
 tri(p1,p2,p3,7)
 line(x,y-1,x,y-11,5)
end

function draw_sail_refl(x,y,a)
 pal(7,10)
 pal(5,11)
 local ax=cos(a)
 local ay=sin(a)
 local p1={x,y+2}
 local p2={x,y+11}
 local p3={x+ax*8,y+2-ay*8}
 tri(p1,p2,p3,7)
 line(x,y,x,y+11,5)
 pal()
 pal(10,138,1)
end

function draw_start(y)
 print("●………",0,y+v,11)
	print("…………",32,y+v,11)
	print("…………",64,y+v,11)
	print("………●",96,y+v,11)
	for i=0,4,2 do -- reflection
		print("●",0,y-1+i+v,11)
	 print("●",120,y-1+i+v,11)
	end
	for i=0,4,2 do
		print("●",0,y-1-i+v,7)
	 print("●",0,y-2-i+v,0)
	 print("●",120,y-1-i+v,7)
	 print("●",120,y-2-i+v,0)
	end
end

function draw_sock(x,y)
 for i=0,13 do
  local sx=16*(i%8)
  local sy=16*flr(i/8)
  rspr(0+sx,32+sy,x,y-i,wang,2)
 end
 pal(7,10)
 pal(5,11)
 pal(8,11)
 for i=0,13 do -- reflection
  local sx=16*(i%8)
  local sy=16*flr(i/8)
  rspr(0+sx,32+sy,x,y+i,wang,2)
 end
 pal()
 pal(10,138,1)
end

function new_gate(y)
 local g={}
 g.x=rnd(85)+2
 g.y=y
 g.yoff=0
 g.passed=false
 g.draw=function(this)
 	print("●………●",g.x,g.y+v+1,11)
 	if (g.passed) then color(12)
 	else color(14)
 	end
 	print("●      ●",g.x,g.y+v)
 end
 g.update=function(this)
  if (g.y>-v+128+g.yoff) then
   yoff=rnd(30)
   g.x=rnd(85)+2
	  g.y=-v-53-g.yoff
	  g.passed=false
	 end
	 if (b.y<g.y) then
	 	if (b.x+4>g.x and b.x<g.x+32) then
	 	 if(not g.passed) then
	 	  g.pass(this)
	 	  b.goals+=1
	 	 end
	 	end
	 end
 end
 g.pass=function(this)
  g.passed=true
 end
 return g
end

function update_array(array)
 for obj in all(array) do
  obj.update(obj)
 end
end

function draw_array(array)
 for obj in all(array) do
  obj.draw(obj)
 end
end

-->8
-- helper functions ♥

-- signed ang +/- 180 deg
function s180a(a)
 if     (a>0.5)  then a-=1
 elseif (a<-0.5) then a+=1
 end
 return a
end

-- rotate angle a
-- towards angle t
-- with angular speed s
function arot(a,t,s)
 local d = s180a(t-a)
 if     (d>s)  then a+=s
 elseif (d<-s) then a-=s
 else   a=t
 end
 return a
end

function draw_debug()
	color(11)
	print("a:"..b.ang,0,0)
 print("x:"..b.x,0,6)
	print("y:"..b.y,0,12)
	print("sa:"..s.ang,0,20)
	print("wf:"..wf,0,28)
	print("v:"..v,0,34)
	print("goals:"..b.goals,0,40)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000bbbbbbbb0000000055555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bbbbbbbbbbb000005555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bbbbbbbbbbbb000055555555555500000000005000000000000000577777770000000057777777000000005777777000000000577777700000000057777700
00bbbbbbbbbbbb000055555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bbbbbbbbbbb000005555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000bbbbbbbb0000000055555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000ccc0000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000ccccc00000000000000000000000000000000000000000000000000
0000000057777000000000005777000000000000577000000000000057000000cccccccccccccccc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000ccccc00000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000ccc0000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000
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
00000500000000000000050000000000000005000000000000000500000000000000050000000000000005000000000000000500000000000000050000000000
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
00000000000000000000000000000000000000887700000000000088770000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000058877000000000000887788770000000088778877000000058877000000000000000000000000000000000000000000000000000000
00000588770000000000058877887700000005027788778800000502778877880000058877887700000005887700000000000000000000000000000000000000
00000088770000000000058877887700000000027788778800000002778877880000058877887700000000887700000000000000000000000000000000000000
00000000000000000000008877000000000000887788770000000088778877000000008877000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000887700000000000088770000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888777777888eeeeee888eeeeee888888888888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88778877788ee888ee88ee888ee88888888888888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
888eee8e8ee8777787778eeeee8ee8eeeee8ee88888e88888888888888888888888888888888888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8777787778eee888ee8eeee88ee8888eee8888888888888888888888888888888888888ff888ff888222222888888222888228882888822288888
888eee8e8ee8777787778eee8eeee8eeeee8ee88888e88888888888888888888888888888888888888ff888ff888822228888228222888882282888222288888
888eee888ee8777888778eee888ee8eee888ee888888888888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee8777777778eeeeeeee8eeeeeeee888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
1111111111111e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111661666116616161111111116611661161616661111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111116111616161116161111177716161616161616161111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111116661661161111611777111116161616166616161111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111161616161116161111177716161616111616161111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111116611616116616161111111116661666166616661111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111661666116616161111111116611661161616661111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111116111616161116161171177716161616161616161111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111116661661161116661777111116161616116116161111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111161616161111161171177716161616161616161111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111116611616116616661111111116661666161616661111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1ee11ee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111ee11e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1e1e1eee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166116161666111111111661166116161666111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161616161616117117771616161616161616111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161611611616177711111616161611611616111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161616161616117117771616161616161616111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166616161666111111111666166616161666111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166116161666111111111661166116161666111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161616161616117117771616161616161616111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161616661616177711111616161616661616111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161611161616117117771616161611161616111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166616661666111111111666166616661666111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1ee11ee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ee11e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1e1e1eee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116661166166611661666166616661666166611711166166616661666166616661111111116661166116616161111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616116116111616161611611161161117111611161616161161116116111111111116161616161116161111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116611616116116661666166111611161166117111666166616611161116116611111111116661616166611611111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616116111161611161611611161161117111116161116161161116116111171111116111616111616161171
1e1111ee1e1e11ee11e11eee1ee11e1e111116161661116116611611161616661161166611711661161116161666116116661711111116111661166116161711
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111118888811111111111111111111111
11111111111111111e1111ee11ee1eee1e11111111661166161611111111111111661666166616661666166617171ccc17178888811111111111111111111111
11111111111111111e111e1e1e111e1e1e11111116111611161611111777111116111616161611611161161111171c1c11718888811111111111111111111111
11111111111111111e111e1e1e111eee1e11111116661611116111111111111116661666166111611161166111711ccc17778888817111111111111111111111
11111111111111111e111e1e1e111e1e1e11111111161611161611111777111111161611161611611161161117111c1c11718888817711111111111111111111
11111111111111111eee1ee111ee1e1e1eee111116611166161611111111111116611611161616661161166617171ccc17178888817771111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111117777111111111111111111
11111111111111111e1111ee11ee1eee1e1111111166116616161111111111111bbb1b111bbb1171116616661666166616661666117711c11c11117117171ccc
11111111111111111e111e1e1e111e1e1e1111111611161116161111177711111b111b111b1b1711161116161616116111611611111171c11c11111711711c1c
11111111111111111e111e1e1e111eee1e1111111666161116661111111111111bb11b111bb11711166616661661116111611661117111c11ccc111717771ccc
11111111111111111e111e1e1e111e1e1e1111111116161111161111177711111b111b111b1b1711111616111616116111611611117111c11c1c111711711c1c
11111111111111111eee1ee111ee1e1e1eee11111661116616661111111111111b111bbb1b1b117116611611161616661161166617111ccc1ccc117117171ccc
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111e1111ee11ee1eee1e1111111166116611111111111111bb11bb11bb11711666166111661611166611711111111111111111111111111111
11111111111111111e111e1e1e111e1e1e111111161116111111177711111b111b1b1b1117111616161616111611161111171111111111111111111111111111
11111111111111111e111e1e1e111eee1e111111161116661111111111111b111b1b1bbb17111666161616111611166111171111111111111111111111111111
11111111111111111e111e1e1e111e1e1e111111161111161111177711111b111b1b111b17111616161616161611161111171111111111111111111111111111
11111111111111111eee1ee111ee1e1e1eee11111166166111111111111111bb1bb11bb111711616161616661666166611711111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111e1111ee11ee1eee1e1111111166166111111111111111bb1bbb1bb111711666166111661611166611711111111111111111111111111111
11111111111111111e111e1e1e111e1e1e111111161116161111177711111b1111b11b1b17111616161616111611161111171111111111111111111111111111
11111111111111111e111e1e1e111eee1e111111166616161111111111111bbb11b11b1b17111666161616111611166111171111111111111111111111111111
11111111111111111e111e1e1e111e1e1e11111111161616111117771111111b11b11b1b17111616161616161611161111171111111111111111111111111111
11111111111111111eee1ee111ee1e1e1eee1111166116161111111111111bb11bbb1b1b11711616161616661666166611711111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111e1111ee11ee1eee1e111111116616661616111111111ccc17171171116611661111116616611171111111111c1c11111111111111111111
11111111111111111e111e1e1e111e1e1e111111161116161616177711111c1111711711161116111111161116161117111111711c1c11111111111111111111
11111111111111111e111e1e1e111eee1e11111116111666116111111ccc1ccc17771711161116661777166616161117111117771ccc11111111111111111111
11111111111111111e111e1e1e111e1e1e11111116111611161617771111111c1171171116111116111111161616111711111171111c11111111111111111111
11111111111111111eee1ee111ee1e1e1eee1111116616111616111111111ccc1717117111661661111116611616117111111111111c11111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111e1111ee11ee1eee1e111111116616661616111111111ccc17171171116616611111116611661171111111111c1c11111111111111111111
11111111111111111e111e1e1e111e1e1e111111161116161616177711111c1111711711161116161171161116111117111111711c1c11111111111111111111
11111111111111111e111e1e1e111eee1e11111116111666166611111ccc1ccc17771711166616161777161116661117111117771ccc11111111111111111111
11111111111111111e111e1e1e111e1e1e11111116111611111617771111111c1171171111161616117116111116111711111171111c11111111111111111111
11111111111111111eee1ee111ee1e1e1eee1111116616111666111111111ccc1717117116611616111111661661117111111111111c11111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111eee11ee1eee11111616111111111ccc11111ccc11111ee111ee111111111111111111111111111111111111111111111111111111111111
11111111111111111e111e1e1e1e11111616177711111c1111111c1111111e1e1e1e111111111111111111111111111111111111111111111111111111111111
11111111111111111ee11e1e1ee11111116111111ccc1ccc11111ccc11111e1e1e1e111111111111111111111111111111111111111111111111111111111111
11111111111111111e111e1e1e1e1111161617771111111c1171111c11111e1e1e1e111111111111111111111111111111111111111111111111111111111111
11111111111111111e111ee11e1e11111616111111111ccc17111ccc11111eee1ee1111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111e1111ee11ee1eee1e111111166616161111116616661616111111111111111111111111111111111111111111111111
111111111111111111111111111111111e111e1e1e111e1e1e111111161616161777161116161616111111111111111111111111111111111111111111111111
111111111111111111111111111111111e111e1e1e111eee1e111111166611611111161116661161111111111111111111111111111111111111111111111111
111111111111111111111111111111111e111e1e1e111e1e1e111111161116161777161116111616111111111111111111111111111111111111111111111111
111111111111111111111111111111111eee1ee111ee1e1e1eee1111161116161111116616111616111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111e1111ee11ee1eee1e111111166616161111116616661616111111111111111111111111111111111111111111111111
111111111111111111111111111111111e111e1e1e111e1e1e111111161616161777161116161616111111111111111111111111111111111111111111111111
111111111111111111111111111111111e111e1e1e111eee1e111111166616661111161116661666111111111111111111111111111111111111111111111111
111111111111111111111111111111111e111e1e1e111e1e1e111111161111161777161116111116111111111111111111111111111111111111111111111111
111111111111111111111111111111111eee1ee111ee1e1e1eee1111161116661111116616111666111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822282228882822282228888888888888888888888888888888888888888888882288222822282228882822282288222822288866688
82888828828282888888888288828828828888828888888888888888888888888888888888888888888888288882828282888828828288288282888288888888
82888828828282288888882288828828822288828888888888888888888888888888888888888888888888288222822282228828822288288222822288822288
82888828828282888888888288828828888288828888888888888888888888888888888888888888888888288288888288828828828288288882828888888888
82228222828282228888822288828288822288828888888888888888888888888888888888888888888882228222888282228288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__map__
3d0000000000000000000000002a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
