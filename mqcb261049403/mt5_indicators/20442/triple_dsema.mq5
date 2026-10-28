//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Triple DSEMA (double smoothed EMA)"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "DSEMA high"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width1  2
#property indicator_label2  "DSEMA close"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width2  2
#property indicator_label3  "DSEMA low"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width3  2
//--- input parameters
input double inpDsemaPeriod=27;  // DSEMA period
//--- indicator buffers
double dsemau[],dsemauc[],dsemac[],dsemacc[],dsemad[],dsemadc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,dsemau,INDICATOR_DATA);
   SetIndexBuffer(1,dsemauc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,dsemac,INDICATOR_DATA);
   SetIndexBuffer(3,dsemacc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,dsemad,INDICATOR_DATA);
   SetIndexBuffer(5,dsemadc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Triple Dsema ("+(string)inpDsemaPeriod+")");
//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      dsemau[i] = iDsema(high[i],inpDsemaPeriod,i,rates_total,0);
      dsemac[i] = iDsema(close[i],inpDsemaPeriod,i,rates_total,1);
      dsemad[i] = iDsema(low[i],inpDsemaPeriod,i,rates_total,2);
      dsemauc[i] = (i>0) ? (dsemau[i]>dsemau[i-1]) ? 2 : (dsemau[i]<dsemau[i-1]) ? 1 : dsemauc[i-1] : 0;
      dsemacc[i] = (i>0) ? (dsemac[i]>dsemac[i-1]) ? 2 : (dsemac[i]<dsemac[i-1]) ? 1 : dsemacc[i-1] : 0;
      dsemadc[i] = (i>0) ? (dsemad[i]>dsemad[i-1]) ? 2 : (dsemad[i]<dsemad[i-1]) ? 1 : dsemadc[i-1] : 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workDsema[][6];
#define _ema1 0
#define _ema2 1
//
//---
//
double iDsema(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(period<=1) return(price);
   if(ArrayRange(workDsema,0)!=bars) ArrayResize(workDsema,bars); instanceNo*=2;
//
//---
//
   workDsema[r][_ema1+instanceNo] = price;
   workDsema[r][_ema2+instanceNo] = price;
   double alpha=2.0/(1.0+MathSqrt(period));
   if(r>0)
     {
      workDsema[r][_ema1+instanceNo]=workDsema[r-1][_ema1+instanceNo]+alpha*(price                         -workDsema[r-1][_ema1+instanceNo]);
      workDsema[r][_ema2+instanceNo]=workDsema[r-1][_ema2+instanceNo]+alpha*(workDsema[r][_ema1+instanceNo]-workDsema[r-1][_ema2+instanceNo]); 
     }
   return(workDsema[r][_ema2+instanceNo]);
  }
//+------------------------------------------------------------------+
