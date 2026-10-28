//+------------------------------------------------------------------+
//|                                             open position MA.mq4 |
//|                                                      reza rahmad |
//|                                           rezarahmad@gmail.com   |
//+------------------------------------------------------------------+
#property copyright "reza rahmad"
#property link      "rezarahmad@gmail.com"
#property version   "2.00"
#property strict
#property indicator_chart_window

input int MA_fast       = 5;
input int MA_slow       = 20;
input int MA_shift_fast = 2;
input int MA_shift_slow = 0;

string prefix = "MA_Dash_";

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
   if(rates_total < MA_slow) return(0);

//--- Calculate MAs dynamically! (Bug fixed from original which calculated only once)
   double h15  = iMA(Symbol(), PERIOD_H1, MA_fast, MA_shift_fast, MODE_SMA, PRICE_CLOSE, 0);
   double h120 = iMA(Symbol(), PERIOD_H1, MA_slow, MA_shift_slow, MODE_SMA, PRICE_CLOSE, 0);
   double current_price = iClose(Symbol(), PERIOD_H1, 0);

//--- Determine Signal
   string signal = "NO LOGIC";
   color sig_color = clrGray;
   
   if(current_price > h15 && current_price > h120)
     {
      signal = "STRONG BUY";
      sig_color = clrLimeGreen;
     }
   else if(current_price > h15 && current_price < h120)
     {
      signal = "WEAK BUY";
      sig_color = clrMediumSeaGreen;
     }
   else if(current_price < h15 && current_price < h120)
     {
      signal = "STRONG SELL";
      sig_color = clrRed;
     }
   else if(current_price < h15 && current_price > h120)
     {
      signal = "WEAK SELL";
      sig_color = clrOrangeRed;
     }

//--- Update Dashboard Text
   ObjectSetString(0, prefix+"Signal", OBJPROP_TEXT, signal);
   ObjectSetInteger(0, prefix+"Signal", OBJPROP_COLOR, sig_color);

   ObjectSetString(0, prefix+"MA5", OBJPROP_TEXT, "MA "+IntegerToString(MA_fast)+" : " + DoubleToString(h15, Digits));
   ObjectSetString(0, prefix+"MA20", OBJPROP_TEXT, "MA "+IntegerToString(MA_slow)+" : " + DoubleToString(h120, Digits));

//--- Update Lines on Chart
   DrawLine(prefix+"Line5", h15, clrMagenta, "MA "+IntegerToString(MA_fast));
   DrawLine(prefix+"Line20", h120, clrDodgerBlue, "MA "+IntegerToString(MA_slow));

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Create the Dashboard UI                                          |
//+------------------------------------------------------------------+
void CreateDashboard()
  {
   int panel_x = 20; // 20px from right edge
   int panel_y = 30; // 30px from top edge
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
   ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, clrBlack); // Dark background
   ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bg, OBJPROP_COLOR, clrDodgerBlue); // Blue border
   ObjectSetInteger(0, bg, OBJPROP_BACK, false);
   ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);

//--- Text alignment setup
   int text_x = panel_x + panel_w - 15; // Left edge of text starts here

//--- Title
   CreateLabel(prefix+"Title", "MARKET TREND (H1)", text_x, panel_y+10, 10, clrWhite, true);

//--- MA Values
   CreateLabel(prefix+"MA5", "MA 5 : 0.0000", text_x, panel_y+35, 9, clrMagenta, false);
   CreateLabel(prefix+"MA20", "MA 20 : 0.0000", text_x, panel_y+55, 9, clrDodgerBlue, false);

//--- Signal
   CreateLabel(prefix+"Signal", "WAITING...", text_x, panel_y+75, 12, clrYellow, true);
  }

//+------------------------------------------------------------------+
//| Helper to create text labels                                     |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, int size, color clr, bool bold)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, (bold ? "Trebuchet MS Bold" : "Trebuchet MS"));
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| Helper to draw dynamic lines on chart                            |
//+------------------------------------------------------------------+
void DrawLine(string name, double price, color clr, string tooltip)
  {
   if(ObjectFind(0, name) == -1)
     {
      ObjectCreate(0, name, OBJ_TREND, 0, 0, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, true);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetString(0, name, OBJPROP_TOOLTIP, tooltip);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
     
//--- Update line position to extend from 7 bars ago to current bar
   datetime t1 = Time[7];
   datetime t2 = Time[0];
   
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, price);
   ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 1, price);
  }
//+------------------------------------------------------------------+
