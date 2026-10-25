//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "© 2026 tshalgo"
#property link "https://www.mql5.com/en/users/protimetrader"
#property version "1.00"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 1

//--- plot ZigZag
#property indicator_label1 "ZigZag"
#property indicator_type1 DRAW_SECTION
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

//--- input parameters
input int InpLookback = 512;
input int InpDepth = 12;    // Depth
input int InpDeviation = 5; // Deviation
input int InpBackstep = 3;  // Back Step

//--- indicator buffers
double ZigZagBuffer[];  // main buffer
double HighMapBuffer[]; // ZigZag high extremes (peaks)
double LowMapBuffer[];  // ZigZag low extremes (bottoms)

int ExtRecalc = 3; // number of last extremes for recalculation

enum EnSearchMode {
   Extremum = 0, // searching for the first extremum
   Peak = 1,     // searching for the next ZigZag peak
   Bottom = -1   // searching for the next ZigZag bottom
};

struct ZZPoint {
   datetime          m_time;
   double            m_price;
   int               m_trend;
};

#define ZZ_MAX 36
#define OBJECT_NAME_PREFIX "ZBC"
ZZPoint m_zz[ZZ_MAX];
int m_zzCount = 0;

double m_lastZZPrice = 0.0;
int m_lastZZDir = 0; // global

// keep track of last processed pivot bar
datetime m_lastZZTime = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0, ZigZagBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, HighMapBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(2, LowMapBuffer, INDICATOR_CALCULATIONS);

//--- set short name and digits
   string short_name = StringFormat("ZigZag(%d,%d,%d)", InpDepth, InpDeviation, InpBackstep);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   PlotIndexSetString(0, PLOT_LABEL, short_name);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
//--- set an empty value
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(ChartID(), OBJECT_NAME_PREFIX);
}

//+------------------------------------------------------------------+
//| ZigZag calculation                                               |
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
   if(rates_total < 100)
      return (0);
//---
   int i = 0;
   int start = 0, extreme_counter = 0, extreme_search = Extremum;
   int shift = 0, back = 0, last_high_pos = 0, last_low_pos = 0;
   double val = 0, res = 0;
   double curlow = 0, curhigh = 0, last_high = 0, last_low = 0;

//--- initializing
   if(prev_calculated == 0) {
      ArrayInitialize(ZigZagBuffer, 0.0);
      ArrayInitialize(HighMapBuffer, 0.0);
      ArrayInitialize(LowMapBuffer, 0.0);
      start = InpDepth;
   }

//--- ZigZag was already calculated before
   if(prev_calculated > 0) {
      i = rates_total - 1;

      //--- searching for the third extremum from the last uncompleted bar
      while(extreme_counter < ExtRecalc && i > rates_total - 100) {
         res = ZigZagBuffer[i];
         if(res != 0.0)
            extreme_counter++;
         i--;
      }
      i++;
      start = i;

      //--- what type of exremum we search for
      if(LowMapBuffer[i] != 0.0) {
         curlow = LowMapBuffer[i];
         extreme_search = Peak;
      } else {
         curhigh = HighMapBuffer[i];
         extreme_search = Bottom;
      }

      //--- clear indicator values
      for(i = start + 1; i < rates_total && !IsStopped(); i++) {
         ZigZagBuffer[i] = 0.0;
         LowMapBuffer[i] = 0.0;
         HighMapBuffer[i] = 0.0;
      }
   }

//--- searching for high and low extremes
   for(shift = start; shift < rates_total && !IsStopped(); shift++) {
      //--- low
      val = low[Lowest(low, InpDepth, shift)];
      if(val == last_low)
         val = 0.0;
      else {
         last_low = val;
         if((low[shift] - val) > InpDeviation * _Point)
            val = 0.0;
         else {
            for(back = 1; back <= InpBackstep; back++) {
               res = LowMapBuffer[shift - back];
               if((res != 0) && (res > val))
                  LowMapBuffer[shift - back] = 0.0;
            }
         }
      }
      if(low[shift] == val)
         LowMapBuffer[shift] = val;
      else
         LowMapBuffer[shift] = 0.0;

      //--- high
      val = high[Highest(high, InpDepth, shift)];
      if(val == last_high)
         val = 0.0;
      else {
         last_high = val;
         if((val - high[shift]) > InpDeviation * _Point)
            val = 0.0;
         else {
            for(back = 1; back <= InpBackstep; back++) {
               res = HighMapBuffer[shift - back];
               if((res != 0) && (res < val))
                  HighMapBuffer[shift - back] = 0.0;
            }
         }
      }
      if(high[shift] == val)
         HighMapBuffer[shift] = val;
      else
         HighMapBuffer[shift] = 0.0;
   }

//--- set last values
   if(extreme_search == 0) { // undefined values
      last_low = 0.0;
      last_high = 0.0;
   } else {
      last_low = curlow;
      last_high = curhigh;
   }

//--- final selection of extreme points for ZigZag
   for(shift = start; shift < rates_total && !IsStopped(); shift++) {
      res = 0.0;
      switch(extreme_search) {
      case Extremum:
         if(last_low == 0.0 && last_high == 0.0) {
            if(HighMapBuffer[shift] != 0) {
               last_high = high[shift];
               last_high_pos = shift;
               extreme_search = Bottom;
               ZigZagBuffer[shift] = last_high;
               res = 1;
            }
            if(LowMapBuffer[shift] != 0.0) {
               last_low = low[shift];
               last_low_pos = shift;
               extreme_search = Peak;
               ZigZagBuffer[shift] = last_low;
               res = 1;
            }
         }
         break;
      case Peak:
         if(LowMapBuffer[shift] != 0.0 && LowMapBuffer[shift] < last_low && HighMapBuffer[shift] == 0.0) {
            ZigZagBuffer[last_low_pos] = 0.0;
            last_low_pos = shift;
            last_low = LowMapBuffer[shift];
            ZigZagBuffer[shift] = last_low;
            res = 1;
         }
         if(HighMapBuffer[shift] != 0.0 && LowMapBuffer[shift] == 0.0) {
            last_high = HighMapBuffer[shift];
            last_high_pos = shift;
            ZigZagBuffer[shift] = last_high;
            extreme_search = Bottom;
            res = 1;
         }
         break;
      case Bottom:
         if(HighMapBuffer[shift] != 0.0 && HighMapBuffer[shift] > last_high && LowMapBuffer[shift] == 0.0) {
            ZigZagBuffer[last_high_pos] = 0.0;
            last_high_pos = shift;
            last_high = HighMapBuffer[shift];
            ZigZagBuffer[shift] = last_high;
         }
         if(LowMapBuffer[shift] != 0.0 && HighMapBuffer[shift] == 0.0) {
            last_low = LowMapBuffer[shift];
            last_low_pos = shift;
            ZigZagBuffer[shift] = last_low;
            extreme_search = Peak;
         }
         break;
      default:
         return (rates_total);
      }
   }

//--- update and draw only on new bar
   if(prev_calculated != rates_total) {
      UpdateZigZagPivots(time);
      DetectBOS();
      DetectCHoCH();
   }

//--- return value of prev_calculated for next call
   return (rates_total);
}

//+------------------------------------------------------------------+
//|  Search for the index of the highest bar                         |
//+------------------------------------------------------------------+
int Highest(const double& array[], const int depth, const int start)
{
   if(start < 0)
      return (0);

   double max = array[start];
   int index = start;

//--- start searching
   for(int i = start - 1; i > start - depth && i >= 0; i--) {
      if(array[i] > max) {
         index = i;
         max = array[i];
      }
   }

//--- return index of the highest bar
   return (index);
}
//+------------------------------------------------------------------+
//|  Search for the index of the lowest bar                          |
//+------------------------------------------------------------------+
int Lowest(const double& array[], const int depth, const int start)
{
   if(start < 0)
      return (0);

   double min = array[start];
   int index = start;

//--- start searching
   for(int i = start - 1; i > start - depth && i >= 0; i--) {
      if(array[i] < min) {
         index = i;
         min = array[i];
      }
   }

//--- return index of the lowest bar
   return (index);
}

void UpdateZigZagPivots(const datetime& time[])
{
   const int total = ArraySize(ZigZagBuffer);
   if(total <= 1)
      return;

   const int lookback = (InpLookback < 2 ? 2 : InpLookback);
   int start = total - lookback;
   if(start < 1)
      start = 1;

   const int end = total - 1;

// scan OLDEST → NEWEST (normal indexing)
   for(int i = start; i <= end; i++) {
      const double cur = ZigZagBuffer[i];
      if(cur == EMPTY_VALUE || cur == 0.0)
         continue;

      const datetime t = time[i];

      // first pivot
      if(m_zzCount == 0) {
         PushZZ(t, cur);
         m_lastZZPrice = cur;
         m_lastZZTime = t;
         m_lastZZDir = 0;
         continue;
      }

      const double last = m_zz[m_zzCount - 1].m_price;

      // If equal price, treat as update (avoid fake flips)
      int dir;
      if(cur > last)
         dir = 1;
      else if(cur < last)
         dir = -1;
      else
         dir = m_lastZZDir;

      // same direction (or not locked yet) → UPDATE last pivot
      if(dir == m_lastZZDir || m_lastZZDir == 0) {
         m_zz[m_zzCount - 1].m_price = cur;
         m_zz[m_zzCount - 1].m_time = t;
      } else {
         // direction flipped → PUSH new pivot
         PushZZ(t, cur);
      }

      m_lastZZDir = dir;
      m_lastZZPrice = cur;
      m_lastZZTime = t;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PushZZ(datetime t, double p)
{
// prevent duplicates
   if(m_zzCount > 0 && m_zz[m_zzCount - 1].m_time == t)
      return;

   if(m_zzCount < ZZ_MAX)
      m_zzCount++;
   else {
      // shift left
      for(int i = 0; i < ZZ_MAX - 1; i++)
         m_zz[i] = m_zz[i + 1];
   }

   m_zz[m_zzCount - 1].m_time = t;
   m_zz[m_zzCount - 1].m_price = p;

   int trend = 0;
   if(m_zzCount > 2) {
      const double p1 = m_zz[m_zzCount - 3].m_price;
      const double p2 = m_zz[m_zzCount - 2].m_price;
      const double p3 = p;

      if(p2 < p1 && p3 > p1) {
         trend = 1;
      }

      if(p2 > p1 && p3 < p1) {
         trend = -1;
      }
   }

   m_zz[m_zzCount - 1].m_trend = trend;
}

// Detects BOS only (continuation breaks).
void DetectBOS()
{
   const long   chart_id = ChartID();
   const string prefix   = OBJECT_NAME_PREFIX + "_BOS_";
   ObjectsDeleteAll(chart_id, prefix);

   if(m_zzCount <= 2)
      return;

   for(int i = 2; i < m_zzCount; i++) {
      const ZZPoint lastPivot  = m_zz[i];
      const ZZPoint firstPivot = m_zz[i - 2];

      const int trendNow  = m_zz[i].m_trend;
      const int trendPrev = m_zz[i - 2].m_trend;

      // continuation in same direction only
      if((trendNow > 0 && trendPrev > 0) || (trendNow < 0 && trendPrev < 0)) {
         const datetime bt = BreakTime(m_zz[i - 1].m_time,
                                       lastPivot.m_time,
                                       firstPivot.m_price,
                                       trendNow);

         if(bt > 0)
            DrawBOS(firstPivot, bt, trendNow);
      }
   }
}



// Draws a BOS as a horizontal segment from the pivot time to the break time,
// plus a small "BOS" label at the break point.
void DrawBOS(const ZZPoint& pivot,
             const datetime breakTime,
             const int dir = 0) // +1 bullish, -1 bearish, 0 unknown
{
   const long chart_id = ChartID();
   const string prefix = OBJECT_NAME_PREFIX + "_BOS_";

// Ensure time order
   datetime t1 = pivot.m_time;
   datetime t2 = breakTime;
   if(t2 < t1) {
      datetime tmp = t1;
      t1 = t2;
      t2 = tmp;
   }

// Unique base name
   const string base = prefix + IntegerToString((long)t1) + "_" + IntegerToString((long)t2);

   const string line_name = base + "_L";
   const string text_name = base + "_T";

// Pick a color based on direction
   color c = clrSilver;
   if(dir > 0)
      c = clrLime;
   else if(dir < 0)
      c = clrTomato;

// ---- Line (horizontal segment) ----
   if(ObjectFind(chart_id, line_name) < 0) {
      if(!ObjectCreate(chart_id, line_name, OBJ_TREND, 0, t1, pivot.m_price, t2, pivot.m_price))
         return;
   } else {
      ObjectMove(chart_id, line_name, 0, t1, pivot.m_price);
      ObjectMove(chart_id, line_name, 1, t2, pivot.m_price);
   }

   ObjectSetInteger(chart_id, line_name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(chart_id, line_name, OBJPROP_RAY_LEFT, false);
   ObjectSetInteger(chart_id, line_name, OBJPROP_COLOR, c);
   ObjectSetInteger(chart_id, line_name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(chart_id, line_name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(chart_id, line_name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chart_id, line_name, OBJPROP_HIDDEN, true);

// ---- Text label ("BOS") ----
   const string label = "BOS";

   if(ObjectFind(chart_id, text_name) < 0) {
      if(!ObjectCreate(chart_id, text_name, OBJ_TEXT, 0, t2, pivot.m_price))
         return;
   } else {
      ObjectMove(chart_id, text_name, 0, t2, pivot.m_price);
   }

   ObjectSetString(chart_id, text_name, OBJPROP_TEXT, label);
   ObjectSetInteger(chart_id, text_name, OBJPROP_COLOR, c);
   ObjectSetInteger(chart_id, text_name, OBJPROP_ANCHOR, ANCHOR_LEFT);
   ObjectSetInteger(chart_id, text_name, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(chart_id, text_name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chart_id, text_name, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DetectCHoCH()
{
   const long   chart_id = ChartID();
   const string prefix   = OBJECT_NAME_PREFIX + "_CHoCH_";
   ObjectsDeleteAll(chart_id, prefix);

   if(m_zzCount <= 2)
      return;

   for(int i = 2; i < m_zzCount; i++) {
      const ZZPoint lastPivot  = m_zz[i];
      const ZZPoint firstPivot = m_zz[i - 2];

      const int trendNow  = m_zz[i].m_trend;
      const int trendPrev = m_zz[i - 2].m_trend;

      // CHoCH = direction changed (non-zero -> opposite non-zero)
      if((trendNow > 0 && trendPrev <= 0) || (trendNow < 0 && trendPrev >= 0)) {
         const datetime bt = BreakTime(m_zz[i - 1].m_time,
                                       lastPivot.m_time,
                                       firstPivot.m_price,
                                       trendNow);

         if(bt > 0)
            DrawCHoCH(firstPivot, bt, trendNow);
      }
   }
}

// Draws a CHoCH as a horizontal segment from the swing level time to the break time,
// plus a "CHoCH" label at the break point.
void DrawCHoCH(const ZZPoint &level,
               const datetime breakTime,
               const int dir = 0) // +1 bullish CHoCH, -1 bearish CHoCH, 0 unknown
{
   const long   chart_id = ChartID();
   const string prefix   = OBJECT_NAME_PREFIX + "_CHoCH_";

// Ensure time order
   datetime t1 = level.m_time;
   datetime t2 = breakTime;
   if(t2 < t1) {
      datetime tmp = t1;
      t1 = t2;
      t2 = tmp;
   }

// Unique base name
   const string base = prefix + IntegerToString((long)t1) + "_" + IntegerToString((long)t2);

   const string line_name = base + "_L";
   const string text_name = base + "_T";

// Color by direction
   color c = clrSilver;
   if(dir > 0)
      c = clrLime;    // bullish CHoCH
   else if(dir < 0)
      c = clrTomato;  // bearish CHoCH

// ---- Line (horizontal segment) ----
   if(ObjectFind(chart_id, line_name) < 0) {
      if(!ObjectCreate(chart_id, line_name, OBJ_TREND, 0, t1, level.m_price, t2, level.m_price))
         return;
   } else {
      ObjectMove(chart_id, line_name, 0, t1, level.m_price);
      ObjectMove(chart_id, line_name, 1, t2, level.m_price);
   }

   ObjectSetInteger(chart_id, line_name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(chart_id, line_name, OBJPROP_RAY_LEFT,  false);
   ObjectSetInteger(chart_id, line_name, OBJPROP_COLOR,     c);
   ObjectSetInteger(chart_id, line_name, OBJPROP_WIDTH,     2);
   ObjectSetInteger(chart_id, line_name, OBJPROP_STYLE,     STYLE_DOT);
   ObjectSetInteger(chart_id, line_name, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_id, line_name, OBJPROP_HIDDEN,    true);

// ---- Text label ("CHoCH") ----
   if(ObjectFind(chart_id, text_name) < 0) {
      if(!ObjectCreate(chart_id, text_name, OBJ_TEXT, 0, t2, level.m_price))
         return;
   } else {
      ObjectMove(chart_id, text_name, 0, t2, level.m_price);
   }

   ObjectSetString(chart_id, text_name, OBJPROP_TEXT, "CHoCH");
   ObjectSetInteger(chart_id, text_name, OBJPROP_COLOR, c);
   ObjectSetInteger(chart_id, text_name, OBJPROP_ANCHOR, ANCHOR_LEFT);
   ObjectSetInteger(chart_id, text_name, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(chart_id, text_name, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_id, text_name, OBJPROP_HIDDEN,    true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime BreakTime(const datetime start_pivot_time,
                   const datetime last_pivot_time,
                   const double   last_pivot_price,
                   const int      trend)
{
   int startShift = iBarShift(_Symbol, _Period, start_pivot_time);
   int endShift   = iBarShift(_Symbol, _Period, last_pivot_time);

   if(startShift < 0 || endShift < 0)
      return 0;

// Ensure we iterate from older -> newer:
// older has larger shift, newer has smaller shift
   if(startShift < endShift) {
      int tmp = startShift;
      startShift = endShift;
      endShift   = tmp;
   }

   if(trend > 0) {
      // bullish break: close > last pivot price
      for(int i = startShift; i >= endShift; --i) {
         Print(i);
         if(iClose(_Symbol, _Period, i) > last_pivot_price)
            return iTime(_Symbol, _Period, i);
      }
   } else if(trend < 0) {
      // bearish break: close < last pivot price
      for(int i = startShift; i >= endShift; --i) {
         if(iClose(_Symbol, _Period, i) < last_pivot_price)
            return iTime(_Symbol, _Period, i);
      }
   }

   return 0; // no break found
}
//+------------------------------------------------------------------+