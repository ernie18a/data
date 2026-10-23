//+------------------------------------------------------------------+
//|                                             MTF_RSI_Smoothed.mq5 |
//|                                                        avoitenko |
//|                          https://www.mql5.com/en/users/avoitenko |
//+------------------------------------------------------------------+
#property copyright "avoitenko"
#property link      "https://www.mql5.com/en/users/avoitenko"
#property version   "1.00"
//---
#property indicator_separate_window
//---
#property indicator_buffers 3
#property indicator_plots   1
//--- limits
#property indicator_minimum 0.0
#property indicator_maximum 100.0
//--- levels
#property indicator_level1       30.0
#property indicator_level2       70.0
#property indicator_levelcolor   clrSilver
#property indicator_levelstyle   STYLE_DOT
#property indicator_levelwidth   1
//--- line
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrDodgerBlue
#property indicator_width1 1
//---
#include <MovingAverages.mqh>
//--- input parameters
input ENUM_TIMEFRAMES InpTimeframe  =  PERIOD_H1;  // Timeframe
input ushort          InpPeriod     =  14;         // Period
input ushort          InpSmoothing  =  5;          // Smoothing
//--- buffers
double rsiBuffer[];
double maBuffer[];
double tfBuffer[];
datetime tfTime[];
//--- global variables
bool calculateValue;
string IndicatorFileName;
int rsi_handle;
int calc_handle;
ENUM_TIMEFRAMES iTimeframe;
ushort iPeriod;
ushort iSmoothing;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- normalize input parameters
   iTimeframe=InpTimeframe;
   if(iTimeframe>=0 && PeriodSeconds(iTimeframe)<PeriodSeconds(_Period)) iTimeframe=_Period;
//---
   iPeriod=InpPeriod;
   if(iPeriod<2)iPeriod=2;
//---
   iSmoothing=InpSmoothing;
//--- buffers
   SetIndexBuffer(0,maBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,rsiBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,tfBuffer,INDICATOR_CALCULATIONS);
//---
   ArraySetAsSeries(maBuffer,true);
   ArraySetAsSeries(rsiBuffer,true);
   ArraySetAsSeries(tfBuffer,true);
//--- recursive mode
   calculateValue=(iTimeframe==-2);
   if(calculateValue)
     {
      rsi_handle=iRSI(NULL,_Period,iPeriod,PRICE_CLOSE);
      if(rsi_handle==INVALID_HANDLE){Print("Error handle #0");return(INIT_FAILED);}
      return(INIT_SUCCEEDED);
     }
//--- normal mode
   IndicatorFileName=MQLInfoString(MQL_PROGRAM_NAME);

   calc_handle=iCustom(NULL,iTimeframe,IndicatorFileName,-2,iPeriod,iSmoothing);
   if(calc_handle==INVALID_HANDLE){Print("Error handle #2");return(INIT_FAILED);}

   rsi_handle=iRSI(NULL,iTimeframe,iPeriod,PRICE_CLOSE);
   if(rsi_handle==INVALID_HANDLE){Print("Error handle #3");return(INIT_FAILED);}

   string short_name=StringFormat("RSI(%d,%d) %s",iPeriod,iSmoothing,TimeframeToString(iTimeframe));
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   IndicatorSetInteger(INDICATOR_DIGITS,2);
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
   ArraySetAsSeries(time,true);

   int limit;
   if(prev_calculated>rates_total || prev_calculated<=0)
     {
      ArrayInitialize(maBuffer,EMPTY_VALUE);
      ArrayInitialize(rsiBuffer,0);
      limit=rates_total-InpPeriod;
     }
   else limit=rates_total-prev_calculated;
//--- for current tf
   if(calculateValue || iTimeframe==PERIOD_CURRENT || iTimeframe==_Period)
     {
      if(iSmoothing<2)
        {
         if(CopyBuffer(rsi_handle,0,0,limit+1,maBuffer)!=limit+1) return(0);
        }
      else
        {
         if(CopyBuffer(rsi_handle,0,0,limit+1,rsiBuffer)!=limit+1) return(0);
         SimpleMAOnBuffer(rates_total,prev_calculated,iPeriod,iSmoothing,rsiBuffer,maBuffer);
        }
      return(rates_total);
     }
//--- for mtf
   int _bars=Bars(_Symbol,iTimeframe);
   if(_bars<1) return(0);

   datetime TimeBegining[];
   if(CopyTime(_Symbol,iTimeframe,_bars-1,1,TimeBegining)!=1)
     {
      Print("Error #5 ",GetLastError());
      return(0);
     }
//---
   int calc=BarsCalculated(calc_handle);
   if(calc<0) return(0);
   if(CopyBuffer(calc_handle,0,0,_bars,tfBuffer)!=_bars)
     {
      Print("Error #6 ",GetLastError());
      return(0);
     }
//--- first calc
   int limits=MathMin(limit,calc);
//--- regular
   if(limits==0) limits=PeriodSeconds(iTimeframe)/PeriodSeconds(_Period);
//---
   for(int i=limits; i>=0; i--)
     {
      maBuffer[i]=EMPTY_VALUE;
      if(time[i]>=TimeBegining[0])
        {
         int y=iBarShift(NULL,iTimeframe,time[i]);
         if(y>=0) maBuffer[i] = tfBuffer[y];
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|   iBarShift                                                      |
//+------------------------------------------------------------------+
int iBarShift(string symbol,ENUM_TIMEFRAMES tf,datetime time)
  {
   datetime lastBar;
   SeriesInfoInteger(symbol,tf,SERIES_LASTBAR_DATE,lastBar);
   int res = Bars(symbol,tf,time,lastBar);
   int mod = (int)fmod(time,PeriodSeconds(tf));
   if(time>lastBar) res=0;
   return((mod==0)?res-1:res);
  }
//+------------------------------------------------------------------+
//|   TimeframeToString                                              |
//+------------------------------------------------------------------+
string TimeframeToString(ENUM_TIMEFRAMES _period=PERIOD_CURRENT)
  {
   if(_period==PERIOD_CURRENT)_period=_Period;
   string str=EnumToString(_period);
   if(StringLen(str)>7) return(StringSubstr(str,7));
   return("Unknown");
  }
//+------------------------------------------------------------------+
