//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Logarithmic Garman Klass Volatility"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Logarithmic Garman Klass Volatility"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrSkyBlue,clrDodgerBlue
#property indicator_width1  2
//--- input parameters
input int inpVolPeriod = 30; // Volatility lookback period
input int inpCompound = 252; // Compound
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
   IndicatorSetString(INDICATOR_SHORTNAME,"Logarithmic Garman Klass Volatility ("+(string)inpVolPeriod+","+(string)inpCompound+")");
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
double work[][6];
#define _lnCC 0
#define _lnCO 1
#define _lnOC 2
#define _lnHL 3
#define _gk   4
#define _lgk  5

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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      work[i][_lnCC] = log(close[i]/(i>0?close[i-1]:close[i]));
      work[i][_lnCO] = log(close[i]/open[i]);
      work[i][_lnOC] = log(open[i]/(i>0?close[i-1]:close[i]));
      work[i][_lnHL] = log(high[i]/low[i]);
      #define square(_a) (_a*_a)
         double lambda = inpVolPeriod/(inpVolPeriod+3.0);
         double varCC = 0;
            for (int k=0; k<inpVolPeriod && (i-k)>=0; k++) varCC += square(work[i-k][_lnCC]);
                                                           varCC /= inpVolPeriod;
         work[i][_lgk] = varCC;
         work[i][_gk]  = square(work[i][_lnOC]) + 0.5*square(work[i][_lnHL]) - 0.386*square(work[i][_lnCO]);
         if (i>inpVolPeriod+4)
         {
            work[i][_lgk] = (varCC>0) ? log(varCC) : log(1);
            work[i][_lgk] = ((1.0-lambda)*log(work[i-1][_gk]>0?work[i-1][_gk]:1)) + (lambda*log(work[i-1][_lgk]>0?work[i-1][_lgk]:1));
            work[i][_lgk] = exp(work[i][_lgk]);
         }            
      val[i]  =  sqrt(work[i][_lgk])*sqrt(inpCompound) * 100;
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
