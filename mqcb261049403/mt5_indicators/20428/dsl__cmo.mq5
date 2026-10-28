//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Discontinued signal lines version of Chandes momentum oscillator"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "CMO no trend zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro
#property indicator_label2  "CMO"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrSandyBrown,clrDeepSkyBlue
#property indicator_width2  2
//
//--- input parameters
//
input int  inpCmoPeriod       = 20; // CMO period
input int  inpCmoSignalPeriod =  9; // CMO signal period
                                    //
//--- buffers and global variables declarations
//
double cmo[],cmoc[],dslup[],dsldn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,dslup,INDICATOR_DATA);
   SetIndexBuffer(1,dsldn,INDICATOR_DATA);
   SetIndexBuffer(2,cmo,INDICATOR_DATA);
   SetIndexBuffer(3,cmoc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Dsl Chandes momentum oscillator ("+(string)inpCmoPeriod+","+(string)inpCmoSignalPeriod+")");
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
   double _alpha=2.0/(1+inpCmoSignalPeriod);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double SumUp=0;
      double SumDn=0;
      for(int k=0; k<inpCmoPeriod && (i-k-1)>=0; k++)
        {
         double diff=close[i-k]-close[i-k-1];
         SumUp += diff>0 ?  diff : 0;
         SumDn += diff<0 ? -diff : 0;
        }
      cmo[i]=(SumUp+SumDn)!=0 ? 100 *(SumUp-SumDn)/(SumUp+SumDn) : 0;
      dslup[i] = (i>0) ? (cmo[i]>0) ? dslup[i-1]+_alpha*(cmo[i]-dslup[i-1]) : dslup[i-1] : 0;
      dsldn[i] = (i>0) ? (cmo[i]<0) ? dsldn[i-1]+_alpha*(cmo[i]-dsldn[i-1]) : dsldn[i-1] : 0;
      cmoc[i]  = (cmo[i] > dslup[i]) ? 2 : (cmo[i] < dsldn[i]) ? 1 : 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
