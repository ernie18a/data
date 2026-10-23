//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "Shadow"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_width1  6
#property indicator_label2  "Super smoother"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrLimeGreen,clrDarkOrange
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Corrected Super smoother"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrLimeGreen,clrDarkOrange
#property indicator_width3  2
//
//--- input parameters
//
input double             inpPeriod = 14;           // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE;  // Price
//
//--- indicator buffers
//
double val[],valc[],vals[],avg[],avgc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,vals,INDICATOR_DATA);
   SetIndexBuffer(1,avg,INDICATOR_DATA);
   SetIndexBuffer(2,avgc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,val,INDICATOR_DATA);
   SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Corrected super smoother ("+(string)inpPeriod+")");
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
      double _price = getPrice(inpPrice,open,close,high,low,i);
      avg[i]  = iSuperSmoother(_price,inpPeriod,i);
      val[i]  = iCorrMaEmaDev(avg[i],_price,(int)inpPeriod,i);
      valc[i] = (i>0) ?(val[i]<avg[i]) ? 1 :(val[i]>avg[i]) ? 2 : valc[i-1]: 0;
      avgc[i] = valc[i];
      vals[i] = val[i];
   }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _corrMaInstances 1
#define _corrMaInstancesSize 5
#define _corrMaRingSize 5
double workCorrMa[_corrMaRingSize][_corrMaInstances*_corrMaInstancesSize];
#define _price 0
#define _orig  1
#define _corr  2
#define _ema0  3
#define _ema1  4
//
//---
//
double iCorrMaEmaDev(double _avg, double price, int period, int i, int instance=0)
{
   int _indP = (i-1)%_corrMaRingSize;
   int _indC = (i  )%_corrMaRingSize;
   int _inst = instance*_corrMaInstancesSize;
   
      //
      //---
      //
      
      workCorrMa[_indC][_inst+_orig]  = _avg;
      workCorrMa[_indC][_inst+_price] = price;
      if (i>0 && period>1)
      {
         double alpha = 2.0/(1.0+period);
         workCorrMa[_indC][_inst+_ema0] = workCorrMa[_indP][_inst+_ema0]+alpha*(price      -workCorrMa[_indP][_inst+_ema0]);
         workCorrMa[_indC][_inst+_ema1] = workCorrMa[_indP][_inst+_ema1]+alpha*(price*price-workCorrMa[_indP][_inst+_ema1]);
      }         
      else for (int k=3; k<_corrMaInstancesSize; k++) workCorrMa[_indC][_inst+k] = price;

      //
      //---
      //
      
      double _deviation = MathMax(MathSqrt(period*(workCorrMa[_indC][_inst+_ema1]-workCorrMa[_indC][_inst+_ema0]*workCorrMa[_indC][_inst+_ema0])/MathMax(period-1,1)),DBL_MIN);
      double v1         = MathPow(_deviation,2);
      double v2         = (i>0) ? MathPow(workCorrMa[_indP][_inst+_corr]-workCorrMa[_indC][_inst+_orig],2) : 0;
      double c          = (v2<v1 || v2==0) ? 0 : 1-v1/v2;
          workCorrMa[_indC][_inst+_corr] = (i>0) ? workCorrMa[_indP][_inst+_corr]+c*(workCorrMa[_indC][_inst+_orig]-workCorrMa[_indP][_inst+_corr]) : workCorrMa[_indC][_inst+_orig];
   return(workCorrMa[_indC][_inst+_corr]);
   #undef _price
   #undef _orig
   #undef _corr
   #undef _ema0
   #undef _ema1
}
//
//---
//
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
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i)
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
