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
extern int    TradeStart = 0;
extern int    TradeEnd   = 23;

double bidBiggest    = 0;
double askBiggest    = 0;
double spreadBiggest = 0;

double bidLowest     = 0;
double askLowest     = 0;
double spreadLowest  = 0;

double bid           = 0;
double ask           = 0;
double spreadnow     = 0;

int    digit         = 5;
double mul           = 1;

datetime catchdateBiggest;
datetime catchdateLowest;
datetime catchdate;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   digit=(int) MarketInfo(Symbol(),MODE_DIGITS);
   if(digit==3 || digit==5)
      mul=10;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int      rates_total,
                const int      prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
  {
//---
   int hr=Hour();
   if(hr<TradeStart || hr>TradeEnd)
     {
      return(0);
     }

   RefreshRates();
   catchdate=TimeCurrent();
   bid = Bid;
   ask = Ask;
   spreadnow=(ask-bid)/Point;

   if(spreadnow>spreadBiggest)
     {
      spreadBiggest    = spreadnow;
      bidBiggest       = bid;
      askBiggest       = ask;
      catchdateBiggest = catchdate;
     }

   if(spreadnow<spreadLowest || spreadLowest==0)
     {
      spreadLowest     = spreadnow;
      bidLowest        = bid;
      askLowest        = ask;
      catchdateLowest  = catchdate;
     }

   Comment("\n\nBiggest Spread"+
           "\nBid: "+DoubleToStr(bidBiggest,Digits)+
           "\nAsk: "+DoubleToStr(askBiggest,Digits)+
           "\nBiggest Spread: "+DoubleToStr(spreadBiggest,2)+" points or "+DoubleToStr(spreadBiggest/mul,2)+" pips"+
           "\nCatch Date/Time: "+TimeToStr(catchdateBiggest,TIME_DATE)+" "+TimeToStr(catchdateBiggest,TIME_SECONDS)+
           "\n\nLowest Spread"+
           "\nBid: "+DoubleToStr(bidLowest,Digits)+
           "\nAsk: "+DoubleToStr(askLowest,Digits)+
           "\nLowest Spread: "+DoubleToStr(spreadLowest,2)+" points or "+DoubleToStr(spreadLowest/mul,2)+" pips"+
           "\nCatch Date/Time: "+TimeToStr(catchdateLowest,TIME_DATE)+" "+TimeToStr(catchdateLowest,TIME_SECONDS)
           );

//--- return value of prev_calculated for next call
   return(0);
  }
//+------------------------------------------------------------------+
