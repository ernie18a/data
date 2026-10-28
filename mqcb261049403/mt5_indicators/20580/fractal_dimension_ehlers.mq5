//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Fractal dimension Ehlers"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Fractal dimension"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
//--- input parameters
input int                inpFdiPeriod    =  30;         // Fractal dimension period
input double             inpFdiThreshold =  1.4;        // Fractal dimension threshold
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE; // Price 
//--- buffers declarations
double val[],valc[],wrk[][3];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,inpFdiThreshold);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Fractal dimension (Ehlers) ("+(string)inpFdiPeriod+","+(string)inpFdiThreshold+")");
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
#define _price  0
#define _smooth 1
#define _ratio  2
//
//---
//
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
   if(ArrayRange(wrk,0)!=rates_total) ArrayResize(wrk,rates_total);
//
//---
//   
   double  log2=MathLog(2.0);
   int _fullSize = MathMax(inpFdiPeriod,2); if(MathMod(_fullSize,2)>0) _fullSize++;
   int _halfSize = _fullSize/2;
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      wrk[i][_price]  = getPrice(inpPrice,open,close,high,low,i,rates_total);
      wrk[i][_smooth] = (i>2) ? (wrk[i][_price]+2.0*wrk[i-1][_price]+2.0+wrk[i-2][_price]+wrk[i-3][_price])/6.0 : wrk[i][_price];

      //
      //---
      //

      double hh = wrk[i][_smooth];
      double ll = wrk[i][_smooth];
      for(int n=1; n<_fullSize && (i-n)>=0; n++)
        {
         hh = MathMax(hh,wrk[i-n][_smooth]);
         ll = MathMin(ll,wrk[i-n][_smooth]);
        }
      double n3=(hh-ll)/_fullSize;
      hh = wrk[i][_smooth];
      ll = wrk[i][_smooth];
      for(int n=1; n<_halfSize && (i-n)>=0; n++)
        {
         hh = MathMax(hh,wrk[i-n][_smooth]);
         ll = MathMin(ll,wrk[i-n][_smooth]);
        }
      double n1=(hh-ll)/_halfSize;
      hh = (i>=_halfSize) ? wrk[i-_halfSize][_smooth] : wrk[i][_smooth];
      ll = (i>=_halfSize) ? wrk[i-_halfSize][_smooth] : wrk[i][_smooth];
      for(int n=_halfSize+1; n<_fullSize && (i-n)>=0; n++)
        {
         hh = MathMax(hh,wrk[i-n][_smooth]);
         ll = MathMin(ll,wrk[i-n][_smooth]);
        }
      double n2=(hh-ll)/_halfSize;

      //
      //
      //
      //
      //

      if(n1>0 && n2>0 && n3>0)
         wrk[i][_ratio] = (i>0) ? 0.5*((MathLog(n1+n2)-MathLog(n3))/log2 + val[i-1]) : (MathLog(n1+n2)-MathLog(n3))/log2;
      else  wrk[i][_ratio] = (i>0) ? wrk[i-1][_ratio] : 0;

      double avg=wrk[i][_ratio];
      for(int n=1; n<20 && (i-n)>=0; n++) avg+=wrk[i-n][_ratio];
      avg/=20;
      val[i]=avg;
      valc[i]=(val[i]>inpFdiThreshold) ? 1 : 2;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
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
