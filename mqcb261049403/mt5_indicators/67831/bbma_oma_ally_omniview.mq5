//+------------------------------------------------------------------+
//|                                       BBMA Oma Ally OmniView.mq5 |
//|     Copyright 2026, MetaQuotes Ltd. Alexander Piechotta (FinGeR) |
//+------------------------------------------------------------------+
#property copyright "Alexander Piechotta (FinGeR)"
#property link "https://www.mql5.com/de/users/alepie"
#property description "BBMA Oma Ally OmniView"
#property description "It's like a bird's-eye view for BBMA Oma Ally fans."
#property description "Just drag it onto the chart and you'll get all the BBMA signals running on the chart."
#property version "1.02"

/*
//+------------------------------------------------------------------+
//| ÄNDERUNGSHISTORIE (CHANGELOG)                                    |
//+------------------------------------------------------------------+
   v1.00 (2025-12-01):
   - Erstveröffentlichung des Indikators.
   
   v1.01 (2026-01-01):
   - Code-Optimierung für MT5 Build 4000+.
   - Fehler bei der Signalberechnung (CSAK Buy) behoben.
   - Hinzufügen der OmniView-Visualisierung.

   v1.02 (2026-04-01):
   - Buffer EMA50 outside Bollinger Bands hinzugefügt.
   
//+------------------------------------------------------------------+
//| FAIRNESS-REGELN & NUTZUNGSBEDINGUNGEN                            |
//+------------------------------------------------------------------+
   1. Dieser Code ist Open Source für Lernzwecke und Verbesserungen.
   2. Bei Weitergabe oder Modifikation muss dieser Header (einschließlich
      der Urheberrechtsangaben) erhalten bleiben.
   3. Eine kommerzielle Nutzung ohne Rücksprache ist nicht gestattet.
//+------------------------------------------------------------------+
*/

#property indicator_chart_window
#property indicator_buffers 44
#property indicator_plots 36

#property indicator_label1 "MAHigh5Fill; MAHigh10Fill"
#property indicator_type1 DRAW_FILLING
#property indicator_color1 clrDarkSlateGray, 139
#property indicator_width1 1

#property indicator_label2 "MALow5Fill; MALow10Fill"
#property indicator_type2 DRAW_FILLING
#property indicator_color2 clrDarkSlateGray, 139
#property indicator_width2 1

#property indicator_type3 DRAW_COLOR_LINE
#property indicator_label3 "Bands middle; ZZLDown; ZZLUp"
#property indicator_color3 clrBlue, clrRed, clrLimeGreen
#property indicator_width3 2

#property indicator_type4 DRAW_LINE
#property indicator_label4 "Bands upper"
#property indicator_color4 clrBlue

#property indicator_type5 DRAW_LINE
#property indicator_label5 "Bands lower"
#property indicator_color5 clrBlue

//--- plot MA High lines
#property indicator_label6 "MAHigh5"
#property indicator_type6 DRAW_LINE
#property indicator_color6 clrDarkSlateGray
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1

//--- plot MA High lines
#property indicator_label7 "MAHigh10"
#property indicator_type7 DRAW_LINE
#property indicator_color7 clrDarkSlateGray
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1

//--- plot MA Low lines
#property indicator_label8 "MALow5"
#property indicator_type8 DRAW_LINE
#property indicator_color8 clrDarkSlateGray
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1

//--- plot MA Low lines
#property indicator_label9 "MALow10"
#property indicator_type9 DRAW_LINE
#property indicator_color9 clrDarkSlateGray
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1

//--- plot EMA50 (ganz vorne)
#property indicator_label10 "EMA50"
#property indicator_type10 DRAW_COLOR_LINE
#property indicator_color10 clrDarkTurquoise, clrYellow
#property indicator_style10 STYLE_SOLID
#property indicator_width10 3

//--- CSAK signals
#property indicator_label11 "CSAK Sell"
#property indicator_type11 DRAW_ARROW
#property indicator_color11 clrWhite
#property indicator_style11 STYLE_SOLID
#property indicator_width11 2

//--- CSAK signals
#property indicator_label12 "CSAK Buy"
#property indicator_type12 DRAW_ARROW
#property indicator_color12 clrYellow
#property indicator_style12 STYLE_SOLID
#property indicator_width12 2

//--- Extreme signals
#property indicator_label13 "Extreme Sell"
#property indicator_type13 DRAW_ARROW
#property indicator_color13 clrYellow
#property indicator_style13 STYLE_SOLID
#property indicator_width13 1

//--- Extreme signals
#property indicator_label14 "Extreme Buy"
#property indicator_type14 DRAW_ARROW
#property indicator_color14 clrYellow
#property indicator_style14 STYLE_SOLID
#property indicator_width14 1

//--- Momentum signals
#property indicator_label15 "CS Momentum Sell"
#property indicator_type15 DRAW_ARROW
#property indicator_color15 clrRed
#property indicator_style15 STYLE_SOLID
#property indicator_width15 1

//--- Momentum signals
#property indicator_label16 "CS Momentum Buy"
#property indicator_type16 DRAW_ARROW
#property indicator_color16 clrDodgerBlue
#property indicator_style16 STYLE_SOLID
#property indicator_width16 1

//--- Reentry signals
#property indicator_label17 "Reentry Sell"
#property indicator_type17 DRAW_ARROW
#property indicator_color17 clrWhite
#property indicator_style17 STYLE_SOLID
#property indicator_width17 1

//--- Reentry signals
#property indicator_label18 "Reentry Buy"
#property indicator_type18 DRAW_ARROW
#property indicator_color18 clrYellow
#property indicator_style18 STYLE_SOLID
#property indicator_width18 1

//--- ZoneZeroLoss plot
#property indicator_label19 "ZoneZeroLoss"
#property indicator_type19 DRAW_NONE

//--- TPW signals
#property indicator_label20 "TPW sell"
#property indicator_type20 DRAW_ARROW
#property indicator_color20 clrRed
#property indicator_style20 STYLE_SOLID
#property indicator_width20 1

//--- TPW signals
#property indicator_label21 "TPW buy"
#property indicator_type21 DRAW_ARROW
#property indicator_color21 clrGreen
#property indicator_style21 STYLE_SOLID
#property indicator_width21 1

//--- Rejection signals
#property indicator_label22 "Rejection EMA50 Sell"
#property indicator_type22 DRAW_ARROW
#property indicator_color22 clrRed
#property indicator_style22 STYLE_SOLID
#property indicator_width22 1

//--- Rejection signals
#property indicator_label23 "Rejection EMA50 Buy"
#property indicator_type23 DRAW_ARROW
#property indicator_color23 clrLimeGreen
#property indicator_style23 STYLE_SOLID
#property indicator_width23 1

//--- GAP signals
#property indicator_label24 "GAP Rejection Sell"
#property indicator_type24 DRAW_ARROW
#property indicator_color24 clrPink
#property indicator_style24 STYLE_SOLID
#property indicator_width24 1

//--- GAPsignals
#property indicator_label25 "GAP Rejection Buy"
#property indicator_type25 DRAW_ARROW
#property indicator_color25 clrPink
#property indicator_style25 STYLE_SOLID
#property indicator_width25 1

//--- Csak2 signals
#property indicator_label26 "CSAK2 Sell"
#property indicator_type26 DRAW_ARROW
#property indicator_color26 clrMagenta
#property indicator_style26 STYLE_SOLID
#property indicator_width26 1

//--- Csak2 signals
#property indicator_label27 "CSAK2 Buy"
#property indicator_type27 DRAW_ARROW
#property indicator_color27 clrYellow
#property indicator_style27 STYLE_SOLID
#property indicator_width27 1

//--- Cross signals
#property indicator_label28 "CrossEMA50mBB Sell"
#property indicator_type28 DRAW_ARROW
#property indicator_color28 clrIndianRed
#property indicator_style28 STYLE_SOLID
#property indicator_width28 1

//--- Cross signals
#property indicator_label29 "CrossEMA50mBB Buy"
#property indicator_type29 DRAW_ARROW
#property indicator_color29 clrGreen
#property indicator_style29 STYLE_SOLID
#property indicator_width29 1

//--- MHV signals
#property indicator_label30 "MHV Sell"
#property indicator_type30 DRAW_ARROW
#property indicator_color30 clrOrange
#property indicator_style30 STYLE_SOLID
#property indicator_width30 1

//--- MHV signals
#property indicator_label31 "MHV Buy"
#property indicator_type31 DRAW_ARROW
#property indicator_color31 clrOrange
#property indicator_style31 STYLE_SOLID
#property indicator_width31 1

//--- Reject plots
#property indicator_label32 "Wick touch Upper BB"
#property indicator_type32 DRAW_ARROW
#property indicator_color32 clrIndianRed
#property indicator_style32 STYLE_SOLID
#property indicator_width32 1

//--- Reject plots
#property indicator_label33 "Wick touch Lower BB"
#property indicator_type33 DRAW_ARROW
#property indicator_color33 clrGreen
#property indicator_style33 STYLE_SOLID
#property indicator_width33 1

//--- CSAA-Sell plots
#property indicator_label34 "CSAA Sell"
#property indicator_type34 DRAW_ARROW
#property indicator_color34 clrIndianRed
#property indicator_style34 STYLE_SOLID
#property indicator_width34 1

//--- CSAA-Buy plots
#property indicator_label35 "CSAA Buy"
#property indicator_type35 DRAW_ARROW
#property indicator_color35 clrGreen
#property indicator_style35 STYLE_SOLID
#property indicator_width35 1

//--- EMA50-Outside-BB
#property indicator_label36 "EMA50 Outside BB"
#property indicator_type36 DRAW_NONE

//--- input parameters 
int InpBandsPeriod = 20;         // Period
int InpBandsShift = 0;           // Shift
double InpBandsDeviations = 2.0; // Deviation

int InpEMA50Period = 50; // Period
int InpEMA90Period = 90; // Period

int InpMahi5Period = 5;   // Period
int InpMahi10Period = 10; // Period
int InpMalo5Period = 5;   // Period
int InpMalo10Period = 10; // Period

//--- NEU: Fractal Settings
int InpFractalBarsLeft = 1;  // Fractal Bars Left
int InpFractalBarsRight = 1; // Fractal Bars Right

//--- die Anzahl der Werte im Indikator Bollinger Bands gespeichert wird
int bars_calculated = 0;
int fr;

//--- indicator buffer
int lastFracUpBar = -1, lastFracDownBar = -1;

double FractalUpBuffer[];
double FractalDownBuffer[];

double MiddleBuffer[];
double MiddleBufferColors[];
double UpperBand[];
double LowerBand[];

double EMA50[];
double EMA50Colors[];
double ZeroLoss[];

double mahi5[];
double mahi10[];
double malo5[];
double malo10[];

// double prices[];

double csak_sell[];
double csak_buy[];
double csak2_sell[];
double csak2_buy[];

double ext_sell[];
double ext_buy[];

double mmt_sell[];
double mmt_buy[];

double ret_sell[];
double ret_buy[];

double tpw_sell[];
double tpw_buy[];

double rejectedEMA50_sell[];
double rejectedEMA50_buy[];

double MHV_sell[];
double MHV_buy[];

double GAPBBtoEMA50_sell[];
double GAPBBtoEMA50_buy[];

double CrossEMA50mBB_sell[];
double CrossEMA50mBB_buy[];

double ext_RejectBBUP[];
double ext_RejectBBDOWN[];

double maHighFill1[];
double maHighFill2[];

double maLowFill1[];
double maLowFill2[];

double csaa_sell[];
double csaa_buy[];

double EMA50outsideBB[];

//--- Arrays for calculations
double atrBuffer[];

int handleBands, handleEMA50, handleMAhi5, handleMAhi10, handleMAlo5, handleMAlo10,
    handleMAhi5H4, handleMAhi10H4, handleMAlo5H4, handleMAlo10H4, atrHandle;

int tpwsell = 0;
int tpwbuy = 0;

// NEU: Wir definieren einen Start-Offset.
// Da wir EMA50 und ATR14 nutzen, sollten wir mindestens 50 Kerzen warten,
// damit alle Buffer gültige Werte haben.
int min_bars_needed = 50;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   
   //--- indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "Bollinger Bands");
   //--- indexes draw begin settings

   //--- number of digits of indicator value
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   //--- settings Bollinger Bands
   PlotIndexSetInteger(2, PLOT_SHIFT, InpBandsShift);
   PlotIndexSetInteger(3, PLOT_SHIFT, InpBandsShift);
   PlotIndexSetInteger(4, PLOT_SHIFT, InpBandsShift);

   //--- settings CSAK-Sell signals
   PlotIndexSetInteger(10, PLOT_ARROW, 242);

   //--- settings CSAK-Buy signals
   PlotIndexSetInteger(11, PLOT_ARROW, 241);

   //--- settings Extrem-Sell signals
   PlotIndexSetInteger(12, PLOT_ARROW, 174);

   //--- settings Extrem-Buy signals
   PlotIndexSetInteger(13, PLOT_ARROW, 174);

   //--- settings Momentum-Sell signals
   PlotIndexSetInteger(14, PLOT_ARROW, 234);

   //--- settings Momentum-Buy signals
   PlotIndexSetInteger(15, PLOT_ARROW, 233);

   //--- settings Reentry-Sell signals
   PlotIndexSetInteger(16, PLOT_ARROW, 198);

   //--- settings Reentry-Buy signals
   PlotIndexSetInteger(17, PLOT_ARROW, 196);

   //--- settings TPW-Sell signals
   PlotIndexSetInteger(19, PLOT_ARROW, 176);

   //--- settings TPW-Buy signals
   PlotIndexSetInteger(20, PLOT_ARROW, 176);

   //--- settings RejectionEMA50-Sell signals
   PlotIndexSetInteger(21, PLOT_ARROW, 244);

   //--- settings RejectionEMA50-Buy signals
   PlotIndexSetInteger(22, PLOT_ARROW, 244);

   //--- settings GAPBBtoEMA50-Sell signals
   PlotIndexSetInteger(23, PLOT_ARROW, 83);

   //--- settings GAPBBtoEMA50-Buy signals
   PlotIndexSetInteger(24, PLOT_ARROW, 83);

   //--- settings Csak2-Sell signals
   PlotIndexSetInteger(25, PLOT_ARROW, 242);

   //--- settings Csak2-Buy signals
   PlotIndexSetInteger(26, PLOT_ARROW, 241);

   //--- settings CrossEMA50mBB-Sell signals
   PlotIndexSetInteger(27, PLOT_ARROW, 172);

   //--- settings CrossEMA50mBB-Buy signals
   PlotIndexSetInteger(28, PLOT_ARROW, 172);

   //--- settings MHV-Sell signals
   PlotIndexSetInteger(29, PLOT_ARROW, 217);

   //--- settings MHV-Buy signals
   PlotIndexSetInteger(30, PLOT_ARROW, 218);

   //--- settings Wick touch Upper BB
   PlotIndexSetInteger(31, PLOT_ARROW, 159);

   //--- settings Wick touch Lower BB
   PlotIndexSetInteger(32, PLOT_ARROW, 159);

   //--- settings CSAA-Sell
   PlotIndexSetInteger(33, PLOT_ARROW, 226);

   //--- settings CSAA-Buy
   PlotIndexSetInteger(34, PLOT_ARROW, 225);

   // IndicatorSetInteger(INDICATOR_DIGITS, Digits() + 1);
   handleBands = iBands(_Symbol, PERIOD_CURRENT, InpBandsPeriod, InpBandsShift, InpBandsDeviations, PRICE_CLOSE);
   handleEMA50 = iMA(_Symbol, PERIOD_CURRENT, InpEMA50Period, 0, MODE_EMA, PRICE_CLOSE);

   handleMAhi5 = iMA(_Symbol, PERIOD_CURRENT, InpMahi5Period, 0, MODE_LWMA, PRICE_HIGH);
   handleMAhi10 = iMA(_Symbol, PERIOD_CURRENT, InpMahi10Period, 0, MODE_LWMA, PRICE_HIGH);

   handleMAlo5 = iMA(_Symbol, PERIOD_CURRENT, InpMalo5Period, 0, MODE_LWMA, PRICE_LOW);
   handleMAlo10 = iMA(_Symbol, PERIOD_CURRENT, InpMalo10Period, 0, MODE_LWMA, PRICE_LOW);

   handleMAhi5H4 = iMA(_Symbol, PERIOD_H4, InpMahi5Period, 0, MODE_LWMA, PRICE_HIGH);
   handleMAhi10H4 = iMA(_Symbol, PERIOD_H4, InpMahi10Period, 0, MODE_LWMA, PRICE_HIGH);

   handleMAlo5H4 = iMA(_Symbol, PERIOD_H4, InpMalo5Period, 0, MODE_LWMA, PRICE_LOW);
   handleMAlo10H4 = iMA(_Symbol, PERIOD_H4, InpMalo10Period, 0, MODE_LWMA, PRICE_LOW);

   atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);

   if (handleBands < 0 || handleEMA50 < 0 || handleMAhi5 < 0 || handleMAhi10 < 0 ||
       handleMAlo5 < 0 || handleMAlo10 < 0 || handleMAhi5H4 < 0 || handleMAhi10H4 < 0 ||
       handleMAlo5H4 < 0 || handleMAlo10H4 < 0 || atrHandle < 0)

   {
      return (INIT_FAILED);
   }

   //--- define buffers
   SetIndexBuffer(0, maHighFill1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(1, maHighFill2, INDICATOR_CALCULATIONS);
   SetIndexBuffer(2, maLowFill1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, maLowFill2, INDICATOR_CALCULATIONS);

   SetIndexBuffer(4, MiddleBuffer, INDICATOR_DATA);
   SetIndexBuffer(5, MiddleBufferColors, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6, UpperBand, INDICATOR_DATA);
   SetIndexBuffer(7, LowerBand, INDICATOR_DATA);

   SetIndexBuffer(8, mahi5, INDICATOR_DATA);
   SetIndexBuffer(9, mahi10, INDICATOR_DATA);
   SetIndexBuffer(10, malo5, INDICATOR_DATA);
   SetIndexBuffer(11, malo10, INDICATOR_DATA);
   SetIndexBuffer(12, EMA50, INDICATOR_DATA);
   SetIndexBuffer(13, EMA50Colors, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(14, csak_sell, INDICATOR_DATA);
   SetIndexBuffer(15, csak_buy, INDICATOR_DATA);
   SetIndexBuffer(16, ext_sell, INDICATOR_DATA);
   SetIndexBuffer(17, ext_buy, INDICATOR_DATA);
   SetIndexBuffer(18, mmt_sell, INDICATOR_DATA);
   SetIndexBuffer(19, mmt_buy, INDICATOR_DATA);
   SetIndexBuffer(20, ret_sell, INDICATOR_DATA);
   SetIndexBuffer(21, ret_buy, INDICATOR_DATA);
   SetIndexBuffer(22, ZeroLoss, INDICATOR_DATA);
   SetIndexBuffer(23, tpw_sell, INDICATOR_DATA);
   SetIndexBuffer(24, tpw_buy, INDICATOR_DATA);
   SetIndexBuffer(25, rejectedEMA50_sell, INDICATOR_DATA);
   SetIndexBuffer(26, rejectedEMA50_buy, INDICATOR_DATA);
   SetIndexBuffer(27, GAPBBtoEMA50_sell, INDICATOR_DATA);
   SetIndexBuffer(28, GAPBBtoEMA50_buy, INDICATOR_DATA);
   SetIndexBuffer(29, csak2_sell, INDICATOR_DATA);
   SetIndexBuffer(30, csak2_buy, INDICATOR_DATA);
   SetIndexBuffer(31, CrossEMA50mBB_sell, INDICATOR_DATA);
   SetIndexBuffer(32, CrossEMA50mBB_buy, INDICATOR_DATA);
   SetIndexBuffer(33, MHV_sell, INDICATOR_DATA);
   SetIndexBuffer(34, MHV_buy, INDICATOR_DATA);

   SetIndexBuffer(35, ext_RejectBBUP, INDICATOR_DATA);
   SetIndexBuffer(36, ext_RejectBBDOWN, INDICATOR_DATA);

   SetIndexBuffer(37, csaa_sell, INDICATOR_DATA);
   SetIndexBuffer(38, csaa_buy, INDICATOR_DATA);

   SetIndexBuffer(39, EMA50outsideBB, INDICATOR_DATA);

   SetIndexBuffer(40, FractalUpBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(41, FractalDownBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(42, atrBuffer, INDICATOR_CALCULATIONS);

   fr = InpFractalBarsLeft + InpFractalBarsRight + 1;

   //--- normale Initialisierung des Indikators
   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Bollinger Bands                                                  |
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
   //--- Anzahl der Werte des Indikators iBands zu kopieren
   int BBmCross, ema50Cross;

   if (rates_total < min_bars_needed)
      return (0);

   if (BarsCalculated(handleBands) != rates_total)
      return (prev_calculated);

   //--- we can copy not all data
   int to_copy;
   if (prev_calculated > rates_total || prev_calculated <= 0)
      to_copy = rates_total;
   else
   {
      to_copy = rates_total - prev_calculated;
      //--- last value is always copied
      to_copy++;
   }

   //--- try to copy
   if (CopyBuffer(handleBands, BASE_LINE, 0, to_copy, MiddleBuffer) <= 0)
      return (0);
   if (CopyBuffer(handleBands, UPPER_BAND, 0, to_copy, UpperBand) <= 0)
      return (0);
   if (CopyBuffer(handleBands, LOWER_BAND, 0, to_copy, LowerBand) <= 0)
      return (0);
   if (CopyBuffer(handleEMA50, 0, 0, to_copy, EMA50) <= 0)
      return (0);
   if (CopyBuffer(handleMAhi10, 0, 0, to_copy, mahi10) <= 0)
      return (0);
   if (CopyBuffer(handleMAhi5, 0, 0, to_copy, mahi5) <= 0)
      return (0);
   if (CopyBuffer(handleMAlo10, 0, 0, to_copy, malo10) <= 0)
      return (0);
   if (CopyBuffer(handleMAlo5, 0, 0, to_copy, malo5) <= 0)
      return (0);
   if (CopyBuffer(handleMAhi5, 0, 0, to_copy, maHighFill1) <= 0)
      return (0);
   if (CopyBuffer(handleMAhi10, 0, 0, to_copy, maHighFill2) <= 0)
      return (0);
   if (CopyBuffer(handleMAlo5, 0, 0, to_copy, maLowFill1) <= 0)
      return (0);
   if (CopyBuffer(handleMAlo10, 0, 0, to_copy, maLowFill2) <= 0)
      return (0);
   if (CopyBuffer(atrHandle, 0, 0, to_copy, atrBuffer) <= 0)
      return (0);

   // SIGNAL Cycle Start here
   int start;

   //--- clean up arrays
   if (prev_calculated < min_bars_needed)
   {
      start = min_bars_needed; // Wir starten erst ab Kerze 50

      ArrayInitialize(csak_sell, EMPTY_VALUE);
      ArrayInitialize(csak_buy, EMPTY_VALUE);
      ArrayInitialize(ext_sell, EMPTY_VALUE);
      ArrayInitialize(ext_buy, EMPTY_VALUE);
      ArrayInitialize(mmt_sell, EMPTY_VALUE);
      ArrayInitialize(mmt_buy, EMPTY_VALUE);
      ArrayInitialize(ret_sell, EMPTY_VALUE);
      ArrayInitialize(ret_buy, EMPTY_VALUE);
      ArrayInitialize(ZeroLoss, EMPTY_VALUE);
      ArrayInitialize(tpw_sell, EMPTY_VALUE);
      ArrayInitialize(tpw_buy, EMPTY_VALUE);
      ArrayInitialize(rejectedEMA50_sell, EMPTY_VALUE);
      ArrayInitialize(rejectedEMA50_buy, EMPTY_VALUE);
      ArrayInitialize(GAPBBtoEMA50_sell, EMPTY_VALUE);
      ArrayInitialize(GAPBBtoEMA50_buy, EMPTY_VALUE);
      ArrayInitialize(csak2_sell, EMPTY_VALUE);
      ArrayInitialize(csak2_buy, EMPTY_VALUE);
      ArrayInitialize(CrossEMA50mBB_sell, EMPTY_VALUE);
      ArrayInitialize(CrossEMA50mBB_buy, EMPTY_VALUE);
      ArrayInitialize(MHV_sell, EMPTY_VALUE);
      ArrayInitialize(MHV_buy, EMPTY_VALUE);
      ArrayInitialize(ext_RejectBBUP, EMPTY_VALUE);
      ArrayInitialize(ext_RejectBBDOWN, EMPTY_VALUE);
      ArrayInitialize(csaa_sell, EMPTY_VALUE);
      ArrayInitialize(csaa_buy, EMPTY_VALUE);
       ArrayInitialize(csaa_buy, EMPTY_VALUE);
      ArrayInitialize(EMA50outsideBB, EMPTY_VALUE);
      // Initialisiere Fractal Buffer, da wir sie jetzt selbst berechnen
      ArrayInitialize(FractalUpBuffer, EMPTY_VALUE);
      ArrayInitialize(FractalDownBuffer, EMPTY_VALUE);
   }
   else
      start = rates_total - fr;

   //--- main cycle of calculations
   for (int i = start; i < rates_total && !IsStopped(); i++)
   {
      // --- NEU: Dynamischer Abstand basierend auf ATR ---
      double gap = 0;
      
 
      // Da wir jetzt erst ab Kerze 50 starten, ist der ATR-Wert hier sicher vorhanden.
      if (atrBuffer[i] != 0 && atrBuffer[i] != EMPTY_VALUE)
      {
         gap = atrBuffer[i] * 0.20; // 20% der ATR
      }
      // Startpositionen für den Stapel
      double currentSellPos = high[i] + (gap / 2); // Stapelt nach oben
      double currentBuyPos = low[i] - (gap / 2);   // Stapelt nach unten
      // --------------------------------------------------

      // --- FRACTAL BERECHNUNG (Ausgelagert) ---
      CalculateDynamicFractals(i, high, low, FractalUpBuffer, FractalDownBuffer, InpFractalBarsLeft, InpFractalBarsRight);
      // ----------------------------------------

      csak_sell[i] = EMPTY_VALUE;
      csak_buy[i] = EMPTY_VALUE;
      csak2_sell[i] = EMPTY_VALUE;
      csak2_buy[i] = EMPTY_VALUE;
      ext_sell[i] = EMPTY_VALUE;
      ext_buy[i] = EMPTY_VALUE;
      mmt_buy[i] = EMPTY_VALUE;
      mmt_sell[i] = EMPTY_VALUE;
      ret_buy[i] = EMPTY_VALUE;
      ret_sell[i] = EMPTY_VALUE;
      tpw_sell[i] = EMPTY_VALUE;
      tpw_buy[i] = EMPTY_VALUE;
      rejectedEMA50_sell[i] = EMPTY_VALUE;
      rejectedEMA50_buy[i] = EMPTY_VALUE;
      MHV_sell[i] = EMPTY_VALUE;
      MHV_buy[i] = EMPTY_VALUE;
      GAPBBtoEMA50_sell[i] = EMPTY_VALUE;
      GAPBBtoEMA50_buy[i] = EMPTY_VALUE;
      CrossEMA50mBB_sell[i] = EMPTY_VALUE;
      CrossEMA50mBB_buy[i] = EMPTY_VALUE;
      ext_RejectBBUP[i] = EMPTY_VALUE;
      ext_RejectBBDOWN[i] = EMPTY_VALUE;
      csaa_sell[i] = EMPTY_VALUE;
      csaa_buy[i] = EMPTY_VALUE;
      EMA50outsideBB[i] = EMPTY_VALUE;
      ZeroLoss[i] = EMPTY_VALUE;
     
      // MiddleBuffer Color Logic
      MiddleBufferColors[i] = 0; // standart

      // EMA50 above MiddleBuffer and MAH and MAL below MiddleBuffer → Red Zone
      if (EMA50[i] >= MiddleBuffer[i] && mahi10[i] <= MiddleBuffer[i] && mahi5[i] <= MiddleBuffer[i] && malo10[i] <= MiddleBuffer[i] && malo5[i] <= MiddleBuffer[i])
      {
         MiddleBufferColors[i] = 1;
         ZeroLoss[i] = -1;
      }

      // EMA50 below MiddleBuffer and MAH and MAL above MiddleBuffer → Green Zone
      if (EMA50[i] <= MiddleBuffer[i] && mahi10[i] >= MiddleBuffer[i] && mahi5[i] >= MiddleBuffer[i] && malo10[i] >= MiddleBuffer[i] && malo5[i] >= MiddleBuffer[i])
      {
         MiddleBufferColors[i] = 2;
         ZeroLoss[i] = 1;
      }

      if (EMA50[i] > UpperBand[i])
         EMA50outsideBB[i] = 1; // EMA50 über UpperBand
      if (EMA50[i] < LowerBand[i])
         EMA50outsideBB[i] = -1; // EMA50 unter LowerBand

      // EMA50 Color Logic
      if (EMA50[i] > UpperBand[i] || EMA50[i] < LowerBand[i])
         EMA50Colors[i] = 1; // Gold
      else
         EMA50Colors[i] = 0; // LimeGreen

      BBmCross = 0;
      ema50Cross = 0;

      // last_BBmCross
      if (close[i - 1] < MiddleBuffer[i - 1] && close[i] > MiddleBuffer[i])
      {
         BBmCross = 1;
      }
      if (close[i - 1] > MiddleBuffer[i - 1] && close[i] < MiddleBuffer[i])
      {
         BBmCross = -1;
      }

      // last_ema50Cross
      if (close[i - 1] < EMA50[i - 1] && close[i] > EMA50[i])
      {
         ema50Cross = 1;
      }
      if (close[i - 1] > EMA50[i - 1] && close[i] < EMA50[i])
      {
         ema50Cross = -1;
      }

      // CSAA Signal
      if (malo10[i] > MiddleBuffer[i] && malo5[i] > MiddleBuffer[i] && open[i] > close[i] && close[i] < malo10[i] && close[i] < malo5[i] && close[i] > MiddleBuffer[i])
      {
         csaa_sell[i] = currentSellPos;
         currentSellPos += gap;
      }
      if (mahi10[i] < MiddleBuffer[i] && mahi5[i] < MiddleBuffer[i] && open[i] < close[i] && close[i] > mahi10[i] && close[i] > mahi5[i] && close[i] < MiddleBuffer[i])
      {
         csaa_buy[i] = currentBuyPos;
         currentBuyPos -= gap;
      }

      // MasterSig
      if ((BBmCross == -1 && close[i] < EMA50[i]) || (ema50Cross == -1 && close[i] < MiddleBuffer[i]))
      {
         CrossEMA50mBB_sell[i] = currentBuyPos;
         currentBuyPos -= gap;
      }
      if ((BBmCross == 1 && close[i] > EMA50[i]) || (ema50Cross == 1 && close[i] > MiddleBuffer[i]))
      {
         CrossEMA50mBB_buy[i] = currentSellPos;
         currentSellPos += gap;
      }

      // CSAK Signal
      if (open[i] > MiddleBuffer[i] && close[i] < MiddleBuffer[i] && close[i] < malo5[i] && close[i] < malo10[i])
      {
         csak_sell[i] = currentSellPos;
         currentSellPos += gap;
      }
      if (open[i - 1] > MiddleBuffer[i - 1] && close[i - 1] > MiddleBuffer[i - 1] && close[i] < MiddleBuffer[i] && open[i] < MiddleBuffer[i] && close[i] < malo5[i] && close[i] < malo10[i])
      {
         csak_sell[i] = currentSellPos;
         currentSellPos += gap;
      }

      if (open[i] < MiddleBuffer[i] && close[i] > MiddleBuffer[i] && close[i] > mahi5[i] && close[i] > mahi10[i])
      {
         csak_buy[i] = currentBuyPos;
         currentBuyPos -= gap;
      }
      if (open[i - 1] < MiddleBuffer[i - 1] && close[i - 1] < MiddleBuffer[i - 1] && close[i] > MiddleBuffer[i] && open[i] > MiddleBuffer[i] && close[i] > mahi5[i] && close[i] > mahi10[i])
      {
         csak_buy[i] = currentBuyPos;
         currentBuyPos -= gap;
      }

      // CSAK2 Signal
      if (open[i] < MiddleBuffer[i] && close[i] < MiddleBuffer[i] && close[i] < malo5[i] && close[i] < malo10[i] && close[i] > LowerBand[i] && csak_sell[i] == EMPTY_VALUE)
      {
         csak2_sell[i] = currentSellPos;
         currentSellPos += gap;
      }
      if (open[i] > MiddleBuffer[i] && close[i] > MiddleBuffer[i] && close[i] > mahi5[i] && close[i] > mahi10[i] && close[i] < UpperBand[i] && csak_buy[i] == EMPTY_VALUE)
      {
         csak2_buy[i] = currentBuyPos;
         currentBuyPos -= gap;
      }

      // Extrem Signal
      if ((mahi5[i] >= UpperBand[i] || mahi5[i - 1] >= UpperBand[i - 1] || mahi5[i - 2] >= UpperBand[i - 2]) && (close[i] < open[i] || close[i - 1] < open[i - 1]) && ((high[i] >= UpperBand[i] && close[i] < UpperBand[i]) || (high[i - 1] >= UpperBand[i] && close[i] < UpperBand[i]) || (open[i] <= UpperBand[i] && close[i - 1] >= UpperBand[i - 1])) && ext_sell[i - 1] == EMPTY_VALUE && ext_sell[i - 2] == EMPTY_VALUE)
      {
         ext_sell[i] = currentSellPos;
         currentSellPos += gap;
      }

      if ((malo5[i] <= LowerBand[i] || malo5[i - 1] <= LowerBand[i - 1] || malo5[i - 2] <= LowerBand[i - 2]) && (close[i] > open[i] || close[i - 1] > open[i - 1]) && ((low[i] <= LowerBand[i] && close[i] > LowerBand[i]) || (low[i - 1] <= LowerBand[i - 1] && close[i] > LowerBand[i]) || (open[i] >= LowerBand[i] && close[i - 1] <= LowerBand[i - 1])) && ext_buy[i - 1] == EMPTY_VALUE && ext_buy[i - 2] == EMPTY_VALUE)
      {
         ext_buy[i] = currentBuyPos;
         currentBuyPos -= gap;
      }

      if (ext_sell[i - 1] != EMPTY_VALUE)
      {
         tpwsell = 1;
         tpwbuy = 0;
      }

      if (ext_buy[i - 1] != EMPTY_VALUE)
      {
         tpwbuy = 1;
         tpwsell = 0;
      }

      // TPW Signal
      if (tpwsell == 1 && (low[i] <= malo5[i] || low[i] <= malo10[i]))
      {
         tpw_sell[i] = currentBuyPos;
         currentBuyPos -= gap;
         tpwsell = 2;
      }
      if (tpwbuy == 1 && (high[i] >= mahi5[i] || high[i] >= mahi10[i]))
      {
         tpw_buy[i] = currentSellPos;
         currentSellPos += gap;
         tpwbuy = 2;
      }

      // --- MHV Logic mit Rückwärts-Check für Stacking ---

      // 1. Gap für die vorherige Kerze (i-1) berechnen
      double gap_prev = 50 * Point();
      if (atrBuffer[i - 1] != 0 && atrBuffer[i - 1] != EMPTY_VALUE)
         gap_prev = atrBuffer[i - 1] * 0.20;

      // MHV Buy (wird unten gezeichnet)
      if (tpwbuy >= 2 && FractalDownBuffer[i - 1] != EMPTY_VALUE && tpw_buy[i] == EMPTY_VALUE && tpw_buy[i - 1] == EMPTY_VALUE && mmt_sell[i] == EMPTY_VALUE && mmt_sell[i - 1] == EMPTY_VALUE && low[i - 1] < MiddleBuffer[i - 1])
      {
         double pos = low[i - 1]; // Startposition am Low von i-1

         // Prüfe alle Buffer, die auf i-1 UNTEN (Buy-Seite) gezeichnet wurden
         // Dazu gehören: Buy-Signale UND tpw_sell/mmt_sell (die unten gezeichnet werden)
         double vals[] = {csak_buy[i - 1], csaa_buy[i - 1], CrossEMA50mBB_buy[i - 1], csak2_buy[i - 1], ext_buy[i - 1], tpw_sell[i - 1], mmt_sell[i - 1], ret_buy[i - 1], rejectedEMA50_buy[i - 1], GAPBBtoEMA50_buy[i - 1], CrossEMA50mBB_sell[i - 1]};

         for (int k = 0; k < ArraySize(vals); k++)
         {
            // Wenn dort schon ein Pfeil ist, schieben wir unsere Position weiter nach unten
            if (vals[k] != EMPTY_VALUE && vals[k] <= pos)
            {
               pos = vals[k] - gap_prev;
            }
         }
         MHV_buy[i - 1] = pos;
         tpwbuy = 3;
      }

      // MHV Sell (wird oben gezeichnet)
      if (tpwsell >= 2 && FractalUpBuffer[i - 1] != EMPTY_VALUE && tpw_sell[i] == EMPTY_VALUE && tpw_sell[i - 1] == EMPTY_VALUE && mmt_buy[i] == EMPTY_VALUE && mmt_buy[i - 1] == EMPTY_VALUE && high[i - 1] > MiddleBuffer[i - 1])
      {
         double pos = high[i - 1]; // Startposition am High von i-1

         // Prüfe alle Buffer, die auf i-1 OBEN (Sell-Seite) gezeichnet wurden
         // Dazu gehören: Sell-Signale UND tpw_buy/mmt_buy (die oben gezeichnet werden)
         double vals[] = {csak_sell[i - 1], csaa_sell[i - 1], CrossEMA50mBB_sell[i - 1], csak2_sell[i - 1], ext_sell[i - 1], tpw_buy[i - 1], mmt_buy[i - 1], ret_sell[i - 1], rejectedEMA50_sell[i - 1], GAPBBtoEMA50_sell[i - 1], CrossEMA50mBB_buy[i - 1]};

         for (int k = 0; k < ArraySize(vals); k++)
         {
            // Wenn dort schon ein Pfeil ist, schieben wir unsere Position weiter nach oben
            if (vals[k] != EMPTY_VALUE && vals[k] >= pos)
            {
               pos = vals[k] + gap_prev;
            }
         }
         MHV_sell[i - 1] = pos;
         tpwsell = 3;
      }

      if (tpwbuy >= 2 && high[i - 1] > UpperBand[i - 1])
         tpwbuy = 0;
      // if (tpwsell >= 2 && low[i - 1] < LowerBand[i - 1])
      //  tpwsell = 0;

      // Momentum Signal
      if (close[i] >= UpperBand[i] && ext_sell[i] == EMPTY_VALUE)
      {
         mmt_buy[i] = currentSellPos;
         currentSellPos += gap;
      }
      if (close[i] <= LowerBand[i] && ext_buy[i] == EMPTY_VALUE)
      {
         mmt_sell[i] = currentBuyPos;
         currentBuyPos -= gap;
      }

      // Rentry Signal Tradingview-version
      // if( (high[i]>=mahi5[i]||high[i]>=mahi10[i]) &&  close[i]<=mahi5[i] && close[i]<=mahi10[i] && close[i]<=MiddleBuffer[i] && (mahi5[i] <=MiddleBuffer[i]||mahi10[i] <=MiddleBuffer[i])  ) ret_sell[i]=high[i];
      // if( (low[i]<=malo5[i]||low[i]<=malo10[i]) &&  close[i]>=malo5[i] && close[i]>=malo10[i] && close[i]>=MiddleBuffer[i] && (malo5[i] >= MiddleBuffer[i]||malo10[i] >= MiddleBuffer[i])  ) ret_buy[i]=low[i];

      // Reentry 2 Signal AllBBMA-version
      if ((high[i] >= mahi5[i] || high[i] >= mahi10[i]) && (close[i] <= mahi5[i] || close[i] <= mahi10[i]) && close[i] <= MiddleBuffer[i])
      {
         ret_sell[i] = currentSellPos;
         currentSellPos += gap;
      }
      if ((low[i] <= malo5[i] || low[i] <= malo10[i]) && (close[i] >= malo5[i] || close[i] >= malo10[i]) && close[i] >= MiddleBuffer[i])
      {
         ret_buy[i] = currentBuyPos;
         currentBuyPos -= gap;
      }

      // rejectedEMA50
      bool upTrend = (low[i] > EMA50[i]) && (low[i - 1] > EMA50[i - 1]);
      bool downTrend = (high[i] < EMA50[i]) && (high[i - 1] < EMA50[i - 1]);
      bool bigBody = MathAbs(close[i] - open[i]) > 0.5 * atrBuffer[i];
      
      // Optimization: Pass limits to avoid scanning full history
      int sinceBigBody = BarsSinceBigBody(i, close, open, atrBuffer, 6);
      int sinceDownTrend = BarsSinceTrend(i, high, low, EMA50, true, 4);
      int sinceUpTrend = BarsSinceTrend(i, high, low, EMA50, false, 4);

      bool RejSell = (high[i] > EMA50[i]) && (close[i] < EMA50[i]) //&& (close[i] < open[i])
                     && (sinceDownTrend < 4) && (sinceBigBody < 6);

      bool RejBuy = (low[i] < EMA50[i]) && (close[i] > EMA50[i]) //&& (close[i] > open[i])
                    && (sinceUpTrend < 4) && (sinceBigBody < 6);

      if (RejBuy)
      {
         rejectedEMA50_buy[i] = currentBuyPos;
         currentBuyPos -= gap;
      }
      if (RejSell)
      {
         rejectedEMA50_sell[i] = currentSellPos;
         currentSellPos += gap;
      }

      // GAPBBtoEMA50
      if ((EMA50[i - 1] > UpperBand[i - 1] || EMA50[i - 2] > UpperBand[i - 2] || EMA50[i - 3] > UpperBand[i - 3] || EMA50[i] > UpperBand[i]) &&
          (close[i] < open[i] && close[i] < UpperBand[i]) &&
          (high[i] >= UpperBand[i] || high[i - 1] >= UpperBand[i - 1] || high[i - 2] >= UpperBand[i - 2]))
      {
         GAPBBtoEMA50_sell[i] = currentSellPos;
         currentSellPos += gap;
      }

      if ((EMA50[i - 1] < LowerBand[i - 1] || EMA50[i - 2] < LowerBand[i - 2] || EMA50[i - 3] < LowerBand[i - 3] || EMA50[i] < LowerBand[i]) &&
          (close[i] > open[i] && close[i] > LowerBand[i]) &&
          (low[i] <= LowerBand[i] || low[i - 1] <= LowerBand[i - 1] || low[i - 2] <= LowerBand[i - 2]))
      {
         GAPBBtoEMA50_buy[i] = currentBuyPos;
         currentBuyPos -= gap;
      }

      // RejectBBDOWN & UP
      if ((high[i] > UpperBand[i]) && close[i] < UpperBand[i] && open[i] < UpperBand[i])
         ext_RejectBBUP[i] = UpperBand[i];
      // RejectBBDOWN & UP
      if ((low[i] < LowerBand[i]) && close[i] > LowerBand[i] && open[i] > LowerBand[i])
         ext_RejectBBDOWN[i] = LowerBand[i];
   }

   //--- den Wert prev_calculated für den nächsten Anruf zurückgeben
   return (rates_total);
}

//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   IndicatorRelease(handleBands);
   IndicatorRelease(handleEMA50);
   IndicatorRelease(handleMAhi10);
   IndicatorRelease(handleMAhi5);
   IndicatorRelease(handleMAlo10);
   IndicatorRelease(handleMAlo5);
   IndicatorRelease(handleMAhi5H4);
   IndicatorRelease(handleMAhi10H4);
   IndicatorRelease(handleMAlo5H4);
   IndicatorRelease(handleMAlo10H4);
   IndicatorRelease(atrHandle);
   
}

//+------------------------------------------------------------------+
//| Helper: BarsSinceBigBody with limit                              |
//+------------------------------------------------------------------+
int BarsSinceBigBody(int shift, const double &close[], const double &open[], const double &atr[], int limit)
{
   int count = 0;
   for (int j = shift - 1; j >= 0 && count < limit; j--)
   {
      bool bigBody = MathAbs(close[j] - open[j]) > 0.5 * atr[j];
      if (bigBody)
         return count;
      count++;
   }
   return 9999;
}

//+------------------------------------------------------------------+
//| BarsSinceTrend: prüft letzte Up/DownTrend-Bedingung              |
//| isDown = true → Downtrend, false → Uptrend                       |
//+------------------------------------------------------------------+
int BarsSinceTrend(int index, const double &high[], const double &low[], const double &ema[], bool isDown, int limit)
{
   int count = 0;
   for (int j = index - 1; j >= 1 && count < limit; j--)
   {
      bool cond = isDown
                      ? ((high[j] < ema[j]) && (high[j - 1] < ema[j - 1]))
                      : ((low[j] > ema[j]) && (low[j - 1] > ema[j - 1]));

      if (cond)
         return count;
      count++;
   }
   return 9999;
}

//+------------------------------------------------------------------+
//| Helper: Calculate Dynamic Fractals                               |
//+------------------------------------------------------------------+
void CalculateDynamicFractals(int i, const double &high[], const double &low[],
                              double &upBuf[], double &dnBuf[],
                              int barsLeft, int barsRight)
{
   // Sicherheitscheck: Negative Inputs verhindern
   if (barsLeft < 0)
      barsLeft = 0;
   if (barsRight < 0)
      barsRight = 0;

   // Wir berechnen das Fraktal für den Index 'fIdx', da wir 'BarsRight' in die Zukunft schauen müssen.
   // Wenn wir bei Kerze 'i' sind, ist das potenzielle Fraktal bei 'i - barsRight'.
   int fIdx = i - barsRight;

   // Sicherheitscheck: Genug Bars links vorhanden?
   if (fIdx < barsLeft)
      return;

   // Sicherheitscheck: Array-Grenzen prüfen (verhindert Crash)
   if (fIdx >= ArraySize(high) || fIdx < 0)
      return;

   // 1. Fractal UP (Highs)
   bool isFractalUp = true;
   double price_curr_up = high[fIdx];

   // Check Left
   for (int l = 1; l <= barsLeft; l++)
   {
      int idx = fIdx - l;
      if (idx < 0)
      {
         isFractalUp = false;
         break;
      }
      if (price_curr_up < high[idx])
      {
         isFractalUp = false;
         break;
      }
   }
   // Check Right (nur wenn links ok)
   if (isFractalUp)
   {
      for (int r = 1; r <= barsRight; r++)
      {
         int idx = fIdx + r;
         if (idx >= ArraySize(high))
         {
            isFractalUp = false;
            break;
         }
         // Dynamic Fractal Logik: rechts muss strikt kleiner sein
         if (price_curr_up <= high[idx])
         {
            isFractalUp = false;
            break;
         }
      }
   }
   upBuf[fIdx] = isFractalUp ? price_curr_up : EMPTY_VALUE;

   // 2. Fractal DOWN (Lows)
   bool isFractalDown = true;
   double price_curr_dn = low[fIdx];

   // Check Left
   for (int l = 1; l <= barsLeft; l++)
   {
      int idx = fIdx - l;
      if (idx < 0)
      {
         isFractalDown = false;
         break;
      }
      if (price_curr_dn > low[idx])
      {
         isFractalDown = false;
         break;
      }
   }
   // Check Right (nur wenn links ok)
   if (isFractalDown)
   {
      for (int r = 1; r <= barsRight; r++)
      {
         int idx = fIdx + r;
         if (idx >= ArraySize(low))
         {
            isFractalDown = false;
            break;
         }
         // Dynamic Fractal Logik: rechts muss strikt größer sein
         if (price_curr_dn >= low[idx])
         {
            isFractalDown = false;
            break;
         }
      }
   }
   dnBuf[fIdx] = isFractalDown ? price_curr_dn : EMPTY_VALUE;
}

// Telegram.mqh - Telegram Communication Include File              
bool SendMessageToTelegram(string message, string chatId, string botToken)
  {
   string url = "https://api.telegram.org/bot" + botToken + "/sendMessage";
   string jsonMessage = "{\"chat_id\":\"" + chatId + "\", \"text\":\"" + message + "\"}";

   char postData[];
   ArrayResize(postData, StringToCharArray(jsonMessage, postData) - 1);

   int timeout = 5000;
   char result[];
   string responseHeaders;
   int responseCode = WebRequest("POST", url, "Content-Type: application/json\r\n", timeout, postData, result, responseHeaders);

   if (responseCode == 200)
     {
      Print("Message sent successfully: ", message);
      return true;
     }
   else
     {
      Print("Failed to send message. HTTP code: ", responseCode, " Error code: ", GetLastError());
      Print("Response: ", CharArrayToString(result));
      return false;
     }
  }
//+------------------------------------------------------------------+

