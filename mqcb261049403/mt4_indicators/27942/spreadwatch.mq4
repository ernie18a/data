//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019 by Jt, FXFledgling Forex Study Group"
#property link      "https://www.facebook.com/groups/FXFledgling/"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------
extern int    TradeStart = 0    ;
extern int    TradeEnd   = 23   ;

double bid1    = 0;
double ask1    = 0;
double spread1 = 0;
double bid2    = 0;
double ask2    = 0;
double spread2 = 0;
int    digit   = 5;
double mul     = 1;

datetime catchdate;
datetime catchdate2;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   digit = (int) MarketInfo(Symbol(),MODE_DIGITS);
   if(digit==3 || digit==5)
      mul=10;
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
   int hr=Hour();
   if(hr<TradeStart || hr>TradeEnd)
     {
      return(0);
     }

   RefreshRates();
   catchdate2 = TimeCurrent();
   bid2 = Bid;
   ask2 = Ask;
   spread2 = (ask2-bid2)/Point;

   if(spread2>spread1)
     {
      spread1 = spread2;
      bid1 = bid2;
      ask1 = ask2;
      catchdate = catchdate2;
     }

   Comment("\n\n"+
           "Bid: "+DoubleToStr(bid1,Digits)+
           "\nAsk: "+DoubleToStr(ask1,Digits)+
           "\nBiggest Spread: "+DoubleToStr(spread1,2)+" points or "+DoubleToStr(spread1/mul,2)+" pips"+
           "\nCatch Date/Time: "+catchdate
          );

//--- return value of prev_calculated for next call
   return(0);
  }
//+------------------------------------------------------------------+
