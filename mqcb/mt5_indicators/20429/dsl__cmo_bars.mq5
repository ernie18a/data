//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Discontinued signal lines version of Chandes momentum oscillator"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   1
#property indicator_label1  "Dsl CMO trend bars"
#property indicator_type1   DRAW_COLOR_BARS
#property indicator_color1  clrDarkGray,clrSandyBrown,clrDeepSkyBlue
//
//--- input parameters
//
input int  inpCmoPeriod       = 20; // CMO period
input int  inpCmoSignalPeriod =  9; // CMO signal period
                                    //
//--- buffers and global variables declarations
//
double cmo[],cmoc[],dslup[],dsldn[],baro[],barh[],barl[],barc[],barcl[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,baro,INDICATOR_DATA);
   SetIndexBuffer(1,barh,INDICATOR_DATA);
   SetIndexBuffer(2,barl,INDICATOR_DATA);
   SetIndexBuffer(3,barc,INDICATOR_DATA);
   SetIndexBuffer(4,barcl,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,dslup,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,dsldn,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,cmo,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,cmoc,INDICATOR_CALCULATIONS);
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
   static int prevDisplayType=-1;int currDisplayType=(int)ChartGetInteger(0,CHART_MODE);
   if(currDisplayType!=prevDisplayType)
     {
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,currDisplayType==CHART_CANDLES?DRAW_COLOR_CANDLES:DRAW_COLOR_BARS);
      prevDisplayType=currDisplayType;
     }

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
      //
      //---
      //
      barh[i]  = high[i];
      barl[i]  = low[i];
      barc[i]  = close[i];
      baro[i]  = open[i];
      barcl[i] = cmoc[i];
     }
   return (i);
  }
//+------------------------------------------------------------------+
