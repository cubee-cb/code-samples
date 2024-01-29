/*
    Pizza class - Extends Food class to store info about a Pizza meal
 */

import java.util.ArrayList;

public class Pizza extends Food
{
    private final ArrayList<Topping> TOPPINGS;
    private double price;

    public Pizza()
    {
        price = 11.5;
        TOPPINGS = new ArrayList<>();
    }

    public Pizza(ArrayList<Topping> newToppings)
    {
        price = 11.5;
        TOPPINGS = newToppings;
    }

    public void addTopping(Topping newTopping)
    {
        TOPPINGS.add(newTopping);

        // update meal price
        price += newTopping.getPrice();
    }

    public dietTypes getDietType()
    {
        // default to vegan
        dietTypes orderType = dietTypes.VEGAN;

        // change meal type based on the food's meal types
        for (Topping topping : TOPPINGS)
        {
            dietTypes foodType = topping.getDietType();

            switch (foodType)
            {
                case MEAT:
                    // always set to meat meal if there is any meat
                    orderType = dietTypes.MEAT;
                    break;

                case VEGETARIAN:
                    // only set to vegetarian if this isn't a meat meal
                    if (orderType != dietTypes.MEAT) orderType = dietTypes.VEGETARIAN;
                    break;
            }
        }

        return orderType;
    }

    public double getPrice()
    {
        return price;
    }


    public boolean setPrice(double newPrice)
    {
        // prevent setting the price negative
        if (newPrice < 0) return false;

        price = newPrice;
        return true;
    }

    public String toString()
    {
        // build string from toppings
        StringBuilder toppingString = new StringBuilder();
        for (Topping topping : TOPPINGS)
        {
            toppingString.append(topping.getDisplayName()).append(" ");
        }

        // if there are no toppings, say it's a plain pizza
        if (TOPPINGS.size() == 0) toppingString.append("Plain ");

        return "[" + getDietType() + "] " + toppingString + "Pizza:\n- Price: $" + getPrice();
    }
}
