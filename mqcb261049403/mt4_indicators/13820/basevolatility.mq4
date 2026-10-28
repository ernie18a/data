//+------------------------------------------------------------------+
//|                                               BaseVolatility.mq4 |
//|                                           Copyright 2015, fxborg |
//|                                   http://fxborg-labo.hateblo.jp/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, fxborg"
#property link      "http://fxborg-labo.hateblo.jp/"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_type1 DRAW_LINE
#property indicator_color1 DarkTurquoise
#property indicator_width1 2
//--- input parameters
input int      InpFastPeriod=10; //  Fast Period
input int      InpSlowPeriod=70; //  Slow Period
input ENUM_MA_METHOD InpMaMethod=MODE_SMMA; // Ma Method 
//---
int   CalcPeriod=2*(InpSlowPeriod+InpFastPeriod);
//---
int min_rates_total;
//--- indicator buffers
double StdDevBuffer[];
double MainBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//---- Initialization of variables of data calculation starting point
   min_rates_total=1+InpFastPeriod+1+InpSlowPeriod+1;
//--- indicator buffers mapping
   IndicatorBuffers(4);
//--- indicator buffers
   SetIndexBuffer(0,MainBuffer);
   SetIndexBuffer(1,StdDevBuffer);
//---
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexDrawBegin(0,min_rates_total);
   SetIndexDrawBegin(1,min_rates_total);
//---
   string short_name="BaseVolatility ("+IntegerToString(InpSlowPeriod)+","+IntegerToString(InpFastPeriod)+")";
   IndicatorShortName(short_name);
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
   int i,j,first;
//--- check for bars count
   if(rates_total<=min_rates_total)
      return(0);
//---
   MathSrand(int(TimeLocal()));
//--- indicator buffers
   ArraySetAsSeries(StdDevBuffer,false);
   ArraySetAsSeries(MainBuffer,false);
//--- rate data
//+----------------------------------------------------+
//|Set High Low Buffeer                                |
//+----------------------------------------------------+
   first=InpFastPeriod+1-1;
   if(first+1<prev_calculated)
      first=prev_calculated-2;
   else
   for(i=0; i<first; i++)
         StdDevBuffer[i]=EMPTY_VALUE;
//---
   for(i=first; i<rates_total-1 && !IsStopped(); i++)
     {
      if(!random(20) && rates_total-i>CalcPeriod && StdDevBuffer[i]!=EMPTY_VALUE) continue;
      StdDevBuffer[i]=iStdDev(Symbol(),PERIOD_CURRENT,InpFastPeriod,0,InpMaMethod,PRICE_CLOSE,rates_total-i);
     }
//+----------------------------------------------------+
//| Set MA Buffeer                                     |
//+----------------------------------------------------+
   first=InpFastPeriod+1+InpSlowPeriod-1+1;
   if(first+1<prev_calculated)
      first=prev_calculated-2;
   else
   for(i=0; i<first; i++)
         MainBuffer[i]=EMPTY_VALUE;
//--- ma cycle
   for(i=first; i<rates_total-1 && !IsStopped(); i++)
     {
      double sd=0.0;
      for(j=(i-InpSlowPeriod+1);j<=i;j++)
         sd+=StdDevBuffer[j];
      //--- Ma Buffer
      MainBuffer[i]=sd/InpSlowPeriod;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+----------------------------------------------------+
//| random func                                        |
//+----------------------------------------------------+
bool random(int x)
  {
   int ran=MathRand();
   bool res=(MathMod(ran,x)==0);
   return(res);
  }
//+------------------------------------------------------------------+
