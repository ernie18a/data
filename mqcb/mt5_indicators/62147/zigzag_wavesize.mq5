//+------------------------------------------------------------------+
//|                                              ZigZag WaveSize.mq5 |
//|                                    Copyright 2025, by Ivan Butko |
//|                        https://www.mql5.com/ru/users/capitalplus |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2025, iboot@yandex.ru, https://t.me/bootelega"
#property link      "https://www.mql5.com/ru/users/capitalplus/seller"
#property description "ZigZag WaveSize - a modified standard ZigZag indicator with the addition "
#property description "of information about the wavelength in points."
#property description "+ Functional levels have been added to the new version"
#property version   "1.4"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrGray

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+

// Main settings
input group " -------------------- MAIN ---------------------------------------- ";

enum WORK_MODE
  {
    Original,                         // Original ZigZag
    Trend_size,                       // Trend size ZigZag
  };
input WORK_MODE Work_mode = Original; // Mode selection

input group " ---------- Settings for Original mode ---------------------------------------- ";

input int    InpDepth     = 12;       // Depth 
input int    InpDeviation = 5;        // Deviation 
input int    InpBackstep  = 3;        // Backstep 


input group " --------- Settings for Trend size mode ---------------------------------------- ";

enum TREND_SIZE_MODE
  {
    Manual,                                              // Manual 
    ATR,                                                 // ATR-based 
  };
input TREND_SIZE_MODE Trend_size_mode = Manual;          // Calculate  
input int             Trend           = 150;             // Minimum ZigZag line size in points
input int             ATR_period      = 20;              // ATR period
input ENUM_TIMEFRAMES ATR_TF          = PERIOD_CURRENT;  // ATR timeframe
input double          ATR_K           = 1.0;             // ATR size multiplier

// Line settings
input group " -------------------- LINES ---------------------------------------- ";
enum MODE
  {
    Standard,                                 // Standard 
    Structural,                               // Structural 
    Disable,                                  // Disable 
  };
input MODE Mode = Standard;                   // Draw mode
input int   Lines_count       = 10;           // Number of lines to draw
input color Lines_color_UP    = clrLightBlue; // Color of up lines
input color Lines_color_DN    = clrCrimson;   // Color of down lines
input int   Lines_width_UP    = 2;            // Width of up lines
input int   Lines_width_DN    = 2;            // Width of down lines

// Level settings
input group " -------------------- LEVELS ---------------------------------------- ";

input bool  Draw_levels         = true;          // Draw levels at reversal points
input int   Levels_count        = 5;             // Number of most recent levels to draw
input color Levels_color_UP     = clrLightBlue;  // Color for resistance levels
input color Levels_color_DN     = clrLightCoral; // Color for support levels
input int   Levels_width        = 2;             // Width of level lines
input bool  Levels_ray          = false;         // Ray
enum LEVELS_TYPE {
       RAY ,            // Segment
       HORIZONTAL       // Horizont     
};
input LEVELS_TYPE Levels_type = RAY;                // Type of level drawing
enum LEVELS_FILTER {
       LIQUID_LEVELS,   // Liquid (not broken) 
       ALL_LEVELS       // All draw       
};
input LEVELS_FILTER Levels_filter = LIQUID_LEVELS;  // Level filtering mode
input int   Levels_break_buffer = 5;                // Filter for breakout detection (points)

// Label settings
input group " -------------------- LABELS ---------------------------------------- ";

input bool  Draw_labels         = true;         // Draw labels at reversal points
input int   Labels_count        = 10;           // Number labels to draw
input color Labels_color        = clrGray;      // Color 
input int   Labels_font_size    = 10;           // Font size 
input bool  Labels_centered     = false;        // Center labels on price level

// Average/Median settings
input group " -------------------- AVG/MED ---------------------------------------- ";

input bool  Draw_avg            = true;         // Draw average wavelength
input bool  Draw_med            = true;         // Draw median wavelength
input int   Lines_count_avg_med = 100;          // Number of lines to calculate average length
input int   Font_size_avg       = 10;           // Average font size
input color Font_color_avg      = clrSteelBlue; // Average font color
input int   Font_size_med       = 10;           // Median font size
input color Font_color_med      = clrTeal;      // Median font color

// Alert settings
input group " ------------------ ALERT TYPES ---------------------------------------- ";

enum ALERT_BOS {
    Alert_Bos_disable,  // Disable
    Alert_Bos_enable    // Enable
};
input ALERT_BOS Alert_BoS = Alert_Bos_disable;                 // (BoS) Break of Structure 

enum ALERT_CHOCH {
    Alert_ChoCH_disable,  // Disable
    Alert_ChoCH_enable    // Enable
};
input ALERT_CHOCH Alert_ChoCH = Alert_ChoCH_disable;           // (CHoCH) Change of Character 

enum ALERT_BREAKOUT {
    Alert_breakout_disable,  // Disable
    Alert_breakout_enable    // Enable
};
input ALERT_BREAKOUT Alert_breakout = Alert_breakout_disable;  // Breakout 

enum ALERT_TYPES {
    Alert_reversal_disable,  // Disable
    Alert_reversal_enable    // Enable
};
input ALERT_TYPES Alert_reversal = Alert_reversal_disable;     // Reverses


input bool Push_use  = false;            // Enable push notifications
input bool Sound_use = false;            // Enable sound alerts
input string Sound_file = "alert.wav";   // Sound file
input bool Mail_use  = false;            // Enable email alerts
input string Mail_subject = "MT notif";  // Email subject

// Cleanup settings
input group " -------------------- CLEANUP ---------------------------------------- ";

enum delete_obj
  {
    Delete,
    Keep,
  };
input delete_obj OnDeinit_delete_obj = Delete; // Objects on the chart when deinitialized

//---- indicator buffers
double ExtZigzagBuffer[];
double ExthighBuffer[];
double ExtlowBuffer[];

//--- globals
string alert_text, last_mode, alert_mode = "", last_alert_mode = "", alert_breakout_mode = "", last_alert_breakout_mode = "", last_size = "";
double last_buf, cur_buf;
int    ExtLevel=3; // recounting's depth of extremums
datetime t, t_last_high, t_last_low;
int n;
string last_zig;
bool alert_breakout_flag = false;

// Variables for trend size ZigZag
int atr_handle;
double atr[];
double trend;
double P;
double cur_size;
double ext;
double cur_low = 0, cur_high = 0, last_high[2], last_low[2];
string state = "";
datetime cur_time;
int cur_time_i;
datetime last_i_time = 0;  // Time of last vertex update

// Variables for alerts
string currentTrendDirectionForAlerts = ""; // Current trend direction for alerts
bool bos_alert_flag = false;               // Flag for BoS alert
bool choch_alert_flag = false;             // Flag for ChoCH alert

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {    
    if (Work_mode == Original)
      {
         if(InpBackstep>=InpDepth)
           {
            Print("Backstep cannot be greater or equal to Depth");
            return(INIT_FAILED);
           }
      //---- indicator buffers
         SetIndexBuffer(0,ExtZigzagBuffer);
         SetIndexBuffer(1,ExthighBuffer,INDICATOR_CALCULATIONS);
         SetIndexBuffer(2,ExtlowBuffer,INDICATOR_CALCULATIONS);
         PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
      //---- indicator short name
         IndicatorSetString(INDICATOR_SHORTNAME,"ZigZag("+string(InpDepth)+","+string(InpDeviation)+","+string(InpBackstep)+")");
      }
    if (Work_mode == Trend_size)
      {
        //--- indicator buffers mapping
        SetIndexBuffer(0,ExtZigzagBuffer);
        SetIndexBuffer(1,ExthighBuffer,INDICATOR_CALCULATIONS);
        SetIndexBuffer(2,ExtlowBuffer,INDICATOR_CALCULATIONS);
        PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
        //--- set accuracy
        IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
        //--- name for DataWindow and indicator subwindow label
        string short_name=StringFormat("ZigZag Trend(%d)",Trend);
        IndicatorSetString(INDICATOR_SHORTNAME,short_name);
        P = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
        // Create ATR handle
        if(Trend_size_mode == ATR)
          {
            atr_handle = iATR(NULL, ATR_TF, ATR_period);
            if(atr_handle == INVALID_HANDLE)
              {
                Print("Failed to create ATR handle");
                return(INIT_FAILED);
              }
          }
      }
    ArraySetAsSeries(ExtZigzagBuffer, true);
    ArraySetAsSeries(ExthighBuffer, true);
    ArraySetAsSeries(ExtlowBuffer, true);
    // Delete objects if reinitialization
    int total = ObjectsTotal(0);
    // Iterate objects from the end
    for(int i = total-1; i >= 0; i--)
      {
       string name = ObjectName(0, i);
       if(StringFind(name, "ZigZag", 0) == 0) // Check name prefix
         {
          if(!ObjectDelete(0, name))
             Print("Error deleting object: ", name);
         }
      }
    //---- initialization done
    return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
    if(rates_total < 100) return(0);
    // Set indexing as series
    ArraySetAsSeries(time, true);
    ArraySetAsSeries(open, true);
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);    
    int bars = iBars(NULL, PERIOD_CURRENT);
// ------------------ Original ZigZag ------------------
    if (Work_mode == Original)
      {
         int    i,limit,counterZ,whatlookfor=0;
         int    back,pos,lasthighpos=0,lastlowpos=0;
         double extremum;
         double curlow=0.0,curhigh=0.0;
         static double lasthigh=0.0;
         static double lastlow=0.0;
         n = 0;
      //--- check for history and inputs
         if(rates_total<InpDepth || InpBackstep>=InpDepth)
            return(0);
      //--- first calculations
        if(prev_calculated==0)
               limit = InitializeAll(rates_total);
         else
           {
            //--- find first extremum in the depth ExtLevel or 100 last bars
            i=counterZ=0;
            while(counterZ<ExtLevel && i<100)
              {
               if(ExtZigzagBuffer[i]!=0.0)
                  counterZ++;
               i++;
              }
            //--- no extremum found - recounting all from begin
            if(counterZ==0)
               limit=InitializeAll(rates_total);
            else
              {
               //--- set Start position to found extremum position
               limit=i-1;
               //--- what kind of extremum?
               if(ExtlowBuffer[i]!=0.0)
                 {
                  //--- low extremum
                  curlow=ExtlowBuffer[i];
                  lastlow = curlow;
                  //--- will look for the next high extremum
                  whatlookfor=1;
                 }
               else
                 {
                  //--- high extremum
                  curhigh=ExthighBuffer[i];
                  lasthigh = curhigh;
                  //--- will look for the next low extremum
                  whatlookfor=-1;
                 }
               //--- clear the rest data
               for(i=limit-1; i>=0; i--)
                 {
                  ExtZigzagBuffer[i]=0.0;
                  ExtlowBuffer[i]=0.0;
                  ExthighBuffer[i]=0.0;
                 }
              }
           }
      //--- main loop
         for(i = limit; i >= 0; i--)
           {
             t = time[i];
             ObjectDelete(0, "ZigZag " + TimeToString(t));
           }
         for(i=limit; i>=0; i--)
           {
            //--- find lowest low in depth of bars
            int lowest_idx = ArrayMinimum(low, i, InpDepth);
            extremum = low[lowest_idx];
            //--- this lowest has been found previously
            if(extremum==lastlow)
               extremum=0.0;
            else
              {
               //--- new last low
               lastlow=extremum;
               //--- discard extremum if current low is too high
               if(low[i]-extremum>InpDeviation*Point())
                  extremum=0.0;
               else
                 {
                  //--- clear previous extremums in backstep bars
                  for(back=1; back<=InpBackstep && i-back>=0; back++)
                    {
                     pos=i-back;
                     if(ExtlowBuffer[pos]!=0 && ExtlowBuffer[pos]>extremum)
                        ExtlowBuffer[pos]=0.0;
                    }
                 }
              }
            //--- found extremum is current low
            if(low[i]==extremum)
               ExtlowBuffer[i]=extremum;
            else
               ExtlowBuffer[i]=0.0;
            //--- find highest high in depth of bars
            int highest_idx = ArrayMaximum(high, i, InpDepth);
            extremum = high[highest_idx];
            //--- this highest has been found previously
            if(extremum==lasthigh)
               extremum=0.0;
            else
              {
               //--- new last high
               lasthigh=extremum;
               //--- discard extremum if current high is too low
               if(extremum-high[i]>InpDeviation*Point())
                  extremum=0.0;
               else
                 {
                  //--- clear previous extremums in backstep bars
                  for(back=1; back<=InpBackstep && i-back>=0; back++)
                    {
                     pos=i-back;
                     if(ExthighBuffer[pos]!=0 && ExthighBuffer[pos]<extremum)
                        ExthighBuffer[pos]=0.0;
                    }
                 }
              }
            //--- found extremum is current high
            if(high[i]==extremum)
               ExthighBuffer[i]=extremum;
            else
               ExthighBuffer[i]=0.0;
           }
      //--- final cutting
         if(whatlookfor==0)
           {
            lastlow=0.0;
            lasthigh=0.0;
           }
         else
           {
            lastlow=curlow;
            lasthigh=curhigh;
           }
         for(i=limit; i>=0; i--)
           {
            switch(whatlookfor)
              {
               case 0: // look for peak or lawn
                  if(lastlow==0.0 && lasthigh==0.0)
                    {
                     if(ExthighBuffer[i]!=0.0)
                       {
                        lasthigh=high[i];
                        lasthighpos=i;
                        whatlookfor=-1;
                        ExtZigzagBuffer[i]=lasthigh;
                        t_last_high = time[i];
                       }
                     if(ExtlowBuffer[i]!=0.0)
                       {
                        lastlow=low[i];
                        lastlowpos=i;
                        whatlookfor=1;
                        ExtZigzagBuffer[i]=lastlow;
                        t_last_low = time[i];
                       }
                    }
                   break;
               case 1: // look for peak
                  if(ExtlowBuffer[i]!=0.0 && ExtlowBuffer[i]<lastlow && ExthighBuffer[i]==0.0)
                    {
                     ExtZigzagBuffer[lastlowpos]=0.0;
                     lastlow=ExtlowBuffer[i];
                     ExtZigzagBuffer[i]=lastlow;
                     lastlowpos = i;
                     t_last_low = time[i];
                    }
                  if(ExthighBuffer[i]!=0.0 && ExtlowBuffer[i]==0.0)
                    {
                     lasthigh=ExthighBuffer[i];
                     lasthighpos=i;
                     ExtZigzagBuffer[i]=lasthigh;
                     whatlookfor=-1;
                     t_last_high = time[i];
                    }
                  break;
               case -1: // look for lawn
                  if(ExthighBuffer[i]!=0.0 && ExthighBuffer[i]>lasthigh && ExtlowBuffer[i]==0.0)
                    {
                      ExtZigzagBuffer[lasthighpos]=0.0;
                      lasthigh=ExthighBuffer[i];
                      ExtZigzagBuffer[i]=lasthigh;
                      lasthighpos=i;
                      t_last_high = time[i];
                    }
                  if(ExtlowBuffer[i]!=0.0 && ExthighBuffer[i]==0.0)
                    {
                     lastlow=ExtlowBuffer[i];
                     lastlowpos=i;
                     ExtZigzagBuffer[i]=lastlow;
                     whatlookfor=1;
                     t_last_low = time[i];
                    }
                  break;
              }
           }
      }
    // ------------------ Trend size ZigZag ------------------
      if (Work_mode == Trend_size)
      {
          if (rates_total < 100)
              return(0);
          //---
          int Start=0;
          // NOTE: this block ignores intra-candle trends
          int bars_calc = -1;
          //--- initializing
          if (prev_calculated == 0)
          {
              ArrayInitialize(ExtZigzagBuffer,0.0);
              ArrayInitialize(ExthighBuffer,0.0);
              ArrayInitialize(ExtlowBuffer,0.0);
              //--- Start calculation from bar number
              Start = rates_total - 1;
              // direction of the starting candle
              bars_calc = rates_total - 2;
              cur_size = high[bars_calc] - low[bars_calc];
              cur_high = high[bars_calc];
              cur_low  = low[bars_calc];
              last_high[1] = cur_high;
              last_low[1] = cur_low;
              cur_time = time[bars_calc];      // we remember the bar time
              if (close[bars_calc] >= close[bars_calc - 1])
              {
                  state = "UP";
                  Start = bars_calc;
                  last_i_time = time[bars_calc - 1];
              }
              if (close[bars_calc] < close[bars_calc - 1])
              {
                  state = "DN";
                  Start = bars_calc;
                  last_i_time = time[bars_calc - 1];
              }
              // Set the trend size
              if (Trend_size_mode == Manual) trend = Trend * P;
          }
          else Start = rates_total - prev_calculated;
          // Finding out the trend
          if (Trend_size_mode == ATR)
          {
              if(CopyBuffer(atr_handle, 0, 0, 1, atr) > 0)
                  trend = atr[0] * ATR_K;
          }
          for (int i = Start; i >= 0 && !IsStopped(); i--)
          {
              if (state == "UP")
              {
                  // Extension
                  if (high[i] >= cur_high)
                  {
                      ObjectDelete(0, "ZigZag " + TimeToString(last_i_time));
                      cur_high = high[i];
                      cur_low  = high[i];
                      cur_size = cur_high - last_low[1];
                      // Find the index number of the previous extremum
                      cur_time_i = iBarShift(NULL, 0, last_i_time);
                      // drawing
                      ExthighBuffer[cur_time_i] = 0.0; // first we reset the previous one
                      ExthighBuffer[i] = cur_high;
                      ExtZigzagBuffer[cur_time_i] = 0.0;
                      ExtZigzagBuffer[i] = cur_high;
                      // Save the time of the current bar
                      last_i_time = time[i];
                      continue;
                  }
                  // if there was no extension, we simply check the correction
                  if (low[i] <= cur_low)
                  {
                      cur_low = low[i];
                  }
                  // if there was an extension, we check whether the correction has exceeded the specified level on the same candle
                  if (cur_high - cur_low > trend)
                  {
                      last_high[0] = last_high[1];
                      last_high[1] = cur_high;           // current high now becomes past high
                      cur_high = cur_low;
                      cur_size = last_high[1] - cur_low;
                      // Save the time of the current bar
                      last_i_time = time[i];
                      state = "DN";
                      // drawing
                      ExtlowBuffer[i] = cur_low;
                      ExtZigzagBuffer[i] = cur_low;
                      continue;
                  }
              }
              if (state == "DN")
              {
                  // Update extremes if required
                  if (low[i] <= cur_low)
                  {
                      ObjectDelete(0, "ZigZag " + TimeToString(last_i_time));
                      cur_low  = low[i];
                      cur_high = low[i];
                      cur_size = last_high[1] - cur_low;
                      // Find the index number of the previous extremum
                      cur_time_i = iBarShift(NULL, 0, last_i_time);
                      // drawing
                      ExtlowBuffer[cur_time_i] = 0.0; // first we reset the previous one
                      ExtlowBuffer[i] = cur_low;
                      ExtZigzagBuffer[cur_time_i] = 0.0;
                      ExtZigzagBuffer[i] = cur_low;
                      // Save the time of the current bar
                      last_i_time = time[i];
                      continue;
                  }
                  // if there was no extension, we check and, if necessary, update the correction
                  if (high[i] >= cur_high)
                  {
                      cur_high = high[i];
                  }
                  // if there was an extension, we check whether the correction has exceeded the specified level on the same candle
                  if (cur_high - cur_low > trend)
                  {
                      last_low[0] = last_low[1];
                      last_low[1] = cur_low;           // current low now becomes last low
                      cur_low = cur_high;
                      cur_size = cur_high - last_low[1];
                      // Save the time of the current bar
                      last_i_time = time[i];
                      state = "UP";
                      // drawing
                      ExthighBuffer[i] = cur_high;
                      ExtZigzagBuffer[i] = cur_high;
                      continue;
                  }
              }
          }
      }
      // ---------------------------------------- Trend lines ----------------------------------------
      int n_lines = 0;
      int arr_t[];
      double arr[];
      ArrayResize(arr, Lines_count + 3);
      ArrayResize(arr_t, Lines_count + 3);
      if (Mode == Standard || Mode == Structural)
      {
          // Delete objects
          int total = ObjectsTotal(0);
          // Loop through objects from the end
          for(int i = total-1; i >= 0; i--)
          {
              string name = ObjectName(0, i);
              if(StringFind(name, "ZigZag UP", 0) == 0 || 
                 StringFind(name, "ZigZag DN", 0) == 0)
              {
                  ObjectDelete(0, name);
              }
          }
          // Correct collection of extremes ONLY from ExtZigzagBuffer
          // ExtZigzagBuffer already contains all extremes in correct order
          for (int i = 0; i < rates_total - 1 && n_lines < Lines_count + 3; i++)
          {
              if (ExtZigzagBuffer[i] != 0.0)
              {
                  arr[n_lines] = ExtZigzagBuffer[i];
                  arr_t[n_lines] = i;
                  n_lines++;
              }
          }
          // Default color drawing
          if (Mode == Standard && n_lines > 1)
          {
              for (int n = 0; n < n_lines - 1 && n < Lines_count; n++)
              {
                  datetime t1 = time[arr_t[n]];
                  datetime t2 = time[arr_t[n + 1]];
                  // Correct direction determination
                  // If current price is higher than next, it's a down line (DN)
                  // If current price is lower than next, it's an up line (UP)
                  if (arr[n] > arr[n + 1])
                  {
                      TrendCreate("ZigZag DN " + TimeToString(t1), t1, arr[n], t2, arr[n + 1], Lines_color_DN, Lines_width_DN);
                  }
                  else
                  {
                      TrendCreate("ZigZag UP " + TimeToString(t1), t1, arr[n], t2, arr[n + 1], Lines_color_UP, Lines_width_UP);
                  }
              }
          }
          // Structural color drawing
          if (Mode == Structural && n_lines > 3)
          {
              for (int i = 0; i < n_lines - 3 && i < Lines_count; i++)
              {
                  // If ZigZag is going up
                  if (arr[i] > arr[i + 1] && arr[i] > arr[i + 2] && arr[i + 1] > arr[i + 3])
                  {
                      // Capture ABS structure
                      datetime t1 = time[arr_t[i]];
                      datetime t2 = time[arr_t[i + 1]];
                      TrendCreate("ZigZag UP " + TimeToString(t1), t1, arr[i], t2, arr[i + 1], Lines_color_UP, Lines_width_UP);
                      t1 = time[arr_t[i + 1]];
                      t2 = time[arr_t[i + 2]];
                      TrendCreate("ZigZag DN " + TimeToString(t1), t1, arr[i + 1], t2, arr[i + 2], Lines_color_UP, Lines_width_UP);
                      t1 = time[arr_t[i + 2]];
                      t2 = time[arr_t[i + 3]];
                      TrendCreate("ZigZag UP " + TimeToString(t1), t1, arr[i + 2], t2, arr[i + 3], Lines_color_UP, Lines_width_UP);
                  }
                  // If ZigZag is going down
                  if (arr[i] < arr[i + 1] && arr[i] < arr[i + 2] && arr[i + 1] < arr[i + 3])
                  {
                      // Capture ABS structure
                      datetime t1 = time[arr_t[i]];
                      datetime t2 = time[arr_t[i + 1]];
                      TrendCreate("ZigZag DN " + TimeToString(t1), t1, arr[i], t2, arr[i + 1], Lines_color_DN, Lines_width_DN);
                      t1 = time[arr_t[i + 1]];
                      t2 = time[arr_t[i + 2]];
                      TrendCreate("ZigZag UP " + TimeToString(t1), t1, arr[i + 1], t2, arr[i + 2], Lines_color_DN, Lines_width_DN);
                      t1 = time[arr_t[i + 2]];
                      t2 = time[arr_t[i + 3]];
                      TrendCreate("ZigZag DN " + TimeToString(t1), t1, arr[i + 2], t2, arr[i + 3], Lines_color_DN, Lines_width_DN);
                  }
              }
          }
      }

      // ---------------------------------------- Levels (Horizontal or Ray) ----------------------------------------
      if (Draw_levels)
      {
          // Static variable to track last processed bar
          static datetime lastProcessedBar = 0;
          bool isNewBar = (time[0] != lastProcessedBar);
          
          // Update time of last processed bar only if it's a new bar
          if (isNewBar)
              lastProcessedBar = time[0];
          
          // Determine if we should delete objects
          bool shouldDeleteObjects = false;
          
          if (Levels_filter == LIQUID_LEVELS) {
              shouldDeleteObjects = true; // Always redraw in LIQUID_LEVELS mode
          } else if (isNewBar && Levels_type == RAY) {
              shouldDeleteObjects = true; // Redraw rays on new bar
          }
          
          if (shouldDeleteObjects)
          {
              int total = ObjectsTotal(0);
              for(int i = total-1; i >= 0; i--)
              {
                  string name = ObjectName(0, i);
                  if(StringFind(name, "ZigZagLevel_", 0) == 0)
                  {
                      ObjectDelete(0, name);
                  }
              }
          }
          
          // Draw levels for reversal points
          int levelsDrawn = 0;
          for (int i = 0; i < n_lines && levelsDrawn < Levels_count; i++)
          {
              double priceLevel = arr[i];
              datetime timeLevel = time[arr_t[i]]; // Time of reversal point
              int levelBarIndex = arr_t[i];        // Bar index of level
              string levelName = "ZigZagLevel_" + IntegerToString(i);
              
              // Correctly determine level type (resistance or support)
              bool isResistance = false;
              if (i < n_lines - 1) {
                  // If current point is higher than next, it's resistance
                  isResistance = (arr[i] > arr[i + 1]);
              } else if (i > 0) {
                  // For last point compare with previous
                  isResistance = (arr[i] > arr[i - 1]);
              }
              
              // Check if level was broken (only for LIQUID_LEVELS mode)
              bool isBroken = false;
              double buffer = Levels_break_buffer * _Point;
              
              if (Levels_filter == LIQUID_LEVELS)
              {
                  // Check all bars after the level
                  for (int j = 0; j < levelBarIndex; j++)
                  {
                      if (isResistance) // Resistance level (maximum)
                      {
                          // Level is considered broken if high > priceLevel + buffer
                          if (high[j] > priceLevel + buffer)
                          {
                              isBroken = true;
                              break;
                          }
                      }
                      else // Support level (minimum)
                      {
                          // Level is considered broken if low < priceLevel - buffer
                          if (low[j] < priceLevel - buffer)
                          {
                              isBroken = true;
                              break;
                          }
                      }
                  }
              }
              
              // Skip level if it was broken and we're in LIQUID_LEVELS mode
              if (Levels_filter == LIQUID_LEVELS && isBroken)
                  continue;
              
              // Set color based on level type
              color lineColor = isResistance ? Levels_color_UP : Levels_color_DN;
              
              if (Levels_type == HORIZONTAL)
              {
                  // For HLINE - create once and don't touch
                  // HLINE automatically extends to the right
                  if (ObjectFind(0, levelName) < 0)
                  {
                      // Create horizontal line
                      ObjectCreate(0, levelName, OBJ_HLINE, 0, 0, priceLevel);
                      ObjectSetInteger(0, levelName, OBJPROP_COLOR, lineColor);
                      ObjectSetInteger(0, levelName, OBJPROP_WIDTH, Levels_width);
                      ObjectSetInteger(0, levelName, OBJPROP_STYLE, STYLE_SOLID);
                      ObjectSetInteger(0, levelName, OBJPROP_RAY_RIGHT, true); // Extend to the right
                  }
              }
              else // RAY
              {
                  // For RAY - either create new line or update existing one
                  if (ObjectFind(0, levelName) < 0)
                  {
                      // Create new trend line
                      datetime currentTime = iTime(Symbol(), 0, 0);
                      ObjectCreate(0, levelName, OBJ_TREND, 0, timeLevel, priceLevel, currentTime, priceLevel);
                      ObjectSetInteger(0, levelName, OBJPROP_COLOR, lineColor);
                      ObjectSetInteger(0, levelName, OBJPROP_WIDTH, Levels_width);
                      ObjectSetInteger(0, levelName, OBJPROP_STYLE, STYLE_SOLID);
                      ObjectSetInteger(0, levelName, OBJPROP_RAY_RIGHT, Levels_ray);
                  }
                  else if (isNewBar)
                  {
                      // Correctly update end point using ObjectMove
                      datetime currentTime = iTime(Symbol(), 0, 0);
                      ObjectMove(0, levelName, 1, currentTime, priceLevel);
                  }
              }
              
              levelsDrawn++;
          }
      }

      // ---------------------------------------- Labels ----------------------------------------
      if (Draw_labels)
      {
          // Static variables for state tracking
          static datetime lastProcessedBar = 0;
          static int prev_n_lines = 0;
          
          bool isNewBar = (time[0] != lastProcessedBar);
          bool newExtremum = (n_lines > prev_n_lines);
          
          // Update time of last processed bar only if it's a new bar
          if (isNewBar)
              lastProcessedBar = time[0];
          
          // Save current number of lines for next call
          prev_n_lines = n_lines;
          
          // Delete objects only when new extremum appears
          if (newExtremum)
          {
              int total = ObjectsTotal(0);
              for(int i = total-1; i >= 0; i--)
              {
                  string name = ObjectName(0, i);
                  if(StringFind(name, "ZigZagLabel_", 0) == 0)
                  {
                      ObjectDelete(0, name);
                  }
              }
          }
          
          // Draw labels for reversal points
          int labelsDrawn = 0;
          for (int i = 0; i < n_lines && labelsDrawn < Labels_count; i++)
          {
              double priceLevel = arr[i];
              datetime timeLevel = time[arr_t[i]]; // Time of reversal point
              string labelName = "ZigZagLabel_" + IntegerToString(i);
              
              // Correctly determine level type (resistance or support)
              bool isResistance = false;
              if (i < n_lines - 1) {
                  // If current point is higher than next, it's resistance
                  isResistance = (arr[i] > arr[i + 1]);
              } else if (i > 0) {
                  // For last point compare with previous
                  isResistance = (arr[i] > arr[i - 1]);
              }
              
              // Determine label position
              int anchor = isResistance ? ANCHOR_LOWER : ANCHOR_UPPER;
              if (Labels_centered) {
                  anchor = ANCHOR_CENTER;
              }
              
              // Calculate wave size
              double waveSize = 0;
              if (i < n_lines - 1) {
                  waveSize = MathAbs(arr[i] - arr[i + 1]);
              }
              
              // Convert wave size to points
              string text = DoubleToString(waveSize * MathPow(10, _Digits), 0);
              
              // Create or update label
              if (ObjectFind(0, labelName) < 0)
              {
                  ObjectCreate(0, labelName, OBJ_TEXT, 0, timeLevel, priceLevel);
                  ObjectSetString(0, labelName, OBJPROP_TEXT, text);
                  ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, Labels_font_size);
                  ObjectSetInteger(0, labelName, OBJPROP_COLOR, Labels_color);
                  ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, anchor);
              }
              else
              {
                  // Update only if necessary
                  ObjectSetString(0, labelName, OBJPROP_TEXT, text);
                  ObjectSetInteger(0, labelName, OBJPROP_TIME, 0, timeLevel);
                  ObjectSetDouble(0, labelName, OBJPROP_PRICE, 0, priceLevel);
                  ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, Labels_font_size);
                  ObjectSetInteger(0, labelName, OBJPROP_COLOR, Labels_color);
                  ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, anchor);
              }
              
              labelsDrawn++;
          }
      }

      // ---------------------------------------- Alert System ----------------------------------------
      if ((Alert_reversal == Alert_reversal_enable || 
           Alert_BoS == Alert_Bos_enable || 
           Alert_ChoCH == Alert_ChoCH_enable || 
           Alert_breakout == Alert_breakout_enable) && n_lines >= 2)
      {
          // Determine current trend direction
          if (n_lines >= 2) {
              if (arr[0] > arr[1]) 
                  currentTrendDirectionForAlerts = "Up";
              else if (arr[0] < arr[1]) 
                  currentTrendDirectionForAlerts = "Down";
          }
      
          // - Reversal Alert -
          if (Alert_reversal == Alert_reversal_enable)
          {
              // Initialize last_alert_mode on first run
              if (last_alert_mode == "") 
                  last_alert_mode = currentTrendDirectionForAlerts;
              
              // Check for reversal
              if (currentTrendDirectionForAlerts != last_alert_mode && currentTrendDirectionForAlerts != "")
              {
                  if (n_lines >= 3)
                  {
                      double wave_size_points = MathAbs(arr[1] - arr[2]) * MathPow(10, _Digits);
                      last_size = DoubleToString(wave_size_points, 0);
                  }
                  
                  SendReversalAlert(currentTrendDirectionForAlerts);
                  last_alert_mode = currentTrendDirectionForAlerts;
              }
          }
      
          // - Breakout Alert -
          if (Alert_breakout == Alert_breakout_enable && n_lines >= 3)
          {
              // Initialize last_alert_breakout_mode on first run
              if (last_alert_breakout_mode == "")
              {
                  if ((arr[0] > arr[2] && arr[0] > arr[1]) || 
                      (arr[0] < arr[2] && arr[0] < arr[1]))
                      last_alert_breakout_mode = currentTrendDirectionForAlerts;
              }
              
              if (last_alert_breakout_mode != currentTrendDirectionForAlerts) 
                  alert_breakout_flag = true;
              
              // Check for breakout condition
              if (currentTrendDirectionForAlerts == "Up" && arr[0] > arr[2] && arr[0] > arr[1] && alert_breakout_flag)
              {
                  SendBreakoutAlert("Up");
                  alert_breakout_flag = false;
              }
              
              if (currentTrendDirectionForAlerts == "Down" && arr[0] < arr[2] && arr[0] < arr[1] && alert_breakout_flag)
              {
                  SendBreakoutAlert("Dn");
                  alert_breakout_flag = false;
              }
              
              last_alert_breakout_mode = currentTrendDirectionForAlerts;
          }
      
          // - Break of Structure (BoS) Alert -
          if (Alert_BoS == Alert_Bos_enable && n_lines >= 4)
          {
              bool is_bos = false;
              if (currentTrendDirectionForAlerts == "Up" && arr[0] > arr[2] && arr[1] > arr[3])
              {
                  is_bos = true;
              }
              else if (currentTrendDirectionForAlerts == "Down" && arr[0] < arr[2] && arr[1] < arr[3])
              {
                  is_bos = true;
              }
              
              if (is_bos && !bos_alert_flag)
              {
                  SendBoSAlert(currentTrendDirectionForAlerts);
                  bos_alert_flag = true;
              }
              else if (!is_bos)
              {
                  bos_alert_flag = false; // Reset flag for next BoS
              }
          }
      
          // - Change of Character (ChoCH) Alert -
          if (Alert_ChoCH == Alert_ChoCH_enable && n_lines >= 5)
          {
              bool is_choch = false;
              if ((currentTrendDirectionForAlerts == "Down" && 
                   arr[0] < arr[2] && 
                   arr[1] > arr[3] && 
                   arr[2] > arr[4]) ||
                  (currentTrendDirectionForAlerts == "Up" && 
                   arr[0] > arr[2] && 
                   arr[1] < arr[3] && 
                   arr[2] < arr[4]))
              {
                  is_choch = true;
              }
              
              if (is_choch && !choch_alert_flag)
              {
                  SendChoCHAlert(currentTrendDirectionForAlerts);
                  choch_alert_flag = true;
              }
              else if (!is_choch)
              {
                  choch_alert_flag = false; // Reset flag for next ChoCH
              }
          }
      }

      // ----------------------------------------- Plotting the average and median wavelengths
      if (Draw_avg || Draw_med)
      {
          int st = 0; 
          int n = 0;
          double arr_avg[], avg = 0, arr_med[];
          ArrayResize(arr_avg, Lines_count_avg_med + 1);
          ArrayResize(arr_med, Lines_count_avg_med);
          
          for (int i = 0; i < rates_total - 1 && n < Lines_count_avg_med + 1; i++)
          {
              if (st == 0)
              {
                  if (ExthighBuffer[i] != 0)    
                  {    
                      st = 1;     
                      arr_avg[n] = ExthighBuffer[i];      
                      n++;     
                  }
                  if (ExtlowBuffer[i] != 0)    
                  {    
                      st = -1;     
                      arr_avg[n] = ExtlowBuffer[i];       
                      n++;     
                  }
              }
              else
              {
                  if (ExtZigzagBuffer[i] != 0 && st == -1)
                  {
                      arr_avg[n] = ExtZigzagBuffer[i];
                      // Calculation
                      if (Draw_avg) avg += MathAbs(arr_avg[n] - arr_avg[n - 1]);
                      if (Draw_med) arr_med[n - 1] = MathAbs(arr_avg[n] - arr_avg[n - 1]);
                      st = 1;
                      n++;
                      continue;
                  }
                  if (ExtZigzagBuffer[i] != 0 && st == 1)
                  {
                      arr_avg[n] = ExtZigzagBuffer[i];
                      // Calculation
                      if (Draw_avg) avg += MathAbs(arr_avg[n] - arr_avg[n - 1]);
                      if (Draw_med) arr_med[n - 1] = MathAbs(arr_avg[n] - arr_avg[n - 1]);
                      st = -1;
                      n++;
                  }
              }
          }
          
          // Average
          if (Draw_avg && n > 2)
          {
              avg = avg / (n - 1);
              // Add check and update:
              string obj_name = "ZigZag AVG";
              if (ObjectFind(0, obj_name) < 0)
              {
                  // If the object does not exist, create it
                  ObjectCreate(0, obj_name, OBJ_LABEL, 0, 0, 0);
                  ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, 10);
                  ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, 40);
                  ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, Font_size_avg);
                  ObjectSetInteger(0, obj_name, OBJPROP_COLOR, Font_color_avg);
                  ObjectSetInteger(0, obj_name, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
                  ObjectSetInteger(0, obj_name, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
              }
              // Update the text
              ObjectSetString(0, obj_name, OBJPROP_TEXT, "AVG: " + DoubleToString(avg * MathPow(10, _Digits), 0) + " p.");
          }
          
          // Median
          if (Draw_med && n > 2)
          {
              double med = 0;
              int size = ArraySize(arr_med);
              if (size == 0) return(0.0); // Handle empty array
              // 1. Sort the array
              ArraySort(arr_med);
              // 2. Determine the median
              if(size % 2 == 1)
              {
                  // Odd number of elements
                  med = arr_med[size / 2];
              }
              else
              {
                  // Even number of elements
                  int mid = size / 2;
                  med = (arr_med[mid - 1] + arr_med[mid]) / 2.0;
              }
              // Add check and update:
              string obj_name = "ZigZag MED";
              if (ObjectFind(0, obj_name) < 0)
              {
                  // If the object does not exist, create it
                  ObjectCreate(0, obj_name, OBJ_LABEL, 0, 0, 0);
                  ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, 10);
                  ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, 10);
                  ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, Font_size_med);
                  ObjectSetInteger(0, obj_name, OBJPROP_COLOR, Font_color_med);
                  ObjectSetInteger(0, obj_name, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
                  ObjectSetInteger(0, obj_name, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
              }
              // Update the text
              ObjectSetString(0, obj_name, OBJPROP_TEXT, "MED: " + DoubleToString(med * MathPow(10, _Digits), 0) + " p.");
          }
      }

// --- done
return(rates_total);
}

//+------------------------------------------------------------------+
//|                Last Extremum Search Function                     |
//+------------------------------------------------------------------+
double FindLastExtremum(int Start_pos, int direction, int rates_total)
{
    int i;
    for(i = Start_pos; i < rates_total; i++)
    {
        if(direction == 1 && ExthighBuffer[i] != 0.0)
        {
            return ExthighBuffer[i];
        }
        if(direction == -1 && ExtlowBuffer[i] != 0.0)
        {
            return ExtlowBuffer[i];
        }
    }
    return 0.0;
}

//+------------------------------------------------------------------+
//| Creates a trend line based on specified coordinates              |
//+------------------------------------------------------------------+
bool TrendCreate(
                 const string          name="TrendLine",  // Trend line name
                 datetime              time1=0,           // Time of the first point
                 double                price1=0,          // Price of the first point
                 datetime              time2=0,           // Time of the second point
                 double                price2=0,          // Price of the second point
                 const color           clr=clrRed,        // Line color
                 const int             width=1,           // Line thickness
                 const long            chart_ID=0,        // Chart ID
                 const int             sub_window=0,      // Subwindow number
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // Line style
                 const bool            back=false,        // Background placement
                 const bool            selectable=false,  // Allow selection/movement
                 const bool            selection=false,   // Initial selection state
                 const bool            ray_right=false,   // Extend line to the right
                 const bool            hidden=false,      // Hide in object list
                 const long            z_order=1)         // Mouse click priority
  {
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__, ": Failed to create trend line! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selectable);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }

//+---------------------------------------------------------------------+
//| GetTimeFrame function - returns the textual timeframe               |
//+---------------------------------------------------------------------+
string GetTimeFrameString()
  {
    switch(Period())
      {
        case PERIOD_M1:   return("M1");
        case PERIOD_M5:   return("M5");
        case PERIOD_M15:  return("M15");
        case PERIOD_M30:  return("M30");
        case PERIOD_H1:   return("H1");
        case PERIOD_H4:   return("H4");
        case PERIOD_D1:   return("Daily");
        case PERIOD_W1:   return("Weekly");
        case PERIOD_MN1:  return("Monthly");
        default: return("Unknown");
      }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int InitializeAll(int rates_total)
  {
   ArrayInitialize(ExtZigzagBuffer,0.0);
   ArrayInitialize(ExthighBuffer,0.0);
   ArrayInitialize(ExtlowBuffer,0.0);
//--- initial calculation position
   return(rates_total - InpDepth);
  }

//+------------------------------------------------------------------+
//| Alert functions                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Send reversal alert                                              |
//+------------------------------------------------------------------+
void SendReversalAlert(string mode)
{
    string symbol = Symbol();
    string timeframe = GetTimeFrameString();
    string alert_text = symbol + " " + timeframe + " Reversal: " + mode;
    
    if(Alert_reversal == Alert_reversal_enable)
    {
        Alert(alert_text);
        if(Push_use) SendNotification(alert_text);
        if(Mail_use) SendMail(Mail_subject, alert_text);
        if(Sound_use) PlaySound(Sound_file);
    }
}

//+------------------------------------------------------------------+
//| Send breakout alert                                              |
//+------------------------------------------------------------------+
void SendBreakoutAlert(string sig)
{
    string symbol = Symbol();
    string timeframe = GetTimeFrameString();
    string alert_text = symbol + " " + timeframe + " Breakout: " + sig;
    
    if(Alert_breakout == Alert_breakout_enable)
    {
        Alert(alert_text);
        if(Push_use) SendNotification(alert_text);
        if(Mail_use) SendMail(Mail_subject, alert_text);
        if(Sound_use) PlaySound(Sound_file);
    }
}

//+------------------------------------------------------------------+
//| Send Break of Structure (BoS) alert                              |
//+------------------------------------------------------------------+
void SendBoSAlert(string mode)
{
    string symbol = Symbol();
    string timeframe = GetTimeFrameString();
    string alert_text = symbol + " " + timeframe + " Break of Structure (BoS): " + mode;
    
    if(Alert_BoS == Alert_Bos_enable)
    {
        Alert(alert_text);
        if(Push_use) SendNotification(alert_text);
        if(Mail_use) SendMail(Mail_subject, alert_text);
        if(Sound_use) PlaySound(Sound_file);
    }
}

//+------------------------------------------------------------------+
//| Send Change of Character (ChoCH) alert                           |
//+------------------------------------------------------------------+
void SendChoCHAlert(string mode)
{
    string symbol = Symbol();
    string timeframe = GetTimeFrameString();
    string alert_text = symbol + " " + timeframe + " Change of Character (ChoCH): " + mode;
    
    if(Alert_ChoCH == Alert_ChoCH_enable)
    {
        Alert(alert_text);
        if(Push_use) SendNotification(alert_text);
        if(Mail_use) SendMail(Mail_subject, alert_text);
        if(Sound_use) PlaySound(Sound_file);
    }
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
    if (OnDeinit_delete_obj == Delete && _UninitReason == REASON_REMOVE)
      {
        // Delete objects if reinitialization
        int deleted = 0;
        int total = ObjectsTotal(0); // 0 - current chart
        // Iterate objects from the end
        for(int i = total-1; i >= 0; i--)
          {
           string name = ObjectName(0, i);
           if(StringFind(name, "ZigZag", 0) == 0) // Check name prefix
             {
              if(ObjectDelete(0, name))
                {
                 deleted++;
                 Print("Deleted object: ", name);
                }
              else
                 Print("Error deleting object: ", name);
             }
          }
      }
  }