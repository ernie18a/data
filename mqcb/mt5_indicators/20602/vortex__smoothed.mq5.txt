//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Vortex - smoothed"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   3
#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'218,231,226',C'255,221,217'
#property indicator_label2  "Vortex +"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDodgerBlue,clrCrimson
#property indicator_width2  3
#property indicator_label3  "Vortex -"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDodgerBlue,clrCrimson
#property indicator_width3  1

//--- input parameters
input int  inpPeriod       = 32; // Vortex period
input int  inpSmoothPeriod = 14; // Prices smoothing period
//--- buffers declarations
double fillu[],filld[],valp[],valpc[],valm[],valmc[],rngbuffer[],vmpbuffer[],vmmbuffer[],smoothedPrices[][3];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fillu,INDICATOR_DATA);
   SetIndexBuffer(1,filld,INDICATOR_DATA);
   SetIndexBuffer(2,valp,INDICATOR_DATA);
   SetIndexBuffer(3,valpc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,valm,INDICATOR_DATA);
   SetIndexBuffer(5,valmc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,rngbuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,vmpbuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,vmmbuffer,INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Vortex - smoothed ("+(string)inpPeriod+","+(string)inpSmoothPeriod+")");
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
#define _shigh  0
#define _slow   1
#define _sclose 2
//
//---
//
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
   if(ArrayRange(smoothedPrices,0)!=rates_total) ArrayResize(smoothedPrices,rates_total);
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      smoothedPrices[i][_shigh]  = iTema(high[i] ,inpSmoothPeriod,i,rates_total,0);
      smoothedPrices[i][_slow]   = iTema(low[i]  ,inpSmoothPeriod,i,rates_total,1);
      smoothedPrices[i][_sclose] = iTema(close[i],inpSmoothPeriod,i,rates_total,2);
      rngbuffer[i] = (i>0) ? MathMax(smoothedPrices[i][_shigh],smoothedPrices[i-1][_sclose])-MathMin(smoothedPrices[i][_slow],smoothedPrices[i-1][_sclose]) : smoothedPrices[i][_shigh]-smoothedPrices[i][_slow];
      vmpbuffer[i] = (i>0) ? MathAbs(smoothedPrices[i][_shigh] - smoothedPrices[i-1][_slow]) : MathAbs(smoothedPrices[i][_shigh] - smoothedPrices[i][_slow]);
      vmmbuffer[i] = (i>0) ? MathAbs(smoothedPrices[i][_slow] - smoothedPrices[i-1][_shigh]) : MathAbs(smoothedPrices[i][_slow] - smoothedPrices[i][_shigh]);
      //
      //---
      //
      double vmpSum = 0;
      double vmmSum = 0;
      double rngSum = 0;
      for(int k=0; k<inpPeriod && (i-k)>=0; k++)
        {
         vmpSum += vmpbuffer[i-k];
         vmmSum += vmmbuffer[i-k];
         rngSum += rngbuffer[i-k];
        }
      if(rngSum!=0)
        {
         valp[i] = vmpSum/rngSum;
         valm[i] = vmmSum/rngSum;
        }
      valpc[i] = (valp[i]>valm[i]) ? 1 : 2;
      valmc[i] = (valp[i]>valm[i]) ? 1 : 2;
      fillu[i] = valp[i];
      filld[i] = valm[i];
     }
   return (i);
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _temaInstances 3
#define _temaInstancesSize 3
double workTema[][_temaInstances*_temaInstancesSize];
#define _tema1 0
#define _tema2 1
#define _tema3 2
//
//---
//
double iTema(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workTema,0)!=bars) ArrayResize(workTema,bars); instanceNo*=_temaInstancesSize;
//
//---
//
   workTema[r][_tema1+instanceNo] = price;
   workTema[r][_tema2+instanceNo] = price;
   workTema[r][_tema3+instanceNo] = price;
   if(r>0 && period>1)
     {
      double alpha=2.0/(1.0+period);
      workTema[r][_tema1+instanceNo] = workTema[r-1][_tema1+instanceNo]+alpha*(price                         -workTema[r-1][_tema1+instanceNo]);
      workTema[r][_tema2+instanceNo] = workTema[r-1][_tema2+instanceNo]+alpha*(workTema[r][_tema1+instanceNo]-workTema[r-1][_tema2+instanceNo]);
      workTema[r][_tema3+instanceNo]=workTema[r-1][_tema3+instanceNo]+alpha*(workTema[r][_tema2+instanceNo]-workTema[r-1][_tema3+instanceNo]); 
     }
   return(workTema[r][_tema3+instanceNo]+3.0*(workTema[r][_tema1+instanceNo]-workTema[r][_tema2+instanceNo]));
  }
//+------------------------------------------------------------------+
