//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "up level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "down level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_DOT
#property indicator_label3  "value"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrLimeGreen,clrOrange
#property indicator_width3  2
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
input double             inpLevelUp         =  100;          // Level up
input double             inpLevelDown       = -100;          // Level down
                                                             //
//---
//
double  val[],valc[],levelUp[],levelDn[];
//------------------------------------------------------------------
//
//------------------------------------------------------------------
void OnInit()
  {
   SetIndexBuffer(0,levelUp,INDICATOR_DATA);
   SetIndexBuffer(1,levelDn,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI - T3 based ("+(string)inpCciPeriod+")");
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double _price = iT3(getPrice(inpCciPrice,open,close,high,low,i,rates_total),inpSmoothPeriod,inpSmoothT3Hot,inpSmoothT3Type==t3_tillson,i,rates_total,1);
      double avg    = iT3(_price,inpCciPeriod,inpT3Hot,inpT3Type==t3_tillson,i,rates_total,0);
      double dev    = iEmaDeviation(_price,inpCciPeriod,i,rates_total);

      //
      //---
      //

      val[i]=(dev!=0) ?(_price-avg)/(0.015*dev) : 0;
      levelUp[i] = inpLevelUp;
      levelDn[i] = inpLevelDown;
      valc[i]    = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1]: 0 : 0;
     }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _t3Instances     2
#define _t3InstancesSize 6
double workT3[][_t3Instances*_t3InstancesSize];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5
//
//---
//
double iT3(double price,double period,double hot,bool original,int r,int bars, int instanceNo=0)
  {
   if(ArrayRange(workT3,0)!=bars) ArrayResize(workT3,bars);
   if(ArrayRange(workT3Coeffs,0)<(instanceNo+1)) ArrayResize(workT3Coeffs,instanceNo+1); if (period<=1) return(price);
   if(workT3Coeffs[instanceNo][_period]!=period)
     {
      workT3Coeffs[instanceNo][_period]=period;
      workT3Coeffs[instanceNo][_c1] = -hot*hot*hot;
      workT3Coeffs[instanceNo][_c2] = 3*hot*hot+3*hot*hot*hot;
      workT3Coeffs[instanceNo][_c3] = -6*hot*hot-3*hot-3*hot*hot*hot;
      workT3Coeffs[instanceNo][_c4] = 1+3*hot+hot*hot*hot+3*hot*hot;
      if(original)
            workT3Coeffs[instanceNo][_alpha]=2.0/(1.0+period);
      else  workT3Coeffs[instanceNo][_alpha]=2.0/(2.0+(period-1.0)/2.0);
     }
   //---
   int buffer=instanceNo*_t3InstancesSize;
   for(int k=0; k<6; k++) workT3[r][k+buffer]=(r>0) ? workT3[r-1][k+buffer]: price;
   if(r>0 && period>1)
     {
      workT3[r][0+buffer] = workT3[r-1][0+buffer]+workT3Coeffs[instanceNo][_alpha]*(price              -workT3[r-1][0+buffer]);
      workT3[r][1+buffer] = workT3[r-1][1+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][0+buffer]-workT3[r-1][1+buffer]);
      workT3[r][2+buffer] = workT3[r-1][2+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][1+buffer]-workT3[r-1][2+buffer]);
      workT3[r][3+buffer] = workT3[r-1][3+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][2+buffer]-workT3[r-1][3+buffer]);
      workT3[r][4+buffer] = workT3[r-1][4+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][3+buffer]-workT3[r-1][4+buffer]);
      workT3[r][5+buffer] = workT3[r-1][5+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][4+buffer]-workT3[r-1][5+buffer]);
     }
   return(workT3Coeffs[instanceNo][_c1]*workT3[r][5+buffer] +
          workT3Coeffs[instanceNo][_c2]*workT3[r][4+buffer]+
          workT3Coeffs[instanceNo][_c3]*workT3[r][3+buffer]+
          workT3Coeffs[instanceNo][_c4]*workT3[r][2+buffer]);
  }
  #undef _c1
  #undef _c2
  #undef _c3
  #undef _c4
//
//---
//
#define _edevInstances 1
#define _edevInstancesSize 2
double workEmaDeviation[][_edevInstances*_edevInstancesSize];
#define _ema0 0
#define _ema1 1
//
//---
//
double iEmaDeviation(double price,double period, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workEmaDeviation,0)!=bars) ArrayResize(workEmaDeviation,bars); instanceNo*=_edevInstancesSize;
   
   workEmaDeviation[i][instanceNo+_ema0] = price;
   workEmaDeviation[i][instanceNo+_ema1] = price;
   if (i>0 && period>1)
   {
      double alpha = 2.0/(1.0+period);
         workEmaDeviation[i][instanceNo+_ema0] = workEmaDeviation[i-1][instanceNo+_ema0]+alpha*(price      -workEmaDeviation[i-1][instanceNo+_ema0]);
         workEmaDeviation[i][instanceNo+_ema1] = workEmaDeviation[i-1][instanceNo+_ema1]+alpha*(price*price-workEmaDeviation[i-1][instanceNo+_ema1]);
   }         
   return(MathSqrt(period*(workEmaDeviation[i][instanceNo+_ema1]-workEmaDeviation[i][instanceNo+_ema0]*workEmaDeviation[i][instanceNo+_ema0])/MathMax(period-1,1)));
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
