//+------------------------------------------------------------------+
//|                                         ExMachina_HeikinAshi.mq5 |
//|                        Copyright 2026, ExMachina Trading Systems |
//|                       https://www.mql5.com/en/users/williammukam |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, ExMachina Trading Systems"
#property link        "https://www.mql5.com/en/users/williammukam"
#property version     "3.00"
#property description "ExMachina Heikin Ashi Enhanced v3.0"
#property description "HA candles or color line overlay on main chart."
#property description "5 smoothing methods - Step filter - MTF - Signal arrows"
#property description "Dashboard - Streak counter - Strength meter"
#property description "Popup / Sound / Push / Email alerts"
#property description "Precision before profit."
#property indicator_chart_window
#property indicator_buffers 14
#property indicator_plots   3
#property strict

//--- Plot 1: Color Line mode
#property indicator_label1  "HA Line"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLime,clrRed,clrGray
#property indicator_width1  2

//--- Plot 2: Color Candles mode
#property indicator_label2  "HA Open;HA High;HA Low;HA Close"
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  clrLime,clrRed,clrGray
#property indicator_width2  2

//--- Plot 3: Signal Arrows on color change
#property indicator_label3  "Signal"
#property indicator_type3   DRAW_COLOR_ARROW
#property indicator_color3  clrLime,clrRed
#property indicator_width3  2

//+------------------------------------------------------------------+
//| Enumerations                                                      |
//+------------------------------------------------------------------+
enum ENUM_HA_DRAW_MODE
{
   HA_DRAW_LINE    = 0,   // Color Line
   HA_DRAW_CANDLES = 1    // Color Candles
};

enum ENUM_HA_SMOOTH_METHOD
{
   HA_SMOOTH_NONE   = 0,  // None (raw HA)
   HA_SMOOTH_SMA    = 1,  // Simple Moving Average
   HA_SMOOTH_EMA    = 2,  // Exponential Moving Average
   HA_SMOOTH_DEMA   = 3,  // Double-Smoothed EMA (Vervoort)
   HA_SMOOTH_SMMA   = 4,  // Smoothed Moving Average
   HA_SMOOTH_LWMA   = 5   // Linear Weighted Moving Average
};

//+------------------------------------------------------------------+
//| Inputs -General                                                  |
//+------------------------------------------------------------------+
input group                 "====== General ======"
input ENUM_HA_DRAW_MODE     InpDrawMode       = HA_DRAW_CANDLES;   // Draw Mode
input ENUM_TIMEFRAMES       InpMTFTimeframe   = PERIOD_CURRENT;    // MTF Timeframe (CURRENT = same)

input group                 "====== Smoothing ======"
input ENUM_HA_SMOOTH_METHOD InpSmoothMethod   = HA_SMOOTH_NONE;    // Smoothing Method
input int                   InpSmoothPeriod   = 6;                 // Smoothing Period (>=2 if enabled)

input group                 "====== Step Filter ======"
input double                InpStepPips       = 0.0;               // Step Filter (pips, 0=off)

input group                 "====== Signal Arrows ======"
input bool                  InpShowArrows     = true;              // Show Signal Arrows
input int                   InpArrowCode      = 159;               // Arrow Code (Wingdings)
input int                   InpArrowSize      = 2;                 // Arrow Size (1-5)
input int                   InpArrowOffset    = 10;                // Arrow Offset (points from H/L)

input group                 "====== Colors ======"
input color                 InpBullColor      = C'0,185,140';      // Bull Color
input color                 InpBearColor      = C'220,50,80';      // Bear Color
input color                 InpNeutralColor   = C'90,95,110';      // Neutral Color

input group                 "====== Alerts ======"
input bool                  InpAlertOnChange  = true;              // Alert on Color Change
input bool                  InpAlertPopup     = true;              // Popup Alert
input bool                  InpAlertSound     = true;              // Sound Alert
input bool                  InpAlertPush      = false;             // Push Notification
input bool                  InpAlertEmail     = false;             // Email Alert
input string                InpAlertSoundFile = "alert.wav";       // Sound File

input group                 "====== Dashboard ======"
input bool                  InpShowDashboard  = true;              // Show Dashboard
input int                   InpDashX          = 20;                // Dashboard X Position
input int                   InpDashY          = 40;                // Dashboard Y Position
input int                   InpDashFontSize   = 9;                 // Dashboard Font Size
input color                 InpDashBgColor    = C'8,10,18';        // Dashboard Background
input color                 InpDashBorderColor= C'30,34,46';       // Dashboard Border
input color                 InpDashTextColor  = C'160,168,180';    // Dashboard Text Color
input color                 InpDashTitleColor = C'90,180,220';     // Dashboard Title Color

//+------------------------------------------------------------------+
//| Constants                                                         |
//+------------------------------------------------------------------+
#define PREFIX           "EXHA_"
#define DASH_WIDTH       270
#define FONT_NAME        "Consolas"
#define COLOR_BULL_IDX   0
#define COLOR_BEAR_IDX   1
#define COLOR_NEUT_IDX   2

//+------------------------------------------------------------------+
//| Buffers                                                           |
//+------------------------------------------------------------------+
//--- Plot 1: Line
double   g_bufLine[];           // 0
double   g_bufLineColor[];      // 1

//--- Plot 2: Candles (OHLC)
double   g_bufCandleOpen[];     // 2
double   g_bufCandleHigh[];     // 3
double   g_bufCandleLow[];      // 4
double   g_bufCandleClose[];    // 5
double   g_bufCandleColor[];    // 6

//--- Plot 3: Signal Arrows
double   g_bufArrow[];          // 7
double   g_bufArrowColor[];     // 8

//--- Calculation buffers
double   g_bufRawOpen[];        // 9
double   g_bufRawClose[];       // 10
double   g_bufSmooth[];         // 11 - smoothed mid (EMA first pass)
double   g_bufSmooth2[];        // 12 - second EMA pass (for DEMA)
double   g_bufStepVal[];        // 13 - step-filtered output

//+------------------------------------------------------------------+
//| Globals                                                           |
//+------------------------------------------------------------------+
datetime g_lastAlertTime     = 0;
int      g_smoothPeriod      = 1;
bool     g_isMTF             = false;
int      g_consecutiveCount  = 0;
int      g_consecutiveDir    = -1;
double   g_stepSize          = 0.0;
double   g_pointValue        = 0.0;

//+------------------------------------------------------------------+
//| OnInit                                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Validate smoothing
   g_smoothPeriod = (InpSmoothMethod == HA_SMOOTH_NONE) ? 1 : MathMax(2, InpSmoothPeriod);

   //--- Detect MTF
   g_isMTF = (InpMTFTimeframe != PERIOD_CURRENT && InpMTFTimeframe != _Period);

   //--- Step filter in price terms
   g_pointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int symbolDigits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double pipSize = (symbolDigits == 3 || symbolDigits == 5) ? g_pointValue * 10.0 : g_pointValue;
   g_stepSize = InpStepPips * pipSize;

   //--- Bind buffers
   SetIndexBuffer(0,  g_bufLine,         INDICATOR_DATA);
   SetIndexBuffer(1,  g_bufLineColor,    INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,  g_bufCandleOpen,   INDICATOR_DATA);
   SetIndexBuffer(3,  g_bufCandleHigh,   INDICATOR_DATA);
   SetIndexBuffer(4,  g_bufCandleLow,    INDICATOR_DATA);
   SetIndexBuffer(5,  g_bufCandleClose,  INDICATOR_DATA);
   SetIndexBuffer(6,  g_bufCandleColor,  INDICATOR_COLOR_INDEX);
   SetIndexBuffer(7,  g_bufArrow,        INDICATOR_DATA);
   SetIndexBuffer(8,  g_bufArrowColor,   INDICATOR_COLOR_INDEX);
   SetIndexBuffer(9,  g_bufRawOpen,      INDICATOR_CALCULATIONS);
   SetIndexBuffer(10, g_bufRawClose,     INDICATOR_CALCULATIONS);
   SetIndexBuffer(11, g_bufSmooth,       INDICATOR_CALCULATIONS);
   SetIndexBuffer(12, g_bufSmooth2,      INDICATOR_CALCULATIONS);
   SetIndexBuffer(13, g_bufStepVal,      INDICATOR_CALCULATIONS);

   //--- Configure draw types
   if(InpDrawMode == HA_DRAW_LINE)
   {
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_COLOR_LINE);
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
   }
   else
   {
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_COLOR_CANDLES);
   }

   //--- Arrows
   if(InpShowArrows)
   {
      PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_COLOR_ARROW);
      PlotIndexSetInteger(2, PLOT_ARROW, InpArrowCode);
      PlotIndexSetInteger(2, PLOT_LINE_WIDTH, InpArrowSize);
   }
   else
      PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);

   //--- Colors for all plots
   for(int p = 0; p <= 2; p++)
   {
      PlotIndexSetDouble(p, PLOT_EMPTY_VALUE, EMPTY_VALUE);
      if(p < 2)
      {
         PlotIndexSetInteger(p, PLOT_COLOR_INDEXES, 3);
         PlotIndexSetInteger(p, PLOT_LINE_COLOR, COLOR_BULL_IDX, InpBullColor);
         PlotIndexSetInteger(p, PLOT_LINE_COLOR, COLOR_BEAR_IDX, InpBearColor);
         PlotIndexSetInteger(p, PLOT_LINE_COLOR, COLOR_NEUT_IDX, InpNeutralColor);
      }
      else
      {
         PlotIndexSetInteger(p, PLOT_COLOR_INDEXES, 2);
         PlotIndexSetInteger(p, PLOT_LINE_COLOR, 0, InpBullColor);
         PlotIndexSetInteger(p, PLOT_LINE_COLOR, 1, InpBearColor);
      }
   }

   //--- Short name
   string smoothLabel = "";
   if(InpSmoothMethod != HA_SMOOTH_NONE)
      smoothLabel = "," + SmoothMethodName() + "(" + IntegerToString(g_smoothPeriod) + ")";
   string stepLabel = (g_stepSize > 0) ? ",Step=" + DoubleToString(InpStepPips, 1) : "";
   string mtfLabel  = g_isMTF ? "," + EnumToString(InpMTFTimeframe) : "";
   IndicatorSetString(INDICATOR_SHORTNAME, "ExMachina HA" + smoothLabel + stepLabel + mtfLabel);

   //--- Dashboard
   if(InpShowDashboard)
      DashboardCreate();

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| OnDeinit                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, PREFIX);
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| OnCalculate                                                       |
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
   if(rates_total < 2)
      return(0);

   if(g_isMTF)
      return CalcMTF(rates_total, prev_calculated, time, open, high, low, close);

   return CalcStandard(rates_total, prev_calculated, time, open, high, low, close);
}

//+------------------------------------------------------------------+
//| Standard (same-timeframe) calculation                             |
//+------------------------------------------------------------------+
int CalcStandard(const int rates_total,
                 const int prev_calculated,
                 const datetime &time[],
                 const double &open[],
                 const double &high[],
                 const double &low[],
                 const double &close[])
{
   int start = (prev_calculated == 0) ? 1 : prev_calculated - 1;

   //--- Seed bar 0
   if(prev_calculated == 0)
   {
      g_bufRawClose[0] = (open[0] + high[0] + low[0] + close[0]) / 4.0;
      g_bufRawOpen[0]  = (open[0] + close[0]) / 2.0;
      g_bufSmooth[0]   = (g_bufRawClose[0] + g_bufRawOpen[0]) / 2.0;
      g_bufSmooth2[0]  = g_bufSmooth[0];
      g_bufStepVal[0]  = g_bufSmooth[0];
      AssignBar(0, g_bufRawOpen[0], high[0], low[0], g_bufRawClose[0], COLOR_NEUT_IDX);
      g_bufArrow[0]      = EMPTY_VALUE;
      g_bufArrowColor[0] = 0;
   }

   //--- Main loop
   for(int i = start; i < rates_total; i++)
   {
      //--- Raw HA OHLC
      g_bufRawClose[i] = (open[i] + high[i] + low[i] + close[i]) / 4.0;
      g_bufRawOpen[i]  = (g_bufRawOpen[i-1] + g_bufRawClose[i-1]) / 2.0;

      double haHigh = MathMax(high[i], MathMax(g_bufRawOpen[i], g_bufRawClose[i]));
      double haLow  = MathMin(low[i],  MathMin(g_bufRawOpen[i], g_bufRawClose[i]));

      //--- Smoothing
      double smoothedMid = ApplySmoothing(i);

      //--- For DEMA the buffer is set inside ApplySmoothing; for others set it here
      if(InpSmoothMethod != HA_SMOOTH_DEMA)
         g_bufSmooth[i] = smoothedMid;

      //--- Step filter
      double stepVal = ApplyStepFilter(i, smoothedMid);
      g_bufStepVal[i] = stepVal;

      //--- Color index
      int colorIdx;
      if(g_stepSize > 0)
         colorIdx = (stepVal > g_bufStepVal[i-1]) ? COLOR_BULL_IDX :
                    (stepVal < g_bufStepVal[i-1]) ? COLOR_BEAR_IDX : COLOR_NEUT_IDX;
      else
         colorIdx = (g_bufRawClose[i] > g_bufRawOpen[i]) ? COLOR_BULL_IDX :
                    (g_bufRawClose[i] < g_bufRawOpen[i]) ? COLOR_BEAR_IDX : COLOR_NEUT_IDX;

      //--- Assign to active plot
      AssignBar(i, g_bufRawOpen[i], haHigh, haLow, g_bufRawClose[i], colorIdx);

      //--- For line mode, use smoothed/step value
      if(InpDrawMode == HA_DRAW_LINE)
         g_bufLine[i] = (g_stepSize > 0) ? stepVal : smoothedMid;

      //--- Signal arrows on color change
      g_bufArrow[i] = EMPTY_VALUE;
      if(InpShowArrows && i > 0)
      {
         int prevColorIdx = GetBarColor(i - 1);
         if(colorIdx != prevColorIdx && colorIdx != COLOR_NEUT_IDX)
         {
            double offset = InpArrowOffset * g_pointValue;
            if(colorIdx == COLOR_BULL_IDX)
            {
               g_bufArrow[i]      = haLow - offset;
               g_bufArrowColor[i] = 0;
            }
            else
            {
               g_bufArrow[i]      = haHigh + offset;
               g_bufArrowColor[i] = 1;
            }
         }
      }
   }

   //--- Post-loop
   if(rates_total > 2)
   {
      int lb = rates_total - 2;
      ProcessAlert(lb, time[lb]);
      UpdateConsecutive(lb);
   }

   if(InpShowDashboard && rates_total > 1)
      DashboardUpdate(rates_total);

   return(rates_total);
}

//+------------------------------------------------------------------+
//| MTF calculation                                                   |
//+------------------------------------------------------------------+
int CalcMTF(const int rates_total,
            const int prev_calculated,
            const datetime &time[],
            const double &open[],
            const double &high[],
            const double &low[],
            const double &close[])
{
   int mtfBars = iBars(_Symbol, InpMTFTimeframe);
   if(mtfBars < 2)
      return(0);

   int copyBars = MathMin(mtfBars, rates_total);
   double mtfOpen[], mtfHigh[], mtfLow[], mtfClose[];
   datetime mtfTime[];

   if(CopyOpen(_Symbol,  InpMTFTimeframe, 0, copyBars, mtfOpen)  <= 0) return(0);
   if(CopyHigh(_Symbol,  InpMTFTimeframe, 0, copyBars, mtfHigh)  <= 0) return(0);
   if(CopyLow(_Symbol,   InpMTFTimeframe, 0, copyBars, mtfLow)   <= 0) return(0);
   if(CopyClose(_Symbol, InpMTFTimeframe, 0, copyBars, mtfClose) <= 0) return(0);
   if(CopyTime(_Symbol,  InpMTFTimeframe, 0, copyBars, mtfTime)  <= 0) return(0);

   //--- Compute HA on MTF data
   int mtfTotal = ArraySize(mtfOpen);
   double haO[], haC[], haH[], haL[];
   ArrayResize(haO, mtfTotal);
   ArrayResize(haC, mtfTotal);
   ArrayResize(haH, mtfTotal);
   ArrayResize(haL, mtfTotal);

   haC[0] = (mtfOpen[0] + mtfHigh[0] + mtfLow[0] + mtfClose[0]) / 4.0;
   haO[0] = (mtfOpen[0] + mtfClose[0]) / 2.0;
   haH[0] = mtfHigh[0];
   haL[0] = mtfLow[0];

   for(int m = 1; m < mtfTotal; m++)
   {
      haC[m] = (mtfOpen[m] + mtfHigh[m] + mtfLow[m] + mtfClose[m]) / 4.0;
      haO[m] = (haO[m-1] + haC[m-1]) / 2.0;
      haH[m] = MathMax(mtfHigh[m], MathMax(haO[m], haC[m]));
      haL[m] = MathMin(mtfLow[m],  MathMin(haO[m], haC[m]));
   }

   //--- Map MTF HA onto current TF
   int start = (prev_calculated == 0) ? 0 : prev_calculated - 1;
   int prevMtfIdx = -1;

   for(int i = start; i < rates_total; i++)
   {
      int mtfIdx = FindMTFBar(time[i], mtfTime, mtfTotal);

      if(mtfIdx < 0)
      {
         AssignBar(i, EMPTY_VALUE, EMPTY_VALUE, EMPTY_VALUE, EMPTY_VALUE, COLOR_NEUT_IDX);
         if(InpDrawMode == HA_DRAW_LINE) g_bufLine[i] = EMPTY_VALUE;
         g_bufArrow[i] = EMPTY_VALUE;
         continue;
      }

      int colorIdx = (haC[mtfIdx] > haO[mtfIdx]) ? COLOR_BULL_IDX :
                     (haC[mtfIdx] < haO[mtfIdx]) ? COLOR_BEAR_IDX : COLOR_NEUT_IDX;

      AssignBar(i, haO[mtfIdx], haH[mtfIdx], haL[mtfIdx], haC[mtfIdx], colorIdx);

      if(InpDrawMode == HA_DRAW_LINE)
         g_bufLine[i] = (haC[mtfIdx] + haO[mtfIdx]) / 2.0;

      g_bufRawOpen[i]  = haO[mtfIdx];
      g_bufRawClose[i] = haC[mtfIdx];

      //--- Arrows at MTF bar transitions
      g_bufArrow[i] = EMPTY_VALUE;
      if(InpShowArrows && prevMtfIdx >= 0 && mtfIdx != prevMtfIdx)
      {
         int prevCol = (haC[prevMtfIdx] > haO[prevMtfIdx]) ? COLOR_BULL_IDX :
                       (haC[prevMtfIdx] < haO[prevMtfIdx]) ? COLOR_BEAR_IDX : COLOR_NEUT_IDX;
         if(colorIdx != prevCol && colorIdx != COLOR_NEUT_IDX)
         {
            double offset = InpArrowOffset * g_pointValue;
            if(colorIdx == COLOR_BULL_IDX)
            {
               g_bufArrow[i]      = haL[mtfIdx] - offset;
               g_bufArrowColor[i] = 0;
            }
            else
            {
               g_bufArrow[i]      = haH[mtfIdx] + offset;
               g_bufArrowColor[i] = 1;
            }
         }
      }
      prevMtfIdx = mtfIdx;
   }

   //--- Post-loop
   if(rates_total > 2)
   {
      int lb = rates_total - 2;
      ProcessAlert(lb, time[lb]);
      UpdateConsecutive(lb);
   }

   if(InpShowDashboard && rates_total > 1)
      DashboardUpdate(rates_total);

   return(rates_total);
}

//+------------------------------------------------------------------+
//| Find MTF bar index for a given time (reverse scan)                |
//+------------------------------------------------------------------+
int FindMTFBar(const datetime barTime,
               const datetime &mtfTime[],
               const int mtfTotal)
{
   for(int m = mtfTotal - 1; m >= 0; m--)
   {
      if(barTime >= mtfTime[m])
         return m;
   }
   return -1;
}

//+------------------------------------------------------------------+
//| Apply smoothing to HA mid-point (buffer-based, no statics)        |
//+------------------------------------------------------------------+
double ApplySmoothing(const int idx)
{
   double mid = (g_bufRawClose[idx] + g_bufRawOpen[idx]) / 2.0;

   if(InpSmoothMethod == HA_SMOOTH_NONE || idx < g_smoothPeriod)
      return mid;

   switch(InpSmoothMethod)
   {
      case HA_SMOOTH_SMA:
      {
         double sum = 0.0;
         for(int j = 0; j < g_smoothPeriod; j++)
            sum += (g_bufRawClose[idx-j] + g_bufRawOpen[idx-j]) / 2.0;
         return sum / g_smoothPeriod;
      }
      case HA_SMOOTH_EMA:
      {
         double k = 2.0 / (g_smoothPeriod + 1.0);
         return mid * k + g_bufSmooth[idx-1] * (1.0 - k);
      }
      case HA_SMOOTH_DEMA:
      {
         //--- First EMA pass
         double k = 2.0 / (g_smoothPeriod + 1.0);
         double ema1 = mid * k + g_bufSmooth[idx-1] * (1.0 - k);
         g_bufSmooth[idx] = ema1;
         //--- Second EMA pass (stored in g_bufSmooth2)
         double ema2 = ema1 * k + g_bufSmooth2[idx-1] * (1.0 - k);
         g_bufSmooth2[idx] = ema2;
         //--- DEMA = 2*EMA1 - EMA2
         return 2.0 * ema1 - ema2;
      }
      case HA_SMOOTH_SMMA:
      {
         return (g_bufSmooth[idx-1] * (g_smoothPeriod - 1) + mid) / g_smoothPeriod;
      }
      case HA_SMOOTH_LWMA:
      {
         double wSum = 0.0, wDiv = 0.0;
         for(int j = 0; j < g_smoothPeriod; j++)
         {
            double w = (double)(g_smoothPeriod - j);
            wSum += w * (g_bufRawClose[idx-j] + g_bufRawOpen[idx-j]) / 2.0;
            wDiv += w;
         }
         return wSum / wDiv;
      }
   }
   return mid;
}

//+------------------------------------------------------------------+
//| Apply step filter (ignore changes smaller than threshold)         |
//+------------------------------------------------------------------+
double ApplyStepFilter(const int idx, const double value)
{
   if(g_stepSize <= 0 || idx < 1)
      return value;

   double prev = g_bufStepVal[idx - 1];
   if(MathAbs(value - prev) < g_stepSize)
      return prev;

   return value;
}

//+------------------------------------------------------------------+
//| Get color index for a bar                                         |
//+------------------------------------------------------------------+
int GetBarColor(const int i)
{
   if(InpDrawMode == HA_DRAW_LINE)
      return (int)g_bufLineColor[i];
   return (int)g_bufCandleColor[i];
}

//+------------------------------------------------------------------+
//| Assign values to the active plot buffers                          |
//+------------------------------------------------------------------+
void AssignBar(const int i,
               const double haOpen,
               const double haHigh,
               const double haLow,
               const double haClose,
               const int colorIdx)
{
   if(InpDrawMode == HA_DRAW_LINE)
   {
      g_bufLine[i]      = (haClose + haOpen) / 2.0;
      g_bufLineColor[i] = (double)colorIdx;
      g_bufCandleOpen[i]  = EMPTY_VALUE;
      g_bufCandleHigh[i]  = EMPTY_VALUE;
      g_bufCandleLow[i]   = EMPTY_VALUE;
      g_bufCandleClose[i] = EMPTY_VALUE;
   }
   else
   {
      //--- MT5 DRAW_COLOR_CANDLES renders Open>Close as filled (solid)
      //    and Open<Close as hollow (outline only, invisible on dark bg).
      //    To make ALL candles solid-filled, we always set Open = max, Close = min.
      //    The color index alone distinguishes bull vs bear.
      g_bufCandleOpen[i]  = MathMax(haOpen, haClose);
      g_bufCandleHigh[i]  = haHigh;
      g_bufCandleLow[i]   = haLow;
      g_bufCandleClose[i] = MathMin(haOpen, haClose);
      g_bufCandleColor[i] = (double)colorIdx;
      g_bufLine[i] = EMPTY_VALUE;
   }
}

//+------------------------------------------------------------------+
//| Update consecutive bar counter                                    |
//+------------------------------------------------------------------+
void UpdateConsecutive(const int barIdx)
{
   int colorIdx = GetBarColor(barIdx);

   if(colorIdx == g_consecutiveDir)
      g_consecutiveCount++;
   else
   {
      g_consecutiveDir   = colorIdx;
      g_consecutiveCount = 1;
   }
}

//+------------------------------------------------------------------+
//| Process alert on color change                                     |
//+------------------------------------------------------------------+
void ProcessAlert(const int barIdx, const datetime barTime)
{
   if(!InpAlertOnChange || barIdx < 1)
      return;

   int currColor = GetBarColor(barIdx);
   int prevColor = GetBarColor(barIdx - 1);

   if(currColor != prevColor && barTime > g_lastAlertTime)
   {
      string dir = (currColor == COLOR_BULL_IDX) ? "BULLISH" :
                   (currColor == COLOR_BEAR_IDX) ? "BEARISH" : "NEUTRAL";

      string tf  = g_isMTF ? EnumToString(InpMTFTimeframe) : EnumToString(_Period);
      string msg = "ExMachina HA | " + _Symbol + " " + tf + " | " + dir + " color change";

      if(InpAlertPopup)  Alert(msg);
      if(InpAlertSound)  PlaySound(InpAlertSoundFile);
      if(InpAlertPush)   SendNotification(msg);
      if(InpAlertEmail)  SendMail("ExMachina HA Alert", msg);
      Print(msg);

      g_lastAlertTime = barTime;
   }
}

//+------------------------------------------------------------------+
//| Smoothing method name for display                                 |
//+------------------------------------------------------------------+
string SmoothMethodName()
{
   switch(InpSmoothMethod)
   {
      case HA_SMOOTH_SMA:  return "SMA";
      case HA_SMOOTH_EMA:  return "EMA";
      case HA_SMOOTH_DEMA: return "DEMA";
      case HA_SMOOTH_SMMA: return "SMMA";
      case HA_SMOOTH_LWMA: return "LWMA";
      default:             return "OFF";
   }
}

//+------------------------------------------------------------------+
//| Dashboard -Create                                                |
//+------------------------------------------------------------------+
void DashboardCreate()
{
   string bgName = PREFIX + "BG";
   ObjectCreate(0, bgName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bgName, OBJPROP_XDISTANCE, InpDashX);
   ObjectSetInteger(0, bgName, OBJPROP_YDISTANCE, InpDashY);
   ObjectSetInteger(0, bgName, OBJPROP_XSIZE,     DASH_WIDTH);
   ObjectSetInteger(0, bgName, OBJPROP_YSIZE,     10);
   ObjectSetInteger(0, bgName, OBJPROP_BGCOLOR,    InpDashBgColor);
   ObjectSetInteger(0, bgName, OBJPROP_BORDER_COLOR, InpDashBorderColor);
   ObjectSetInteger(0, bgName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bgName, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bgName, OBJPROP_BACK,       false);
   ObjectSetInteger(0, bgName, OBJPROP_SELECTABLE,  false);

   int x0  = InpDashX + 12;
   int y0  = InpDashY + 10;
   int fs  = InpDashFontSize;
   int lh  = fs + 9;
   int xV  = InpDashX + 160;

   DL("Title", x0, y0, "EXMACHINA HEIKIN ASHI", InpDashTitleColor, fs + 1);
   y0 += lh + 2;
   DL("Sep1",  x0, y0, "------------------------------", InpDashBorderColor, fs - 2);
   y0 += lh - 3;

   DL("TrLbl",  x0, y0, "Trend:",         InpNeutralColor, fs);
   DL("TrVal",  xV, y0, "---",            InpDashTextColor, fs);
   y0 += lh;

   DL("SmLbl",  x0, y0, "Smoothing:",     InpNeutralColor, fs);
   string smT = (InpSmoothMethod == HA_SMOOTH_NONE) ? "OFF" :
                SmoothMethodName() + "(" + IntegerToString(g_smoothPeriod) + ")";
   DL("SmVal",  xV, y0, smT,              C'200,170,50', fs);
   y0 += lh;

   DL("StLbl",  x0, y0, "Step Filter:",   InpNeutralColor, fs);
   string stT = (g_stepSize <= 0) ? "OFF" : DoubleToString(InpStepPips, 1) + " pips";
   DL("StVal",  xV, y0, stT,              C'160,120,200', fs);
   y0 += lh;

   DL("HCLbl",  x0, y0, "HA Close:",      InpNeutralColor, fs);
   DL("HCVal",  xV, y0, "---",            InpDashTextColor, fs);
   y0 += lh;

   DL("HOLbl",  x0, y0, "HA Open:",       InpNeutralColor, fs);
   DL("HOVal",  xV, y0, "---",            InpDashTextColor, fs);
   y0 += lh;

   DL("DtLbl",  x0, y0, "HA Delta:",      InpNeutralColor, fs);
   DL("DtVal",  xV, y0, "---",            InpDashTextColor, fs);
   y0 += lh;

   DL("CsLbl",  x0, y0, "Consecutive:",   InpNeutralColor, fs);
   DL("CsVal",  xV, y0, "---",            InpDashTextColor, fs);
   y0 += lh;

   DL("StrLbl", x0, y0, "Strength:",      InpNeutralColor, fs);
   DL("StrVal", xV, y0, "---",            InpDashTextColor, fs);
   y0 += lh;

   DL("StrBar", x0, y0, "..........",    C'30,34,46', fs);
   y0 += lh + 2;

   DL("Sep2",   x0, y0, "------------------------------", InpDashBorderColor, fs - 2);
   y0 += lh - 3;
   DL("Brand",  x0, y0, "Precision before profit",          C'55,60,75', fs - 2);

   int totalH = (y0 + lh + 2) - InpDashY;
   ObjectSetInteger(0, bgName, OBJPROP_YSIZE, totalH);

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Dashboard -Update                                                |
//+------------------------------------------------------------------+
void DashboardUpdate(const int total)
{
   int lb = total - 1;
   int colorIdx = GetBarColor(lb);

   //--- Trend
   string trendText;
   color  trendClr;
   if(colorIdx == COLOR_BULL_IDX)      { trendText = "^ BULLISH";   trendClr = InpBullColor;    }
   else if(colorIdx == COLOR_BEAR_IDX) { trendText = "v BEARISH";   trendClr = InpBearColor;    }
   else                                { trendText = "- NEUTRAL";   trendClr = InpNeutralColor; }
   DS("TrVal", trendText, trendClr);

   //--- HA Close, Open, Delta
   int dig = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double haC = g_bufRawClose[lb];
   double haO = g_bufRawOpen[lb];
   double delta = haC - haO;

   DS("HCVal", DoubleToString(haC, dig), InpDashTextColor);
   DS("HOVal", DoubleToString(haO, dig), InpDashTextColor);

   color  dtClr  = (delta > 0) ? InpBullColor : (delta < 0) ? InpBearColor : InpNeutralColor;
   string dtSign = (delta > 0) ? "+" : "";
   DS("DtVal", dtSign + DoubleToString(delta, dig), dtClr);

   //--- Consecutive
   string dirWord = (g_consecutiveDir == COLOR_BULL_IDX) ? " green" :
                    (g_consecutiveDir == COLOR_BEAR_IDX) ? " red"   : "";
   color  csClr   = (g_consecutiveDir == COLOR_BULL_IDX) ? InpBullColor :
                    (g_consecutiveDir == COLOR_BEAR_IDX) ? InpBearColor  : InpNeutralColor;
   DS("CsVal", IntegerToString(g_consecutiveCount) + dirWord + " bars", csClr);

   //--- Strength (body / range ratio)
   //    In line mode, candle buffers are EMPTY_VALUE, so use raw HA + real H/L
   double haHi, haLo;
   if(InpDrawMode == HA_DRAW_CANDLES)
   {
      haHi = g_bufCandleHigh[lb];
      haLo = g_bufCandleLow[lb];
   }
   else
   {
      //--- Approximate: use raw HA open/close spread as proxy
      haHi = MathMax(haC, haO);
      haLo = MathMin(haC, haO);
   }
   double range = MathAbs(haHi - haLo);
   double body  = MathAbs(haC - haO);
   int strength = (range > 0) ? (int)MathRound((body / range) * 100.0) : 50;
   strength = MathMin(strength, 100);

   color strClr = (strength >= 70) ? InpBullColor :
                  (strength >= 40) ? C'200,170,50' : InpBearColor;
   DS("StrVal", IntegerToString(strength) + "%", strClr);

   //--- Visual bar using ASCII-safe characters
   int filled = (int)MathRound(strength / 10.0);
   int empty  = 10 - filled;
   string bar = "";
   for(int j = 0; j < filled; j++) bar += "|";
   for(int j = 0; j < empty; j++)  bar += ".";
   DS("StrBar", bar, strClr);

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Dashboard -Create label (short alias)                            |
//+------------------------------------------------------------------+
void DL(const string id, const int x, const int y,
        const string text, const color clr, const int fontSize)
{
   string name = PREFIX + id;
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0,  name, OBJPROP_TEXT,       text);
   ObjectSetInteger(0, name, OBJPROP_COLOR,      clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,   fontSize);
   ObjectSetString(0,  name, OBJPROP_FONT,       FONT_NAME);
   ObjectSetInteger(0, name, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,     ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0, name, OBJPROP_BACK,        false);
}

//+------------------------------------------------------------------+
//| Dashboard -Update text & color (short alias)                     |
//+------------------------------------------------------------------+
void DS(const string id, const string text, const color clr)
{
   string name = PREFIX + id;
   ObjectSetString(0,  name, OBJPROP_TEXT,  text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
}
//+------------------------------------------------------------------+
