//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Premium stochastic"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro,clrGainsboro
#property indicator_label2  "Stochastic"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrLimeGreen,clrGreen,clrSandyBrown,clrRed
#property indicator_width2  2
//--- input parameters
input int    inpPeriod       =  32;  // Stochastic period
input int    inpSmoothPeriod =   5;  // Smoothing period
input double inpLevel1       = 0.9;  // Level 1
input double inpLevel2       = 0.2;  // Level 2

//--- buffers declarations
double fillu[],filld[],val[],valc[],ema0[],ema1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fillu,INDICATOR_DATA);
   SetIndexBuffer(1,filld,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,ema0,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ema1,INDICATOR_CALCULATIONS);
//---
      IndicatorSetInteger(INDICATOR_LEVELS,4);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0, inpLevel1);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1, inpLevel2);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-inpLevel1);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,3,-inpLevel2);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Premium stochastic ("+(string)inpPeriod+","+(string)inpSmoothPeriod+")");
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
   double _alpha    = 2.0/(1.0+inpSmoothPeriod);
   double _minLevel = MathMin(inpLevel1,inpLevel2);
   double _maxLevel = MathMax(inpLevel1,inpLevel2);

   //
   //---
   //
   
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
         int    _start = MathMax(i-inpPeriod,0);
         double _min   = low [ArrayMinimum(low ,_start,inpPeriod)];
         double _max   = high[ArrayMaximum(high,_start,inpPeriod)];
         double _sto   = (_min!=_max) ? 10.0*((close[i]-_min)/(_max-_min)-0.5) : 0;
         ema0[i] = (i>0) ? ema0[i-1]+_alpha*(_sto   -ema0[i-1]) : 0;
         ema1[i] = (i>0) ? ema1[i-1]+_alpha*(ema0[i]-ema1[i-1]) : 0;

         //
         //---
         //
         
         double _exp = MathExp(ema1[i]);
         val[i]  = (_exp-1.0)/(_exp+1.0);
         valc[i] = 0;
            if (val[i]> _minLevel) valc[i] = (val[i]> _maxLevel) ? 2 : 1;
            if (val[i]<-_minLevel) valc[i] = (val[i]<-_maxLevel) ? 4 : 3;
         
         fillu[i] = val[i];
         filld[i] = (val[i]>0) ? MathMin(_minLevel,val[i]) : (val[i]<0) ? MathMax(-_minLevel,val[i]) : val[i];
     }
   return (i);
  }