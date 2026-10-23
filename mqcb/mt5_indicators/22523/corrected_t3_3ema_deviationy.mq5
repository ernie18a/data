//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "T3"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrCrimson,clrGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Corrected T3"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrCrimson,clrGreen
#property indicator_width2  2
//
//--- input parameters
//
enum enT3Type
  {
   t3_tillson, // Tim Tillson way of calculation
   t3_fulksmat // Fulks/Matulich way of calculation
  };
input double             inpPeriod = 10;           // Period
input double             inpHot    = 0.7;          // T3 hot
input enT3Type           inpT3Type = t3_fulksmat;  // T3 type
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE;  // Price
//
//--- indicator buffers
//
double val[],valc[],avg[],avgc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,avg,INDICATOR_DATA);
   SetIndexBuffer(1,avgc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Corrected T3 ("+(string)inpPeriod+")");
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
   bool _original = (inpT3Type==t3_tillson);
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
   {
      double _price = getPrice(inpPrice,open,close,high,low,i);
      avg[i]  = iT3(_price,inpPeriod,inpHot,_original,i);
      val[i]  = iCorrMaEmaDev(avg[i],_price,(int)inpPeriod,i);
      valc[i] = (i>0) ?(val[i]<avg[i]) ? 2 :(val[i]>avg[i]) ? 1 : valc[i-1]: 0;
      avgc[i] = valc[i];
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
#define _t3Instances     2
#define _t3InstancesSize 6
#define _t3RingSize      5
double workT3[_t3RingSize][_t3Instances*_t3InstancesSize];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5
//
//
//
double iT3(double price,double period,double hot,bool original,int i, int instance=0)
{
   int _indP = (i-1)%_t3RingSize;
   int _indC = (i  )%_t3RingSize;
   int _inst = instance*_t3InstancesSize;
   
   //
   //---
   //
   
      if(ArrayRange(workT3Coeffs,0)<(instance+1)) { ArrayResize(workT3Coeffs,instance+1); workT3Coeffs[instance][_period]=-99; }
      if(workT3Coeffs[instance][_period]!=period)
      {
         workT3Coeffs[instance][_period] = period;
         workT3Coeffs[instance][_c1]     = -hot*hot*hot;
         workT3Coeffs[instance][_c2]     = 3*hot*hot+3*hot*hot*hot;
         workT3Coeffs[instance][_c3]     = -6*hot*hot-3*hot-3*hot*hot*hot;
         workT3Coeffs[instance][_c4]     = 1+3*hot+hot*hot*hot+3*hot*hot;
         workT3Coeffs[instance][_alpha]  = (original) ? 2.0/(1.0+period) : 2.0/(2.0+(period-1.0)/2.0);
      }
      if(i>0 && period>1)
      {
         workT3[_indC][  _inst] = workT3[_indP][  _inst]+workT3Coeffs[instance][_alpha]*(price                 -workT3[_indP][  _inst]);
         workT3[_indC][1+_inst] = workT3[_indP][1+_inst]+workT3Coeffs[instance][_alpha]*(workT3[_indC][0+_inst]-workT3[_indP][1+_inst]);
         workT3[_indC][2+_inst] = workT3[_indP][2+_inst]+workT3Coeffs[instance][_alpha]*(workT3[_indC][1+_inst]-workT3[_indP][2+_inst]);
         workT3[_indC][3+_inst] = workT3[_indP][3+_inst]+workT3Coeffs[instance][_alpha]*(workT3[_indC][2+_inst]-workT3[_indP][3+_inst]);
         workT3[_indC][4+_inst] = workT3[_indP][4+_inst]+workT3Coeffs[instance][_alpha]*(workT3[_indC][3+_inst]-workT3[_indP][4+_inst]);
         workT3[_indC][5+_inst] = workT3[_indP][5+_inst]+workT3Coeffs[instance][_alpha]*(workT3[_indC][4+_inst]-workT3[_indP][5+_inst]);
      }
      else for(int k=0; k<_t3InstancesSize; k++) workT3[_indC][k+_inst]= price;

      return(workT3Coeffs[instance][_c1]*workT3[_indC][_inst+5]+
             workT3Coeffs[instance][_c2]*workT3[_indC][_inst+4]+
             workT3Coeffs[instance][_c3]*workT3[_indC][_inst+3]+
             workT3Coeffs[instance][_c4]*workT3[_indC][_inst+2]);

   //
   //
   //

   #undef  _period
   #undef  _c1
   #undef  _c2
   #undef  _c3
   #undef  _c4
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
