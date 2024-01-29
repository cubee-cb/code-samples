/*
    Food class - Base class to extend into different meals
 */

public abstract class Food implements Purchasable
{
    private double price;

    public dietTypes getDietType()
    {
        return dietTypes.VEGAN;
    }

    public String toString()
    {
        return "[" + getDietType() + "] Basic Food:\n- Price: $" + getPrice();
    }
}

