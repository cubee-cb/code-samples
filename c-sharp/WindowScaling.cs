// This file contains two different display scaling functions: one from Everlost Isle, and the other from Ninja Cat Remewstered.
// Both of them try to do the same thing, however Nnja Caat's one has a lot more features.
// They also rely on external code to function properly, as they use the save file to get/save the resolution.

// Everlost Isle: get screen resolution and scale
void ReScale(float forceScale = 0)
{

  Cubee.DebugPrint("figuring out the resolution...");

  xres = xresBase;
  yres = yresBase;

  // use specified scale
  if (forceScale != 0)
  {
    scale = forceScale;
  }
  // use options file scale
  else if (options.forceScale != 0)
  {
    scale = options.forceScale;
  }
  // determine scale from window size
  else
  {

    // find scale
    scale = actual_xres / xres;
    scaley = actual_yres / yres;
    if (scaley < scale)
    {
      scale = scaley;
    }

    scale = Math.Max(scale, 1);
  }

  // adjust resolution to fill screen
  xres = (int)(actual_xres / scale);
  yres = (int)(actual_yres / scale);

  xo = (int)(actual_xres - xres * scale) / 2;
  yo = (int)(actual_yres - yres * scale) / 2;

  Cubee.DebugPrint("init internal screen layers");

  // smol screen
  PresentationParameters parameter = _graphics.GraphicsDevice.PresentationParameters;
  _renderTarget = new RenderTarget2D(_graphics.GraphicsDevice, xres, yres, false, SurfaceFormat.Color, DepthFormat.None, parameter.MultiSampleCount, RenderTargetUsage.DiscardContents);
  _lightTarget = new RenderTarget2D(_graphics.GraphicsDevice, xres, yres, false, SurfaceFormat.Color, DepthFormat.None, parameter.MultiSampleCount, RenderTargetUsage.DiscardContents);
  _shadowTarget = new RenderTarget2D(_graphics.GraphicsDevice, xres, yres, false, SurfaceFormat.Color, DepthFormat.None, parameter.MultiSampleCount, RenderTargetUsage.DiscardContents);
  _menuTarget = new RenderTarget2D(_graphics.GraphicsDevice, xres, yres, false, SurfaceFormat.Color, DepthFormat.None, parameter.MultiSampleCount, RenderTargetUsage.DiscardContents);
  _mapTarget = new RenderTarget2D(_graphics.GraphicsDevice, map_w, map_h, false, SurfaceFormat.Color, DepthFormat.None, parameter.MultiSampleCount, RenderTargetUsage.DiscardContents);
  _globalTarget = new RenderTarget2D(_graphics.GraphicsDevice, xres, yres, false, SurfaceFormat.Color, DepthFormat.None, parameter.MultiSampleCount, RenderTargetUsage.DiscardContents);

  // camera init
  var viewportAdapter = new BoxingViewportAdapter(Window, GraphicsDevice, xres, yres);
  _camera = new OrthographicCamera(viewportAdapter);

}


// Ninja Cat Remewstered: 
void ApplyDPI(float dpiX, float dpiY)
{
  p8DPI = Math.Min(dpiX, dpiY);
  p8DPIScale = p8DPI / 256f;

  // todo: do we need this?
  // maybe just for first-time run / settings reset to set a reasonable default control scale
  p8DPIScale = 1;
}

// function to re-scale the internal display elements
/// <summary>
/// Scales the internal display based on parameters and Options file values.
/// </summary>
/// <param name="targetWidth">The width the internal display needs to fit within.</param>
/// <param name="targetHeight">The height the internal display needs to fit within.</param>
/// <param name="forceUpdateMode">If true, forces _graphics.ApplyChanges() to be called even if the fullscreen status hasn't changed.</param>
void ScaleDisplay(int targetWidth, int targetHeight, bool forceUpdateMode = false)
{
  // should we be fullscreen now?
  bool fullscreen = p8Options.fullscreen;

  Window.AllowUserResizing = true;

  // base internal resolution
  int p8BaseInternalWidth = 128;
  int p8BaseInternalHeight = 120; // that moment when you clip the resolution due to engine limitations and the resulting resolution scales perfectly to basically any common resolution you could want (240, 480, 720, 1080, etc...)
  p8InternalWidth = p8BaseInternalWidth;
  p8InternalHeight = p8BaseInternalHeight;


  // limit minimum screen size
  targetWidth = Math.Max(p8BaseInternalWidth, targetWidth);
  targetHeight = Math.Max(p8BaseInternalHeight, targetHeight);


  // get display resolution if fullscreen, otherwise use the target window size
  if (fullscreen)
  {
    p8WindowWidth = GraphicsDevice.DisplayMode.Width;
    p8WindowHeight = GraphicsDevice.DisplayMode.Height;
    _graphics.IsFullScreen = true;

    _graphics.HardwareModeSwitch = !p8Options.borderless;

  }
  else
  {
    p8WindowWidth = targetWidth;
    p8WindowHeight = targetHeight;
    _graphics.IsFullScreen = false;


    _graphics.PreferredBackBufferWidth = p8WindowWidth;
    _graphics.PreferredBackBufferHeight = p8WindowHeight;
  }

  // re-create window if fullscreen changed
  if (fullscreen != _graphics.IsFullScreen || forceUpdateMode)
  {
    _graphics.ApplyChanges();
  }

  // get scale for internal screen to fit
  p8Scale = Math.Min((float)p8WindowWidth / (float)p8InternalWidth, (float)p8WindowHeight / (float)p8InternalHeight); // casts are NOT redundant, thank you very much
  if (p8Options.integerScale)
  {
    p8Scale = (float)Math.Floor(p8Scale);
  }

  // use overscan mode by default for the touch controls
  p8UIScreenWidth = (int)Math.Ceiling(p8WindowWidth / p8Scale / 2) * 2;
  p8UIScreenHeight = (int)Math.Ceiling(p8WindowHeight / p8Scale / 2) * 2;


  // handle aspect ratio option
  switch (p8Options.aspect)
  {

    // use raw internal resolution
    default:
    case 0:
      break;

    // letterbox internal resolution to better fit the display's aspect ratio
    case 1:
      p8InternalWidth = (int)Math.Floor(p8WindowWidth / p8Scale / 2) * 2;
      p8InternalHeight = (int)Math.Floor(p8WindowHeight / p8Scale / 2) * 2;

      /*/
      // also resize the touch controls
      p8UIScreenWidth = (int)Math.Floor(p8WindowWidth / p8Scale / 2) * 2;
      p8UIScreenHeight = (int)Math.Floor(p8WindowHeight / p8Scale / 2) * 2;
      p8InternalWidth = p8UIScreenWidth;
      p8InternalHeight = p8UIScreenHeight;
      //*/


      // / 2 * 2 should make the window always have even dimensions
      break;

    // as case 1, but include a margin of overscan to fill the edges
    // obviously this is the "intended" aspect ratio
    case 2:
      p8InternalWidth = p8UIScreenWidth;
      p8InternalHeight = p8UIScreenHeight;
      // / 2 * 2 should make the window always have even dimensions


      /*/ if aspect is 2, then also add a little overscan to fill the letterbox
      if (p8Options.aspect == 2)
      {
        int remainder = (int)Math.Ceiling(p8WindowWidth / p8Scale - p8InternalWidth + 1);
        p8InternalWidth = (int)Math.Ceiling((float)p8InternalWidth + remainder);
        p8InternalHeight = (int)Math.Ceiling((float)p8InternalHeight + remainder);
      }
      //*/
      break;




    // 3ds ratio
    case -1:
      p8InternalWidth = 200;
      p8InternalHeight = 120;
      break;
  }

  p8InternalWidth = Math.Max(p8InternalWidth, p8BaseInternalWidth);
  p8InternalHeight = Math.Max(p8InternalHeight, p8BaseInternalHeight);

  // create render targets
  PresentationParameters parameter = GraphicsDevice.PresentationParameters;
  p8InternalScreen?.Dispose();
  p8InternalScreen = new RenderTarget2D(GraphicsDevice, p8InternalWidth, p8InternalHeight, false, SurfaceFormat.Color, DepthFormat.None, parameter.MultiSampleCount, RenderTargetUsage.PreserveContents);

  p8UIScreen?.Dispose();
  p8UIScreen = new RenderTarget2D(GraphicsDevice, p8UIScreenWidth, p8UIScreenHeight, false, SurfaceFormat.Color, DepthFormat.None, parameter.MultiSampleCount, RenderTargetUsage.PreserveContents);
  // use RenderTargetUsage.PreserveContents so we can keep the screen between frames, pico-8 style


  // update display offsets
  p8ScreenOffsetX = -(int)Math.Floor((float)(p8BaseInternalWidth - p8InternalWidth) / 2);
  p8ScreenOffsetY = -(int)Math.Floor((float)(p8BaseInternalHeight - p8InternalHeight) / 2);

  p8UIScreenOffsetX = -(int)Math.Floor((float)(p8BaseInternalWidth - p8InternalWidth) / 2);
  p8UIScreenOffsetY = -(int)Math.Floor((float)(p8BaseInternalHeight - p8InternalHeight) / 2);

  // update edge offsets
  //p8LeftEdge = -p8ScreenOffsetX + 1;
  //p8RightEdge = p8BaseInternalWidth + p8ScreenOffsetX - 1;
  //p8TopEdge = -p8ScreenOffsetY + 1;
  //p8BottomEdge = p8BaseInternalWidth + p8ScreenOffsetY - 1;

  // determine if the screen is currently portrait
  p8Portrait = p8WindowWidth < p8WindowHeight;

  // save last screen size
  previousWindowWidth = Window.ClientBounds.Width;
  previousWindowHeight = Window.ClientBounds.Height;

  // get the device's dpi
  var (dpiX, dpiY) = Platform.GetDPI();
  ApplyDPI(dpiX, dpiY);

  //p8DPIScale *= 10;

  // save the new window size unless we're in fullscreen mode, so we don't overwrite the windowed mode resolution with the display resolution
  if (!fullscreen)
  {
    p8Options.resolution = new Dictionary<string, int>() { { "X", Window.ClientBounds.Width }, { "Y", Window.ClientBounds.Height } };
  }
  Save();
}
