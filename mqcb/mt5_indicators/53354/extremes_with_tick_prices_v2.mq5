//+------------------------------------------------------------------+
//|                             Higher High Lower Low with ticks.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+

#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "2.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "Extreme highs"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrChartreuse
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Extreme lows"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrChartreuse
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- input parameters
input int start = 5; // Lookback bars
input bool show_BoS = true; // Lines should keep drawing on BoS
input bool using_optimization = true; // Use ticks from current bar only


//--- indicator buffers
double HighBuffer[];
double LowBuffer[];


MqlTick ticks[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,HighBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LowBuffer,INDICATOR_DATA);

   ArraySetAsSeries(HighBuffer, true);
   ArraySetAsSeries(LowBuffer, true);

   ChartNavigate(0, CHART_END);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }


int ticksReceived = 0;

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

   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(time, true);
   
   int range = 0;

   datetime barStart = time[0]; // Start time of the current bar
   datetime barEnd = time[0] + PeriodSeconds(); // Start time of the next bar

   if(using_optimization)
     {
      datetime fromTime = iTime(Symbol(), Period(), 1);
      range = CopyTicksRange(Symbol(), ticks, COPY_TICKS_INFO, fromTime * 1000, TimeCurrent() * 1000);

      ticksReceived = range;
     }

   for(int i = start; i >= 0; i--)
     {

      if(!using_optimization)
        {

         datetime fromTime = iTime(Symbol(), Period(), start - i);
         range = CopyTicksRange(Symbol(), ticks, COPY_TICKS_INFO, fromTime * 1000, TimeCurrent() * 1000);

         ticksReceived = range;
        }

      double lowestBid = DBL_MAX;
      double highestAsk = -DBL_MAX;

      if(range > 0)
        {
         for(int k = 0; k < range; k++)
           {

            if(using_optimization)
              {

               if(ticks[k].time >= barStart && ticks[k].time <= barEnd)
                 {
                  if(ticks[k].bid != 0 && lowestBid > ticks[k].bid)
                     lowestBid = ticks[k].bid;

                  if(ticks[k].ask != 0 && highestAsk < ticks[k].ask)
                     highestAsk = ticks[k].ask;
                 }
              }
            else if(!using_optimization)
              {

               if(ticks[k].bid != 0 && lowestBid > ticks[k].bid)
                  lowestBid = ticks[k].bid;

               if(ticks[k].ask != 0 && highestAsk < ticks[k].ask)
                  highestAsk = ticks[k].ask;

              }
           }
        }

      double highestHigh = high[i];
      double lowestLow = low[i];

      for(int j = 1; j < start; j++)
        {
         if(high[i + j] > highestHigh)
            highestHigh = high[i + j]; // update highest high

         if(low[i + j] < lowestLow)
            lowestLow = low[i + j]; // update lowest low
        }


      // Assign the highest and lowest values to the buffers
      HighBuffer[i] = MathMax(highestHigh, highestAsk);
      LowBuffer[i] = MathMin(lowestLow, lowestBid);

      // Stop drawing extremum lines when there's a break of market structure
      if(!show_BoS)
        {
         if(HighBuffer[i] != HighBuffer[i + 1])
            HighBuffer[i + 1] = EMPTY_VALUE;
         if(LowBuffer[i] != LowBuffer[i + 1])
            LowBuffer[i + 1] = EMPTY_VALUE;
        }
     }

   for(int i = rates_total - 1; i >= start; i--)
     {
      HighBuffer[i] = EMPTY_VALUE;
      LowBuffer[i] = EMPTY_VALUE;
     }

   Comment("Ticks received: ", ticksReceived);


   return (rates_total);
  }
//+------------------------------------------------------------------+
