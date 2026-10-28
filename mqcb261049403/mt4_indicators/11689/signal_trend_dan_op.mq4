//+------------------------------------------------------------------+
//|                                     signal_trend_dan_op.mq4      |
//|                                                      reza rahmad |
//|                                           rezarahmad@gmail.com   |
//+------------------------------------------------------------------+
#property copyright "reza rahmad"
#property link      "rezarahmad@gmail.com"
#property version   "2.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2

#property indicator_color1 clrDodgerBlue
#property indicator_color2 clrRed
#property indicator_width1 2
#property indicator_width2 2

//--- Inputs
input string   sec1 = "--- Moving Average ---";
input int      MAperiod = 5;
input int      Shift = 2;

input string   sec2 = "--- Stochastic ---";
input int      Kperiod = 14;
input int      Dperiod = 3;
input int      Slowing = 3;

input string   sec3 = "--- ADX ---";
input int      ADXperiod = 14;

input string   sec4 = "--- Settings ---";
input bool     ShowArrows = true;

//--- Indicator buffers
double BufferBuy[];
double BufferSell[];

string prefix = "SigTrend_";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, BufferBuy);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 233);
   SetIndexEmptyValue(0, 0.0);
   
   SetIndexBuffer(1, BufferSell);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 234);
   SetIndexEmptyValue(1, 0.0);
   
   IndicatorShortName("Signal Trend & OP");
   
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
   if(rates_total < MathMax(MAperiod, Kperiod)) return(0);

   int limit = rates_total - prev_calculated;
   if(prev_calculated == 0) limit = rates_total - 2;

   for(int i = limit; i >= 0; i--)
     {
      BufferBuy[i] = 0.0;
      BufferSell[i] = 0.0;
      
      double stoch_main0 = iStochastic(Symbol(), 0, Kperiod, Dperiod, Slowing, MODE_SMA, 0, MODE_MAIN, i);
      double stoch_main1 = iStochastic(Symbol(), 0, Kperiod, Dperiod, Slowing, MODE_SMA, 0, MODE_MAIN, i+1);
      double stoch_sig0  = iStochastic(Symbol(), 0, Kperiod, Dperiod, Slowing, MODE_SMA, 0, MODE_SIGNAL, i);
      double stoch_sig1  = iStochastic(Symbol(), 0, Kperiod, Dperiod, Slowing, MODE_SMA, 0, MODE_SIGNAL, i+1);
      
      double ma_val = iMA(Symbol(), 0, MAperiod, Shift, MODE_SMA, PRICE_TYPICAL, i);
      
      bool buy_condition = (stoch_main0 > stoch_sig0 && stoch_main1 < stoch_sig1 && high[i] > ma_val);
      bool sell_condition = (stoch_main0 < stoch_sig0 && stoch_main1 > stoch_sig1 && low[i] < ma_val);
      
      if(ShowArrows)
        {
         double offset = 5 * Point;
         if(Period() >= PERIOD_M30) offset = 8 * Point;
         if(Period() >= PERIOD_W1) offset = 12 * Point;
         if(Period() >= PERIOD_MN1) offset = 60 * Point;
         
         if(buy_condition)
           {
            BufferBuy[i] = low[i] - offset;
           }
         else if(sell_condition)
           {
            BufferSell[i] = high[i] + offset;
           }
        }
     }

//--- Update Dashboard (Outside the loop, calculated only once per tick for bar 0)
   double adx_plus  = iADX(Symbol(), 0, ADXperiod, PRICE_CLOSE, MODE_PLUSDI, 0);
   double adx_minus = iADX(Symbol(), 0, ADXperiod, PRICE_CLOSE, MODE_MINUSDI, 0);
   
   string trend_text = "WAITING...";
   color trend_color = clrYellow;
   
   if(adx_plus > adx_minus)
     {
      trend_text = "TREND BUY";
      trend_color = clrLimeGreen;
     }
   else if(adx_minus > adx_plus)
     {
      trend_text = "TREND SELL";
      trend_color = clrRed;
     }
     
   ObjectSetString(0, prefix+"Signal", OBJPROP_TEXT, trend_text);
   ObjectSetInteger(0, prefix+"Signal", OBJPROP_COLOR, trend_color);
   
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Create Dashboard UI                                              |
//+------------------------------------------------------------------+
void CreateDashboard()
  {
   int panel_x = 20;
   int panel_y = 30;
   int panel_w = 180;
   int panel_h = 70;
   
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
   ObjectSetInteger(0, bg, OBJPROP_COLOR, clrDimGray);
   ObjectSetInteger(0, bg, OBJPROP_BACK, false);
   ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);

   int text_x = panel_x + panel_w - 15;
   
//--- Title
   CreateLabel(prefix+"Title", "ADX MAIN TREND", text_x, panel_y+10, 10, clrWhite, true);

//--- Signal
   CreateLabel(prefix+"Signal", "WAITING...", text_x, panel_y+35, 14, clrYellow, true);
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
