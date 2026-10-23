//+------------------------------------------------------------------+
//|                                   Standard Deviation Channel.mq4 |
//|                                           Copyright 2015, Awran5 |
//|                                                 awran5@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Awran5"
#property link      "awran5@yahoo.com"
#property version   "1.00"
#property description "Simple indicator to show 2 levels of Standard Deviation Channel on your chart"
#property strict
#property indicator_chart_window

extern int    FirstBar              = 1;           // First Bar
extern int    LastBar               = 50;          // Last Bar
extern ENUM_TIMEFRAMES FixedPeriod  = 0;           // Time Frame to use
input string  lb_0                  = "";          // ----- CHANNEL --------------------------------------
extern double cDeviation            = 1.618;       // Channel Deviation
extern ENUM_LINE_STYLE cStyle       = 0;           // Channel Style
extern color  cColor                = clrRoyalBlue;// Channel Color
extern int    cWidth                = 1;           // Channel Width
input string  lb_1                  = "";          // ----- LEVELS ---------------------------------------
extern double lDeviation            = 0.618;       // Levels Deviation
extern ENUM_LINE_STYLE lStyle       = 0;           // Levels Style
extern color  lColor                = clrGold;     // Levels Color
extern int    lWidth                = 1;           // Levels Width
//---
string StdDevChannel="StdDev Channel",StdDevLevels="StdDev Levels";
datetime FirstBarTime,LastBarTime;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//---- indicator short name
   IndicatorShortName("iStdDev");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| deinitialization function                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(ObjectFind(StdDevChannel) >= 0)  ObjectDelete(StdDevChannel);
   if(ObjectFind(StdDevLevels)  >= 0)  ObjectDelete(StdDevLevels);
   Comment("");
//---
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
   int counted_bars=IndicatorCounted(),
   limit=Bars-counted_bars,
   i;
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;

   for(i=limit-1; i>=0; i--)
     {
      FirstBarTime = iTime(NULL, FixedPeriod, i+FirstBar);
      LastBarTime  = iTime(NULL, FixedPeriod, i+LastBar);
     }

   DrawSDChannel(StdDevChannel,cDeviation,LastBarTime,FirstBarTime,cColor,cStyle,cWidth);
   DrawSDChannel(StdDevLevels,lDeviation,LastBarTime,FirstBarTime,lColor,lStyle,lWidth);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSDChannel(string name,double deviation,datetime t1,datetime t2,color clr,int style,int width)
  {
//---
   ObjectDelete(name);
   ObjectCreate(name,OBJ_STDDEVCHANNEL,0,t1,0,t2,0);
   ObjectSet(name,OBJPROP_DEVIATION,deviation);
   ObjectSet(name,OBJPROP_COLOR,clr);
   ObjectSet(name,OBJPROP_STYLE,style);
   ObjectSet(name,OBJPROP_WIDTH,width);
   ObjectSet(name,OBJPROP_RAY,true);
//---
  }
//+------------------------------------------------------------------+
