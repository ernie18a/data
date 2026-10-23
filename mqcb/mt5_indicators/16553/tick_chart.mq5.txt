//+------------------------------------------------------------------+
//|                                                   Tick Chart.mq5 |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.004"
//---- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_width1  1
#property indicator_label1  "Ask"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_width2  1
#property indicator_label2  "Bid"
//--- indicator buffer
double ExtAsk[];
double ExtBid[];
//---
bool first_start;
MqlTick ExTicks[];
int copied;                               // the size of the array of ticks
//---
input int      ticks=400;                 // amount requested by ticks
input datetime start=D'2016.10.07 02:06:03'; // with a date query tics
input int      millisecond=200;           // timer
input int      view=300;                  // see how many bars
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(view>=ticks)
     {
      Print("Parameter \"see how many bars\" must be less than the parameter \"amount requested by ticks\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
//--- indicator buffer mapping
   SetIndexBuffer(0,ExtAsk,INDICATOR_DATA);
   SetIndexBuffer(1,ExtBid,INDICATOR_DATA);
   ArraySetAsSeries(ExtAsk,true);
   ArraySetAsSeries(ExtBid,true);
   ArrayInitialize(ExtAsk,0.0);
   ArrayInitialize(ExtBid,0.0);
//--- sets drawing line to empty value 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

   IndicatorSetInteger(INDICATOR_DIGITS,Digits());

   ArrayFree(ExTicks);
   first_start=true;

   EventSetMillisecondTimer(millisecond);
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
   static string server="";
   Comment("Trader Server Name: ",server);
   if(server!=AccountInfoString(ACCOUNT_SERVER))
     {
      first_start=true;

     }
   server=AccountInfoString(ACCOUNT_SERVER);
   if(!first_start)
      return(rates_total);

//--- ask for ticks
   ResetLastError();
   copied=CopyTicks(Symbol(),ExTicks,COPY_TICKS_INFO,(ulong)start*1000,ticks);
   int err=GetLastError();
   Comment("Booked: ",ticks,", downloads: ",copied,", error code: ",err);
   if(err==0)
     {
      first_start=false;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   if(first_start)
      return;
   static int prev_count=0;

   if(prev_count+view<copied)
     {
      int j=0;
      for(int i=prev_count;i<prev_count+view;i++)
        {
         ExtAsk[view-j]=ExTicks[i].ask;
         ExtBid[view-j]=ExTicks[i].bid;
         j++;
        }
      prev_count++;
      ChartRedraw();
     }
   else
     {
      prev_count=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }
//+------------------------------------------------------------------+
