//+------------------------------------------------------------------+
//|                                     MTF_by_recursion_example.mq4 |
//|                   Copyright © 2023, matti.k.kinnunen@outlook.com |
//|                                             www.mattikinnunen.fi |
//+------------------------------------------------------------------+

#property copyright "Copyright 2023 ©, matti.k.kinnunen@outlook.com"
#property link      "mailto:matti.k.kinnunen@outlook.com"
#property version   "1.01"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_maximum 100;
#property indicator_minimum 0;
#property indicator_level1 70;
#property indicator_level2 30;
#property indicator_level3 50;
#property indicator_color1 Gray;
input int Timeframe = 0;
ENUM_TIMEFRAMES finalTimeframe;
extern int IndicatorPeriod = 14;
double bufferToDraw[];
int firstBarToDraw;
int bars1, bars2;
int prevCalculated; // prev_calculated of OnCalculate() is a constant so we can not modify it - that is why we use this global variable.
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(IndicatorPeriod<2)
     {
      IndicatorPeriod=2;
      Alert("IndicatorPeriod minimum is 2! IndicatorPeriod was set to 2.");
     }
   finalTimeframe = GetValidatedTimeFrame();
   if(finalTimeframe == (-1))
     {
      return (INIT_FAILED);
     }
   firstBarToDraw   = IndicatorPeriod * finalTimeframe /_Period;
//--- indicator buffers mapping
   SetIndexBuffer(0, bufferToDraw);
   SetIndexStyle(0, DRAW_LINE,EMPTY,1,clrDodgerBlue);

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
   int counted_bars = IndicatorCounted();
   if(counted_bars<0)
      return(-1);

   if(finalTimeframe != _Period)
     {
      if(!download_history(finalTimeframe))
        {
         return prev_calculated;
        }
      bars1 = iBars(NULL,finalTimeframe);
      if(bars2 !=0 && bars2 != bars1) // This block makes sure indicator has more than couple of bars available after first multi time frame launch
        {
         prevCalculated = firstBarToDraw;
        }
      else
        {
         prevCalculated = prev_calculated;
        }
      bars2 = bars1;
     }
   else
     {
      prevCalculated = prev_calculated;
     }

   if(finalTimeframe != _Period)
     {
      for(int i = Bars-1-MathMax(firstBarToDraw, prevCalculated); i >= 0; --i)
        {
         int y = iBarShift(NULL,finalTimeframe,Time[i],true);
         bufferToDraw[i] = iCustom(NULL,finalTimeframe,"MTF_by_recursion_example",finalTimeframe,IndicatorPeriod,0,y); // The recursive call itself
        }
     }
   else // This block will be executed in the recursive call and when not using upper timeframes
     {
      for(int i = Bars-1-MathMax(firstBarToDraw, prevCalculated); i >= 0; --i)
        {
         bufferToDraw[i] = GetIndicatorValue(i);
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES GetValidatedTimeFrame() // Thanks to William Roeder for the idea of validating input timeframe - I just wrapped it in a function
  {
   if(Timeframe <= _Period)
     {
      return (ENUM_TIMEFRAMES)_Period;
     }
   else
     {
      ENUM_TIMEFRAMES TF[]  = { PERIOD_M1,  PERIOD_M5,  PERIOD_M15, PERIOD_M30,
                                PERIOD_H1,  PERIOD_H4,  PERIOD_D1,  PERIOD_W1,
                                PERIOD_MN1, 0
                              };
      int i;
      for(i = 0; TF[i] < Timeframe; i++);
      if(Timeframe != TF[i+1])
        {
         return TF[i];
        }
     }
   return (ENUM_TIMEFRAMES)-1; // Something probably wrong with the input in this case
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetIndicatorValue(int &i) // The purpose of this function is just to demonstrate custom made indicators in recursive calls - replace it by your own custom indicator calculation if needed
  {
   return (iMFI(NULL,finalTimeframe,IndicatorPeriod,i+1) + iWPR(NULL,finalTimeframe,IndicatorPeriod,i+1) + 100 + iRSI(NULL,finalTimeframe,IndicatorPeriod,0,i+1) + iStochastic(NULL,finalTimeframe,IndicatorPeriod,3,3,0,0,MODE_MAIN,i+1))/4;
  }
//+-----------------------------------------------------------------------------------------------------------------------+
//|                                                                                                                       |
//+-----------------------------------------------------------------------------------------------------------------------+
// Thanks to William Roeder for download related code below - I just modified it for my own purposes
//+-----------------------------------------------------------------------------------------------------------------------+
//|                                                                                                                       |
//+-----------------------------------------------------------------------------------------------------------------------+

#define SYMBOL string
#define THIS_SYMBOL ""
bool  download_history(ENUM_TIMEFRAMES period=PERIOD_CURRENT)
  {
   return download_history(_Symbol, period);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  download_history(
   SYMBOL            symbol=THIS_SYMBOL,     ///< The symbol required.
   ENUM_TIMEFRAMES   period=PERIOD_CURRENT   /**< The standard timeframe.*/)
  {
   if(symbol == THIS_SYMBOL)
      symbol = _Symbol;
   if(period == PERIOD_CURRENT)
      period = (ENUM_TIMEFRAMES)_Period;
   datetime today = iTime(NULL,finalTimeframe,0);
   ResetLastError();
   datetime other = iTime(symbol, period, 0);
   if(_LastError == 0
      && (today - other)<finalTimeframe*60)
      return true;
   if(_LastError != ERR_HISTORY_WILL_UPDATED
      && _LastError != ERR_NO_HISTORY_DATA)
      Print(StringFormat("iTime(%s,%i) Failed: %i", symbol, period,_LastError));
   return false;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
