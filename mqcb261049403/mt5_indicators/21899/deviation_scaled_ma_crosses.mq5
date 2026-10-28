//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Deviation scaled ma crosses"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "DSMA fast"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width1  2
#property indicator_label2  "DSMA slow"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width2  2
//--- input parameters
input double             inpPeriodFast = 40;          // Fast period
input double             inpPeriodSlow = 100;         // Slow period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price
//--- indicator buffers
double val[],valc[],vals[],valsc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,vals,INDICATOR_DATA);
   SetIndexBuffer(3,valsc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Deviation scaled MA crosses ("+(string)inpPeriodFast+","+(string)inpPeriodSlow+")");
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
      double filter = (i>1) ? close[i]-close[i-2] : 0;
      double price  = getPrice(inpPrice,open,close,high,low,i,rates_total);
      val[i] =iDsma(price,filter,inpPeriodFast,i,rates_total,0);
      vals[i]=iDsma(price,filter,inpPeriodSlow,i,rates_total,1);
      valc[i]= (val[i]>vals[i]) ? 2 :(val[i]<vals[i]) ? 1 : (i>0) ? valc[i-1]: 0;
      valsc[i] = valc[i];
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _dsmaInstances 2
#define _dsmaInstancesSize 3
double workDsma[][_dsmaInstances*_dsmaInstancesSize];
#define _filter  0
#define _dsm     1
#define _ssm     2
//
//---
//
double workDsmaCoeffs[][4];
#define _speriod 0
#define _sc1    1
#define _sc2    2
#define _sc3    3

double iDsma(double price, double filter, double period, int i, int bars, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workDsma,0) !=bars)                 ArrayResize(workDsma,bars);
   if (ArrayRange(workDsmaCoeffs,0) < (instanceNo+1)) ArrayResize(workDsmaCoeffs,instanceNo+1);
   if (workDsmaCoeffs[instanceNo][_speriod] != period)
   {
      workDsmaCoeffs[instanceNo][_speriod] = period;
      double a1 = MathExp(-1.414*M_PI/period);
      double b1 = 2.0*a1*MathCos(1.414*M_PI/period);
         workDsmaCoeffs[instanceNo][_sc2] = b1;
         workDsmaCoeffs[instanceNo][_sc3] = -a1*a1;
         workDsmaCoeffs[instanceNo][_sc1] = 1.0 - workDsmaCoeffs[instanceNo][_sc2] - workDsmaCoeffs[instanceNo][_sc3];
   }

   //
   //
   //
   //
   //

      int s = instanceNo*_dsmaInstancesSize; 
      workDsma[i][s+_ssm]    = filter;
      workDsma[i][s+_filter] = filter;
      if (i>1)
      {  
          workDsma[i][s+_ssm] = workDsmaCoeffs[instanceNo][_sc1]*(workDsma[i][s+_filter]+workDsma[i-1][s+_filter])/2.0 + 
                                workDsmaCoeffs[instanceNo][_sc2]*workDsma[i-1][s+_ssm]                                 + 
                                workDsmaCoeffs[instanceNo][_sc3]*workDsma[i-2][s+_ssm]; 
      }
      double rms = 0;
      for (int k=0; k<period && (i-k)>=0; k++) 
             rms += workDsma[i-k][s+_ssm]*workDsma[i-k][s+_ssm];
             rms = MathSqrt(rms/period);
      double _scaledFilt = (rms)!=0 ? workDsma[i][s+_ssm] / rms : 1;
      double _alpha = MathAbs(_scaledFilt)*5 / period;
      workDsma[i][s+_dsm] = (i>0) ? workDsma[i-1][s+_dsm]+_alpha*(price-workDsma[i-1][s+_dsm]) : price;
   return(workDsma[i][s+_dsm]);
}
//
//---
//
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
