//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Discontinued signal line super smoother synthetic momentum"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   4
#property indicator_label1  "no trend zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro,clrGainsboro
#property indicator_label2  "no trend zone up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "no trend zone down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Momentum"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrDodgerBlue,clrDeepPink
#property indicator_width4  2
//--- input parameters
input int                inpPeriod1  = 5;           // Period 1
input int                inpPeriod2  = 20;          // Period 2
input int                inpPeriod3  = 50;          // Period 3
input int                inpPeriod4  = 100;         // Period 4
input int                inpPeriod5  = 200;         // Period 5
input int                inpSignal   = 20;          // DSL signal period
input ENUM_APPLIED_PRICE inpPrice    = PRICE_CLOSE; // Price
//--- buffers and global variables declarations
double val[],valc[],dslup[],dsldn[],dslupl[],dsldnl[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,dslup,INDICATOR_DATA);
   SetIndexBuffer(1,dsldn,INDICATOR_DATA);
   SetIndexBuffer(2,dslupl,INDICATOR_DATA);
   SetIndexBuffer(3,dsldnl,INDICATOR_DATA);
   SetIndexBuffer(4,val,INDICATOR_DATA);
   SetIndexBuffer(5,valc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"DSL Synthetic super smoother momentum ("+(string)inpPeriod1+","+(string)inpPeriod2+","+(string)inpPeriod3+","+(string)inpPeriod4+","+(string)inpPeriod5+","+(string)inpSignal+")");
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
   double _coeff1 = double(inpPeriod5/inpPeriod4);
   double _coeff2 = double(inpPeriod5/inpPeriod3);
   double _coeff3 = double(inpPeriod5/inpPeriod2);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
   {
      double _price = getPrice(inpPrice,open,close,high,low,i);
      double _avg   = iSuperSmoother(_price, inpPeriod1,i,0);
      double _avg1  = iSuperSmoother(_price, inpPeriod2,i,1); double _mom1 = 100.*(_avg-_avg1)/_avg1;
      double _avg2  = iSuperSmoother(_price, inpPeriod3,i,2); double _mom2 = 100.*(_avg-_avg2)/_avg2;
      double _avg3  = iSuperSmoother(_price, inpPeriod4,i,3); double _mom3 = 100.*(_avg-_avg3)/_avg3;
      double _avg4  = iSuperSmoother(_price, inpPeriod5,i,4); double _mom4 = 100.*(_avg-_avg4)/_avg4;
      val[i]  = (_mom4 +_mom3*_coeff1+_mom2*_coeff2+_mom1*_coeff3)/4.0;
      dslupl[i] = dslup[i] = iSuperSmoother(val[i],inpSignal,i,5,val[i]<0);
      dsldnl[i] = dsldn[i] = iSuperSmoother(val[i],inpSignal,i,6,val[i]>0);
      valc[i] = (val[i]>dslupl[i]) ? 1 :(val[i]<dsldnl[i]) ? 2 : 0;
   }
   return (i);
}
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _ssmInstances 7
#define _ssmInstancesSize 2
#define _ssmRingSize 6
double workSsm[_ssmRingSize][_ssmInstances*_ssmInstancesSize];
#define _price 0
#define _ssm   1
//
//---
//
double workSsmCoeffs[][4];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
//
//---
//
double iSuperSmoother(double price, double period, int i, int instance=0, bool copy=false)
{
   int _indP = (i-1)%_ssmRingSize;
   int _indC = (i  )%_ssmRingSize;
   int _inst = instance*_ssmInstancesSize;
   
   //
   //--
   //
   
      if(!copy && i>1 && period>1)
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
            workSsm[_indC][_inst+_price] = price;
            workSsm[_indC][_inst+_ssm]   = workSsmCoeffs[instance][_c1]*(price+workSsm[_indP][_inst+_price])/2.0 + 
                                           workSsmCoeffs[instance][_c2]*       workSsm[_indP][_inst+_ssm]                                + 
                                           workSsmCoeffs[instance][_c3]*       workSsm[_indO][_inst+_ssm];
      }                                      
      else for(int k=0; k<_ssmInstancesSize; k++) workSsm[_indC][_inst+k]= (i>0) ? workSsm[_indP][_inst+k] : price;
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
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i)
  {
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
