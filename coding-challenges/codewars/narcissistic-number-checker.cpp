#include <math.h>
// checks if a number is narcissistic
bool narcissistic( int value )
{
  std::string numbers_string = std::to_string(value);
  int result = 0;
  for (int i = 0; i < numbers_string.size(); i++)
  {
    result += std::pow((int)numbers_string[i] - 48, numbers_string.size());
  }
  return value == result;
}