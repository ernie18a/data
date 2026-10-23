//+------------------------------------------------------------------+
//|                                                   CISD.mq5       |
//|                                  https://www.mql5.com            |
//+------------------------------------------------------------------+
#property link      "https://www.mql5.com/en/users/asma381/news"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1

// Candle coloring plot
#property indicator_label1  "Candles"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrNONE, C'8,153,129', C'242,54,69' // [0] None, [1] Bull Color, [2] Bear Color
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#define PREFIX_CISD "CISD_Z_"

enum ENUM_CANDLE_COLOR_MODE
{
   CANDLE_COLOR_BULL_BEAR = 0, // Bull candles = Bull Color, Bear candles = Bear Color
   CANDLE_COLOR_CISD_TREND = 1 // Color candles by confirmed CISD Trend
};

//--- Input Parameters
input group "=== Candle Coloring ==="
input bool                   InpColorCandles      = true;                  // Enable Candle Coloring
input ENUM_CANDLE_COLOR_MODE InpCandleColorMode   = CANDLE_COLOR_BULL_BEAR;// Coloring Mode
input color                  InpBullCandle        = C'8,153,129';          // Bull Candle Color (Green)
input color                  InpBearCandle        = C'242,54,69';          // Bear Candle Color (Red)

input group "=== True CISD ==="
input bool            InpShowCISD          = true;          // Show CISD
input int             InpMinDelivery       = 3;             // Minimum Delivery Candles
input int             InpMaxSeq            = 100;           // Maximum CISD Validity (Bars)
input int             InpMinSeq            = 1;             // Minimum CISD Duration (Bars)
input color           InpCBull             = C'8,153,129';  // Bullish CISD Line Color
input color           InpCBear             = C'242,54,69';  // Bearish CISD Line Color
input int             InpCisdWidth         = 2;             // CISD Line Width
input bool            InpShowPendingLabel  = true;          // Show Pending CISD Label
input int             InpPendingOffset     = 2;             // Pending Label Offset (Bars)

input group "=== Market Structure Shift (MSS) ==="
input bool            InpShowMSS           = false;         // Show MSS Dots
input int             InpMssLen            = 3;             // MSS Pivot Length
input color           InpCMSS              = C'120,123,134';// MSS Dot Color

input group "=== Liquidity Sweeps ==="
input bool            InpShowSweeps        = true;          // Show Liquidity Sweeps
input int             InpSwingLen          = 10;            // Sweep Swing Length
input color           InpCSweepH           = C'120,123,134';// Sweep High Color
input color           InpCSweepL           = C'120,123,134';// Sweep Low Color
input int             InpSweepWidth        = 1;             // Sweep Level Width
input int             InpSweepWickWidth    = 5;             // Sweep Wick Width

input group "=== Performance Optimization ==="
input int             InpMaxBars           = 1500;          // Max Bars to Calculate (Prevents Hang)

//--- Indicator Buffers for Candle Coloring
double BufOpen[];
double BufHigh[];
double BufLow[];
double BufClose[];
double BufCandleColor[];

// Dynamic arrays for stable delivery sequence counting
int arrBullSeq[];
int arrBearSeq[];

// Setup State Struct
struct CISD_State
{
   bool     active;
   double   level;
   int      x1;
   datetime t1;
};

CISD_State bullSetup;
CISD_State bearSetup;

int trend = 0;

// Liquidity Sweep Variables
double   swingHigh = 0.0;
double   swingLow = 0.0;
datetime swingHighTime = 0;
datetime swingLowTime = 0;

// MSS Variables
double lastMssHigh = 0.0;
double lastMssLow = 0.0;

//+------------------------------------------------------------------+
//| Chart Object Cleanup                                             |
//+------------------------------------------------------------------+
void CleanObjects()
{
   ObjectsDeleteAll(0, PREFIX_CISD);
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, BufOpen,        INDICATOR_DATA);
   SetIndexBuffer(1, BufHigh,        INDICATOR_DATA);
   SetIndexBuffer(2, BufLow,         INDICATOR_DATA);
   SetIndexBuffer(3, BufClose,       INDICATOR_DATA);
   SetIndexBuffer(4, BufCandleColor, INDICATOR_COLOR_INDEX);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 3);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, clrNONE);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, InpBullCandle);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 2, InpBearCandle);

   if(!InpColorCandles)
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
   else
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_COLOR_CANDLES);

   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "CISD ");

   ResetState();
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Reset States                                                     |
//+------------------------------------------------------------------+
void ResetState()
{
   trend = 0;
   swingHigh = 0.0;
   swingLow = 0.0;
   swingHighTime = 0;
   swingLowTime = 0;
   lastMssHigh = 0.0;
   lastMssLow = 0.0;

   bullSetup.active = false;
   bullSetup.level = 0.0;
   bullSetup.x1 = 0;
   bullSetup.t1 = 0;

   bearSetup.active = false;
   bearSetup.level = 0.0;
   bearSetup.x1 = 0;
   bearSetup.t1 = 0;

   CleanObjects();
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   CleanObjects();
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Active CISD Visual Helpers (Single Dedicated Handles)            |
//+------------------------------------------------------------------+
void UpdateActiveCisdLine(bool isBull, datetime t1, datetime t2, double level, color col, int width)
{
   string name = PREFIX_CISD + (isBull ? "ACT_BULL_L" : "ACT_BEAR_L");
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TREND, 0, t1, level, t2, level);
      ObjectSetInteger(0, name, OBJPROP_COLOR, col);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   }
   else
   {
      ObjectMove(0, name, 0, t1, level);
      ObjectMove(0, name, 1, t2, level);
   }
}

void RemoveActiveCisdLine(bool isBull)
{
   ObjectDelete(0, PREFIX_CISD + (isBull ? "ACT_BULL_L" : "ACT_BEAR_L"));
}

void UpdatePendingLabel(bool isBull, datetime curTime, double level, color col)
{
   string name = PREFIX_CISD + (isBull ? "ACT_BULL_LBL" : "ACT_BEAR_LBL");
   datetime targetTime = curTime + InpPendingOffset * PeriodSeconds(_Period);

   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TEXT, 0, targetTime, level);
      ObjectSetString(0, name, OBJPROP_TEXT, "Pending CISD");
      ObjectSetString(0, name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, name, OBJPROP_COLOR, col);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT);
   }
   else
   {
      ObjectMove(0, name, 0, targetTime, level);
      ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   }
}

void RemovePendingLabel(bool isBull)
{
   ObjectDelete(0, PREFIX_CISD + (isBull ? "ACT_BULL_LBL" : "ACT_BEAR_LBL"));
}

void CreateConfirmedCisd(bool isBull, datetime t1, datetime t2, double level, double candleExtreme, color col, int width, bool isDashed)
{
   string lineName = PREFIX_CISD + "CONF_L_" + (isBull ? "B_" : "S_") + IntegerToString((long)t1);
   if(ObjectFind(0, lineName) < 0)
   {
      ObjectCreate(0, lineName, OBJ_TREND, 0, t1, level, t2, level);
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, col);
      ObjectSetInteger(0, lineName, OBJPROP_WIDTH, width);
      ObjectSetInteger(0, lineName, OBJPROP_STYLE, isDashed ? STYLE_DASH : STYLE_SOLID);
      ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, false);
   }

   datetime midTime = t1 + (datetime)((t2 - t1) / 2);
   string txtName = PREFIX_CISD + "CONF_T_" + (isBull ? "B_" : "S_") + IntegerToString((long)t1);
   if(ObjectFind(0, txtName) < 0)
   {
      ObjectCreate(0, txtName, OBJ_TEXT, 0, midTime, level);
      ObjectSetString(0, txtName, OBJPROP_TEXT, "CISD");
      ObjectSetString(0, txtName, OBJPROP_FONT, "Arial Bold");
      ObjectSetInteger(0, txtName, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, txtName, OBJPROP_COLOR, col);
      ObjectSetInteger(0, txtName, OBJPROP_ANCHOR, isBull ? ANCHOR_UPPER : ANCHOR_LOWER);
   }

   string arrName = PREFIX_CISD + "CONF_A_" + (isBull ? "B_" : "S_") + IntegerToString((long)t2);
   if(ObjectFind(0, arrName) < 0)
   {
      ObjectCreate(0, arrName, OBJ_ARROW, 0, t2, candleExtreme);
      ObjectSetInteger(0, arrName, OBJPROP_ARROWCODE, isBull ? 233 : 234);
      ObjectSetInteger(0, arrName, OBJPROP_COLOR, col);
      ObjectSetInteger(0, arrName, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, arrName, OBJPROP_ANCHOR, isBull ? ANCHOR_TOP : ANCHOR_BOTTOM);
   }
}

//+------------------------------------------------------------------+
//| Pivot Checks                                                     |
//+------------------------------------------------------------------+
bool IsPivotHigh(const double &h[], int i, int left, int right)
{
   int p = i - right;
   if(p < left) return false;
   double val = h[p];
   for(int k = 1; k <= left; k++)  if(h[p - k] >= val) return false;
   for(int k = 1; k <= right; k++) if(h[p + k] > val)  return false;
   return true;
}

bool IsPivotLow(const double &l[], int i, int left, int right)
{
   int p = i - right;
   if(p < left) return false;
   double val = l[p];
   for(int k = 1; k <= left; k++)  if(l[p - k] <= val) return false;
   for(int k = 1; k <= right; k++) if(l[p + k] < val)  return false;
   return true;
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
   if(rates_total < 20) return 0;

   // Size arrays properly
   if(ArraySize(arrBullSeq) < rates_total) ArrayResize(arrBullSeq, rates_total);
   if(ArraySize(arrBearSeq) < rates_total) ArrayResize(arrBearSeq, rates_total);

   int start = prev_calculated - 1;
   if(prev_calculated == 0)
   {
      ResetState();
      int maxBars = (InpMaxBars > 0 && rates_total > InpMaxBars) ? InpMaxBars : rates_total;
      start = rates_total - maxBars;
      if(start < 1) start = 1;
      arrBullSeq[0] = 0;
      arrBearSeq[0] = 0;
   }
   if(start < 1) start = 1;

   for(int i = start; i < rates_total; i++)
   {
      bool isBull = close[i] >= open[i];
      bool isBear = close[i] < open[i];
      bool prevBull = close[i-1] >= open[i-1];
      bool prevBear = close[i-1] < open[i-1];

      // 1. Stable Delivery Tracking (Array based, no tick loop runaway)
      if(isBull)
      {
         arrBullSeq[i] = prevBull ? (arrBullSeq[i-1] + 1) : 1;
         arrBearSeq[i] = 0;
      }
      else if(isBear)
      {
         arrBearSeq[i] = prevBear ? (arrBearSeq[i-1] + 1) : 1;
         arrBullSeq[i] = 0;
      }
      else
      {
         arrBullSeq[i] = 0;
         arrBearSeq[i] = 0;
      }

      // 2. Liquidity Sweeps
      if(IsPivotHigh(high, i, InpSwingLen, 1))
      {
         swingHigh = high[i - 1];
         swingHighTime = time[i - 1];
      }
      if(IsPivotLow(low, i, InpSwingLen, 1))
      {
         swingLow = low[i - 1];
         swingLowTime = time[i - 1];
      }

      bool bearSweep = (swingHighTime != 0 && high[i] > swingHigh && close[i] < swingHigh);
      bool bullSweep = (swingLowTime != 0 && low[i] < swingLow && close[i] > swingLow);

      if(InpShowSweeps)
      {
         if(bearSweep)
         {
            string hName = PREFIX_CISD + "SWP_H_" + IntegerToString((long)time[i]);
            string vName = PREFIX_CISD + "SWP_V_" + IntegerToString((long)time[i]);
            if(ObjectFind(0, hName) < 0)
            {
               ObjectCreate(0, hName, OBJ_TREND, 0, swingHighTime, swingHigh, time[i], swingHigh);
               ObjectSetInteger(0, hName, OBJPROP_COLOR, InpCSweepH);
               ObjectSetInteger(0, hName, OBJPROP_WIDTH, InpSweepWidth);
               ObjectSetInteger(0, hName, OBJPROP_RAY_RIGHT, false);
            }
            if(ObjectFind(0, vName) < 0)
            {
               ObjectCreate(0, vName, OBJ_TREND, 0, time[i], swingHigh, time[i], high[i]);
               ObjectSetInteger(0, vName, OBJPROP_COLOR, InpCSweepH);
               ObjectSetInteger(0, vName, OBJPROP_WIDTH, InpSweepWickWidth);
               ObjectSetInteger(0, vName, OBJPROP_RAY_RIGHT, false);
            }
         }
         if(bullSweep)
         {
            string hName = PREFIX_CISD + "SWP_HL_" + IntegerToString((long)time[i]);
            string vName = PREFIX_CISD + "SWP_VL_" + IntegerToString((long)time[i]);
            if(ObjectFind(0, hName) < 0)
            {
               ObjectCreate(0, hName, OBJ_TREND, 0, swingLowTime, swingLow, time[i], swingLow);
               ObjectSetInteger(0, hName, OBJPROP_COLOR, InpCSweepL);
               ObjectSetInteger(0, hName, OBJPROP_WIDTH, InpSweepWidth);
               ObjectSetInteger(0, hName, OBJPROP_RAY_RIGHT, false);
            }
            if(ObjectFind(0, vName) < 0)
            {
               ObjectCreate(0, vName, OBJ_TREND, 0, time[i], swingLow, time[i], low[i]);
               ObjectSetInteger(0, vName, OBJPROP_COLOR, InpCSweepL);
               ObjectSetInteger(0, vName, OBJPROP_WIDTH, InpSweepWickWidth);
               ObjectSetInteger(0, vName, OBJPROP_RAY_RIGHT, false);
            }
         }
      }

      if(swingHighTime != 0 && close[i] > swingHigh)
      {
         swingHigh = 0.0;
         swingHighTime = 0;
      }
      if(swingLowTime != 0 && close[i] < swingLow)
      {
         swingLow = 0.0;
         swingLowTime = 0;
      }

      // 3. Market Structure Shift (MSS)
      if(IsPivotHigh(high, i, InpMssLen, InpMssLen))
         lastMssHigh = high[i - InpMssLen];

      if(IsPivotLow(low, i, InpMssLen, InpMssLen))
         lastMssLow = low[i - InpMssLen];

      bool bullMSS = (lastMssHigh > 0.0 && close[i] > lastMssHigh && close[i-1] <= lastMssHigh);
      bool bearMSS = (lastMssLow > 0.0 && close[i] < lastMssLow && close[i-1] >= lastMssLow);

      if(InpShowMSS)
      {
         if(bullMSS)
         {
            string mssDot = PREFIX_CISD + "MSS_B_" + IntegerToString((long)time[i]);
            if(ObjectFind(0, mssDot) < 0)
            {
               ObjectCreate(0, mssDot, OBJ_ARROW, 0, time[i], low[i] - 5 * _Point);
               ObjectSetInteger(0, mssDot, OBJPROP_ARROWCODE, 159);
               ObjectSetInteger(0, mssDot, OBJPROP_COLOR, InpCMSS);
               ObjectSetInteger(0, mssDot, OBJPROP_ANCHOR, ANCHOR_TOP);
            }
         }
         if(bearMSS)
         {
            string mssDot = PREFIX_CISD + "MSS_S_" + IntegerToString((long)time[i]);
            if(ObjectFind(0, mssDot) < 0)
            {
               ObjectCreate(0, mssDot, OBJ_ARROW, 0, time[i], high[i] + 5 * _Point);
               ObjectSetInteger(0, mssDot, OBJPROP_ARROWCODE, 159);
               ObjectSetInteger(0, mssDot, OBJPROP_COLOR, InpCMSS);
               ObjectSetInteger(0, mssDot, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
            }
         }
      }

      // 4. CISD Setup Triggers
      if(InpShowCISD)
      {
         if(arrBearSeq[i] >= InpMinDelivery)
         {
            int startIdx = i - arrBearSeq[i] + 1;
            bullSetup.level = open[startIdx];
            bullSetup.x1 = startIdx;
            bullSetup.t1 = time[startIdx];
            bullSetup.active = true;
         }

         if(arrBullSeq[i] >= InpMinDelivery)
         {
            int startIdx = i - arrBullSeq[i] + 1;
            bearSetup.level = open[startIdx];
            bearSetup.x1 = startIdx;
            bearSetup.t1 = time[startIdx];
            bearSetup.active = true;
         }

         // 5. Confirm / Manage Setups
         bool bullConfirm = (bullSetup.active && close[i] > bullSetup.level && (i - bullSetup.x1) >= InpMinSeq);
         bool bearConfirm = (bearSetup.active && close[i] < bearSetup.level && (i - bearSetup.x1) >= InpMinSeq);

         if(bullSetup.active)
         {
            if((i - bullSetup.x1) <= InpMaxSeq)
            {
               if(bullConfirm)
               {
                  RemoveActiveCisdLine(true);
                  RemovePendingLabel(true);
                  CreateConfirmedCisd(true, bullSetup.t1, time[i], bullSetup.level, low[i], InpCBull, InpCisdWidth, trend == 1);
                  trend = 1;
                  bullSetup.active = false;
               }
               else if(i == rates_total - 1)
               {
                  UpdateActiveCisdLine(true, bullSetup.t1, time[i], bullSetup.level, InpCBull, InpCisdWidth);
                  if(InpShowPendingLabel)
                     UpdatePendingLabel(true, time[i], bullSetup.level, InpCBull);
               }
            }
            else
            {
               RemoveActiveCisdLine(true);
               RemovePendingLabel(true);
               bullSetup.active = false;
            }
         }

         if(bearSetup.active)
         {
            if((i - bearSetup.x1) <= InpMaxSeq)
            {
               if(bearConfirm)
               {
                  RemoveActiveCisdLine(false);
                  RemovePendingLabel(false);
                  CreateConfirmedCisd(false, bearSetup.t1, time[i], bearSetup.level, high[i], InpCBear, InpCisdWidth, trend == -1);
                  trend = -1;
                  bearSetup.active = false;
               }
               else if(i == rates_total - 1)
               {
                  UpdateActiveCisdLine(false, bearSetup.t1, time[i], bearSetup.level, InpCBear, InpCisdWidth);
                  if(InpShowPendingLabel)
                     UpdatePendingLabel(false, time[i], bearSetup.level, InpCBear);
               }
            }
            else
            {
               RemoveActiveCisdLine(false);
               RemovePendingLabel(false);
               bearSetup.active = false;
            }
         }
      }

      // 6. Candle Coloring: Bull candles = Bull color, Bear candles = Bear color
      if(InpColorCandles)
      {
         BufOpen[i]  = open[i];
         BufHigh[i]  = high[i];
         BufLow[i]   = low[i];
         BufClose[i] = close[i];

         if(InpCandleColorMode == CANDLE_COLOR_BULL_BEAR)
         {
            // Direct Directional Coloring
            BufCandleColor[i] = (close[i] >= open[i]) ? 1.0 : 2.0; // 1 = Bull Color, 2 = Bear Color
         }
         else // CANDLE_COLOR_CISD_TREND
         {
            // Coloring based on confirmed CISD Trend
            BufCandleColor[i] = (trend == 1) ? 1.0 : (trend == -1) ? 2.0 : ((close[i] >= open[i]) ? 1.0 : 2.0);
         }
      }
      else
      {
         BufOpen[i]  = EMPTY_VALUE;
         BufHigh[i]  = EMPTY_VALUE;
         BufLow[i]   = EMPTY_VALUE;
         BufClose[i] = EMPTY_VALUE;
         BufCandleColor[i] = 0.0;
      }
   }

   return(rates_total);
}
//+------------------------------------------------------------------+