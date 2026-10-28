//+------------------------------------------------------------------+
//|                                             AIS Central Axis.mq5 |
//|                                                        AIS Forex |
//|                        https://www.mql5.com/ru/users/aleksej1966 |
//+------------------------------------------------------------------+
#property copyright "AIS Forex"
#property link      "https://www.mql5.com/ru/users/aleksej1966"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_type1  DRAW_LINE
#property indicator_label1 "Central Axis"
#property indicator_color1 clrBlue
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID

input uchar iPeriod=3;

int period;
double buffer[],max[],min[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,buffer,INDICATOR_DATA);
   ArraySetAsSeries(buffer,true);

   period=MathMax(1,iPeriod);

   ArrayResize(max,period);
   ArrayInitialize(max,DBL_MAX);
   ArrayResize(min,period);
   ArrayInitialize(max,0);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[])
  {
//---
   if(rates_total>prev_calculated)
     {
      ArraySetAsSeries(high,true);
      ArraySetAsSeries(low,true);

      int bars=prev_calculated>0?rates_total-prev_calculated:rates_total-3;

      for(int i=bars; i>0; i--)
        {
         int i1=i+1,i2=i+2;

         if(high[i]<=high[i1] && high[i1]>=high[i2])
            ShiftExt(max,high[i1]);

         if(low[i]>=low[i1] && low[i1]<=low[i2])
            ShiftExt(min,low[i1]);

         double minmax=max[0],maxmin=min[0];
         for(int j=1; j<period; j++)
           {
            minmax=MathMin(minmax,max[j]);
            maxmin=MathMax(maxmin,min[j]);
           }

         buffer[i]=(minmax+maxmin)/2;
         buffer[0]=buffer[i];
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShiftExt(double &array[],double price)
  {
//---
   for(int i=period-1; i>0; i--)
      array[i]=array[i-1];
   array[0]=price;
//---
  }
//+------------------------------------------------------------------+
