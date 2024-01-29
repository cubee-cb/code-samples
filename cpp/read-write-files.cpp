
// read a file and return its content as a string
string readFileContent(const string& filePath)
{
    // open stream
    string content;
    ifstream fileStream(filePath);

    // check if file is open before trying to read it
    if (fileStream.is_open())
    {
        // read file content
        string line;
        bool firstDone = false; // this tracks whether a newline should be added, skips adding one to the first line.
        while (getline(fileStream, line))
        {
            if (firstDone) content.append("\n");
            content.append(line);

            firstDone = true;
        }
    }
        // set content to error string if the file could not be opened
    else
    {
        content = "could not open file: \"" + filePath + "\"";
    }

    // close stream
    fileStream.close();

    return content;
}


// write to a file. returns false if the file could not be found, and true if it was
bool writeFile(const string& fileName, const string& content)
{
    string fileContent;

    // get file stream and open file
    ofstream fileStream(fileName); // ofstream: OUTPUT file stream

    // is file open?
    if (fileStream.is_open())
    {
        // write content to file
        fileStream << content;

        fileStream.close();
        return true;
    }
    // inform user if the file was not found
    else
    {
        printLine("Could not open file: " + fileName);

        fileStream.close();
        return false;
    }

}
