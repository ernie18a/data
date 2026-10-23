//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Deviation scaled macd"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
#property indicator_label2  "MACD signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_DOT
//--- input parameters
enum enColorOn
{
   color_onZero,  // Change color on MACD zero line cross
   color_onSlope, // Change color on MACD slope change
   color_onSignal // Change color on MACD crossing signal line
};
input int                inpFastPeriod   = 40;          // MACD fast period
input int                inpSlowPeriod   = 100;         // MACD slow period
input int                inpSignalPeriod = 9;           // MACD signal period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE; // Price 
input enColorOn          inpColorOn      = color_onZero; // Color change on :
//--- buffers declarations
double val[],valc[],signal[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,signal,INDICATOR_DATA);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"MACD of deviation scaled MA ("+(string)inpFastPeriod+","+(string)inpSlowPeriod+","+(string)inpSignalPeriod+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double filter = (i>1) ? close[i]-close[i-2] : 0;
      double price  = getPrice(inpPrice,open,close,high,low,i,rates_total);
      val[i]    = iDsma(price,filter,inpFastPeriod,i,rates_total,0)-iDsma(price,filter,inpSlowPeriod,i,rates_total,1);
      filter    = (i>1) ? val[i]-val[i-2] : 0;      
      signal[i] = iDsma(val[i],filter,inpSignalPeriod,i,rates_total,2);
      switch (inpColorOn)
      {
         case color_onSlope  :  valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
         case color_onSignal :  valc[i] = (val[i]>signal[i]) ? 1 :(val[i]<signal[i]) ? 2 : (i>0) ? valc[i-1] : 0; break;
         default :              valc[i] = (val[i]>0) ? 1 :(val[i]<0) ? 2 : (i>0) ? valc[i-1] : 0;
      }         
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _dsmaInstances 3
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