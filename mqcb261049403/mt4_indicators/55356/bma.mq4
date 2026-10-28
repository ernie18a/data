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

// Global variables:
int ExtCountedBars = 0;

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
   SetIndexShift(0, MA_Shift);
   SetIndexShift(1, MA_Shift);
   SetIndexShift(2, MA_Shift);
   IndicatorDigits(_Digits);
   draw_begin = MA_Period - 1;

   // Indicator short name:
   switch(MA_Method)
   {
      case MODE_SMA : short_name = "Band SMA("; break;
      case MODE_EMA : short_name = "Band EMA(";  draw_begin = 0; break;
      case MODE_SMMA : short_name = "Band SMMA("; break;
      case MODE_LWMA : short_name = "Band LWMA(";
   }
   IndicatorShortName(short_name + IntegerToString(MA_Period) + ")");
   
   SetIndexDrawBegin(0, draw_begin);
   SetIndexDrawBegin(1, draw_begin);
   SetIndexDrawBegin(2, draw_begin);

   // Indicator buffers mapping:
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexBuffer(2, ExtMapBuffer3);

   // Initialization done.
   return(INIT_SUCCEEDED);
}
  
//+------------------------------------------------------------------+
//| Data calculation                                                 |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[]
)
{
   if (Bars <= MA_Period) return(0);
   
   ExtCountedBars = IndicatorCounted();

   // Check for possible errors.
   if (ExtCountedBars < 0) return(0);

   // Last counted bar will be recounted.
   if (ExtCountedBars > 0) ExtCountedBars--;

   switch(MA_Method)
   {
      case MODE_SMA : sma();  break;
      case MODE_EMA : ema();  break;
      case MODE_SMMA : smma(); break;
      case MODE_LWMA : lwma();
   }

   return(rates_total);
}

//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
void sma()
{
   double sum = 0;
   int    i, pos = Bars - ExtCountedBars - 1;

   // Initial accumulation.
   if (pos < MA_Period) pos = MA_Period;
   for (i = 1; i < MA_Period; i++, pos--)
      sum += Close[pos];

   // Main calculation loop.
   while (pos >= 0)
   {
      sum += Close[pos];
      ExtMapBuffer1[pos] = sum / MA_Period;
      ExtMapBuffer2[pos] = (ExtMapBuffer1[pos] / 100) * (100 + Percentage);
      ExtMapBuffer3[pos] = (ExtMapBuffer1[pos] / 100) * (100 - Percentage);
      sum -= Close[pos + MA_Period - 1];
      pos--;
   }

   // Zero initial bars.
   if (ExtCountedBars < 1)
   {
      for (i = 1; i < MA_Period; i++)
      {
         ExtMapBuffer1[Bars - i] = 0;
         ExtMapBuffer2[Bars - i] = 0;
         ExtMapBuffer3[Bars - i] = 0;
      }
   }
}

//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
void ema()
{
   double pr = 2.0 / (MA_Period + 1);
   int    pos = Bars - 2;
   if (ExtCountedBars > 2) pos = Bars - ExtCountedBars - 1;

   // Main calculation loop.
   while (pos >= 0)
   {
      if (pos == Bars - 2) ExtMapBuffer1[pos + 1] = Close[pos + 1];
      ExtMapBuffer1[pos] = Close[pos] * pr + ExtMapBuffer1[pos + 1] * (1 - pr);
      ExtMapBuffer2[pos] = (ExtMapBuffer1[pos] / 100) * (100 + Percentage);
      ExtMapBuffer3[pos] = (ExtMapBuffer1[pos] / 100) * (100 - Percentage);
      pos--;
   }
}

//+------------------------------------------------------------------+
//| Smoothed Moving Average                                          |
//+------------------------------------------------------------------+
void smma()
{
   double sum = 0;
   int    i, k, pos = Bars - ExtCountedBars + 1;

   // Main calculation loop.
   pos = Bars - MA_Period;
   if (pos > Bars - ExtCountedBars) pos = Bars - ExtCountedBars;
   while (pos >= 0)
   {
      if (pos == Bars - MA_Period)
      {
         // Initial accumulation.
         for (i = 0, k = pos; i < MA_Period; i++, k++)
         {
            sum += Close[k];
            // Zero initial bars.
            ExtMapBuffer1[k] = 0;
            ExtMapBuffer2[k] = 0;
            ExtMapBuffer3[k] = 0;
         }
      }
      else sum = ExtMapBuffer1[pos + 1] * (MA_Period - 1) + Close[pos];
      ExtMapBuffer1[pos] = sum / MA_Period;
      ExtMapBuffer2[pos] = (ExtMapBuffer1[pos] / 100) * (100 + Percentage);
      ExtMapBuffer3[pos] = (ExtMapBuffer1[pos] / 100) * (100 - Percentage);
      pos--;
   }
}

//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
void lwma()
{
   double sum = 0.0, lsum = 0.0;
   double price;
   int    i, weight = 0, pos = Bars - ExtCountedBars - 1;

   // Initial accumulation.
   if (pos < MA_Period) pos = MA_Period;
   for (i = 1; i <= MA_Period; i++, pos--)
   {
      price = Close[pos];
      sum += price * i;
      lsum += price;
      weight += i;
   }
   // Main calculation loop.
   pos++;
   i = pos + MA_Period;
   while (pos >= 0)
   {
      ExtMapBuffer1[pos] = sum / weight;
      ExtMapBuffer2[pos] = (ExtMapBuffer1[pos] / 100) * (100 + Percentage);
      ExtMapBuffer3[pos] = (ExtMapBuffer1[pos] / 100) * (100 - Percentage);
      if (pos == 0) break;
      pos--;
      i--;
      price = Close[pos];
      sum = sum - lsum + price * MA_Period;
      lsum -= Close[i];
      lsum += price;
   }

   // Zero initial bars.
   if (ExtCountedBars<1)
   {
      for (i = 1; i < MA_Period; i++)
      {
         ExtMapBuffer1[Bars - i] = 0;
         ExtMapBuffer2[Bars - i] = 0;
         ExtMapBuffer3[Bars - i] = 0;
      }
   }
}
//+------------------------------------------------------------------+