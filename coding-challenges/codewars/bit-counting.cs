using System;

public class Kata
{
  public static int CountBits(int n)
  {
    // convert the int to a string in base 2
    string binaryString = Convert.ToString(n, 2);
    
    // count ones in string
    int countOnes = 0;
    foreach (char c in binaryString)
    {
      if (c == '1') countOnes++;
    }
    
    return countOnes;
  }
}