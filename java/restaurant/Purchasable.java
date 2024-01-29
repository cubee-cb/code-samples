/*
    Purchasable Interface - Basic object that can be implemented to gain getPrice and setPrice methods
 */

public interface Purchasable
{
    double price = 11.5;

    double getPrice();

    boolean setPrice(double newPrice);

    String toString();
}
