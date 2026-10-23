//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "ATR adaptive JMA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "JMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrCrimson,clrGreen
#property indicator_width1  2
//--- input parameters
input int                inpJmaPeriod = 14;          // JMA period
input double             inpJmaPhase  = 0;           // JMA phase
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price
//--- indicator buffers
double val[],valc[],atr[],tr[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,atr,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,tr,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"ATR adaptive JMA ("+(string)inpJmaPeriod+")");
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
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
   {
      tr[i] = (i>0) ? MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]) : high[i]-low[i];
      atr[i] = 0; 
         for (int k=0; k<inpJmaPeriod && (i-k)>=0; k++) 
            atr[i] += tr[i-k]; 
            atr[i] /= inpJmaPeriod;
         int _start = MathMax(i-inpJmaPeriod+1,0);
         double _max   = atr[ArrayMaximum(atr,_start,inpJmaPeriod)];            
         double _min   = atr[ArrayMinimum(atr,_start,inpJmaPeriod)];            
         double _coeff = (_min!=_max) ? 1-(atr[i]-_min)/(_max-_min) : 0.5;
         
      val[i]  = iSmooth(getPrice(inpPrice,open,close,high,low,i,rates_total),inpJmaPeriod*(_coeff+1.0)/2.0,inpJmaPhase,i);
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
   }
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
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
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>=0)
      switch(tprice)
        {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
        }
   return(0);
  }
//+------------------------------------------------------------------+
