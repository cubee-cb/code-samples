using System;
using System.Linq;

public class Kata
{
  public int ReverseNumber(int n)
  {
    char[] outString = Math.Abs(n).ToString().ToCharArray();
    Array.Reverse(outString);
    return int.Parse(new string(outString)) * Math.Sign(n);
  }
}