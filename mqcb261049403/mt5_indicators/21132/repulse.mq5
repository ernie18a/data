//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Repulse"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Repulse"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrLimeGreen,clrCrimson
#property indicator_width1  2
//--- input parameters
input int  inpPeriod  = 15; // Repulse period
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
   IndicatorSetString(INDICATOR_SHORTNAME,"Repulse ("+(string)inpPeriod+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
         val[i] = iRepulse(inpPeriod,open,high,low,close,i,rates_total);
         valc[i] = (val[i]>0) ? 1 :(val[i]<0) ? 2 : 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workRepulse[][4];
#define PosRaw  0
#define NegRaw  1
#define PosEma  2
#define NegEma  3
//
//---
//
double iRepulse(int period, const double& open[], const double& high[], const double& low[], const double& close[] ,int i, int bars)
  {
   if (ArrayRange(workRepulse,0)!=bars) ArrayResize(workRepulse,bars);
   
      double alpha = 2.0/(1.0+period*5.0);
      int   _start = MathMax(i-period+1,0);
         workRepulse[i][PosRaw] = 100.0*(3*close[i]-2*low[ArrayMinimum(low,_start,period)]-open[i])/close[i];
         workRepulse[i][NegRaw] = 100.0*(open[i]+2*high[ArrayMaximum(high,_start,period)]-3*close[i])/close[i];
         workRepulse[i][PosEma] = (i>0) ? workRepulse[i-1][PosEma]+alpha*(workRepulse[i][PosRaw]-workRepulse[i-1][PosEma]) : workRepulse[i][PosRaw];
         workRepulse[i][NegEma] = (i>0) ? workRepulse[i-1][NegEma]+alpha*(workRepulse[i][NegRaw]-workRepulse[i-1][NegEma]) : workRepulse[i][NegRaw];
      return(workRepulse[i][PosEma]-workRepulse[i][NegEma]);
  }
//+------------------------------------------------------------------+
