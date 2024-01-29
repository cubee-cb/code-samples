/*
    Restaurant Order Tracker
    Author: J M

    Main class for the Restaurant Order Tracker program
 */

import java.util.ArrayList;
import java.util.Scanner;

public class RestaurantDriver
{
    final static String LINE = "--------------------------------------------";

    static void testClasses()
    {
        System.out.println("=== default ===");

        Order defaultOrder = new Order();
        Pizza defaultPizza = new Pizza();
        Pasta defaultPasta = new Pasta();
        Topping defaultTopping = new Topping();

        System.out.println(defaultOrder);
        System.out.println(defaultPizza);
        System.out.println(defaultPasta);
        System.out.println(defaultTopping);

        System.out.println("=== non-default ===");

        Topping ham = new Topping(toppingTypes.HAM);
        Topping cheese = new Topping(toppingTypes.CHEESE);
        Topping bolognese = new Topping(toppingTypes.BOLOGNESE);

        Pizza pizza = new Pizza();
        pizza.addTopping(ham);
        pizza.addTopping(cheese);

        Pasta pasta = new Pasta();
        pasta.setTopping(bolognese);

        Order order = new Order("Mario Mario", "2550101804", "Mushroom Kingdom");
        order.addMeal(pizza);
        order.addMeal(pasta);

        System.out.println(order);
        System.out.println(pizza);
        System.out.println(pasta);
        System.out.println(ham);
        System.out.println(cheese);
        System.out.println(bolognese);
    }

    private static String askForString(String question)
    {
        String line = null;

        while (line == null || line.isEmpty())
        {
            System.out.println(question + ": ");
            Scanner scanner = new Scanner(System.in);
            line = scanner.nextLine();
        }

        return line;
    }

    // simple function to prompt user for any input; reusable
    private static void waitForInput()
    {
        System.out.println("Press ENTER to continue");
        Scanner scanner = new Scanner(System.in);
        scanner.nextLine();
    }

    // this function loops while the user creates meals, and adds those meals to the order passed into the function
    private static void createOrderMeals(Order order)
    {

        // ask for meals in a loop
        boolean addingMeals = true;
        while (addingMeals)
        {
            // ask for meal type
            Food meal = null;
            char response;
            while (meal == null)
            {
                // ask what meal type the user wants to make
                System.out.println(LINE);
                System.out.println("[A] Pizza - [B] Pasta");
                response = askForString("Which type of meal are you adding? [A/B]").toLowerCase().charAt(0);

                switch (response)
                {
                    case 'a':
                    {
                        meal = new Pizza();
                        break;
                    }
                    case 'b':
                    {
                        meal = new Pasta();
                        break;
                    }
                }
            }

            boolean editingMeal = true;
            while (editingMeal)
            {
                // print details for the current meal
                System.out.println(LINE);
                System.out.println("Current meal details:");
                System.out.println(meal);
                System.out.println(LINE);

                // ask what to do for the current meal
                if (meal.getClass() == Pizza.class)
                {
                    System.out.println("[A]dd topping to meal - [C]reate another meal - [S]ubmit order");
                }
                else
                {
                    System.out.println("[A]pply meal topping - [C]reate another meal - [S]ubmit order");
                }
                response = askForString("What would you like to do?").toLowerCase().charAt(0);

                System.out.println(LINE);
                switch (response)
                {
                    // [A]dd topping to meal
                    case 'a':
                    {
                        if (meal.getClass() == Pizza.class)
                        {
                            ((Pizza) meal).addTopping(getPizzaTopping());
                        }
                        else
                        {
                            ((Pasta) meal).setTopping(getPastaTopping());
                        }
                        break;
                    }
                    // [C]reate another meal
                    case 'c':
                    {
                        System.out.println("Adding another meal.");
                        editingMeal = false;
                        break;
                    }
                    // [S]ubmit order
                    case 's':
                    {
                        System.out.println("Order creation finished.");
                        editingMeal = false;
                        addingMeals = false;
                        break;
                    }
                }
            }
            order.addMeal(meal);

        }
    }

    private static Topping getPizzaTopping()
    {
        Topping topping = null;

        while (topping == null)
        {
            System.out.println("Available toppings:\n[H]am\n[C]heese\n[P]ineapple\n[M]ushrooms\n[T]omato\n[S]eafood");
            char toppingChar = askForString("Choose a topping").toLowerCase().charAt(0);
            switch (toppingChar)
            {
                default:
                {
                    System.out.println(LINE);
                    System.out.println("Invalid option");
                    waitForInput();
                    break;
                }
                case 'h':
                {
                    topping = new Topping(toppingTypes.HAM);
                    break;
                }
                case 'c':
                {
                    topping = new Topping(toppingTypes.CHEESE);
                    break;
                }
                case 'p':
                {
                    topping = new Topping(toppingTypes.PINEAPPLE);
                    break;
                }
                case 'm':
                {
                    topping = new Topping(toppingTypes.MUSHROOMS);
                    break;
                }
                case 't':
                {
                    topping = new Topping(toppingTypes.TOMATO);
                    break;
                }
                case 's':
                {
                    topping = new Topping(toppingTypes.SEAFOOD);
                    break;
                }
            }
        }



        return topping;
    }

    private static Topping getPastaTopping()
    {
        Topping topping = null;

        while (topping == null)
        {
            System.out.println("Available toppings:\n[B]olognese\n[M]arinara\n[P]rimavera\n[T]omato");
            char toppingChar = askForString("Choose a topping").toLowerCase().charAt(0);
            switch (toppingChar)
            {
                default:
                {
                    System.out.println(LINE);
                    System.out.println("Invalid option");
                    waitForInput();
                    break;
                }
                case 'b':
                {
                    topping = new Topping(toppingTypes.BOLOGNESE);
                    break;
                }
                case 'm':
                {
                    topping = new Topping(toppingTypes.MARINARA);
                    break;
                }
                case 'p':
                {
                    topping = new Topping(toppingTypes.PRIMAVERA);
                    break;
                }
                case 't':
                {
                    topping = new Topping(toppingTypes.TOMATO_PASTA);
                    break;
                }
            }
        }

        return topping;
    }

    public static void main(String[] args)
    {
        // test the classes function
        //testClasses();

        ArrayList<Order> orders = new ArrayList<>();


        // loop
        boolean running = true;
        while (running)
        {

            // ask for user choice
            System.out.println("[A]dd an order - [D]eliver an order - [L]ist orders - [Q]uit");

            char choice = askForString("What would you like to do? ").toLowerCase().charAt(0);

            System.out.println(LINE);
            switch (choice)
            {
                default:
                {
                    System.out.println("That is not a valid option.");
                    break;
                }

                // [A]dd a new order
                case 'a':
                {
                    System.out.println("Adding a new order.");
                    System.out.println(LINE);
                    // ask for name, phone, address
                    String name = askForString("Customer Name");
                    String phone = askForString("Contact (Phone)");
                    String address = askForString("Delivery Address");

                    // create order
                    Order order = new Order(name, phone, address);
                    createOrderMeals(order);
                    orders.add(order);

                    // show order details
                    System.out.println(LINE);
                    System.out.println("Created order:");
                    System.out.println(order);
                    System.out.println(LINE);

                    waitForInput();

                    break;
                }

                // [D]eliver an order
                case 'd':
                {
                    if (orders.isEmpty())
                    {
                        System.out.println("There are no orders to deliver.");
                    }
                    else
                    {
                        System.out.println("The following order has been dispatched:");

                        // remove the first order from the list, and print the details from the removed object
                        Order removedOrder = orders.remove(0);
                        System.out.println(removedOrder.toString());
                    }


                    break;
                }

                // [L]ist existing orders
                case 'l':
                {
                    if (orders.isEmpty())
                    {
                        System.out.println("There are currently no orders.");
                    }
                    else
                    {
                        System.out.println("Current orders:");

                        // print all existing orders
                        for (Order order : orders)
                        {
                            System.out.println(order.toString());
                        }
                    }
                    break;
                }

                // [Q]uit
                case 'q':
                {
                    System.out.println("Goodbye!");
                    running = false;
                    break;
                }
            }

            System.out.println(LINE);

        }

        // end of loop
    }
}