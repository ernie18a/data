#property copyright "© 2026 tshalgo"
#property link "https://www.mql5.com/en/users/protimetrader"
#property version "1.00"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 1

//--- plot ZigZag
#property indicator_label1 "ZigZag"
#property indicator_color1 C'103,128,119'
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

//+------------------------------------------------------------------+
//|                       INPUT PARAMETERS                           |
//+------------------------------------------------------------------+
input int InpLookback = 512; // Total number of bars to analyze
input int InpDepth = 12;     // ZigZag Depth
input int InpDeviation = 5;  // ZigZag Deviation
input int InpBackstep = 3;   // ZigZag Backstep

input bool InpDrawClosed = true; // Show closed levels
input bool InpDrawZigZag = true; // Show ZigZag line
input bool InpDrawLabels = true; // Show level labels

//+------------------------------------------------------------------+
//|                          CONSTANTS                               |
//+------------------------------------------------------------------+
#define ZZ_MAX 36
#define OBJECT_NAME_PREFIX "ZZ_SNR_DT"

//+------------------------------------------------------------------+
//|                      INDICATOR BUFFERS                           |
//+------------------------------------------------------------------+
double ZigZagBuffer[];  // Main ZigZag buffer
double HighMapBuffer[]; // ZigZag high extremes
double LowMapBuffer[];  // ZigZag low extremes

//+------------------------------------------------------------------+
//|                      INTERNAL VARIABLES                          |
//+------------------------------------------------------------------+
int m_extRecalc = 3;        // Number of last extremes to recalc
double m_lastZZPrice = 0.0; // Last ZigZag price
int m_lastZZDir = 0;        // Last ZigZag direction
datetime m_lastZZTime = 0;  // Last processed pivot time

//+------------------------------------------------------------------+
//|                         ENUMERATIONS                             |
//+------------------------------------------------------------------+
enum ESearchMode
  {
   SEARCH_MODE_EXTREMUM = 0, // Searching first extremum
   SEARCH_MODE_PEAK = 1,     // Searching next peak
   SEARCH_MODE_BOTTOM = -1   // Searching next bottom
  };

//+------------------------------------------------------------------+
//|                           STRUCTURES                             |
//+------------------------------------------------------------------+
struct SZZPoint
  {
   datetime          time;
   double            price;
   int               trend;
   int               shift; // Not series index
  };

struct SLineStyle
  {
   color             line_color;
   int               line_width;
   ENUM_LINE_STYLE   line_style;
   bool              is_selectable;
  };

struct STextStyle
  {
   string            font_name;
   int               font_size;
   color             text_color;
   bool              is_selectable;
   ENUM_ANCHOR_POINT anchor;
  };

struct SSNRStyle
  {
   SLineStyle        line;
   STextStyle        text;
  };

struct SSNRLevel
  {
   string            type; // "S" or "R"
   double            price;
   datetime          t1;
   datetime          t2;
   bool              is_open;

   int               x;
   int               y;
  };

//+------------------------------------------------------------------+
//|                        GLOBAL STORAGE                            |
//+------------------------------------------------------------------+
SZZPoint m_zz[ZZ_MAX];
int m_zzCount = 0;

SSNRLevel m_extLevels[];
SSNRStyle m_extSupportStyle;
SSNRStyle m_extResistanceStyle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
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

//--- draw type
   if(!InpDrawZigZag)
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
   else
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_SECTION);

//--- SUPPORT STYLE ---
   m_extSupportStyle.line.line_color   = C'103,128,119';
   m_extSupportStyle.line.line_width   = 2;
   m_extSupportStyle.line.line_style   = STYLE_SOLID;
   m_extSupportStyle.line.is_selectable = false;

   m_extSupportStyle.text.font_name    = "Fira Code Medium";
   m_extSupportStyle.text.font_size    = 10;
   m_extSupportStyle.text.text_color   = C'235,219,178';
   m_extSupportStyle.text.is_selectable = false;
   m_extSupportStyle.text.anchor       = ANCHOR_LEFT;

//--- RESISTANCE STYLE ---
   m_extResistanceStyle.line.line_color   = C'197,126,145';
   m_extResistanceStyle.line.line_width   = 1;
   m_extResistanceStyle.line.line_style   = STYLE_DOT;
   m_extResistanceStyle.line.is_selectable = false;

   m_extResistanceStyle.text.font_name    = "Fira Code Medium";
   m_extResistanceStyle.text.font_size    = 10;
   m_extResistanceStyle.text.text_color   = C'235,219,178';
   m_extResistanceStyle.text.is_selectable = false;
   m_extResistanceStyle.text.anchor       = ANCHOR_LEFT;

//--- set empty value
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(ChartID(), OBJECT_NAME_PREFIX);
   ClearLevels();
  }

//+------------------------------------------------------------------+
//| ZigZag calculation                                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
  {
   if(rates_total < 100)
      return (0);

//---
   int i = 0;
   int start = 0, extreme_counter = 0, extreme_search = SEARCH_MODE_EXTREMUM;
   int shift = 0, back = 0, last_high_pos = 0, last_low_pos = 0;
   double val = 0, res = 0;
   double curlow = 0, curhigh = 0, last_high = 0, last_low = 0;

//--- initializing
   if(prev_calculated == 0)
     {
      ArrayInitialize(ZigZagBuffer, 0.0);
      ArrayInitialize(HighMapBuffer, 0.0);
      ArrayInitialize(LowMapBuffer, 0.0);
      start = InpDepth;
     }

//--- ZigZag was already calculated before
   if(prev_calculated > 0)
     {
      i = rates_total - 1;

      //--- searching for the third extremum from the last uncompleted bar
      while(extreme_counter < m_extRecalc && i > rates_total - 100)
        {
         res = ZigZagBuffer[i];
         if(res != 0.0)
            extreme_counter++;
         i--;
        }
      i++;
      start = i;

      //--- what type of exremum we search for
      if(LowMapBuffer[i] != 0.0)
        {
         curlow = LowMapBuffer[i];
         extreme_search = SEARCH_MODE_PEAK;
        }
      else
        {
         curhigh = HighMapBuffer[i];
         extreme_search = SEARCH_MODE_BOTTOM;
        }

      //--- clear indicator values
      for(i = start + 1; i < rates_total && !IsStopped(); i++)
        {
         ZigZagBuffer[i] = 0.0;
         LowMapBuffer[i] = 0.0;
         HighMapBuffer[i] = 0.0;
        }
     }

//--- searching for high and low extremes
   for(shift = start; shift < rates_total && !IsStopped(); shift++)
     {
      //--- low
      val = low[Lowest(low, InpDepth, shift)];
      if(val == last_low)
         val = 0.0;
      else
        {
         last_low = val;
         if((low[shift] - val) > InpDeviation * _Point)
            val = 0.0;
         else
           {
            for(back = 1; back <= InpBackstep; back++)
              {
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
      else
        {
         last_high = val;
         if((val - high[shift]) > InpDeviation * _Point)
            val = 0.0;
         else
           {
            for(back = 1; back <= InpBackstep; back++)
              {
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
   if(extreme_search == SEARCH_MODE_EXTREMUM)
     {
      last_low = 0.0;
      last_high = 0.0;
     }
   else
     {
      last_low = curlow;
      last_high = curhigh;
     }

//--- final selection of extreme points for ZigZag
   for(shift = start; shift < rates_total && !IsStopped(); shift++)
     {
      res = 0.0;
      switch(extreme_search)
        {
         case SEARCH_MODE_EXTREMUM:
            if(last_low == 0.0 && last_high == 0.0)
              {
               if(HighMapBuffer[shift] != 0)
                 {
                  last_high = high[shift];
                  last_high_pos = shift;
                  extreme_search = SEARCH_MODE_BOTTOM;
                  ZigZagBuffer[shift] = last_high;
                  res = 1;
                 }
               if(LowMapBuffer[shift] != 0.0)
                 {
                  last_low = low[shift];
                  last_low_pos = shift;
                  extreme_search = SEARCH_MODE_PEAK;
                  ZigZagBuffer[shift] = last_low;
                  res = 1;
                 }
              }
            break;

         case SEARCH_MODE_PEAK:
            if(LowMapBuffer[shift] != 0.0 && LowMapBuffer[shift] < last_low &&
               HighMapBuffer[shift] == 0.0)
              {
               ZigZagBuffer[last_low_pos] = 0.0;
               last_low_pos = shift;
               last_low = LowMapBuffer[shift];
               ZigZagBuffer[shift] = last_low;
               res = 1;
              }
            if(HighMapBuffer[shift] != 0.0 && LowMapBuffer[shift] == 0.0)
              {
               last_high = HighMapBuffer[shift];
               last_high_pos = shift;
               ZigZagBuffer[shift] = last_high;
               extreme_search = SEARCH_MODE_BOTTOM;
               res = 1;
              }
            break;

         case SEARCH_MODE_BOTTOM:
            if(HighMapBuffer[shift] != 0.0 && HighMapBuffer[shift] > last_high &&
               LowMapBuffer[shift] == 0.0)
              {
               ZigZagBuffer[last_high_pos] = 0.0;
               last_high_pos = shift;
               last_high = HighMapBuffer[shift];
               ZigZagBuffer[shift] = last_high;
              }
            if(LowMapBuffer[shift] != 0.0 && HighMapBuffer[shift] == 0.0)
              {
               last_low = LowMapBuffer[shift];
               last_low_pos = shift;
               ZigZagBuffer[shift] = last_low;
               extreme_search = SEARCH_MODE_PEAK;
              }
            break;

         default:
            return (rates_total);
        }
     }

//--- update and draw only on new bar
   if(prev_calculated != rates_total)
     {
      UpdateZigZagPivots(time);

      ObjectsDeleteAll(ChartID(), OBJECT_NAME_PREFIX);
      ClearLevels();

      DetectSupport(time, close);
      DetectResistance(time, close);

      RenderLevels();
      UpdateLevelPositions();
      if(InpDrawLabels)
         DrawLabels();
     }

//--- return value of prev_calculated for next call
   return (rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      UpdateLevelPositions();
      if(InpDrawLabels)
         DrawLabels();
     }
  }

//+------------------------------------------------------------------+
//|  Search for the index of the highest bar                         |
//+------------------------------------------------------------------+
int Highest(const double &array[], const int depth, const int start)
  {
   if(start < 0)
      return (0);

   double max = array[start];
   int index = start;

//--- start searching
   for(int i = start - 1; i > start - depth && i >= 0; i--)
     {
      if(array[i] > max)
        {
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
int Lowest(const double &array[], const int depth, const int start)
  {
   if(start < 0)
      return (0);

   double min = array[start];
   int index = start;

//--- start searching
   for(int i = start - 1; i > start - depth && i >= 0; i--)
     {
      if(array[i] < min)
        {
         index = i;
         min = array[i];
        }
     }

//--- return index of the lowest bar
   return (index);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateZigZagPivots(const datetime &time[])
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
   for(int i = start; i <= end; i++)
     {
      const double cur = ZigZagBuffer[i];
      if(cur == EMPTY_VALUE || cur == 0.0)
         continue;

      const datetime t = time[i];

      // first pivot
      if(m_zzCount == 0)
        {
         PushZZ(t, cur, i);
         m_lastZZPrice = cur;
         m_lastZZTime = t;
         m_lastZZDir = 0;
         continue;
        }

      const double last = m_zz[m_zzCount - 1].price;

      // If equal price, treat as update (avoid fake flips)
      int dir;
      if(cur > last)
         dir = 1;
      else
         if(cur < last)
            dir = -1;
         else
            dir = m_lastZZDir;

      // same direction (or not locked yet) → UPDATE last pivot
      if(dir == m_lastZZDir || m_lastZZDir == 0)
        {
         m_zz[m_zzCount - 1].price = cur;
         m_zz[m_zzCount - 1].time = t;
        }
      else
        {
         // direction flipped → PUSH new pivot
         PushZZ(t, cur, i);
        }

      m_lastZZDir = dir;
      m_lastZZPrice = cur;
      m_lastZZTime = t;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PushZZ(datetime t, double p, int s)
  {
// prevent duplicates
   if(m_zzCount > 0 && m_zz[m_zzCount - 1].time == t)
      return;

   if(m_zzCount < ZZ_MAX)
      m_zzCount++;
   else
     {
      // shift left
      for(int i = 0; i < ZZ_MAX - 1; i++)
         m_zz[i] = m_zz[i + 1];
     }

   m_zz[m_zzCount - 1].time = t;
   m_zz[m_zzCount - 1].price = p;
   m_zz[m_zzCount - 1].shift = s;

   int trend = 0;
   if(m_zzCount > 2)
     {
      const double p1 = m_zz[m_zzCount - 3].price;
      const double p2 = m_zz[m_zzCount - 2].price;
      const double p3 = p;

      if(p2 < p1 && p3 > p1)
        {
         trend = 1;
        }

      if(p2 > p1 && p3 < p1)
        {
         trend = -1;
        }
     }

   m_zz[m_zzCount - 1].trend = trend;
  }

//+------------------------------------------------------------------+
//| Detects support levels from low pivots                           |
//+------------------------------------------------------------------+
void DetectSupport(const datetime &time[], const double &close[])
  {
   const int total = ArraySize(time);
   const long chart_id = ChartID();

   if(m_zzCount < 2)
      return;

   for(int i = 1; i < m_zzCount - 1; i++)
     {
      const SZZPoint prev = m_zz[i - 1];
      const SZZPoint pivot = m_zz[i];

      long t1 = pivot.time;
      double level = pivot.price;
      long t2 = time[total - 1]; // default extend to last bar

      // Only low pivots (support)
      if(pivot.price > prev.price)
         continue;

      // Find first break below support
      for(int j = pivot.shift; j < ArraySize(time); j++)
        {
         if(close[j] < level)
           {
            t2 = time[j];
            break;
           }
        }

      const bool isOpen = t2 == time[total - 1];
      if(!InpDrawClosed && !isOpen)
         continue;

      const string type = "S";
      //if(t1 == m_zz[m_zzCount - 1].time)
      //continue;

      AddLevel(type, level, t1, t2, isOpen);
     }
  }

//+------------------------------------------------------------------+
//| Detects resistance levels from high pivots                       |
//+------------------------------------------------------------------+
void DetectResistance(const datetime &time[], const double &close[])
  {
   const int total = ArraySize(time);
   const long chart_id = ChartID();

   if(m_zzCount < 2)
      return;

   for(int i = 1; i < m_zzCount - 1; i++)
     {
      const SZZPoint prev = m_zz[i - 1];
      const SZZPoint pivot = m_zz[i];

      long t1 = pivot.time;
      double level = pivot.price;
      long t2 = time[total - 1];

      // Only high pivots (resistance)
      if(pivot.price < prev.price)
         continue;

      // Find first break above resistance
      for(int j = pivot.shift; j < ArraySize(time); j++)
        {
         if(close[j] > level)
           {
            t2 = time[j];
            break;
           }
        }

      const bool isOpen = t2 == time[total - 1];
      if(!InpDrawClosed && !isOpen)
         continue;

      const string type = "R";
      //if(t1 == m_zz[m_zzCount - 1].time)
      //continue;

      AddLevel(type, level, t1, t2, isOpen);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddLevel(string type, double price, datetime t1, datetime t2,
              bool isOpen)
  {
   int i = ArraySize(m_extLevels);
   ArrayResize(m_extLevels, i + 1);

   m_extLevels[i].type = type;
   m_extLevels[i].price = price;
   m_extLevels[i].t1 = t1;
   m_extLevels[i].t2 = t2;
   m_extLevels[i].is_open = isOpen;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenderLevels()
  {
   long chart_id = ChartID();

   for(int i = 0; i < ArraySize(m_extLevels); i++)
     {
      SSNRStyle style =
         (m_extLevels[i].type == "S") ? m_extSupportStyle : m_extResistanceStyle;

      DrawLevel(chart_id, m_extLevels[i].type, m_extLevels[i].price, m_extLevels[i].t1,
                m_extLevels[i].t2, style, m_extLevels[i].is_open);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLevel(long chart_id, string type, double level, datetime t1,
               datetime t2, SSNRStyle &style, bool isOpen)
  {
// --- Unique line name ---
   const string prefix = OBJECT_NAME_PREFIX + "_" + IntegerToString(t1);
   const string status = isOpen ? "O" : "C";
   string line_name = prefix + "_" + type + status + "L";

// --- Draw line ---
   if(ObjectFind(chart_id, line_name) < 0)
      ObjectCreate(chart_id, line_name, OBJ_TREND, 0, t1, level, t2, level);

   if(!isOpen)
     {
      style.line.line_width = 1;
      style.line.line_style = STYLE_DOT;
     }
   else
     {
      style.line.line_width = 2;
     }

   ApplyLineStyle(chart_id, line_name, style);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyLineStyle(long chart_id, string name, SSNRStyle &style)
  {
   ObjectSetInteger(chart_id, name, OBJPROP_COLOR, style.line.line_color);
   ObjectSetInteger(chart_id, name, OBJPROP_WIDTH, style.line.line_width);
   ObjectSetInteger(chart_id, name, OBJPROP_STYLE, style.line.line_style);
   ObjectSetInteger(chart_id, name, OBJPROP_SELECTABLE, style.line.is_selectable);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateLevelPositions()
  {
   long chart_id = ChartID();

   for(int i = 0; i < ArraySize(m_extLevels); i++)
     {
      datetime textTime;
      double textPrice;

      if(m_extLevels[i].is_open)
        {
         textTime = m_extLevels[i].t2; // right edge
         textPrice = m_extLevels[i].price;
        }
      else
        {
         textTime =
            m_extLevels[i].t1 + (m_extLevels[i].t2 - m_extLevels[i].t1) / 2; // midpoint
         textPrice = m_extLevels[i].price;
        }

      int x, y;
      if(ChartTimePriceToXY(chart_id, 0, textTime, textPrice, x, y))
        {
         m_extLevels[i].x = x;
         m_extLevels[i].y = y;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLabels()
  {
   long chart_id = ChartID();

   for(int i = 0; i < ArraySize(m_extLevels); i++)
     {

      string prefix = OBJECT_NAME_PREFIX + "_" + IntegerToString(m_extLevels[i].t1);
      string status = m_extLevels[i].is_open ? "O" : "C";
      string name = prefix + "_" + m_extLevels[i].type + status + "T";

      if(ObjectFind(chart_id, name) < 0)
         ObjectCreate(chart_id, name, OBJ_LABEL, 0, 0, 0);

      ObjectSetInteger(chart_id, name, OBJPROP_XDISTANCE, m_extLevels[i].x);
      ObjectSetInteger(chart_id, name, OBJPROP_YDISTANCE, m_extLevels[i].y);

      //--- Text ---
      string text = m_extLevels[i].type + " | " + PeriodToString(_Period);
      ObjectSetString(chart_id, name, OBJPROP_TEXT, text);

      SSNRStyle style =
         (m_extLevels[i].type == "S") ? m_extSupportStyle : m_extResistanceStyle;

      style.text.anchor = (m_extLevels[i].type == "S" && !m_extLevels[i].is_open)
                          ? ANCHOR_UPPER
                          : ANCHOR_LOWER;

      if(m_extLevels[i].is_open)
        {
         style.text.anchor = ANCHOR_LEFT;
         style.text.font_size = (int)(style.text.font_size * 0.8);
        }

      ApplyTextStyle(chart_id, name, style);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyTextStyle(long chart_id, string name, SSNRStyle &style)
  {
   ObjectSetString(chart_id, name, OBJPROP_FONT, style.text.font_name);
   ObjectSetInteger(chart_id, name, OBJPROP_FONTSIZE, style.text.font_size);
   ObjectSetInteger(chart_id, name, OBJPROP_COLOR, style.text.text_color);
   ObjectSetInteger(chart_id, name, OBJPROP_ANCHOR, style.text.anchor);
   ObjectSetInteger(chart_id, name, OBJPROP_SELECTABLE, style.text.is_selectable);
  }

void ClearLevels() { ArrayResize(m_extLevels, 0); }

//+------------------------------------------------------------------+
//| Converts MQL5 timeframe constant to string like "M5", "H1"       |
//+------------------------------------------------------------------+
string PeriodToString(ENUM_TIMEFRAMES period)
  {
   switch(period)
     {
      case PERIOD_M1:
         return "M1";
      case PERIOD_M2:
         return "M2";
      case PERIOD_M3:
         return "M3";
      case PERIOD_M4:
         return "M4";
      case PERIOD_M5:
         return "M5";
      case PERIOD_M6:
         return "M6";
      case PERIOD_M10:
         return "M10";
      case PERIOD_M12:
         return "M12";
      case PERIOD_M15:
         return "M15";
      case PERIOD_M20:
         return "M20";
      case PERIOD_M30:
         return "M30";
      case PERIOD_H1:
         return "H1";
      case PERIOD_H2:
         return "H2";
      case PERIOD_H3:
         return "H3";
      case PERIOD_H4:
         return "H4";
      case PERIOD_H6:
         return "H6";
      case PERIOD_H8:
         return "H8";
      case PERIOD_H12:
         return "H12";
      case PERIOD_D1:
         return "D1";
      case PERIOD_W1:
         return "W1";
      case PERIOD_MN1:
         return "MN1";
      default:
         return "Unknown";
     }
  }
//+------------------------------------------------------------------+
