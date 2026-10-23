//+------------------------------------------------------------------+
//|                                           TangoMovingAverage.mq4 |
//|                                           Copyright 2015, fxborg |
//|                                  http://blog.livedoor.jp/fxborg/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, fxborg"
#property link      "http://blog.livedoor.jp/fxborg/"
#property version   "1.1"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
//--- plot Label1
//--- input parameters
input  int InpPeriod=20;   // Period
input double InpReversalNoiseFilter=5;     // Noise Filter
input  color InpLineColor=DeepPink; // Tango Line Color
input  color InpMaColor=DarkViolet; // Middle Line Color
input  color InpBandColor=Gray; // Band Color
input double InpDeviations=2.0; // Bands Deviations
//--- indicator buffers
double LineBuffer[];
double MaBuffer[];
//---- for calc 
double HighesBuffer[];
double LowesBuffer[];
double HighBuffer[];
double LowBuffer[];
double UpperBuffer[];
double LowerBuffer[];
int CalcBarCount=2;     // Calc Bar Count
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   string short_name;
//--- indicator buffers mapping
   IndicatorBuffers(8);
   SetIndexBuffer(0,LineBuffer);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,InpLineColor);
   SetIndexShift(0,1);
   SetIndexBuffer(1,MaBuffer);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,InpMaColor);
   SetIndexShift(1,1);
//---
   SetIndexBuffer(2,UpperBuffer);
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT,0,InpBandColor);
   SetIndexShift(2,1);
//---
   SetIndexBuffer(3,LowerBuffer);
   SetIndexStyle(3,DRAW_LINE,STYLE_DOT,0,InpBandColor);
   SetIndexShift(3,1);
//---
   SetIndexBuffer(4,HighesBuffer);
   SetIndexBuffer(5,LowesBuffer);
   SetIndexBuffer(6,HighBuffer);
   SetIndexBuffer(7,LowBuffer);
   if(InpPeriod<2)
     {
      Alert("InpPeriod is too small.");
      return(INIT_FAILED);
     }
//---
   short_name="Tango Line v1.1("+IntegerToString(InpPeriod)+")";
   IndicatorShortName(short_name);
//---
   return(INIT_SUCCEEDED);
  }
//--------------------------------------------------------------------
//| De-initialization                                                |
//--------------------------------------------------------------------
int deinit()
  {
   string short_name="Tango Line v1.1("+IntegerToString(InpPeriod)+")";
   IndicatorShortName(short_name);
   return(0);
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
   int i,k,pos;
//--- check for bars count
   if(rates_total<=InpPeriod)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(LineBuffer,false);
   ArraySetAsSeries(MaBuffer,false);
   ArraySetAsSeries(UpperBuffer,false);
   ArraySetAsSeries(LowerBuffer,false);
//---
   ArraySetAsSeries(HighesBuffer,false);
   ArraySetAsSeries(LowesBuffer,false);
   ArraySetAsSeries(HighBuffer,false);
   ArraySetAsSeries(LowBuffer,false);
//---
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(high,false);
//---
   pos=InpPeriod-1;
   if(pos+1<prev_calculated)
      pos=prev_calculated-2;
   else
     {
      for(i=0; i<pos; i++)
        {
         LowesBuffer[i]=0.0;
         HighesBuffer[i]=0.0;
         HighBuffer[i]=0.0;
         LowBuffer[i]=0.0;
         LineBuffer[i]=0.0;
        }
     }
//--- calculate HighesBuffer[] and ExtHighesBuffer[]
   int spike_bar=pos-InpPeriod+1;
   int btm_bar=pos-InpPeriod+1;
   int top_bar=pos-InpPeriod+1;
//--- i < rates_total 
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      //--- calculate range spread
      double dmin=1000000.0;
      double dmax=-1000000.0;
      for(k=i-InpPeriod+1; k<=i; k++)
        {
         if(dmin>low[k]) dmin=low[k];
         if(dmax<high[k]) dmax=high[k];
        }
      //--- hook
      if((LowesBuffer[i-2]-InpReversalNoiseFilter*Point)>LowesBuffer[i-1]
         && LowesBuffer[i-1]==dmin)
        {
         btm_bar=i-1;
        }
      if((HighesBuffer[i-2]+InpReversalNoiseFilter*Point)<HighesBuffer[i-1]
         && HighesBuffer[i-1]==dmax)
        {
         top_bar=i-1;
        }
      LowesBuffer[i]=dmin;
      HighesBuffer[i]=dmax;
      spike_bar=MathMax(top_bar,btm_bar);
      //---
      if(spike_bar>i-InpPeriod+1)
        {
         //--- calculate range spread
         dmin=1000000.0;
         dmax=-1000000.0;
         //---
         for(k=i-InpPeriod+1; k<=i; k++)
           {
            //---
            if(k>=spike_bar)
              {
               if(dmin>low[k]) dmin=low[k];
               if(dmax<high[k]) dmax=high[k];
              }
           }
        }
      double middle_line=(LowesBuffer[i]+HighesBuffer[i])/2;
      if(spike_bar==top_bar)
        {
         HighBuffer[i]=dmax;
         LowBuffer[i]=MathMin(dmin,middle_line);
        }
      else if(spike_bar==btm_bar)
        {
         HighBuffer[i]=MathMax(dmax,middle_line);
         LowBuffer[i]=(dmin);
        }
      LineBuffer[i]=(dmax+dmin)/2;

     }
//--- avg
   int AvgPeriod=(int)MathFloor(InpPeriod/2);
//   int AvgPeriod = 5;
   pos=AvgPeriod-1;
   if(pos+1<prev_calculated)
      pos=prev_calculated-2;
   else
     {
      for(i=0; i<pos; i++)
        {
         MaBuffer[i]=0.0;
        }
     }
//---
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      double sumM=0.0;
      for(k=0; k<AvgPeriod; k++)
        {
         sumM+=LineBuffer[i-k];
        }
      MaBuffer[i]=sumM/AvgPeriod;
      double std =  calc_StdDev(i,close, MaBuffer[i],AvgPeriod);
      UpperBuffer[i]=  MaBuffer[i]+InpDeviations*std;
      LowerBuffer[i]=  MaBuffer[i]-InpDeviations*std;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
double calc_StdDev(int pos,const double &price[],const double mean,int period)
  {
   double res=0.0;
   if(pos>=period)
     {
      for(int i=0; i<period; i++)
         res+=MathPow(price[pos-i]-mean,2);
      res=MathSqrt(res/period);
     }
   return(res);
  }
//+------------------------------------------------------------------+
