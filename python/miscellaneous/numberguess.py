# Import modules
import random, math

# Random number
n=math.floor(random.random()*10)+1
t=0
print("1 to 10")

def _main():
    global n
    global t
    try:
        # Get input
        i=int(input("Enter number: "))
        run=True
    except:
        # Check if number
        print("\nNot an integer\n")
        run=False

    if run:
        t+=1
        # Check if correct
        if i==n:
            # Correct
            print("\nCorrect. " + str(t) + " tries.\n")
            t=0
            n=math.floor(random.random()*10)+1
        else:
            # Incorrect
            print("")
            if i>10:
                print("Too High.")
            elif i<1:
                print("Too low.")
            elif i>n:
                print("Lower.")
            elif i<n:
                print("Higher.")
            print("")

while True:
    _main()
