//+------------------------------------------------------------------+
//|                                           Shtenco Oscillator.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                          https://www.mql5.com/ru/users/koshtenko |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2023, MetaQuotes Ltd."
#property link        "https://www.mql5.com/ru/users/koshtenko"
#property description "Shtenco Oscillator"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_label1  "Shtenco Oscillator"
//--- input parameters
input int InpPeriod=14;  // Period for SMA
//--- indicator buffers
double    ExtBuffer[];

int       ExtPeriod;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input value
   if(InpPeriod <= 0)
     {
      ExtPeriod = 14;
      PrintFormat("Incorrect input parameter InpPeriod = %d. Indicator will use value %d for calculations.", InpPeriod, ExtPeriod);
     }
   else
      ExtPeriod = InpPeriod;
//--- indicator buffers mapping
   SetIndexBuffer(0, ExtBuffer, INDICATOR_DATA);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpPeriod);
//--- name for DataWindow and indicator subwindow label
   string short_name = StringFormat("Shtenco Oscillator(%d)", ExtPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   PlotIndexSetString(0, PLOT_LABEL, short_name);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average Calculation                                |
//+------------------------------------------------------------------+
double CalculateSMA(const double &close[], int period, int index, double &sum)
  {
   sum += close[index];
   if (index >= period)
     sum -= close[index - period];
   
   return sum / period;
  }
//+------------------------------------------------------------------+
//| New Feature Indicator                                            |
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
   if (rates_total <= ExtPeriod)
      return 0;

   int start;
   double sum = 0.0;

   //--- preliminary calculations
   if (prev_calculated == 0)
     {
      //--- first Period values of the indicator are not calculated
      for (int i = 0; i < ExtPeriod; i++)
         ExtBuffer[i] = 0.0;
      start = ExtPeriod;

      // Calculate the initial sum for the first window
      for (int i = 0; i < ExtPeriod; i++)
         sum += close[i];
     }
   else
      start = prev_calculated - 1;

   //--- the main loop of calculations
   for (int i = start; i < rates_total && !IsStopped(); i++)
     {
      double sma = CalculateSMA(close, ExtPeriod, i, sum);
      ExtBuffer[i] = tick_volume[i] != 0 ? sma / tick_volume[i] : 0;
     }

   //--- return value of prev_calculated for next call
   return rates_total;
  }
