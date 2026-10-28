//+------------------------------------------------------------------+
//|                                                 AIS Extremum.mq5 |
//|                                                        AIS Forex |
//|                        https://www.mql5.com/ru/users/aleksej1966 |
//+------------------------------------------------------------------+
#property copyright "AIS Forex"
#property link      "https://www.mql5.com/ru/users/aleksej1966"
#property version   "3.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_type1  DRAW_ARROW
#property indicator_label1 "Max"
#property indicator_color1 clrBlue
#property indicator_width1 3
#property indicator_style1 STYLE_SOLID

#property indicator_type2  DRAW_ARROW
#property indicator_label2 "Min"
#property indicator_color2 clrRed
#property indicator_width2 3
#property indicator_style2 STYLE_SOLID

input ushort iPeriod=24,
             History=10000;
input uchar PercentMax=66,
            PercentMin=66;

int period,percentmax,sizemax=1,cntmax=0,percentmin,sizemin=1,cntmin=0;
int priceh[],arrmax[][2],pricel[],arrmin[][2];
double max[],min[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,max,INDICATOR_DATA);
   ArraySetAsSeries(max,true);

   SetIndexBuffer(1,min,INDICATOR_DATA);
   ArraySetAsSeries(min,true);

   period=MathMax(2,iPeriod);
   percentmax=MathMin(99,MathMax(50,PercentMax));
   percentmin=MathMin(99,MathMax(50,PercentMin));

   ArrayResize(arrmax,sizemax);
   ArrayInitialize(arrmax,0);

   ArrayResize(arrmin,sizemin);
   ArrayInitialize(arrmin,0);

   ArrayResize(priceh,period);
   ArrayResize(pricel,period);
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

      int bars=rates_total-prev_calculated;

      if(prev_calculated==0)
        {
         bars=rates_total-period-1;
         if(History>0)
            bars=MathMin(bars,History);

         for(int i=rates_total-1;i>bars;i--)
            ShiftPrice(high[i],low[i]);
        }

      for(int i=bars; i>0; i--)
        {
         ShiftPrice(high[i],low[i]);

         int sumh=period*priceh[0],suml=period*pricel[0];
         for(int j=0;j<period;j++)
           {
            sumh=sumh-priceh[j];
            suml=suml-pricel[j];
           }

         if(sumh>0)
           {
            cntmax++;
            if(CalcStat(arrmax,sizemax,sumh,cntmax)>=percentmax)
               max[i]=high[i]+20*_Point;
           }

         if(suml<0)
           {
            cntmin++;
            if(CalcStat(arrmin,sizemin,-suml,cntmin)>=percentmin)
               min[i]=low[i]-20*_Point;
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcStat(int &array[][2],int &size,int var,int counter)
  {
//---
   int indx=ArrayBsearch(array,var),sum=0;
   if(array[indx][0]==var)
      array[indx][1]++;
   else
     {
      ArrayResize(array,size+1);
      array[size][0]=var;
      array[size][1]=1;
      size++;
      ArraySort(array);
      indx=ArrayBsearch(array,var);
     }

   for(int i=0; i<=indx; i++)
      sum=sum+array[i][1];

   return(100.*sum/counter);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShiftPrice(double h,double l)
  {
//---
   for(int i=period-1;i>0;i--)
     {
      int j=i-1;
      priceh[i]=priceh[j];
      pricel[i]=pricel[j];
     }
   priceh[0]=(int)MathRound(h/_Point);
   pricel[0]=(int)MathRound(l/_Point);
//---
  }
//+------------------------------------------------------------------+
