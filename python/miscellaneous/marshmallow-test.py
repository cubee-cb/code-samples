# Marshmallow
# By Cubee

# Import functions
import pygame, math, random
import pygame.gfxdraw as g
from pygame.locals import *

# Initialise pygame, screen and clock
pygame.init()
sw, sh = 320, 240
screen = pygame.Surface((sw, sh))
pygame.display.set_mode((680, 700), DOUBLEBUF)
real_screen = pygame.display.get_surface()
aw = real_screen.get_width()
ah = real_screen.get_height()
clock = pygame.time.Clock()
run = True

# Level
level = [
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2],
  [1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2],
  [1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 2, 0, 2, 0, 0, 2, 2],
  [1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
]

# Outline colours
line_c = (200, 200, 200)
line_c2 = (200, 80, 80)

# Make solid tile sprite
tile = pygame.Surface((16, 16))
tile.fill((255, 255, 255))
g.line(tile, 0, 0, 15, 0, line_c)
g.line(tile, 0, 0, 0, 15, line_c)
g.line(tile, 15, 15, 0, 15, line_c)
g.line(tile, 15, 15, 15, 0, line_c)

# Make red tile sprite
bad = pygame.Surface((16, 16))
bad.fill((255, 100, 100))
g.line(bad, 0, 0, 15, 0, line_c2)
g.line(bad, 0, 0, 0, 15, line_c2)
g.line(bad, 15, 15, 0, 15, line_c2)
g.line(bad, 15, 15, 15, 0, line_c2)

tiles = [None, tile, bad]

# Make player sprite

# Eyes
pl_eye = pygame.Surface((2, 4))
pl_eye.fill((0, 0, 0))
# g.pixel(pl_eye, 0, 0, (255, 255, 255)) # Eye shine

# Surprised eyes
pl_eye2 = pygame.Surface((1, 2))
pl_eye2.fill((0, 0, 0))

# Body
player = pygame.Surface((12, 12))
player.fill((255, 255, 255))
g.line(player, 0, 0, 11, 0, line_c)
g.line(player, 0, 0, 0, 11, line_c)
g.line(player, 11, 11, 0, 11, line_c)
g.line(player, 11, 11, 11, 0, line_c)

# Init function
def _init():
  global x,y,xv,yv,grv,acc,frc,dec,max_spd,jump,die,cx,cy,cxv,cyv,cxt,cyt,t

  # Player position
  x = 32
  y = 64
  xv = 0
  yv = 0

  # Player physics and state
  grv = 0.2
  acc = 0.1
  frc = acc
  dec = 0.3
  max_spd = 3
  jump = False
  die = False

  # Camera position
  cx = x-sw/2
  cy = y-sh/2
  cxv = 0
  cyv = 0
  cxt = cx
  cyt = cy

  # Other variables
  t = 0


# Sign function
def sign(n):
  if n > 0:
    return 1
  elif n < 0:
    return -1
  else:
    return 0


_init()

# Main loop
while run:

  # Limit framerate
  clock.tick(60)

  # Check events
  for event in pygame.event.get():
    # Quit
    if event.type == QUIT:
      run = False

  # Get keys
  keys = pygame.key.get_pressed()

  # Controllable if alive
  if not die:
    air = False

    # get inputs
    if keys[K_LEFT]:
      if air or xv < 0:
        xv -= acc
      else:
        xv -= dec

    if keys[K_RIGHT]:
      if air or xv > 0:
        xv += acc
      else:
        xv += dec

    # Apply friction
    if not keys[K_LEFT] and not keys[K_RIGHT]:
      xv -= 0.1*sign(xv)
      if abs(xv) < acc:
        xv = 0

    # Gravity and speed limits
    yv += grv
    yv = min(yv, 8)
    xv = min(max(xv, -max_spd), max_spd)

    # Move player
    y += yv
    x += xv

    # Stay in level
    x = min(max(x, 0), len(level[0])*16)
    y = min(max(y, 0), len(level)*16)

    # Set camera target
    cxt = (x+xv*25)-sw/2
    cyt = (y+yv*25)-sh/2

    # Collide with walls
    try:
      # Right wall
      if level[int(y/16)][int((x+xv+6)/16)] == 1:
        xv = 0
        while level[int(y/16)][int((x+6)/16)] == 0:
          x += 0.1
        while level[int(y/16)][int((x+6)/16)] == 1:
          x -= 0.1
      # Left wall
      if level[int(y/16)][int((x+xv-6)/16)] == 1:
        xv = 0
        while level[int(y/16)][int((x-6)/16)] == 0:
          x -= 0.1
        while level[int(y/16)][int((x-6)/16)] == 1:
          x += 0.1

    except:
      print("Nil wall")

    # Collide with ceiling
    try:
      if level[int((y+yv-6)/16)][int(x/16)] == 1:
        yv = 0
        while level[int((y-6)/16)][int(x/16)] == 0:
          y -= 0.1
        while level[int((y-6)/16)][int(x/16)] == 1:
          y += 0.1
    except:
      print("Nil roof")

    # Collide with ground
    try:
      if level[int((y+yv+5)/16)][int(x/16)] == 1:
        jump = False
        air = False
        yv = 0
        while level[int((y+5)/16)][int(x/16)] == 0:
          y += 0.1
        while level[int((y+5)/16)][int(x/16)] == 1:
          y -= 0.1
        if keys[K_z]:
          yv = -4
          jump = True
    except:
      # Die
      print("Nil floor")
      die = True
      t=0
      # Set camera target
      cxt = x-sw/2
      cyt = y-sh/2
      yv = -5
      xv = 0

  else:
    if y < cy+sh+16 and t > 40:
      yv += grv
      y += yv
    if t>160:
      _init()
      die=False

  cx = min(max(cx, 0), len(level[0])*16-sw)
  cy = min(max(cy, 0), len(level)*16-sh)
  cxt = min(max(cxt, 0), len(level[0])*16-sw)
  cyt = min(max(cyt, 0), len(level)*16-sh)

  cxv = (cx-cxt)/16
  cyv = (cy-cyt)/16
  cx -= cxv
  cy -= cyv

  # Clear screen
  screen.fill((150, 150, 150))

  # Draw level
  for ty in range(len(level)):
    for tx in range(len(level[ty])):
      til = level[ty][tx]
      if til != 0 and til is not None:
        tile_x = tx*16-cx
        tile_y = ty*16-cy
        if -16 < tile_x < sw and -16 < tile_y < sh:
          screen.blit(tiles[til], (tile_x, tile_y))

  # Draw player
  screen.blit(player, (x-6-cx, y-6-cy))
  l_eye = max(min(x-3-cx+xv, x-cx-1), x-cx-4)
  r_eye = max(min(x+1-cx+xv, x-cx+2), x-cx-1)

  # Draw player eyes
  if die:
    y_eye = y-2-cy
    screen.blit(pl_eye2, (l_eye, y_eye+1))
    screen.blit(pl_eye2, (r_eye+1, y_eye+1))
  else:
    y_eye = max(min(y-4-cy+yv, y-cy), y-cy-6)
    screen.blit(pl_eye, (l_eye, y_eye))
    screen.blit(pl_eye, (r_eye, y_eye))

  # Calculate scale
  wsc = math.floor(aw/sw)
  hsc = math.floor(ah/sh)
  if aw<sh:
    sc=hsc
  else:
    sc=wsc
  nw = sw*sc
  nh = sh*sc
  xo = (aw-nw)/2
  yo = (ah-nh)/2
  fake_screen = pygame.transform.scale(screen, (nw, nh))
  real_screen.blit(fake_screen, (xo, yo))


  # Flip screen
  pygame.display.flip()

  t += 1

# exit
pygame.quit()
quit(0)
