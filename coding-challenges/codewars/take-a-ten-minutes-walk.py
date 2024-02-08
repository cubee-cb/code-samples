# the goal is to validate whether a list of NSEW characters moves across exactly 10 spaces and end up at the starting location
# to ensure we end up at the same starting location, we can just check if we move north/east and back south/west the same amount. if we move the same distance both ways, we may as well have not moved at all.

def is_valid_walk(walk):
    return len(walk) == 10 and walk.count('e') == walk.count('w') and walk.count('n') == walk.count('s')
