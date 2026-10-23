//+------------------------------------------------------------------+
//|                                  MA Gauge Professional           |
//|               True Historical Entry, Live Pips & Clean Inputs    |
//+------------------------------------------------------------------+
#property copyright "Amarnath Kondiyan Mohan"
#property link      "https://www.linkedin.com/in/amarnath-kondiyan-mohan-546293a/"
#property link      "amarfx@gmail.com"
#property version   "7.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- Plot 1: Long Entry Arrows
#property indicator_label1  "Long Entry"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Plot 2: Short Entry Arrows
#property indicator_label2  "Short Entry"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- Input parameters
input string separator0 = "--- Main Chart Settings ---";
input int InpMAPeriod = 14;                                // Active Plotted MA Period
input ENUM_MA_METHOD InpMAMethod = MODE_SMA;               // MA Method
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE;    // Applied Price

input string separator1 = "--- MTF Advisor Settings ---";
input ENUM_TIMEFRAMES InpTF1 = PERIOD_H1;                  // Higher Timeframe 1
input ENUM_TIMEFRAMES InpTF2 = PERIOD_H4;                  // Higher Timeframe 2
input ENUM_TIMEFRAMES InpTF3 = PERIOD_D1;                  // Higher Timeframe 3

input string separator2 = "--- Auto-Optimizer Settings ---";
input int InpOptStart = 10;                                // Scan Start Period
input int InpOptEnd = 100;                                 // Scan End Period
input int InpOptStep = 10;                                 // Scan Step (e.g. 10, 20, 30...)

input string separator3 = "--- Dashboard & Stats ---";
input int InpHistoryBars = 1000;                           // History Bars for Stats (0 = All)
input color InpTextColor = clrWhite;                       // Dashboard Text Color
input int InpCorner = CORNER_LEFT_UPPER;                   // Dashboard Corner
input int InpX = 20;                                       // X Offset
input int InpY = 20;                                       // Y Offset
input int InpLineGap = 16;                                 // Vertical Spacing

//--- Indicator Buffers
double BufferLong[];
double BufferShort[];

//--- Global Variables
int ma_handle_current, ma_handle_tf1, ma_handle_tf2, ma_handle_tf3;
int current_trend = 0;
double trend_start_price = 0.0, active_peak_price = 0.0;

//--- Internal Safe Variables for Validator
int safe_ma_period;
int safe_opt_start;
int safe_opt_end;
int safe_opt_step;
ENUM_MA_METHOD safe_method;
ENUM_APPLIED_PRICE safe_price;
ENUM_TIMEFRAMES safe_tf1;
ENUM_TIMEFRAMES safe_tf2;
ENUM_TIMEFRAMES safe_tf3;

//--- Complete Historical Stats Variables (Main MA)
int stat_long_total = 0, stat_short_total = 0;
double long_max_pips = 0.0, long_avg_pips = 0.0;
double short_max_pips = 0.0, short_avg_pips = 0.0;
int long_wins = 0, long_losses = 0;
int short_wins = 0, short_losses = 0;
double long_win_rate = 0.0, short_win_rate = 0.0;

//--- Auto-Optimizer Data Structures
struct MA_Result
  {
   int               period;
   double            win_rate;
   double            max_peak;
   double            avg_peak;
   double            score;
  };

MA_Result opt_results[];
int opt_handles[];

//+------------------------------------------------------------------+
//| Timeframe Sanitizer (Protects against Error 4805)                |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES SanitizeTimeframe(int tf)
  {
   switch(tf)
     {
      case PERIOD_M1:
         return PERIOD_M1;
      case PERIOD_M2:
         return PERIOD_M2;
      case PERIOD_M3:
         return PERIOD_M3;
      case PERIOD_M4:
         return PERIOD_M4;
      case PERIOD_M5:
         return PERIOD_M5;
      case PERIOD_M6:
         return PERIOD_M6;
      case PERIOD_M10:
         return PERIOD_M10;
      case PERIOD_M12:
         return PERIOD_M12;
      case PERIOD_M15:
         return PERIOD_M15;
      case PERIOD_M20:
         return PERIOD_M20;
      case PERIOD_M30:
         return PERIOD_M30;
      case PERIOD_H1:
         return PERIOD_H1;
      case PERIOD_H2:
         return PERIOD_H2;
      case PERIOD_H3:
         return PERIOD_H3;
      case PERIOD_H4:
         return PERIOD_H4;
      case PERIOD_H6:
         return PERIOD_H6;
      case PERIOD_H8:
         return PERIOD_H8;
      case PERIOD_H12:
         return PERIOD_H12;
      case PERIOD_D1:
         return PERIOD_D1;
      case PERIOD_W1:
         return PERIOD_W1;
      case PERIOD_MN1:
         return PERIOD_MN1;
      default:
         return _Period; // If validator injects garbage, fallback to current chart TF
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// --- 1. Extreme Input Protection (Validator Bypass) ---
   safe_ma_period = (InpMAPeriod <= 0 || InpMAPeriod > 2000) ? 14 : InpMAPeriod;
   safe_opt_start = (InpOptStart <= 0 || InpOptStart > 1000) ? 10 : InpOptStart;
   safe_opt_step  = (InpOptStep <= 0 || InpOptStep > 500) ? 10 : InpOptStep;
   safe_opt_end   = (InpOptEnd <= safe_opt_start || InpOptEnd > 2000) ? safe_opt_start + (safe_opt_step * 5) : InpOptEnd;

   if((safe_opt_end - safe_opt_start) / safe_opt_step > 30)
     {
      safe_opt_end = safe_opt_start + (safe_opt_step * 30);
     }

   int method_val = (int)InpMAMethod;
   safe_method = (method_val < 0 || method_val > 3) ? MODE_SMA : InpMAMethod;

   int price_val = (int)InpAppliedPrice;
   safe_price = (price_val < 1 || price_val > 7) ? PRICE_CLOSE : InpAppliedPrice;

// Sanitize Timeframes to prevent Error 4805
   safe_tf1 = SanitizeTimeframe((int)InpTF1);
   safe_tf2 = SanitizeTimeframe((int)InpTF2);
   safe_tf3 = SanitizeTimeframe((int)InpTF3);

   SetIndexBuffer(0, BufferLong, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   ArraySetAsSeries(BufferLong, false);

   SetIndexBuffer(1, BufferShort, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);
   ArraySetAsSeries(BufferShort, false);

// --- 2. Main & MTF Handles (Using Safe Variables) ---
   ma_handle_current = iMA(_Symbol, _Period, safe_ma_period, 0, safe_method, safe_price);
   ma_handle_tf1 = iMA(_Symbol, safe_tf1, safe_ma_period, 0, safe_method, safe_price);
   ma_handle_tf2 = iMA(_Symbol, safe_tf2, safe_ma_period, 0, safe_method, safe_price);
   ma_handle_tf3 = iMA(_Symbol, safe_tf3, safe_ma_period, 0, safe_method, safe_price);

// --- 3. Validate Handles ---
   if(ma_handle_current == INVALID_HANDLE || ma_handle_tf1 == INVALID_HANDLE ||
      ma_handle_tf2 == INVALID_HANDLE || ma_handle_tf3 == INVALID_HANDLE)
     {
      Print("Error creating main MA handles: ", GetLastError());
      return(INIT_FAILED);
     }

// --- 4. Initialize Optimizer Handles (Using Safe Variables) ---
   int opt_count = 0;
   for(int p = safe_opt_start; p <= safe_opt_end; p += safe_opt_step)
      opt_count++;

   ArrayResize(opt_handles, opt_count);
   ArrayResize(opt_results, opt_count);

   int idx = 0;
   for(int p = safe_opt_start; p <= safe_opt_end; p += safe_opt_step)
     {
      opt_handles[idx] = iMA(_Symbol, _Period, p, 0, safe_method, safe_price);

      if(opt_handles[idx] == INVALID_HANDLE)
        {
         Print("Error creating optimizer MA handle for period: ", p);
         return(INIT_FAILED);
        }

      opt_results[idx].period = p;
      idx++;
     }

   CreateDashboard();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "MAGauge_");
   IndicatorRelease(ma_handle_current);
   IndicatorRelease(ma_handle_tf1);
   IndicatorRelease(ma_handle_tf2);
   IndicatorRelease(ma_handle_tf3);

   for(int i = 0; i < ArraySize(opt_handles); i++)
     {
      IndicatorRelease(opt_handles[i]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPipValue()
  {
   double pip = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   if(digits == 3 || digits == 5)
      pip *= 10;
   return pip;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTFName(ENUM_TIMEFRAMES tf)
  {
   string name = EnumToString(tf);
   StringReplace(name, "PERIOD_", "");
   return name;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetTFState(ENUM_TIMEFRAMES tf, int handle)
  {
   double close[], ma[];
   if(CopyClose(_Symbol, tf, 0, 1, close) <= 0)
      return 0;
   if(CopyBuffer(handle, 0, 0, 1, ma) <= 0)
      return 0;
   if(close[0] > ma[0])
      return 1;
   if(close[0] < ma[0])
      return -1;
   return 0;
  }

//+------------------------------------------------------------------+
//| Optimizer Engine (Scans all Handles)                             |
//+------------------------------------------------------------------+
void RunOptimizer(const int rates_total, const double &high[], const double &low[], const double &close[], double pip_size)
  {
   int start_idx = 1;
   if(InpHistoryBars > 0 && rates_total > InpHistoryBars)
      start_idx = rates_total - InpHistoryBars;

   int n_opt = ArraySize(opt_handles);
   double ma_data[];

   for(int h = 0; h < n_opt; h++)
     {
      int copied = CopyBuffer(opt_handles[h], 0, 0, rates_total, ma_data);
      if(copied <= 0)
         continue;

      // Safe upper bound – avoid array out-of-range
      int end = MathMin(rates_total-1, copied);

      // Pass 1: Max & Avg
      double l_max = 0.0, l_total = 0.0, s_max = 0.0, s_total = 0.0;
      int l_count = 0, s_count = 0, temp_trend = 0;
      double temp_start = 0.0, temp_peak = 0.0;

      for(int i = start_idx; i < end; i++)
        {
         if(close[i-1] <= ma_data[i-1] && close[i] > ma_data[i]) // UP
           {
            if(temp_trend == -1)
              {
               double dist = (temp_start - temp_peak) / pip_size;
               if(dist > s_max)
                  s_max = dist;
               s_total += dist;
               s_count++;
              }
            temp_trend = 1;
            temp_start = close[i];
            temp_peak = high[i];
           }
         else
            if(close[i-1] >= ma_data[i-1] && close[i] < ma_data[i]) // DOWN
              {
               if(temp_trend == 1)
                 {
                  double dist = (temp_peak - temp_start) / pip_size;
                  if(dist > l_max)
                     l_max = dist;
                  l_total += dist;
                  l_count++;
                 }
               temp_trend = -1;
               temp_start = close[i];
               temp_peak = low[i];
              }
            else
              {
               if(temp_trend == 1)
                  temp_peak = MathMax(temp_peak, high[i]);
               if(temp_trend == -1)
                  temp_peak = MathMin(temp_peak, low[i]);
              }
        }

      double avg_l = (l_count > 0) ? (l_total / l_count) : 0.0;
      double avg_s = (s_count > 0) ? (s_total / s_count) : 0.0;

      // Pass 2: Wins based on Avg
      int wins = 0, total_trades = l_count + s_count;
      temp_trend = 0;
      temp_start = 0.0;
      temp_peak = 0.0;

      for(int i = start_idx; i < end; i++)
        {
         if(close[i-1] <= ma_data[i-1] && close[i] > ma_data[i])
           {
            if(temp_trend == -1 && (temp_start - temp_peak)/pip_size >= avg_s)
               wins++;
            temp_trend = 1;
            temp_start = close[i];
            temp_peak = high[i];
           }
         else
            if(close[i-1] >= ma_data[i-1] && close[i] < ma_data[i])
              {
               if(temp_trend == 1 && (temp_peak - temp_start)/pip_size >= avg_l)
                  wins++;
               temp_trend = -1;
               temp_start = close[i];
               temp_peak = low[i];
              }
            else
              {
               if(temp_trend == 1)
                  temp_peak = MathMax(temp_peak, high[i]);
               if(temp_trend == -1)
                  temp_peak = MathMin(temp_peak, low[i]);
              }
        }

      // Store Results
      opt_results[h].win_rate = (total_trades > 0) ? ((double)wins / total_trades) * 100.0 : 0.0;
      opt_results[h].max_peak = MathMax(l_max, s_max);
      opt_results[h].avg_peak = (avg_l + avg_s) / 2.0;
      opt_results[h].score = (opt_results[h].win_rate / 100.0) * opt_results[h].avg_peak; // Expectancy Score
     }

// Bubble Sort by Score (Descending)
   for(int i=0; i<n_opt-1; i++)
     {
      for(int j=0; j<n_opt-i-1; j++)
        {
         if(opt_results[j].score < opt_results[j+1].score)
           {
            MA_Result temp = opt_results[j];
            opt_results[j] = opt_results[j+1];
            opt_results[j+1] = temp;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Active Plotted MA Stats                                          |
//+------------------------------------------------------------------+
void UpdateStats(const int rates_total, const double &high[], const double &low[], const double &close[], const double &ma[], double pip_size)
  {
   int start_idx = 1;
   if(InpHistoryBars > 0 && rates_total > InpHistoryBars)
      start_idx = rates_total - InpHistoryBars;

// Use the actual size of ma[] (which was copied with rates_total)
   int ma_copied = ArraySize(ma);
   int end = MathMin(rates_total-1, ma_copied);

   double l_max = 0.0, l_total = 0.0, s_max = 0.0, s_total = 0.0;
   int l_count = 0, s_count = 0, temp_trend = 0;
   double temp_start_price = 0.0, temp_peak_price = 0.0;

   for(int i = start_idx; i < end; i++)
     {
      bool cross_up = (close[i-1] <= ma[i-1] && close[i] > ma[i]);
      bool cross_dn = (close[i-1] >= ma[i-1] && close[i] < ma[i]);

      if(cross_up)
        {
         if(temp_trend == -1)
           {
            double dist = (temp_start_price - temp_peak_price) / pip_size;
            if(dist > s_max)
               s_max = dist;
            s_total += dist;
            s_count++;
           }
         temp_trend = 1;
         temp_start_price = close[i];
         temp_peak_price = high[i];
        }
      else
         if(cross_dn)
           {
            if(temp_trend == 1)
              {
               double dist = (temp_peak_price - temp_start_price) / pip_size;
               if(dist > l_max)
                  l_max = dist;
               l_total += dist;
               l_count++;
              }
            temp_trend = -1;
            temp_start_price = close[i];
            temp_peak_price = low[i];
           }
         else
           {
            if(temp_trend == 1)
               temp_peak_price = MathMax(temp_peak_price, high[i]);
            if(temp_trend == -1)
               temp_peak_price = MathMin(temp_peak_price, low[i]);
           }
     }

   long_max_pips = l_max;
   long_avg_pips = (l_count > 0) ? (l_total / l_count) : 0.0;
   short_max_pips = s_max;
   short_avg_pips = (s_count > 0) ? (s_total / s_count) : 0.0;
   stat_long_total = l_count;
   stat_short_total = s_count;

   int l_win_count = 0, s_win_count = 0;
   temp_trend = 0;
   temp_start_price = 0.0;
   temp_peak_price = 0.0;

   for(int i = start_idx; i < end; i++)
     {
      bool cross_up = (close[i-1] <= ma[i-1] && close[i] > ma[i]);
      bool cross_dn = (close[i-1] >= ma[i-1] && close[i] < ma[i]);

      if(cross_up)
        {
         if(temp_trend == -1 && (temp_start_price - temp_peak_price)/pip_size >= short_avg_pips)
            s_win_count++;
         temp_trend = 1;
         temp_start_price = close[i];
         temp_peak_price = high[i];
        }
      else
         if(cross_dn)
           {
            if(temp_trend == 1 && (temp_peak_price - temp_start_price)/pip_size >= long_avg_pips)
               l_win_count++;
            temp_trend = -1;
            temp_start_price = close[i];
            temp_peak_price = low[i];
           }
         else
           {
            if(temp_trend == 1)
               temp_peak_price = MathMax(temp_peak_price, high[i]);
            if(temp_trend == -1)
               temp_peak_price = MathMin(temp_peak_price, low[i]);
           }
     }
   long_wins = l_win_count;
   long_losses = l_count - l_win_count;
   short_wins = s_win_count;
   short_losses = s_count - s_win_count;
   long_win_rate = (l_count > 0) ? ((double)long_wins / l_count) * 100.0 : 0.0;
   short_win_rate = (s_count > 0) ? ((double)short_wins / s_count) * 100.0 : 0.0;
  }

//+------------------------------------------------------------------+
//| Main Calculation Loop                                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
   if(rates_total < safe_ma_period)
      return(0);

   double ma[];
   if(CopyBuffer(ma_handle_current, 0, 0, rates_total, ma) <= 0)
      return 0;
   double pip_size = GetPipValue();

   if(prev_calculated == 0)
     {
      current_trend = 0;
      trend_start_price = 0.0;
      active_peak_price = 0.0;
      ArrayInitialize(BufferLong, EMPTY_VALUE);
      ArrayInitialize(BufferShort, EMPTY_VALUE);
     }

   int start = (prev_calculated == 0) ? 1 : prev_calculated - 1;

   for(int i = start; i < rates_total - 1; i++)
     {
      BufferLong[i] = EMPTY_VALUE;
      BufferShort[i] = EMPTY_VALUE;
      if(close[i-1] <= ma[i-1] && close[i] > ma[i])
        {
         current_trend = 1;
         trend_start_price = close[i];
         active_peak_price = high[i];
         // Correct offset – pip_size is already in price units
         BufferLong[i] = low[i] - (5 * pip_size);
        }
      else
         if(close[i-1] >= ma[i-1] && close[i] < ma[i])
           {
            current_trend = -1;
            trend_start_price = close[i];
            active_peak_price = low[i];
            BufferShort[i] = high[i] + (5 * pip_size);
           }
         else
           {
            if(current_trend == 1)
               active_peak_price = MathMax(active_peak_price, high[i]);
            if(current_trend == -1)
               active_peak_price = MathMin(active_peak_price, low[i]);
           }
     }

// Only run the heavy stats and optimizer on a new bar formation
   static datetime last_time = 0;
   if(time[rates_total-1] != last_time || prev_calculated == 0)
     {
      last_time = time[rates_total-1];
      UpdateStats(rates_total, high, low, close, ma, pip_size);
      RunOptimizer(rates_total, high, low, close, pip_size);
     }

   int last = rates_total - 1;
   double current_close = close[last];
   double live_peak = active_peak_price;
   double current_pips = 0.0, max_live_pips = 0.0;

   if(current_trend == 1)
     {
      live_peak = MathMax(live_peak, high[last]);
      current_pips = (current_close - trend_start_price) / pip_size;
      max_live_pips = (live_peak - trend_start_price) / pip_size;
     }
   else
      if(current_trend == -1)
        {
         live_peak = MathMin(live_peak, low[last]);
         current_pips = (trend_start_price - current_close) / pip_size;
         max_live_pips = (trend_start_price - live_peak) / pip_size;
        }

   int state_curr = current_trend;
   int state_tf1 = GetTFState(safe_tf1, ma_handle_tf1);
   int state_tf2 = GetTFState(safe_tf2, ma_handle_tf2);
   int state_tf3 = GetTFState(safe_tf3, ma_handle_tf3);

   int overall_score = state_curr + state_tf1 + state_tf2 + state_tf3;
   string adv_text;
   color adv_color;

   if(overall_score == 4)
     {
      adv_text = "STRONG BULLISH";
      adv_color = clrLimeGreen;
     }
   else
      if(overall_score >= 2)
        {
         adv_text = "WEAK BULLISH";
         adv_color = clrMediumSeaGreen;
        }
      else
         if(overall_score == -4)
           {
            adv_text = "STRONG BEARISH";
            adv_color = clrRed;
           }
         else
            if(overall_score <= -2)
              {
               adv_text = "WEAK BEARISH";
               adv_color = clrOrangeRed;
              }
            else
              {
               adv_text = "MIXED / CHOP";
               adv_color = clrGold;
              }

// --- UI Dashboard Updates ---
   int current_y = InpY;

   UpdateLabel("MAGauge_Title", "📊 MA Gauge Pro (Algorithmic Edition)", InpX, current_y, InpTextColor);
   current_y += InpLineGap;
   UpdateLabel("MAGauge_Line1", "--------------------------------------", InpX, current_y, InpTextColor);
   current_y += InpLineGap;
   UpdateLabel("MAGauge_AdvHead", "[ OVERALL ADVISOR: " + adv_text + " ]", InpX, current_y, adv_color);
   current_y += (InpLineGap + 4);

   UpdateLabel("MAGauge_TFCurr", "[ " + GetTFName(_Period) + " Chart ] : " + (state_curr == 1 ? "LONG" : "SHORT"), InpX + 15, current_y, (state_curr == 1 ? clrLimeGreen : clrRed));
   current_y += InpLineGap;
   UpdateLabel("MAGauge_TF1", "[ HTF 1 - " + GetTFName(safe_tf1) + " ] : " + (state_tf1 == 1 ? "LONG" : "SHORT"), InpX + 15, current_y, (state_tf1 == 1 ? clrLimeGreen : clrRed));
   current_y += InpLineGap;
   UpdateLabel("MAGauge_TF2", "[ HTF 2 - " + GetTFName(safe_tf2) + " ] : " + (state_tf2 == 1 ? "LONG" : "SHORT"), InpX + 15, current_y, (state_tf2 == 1 ? clrLimeGreen : clrRed));
   current_y += InpLineGap;
   UpdateLabel("MAGauge_TF3", "[ HTF 3 - " + GetTFName(safe_tf3) + " ] : " + (state_tf3 == 1 ? "LONG" : "SHORT"), InpX + 15, current_y, (state_tf3 == 1 ? clrLimeGreen : clrRed));
   current_y += (InpLineGap + 4);

// -- THE NEW OPTIMIZER BLOCK --
   UpdateLabel("MAGauge_LineO", "======================================", InpX, current_y, clrGold);
   current_y += InpLineGap;
   UpdateLabel("MAGauge_OptHead", "🏆 AUTO-OPTIMIZER (Best MA Discovered)", InpX, current_y, clrGold);
   current_y += InpLineGap;

   if(ArraySize(opt_results) > 0)
     {
      UpdateLabel("MAGauge_Opt1", "Period: " + IntegerToString(opt_results[0].period) + " | Score: " + DoubleToString(opt_results[0].score, 1), InpX + 10, current_y, clrWhite);
      current_y += InpLineGap;
      UpdateLabel("MAGauge_Opt2", "Win Rate: " + DoubleToString(opt_results[0].win_rate, 1) + "% | Avg Peak: " + DoubleToString(opt_results[0].avg_peak, 1), InpX + 10, current_y, clrWhite);
      current_y += InpLineGap;
      UpdateLabel("MAGauge_Opt3", "Largest Historic Peak: " + DoubleToString(opt_results[0].max_peak, 1) + " pips", InpX + 10, current_y, clrWhite);
      current_y += InpLineGap;
     }

   UpdateLabel("MAGauge_Line2", "======================================", InpX, current_y, clrGold);
   current_y += InpLineGap;
   UpdateLabel("MAGauge_Live", "Active Trade: " + DoubleToString(current_pips, 1) + " | Peak: " + DoubleToString(max_live_pips, 1), InpX, current_y, (current_trend == 1 ? clrLimeGreen : clrRed));
   current_y += (InpLineGap + 8);

// -- ACTIVE PLOTTED MA STATS --
   UpdateLabel("MAGauge_HeadL", "[ PLOTTED LONG PROBABILITY ]", InpX, current_y, clrLimeGreen);
   current_y += InpLineGap;
   UpdateLabel("MAGauge_LWins", "Wins: " + IntegerToString(long_wins) + " | Loss: " + IntegerToString(long_losses) + " | Avg Target: " + DoubleToString(long_avg_pips, 1), InpX, current_y, clrWhite);
   current_y += InpLineGap;
   UpdateLabel("MAGauge_LRate", "Win Probability: " + DoubleToString(long_win_rate, 1) + "%", InpX, current_y, clrLimeGreen);
   current_y += (InpLineGap + 8);

   UpdateLabel("MAGauge_HeadS", "[ PLOTTED SHORT PROBABILITY ]", InpX, current_y, clrRed);
   current_y += InpLineGap;
   UpdateLabel("MAGauge_SWins", "Wins: " + IntegerToString(short_wins) + " | Loss: " + IntegerToString(short_losses) + " | Avg Target: " + DoubleToString(short_avg_pips, 1), InpX, current_y, clrWhite);
   current_y += InpLineGap;
   UpdateLabel("MAGauge_SRate", "Win Probability: " + DoubleToString(short_win_rate, 1) + "%", InpX, current_y, clrRed);

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Dashboard Setup                                                  |
//+------------------------------------------------------------------+
void CreateDashboard()
  {
   string objects[] = {"MAGauge_Title", "MAGauge_Line1", "MAGauge_AdvHead",
                       "MAGauge_TFCurr", "MAGauge_TF1", "MAGauge_TF2", "MAGauge_TF3",
                       "MAGauge_LineO", "MAGauge_OptHead", "MAGauge_Opt1", "MAGauge_Opt2", "MAGauge_Opt3",
                       "MAGauge_Line2", "MAGauge_Live",
                       "MAGauge_HeadL", "MAGauge_LWins", "MAGauge_LRate",
                       "MAGauge_HeadS", "MAGauge_SWins", "MAGauge_SRate"
                      };

   for(int i = 0; i < ArraySize(objects); i++)
     {
      if(ObjectFind(0, objects[i]) < 0)
        {
         ObjectCreate(0, objects[i], OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, objects[i], OBJPROP_CORNER, InpCorner);
         ObjectSetInteger(0, objects[i], OBJPROP_FONTSIZE, 9);
         ObjectSetString(0, objects[i], OBJPROP_FONT, "Consolas");
         ObjectSetInteger(0, objects[i], OBJPROP_BACK, false);
         ObjectSetInteger(0, objects[i], OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, objects[i], OBJPROP_HIDDEN, true);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateLabel(string name, string text, int x, int y, color clr)
  {
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
