using System;

public static class Kata
{
  public static string Disemvowel(string str)
  {
    string[] vowels = new string[5] { "a", "e", "i", "o", "u"};

    foreach (string vowel in vowels)
    {
      str = str.Replace(vowel, string.Empty).Replace(vowel.ToUpper(), string.Empty);
    }
    
    return str;
  }
}