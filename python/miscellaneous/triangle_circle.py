import pygame, math, random

# Init pygame
pygame.init()

clock=pygame.time.Clock()

_run=True

# Init variables
t=0
sw=0
sh=0
pygame.display.set_mode([0,0], pygame.DOUBLEBUF | pygame.FULLSCREEN)
sw,sh=pygame.display.get_surface().get_size()

# Triangle function
def tri(s,t,x1,y1,x2,y2,x3,y3,c=(255,255,255)):
    t=math.floor(t)
    pygame.draw.line(s,c,(x1,y1),(x2,y2),t)
    pygame.draw.line(s,c,(x2,y2),(x3,y3),t)
    pygame.draw.line(s,c,(x3,y3),(x1,y1),t)

# Main function
def _main():
    # Use globals
    global t
    global sw
    global sh
    global r
    global g
    global b

    # Limit FPS
    clock.tick(60)

    # Check for escape key
    events = pygame.event.get()
    for event in events:
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_ESCAPE:
                pygame.quit()
                quit()

    # Timer
    t+=2

    # Clear screen
    s=pygame.display.get_surface()
    # Cool effect
    for i in range(0,5000):
        # Rectangle position and size
        rsc=sw/20
        w=random.randint(rsc/6,rsc)
        h=random.randint(rsc/6,rsc)
        w=4
        h=4
        x=random.randint(0,sw-1)
        y=random.randint(0,sh-1)

        # Draw rectangle
        r2c=s.get_at((x,y))[:3] # Get colour
        r2c=tuple(x/1.1 for x in r2c) # Make it darker
        r2=pygame.Surface((w,h)) # Make rectangle
        r2.set_alpha(200) # Make it transparent
        r2.fill(r2c) # Set colour
        s.blit(r2,(x-w/2,y-w/2)) # Draw rectangle

    # Draw triangle
    ts=sw/4
    tri(s,sw/128,math.sin(t/100)*ts+sw/2,math.cos(t/100)*ts+sh/2,math.sin((t/3)/100)*ts+sw/2,math.cos((t/3)/100)*ts+sh/2,math.sin((t/3*2)/100)*ts+sw/2,math.cos((t/3*2)/100)*ts+sh/2)

    # Update screen
    pygame.display.flip()

# Running
while _run:
    _main()
