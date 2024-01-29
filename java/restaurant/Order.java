/*
    Order class - Contains information about an order, including customer details and a list of meals
 */

import java.util.ArrayList;

public class Order implements Purchasable
{
    private final ArrayList<Food> MEALS;
    private final String CUSTOMER_NAME;
    private final String CUSTOMER_CONTACT; // this is a string, as this is a phone number, not an actual number
    private final String DELIVERY_ADDRESS;
    private dietTypes mealType; // may be any of the mealTypes enums
    private double price;

    public Order()
    {
        MEALS = new ArrayList<>();
        CUSTOMER_NAME = "Junk-food Jones";
        CUSTOMER_CONTACT = "0123456789";
        DELIVERY_ADDRESS = "Hamburger Lane";
        mealType = dietTypes.MEAT;
        price = 10;
    }

    public Order(String customerName, String customerNumber, String deliveryAddress)
    {
        MEALS = new ArrayList<>();
        this.CUSTOMER_NAME = customerName;
        this.CUSTOMER_CONTACT = customerNumber;
        this.DELIVERY_ADDRESS = deliveryAddress;

        // get prices and type from meals
        this.mealType = getMealType(MEALS);
        this.price = getMealPrice(MEALS);
    }

    void addMeal(Food meal)
    {
        MEALS.add(meal);

        // update order price
        price = getMealPrice(MEALS);
    }

    public dietTypes getDietType()
    {
        return getMealType(MEALS);
    }

    public dietTypes getMealType(ArrayList<Food> meals)
    {
        // default to vegan
        dietTypes orderType = dietTypes.VEGAN;

        // change meal type based on the food's meal types
        for (Food food : meals)
        {
            dietTypes foodType = food.getDietType();
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

    public double getMealPrice(ArrayList<Food> meals)
    {
        double orderPrice = 0;
        for (Food food : meals)
        {
            orderPrice += food.getPrice();
        }

        return orderPrice;
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
        StringBuilder orders = new StringBuilder();
        for (Food meal : MEALS)
        {
            orders.append(meal.toString()).append("\n");
        }

        return "[" + getMealType(MEALS) + "] Order for " + CUSTOMER_NAME + " (Contact: " + CUSTOMER_CONTACT + ")\n- Deliver to: " + DELIVERY_ADDRESS + "\n- Total Price: $" + getPrice() + "\n- Meals: " + MEALS.size() + "\n" + orders;
    }
}
