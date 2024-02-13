import time

c = ""
ouch = "Ouch. Walls hurt.\n"
line = "----------------"
n = ["n", "north"]
s = ["s", "south"]
e = ["e", "east"]
w = ["w", "west"]
u = ["u", "up"]
d = ["d", "down"]
look = ["l", "look", "where", "where?", "where am i", "where am i?"]


def choose(prompt):
    print()
    print(line)
    a = input(prompt).lower()
    print()
    for i in range(len(n)):
        if a == n[i]:
            return "north"
    for i in range(len(s)):
        if a == s[i]:
            return "south"
    for i in range(len(e)):
        if a == e[i]:
            return "east"
    for i in range(len(w)):
        if a == w[i]:
            return "west"
    for i in range(len(u)):
        if a == u[i]:
            return "up"
    for i in range(len(d)):
        if a == d[i]:
            return "down"
    for i in range(len(look)):
        if a == look[i]:
            return "look"
    print("What?")
    return 0


def _print(text, delay=0.5):
    print(text)
    time.sleep(delay)


def intro():
    global c
    _print("You are in a room")
    _print("There is a door north")
    _print("There is a door east")
    c = choose("Choose: ")
    if c == "look":
        intro()
    elif c == "north":
        hall1()
    elif c == "east":
        hall2()
    elif c != 0:
        print(ouch)
    intro()


def hall1():
    global c
    _print("You are in a hallway")
    _print("There is a door north and a door south")
    c = choose("Choose: ")
    if c == "look":
        hall1()
    elif c == "south":
        intro()
    elif c != 0:
        print(ouch)
    hall1()


def hall2():
    global c
    _print("You are in a hallway")
    _print("There are doors north, east and west")
    c = choose("Choose: ")
    if c == "look":
        hall2()
    elif c == "north":
        room1()
    elif c == "west":
        intro()
    elif c == "east":
        hall2()
    elif c != 0:
        print(ouch)
    hall2()


def room1():
    global c
    _print("You are in a room")
    _print("There is a door south")
    c = choose("Choose: ")
    if c == "look":
        room1()
    elif c == "south":
        hall2()
    elif c != 0:
        print(ouch)
    room1()


while True:
    intro()
