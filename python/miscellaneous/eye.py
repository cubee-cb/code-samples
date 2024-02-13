import pygame, math, random

pygame.init()

clock=pygame.time.Clock()

_run=True

t=0
sw=0
sh=0
pygame.display.set_mode([0,0], pygame.DOUBLEBUF | pygame.FULLSCREEN)
sw,sh=pygame.display.get_surface().get_size()
rs=pygame.Rect(0,0,sw,sh)
r=255
g=255
b=255

def _main():
    # Use globals
    global rs
    global t
    global sw
    global sh
    global r
    global g
    global b

    # Limit FPS
    clock.tick(60)
    events = pygame.event.get()
    for event in events:
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_ESCAPE:
                pygame.quit()
                quit()

    # Rectangle position
    rw=math.sin(t/20)*sw-sw/8
    rh=math.cos(t/20)*sh-sh/8
    rx=sw/2-rw/2
    ry=sh/2-rh/2

    # Timer
    t+=1

    # Set colour
    rnx=sw/40
    rny=sh/40
    if (rw<=rnx and rw>-rnx) or (rh<=rny and rh>-rny):
        r=r+random.randint(-50,50)
        g=g+random.randint(-50,50)
        b=b+random.randint(-50,50)

    # Limit colours
    if r>255:
        r=255
    elif r<0:
        r=0
    if g>255:
        g=255
    elif g<0:
        g=0
    if b>255:
        b=255
    elif b<0:
        b=0

    # Clear screen
    s=pygame.display.get_surface()
    # Cool effect
    for i in range(0,199):
        # Rectangle position
        rsc=sw/20
        w=random.randint(rsc/6,rsc)
        h=random.randint(rsc/6,rsc)
        x=random.randint(0,sw-1)
        y=random.randint(0,sh-1)

        # Draw rectangle
        r2c=s.get_at((x,y))[:3]
        r2c=tuple(x/1.1 for x in r2c)
        r2=pygame.Surface((w,h))
        r2.set_alpha(200)
        r2.fill(r2c)
        s.blit(r2,(x-w/2,y-w/2))

    #pygame.draw.rect(s,(0,0,0),rs)

    # Draw rectangle
    re=pygame.Rect(rx,ry,rw,rh)
    pygame.draw.rect(s,(r,g,b),re)

    # Update screen
    pygame.display.flip()

# Running
while _run:
    _main()
