//+------------------------------------------------------------------+
//| Statistical Zigzag with standard deviation                       |
//+------------------------------------------------------------------+
#property version   "1.00"
#property copyright "phade"
#property link "https://www.mql5.com/en/users/phade"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Adaptive ZigZag"
#property indicator_type1   DRAW_COLOR_SECTION
#property indicator_color1  clrBeige, clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

input int    Length        = 100;   // Length
input double VolMultiplier = 4.0;   // Volatility multiplier

double ZigZagBuffer[];
double ColorBuffer[];
double StdDevBuffer[];
int    std_handle = INVALID_HANDLE;

struct SwingPoint
  {
   int               index;
   double            value;
   int               dir;          // 1=up, -1=down
  };
SwingPoint swings[];

double lastSwingValue = 0.0;
int    lastSwingIndex = -1;
int    lastSwingDir   = 0;
string trendLineName  = "_statistical_level";

//+------------------------------------------------------------------+
//| High search                                                      |
//+------------------------------------------------------------------+
int Highest(const double &arr[], int end, int start)
  {
   if(start < 0 || end >= ArraySize(arr) || start >= end)
      return -1;
   double mx = arr[start + 1];
   int    idx = start + 1;
   for(int i = start + 1; i <= end; i++)
      if(arr[i] > mx)
        {
         mx = arr[i];
         idx = i;
        }
   return idx;
  }

//+------------------------------------------------------------------+
//|  Low search                                                      |
//+------------------------------------------------------------------+
int Lowest(const double &arr[], int end, int start)
  {
   if(start < 0 || end >= ArraySize(arr) || start >= end)
      return -1;
   double mn = arr[start + 1];
   int    idx = start + 1;
   for(int i = start + 1; i <= end; i++)
      if(arr[i] < mn)
        {
         mn = arr[i];
         idx = i;
        }
   return idx;
  }

//+------------------------------------------------------------------+
//| Draw horizontal projection line                                  |
//+------------------------------------------------------------------+
void DrawTrendLine(const datetime &time[], int start_idx,
                   double start_price, int rates_total)
  {
   ObjectDelete(0, trendLineName);
   datetime future = time[rates_total - 1] + 10 * PeriodSeconds();
   if(ObjectCreate(0, trendLineName, OBJ_TREND, 0,
                   time[start_idx], start_price,
                   future, start_price))
     {
      ObjectSetInteger(0, trendLineName, OBJPROP_COLOR, clrSilver);
      ObjectSetInteger(0, trendLineName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, trendLineName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, trendLineName, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, trendLineName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, trendLineName, OBJPROP_BACK, true);
     }
  }

//+------------------------------------------------------------------+
//| Find first swing in oldest Length bars                           |
//+------------------------------------------------------------------+
bool CalStartSwing(const double &high[], const double &low[])
  {
   double maxHigh = -DBL_MAX, minLow = DBL_MAX;
   int    maxIdx = -1,       minIdx = -1;

   for(int i = 0; i < Length; i++)
     {
      if(high[i] > maxHigh)
        {
         maxHigh = high[i];
         maxIdx = i;
        }
      if(low[i]  < minLow)
        {
         minLow  = low[i];
         minIdx = i;
        }
     }

   if(maxIdx == -1 && minIdx == -1)
      return false;

   if(maxIdx > minIdx)
     {
      lastSwingValue = maxHigh;
      lastSwingIndex = maxIdx;
      lastSwingDir = 1;
      SwingPoint sp;
      sp.index = maxIdx;
      sp.value = maxHigh;
      sp.dir = 1;
      ArrayResize(swings, 1);
      swings[0] = sp;
      ZigZagBuffer[maxIdx] = maxHigh;
      ColorBuffer[maxIdx] = 0;
      return true;
     }
   else
     {
      lastSwingValue = minLow;
      lastSwingIndex = minIdx;
      lastSwingDir = -1;
      SwingPoint sp;
      sp.index = minIdx;
      sp.value = minLow;
      sp.dir = -1;
      ArrayResize(swings, 1);
      swings[0] = sp;
      ZigZagBuffer[minIdx] = minLow;
      ColorBuffer[minIdx] = 1;
      return true;
     }
  }

//+------------------------------------------------------------------+
//| Initializer                                                      |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ZigZagBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ColorBuffer,  INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, StdDevBuffer, INDICATOR_CALCULATIONS);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "Adaptive ZigZag SD");

   std_handle = iStdDev(NULL, 0, Length, 0, MODE_SMA, PRICE_CLOSE);
   if(std_handle == INVALID_HANDLE)
      return(INIT_FAILED);

   ArrayResize(swings, 0);
   
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Deinit                                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0, trendLineName);
   if(std_handle != INVALID_HANDLE)
      IndicatorRelease(std_handle);
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
   if(rates_total <= Length + 1)
      return(rates_total);
      
   int to_copy = (prev_calculated < 0 || prev_calculated > rates_total) ? rates_total : rates_total - prev_calculated + 1;
   
   if(CopyBuffer(std_handle, 0, 0, to_copy, StdDevBuffer) <= 0)
      return(rates_total);

   if(prev_calculated == 0)
     {
      ArrayResize(swings, 0);
      ArrayInitialize(ZigZagBuffer, EMPTY_VALUE);
      lastSwingDir = 0;
      lastSwingIndex = -1;
      lastSwingValue = 0.0;
      if(!CalStartSwing(high, low))
         return(rates_total);
     }
   else
     {
      for(int i = lastSwingIndex + 1; i < rates_total; i++)
         ZigZagBuffer[i] = EMPTY_VALUE;
     }

   int newest = rates_total - 1;
   int start_from = lastSwingIndex + 1;

   for(int i = start_from; i <= newest; i++)
     {
      double thr = StdDevBuffer[i] * VolMultiplier;
      
      if(thr <= 0)
         continue;

      // ----- NEW HIGH (must be after last swing) ----------------------
      if(high[i] - lastSwingValue > thr)
        {
         int extremum = Highest(high, i, lastSwingIndex);  // +1 built in
         if(extremum == -1)
            continue;

         if(lastSwingDir == 1)  // extend
           {
            ZigZagBuffer[lastSwingIndex] = EMPTY_VALUE;
            lastSwingValue = high[extremum];
            lastSwingIndex = extremum;
            swings[ArraySize(swings)-1].index = extremum;
            swings[ArraySize(swings)-1].value = high[extremum];
           }
         else  // reverse
           {
            lastSwingValue = high[extremum];
            lastSwingIndex = extremum;
            lastSwingDir = 1;
            SwingPoint sp;
            sp.index = extremum;
            sp.value = high[extremum];
            sp.dir = 1;
            int n = ArraySize(swings);
            ArrayResize(swings, n+1);
            swings[n] = sp;
           }
         ZigZagBuffer[extremum] = high[extremum];
         ColorBuffer[extremum] = 0;
         DrawTrendLine(time, extremum, high[extremum], rates_total);
        }
      // ----- NEW LOW --------------------------------------------------
      else
         if(lastSwingValue - low[i] > thr)
           {
            int extremum = Lowest(low, i, lastSwingIndex);
            if(extremum == -1)
               continue;

            if(lastSwingDir == -1)  // extend
              {
               ZigZagBuffer[lastSwingIndex] = EMPTY_VALUE;
               lastSwingValue = low[extremum];
               lastSwingIndex = extremum;
               swings[ArraySize(swings)-1].index = extremum;
               swings[ArraySize(swings)-1].value = low[extremum];
              }
            else  // reverse
              {
               lastSwingValue = low[extremum];
               lastSwingIndex = extremum;
               lastSwingDir = -1;
               SwingPoint sp;
               sp.index = extremum;
               sp.value = low[extremum];
               sp.dir = -1;
               int n = ArraySize(swings);
               ArrayResize(swings, n+1);
               swings[n] = sp;
              }
            ZigZagBuffer[extremum] = low[extremum];
            ColorBuffer[extremum] = 1;
            DrawTrendLine(time, extremum, low[extremum], rates_total);
           }
     }

   if(ArraySize(swings) > 0)
     {
      SwingPoint last = swings[ArraySize(swings)-1];
      DrawTrendLine(time, last.index, last.value, rates_total);
     }

   return(rates_total);
  }
