//+------------------------------------------------------------------+
//|                               sideway_or__trend_v_1_2_update.mq4 |
//|                                                      reza rahmad |
//|                                           rezarahmad@gmail.com   |
//+------------------------------------------------------------------+
#property copyright "reza rahmad"
#property link      "rezarahmad@gmail.com"
#property version   "2.00"
#property strict
#property indicator_chart_window

input int period_adx = 14;

string prefix = "ADX_Dash_";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   CreateDashboard();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, prefix);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total < period_adx) return(0);

//--- Calculate ADX
   double adx_main  = iADX(Symbol(), 0, period_adx, PRICE_CLOSE, MODE_MAIN, 0);
   double adx_plus  = iADX(Symbol(), 0, period_adx, PRICE_CLOSE, MODE_PLUSDI, 0);
   double adx_minus = iADX(Symbol(), 0, period_adx, PRICE_CLOSE, MODE_MINUSDI, 0);

//--- Determine Logic (Fixed Logic Bug from original version)
   string state = "NO SIGNAL";
   color c = clrGray;
   string symbol_char = ""; // Wingdings

   if(adx_main > adx_plus && adx_main > adx_minus)
     {
      if(adx_plus > adx_minus) { state = "SIDEWAY BUY"; c = clrMagenta; symbol_char = CharToStr(75); }
      else { state = "SIDEWAY SELL"; c = clrMagenta; symbol_char = CharToStr(75); }
     }
   else if(adx_main < 20)
     {
      if(adx_plus > adx_minus) { state = "SIDEWAY BUY"; c = clrMagenta; symbol_char = CharToStr(75); }
      else { state = "SIDEWAY SELL"; c = clrMagenta; symbol_char = CharToStr(75); }
     }
   else if(adx_main < adx_plus && adx_plus > adx_minus)
     {
      state = "TREND BUY"; c = clrLimeGreen; symbol_char = CharToStr(221); // Up arrow
     }
   else if(adx_main < adx_minus && adx_plus < adx_minus)
     {
      state = "TREND SELL"; c = clrRed; symbol_char = CharToStr(222); // Down arrow
     }

//--- Update Dashboard Text
   ObjectSetString(0, prefix+"Signal", OBJPROP_TEXT, state);
   ObjectSetInteger(0, prefix+"Signal", OBJPROP_COLOR, c);
   
   ObjectSetString(0, prefix+"Arrow", OBJPROP_TEXT, symbol_char);
   ObjectSetInteger(0, prefix+"Arrow", OBJPROP_COLOR, c);

   ObjectSetString(0, prefix+"Val", OBJPROP_TEXT, "ADX ("+IntegerToString(period_adx)+") : " + DoubleToString(adx_main, 2));

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Create the Dashboard UI                                          |
//+------------------------------------------------------------------+
void CreateDashboard()
  {
   int panel_x = 20; // 20px from right edge
   int panel_y = 150; // 150px from top edge (to avoid overlapping with other dashes)
   int panel_w = 180;
   int panel_h = 100;
   
//--- Background Panel
   string bg = prefix + "BG";
   ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bg, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, panel_x);
   ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, panel_y);
   ObjectSetInteger(0, bg, OBJPROP_XSIZE, panel_w);
   ObjectSetInteger(0, bg, OBJPROP_YSIZE, panel_h);
   ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, clrBlack); 
   ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bg, OBJPROP_COLOR, clrMagenta); 
   ObjectSetInteger(0, bg, OBJPROP_BACK, false);
   ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);

   int text_x = panel_x + panel_w - 15; 
   int arrow_x = panel_x + panel_w - 140; // Place arrow on the left side of the panel

//--- Title
   CreateLabel(prefix+"Title", "MARKET PHASE", text_x, panel_y+10, 10, clrWhite, true, "Trebuchet MS Bold");

//--- ADX Value
   CreateLabel(prefix+"Val", "ADX (14) : 0.00", text_x, panel_y+35, 9, clrLightGray, false, "Trebuchet MS");

//--- Signal Text
   CreateLabel(prefix+"Signal", "WAITING...", text_x, panel_y+65, 12, clrYellow, true, "Trebuchet MS Bold");
   
//--- Signal Arrow (Wingdings)
   CreateLabel(prefix+"Arrow", "", arrow_x, panel_y+50, 30, clrYellow, false, "Wingdings");
  }

//+------------------------------------------------------------------+
//| Helper to create text labels                                     |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, int size, color clr, bool bold, string font)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }
//+------------------------------------------------------------------+