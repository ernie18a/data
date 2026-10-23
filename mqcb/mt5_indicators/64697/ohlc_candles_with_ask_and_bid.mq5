//+------------------------------------------------------------------+
//|                                              No gaps candles.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 7
#property indicator_plots   1

#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGreen, clrRed, clrGray

double OpenBuffer[];
double HighBuffer[];
double LowBuffer[];
double CloseBuffer[];
double ColorBuffer[];
double LastAsk[];
double LastBid[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, OpenBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, HighBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, LowBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, CloseBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, ColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5, LastAsk, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, LastBid, INDICATOR_CALCULATIONS);

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
      ArrayInitialize(LastAsk, 0.0);
      ArrayInitialize(LastBid, 0.0);
      start = 0;
     }
   else
     {
      start = prev_calculated - 1;
     }

   for(int i = start; i < rates_total; i++)
     {
      OpenBuffer[i] = open[i];
      CloseBuffer[i] = close[i];

      if(i < rates_total - 1)
        {
         HighBuffer[i] = (LastAsk[i] > 0) ? LastAsk[i] : high[i];
         LowBuffer[i] = (LastBid[i] > 0) ? LastBid[i] : low[i];
        }
      else
        {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         HighBuffer[i] = MathMax(high[i], ask);
         LowBuffer[i] = MathMin(low[i], bid);

         LastAsk[i] = HighBuffer[i];
         LastBid[i] = LowBuffer[i];
        }

      ColorBuffer[i] = (CloseBuffer[i] > OpenBuffer[i]) ? 0 : 
                       (CloseBuffer[i] < OpenBuffer[i]) ? 1 : 2;
     }

   return(rates_total);
  }
