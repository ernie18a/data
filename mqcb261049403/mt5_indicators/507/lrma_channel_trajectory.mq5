//+------------------------------------------------------------------+
//|                                      LRMA_Channel_trajectory.mq5 |
//|                                            Copyright 2010, Urain |
//|                              https://www.mql5.com/ru/users/urain |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, Urain"
#property link      "https://www.mql5.com/ru/users/urain"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   5
//--- plot Label1
#property indicator_label1  "Transform"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Label3
#property indicator_label2  "LineUp"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDeepSkyBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Label4
#property indicator_label3  "LineDown"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDeepSkyBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Label1
#property indicator_label4  "LR_down"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Label1
#property indicator_label5  "LR_up"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrBlue
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- input parameters
input int      lr_per     = 16;   // Linear regression period
input double   stdev_koef = 2.0;  // Standard deviation ratio
//--- indicator buffers
double         TransBuffer[];
double         Label1Buffer[];
double         Color1Buffer[];
double         Label2Buffer[];
double         Label3Buffer[];
double         Label4Buffer[];
double sma2,lwma3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping 
   SetIndexBuffer(0,TransBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,Label3Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,Label4Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,Label1Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,Color1Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,Label2Buffer,INDICATOR_CALCULATIONS);

   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);
//---
   return(0);
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
   int prev=prev_calculated;

   for(int i=prev;i<rates_total;i++)
      TransBuffer[i]=close[i];

   for(int i=prev;i<rates_total;i++)
     {
      if(i>lr_per)
        {
         sma2=2.*SMA(TransBuffer,lr_per+1,i);
         lwma3=3.*LWMA(TransBuffer,lr_per+1,i);
         Label1Buffer[i]=lwma3-sma2;
         Label2Buffer[i]=2.*sma2-lwma3;
        }
     }

   for(int i=prev;i<rates_total;i++)
     {
      if(i>lr_per)
        {
         double temp=(Label1Buffer[i]-Label2Buffer[i])/(lr_per);
         double Kstdev=stdev_koef*StDev(TransBuffer,Label1Buffer[i],temp,lr_per,i);
         if(temp>0)Color1Buffer[i]=Label1Buffer[i];
         Label3Buffer[i]=Label1Buffer[i]+Kstdev;
         Label4Buffer[i]=Label1Buffer[i]-Kstdev;
        }
     }
   for(int i=prev;i<rates_total;i++)
      if(Color1Buffer[i]!=0)
        {
         Label1Buffer[i]=0; // Label3Buffer[i]=0;
        }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double SMA(const double &cot[],int per,int shift)
  {
   double res=0;
   for(int i=0;i<per;i++)
      res+=cot[shift-i];
   return(res/(double)per);
  }
//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
double LWMA(const double &cot[],int per,int shift)
  {
   double res=0; int sumk=0;
   for(int i=0;i<per;i++)
     {
      res+=cot[shift-i]*(double)(per-i);
      sumk+=per-i;
     }
   return(res/(double)sumk);
  }
//+------------------------------------------------------------------+
//| Standard deviation                                               |
//+------------------------------------------------------------------+
double StDev(const double &cot[],double nl,double lr,int per,int shift)
  {
   double res=0;
   for(int i=0;i<per;i++)
     {
      double temp=cot[shift-i]-(nl-lr*i);
      res+=temp*temp;
     }
   return(sqrt(res/(double)per));
  }