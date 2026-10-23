//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "AMA - double smoothed"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "AMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//
//

input int                inpPeriod     = 14;          // Period
input int                inpFastPeriod =  2;          // Fast end period
input int                inpSlowPeriod = 30;          // Slow end period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price

//
//---
//

double val[],valw[],valc[],prices[];
int _minMaxPeriod; double _fastEnd,_slowEnd;

//------------------------------------------------------------------
// 
//------------------------------------------------------------------ 
//
//
//

int OnInit()
{
   //
   //
   //
         SetIndexBuffer(0,val   ,INDICATOR_DATA);
         SetIndexBuffer(1,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,valw  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,prices,INDICATOR_CALCULATIONS);
            _minMaxPeriod = inpPeriod>1 ? inpPeriod-1 : 1;
            _fastEnd      = 2.0 /(MathMin(inpFastPeriod,inpPeriod)+1.0);
            _slowEnd      = 2.0 /(MathMax(inpSlowPeriod,inpPeriod)+1.0);
   //
   //
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"AMA ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
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
   static int    prev_i = -1;
   static double prev_max,prev_min;
   
   //
   //
   //
   
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      prices[i] = getPrice(inpPrice,open,high,low,close,i);
         if (prev_i!=i)
         {
            prev_i = i; 
            int start    = i-inpPeriod+1; if (start<0) start=0;
                prev_max = prices[ArrayMaximum(prices,start,_minMaxPeriod)];
                prev_min = prices[ArrayMinimum(prices,start,_minMaxPeriod)];
         }
         double max = (prices[i]>prev_max) ? prices[i] : prev_max;
         double min = (prices[i]<prev_min) ? prices[i] : prev_min;

         //
         //---
         //

         if (i>0)
         {
            double mltp = (max!=min) ? ((prices[i]-min)-(max-prices[i]))/(max-min) : 1; if (mltp<0) mltp *= -1;
            double ssc  = mltp * ( _fastEnd-_slowEnd) + _slowEnd;	
                valw[i] = valw[i-1]+ssc*(prices[i]-valw[i-1]);
                val[i]  = val [i-1]+ssc*(valw[i]  -val [i-1]);
                valc[i] = (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1];
         }
         else { valw[i] = val[i] = prices[i]; valc[i] = 0; }
   }
   return(i);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

template <typename T>
double getPrice(ENUM_APPLIED_PRICE tprice, T& open[], T& high[], T& low[], T& close[], int i)
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
//------------------------------------------------------------------