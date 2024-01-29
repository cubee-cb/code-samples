
// take a string input and split it by the delimeter into the returned vector<string>
vector<string> split(const string& input, char delimiter)
{
    vector<string> out;
    int delimiterPosition = 0;

    // add first entry. also allows returning the input string if no delimiter is found
    delimiterPosition = (int)(input.find(delimiter));
    out.push_back(input.substr(0, delimiterPosition));

    // loop to find delimeters and add substrings to the output
    while (input.find(delimiter, delimiterPosition) != string::npos)
    {
        int subStart = (int)(input.find(delimiter, delimiterPosition));
        delimiterPosition = (int)(input.find(delimiter, delimiterPosition + 1));
        string subStr = input.substr(subStart + 1, delimiterPosition - subStart - 1);
        out.push_back(subStr);

    }

    return out;
}
