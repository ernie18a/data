//+------------------------------------------------------------------+
//|                                                 RainbowRanga.mq5 |
//|                          Copyright 2026, Amarnath Kondiyan Mohan |
//|     https://www.linkedin.com/in/amarnath-kondiyan-mohan-546293a/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Amarnath Kondiyan Mohan"
#property link      "https://www.linkedin.com/in/amarnath-kondiyan-mohan-546293a/"
#property version   "1.02"
#property indicator_chart_window
#property indicator_buffers 21
#property indicator_plots 20

//--- Indicator Settings
input string   _hdr1_ = "--- Envelope Settings ---";
input int      InpMAPeriod = 25;                               // Base MA Period
input ENUM_MA_METHOD InpMAMethod = MODE_EMA;                   // Base MA Method
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE;        // Applied Price
input double   InpDevStart = 0.1;                              // Deviation Start (%)
input double   InpDevStep = 0.1;                               // Deviation Step (%)

input string   _hdr2_ = "--- Advisor Settings ---";
input int      InpAdxPeriod = 14;                              // ADX Period
input double   InpAdxThreshold = 25.0;                         // ADX Strong Trend Threshold

//--- SL / TP Engine Settings
input string   _hdr3_ = "--- Trade Planner ---";
input double   InpSLMultiplier = 1.0;                          // SL Multiplier (x Bandwidth)
input double   InpTPMultiplier = 1.5;                          // TP Multiplier (x Bandwidth)

//--- Dashboard UI Settings
input string   _hdr4_ = "--- Dashboard UI Settings ---";
input string   InpFontName = "Consolas";                       // Dashboard Font
input int      InpFontSize = 10;                               // Dashboard Font Size
input color    InpColorBg = clrBlack;                          // Background Color
input color    InpColorText = clrWhite;                        // Default Text Color
input color    InpColorHeader = clrYellow;                     // Main Header Color
input color    InpColorSubHead = clrDeepSkyBlue;               // Section Divider Color
input color    InpColorBull = clrLime;                         // Bullish/Buy Color
input color    InpColorBear = clrRed;                          // Bearish/Sell Color
input int      InpPanelX = 20;                                 // X Position Offset
input int      InpPanelY = 20;                                 // Y Position Offset

//--- Buffer Arrays
double U0[], U1[], U2[], U3[], U4[], U5[], U6[], U7[], U8[], U9[];
double L0[], L1[], L2[], L3[], L4[], L5[], L6[], L7[], L8[], L9[];
double MABuffer[];

//--- Handles & MTF Setup
int ma_handle, adx_handle;
int tf_handles[7];
ENUM_TIMEFRAMES tfs[7] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1};
string tf_names[7] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1"};

//--- Colors
color UpperColors[10] = {clrLime, clrLimeGreen, clrGreenYellow, clrYellow, clrGold, clrOrange, clrDarkOrange, clrOrangeRed, clrRed, clrDarkRed};
color LowerColors[10] = {clrCyan, clrDeepSkyBlue, clrDodgerBlue, clrRoyalBlue, clrBlue, clrMediumBlue, clrDarkBlue, clrBlueViolet, clrDarkViolet, clrPurple};

//--- UI Setup
string UI_PREFIX = "RBW_PRO_";
int UI_LINES = 22;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// Input Validation
   int safe_ma_period = (InpMAPeriod <= 0) ? 25 : InpMAPeriod;
   int safe_adx_period = (InpAdxPeriod <= 0) ? 14 : InpAdxPeriod;

// Buffers mapping
   SetIndexBuffer(20, MABuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(0, U0, INDICATOR_DATA);
   SetIndexBuffer(1, U1, INDICATOR_DATA);
   SetIndexBuffer(2, U2, INDICATOR_DATA);
   SetIndexBuffer(3, U3, INDICATOR_DATA);
   SetIndexBuffer(4, U4, INDICATOR_DATA);
   SetIndexBuffer(5, U5, INDICATOR_DATA);
   SetIndexBuffer(6, U6, INDICATOR_DATA);
   SetIndexBuffer(7, U7, INDICATOR_DATA);
   SetIndexBuffer(8, U8, INDICATOR_DATA);
   SetIndexBuffer(9, U9, INDICATOR_DATA);
   SetIndexBuffer(10, L0, INDICATOR_DATA);
   SetIndexBuffer(11, L1, INDICATOR_DATA);
   SetIndexBuffer(12, L2, INDICATOR_DATA);
   SetIndexBuffer(13, L3, INDICATOR_DATA);
   SetIndexBuffer(14, L4, INDICATOR_DATA);
   SetIndexBuffer(15, L5, INDICATOR_DATA);
   SetIndexBuffer(16, L6, INDICATOR_DATA);
   SetIndexBuffer(17, L7, INDICATOR_DATA);
   SetIndexBuffer(18, L8, INDICATOR_DATA);
   SetIndexBuffer(19, L9, INDICATOR_DATA);

// Configure Plots
   for(int i = 0; i < 10; i++)
     {
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(i, PLOT_LINE_COLOR, UpperColors[i]);
      PlotIndexSetInteger(i + 10, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(i + 10, PLOT_LINE_COLOR, LowerColors[i]);
     }

// Initialize Handles
   ma_handle = iMA(_Symbol, _Period, safe_ma_period, 0, InpMAMethod, InpAppliedPrice);
   adx_handle = iADX(_Symbol, _Period, safe_adx_period);
   for(int i = 0; i < 7; i++)
      tf_handles[i] = iMA(_Symbol, tfs[i], safe_ma_period, 0, InpMAMethod, InpAppliedPrice);

   if(ma_handle == INVALID_HANDLE || adx_handle == INVALID_HANDLE)
     {
      Print("Failed to create indicator handles.");
      return INIT_FAILED;
     }

   CreateGUI();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Main Calculations                                                |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
   if(rates_total < 20)
      return 0; // Wait for enough bars

   int to_copy = (prev_calculated == 0) ? rates_total : rates_total - prev_calculated + 1;
   double ma[];
   ArraySetAsSeries(ma, true);
   if(CopyBuffer(ma_handle, 0, 0, to_copy, ma) <= 0)
      return 0;

// 1. Draw Envelopes
   for(int i = 0; i < to_copy; i++)
     {
      int target = rates_total - 1 - i;
      double base_ma = ma[i];
      if(base_ma == 0.0)
         continue;

      for(int j=0; j<10; j++)
        {
         double dev = (InpDevStart + j*InpDevStep)/100.0;
         if(j==0)
            U0[target] = base_ma*(1+dev);
         else
            if(j==1)
               U1[target] = base_ma*(1+dev);
            else
               if(j==2)
                  U2[target] = base_ma*(1+dev);
               else
                  if(j==3)
                     U3[target] = base_ma*(1+dev);
                  else
                     if(j==4)
                        U4[target] = base_ma*(1+dev);
                     else
                        if(j==5)
                           U5[target] = base_ma*(1+dev);
                        else
                           if(j==6)
                              U6[target] = base_ma*(1+dev);
                           else
                              if(j==7)
                                 U7[target] = base_ma*(1+dev);
                              else
                                 if(j==8)
                                    U8[target] = base_ma*(1+dev);
                                 else
                                    if(j==9)
                                       U9[target] = base_ma*(1+dev);
         if(j==0)
            L0[target] = base_ma*(1-dev);
         else
            if(j==1)
               L1[target] = base_ma*(1-dev);
            else
               if(j==2)
                  L2[target] = base_ma*(1-dev);
               else
                  if(j==3)
                     L3[target] = base_ma*(1-dev);
                  else
                     if(j==4)
                        L4[target] = base_ma*(1-dev);
                     else
                        if(j==5)
                           L5[target] = base_ma*(1-dev);
                        else
                           if(j==6)
                              L6[target] = base_ma*(1-dev);
                           else
                              if(j==7)
                                 L7[target] = base_ma*(1-dev);
                              else
                                 if(j==8)
                                    L8[target] = base_ma*(1-dev);
                                 else
                                    if(j==9)
                                       L9[target] = base_ma*(1-dev);
        }
     }

// Set series flag for PA analysis
   double h_series[], l_series[], c_series[];
   ArraySetAsSeries(h_series, true);
   ArraySetAsSeries(l_series, true);
   ArraySetAsSeries(c_series, true);
   CopyHigh(_Symbol, _Period, 0, 15, h_series);
   CopyLow(_Symbol, _Period, 0, 15, l_series);
   CopyClose(_Symbol, _Period, 0, 15, c_series);

// 2. PRIMARY TREND (EMA Median Phase)
   double current_close = c_series[0];
   double current_ma = ma[0];
   double dev_pct = (MathAbs(current_close - current_ma) / current_ma) * 100.0;
   bool is_upper = (current_close > current_ma);

   string primary_phase = is_upper ? "BULLISH (Price > Median EMA)" : "BEARISH (Price < Median EMA)";
   color primary_clr = is_upper ? InpColorBull : InpColorBear;

// 3. BOUNDARY ANALYSIS (>= 0.5 Resistance/Support)
   string zone_status = "Equilibrium (Inner Range)";
   color zone_color = InpColorText;

   if(dev_pct >= 0.8)
     {
      zone_status = is_upper ? "EXTREME UPPER RESISTANCE" : "EXTREME LOWER SUPPORT";
      zone_color = is_upper ? clrRed : clrMagenta;
     }
   else
      if(dev_pct >= 0.5)
        {
         zone_status = is_upper ? "UPPER RESISTANCE BOUNDARY" : "LOWER SUPPORT BOUNDARY";
         zone_color = is_upper ? clrOrange : clrDodgerBlue;
        }

// 4. SECONDARY TREND (Price Action HH/LL/HL/LH)
   double curr_sh = h_series[ArrayMaximum(h_series, 1, 5)];
   double prev_sh = h_series[ArrayMaximum(h_series, 6, 5)];
   double curr_sl = l_series[ArrayMinimum(l_series, 1, 5)];
   double prev_sl = l_series[ArrayMinimum(l_series, 6, 5)];

   string pa_h = (curr_sh > prev_sh) ? "HH" : "LH";
   string pa_l = (curr_sl > prev_sl) ? "HL" : "LL";

   string secondary_trend = pa_h + ", " + pa_l;
   color sec_clr = InpColorText;
   if(pa_h == "HH" && pa_l == "HL")
     {
      secondary_trend += " (Up PA)";
      sec_clr = InpColorBull;
     }
   else
      if(pa_h == "LH" && pa_l == "LL")
        {
         secondary_trend += " (Down PA)";
         sec_clr = InpColorBear;
        }
      else
        {
         secondary_trend += " (Mixed PA)";
         sec_clr = clrGold;
        }

// 5. MTF SCORING ENGINE
   int mtf_score = 0;
   string mtf_states[7];

   for(int i = 0; i < 7; i++)
     {
      double mtf_ma[], mtf_close[];
      if(CopyBuffer(tf_handles[i], 0, 0, 1, mtf_ma) > 0 && CopyClose(_Symbol, tfs[i], 0, 1, mtf_close) > 0)
        {
         if(mtf_close[0] > mtf_ma[0])
           {
            mtf_score += 1;
            mtf_states[i] = "UP";
           }
         else
           {
            mtf_score -= 1;
            mtf_states[i] = "DN";
           }
        }
      else
         mtf_states[i] = "--";
     }

   string mtf_consensus = "Consolidation (Mixed)";
   color mtf_clr = InpColorText;
   if(mtf_score >= 4)
     {
      mtf_consensus = "STRONG BULL (Score: +" + IntegerToString(mtf_score) + "/7)";
      mtf_clr = InpColorBull;
     }
   else
      if(mtf_score <= -4)
        {
         mtf_consensus = "STRONG BEAR (Score: " + IntegerToString(mtf_score) + "/7)";
         mtf_clr = InpColorBear;
        }
      else
         if(mtf_score > 0)
           {
            mtf_consensus = "MILD BULL (Score: +" + IntegerToString(mtf_score) + "/7)";
            mtf_clr = InpColorBull;
           }
         else
            if(mtf_score < 0)
              {
               mtf_consensus = "MILD BEAR (Score: " + IntegerToString(mtf_score) + "/7)";
               mtf_clr = InpColorBear;
              }

// 6. ADX & OVERALL MOMENTUM SUGGESTION
   double adx_val[];
   string adx_str = "Loading...";
   color adx_clr = InpColorText;
   if(CopyBuffer(adx_handle, 0, 0, 1, adx_val) > 0)
     {
      adx_str = DoubleToString(adx_val[0], 1) + ((adx_val[0] > InpAdxThreshold) ? " (High Volatility)" : " (Low Volatility)");
      if(adx_val[0] > InpAdxThreshold)
         adx_clr = clrGold;
     }

   string overall_suggestion = "Wait for clarity.";
   color sugg_clr = InpColorText;

   if(mtf_score >= 4 && is_upper && (pa_h == "HH" && pa_l == "HL"))
     {
      overall_suggestion = "FULL BULLISH ALIGNMENT. Look for Pullback Buys.";
      sugg_clr = InpColorBull;
     }
   else
      if(mtf_score <= -4 && !is_upper && (pa_h == "LH" && pa_l == "LL"))
        {
         overall_suggestion = "FULL BEARISH ALIGNMENT. Look for Pullback Sells.";
         sugg_clr = InpColorBear;
        }
      else
         if(dev_pct >= 0.8)
           {
            overall_suggestion = "EXTREME DEVIATION. High Risk of Mean Reversion.";
            sugg_clr = clrOrange;
           }
         else
            if(mtf_score > 0 && !is_upper)
              {
               overall_suggestion = "CORRECTIVE PHASE. Testing Median MA Support.";
               sugg_clr = clrYellow;
              }
            else
               if(mtf_score < 0 && is_upper)
                 {
                  overall_suggestion = "CORRECTIVE PHASE. Testing Median MA Resistance.";
                  sugg_clr = clrYellow;
                 }

// --- Pip & Bandwidth Calculations ---
   double point = _Point;
   double pip_size = (_Digits == 5 || _Digits == 3) ? point * 10 : point;
   double bw_price_dist = current_ma * 0.008;
   int bw_pips = (int)MathRound(bw_price_dist / pip_size);
   int sl_pips = (int)MathRound(bw_pips * InpSLMultiplier);
   int tp_pips = (int)MathRound(bw_pips * InpTPMultiplier);

// 7. BUILD THE UI
   UpdateGUILine(0, "══ ENVELOPE DASHBOARD PRO ══", InpColorHeader);
   UpdateGUILine(1, "ADX Momentum: " + adx_str, adx_clr);
   UpdateGUILine(2, "── TREND ANALYSIS ──", InpColorSubHead);
   UpdateGUILine(3, "Primary Phase: " + primary_phase, primary_clr);
   UpdateGUILine(4, "Price Action:  " + secondary_trend, sec_clr);
   UpdateGUILine(5, "MTF Consensus: " + mtf_consensus, mtf_clr);
   UpdateGUILine(6, "Micro: M1[" + mtf_states[0] + "] M5[" + mtf_states[1] + "] M15[" + mtf_states[2] + "]", InpColorText);
   UpdateGUILine(7, "Macro: M30[" + mtf_states[3] + "] H1[" + mtf_states[4] + "] H4[" + mtf_states[5] + "] D1[" + mtf_states[6] + "]", InpColorText);

   UpdateGUILine(8, "── BOUNDARY STATUS ──", InpColorSubHead);
   UpdateGUILine(9, "Deviation: " + DoubleToString(dev_pct, 2) + "%", InpColorText);
   UpdateGUILine(10, "Boundary:  " + zone_status, zone_color);

   UpdateGUILine(11, "── TRADE PLANNER ──", clrOrange);
   UpdateGUILine(12, "Bandwidth (0.8%): " + IntegerToString(bw_pips) + " pips", InpColorText);
   UpdateGUILine(13, "SL Target: " + IntegerToString(sl_pips) + " pips (BWx" + DoubleToString(InpSLMultiplier, 1) + ")", InpColorBear);
   UpdateGUILine(14, "TP Target: " + IntegerToString(tp_pips) + " pips (BWx" + DoubleToString(InpTPMultiplier, 1) + ")", InpColorBull);
   UpdateGUILine(15, "Risk/Reward Ratio = 1:" + DoubleToString(InpTPMultiplier/InpSLMultiplier, 2), clrGold);

   UpdateGUILine(16, "── STRATEGY ENGINE ──", InpColorSubHead);
   UpdateGUILine(17, overall_suggestion, sugg_clr);

   ChartRedraw();
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| UI Management Functions                                          |
//+------------------------------------------------------------------+
void CreateGUI()
  {
   string bg_name = UI_PREFIX + "BG";
   ObjectCreate(0, bg_name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bg_name, OBJPROP_XDISTANCE, InpPanelX);
   ObjectSetInteger(0, bg_name, OBJPROP_YDISTANCE, InpPanelY);
   ObjectSetInteger(0, bg_name, OBJPROP_XSIZE, 350);
   ObjectSetInteger(0, bg_name, OBJPROP_YSIZE, (UI_LINES * (InpFontSize + 6)) + 10);
   ObjectSetInteger(0, bg_name, OBJPROP_BGCOLOR, InpColorBg);
   ObjectSetInteger(0, bg_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bg_name, OBJPROP_COLOR, InpColorSubHead);
   ObjectSetInteger(0, bg_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bg_name, OBJPROP_BACK, false);
   ObjectSetInteger(0, bg_name, OBJPROP_SELECTABLE, false);

   for(int i = 0; i < UI_LINES; i++)
     {
      string lbl_name = UI_PREFIX + "LBL_" + IntegerToString(i);
      ObjectCreate(0, lbl_name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, lbl_name, OBJPROP_XDISTANCE, InpPanelX + 10);
      ObjectSetInteger(0, lbl_name, OBJPROP_YDISTANCE, InpPanelY + 10 + (i * (InpFontSize + 6)));
      ObjectSetInteger(0, lbl_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetString(0, lbl_name, OBJPROP_FONT, InpFontName);
      ObjectSetInteger(0, lbl_name, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetInteger(0, lbl_name, OBJPROP_COLOR, InpColorText);
      ObjectSetInteger(0, lbl_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, lbl_name, OBJPROP_BACK, false);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateGUILine(int index, string text, color clr)
  {
   string lbl_name = UI_PREFIX + "LBL_" + IntegerToString(index);
   ObjectSetString(0, lbl_name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, lbl_name, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, UI_PREFIX);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
