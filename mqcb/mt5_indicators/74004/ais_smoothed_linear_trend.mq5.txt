//+------------------------------------------------------------------+
//|                                    AIS Smoothed Linear Trend.mq5 |
//|                                                        AIS Forex |
//|                        https://www.mql5.com/ru/users/aleksej1966 |
//+------------------------------------------------------------------+
#property copyright "AIS Forex"
#property link      "https://www.mql5.com/ru/users/aleksej1966"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_applied_price PRICE_CLOSE

#property indicator_type1  DRAW_LINE
#property indicator_label1 "AIS SLT"
#property indicator_color1 clrBlue
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID

enum _type {Center,Forward,Back};

input _type Type=Center;
input ushort iPeriod=15;

ushort period=3;
double buffer[],coeff[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,buffer,INDICATOR_DATA);
   ArraySetAsSeries(buffer,true);

   period=MathMax(period,iPeriod);

   ArrayResize(coeff,period);
   ArrayInitialize(coeff,0);

   if(Type==Center)
     {
      if(MathMod(period,2)==0)
         for(int i=period/2-1,j=i+1;i>=0;i--,j++)
           {
            coeff[i]=1./(j-i);
            coeff[j]=1./(i-j);
           }
      else
         for(int i=period/2-1,j=i+2;i>=0;i--,j++)
           {
            coeff[i]=1./(j-i);
            coeff[j]=1./(i-j);
           }
     }

   if(Type==Forward)
      for(int i=1;i<period;i++)
        {
         coeff[0]=coeff[0]+1./i;
         coeff[i]=-1./i;
        }

   if(Type==Back)
      for(int i=0;i<period-1;i++)
        {
         coeff[i]=1./(period-i-1);
         coeff[period-1]=coeff[period-1]-1./(period-i-1);
        }

   if(Type==Center)
      for(int i=0;i<period;i++)
         coeff[i]=2*coeff[i]/period;
   else
      for(int i=0;i<period;i++)
         coeff[i]=coeff[i]/(period-1);

   for(int i=0;i<period;i++)
      coeff[i]=(period*coeff[i]+1)/period;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const int32_t begin,
                const double &price[])
  {
//---
   ArraySetAsSeries(price,true);

   int bars=prev_calculated>0? rates_total-prev_calculated:rates_total-period-1;

   for(int i=bars;i>-1;i--)
     {
      buffer[i]=coeff[0]*price[i];

      for(int j=1;j<period;j++)
         buffer[i]=buffer[i]+coeff[j]*price[i+j];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
