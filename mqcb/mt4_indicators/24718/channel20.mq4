//+------------------------------------------------------------------+
//|                                                    channel20.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2

enum MODE_A{mode_high=1,mode_low};

#import "Fuction.ex4"
double Channel20(const int  PeriodeChannel,int debut,MODE_A highlow);
#import

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

input int PeriodChannel = 20;
double channelBas[];
double channelHaut[];


//+------------------------------------------------------------------+
//|       on init                                                           |
//+------------------------------------------------------------------+

int OnInit()
  {
  
  SetIndexStyle(0,DRAW_LINE,3,3,Blue);
   SetIndexBuffer(0,channelHaut);
   SetIndexLabel(0,"channelHaut");

  
   SetIndexStyle(1,DRAW_LINE,3,3,Red);
   SetIndexBuffer(1,channelBas);
   SetIndexLabel(1,"channelBas");
   
//--- indicator buffers mapping
   
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
  
  int i;
  double ph,pb;
  
  for(i=Bars -PeriodChannel-1; i>=1; i--)
      {
      ph = Channel20(PeriodChannel,i-1,mode_high);
      pb = Channel20(PeriodChannel,i-1,mode_low);
      channelHaut[i] = ph;
      channelBas [i] = pb;
      } 
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
