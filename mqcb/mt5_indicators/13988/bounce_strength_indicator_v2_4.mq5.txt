//+------------------------------------------------------------------+
//|                               Bounce Strength Indicator_v2.4.mq5 |
//| Bounce Strength Indicator v2.4            Copyright 2015, fxborg |
//|                                   http://fxborg-labo.hateblo.jp/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, fxborg"
#property link      "http://fxborg-labo.hateblo.jp/"
#property version   "2.4"
#include <MovingAverages.mqh>
#define GOMPERTS_C 0.99
#define GOMPERTS_B 0.15

#property indicator_buffers 20
#property indicator_plots   3
//---
#property indicator_separate_window
#property indicator_type1 DRAW_NONE
#property indicator_type2 DRAW_COLOR_HISTOGRAM
#property indicator_type3 DRAW_LINE
//---
#property indicator_color1 DimGray
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID
//---
#property indicator_color2 Gold,DodgerBlue,DeepPink
#property indicator_label2 "BSI Main"
#property indicator_width2 3
#property indicator_style2 STYLE_SOLID
//---
#property indicator_color3 LimeGreen
#property indicator_label3 "BSI Slow"
#property indicator_width3 2
#property indicator_style3 STYLE_SOLID

//--- input parameters
input double InpScaleFactor=0.75;      // Scale factor
input int    InpMaPeriod=3;            // Smooth Period
input int    InpVolatilityPeriod=55;   // Volatility Period
input int    InpBSIPeriod=5;           // BSI_CalcBars
input int    InpFastPeriod=10;         // Fast Period
input int    InpSlowPeriod=7;          // Slow Period
input bool   InpUsingVolumeWeight=true;// Using TickVolume
//---
int  StdDevPeriod=int(InpVolatilityPeriod/7); // Fast Period
//---
ENUM_MA_METHOD InpMaMethod=MODE_SMMA; // Ma Method 
//---- will be used as indicator buffers
double UpperBuffer[];
double MedianBuffer[];
double LowerBuffer[];
double TrendBuffer[];
//---
double UpperMaBuffer[];
double MedianMaBuffer[];
double LowerMaBuffer[];
//---
double MainBuffer[];
double SigBuffer[];
double MainColor_Buffer[];
double TrendColor_Buffer[];
double PosBuffer[];
double NegBuffer[];
//---
double BaseBuffer[];
double VolBuffer[];
//---
double HighBuffer[];
double LowBuffer[];
double CloseBuffer[];
double StdDevBuffer[];
double StdDevCalcBuffer[];
//---- declaration of global variables
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total=StdDevPeriod+InpVolatilityPeriod+InpMaPeriod+InpMaPeriod+InpSlowPeriod+InpBSIPeriod+MathMax(InpFastPeriod,InpSlowPeriod);
//--- indicator buffers mapping
//--- indicator buffers
   SetIndexBuffer(0,SigBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(1,MainBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,MainColor_Buffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,TrendBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,TrendColor_Buffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,PosBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,NegBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,MedianMaBuffer,INDICATOR_DATA);
   SetIndexBuffer(8,BaseBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,UpperMaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,LowerMaBuffer,INDICATOR_CALCULATIONS);
//---
   SetIndexBuffer(11,UpperBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,MedianBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,LowerBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,HighBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(15,LowBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(16,CloseBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(17,StdDevBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(18,StdDevCalcBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(19,VolBuffer,INDICATOR_CALCULATIONS);
//---
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(9,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(10,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(11,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(12,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(13,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(14,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(15,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(16,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(17,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(18,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(19,PLOT_EMPTY_VALUE,0);
//---
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---
   string short_name="BSI v2.4";
//---
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
   if(rates_total<=min_rates_total+3)
      return(0);
//---
   MathSrand(int(TimeLocal()));
//--- indicator buffers
//+----------------------------------------------------+
//| Set Median Buffeer                                 |
//+----------------------------------------------------+
   first=StdDevPeriod;
   if(first+1<prev_calculated)
      first=prev_calculated-2;
   else
     {
      for(i=0; i<first; i++)
        {
         MedianBuffer[i]=close[i];
         HighBuffer[i]=high[i];
         LowBuffer[i]=low[i];
        }
     }
//---
   for(i=first; i<rates_total && !IsStopped(); i++)
     {
      //---
      StdDevBuffer[i]=calcStdDev(close,StdDevPeriod,i);
      int second=StdDevPeriod+InpVolatilityPeriod;
      //---
      if(i<=second)continue;
      long volsum=0;
      double sd=0.0;
      for(j=(i-InpVolatilityPeriod+1);j<=i;j++)
        {
         sd+=StdDevBuffer[j];
         if(InpUsingVolumeWeight) volsum+=tick_volume[j];
        }
      if(InpUsingVolumeWeight) VolBuffer[i]=(double)volsum/InpVolatilityPeriod;
      //--- Base Buffer
      double v=sd/InpVolatilityPeriod;
      BaseBuffer[i]=v;
      //---
      int third=second+InpMaPeriod+InpMaPeriod;
      if(i<=third)continue;
      //--- 
      StepChannel(high,low,close,
                  InpScaleFactor,InpMaPeriod,v,i,
                  HighBuffer,LowBuffer,CloseBuffer,
                  UpperBuffer,LowerBuffer,MedianBuffer,
                  UpperMaBuffer,LowerMaBuffer,MedianMaBuffer);
      //--- 
      int fourth=third+InpBSIPeriod;
      if(i<=fourth) continue;
      //---
      SigBuffer[i]=calc_BSI(high,low,close,tick_volume,i);
      int fifth=fourth+InpFastPeriod;
      if(i<=fifth)continue;
      //---
      double sigsum=0.0;
      for(j=0;j<InpFastPeriod;j++)
        {
         sigsum+=SigBuffer[i-j];
        }
      MainBuffer[i]=(sigsum/InpFastPeriod);
      //---
      int sixes=fourth+InpSlowPeriod;
      if(i<=sixes)continue;
      //---
      double mainsum=0.0;
      for(j=0;j<InpSlowPeriod;j++)
        {
         mainsum+=MainBuffer[i-j];
        }
      //---
      TrendBuffer[i]=(mainsum/InpSlowPeriod);
      //---
      if(TrendBuffer[i]>0)
        {
         TrendColor_Buffer[i]=1.0;
        }
      else if(TrendBuffer[i]<0)
        {
         TrendColor_Buffer[i]=2.0;
        }
      else
         TrendColor_Buffer[i]=0.0;
      //---
      if(0<MainBuffer[i] && TrendBuffer[i]<MainBuffer[i])
         MainColor_Buffer[i]=1.0;
      else if(0>MainBuffer[i] && TrendBuffer[i]>MainBuffer[i])
         MainColor_Buffer[i]=2.0;
      else
         MainColor_Buffer[i]=0.0;
      //---
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcStdDev(const double  &close[],int span,int i)
  {
   if(i<span-1)   return 0.0;
//---
   if(i==span-1)
      StdDevCalcBuffer[i]=SimpleMA(i,span,close);
   else
      StdDevCalcBuffer[i]=SmoothedMA(i,span,StdDevCalcBuffer[i-1],close);
//---
   double sum=0.0;
   for(int j=0;j<span;j++)
      sum+=MathPow(close[i-j]-StdDevCalcBuffer[i],2);
   return MathSqrt(sum/span);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long calcMaxVol(const long  &tick_volume[],int span,int i)
  {
   if(i<span-1) return 0;
   long volmax=0;
   for(int j=0;j<span;j++)
      if(volmax<tick_volume[i-j]) volmax=tick_volume[i-j];
   return volmax;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_BSI(const double  &high[],const double  &low[],const double  &close[],const long  &tick_volume[],int i)
  {
   if(i<=min_rates_total)return 0.0;
   if(MedianMaBuffer[(i-InpBSIPeriod+1)]==0)return 0.0;
//---
   double sumpos2=0.0;
   double sumneg2=0.0;
   double sumpos=0.0;
   double sumneg=0.0;
   double sumhigh=0.0;
   double sumpvol = 0.0;
   double sumnvol = 0.0;
//---
   double sum=0;
//---
   for(int k=(i-InpBSIPeriod+1); k<=i; k++)
     {
      //---
      double vol=1.0;
      //---
      if(InpUsingVolumeWeight && VolBuffer[k]>0)
        {
         if(tick_volume[k]>0)
            vol=MathMin(1.0,MathSqrt(tick_volume[k]/VolBuffer[k]));
         else if(tick_volume[k-1]>0 && tick_volume[k]==0)
            vol=MathMin(1.0,MathSqrt(tick_volume[k-1]/VolBuffer[k-1]));
        }
      //--- Range position ratio
      double range=(UpperMaBuffer[i]-LowerMaBuffer[i])/_Point;
      //--- Bar Spread
      double sp=(high[k]-low[k]);
      //--- Not DownBar
      if(!(close[k-1]-sp*0.2>close[k]))
        {
         double ratio=GompertzRatio((MedianMaBuffer[k]-low[k])/_Point,range)/range;
         sumpos+=(close[k]-low[k]) *ratio *vol;
         sumpos2+=(close[k]-low[k]);
        }
      //--- Not UpBar
      if(!(close[k-1]+sp*0.2<close[k]))
        {
         double ratio=GompertzRatio((high[k]-MedianMaBuffer[k])/_Point,range)/range;
         sumneg+=(high[k]-close[k]) *ratio*vol;
         sumneg2+=(high[k]-close[k]);
        }
     }
//---      
   double tmppos,tmpneg;
   tmppos=sumpos;
   tmpneg=sumneg;
   PosBuffer[i]=tmppos;
   NegBuffer[i]=-tmpneg;
//---
   if((tmppos+tmpneg)!=0)
     {
      return (tmppos-tmpneg)*MathAbs((tmppos-tmpneg)/(tmppos+tmpneg));
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GompertzRatio(double x,double a)
  {
   if(a==0.0 || x==0.0)return 0;
   double b=GOMPERTS_B;
   double c=GOMPERTS_C;
   double y;
   y=a*MathExp(-b*MathPow(c,x));
//---
   return y;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StepChannel(const double &high[],const double &low[],const double &close[],
                 double scale_factor,int ma_period,double volatility,int i,
                 double  &high_buffer[],double  &low_buffer[],double  &close_buffer[],
                 double   &upper_buffer[],double   &lower_buffer[],double   &median_buffer[],
                 double   &upper_ma_buffer[],double   &lower_ma_buffer[],double   &median_ma_buffer[])
  {
   int j;
//---
   double h,l,c,hsum=0.0,lsum=0.0,csum=0.0;
//---
   for(j=0;j<ma_period;j++)
     {
      hsum += high[i-j];
      lsum += low[i-j];
      csum += close[i-j];
     }
//---
   h=hsum/ma_period;
   l=lsum/ma_period;
   c=csum/ma_period;
//--- Base Volatility
   double base=volatility*scale_factor;
//--- Hybrid Mode
   if((h-base)>high_buffer[i-1]) high_buffer[i]=h;
   else if(h+base<high_buffer[i-1]) high_buffer[i]=h+base;
   else high_buffer[i]=high_buffer[i-1];
//---
   if(l+base<low_buffer[i-1]) low_buffer[i]=l;
   else if((l-base)>low_buffer[i-1]) low_buffer[i]=l-base;
   else low_buffer[i]=low_buffer[i-1];
//---
   if((c-base/2)>close_buffer[i-1]) close_buffer[i]=c-base/2;
   else if(c+base/2<close_buffer[i-1]) close_buffer[i]=c+base/2;
   else close_buffer[i]=close_buffer[i-1];
//---
   upper_buffer[i]=high_buffer[i] + base/2;
   lower_buffer[i]=low_buffer[i]  - base/2;
   median_buffer[i]=(high_buffer[i]+low_buffer[i]+close_buffer[i]*2)/4;
//---
   hsum=0.0;
   lsum=0.0;
   csum=0.0;
//---
   for(j=0;j<ma_period;j++)
     {
      hsum += upper_buffer[i-j];
      lsum += lower_buffer[i-j];
      csum += median_buffer[i-j];
     }
//---
   upper_ma_buffer[i]=hsum/ma_period;
   lower_ma_buffer[i]=lsum/ma_period;
   median_ma_buffer[i]=csum/ma_period;
  }
//+------------------------------------------------------------------+
