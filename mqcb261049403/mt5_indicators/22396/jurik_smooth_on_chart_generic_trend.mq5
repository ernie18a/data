//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Tripple Jurik on chart generic trend"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   4
#property indicator_label1  "Smooth high"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Smooth close"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepPink,clrGreen
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Smooth low"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepPink,clrGreen
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Smooth generic"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrDeepPink,clrGreen
#property indicator_width4  2
//--- input parameters
input double inpSmoothPeriod = 27; // Smooth period
input double inpSmoothPhase  =  0; // Smooth phase
//--- indicator buffers
double valu[],valuc[],valc[],valcc[],vald[],valdc[],valg[],valgc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,valu,INDICATOR_DATA);
   SetIndexBuffer(1,valuc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,valc,INDICATOR_DATA);
   SetIndexBuffer(3,valcc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,vald,INDICATOR_DATA);
   SetIndexBuffer(5,valdc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,valg,INDICATOR_DATA);
   SetIndexBuffer(7,valgc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Triple Jurik OCGT ("+(string)inpSmoothPeriod+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
   {
      valu[i] = iSmooth(high[i]                      ,inpSmoothPeriod,inpSmoothPhase,i,0);
      valc[i] = iSmooth(close[i]                     ,inpSmoothPeriod,inpSmoothPhase,i,1);
      vald[i] = iSmooth(low[i]                       ,inpSmoothPeriod,inpSmoothPhase,i,2);
      valg[i] = iSmooth((high[i]+low[i]+close[i])/3.0,inpSmoothPeriod,inpSmoothPhase,i,3);
      valuc[i] = (i>0) ? (valu[i]>valu[i-1]) ? 2 : (valu[i]<valu[i-1]) ? 1 : valuc[i-1] : 0;
      valcc[i] = (i>0) ? (valc[i]>valc[i-1]) ? 2 : (valc[i]<valc[i-1]) ? 1 : valcc[i-1] : 0;
      valdc[i] = (i>0) ? (vald[i]>vald[i-1]) ? 2 : (vald[i]<vald[i-1]) ? 1 : valdc[i-1] : 0;
      valgc[i] = (valuc[i]==2 && valcc[i]==2 && valdc[i]==2) ? 2 : (valuc[i]==1 && valcc[i]==1 && valdc[i]==1) ? 1 : 0;
   }
   return(i);
}
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _smoothInstances     4
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
   int _indP = (int)MathMod(i-1,_smoothRingSize);
   int _indC = (int)MathMod(i  ,_smoothRingSize);
   int _inst = instance*_smoothInstancesSize;

   if(i==0 || length<=1) { int k=0; for(; k<volty; k++) workSmooth[_indC][_inst+k]=price; for(; k<_smoothInstancesSize; k++) workSmooth[_indC][_inst+k]=0; return(price); }

   //
   //
   //

      double len1 = MathMax(MathLog(MathSqrt(0.5*(length-1.0)))/MathLog(2.0)+2.0,0);
      double pow1 = MathMax(len1-2.0,0.5);
      double del1 = price - workSmooth[_indP][_inst+bsmax];
      double del2 = price - workSmooth[_indP][_inst+bsmin];
      int   _indF = (int)MathMod(i-MathMin(i,10),_smoothRingSize);

      workSmooth[_indC][_inst+volty]  = (MathAbs(del1) > MathAbs(del2)) ? MathAbs(del1) : (MathAbs(del1) < MathAbs(del2)) ? MathAbs(del2) : 0;
      workSmooth[_indC][_inst+vsum]   = workSmooth[_indP][_inst+vsum]+(workSmooth[_indC][_inst+volty]-workSmooth[_indF][_inst+volty])*0.1;
      workSmooth[_indC][_inst+avolty] = workSmooth[_indP][_inst+avolty]+(2.0/(MathMax(4.0*length,30)+1.0))*(workSmooth[_indC][_inst+vsum]-workSmooth[_indP][_inst+avolty]);
      
      double dVolty = (workSmooth[_indC][_inst+avolty]>0) ? workSmooth[_indC][_inst+volty]/workSmooth[_indC][_inst+avolty]: 0;
         if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
         if (dVolty < 1.0)                    dVolty = 1.0;

      //
      //
      //

      double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if(del1 > 0) workSmooth[_indC][_inst+bsmax] = price; else workSmooth[_indC][_inst+bsmax] = price - Kv*del1;
         if(del2 < 0) workSmooth[_indC][_inst+bsmin] = price; else workSmooth[_indC][_inst+bsmin] = price - Kv*del2;

      //
      //
      //

      double corr  = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         workSmooth[_indC][_inst+0] = price + alpha*(workSmooth[_indP][_inst+0]-price);
         workSmooth[_indC][_inst+1] = (price - workSmooth[_indC][_inst+0])*(1-beta) + beta*workSmooth[_indP][_inst+1];
         workSmooth[_indC][_inst+2] = (workSmooth[_indC][_inst+0] + corr*workSmooth[_indC][_inst+1]);
         workSmooth[_indC][_inst+3] = (workSmooth[_indC][_inst+2] - workSmooth[_indP][_inst+4])*MathPow((1-alpha),2) + MathPow(alpha,2)*workSmooth[_indP][_inst+3];
         workSmooth[_indC][_inst+4] = (workSmooth[_indP][_inst+4] + workSmooth[_indC][_inst+3]);
   return(workSmooth[_indC][_inst+4]);

   #undef bsmax
   #undef bsmin
   #undef volty
   #undef vsum
   #undef avolty
}    
//+------------------------------------------------------------------+