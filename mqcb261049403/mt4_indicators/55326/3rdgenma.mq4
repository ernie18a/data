//+------------------------------------------------------------------+
//|                                                     3rdGenMA.mq4 |
//|                                    Copyright © 2025 Wolfforex.com|
//|                                        https://www.wolfforex.com |
//+------------------------------------------------------------------+
#property copyright "www.Wolfforex.com, 2025"
#property version   "1.01"
#property strict

#property description "3rd Generation MA based on research paper by Dr. Manfred"
#property description "Offers least possible lag but still provides price smoothing."

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrRed
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

// Indicator parameters.
input int MA_Period = 50;
input int MA_Sampling_Period = 220; // MA_Sampling_Period (should be more than 4 * MA_Period)
input ENUM_MA_METHOD MA_Method = MODE_EMA;
input ENUM_APPLIED_PRICE MA_Applied_Price = PRICE_TYPICAL;

// Indicator buffers.
double MA3G[];
double MA1[];

// Global variables.
double Lambda, Alpha;

int OnInit()
{
   int    draw_begin;
   string short_name;

   if (MA_Sampling_Period < MA_Period * 4)
   {
      Print("MA_Sampling_Period should be >= MA_Period * 4.");
      return(INIT_FAILED);
   }

   IndicatorBuffers(2);

   IndicatorDigits(_Digits);
   
   draw_begin = MA_Sampling_Period - 1;

   switch(MA_Method)
   {
      case MODE_EMA:
         short_name = "3GEMA(";  
         break;
      case MODE_SMMA:
         short_name = "3GSMMA(";
         break;
      case MODE_LWMA:
         short_name = "3GLWMA(";
         break;
      default:
         short_name = "3GSMA(";
   }
   IndicatorShortName(short_name + IntegerToString(MA_Period) + "," + IntegerToString(MA_Sampling_Period) + ")");

   SetIndexDrawBegin(0, draw_begin);

   SetIndexBuffer(0, MA3G);
   SetIndexBuffer(1, MA1);

   Lambda = 1.0 * MA_Sampling_Period / (1.0 * MA_Period);
   Alpha = Lambda * (MA_Sampling_Period - 1) / (MA_Sampling_Period - Lambda);

   Print("Lambda = ", Lambda, "; Alpha = ", Alpha);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| 3rd Generation Moving Average Custom Indicator                   |
//+------------------------------------------------------------------+
int start()
{
   int i;
   int TotalPeriod = MA_Period + MA_Sampling_Period;

   if (Bars <= TotalPeriod)
   {
      Print("Not enough bars.");
      return(0);
   }
   int ExtCountedBars = IndicatorCounted();
   // Check for possible errors.
   if (ExtCountedBars < 0) return(-1);
   // Last counted bar will be recounted.
   if (ExtCountedBars > 0) ExtCountedBars--;
   if (ExtCountedBars < TotalPeriod) ExtCountedBars = TotalPeriod;

   for (i = Bars - ExtCountedBars - 1; i >= 0; i--)
      MA1[i] = iMA(NULL, 0, MA_Sampling_Period, 0, MA_Method, MA_Applied_Price, i);
   
   for (i = Bars - ExtCountedBars - 1; i >= 0; i--)
   {
      double MA2 = iMAOnArray(MA1, 0, MA_Period, 0, MA_Method, i);
      MA3G[i] = (Alpha + 1) * MA1[i] - Alpha * MA2;
   }

   return(0);
}
//+------------------------------------------------------------------+