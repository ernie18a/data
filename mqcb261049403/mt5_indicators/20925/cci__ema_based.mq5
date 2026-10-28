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
input int                inpCciPeriod       = 32;            // CCI period
input ENUM_APPLIED_PRICE inpCciPrice        = PRICE_TYPICAL; // Price
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
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI - ema based ("+(string)inpCciPeriod+")");
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
      double _price=getPrice(inpCciPrice,open,close,high,low,i,rates_total);
      double avg = iEma(_price,inpCciPeriod,i,rates_total);
      double dev = iEmaDeviation(_price,inpCciPeriod,i,rates_total);

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
#define _emaInstances 1
double workEma[][_emaInstances];
//
//---
//
double iEma(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=bars) ArrayResize(workEma,bars);

//
//---
//

   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
  }
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
double iEmaDeviation(double price,double period,int i,int bars,int instanceNo=0)
  {
   if(ArrayRange(workEmaDeviation,0)!=bars) ArrayResize(workEmaDeviation,bars); instanceNo*=_edevInstancesSize;

   workEmaDeviation[i][instanceNo+_ema0] = price;
   workEmaDeviation[i][instanceNo+_ema1] = price;
   if(i>0 && period>1)
     {
      double alpha=2.0/(1.0+period);
      workEmaDeviation[i][instanceNo+_ema0] = workEmaDeviation[i-1][instanceNo+_ema0]+alpha*(price      -workEmaDeviation[i-1][instanceNo+_ema0]);
      workEmaDeviation[i][instanceNo+_ema1] = workEmaDeviation[i-1][instanceNo+_ema1]+alpha*(price*price-workEmaDeviation[i-1][instanceNo+_ema1]);
     }
   return(MathSqrt(period*(workEmaDeviation[i][instanceNo+_ema1]-workEmaDeviation[i][instanceNo+_ema0]*workEmaDeviation[i][instanceNo+_ema0])/MathMax(period-1,1)));
  }
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
