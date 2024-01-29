
// function to get a character within a range as input from the player
char getCharInput(const string& question, char min, char max)
{
    char out = 0;
    bool accepted = false;

    // repeat until we get a character we can accept
    do
    {
        // ask for input and specify the appropriate character range to the user
        cout << question + " [" << min << "-" << max << "]: ";
        string line;
        cin >> line;

        // get the first character of the input
        out = line[0];

        // convert uppercase chars to lowercase
        if (out >= 'A' && out <= 'Z') out = _tolower(line[0]);

        // check if the input is in range and the user actually input only one char, then tell the user if not
        accepted = out >= min && out <= max && line.length() == 1;
        if (!accepted)
        {
            cout << "Please enter a letter in the range specified.\n";
        }

    } while (!accepted);

    // discard enter press
    string discardString;
    getline(cin, discardString);
    return out;
}


// function to get a character from specific allowed options contained in a string as input from the player
char getCharInput(const string& question, const string& validChars)
{
    char out = 0;
    bool accepted = false;

    // repeat until we get a character we can accept
    do
    {
        // ask for input and specify the appropriate character range to the user
        cout << question + ": ";
        string line;
        cin >> line;

        // get the first character of the input
        out = line[0];

        // convert uppercase chars to lowercase
        if (out >= 'A' && out <= 'Z') out = _tolower(line[0]);

        // check if the character was one of the allowed options
        accepted = false;
        for (char character : validChars)
        {
            if (out == character) accepted = true;
        }

        // check if the input is in range and the user actually input only one char, then tell the user if not
        if (!accepted || line.length() > 1)
        {
            cout << "Please choose one of the allowed options.\n";
        }

    } while (!accepted);

    // discard enter press
    string discardString;
    getline(cin, discardString);
    return out;
}
