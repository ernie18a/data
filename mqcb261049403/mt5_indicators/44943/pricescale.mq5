//+------------------------------------------------------------------+
//|                                                   PriceScale.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                              https://www.mql5.com/ru/users/s22aa |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com/ru/users/s22aa"
#property version   "1.08"
#property indicator_chart_window
#property  indicator_plots 0
#include <Canvas\Canvas.mqh>

#define TOSTR(A) Print(#A + " = " + (string)(A))

input int   font_size    = 12;  // scale font size
input int   _rl          = 50;  // round levels
input bool background = false;  // Object in the background
bool chart_mode_Bid;
string font = "Trebuchet MS";
color txtclr, priceclr;
int ChartWidth;
int ChartHeight;
int font_width, font_height, _len;
double coef, priceMin, priceMax;
//+------------------------------------------------------------------+
int OnInit()
  {
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 0, true);
   ChartSetInteger(0, CHART_EVENT_MOUSE_WHEEL, 0, true);
   ChartSetInteger(0, CHART_SHOW_PRICE_SCALE, 0, false);
   ChartSetInteger(0, CHART_FOREGROUND, 0, false);

   chart_mode_Bid = (SymbolInfoInteger(_Symbol, SYMBOL_CHART_MODE) == SYMBOL_CHART_MODE_BID);

   if(chart_mode_Bid)
      priceclr = (color)ChartGetInteger(0, CHART_COLOR_BID);
   else
      priceclr = (color)ChartGetInteger(0, CHART_COLOR_LAST);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   double price = 0;
   if(chart_mode_Bid)
      price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   else
      price = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   if(price >= priceMin && price <= priceMax)
      PriceLast((int)(coef * (priceMax - price)), price);
   else
      ObjectDelete(0, "PriceLast");
   return(rates_total);
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long & lparam, const double & dparam, const string & sparam)
  {
   static long lastWidth = 0, lastHeight = 0;
   static double lastY = 0;
   static uint time_click = 0;

   if(id == CHARTEVENT_CLICK)
     {
      if(lparam > ChartWidth - font_width * (_len + 2))
         if(GetTickCount() <= time_click + 500)
            ChartSetInteger(0, CHART_SCALEFIX, false);
         else
            time_click = GetTickCount();
     }

   if(id == CHARTEVENT_MOUSE_MOVE)
     {
      if(((uint)sparam & 1) == 1) //  "ЛКМ"
        {
         if(lparam > ChartWidth - font_width * (_len + 2))
           {
            double deltaY = dparam - lastY;
            if(deltaY != 0)
              {
               priceMin = ChartGetDouble(0, CHART_PRICE_MIN);
               priceMax = ChartGetDouble(0, CHART_PRICE_MAX);
               coef = ChartHeight / (priceMax - priceMin);
               priceMin = ChartGetDouble(0, CHART_PRICE_MIN) - deltaY / coef;
               priceMax = ChartGetDouble(0, CHART_PRICE_MAX) + deltaY / coef;
               ChartSetInteger(0, CHART_SCALEFIX, true);
               ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
               ChartSetDouble(0, CHART_FIXED_MIN, priceMin);
               ChartSetDouble(0, CHART_FIXED_MAX, priceMax);
               ChartRedraw();
              }
           }
         else
            ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
        }
      else
        {
         ChartWidth  = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
         ChartHeight = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

         datetime time;
         double price;
         int sub_window;
         ChartXYToTimePrice(0, (int)lparam, (int)dparam, sub_window, time, price);
         Runner((int)dparam, price);
        }
      lastY = dparam;
     }

   if(id ==  CHARTEVENT_MOUSE_WHEEL)
     {
      int x_cursor = (int)(short)lparam;
      int y_cursor = (int)(short)(lparam >> 16);

      datetime time;
      double price;
      int sub_window;
      ChartXYToTimePrice(0, x_cursor, y_cursor, sub_window, time, price);
      Runner(y_cursor, price);
     }

   if(id == CHARTEVENT_CHART_CHANGE)
     {
      ChartWidth  = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      ChartHeight = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
      if(lastWidth != ChartWidth || lastHeight != ChartHeight)
        {
         chart_mode_Bid = (SymbolInfoInteger(_Symbol, SYMBOL_CHART_MODE) == SYMBOL_CHART_MODE_BID);

         if(chart_mode_Bid)
            priceclr = (color)ChartGetInteger(0, CHART_COLOR_BID);
         else
            priceclr = (color)ChartGetInteger(0, CHART_COLOR_LAST);

         lastWidth = ChartWidth;
         lastHeight = ChartHeight;
         ObjectDelete(0, "PriceLast");
         ObjectDelete(0, "Price");
         ObjectDelete(0, "PriceScale");

         Runner(0, 0, true);
        }
     }
  }
//+------------------------------------------------------------------+
uint AnotherColor(uint back)
  {
   union argb
     {
      uint clr;
      uchar c[4];
     };

   argb c;
   c.clr = back;
   c.c[0] = (c.c[0] > 127) ? 0 : 255;
   c.c[1] = (c.c[1] > 127) ? 0 : 255;
   c.c[2] = (c.c[2] > 127) ? 0 : 255;
   return c.clr;
  }
//+------------------------------------------------------------------+
void Scale(bool chart_change = false)
  {
   static double lastCoef = 0;
   priceMin = ChartGetDouble(0, CHART_PRICE_MIN);
   priceMax = ChartGetDouble(0, CHART_PRICE_MAX);
   if(priceMax - priceMin > 0)
     {
      coef = ChartHeight / (priceMax - priceMin);
      if(lastCoef != coef || chart_change)
        {
         lastCoef = coef;
         color clr = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);

         txtclr = (color)AnotherColor(clr);

         _len = StringLen(DoubleToString(priceMax, _Digits));

         TextSetFont(font, font_size * -10);
         TextGetSize("0", font_width, font_height);

         CCanvas canvas1;

         if(ObjectFind(0, "PriceScale") >= 0)
            canvas1.Attach(0, "PriceScale", COLOR_FORMAT_ARGB_NORMALIZE);
         else
            canvas1.CreateBitmapLabel(0, 0, "PriceScale", ChartWidth - font_width * (_len + 2), 0, font_width * (_len + 2), ChartHeight, COLOR_FORMAT_ARGB_NORMALIZE);
         canvas1.Erase(ColorToARGB(clr));

         ObjectSetInteger(0, "PriceScale", OBJPROP_BACK, background);

         canvas1.LineThickVertical(0, 0, ChartHeight, ColorToARGB(txtclr), 3, STYLE_SOLID, LINE_END_BUTT);

         int grid_step = ChartHeight / (font_height * 2);
         int grid_coef = (int)((priceMax - priceMin) / grid_step / _Point) / _rl * _rl;
         grid_coef = grid_coef == 0 ? _rl : grid_coef;
         double price = (int)(priceMax / _Point) / grid_coef * grid_coef * _Point;

         canvas1.FontNameSet(font);
         canvas1.FontSizeSet(font_size * -10);

         while(!IsStopped() && price >= priceMin)
           {
            int TextPosY = (int)
                           (coef * (priceMax - price));
            string text = DoubleToString(price, _Digits);
            canvas1.TextOut(font_width, TextPosY - font_height / 2, text,  ColorToARGB(txtclr));
            canvas1.LineThickHorizontal(0, font_width / 2, TextPosY, ColorToARGB(txtclr), 2, STYLE_SOLID, LINE_END_BUTT);
            price -= grid_coef * _Point;
           }
         canvas1.Update(true);

         if(chart_mode_Bid)
            price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         else
            price = SymbolInfoDouble(_Symbol, SYMBOL_LAST);

         if(price >= priceMin && price <= priceMax)
            PriceLast((int)(coef * (priceMax - price)), price);
         else
            ObjectDelete(0, "PriceLast");
        }
     }
  }
//+------------------------------------------------------------------+
void Runner(int y = 0, double price = 0, bool chart_change = false)
  {
   static int lastY = 0;
   static double lastPrice = 0;

   Scale(chart_change);

   if(y == 0 || price == 0)
     {
      y = lastY;
      price = lastPrice;
     }
   else
     {
      lastY = y;
      lastPrice = price;
     }

   CCanvas canvas2;

   if(ObjectFind(0, "Price") >= 0)
      canvas2.Attach(0, "Price", COLOR_FORMAT_ARGB_NORMALIZE);
   else
      canvas2.CreateBitmapLabel(0, 0, "Price", ChartWidth - font_width * (_len + 2) + 1, 10, font_width * (_len + 2) - 2, font_height, COLOR_FORMAT_ARGB_NORMALIZE);
   canvas2.Erase(ColorToARGB((color)AnotherColor(txtclr)));
   ObjectSetInteger(0, "Price", OBJPROP_ANCHOR, ANCHOR_LEFT);
   ObjectSetInteger(0, "Price", OBJPROP_YDISTANCE, y);

   canvas2.FontNameSet(font);
   canvas2.FontSizeSet(font_size * -10);

   canvas2.Rectangle(0, 0, font_width * (_len + 2) - 2, font_height - 1, ColorToARGB(txtclr));
   canvas2.TextOut(font_width, 0, DoubleToString(price, _Digits),  ColorToARGB(txtclr));
   canvas2.Update(true);
  }
//+------------------------------------------------------------------+
void PriceLast(int y = 0, double price = 0)
  {
   static double last_prise = 0;
   if(price == 0)
      price = last_prise;
   else
      last_prise = price;

   CCanvas canvas3;

   if(ObjectFind(0, "PriceLast") >= 0)
      canvas3.Attach(0, "PriceLast", COLOR_FORMAT_ARGB_NORMALIZE);
   else
      canvas3.CreateBitmapLabel(0, 0, "PriceLast", ChartWidth - font_width * (_len + 2) + 1, 10, font_width * (_len + 2) - 2, font_height, COLOR_FORMAT_ARGB_NORMALIZE);
   canvas3.Erase(ColorToARGB(priceclr, 200));

   ObjectSetInteger(0, "PriceLast", OBJPROP_ANCHOR, ANCHOR_LEFT);
   ObjectSetInteger(0, "PriceLast", OBJPROP_YDISTANCE, y);

   canvas3.FontNameSet(font);
   canvas3.FontSizeSet(font_size * -10);

   canvas3.Rectangle(0, 0, font_width * (_len + 2) - 2, font_height - 1, ColorToARGB(txtclr));
   canvas3.TextOut(font_width, 0, DoubleToString(price, _Digits),  ColorToARGB(txtclr));
   canvas3.Update(true);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0, "PriceLast");
   ObjectDelete(0, "Price");
   ObjectDelete(0, "PriceScale");
   ChartSetInteger(0, CHART_SHOW_PRICE_SCALE, true);
  }
//+------------------------------------------------------------------+
