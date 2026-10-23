//+------------------------------------------------------------------+
//|                                                         Beginner |
//|                                                 Copyright © 2025 |
//+------------------------------------------------------------------+
#property version   "1.02"
#property description "Beginner - basic indicator for marking chart's highs and lows."
#property description "Repaints."
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrBlue
#property indicator_type1 DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_color2 clrRed
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#define   SH_BUY   1
#define   SH_SELL  -1

input int AllBars = 0;  // AllBars: How many bars to calculate on. 0 - all.
input int Otstup  = 30; // Otstup: Percentage distance to consider new low/high.
input int Per     = 9;  // Period: Number of bars to seek high/low on.

// Indicator buffers.
double    BufD[];
double    BufU[];

// Global variables.
int NB, UD;

//+------------------------------------------------------------------+
//| Initialization.                                                  |
//+------------------------------------------------------------------+
int init()
{
   // Calculating NB - number of bars to calculate the indicator on.
   if ((Bars < AllBars + Per) || (AllBars == 0)) NB = Bars - Per;
   else NB = AllBars;
   
   IndicatorShortName("Beginner(" + IntegerToString(Per) + ")");
   
   // Dots.
   SetIndexArrow(0, 159);
   SetIndexArrow(1, 159);
   
   SetIndexBuffer(0, BufU);
   SetIndexBuffer(1, BufD);
   
   SetIndexDrawBegin(0, Bars - NB);
   SetIndexDrawBegin(1, Bars - NB);
   
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   
   return(0);
}

//+------------------------------------------------------------------+
//| Indicator main function.                                         |
//+------------------------------------------------------------------+
int start()
{
   int CB = IndicatorCounted();

   if (CB < 0) return(-1);
   else if (NB > Bars - CB) NB = Bars - CB + 100;
   
   for (int SH = 1; SH < NB; SH++)
   {
      double R;
      int i;
      
      for (R = 0, i = SH; i < SH + 10; i++)
         R += (10 + SH - i) * (High[i] - Low[i]);
      
      R /= 55;

      double SHMax = High[iHighest(Symbol(), Period(), MODE_HIGH, Per, SH)];
      double SHMin = Low[iLowest(Symbol(), Period(), MODE_LOW, Per, SH)];
      
      BufU[SH] = EMPTY_VALUE;
      BufD[SH] = EMPTY_VALUE;
      
      if ((Close[SH] < SHMin + (SHMax - SHMin) * Otstup / 100) && (UD != SH_SELL))
      {
         BufU[SH] = Low[SH] - R * 0.5;
         UD = SH_SELL;
      }
      else if ((Close[SH] > SHMax - (SHMax - SHMin) * Otstup / 100) && (UD != SH_BUY))
      {
         BufD[SH] = High[SH] + R * 0.5;
         UD = SH_BUY;
      }
   }
   
   return(0);
}