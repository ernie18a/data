//+------------------------------------------------------------------+
//|                                 FractalDimensionTrendStrength.mq5 |
//|                                           Copyright Bosede Gbadebo |
//|                                       https://www.mql5.com        |
//+------------------------------------------------------------------+
#property copyright "Bosede Gbadebo"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Quantifies trend strength versus choppiness using a rolling, Katz-style fractal dimension of price."

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1

#property indicator_minimum 1.0
#property indicator_maximum 2.0
#property indicator_level1  1.40
#property indicator_level2  1.65
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor clrSilver
#property indicator_levelwidth 1

#property indicator_label1  "Fractal Dimension"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLimeGreen, clrOrangeRed, clrSilver
#property indicator_width1  2
#property indicator_style1  STYLE_SOLID

//--- Inputs
input int                InpFractalPeriod   = 30;          // Fractal Dimension lookback period (bars)
input int                InpSmoothPeriod    = 5;            // Smoothing period applied to raw FD (EMA)
input double             InpTrendThreshold  = 1.40;         // FD <= this value marks a trending market
input double             InpChopThreshold   = 1.65;         // FD >= this value marks a choppy/ranging market
input ENUM_APPLIED_PRICE InpAppliedPrice    = PRICE_CLOSE;  // Price source used in the FD calculation

//--- Indicator buffers
double FD_Smoothed[];   // plotted line (smoothed fractal dimension, 1.0 - 2.0)
double FD_Color[];      // color index buffer: 0=trending, 1=choppy, 2=neutral
double FD_Raw[];        // internal, non-plotted calculation buffer

//+------------------------------------------------------------------+
//| Returns the applied price for bar i from the standard OHLC sets  |
//+------------------------------------------------------------------+
double GetAppliedPrice(const int i,
                        const double &open[],
                        const double &high[],
                        const double &low[],
                        const double &close[])
  {
   switch(InpAppliedPrice)
     {
      case PRICE_OPEN:     return(open[i]);
      case PRICE_HIGH:     return(high[i]);
      case PRICE_LOW:      return(low[i]);
      case PRICE_MEDIAN:   return((high[i] + low[i]) / 2.0);
      case PRICE_TYPICAL:  return((high[i] + low[i] + close[i]) / 3.0);
      case PRICE_WEIGHTED: return((high[i] + low[i] + 2.0 * close[i]) / 4.0);
      default:             return(close[i]); // PRICE_CLOSE
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                        |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, FD_Smoothed, INDICATOR_DATA);
   SetIndexBuffer(1, FD_Color,    INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, FD_Raw,      INDICATOR_CALCULATIONS);

   ArraySetAsSeries(FD_Smoothed, false);
   ArraySetAsSeries(FD_Color,    false);
   ArraySetAsSeries(FD_Raw,      false);

   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpFractalPeriod);
   PlotIndexSetString(0, PLOT_LABEL, "Fractal Dimension");

   IndicatorSetString(INDICATOR_SHORTNAME,
                       StringFormat("Fractal Dimension Trend Strength (%d,%d)", InpFractalPeriod, InpSmoothPeriod));
   IndicatorSetInteger(INDICATOR_DIGITS, 3);

   if(InpFractalPeriod < 5)
     {
      Print("InpFractalPeriod must be >= 5. Indicator will not calculate correctly with smaller values.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpSmoothPeriod < 1)
     {
      Print("InpSmoothPeriod must be >= 1.");
      return(INIT_PARAMETERS_INCORRECT);
     }

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
   if(rates_total < InpFractalPeriod + 1)
      return(0);

   int start;
   if(prev_calculated == 0)
      start = InpFractalPeriod;
   else
      start = prev_calculated - 1;

   if(start < InpFractalPeriod)
      start = InpFractalPeriod;

   double alpha = 2.0 / (InpSmoothPeriod + 1.0);

   for(int i = start; i < rates_total; i++)
     {
      int winStart = i - InpFractalPeriod + 1;
      if(winStart < 0)
        {
         FD_Raw[i]      = 1.0;
         FD_Smoothed[i] = 1.0;
         FD_Color[i]    = 2.0;
         continue;
        }

      //--- Katz-style fractal dimension over the lookback window
      double p0   = GetAppliedPrice(winStart, open, high, low, close);
      double prevP = p0;
      double L    = 0.0;   // total path length (sum of step distances)
      double dmax = 0.0;   // diameter (max distance from the first point)

      for(int j = winStart + 1; j <= i; j++)
        {
         double pj = GetAppliedPrice(j, open, high, low, close);
         L += MathAbs(pj - prevP);
         double dist0 = MathAbs(pj - p0);
         if(dist0 > dmax)
            dmax = dist0;
         prevP = pj;
        }

      int n = InpFractalPeriod - 1;
      double fd;
      if(L > 0.0 && dmax > 0.0 && n > 1)
         fd = MathLog(n) / (MathLog(dmax / L) + MathLog(n));
      else
         fd = 1.0;

      if(fd < 1.0) fd = 1.0;
      if(fd > 2.0) fd = 2.0;

      FD_Raw[i] = fd;

      //--- EMA smoothing of the raw fractal dimension
      if(i == InpFractalPeriod)
         FD_Smoothed[i] = fd;
      else
         FD_Smoothed[i] = FD_Smoothed[i - 1] + alpha * (fd - FD_Smoothed[i - 1]);

      //--- Color zone classification
      if(FD_Smoothed[i] <= InpTrendThreshold)
         FD_Color[i] = 0.0; // trending
      else if(FD_Smoothed[i] >= InpChopThreshold)
         FD_Color[i] = 1.0; // choppy
      else
         FD_Color[i] = 2.0; // neutral / transition
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
