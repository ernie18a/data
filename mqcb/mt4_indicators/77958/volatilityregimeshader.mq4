//+------------------------------------------------------------------+
//|                                       VolatilityRegimeShader.mq4 |
//|                                           Copyright 2026, Osazee |
//|                           https://www.mql5.com/en/users/45266274 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Osazee"
#property link        "https://www.mql5.com/en/users/45266274"
#property version     "1.00"
#property description "Classifies volatility into Compression, Normal and Expansion"
#property description "regimes using the percentile rank of the current ATR within a"
#property description "lookback window, and shades the chart background by regime."
#property strict
#property indicator_chart_window
#property indicator_buffers 2

input string InpHdrCalc   = "===== Calculation =====";  // .
input int    InpAtrPeriod = 14;    // ATR period
input int    InpLookback  = 100;   // Percentile lookback (bars)
input double InpLowPct    = 20.0;  // Compression at or below percentile
input double InpHighPct   = 80.0;  // Expansion at or above percentile
input int    InpMaxBars   = 3000;  // Bars to calculate and shade

input string InpHdrDisp          = "===== Display =====";  // .
input color  InpCompressionColor = C'220,232,250'; // Compression shade
input color  InpExpansionColor   = C'252,226,222'; // Expansion shade
input bool   InpShadeNormal      = false;          // Shade Normal regime
input color  InpNormalColor      = C'240,240,240'; // Normal shade
input bool   InpShowLabel        = true;           // Show current regime label

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input string InpHdrAlert   = "===== Alerts (closed bars only) =====";  // .
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

   IndicatorBuffers(3);
   SetIndexBuffer(0, BufRank);
   SetIndexBuffer(1, BufRegime);
   SetIndexBuffer(2, BufAtr);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexLabel(0, "ATR Percentile");
   SetIndexLabel(1, "Regime (0=Compression, 1=Normal, 2=Expansion)");
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);

   IndicatorShortName("Volatility Regime Shader");
   IndicatorDigits(1);

   DeleteObjects(PFX);
   g_lastBarTime    = 0;
   g_lastLiveRegime = -1;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Remove chart objects                                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteObjects(PFX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Main calculation (series indexing: 0 = forming bar)              |
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

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);

   if(prev_calculated <= 0)
     {
      ArrayInitialize(BufRank,   EMPTY_VALUE);
      ArrayInitialize(BufRegime, EMPTY_VALUE);
      ArrayInitialize(BufAtr,    0.0);
     }

//--- ATR values
   int atrLimit = (prev_calculated <= 0) ? rates_total - InpAtrPeriod - 1
                  : rates_total - prev_calculated;
   for(int i = atrLimit; i >= 0; i--)
      BufAtr[i] = iATR(NULL, 0, InpAtrPeriod, i);

//--- percentile rank and regime
   int oldestValid = MathMin(rates_total - InpAtrPeriod - InpLookback - 1, InpMaxBars - 1);
   int start       = (prev_calculated <= 0) ? oldestValid
                     : MathMin(rates_total - prev_calculated, oldestValid);

   for(int i = start; i >= 0; i--)
     {
      double current = BufAtr[i];
      int    below   = 0;
      for(int j = i + 1; j <= i + InpLookback; j++)
         if(BufAtr[j] < current)
            below++;
      double rank = 100.0 * below / InpLookback;
      BufRank[i]   = rank;
      BufRegime[i] = (rank <= InpLowPct) ? 0 : ((rank >= InpHighPct) ? 2 : 1);
     }

//--- shading, alerts and label
   bool newBar     = (time[0] != g_lastBarTime);
   int  liveRegime = (int)BufRegime[0];

   if(newBar || liveRegime != g_lastLiveRegime)
     {
      RebuildShading(time, high, oldestValid);
      g_lastLiveRegime = liveRegime;
     }
   if(newBar)
     {
      if(prev_calculated > 0)
         CheckRegimeAlert();
      g_lastBarTime = time[0];
     }
   UpdateLabel(BufRank[0], liveRegime);

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Redraw background zones for each run of identical regimes        |
//+------------------------------------------------------------------+
void RebuildShading(const datetime &time[], const double &high[], const int from)
  {
   DeleteObjects(PFX + "Z_");

   int    top_idx  = ArrayMaximum(high, from + 1, 0);
   double top      = (top_idx >= 0) ? high[top_idx] * 3.0 : 0.0;
   int    segStart = from;

   for(int i = from - 1; i >= -1; i--)
     {
      if(i >= 0 && BufRegime[i] == BufRegime[segStart])
         continue;

      color c = RegimeShade((int)BufRegime[segStart]);
      if(c != clrNONE)
         DrawZone(time[segStart], time[i + 1] + PeriodSeconds(), top, c);
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
   ObjectSetInteger(0, n, OBJPROP_BACK,       true);   // filled in the background
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_SELECTED,   false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN,     true);
  }

//+------------------------------------------------------------------+
//| Delete all objects whose names start with the prefix             |
//+------------------------------------------------------------------+
void DeleteObjects(const string prefix)
  {
   for(int k = ObjectsTotal(0, -1, -1) - 1; k >= 0; k--)
     {
      string n = ObjectName(0, k, -1, -1);
      if(StringFind(n, prefix) == 0)
         ObjectDelete(0, n);
     }
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
void CheckRegimeAlert()
  {
   if(!InpAlertPopup && !InpAlertPush && !InpAlertSound)
      return;
   if(BufRegime[1] == EMPTY_VALUE || BufRegime[2] == EMPTY_VALUE)
      return;
   if(BufRegime[1] == BufRegime[2])
      return;

   string tf  = StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period), 7);
   string msg = StringFormat("%s %s: volatility regime changed to %s (ATR percentile %.0f)",
                             _Symbol, tf, RegimeName((int)BufRegime[1]), BufRank[1]);
   if(InpAlertPopup)
      Alert(msg);
   if(InpAlertPush)
      SendNotification(msg);
   if(InpAlertSound)
      PlaySound(InpSoundFile);
  }
//+------------------------------------------------------------------+
