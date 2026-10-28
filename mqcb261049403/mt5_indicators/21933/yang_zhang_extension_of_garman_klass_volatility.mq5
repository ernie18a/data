//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Yang Zhang extension of Garman Klass Volatility"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Yang Zhang extension of Garman Klass Volatility"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrSkyBlue,clrDodgerBlue
#property indicator_width1  2
//--- input parameters
input int inpVolPeriod = 22; // Volatility lookback period
//--- buffers and global variables declarations
double val[],valc[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Yang Zhang extension of Garman Klass Volatility ("+(string)inpVolPeriod+")");
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
double work[][3];
#define _gkyzoc 0
#define _gkyzhl 1
#define _gkyzco 2

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
   if (ArrayRange(work,0)!=rates_total) ArrayResize(work,rates_total);
   double _corr = sqrt((double)inpVolPeriod/(inpVolPeriod-1.0));
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      work[i][_gkyzoc] =log(open[i]/(i>0?close[i-1]:close[i]))*log(open[i]/(i>0?close[i-1]:close[i]));
      work[i][_gkyzhl] =0.5*log(high[i]/low[i])*log(high[i]/low[i]);
      work[i][_gkyzco] =(2*log(2)-1.0)*log(close[i]/open[i])*log(close[i]/open[i]);
      double _sum = 0; for (int k=0; k<inpVolPeriod && (i-k)>=0; k++) _sum += work[i-k][_gkyzoc]+work[i-k][_gkyzhl]-work[i-k][_gkyzco];
      double gkyz=sqrt(_sum)*sqrt(256.0/(double)inpVolPeriod);
      val[i]  = gkyz*_corr;
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
