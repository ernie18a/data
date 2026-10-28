//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Simple Harmonic Index"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2

//
//
//

input int                 inpPeriod   = 14;          // Period 
input ENUM_APPLIED_PRICE  inpPrice    = PRICE_CLOSE; // Price

double val[],work1[],prices[],_alpha;

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
         SetIndexBuffer(1,prices,INDICATOR_CALCULATIONS);
         SetIndexBuffer(2,work1 ,INDICATOR_CALCULATIONS);
            _alpha = 2.0/(1.0+(inpPeriod>1 ? inpPeriod : 1));
   //
   //---
   //

   IndicatorSetString(INDICATOR_SHORTNAME,"Simple Harmonic Index ("+(string)inpPeriod+")");
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
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,prices[i],i);
         if (i>1)
         {
            double _vt = prices[i  ]-prices[i-1];
            double _vy = prices[i-1]-prices[i-2];
            double _acceleration = _vt - _vy;
               work1[i] = work1[i-1] + _alpha*(_acceleration-work1[i-1]);
            double _t   = 2.0*M_PI*MathSqrt(MathAbs(_vt/work1[i]));
               val[i]   = val[i-1] + _alpha*((prices[i]>prices[i-1] ? _t : -_t)-val[i-1]);
         }
         else val[i] = work1[i] = 0;
   }               
   return(i);        
}