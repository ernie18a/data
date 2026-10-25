//------------------------------------------------------------------
#property copyright   "© mladen"
#property link        "mladenfx@gmail.com"
#property description "Force index - JMA"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrDeepSkyBlue,clrPink
#property indicator_label2  "Force index"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDodgerBlue,clrPaleVioletRed
#property indicator_width2  2
//
//---
//
input int                 inpPeriod = 14;          // Smoothing period
input double              inpPhase  = 0;           // Smoothing phase
input ENUM_APPLIED_VOLUME inpVolume = VOLUME_TICK; // Volume to use

//
//--- buffers and global variables declarations
//
double val[],valc[],fillu[],filld[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0,fillu,INDICATOR_DATA); 
   SetIndexBuffer(1,filld,INDICATOR_DATA); 
   SetIndexBuffer(2,val  ,INDICATOR_DATA); 
   SetIndexBuffer(3,valc ,INDICATOR_COLOR_INDEX); 
      IndicatorSetString(INDICATOR_SHORTNAME,"Force index ("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _diff = (i>0) ? (inpVolume==VOLUME_TICK ? tick_volume[i] : volume[i])*(close[i]-close[i-1]) : 0;
      val[i]   = iSmooth(_diff,inpPeriod,inpPhase,i);
      valc[i]  = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
      fillu[i] = val[i]; 
      filld[i] = 0;
   }
   return(i);
}
//------------------------------------------------------------------
//    custom functions
//------------------------------------------------------------------
#define _smoothInstances     1
#define _smoothInstancesSize 10
#define _smoothRingSize      11
double workSmooth[_smoothRingSize][_smoothInstances*_smoothInstancesSize];
#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9
//
//
//
double iSmooth(double price, double length, double phase, int i, int instance=0)
{
   int _indP = (i-1)%_smoothRingSize;
   int _indC = (i  )%_smoothRingSize;
   int _inst = instance*_smoothInstancesSize;

   if(i==0 || length<=1) { int k=0; for(; k<volty; k++) workSmooth[_indC][_inst+k]=price; for(; k<_smoothInstancesSize; k++) workSmooth[_indC][_inst+k]=0; return(price); }

   //
   //
   //

      double len1 = MathMax(MathLog(MathSqrt(0.5*(length-1.0)))/MathLog(2.0)+2.0,0);
      double pow1 = MathMax(len1-2.0,0.5);
      double del1 = price - workSmooth[_indP][_inst+bsmax], absDel1 = MathAbs(del1);
      double del2 = price - workSmooth[_indP][_inst+bsmin], absDel2 = MathAbs(del2);
      int   _indF = (i-MathMin(i,10))%_smoothRingSize;

         workSmooth[_indC][_inst+volty]  = (absDel1 > absDel2) ? absDel1 : (absDel1 < absDel2) ? absDel2 : 0;
         workSmooth[_indC][_inst+vsum]   = workSmooth[_indP][_inst+vsum]+(workSmooth[_indC][_inst+volty]-workSmooth[_indF][_inst+volty])*0.1;
         workSmooth[_indC][_inst+avolty] = workSmooth[_indP][_inst+avolty]+(2.0/(MathMax(4.0*length,30)+1.0))*(workSmooth[_indC][_inst+vsum]-workSmooth[_indP][_inst+avolty]);
      
      double dVolty    = (workSmooth[_indC][_inst+avolty]>0) ? workSmooth[_indC][_inst+volty]/workSmooth[_indC][_inst+avolty]: 0;
      double dVoltyTmp = MathPow(len1,1.0/pow1);
         if (dVolty > dVoltyTmp) dVolty = dVoltyTmp;
         if (dVolty < 1.0)       dVolty = 1.0;

      double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         workSmooth[_indC][_inst+bsmax] = (del1 > 0) ? price : price - Kv*del1;
         workSmooth[_indC][_inst+bsmin] = (del2 < 0) ? price : price - Kv*del2;

      //
      //
      //

      double corr  = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

          workSmooth[_indC][_inst+0] = price + alpha*(workSmooth[_indP][_inst+0]-price);
          workSmooth[_indC][_inst+1] = (price - workSmooth[_indC][_inst+0])*(1-beta) + beta*workSmooth[_indP][_inst+1];
          workSmooth[_indC][_inst+2] = (workSmooth[_indC][_inst+0] + corr*workSmooth[_indC][_inst+1]);
          workSmooth[_indC][_inst+3] = (workSmooth[_indC][_inst+2] - workSmooth[_indP][_inst+4])*((1-alpha)*(1-alpha)) + (alpha*alpha)*workSmooth[_indP][_inst+3];
          workSmooth[_indC][_inst+4] = (workSmooth[_indP][_inst+4] + workSmooth[_indC][_inst+3]);
   return(workSmooth[_indC][_inst+4]);

   #undef bsmax
   #undef bsmin
   #undef volty
   #undef vsum
   #undef avolty
}    