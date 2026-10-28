//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Simple oscillator - invented by mladen"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_label1  "Trend zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'230,243,230',C'243,230,230'
#property indicator_label2  "Oscillator"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrGreen,clrRed
#property indicator_width2  2

//
//--- input parameters
//

input int                inpLength = 25;           // Oscillator period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE;  // Price

//
//--- buffers and global variables declarations
//

double val[],valc[],levup[],levdn[],prices[];
double ª_weight; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,levup ,INDICATOR_DATA);
         SetIndexBuffer(1,levdn ,INDICATOR_DATA);
         SetIndexBuffer(2,val   ,INDICATOR_DATA);
         SetIndexBuffer(3,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(4,prices,INDICATOR_CALCULATIONS);
                  ª_weight = (inpLength-1.0)/2.0; 
   //---
   IndicatorSetString(INDICATOR_SHORTNAME,"Simple oscillator ("+(string)inpLength+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
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
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,prices[i],i);
      
      //
      //---
      //
   
      double _weight = ª_weight;
         val[i]   = 0; for (int k=0; k<inpLength && i>=k; k++, _weight -=1.0) val[i] += prices[i-k]*_weight;
         levdn[i] = 0; levup[i] = val[i];
         valc[i]  = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
   }
   return (i);
}