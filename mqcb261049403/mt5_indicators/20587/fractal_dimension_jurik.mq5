//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Fractal dimension Jurik"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "Fractal dimension index"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
//--- input parameters
input int                inpFdiPeriod    =  30;         // Fractal dimension period
input int                inpFdiCount     =   5;         // Fractal dimension count
input int                inpFdiSmooth    =   5;         // Fractal dimension smoth
input double             inpFdiThreshold =  1.5;        // Fractal dimension threshold
//--- buffers declarations
double val[],valc[],prices[],smlRange[],smlSumm[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,smlRange,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,smlSumm,INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,inpFdiThreshold);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Fractal dimension (Jurik) ("+(string)inpFdiPeriod+","+(string)inpFdiCount+","+(string)inpFdiSmooth+","+(string)inpFdiThreshold+")");
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
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      val[i] = iSma(iFD(close,high,low,inpFdiPeriod,inpFdiCount,i),inpFdiSmooth,i,rates_total);
      valc[i]=(val[i]>inpFdiThreshold) ? 1 : 2;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double iFD(const double &close[],const double &high[],const double &low[],int size,int count,int i)
  {
   double bigRange = 0.00;
   int    window1  = size*(count-1);
   int    window2  = size* count;
   double nLog     = MathLog(count);

   smlRange[i] = (i>=size) ? MathMax(close[i-size],maxHigh(high,size,i))- MathMin(close[i-size],minLow(low,size,i)) : 0;
   smlSumm[i]  = (i>0)     ? smlSumm[i-1]+smlRange[i] : 0;
   if(i>window1)
     {
      bigRange    = (i>=window2) ? MathMax(close[i-window2],maxHigh(high,window2,i)) - MathMin(close[i-window2],minLow(low,window2,i)) : 0;
      smlSumm[i] -= smlRange[i-window1];
      return( 2 - MathLog(bigRange/(smlSumm[i]/window1))/nLog);
     }
   else return(1.5);
  }
//
//---
//
double minLow(const double &low[],int period,int shift)
  {
   double minValue=low[shift];
   for(int i=1; i<period && (shift-i)>-0; i++) minValue=MathMin(minValue,low[shift-i]);
   return(minValue);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double maxHigh(const double &high[],int period,int shift)
  {
   double maxValue=high[shift];
   for(int i=1; i<period && (shift-i)>=0; i++) maxValue=MathMax(maxValue,high[shift-i]);
   return(maxValue);
  }
//
//---
//
double workSma[][1];
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
//+------------------------------------------------------------------+
