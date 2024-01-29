// Most of these functions depend on the Cubee.DebugPrint() function existing in the same namespace.

// clip the filename from a path to use as a key. allows setting a "namespace" via prefix, for avoiding duplicate id conflicts from different mods. e.g. minecraft.torch, or caseytime.casey
string KeyFromPath(string i, string prefix)
{
  string item = i.Split(Path.DirectorySeparatorChar)[^1];
  item = item.Substring(0, item.LastIndexOf("."));

  if (prefix != "" && !item.Contains(".")) item = prefix + "." + item;

  return item;
}


// function to load json files into a dictionary (key is filename without extensions, formatted as namespace.item)
void LoadJsonFromFolder<T>(string label, Dictionary<string, T> dictionary, string path, string prefix = "")
{
  if (Directory.Exists(path))
  {
    foreach (string i in Directory.GetFiles(path))
    {
      T loaded = JsonConvert.DeserializeObject<T>(File.ReadAllText(i), loadingJsonSettings);

      // clip directory path
      string item = KeyFromPath(i, prefix);

      // add, replacing items if they already exist
      if (dictionary.ContainsKey(item))
      {
        dictionary[item] = loaded;
      }
      else
      {
        dictionary.Add(item, loaded);
      }

      Cubee.DebugPrint("loaded " + label + " \"" + item + "\"");
    }

  }
}


// function to load json files into a list (key is a number)
void LoadJsonFromFolderAsList<T>(string label, List<T> list, string path, string prefix = "")
{
  if (Directory.Exists(path))
  {
    foreach (string i in Directory.GetFiles(path))
    {
      T loaded = JsonConvert.DeserializeObject<T>(File.ReadAllText(i), loadingJsonSettings);

      // clip directory path
      string item = KeyFromPath(i, prefix);

      list.Add(loaded);

      Cubee.DebugPrint("loaded " + label + " \"" + item + "\"");
    }

  }
}


// function to load graphics into a dictionary
void LoadGFXFromFolder(string label, Dictionary<string, Texture2D> dictionary, string path, string prefix = "")
{
  Cubee.DebugPrint("textures");
  if (Directory.Exists(path))
  {
    foreach (string i in Directory.GetFiles(path))
    {
      // import png as Texture2D
      FileStream fileStream = new FileStream(i, FileMode.Open);
      try
      {
        Texture2D loaded = Texture2D.FromStream(GraphicsDevice, fileStream);

        // clip directory path
        string item = KeyFromPath(i, prefix);

        // add, replacing items if they already exist
        if (dictionary.ContainsKey(item))
        {
          dictionary[item] = loaded;
        }
        else
        {
          dictionary.Add(item, loaded);
        }

        Cubee.DebugPrint("loaded " + label + " \"" + item + "\"");

      }
      catch (Exception e)
      {
        Cubee.DebugPrint(e, true);
        Cubee.DebugPrint("non-image found in the graphics folder");
      }

      fileStream.Dispose();
    }

  }
}


// function to load sound effects into a dictionary
void LoadSFXFromFolder(string label, Dictionary<string, SoundEffect> dictionary, string path, string prefix = "")
{
  Cubee.DebugPrint("sounds time");
  if (Directory.Exists(path))
  {
    foreach (string i in Directory.GetFiles(path))
    {
      // import png as Texture2D
      FileStream fileStream = new FileStream(i, FileMode.Open);
      try
      {
        //Texture2D loaded = Texture2D.FromStream(GraphicsDevice, fileStream);
        SoundEffect loaded = SoundEffect.FromStream(fileStream);

        // clip directory path
        string item = KeyFromPath(i, prefix);

        // add, replacing items if they already exist
        if (dictionary.ContainsKey(item))
        {
          dictionary[item] = loaded;
        }
        else
        {
          dictionary.Add(item, loaded);
        }

        Cubee.DebugPrint("loaded " + label + " \"" + item + "\"");

      }
      catch (Exception e)
      {
        Cubee.DebugPrint(e, true);
        Cubee.DebugPrint("did someone do a silly and put a not-wav in one of the sound effect folders?");
      }

      fileStream.Dispose();
    }

  }
}


// function to load text files into a dictionary
void LoadTextFromFolder(string label, Dictionary<string, string[]> dictionary, string path, string prefix = "")
{
  if (Directory.Exists(path))
  {
    foreach (string i in Directory.GetFiles(path))
    {
      string[] loaded = File.ReadAllText(i).Split("\n");

      // clip directory path
      string item = KeyFromPath(i, prefix);

      // add, replacing items if they already exist
      if (dictionary.ContainsKey(item))
      {
        dictionary[item] = loaded;
      }
      else
      {
        dictionary.Add(item, loaded);
      }

      Cubee.DebugPrint("loaded " + label + " \"" + item + "\"");
    }

  }
}