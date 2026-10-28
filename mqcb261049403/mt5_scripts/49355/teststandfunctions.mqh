//+----------------------------------------------------------------------------+
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//+----------------------------------------------------------------------------+
#property copyright "Copyright 2007-2024, JQS aka Joo."
#property link      "https://www.mql5.com/ru/users/joo"

#include <Canvas\Canvas.mqh>
//#include <\Math\Functions.mqh>
#include "TestFunctions.mqh"


//——————————————————————————————————————————————————————————————————————————————
class C_TestStand
{
  public:
  void Init (int width, int height)
  {
    W = width;  //750;
    H = height; //375;

    WscrFunc = H - 2;
    HscrFunc = H - 2;

    //creating a table ---------------------------------------------------------
    string canvasName = "AO_Test_Func_Canvas";

    if (!Canvas.CreateBitmapLabel (canvasName, 5, 30, W, H, COLOR_FORMAT_ARGB_RAW))
    {
      Print ("Error creating Canvas: ", GetLastError ());
      return;
    }

    ObjectSetInteger (0, canvasName, OBJPROP_HIDDEN, false);
    ObjectSetInteger (0, canvasName, OBJPROP_SELECTABLE, true);

    ArrayResize (FunctScrin, HscrFunc);

    for (int i = 0; i < HscrFunc; i++) ArrayResize (FunctScrin [i].clr, HscrFunc);

  }

  struct S_CLR
  {
      color clr [];
  };

  //----------------------------------------------------------------------------
  public:
  void CanvasErase ()
  {
    Canvas.Erase (XRGB (0, 0, 0));
    Canvas.FillRectangle (1,     1, H - 2, H - 2, COLOR2RGB (clrWhite));
    Canvas.FillRectangle (H + 1, 1, W - 2, H - 2, COLOR2RGB (clrWhite));
  }

  //----------------------------------------------------------------------------
  public:
  void MaxMinDr (C_Function &f)
  {
    //draw Max global-------------------------------------------------------------
    int x = (int)Scale (f.GetMaxFuncX (), f.GetMinRangeX (), f.GetMaxRangeX (), 1, W / 2 - 1, false);
    int y = (int)Scale (f.GetMaxFuncY (), f.GetMinRangeY (), f.GetMaxRangeY (), 1, H   - 1, true);

    //Canvas.Circle(x, y, 10, COLOR2RGB(clrBlack));
    //Canvas.Circle(x, y, 11, COLOR2RGB(clrBlack));

    Canvas.Circle (x, y, 12, COLOR2RGB (clrBlack));
    Canvas.Circle (x, y, 13, COLOR2RGB (clrBlack));
    Canvas.Circle (x, y, 14, COLOR2RGB (clrBlack));
    Canvas.Circle (x, y, 15, COLOR2RGB (clrBlack));

    //Canvas.LineWu(W/4 + 1, 0,   W/4 + 1, H,   COLOR2RGB(clrWhite), 10234233);
    //Canvas.LineWu(0,       H/2, W/2,     H/2, COLOR2RGB(clrWhite), 10234233);

    //draw Min global-------------------------------------------------------------
    x = (int)Scale (f.GetMinFuncX (), f.GetMinRangeX (), f.GetMaxRangeX (), 0, W / 2 - 1, false);
    y = (int)Scale (f.GetMinFuncY (), f.GetMinRangeY (), f.GetMaxRangeY (), 0, H - 1, true);

    Canvas.Circle (x, y, 12, COLOR2RGB (clrBlack));
    Canvas.Circle (x, y, 13, COLOR2RGB (clrBlack));
  }

  //----------------------------------------------------------------------------
  public:
  void PointDr (double &args [], C_Function &f, int shiftX, int shiftY, int count, bool main)
  {
    double x = 0.0;
    double y = 0.0;

    double xAve = 0.0;
    double yAve = 0.0;

    int width  = 0;
    int height = 0;

    color clrF = clrNONE;

    for (int i = 0; i < count; i++)
    {
      xAve += args [i * 2];
      yAve += args [i * 2 + 1];

      x = args [i * 2];
      y = args [i * 2 + 1];

      width  = (int)Scale (x, f.GetMinRangeX (), f.GetMaxRangeX (), 0, WscrFunc - 1, false);
      height = (int)Scale (y, f.GetMinRangeY (), f.GetMaxRangeY (), 0, HscrFunc - 1, true);

      clrF = DoubleToColor (i, 0, count - 1, 0, 270);
      Canvas.FillCircle (width + shiftX, height + shiftY, 1, COLOR2RGB (clrF));
    }

    xAve /= (double)count;
    yAve /= (double)count;

    width  = (int)Scale (xAve, f.GetMinRangeX (), f.GetMaxRangeX (), 0, WscrFunc - 1, false);
    height = (int)Scale (yAve, f.GetMinRangeY (), f.GetMaxRangeY (), 0, HscrFunc - 1, true);

    if (!main)
    {
      Canvas.FillCircle (width + shiftX, height + shiftY, 3, COLOR2RGB (clrBlack));
      Canvas.FillCircle (width + shiftX, height + shiftY, 2, COLOR2RGB (clrWhite));
    }
    else
    {
      Canvas.Circle (width + shiftX, height + shiftY, 5, COLOR2RGB (clrBlack));
      Canvas.Circle (width + shiftX, height + shiftY, 6, COLOR2RGB (clrBlack));
    }
  }

  //----------------------------------------------------------------------------
  public:
  void SendGraphToCanvas ()
  {
    for (int w = 0; w < HscrFunc; w++)
    {
      for (int h = 0; h < HscrFunc; h++)
      {
        Canvas.PixelSet (w + 1, h + 1, COLOR2RGB (FunctScrin [w].clr [h]));
      }
    }
  }

  //----------------------------------------------------------------------------
  public:
  void DrawFunctionGraph (C_Function &f)
  {
    double ar [2];
    double fV;

    for (int w = 0; w < HscrFunc; w++)
    {
      ar [0] = Scale (w, 0, H, f.GetMinRangeX (), f.GetMaxRangeX (), false);
      for (int h = 0; h < HscrFunc; h++)
      {
        ar [1] = Scale (h, 0, H, f.GetMinRangeY (), f.GetMaxRangeY (), true);
        fV = f.CalcFunc (ar, 1);
        FunctScrin [w].clr [h] = DoubleToColor (fV, f.GetMinFunValue (), f.GetMaxFunValue (), 0, 270);
      }
    }
  }

  //----------------------------------------------------------------------------
  public:
  void Update ()
  {
    Canvas.Update ();
  }

  //----------------------------------------------------------------------------
  //Scaling a number from a range to a specified range
  public:
  double Scale (double In, double InMIN, double InMAX, double OutMIN, double OutMAX, bool Revers = false)
  {
    if (OutMIN == OutMAX) return (OutMIN);
    if (InMIN == InMAX) return ((OutMIN + OutMAX) / 2.0);
    else
    {
      if (Revers)
      {
        if (In < InMIN) return (OutMAX);
        if (In > InMAX) return (OutMIN);
        return (((InMAX - In) * (OutMAX - OutMIN) / (InMAX - InMIN)) + OutMIN);
      }
      else
      {
        if (In < InMIN) return (OutMIN);
        if (In > InMAX) return (OutMAX);
        return (((In - InMIN) * (OutMAX - OutMIN) / (InMAX - InMIN)) + OutMIN);
      }
    }
  }

  //----------------------------------------------------------------------------
  private:
  color DoubleToColor (const double In,    //input value
                       const double inMin, //minimum of input values
                       const double inMax, //maximum of input values
                       const int    loH,   //lower bound of HSL range values
                       const int    upH)   //upper bound of HSL range values
  {
    int h = (int)Scale (In, inMin, inMax, loH, upH, true);
    return HSLtoRGB (h, 1.0, 0.5);
  }

  //----------------------------------------------------------------------------
  private:
  color HSLtoRGB (const int    h, //0   ... 360
                  const double s, //0.0 ... 1.0
                  const double l) //0.0 ... 1.0
  {
    int r;
    int g;
    int b;
    if (s == 0.0)
    {
      r = g = b = (unsigned char)(l * 255);
      return StringToColor ((string)r + "," + (string)g + "," + (string)b);
    }
    else
    {
      double v1, v2;
      double hue = (double)h / 360.0;
      v2 = (l < 0.5) ? (l * (1.0 + s)) : ((l + s) - (l * s));
      v1 = 2.0 * l - v2;
      r = (unsigned char)(255 * HueToRGB (v1, v2, hue + (1.0 / 3.0)));
      g = (unsigned char)(255 * HueToRGB (v1, v2, hue));
      b = (unsigned char)(255 * HueToRGB (v1, v2, hue - (1.0 / 3.0)));
      return StringToColor ((string)r + "," + (string)g + "," + (string)b);
    }
  }

  //----------------------------------------------------------------------------
  private:
  double HueToRGB (double v1, double v2, double vH)
  {
    if (vH < 0) vH += 1;
    if (vH > 1) vH -= 1;
    if ((6 * vH) < 1) return (v1 + (v2 - v1) * 6 * vH);
    if ((2 * vH) < 1) return v2;
    if ((3 * vH) < 2) return (v1 + (v2 - v1) * ((2.0f / 3) - vH) * 6);
    return v1;
  }

  //----------------------------------------------------------------------------
  public:
  int W; //monitor screen width
  public:
  int H; //monitor screen height

  private:
  int WscrFunc; //test function screen width
  private:
  int HscrFunc; //test function screen height

  public:
  CCanvas Canvas;      //drawing table
  private:
  S_CLR FunctScrin []; //two-dimensional matrix of colors
};
//——————————————————————————————————————————————————————————————————————————————
