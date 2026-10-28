//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Double smoothed Wilders EMA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Double smoothed Wilders EMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//--- input parameters
//

input ENUM_APPLIED_PRICE inpPrice  = PRICE_MEDIAN; // Price
input double             inpPeriod = 14;           // Period

//
//--- indicator buffers
//

double val[],valc[],work[];
double _alpha;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------ 
//
//---
//

int OnInit()
{
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,work,INDICATOR_COLOR_INDEX);
      _alpha = 1.0 /MathSqrt(inpPeriod>1 ? inpPeriod : 1);
   IndicatorSetString(INDICATOR_SHORTNAME,"Double smoothed Wilders EMA ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
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
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price = getPrice(inpPrice,open,close,high,low,i);
      if (i>0)
      {
         work[i] = work[i-1] + _alpha*(_price-work[i-1]);
         val[i]  = val[i-1]  + _alpha*(work[i]-val[i-1]);
         valc[i] = (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1];
      }
      else { work[i] = val[i] = _price; valc[i] = 0; }
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

template <typename T>
double getPrice(ENUM_APPLIED_PRICE tprice, T& open[],T& close[],T& high[], T& low[],int i)
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
//------------------------------------------------------------------+