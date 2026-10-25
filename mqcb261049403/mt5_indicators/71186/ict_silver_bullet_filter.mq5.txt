//+------------------------------------------------------------------+
//|                                     ICT_Silver_Bullet_Filter.mq5 |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

input group "=== Temporal Settings ==="
input string InpStartTime     = "10:00";     // Silver Bullet Start Time
input string InpEndTime       = "11:00";     // Silver Bullet End Time
input int    InpBrokerOffset  = 0;           // Broker GMT Shift (Hours)
input int    InpMaxDays       = 10;          // History Days to Scan

input group "=== Visuals ==="
input color  InpWindowColor   = clrDarkSlateGray; // Macro Window Color
input color  InpBullFVGColor  = clrDarkSeaGreen;  // Bullish FVG Color
input color  InpBearFVGColor  = clrIndianRed;     // Bearish FVG Color

string prefix = "SB_MACRO_";

//+------------------------------------------------------------------+
int OnInit()
  {
   Print("ICT Silver Bullet Filter Initialized.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, prefix);
  }

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
   if(rates_total < 5) return(0);
   if(_Period > PERIOD_H1) return(rates_total); 

   int limit = (prev_calculated == 0) ? rates_total - (InpMaxDays * 288) : prev_calculated - 1;
   if(limit < 2) limit = 2;

   for(int i = limit; i < rates_total - 1; i++)
     {
      datetime current_time = time[i];
      MqlDateTime dt;
      TimeToStruct(current_time, dt);
      
      // Calculate active window
      int h_start = (int)StringToInteger(StringSubstr(InpStartTime, 0, 2)) + InpBrokerOffset;
      int m_start = (int)StringToInteger(StringSubstr(InpStartTime, 3, 2));
      int h_end   = (int)StringToInteger(StringSubstr(InpEndTime, 0, 2)) + InpBrokerOffset;
      int m_end   = (int)StringToInteger(StringSubstr(InpEndTime, 3, 2));
      
      int current_mins = dt.hour * 60 + dt.min;
      int start_mins   = h_start * 60 + m_start;
      int end_mins     = h_end * 60 + m_end;
      
      bool is_silver_bullet = (current_mins >= start_mins && current_mins <= end_mins);

      // Draw Time Window Background Line (Bottom of chart)
      if(is_silver_bullet)
        {
         string line_name = prefix + "W_" + TimeToString(time[i]);
         if(ObjectFind(0, line_name) < 0)
           {
            ObjectCreate(0, line_name, OBJ_VLINE, 0, time[i], 0);
            ObjectSetInteger(0, line_name, OBJPROP_COLOR, InpWindowColor);
            ObjectSetInteger(0, line_name, OBJPROP_STYLE, STYLE_DOT);
            ObjectSetInteger(0, line_name, OBJPROP_BACK, true);
           }
        }

      // Filter: Only process FVGs INSIDE the Silver Bullet window
      if(!is_silver_bullet) continue;

      // FVG Logic (3-candle formation)
      double high_1 = high[i-2];
      double low_1  = low[i-2];
      double high_3 = high[i];
      double low_3  = low[i];

      // Bullish FVG
      if(low_3 > high_1)
        {
         string box_name = prefix + "FVG_B_" + TimeToString(time[i-1]);
         if(ObjectFind(0, box_name) < 0)
           {
            ObjectCreate(0, box_name, OBJ_RECTANGLE, 0, time[i-2], low_3, time[i]+PeriodSeconds(_Period)*5, high_1);
            ObjectSetInteger(0, box_name, OBJPROP_COLOR, InpBullFVGColor);
            ObjectSetInteger(0, box_name, OBJPROP_FILL, true);
            ObjectSetInteger(0, box_name, OBJPROP_BACK, true);
           }
        }

      // Bearish FVG
      if(high_3 < low_1)
        {
         string box_name = prefix + "FVG_S_" + TimeToString(time[i-1]);
         if(ObjectFind(0, box_name) < 0)
           {
            ObjectCreate(0, box_name, OBJ_RECTANGLE, 0, time[i-2], high_3, time[i]+PeriodSeconds(_Period)*5, low_1);
            ObjectSetInteger(0, box_name, OBJPROP_COLOR, InpBearFVGColor);
            ObjectSetInteger(0, box_name, OBJPROP_FILL, true);
            ObjectSetInteger(0, box_name, OBJPROP_BACK, true);
           }
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+