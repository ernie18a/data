//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Standard deviation ratio adaptive EMA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Standard deviation"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrMediumSeaGreen
#property indicator_width1  2

//
//--- input parameters
//

input int                inpPeriod  = 20;          // Ema period
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price

//
//--- indicator buffers
//
double val[],valc[];
double ª_alpha;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
            ª_alpha = 2.0/(1.0+inpPeriod);
   //
   //--- indicator short name assignment
   //
         IndicatorSetString(INDICATOR_SHORTNAME,"Standard deviation ratio EMA ("+(string)inpPeriod+")");
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

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
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
      double _price; _setPrice(inpPrice,_price,i);
      val[i]  = (i>0) ? (val[i-1]) +(ª_alpha/iStandardDeviationRatio(_price,inpPeriod,2*inpPeriod,i,rates_total))*(_price-val[i-1]) : _price;
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

#define _checkArrayReserve 500
#define _checkArraySize(_arrayName,_ratesTotal)                            \
     static bool _arrayError     = false;                                  \
   { static int  _arrayResizedTo = 0;                                      \
             if (_arrayResizedTo<_ratesTotal)                              \
             {                                                             \
                  int _res = (_ratesTotal+_checkArrayReserve);             \
                      _res -= ArrayResize(_arrayName,_res);                \
                  if (_res)                                                \
                        _arrayError     = true;                            \
                  else {_arrayResizedTo = _ratesTotal+_checkArrayReserve;  \
              }}                                                           \
   }

//
//---
//

double iStandardDeviationRatio(double price, int shortPeriod, int longPeriod, int i, int bars, int _instance=0)
{
   //
   //---
   //
   
      #define _functionInstancesArraySize 6
      #ifdef  _functionInstances
            static double _workArray[][_functionInstancesArraySize*_functionInstances];
      #else static double _workArray[][_functionInstancesArraySize];
      #endif
            _checkArraySize(_workArray,bars); 

      //
      //---
      //
                  
         #ifdef _functionInstances 
                   int _winst = _instance*_functionInstancesArraySize; 
         #else #define _winst   _instance
         #endif
         #define _price   _winst
         #define _price2  _winst+1
         #define _sum1    _winst+2
         #define _sum12   _winst+3
         #define _sum2    _winst+4
         #define _sum22   _winst+5
      
   //
   //---
   //
      
      _workArray[i][_price] =price;
      _workArray[i][_price2]=price*price;
      if (i>shortPeriod)
            {
               _workArray[i][_sum1]  = _workArray[i-1][_sum1 ]+price      -_workArray[i-shortPeriod][_price];
               _workArray[i][_sum12] = _workArray[i-1][_sum12]+price*price-_workArray[i-shortPeriod][_price2];
            }
      else  {
               _workArray[i][_sum1]  = _workArray[i][_price];
               _workArray[i][_sum12] = _workArray[i][_price2]; 
               for(int k=1; k<shortPeriod && i>=k; k++) 
               {
                  _workArray[i][_sum1]  += _workArray[i-k][_price]; 
                  _workArray[i][_sum12] += _workArray[i-k][_price2]; 
               }                  
            }         
      if (i>longPeriod)
            {
               _workArray[i][_sum2]  = _workArray[i-1][_sum2 ]+price      -_workArray[i-longPeriod][_price];
               _workArray[i][_sum22] = _workArray[i-1][_sum22]+price*price-_workArray[i-longPeriod][_price2];
            }
      else  {
               _workArray[i][_sum2]  = _workArray[i][_price];
               _workArray[i][_sum22] = _workArray[i][_price2]; 
               for(int k=1; k<longPeriod && i>=k; k++) 
               {
                  _workArray[i][_sum2]  += _workArray[i-k][_price]; 
                  _workArray[i][_sum22] += _workArray[i-k][_price2]; 
               }                  
            }         
   double shortDeviation = MathSqrt((_workArray[i][_sum12]-_workArray[i][_sum1]*_workArray[i][_sum1]/(double)shortPeriod)/(double)shortPeriod);
   double longDeviation  = MathSqrt((_workArray[i][_sum22]-_workArray[i][_sum2]*_workArray[i][_sum2]/(double)longPeriod) /(double)longPeriod);
   return (i>longPeriod ? shortDeviation/longDeviation : 1);

   //
   //---
   //
            
   #undef _price #undef _price2 #undef _sum1 #undef _sum2 #undef _sum12 #undef _sum22
   #undef _functionInstances #undef _functionInstancesArraySize
}
//+------------------------------------------------------------------+
