//+------------------------------------------------------------------+
//|                                                         DLXT.mq5 |
//|                     Copyright 2018, MetaQuotes Software Corp.Xio |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp.Xio"
#property description  "The index according to the EMA index and the trend of MACD indicators calculated signals," 
#property description  "and adding color on candle charts, the default setting is: "
#property description  "red column represents the rising trend, green column represents the downward trend,"
#property description  "blue column represents no obvious signals."
#property copyright "Copyright 2018, MetaQuotes Software Corp.Jianye Xiong"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 8
//--- plot Label1
#property indicator_label1  "P_Open;P_High;P_Low;P_Close"
#property indicator_plots   1
#property indicator_type1 DRAW_COLOR_CANDLES
#property indicator_width1  3


#include <MovingAverages.mqh>
//--- input parameters
input int   macdfast=12;
input int   macdslow=26;
input int   macdsignal=9;
input int   emaperiod=12;
input color Rise=clrDeepPink;
input color Drop=clrSpringGreen;
input color Noise=clrMediumSlateBlue;

int   Handle_macd;
int   Handle_ema;

//--- indicator buffers
double   Power_buffer[];
double   macd_main_buffer[];
double   ema_buffer[];
double   color_buffer[];
double buffer_open[],buffer_high[],buffer_low[],buffer_close[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- indicator buffers mapping 
   SetIndexBuffer(0,buffer_open,INDICATOR_DATA);
   SetIndexBuffer(1,buffer_high,INDICATOR_DATA);
   SetIndexBuffer(2,buffer_low,INDICATOR_DATA);
   SetIndexBuffer(3,buffer_close,INDICATOR_DATA);
   SetIndexBuffer(4,color_buffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,Power_buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,ema_buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,macd_main_buffer,INDICATOR_CALCULATIONS);
//---
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,3);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,Drop);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,Rise);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,Noise);
//---   
   Handle_macd=iMACD(_Symbol,0,macdfast,macdslow,macdsignal,PRICE_CLOSE);
   Handle_ema=iMA(_Symbol,0,emaperiod,0,MODE_EMA,PRICE_CLOSE);

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
   int digits=Digits();
   CopyBuffer(Handle_ema,0,0,rates_total,ema_buffer);
   CopyBuffer(Handle_macd,0,0,rates_total,macd_main_buffer);
   int   start;
   start=prev_calculated;
   if(prev_calculated==0)
     {
      start=MathMax(emaperiod,macdslow)-1;
     }
   for(int i=start;i<=rates_total-1;i++)
     {
      buffer_open[i]=open[i];  //get open price
      buffer_high[i]=high[i];  //get high price
      buffer_low[i]=low[i];    //get low price
      buffer_close[i]=close[i];//get close price
      color_buffer[i]=2;
      Power_buffer[i]=0;

      if((macd_main_buffer[i]-macd_main_buffer[i-1])>0 && (ema_buffer[i]-ema_buffer[i-1])>0)
        {
         Power_buffer[i]=1;//rise signal
         color_buffer[i]=1;
        }
      if((macd_main_buffer[i]-macd_main_buffer[i-1])<0 && (ema_buffer[i]-ema_buffer[i-1])<0)
        {
         Power_buffer[i]=-1;//drop signal 
         color_buffer[i]=0;
        }
     }

   return(rates_total-1);
  }
//+------------------------------------------------------------------+
