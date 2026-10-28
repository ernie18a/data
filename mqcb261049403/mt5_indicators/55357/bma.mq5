//+------------------------------------------------------------------+
//|                                              Band Moving Average |
//|                                    Copyright © 2025 Wolfforex.com|
//|                                        https://www.wolfforex.com |
//+------------------------------------------------------------------+
#property copyright "www.Wolfforex.com, 2025"
#property version   "1.06"
#property strict

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_color1  clrRed
#property indicator_color2  clrBlue
#property indicator_color3  clrGreen
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_SOLID
#property indicator_style3  STYLE_SOLID
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1

// Indicator parameters:
input int MA_Period = 49;
input int MA_Shift = 0;
input ENUM_MA_METHOD MA_Method = MODE_SMA;
input double Percentage = 2;

// Indicator buffers:
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   int    draw_begin;
   string short_name;

   if (MA_Period < 2)
   {
      Print("MA Period should be greater than 1.");
      return(INIT_PARAMETERS_INCORRECT);
   }

   // Drawing settings:
   draw_begin = MA_Period - 1;
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);

   PlotIndexSetInteger(0, PLOT_SHIFT, MA_Shift);
   PlotIndexSetInteger(1, PLOT_SHIFT, MA_Shift);
   PlotIndexSetInteger(2, PLOT_SHIFT, MA_Shift);
   
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, draw_begin);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, draw_begin);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, draw_begin);

   // Indicator short name:
   switch(MA_Method)
   {
      case MODE_SMA  : short_name = "Band SMA("; break;
      case MODE_EMA  : short_name = "Band EMA("; draw_begin = 0; break;
      case MODE_SMMA : short_name = "Band SMMA("; break;
      case MODE_LWMA : short_name = "Band LWMA(";
   }
   IndicatorSetString(INDICATOR_SHORTNAME, short_name + IntegerToString(MA_Period) + ")");

   // Indicator buffers mapping:
   SetIndexBuffer(0, ExtMapBuffer1, INDICATOR_DATA);
   SetIndexBuffer(1, ExtMapBuffer2, INDICATOR_DATA);
   SetIndexBuffer(2, ExtMapBuffer3, INDICATOR_DATA);

   // Initialization done.
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Data calculation                                                 |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &Close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   ArraySetAsSeries(Close, false);

   // Fill buffers with zero values for the first run.
   if (prev_calculated == 0)
   {
      ArrayInitialize(ExtMapBuffer1, 0.0);
      ArrayInitialize(ExtMapBuffer2, 0.0);
      ArrayInitialize(ExtMapBuffer3, 0.0);
   }

   // Not enought bars to use with the given period.
   if (rates_total <= MA_Period) return(0);

   switch(MA_Method)
   {
      case MODE_SMA  : sma(Close, rates_total); break;
      case MODE_EMA  : ema(Close, rates_total);  break;
      case MODE_SMMA : smma(Close, rates_total); break;
      case MODE_LWMA : lwma(Close, rates_total); 
   }

   return(rates_total);
}

//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
void sma(const double &Close[], const int rates_total)
{
   double sum = 0;
   int pos = 0;

   // Initial accumulation.
   for (int i = 0; i < (MA_Period - 1); i++, pos++) 
      sum += Close[pos];

   // Main calculation loop.
   while (pos < rates_total)
   {
      sum += Close[pos];
      ExtMapBuffer1[pos] = sum / MA_Period;
      ExtMapBuffer2[pos] = (ExtMapBuffer1[pos] / 100) * (100 + Percentage);
      ExtMapBuffer3[pos] = (ExtMapBuffer1[pos] / 100) * (100 - Percentage);
	   sum -= Close[pos - MA_Period + 1];
 	   pos++;
   }
}

//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
void ema(const double &Close[], const int rates_total)
{
   double pr = 2.0 / (MA_Period + 1);
   int   pos = 1;

   // Main calculation loop.
   while (pos < rates_total)
   {
      if (pos == 1) ExtMapBuffer1[0] = Close[0];
      ExtMapBuffer1[pos] = Close[pos] * pr + ExtMapBuffer1[pos - 1] * (1 - pr);
      ExtMapBuffer2[pos] = (ExtMapBuffer1[pos] / 100) * (100 + Percentage);
      ExtMapBuffer3[pos] = (ExtMapBuffer1[pos] / 100) * (100 - Percentage);
 	   pos++;
   }
}

//+------------------------------------------------------------------+
//| Smoothed Moving Average                                          |
//+------------------------------------------------------------------+
void smma(const double &Close[], const int rates_total)
{
   double sum = 0;
   int i;
   int pos = MA_Period;

   // Main calculation loop.
   while (pos < rates_total)
   {
      if (pos == MA_Period)
      {
         // Initial accumulation.
         for(i = 0; i < MA_Period; i++)
         {
            sum += Close[i];
            // Zero initial bars.
            ExtMapBuffer1[i] = 0;
            ExtMapBuffer2[i] = 0;
            ExtMapBuffer3[i] = 0;
         }
      }
      else sum = ExtMapBuffer1[pos - 1] * (MA_Period-1) + Close[pos];
      
      ExtMapBuffer1[pos] = sum / MA_Period;
      ExtMapBuffer2[pos] = (ExtMapBuffer1[pos] / 100) * (100 + Percentage);
      ExtMapBuffer3[pos] = (ExtMapBuffer1[pos] / 100) * (100 - Percentage);
 	   pos++;
   }
}

//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
void lwma(const double &Close[], const int rates_total)
{
   double sum = 0.0, lsum = 0.0;
   double price;
   int    i, weight = 0, pos = 0;

   // Initial accumulation.
   for (i = 1; i <= MA_Period; i++, pos++)
   {
      price = Close[pos];
      sum += price * i;
      lsum += price;
      weight += i;
   }

   // Main calculation loop.
   i = pos - MA_Period;
   while (pos < rates_total)
   {
      ExtMapBuffer1[pos] = sum / weight;
      ExtMapBuffer2[pos] = (ExtMapBuffer1[pos] / 100) * (100 + Percentage);
      ExtMapBuffer3[pos] = (ExtMapBuffer1[pos] / 100) * (100 - Percentage);
      if (pos == (rates_total - 1)) break;
      pos++;
      i++;
      price = Close[pos];
      sum = sum - lsum + price * MA_Period;
      lsum -= Close[i];
      lsum += price;
   }
}
//+------------------------------------------------------------------+