//+------------------------------------------------------------------+
//|                                                   SwingChart.mq5 |
//|                                  Copyright 2016, André S. Enger. |
//|                                          andre_enger@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Andre S. Enger."
#property link      "andre_enger@hotmail.com"
#property version   "1.0"
#property description "Gann swingchart and hybrid ZigZag implementation."

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 2

#property indicator_label1  "Zig Zag"
#property indicator_type1   DRAW_ZIGZAG
#property indicator_color1  clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2   clrRed,clrGray,clrBlue,clrGreen
#property indicator_label2  "Open;High;Low;Close"

//--- Buffers
double ExtPeaksBuffer[];
double ExtTroughsBuffer[];
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];

//--- Globals
bool lastDirection;
int lastIndex;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtPeaksBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtTroughsBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ExtCloseBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,ExtColorBuffer,INDICATOR_COLOR_INDEX);

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
      start=0;
      lastIndex=0;
     }
   else
      start=prev_calculated-1;
   start=MathMax(1,start);
//--- main loop
   for(int bar=start; bar<rates_total-1; bar++)
     {
      bool upDay=low[bar-1]<=low[bar] && high[bar-1]<high[bar];
      bool downDay=low[bar-1]>low[bar] && high[bar-1]>=high[bar];
      bool insideDay=low[bar-1]<=low[bar] && high[bar-1]>=high[bar];
      bool outsideDay=low[bar-1]>low[bar] && high[bar-1]<high[bar];
      bool goingUp=close[bar]>open[bar]; //--- Approximation to the price action on outside days
      ExtOpenBuffer[bar]=open[bar];
      ExtHighBuffer[bar]=high[bar];
      ExtLowBuffer[bar]=low[bar];
      ExtCloseBuffer[bar]=close[bar];
      if(downDay) ExtColorBuffer[bar]=0;
      else if(insideDay) ExtColorBuffer[bar]=1;
      else if(outsideDay) ExtColorBuffer[bar]=2;
      else if(upDay) ExtColorBuffer[bar]=3;
      ExtPeaksBuffer[bar]=0;
      ExtTroughsBuffer[bar]=0;
      //---
      if(lastDirection)
        {
         if(high[bar]>high[lastIndex])
           {
            ExtPeaksBuffer[lastIndex]=0;
            ExtPeaksBuffer[bar]=high[bar];
            if(outsideDay)
              {
               ExtTroughsBuffer[bar]=low[bar];
               if(goingUp)
                 {
                  ExtPeaksBuffer[lastIndex]=high[lastIndex];
                  ResolveUncertainityBull(bar,lastIndex,false,open,high,low,close);
                 }
               else
                  lastDirection=false;
              }
            lastIndex=bar;
           }
         else if(downDay)
           {
            ResolveUncertainityBull(bar,lastIndex,false,open,high,low,close);
            ExtTroughsBuffer[bar]=low[bar];
            lastDirection=false;
            lastIndex=bar;
           }
         else if(outsideDay)
           {
            ExtPeaksBuffer[bar]=high[bar];
            ExtTroughsBuffer[bar]=low[bar];
            if(goingUp)
               ResolveUncertainityBull(bar,lastIndex,false,open,high,low,close);
            else if(!goingUp)
              {
               ResolveUncertainityBull(bar,lastIndex,true,open,high,low,close);
               lastDirection=false;
              }
            lastIndex=bar;
           }
        }
      else
        {
         if(low[bar]<low[lastIndex])
           {
            ExtTroughsBuffer[lastIndex]=0;
            ExtTroughsBuffer[bar]=low[bar];
            if(outsideDay)
              {
               ExtPeaksBuffer[bar]=high[bar];
               if(!goingUp)
                 {
                  ExtTroughsBuffer[lastIndex]=low[lastIndex];
                  ResolveUncertainityBear(bar,lastIndex,false,open,high,low,close);
                 }
               else
                  lastDirection=true;
              }
            lastIndex=bar;
           }
         else if(upDay)
           {
            ResolveUncertainityBear(bar,lastIndex,false,open,high,low,close);
            ExtPeaksBuffer[bar]=high[bar];
            lastDirection=true;
            lastIndex=bar;
           }
         else if(outsideDay)
           {
            ExtPeaksBuffer[bar]=high[bar];
            ExtTroughsBuffer[bar]=low[bar];
            if(!goingUp)
               ResolveUncertainityBear(bar,lastIndex,false,open,high,low,close);
            else
              {
               ResolveUncertainityBear(bar,lastIndex,true,open,high,low,close);
               lastDirection=true;
              }
            lastIndex=bar;
           }
        }
     }
   ExtPeaksBuffer[rates_total-1]=0;
   ExtTroughsBuffer[rates_total-1]=0;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Resolves uncertain periods in the ZigZag                         |
//|------------------------------------------------------------------|
//| Preconditions: There has been a bull trend until lastIndex.      |
//|   Therefore the ZigZag has a peak there, and if there also is    |
//|   a trough, the ZigZag points up. There has been atleast one bar,|
//|   so 'bar-lastIndex>0'.                                          |
//| Postconditions: Draw proper peaks and troughs upto 'bar'.        |
//| Parameter 'tweaked': If true then there is a maximum at 'bar'    |
//|   and the ZigZag must point down there.                          |
//+------------------------------------------------------------------+
void ResolveUncertainityBull(int bar,
                             int index,
                             bool tweaked,
                             const double &open[],
                             const double &high[],
                             const double &low[],
                             const double &close[])
  {
//--- Skip first possible minimum (at lastIndex) if the ZigZag is vertical there
//--- or the candle at lastIndex points up (approximates price continuity)
   int startSkip=ExtTroughsBuffer[index]==0?0:1;
   if(open[index]<close[index] && startSkip==0) startSkip++;
//--- Search until bar or one before depending on ZigZag direction at end.
//--- If ZigZag points down at bar, the minimum must come before this.
   int minimal=ArrayMinimum(low,index+startSkip,bar-index-startSkip+(tweaked?0:1));
   while(minimal!=-1 && minimal<bar)
     {
      ExtTroughsBuffer[minimal]=low[minimal];
      //--- Having added a trough, the next maximum can be on same bar only if
      //--- it is a bull candle and there is not a peak there from before 
      int maxSkip=ExtPeaksBuffer[minimal]==0?0:1;
      if(open[minimal]>close[minimal] && maxSkip==0) maxSkip++;
      //--- Search until bar or one before depending on tweak.
      //--- If ZigZag points down at bar, the "exit" maximum is there.
      int maximal=ArrayMaximum(high,minimal+maxSkip,bar-minimal-maxSkip+(tweaked?1:0));
      if(maximal==-1 || (tweaked && maximal>=bar))
         break;
      ExtPeaksBuffer[maximal]=high[maximal];
      //--- Having added a peak, the next minimum can be on same bar only if
      //--- it is a bear candle and not a trough there from before
      int minSkip=ExtTroughsBuffer[maximal]==0?0:1;
      if(open[maximal]<close[maximal] && minSkip==0) minSkip++;
      //--- Find next minimum
      minimal=ArrayMinimum(low,maximal+minSkip,bar-maximal-minSkip+(tweaked?0:1));
     }
  }
//+------------------------------------------------------------------+
//| Same as above, bear-trend version                                |
//+------------------------------------------------------------------+
void ResolveUncertainityBear(int bar,
                             int index,
                             bool tweaked,
                             const double &open[],
                             const double &high[],
                             const double &low[],
                             const double &close[])
  {
   int startSkip=ExtPeaksBuffer[index]==0?0:1;
   if(open[index]>close[index] && startSkip==0) startSkip++;
   int maximal=ArrayMaximum(high,index+startSkip,bar-index-startSkip+(tweaked?0:1));
   while(maximal!=-1 && maximal<bar)
     {
      ExtPeaksBuffer[maximal]=high[maximal];
      int minSkip=ExtTroughsBuffer[maximal]==0?0:1;
      if(open[maximal]<close[maximal] && minSkip==0) minSkip++;
      int minimal=ArrayMinimum(low,maximal+minSkip,bar-maximal-minSkip+(tweaked?1:0));
      if(minimal==-1 || (tweaked && minimal==bar))
         break;
      ExtTroughsBuffer[minimal]=low[minimal];
      int maxSkip=ExtPeaksBuffer[minimal]==0?0:1;
      if(open[minimal]>close[minimal] && maxSkip==0) maxSkip++;
      maximal=ArrayMaximum(high,minimal+maxSkip,bar-minimal-maxSkip+(tweaked?0:1));
     }
  }
//+------------------------------------------------------------------+
