//+------------------------------------------------------------------+
//|                                             Consecutive_Bars.mq5 |
//|                            Copyright 2026, Ryan Lawrence Johnson |
//|                                https://www.mql5.com/en/users/rjo |
//+------------------------------------------------------------------+
//#version 1.41 - optimized for Renko & high-speed execution
//  - Removed MQL4-compat #define SERIES macros (used iOpen/iClose - very slow)
//  - Direct access to OnCalculate price arrays
//  - Iterative MA computation (O(n) instead of O(n^2))
//  - Minimal per-tick work when prev_calculated > 0
//  - No ArraySetAsSeries overhead on every iteration
//+------------------------------------------------------------------+

#property copyright   "(C) 2026, Ryan Lawrence Johnson"
#property link        "https://www.mql5.com/en/users/rjo"
#property version     "1.50"
#property indicator_separate_window

#property indicator_buffers 4
#property indicator_plots   4

//--- plot 0: consecutive up bars (section line)
#property indicator_type1   DRAW_SECTION
#property indicator_style1  STYLE_SOLID
#property indicator_color1  clrDodgerBlue
#property indicator_width1  1

//--- plot 1: consecutive down bars (section line)
#property indicator_type2   DRAW_SECTION
#property indicator_style2  STYLE_SOLID
#property indicator_color2  clrRed
#property indicator_width2  1

//--- plot 2: moving average of consecutive up bars
#property indicator_type3   DRAW_LINE
#property indicator_style3  STYLE_DOT
#property indicator_color3  clrAqua
#property indicator_width3  1

//--- plot 3: moving average of consecutive down bars
#property indicator_type4   DRAW_LINE
#property indicator_style4  STYLE_DOT
#property indicator_color4  clrMagenta
#property indicator_width4  1

//--- settings
input int            MaxBars    = 200;        // Max Bars to Show
input int            MAPeriodUp = 14;          // MA Period (Consec Up)
input ENUM_MA_METHOD MAMethodUp = MODE_EMA;   // MA Method (Consec Up)
input int            MAPeriodDn = 14;          // MA Period (Consec Dn)
input ENUM_MA_METHOD MAMethodDn = MODE_EMA;   // MA Method (Consec Dn)

//--- indicator buffers (AS_SERIES = false, standard MQL5 direction)
double consecUpBars[];
double consecDnBars[];
double maUpBars[];
double maDnBars[];

//--- persistent state across OnCalculate calls
int    lastCountUp;
int    lastCountDn;

//+------------------------------------------------------------------+
//| Compute a moving average over a source buffer (iterative O(n))   |
//+------------------------------------------------------------------+
void ComputeMA_Buffer(const double &src[], double &dst[], const int total,
                      const int period, const ENUM_MA_METHOD method,
                      const int startIdx)
  {
   if(period < 1 || total < period)
     {
      for(int i = startIdx; i < total; i++)
         dst[i] = EMPTY_VALUE;
      return;
     }

   switch(method)
     {
      case MODE_SMA:
        {
         double sum    = 0.0;
         int    filled = 0;
         for(int i = 0; i < total; i++)
           {
            double v = src[i];
            sum += v;
            filled++;
            if(filled > period)
              {
               sum -= src[i - period];
               filled = period;
              }
            if(i >= startIdx)
               dst[i] = (filled >= period) ? sum / period : EMPTY_VALUE;
           }
         break;
        }

      case MODE_EMA:
        {
         const double alpha = 2.0 / (period + 1.0);
         double sum = 0.0;
         for(int i = 0; i < period; i++)
            sum += src[i];
         double ema = sum / period;
         if(period - 1 >= startIdx)
            dst[period - 1] = ema;
         for(int i = period; i < total; i++)
           {
            ema = src[i] * alpha + ema * (1.0 - alpha);
            if(i >= startIdx)
               dst[i] = ema;
           }
         for(int i = startIdx; i < period - 1 && i < total; i++)
            dst[i] = EMPTY_VALUE;
         break;
        }

      case MODE_SMMA:
        {
         double sum = 0.0;
         for(int i = 0; i < period; i++)
            sum += src[i];
         double smma = sum / period;
         if(period - 1 >= startIdx)
            dst[period - 1] = smma;
         for(int i = period; i < total; i++)
           {
            smma = (smma * (period - 1) + src[i]) / period;
            if(i >= startIdx)
               dst[i] = smma;
           }
         for(int i = startIdx; i < period - 1 && i < total; i++)
            dst[i] = EMPTY_VALUE;
         break;
        }

      case MODE_LWMA:
        {
         for(int i = startIdx; i < total; i++)
           {
            if(i + period > total)
              {
               dst[i] = EMPTY_VALUE;
               continue;
              }
            double weightSum = 0.0;
            double valSum    = 0.0;
            for(int k = 0; k < period; k++)
              {
               double w = period - k;
               weightSum += w;
               valSum    += w * src[i + k];
              }
            dst[i] = valSum / weightSum;
           }
         break;
        }
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, consecUpBars, INDICATOR_DATA);
   PlotIndexSetString(0, PLOT_LABEL, "Consec Up Bars");

   SetIndexBuffer(1, consecDnBars, INDICATOR_DATA);
   PlotIndexSetString(1, PLOT_LABEL, "Consec Dn Bars");

   SetIndexBuffer(2, maUpBars, INDICATOR_DATA);
   PlotIndexSetString(2, PLOT_LABEL, "MA Up Bars");

   SetIndexBuffer(3, maDnBars, INDICATOR_DATA);
   PlotIndexSetString(3, PLOT_LABEL, "MA Dn Bars");

   IndicatorSetString(INDICATOR_SHORTNAME, "Consec Bars");

   lastCountUp = 0;
   lastCountDn = 0;

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
   int start;

   if(prev_calculated == 0)
     {
      lastCountUp = 0;
      lastCountDn = 0;
      start = 0;

      int drawBegin = rates_total - MaxBars;
      if(drawBegin < 0)
         drawBegin = 0;
      for(int p = 0; p < 4; p++)
         PlotIndexSetInteger(p, PLOT_DRAW_BEGIN, drawBegin);
     }
   else
     {
      start = 1;
     }

//--- PASS 1: forward scan for consecutive counts (oldest -> newest)
   int cUp = lastCountUp;
   int cDn = lastCountDn;

   for(int bar = start; bar < rates_total; bar++)
     {
      double cl = close[bar];
      double op = open[bar];

      if(cl > op)
        {
         if(bar > 0 && close[bar - 1] <= open[bar - 1])
            cUp = 1;
         else if(bar > 0)
            cUp++;
         consecUpBars[bar] = (double)cUp;
        }
      else
        {
         cUp = 0;
         consecUpBars[bar] = 0.0;
        }

      if(cl < op)
        {
         if(bar > 0 && close[bar - 1] >= open[bar - 1])
            cDn = 1;
         else if(bar > 0)
            cDn++;
         consecDnBars[bar] = (double)cDn;
        }
      else
        {
         cDn = 0;
         consecDnBars[bar] = 0.0;
        }
     }

   lastCountUp = cUp;
   lastCountDn = cDn;

//--- PASS 2: moving averages (iterative O(n) per buffer)
   ComputeMA_Buffer(consecUpBars, maUpBars, rates_total, MAPeriodUp, MAMethodUp, 0);
   ComputeMA_Buffer(consecDnBars, maDnBars, rates_total, MAPeriodDn, MAMethodDn, 0);

   return(rates_total);
  }
//+------------------------------------------------------------------+
