//+------------------------------------------------------------------+
//|                                                PercentChange.mq5 |
//|                                          Copyright 2018, pipPod. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright  "Copyright 2015, pipPod."
#property link       "https://www.mql5.com/en/users/pippod"
#property description"Percent Change"
#property version    "1.10"
#property strict
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot Label1
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrLimeGreen,clrFireBrick,clrYellow
#property indicator_label1  "Open;High;Low;Close"
//---
input long chartID=0;
input ushort eventID=0;
//--- indicator buffers
double OpenBuffer[];
double HighBuffer[];
double LowBuffer[];
double CloseBuffer[];
double ColorBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME,"Percent Change");
   IndicatorSetInteger(0,INDICATOR_DIGITS,4);
//--- indicator buffers mapping
   SetIndexBuffer(0,OpenBuffer,INDICATOR_DATA);
   //ArraySetAsSeries(OpenBuffer,true);
   SetIndexBuffer(1,HighBuffer,INDICATOR_DATA);
   //ArraySetAsSeries(HighBuffer,true);
   SetIndexBuffer(2,LowBuffer,INDICATOR_DATA);
   //ArraySetAsSeries(LowBuffer,true);
   SetIndexBuffer(3,CloseBuffer,INDICATOR_DATA);
   //ArraySetAsSeries(CloseBuffer,true);
   SetIndexBuffer(4,ColorBuffer,INDICATOR_COLOR_INDEX);
   //ArraySetAsSeries(ColorBuffer,true);
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
   int begin=prev_calculated-1;
   if(!prev_calculated)
     {
      int barsWindow=MathMin((int)ChartGetInteger(ChartID(),CHART_VISIBLE_BARS)+20,rates_total);
      begin=rates_total-barsWindow;
      //for(int i=0;i<indicator_buffers;i++)
         //PlotIndexSetInteger(i,PLOT_DRAW_BEGIN,begin);
      OpenBuffer[begin]=HighBuffer[begin]=LowBuffer[begin]=CloseBuffer[begin]=0.0;
      begin++;
     }
//--- main loop
   static double prevClose,prevCloseBuffer;
   for(int i=begin;i<rates_total && !_StopFlag;i++)
     {
      if(rates_total!=prev_calculated)
        {
         prevClose=close[i-1];
         prevCloseBuffer=CloseBuffer[i-1];
        } 
//--- check zero divide calculate percent change
      if(prevClose)
        {
         OpenBuffer[i]=prevCloseBuffer+open[i]/prevClose-1;
         HighBuffer[i]=prevCloseBuffer+high[i]/prevClose-1;
         LowBuffer[i]=prevCloseBuffer+low[i]/prevClose-1;
         CloseBuffer[i]=prevCloseBuffer+close[i]/prevClose-1;
        }
      else
         OpenBuffer[i]=HighBuffer[i]=LowBuffer[i]=CloseBuffer[i]=prevCloseBuffer; 
//--- set colour
      ColorBuffer[i]=OpenBuffer[i]<CloseBuffer[i]?0:OpenBuffer[i]>CloseBuffer[i]?1:2;    
     } 
//--- call custom chart event
   if(prev_calculated)
      ::EventChartCustom(chartID,eventID,eventID,rates_total-prev_calculated,_Symbol);   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
