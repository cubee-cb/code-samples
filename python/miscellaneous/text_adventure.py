import time
sleep=time.sleep
inv=[]

def choose():
    print()
    print("You have:")
    if len(inv)==0:
        print("- nothing")
    else:
        for i in range(len(inv)):
            print("- " + str(inv[i]))
    try:
        c=int(input("Enter choice: "))
    except:
        print("What?")
        c=0
    print()
    return c

def intro():
    print("Type (1) to start")
    c=choose()
    if c==1:
        r1()
    else:
        intro()

def r1():
    print("You enter 'Room 1'")
    sleep(1)
    print("\nGo to (1) 'Room 2'")
    c=choose()
    if c==1:
        r2()
    else:
        r1()

def r2():
    print("You enter 'Room 2'")
    sleep(1)
    print("\nGo to (1) 'Win Room' or (2) 'Room 1'")
    c=choose()
    if c==1:
        win()
    elif c==2:
        r1()
    else:
        r2()

def win():
    print("You win")
    sleep(1)
    print()
    intro()

intro()
