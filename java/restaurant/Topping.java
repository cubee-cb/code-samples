/*
    Topping class - stores info about a Topping object
 */

public class Topping implements Purchasable
{
    private final toppingTypes TYPE;
    private final String DISPLAY_NAME;
    private double price;
    private dietTypes dietType;

    public Topping()
    {
        TYPE = toppingTypes.HAM;
        price = getToppingPrice(TYPE);
        DISPLAY_NAME = getToppingName(TYPE);
        dietType = getToppingDiet(TYPE);
    }

    public Topping(toppingTypes newType)
    {
        TYPE = newType;
        price = getToppingPrice(TYPE);
        DISPLAY_NAME = getToppingName(TYPE);
        dietType = getToppingDiet(TYPE);
    }

    public dietTypes getDietType()
    {
        return dietType;
    }

    public String getDisplayName()
    {
        return DISPLAY_NAME;
    }

    public double getPrice()
    {
        return price;
    }

    // determines the price of the topping based on its type
    public double getToppingPrice(toppingTypes toppingType)
    {
        double toppingPrice = 0;
        switch (toppingType)
        {
            // pizza toppings
            default:
            case HAM:
            case CHEESE:
            case MUSHROOMS:
            case TOMATO:
                toppingPrice = 2;
                break;
            case PINEAPPLE:
                toppingPrice = 2.5;
                break;
            case SEAFOOD:
                toppingPrice = 3.5;
                break;

            // pasta toppings
            case TOMATO_PASTA:
                toppingPrice = 4;
                break;
            case BOLOGNESE:
            case PRIMAVERA:
                toppingPrice = 5.2;
                break;
            case MARINARA:
                toppingPrice = 6.8;
                break;
        }

        return toppingPrice;
    }

    // converts the passed enum value into a string
    public String getToppingName(toppingTypes toppingType)
    {
        String toppingName = "Dubious";
        switch (toppingType)
        {
            // pizza toppings
            case HAM:
                toppingName = "Ham";
                break;
            case CHEESE:
                toppingName = "Cheese";
                break;
            case MUSHROOMS:
                toppingName = "Mushroom";
                break;
            case TOMATO:
                toppingName = "Tomato";
                break;
            case PINEAPPLE:
                toppingName = "Pineapple";
                break;
            case SEAFOOD:
                toppingName = "Seafood";
                break;

            // pasta toppings
            case TOMATO_PASTA:
                toppingName = "Tomato";
                break;
            case BOLOGNESE:
                toppingName = "Bolognese";
                break;
            case PRIMAVERA:
                toppingName = "Primavera";
                break;
            case MARINARA:
                toppingName = "Marinara";
                break;
        }

        return toppingName;
    }

    // converts the passed enum value into a string
    public dietTypes getToppingDiet(toppingTypes toppingType)
    {
        dietTypes diet;
        switch (toppingType)
        {
            // pizza toppings
            case HAM:
            case SEAFOOD:
            case BOLOGNESE:
                diet = dietTypes.MEAT;
                break;
            case CHEESE:
            case TOMATO:
            case PINEAPPLE:
            case TOMATO_PASTA:
            case PRIMAVERA:
                diet = dietTypes.VEGETARIAN;
                break;
            default:
            case MUSHROOMS:
            case MARINARA:
                diet = dietTypes.VEGAN;
                break;

        }

        return diet;
    }

    public boolean setDietType(dietTypes newDietType)
    {
        dietType = newDietType;
        return true;
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
        return "Topping: price: $" + getPrice();
    }
}
