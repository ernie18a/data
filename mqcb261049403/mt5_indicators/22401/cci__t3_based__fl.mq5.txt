//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_label1  "up level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "down level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_DOT
#property indicator_label3  "middle level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_DOT
#property indicator_label4  "value"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrLimeGreen,clrOrange
#property indicator_width4  2
//
//---
//
enum enT3Type
  {
   t3_tillson, // Tim Tillson way of calculation
   t3_fulksmat // Fulks/Matulich way of calculation
  };
input int                inpCciPeriod       = 32;            // CCI period
input ENUM_APPLIED_PRICE inpCciPrice        = PRICE_TYPICAL; // Price
input double             inpT3Hot           = 0.7;           // T3 "hot"
input enT3Type           inpT3Type          = t3_fulksmat;   // T3 type
input int                inpSmoothPeriod    = 10;            // Smoothing period
input double             inpSmoothT3Hot     = 0.7;           // Smoothing T3 "hot"
input enT3Type           inpSmoothT3Type    = t3_fulksmat;   // Smoothing T3 type
input int                inpFlPeriod        = 32;            // Floating levels period
input double             inpFlLevelUp       = 80.0;          // Up level %
input double             inpFlLevelDown     = 20.0;          // Down level %
//
//---
//
double  val[],valc[],levelUp[],levelDn[],levelMi[];
//------------------------------------------------------------------
//
//------------------------------------------------------------------
void OnInit()
  {
   SetIndexBuffer(0,levelUp,INDICATOR_DATA);
   SetIndexBuffer(1,levelDn,INDICATOR_DATA);
   SetIndexBuffer(2,levelMi,INDICATOR_DATA);
   SetIndexBuffer(3,val,INDICATOR_DATA);
   SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI - T3 based - fl ("+(string)inpCciPeriod+")");
  }
//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double _price = iT3(getPrice(inpCciPrice,open,close,high,low,i,rates_total),inpSmoothPeriod,inpSmoothT3Hot,inpSmoothT3Type==t3_tillson,i,1);
      double avg    = iT3(_price,inpCciPeriod,inpT3Hot,inpT3Type==t3_tillson,i,0);
      double dev    = MathMax(iEmaDeviation(_price,inpCciPeriod,i),DBL_MIN);

      //
      //---
      //

      val[i] = (_price-avg)/(0.015*dev);
            int _start = MathMax(i-inpFlPeriod+1,0);
            double min = val[ArrayMinimum(val,_start,inpFlPeriod)];
            double max = val[ArrayMaximum(val,_start,inpFlPeriod)];
            double range = max-min;
            levelUp[i] = min+inpFlLevelUp  *range/100.0;
            levelDn[i] = min+inpFlLevelDown*range/100.0;
            levelMi[i] = min+50            *range/100.0;
      valc[i] = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1]: 0 : 0;
     }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
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
   if(ArrayRange(workT3Coeffs,0)<(instance+1)) ArrayResize(workT3Coeffs,instance+1);
   if(workT3Coeffs[instance][_period]!=period)
   {
      workT3Coeffs[instance][_period]= period;
      workT3Coeffs[instance][_c1]    = -hot*hot*hot;
      workT3Coeffs[instance][_c2]    = 3*hot*hot+3*hot*hot*hot;
      workT3Coeffs[instance][_c3]    = -6*hot*hot-3*hot-3*hot*hot*hot;
      workT3Coeffs[instance][_c4]    = 1+3*hot+hot*hot*hot+3*hot*hot;
      workT3Coeffs[instance][_alpha] = (original) ? 2.0/(1.0+period) : 2.0/(2.0+(period-1.0)/2.0);
   }
   
   //
   //
   //
   
      int _indP = (i-1)%_t3RingSize;
      int _indC = (i  )%_t3RingSize;
      int _inst = instance*_t3InstancesSize;
   
      for(int k=0; k<_t3InstancesSize; k++) workT3[_indC][k+_inst]=(i>0) ? workT3[_indP][k+_inst]: price;
      if(i>0 && period>1)
      {
         workT3[_indC][_inst  ] = workT3[_indP][_inst  ]+workT3Coeffs[instance][_alpha]*(price                 -workT3[_indP][_inst  ]);
         workT3[_indC][_inst+1] = workT3[_indP][_inst+1]+workT3Coeffs[instance][_alpha]*(workT3[_indC][_inst  ]-workT3[_indP][_inst+1]);
         workT3[_indC][_inst+2] = workT3[_indP][_inst+2]+workT3Coeffs[instance][_alpha]*(workT3[_indC][_inst+1]-workT3[_indP][_inst+2]);
         workT3[_indC][_inst+3] = workT3[_indP][_inst+3]+workT3Coeffs[instance][_alpha]*(workT3[_indC][_inst+2]-workT3[_indP][_inst+3]);
         workT3[_indC][_inst+4] = workT3[_indP][_inst+4]+workT3Coeffs[instance][_alpha]*(workT3[_indC][_inst+3]-workT3[_indP][_inst+4]);
         workT3[_indC][_inst+5] = workT3[_indP][_inst+5]+workT3Coeffs[instance][_alpha]*(workT3[_indC][_inst+4]-workT3[_indP][_inst+5]);
      }
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
#define _edevInstances 1
#define _edevInstancesSize 2
#define _edevRingSize 5
double workEmaDeviation[_edevRingSize][_edevInstances*_edevInstancesSize];
#define _ema0 0
#define _ema1 1
//
//---
//
double iEmaDeviation(double price,double period, int i, int instanceNo=0)
{
   
   
   int _indP = (i-1)%_edevRingSize;
   int _indC = (i  )%_edevRingSize;
   instanceNo *= _edevInstancesSize;   
   
   workEmaDeviation[_indC][instanceNo+_ema0] = price;
   workEmaDeviation[_indC][instanceNo+_ema1] = price;
   if (i>0 && period>1)
   {
      double alpha = 2.0/(1.0+period);
         workEmaDeviation[_indC][instanceNo+_ema0] = workEmaDeviation[_indP][instanceNo+_ema0]+alpha*(price      -workEmaDeviation[_indP][instanceNo+_ema0]);
         workEmaDeviation[_indC][instanceNo+_ema1] = workEmaDeviation[_indP][instanceNo+_ema1]+alpha*(price*price-workEmaDeviation[_indP][instanceNo+_ema1]);
   }         
   return(MathSqrt(period*(workEmaDeviation[_indC][instanceNo+_ema1]-workEmaDeviation[_indC][instanceNo+_ema0]*workEmaDeviation[_indC][instanceNo+_ema0])/MathMax(period-1,1)));
}
//
//---
//
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
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
