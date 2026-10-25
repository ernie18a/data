//+------------------------------------------------------------------+
//|                                       VolatilityRegimeShader.mq5 |
//|                                           Copyright 2026, Osazee |
//|                           https://www.mql5.com/en/users/45266274 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Osazee"
#property link        "https://www.mql5.com/en/users/45266274"
#property version     "1.00"
#property description "Classifies volatility into Compression, Normal and Expansion"
#property description "regimes using the percentile rank of the current ATR within a"
#property description "lookback window, and shades the chart background by regime."
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2

#property indicator_label1  "ATR Percentile"
#property indicator_type1   DRAW_NONE
#property indicator_label2  "Regime (0=Compression, 1=Normal, 2=Expansion)"
#property indicator_type2   DRAW_NONE

input group "Calculation"
input int    InpAtrPeriod = 14;    // ATR period
input int    InpLookback  = 100;   // Percentile lookback (bars)
input double InpLowPct    = 20.0;  // Compression at or below percentile
input double InpHighPct   = 80.0;  // Expansion at or above percentile
input int    InpMaxBars   = 3000;  // Bars to calculate and shade

input group "Display"
input color InpCompressionColor = C'220,232,250'; // Compression shade
input color InpExpansionColor   = C'252,226,222'; // Expansion shade
input bool  InpShadeNormal      = false;          // Shade Normal regime
input color InpNormalColor      = C'240,240,240'; // Normal shade
input bool  InpShowLabel        = true;           // Show current regime label

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "Alerts (closed bars only)"
input bool   InpAlertPopup = false;       // Pop-up alert on regime change
input bool   InpAlertPush  = false;       // Push notification on regime change
input bool   InpAlertSound = false;       // Play sound on regime change
input string InpSoundFile  = "alert.wav"; // Sound file

//--- buffers
double BufRank[];
double BufRegime[];
double BufAtr[];

//--- globals
const string PFX = "VRS_";
int      g_atrHandle      = INVALID_HANDLE;
datetime g_lastBarTime    = 0;
int      g_lastLiveRegime = -1;

//+------------------------------------------------------------------+
//| Initialization and checking of input parameters                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpAtrPeriod < 1 || InpLookback < 10 || InpMaxBars < 50)
     {
      Print("ATR period must be 1 or more, lookback 10 or more, bars to calculate 50 or more.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpLowPct < 0.0 || InpHighPct > 100.0 || InpLowPct >= InpHighPct)
     {
      Print("Percentile thresholds must satisfy 0 <= Compression < Expansion <= 100.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   g_atrHandle = iATR(_Symbol, _Period, InpAtrPeriod);
   if(g_atrHandle == INVALID_HANDLE)
     {
      Print("Failed to create the ATR handle, error ", GetLastError());
      return(INIT_FAILED);
     }

   SetIndexBuffer(0, BufRank,   INDICATOR_DATA);
   SetIndexBuffer(1, BufRegime, INDICATOR_DATA);
   SetIndexBuffer(2, BufAtr,    INDICATOR_CALCULATIONS);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   IndicatorSetString(INDICATOR_SHORTNAME, "Volatility Regime Shader");
   IndicatorSetInteger(INDICATOR_DIGITS, 1);

   ObjectsDeleteAll(0, PFX);
   g_lastBarTime    = 0;
   g_lastLiveRegime = -1;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Release the ATR handle and remove chart objects                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_atrHandle != INVALID_HANDLE)
      IndicatorRelease(g_atrHandle);
   ObjectsDeleteAll(0, PFX);
   ChartRedraw();
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
   if(rates_total < InpAtrPeriod + InpLookback + 2)
      return(0);
   if(BarsCalculated(g_atrHandle) < rates_total)
      return(prev_calculated);

   ArraySetAsSeries(time, false);
   ArraySetAsSeries(high, false);

//--- copy ATR values
   int toCopy = (prev_calculated <= 0 || prev_calculated > rates_total)
                ? rates_total : rates_total - prev_calculated + 1;
   if(CopyBuffer(g_atrHandle, 0, 0, toCopy, BufAtr) <= 0)
      return(prev_calculated);

   if(prev_calculated <= 0)
     {
      ArrayInitialize(BufRank,   EMPTY_VALUE);
      ArrayInitialize(BufRegime, EMPTY_VALUE);
     }

//--- percentile rank and regime
   int firstValid = MathMax(InpAtrPeriod + InpLookback, rates_total - InpMaxBars);
   int start      = (prev_calculated <= 0) ? firstValid : MathMax(prev_calculated - 1, firstValid);

   for(int i = start; i < rates_total; i++)
     {
      double current = BufAtr[i];
      int    below   = 0;
      for(int j = i - InpLookback; j < i; j++)
         if(BufAtr[j] < current)
            below++;
      double rank = 100.0 * below / InpLookback;
      BufRank[i]   = rank;
      BufRegime[i] = (rank <= InpLowPct) ? 0 : ((rank >= InpHighPct) ? 2 : 1);
     }

//--- shading, alerts and label
   int  last       = rates_total - 1;
   bool newBar     = (time[last] != g_lastBarTime);
   int  liveRegime = (int)BufRegime[last];

   if(newBar || liveRegime != g_lastLiveRegime)
     {
      RebuildShading(rates_total, time, high, firstValid);
      g_lastLiveRegime = liveRegime;
     }
   if(newBar)
     {
      if(prev_calculated > 0)
         CheckRegimeAlert(rates_total);
      g_lastBarTime = time[last];
     }
   UpdateLabel(BufRank[last], liveRegime);

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Redraw background zones for each run of identical regimes        |
//+------------------------------------------------------------------+
void RebuildShading(const int total, const datetime &time[], const double &high[], const int from)
  {
   ObjectsDeleteAll(0, PFX + "Z_");

   int    top_idx = ArrayMaximum(high, from, total - from);
   double top     = (top_idx >= 0) ? high[top_idx] * 3.0 : 0.0;
   int    segStart = from;

   for(int i = from + 1; i <= total; i++)
     {
      if(i < total && BufRegime[i] == BufRegime[segStart])
         continue;

      color c = RegimeShade((int)BufRegime[segStart]);
      if(c != clrNONE)
         DrawZone(time[segStart], time[i - 1] + PeriodSeconds(), top, c);
      segStart = i;
     }
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Draw one background zone                                         |
//+------------------------------------------------------------------+
void DrawZone(const datetime t1, const datetime t2, const double top, const color c)
  {
   string n = PFX + "Z_" + IntegerToString((long)t1);
   if(!ObjectCreate(0, n, OBJ_RECTANGLE, 0, t1, top, t2, 0.0))
      return;
   ObjectSetInteger(0, n, OBJPROP_COLOR,      c);
   ObjectSetInteger(0, n, OBJPROP_FILL,       true);
   ObjectSetInteger(0, n, OBJPROP_BACK,       true);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_SELECTED,   false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN,     true);
  }

//+------------------------------------------------------------------+
//| Shade color for a regime (clrNONE = not shaded)                  |
//+------------------------------------------------------------------+
color RegimeShade(const int regime)
  {
   if(regime == 0)
      return(InpCompressionColor);
   if(regime == 2)
      return(InpExpansionColor);
   return(InpShadeNormal ? InpNormalColor : clrNONE);
  }

//+------------------------------------------------------------------+
//| Regime name                                                      |
//+------------------------------------------------------------------+
string RegimeName(const int regime)
  {
   if(regime == 0)
      return("COMPRESSION");
   if(regime == 2)
      return("EXPANSION");
   return("NORMAL");
  }

//+------------------------------------------------------------------+
//| Current regime label in the upper-right corner                   |
//+------------------------------------------------------------------+
void UpdateLabel(const double rank, const int regime)
  {
   string n = PFX + "LABEL";
   if(!InpShowLabel)
     {
      ObjectDelete(0, n);
      return;
     }
   if(ObjectFind(0, n) < 0)
     {
      ObjectCreate(0, n, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, n, OBJPROP_CORNER,     CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, n, OBJPROP_ANCHOR,     ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0, n, OBJPROP_XDISTANCE,  10);
      ObjectSetInteger(0, n, OBJPROP_YDISTANCE,  20);
      ObjectSetString(0,  n, OBJPROP_FONT,       "Arial");
      ObjectSetInteger(0, n, OBJPROP_FONTSIZE,   9);
      ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, n, OBJPROP_HIDDEN,     true);
     }
   color c = (regime == 0) ? clrRoyalBlue : ((regime == 2) ? clrFireBrick : clrGray);
   ObjectSetString(0,  n, OBJPROP_TEXT,
                   StringFormat("Volatility: %s  |  ATR percentile %.0f", RegimeName(regime), rank));
   ObjectSetInteger(0, n, OBJPROP_COLOR, c);
  }

//+------------------------------------------------------------------+
//| Alert when the last closed bar starts a new regime               |
//+------------------------------------------------------------------+
void CheckRegimeAlert(const int total)
  {
   if(!InpAlertPopup && !InpAlertPush && !InpAlertSound)
      return;
   int b = total - 2;
   if(b < 1 || BufRegime[b] == EMPTY_VALUE || BufRegime[b - 1] == EMPTY_VALUE)
      return;
   if(BufRegime[b] == BufRegime[b - 1])
      return;

   string tf  = StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period), 7);
   string msg = StringFormat("%s %s: volatility regime changed to %s (ATR percentile %.0f)",
                             _Symbol, tf, RegimeName((int)BufRegime[b]), BufRank[b]);
   if(InpAlertPopup)
      Alert(msg);
   if(InpAlertPush)
      SendNotification(msg);
   if(InpAlertSound)
      PlaySound(InpSoundFile);
  }
//+------------------------------------------------------------------+
