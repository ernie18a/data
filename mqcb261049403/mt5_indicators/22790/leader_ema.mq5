//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Leader EMA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "EMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Leader EMA"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrGreen,clrDeepPink
#property indicator_width2  2

//
//--- input parameters
//

enum enColorMode
{
   cm_onSlope, // Change color on slope change
   cm_onCross  // Change color on leader ema to ema cross
};
input double             inpPeriod    = 14;          // EMA cycles period
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price
input enColorMode        inpColorMode = cm_onSlope;  // Color mode

//
//--- indicator buffers
//

double val[],valc[],ema[],emaw[];
double ª_alpha; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   SetIndexBuffer(0,ema ,INDICATOR_DATA);
   SetIndexBuffer(1,val ,INDICATOR_DATA);
   SetIndexBuffer(2,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,emaw,INDICATOR_CALCULATIONS);
         ª_alpha = 2.0/(1.0+inpPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME,"Leader EMA ("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
// Custom iteration function
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

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
         ema[i]  = (i>0) ? ema[i-1] +ª_alpha*(_price-ema[i-1]) : _price;
         emaw[i] = (i>0) ? emaw[i-1]+ª_alpha*(_price-ema[i]-emaw[i-1]) : _price;
         val[i]  = ema[i]+emaw[i];
         if (inpColorMode==cm_onSlope)
               valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
         else  valc[i] = (val[i]>ema[i]) ? 1 : (val[i]<ema[i]) ? 2 : (i>0) ? valc[i-1] : 0;
   }
   return(i);
}