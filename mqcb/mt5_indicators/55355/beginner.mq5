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
#property indicator_plots   1
#property indicator_color1  clrBlue, clrRed
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#define   SH_BUY   1
#define   SH_SELL  -1

input int AllBars = 0;  // AllBars: How many bars to calculate on. 0 - all.
input int Otstup  = 30; // Otstup: Percentage distance to consider new low/high.
input int Per     = 9;  // Period: Number of bars to seek high/low on.

// Indicator buffers.
double    Buf[];
double    BufCol[];

// Global variables.
int NB, UD;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, "Beginner(" + IntegerToString(Per) + ")");

   PlotIndexSetInteger(0, PLOT_ARROW, 159);

   SetIndexBuffer(0, Buf, INDICATOR_DATA);
   SetIndexBuffer(1, BufCol, INDICATOR_COLOR_INDEX);
}

//+------------------------------------------------------------------+
//| Custom Beginner                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   double dbOtstup = Otstup;

   ArraySetAsSeries(High, true);
   ArraySetAsSeries(Low, true);
   ArraySetAsSeries(Close, true);

   // NB will hold the number of bars for indicator calculation.
   if ((rates_total < (AllBars + Per)) || (AllBars == 0)) NB = rates_total - Per;
   else NB = AllBars;

   int CB = prev_calculated;
   
   if (CB < 0) return(-1);
   else if (NB > (rates_total - CB)) NB = rates_total - CB + 100;
   
   for (int SH = 1; SH < NB; SH++) // R is needed for distance between chart and arrows.
   {
      double R;
      int i;

      for (R = 0, i = SH; i < SH + 10; i++)
         R += (10 + SH - i) * (High[i] - Low[i]);

      R /= 55;

      double SHMax = High[ArrayMaximum(High, SH, Per)];
      double SHMin = Low[ArrayMinimum(Low, SH, Per)];
      double diff = (SHMax - SHMin) * dbOtstup / 100.0;
      
      Buf[rates_total - SH - 1] = EMPTY_VALUE;
      
      if ((Close[SH] < (SHMin + diff)) && (UD != SH_SELL))
      {
         Buf[rates_total - SH - 1] = Low[SH] - R * 0.5;
         BufCol[rates_total - SH - 1] = 0;
         UD = SH_SELL;
      }
      else if ((Close[SH] > (SHMax - diff)) && (UD != SH_BUY))
      {
         Buf[rates_total - SH - 1] = High[SH] + R * 0.5;
         BufCol[rates_total - SH - 1] = 1;
         UD = SH_BUY;
      }
   }
   
   return(rates_total);
}