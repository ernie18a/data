//+------------------------------------------------------------------+
//|                                            CandleStrengthATR.mq5 |
//|                                           Copyright 2026, Osazee |
//|                           https://www.mql5.com/en/users/45266274 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Osazee"
#property link        "https://www.mql5.com/en/users/45266274"
#property version     "1.00"
#property description "Measures each candle's body (or full range) in units of ATR."
#property description "Positive values are bullish, negative values are bearish."
#property description "Candles beyond the threshold are highlighted as strong."
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1

#property indicator_label1  "Candle Strength (x ATR)"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrForestGreen,clrLightGreen,clrCrimson,clrLightPink
#property indicator_width1  2

enum ENUM_STRENGTH_MEASURE
  {
   MEASURE_BODY  = 0, // Body (close - open)
   MEASURE_RANGE = 1  // Full range (high - low), signed by direction
  };

input group "Calculation"
input int                   InpAtrPeriod = 14;           // ATR period
input ENUM_STRENGTH_MEASURE InpMeasure   = MEASURE_BODY; // Candle size to measure
input double                InpThreshold = 0.7;          // Strong candle threshold (x ATR)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "Alerts (closed bars only)"
input bool   InpAlertPopup = false;       // Pop-up alert on strong candle
input bool   InpAlertPush  = false;       // Push notification on strong candle
input bool   InpAlertSound = false;       // Play sound on strong candle
input string InpSoundFile  = "alert.wav"; // Sound file

//--- color indexes
#define CLR_STRONG_BULL 0
#define CLR_WEAK_BULL   1
#define CLR_STRONG_BEAR 2
#define CLR_WEAK_BEAR   3

//--- buffers
double BufStrength[];
double BufColor[];
double BufAtr[];

//--- globals
int      g_atrHandle   = INVALID_HANDLE;
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

   g_atrHandle = iATR(_Symbol, _Period, InpAtrPeriod);
   if(g_atrHandle == INVALID_HANDLE)
     {
      Print("Failed to create the ATR handle, error ", GetLastError());
      return(INIT_FAILED);
     }

   SetIndexBuffer(0, BufStrength, INDICATOR_DATA);
   SetIndexBuffer(1, BufColor,    INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, BufAtr,      INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpAtrPeriod);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);

//--- threshold levels
   IndicatorSetInteger(INDICATOR_LEVELS, 2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0,  InpThreshold);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, -InpThreshold);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, clrSilver);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, STYLE_DOT);

   IndicatorSetString(INDICATOR_SHORTNAME,
                      StringFormat("Candle Strength ATR(%d) %.2f", InpAtrPeriod, InpThreshold));
   IndicatorSetInteger(INDICATOR_DIGITS, 2);

   g_lastBarTime = 0;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Release the ATR handle                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_atrHandle != INVALID_HANDLE)
      IndicatorRelease(g_atrHandle);
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
   if(rates_total < InpAtrPeriod + 2)
      return(0);
   if(BarsCalculated(g_atrHandle) < rates_total)
      return(prev_calculated);

   ArraySetAsSeries(time,  false);
   ArraySetAsSeries(open,  false);
   ArraySetAsSeries(high,  false);
   ArraySetAsSeries(low,   false);
   ArraySetAsSeries(close, false);

//--- copy ATR values
   int toCopy = (prev_calculated <= 0 || prev_calculated > rates_total)
                ? rates_total : rates_total - prev_calculated + 1;
   if(CopyBuffer(g_atrHandle, 0, 0, toCopy, BufAtr) <= 0)
      return(prev_calculated);

   int start;
   if(prev_calculated <= 0)
     {
      for(int k = 0; k < InpAtrPeriod; k++)
        {
         BufStrength[k] = EMPTY_VALUE;
         BufColor[k]    = CLR_WEAK_BULL;
        }
      start = InpAtrPeriod;
     }
   else
      start = prev_calculated - 1;

//--- strength in ATR units
   for(int i = start; i < rates_total; i++)
     {
      double atr = BufAtr[i];
      if(atr <= 0.0)
        {
         BufStrength[i] = EMPTY_VALUE;
         BufColor[i]    = CLR_WEAK_BULL;
         continue;
        }
      double value   = CandleSize(open[i], high[i], low[i], close[i]) / atr;
      BufStrength[i] = value;
      BufColor[i]    = ColorIndex(value);
     }

//--- alert on the last closed bar
   if(time[rates_total - 1] != g_lastBarTime)
     {
      if(prev_calculated > 0)
         CheckStrongCandle(BufStrength[rates_total - 2]);
      g_lastBarTime = time[rates_total - 1];
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
//| Histogram color index for a strength value                       |
//+------------------------------------------------------------------+
double ColorIndex(const double value)
  {
   if(value >= 0.0)
      return((value >= InpThreshold) ? CLR_STRONG_BULL : CLR_WEAK_BULL);
   return((-value >= InpThreshold) ? CLR_STRONG_BEAR : CLR_WEAK_BEAR);
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
