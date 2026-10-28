//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "Super smoother"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_width1  6
#property indicator_label2  "Super smoother"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrLimeGreen,clrDarkOrange
#property indicator_width2  2
//
//--- input parameters
//
input double             inpPeriod = 27;           // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_MEDIAN; // Price
//
//--- indicator buffers
//
double val[],valc[],vals[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0,vals,INDICATOR_DATA);
   SetIndexBuffer(1,val,INDICATOR_DATA);
   SetIndexBuffer(2,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Super smoother ("+(string)inpPeriod+")");
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
      val[i]  = iSuperSmoother(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,i);
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
      vals[i] = val[i];
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _ssmInstances 1
#define _ssmInstancesSize 2
#define _ssmRingSize 10
double workSsm[_ssmRingSize][_ssmInstances*_ssmInstancesSize];
#define _price 0
#define _ssm   1
double workSsmCoeffs[][4];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
//
//---
//
double iSuperSmoother(double price, double period, int i, int instance=0)
{
   int _indC = (i)%_ssmRingSize;
   int _inst = instance*_ssmInstancesSize;
   
   //
   //--
   //
   
      if(i>1 && period>1)
      {
         if(ArrayRange(workSsmCoeffs,0)<(instance+1)) { ArrayResize(workSsmCoeffs,instance+1); workSsmCoeffs[instance][_period]=-99; }
         if(workSsmCoeffs[instance][_period]!=period)
         {
            double a1 = MathExp(-1.414*M_PI/period);
            double b1 = 2.0*a1*MathCos(1.414*M_PI/period);
               workSsmCoeffs[instance][_c2]     = b1;
               workSsmCoeffs[instance][_c3]     = -a1*a1;
               workSsmCoeffs[instance][_c1]     = 1.0 - workSsmCoeffs[instance][_c2] - workSsmCoeffs[instance][_c3];
               workSsmCoeffs[instance][_period] = period;
         }
         int _indO = (i-2)%_ssmRingSize;
         int _indP = (i-1)%_ssmRingSize;
            workSsm[_indC][_inst+_price] = price;
            workSsm[_indC][_inst+_ssm]   = workSsmCoeffs[instance][_c1]*(price+workSsm[_indP][_inst+_price])/2.0 + 
                                           workSsmCoeffs[instance][_c2]*       workSsm[_indP][_inst+_ssm]                                + 
                                           workSsmCoeffs[instance][_c3]*       workSsm[_indO][_inst+_ssm];
      }                                      
      else for(int k=0; k<_ssmInstancesSize; k++) workSsm[_indC][_inst+k]= price;
   return(workSsm[_indC][_inst+_ssm]);
   
   //
   //---
   //
   
   #undef _period
   #undef _c1
   #undef _c2
   #undef _c3
   #undef _ssm
   #undef _price
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
