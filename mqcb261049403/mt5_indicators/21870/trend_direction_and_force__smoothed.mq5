//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Trend direction and force - smoothed"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "No trend zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro
#property indicator_label2  "Trend direction and force"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrSandyBrown,clrDeepSkyBlue
#property indicator_width2  2
//
//--- input parameters
//
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
input int       trendPeriod  = 20;      // Trend period
input int       smoothPeriod = 3;       // Smoothing period
input enMaTypes smoothType   = ma_ema;  // Smoothing type
input double    TriggerUp    =  0.05;   // Trigger up level
input double    TriggerDown  = -0.05;   // Trigger down level
//
//--- buffers and global variables declarations
//
double val[],valc[],levup[],levdn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,levup,INDICATOR_DATA);
   SetIndexBuffer(1,levdn,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend direction and force smoothed ("+(string)trendPeriod+","+(string)smoothPeriod+")");
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
double workTrend[][3];
#define _MMA   0
#define _SMMA  1
#define _TDF   2
//
//---
//
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
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   if(ArrayRange(workTrend,0)!=rates_total) ArrayResize(workTrend,rates_total);
   double _alpha=2.0/(1+trendPeriod);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
         workTrend[i][_MMA]  = (i>0) ? workTrend[i-1][_MMA]+_alpha*(close[i]-workTrend[i-1][_MMA]) : close[i];
         workTrend[i][_SMMA] = (i>0) ? workTrend[i-1][_SMMA]+_alpha*(workTrend[i][_MMA]-workTrend[i-1][_SMMA]) : workTrend[i][_MMA];
            double impetmma  = (i>0) ? workTrend[i][_MMA]  - workTrend[i-1][_MMA]  : 0;
            double impetsmma = (i>0) ? workTrend[i][_SMMA] - workTrend[i-1][_SMMA] : 0;
            double divma     = MathAbs(workTrend[i][_MMA]-workTrend[i][_SMMA])/_Point;
            double averimpet = (impetmma+impetsmma)/(2*_Point);
         workTrend[i][_TDF]  = divma*MathPow(averimpet,3);

         //
         //---
         //
               
         double absValue = 0;  for (int k=0; k<trendPeriod*3 && (i-k)>=0; k++)  absValue = MathMax(absValue,MathAbs(workTrend[i-k][_TDF]));
         val[i] = iCustomMa(smoothType,(absValue > 0) ? workTrend[i][_TDF]/absValue : 0,smoothPeriod,i,rates_total);
         levup[i] = TriggerUp;
         levdn[i] = TriggerDown;
         valc[i]  = (val[i] > levup[i]) ? 2 : (val[i] < levdn[i]) ? 1 : 0;
     }
   return (i);
  }
//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
#define _maInstances 1
#define _maWorkBufferx1 _maInstances
//
//---
//
double iCustomMa(int mode,double price,double length,int r,int bars,int instanceNo=0)
  {
   switch(mode)
     {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
     }
  }
//
//---
//
double workSma[][_maWorkBufferx1];
//
//---
//
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo]=price;
   double avg=price; int k=1; for(; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo];
   return(avg/(double)k);
  }
//
//---
//
double workEma[][_maWorkBufferx1];
//
//---
//
double iEma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=_bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
  }
//
//---
//
double workSmma[][_maWorkBufferx1];
//
//---
//
double iSmma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSmma,0)!=_bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo]=price;
   if(r>1 && period>1)
      workSmma[r][instanceNo]=workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
  }
//
//---
//
double workLwma[][_maWorkBufferx1];
//
//---
//
double iLwma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workLwma,0)!=_bars) ArrayResize(workLwma,_bars);

   workLwma[r][instanceNo] = price; if(period<1) return(price);
   double sumw = period;
   double sum  = period*price;

   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight=period-k;
      sumw  += weight;
      sum   += weight*workLwma[r-k][instanceNo];
     }
   return(sum/sumw);
  }
 
//+------------------------------------------------------------------+
