//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro,clrGainsboro
#property indicator_label2  "Volume zone oscillator"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrLimeGreen,clrCrimson
#property indicator_width2  2
//
//---
//
input  int    inpPeriod    =  14;    // Period
//
//---
//
double vzo[],vzoc[],levup[],levdn[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,levup,INDICATOR_DATA);
   SetIndexBuffer(1,levdn,INDICATOR_DATA);
   SetIndexBuffer(2,vzo,INDICATOR_DATA);
   SetIndexBuffer(3,vzoc,INDICATOR_COLOR_INDEX);
   IndicatorSetString(INDICATOR_SHORTNAME,"Volume zone oscillator ("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double work[][2];
#define _vp 0
#define _tv 1
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   if (ArrayRange(work,0)!=rates_total) ArrayResize(work,rates_total);
   double alpha = 2.0 / (1.0 + inpPeriod);
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total  && !_StopFlag; i++)
   {
         double sign = (i>0) ? (close[i]>close[i-1]) ? 1 : (close[i]<close[i-1]) ? -1 : 0 : 0; 
         double R = sign * tick_volume[i];
         work[i][_vp] = (i==0) ? R                      : work[i-1][_vp]+alpha*(R             -work[i-1][_vp]);
         work[i][_tv] = (i==0) ? (double)tick_volume[i] : work[i-1][_tv]+alpha*(tick_volume[i]-work[i-1][_tv]);
               vzo[i] = (work[i][_tv]!=0) ? 100.0*work[i][_vp]/work[i][_tv] : 0;
               vzoc[i] = (vzo[i]>0) ? 1 : (vzo[i]<0) ? 2 : 0;
               levup[i] = MathMax(vzo[i],0);
               levdn[i] = MathMin(vzo[i],0);
   }      
   return(i);
}