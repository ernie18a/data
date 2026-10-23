//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "T3 deviation"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "T3 deviation"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrSkyBlue,clrDodgerBlue
#property indicator_width1  2
//--- input parameters
enum enT3Type
  {
   t3_tillson, // Tim Tillson way of calculation
   t3_fulksmat // Fulks/Matulich way of calculation
  };
input int                inpDevPeriod     = 20;          // Deviation period
input double             inpDevHot        = 0.7;         // Deviation "hot"
input enT3Type           inpDevType       = t3_tillson;  // Deviation T3 type
input ENUM_APPLIED_PRICE inpPrice         = PRICE_CLOSE; // Price
//--- buffers and global variables declarations
double val[],valc[],prices[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"T3 deviation ("+(string)inpDevPeriod+")");
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
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      val[i]  = iT3Deviation(getPrice(inpPrice,open,close,high,low,i,rates_total),inpDevPeriod,inpDevHot,inpDevType==t3_tillson,i,rates_total);
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double t3Values[][36];
double _c1,_c2,_c3,_c4;
//
//---
//
double iT3(double price,int period,bool _original,int i,int bars,int s)
  {
   if(ArrayRange(t3Values,0)!=bars) ArrayResize(t3Values,bars);
//
//---
//

   int r=i;
   t3Values[r][s+0] = price;
   t3Values[r][s+1] = price;
   t3Values[r][s+2] = price;
   t3Values[r][s+3] = price;
   t3Values[r][s+4] = price;
   t3Values[r][s+5] = price;
   if(r>0)
     {
      double n=period; if(!_original) n=1.0+(n-1.0)/2.0;
      double alpha=2.0/(1.0+n);
      t3Values[r][s+0] = t3Values[r-1][s+0]+alpha*(price           -t3Values[r-1][s+0]);
      t3Values[r][s+1] = t3Values[r-1][s+1]+alpha*(t3Values[r][s+0]-t3Values[r-1][s+1]);
      t3Values[r][s+2] = t3Values[r-1][s+2]+alpha*(t3Values[r][s+1]-t3Values[r-1][s+2]);
      t3Values[r][s+3] = t3Values[r-1][s+3]+alpha*(t3Values[r][s+2]-t3Values[r-1][s+3]);
      t3Values[r][s+4] = t3Values[r-1][s+4]+alpha*(t3Values[r][s+3]-t3Values[r-1][s+4]);
      t3Values[r][s+5] = t3Values[r-1][s+5]+alpha*(t3Values[r][s+4]-t3Values[r-1][s+5]);
     }
   return(_c1*t3Values[r][s+5] + _c2*t3Values[r][s+4] + _c3*t3Values[r][s+3] + _c4*t3Values[r][s+2]);
  }
//
//---
//
double t3Valued[][6];
//
//---
//
double iT3Deviation(double price,int period,double _hot,bool _original,int i,int bars)
  {
   if(ArrayRange(t3Valued,0)!=bars) ArrayResize(t3Valued,bars);
   double a  = _hot;
   _c1 = -a*a*a;
   _c2 =  3*(a*a+a*a*a);
   _c3 = -3*(2*a*a+a+a*a*a);
   _c4 = 1+3*a+a*a*a+3*a*a;

//
//---
//
   double n=period; if(!_original) n=1.0+(n-1)/2.0; int r=i;
   double alpha= 2.0/(1.0+n);
   double temp = iT3(price         ,period,_original,i,bars, 0); t3Valued[r][0] = (r>0) ? MathSqrt(alpha*(price         -temp)*(price         -temp)+(1.0-alpha)*t3Valued[r-1][0]*t3Valued[r-1][0]) : 0;
   temp = iT3(t3Valued[r][0],period,_original,i,bars, 6); t3Valued[r][1] = (r>0) ? MathSqrt(alpha*(t3Valued[r][0]-temp)*(t3Valued[r][0]-temp)+(1.0-alpha)*t3Valued[r-1][1]*t3Valued[r-1][1]) : 0;
   temp = iT3(t3Valued[r][1],period,_original,i,bars,12); t3Valued[r][2] = (r>0) ? MathSqrt(alpha*(t3Valued[r][1]-temp)*(t3Valued[r][1]-temp)+(1.0-alpha)*t3Valued[r-1][2]*t3Valued[r-1][2]) : 0;
   temp = iT3(t3Valued[r][2],period,_original,i,bars,18); t3Valued[r][3] = (r>0) ? MathSqrt(alpha*(t3Valued[r][2]-temp)*(t3Valued[r][2]-temp)+(1.0-alpha)*t3Valued[r-1][3]*t3Valued[r-1][3]) : 0;
   temp = iT3(t3Valued[r][3],period,_original,i,bars,24); t3Valued[r][4] = (r>0) ? MathSqrt(alpha*(t3Valued[r][3]-temp)*(t3Valued[r][3]-temp)+(1.0-alpha)*t3Valued[r-1][4]*t3Valued[r-1][4]) : 0;
   temp = iT3(t3Valued[r][4],period,_original,i,bars,30); t3Valued[r][5] = (r>0) ? MathSqrt(alpha*(t3Valued[r][4]-temp)*(t3Valued[r][4]-temp)+(1.0-alpha)*t3Valued[r-1][5]*t3Valued[r-1][5]) : 0;
   return(MathSqrt(n)*(_c1*t3Valued[r][5] + _c2*t3Valued[r][4] + _c3*t3Valued[r][3] + _c4*t3Valued[r][2]));
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
