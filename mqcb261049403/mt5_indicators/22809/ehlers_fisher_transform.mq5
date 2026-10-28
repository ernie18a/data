//------------------------------------------------------------------
#property copyright    "© mladen, 2018"
#property link         "mladenfx@gmail.com"
#property version      "1.00"
#property description  "."
#property description  "Ehlers fisher transform"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "ft"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrGreen,clrCrimson
#property indicator_width1  2

//
//---
//

input int                inpPeriod        =  14;         // Period
input ENUM_APPLIED_PRICE inpPrice         = PRICE_CLOSE; // Price 

//
//---
//

double val[],valc[],prices[],work[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,val    ,INDICATOR_DATA);
         SetIndexBuffer(1,valc   ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,prices ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,work   ,INDICATOR_CALCULATIONS);
   //---
         IndicatorSetString(INDICATOR_SHORTNAME,"Ehlers fisher transform ("+(string)inpPeriod+")");
   return(0);
}

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
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,prices[i],i);

      // 
      //---
      //

      int _start = i>inpPeriod ? i-inpPeriod+1 : 0;
         double _max = prices[ArrayMaximum(prices,_start,inpPeriod)];
         double _min = prices[ArrayMinimum(prices,_start,inpPeriod)];
      
         work[i] = (i>0) ? (_max!=_min) ? 0.333*2.0*((prices[i]-_min)/(_max-_min)-0.5)+0.667*work[i-1] : 0 : 0;
         work[i] = (work[i]>0.999) ? 0.999 : (work[i]<-0.999) ? -0.999 : work[i];
         val[i]  = (i>0) ? 0.5*MathLog((1.0+work[i])/(1.0-work[i]))+0.5*val[i-1] : 0;      
         valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : 0 : 0;
   }
   return(i);
}