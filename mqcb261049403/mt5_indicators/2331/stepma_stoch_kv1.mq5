//+------------------------------------------------------------------+
//|                                             StepMA_Stoch_KV1.mq5 |
//|                           Copyright © 2005, TrendLaboratory Ltd. |
//|                                       E-mail: igorad2004@list.ru |
//|                           modified by Kalenzo -> simone@konto.pl |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, TrendLaboratory Ltd."
#property link      "E-mail: igorad2004@list.ru"
//--- indicator version
#property version   "1.02"
//--- drawing the indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers is 2
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//--- drawing the indicator as a seven-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//--- colors of the seven-color histogram are as follows
#property indicator_color1 clrMagenta,clrMediumVioletRed,clrPlum,clrGray,clrLightSkyBlue,clrTeal,clrDodgerBlue
//--- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1 2
//--- displaying the indicator label
#property indicator_label1 "StepMA_Stoch_KV1"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint PeriodWATR=10;
input double Kwatr=1.0000;
input bool HighLow=false;
//+-----------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//--- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(PeriodWATR+1);
//--- Set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//--- set dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorIndBuffer,true);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"StepMA_Stoch_KV1");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declarations of local variables 
   int limit,bar,TrendMin,TrendMax,TrendMid;
   double SminMin0,SmaxMin0,SumRange,dK,WATR0;
   double SminMax0,SmaxMax0,SminMid0,SmaxMid0;
   double linemin,linemax,linemid,Stoch1,Stoch2,bsmin,bsmax;
   static double SminMin1,SmaxMin1,WATRmax,WATRmin;
   static double SminMax1,SmaxMax1,SminMid1,SmaxMid1,WATRmax_,WATRmin_;
   static int TrendMin1,TrendMax1,TrendMid1;
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
//--- the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      bar=limit;
      SumRange=0;
      for(int iii=0; iii<int(PeriodWATR); iii++)
        {
         dK=1+1.0*(PeriodWATR-iii)/PeriodWATR;
         int kkk=bar+iii;
         SumRange+=dK*MathAbs(high[kkk]-low[kkk]);
        }
      WATR0=SumRange/PeriodWATR;
      WATRmax_=WATR0;
      WATRmin_=WATR0;
      int StepSizeMin=int(MathRound(Kwatr*WATRmin/_Point));
      int StepSizeMax=int(MathRound(Kwatr*WATRmax/_Point));
      int StepSizeMid=int(MathRound(Kwatr*0.5*(WATRmax+WATRmin)/_Point));
      if(HighLow)
        {
         SmaxMin1=low[bar]+2*StepSizeMin*_Point;
         SminMin1=high[bar]-2*StepSizeMin*_Point;
         SmaxMax1=low[bar]+2*StepSizeMax*_Point;
         SminMax1=high[bar]-2*StepSizeMax*_Point;
         SmaxMid1=low[bar]+2*StepSizeMid*_Point;
         SminMid1=high[bar]-2*StepSizeMid*_Point;
        }
      if(!HighLow)
        {
         SmaxMin1=close[bar]+2*StepSizeMin*_Point;
         SminMin1=close[bar]-2*StepSizeMin*_Point;
         SmaxMax1=close[bar]+2*StepSizeMax*_Point;
         SminMax1=close[bar]-2*StepSizeMax*_Point;
         SmaxMid1=close[bar]+2*StepSizeMid*_Point;
         SminMid1=close[bar]-2*StepSizeMid*_Point;
        }
      TrendMin1=0;
      TrendMax1=0;
      TrendMid1=0;
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars
//---
   TrendMin=TrendMin1;
   TrendMax=TrendMax1;
   TrendMid=TrendMid1;
//--- main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      SumRange=0;
      for(int iii=0; iii<int(PeriodWATR); iii++)
        {
         dK=1+1.0*(PeriodWATR-iii)/PeriodWATR;
         int kkk=bar+iii;
         SumRange+=dK*MathAbs(high[kkk]-low[kkk]);
        }
      WATR0=SumRange/PeriodWATR;
      //---
      WATRmax=MathMax(WATR0,WATRmax_);
      WATRmin=MathMin(WATR0,WATRmin_);
      //---
      int StepSizeMin=int(MathRound(Kwatr*WATRmin/_Point));
      int StepSizeMax=int(MathRound(Kwatr*WATRmax/_Point));
      int StepSizeMid=int(MathRound(Kwatr*0.5*(WATRmax+WATRmin)/_Point));
      //---
      if(HighLow)
        {
         SmaxMin0=low[bar]+2*StepSizeMin*_Point;
         SminMin0=high[bar]-2*StepSizeMin*_Point;
         SmaxMax0=low[bar]+2*StepSizeMax*_Point;
         SminMax0=high[bar]-2*StepSizeMax*_Point;
         SmaxMid0=low[bar]+2*StepSizeMid*_Point;
         SminMid0=high[bar]-2*StepSizeMid*_Point;
         //---
         if(close[bar]>SmaxMin1) TrendMin=+1;
         if(close[bar]<SminMin1) TrendMin=-1;
         if(close[bar]>SmaxMax1) TrendMax=+1;
         if(close[bar]<SminMax1) TrendMax=-1;
         if(close[bar]>SmaxMid1) TrendMid=+1;
         if(close[bar]<SminMid1) TrendMid=-1;
        }
      if(!HighLow)
        {
         SmaxMin0=close[bar]+2*StepSizeMin*_Point;
         SminMin0=close[bar]-2*StepSizeMin*_Point;
         SmaxMax0=close[bar]+2*StepSizeMax*_Point;
         SminMax0=close[bar]-2*StepSizeMax*_Point;
         SmaxMid0=close[bar]+2*StepSizeMid*_Point;
         SminMid0=close[bar]-2*StepSizeMid*_Point;
         //---
         if(close[bar]>SmaxMin1) TrendMin=+1;
         if(close[bar]<SminMin1) TrendMin=-1;
         if(close[bar]>SmaxMax1) TrendMax=+1;
         if(close[bar]<SminMax1) TrendMax=-1;
         if(close[bar]>SmaxMid1) TrendMid=+1;
         if(close[bar]<SminMid1) TrendMid=-1;
        }
      //---
      if(TrendMin>0 && SminMin0<SminMin1) SminMin0=SminMin1;
      if(TrendMin<0 && SmaxMin0>SmaxMin1) SmaxMin0=SmaxMin1;
      if(TrendMax>0 && SminMax0<SminMax1) SminMax0=SminMax1;
      if(TrendMax<0 && SmaxMax0>SmaxMax1) SmaxMax0=SmaxMax1;
      if(TrendMid>0 && SminMid0<SminMid1) SminMid0=SminMid1;
      if(TrendMid<0 && SmaxMid0>SmaxMid1) SmaxMid0=SmaxMid1;
      //---
      if(TrendMin>0) linemin=SminMin0+StepSizeMin*_Point;
      if(TrendMin<0) linemin=SmaxMin0-StepSizeMin*_Point;
      if(TrendMax>0) linemax=SminMax0+StepSizeMax*_Point;
      if(TrendMax<0) linemax=SmaxMax0-StepSizeMax*_Point;
      if(TrendMid>0) linemid=SminMid0+StepSizeMid*_Point;
      if(TrendMid<0) linemid=SmaxMid0-StepSizeMid*_Point;
      //---
      bsmin=linemax-StepSizeMax*_Point;
      bsmax=linemin+StepSizeMax*_Point;
      double res=bsmax-bsmin;
      if(!res) res=0.00000001;
      Stoch1=NormalizeDouble((linemin-bsmin)/res,6);
      Stoch2=NormalizeDouble((linemid-bsmin)/res,6);
      IndBuffer[bar]=Stoch1-Stoch2;
      //---
      if(bar)
        {
         SminMin1=SminMin0;
         SmaxMin1=SmaxMin0;
         SminMax1=SminMax0;
         SmaxMax1=SmaxMax0;
         SminMid1=SminMid0;
         SmaxMid1=SmaxMid0;
         WATRmax_=WATRmax;
         WATRmin_=WATRmin;
         TrendMin1=TrendMin;
         TrendMax1=TrendMax;
         TrendMid1=TrendMid;
        }
     }
   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
//--- main cycle of the indicator coloring
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      int clr=3;
      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar+1]) clr=6;
         if(IndBuffer[bar]==IndBuffer[bar+1]) clr=5;
         if(IndBuffer[bar]<IndBuffer[bar+1]) clr=4;
        }
      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar+1]) clr=0;
         if(IndBuffer[bar]==IndBuffer[bar+1]) clr=1;
         if(IndBuffer[bar]>IndBuffer[bar+1]) clr=2;
        }
      ColorIndBuffer[bar]=clr;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
