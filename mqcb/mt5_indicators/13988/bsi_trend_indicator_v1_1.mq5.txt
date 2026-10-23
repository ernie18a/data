//+------------------------------------------------------------------+
//|                                     BSI_Trend_Indicator_v1.1.mq5 |
//| BSI Trend Indicator v1.1                  Copyright 2015, fxborg |
//|                                   http://fxborg-labo.hateblo.jp/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, fxborg"
#property link      "http://fxborg-labo.hateblo.jp/"
#property version   "1.1"
#include <MovingAverages.mqh>
#define GOMPERTS_C 0.99
#define GOMPERTS_B 0.15

#property indicator_buffers 30
#property indicator_plots   3
//---
#property indicator_chart_window
#property indicator_type1 DRAW_NONE
#property indicator_type2 DRAW_NONE
#property indicator_type3 DRAW_COLOR_LINE
//---
#property indicator_color1 Goldenrod
#property indicator_width1 2
#property indicator_style1 STYLE_SOLID
#property indicator_color2 Red
#property indicator_width2 2
#property indicator_style2 STYLE_SOLID
#property indicator_color3 DeepPink,LightPink,DimGray,LightSkyBlue,DodgerBlue
#property indicator_width3 3
#property indicator_style3 STYLE_SOLID

//--- input parameters
input int    InpBSIPeriod=5;           // BSI_CalcBars
input int    InpFastPeriod=10;         // Fast Period
input int    InpSlowPeriod=7;          // Slow Period
input bool   InpUsingVolumeWeight=true;// Using TickVolume
input int    InpLwMaPeriod=30;         // LWMA Period
//---
int    SmoothPeriod=3;        // Smooth Period
double ScaleFactor=0.75;      // Scale factor
int    VolatilityPeriod=55;   // Volatility Period
int    StdDevPeriod=int(VolatilityPeriod/7); // Fast Period
double Slow_ScaleFactor=2.25;      // Scale factor
int    Slow_VolatilityPeriod=70;   // Volatility Period
int    Slow_StdDevPeriod=int(Slow_VolatilityPeriod/7); // Fast Period
ENUM_MA_METHOD InpMaMethod=MODE_SMMA; // Ma Method
//---- will be used as indicator buffers
double SlowBuffer[];
double LwMaBuffer[];
//---
double MainBuffer[];
double SigBuffer[];
double MainColor_Buffer[];
double SlowColor_Buffer[];
double PriceBuffer[];
//---
double VolBuffer[];
//---
double HighBuffer[];
double LowBuffer[];
double CloseBuffer[];
double StdDevBuffer[];
double StdDevCalcBuffer[];
//---
double Slow_HighBuffer[];
double Slow_LowBuffer[];
double Slow_CloseBuffer[];
double Slow_StdDevBuffer[];
double Slow_StdDevCalcBuffer[];
//---
double MedianBuffer[];
double MedianMaBuffer[];
//---
double Slow_MedianBuffer[];
double Slow_MedianMaBuffer[];
//---
double LowerBuffer[];
double LowerMaBuffer[];
double UpperBuffer[];
double UpperMaBuffer[];
//---
double Slow_LowerBuffer[];
double Slow_LowerMaBuffer[];
double Slow_UpperBuffer[];
double Slow_UpperMaBuffer[];
//---
//--- declaration of global variables
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initialization of variables of data calculation starting point
   min_rates_total=Slow_StdDevPeriod+Slow_VolatilityPeriod+SmoothPeriod+SmoothPeriod+InpSlowPeriod+InpBSIPeriod+MathMax(InpFastPeriod,InpSlowPeriod);
//--- indicator buffers mapping
//--- indicator buffers
   int idx=0;
//---
   SetIndexBuffer(idx++,MedianMaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,Slow_MedianMaBuffer,INDICATOR_DATA);
   SetIndexBuffer(idx++,MainBuffer,INDICATOR_DATA);
   SetIndexBuffer(idx++,MainColor_Buffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(idx++,SlowBuffer,INDICATOR_DATA);
//---
   SetIndexBuffer(idx++,SlowColor_Buffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(idx++,SigBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,PriceBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,LwMaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,MedianBuffer,INDICATOR_CALCULATIONS);
//10
   SetIndexBuffer(idx++,HighBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,LowBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,CloseBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,StdDevBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,StdDevCalcBuffer,INDICATOR_CALCULATIONS);
//---
   SetIndexBuffer(idx++,VolBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,UpperBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,LowerBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,UpperMaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,LowerMaBuffer,INDICATOR_CALCULATIONS);
//20
   SetIndexBuffer(idx++,Slow_HighBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,Slow_LowBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,Slow_CloseBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,Slow_StdDevBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,Slow_StdDevCalcBuffer,INDICATOR_CALCULATIONS);

   SetIndexBuffer(idx++,Slow_MedianBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,Slow_UpperBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,Slow_LowerBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,Slow_UpperMaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(idx++,Slow_LowerMaBuffer,INDICATOR_CALCULATIONS);
//30  
//---
   for(idx=0;idx<30;idx++)
      PlotIndexSetDouble(idx,PLOT_EMPTY_VALUE,0);
//---
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---
   string short_name="BSI Trend v1.1";
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
   first=Slow_StdDevPeriod;
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
      PriceBuffer[i]=(high[i]+low[i]+close[i])/3;
      StdDevBuffer[i]=calcStdDev(StdDevCalcBuffer,close,StdDevPeriod,i);
      Slow_StdDevBuffer[i]=calcStdDev(Slow_StdDevCalcBuffer,close,Slow_StdDevPeriod,i);
      int second=Slow_StdDevPeriod+Slow_VolatilityPeriod;
      //---
      if(i<=second)continue;
      long volsum=0;
      double sd=0.0;
      double slow_sd=0.0;
      //---
      for(j=(i-Slow_VolatilityPeriod+1);j<=i;j++)
        {
         slow_sd+=StdDevBuffer[j];
         if(j<=(i-VolatilityPeriod+1))
           {
            sd+=StdDevBuffer[j];
            if(InpUsingVolumeWeight) volsum+=tick_volume[j];
           }

        }
      //---
      if(InpUsingVolumeWeight) VolBuffer[i]=(double)volsum/VolatilityPeriod;
      //--- Base Buffer
      double v=sd/VolatilityPeriod;
      double slow_v=slow_sd/Slow_VolatilityPeriod;
      //---
      int third=second+SmoothPeriod+SmoothPeriod;
      if(i<=third)continue;
      //--- 
      StepChannel(high,low,close,
                  ScaleFactor,SmoothPeriod,v,i,
                  HighBuffer,LowBuffer,CloseBuffer,
                  UpperBuffer,LowerBuffer,MedianBuffer,
                  UpperMaBuffer,LowerMaBuffer,MedianMaBuffer);
      //--- 
      StepChannel(high,low,close,
                  Slow_ScaleFactor,SmoothPeriod,slow_v,i,
                  Slow_HighBuffer,Slow_LowBuffer,Slow_CloseBuffer,
                  Slow_UpperBuffer,Slow_LowerBuffer,Slow_MedianBuffer,
                  Slow_UpperMaBuffer,Slow_LowerMaBuffer,Slow_MedianMaBuffer);

      //--- 
      LwMaBuffer[i]=LinearWeightedMA(i,InpLwMaPeriod,PriceBuffer);
      //---
      int fourth=third+InpBSIPeriod;
      if(i<=fourth) continue;
      //---
      SigBuffer[i]=calc_BSI(high,low,close,tick_volume,i);
      //---
      int fifth=fourth+InpFastPeriod;
      if(i<=fifth)continue;
      //---
      double sigsum=0.0;
      for(j=0;j<InpFastPeriod;j++)
        {
         sigsum+=SigBuffer[i-j];
        }
      MainBuffer[i]=LwMaBuffer[i]+(sigsum/InpFastPeriod);
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
      SlowBuffer[i]=(mainsum/InpSlowPeriod);
      //---
      if(MathMax(LwMaBuffer[i-1],LwMaBuffer[i])<MainBuffer[i] && MainBuffer[i-1]<MainBuffer[i])
        {
         //---
         if(MainColor_Buffer[i-1]==4.0 || 
            (MainColor_Buffer[i-1]!=0.0 && Slow_MedianMaBuffer[i-3]*1.0001<Slow_MedianMaBuffer[i]))
            MainColor_Buffer[i]=4.0;
         else
            MainColor_Buffer[i]=3.0;
         //---
        }
      else if(MathMin(LwMaBuffer[i-1],LwMaBuffer[i])>MainBuffer[i] && MainBuffer[i-1]>MainBuffer[i])
        {
         //---
         if(MainColor_Buffer[i-1]==0.0 || 
            (MainColor_Buffer[i-1]!=4.0 && Slow_MedianMaBuffer[i-3]*0.9999>Slow_MedianMaBuffer[i]))
            MainColor_Buffer[i]=0.0;
         else
            MainColor_Buffer[i]=1.0;
         //---
        }
      else
         MainColor_Buffer[i]=2.0;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcStdDev(double  &calc_buffer[],const double  &close[],int span,int i)
  {
   if(i<span-1)   return 0.0;
//---
   if(i==span-1)
      calc_buffer[i]=SimpleMA(i,span,close);
   else
      calc_buffer[i]=SmoothedMA(i,span,calc_buffer[i-1],close);
//---
   double sum=0.0;
   for(int j=0;j<span;j++)
      sum+=MathPow(close[i-j]-calc_buffer[i],2);
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
//      Comment(s);
   double tmppos,tmpneg;
   tmppos=sumpos;
   tmpneg=sumneg;
//---
   if((tmppos+tmpneg)!=0)
     {
      return  (tmppos-tmpneg)*MathAbs((tmppos-tmpneg)/(tmppos+tmpneg));
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
