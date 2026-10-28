//+------------------------------------------------------------------+
//|                                       RVFL Indicator_Free.mq5    |
//|                      Range Vector Fibo Logic (Indicator Version) |
//|                               Copyright 2025, AlgoPulse Academy  |
//+------------------------------------------------------------------+
#property copyright "apa_ravigrg"
#property link      "https://www.mql5.com/en/market/product/158065"
#property version   "1.00"

// --- PROMOTIONAL DESCRIPTION ---
#property description "--------------------------------------------------------------"
#property description "Range Vector Fibo Logic Indicator (Free Version)"
#property description " "
#property description "This indicator draws the 'One Candle' Daily Breakout levels used in"
#property description "popular institutional strategies (0.9 SL / 1.25 TP)."
#property description " "
#property description "👇 AUTOMATE THIS STRATEGY HERE 👇"
#property description "https://www.mql5.com/en/market/product/158065"
#property description "--------------------------------------------------------------"

#property indicator_chart_window
#property indicator_plots 0

// ==================================================================
// ─── 0. BRANDING ───
// ==================================================================
input group "=== Branding ==="
input string   Brand             = "apa_ravigrg";                 // The Brand
input string   Contact           = "marketmindwithravi@gmail.com"; // Contact
input string   Product           = "Range Vector Fibo Logic Indicator"; // Product

// ==================================================================
// ─── 1. VISUAL SETTINGS ───
// ==================================================================
input group "=== Visual Settings ==="
input int      History_Days      = 10;        // Days to Show
input bool     Show_Period_Sep   = true;      // Show Period Separator
input color    Color_Entry       = clrBlack; // Entry Line Color
input color    Color_SL          = clrRed;   // Stop Loss Color
input color    Color_TP          = clrBlue;  // Take Profit Color
input int      Line_Width        = 2;        // Line Width (Thicker is better for visibility)

// ==================================================================
// ─── 2. FIBONACCI SETTINGS (VIRAL DEFAULTS) ───
// ==================================================================
input group "=== Fibonacci Settings ==="
// Default 1:2.5 Risk-Reward (Matches the Viral Video)
input double   Long_SL_Level     = 0.9;   // Long SL (0.1 Risk)
input double   Long_TP_Level     = 1.25;  // Long TP (0.25 Reward)
input double   Short_SL_Level    = 0.1;   // Short SL (0.1 Risk)
input double   Short_TP_Level    = -0.25; // Short TP (0.25 Reward)

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Redraw immediately on load
   DrawLevels();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "RVFL_");
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
   // OPTIMIZATION: Only redraw on New Bar or First Load
   if(prev_calculated == 0 || IsNewBar())
     {
      DrawLevels();
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Logic: Main Drawing Controller                                   |
//+------------------------------------------------------------------+
void DrawLevels()
{
   // Safety check for data readiness
   if(!SeriesInfoInteger(Symbol(), PERIOD_D1, SERIES_SYNCHRONIZED)) return;
   if(Bars(Symbol(), PERIOD_D1) < History_Days + 2) return;

   ObjectsDeleteAll(0, "RVFL_"); // Clean old lines to prevent duplication
   
   double highs[], lows[];
   datetime times[];
   
   // BATCH DATA FETCH
   int count = History_Days + 2;
   if(CopyHigh(Symbol(), PERIOD_D1, 0, count, highs) < count) return;
   if(CopyLow(Symbol(), PERIOD_D1, 0, count, lows) < count) return;
   if(CopyTime(Symbol(), PERIOD_D1, 0, count, times) < count) return;
   
   // Set as Series (Index 0 = Newest)
   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(lows, true);
   ArraySetAsSeries(times, true);
   
   // Loop through history
   // i=0 is Today (Current running day).
   // i=1 is Yesterday.
   for(int i=0; i<History_Days; i++)
   {
      // To draw lines FOR Day [i], we need High/Low from Day [i+1] (The Previous Candle)
      if(i+1 >= ArraySize(highs)) break;
      
      double h = highs[i+1];
      double l = lows[i+1];
      double rng = h - l;
      
      // Calculate Time Boundaries (00:00 to 00:00 next day)
      datetime t_start = times[i];
      datetime t_end   = t_start + 86400; // 24 Hours
      
      // If it's the current running day, extend the line a bit forward visually
      if(i==0) t_end = TimeCurrent() + PeriodSeconds()*10; 

      string suffix = "_" + IntegerToString(i);
      
      // --- 1. Period Separator ---
      if(Show_Period_Sep)
      {
         string sep_name = "RVFL_Sep" + suffix;
         if(ObjectFind(0, sep_name) < 0) ObjectCreate(0, sep_name, OBJ_VLINE, 0, t_start, 0);
         ObjectSetInteger(0, sep_name, OBJPROP_TIME, t_start);
         ObjectSetInteger(0, sep_name, OBJPROP_COLOR, clrGray);
         ObjectSetInteger(0, sep_name, OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, sep_name, OBJPROP_SELECTABLE, false); 
         ObjectSetInteger(0, sep_name, OBJPROP_HIDDEN, true);
      }

      // --- 2. Calculate Levels ---
      double l_sl = l + (rng * Long_SL_Level);
      double l_tp = l + (rng * Long_TP_Level);
      
      double s_sl = l + (rng * Short_SL_Level);
      double s_tp = l - (rng * MathAbs(Short_TP_Level));

      // --- 3. Draw Lines (Segmented) ---
      // Long Setup
      DrawSegment("RVFL_L_TP"+suffix, t_start, t_end, l_tp, Color_TP, 1, STYLE_SOLID);
      DrawSegment("RVFL_L_Ent"+suffix, t_start, t_end, h, Color_Entry, Line_Width, STYLE_SOLID);
      DrawSegment("RVFL_L_SL"+suffix, t_start, t_end, l_sl, Color_SL, 1, STYLE_DOT);
      
      // Short Setup
      DrawSegment("RVFL_S_SL"+suffix, t_start, t_end, s_sl, Color_SL, 1, STYLE_DOT);
      DrawSegment("RVFL_S_Ent"+suffix, t_start, t_end, l, Color_Entry, Line_Width, STYLE_SOLID);
      DrawSegment("RVFL_S_TP"+suffix, t_start, t_end, s_tp, Color_TP, 1, STYLE_SOLID);
   }
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Helper: Draw Trend Line Segment                                  |
//+------------------------------------------------------------------+
void DrawSegment(string name, datetime t1, datetime t2, double price, color clr, int width, ENUM_LINE_STYLE style)
{
   if(ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price);
   else
   {
      ObjectSetDouble(0, name, OBJPROP_PRICE, 0, price);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 1, price);
      ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
      ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
   }
   
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false); 
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false); 
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true); 
}

//+------------------------------------------------------------------+
//| Helper: Check for New Bar                                        |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   static datetime last_time = 0;
   datetime current_time = iTime(Symbol(), Period(), 0);
   if(last_time != current_time)
   {
      last_time = current_time;
      return true;
   }
   return false;
}