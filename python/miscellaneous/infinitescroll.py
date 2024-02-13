import random, time

# Set variables
x=0
y=0
z=0
l="\\"
t="_"
dly=0.1
upl=42
slv=12

# Program header
print("infinitescroll.py - Infinite Terrain Generator.")
#print("Lock in portrait but hold in landscape")
#input("for best experience, then press enter.")

# Main loop
while True:
 
 # Calculate the symbol for the terrain
 z=random.randint(-1,1)
 if z==1:
  l="\\"
 elif z==-1:
  l=t+"/"
 else:
  l="|"
  
 # Random stuff
 
 # Plants
 
 # Trees
 if random.randint(1,6)==1:
  tr="="*random.randint(1,6)
  l=l+"%s()" % tr
  
 # Flowers
 elif random.randint(1,3)==1:
  l=l+"*"
  
 # Grass
 elif random.randint(1,3)==1:
  l=l+"<"
  
 # Clouds
 if random.randint(1,4)==1:
  cl=" "*random.randint(10,18)
  l=l+"%s@" % cl
  
# Move the terrain
 y=y+z
 
 # Upper/lower limits
 if y>upl:
  y=upl
  l="|"
 if y<=slv:
  y=slv
  l=")"
  t=" "
 else:
  t="_"
  
 x=str(t)*y
 print(str(x)+str(l))
 time.sleep(dly)
