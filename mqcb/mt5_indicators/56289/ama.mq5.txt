//+------------------------------------------------------------------+
//|                                              SelfOptimizedMA.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//|                                          Author: Yashar Seyyedin |
//|       Web Address: https://www.mql5.com/en/users/yashar.seyyedin |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot AMA
#property indicator_label1  "AMALower"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot AMA
#property indicator_label2  "AMAUpper"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3
//--- indicator buffers
double         AMALowerBuffer[];
double         AMAUpperBuffer[];

//input parameters
input int MAX_PERIOD =50;
input int MIN_PERIOD =25;
input int DIST_LOOKBACK =100;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,AMALowerBuffer,INDICATOR_DATA);
   ArraySetAsSeries(AMALowerBuffer,true);
   
   SetIndexBuffer(1,AMAUpperBuffer,INDICATOR_DATA);
   ArraySetAsSeries(AMAUpperBuffer,true);
//---
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
//---
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   int BARS=MathMax(rates_total-prev_calculated-2*DIST_LOOKBACK,1);

   for(int i=BARS; i>=0; i--)
     {
      AMALowerBuffer[i] = AMALower(i, open, high, low, close);
      AMAUpperBuffer[i] = AMAUpper(i, open, high, low, close);
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AMALower(int index,
           const double &open[],
           const double &high[],
           const double &low[],
           const double &close[]
          )
  {
   for(int len=MAX_PERIOD;len>=MIN_PERIOD;len--)
     {
      for(int i=index;i<index+DIST_LOOKBACK;i++)
        {
         if(close[i]<sma(close, len, i) && close[i+1]<sma(close, len, i+1))
            break;
         if(BounceUp(i, len, open, high, low, close))
            return sma(close, len, index);
        }
     }
   return EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AMAUpper(int index,
           const double &open[],
           const double &high[],
           const double &low[],
           const double &close[]
          )
  {
   for(int len=MAX_PERIOD;len>=MIN_PERIOD;len--)
     {
      for(int i=index;i<index+DIST_LOOKBACK;i++)
        {
         if(close[i]>sma(close, len, i) && close[i+1]>sma(close, len, i+1))
            break;
         if(BounceDown(i, len, open, high, low, close))
            return sma(close, len, index);
        }
     }
   return EMPTY_VALUE;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BounceUp(int index, int len,
              const double &open[],
              const double &high[],
              const double &low[],
              const double &close[]
             )
  {
   if(close[index]<sma(close, len, index))
      return false;
   if(low[index+1]>sma(close, len, index+1))
      return false;
   if(close[index+2]<sma(close, len, index+2))
      return false;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BounceDown(int index, int len,
              const double &open[],
              const double &high[],
              const double &low[],
              const double &close[]
             )
  {
   if(close[index]>sma(close, len, index))
      return false;
   if(high[index+1]<sma(close, len, index+1))
      return false;
   if(close[index+2]>sma(close, len, index+2))
      return false;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double sma(const double &src[], int length, int index)
  {
   double sum = 0.0;
   for(int i = index; i<index+length; i++)
      sum = sum + src[i] / length;
   return sum;
  }
//+------------------------------------------------------------------+

