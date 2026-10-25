//+------------------------------------------------------------------+
//|                                            CandleStrengthATR.mq4 |
//|                                           Copyright 2026, Osazee |
//|                           https://www.mql5.com/en/users/45266274 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Osazee"
#property link        "https://www.mql5.com/en/users/45266274"
#property version     "1.00"
#property description "Measures each candle's body (or full range) in units of ATR."
#property description "Positive values are bullish, negative values are bearish."
#property description "Candles beyond the threshold are highlighted as strong."
#property strict
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color2  clrForestGreen
#property indicator_color3  clrLightGreen
#property indicator_color4  clrCrimson
#property indicator_color5  clrLightPink
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2

enum ENUM_STRENGTH_MEASURE
  {
   MEASURE_BODY  = 0, // Body (close - open)
   MEASURE_RANGE = 1  // Full range (high - low), signed by direction
  };

input string                InpHdrCalc   = "===== Calculation =====";  // .
input int                   InpAtrPeriod = 14;           // ATR period
input ENUM_STRENGTH_MEASURE InpMeasure   = MEASURE_BODY; // Candle size to measure
input double                InpThreshold = 0.7;          // Strong candle threshold (x ATR)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input string InpHdrAlert   = "===== Alerts (closed bars only) =====";  // .
input bool   InpAlertPopup = false;       // Pop-up alert on strong candle
input bool   InpAlertPush  = false;       // Push notification on strong candle
input bool   InpAlertSound = false;       // Play sound on strong candle
input string InpSoundFile  = "alert.wav"; // Sound file

//--- buffers: 0 = value for iCustom, 1-4 = colored histograms
double BufStrength[];
double BufStrongBull[];
double BufWeakBull[];
double BufStrongBear[];
double BufWeakBear[];

//--- globals
datetime g_lastBarTime = 0;

//+------------------------------------------------------------------+
//| Initialization and checking of input parameters                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpAtrPeriod < 1 || InpThreshold <= 0.0)
     {
      Print("ATR period must be 1 or more and the threshold must be above zero.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   SetIndexBuffer(0, BufStrength);
   SetIndexBuffer(1, BufStrongBull);
   SetIndexBuffer(2, BufWeakBull);
   SetIndexBuffer(3, BufStrongBear);
   SetIndexBuffer(4, BufWeakBear);

   SetIndexStyle(0, DRAW_NONE);
   SetIndexLabel(0, "Candle Strength (x ATR)");
   SetIndexLabel(1, "Strong bullish");
   SetIndexLabel(2, "Bullish");
   SetIndexLabel(3, "Strong bearish");
   SetIndexLabel(4, "Bearish");
   for(int k = 0; k < 5; k++)
     {
      if(k > 0)
         SetIndexStyle(k, DRAW_HISTOGRAM);
      SetIndexEmptyValue(k, EMPTY_VALUE);
      SetIndexDrawBegin(k, InpAtrPeriod);
     }

//--- threshold levels
   SetLevelValue(0,  InpThreshold);
   SetLevelValue(1, -InpThreshold);
   SetLevelStyle(STYLE_DOT, 1, clrSilver);

   IndicatorShortName(StringFormat("Candle Strength ATR(%d) %.2f", InpAtrPeriod, InpThreshold));
   IndicatorDigits(2);

   g_lastBarTime = 0;
   return(INIT_SUCCEEDED);
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
   if(rates_total < InpAtrPeriod + 2)
      return(0);

   ArraySetAsSeries(time,  true);
   ArraySetAsSeries(open,  true);
   ArraySetAsSeries(high,  true);
   ArraySetAsSeries(low,   true);
   ArraySetAsSeries(close, true);

   int limit;
   if(prev_calculated <= 0)
     {
      ArrayInitialize(BufStrength,   EMPTY_VALUE);
      ArrayInitialize(BufStrongBull, EMPTY_VALUE);
      ArrayInitialize(BufWeakBull,   EMPTY_VALUE);
      ArrayInitialize(BufStrongBear, EMPTY_VALUE);
      ArrayInitialize(BufWeakBear,   EMPTY_VALUE);
      limit = rates_total - InpAtrPeriod - 1;
     }
   else
      limit = rates_total - prev_calculated;

//--- strength in ATR units
   for(int i = limit; i >= 0; i--)
     {
      BufStrength[i]   = EMPTY_VALUE;
      BufStrongBull[i] = EMPTY_VALUE;
      BufWeakBull[i]   = EMPTY_VALUE;
      BufStrongBear[i] = EMPTY_VALUE;
      BufWeakBear[i]   = EMPTY_VALUE;

      double atr = iATR(NULL, 0, InpAtrPeriod, i);
      if(atr <= 0.0)
         continue;

      double value = CandleSize(open[i], high[i], low[i], close[i]) / atr;
      BufStrength[i] = value;

      if(value >= 0.0)
        {
         if(value >= InpThreshold)
            BufStrongBull[i] = value;
         else
            BufWeakBull[i] = value;
        }
      else
        {
         if(-value >= InpThreshold)
            BufStrongBear[i] = value;
         else
            BufWeakBear[i] = value;
        }
     }

//--- alert on the last closed bar
   if(time[0] != g_lastBarTime)
     {
      if(prev_calculated > 0)
         CheckStrongCandle(BufStrength[1]);
      g_lastBarTime = time[0];
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Signed candle size according to the selected measure             |
//+------------------------------------------------------------------+
double CandleSize(const double o, const double h, const double l, const double c)
  {
   if(InpMeasure == MEASURE_BODY)
      return(c - o);
   double range = h - l;
   return((c >= o) ? range : -range);
  }

//+------------------------------------------------------------------+
//| Alert when the last closed candle is strong                      |
//+------------------------------------------------------------------+
void CheckStrongCandle(const double value)
  {
   if(!InpAlertPopup && !InpAlertPush && !InpAlertSound)
      return;
   if(value == EMPTY_VALUE || MathAbs(value) < InpThreshold)
      return;

   string tf  = StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period), 7);
   string msg = StringFormat("%s %s: strong %s candle (%.2f x ATR)",
                             _Symbol, tf, (value > 0.0 ? "bullish" : "bearish"), MathAbs(value));
   if(InpAlertPopup)
      Alert(msg);
   if(InpAlertPush)
      SendNotification(msg);
   if(InpAlertSound)
      PlaySound(InpSoundFile);
  }
//+------------------------------------------------------------------+
