//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "AMA"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
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

double val[],valc[],g_fastEnd,g_slowEnd; int g_hlPeriod;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------ 
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
            g_fastEnd  = 2.0/(inpFastPeriod+1.0);   
            g_slowEnd  = 2.0/(inpSlowPeriod+1.0);   
            g_hlPeriod = inpPeriod+1;
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"AMA ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}

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
   static int    prev_i=-1;
   static double prev_max,prev_min;

   //
   //
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      if (prev_i!=i)
         {
            prev_i = i; 
            int start    = i-g_hlPeriod+1; if (start<0) start=0;
                prev_max = high[ArrayMaximum(high,start,g_hlPeriod-1)];
                prev_min = low [ArrayMinimum(low ,start,g_hlPeriod-1)];
         }
         double max = (high[i] > prev_max) ? high[i] : prev_max;
         double min = (low[i]  < prev_min) ? low[i]  : prev_min;

         //
         //---
         //

         double mltp = (max!=min) ? ((_price-min)-(max-_price))/(max-min) : 1; if (mltp<0) mltp *= -1;
         double ssc  = mltp * ( g_fastEnd-g_slowEnd) + g_slowEnd;	
	
         //
         //---
         //

      val[i] = (i>0) ? val[i-1]+(ssc*ssc)*(_price-val[i-1]) : _price;
      valc[i]=(i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
   }
   return(i);
}