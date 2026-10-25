//+------------------------------------------------------------------+
//|                                            spreads.mq5
//|
//|answer to question  https://www.mql5.com/ru/forum/160683/page2440#comment_54567107 Before launching, make sure Symbol2 is in the market overview or add it
//|answer to question  https://www.mql5.com/ru/forum/160683/page2517#comment_55538088
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Roman Shiredchenko"
#property version   "1.3"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Current
#property indicator_label1  "Difference"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//+------------------------------------------------------------------+
input double Weighting_coefficients1 = 1;          // proportionality factor (position volume) of the first spread symbol
input int Coefficient_to_an_integer1 = 100000;     // number of quotation marks Sym 1
input string Symbol2 = "USDCAD";                   //second spread symbol
input bool   Symbol2_Reverse = true;               //inverse correlation
input double Weighting_coefficients2 = 1;          // proportionality factor (position volume) of the first spread symbol
input int Coefficient_to_an_integer2 = 100000;     // number of quotation marks Sym 2

//--- indicator buffers
double         BufferCurrent[];  // Current
const int EMPTY = -1;
int priv = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!SymbolSelect(Symbol2, true))
      return INIT_FAILED;
//--- indicator buffers mapping
   SetIndexBuffer(0, BufferCurrent, INDICATOR_DATA);
   PlotIndexSetString(0, PLOT_LABEL, "Spread");
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS, 0);
   PlotIndexSetInteger(0, PLOT_SHIFT, 0);
   ArraySetAsSeries(BufferCurrent, true);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,      // size of input timeseries
                const int prev_calculated,  // processed bars on previous call
                const datetime& time[],     // Time
                const double& open[],       // Open
                const double& high[],       // High
                const double& low[],        // Low
                const double& close[],      // Close
                const long& tick_volume[],  // Tick Volume
                const long& volume[],       // Real Volume
                const int& spread[])        // Spread
  {
   int limit = 0, corr = 0;
   if(prev_calculated <= 0)
     {
      limit = rates_total - 1;
      EventSetTimer(1);
      priv = 0;
     }

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   
   if(Bars(Symbol2,PERIOD_CURRENT)==0)
      return(0);
   
   for(int i = limit; i >= 0; i--)
     {
      datetime time2 = iTime(Symbol2, PERIOD_CURRENT, i - corr);
      if(time2 > time[i])                  //if there is no such bar on the current instrument
        {
         corr++;
         continue;
        }
      double open2 = iOpen(Symbol2, PERIOD_CURRENT, i);

      if(open2 != 0)
         if(!Symbol2_Reverse)
            BufferCurrent[i] = NormalizeDouble(Coefficient_to_an_integer1 * Weighting_coefficients1 * open[i] - Coefficient_to_an_integer2 * Weighting_coefficients2 * open2,0);
         else
            BufferCurrent[i] = NormalizeDouble(Coefficient_to_an_integer1 * Weighting_coefficients1 * open[i] + Coefficient_to_an_integer1 * Weighting_coefficients2 * open2,0);
     }

   priv = rates_total;
   return(rates_total);
  }
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(priv <= 0)                            // if it's a weekend and there are no new ticks
      ChartSetSymbolPeriod(0, _Symbol, PERIOD_CURRENT);
   else
      EventKillTimer();
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
