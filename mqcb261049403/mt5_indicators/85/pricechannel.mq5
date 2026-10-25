//+------------------------------------------------------------------+
//|                                                  PriceCannel.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "2010, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
//---- plot Up
#property indicator_label1  "Up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//---- plot Medium
#property indicator_label2  "Medium"
#property indicator_type2   DRAW_LINE
#property indicator_color2  DeepSkyBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//---- plot Down
#property indicator_label3  "Down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  Blue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input int      PeriodPR=26;
//--- indicator buffers
double         UpBuffer[];
double         MediumBuffer[];
double         DownBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,MediumBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,DownBuffer,INDICATOR_DATA);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| get highest value for range                                      |
//+------------------------------------------------------------------+
double Highest(const double&array[],int range,int fromIndex)
  {
   double res=0;
//---
   res=array[fromIndex];
   for(int i=fromIndex;i>fromIndex-range && i>=0;i--)
     {
      if(res<array[i]) res=array[i];
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| get lowest value for range                                       |
//+------------------------------------------------------------------+
double Lowest(const double&array[],int range,int fromIndex)
  {
   double res=0;
//---
   res=array[fromIndex];
   for(int i=fromIndex;i>fromIndex-range && i>=0;i--)
     {
      if(res>array[i]) res=array[i];
     }
//---
   return(res);
  }
  int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& Open[],
                const double& High[],
                const double& Low[],
                const double& Close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
     int limit;
   if(prev_calculated==0) limit=0;
   else                   limit=prev_calculated-1;
   for(int i=limit;i<rates_total;i++)
   {
      double high=Highest(High,PeriodPR,i);
      double low=Lowest(Low,PeriodPR,i);
      UpBuffer[i]=Highest(High,PeriodPR,i);
      DownBuffer[i]=Lowest(Low,PeriodPR,i);
      MediumBuffer[i]=(high+low)/2.0;
   }
//---
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
