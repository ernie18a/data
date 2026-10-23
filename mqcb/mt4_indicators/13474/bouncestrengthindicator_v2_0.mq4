//+------------------------------------------------------------------+
//|                                                          BSI.mq4 |
//|                                          Copyright 2015, fxborg. |
//|                                  http://blog.livedoor.jp/fxborg/ |
//+------------------------------------------------------------------+
#property copyright   "2015, fxborg"
#property link        "http://blog.livedoor.jp/fxborg/"
#property description "Bounce Strength Indicator"
#property version   "2.0"
#property strict
//---
#property indicator_separate_window
#property indicator_buffers    7
#property indicator_label1     "Up Bounce Strength"
#property indicator_color1     DodgerBlue
#property indicator_type1      DRAW_HISTOGRAM    
#property indicator_width1     1
//---
#property indicator_label2     "Down Bounce Strength"
#property indicator_color2     Crimson
#property indicator_type2      DRAW_HISTOGRAM  
#property indicator_width2     1
//---
#property indicator_label3     "Strength/Weekness"
#property indicator_type3      DRAW_NONE
#property indicator_width3     2
//---
#property indicator_label4     "Up Trend"
#property indicator_type4      DRAW_HISTOGRAM    
#property indicator_color4     DodgerBlue
#property indicator_width4     1
//---
#property indicator_label5     "Down Trend"
#property indicator_type5      DRAW_HISTOGRAM    
#property indicator_color5     Tomato
#property indicator_width5     1
//---
#property indicator_label6     "Signal"
#property indicator_color6     DarkSlateBlue
#property indicator_type6      DRAW_LINE    
#property indicator_width6     1
//---
#property indicator_label7     "Slow Trend"
#property indicator_color7     Navy
#property indicator_type7      DRAW_LINE    
#property indicator_width7     1
//---
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
//--- input parameters
input int InpRangePeriod=20;            //  Range Period
input int InpSlowing=3;                 // Slowing
input int InpAvgPeriod=14;              //  Avg Period
input bool InpUsingVolumeWeight=true;   // Using TickVolume
input double InpReversalNoiseFilter=5;  // Noise Filter
input  color InpSigColor=DarkSlateBlue; // Signal Color
input  color InpSlowColor=Navy; // Slow Color
//---
double RevNoiseFilter=InpReversalNoiseFilter*Point;
//--- buffers
double PosBuffer[];
double NegBuffer[];
double SigBuffer[];
double MainBuffer[];
double SlowBuffer[];
//---- for disp
double UpTrendBuffer[];
double DownTrendBuffer[];
//---- for calc 
double VolBuffer[];
double HighesBuffer[];
double LowesBuffer[];
double HighBuffer[];
double LowBuffer[];
double TangoBuffer[];
double TangoMaBuffer[];
//---
int draw_begin1=0;
int draw_begin2=0;
double pos_offset=75;
double neg_offset=75;
//--------------------------------------------------------------------
//| De-initialization                                                |
//--------------------------------------------------------------------
int deinit()
  {
   string short_name="Bounce Strength Index v2.0("+IntegerToString(InpRangePeriod)+","+IntegerToString(InpSlowing)+","+IntegerToString(InpAvgPeriod)+")";
   if(InpUsingVolumeWeight)
      short_name+=" using Volumes";
   IndicatorShortName(short_name);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   string short_name;
//--- 2 additional buffers are used for counting.
   IndicatorBuffers(14);
   SetIndexBuffer(7,VolBuffer);
   SetIndexBuffer(8,TangoBuffer);
   SetIndexBuffer(9,TangoMaBuffer);
   SetIndexBuffer(10,HighBuffer);
   SetIndexBuffer(11,LowBuffer);
   SetIndexBuffer(12,HighesBuffer);
   SetIndexBuffer(13,LowesBuffer);
//--- indicator lines
   SetIndexBuffer(0,PosBuffer);
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexBuffer(1,NegBuffer);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexBuffer(2,MainBuffer);
   SetIndexBuffer(3,UpTrendBuffer);
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexBuffer(4,DownTrendBuffer);
   SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexBuffer(5,SigBuffer);
   SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,1,InpSigColor);
   SetIndexBuffer(6,SlowBuffer);
   SetIndexStyle(6,DRAW_LINE,STYLE_SOLID,1,InpSlowColor);
//--- name for DataWindow and indicator subwindow label
//---
   draw_begin1=InpRangePeriod+InpSlowing;
   draw_begin2=draw_begin1+InpAvgPeriod;
   SetIndexDrawBegin(0,draw_begin1);
   SetIndexDrawBegin(1,draw_begin1);
   SetIndexDrawBegin(2,draw_begin2);
   short_name="Bounce Strength Index v2.0("+IntegerToString(InpRangePeriod)+","+IntegerToString(InpSlowing)+","+IntegerToString(InpAvgPeriod)+")";
   if(InpUsingVolumeWeight)
      short_name+=" using Volumes";
   IndicatorShortName(short_name);
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| BSI caluclate                                                    |
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
   int i,k,pos;
//--- check for bars count
   if(rates_total<=InpRangePeriod+InpAvgPeriod+InpSlowing)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(PosBuffer,false);
   ArraySetAsSeries(NegBuffer,false);
   ArraySetAsSeries(SigBuffer,false);
   ArraySetAsSeries(MainBuffer,false);
   ArraySetAsSeries(SlowBuffer,false);
   ArraySetAsSeries(UpTrendBuffer,false);
   ArraySetAsSeries(DownTrendBuffer,false);
//---
   ArraySetAsSeries(HighesBuffer,false);
   ArraySetAsSeries(LowesBuffer,false);
   ArraySetAsSeries(VolBuffer,false);
   ArraySetAsSeries(HighBuffer,false);
   ArraySetAsSeries(LowBuffer,false);
   ArraySetAsSeries(TangoBuffer,false);
   ArraySetAsSeries(TangoMaBuffer,false);
//---
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(tick_volume,false);
//---
   pos=InpRangePeriod-1;
//---
   if(pos+1<prev_calculated)
      pos=prev_calculated-2;
   else
     {
      for(i=0; i<pos; i++)
        {
         LowesBuffer[i]=0.0;
         HighesBuffer[i]=0.0;
         VolBuffer[i]=0.0;
        }

     }
//--- calculate HighesBuffer[] and HighesBuffer[]
   int reversal_bar=pos-InpRangePeriod+1;
   int btm_bar=reversal_bar;
   int top_bar=reversal_bar;
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      //--- calculate range spread
      double dmin=1000000.0;
      double dmax=-1000000.0;
      long volmax=0;
      for(k=i-InpRangePeriod+1; k<=i; k++)
        {
         if(dmin>low[k]) dmin=low[k];
         if(dmax<high[k]) dmax=high[k];
         if(InpUsingVolumeWeight && volmax<tick_volume[k])
            volmax=tick_volume[k];
        }
      //--- find reversal bar
      if((LowesBuffer[i-2]-RevNoiseFilter)>LowesBuffer[i-1]
         && LowesBuffer[i-1]==dmin)
        {
         btm_bar=i-1;
        }
      if((HighesBuffer[i-2]+RevNoiseFilter)<HighesBuffer[i-1]
         && HighesBuffer[i-1]==dmax)
        {
         top_bar=i-1;
        }
      reversal_bar=MathMax(top_bar,btm_bar);
      //---
      LowesBuffer[i]=dmin;
      HighesBuffer[i]=dmax;
      //---
      if(InpUsingVolumeWeight)
         VolBuffer[i]=(double)volmax;
      //--- tango line
      if(MathMax(top_bar,btm_bar)>i-InpRangePeriod+1)
        {
         //--- calculate range spread
         dmin=1000000.0;
         dmax=-1000000.0;
         //---
         for(k=i-InpRangePeriod+1; k<=i; k++)
           {
            if(k>=reversal_bar)
              {
               if(dmin>low[k]) dmin=low[k];
               if(dmax<high[k]) dmax=high[k];
              }
           }
        }
      //---
      TangoBuffer[i]=(dmax+dmin)/2;
     }
//--- line
   int MaPeriod=(int)MathRound(InpRangePeriod/2);
   pos=InpRangePeriod-1+MathMax(MaPeriod,InpSlowing)-1;
   if(pos+1<prev_calculated)
      pos=prev_calculated-2;
   else
     {
      for(i=0; i<pos; i++)
        {
         MainBuffer[i]=0.0;
         PosBuffer[i]=0.0;
         NegBuffer[i]=0.0;
        }
     }
//--- main cycle
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      double sumTango=0.0;
      for(k=(i-MaPeriod+1);k<=i;k++)
         sumTango+=TangoBuffer[k];
      //---
      TangoMaBuffer[i]=sumTango/MaPeriod;
      //---
      double sumpos=0.0;
      double sumneg=0.0;
      double sumhigh=0.0;
      double sumpvol = 0.0;
      double sumnvol = 0.0;
      //---
      double fact=(HighBuffer[i]-LowBuffer[i])/close[i];
      //---
      for(k=(i-InpSlowing+1); k<=i; k++)
        {
         //---
         double vol=1.0;
         if(InpUsingVolumeWeight && VolBuffer[k]>0)
           {
            double vol_fact=MathSqrt(VolBuffer[k]);
            vol=MathSqrt(tick_volume[k])/vol_fact;
           }
         //--- Range position ratio
         double ratio=0;
         //--- Bar Spread
         double sp=(high[k]-low[k]);
         //--- Not DownBar
         if(!(close[k-1]-sp*0.2>close[k]))
           {
            ratio=-1*(low[k]/TangoMaBuffer[k])+2;
            sumpos+=(close[k]-low[k])*ratio;
           }
         //--- Not UpBar
         if(!(close[k-1]+sp*0.2<close[k]))
           {
            ratio=-1*(high[k]/TangoMaBuffer[k])+2;
            sumneg+=(high[k]-close[k])*ratio;
           }
        }
      double tmppos,tmpneg;
      tmppos=sumpos/InpSlowing/ Point;
      tmpneg=sumneg/InpSlowing/ Point;
      if((tmppos+tmpneg)!=0)
        {
         SigBuffer[i]=2*(tmppos-tmpneg)*MathAbs((tmppos-tmpneg)/(tmppos+tmpneg));
        }
      PosBuffer[i] = tmppos;
      NegBuffer[i] = -tmpneg;
      // up Trend
     }
//--- avg
   pos=InpRangePeriod-1;
   if(pos+1<prev_calculated)
      pos=prev_calculated-2;
   else
     {
      for(i=0; i<pos; i++)
        {
         MainBuffer[i]=0.0;
         SigBuffer[i]=0.0;
         UpTrendBuffer[i]=0.0;
         DownTrendBuffer[i]=0.0;
        }
     }
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      //---
      double sum_range=0;
      double sum_avg=0;
      for(k=InpRangePeriod-1; k>=0; k--)
        {
         sum_range+=SigBuffer[i-k];

         if(k<=InpAvgPeriod-1)
            sum_avg+=SigBuffer[i-k];
        }
      //---
      SlowBuffer[i]=sum_range/InpRangePeriod;
      //---
      double trend = sum_avg/InpAvgPeriod;
      MainBuffer[i]= trend;
      if(trend>0)
        {
         UpTrendBuffer[i]=trend;
         DownTrendBuffer[i]=0.0;
        }
      else if(trend<0)
        {
         UpTrendBuffer[i]=0.0;
         DownTrendBuffer[i]=trend;
        }
      else
        {
         UpTrendBuffer[i]=0.0;
         DownTrendBuffer[i]=0.0;
        }
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
