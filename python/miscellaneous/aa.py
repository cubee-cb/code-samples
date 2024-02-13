import random
import time

auto = True

while True:

    health = random.randint(50, 100)
    turn = random.randint(0, 1)
    defeat = -1

    while health > 0:
        boss = random.randint(50, 100)
        defeat += 1
        while health > 0 and boss > 0:
            print()
            if turn == 0:
                print("Boss's turn")
            else:
                print("Your turn")
            if auto:
                time.sleep(1.5)
            else:
                input("Press ENTER ")
            attack = random.randint(3, 10)
            defence = random.randint(3, 10)
            damage = attack - defence
            damage = max(damage, 0)
            if turn == 0:
                health -= damage
                turn = 1
            else:
                boss -= damage
                turn = 0

            print()
            if damage > 0:
                print("Hit! " + str(damage) + " damage.")
            else:
                print("Miss!")
            print("Boss:  " + str(boss))
            print("You:  " + str(health))
            time.sleep(1)
        print("\nBoss defeated\n")
        health += random.randint(50, 100)
        print("Health regenerated\n")

    print("Game Over")
    print("You defeated " + str(defeat) + " bosses.")
    time.sleep(2)
