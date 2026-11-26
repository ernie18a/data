//+------------------------------------------------------------------+
//|                               Dynamic_Session_Sweep_Detector.mq5 |
//|                                    Author: Gbadebo Adedayo David |
//|   Tracks Asian / London / New York session ranges, locks them    |
//|     at session close, and flags liquidity sweeps of those ranges |
//|   with a rejection close back inside the level.                  |
//+------------------------------------------------------------------+
#property copyright "Gbadebo Adedayo David"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDimGray
#property indicator_width1  2
#property indicator_label1  "Sweep Down (bearish)"

#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDimGray
#property indicator_width2  2
#property indicator_label2  "Sweep Up (bullish)"

//--- Session hours (server time)
input int    InpAsianStartHour     = 0;      // Asian session start hour
input int    InpAsianEndHour       = 7;      // Asian session end hour (range locks here)
input int    InpLondonStartHour    = 7;      // London session start hour
input int    InpLondonEndHour      = 13;     // London session end hour (range locks here)
input int    InpNewYorkStartHour   = 13;     // New York session start hour
input int    InpNewYorkEndHour     = 21;     // New York session end hour (range locks here)

//--- General settings
input int    InpLookbackDays       = 5;      // Days of session history to draw/scan
input double InpMinSweepPips       = 2.0;    // Minimum penetration beyond level to count as a sweep
input int    InpSweepZoneBars      = 6;      // Width of shaded reaction zone (in bars)
input bool   InpShowSessionBoxes   = true;   // Draw session range rectangles
input bool   InpShowSweepZones     = true;   // Draw shaded reaction zone after a sweep
input bool   InpAlertOnSweep       = false;  // Alert on newly confirmed sweep

//--- Visuals
input color  InpAsianBoxColor      = clrSilver;    // Asian box border color
input color  InpLondonBoxColor     = clrGray;      // London box border color
input color  InpNewYorkBoxColor    = clrDimGray;   // New York box border color
input color  InpZoneColor          = clrGainsboro; // Reaction zone fill color
input int    InpSweepUpArrowCode   = 233;    // Wingdings code, swept-low (bullish) arrow
input int    InpSweepDownArrowCode = 234;    // Wingdings code, swept-high (bearish) arrow

//--- Indicator buffers
double SweepDownBuffer[];   // bearish signal (swept a session high)
double SweepUpBuffer[];     // bullish signal (swept a session low)

//--- Internal structure describing one session's daily range
struct SessionRange
  {
   datetime day;         // midnight timestamp of the trading day this range belongs to
   datetime start_time;
   datetime end_time;
   double   high;
   double   low;
   bool     locked;       // true once session end hour has passed
   bool     sweptHigh;    // high already swept and marked this day
   bool     sweptLow;     // low already swept and marked this day
   bool     boxDrawn;
  };

#define SESSION_COUNT 3
SessionRange g_sessions[SESSION_COUNT][32]; // [session index][rolling day slot]
string       g_sessionNames[SESSION_COUNT] = {"Asian","London","NewYork"};
color        g_sessionColors[SESSION_COUNT];

double       g_pipSize = 0.0;

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, SweepDownBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SweepUpBuffer,   INDICATOR_DATA);

   PlotIndexSetInteger(0, PLOT_ARROW, InpSweepDownArrowCode);
   PlotIndexSetInteger(1, PLOT_ARROW, InpSweepUpArrowCode);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   ArraySetAsSeries(SweepDownBuffer, false);
   ArraySetAsSeries(SweepUpBuffer,   false);

   g_sessionColors[0] = InpAsianBoxColor;
   g_sessionColors[1] = InpLondonBoxColor;
   g_sessionColors[2] = InpNewYorkBoxColor;

   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   g_pipSize = (digits == 3 || digits == 5) ? point * 10.0 : point;

   ArrayInitialize(SweepDownBuffer, EMPTY_VALUE);
   ArrayInitialize(SweepUpBuffer,   EMPTY_VALUE);

   IndicatorSetString(INDICATOR_SHORTNAME, "Dynamic Session Sweep Detector");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "DSSD_");
  }

//+------------------------------------------------------------------+
//| Returns the rolling slot index for a given day (0..31), keyed by |
//| days-since-epoch modulo array size — enough for InpLookbackDays  |
//+------------------------------------------------------------------+
int DaySlot(datetime day)
  {
   long days = day / 86400;
   return (int)(days % 32);
  }

//+------------------------------------------------------------------+
//| Session hour bounds lookup                                       |
//+------------------------------------------------------------------+
void GetSessionHours(int sIdx, int &startHour, int &endHour)
  {
   if(sIdx == 0) { startHour = InpAsianStartHour;   endHour = InpAsianEndHour;   }
   else if(sIdx == 1) { startHour = InpLondonStartHour;  endHour = InpLondonEndHour;  }
   else { startHour = InpNewYorkStartHour; endHour = InpNewYorkEndHour; }
  }

//+------------------------------------------------------------------+
//| Draws / updates the rectangle for a locked session range         |
//+------------------------------------------------------------------+
void DrawSessionBox(int sIdx, SessionRange &sr)
  {
   if(!InpShowSessionBoxes)
      return;

   string name = "DSSD_Box_" + g_sessionNames[sIdx] + "_" + IntegerToString((long)sr.day);

   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, sr.start_time, sr.high, sr.end_time, sr.low);
   else
     {
      ObjectMove(0, name, 0, sr.start_time, sr.high);
      ObjectMove(0, name, 1, sr.end_time,   sr.low);
     }

   ObjectSetInteger(0, name, OBJPROP_COLOR, g_sessionColors[sIdx]);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_FILL,  false);
   ObjectSetInteger(0, name, OBJPROP_BACK,  true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, g_sessionNames[sIdx] + " range " + TimeToString(sr.day, TIME_DATE));
  }

//+------------------------------------------------------------------+
//| Draws the shaded reaction zone after a confirmed sweep           |
//+------------------------------------------------------------------+
void DrawSweepZone(int sIdx, datetime sweepTime, double top, double bottom, datetime zoneEnd)
  {
   if(!InpShowSweepZones)
      return;

   string name = "DSSD_Zone_" + g_sessionNames[sIdx] + "_" + IntegerToString((long)sweepTime);

   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, sweepTime, top, zoneEnd, bottom);
   else
     {
      ObjectMove(0, name, 0, sweepTime, top);
      ObjectMove(0, name, 1, zoneEnd,   bottom);
     }

   ObjectSetInteger(0, name, OBJPROP_COLOR, InpZoneColor);
   ObjectSetInteger(0, name, OBJPROP_FILL,  true);
   ObjectSetInteger(0, name, OBJPROP_BACK,  true);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

//+------------------------------------------------------------------+
//| Main calculation                                                 |
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
   if(rates_total < 3)
      return(0);

   int start = (prev_calculated > 2) ? prev_calculated - 2 : 0;

   // limit how far back we bother processing, based on InpLookbackDays
   datetime cutoff = time[rates_total - 1] - (datetime)(InpLookbackDays + 1) * 86400;

   for(int i = start; i < rates_total; i++)
     {
      if(i < 0 || time[i] < cutoff)
         continue;

      if(i >= ArraySize(SweepDownBuffer))
         continue;

      SweepDownBuffer[i] = EMPTY_VALUE;
      SweepUpBuffer[i]   = EMPTY_VALUE;

      MqlDateTime mdt;
      TimeToStruct(time[i], mdt);
      datetime dayStart = time[i] - (mdt.hour * 3600 + mdt.min * 60 + mdt.sec);

      for(int s = 0; s < SESSION_COUNT; s++)
        {
         int slot = DaySlot(dayStart);
         SessionRange range = g_sessions[s][slot];

         int sh, eh;
         GetSessionHours(s, sh, eh);
         datetime sessStart = dayStart + sh * 3600;
         datetime sessEnd   = dayStart + eh * 3600;

         // (Re)initialize the slot if it belongs to a new day
         if(range.day != dayStart)
           {
            range.day        = dayStart;
            range.start_time = sessStart;
            range.end_time   = sessEnd;
            range.high       = -DBL_MAX;
            range.low        = DBL_MAX;
            range.locked     = false;
            range.sweptHigh  = false;
            range.sweptLow   = false;
            range.boxDrawn   = false;
           }

         // Build the range while inside session hours
         if(time[i] >= sessStart && time[i] < sessEnd)
           {
            if(high[i] > range.high) range.high = high[i];
            if(low[i]  < range.low)  range.low  = low[i];
           }
         // Lock it the first bar at/after session end
         else if(time[i] >= sessEnd && !range.locked && range.high > -DBL_MAX)
           {
            range.locked = true;
            DrawSessionBox(s, range);
            range.boxDrawn = true;
           }

         // Sweep detection only applies once the range is locked
         if(range.locked && time[i] >= range.end_time)
           {
            double minSweep = InpMinSweepPips * g_pipSize;

            // Bearish sweep: wick trades above locked high, candle closes back below it
            if(!range.sweptHigh && high[i] > range.high + minSweep && close[i] < range.high)
              {
               range.sweptHigh = true;
               SweepDownBuffer[i] = high[i];

               datetime zoneEnd = time[i] + (datetime)InpSweepZoneBars * PeriodSeconds();
               DrawSweepZone(s, time[i], high[i], range.high, zoneEnd);

               if(InpAlertOnSweep)
                  Alert(_Symbol, " ", g_sessionNames[s], " session high swept at ", TimeToString(time[i]));
              }

            // Bullish sweep: wick trades below locked low, candle closes back above it
            if(!range.sweptLow && low[i] < range.low - minSweep && close[i] > range.low)
              {
               range.sweptLow = true;
               SweepUpBuffer[i] = low[i];

               datetime zoneEnd = time[i] + (datetime)InpSweepZoneBars * PeriodSeconds();
               DrawSweepZone(s, time[i], range.low, low[i], zoneEnd);

               if(InpAlertOnSweep)
                  Alert(_Symbol, " ", g_sessionNames[s], " session low swept at ", TimeToString(time[i]));
              }
           }

         // While still forming (not yet locked), keep the box preview updated on the last bar
         if(!range.locked && i == rates_total - 1 && range.high > -DBL_MAX)
            DrawSessionBox(s, range);

         g_sessions[s][slot] = range;
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
