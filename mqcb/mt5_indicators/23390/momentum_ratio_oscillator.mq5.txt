//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Momentum ratio oscillator"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "Oscillator"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrDarkOrange
#property indicator_width1  2
#property indicator_level1  1
#property indicator_level2  0.8
#property indicator_level3  0.2
#property indicator_maximum 1.1
#property indicator_minimum -.1

//
//---
//

input int                inpPeriod = 50;          // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price

//
//---
//

double val[],valc[],ema[],emaa[],emab[],ª_alpha; 
;

//------------------------------------------------------------------ 
//  Custom indicator initialization function
//------------------------------------------------------------------

void OnInit()
{
   //
   //---- indicator buffers mapping
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,ema ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,emaa,INDICATOR_CALCULATIONS);
         SetIndexBuffer(4,emab,INDICATOR_CALCULATIONS);
            ª_alpha = 2.0/(1.0*inpPeriod);
   //            
   //----
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Momentum ratio oscillator ("+(string)inpPeriod+")");
}

//------------------------------------------------------------------
//  Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_where,_index) { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _where = close[_index];                                              break; \
      case PRICE_OPEN:     _where = open[_index];                                               break; \
      case PRICE_HIGH:     _where = high[_index];                                               break; \
      case PRICE_LOW:      _where = low[_index];                                                break; \
      case PRICE_MEDIAN:   _where = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _where = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _where = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _where = 0; \
   }}

//
//---
//


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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      if (i>0)
      {
         ema[i] = ema[i-1] + ª_alpha*(_price-ema[i-1]);
            
               double ratioa = ema[i]/ema[i-1];

         emaa[i] = emaa[i-1] + ª_alpha*((ratioa<1.0 ? ratioa : 0)-emaa[i-1]);
         emab[i] = emab[i-1] + ª_alpha*((ratioa>1.0 ? ratioa : 0)-emab[i-1]);
            
               double ratiob = ratioa/(ratioa + emab[i]);
            
         val[i]  = 2.0*ratioa/(ratioa + ratiob*emaa[i]) - 1.0;
         valc[i] = (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1];
      }
      else { ema[i] = _price; emaa[i] = emab[i] = val[i] = valc[i] = 0; }
   }
   return(i);
}