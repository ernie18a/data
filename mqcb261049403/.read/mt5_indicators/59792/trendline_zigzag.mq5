//+------------------------------------------------------------------+
//|                                         Trendline Channel Zigzag |
//|                                            Copyright 2025, phade |
//+------------------------------------------------------------------+
#property copyright "phade"
#property link      "https://forge.mql5.io"
#property description "Continuous trendlines from channel pivot to current extreme"
#property version   "1.2"

#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots 6

#property indicator_label1  "Pivot Point A"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDarkGray
#property indicator_width1  1
#property indicator_label2  "Pivot Point B"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDarkGray
#property indicator_width2  1
#property indicator_label3  "Middle"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSlateGray
#property indicator_width3  1
#property indicator_label4  "High Shifts"
#property indicator_type4   DRAW_LINE
#property indicator_style4  STYLE_DOT
#property indicator_color4  clrSlateGray
#property indicator_width4  1
#property indicator_label5  "Low Shifts"
#property indicator_type5   DRAW_LINE
#property indicator_style5  STYLE_DOT
#property indicator_color5  clrSlateGray
#property indicator_width5  1
#property indicator_label6 "Trendline Zigzag"
#property indicator_type6  DRAW_ZIGZAG
#property indicator_color6 clrLightGray
#property indicator_width6 1


enum ENUM_PIVOT_MODE
  {

   trendline = 0, // Trendline
   active_repaint = 1 // Active Repainting
  };



input int iPeriods = 20;                // Channel period
input int zigzag_depth = 10;            // Depth (flat bars required)
input ENUM_PIVOT_MODE zigzag_mode = 0;  // Zigzag mode
input bool pivot_correction = true;     // Correct invalid pivots
input int volume_lookback = 3;          // Volume average lookback period
input double volume_multiplier = 0.4;   // Tick volume > avg at pivot
input bool use_ma_filter = true;        // Use MA filter for pivots
input int ma_period = 200;              // MA Period (EMA)

// Buffers
double high_shifts[];
double low_shifts[];
double arr_buf_up[];
double arr_buf_down[];
double middle_band[];
double ZigzagStart[];
double ZigzagEnd[];
double rsi[];
double ma[];

int state = 0;
int rsi_handle = INVALID_HANDLE;
int ma_handle = INVALID_HANDLE;

int rsi_period = 14;





//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// Indicator buffers mapping
   SetIndexBuffer(0, arr_buf_up, INDICATOR_DATA);
   SetIndexBuffer(1, arr_buf_down, INDICATOR_DATA);
   SetIndexBuffer(2, middle_band, INDICATOR_DATA);
   SetIndexBuffer(3, high_shifts, INDICATOR_DATA);
   SetIndexBuffer(4, low_shifts, INDICATOR_DATA);
   SetIndexBuffer(5, ZigzagStart, INDICATOR_DATA);
   SetIndexBuffer(6, ZigzagEnd, INDICATOR_DATA);
   SetIndexBuffer(7, rsi, INDICATOR_CALCULATIONS);
   SetIndexBuffer(8, ma, INDICATOR_CALCULATIONS);

   PlotIndexSetInteger(0, PLOT_ARROW, 236);
   PlotIndexSetInteger(1, PLOT_ARROW, 238);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 10);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);

   rsi_handle = iRSI(_Symbol, 0, rsi_period, PRICE_CLOSE);
   ma_handle = iMA(_Symbol, 0, ma_period, 0, MODE_EMA, PRICE_CLOSE);

   return(INIT_SUCCEEDED);
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
   int depth = zigzag_depth;
   int start = (prev_calculated == 0) ? MathMax(iPeriods, ma_period) + 1 : prev_calculated - (depth + 1);

   static int lastUpIndex = -1;  // last low pivot index (where up marker draws)
   static int lastDownIndex = -1; // last high pivot index (where down marker draws)
   static double lastSwingLow = -1;
   static double lastSwingHigh = -1;
   static double highest;
   static double lowest;
   static double cur_highest;
   static double cur_lowest;

   int to_copy = (prev_calculated > 0) ? (rates_total - prev_calculated + 1) : rates_total;

   if(CopyBuffer(rsi_handle, 0, 0, to_copy, rsi) < 0)
      return rates_total;

   if(CopyBuffer(ma_handle, 0, 0, to_copy, ma) < 0)
      return rates_total;


   for(int i = start; i < rates_total; i++)
     {
      highest = high[ArrayMaximum(high, i - iPeriods + 1, iPeriods)];
      lowest = low[ArrayMinimum(low, i - iPeriods + 1, iPeriods)];

      high_shifts[i] = highest;
      low_shifts[i] = lowest;
      middle_band[i] = (highest + lowest) / 2.0;
     }


   for(int i = start; i < rates_total; i++)
     {
      arr_buf_up[i] = EMPTY_VALUE;
      arr_buf_down[i] = EMPTY_VALUE;
      ZigzagStart[i] = EMPTY_VALUE;
      ZigzagEnd[i] = EMPTY_VALUE;
     }

   bool upwardsDir = false, downwardsDir = false;
   bool leg_search = true;

   for(int i = rates_total-1-(depth+1); i >= start; i--)
     {
      if(state != 1) // Searching for swing low (bottom pivot)
        {

         if(low[i] < lastSwingLow)
           {
            lastSwingLow = low[i]; // continuous update for lastSwingLow
            lastUpIndex = i;
           }

         // --- channel shifted downwards into flat channel (support zone)
         if(low_shifts[i-1] > low_shifts[i] && low_shifts[i] == low_shifts[i+depth+1])
           {
            // RSI filter
            bool rsi_validated = rsi[i] < 50; // rsi sell zone

            // Volume filter
            bool volume_validated = VolumeCheck(i, tick_volume);

            // MA filter: close below EMA
            bool ma_validated = !use_ma_filter || close[i] < ma[i];

            if(rsi_validated && volume_validated && ma_validated)
              {
               state = 1;
               upwardsDir = true;
               leg_search = false;

               lastUpIndex = i; // last low pivot index
               arr_buf_up[i] = low_shifts[lastUpIndex];
               ZigzagStart[i] = low[lastUpIndex];
               lastSwingLow = low[lastUpIndex];


               if(lastUpIndex >= 0)
                 {
                  for(int j = i; j > lastUpIndex; j--)
                    {
                     arr_buf_up[j] = EMPTY_VALUE;
                     ZigzagStart[j] = EMPTY_VALUE;
                    }
                 }
              }
           }
        }
      else
        {
         leg_search = true;
        }

      if(state != 2) // Searching for swing high (top pivot)
        {

         if(high[i] > lastSwingHigh)
           {
            lastSwingHigh= high[i]; // continuous update for lastSwingHigh
            lastDownIndex = i;
           }


         // --- channel shifted upwards into flat channel (resistance zone)
         if(high_shifts[i-1] < high_shifts[i] && high_shifts[i] == high_shifts[i+depth+1])
           {
            // RSI filter
            bool rsi_validated = rsi[i] > 50; // rsi buy zone

            // Volume filter
            bool volume_validated = VolumeCheck(i, tick_volume);

            // MA filter: close above EMA
            bool ma_validated = !use_ma_filter || close[i] > ma[i];

            if(rsi_validated && volume_validated && ma_validated)
              {
               state = 2;

               downwardsDir = true;
               leg_search = false;

               lastDownIndex = i; // last high pivot index
               arr_buf_down[i] = high_shifts[lastDownIndex];
               ZigzagEnd[i] = high[lastDownIndex];
               lastSwingHigh = high[lastDownIndex];

               if(lastDownIndex >= 0)
                 {
                  for(int j = i; j > lastDownIndex; j--)
                    {
                     arr_buf_down[j] = EMPTY_VALUE;
                     ZigzagEnd[j] = EMPTY_VALUE;
                    }
                 }
              }
           }
        }
      else
        {
         leg_search = true;
        }
     }

   // leg validation
   if(pivot_correction)
     {
      for(int i = start; i < rates_total; i++)
        {
         if(state == 1)
           {
            if(lastSwingLow >= 0 && low[i] < lastSwingLow)
              {
               if(lastUpIndex >= 0)
                 {
                  for(int j = lastUpIndex; j < i; j++)
                    {
                     arr_buf_up[j] = EMPTY_VALUE;
                     ZigzagStart[j] = EMPTY_VALUE;
                    }
                  state = 2; // Switch to low swing search
                 }
              }
           }

         if(state == 2)
           {
            if(lastSwingHigh >= 0 && high[i] > lastSwingHigh)
              {
               if(lastDownIndex >= 0)
                 {
                  for(int j = lastDownIndex; j < i; j++)
                    {
                     arr_buf_down[j] = EMPTY_VALUE;
                     ZigzagEnd[j] = EMPTY_VALUE;
                    }
                  state = 1; // Switch to high swing search
                 }
              }
           }
        }
     }

   // local highs and local lows for dynamic trendline engine
   if(zigzag_mode == trendline)
     {
      for(int i = start; i < rates_total; i++)
        {
         cur_highest = high[ArrayMaximum(high, i - 10, 10)];
         cur_lowest = low[ArrayMinimum(low, i - 10, 10)];

         if(leg_search)
           {
            if((state == 0 || state == 1) && !downwardsDir)
              {

               ZigzagEnd[i] = cur_lowest;
               ZigzagEnd[i-1] = EMPTY_VALUE;
              }
            if((state == 0 || state == 2) && !upwardsDir)
              {
               ZigzagStart[i] = cur_highest;
               ZigzagStart[i-1] = EMPTY_VALUE;
              }
           }
        }
     }
   else if(zigzag_mode == active_repaint)
     {
      if((state == 0 || state == 1) && !downwardsDir)
         ZigzagEnd[lastUpIndex] = lastSwingLow;

      if((state == 0 || state == 2) && !upwardsDir)
         ZigzagEnd[lastDownIndex] = lastSwingHigh;
     }
  

   return rates_total;
  }



//+------------------------------------------------------------------+
//|   Function to validate volume (trading participation)            |
//+------------------------------------------------------------------+
bool VolumeCheck(int pos, const long &tick_volume[])
  {

   bool volume_validated = true;

   if(volume_multiplier > 0)
     {
      long avg_vol = 0;
      for(int v = pos; v > pos - volume_lookback && v >= 0; v--)
         avg_vol += tick_volume[v];

      avg_vol /= MathMin(volume_lookback, pos + 1);
      if(tick_volume[pos] < avg_vol * volume_multiplier)
         volume_validated = false;
     }

   return volume_validated;
  }

//+------------------------------------------------------------------+
//| Cleanup                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }
