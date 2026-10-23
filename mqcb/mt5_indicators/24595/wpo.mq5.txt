//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Wave period oscillator"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2

//
//
//

input int                 inpPeriod   = 14;          // Period 
input int                 inpHlPeriod =  3;          // Highest price period
input ENUM_APPLIED_PRICE  inpPrice    = PRICE_CLOSE; // Price

double val[],prices[],_alpha;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,val);
         SetIndexBuffer(1,prices);
            _alpha = 2.0/(1.0+(inpPeriod>1 ? inpPeriod : 1));
   //
   //---
   //

   IndicatorSetString(INDICATOR_SHORTNAME,"Wave period oscillator ("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
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
   static double prev_max;

   //
   //---
   //
   
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,prices[i],i);
         if (prev_i!=i)
         {
            prev_i = i; 
            int start    = i-inpHlPeriod+1; if (start<0) start=0;
                prev_max = prices[ArrayMaximum(prices,start,inpHlPeriod-1)];
         }
         double max = (prices[i]>prev_max) ? prices[i] : prev_max;

         //
         //
         //
         
           double _angle = MathArcsin(prices[i]/max);         
           double _wave  = 2.0*M_PI/_angle;
           val[i] = (i>0) ? val[i-1] + _alpha*((prices[i]>prices[i-1] ? _wave : -_wave) - val[i-1]) : 0;
   }               
   return(i);        
}