//+------------------------------------------------------------------+
//|                           Volume-Weighted Price Displacement.mq5 |
//|                                                 Sanmi Samuel Ojo |
//+------------------------------------------------------------------+
#property copyright "Sanmi Samuel Ojo"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Measures how far price has displaced from its rolling "
#property description "volume-weighted mean, normalized by rolling price "
#property description "volatility, to flag impulse and exhaustion conditions."

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2

//--- Plot 1: color histogram (the oscillator)
#property indicator_label1  "VW Displacement"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrSilver, clrGray, clrGainsboro, clrDimGray, clrBlack
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

//--- Plot 2: signal line (smoothed oscillator)
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_DASH
#property indicator_width2  1

//--- Level lines
#property indicator_level1  0.0
#property indicator_level2  1.0
#property indicator_level3  -1.0
#property indicator_level4  2.0
#property indicator_level5  -2.0
#property indicator_levelcolor clrLightGray
#property indicator_levelstyle STYLE_DOT

//--- Inputs
input int    InpVWAPPeriod      = 20;    // VWAP lookback period (bars)
input int    InpVolatilityPeriod = 14;   // StdDev lookback period for normalization
input int    InpSignalPeriod    = 5;     // Signal line smoothing period (SMA)
input double InpImpulseLevel    = 1.0;   // Impulse threshold (z-score)
input double InpExhaustionLevel = 2.0;   // Exhaustion threshold (z-score)
input ENUM_APPLIED_PRICE InpVWAPPrice = PRICE_TYPICAL; // Price used for VWAP weighting

//--- Buffers
double OscBuffer[];
double OscColor[];
double SignalBuffer[];
double VWAPWork[];      // internal working buffer, not plotted
double TPVolWork[];     // internal working buffer, not plotted

//--- Color indices for the histogram
#define CLR_BULL_EXHAUST 0
#define CLR_BULL_IMPULSE 1
#define CLR_NEUTRAL      2
#define CLR_BEAR_IMPULSE 3
#define CLR_BEAR_EXHAUST 4

int g_minBars;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpVWAPPeriod < 2 || InpVolatilityPeriod < 2 || InpSignalPeriod < 1)
     {
      Print("VWPDO: invalid input period(s). All periods must be >= 2 (signal >= 1).");
      return(INIT_PARAMETERS_INCORRECT);
     }

   SetIndexBuffer(0, OscBuffer,    INDICATOR_DATA);
   SetIndexBuffer(1, OscColor,     INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, SignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, VWAPWork,     INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, TPVolWork,    INDICATOR_CALCULATIONS);

   ArraySetAsSeries(OscBuffer,    false);
   ArraySetAsSeries(OscColor,     false);
   ArraySetAsSeries(SignalBuffer, false);
   ArraySetAsSeries(VWAPWork,     false);
   ArraySetAsSeries(TPVolWork,    false);

   g_minBars = MathMax(InpVWAPPeriod, InpVolatilityPeriod) + InpSignalPeriod;

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, g_minBars);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, g_minBars);

   IndicatorSetString(INDICATOR_SHORTNAME,
      StringFormat("VW-Displacement(%d,%d,%d)", InpVWAPPeriod, InpVolatilityPeriod, InpSignalPeriod));
   IndicatorSetInteger(INDICATOR_DIGITS, 3);

   return(INIT_SUCCEEDED);
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
   if(rates_total < g_minBars + 1)
      return(0);

   int start;
   if(prev_calculated <= 0)
      start = 0;
   else
      start = prev_calculated - 1;

   for(int i = start; i < rates_total; i++)
     {
      //--- typical/applied price and volume used for VWAP weighting
      double price = GetAppliedPrice(InpVWAPPrice, open, high, low, close, i);
      double vol   = (double)(tick_volume[i] > 0 ? tick_volume[i] : 1);
      TPVolWork[i] = price * vol;

      if(i < InpVWAPPeriod - 1)
        {
         VWAPWork[i]   = EMPTY_VALUE;
         OscBuffer[i]  = EMPTY_VALUE;
         OscColor[i]   = CLR_NEUTRAL;
         SignalBuffer[i] = EMPTY_VALUE;
         continue;
        }

      //--- rolling VWAP over InpVWAPPeriod bars ending at i
      double sumTPVol = 0.0, sumVol = 0.0;
      for(int k = i - InpVWAPPeriod + 1; k <= i; k++)
        {
         sumTPVol += TPVolWork[k];
         sumVol   += (double)(tick_volume[k] > 0 ? tick_volume[k] : 1);
        }
      double vwap = (sumVol > 0.0) ? sumTPVol / sumVol : close[i];
      VWAPWork[i] = vwap;

      if(i < InpVolatilityPeriod - 1)
        {
         OscBuffer[i]  = EMPTY_VALUE;
         OscColor[i]   = CLR_NEUTRAL;
         SignalBuffer[i] = EMPTY_VALUE;
         continue;
        }

      //--- rolling stdev of close over InpVolatilityPeriod bars ending at i
      double sumC = 0.0;
      for(int k = i - InpVolatilityPeriod + 1; k <= i; k++)
         sumC += close[k];
      double meanC = sumC / InpVolatilityPeriod;

      double sumSq = 0.0;
      for(int k = i - InpVolatilityPeriod + 1; k <= i; k++)
         sumSq += (close[k] - meanC) * (close[k] - meanC);
      double stdev = MathSqrt(sumSq / InpVolatilityPeriod);

      double osc;
      if(stdev > 0.0000001)
         osc = (close[i] - vwap) / stdev;
      else
         osc = 0.0;

      OscBuffer[i] = osc;

      //--- color classification
      if(osc >= InpExhaustionLevel)
         OscColor[i] = CLR_BULL_EXHAUST;
      else if(osc >= InpImpulseLevel)
         OscColor[i] = CLR_BULL_IMPULSE;
      else if(osc <= -InpExhaustionLevel)
         OscColor[i] = CLR_BEAR_EXHAUST;
      else if(osc <= -InpImpulseLevel)
         OscColor[i] = CLR_BEAR_IMPULSE;
      else
         OscColor[i] = CLR_NEUTRAL;

      //--- signal line: SMA of the oscillator over InpSignalPeriod bars
      if(i < g_minBars - 1)
        {
         SignalBuffer[i] = EMPTY_VALUE;
         continue;
        }

      double sumOsc = 0.0;
      bool ready = true;
      for(int k = i - InpSignalPeriod + 1; k <= i; k++)
        {
         if(OscBuffer[k] == EMPTY_VALUE)
           {
            ready = false;
            break;
           }
         sumOsc += OscBuffer[k];
        }
      SignalBuffer[i] = ready ? (sumOsc / InpSignalPeriod) : EMPTY_VALUE;
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }

//+------------------------------------------------------------------+
//| Helper: return requested applied price for a given bar index     |
//+------------------------------------------------------------------+
double GetAppliedPrice(const ENUM_APPLIED_PRICE type,
                        const double &open[],
                        const double &high[],
                        const double &low[],
                        const double &close[],
                        const int i)
  {
   switch(type)
     {
      case PRICE_CLOSE:    return(close[i]);
      case PRICE_OPEN:     return(open[i]);
      case PRICE_HIGH:     return(high[i]);
      case PRICE_LOW:      return(low[i]);
      case PRICE_MEDIAN:   return((high[i] + low[i]) / 2.0);
      case PRICE_TYPICAL:  return((high[i] + low[i] + close[i]) / 3.0);
      case PRICE_WEIGHTED: return((high[i] + low[i] + 2.0 * close[i]) / 4.0);
      default:             return((high[i] + low[i] + close[i]) / 3.0);
     }
  }
//+------------------------------------------------------------------+
