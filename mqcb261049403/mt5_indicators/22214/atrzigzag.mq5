//+------------------------------------------------------------------+
//|                                                    ATRZigZag.mq5 |
//|                                  Copyright 2018, André S. Enger. |
//|                                          andre_enger@hotmail.com |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Andre S. Enger."
#property link      "andre_enger@hotmail.com"
#property version   "1.0"
#property description "ATR-based ZigZag implementation."

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 1

#property indicator_label1  "Zig Zag"
#property indicator_type1   DRAW_ZIGZAG
#property indicator_color1  clrYellowGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

input double AtrMultiplier=1.5; //ATR threshold for directional change
input int AtrPeriod=50; // Period for ATR calculation
input int MaxPeriod=10; // Max bar period before directional change
input int MinPeriod=3; // Min bar period before directional change
input bool RealTimeMode=true; // Draw tentative zigzag at newest bar
//--- Buffers
double ExtPeaksBuffer[];
double ExtTroughsBuffer[];

//--- Globals
bool _lastDirection;
bool _realtimeChange;
int _lastIndex;
int _lastIndex2;
int _contraIndex;
double _atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtPeaksBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtTroughsBuffer,INDICATOR_DATA);

   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
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
   int start;
   if(prev_calculated>rates_total || prev_calculated<=0)
     {
      start=1;
      _lastIndex=0;
      _lastIndex2=0;
      _contraIndex=0;
      _atr=0;
      _realtimeChange=false;
     }
   else
      start=MathMax(1,prev_calculated-1);
   double atr=_atr;
//--- main loop
   for(int bar=start; bar<rates_total-(RealTimeMode?0:1); bar++)
     {
      bool realtimeBar=bar==rates_total-1;
      //--- Update ATR and other tasks
      if(!realtimeBar)
        {
         double tr=MathMax(high[bar],close[bar-1])-MathMin(low[bar],close[bar-1]);
         atr+=(tr-atr)*(2.0/(1.0+AtrPeriod));
         _atr=atr;
         if(_realtimeChange && RealTimeMode)
           {
            if(_lastDirection)
               ExtPeaksBuffer[_lastIndex]=high[_lastIndex];
            else
               ExtTroughsBuffer[_lastIndex]=low[_lastIndex];
            ExtPeaksBuffer[rates_total-1]=0;
            ExtTroughsBuffer[rates_total-1]=0;
            _realtimeChange=false;
           }
         //---
         ExtTroughsBuffer[bar]=0;
         ExtPeaksBuffer[bar]=0;
        }
      //--- Conditions
      bool shouldntChange=bar-_lastIndex<MinPeriod;
      bool shallChange=bar-_lastIndex>MaxPeriod;
      bool mustChange,shouldChange,canChange;
      if(_lastDirection)
        {
         mustChange=low[bar]<low[_lastIndex2];
         shouldChange=ExtPeaksBuffer[_lastIndex]-low[bar]>atr*AtrMultiplier;
         canChange=low[bar]<low[_contraIndex];
        }
      else
        {
         mustChange=high[bar]>high[_lastIndex2];
         shouldChange=high[bar]-ExtTroughsBuffer[_lastIndex]>atr*AtrMultiplier;
         canChange=high[bar]>high[_contraIndex];
        }
      bool changeNow=mustChange || (canChange && shouldChange && !shouldntChange);
      //--- Algorithm realtime
      if(realtimeBar && RealTimeMode)
        {
         if(_lastDirection)
           {
            if(!_realtimeChange && high[bar]>ExtPeaksBuffer[_lastIndex])
              {
               ExtPeaksBuffer[_lastIndex]=0;
               ExtPeaksBuffer[bar]=high[bar];
               _realtimeChange=true;
              }
            else if(_realtimeChange && high[bar]>ExtPeaksBuffer[bar])
              {
               ExtPeaksBuffer[bar]=high[bar];
              }
           }
         else
           {
            if(!_realtimeChange && low[bar]<ExtTroughsBuffer[_lastIndex])
              {
               ExtTroughsBuffer[_lastIndex]=0;
               ExtTroughsBuffer[bar]=low[bar];
               _realtimeChange=true;
              }
            else if(_realtimeChange && low[bar]<ExtTroughsBuffer[bar])
              {
               ExtTroughsBuffer[bar]=low[bar];
              }
           }
        }
      else
        {
         if(canChange)
            _contraIndex=bar;
         if(_lastDirection)
           {
            if(high[bar]>ExtPeaksBuffer[_lastIndex])
              {
               ExtPeaksBuffer[_lastIndex]=0;
               ExtPeaksBuffer[bar]=high[bar];
               if(open[bar]>close[bar])
                 {
                  shouldntChange=0<MinPeriod;
                  shouldChange=ExtPeaksBuffer[bar]-low[bar]>atr*AtrMultiplier;
                  changeNow=mustChange || (canChange && shouldChange && !shouldntChange);
                  if(changeNow)
                    {
                     ExtTroughsBuffer[bar]=low[bar];
                     _lastDirection=false;
                     _lastIndex2=bar;
                    }
                 }
               else if(changeNow)
                 {
                  ExtPeaksBuffer[_lastIndex]=high[_lastIndex];
                  ExtTroughsBuffer[bar]=low[bar];
                  _lastIndex2=bar;
                 }
               _lastIndex=bar;
               _contraIndex=bar;
              }
            else if(changeNow)
              {
               ExtTroughsBuffer[bar]=low[bar];
               _lastDirection=false;
               _lastIndex2=_lastIndex;
               _lastIndex=bar;
               _contraIndex=bar;
              }
            else if(shallChange)
              {
               int startSkip=ExtTroughsBuffer[_lastIndex]==0?0:1;
               if(open[_lastIndex]<close[_lastIndex] && startSkip==0) startSkip++;
               bar=ArrayMinimum(low,_lastIndex+startSkip,bar-_lastIndex-startSkip+1);
               ExtTroughsBuffer[bar]=low[bar];
               _lastDirection=false;
               _lastIndex2=_lastIndex;
               _lastIndex=bar;
               _contraIndex=bar;
              }
           }
         else
           {
            //--- bear trend
            if(low[bar]<ExtTroughsBuffer[_lastIndex])
              {
               ExtTroughsBuffer[_lastIndex]=0;
               ExtTroughsBuffer[bar]=low[bar];
               if(open[bar]<close[bar])
                 {
                  shouldntChange=0<MinPeriod;
                  shouldChange=high[bar]-ExtTroughsBuffer[bar]>atr*AtrMultiplier;
                  changeNow=mustChange || (canChange && shouldChange && !shouldntChange);
                  if(changeNow)
                    {
                     ExtPeaksBuffer[bar]=high[bar];
                     _lastDirection=true;
                     _lastIndex2=bar;
                    }
                 }
               else if(changeNow)
                 {
                  ExtTroughsBuffer[_lastIndex]=low[_lastIndex];
                  ExtPeaksBuffer[bar]=high[bar];
                  _lastIndex2=bar;
                 }
               _lastIndex=bar;
               _contraIndex=bar;
              }
            else if(changeNow)
              {
               ExtPeaksBuffer[bar]=high[bar];
               _lastDirection=true;
               _lastIndex2=_lastIndex;
               _lastIndex=bar;
               _contraIndex=bar;
              }
            else if(shallChange)
              {
               int startSkip=ExtPeaksBuffer[_lastIndex]==0?0:1;
               if(open[_lastIndex]>close[_lastIndex] && startSkip==0) startSkip++;
               bar=ArrayMaximum(high,_lastIndex+startSkip,bar-_lastIndex-startSkip+1);
               ExtPeaksBuffer[bar]=high[bar];
               _lastDirection=true;
               _lastIndex2=_lastIndex;
               _lastIndex=bar;
               _contraIndex=bar;
              }
           }
         //--- 
         ExtPeaksBuffer[rates_total-1]=0;
         ExtTroughsBuffer[rates_total-1]=0;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
