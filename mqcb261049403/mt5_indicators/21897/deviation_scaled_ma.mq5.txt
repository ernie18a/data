//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Deviation scaled MA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "DSMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width1  2
//--- input parameters
input int                inpPeriod = 25;          // MA period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price
//--- indicator buffers
double val[],valc[],flt[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,flt,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Deviation scaled MA ("+(string)inpPeriod+")");
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
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      flt[i] = (i>1) ? iSsm(close[i]-close[i-2],inpPeriod,i,rates_total) : 0;
      double rms = 0;
         for (int k=0; k<inpPeriod && (i-k)>=0; k++) 
             rms += flt[i-k]*flt[i-k];
             rms = MathSqrt(rms/inpPeriod);
      double _scaledFilt = (rms)!=0 ? flt[i] / rms : 1;
      double _alpha = MathAbs(_scaledFilt)*5 / inpPeriod;
      double _price = getPrice(inpPrice,open,close,high,low,i,rates_total);
      val[i]  = (i>0) ? val[i-1]+_alpha*(_price-val[i-1]) : _price;
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _maWorkBufferx2 2
double workSsm[][_maWorkBufferx2];
#define _tprice  0
#define _ssm     1
//
//---
//
double workSsmCoeffs[][4];
#define _speriod 0
#define _sc1    1
#define _sc2    2
#define _sc3    3

double iSsm(double price, double period, int i, int bars, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workSsm,0) !=bars)                 ArrayResize(workSsm,bars);
   if (ArrayRange(workSsmCoeffs,0) < (instanceNo+1)) ArrayResize(workSsmCoeffs,instanceNo+1);
   if (workSsmCoeffs[instanceNo][_speriod] != period)
   {
      workSsmCoeffs[instanceNo][_speriod] = period;
      double a1 = MathExp(-1.414*M_PI/period);
      double b1 = 2.0*a1*MathCos(1.414*M_PI/period);
         workSsmCoeffs[instanceNo][_sc2] = b1;
         workSsmCoeffs[instanceNo][_sc3] = -a1*a1;
         workSsmCoeffs[instanceNo][_sc1] = 1.0 - workSsmCoeffs[instanceNo][_sc2] - workSsmCoeffs[instanceNo][_sc3];
   }

   //
   //
   //
   //
   //

      int s = instanceNo*2; 
      workSsm[i][s+_ssm]    = price;
      workSsm[i][s+_tprice] = price;
      if (i>1)
      {  
          workSsm[i][s+_ssm] = workSsmCoeffs[instanceNo][_sc1]*(workSsm[i][s+_tprice]+workSsm[i-1][s+_tprice])/2.0 + 
                               workSsmCoeffs[instanceNo][_sc2]*workSsm[i-1][s+_ssm]                                + 
                               workSsmCoeffs[instanceNo][_sc3]*workSsm[i-2][s+_ssm]; }
   return(workSsm[i][s+_ssm]);
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
