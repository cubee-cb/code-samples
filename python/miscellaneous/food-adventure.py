# Food Adventure
# By Cubee <('.'<)

# Import
import time
import random

items = ["stick", "sword", "flowerpot", "twig", "shovel", "yourself", "abandoned pie", "old computer", "pillow",
         "video game", "bird", "book", "novel", "teapot", "gold bar", "brick", "pancake", "hamburger", "paper",
         "paper plane", "knife", "fork", "spoon", "axe", "toy car", "burrito", "taco", "cherry", "window", "hammer",
         "chair", "paintbrush", "new computer", "console", "controller", "vegetable", "abandoned quiche", "ghost",
         "spider", "solar system", "universe", "black hole", "star", "sun", "moon", "toy", "doll", "action figure",
         "blocks", "remote", "brick", "apple", "orange", "eggplant", "blue hedgehog", "fast hedgehog", "enchilada",
         "faster hedgehog", "plumber toy", "plastic bag", "sauce bottle", "pan", "annoying dog", "legendary artifact",
         "snail pie", "fish", "goat", "pain", "angry duck", "cardboard chip", "potato", "k9", "9001", "cougar 600",
         "green carpet", "grass patch", "fabric", "miner", "cubee", "oven", "air conditioner", "prisoner", "monster",
         "mirror", "fancy hat", "fancy jacket", "fancy shoes", "hole", "nothing", "giant", "snake", "segway", "robot",
         "goose", "helmet", "priceless vase", "expensive plate", "expensive computer", "money", "f2p game", "bad times",
         "good times", "average times", "today", "tomorrow", "history", "all time", "bill cipher", "harry", "bread",
         "glasses", "blue curtains", "red chair", "yellow table", "diamond", "topaz", "sapphire", "ruby", "emerald",
         "helium", "balloon", "turtle shell", "feather", "air", "toast", "toastie", "go-kart", "internet", "galaxy",
         "jar of honey", "tablet", "spatula", "crab", "keyboard", "dust", "red dot", "laser beam", "death star laser",
         "war", "fluff", "slime", "vase", "glass", "ceramic figure", "integer", "error 9001", "over 9000", "flying hat",
         "wing cap", "metallic cube", "wood", "rock", "sans", "coal", "present", "santa", "quote", "ryu", "circuit",
         "lead", "kryptonite", "disc", "cassette", "generic food", "digital code", "anonymous", "music", "record",
         "carbon", "vr helmet", "leaf", "mouse", "past", "future", "checkpoint", "sign", "grenade", "wand", "magic",
         "darkness", "light", "wall", "floor", "bat", "batmobile", "oxygen", "water", "juice", "cup", "dirt", "salt"]

# Player stats
inventory = ["shoes", "jacket", "hat"]
eaten = 0

# Room inventories
out_inv = []
for it in range(random.randint(1, 10)):
    out_inv.append(items[random.randint(0, len(items)-1)])
h1_inv = []
for it in range(random.randint(1, 10)):
    h1_inv.append(items[random.randint(0, len(items)-1)])
back_inv = []
for it in range(random.randint(1, 10)):
    back_inv.append(items[random.randint(0, len(items)-1)])
r1_inv = []
for it in range(random.randint(1, 10)):
    r1_inv.append(items[random.randint(0, len(items)-1)])
r2_inv = []
for it in range(random.randint(1, 10)):
    r2_inv.append(items[random.randint(0, len(items)-1)])

# Texts
c = ""
ouch = "You can't go that way.\n"  # "Ouch. Walls hurt.\n"
line = "________________________________________"

# Input items
ex = ["exit", "quit", "stop", "close"]
n = ["n", "north"]
s = ["s", "south"]
e = ["e", "east"]
w = ["w", "west"]
u = ["u", "up"]
d = ["d", "down"]
get = ["take", "get", "grab"]
use = ["use", "equip", "wear"]
eat = ["eat", "consume", "yum"]
look = ["l", "look", "where", "where?", "where am i", "where am i?", "?"]


def choose(inv=None, prompt="> "):
    global eaten, inventory

    print(line)
    print()

    # Game over if no items
    if len(inventory) == 0:
        _print("Game Over")
        _print("You ate " + str(eaten) + " things.")
        _print("Empty pockets aren't edible", 2)
        input("Press ENTER to quit.")
        exit()

    print("You have: " + str(inventory))
    if inv is None or inv == []:
        inv = []
        _print("Nothing in this area")
    else:
        _print("Here there is: " + str(inv))
    a = input(prompt).lower()
    print()

    # Close game
    for i in range(len(ex)):
        if a == ex[i]:
            _print("Bye")
            exit()

    # Eat items
    for i in range(len(inventory)):
        for i2 in range(len(eat)):

            if a == eat[i2] + " all":
                for ir in range(len(inventory)):
                    eaten += 1
                    _print("You " + eat[i2] + " the " + inventory[i] + "!")
                    inventory[i] = "green---"
                    inventory.remove("green---")
                print()
                _print("You have eaten " + str(eaten) + " things.")
                return 0, inv

            if a == eat[i2] + " " + inventory[i]:
                eaten += 1
                food = ["Yum.", "Good food.", "CONSUMING OBJECT...   ...   DONE.", "Eating intensifies.",
                        "Fortunately, you couldn't not eat it.", "...", "You have eaten " + str(eaten) + " items now!"]
                _print("You " + eat[i2] + " the " + inventory[i] + "!")
                _print(food[min(int(eaten/4), len(food)-1)])
                print()
                _print("You have eaten " + str(eaten) + " things.")
                inventory[i] = "green---"
                inventory.remove("green---")
                return 0, inv

    # Use items
    for i in range(len(inventory)):
        for i2 in range(len(use)):
            if a == use[i2] + " " + inventory[i]:
                _print("You " + use[i2] + " the " + inventory[i] + ", but why didn't you eat it?")
                print()
                inventory[i] = "green---"
                inventory.remove("green---")
                return 0, inv

    # Take items
    for i in range(len(inv)):
        for i2 in range(len(get)):

            if a == get[i2] + " all":
                for ir in range(len(inv)):
                    _print("You " + get[i2] + " the " + inv[i] + "!", 0.2)
                    inventory.append(inv[i])
                    inv[i] = "green---"
                    inv.remove("green---")
                return 0, inv

            if a == get[i2] + " " + inv[i]:
                _print("You " + get[i2] + " the " + inv[i] + "!")
                inventory.append(inv[i])
                inv[i] = "green---"
                inv.remove("green---")
                return 0, inv

    # Moving around
    for i in range(len(n)):
        if a == n[i]:
            return "north", inv
    for i in range(len(s)):
        if a == s[i]:
            return "south", inv
    for i in range(len(e)):
        if a == e[i]:
            return "east", inv
    for i in range(len(w)):
        if a == w[i]:
            return "west", inv
    for i in range(len(u)):
        if a == u[i]:
            return "up", inv
    for i in range(len(d)):
        if a == d[i]:
            return "down", inv
    for i in range(len(look)):
        if a == look[i]:
            return "look", inv
    _print("You can't do that.")
    print()
    return 0, inv


def _print(text, delay=0.5):
    print(text)
    time.sleep(delay)


# Game rooms
def intro():
    print(line)
    print()
    global c
    _print("You are in a room")
    _print("There is a door NORTH")
    _print("There is a door EAST")
    c, ds = choose()
    if c == "look":
        intro()
    elif c == "north":
        hall1()
    elif c == "east":
        hall2()
    elif c != 0:
        print(ouch)
    intro()


# Path 1
def hall1():
    print(line)
    print()
    global c, h1_inv
    _print("You are in a hallway")
    _print("There is a door NORTH and a door SOUTH")
    c, h1_inv = choose(h1_inv)
    if c == "look":
        hall1()
    elif c == "north":
        outside()
    elif c == "south":
        intro()
    elif c != 0:
        print(ouch)
    hall1()


def outside():
    print(line)
    print()
    global c, out_inv
    _print("You went outside")
    _print("There is a house SOUTH")
    c, out_inv = choose(out_inv)
    if c == "look":
        outside()
    elif c == "south":
        hall1()
    elif c != 0:
        print(ouch)
    outside()


# Path 2
def hall2():
    print(line)
    print()
    global c
    _print("You are in a hallway")
    _print("There are doors NORTH and WEST")
    _print("You can go outside EAST")
    c, ds = choose()
    if c == "look":
        hall2()
    elif c == "north":
        room1()
    elif c == "west":
        intro()
    elif c == "east":
        backyard()
    elif c != 0:
        print(ouch)
    hall2()


def room1():
    print(line)
    print()
    global c, r1_inv
    _print("You are in a room")
    _print("There is a door SOUTH")
    c, r1_inv = choose(r1_inv)
    if c == "look":
        room1()
    elif c == "south":
        hall2()
    elif c != 0:
        print(ouch)
    room1()


def backyard():
    print(line)
    print()
    global c, back_inv
    _print("You went into a small place surrounded by fences.")
    _print("There is a door to inside WEST")
    _print("There is a ladder UP to the roof")
    c, back_inv = choose(back_inv)
    if c == "look":
        backyard()
    elif c == "west":
        hall2()
    elif c == "up":
        roof()
    elif c != 0:
        print(ouch)
    backyard()


def roof():
    print(line)
    print()
    global c, r2_inv
    _print("You are on the roof")
    _print("The fence area is DOWN the ladder")
    c, r2_inv = choose(r2_inv)
    if c == "look":
        roof()
    elif c == "down":
        backyard()
    elif c != 0:
        print(ouch)
    roof()


while True:
    print()
    _print("_)\\,.-~')__Food Adventure__('~-.,/(_")
    _print("By Cubee")
    print()
    _print("Instructions:")
    _print("Keywords for moving are CAPITAL")
    _print("EAT everything you can to get points")
    _print("However, before you can EAT, you must first TAKE")
    _print("TAKE ALL to TAKE everything in the room.")
    _print("EAT ALL to EAT everything, then the game will be over")
    _print("(You can also USE items, but that's a bad idea)")
    print()
    input("Press ENTER to continue.")
    print()
    _print("Shorthands:\n n: north\n s: south\n e: east\n w: west\n l: look")
    print()
    input("Press ENTER to continue.")
    intro()
