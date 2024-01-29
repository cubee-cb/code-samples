using System;
using System.Collections.Generic;
using System.Diagnostics;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.Graphics;

namespace Ninja_Cat
{
  class Cubee
  {
    private static string charSet = "▮■□⁙⁘‖◀▶「」¥•、。゛゜ !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~○█▒🐱⬇️░✽●♥☉웃⌂⬅️😐♪🅾️◆…➡️★⧗⬆️ˇ∧❎▤▥\n";

    private static Dictionary<char, Color> colourCodes = new Dictionary<char, Color>()
    {
      { '0', new Color(0, 0, 0) }, // black
      { '1', new Color(29, 43, 83) }, // dark blue
      { '2', new Color(126, 37, 83) }, // dark purple
      { '3', new Color(0, 135, 81) }, // dark green
      { '4', new Color(171, 82, 54) }, // brown
      { '5', new Color(95, 87, 79) }, // dark grey
      { '6', new Color(194, 195, 199) }, // light grey
      { '7', new Color(255, 241, 232) }, // white
      { '8', new Color(255, 0, 77) }, // red
      { '9', new Color(255, 163, 0) }, // orange
      { 'a', new Color(255, 236, 39) }, // yellow
      { 'b', new Color(0, 228, 54) }, // green
      { 'c', new Color(41, 173, 255) }, // blue
      { 'd', new Color(131, 118, 156) }, // med grey
      { 'e', new Color(255, 119, 168) }, // pink
      { 'f', new Color(255, 204, 170) }  // peach
    };

    private static char[] intToChar = new char[16] { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
    private static Dictionary<char, char> dark = new Dictionary<char, char>()
    {
      { '0', '0' }, // black
      { '1', '0' }, // dark blue
      { '2', '0' }, // dark purple
      { '3', '1' }, // dark green
      { '4', '2' }, // brown
      { '5', '1' }, // dark grey
      { '6', '5' }, // light grey
      { '7', 'd' }, // white
      { '8', '2' }, // red
      { '9', '4' }, // orange
      { 'a', '9' }, // yellow
      { 'b', '3' }, // green
      { 'c', '1' }, // blue
      { 'd', '1' }, // med grey
      { 'e', '2' }, // pink
      { 'f', '4' }  // peach
    };

    [Conditional("DEBUG")]
    public static void DebugPrint(object text, bool error = false)
    {
      string from = "CB";
      if (error)
      {
        from = "!!";
      }
      Debug.WriteLine("[" + from + "] " + text.ToString());

    }

    public static int GetStringLength(string input)
    {
      string text = input.ToString();
      int len = 0;

      int id = 0;
      bool skipNext = false;
      foreach (char i in text)
      {
        // don't count colour code
        if (skipNext)
        {
          skipNext = false;

        }
        // don't count colour code character
        else if (i == '§' && (colourCodes.ContainsKey(text[id + 1]) || text[id + 1] == '-'))
        {
          skipNext = true;

        }

        // add to length
        else
        {
          len += 1;
        }

        id += 1;
      }


      return len;
    }

    /// <summary>
    /// Prints text using glyphs from a specified Texture2D font, with adjustable parameters.
    /// </summary>
    /// <param name="spriteBatch">The Texture2D to display.</param>
    /// <param name="input">An object representing what to print. object.ToString() is called to convert this into a string.</param>
    /// <param name="x">X position to draw at.</param>
    /// <param name="y">Y position to draw at.</param>
    /// <param name="font">Texture2D font to use for rendering the text.</param>
    /// <param name="baseCol">Color used to tint the font glyphs.</param>
    /// <param name="clipLength">Distance in pixels from print location start to wrap the text to a new line. 0 to disable.</param>
    /// <param name="depth">When used in a spriteBatch with depth sorting enabled, use this to specify the depth.</param>
    /// <param name="skip3D">When false, the font will have a darker version drawn 1 pixel beneath it.</param>
    /// <param name="charWidth">Width (in pixels) of the character glyphs. Used additionally with charGap to determine the size of the glyphs in the sprite sheet.</param>
    /// <param name="charGap">Gap (in pixels) between character glyphs in the character sheet.</param>
    /// <param name="printChars">Limits how many characters should be printed, useful for progressively-typed text without having to create a new string every time. -1 to disable.</param>
    /// <param name="scale">Scale the font glyphs will be rendered at.</param>
    /// <param name="extraNewLineGap">Extra height (in pixels) added between new lines.</param>
    /// <param name="ignoreFormatCodes">If true, format codes will be stripped as usual, but their effects are ignored.</param>
    public static (float length, float width, float height) Print(SpriteBatch spriteBatch, object input, float x, float y, Texture2D font, int colour = 7, bool darken = false, int clipLength = 0, float depth = 0.0001f, bool skip3D = false, int charWidth = 4, int charGap = 1, int printChars = -1, float scale = 1, int extraNewLineGap = 0, bool ignoreFormatCodes = false, float opacity = 1, int globalKerning = 0, bool draw = true)
    {

      char baseCol = intToChar[colour];
      char col = baseCol;

      string text = input.ToString();
      int xOffset = 0;
      int yOffset = 0;
      int thisChar = 1;

      int totalLength = GetStringLength(text) * charWidth;
      float width = totalLength;
      bool newLines = text.Contains("\n");
      if (newLines) width = 0; // reset width if this covers multiple lines
      float height = font.Height;

      string[] words = text.Split(" ");

      foreach (string w in words)
      {
        string word = w;

        int wordLength = GetStringLength(word) * charWidth;

        // add a space to each word, except the last one in the line
        if (word != words[^1])
        {
          word += " ";
        }

        // go to next line if the word will exceed length
        if (clipLength > 0 && xOffset + wordLength + globalKerning * wordLength / charWidth > clipLength && xOffset > 0)
        {
          // adjust width for multi-line strings
          if (width == totalLength) width = 0;
          width = Math.Max(width, xOffset - charWidth);

          xOffset = 0;
          yOffset += font.Height + extraNewLineGap;
          height += font.Height + extraNewLineGap;
          //width -= charWidth; // a hacky solution to having an extra space after each word increasing the width
        }

        // each character

        int id = -1;
        bool skipNext = false;
        foreach (char i in word)
        {
          int charID = 0;
          id += 1;

          //(new code)

          // handle colour codes
          if (skipNext)
          {
            skipNext = false;
            continue;

          }
          else if (i == '§' && (colourCodes.ContainsKey(word[id + 1]) || word[id + 1] == '-'))
          {
            // return to base colour if value is - or if we're ignoring the colour codes
            if (ignoreFormatCodes || word[id + 1] == '-')
            {
              col = baseCol;
            }
            // otherwise get colour code
            else
            {
              col = word[id + 1];
            }
            skipNext = true;
            continue;

          }

          // handle newlines and find graphics offset for character (v3)
          if (i == '\n')
          {
            xOffset = -charWidth;
            yOffset += font.Height;
            height += font.Height;
          }
          else
          {
            charID = charSet.IndexOf(i);
          }

          // only draw if allowed
          if (draw)
          {
            if ((printChars == -1 || thisChar <= printChars) && i != '_')
            {
              Rectangle charRect = new Rectangle(charID * (charWidth + charGap), 0, charWidth, font.Height);
              //Rectangle borderRect = new Rectangle(charID * (charWidth + charGap), 0, charWidth + 1, fontBorder.Height);
              Color tCol = colourCodes[col] * opacity;
              Color dCol = colourCodes[dark[col]] * opacity;

              if (darken && col != baseCol)
              {
                tCol = colourCodes[dark[col]] * opacity;
                dCol = colourCodes[dark[dark[col]]] * opacity;
              }

              if (!skip3D)
              {
                spriteBatch.Draw(font, new Vector2((float)Math.Floor(x + xOffset), (float)Math.Floor(y + yOffset) + 1) * scale, charRect, dCol, 0, Vector2.Zero, Vector2.One * scale, SpriteEffects.None, depth + 0.00001f);
              }
              spriteBatch.Draw(font, new Vector2((float)Math.Floor(x + xOffset), (float)Math.Floor(y + yOffset)) * scale, charRect, tCol, 0, Vector2.Zero, Vector2.One * scale, SpriteEffects.None, depth);

            }
          } // draw

          thisChar += 1;

          // add offset
          xOffset += charWidth + globalKerning;

          // increase stored text width
          width = Math.Max(width, xOffset);

        }
      }

      return (text.Length * charWidth / 2 * scale, width * scale, height * scale);


    }











  }
}
