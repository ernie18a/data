//+------------------------------------------------------------------+
//|                                           Foot Print X-Ray [BOS] |
//|                                                          © israr |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, BOSWaves"
#property link      "https://www.mql5.com/en/users/searchmixed/seller"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5

// --- Plot definitions for Signals ---
#property indicator_label1  "Bullish Absorption"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_width1  2

#property indicator_label2  "Bearish Absorption"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_width2  2

#property indicator_label3  "Bullish Divergence"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrLime
#property indicator_width3  2

#property indicator_label4  "Bearish Divergence"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_width4  2

#property indicator_label5  "Exhaustion"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrOrange
#property indicator_width5  2

// --- Input Parameters ---
input group "=== Chart Display ==="
input bool             InpHideCandles     = true;          // Hide Background Candles
input int              InpFontSize        = 8;             // Base Footprint Font Size (6 - 12)

input group "=== Footprint Width ==="
input bool             InpAutoWidth       = true;          // Auto Width (Match MT5 Candle Scale)
input double           InpManualWidth     = 0.50;          // Manual Width Ratio (if Auto is off)
input double           InpWidthMultiplier = 1.0;          // Width Spacing Multiplier (0.5 - 1.5)

input group "=== Timeframe ==="
input bool             InpAutoTF          = true;          // Auto Lower Timeframe
input ENUM_TIMEFRAMES  InpLtfManual       = PERIOD_M1;     // Manual LTF (if Auto is off)

input group "=== Footprint ==="
input bool             InpAutoSz          = true;          // Auto Row Size (ATR based)
input double           InpManSz           = 0.00020;       // Manual Row Size (in Price)
input string           InpTxtMode         = "Delta %";     // Cell Text Mode ("Delta %", "Volume", "None")
input bool             InpShowAcc         = true;          // Accent Lines (Dominant edge)

input group "=== Point of Control ==="
input bool             InpShowPOC         = true;          // Highlight POC Row
input color            InpPocCol          = clrWhite;      // POC Color
input bool             InpShowPOCln       = true;          // POC Line

input group "=== Stacked Imbalance ==="
input bool             InpShowSI          = true;          // Show Stacked Imbalances
input int              InpSiMinRows       = 3;             // Min Consecutive Rows
input double           InpSiThresh        = 0.60;          // Dominance Threshold (0.50 - 0.95)

input group "=== Absorption ==="
input bool             InpShowAbsorb      = true;          // Show Absorption
input int              InpAbsorbRows      = 2;             // Extreme Rows to Check
input double           InpAbsorbThresh   = 0.65;          // Absorption Threshold

input group "=== Unfinished Business ==="
input bool             InpShowUB          = true;          // Show Unfinished Business
input double           InpUbThresh        = 0.85;          // UB Dominance Threshold

input group "=== Signals & Tweaks ==="
input bool             InpShowDiv         = true;          // Delta Divergence
input int              InpDivLookback     = 10;            // Divergence Lookback
input bool             InpShowExh         = true;          // Signals: Exhaustion Bars
input double           InpExhVolMult      = 2.0;           // Volume Multiplier
input double           InpExhDeltaPct     = 0.15;          // Max Delta Ratio

input group "=== Color Palette ==="
input color            InpBuyCol          = clrLime;       // Buyers Color
input color            InpSellCol         = clrRed;        // Sellers Color
input bool             InpColAuto         = true;          // Color Text by Box
input color            InpTextCol         = clrWhite;      // Manual Text Color
input color            InpSiBullCol       = clrLime;       // SI Bull Border Color
input color            InpSiBearCol       = clrRed;        // SI Bear Border Color
input color            InpUbBullCol       = clrLime;       // UB Bull Fill Color
input color            InpUbBearCol       = clrRed;        // UB Bear Fill Color

input group "=== Candle Overlay ==="
input bool             InpShowCandle      = true;          // Show Candle Overlay (Wicks)
input int              InpMaxBars         = 25;            // Max Bars to Render Footprints

// --- Global Indicator Buffers ---
double BullAbsorbBuffer[];
double BearAbsorbBuffer[];
double BullDivBuffer[];
double BearDivBuffer[];
double ExhaustionBuffer[];

// --- UB Zone Structure ---
struct UBZone
  {
   datetime          start_time;
   double            mid_price;
   double            top;
   double            bot;
   int               side; // 1 = Bullish, -1 = Bearish
   string            box_name;
  };

UBZone ub_zones[];

// --- Global variables for background chart color restoration and state ---
color orig_up, orig_down, orig_candle_bull, orig_candle_bear, orig_wick_up, orig_wick_down, orig_line;
long orig_chart_mode;
bool colors_saved = false;
bool g_historical_drawn = false;

//+------------------------------------------------------------------+
//| Custom Indicator Initialization Function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// Bind indicator buffers
   SetIndexBuffer(0, BullAbsorbBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, BearAbsorbBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, BullDivBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, BearDivBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, ExhaustionBuffer, INDICATOR_DATA);
// Configure arrow styles
   PlotIndexSetInteger(0, PLOT_ARROW, 4);   // Filled Diamond
   PlotIndexSetInteger(1, PLOT_ARROW, 4);   // Filled Diamond
   PlotIndexSetInteger(2, PLOT_ARROW, 5);   // Cross (X)
   PlotIndexSetInteger(3, PLOT_ARROW, 5);   // Cross (X)
   PlotIndexSetInteger(4, PLOT_ARROW, 159); // Filled Circle
// Set empty plot values to 0.0
   for(int i = 0; i < 5; i++)
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0);
   IndicatorSetString(INDICATOR_SHORTNAME, "Foot Print X-Ray [BOSWaves]");
// Handle dynamic chart candle hiding
   ApplyHideChartCandles(InpHideCandles);
   g_historical_drawn = false;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom Indicator Deinitialization Function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ClearObjects();
   RestoreOriginalChartColors();
  }

//+------------------------------------------------------------------+
//| Main Calculation Engine                                          |
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
   if(rates_total < 220)
      return(0);
// Reverse index arrays so index 0 represents the newest bar (Pinescript style)
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);
// Track new bar opening state
   static datetime last_bar_time = 0;
   bool is_new_bar = (time[0] != last_bar_time);
// Reset draw state and clean all visual elements when changing settings or on new bar
   if(prev_calculated == 0 || is_new_bar)
     {
      last_bar_time = time[0];
      g_historical_drawn = false;
      ClearObjects();
     }
// Initialize indicator buffer segments
   int limit = rates_total - prev_calculated;
   if(limit <= 0)
      limit = 1;
   if(prev_calculated == 0)
      limit = rates_total - 1;
   for(int i = 0; i < limit && i < rates_total; i++)
     {
      BullAbsorbBuffer[i] = 0.0;
      BearAbsorbBuffer[i] = 0.0;
      BullDivBuffer[i] = 0.0;
      BearDivBuffer[i] = 0.0;
      ExhaustionBuffer[i] = 0.0;
     }
// Volume Guard Check
   if(tick_volume[0] == 0 && volume[0] == 0)
     {
      Print("Foot Print X-Ray warning: No Volume data available.");
      return(rates_total);
     }
// Set Lower Timeframe
   ENUM_TIMEFRAMES ltf = InpAutoTF ? GetAutoLTF(Period()) : InpLtfManual;
   if(ltf > Period())
      ltf = Period();
   color chart_bg = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   color chart_fg = (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND);
   bool is_light_bg = (GetBrightness(chart_bg) > 0.5);
   double tempDelta[];
   ArrayResize(tempDelta, InpMaxBars);
   ArrayInitialize(tempDelta, 0.0);
// Determine historical rendering boundaries vs active real-time updates
   int start_idx = 0;
   int historical_count = (int)MathMin(InpMaxBars - 1, rates_total - 220);
   if(!g_historical_drawn)
     {
      start_idx = historical_count;
      ArrayResize(ub_zones, 0); // Rebuild UB zones
     }
   else
     {
      start_idx = 0; // Tick Optimization: Recalculate ONLY real-time index 0 on ticks
      // Update historical UB zones mitigation conditions against real-time price action
      int active_count = ArraySize(ub_zones);
      double cur_high = high[0];
      double cur_low = low[0];
      for(int k = active_count - 1; k >= 0; k--)
        {
         double mid = ub_zones[k].mid_price;
         if(cur_high >= mid && cur_low <= mid)
           {
            ObjectDelete(0, ub_zones[k].box_name);
            for(int m = k; m < active_count - 1; m++)
               ub_zones[m] = ub_zones[m + 1];
            ArrayResize(ub_zones, active_count - 1);
            active_count--;
           }
         else
           {
            datetime end_t = time[0] + PeriodSeconds(Period());
            ObjectMove(0, ub_zones[k].box_name, 1, end_t, ub_zones[k].bot);
           }
        }
     }
// Get scale value to calculate width constraints
   int cur_scale = (int)ChartGetInteger(0, CHART_SCALE);
// Adjust text sizes based on the zoom scale
   int active_font_size = InpFontSize;
   bool hide_text_for_scale = false;
   if(cur_scale <= 1)
      hide_text_for_scale = true; // Hide text entirely on scale 0 and 1
   else
      if(cur_scale == 2)
         active_font_size = (int)MathMax(6.0, InpFontSize - 2.0); // Make text smaller on scale 2
      else
         if(cur_scale == 3)
            active_font_size = (int)MathMax(7.0, InpFontSize - 1.0); // Slightly smaller on scale 3
   int successful_draws = 0;
// Main rendering iteration
   for(int idx = start_idx; idx >= 0; idx--)
     {
      datetime bar_time = time[idx];
      double bar_high = high[idx];
      double bar_low = low[idx];
      double bar_open = open[idx];
      double bar_close = close[idx];
      // Safe asynchronous extraction of lower timeframe history
      datetime start_time = bar_time;
      datetime end_time = bar_time + PeriodSeconds(Period()) - 1;
      double ltf_open[], ltf_high[], ltf_low[], ltf_close[];
      long ltf_vol[];
      int copied = CopyOpen(Symbol(), ltf, start_time, end_time, ltf_open);
      // Flickering Check: If MT5 has not synchronized this bar's LTF data yet,
      // skip without deleting existing objects. This preserves visuals during sync lags.
      if(copied <= 0)
         continue;
      CopyHigh(Symbol(), ltf, start_time, end_time, ltf_high);
      CopyLow(Symbol(), ltf, start_time, end_time, ltf_low);
      CopyClose(Symbol(), ltf, start_time, end_time, ltf_close);
      if(CopyTickVolume(Symbol(), ltf, start_time, end_time, ltf_vol) <= 0)
         CopyRealVolume(Symbol(), ltf, start_time, end_time, ltf_vol);
      // Clean up previous graphics on this bar now that we have fresh, valid data to replace it
      ClearBarObjects(bar_time);
      // --- Footprint Calculations ---
      double rowSz = 0;
      if(InpAutoSz)
        {
         double atr = GetATR(high, low, close, idx, rates_total);
         rowSz = NormalizeDouble(atr * 0.1, _Digits);
        }
      else
        {
         rowSz = InpManSz;
        }
      if(rowSz <= 0)
         rowSz = _Point;
      int nRows = (int)MathMax(1.0, MathRound((bar_high - bar_low) / rowSz));
      if(nRows > 50)
        {
         nRows = 50;
         rowSz = (bar_high - bar_low) / nRows;
        }
      double step = (bar_high - bar_low) / nRows;
      double rowBV[], rowSV[], rowTot[], rowRat[], rowTops[], rowBots[];
      int siMark[];
      ArrayResize(rowBV, nRows);
      ArrayResize(rowSV, nRows);
      ArrayResize(rowTot, nRows);
      ArrayResize(rowRat, nRows);
      ArrayResize(rowTops, nRows);
      ArrayResize(rowBots, nRows);
      ArrayResize(siMark, nRows);
      ArrayInitialize(siMark, 0);
      double rBot = bar_low;
      for(int i = 0; i < nRows; i++)
        {
         double rTop = rBot + step;
         double bv = 0.0;
         double sv = 0.0;
         if(copied > 0)
           {
            for(int j = 0; j < copied; j++)
              {
               double jh = ltf_high[j];
               double jl = ltf_low[j];
               if(jh >= rBot && jl <= rTop)
                 {
                  double olap = MathMin(jh, rTop) - MathMax(jl, rBot);
                  double rng = jh - jl;
                  double frac = rng > 0 ? olap / rng : 1.0;
                  double av = (double)ltf_vol[j] * frac;
                  if(ltf_close[j] > ltf_open[j])
                     bv += av;
                  else
                     if(ltf_close[j] < ltf_open[j])
                        sv += av;
                     else
                       {
                        bv += av * 0.5;
                        sv += av * 0.5;
                       }
                 }
              }
           }
         double tot = bv + sv;
         double ratio = tot > 0 ? (bv - sv) / tot : 0.0;
         rowBV[i] = bv;
         rowSV[i] = sv;
         rowTot[i] = tot;
         rowRat[i] = ratio;
         rowTops[i] = rTop;
         rowBots[i] = rBot;
         rBot = rTop;
        }
      // Bar Delta for Alerts
      double barDelta = 0;
      double totalVolume = 0;
      for(int i = 0; i < nRows; i++)
        {
         barDelta += (rowBV[i] - rowSV[i]);
         totalVolume += rowTot[i];
        }
      if(idx < InpMaxBars)
         tempDelta[idx] = barDelta;
      // UB Mitigation check during initial/historical load sweeps
      if(!g_historical_drawn)
        {
         int act_c = ArraySize(ub_zones);
         for(int k = act_c - 1; k >= 0; k--)
           {
            double mid = ub_zones[k].mid_price;
            if(bar_high >= mid && bar_low <= mid)
              {
               ObjectDelete(0, ub_zones[k].box_name);
               for(int m = k; m < act_c - 1; m++)
                  ub_zones[m] = ub_zones[m + 1];
               ArrayResize(ub_zones, act_c - 1);
               act_c--;
              }
            else
              {
               datetime end_t = time[0] + PeriodSeconds(Period());
               ObjectMove(0, ub_zones[k].box_name, 1, end_t, ub_zones[k].bot);
              }
           }
        }
      // Identify POC Row
      int pocIdx = 0;
      double pocVol = 0;
      for(int i = 0; i < nRows; i++)
        {
         if(rowTot[i] > pocVol)
           {
            pocVol = rowTot[i];
            pocIdx = i;
           }
        }
      // Stacked Imbalances
      if(InpShowSI && nRows >= InpSiMinRows)
        {
         int bullRun = 0, bullStart = 0;
         for(int i = 0; i < nRows; i++)
           {
            if(rowRat[i] >= InpSiThresh)
              {
               if(bullRun == 0)
                  bullStart = i;
               bullRun++;
              }
            else
              {
               if(bullRun >= InpSiMinRows)
                 {
                  for(int j = bullStart; j < i; j++)
                     siMark[j] = 1;
                 }
               bullRun = 0;
              }
           }
         if(bullRun >= InpSiMinRows)
           {
            for(int j = bullStart; j < nRows; j++)
               siMark[j] = 1;
           }
         int bearRun = 0, bearStart = 0;
         for(int i = 0; i < nRows; i++)
           {
            if(rowRat[i] <= -InpSiThresh)
              {
               if(bearRun == 0)
                  bearStart = i;
               bearRun++;
              }
            else
              {
               if(bearRun >= InpSiMinRows)
                 {
                  for(int j = bearStart; j < i; j++)
                     siMark[j] = -1;
                 }
               bearRun = 0;
              }
           }
         if(bearRun >= InpSiMinRows)
           {
            for(int j = bearStart; j < nRows; j++)
               siMark[j] = -1;
           }
        }
      // Absorption
      bool bullAbsorb = false;
      bool bearAbsorb = false;
      if(InpShowAbsorb && nRows >= InpAbsorbRows)
        {
         double topSV = 0, topTot = 0;
         int startTopIdx = (int)MathMax(0.0, nRows - InpAbsorbRows);
         for(int i = startTopIdx; i < nRows; i++)
           {
            topSV += rowSV[i];
            topTot += rowTot[i];
           }
         double topSellRat = topTot > 0 ? topSV / topTot : 0.0;
         bearAbsorb = (bar_close > bar_open && topSellRat >= InpAbsorbThresh);
         double botBV = 0, botTot = 0;
         int endBotIdx = (int)MathMin(InpAbsorbRows - 1, nRows - 1);
         for(int i = 0; i <= endBotIdx; i++)
           {
            botBV += rowBV[i];
            botTot += rowTot[i];
           }
         double botBuyRat = botTot > 0 ? botBV / botTot : 0.0;
         bullAbsorb = (bar_close < bar_open && botBuyRat >= InpAbsorbThresh);
        }
      // --- Precise MT5 Candle Size Width Controller ---
      double width_ratio = InpManualWidth;
      if(InpAutoWidth)
        {
         width_ratio = GetScaleWidthRatio();
        }
      width_ratio *= InpWidthMultiplier;
      // Limit safety boundary limits
      if(width_ratio < 0.05)
         width_ratio = 0.05;
      if(width_ratio > 0.95)
         width_ratio = 0.95;
      int bar_seconds = PeriodSeconds(Period());
      int span = (int)(bar_seconds * 0.5 * width_ratio);
      datetime box_left  = bar_time - span;
      datetime box_right = bar_time + span;
      // Draw footprint cells
      for(int i = 0; i < nRows; i++)
        {
         double bv = rowBV[i];
         double sv = rowSV[i];
         double tot = rowTot[i];
         double ratio = rowRat[i];
         double rT = rowTops[i];
         double rB = rowBots[i];
         bool isPOC = (i == pocIdx && InpShowPOC);
         int si = siMark[i];
         color rc = ColorFromGradient(ratio, InpSellCol, InpBuyCol);
         double opacity = (100.0 - MathMax(35.0, 82.0 - MathAbs(ratio) * 47.0)) / 100.0;
         color bgC = BlendWithBackground(rc, chart_bg, opacity);
         color bdC = BlendWithBackground(chart_fg, chart_bg, 0.07);
         int bdW = 1;
         if(isPOC)
           {
            bgC = BlendWithBackground(InpPocCol, chart_bg, 0.75);
            bdC = BlendWithBackground(InpPocCol, chart_bg, 0.60);
            bdW = 2;
           }
         else
            if(si == 1 && InpShowSI)
              {
               bdC = BlendWithBackground(InpSiBullCol, chart_bg, 0.90);
               bdW = 2;
              }
            else
               if(si == -1 && InpShowSI)
                 {
                  bdC = BlendWithBackground(InpSiBearCol, chart_bg, 0.90);
                  bdW = 2;
                 }
         string txt = "";
         if(tot > 0)
           {
            if(InpTxtMode == "Delta %")
               txt = DoubleToString(ratio * 100.0, 1) + "%";
            else
               if(InpTxtMode == "Volume")
                  txt = FormatVolume(bv - sv);
           }
         color txC = InpTextCol;
         if(InpColAuto)
           {
            txC = is_light_bg ? BlendWithBackground(rc, clrBlack, 0.75) : BlendWithBackground(rc, clrWhite, 0.75);
           }
         if(isPOC)
           {
            txC = InpPocCol;
           }
         string boxName = "FPX_" + Symbol() + "_" + IntegerToString(Period()) + "_" + IntegerToString(bar_time) + "_Box_" + IntegerToString(i);
         string txtName = "FPX_" + Symbol() + "_" + IntegerToString(Period()) + "_" + IntegerToString(bar_time) + "_Txt_" + IntegerToString(i);
         CreateRectangle(boxName, box_left, rT, box_right, rB, bgC, bdC, bdW);
         if(txt != "" && !hide_text_for_scale)
           {
            // Center Heuristic: Scale text font size down further if string has more characters
            int final_font_size = active_font_size;
            int txt_len = StringLen(txt);
            if(cur_scale == 3 && txt_len > 4)
               final_font_size = (int)MathMax(6.0, active_font_size - 1.0);
            else
               if(cur_scale == 2 && txt_len > 4)
                  final_font_size = (int)MathMax(5.0, active_font_size - 1.0);
            // Locked directly to bar_time center with forceful ANCHOR_CENTER in both creation and updates
            datetime txt_time = bar_time;
            double txt_price = (rT + rB) / 2.0;
            CreateText(txtName, txt_time, txt_price, txt, txC, final_font_size);
           }
         // Accent line
         if(InpShowAcc && tot > 0)
           {
            double accY = (bv - sv >= 0) ? rT : rB;
            string accName = "FPX_" + Symbol() + "_" + IntegerToString(Period()) + "_" + IntegerToString(bar_time) + "_Acc_" + IntegerToString(i);
            color accCol = BlendWithBackground(rc, chart_bg, opacity + 0.25);
            CreateLine(accName, box_left, accY, box_right, accY, accCol, 2, STYLE_SOLID);
           }
        }
      // Center-aligned POC Line
      if(InpShowPOC && InpShowPOCln && nRows > 0)
        {
         double pocMid = (rowTops[pocIdx] + rowBots[pocIdx]) / 2.0;
         string pocLnName = "FPX_" + Symbol() + "_" + IntegerToString(Period()) + "_" + IntegerToString(bar_time) + "_PocLn";
         CreateLine(pocLnName, box_left, pocMid, box_right, pocMid, InpPocCol, 1, STYLE_SOLID);
        }
      // Unfinished Business Creation
      if(InpShowUB && nRows >= 2)
        {
         double topBV = rowBV[nRows - 1], topSV = rowSV[nRows - 1], topTot = topBV + topSV;
         if(topTot > 0 && (topBV / topTot) >= InpUbThresh)
           {
            double zT = rowTops[nRows - 1], zB = rowBots[nRows - 1], mid = (zT + zB) / 2.0;
            UBZone new_zone;
            new_zone.start_time = bar_time;
            new_zone.mid_price = mid;
            new_zone.top = zT;
            new_zone.bot = zB;
            new_zone.side = -1;
            new_zone.box_name = "FPX_UB_Bear_" + IntegerToString(bar_time);
            datetime end_t = time[0] + PeriodSeconds(Period());
            CreateRectangle(new_zone.box_name, bar_time, zT, end_t, zB,
                            BlendWithBackground(InpUbBearCol, chart_bg, 0.15),
                            BlendWithBackground(InpUbBearCol, chart_bg, 0.40), 1);
            int sz = ArraySize(ub_zones);
            ArrayResize(ub_zones, sz + 1);
            ub_zones[sz] = new_zone;
           }
         double botBV = rowBV[0], botSV = rowSV[0], botTot = botBV + botSV;
         if(botTot > 0 && (botSV / botTot) >= InpUbThresh)
           {
            double zT = rowTops[0], zB = rowBots[0], mid = (zT + zB) / 2.0;
            UBZone new_zone;
            new_zone.start_time = bar_time;
            new_zone.mid_price = mid;
            new_zone.top = zT;
            new_zone.bot = zB;
            new_zone.side = 1;
            new_zone.box_name = "FPX_UB_Bull_" + IntegerToString(bar_time);
            datetime end_t = time[0] + PeriodSeconds(Period());
            CreateRectangle(new_zone.box_name, bar_time, zT, end_t, zB,
                            BlendWithBackground(InpUbBullCol, chart_bg, 0.15),
                            BlendWithBackground(InpUbBullCol, chart_bg, 0.40), 1);
            int sz = ArraySize(ub_zones);
            ArrayResize(ub_zones, sz + 1);
            ub_zones[sz] = new_zone;
           }
        }
      // Standard Plot Buffers
      double spacing = GetATR(high, low, close, idx, rates_total) * 0.2;
      if(spacing <= 0)
         spacing = _Point * 10;
      if(InpShowAbsorb)
        {
         if(bullAbsorb)
            BullAbsorbBuffer[idx] = bar_low - spacing;
         if(bearAbsorb)
            BearAbsorbBuffer[idx] = bar_high + spacing;
        }
      bool priceHH = bar_high > GetHighest(high, idx + 1, InpDivLookback, rates_total);
      bool priceLL = bar_low < GetLowest(low, idx + 1, InpDivLookback, rates_total);
      bool bearDiv = InpShowDiv && priceHH && (barDelta < 0);
      bool bullDiv = InpShowDiv && priceLL && (barDelta > 0);
      if(bullDiv)
         BullDivBuffer[idx] = bar_low - spacing;
      if(bearDiv)
         BearDivBuffer[idx] = bar_high + spacing;
      double volSMA = GetVolumeSMA(tick_volume, idx, 20, rates_total);
      double bar_vol = (double)tick_volume[idx];
      bool isExh = InpShowExh && (bar_vol > volSMA * InpExhVolMult) &&
                   (bar_vol > 0 ? (MathAbs(barDelta) / bar_vol < InpExhDeltaPct) : false);
      if(isExh)
         ExhaustionBuffer[idx] = bar_close;
      // Candle Overlay Wicks (Aligned exactly on bar center coordinate)
      if(InpShowCandle)
        {
         string wick_name = "FPX_" + Symbol() + "_" + IntegerToString(Period()) + "_" + IntegerToString(bar_time) + "_Wick";
         color wick_color = (barDelta >= 0) ? InpBuyCol : InpSellCol;
         datetime wick_time = bar_time; // Centered precisely over the footprints
         CreateLine(wick_name, wick_time, bar_low, wick_time, bar_high, wick_color, 1, STYLE_SOLID);
        }
      if(idx > 0)
         successful_draws++;
     }
// Lock drawing state for historical bars ONLY after we successfully build them
   if(!g_historical_drawn && historical_count > 0 && (successful_draws >= historical_count - 2))
     {
      g_historical_drawn = true;
     }
// Maintain maximum constraint on UB Zones list to conserve chart resources
   while(ArraySize(ub_zones) > 50)
     {
      ObjectDelete(0, ub_zones[0].box_name);
      int sz = ArraySize(ub_zones);
      for(int m = 0; m < sz - 1; m++)
         ub_zones[m] = ub_zones[m + 1];
      ArrayResize(ub_zones, sz - 1);
     }
// Trigger Alerts on the recently closed bar (index 1)
   static datetime last_alert_bar_time = 0;
   if(time[1] != last_alert_bar_time && InpMaxBars > 2)
     {
      last_alert_bar_time = time[1];
      if(tempDelta[1] > 0 && tempDelta[2] <= 0)
         Alert("Foot Print X-Ray Flip Bullish on " + Symbol());
      if(tempDelta[1] < 0 && tempDelta[2] >= 0)
         Alert("Foot Print X-Ray Flip Bearish on " + Symbol());
      if(BullAbsorbBuffer[1] != 0.0)
         Alert("Bullish Absorption on " + Symbol());
      if(BearAbsorbBuffer[1] != 0.0)
         Alert("Bearish Absorption on " + Symbol());
      if(BullDivBuffer[1] != 0.0)
         Alert("Bullish Divergence on " + Symbol());
      if(BearDivBuffer[1] != 0.0)
         Alert("Bearish Divergence on " + Symbol());
      if(ExhaustionBuffer[1] != 0.0)
         Alert("Exhaustion Bar on " + Symbol());
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Chart Event Handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
// Redraw immediately when user zooms in (+) or out (-) to adjust footprint column widths
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      static int last_scale = -1;
      int cur_scale = (int)ChartGetInteger(0, CHART_SCALE);
      if(cur_scale != last_scale)
        {
         last_scale = cur_scale;
         g_historical_drawn = false; // Flag reset triggers full historical canvas reconstruction
         ChartRedraw(0);
        }
     }
  }

//+------------------------------------------------------------------+
//| Helper: Dynamic Optimal Candle Ratio Scaling                     |
//+------------------------------------------------------------------+
double GetScaleWidthRatio()
  {
   int scale = (int)ChartGetInteger(0, CHART_SCALE);
   switch(scale)
     {
      case 5:
         return 0.60; // 60% bar-time width
      case 4:
         return 0.55; // 55% bar-time width
      case 3:
         return 0.50; // 50% bar-time width
      case 2:
         return 0.45; // 45% bar-time width
      case 1:
         return 0.40; // 40% bar-time width
      case 0:
         return 0.30; // 30% bar-time width
      default:
         return 0.50;
     }
  }

//+------------------------------------------------------------------+
//| Helper: Dynamic Lower Timeframe Calculation                       |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES GetAutoLTF(ENUM_TIMEFRAMES current_tf)
  {
   switch(current_tf)
     {
      case PERIOD_M1:
         return PERIOD_M1;
      case PERIOD_M2:
         return PERIOD_M1;
      case PERIOD_M3:
         return PERIOD_M1;
      case PERIOD_M4:
         return PERIOD_M1;
      case PERIOD_M5:
         return PERIOD_M1;
      case PERIOD_M6:
         return PERIOD_M1;
      case PERIOD_M10:
         return PERIOD_M1;
      case PERIOD_M12:
         return PERIOD_M1;
      case PERIOD_M15:
         return PERIOD_M1;
      case PERIOD_M20:
         return PERIOD_M2;
      case PERIOD_M30:
         return PERIOD_M5;
      case PERIOD_H1:
         return PERIOD_M5;
      case PERIOD_H2:
         return PERIOD_M15;
      case PERIOD_H3:
         return PERIOD_M15;
      case PERIOD_H4:
         return PERIOD_M15;
      case PERIOD_H6:
         return PERIOD_M30;
      case PERIOD_H8:
         return PERIOD_H1;
      case PERIOD_H12:
         return PERIOD_H1;
      case PERIOD_D1:
         return PERIOD_H1;
      case PERIOD_W1:
         return PERIOD_H4;
      case PERIOD_MN1:
         return PERIOD_D1;
      default:
         return PERIOD_M1;
     }
  }

//+------------------------------------------------------------------+
//| Helper: Get ATR Value                                            |
//+------------------------------------------------------------------+
double GetATR(const double &high[], const double &low[], const double &close[], int idx, int rates_total)
  {
   if(idx >= rates_total - 1)
      return(0.001);
   int period = 200;
   double sum = 0;
   int count = 0;
   for(int i = idx; i < idx + period && i < rates_total - 1; i++)
     {
      double h = high[i];
      double l = low[i];
      double prev_c = close[i + 1];
      double tr = MathMax(h - l, MathMax(MathAbs(h - prev_c), MathAbs(l - prev_c)));
      sum += tr;
      count++;
     }
   return(count > 0 ? sum / count : 0.001);
  }

//+------------------------------------------------------------------+
//| Helper: Simple Moving Average of Volume                          |
//+------------------------------------------------------------------+
double GetVolumeSMA(const long &vol_arr[], int start_idx, int count, int rates_total)
  {
   double sum = 0;
   int actual_count = 0;
   for(int i = start_idx; i < start_idx + count && i < rates_total; i++)
     {
      sum += (double)vol_arr[i];
      actual_count++;
     }
   return(actual_count > 0 ? sum / actual_count : 0.0);
  }

//+------------------------------------------------------------------+
//| Helper: Array Extreme Lookups                                    |
//+------------------------------------------------------------------+
double GetHighest(const double &arr[], int start_idx, int count, int rates_total)
  {
   double val = -1.7976931348623158e+308;
   for(int i = start_idx; i < start_idx + count && i < rates_total; i++)
     {
      if(arr[i] > val)
         val = arr[i];
     }
   return(val);
  }

//+------------------------------------------------------------------+
//| Helper: Array Extreme Lookups                                    |
//+------------------------------------------------------------------+
double GetLowest(const double &arr[], int start_idx, int count, int rates_total)
  {
   double val = 1.7976931348623158e+308;
   for(int i = start_idx; i < start_idx + count && i < rates_total; i++)
     {
      if(arr[i] < val)
         val = arr[i];
     }
   return(val);
  }

//+------------------------------------------------------------------+
//| Helper: Interpolate Colors                                       |
//+------------------------------------------------------------------+
color ColorFromGradient(double ratio, color col_min, color col_max)
  {
   double t = (ratio + 1.0) / 2.0;
   if(t < 0.0)
      t = 0.0;
   if(t > 1.0)
      t = 1.0;
   uchar r1 = (uchar)(col_min & 0xFF);
   uchar g1 = (uchar)((col_min >> 8) & 0xFF);
   uchar b1 = (uchar)((col_min >> 16) & 0xFF);
   uchar r2 = (uchar)(col_max & 0xFF);
   uchar g2 = (uchar)((col_max >> 8) & 0xFF);
   uchar b2 = (uchar)((col_max >> 16) & 0xFF);
   uchar r = (uchar)(r1 + t * (r2 - r1));
   uchar g = (uchar)(g1 + t * (g2 - g1));
   uchar b = (uchar)(b1 + t * (b2 - b1));
   return((color)((b << 16) | (g << 8) | r));
  }

//+------------------------------------------------------------------+
//| Helper: Opacity/Background Blend Simulation                      |
//+------------------------------------------------------------------+
color BlendWithBackground(color col, color bg_col, double alpha_pct)
  {
   if(alpha_pct < 0.0)
      alpha_pct = 0.0;
   if(alpha_pct > 1.0)
      alpha_pct = 1.0;
   uchar r1 = (uchar)(bg_col & 0xFF);
   uchar g1 = (uchar)((bg_col >> 8) & 0xFF);
   uchar b1 = (uchar)((bg_col >> 16) & 0xFF);
   uchar r2 = (uchar)(col & 0xFF);
   uchar g2 = (uchar)((col >> 8) & 0xFF);
   uchar b2 = (uchar)((col >> 16) & 0xFF);
   uchar r = (uchar)(r1 + alpha_pct * (r2 - r1));
   uchar g = (uchar)(g1 + alpha_pct * (g2 - g1));
   uchar b = (uchar)(b1 + alpha_pct * (b2 - b1));
   return((color)((b << 16) | (g << 8) | r));
  }

//+------------------------------------------------------------------+
//| Helper: Calculate Color Brightness                               |
//+------------------------------------------------------------------+
double GetBrightness(color col)
  {
   uchar r = (uchar)(col & 0xFF);
   uchar g = (uchar)((col >> 8) & 0xFF);
   uchar b = (uchar)((col >> 16) & 0xFF);
   return((0.299 * r + 0.587 * g + 0.114 * b) / 255.0);
  }

//+------------------------------------------------------------------+
//| Helper: Format Large Volume Numbers                              |
//+------------------------------------------------------------------+
string FormatVolume(double v)
  {
   double a = MathAbs(v);
   string s = v < 0 ? "-" : "";
   if(a >= 1000000.0)
      return(s + DoubleToString(a / 1000000.0, 1) + "M");
   else
      if(a >= 1000.0)
         return(s + DoubleToString(a / 1000.0, 1) + "K");
      else
         return(s + DoubleToString(a, 0));
  }

//+------------------------------------------------------------------+
//| Helper: Dynamic chart background candle controller                |
//+------------------------------------------------------------------+
void SaveOriginalChartColors()
  {
   if(colors_saved)
      return;
   orig_up          = (color)ChartGetInteger(0, CHART_COLOR_CHART_UP);
   orig_down        = (color)ChartGetInteger(0, CHART_COLOR_CHART_DOWN);
   orig_candle_bull = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BULL);
   orig_candle_bear = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BEAR);
   orig_line        = (color)ChartGetInteger(0, CHART_COLOR_CHART_LINE);
   orig_chart_mode  = ChartGetInteger(0, CHART_MODE);
   colors_saved = true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyHideChartCandles(bool hide)
  {
   if(hide)
     {
      SaveOriginalChartColors();
      ChartSetInteger(0, CHART_COLOR_CHART_UP, clrNONE);
      ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrNONE);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrNONE);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrNONE);
      ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrNONE);
     }
   else
     {
      RestoreOriginalChartColors();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RestoreOriginalChartColors()
  {
   if(!colors_saved)
      return;
   ChartSetInteger(0, CHART_COLOR_CHART_UP, orig_up);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, orig_down);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, orig_candle_bull);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, orig_candle_bear);
   ChartSetInteger(0, CHART_COLOR_CHART_LINE, orig_line);
   ChartSetInteger(0, CHART_MODE, orig_chart_mode);
   colors_saved = false;
  }

//+------------------------------------------------------------------+
//| Helper: Delete Indicator Graphic Objects                         |
//+------------------------------------------------------------------+
void ClearObjects()
  {
   string prefix = "FPX_" + Symbol() + "_" + IntegerToString(Period()) + "_";
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, -1, -1);
      if(StringFind(name, prefix) == 0)
         ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClearBarObjects(datetime bar_time)
  {
   string prefix = "FPX_" + Symbol() + "_" + IntegerToString(Period()) + "_" + IntegerToString(bar_time) + "_";
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, -1, -1);
      if(StringFind(name, prefix) == 0)
         ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
//| Helper: Create/Modify Interactive Rectangles                    |
//+------------------------------------------------------------------+
void CreateRectangle(string name, datetime t1, double p1, datetime t2, double p2, color bg_color, color border_color, int width)
  {
   if(!ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2))
     {
      ObjectMove(0, name, 0, t1, p1);
      ObjectMove(0, name, 1, t2, p2);
     }
// Apply visual parameters forcefully on every tick
   ObjectSetInteger(0, name, OBJPROP_COLOR, border_color);
   ObjectSetInteger(0, name, OBJPROP_FILL, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg_color);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| Helper: Create/Modify Centered Cell Text Labels                 |
//+------------------------------------------------------------------+
void CreateText(string name, datetime t, double p, string txt, color text_color, int font_size)
  {
   if(!ObjectCreate(0, name, OBJ_TEXT, 0, t, p))
     {
      ObjectMove(0, name, 0, t, p);
     }
// Apply center properties forcefully on every single tick call
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, name, OBJPROP_COLOR, text_color);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_CENTER); // Locked Horizontally and Vertically
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| Helper: Create/Modify Accent/POC Lines                           |
//+------------------------------------------------------------------+
void CreateLine(string name, datetime t1, double p1, datetime t2, double p2, color line_color, int width, ENUM_LINE_STYLE style)
  {
   if(!ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2))
     {
      ObjectMove(0, name, 0, t1, p1);
      ObjectMove(0, name, 1, t2, p2);
     }
// Apply line properties forcefully on every single tick call
   ObjectSetInteger(0, name, OBJPROP_COLOR, line_color);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }
//+------------------------------------------------------------------+
