/*
    Pasta class - Extends Food class to store info about a Pasta meal
 */

public class Pasta extends Food
{
    private Topping topping;
    private double price;

    public Pasta()
    {
        price = 11.5;
    }

    public Pasta(Topping newTopping)
    {
        price = 11.5;
        topping = newTopping;
    }

    public dietTypes getDietType()
    {
        // return the diet type of the topping
        return topping == null? dietTypes.VEGAN : topping.getDietType();
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

    public void setTopping(Topping newTopping)
    {
        // update meal price
        // the topping is being replaced, so remove the old topping's price if it was set
        if (topping != null) price -= topping.getPrice();
        price += newTopping.getPrice();

        topping = newTopping;
    }

    public String toString()
    {
        // get name of topping
        String toppingString = "Plain ";
        if (topping != null) toppingString = topping.getDisplayName() + " ";

        return "[" + getDietType() + "] " + toppingString + "Pasta:\n- Price: $" + getPrice();
    }
}
